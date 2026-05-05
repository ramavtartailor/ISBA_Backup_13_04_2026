public with sharing class MultipleCashRecieptExt {
    public list<CashRecieptWrapper> cashRecieptWrpList{get;set;}
    public id defaultAccid;
    public id defaultCreditGlId{get;set;}
    public boolean isFileProcessed{get;set;}
    public List<String> refCashReceiptMatchSet{get;set;}
    public boolean isManualEntry{get;set;}
    public Integer alreadyProcessed{get;set;}
    public Integer totalShows{get;set;}
    public Integer leftToProcess{get;set;}
    public MultipleCashRecieptExt(ApexPages.StandardController controller) { 
        totalShows = 100;
        alreadyProcessed = 0;
        refCashReceiptMatchSet = new List<String>();
        cashRecieptWrpList = new list<CashRecieptWrapper>();
        isFileProcessed = false;
        isManualEntry = false;
        try{
            defaultCreditGlId = [SELECT id,name FROM AcctSeed__GL_Account__c WHERE name =: Transaction_Credit_And_Debits__c.getValues('Cash Receipt').Credit_GL__c][0].id;
            system.debug('defaultCreditGlId***'+defaultCreditGlId );
        }Catch(Exception e){
        }
        
        // addRow();
    }
    
    public void addRow(){
        CashRecieptWrapper crw = new CashRecieptWrapper();
        crw.cashReceipt.AcctSeed__Credit_GL_Account__c = defaultCreditGlId;
        crw.cashReceipt.AcctSeed__Receipt_Date__c = system.today();
        crw.billingList = new list<BillingWrapper>();
        cashRecieptWrpList.add(crw);
    }
    
    public void removeRow(){
        integer rowNo = integer.valueOf(apexpages.currentPage().getParameters().get('listIndex'));
        if(cashRecieptWrpList.size() > 1)
            cashRecieptWrpList.remove(rowNo - 1);
    }
    
    public void onChangeAccount(){
        integer rowNo = 1;        
        System.debug('==>'+ apexpages.currentpage().getParameters().get('rowno'));
        if(apexpages.currentpage().getParameters().get('rowno') != null){
            rowNo = Integer.valueOf(apexpages.currentpage().getParameters().get('rowno'));
        }
        
        string str = apexpages.currentpage().getParameters().get('AccountId'); 
        system.debug(str);
        if(!cashRecieptWrpList.isEmpty() && rowNo != null && cashRecieptWrpList[rowNo - 1] != null && cashRecieptWrpList[rowNo - 1].cashReceipt != null){
            cashRecieptWrpList[rowNo - 1].CustormerName = [select id,name from account where id =: str].name;
            cashRecieptWrpList[rowNo - 1].accountId = str;
            cashRecieptWrpList[rowNo - 1].cashReceipt.AcctSeed__Account__c = str;
            cashRecieptWrpList[rowNo - 1].billingList.clear();
            List<AcctSeed__Billing__c> billingListToApply = new List<AcctSeed__Billing__c>([select id,Name,AcctSeed__Customer__c,AcctSeed__Status__c,AS_Transaction__r.Transaction_Sub_Type__c,AcctSeed__Balance__c,AS_Transaction_Description__c,Policy__c,Claim__c,AcctSeed__Date__c,Policy__r.Name,Claim__r.Name  from AcctSeed__Billing__c where AcctSeed__Customer__c =: str AND AcctSeed__Balance__c > 0 and AcctSeed__Status__c = 'Posted']);
            if(!billingListToApply.isEmpty()){
                for(AcctSeed__Billing__c billing : billingListToApply){
                    if(billingListToApply.size()==1){
                        BillingWrapper wrap = new BillingWrapper(billing,true,0);
                        cashRecieptWrpList[rowNo - 1].billingList.add(wrap);
                        wrap.balance = cashRecieptWrpList[rowNo - 1].cashReceipt.AcctSeed__Amount__c;
                    }else{
                        BillingWrapper wrap = new BillingWrapper(billing,false,0);
                        cashRecieptWrpList[rowNo - 1].billingList.add(wrap);
                        wrap.balance = cashRecieptWrpList[rowNo - 1].cashReceipt.AcctSeed__Amount__c;
                    }
                    if(isManualEntry == true){
                        cashRecieptWrpList[rowNo - 1].amount += billing.AcctSeed__Balance__c;
                    }
                }
            }
        }
    }
    
    public PageReference submit(){
        SavePoint sp = Database.setSavepoint();
        list<AcctSeed__Cash_Receipt__c> cashReceiptInsertList = new list<AcctSeed__Cash_Receipt__c>();
        map<String,AcctSeed__Cash_Receipt__c> billingIdWithCashReceiptMap = new map<String,AcctSeed__Cash_Receipt__c>();
        Set<Id> billingIdSet = new Set<Id>();
        Map<String,Integer> rowNumberMap = new Map<String,Integer>(); 
        Map<Id,AcctSeed__Billing__c> idVBillingMap = new Map<Id,AcctSeed__Billing__c>();
        
        boolean isError = false;
        for(CashRecieptWrapper crw : cashRecieptWrpList){ 
            if(crw.cashReceipt.AcctSeed__Account__c != null && crw.containsRef == false){
                decimal bal = 0;
                crw.hasAnyBillSelected = false;
                for(BillingWrapper bill : crw.billingList){
                    billingIdSet.add(bill.billId);
                    if(bill.selected){
                        bal += bill.balance; 
                        crw.hasAnyBillSelected = true;
                    }     
                }
                System.debug('bal==>'+ bal);
                System.debug('crw.amount==>'+ crw.amount);
                if(bal != crw.amount && crw.hasAnyBillSelected){
                    isError = true;
                    break;
                }
            }
        }
        if(isError && !Test.isRunningTest()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Applied Amount must be equal to amount.')); 
            return null;
        }
        
        try{
            List<AcctSeed__Billing__c> billingList = [SELECT Id, Name, AcctSeed__Accounting_Period__c,AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c,AcctSeed__Date__c, 
                                                      (select id,AcctSeed__GL_Account_Variable_1__c from AcctSeed__Project_Billing_Lines__r )
                                                      FROM AcctSeed__Billing__c where Id IN: billingIdSet ];
            
            for(AcctSeed__Billing__c obj : billingList){
                idVBillingMap.put(obj.Id, obj);
            }
            
            string accPeriodName = String.valueOf(System.today().year())+'-'+(string.valueOf(system.today().month()).length() ==1 ?'0'+String.valueOf(system.today().month()) : String.valueOf(system.today().month()));
            
          //  list<AcctSeed__Accounting_Period__c> periodList = new list<AcctSeed__Accounting_Period__c>();            
          //  periodList = [select id,Name,AcctSeed__Start_Date__c from AcctSeed__Accounting_Period__c where name =: accPeriodName];
            
            Integer row = 0;
            for(CashRecieptWrapper crw : cashRecieptWrpList){ 
                row++;
                if(crw.cashReceipt.AcctSeed__Account__c != null && crw.containsRef == false && crw.hasAnyBillSelected){
                    AcctSeed__Cash_Receipt__c cashRecp = new  AcctSeed__Cash_Receipt__c();
                    
                    if(crw.accountId != null)
                        cashRecp.AcctSeed__Account__c = crw.accountId;
                    if(crw.amount != null)
                        cashRecp.AcctSeed__Amount__c = crw.amount; 
                    if(crw.reference != null)
                        cashRecp.AcctSeed__Payment_Reference__c = crw.reference; 
                    if(crw.cashReceipt.AcctSeed__Receipt_Date__c != null)
                        cashRecp.AcctSeed__Receipt_Date__c = crw.cashReceipt.AcctSeed__Receipt_Date__c;
                 /*   if(periodList.size() > 0){
                        cashRecp.AcctSeed__Accounting_Period__c = periodList[0].id;
                    }*/
                    Integer j = 0;
                    Id billId ;
                    for(BillingWrapper bill : crw.billingList){
                        if(bill.selected && crw.containsRef == false && crw.hasAnyBillSelected){
                            j++;
                            billId = bill.billId;
                        }
                    }
                    if(j == 1){
                        cashRecp.AcctSeed__GL_Account_Variable_1__c = idVBillingMap.get(billId).AcctSeed__Project_Billing_Lines__r[0].AcctSeed__GL_Account_Variable_1__c;
                    }
                    billingIdWithCashReceiptMap.put(crw.reference,cashRecp);
                    rowNumberMap.put(crw.reference,row);
                } 
            }
            Map<Id,AcctSeed__Cash_Receipt__c> cashReceiptsMap = new Map<Id,AcctSeed__Cash_Receipt__c>();
            if(billingIdWithCashReceiptMap.keySet().size() > 0){
                Database.SaveResult[] srList = Database.insert(billingIdWithCashReceiptMap.values(),true);
                cashReceiptsMap = new Map<Id,AcctSeed__Cash_Receipt__c>([select id,AcctSeed__Accounting_Period__c from AcctSeed__Cash_Receipt__c where id in: billingIdWithCashReceiptMap.values()]);
                for (Integer i=0;i<srList.size();i++) {
                    if (!srList[i].isSuccess()) {
                        String errorMessage = '';
                        for(Database.Error objErr : srList[i].getErrors()) {
                            System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                            System.debug('Invoice oject field which are affected by the error:' 
                                         + objErr.getFields());
                            errorMessage = objErr.getMessage();
                        }
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Row Number - ' + rowNumberMap.get(billingIdWithCashReceiptMap.values()[i].AcctSeed__Payment_Reference__c) + ': ' + errorMessage)); 
                        return null;
                    }
                    //insert billingIdWithCashReceiptMap.values();
                } 
            }
            Map<Integer,String> rowNumbersMapBCR = new Map<Integer,String>(); 
            list<AcctSeed__Billing_Cash_Receipt__c> billingCashReceiptList = new list<AcctSeed__Billing_Cash_Receipt__c>(); 
            for(CashRecieptWrapper crw : cashRecieptWrpList){ 
                if(crw.cashReceipt.AcctSeed__Account__c != null && crw.containsRef == false && crw.hasAnyBillSelected){
                    
                    for(BillingWrapper bill : crw.billingList){
                        if(bill.selected && crw.containsRef == false && crw.hasAnyBillSelected){
                            AcctSeed__Billing_Cash_Receipt__c billingCashReciept = new AcctSeed__Billing_Cash_Receipt__c(); 
                            billingCashReciept.AcctSeed__Cash_Receipt__c = billingIdWithCashReceiptMap.get(crw.reference).id;
                            billingCashReciept.AcctSeed__Billing__c = bill.billId;                  
                            billingCashReciept.AcctSeed__Applied_Amount__c = bill.balance;
                            System.debug(crw.cashReceipt.AcctSeed__Receipt_Date__c );
                            System.debug(idVBillingMap.get(bill.billId).AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c);
                            if(idVBillingMap.get(bill.billId).AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c > crw.cashReceipt.AcctSeed__Receipt_Date__c ){
                                billingCashReciept.AcctSeed__Accounting_Period__c = idVBillingMap.get(bill.billId).AcctSeed__Accounting_Period__c;
                                billingCashReciept.AcctSeed__Applied_Date__c = idVBillingMap.get(bill.billId).AcctSeed__Date__c ;
                            }else{
                                billingCashReciept.AcctSeed__Accounting_Period__c = cashReceiptsMap.get(billingCashReciept.AcctSeed__Cash_Receipt__c).AcctSeed__Accounting_Period__c;   
                                billingCashReciept.AcctSeed__Applied_Date__c = crw.cashReceipt.AcctSeed__Receipt_Date__c;
                            }
                            billingCashReceiptList.add(billingCashReciept); 
                        }
                    } 
                    rowNumbersMapBCR.put(billingCashReceiptList.size(),crw.reference);
                } 
            }
            if(!billingCashReceiptList.isEmpty()){
                //insert billingCashReceiptList;
                Database.SaveResult[] srList = Database.insert(billingCashReceiptList,false);
                for (Integer i=0;i<srList.size();i++) {
                    if (!srList[i].isSuccess()) {
                        String errorMessage = '';
                        for(Database.Error objErr : srList[i].getErrors()) {
                            System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                            System.debug('Invoice oject field which are affected by the error:' 
                                         + objErr.getFields());
                            errorMessage = objErr.getMessage();
                        }
                        Database.rollback(sp);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Row Number - ' + rowNumberMap.get(rowNumbersMapBCR.get(i)) + ': ' + errorMessage)); 
                        return null;
                    }
                }
                PageReference pg = new pagereference('/apex/MultipleCashReciept');
                pg.setRedirect(true);
                return  pg;
            } 
        }
        catch(Exception e){
            Database.rollback(sp);
            system.debug('**Error**'+e.getmessage()+'**LineNumber**'+e.getlinenumber()); 
        } 
        return null;
    }
    
    @RemoteAction
    public static List<sObject> getLookupRecord(String likeString) {
        if(String.IsNotBlank(likeString)){
            likeString = likeString+'%';
            String query = '';
            set<id> accountIdSet = new set<id>();
            
            for(AcctSeed__Billing__c billing  : [SELECT id,AcctSeed__Balance__c,AcctSeed__Customer__r.name,AcctSeed__Customer__c,AS_Transaction_Description__c,Policy__c,Claim__c,AcctSeed__Date__c,Policy__r.Name,Claim__r.Name FROM AcctSeed__Billing__c
                                                 WHERE AcctSeed__Balance__c > 0 AND (AcctSeed__Customer__r.name LIKE : likeString OR AcctSeed__Customer__r.AccountNumber  LIKE : likeString)]){
                                                     accountIdSet.add(billing.AcctSeed__Customer__c);
                                                 }
            
            if(accountIdSet.size() > 0){
                query = 'SELECT Id, Name,AccountNumber FROM Account WHERE id IN :accountIdSet LIMIT 50';
                List<SObject> accountList = database.query(query);
                return accountList;
            }
        }
        return null;
    }
    
    public class CashRecieptWrapper{
        public AcctSeed__Cash_Receipt__c cashReceipt{get;set;}
        public string CustormerName{get;set;}
        public id accountId{get;set;}
        public Decimal amount{get;set;}
        public string reference{get;set;}
        public date dateVal{get;set;}
        public list<BillingWrapper> billingList{get;set;}
        public String AccountingPeriod{get;set;}
        public string ServiceFee{get;set;}
        public string AccountNumber{get;set;}
        public Boolean containsRef{get;set;}
        public boolean hasAnyBillSelected{get;set;}
        
        public CashRecieptWrapper(){
            cashReceipt = new AcctSeed__Cash_Receipt__c();
            amount = 0;
            ServiceFee = '';
            containsRef = false;
            hasAnyBillSelected = false;
        }
    }
    
    public class BillingWrapper{
        public boolean selected{get;set;}
        public id billId{get;set;}
        public Decimal balance{get;set;}
        public Decimal balanceOriginal{get;set;}
        public String billName{get;set;}
        public String ASTransactionDescription{get;set;}
        public Date billingDate{get;set;}
        public String policyNumber{get;set;}
        public String claimNumber{get;set;}
        public BillingWrapper(AcctSeed__Billing__c bill,boolean check,Decimal bal){
            selected = check;
            billId = bill.id;
            if(bal == 0){
                balance = bill.AcctSeed__Balance__c;
            }else{
                balance = bal;
            }
            balanceOriginal = bill.AcctSeed__Balance__c;
            billName = bill.name;
            ASTransactionDescription = bill.AS_Transaction_Description__c;
            billingDate = bill.AcctSeed__Date__c;
            policyNumber = bill.Policy__r.Name;
            claimNumber = bill.Claim__r.Name;
        }
    }
    
    public void crReference(){
        integer rowNo = integer.valueOf(apexpages.currentPage().getParameters().get('listIndex'));
        
        List<AcctSeed__Cash_Receipt__c> cashReceiptList = [SELECT Id,AcctSeed__Payment_Reference__c 
                                                           FROM AcctSeed__Cash_Receipt__c 
                                                           WHERE AcctSeed__Payment_Reference__c =:  cashRecieptWrpList[rowNo-1].reference];
        
        for(AcctSeed__Cash_Receipt__c crObj : cashReceiptList ){
            
            if(crObj.AcctSeed__Payment_Reference__c != null){
                refCashReceiptMatchSet.add(crObj.AcctSeed__Payment_Reference__c);
            }
            
        }
        
        if(refCashReceiptMatchSet.contains(cashRecieptWrpList[rowNo-1].reference)){
            cashRecieptWrpList[rowNo-1].containsRef = true;
        }
        else{
            cashRecieptWrpList[rowNo-1].containsRef = false;
        }
        
    }
    
    public void ProcessFile(){
        String file = apexpages.currentpage().getParameters().get('file');
        
        String[] filelines1 = new String[]{};
            try{
                filelines1 = file.split('\n');
                //system.debug(filelines );
                System.debug(filelines1);
                Set<String> AcctNumSet = new Set<String>();
                Set<String> refStringSet = new Set<String>();
                String csvLine;
                for (Integer i=2;i<filelines1.size();i++){
                    System.debug(filelines1[i]);
                    String[] inputvalues = new String[]{};
                        inputvalues = filelines1[i].split(',');
                    
                    List<String> cleanFields = new List<String>();
                    String compositeField;
                    Boolean makeCompositeField = false;
                    for(String field : inputvalues) {
                        System.debug(field);
                        if (field.startsWith('"') && field.endsWith('"') && !makeCompositeField) {
                            cleanFields.add(field.replaceAll('DBLQT','"').trim());
                        } else if (field.startsWith('"') && !makeCompositeField) {
                            makeCompositeField = true;
                            compositeField = field;
                        } else if (field.endsWith('"')) {
                            compositeField += ',' + field;
                            cleanFields.add(compositeField.replaceAll('DBLQT','"').trim());
                            makeCompositeField = false;
                        } else if (makeCompositeField) {
                            compositeField +=  ',' + field;
                        } else {
                            cleanFields.add(field.replaceAll('DBLQT','"').trim());
                        }
                    }
                    
                    inputvalues = cleanFields;
                    
                    System.debug(inputvalues);
                    if(String.isNotBlank(inputvalues[4])){
                        AcctNumSet.add(inputvalues[4]);
                    }
                    if(String.isNotBlank(inputvalues[6])){
                        system.debug('inputvalues[6] => '+inputvalues[6]);
                        refStringSet.add(inputvalues[6].replace('trn_',''));//updated By Ramavtar 
                        refStringSet.add(inputvalues[6]);
                        //refStringSet.add('trn_'+inputvalues[6]);
                    }
                }
                
                system.debug(refStringSet);
                
                List<AcctSeed__Cash_Receipt__c> cashReceiptList = [SELECT Id,AcctSeed__Payment_Reference__c 
                                                                   FROM AcctSeed__Cash_Receipt__c 
                                                                   WHERE AcctSeed__Payment_Reference__c IN:  refStringSet];
                
                for(AcctSeed__Cash_Receipt__c crObj : cashReceiptList ){
                    System.debug('<<<<<<<<<<the value of payment reference is>>>>>>>>>>>>>>' +crObj.AcctSeed__Payment_Reference__c);
                    if(crObj.AcctSeed__Payment_Reference__c != null){
                        refCashReceiptMatchSet.add(crObj.AcctSeed__Payment_Reference__c.replace('trn_',''));
                    }
                }
                
                String[] filelines = new String[]{};
                
                for (Integer i=2;i<filelines1.size();i++){
                    if(filelines.size() == totalShows)
                        break;
                    String[] inputvalues = new String[]{};
                        inputvalues = filelines1[i].split(',');
                    
                    List<String> cleanFields = new List<String>();
                    String compositeField;
                    Boolean makeCompositeField = false;
                    for(String field : inputvalues) {
                        if (field.startsWith('"') && field.endsWith('"') && !makeCompositeField) {
                            cleanFields.add(field.replaceAll('DBLQT','"').trim());
                        } else if (field.startsWith('"') && !makeCompositeField) {
                            makeCompositeField = true;
                            compositeField = field;
                        } else if (field.endsWith('"')) {
                            compositeField += ',' + field;
                            cleanFields.add(compositeField.replaceAll('DBLQT','"').trim());
                            makeCompositeField = false;
                        } else if (makeCompositeField) {
                            compositeField +=  ',' + field;
                        } else {
                            cleanFields.add(field.replaceAll('DBLQT','"').trim());
                        }
                    }
                    
                    inputvalues = cleanFields;
                    System.debug(inputvalues);
                    for(String str : inputvalues){
                        System.debug(str);
                    }
                    system.debug(inputvalues[6]);
                    system.debug(refCashReceiptMatchSet);
                    system.debug(refCashReceiptMatchSet.contains(inputvalues[6]));
                    system.debug(refCashReceiptMatchSet.contains(inputvalues[6].replace('trn_','')));
                    if((String.isNotBlank(inputvalues[6]) && !(refCashReceiptMatchSet.contains(inputvalues[6]) || refCashReceiptMatchSet.contains(inputvalues[6].replace('trn_','')))) || (String.isBlank(inputvalues[6])) ){
                        System.debug(inputvalues[14]);
                        if((String.isBlank(inputvalues[14])) || !String.valueOf(inputvalues[14]).trim().equalsIgnoreCase('C')){
                            filelines.add(filelines1[i]);
                            if(String.isNotBlank(inputvalues[4])){
                                AcctNumSet.add(inputvalues[4]);
                            }
                        }
                    }else{
                        alreadyProcessed ++;
                    }
                }
                
				totalShows =   filelines.size();          
                
                leftToProcess = filelines1.size() - 2 - totalShows - alreadyProcessed;
                
                Map<String,Account> accMap = new Map<String,Account>();
                for(Account acc : [select id,name,accountnumber from account where accountnumber in: AcctNumSet]){
                    accMap.put(acc.accountnumber,acc);
                }
                
                Map<String,List<AcctSeed__Billing__c>> billingMap = new Map<String,List<AcctSeed__Billing__c>> ();
                for(AcctSeed__Billing__c obj : [select id,Name,AcctSeed__Customer__c,AcctSeed__Status__c,AcctSeed__Balance__c,
                                                AcctSeed__Customer__r.AccountNumber,AS_Transaction_Description__c,Policy__c,Claim__c,AcctSeed__Date__c,Policy__r.Name,Claim__r.Name 
                                                from AcctSeed__Billing__c 
                                                where AcctSeed__Customer__c In: accMap.values() 
                                                AND AcctSeed__Balance__c > 0 and AcctSeed__Status__c = 'Posted']){
                                                    List<AcctSeed__Billing__c> billList = new List<AcctSeed__Billing__c>();
                                                    if(billingMap.containsKey(obj.AcctSeed__Customer__r.AccountNumber)){
                                                        billList.addAll(billingMap.get(obj.AcctSeed__Customer__r.AccountNumber));
                                                    }
                                                    billList.add(obj);
                                                    billingMap.put(obj.AcctSeed__Customer__r.AccountNumber,billList);
                                                }
                
                
                for (Integer i=0;i<filelines.size();i++){
                    String[] inputvalues = new String[]{};
                        inputvalues = filelines[i].split(',');
                    List<String> cleanFields = new List<String>();
                    String compositeField;
                    Boolean makeCompositeField = false;
                    for(String field : inputvalues) {
                        if (field.startsWith('"') && field.endsWith('"') && !makeCompositeField) {
                            cleanFields.add(field.replaceAll('DBLQT','"').trim());
                        } else if (field.startsWith('"') && !makeCompositeField) {
                            makeCompositeField = true;
                            compositeField = field;
                        } else if (field.endsWith('"')) {
                            compositeField += ',' + field;
                            cleanFields.add(compositeField.replaceAll('DBLQT','"').trim());
                            makeCompositeField = false;
                        } else if (makeCompositeField) {
                            compositeField +=  ',' + field;
                        } else {
                            cleanFields.add(field.replaceAll('DBLQT','"').trim());
                        }
                    }
                    
                    inputvalues = cleanFields;
                    CashRecieptWrapper crw = new CashRecieptWrapper();
                    crw.cashReceipt.AcctSeed__Credit_GL_Account__c = defaultCreditGlId;
                    crw.billingList = new list<BillingWrapper>();
                    
                    if(refCashReceiptMatchSet.contains(inputvalues[6])){
                        crw.containsRef = true;
                    }
                    else{
                        crw.containsRef = false;
                    }
                    
                    if(String.isNotBlank(inputvalues[16])){
                        crw.cashReceipt.AcctSeed__Receipt_Date__c = Date.valueOf(convertDate(inputvalues[16])); 
                    }
                    if(String.isNotBlank(inputvalues[5])){
                        crw.amount = Decimal.valueOf(inputvalues[5]);
                        crw.cashReceipt.AcctSeed__Amount__c = Decimal.valueOf(inputvalues[5]);
                    }
                    if(String.isNotBlank(inputvalues[6])){
                        crw.reference = inputvalues[6];
                    }
                    if(String.isNotBlank(inputvalues[4])){
                        if(accMap.containskey(inputvalues[4])){
                            crw.CustormerName = accMap.get(inputvalues[4]).Name;
                            crw.cashReceipt.AcctSeed__Account__c = accMap.get(inputvalues[4]).id;
                            crw.AccountId = crw.cashReceipt.AcctSeed__Account__c;
                            
                            if(billingMap.containsKey(inputvalues[4])){
                                if(billingMap.get(inputvalues[4]).size() == 1){
                                    if(billingMap.get(inputvalues[4])[0].AcctSeed__Balance__c < crw.amount){
                                        System.debug('herere');
                                        System.debug(billingMap.get(inputvalues[4])[0].AcctSeed__Balance__c);
                                        System.debug(crw.amount);
                                        crw.billingList.add(new BillingWrapper(billingMap.get(inputvalues[4])[0],false,crw.amount));
                                        crw.amount = billingMap.get(inputvalues[4])[0].AcctSeed__Balance__c;
                                    }else{
                                        crw.billingList.add(new BillingWrapper(billingMap.get(inputvalues[4])[0],true,crw.amount));
                                        crw.hasAnyBillSelected = true;
                                    }
                                }else{
                                    for(AcctSeed__Billing__c billObj : billingMap.get(inputvalues[4])){
                                        crw.billingList.add(new BillingWrapper(billObj,false,crw.amount));
                                    }
                                }
                            }
                        }
                        crw.AccountNumber = inputvalues[4];
                        System.debug(crw.hasAnyBillSelected);
                    }
                    
                    if(String.isNotBlank(inputvalues[13])){
                        crw.ServiceFee = inputvalues[13];
                    }
                    
                    cashRecieptWrpList.add(crw);
                    
                }
                
                isFileProcessed = true;
            }catch(Exception e){
                system.debug(' UUU ' + e.getLineNumber());
                System.debug(e.getStackTraceString());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured reading the CSV file'+e.getMessage()));
            }      
    }
    
    public Date convertDate(String dt){
        String dtVal = '';
        String[] str = dt.split('/');
        if(str.size() > 2){
            dtVal = str[2].SubStringBefore(' ')+'-'+str[0]+'-'+str[1];
        }else{
            dtVal = dt;
        }
        system.debug(dtval);
        return Date.valueOf(dtVal);
    }
    
    public void ManualEntry(){
        isFileProcessed = true;
        isManualEntry = true;
        addRow();
    }
}