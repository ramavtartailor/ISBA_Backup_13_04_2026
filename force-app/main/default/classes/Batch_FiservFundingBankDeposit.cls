global class Batch_FiservFundingBankDeposit implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.stateful{
    
    global string dtStr;
    global Date dt;
    global String lmt;
    global Integer pageNo;
    global List<String> successStatusList;
    global List<String> errorStatusList;
    global String Bank_Deposit_GL;
    global String Adjustment_GL_Account;
    global Map<String,Set<String>> fundingMap = new Map<String,Set<String>>();
    global Boolean callAgain = false;
    global Boolean isCreditCard = true;
    
    global Batch_FiservFundingBankDeposit(Date tempDt, Integer pageNo, Map<String,Set<String>> fundMap, Boolean isCreditCard){
        this.dt = tempDt;
        this.dtStr = dt.year()+''+String.valueOf(dt.month()).leftPad(2, '0')+''+String.valueOf(dt.day()).leftPad(2, '0');
        this.pageNo = pageNo;
        this.fundingMap = fundMap;
        this.isCreditCard = isCreditCard;
        setCreds();
    }
    
    global Batch_FiservFundingBankDeposit(Date tempDt){
        this.dt = tempDt;
        this.pageNo = 1;
        this.dtStr = dt.year()+''+String.valueOf(dt.month()).leftPad(2, '0')+''+String.valueOf(dt.day()).leftPad(2, '0');
        setCreds();
    }
    
    global Batch_FiservFundingBankDeposit(){
        Fiserv_Creds__c crds = Fiserv_Creds__c.getOrgDefaults();
        this.dt = crds.Last_Funding_Date_CC__c.addDays(1);
        this.pageNo = 1;
        this.dtStr = dt.year()+''+String.valueOf(dt.month()).leftPad(2, '0')+''+String.valueOf(dt.day()).leftPad(2, '0');
        setCreds();
    }
    
    global void setCreds(){
        Fiserv_Creds__c crds = Fiserv_Creds__c.getOrgDefaults();
        this.lmt = String.valueOf(Integer.valueOf(crds.Fiserv_Funding_Batch_Limit__c));
        this.Bank_Deposit_GL = crds.Fiserv_Funding_GL_Account__c;
        this.Adjustment_GL_Account = crds.Fiserv_Funding_Adjustment_GL_Account__c;
        this.errorStatusList = new List<String>();
        for(String str : crds.Fiserv_Funding_Error_Status__c.split(',')){
            if(String.isNotBlank(str)){
                this.errorStatusList.add(str.trim());
            }
        }
        
        this.successStatusList = new List<String>();
        for(String str : crds.Fiserv_Funding_Success_Status__c.split(',')){
            if(String.isNotBlank(str)){
                this.successStatusList.add(str.trim());
            }
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id FROM Account Limit 1');
    }
    
    global void execute(Database.BatchableContext bc, List<Account> data){
        List<Integration_Log__c> logList = new List<Integration_Log__c>();
        try{
            String fundingIdPreFix = 'Fiserv CC - ';
            String response = '';
            if(isCreditCard){
                response = Fiserv_Utils.getCCFunding(dtStr, lmt, String.valueOf(pageNo));
                fundingIdPreFix = 'Fiserv CC - ';
            }
            else{
                response = Fiserv_Utils.getAchFunding(dtStr, lmt, String.valueOf(pageNo));
                fundingIdPreFix = 'Fiserv ACH - ';
            }            
            System.debug('response => '+ response);
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response);
            
            if(result.containsKey('errormsg')){
                if(dt < system.today().addDays(-1)){
                    callAgain = true;
                    pageNo = 1;  
                    dt = dt.addDays(1);
                }
                else if(isCreditCard){
                    isCreditCard = false;
                    callAgain = true;
                    pageNo = 1;
                    Fiserv_Creds__c crds = Fiserv_Creds__c.getOrgDefaults();
                    dt = crds.Last_Funding_Date_ACH__c.addDays(1);
                }
            }
            else{
                if(result.containsKey('txns')){
                    List<Object> transactions = (List<Object>)result.get('txns');
                    if(!transactions.isEmpty()){
                        for(Object obj : transactions){
                            Map<String, Object> transObj = (Map<String, Object>) obj;
                            if( successStatusList.contains(String.valueOf(transObj.get('status'))) || errorStatusList.contains(String.valueOf(transObj.get('status'))) ){
                                if(transObj.containsKey('retref') && transObj.get('retref') != null ){
                                    String fundingId = fundingIdPreFix + String.valueOf(transObj.get('fundingtxnid'));
                                    Set<String> transIds = new Set<String>();
                                    if(fundingMap.containsKey(fundingId)){
                                        transIds = fundingMap.get(fundingId);
                                    }
                                    
                                    if(errorStatusList.contains(String.valueOf(transObj.get('status')))){
                                        //create Negetive Cr and Brc and Update Payment Schedule;
                                        transIds.add(('rejected_'+String.valueOf(transObj.get('retref'))));
                                        paymentFailed(String.valueOf(transObj.get('retref')), dt, JSON.serialize(transObj));
                                    }
                                    
                                    transIds.add(String.valueOf(transObj.get('retref')));
                                    fundingMap.put(fundingId, transIds);
                                }
                            }
                        }
                    }
                }
                System.debug('fundingMap => '+ fundingMap);
                
                if(result.containsKey('perPageSize')){
                    System.debug('result.get(perPageSize) => '+ result.get('perPageSize'));
                    
                    if(result.containsKey('currentPageSize') && result.get('perPageSize') == result.get('currentPageSize')){
                        System.debug('result.get(currentPageSize) => '+ result.get('currentPageSize'));
                        
                        pageNo += 1;
                        callAgain = true;
                    }
                    else{
                        System.debug('Creating Bank Deposit');
                        
                        List<AcctSeed__Bank_Deposit__c> bankDepositList = new List<AcctSeed__Bank_Deposit__c>();
                        
                        Set<String> allTransIds = new Set<String>();
                        List<AcctSeed__Bank_Deposit__c> oldBankDeposits = new List<AcctSeed__Bank_Deposit__c>([SELECT Id,AcctSeed__Deposit_Reference__c FROM AcctSeed__Bank_Deposit__c WHERE AcctSeed__Deposit_Reference__c IN : fundingMap.keySet()]);
                        Map<String,AcctSeed__Bank_Deposit__c> oldBankDepositsMap = new Map<String,AcctSeed__Bank_Deposit__c>();
                        for(AcctSeed__Bank_Deposit__c bd: oldBankDeposits){
                            oldBankDepositsMap.put(bd.AcctSeed__Deposit_Reference__c, bd);
                        }
                        
                        List<Object> fundings = (List<Object>)result.get('fundings');
                        if(!fundings.isEmpty()){
                            for(Object obj: fundings){
                                Map<String, Object> fundingObj = (Map<String, Object>) obj;
                                String fundingId = fundingIdPreFix + String.valueOf(fundingObj.get('fundingmasterid'));
                                if(!fundingMap.containsKey(fundingId)){
                                    fundingMap.put(fundingId, new Set<String>() );
                                }
                            }
                        }
                        
                        for(String fundingId : fundingMap.keySet()){
                            if(fundingMap.containsKey(fundingId)){
                                Set<String> transIds = fundingMap.get(fundingId);
                                AcctSeed__Bank_Deposit__c bankDeposit = new AcctSeed__Bank_Deposit__c(
                                    AcctSeed__Cleared_Date__c = dt,
                                    AcctSeed__Deposit_Date__c = dt,
                                    AcctSeed__Bank_Account__c = Bank_Deposit_GL,
                                    AcctSeed__Deposit_Reference__c  = fundingId
                                    //AcctSeed__Amount__c = Decimal.valueOf(String.valueOf(fundingObj.get('totalfunding')))
                                );
                                if(oldBankDepositsMap.containsKey(fundingId)){
                                    bankDeposit.Id = oldBankDepositsMap.get(fundingId).Id;
                                }
                                bankDepositList.add(bankDeposit);
                                allTransIds.addAll(transIds);
                            }
                        }
                        //Map<String,Decimal> serviceFeeMap = new Map<String,Decimal>();
                        //List<Object> fundings = (List<Object>)result.get('fundings');
                        
                        Map<String,AcctSeed__Journal_Entry_Line__c> fundingWithLineMap = new Map<String,AcctSeed__Journal_Entry_Line__c>();
                        
                        if(!fundings.isEmpty()){
                            
                            Map<String,AcctSeed__Journal_Entry__c> jeMap = new Map<String,AcctSeed__Journal_Entry__c>();
                            Map<String,List<AcctSeed__Journal_Entry_Line__c>> jeLineMap = new Map<String,List<AcctSeed__Journal_Entry_Line__c>>();
                            List<AcctSeed__Journal_Entry_Line__c> lineList = new List<AcctSeed__Journal_Entry_Line__c>();
                            
                            //Create Je
                            for(Object obj: fundings){
                                Map<String, Object> fundingObj = (Map<String, Object>) obj;
                                String fundingId = fundingIdPreFix + String.valueOf(fundingObj.get('fundingmasterid'));
                                if(!oldBankDepositsMap.containsKey(fundingId) && fundingObj.containsKey('servicecharge') && Decimal.valueOf(String.valueOf(fundingObj.get('servicecharge'))) != 0){
                                    Decimal adjAmount = - Decimal.valueOf(String.valueOf(fundingObj.get('servicecharge')));
                                    AcctSeed__Journal_Entry__c je = new AcctSeed__Journal_Entry__c(
                                        Name = 'Bank Rec JE '+String.valueOf(dt),
                                        AcctSeed__Journal_Date__c = dt
                                    );
                                    jeMap.put(fundingId, je);
                                    List<AcctSeed__Journal_Entry_Line__c> tempLineList = new List<AcctSeed__Journal_Entry_Line__c>();
                                    //Credit JE Line
                                    AcctSeed__Journal_Entry_Line__c jelCred = new AcctSeed__Journal_Entry_Line__c(
                                        AcctSeed__Credit__c = adjAmount,
                                        AcctSeed__GL_Account__c = Bank_Deposit_GL,
                                        //AcctSeed__Journal_Entry__c = je.Id,
                                        AcctSeed__Date__c = dt
                                    );
                                    tempLineList.add(jelCred); 
                                    lineList.add(jelCred);
                                    
                                    //Debit JE Line
                                    AcctSeed__Journal_Entry_Line__c jelDebit = new AcctSeed__Journal_Entry_Line__c(
                                        AcctSeed__Debit__c = adjAmount,
                                        AcctSeed__GL_Account__c = Adjustment_GL_Account,
                                        //AcctSeed__Journal_Entry__c = je.Id,
                                        AcctSeed__Date__c = dt
                                    );
                                    tempLineList.add(jelDebit); 
                                    lineList.add(jelDebit);
                                    
                                    jeLineMap.put(fundingId, tempLineList);
                                    fundingWithLineMap.put(fundingId,jelCred);
                                }
                            }
                            
                            if(!jeMap.keySet().isEmpty()){
                                Insert jeMap.values();
                                
                                for(String key: jeLineMap.keySet()){
                                    List<AcctSeed__Journal_Entry_Line__c> tempLineList = jeLineMap.get(key);
                                    for(AcctSeed__Journal_Entry_Line__c jel: tempLineList){
                                        jel.AcctSeed__Journal_Entry__c = jeMap.get(key).Id;
                                    }
                                }
                                
                                Insert lineList;
                                
                                AcctSeed.PostResult[] postResults = AcctSeed.JournalEntryPostService.postJournalEntries(jeMap.values());
                                
                                // Loop through post results
                                for (AcctSeed.PostResult theResult : postResults) {
                                    if (theResult.isSuccess) {
                                        System.debug('Successfully posted journal entry: ' + theResult.id);
                                    } 
                                    else {
                                        System.debug('Error posting billing ' + theResult.id);
                                        for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                                            System.debug('Error status code ' + errorResult.statusCode);
                                            System.debug('Error message ' + errorResult.message);
                                        }
                                    }
                                }
                            }
                        }
                        
                        if(!bankDepositList.isEmpty()){
                            Upsert bankDepositList;
                            
                            List<AcctSeed__Cash_Receipt__c> crList = new List<AcctSeed__Cash_Receipt__c>([SELECT Id, AcctSeed__Payment_Reference__c FROM AcctSeed__Cash_Receipt__c WHERE AcctSeed__Payment_Reference__c IN : allTransIds]);
                            
                            for(AcctSeed__Bank_Deposit__c bankDeposit: bankDepositList){
                                
                                Set<String> transIds = fundingMap.get(bankDeposit.AcctSeed__Deposit_Reference__c);
                                List<Id> crIds = new List<Id>();
                                for(AcctSeed__Cash_Receipt__c cr: crList){
                                    if(transIds.contains(cr.AcctSeed__Payment_Reference__c)){
                                        crIds.add(cr.Id);
                                    }
                                }
                                
                                if(!crIds.isEmpty()){
                                    AcctSeed.ServiceResult sr = AcctSeed.BankDeposit.associate(bankDeposit.Id, crIds);
                                    Integration_Log__c log = new Integration_Log__c();
                                    log.JSON_Body__c = String.valueOf(sr);
                                    log.Status__c = 'Processed Successfully';
                                    log.Description__c= 'Log for Bank Deposit '+String.valueOf(dt)+(isCreditCard ? ' Credit Card': ' ACH');
                                    logList.add(log);
                                }
                                
                                if(fundingWithLineMap.containsKey(bankDeposit.AcctSeed__Deposit_Reference__c)){
                                    List<Id> jeLineIds = new List<Id>();
                                    jeLineIds.add(fundingWithLineMap.get(bankDeposit.AcctSeed__Deposit_Reference__c).Id);
                                    AcctSeed.ServiceResult srJEL = AcctSeed.BankDeposit.associate(bankDeposit.Id, jeLineIds);
                                    Integration_Log__c log = new Integration_Log__c();
                                    log.JSON_Body__c = String.valueOf(srJEL);
                                    log.Status__c = 'Processed Successfully';
                                    log.Description__c= 'Log for Bank Deposit JEL '+String.valueOf(dt)+(isCreditCard ? ' Credit Card': ' ACH');
                                    logList.add(log);
                                }
                            }
                        }
                        
                        if(dt < system.today()){
                            Date newDt = Date.valueOf(String.valueOf(result.get('fundingdate')));
                            Fiserv_Creds__c crds = Fiserv_Creds__c.getOrgDefaults();
                            if(isCreditCard && dt == system.today().addDays(-1)){
                                if(newDt > crds.Last_Funding_Date_CC__c){
                                    crds.Last_Funding_Date_CC__c = newDt;
                                }
                                newDt = crds.Last_Funding_Date_ACH__c;
                                isCreditCard = false;
                            }
                            else if(isCreditCard){
                                if(newDt > crds.Last_Funding_Date_CC__c){
                                    crds.Last_Funding_Date_CC__c = newDt;
                                }
                            }
                            else{
                                if(newDt > crds.Last_Funding_Date_ACH__c){
                                    crds.Last_Funding_Date_ACH__c = newDt;
                                }
                            }
                            Update crds;
                            dt = newDt.addDays(1);
                            pageNo = 1;
                            callAgain = true;
                        }
                        else if(isCreditCard){
                            Fiserv_Creds__c crds = Fiserv_Creds__c.getOrgDefaults();
                            dt = crds.Last_Funding_Date_ACH__c.addDays(1);
                            isCreditCard = false;
                            callAgain = true;
                            pageNo = 1;
                        }
                        Integration_Log__c log = new Integration_Log__c();
                        log.JSON_Body__c = String.valueOf(fundingMap);
                        log.Status__c = 'Processed Successfully';
                        log.Description__c= 'Log for Bank Deposit Transaction Map. '+String.valueOf(dt)+(isCreditCard ? ' Credit Card': ' ACH');
                        logList.add(log);
                        fundingMap = new Map<String,Set<String>>();
                    }
                }
            }
            
            if(!logList.isEmpty()){
                Insert logList;
            }
        }
        catch(DmlException e){
            system.debug('Error => '+e.getDmlMessage(0)+'\nAt => '+e.getLineNumber());
            Integration_Log__c log = new Integration_Log__c();
            log.JSON_Body__c = 'Error => '+e.getDmlMessage(0)+' At => '+e.getLineNumber();
            log.Status__c = 'Processed Successfully';
            log.Description__c= 'Log for Bank Deposit Exception '+String.valueOf(dt)+(isCreditCard ? ' Credit Card': ' ACH');
            logList.add(log);
            if(!logList.isEmpty()){
                Insert logList;
            }
        }
        catch(Exception e){
            system.debug('Error => '+e.getMessage()+'\nAt => '+e.getLineNumber());
            Integration_Log__c log = new Integration_Log__c();
            log.JSON_Body__c = 'Error => '+e.getMessage()+' At => '+e.getLineNumber();
            log.Status__c = 'Processed Successfully';
            log.Description__c= 'Log for Bank Deposit Exception '+String.valueOf(dt)+(isCreditCard ? ' Credit Card': ' ACH');
            logList.add(log);
            if(!logList.isEmpty()){
                Insert logList;
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
        if(callAgain){
            Batch_FiservFundingBankDeposit b = new Batch_FiservFundingBankDeposit(dt, pageNo, fundingMap, isCreditCard);
            Database.executeBatch(b);
        }
    }
    
    global void execute(SchedulableContext sc){
        Batch_FiservFundingBankDeposit b = new Batch_FiservFundingBankDeposit();
        Database.executeBatch(b);
    }
    
    public static String updatePSchRecords(List<Sobject> records, String operation){
        String msg = '';
        String jsonBody = '{"Records" : '+JSON.serialize(records)+',"Opr":'+JSON.serialize(operation)+'}';
        
        system.debug(jsonBody);
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:CashReceipt_Api/services/apexrest/InsertDeletePaymentScheduleRecords');
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        request.setBody(jsonBody);
        request.setTimeout(120000);
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        system.debug('796::');
        if(!test.isRunningTest()) {
            response = http.send(request); 
            msg  = response.getBody(); 
            system.debug(msg); 
            if(response.getStatusCode() == 200){
                return msg; 
            } else{
                return 'Error'; 
            }  
        }
        else{
            response.setHeader('Content-Type', 'application/json');
            String q = 'SELECT Id FROM AcctSeed__Cash_Receipt__c LIMIT 1';
            system.debug('query=>'+q);
            List<Sobject> obj = Database.query(q);
            system.debug('obj =>'+obj);
            response.setStatusCode(200);
            return JSON.serialize(obj);
        }
    }
    
    global static void paymentFailed(String reference, Date recDate, String jsonBody){
        List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>([SELECT Id, Cash_Receipt__c FROM Payment_Schedule__c WHERE Payment_Reference__c =: reference AND Status__c = 'Paid' LIMIT 1]);
        
        if(!paymentSchedules.isEmpty()){
            if(paymentSchedules[0].Cash_Receipt__c != null){
                List<AcctSeed__Cash_Receipt__c> crList = new List<AcctSeed__Cash_Receipt__c>([SELECT Id, Name, AcctSeed__Description__c, Processing_Type__c, AcctSeed__Credit_GL_Account__c, AcctSeed__Ledger__c, AcctSeed__Account__c, AcctSeed__Accounting_Period__c, AcctSeed__Amount__c, AcctSeed__Payment_Reference__c, AcctSeed__GL_Account_Variable_1__c,
                                                                                              (SELECT Id, AcctSeed__Adjustment_GL_Account__c, AcctSeed__Adjustment_Amount__c, AcctSeed__Accounting_Period__c, AcctSeed__Applied_Amount__c, AcctSeed__Billing__c, AcctSeed__Billing__r.ISBAM_Error_Description__c FROM AcctSeed__Billing_Cash_Receipts__r) FROM AcctSeed__Cash_Receipt__c WHERE Id =: paymentSchedules[0].Cash_Receipt__c AND AcctSeed__Payment_Reference__c =: reference LIMIT 1]);
                
                Set<String> billIds = new Set<String>();
                
                if(!crList.isEmpty()){
                    //Negetive Cash Receipt
                    AcctSeed__Cash_Receipt__c cr = new AcctSeed__Cash_Receipt__c();
                    cr.AcctSeed__Amount__c = -crList[0].AcctSeed__Amount__c;
                    //cr.AcctSeed__Accounting_Period__c = 'a1U4A0000071yTUUAY';//crList[0].AcctSeed__Accounting_Period__c;
                    cr.AcctSeed__Status__c = 'Approved';
                    cr.AcctSeed__Account__c = crList[0].AcctSeed__Account__c;
                    cr.AcctSeed__Receipt_Date__c = recDate;
                    cr.AcctSeed__Ledger__c = crList[0].AcctSeed__Ledger__c;
                    cr.AcctSeed__Credit_GL_Account__c = crList[0].AcctSeed__Credit_GL_Account__c;
                    cr.AcctSeed__Payment_Reference__c = 'rejected_'+crList[0].AcctSeed__Payment_Reference__c;
                    cr.AcctSeed__Description__c = crList[0].AcctSeed__Description__c;
                    cr.Processing_Type__c = crList[0].Processing_Type__c;
                    cr.AcctSeed__GL_Account_Variable_1__c = crList[0].AcctSeed__GL_Account_Variable_1__c;
                    
                    
                    
                    system.debug('cr => '+cr);
                    // Post the cash receipts
                    String postResults = postRecords(new List<AcctSeed__Cash_Receipt__c>{cr} , 'AcctSeed__Cash_Receipt__c');
                    //AcctSeed.PostResult[] postResults = AcctSeed.CashReceiptPostService.postCashReceipts(new List<AcctSeed__Cash_Receipt__c>{cr});
                    system.debug('postResults => '+postResults);
                    
                    List<AcctSeed__Cash_Receipt__c> updatedCR = (List<AcctSeed__Cash_Receipt__c>) System.JSON.deserializeStrict(postResults, List<AcctSeed__Cash_Receipt__c>.class);
                    cr.Id = updatedCR[0].Id;
                    
                    List<AcctSeed__Billing_Cash_Receipt__c> bcrList = new List<AcctSeed__Billing_Cash_Receipt__c>();
                    List<AcctSeed__Billing__c> billingsToUpdate = new List<AcctSeed__Billing__c>();
                    
                    for(AcctSeed__Billing_Cash_Receipt__c bcr: crList[0].AcctSeed__Billing_Cash_Receipts__r){
                        system.debug('bcr => '+bcr);
                        AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
                        bill.Id = bcr.AcctSeed__Billing__c;
                        bill.ISBAM_Error__c = 'Rejected Cash Receipt';
                        bill.ISBAM_Error_Description__c = (bcr.AcctSeed__Billing__r.ISBAM_Error_Description__c != null ? bcr.AcctSeed__Billing__r.ISBAM_Error_Description__c + '\nRejected Cash Receipt ' + crList[0].Name :  'Rejected Cash Receipt ' + crList[0].Name);
                        billingsToUpdate.add(bill);
                        billIds.add(bill.Id);
                        //Createing Billing Cash Receipt
                        AcctSeed__Billing_Cash_Receipt__c billingCashReceipt = new AcctSeed__Billing_Cash_Receipt__c();
                        billingCashReceipt.AcctSeed__Applied_Amount__c = -bcr.AcctSeed__Applied_Amount__c;
                        billingCashReceipt.AcctSeed__Billing__c = bcr.AcctSeed__Billing__c;
                        billingCashReceipt.AcctSeed__Cash_Receipt__c = cr.Id;
                        billingCashReceipt.AcctSeed__Applied_Date__c = recDate;
                        billingCashReceipt.AcctSeed__Status__c = 'Approved';
                        //billingCashReceipt.AcctSeed__Accounting_Period__c = 'a1U4A0000071yTUUAY';//bcr.AcctSeed__Accounting_Period__c;   
                        if(String.isNotBlank(bcr.AcctSeed__Adjustment_GL_Account__c)){
                            billingCashReceipt.AcctSeed__Adjustment_Amount__c = bcr.AcctSeed__Adjustment_Amount__c != null ? -bcr.AcctSeed__Adjustment_Amount__c: null;
                            billingCashReceipt.AcctSeed__Adjustment_GL_Account__c = bcr.AcctSeed__Adjustment_GL_Account__c;
                        }
                        
                        system.debug(billingCashReceipt);
                        bcrList.add(billingCashReceipt);
                    }
                    //Insert bcrList;
                    
                    System.debug('bcrList => '+bcrList);
                    String bcrPostResults = postRecords(bcrList , 'AcctSeed__Billing_Cash_Receipt__c');
                    //AcctSeed.PostResult[] bcrPostResults = AcctSeed.BillingCashReceiptPostService.postBillingCashReceipts(bcrList);
                    system.debug('bcrPostResults => '+bcrPostResults);
                    
                    
                    if(!billingsToUpdate.isEmpty()){
                        //Update billingsToUpdate;
                        String updateBillingResp = updatePSchRecords(billingsToUpdate, 'Update');
                        
                        List<Integration_Log__c> integrationLogs = new List<Integration_Log__c>([SELECT Id FROM Integration_Log__c WHERE Billing__c =: billingsToUpdate[0].Id AND Transaction_Id__c =: reference limit 1]);
                        
                        if(!integrationLogs.isEmpty()){
                            integrationLogs[0].Status__c = 'Rejected ACH';
                            integrationLogs[0].Description__c = 'Rejected ACH';
                            updatePSchRecords(integrationLogs, 'Upsert');
                            //Upsert integrationLogs;
                        }
                            
                        //send Email On Error
                        sendEmail(billIds, reference);
                        
                    }
                    
                }
            }
            else{
                paymentSchedules[0].Manual_Attention_Required__c = true;
            } 
            paymentSchedules[0].Webhook_JSON__c = jsonBody;
            paymentSchedules[0].Status__c = 'Rejected';
            paymentSchedules[0].Settled_Date__c = null;
            paymentSchedules[0].Cash_Receipt__c = null;
            paymentSchedules[0].Paid_Amount__c = 0;
            //Update paymentSchedules;
            updatePSchRecords(paymentSchedules, 'Update');
        }
    } 
    
    public static String postRecords(List<Sobject> records, String obj){
        try{
            String msg = '';
            String jsonBody = '{"Records" : '+JSON.serialize(records)+',"obj":'+JSON.serialize(obj)+'}';
            
            system.debug(jsonBody);
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:CashReceipt_Api/services/apexrest/posting');
            request.setMethod('POST');
            request.setHeader('Content-Type','application/json');
            request.setBody(jsonBody);
            request.setTimeout(120000);
            Http http = new Http();
            HttpResponse response = new HttpResponse();
            system.debug('796::');
            if(!test.isRunningTest()) {
                response = http.send(request); 
                msg  = response.getBody(); 
                system.debug(msg); 
                return msg;  
            }
            else{
                response.setHeader('Content-Type', 'application/json');
                response.setStatusCode(200);
                system.debug('records => '+records);
                insert records;
                return JSON.serialize(records);
            }
        }
        Catch(Exception e){
            system.debug('Error at '+e.getLineNumber()+'   '+ e.getMessage());
            return null;
        }
    }
    
    public static void sendEmail(Set<String> billIds, String reference){
        try{
            String msg = '';
            List<String> bills = new List<String>();
            bills.addAll(billIds);
            String jsonBody = '{"billIds" : '+JSON.serialize(bills)+',"ref":'+reference+'}';
            
            system.debug(jsonBody);
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:CashReceipt_Api/services/apexrest/sendPaymentFailedError');
            request.setMethod('POST');
            request.setHeader('Content-Type','application/json');
            request.setBody(jsonBody);
            request.setTimeout(120000);
            Http http = new Http();
            HttpResponse response = new HttpResponse();
            system.debug('796::');
            if(!test.isRunningTest()) {
                response = http.send(request); 
                msg  = response.getBody();  
            }
            else{
               SendEmailHelper.sendEmail(bills, reference); 
            }
        }
        Catch(Exception e){
            system.debug('Error at '+e.getLineNumber()+'   '+ e.getMessage());
        }
    }
}