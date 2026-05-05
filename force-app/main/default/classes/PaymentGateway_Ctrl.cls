public without sharing class PaymentGateway_Ctrl {
    public  Decimal CHECK_TRANSACTION_FEE = 5;
    public  Decimal CREDIT_CARD_SERVICE_FEE_VISA = 2.75;
    public  Decimal CREDIT_CARD_SERVICE_FEE_MasterCard = 2.75;
    public  Decimal CREDIT_CARD_SERVICE_FEE_Discovery = 2.75;
    public  Decimal CREDIT_CARD_SERVICE_FEE_American_Express = 2.75;
    public String currentStage{get;set;}
    public PaymentGateway_Ctrl_Wrapper warpperObj{get;set;}
    public AcctSeed__Billing__c billing{get;set;}
    public Decimal perMonthAmount{get;set;}
    public Decimal perQuarterAmount{get;set;}
    public Decimal perTotalMonthAmount{get;set;}
    public Decimal perTotalQuarterAmount{get;set;}
    public Decimal firstInstallment{get;set;}
    public Decimal totalCredit{get;set;}
    public Decimal totalCLECredit{get;set;}
    public Decimal premium{get;set;}
    public Decimal balance{get;set;}
    public Decimal policyDividend{get;set;}
    public List<String> paymentMonths{get;set;}
    public List<String> paymentQuarters{get;set;}
    public List<String> finalpaymentMonths;
    public List<String> finalpaymentQuarters;
    public Decimal totalAmountDue{get;set;}
    public Decimal totalServiceFee{get;set;}
    public Decimal creditCardServiceFee{get;set;}
    public boolean noInvoiceFound{get;set;}
    public boolean paymentError{get;set;}
    public String paymentErrorMessage{get;set;}
    public String receiptNumber{get;set;}
    public String SelectedMethod{get;set;}
    @TestVisible private Decimal baseAmountToPay{get;set;}
    public String invoiceNotFoundErrorMessage{get;set;}
    public String paymentInvalidDateError{get;set;}
    public boolean paymentInvalidDate{get;set;}
    public Decimal creditCardfee{get;set;}
    public String accountName{get;set;}
    public string lasttime;
    public Date paymentQuartersDt;
    public Date paymentMonthsDt; 
    private String validationString;
    public AcctSeed__Payment_Method__c paymentMethod{get;set;}
    public Date firstInstallmentDate{get;set;}
    public String firstInstallmentDateString{get;set;}
    public Policy__c policy{get;set;}
    public boolean enablePaymentDate{get;set;}
    public Id sfInternalId;
    public String userSession;
    public List<AcctSeed__Billing_Cash_Receipt__c> bcrList{get;set;}
    public List<AcctSeed__Billing_Line__c > billingLines{get;set;}
    public List<AcctSeed__Billing_Credit_Memo__c> creditMemo{get;set;}
    public List<Integration_Log__c> integrationLog{get;set;}
    public string redirectUrl{get;set;}
    
    public PaymentGateway_Ctrl(){
        redirectUrl = '';
        currentStage ='findInvoice';
        totalAmountDue =0;
        totalServiceFee=0;
        warpperObj = new PaymentGateway_Ctrl_Wrapper();
        paymentError =false;
        paymentErrorMessage='';
        lasttime = 'Full';
        policy = new Policy__c();
        System.debug(Apexpages.currentpage().getparameters());
        if(Apexpages.currentpage().getparameters().get('id') != null){
            currentStage = 'schedule';
            validationString = Apexpages.currentpage().getparameters().get('id');
            checkPaymentProcessor();
            //nextFunction();
        }else if(Apexpages.currentpage().getparameters().get('sfInternalId') != null){
            currentStage = 'schedule';
            sfInternalId = Apexpages.currentpage().getparameters().get('sfInternalId');
            nextFunction();
        }
        String IPAddress = ApexPages.currentPage().getHeaders().get('True-Client-IP');
        //Get IP address when no caching (sandbox, dev, secure urls)
        if (String.isBlank(IPAddress)) {
            IPAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        }  
        if (String.isBlank(IPAddress)) {
            IPAddress = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        }
        String browserAgent = ApexPages.currentPage().getHeaders().get('User-Agent');
        userSession = (IPAddress !=null ? ('IP Address : ' + IPAddress + '\n\n' ): '') + ('User Agent : ' + browserAgent !=null ? (browserAgent + '\n' ): '');
    }
    
    public PageReference checkPaymentProcessor(){
        if(String.isNotBlank(validationString)){
			System.debug(validationString);
            Id billingId = PaymentGateway_Ctrl.processDecryption(validationString.trim() ,Label.Encryption_Key_Payment_Id); 
            List<AcctSeed__Billing__c> billingList = new List<AcctSeed__Billing__c>([SELECT Id,AcctSeed__Payment_Processor__r.Name,Internal_Payment_Link__c FROM AcctSeed__Billing__c WHERE Id=: billingId]);
            if(!billingList.isEmpty() && billingList[0].AcctSeed__Payment_Processor__r.Name != 'Forte'){
                redirectUrl = paymentGatewayClass.getUrl()+'?'+billingList[0].Internal_Payment_Link__c.substringAfter('?');
            }
            else{
                nextFunction();
            } 
        }
        return null;
    }
    
    public void nextFunction(){
        system.debug('currentStage'+currentStage);
        if(currentStage == 'schedule'){
            List<AcctSeed__Billing__c> billingList;
            system.debug('validationString'+validationString);
            System.debug('sfInternalId' + sfInternalId);
            if(validationString == null){
                if(sfInternalId == null){
                    String zipCodePattern = (warpperObj.zipCode.trim() + '-%');
                    billingList = [select id,name,AcctSeed__Due_Date2__c ,AcctSeed__Balance__c,AcctSeed__Customer__r.Name, Policy_Endorsement__c,
                                   AcctSeed__Customer__c,First_Payment_Date__c,IsPaymentProcessed__c,Mode_Of_Payment__c,
                                   Next_Payment_Base_Amount__c,Next_Payment_Date__c,Next_Payment_Service_Fee__c,AcctSeed__Billing_Street__c,
                                   Payment_Frequency__c,Firm_Name__c,Legacy_Invoice_Id__c,Legacy_Firm_Id__c,AcctSeed__Billing_City__c,AcctSeed__Received_Amount__c ,Allow_CatchUp_Schedule__c , Policy__r.Total_CLE_Credit__c, Policy__r.Policy_Dividend__c, Policy__r.Premium__c,Policy__r.Total_Credit__c,
                                   AcctSeed__Customer__r.AccountNumber,AcctSeed__Billing_State__c,AcctSeed__Billing_PostalCode__c,Billing_Description__c,AS_Transaction_Description__c,Policy__r.Effective_Date__c,Policy__c,Policy__r.Expiration_Date__c  
                                   from AcctSeed__Billing__c 
                                   where (((name=:warpperObj.policyInvoiceNumber.trim() OR Policy__r.Name =:warpperObj.policyInvoiceNumber.trim()) 
                                          and (AcctSeed__Customer__r.BillingPostalCode=:warpperObj.zipCode.trim() or AcctSeed__Customer__r.BillingPostalCode like: zipCodePattern))
                                   OR
                                   ((AcctSeed__Customer__r.Name='Dummy Billing Account' AND Billing_Zip_Code__c=:warpperObj.zipCode.trim()) 
                                    AND (Legacy_Invoice_Id__c=:warpperObj.policyInvoiceNumber.trim() OR Legacy_Policy_Id__c =:warpperObj.policyInvoiceNumber.trim()) )) 
                                   AND 
                                   AcctSeed__Payment_Processor__r.AcctSeed__Type__c != 'Cardknox'
                                   limit 1];
                }else{
                    billingList = [select id,name,AcctSeed__Due_Date2__c ,AcctSeed__Balance__c,AcctSeed__Customer__r.Name, Policy_Endorsement__c,
                               AcctSeed__Customer__c,First_Payment_Date__c,IsPaymentProcessed__c,Mode_Of_Payment__c,
                               Next_Payment_Base_Amount__c,Next_Payment_Date__c,Next_Payment_Service_Fee__c,AcctSeed__Billing_Street__c,Policy__r.Total_CLE_Credit__c, Policy__r.Policy_Dividend__c,Policy__r.Premium__c,Policy__r.Total_Credit__c,
                               Payment_Frequency__c,Firm_Name__c,Legacy_Invoice_Id__c,Legacy_Firm_Id__c,AcctSeed__Billing_City__c,AcctSeed__Received_Amount__c, Allow_CatchUp_Schedule__c ,
                               AcctSeed__Customer__r.AccountNumber,AcctSeed__Billing_State__c,AcctSeed__Billing_PostalCode__c,Billing_Description__c,AS_Transaction_Description__c  ,Policy__r.Effective_Date__c,Policy__c,Policy__r.Expiration_Date__c
                                   from AcctSeed__Billing__c 
                                   where Id =: sfInternalId 
                                   AND 
                                   AcctSeed__Payment_Processor__r.AcctSeed__Type__c != 'Cardknox'
                               limit 1];
                }
                
            }else{
                System.debug(validationString);
                Id billingId = PaymentGateway_Ctrl.processDecryption(validationString.trim() ,Label.Encryption_Key_Payment_Id);
                SYstem.debug(billingId);
                billingList = [select id,name,AcctSeed__Due_Date2__c ,AcctSeed__Balance__c,AcctSeed__Customer__r.Name, Policy_Endorsement__c,
                               AcctSeed__Customer__c,First_Payment_Date__c,IsPaymentProcessed__c,Mode_Of_Payment__c,
                               Next_Payment_Base_Amount__c,Next_Payment_Date__c,Next_Payment_Service_Fee__c,AcctSeed__Billing_Street__c,Policy__r.Total_CLE_Credit__c, Policy__r.Policy_Dividend__c,Policy__r.Premium__c,Policy__r.Total_Credit__c,
                               Payment_Frequency__c,Firm_Name__c,Legacy_Invoice_Id__c,Legacy_Firm_Id__c,AcctSeed__Billing_City__c,AcctSeed__Received_Amount__c, Allow_CatchUp_Schedule__c ,
                               AcctSeed__Customer__r.AccountNumber,AcctSeed__Billing_State__c,AcctSeed__Billing_PostalCode__c,Billing_Description__c,AS_Transaction_Description__c  ,Policy__r.Effective_Date__c,Policy__c,Policy__r.Expiration_Date__c
                               from AcctSeed__Billing__c 
                               where Id =: billingId
                               AND 
                               AcctSeed__Payment_Processor__r.AcctSeed__Type__c != 'Cardknox'
                               limit 1];
            }
            
            if(billingList==null || billingList.size()==0 || billingList[0].AcctSeed__Balance__c<0){
                noInvoiceFound = true;
                currentStage='findInvoice';
                invoiceNotFoundErrorMessage = 'Error: No invoice found. Please verify Policy/Invoice # and Zip Code';
            }
            else{
                 billing= billingList[0];
                if(billingList[0].IsPaymentProcessed__c || billingList[0].AcctSeed__Received_Amount__c != 0){
                    noInvoiceFound = true;
                    currentStage='findInvoice';
                    invoiceNotFoundErrorMessage ='Error: Payment has been already submitted for this invoice';
                    
                }/*else if(billingList[0].AcctSeed__Due_Date2__c .addMonths(3) < system.today()){
                    noInvoiceFound = true;
                    currentStage='findInvoice';
                    invoiceNotFoundErrorMessage ='Your invoice has passed the time limit to make an online Payment please contact accounting@isbamutual.com.';
                    
                }*/
                else{
                   // billing= billingList[0];
                    noInvoiceFound = false;
                    
                    if(totalAmountDue == null){
                        totalAmountDue = billing.AcctSeed__Balance__c;
                    }
                    
                    // Line Added by Sarbjeet
                    
                    warpperObj.billingStreet = billing.AcctSeed__Billing_Street__c;
                    warpperObj.billingCity = billing.AcctSeed__Billing_City__c;
                    warpperObj.billingState = billing.AcctSeed__Billing_State__c;
                    warpperObj.billingPostal = billing.AcctSeed__Billing_PostalCode__c;
                    warpperObj.effectiveDate = billing.AcctSeed__Due_Date2__c;
                    totalCredit = (billing.Policy__r.Total_Credit__c != null ? billing.Policy__r.Total_Credit__c : 0) ;
                    totalCLECredit = (billing.Policy__r.Total_CLE_Credit__c != null ? billing.Policy__r.Total_CLE_Credit__c : 0) ;
                    policyDividend = (billing.Policy__r.Policy_Dividend__c != null ? billing.Policy__r.Policy_Dividend__c : 0) ;
                    premium = billing.Policy__r.Premium__c;
                    balance = billing.AcctSeed__Balance__c;
                    if(billing.Policy__c != null){
                        warpperObj.effectiveDate = billing.Policy__r.Effective_Date__c;
                    }
                    warpperObj.balanceDue = billing.AcctSeed__Balance__c;
                    warpperObj.description = (billing.Billing_Description__c != null ? billing.Billing_Description__c : billing.AS_Transaction_Description__c);
                    if(billing.AcctSeed__Customer__r.Name=='Dummy Billing Account'){
                        accountName = billing.Firm_Name__c;
                        warpperObj.invoiceId=billing.Legacy_Invoice_Id__c;
                        warpperObj.firmId=billing.Legacy_Firm_Id__c;
                        warpperObj.firmName=accountName;
                    }else{
                        accountName = billing.AcctSeed__Customer__r.Name;
                        warpperObj.invoiceId=billing.Name;
                        warpperObj.firmId=billing.AcctSeed__Customer__r.AccountNumber;
                        warpperObj.firmName=accountName;
                    }
                    
                    if(lasttime != 'Full'){
                        warpperObj.paymentTypeVar='';
                        warpperObj.paymentScheduleVar = lasttime;
                        paymentScheduleFunction();
                    }
                }
            }
            
            if(billing != null){
                if(billing.Payment_Frequency__c == null && String.isBlank(warpperObj.paymentScheduleVar)){
                    warpperObj.paymentScheduleVar = 'Full';
                    paymentScheduleFunction();
                }
                
                bcrList = new List<AcctSeed__Billing_Cash_Receipt__c>(
                    [select id,Name ,AcctSeed__Applied_Amount__c,AcctSeed__Applied_Date__c, AcctSeed__Status__c,AcctSeed__Cash_Receipt__r.AcctSeed__Receipt_Date__c,
                     AcctSeed__Cash_Receipt__r.AcctSeed__Purpose__c from AcctSeed__Billing_Cash_Receipt__c where AcctSeed__Billing__c =: billing.Id ]);
                
                billingLines = new List<AcctSeed__Billing_Line__c>(
                    [select id, Name, AcctSeed__Comment__c, AcctSeed__Total__c from AcctSeed__Billing_Line__c where AcctSeed__Billing__c =: billing.Id ]);
                
                creditMemo = new List<AcctSeed__Billing_Credit_Memo__c>(
                    [select id,Name,AcctSeed__Amount__c ,AcctSeed__Applied_Date__c from AcctSeed__Billing_Credit_Memo__c where AcctSeed__Billing_Invoice__c  =: billing.Id ]);
                
                integrationLog = new List<Integration_Log__c>(
                    [select id,Name, Status__c from Integration_Log__c where Billing__c  =: billing.Id ]);
            }            
        }else if(currentStage == 'payment'){
            paymentInvalidDate = false;
            if(warpperObj.paymentScheduleVar=='Full'){
                if(policy.Effective_Date__c < System.today() || policy.Effective_Date__c > warpperObj.effectiveDate){
                    currentStage='schedule';
                    paymentInvalidDateError = 'Invalid Payment Date Selected';
                    paymentInvalidDate = true;
                    firstInstallmentDate = warpperObj.effectiveDate;
                }else if(policy.Effective_Date__c ==  System.today()){
                    totalAmountDue = billing.AcctSeed__Balance__c;
                }else{
                    if(policy.Effective_Date__c == null){
                        firstInstallmentDate = warpperObj.effectiveDate;
                    }else{
                        firstInstallmentDate = policy.Effective_Date__c;
                    }
                    firstInstallmentDateString = '('+ firstInstallmentDate.day()+' '+DateTime.newInstanceGMT(System.Date.newInstance(firstInstallmentDate.year(), firstInstallmentDate.month(), firstInstallmentDate.day()),System.Time.newInstance(0, 0, 0, 0)).formatGMT('MMM') +  ' \' '+  firstInstallmentDate.year()  + ')';
                }
            }
        }
        else if(currentStage == 'contactDetails'){
            if(SelectedMethod !='' && SelectedMethod != null){
                boolean boo = true;
                for( AcctSeed__Payment_Method__c Paymethod: [SELECT Name,Credit_Card_Number__c,AcctSeed__Routing_Number__c,AcctSeed__Card_Holder_Name__c,Account_Number__c,Name_on_Card__c,AcctSeed__Type__c,AcctSeed__External_Id__c,AcctSeed__Last_Four_Digits__c,AcctSeed__Expiration_Month__c,AcctSeed__Expiration_Year__c, Id, Card_Verification_Number__c, AcctSeed__Bank_Account_Type__c   FROM AcctSeed__Payment_Method__c WHERE Id =: SelectedMethod])
                {
                    boo = false;
                    warpperObj.cardTypeVar = Paymethod.AcctSeed__Type__c;
                    warpperObj.cardNumber = Paymethod.Credit_Card_Number__c;
                    warpperObj.verificationNumber = Paymethod.Card_Verification_Number__c  ;
                    warpperObj.expireMonth = Paymethod.AcctSeed__Expiration_Month__c;
                    warpperObj.expireYear = Paymethod.AcctSeed__Expiration_Year__c;
                    warpperObj.nameOnCard = Paymethod.Name_on_Card__c;
                    warpperObj.accountNumber = Paymethod.Account_Number__c;
                    warpperObj.routingNumber = Paymethod.AcctSeed__Routing_Number__c;
                    warpperObj.accountType = Paymethod.AcctSeed__Bank_Account_Type__c ;
                    warpperObj.accountHolderName = Paymethod.AcctSeed__Card_Holder_Name__c;
                    paymentMethod = Paymethod;
                    paymentMethod.Id = null;
                }
                if(boo){
                    warpperObj.cardTypeVar = null;
                    warpperObj.cardNumber = null;
                    warpperObj.verificationNumber = null  ;
                    warpperObj.expireMonth = null;
                    warpperObj.expireYear = null;
                    warpperObj.nameOnCard = null;
                    warpperObj.accountNumber = null;
                    warpperObj.routingNumber = null;
                    warpperObj.accountType = null;
                    warpperObj.accountHolderName = null;
                    paymentMethod = null;
                }
            }else{
                warpperObj.cardTypeVar = null;
                warpperObj.cardNumber = null;
                warpperObj.verificationNumber = null  ;
                warpperObj.expireMonth = null;
                warpperObj.expireYear = null;
                warpperObj.nameOnCard = null;
                warpperObj.accountNumber = null;
                warpperObj.routingNumber = null;
                warpperObj.accountType = null;
                warpperObj.accountHolderName = null;
                paymentMethod = null;
            }
        }
        else if(currentStage == 'processPayment'){
            
            processPayment();
        }
    }
    public List<SelectOption> ExistingList{
        get
        {
            
            ExistingList = new List<SelectOption>();
            ExistingList.add(new SelectOption('','--None--'));
            for( AcctSeed__Payment_Method__c Paymethod: [SELECT AcctSeed__Last_Four_Digits__c, Id,AcctSeed__Payment_Method_Type__c FROM AcctSeed__Payment_Method__c WHERE AcctSeed__Customer__c=:billing.AcctSeed__Customer__c])
            {
                ExistingList.add(new SelectOption(Paymethod.Id,Paymethod.AcctSeed__Payment_Method_Type__c + '-' + Paymethod.AcctSeed__Last_Four_Digits__c));
              
            }       
            return ExistingList; 
        }
        set;
    }

    public void paymentScheduleFunction(){
        system.debug('debug paymentScheduleVar=>'+warpperObj.paymentScheduleVar);
        if(warpperObj.paymentScheduleVar=='Month'){
            enablePaymentDate = false;
            lasttime = 'Month';
            Decimal numberOfPayments = 12;
            Date monthlyBilling = warpperObj.effectiveDate;
            
            if(billing.Allow_CatchUp_Schedule__c){
                monthlyBilling = System.today();
                numberOfPayments = monthlyBilling.monthsBetween(billing.Policy__r.Expiration_Date__c);
            }
            
            perMonthAmount = billing.AcctSeed__Balance__c / numberOfPayments;
            firstInstallment = perMonthAmount;
            //Date monthlyBilling = billing.AcctSeed__Due_Date2__c ; // Change done for billing date from system date;
            paymentMonths = new List<String>();
            finalPaymentMonths = new List<String>();
            perTotalMonthAmount =0; 
            totalAmountDue = 0;                          // Change login by sarbjeet
            paymentMonthsDt = null;    
            
            for(Integer i=0;i<numberOfPayments;i++){
                
                if(monthlyBilling.addMonths(i) <=system.Today()){
                    
                    totalAmountDue += perMonthAmount;
                    
                } else if(i==0 && monthlyBilling <= system.Today()){
                    
                    totalAmountDue += perMonthAmount;
                    
                } else {
                    
                    Integer day;
                    
                    if(monthlyBilling.day()>28){
                        
                        Date startDate = monthlyBilling.addMonths(i).toStartOfMonth(); 
                        Date endDate = startDate.addMonths(1).toStartOfMonth().addDays(-1);
                        
                        if(startDate.day() <= monthlyBilling.day() && endDate.day() >=monthlyBilling.day()){
                            
                            day = monthlyBilling.day();
                            
                        } else {
                            
                            day = endDate.day();
                        }
                        
                    } else {
                        
                        day = monthlyBilling.day();
                    }
                    
                    // testing format khoker DD 'mon YYYY
                    //paymentMonths.add('('+day+' '+DateTime.newInstanceGMT(System.Date.newInstance(monthlyBilling.addMonths(i).year(), monthlyBilling.month()+i, day), System.Time.newInstance(0, 0, 0, 0)).formatGMT('MMM') +  ' \' '+  monthlyBilling.addMonths(i).year()  + ')');
                    
                    // mm/dd/yyyy
                    paymentMonths.add('('+DateTime.newInstanceGMT(System.Date.newInstance(monthlyBilling.addMonths(i).year(), monthlyBilling.month()+i, day), System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM') + '/' + day + '/' +  monthlyBilling.addMonths(i).year()  + ')');
                    
                    finalPaymentMonths.add(DateTime.newInstanceGMT(System.Date.newInstance(monthlyBilling.addMonths(i).year(), monthlyBilling.month()+i, day), System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM') + '/'+ (String.valueOf(day).length() == 1 ? ('0'+day): ''+day)+'/' +  monthlyBilling.addMonths(i).year()); 
                    
                    if(paymentMonthsDt == null){
                        paymentMonthsDt = monthlyBilling.addMonths(i);// System.Date.newInstance(monthlyBilling.addMonths(i).year(), monthlyBilling.month()+i, day);
                    }
                    
                    firstInstallmentDate = paymentMonthsDt;
                    
                }
                
            }
            
            if(totalAmountDue == 0){
                
                perTotalMonthAmount = perMonthAmount;
                
            } else {
                
                perTotalMonthAmount = totalAmountDue ;
            }
            
        }else if(warpperObj.paymentScheduleVar=='Quarter'){
            enablePaymentDate = false;
            lasttime = 'Quarter';
            perQuarterAmount = billing.AcctSeed__Balance__c / 4;
            firstInstallment = perQuarterAmount;
            //Date quarterlyBilling = billing.AcctSeed__Due_Date2__c ;
            Date quarterlyBilling = warpperObj.effectiveDate;
            paymentQuarters = new List<String>();
            finalPaymentQuarters = new List<String>(); 
            perTotalQuarterAmount = 0 ;
            totalAmountDue = 0;                          // Change login by sarbjeet
            paymentQuartersDt = null;
            
            //totalAmountDue += perQuarterAmount;
            
            for(Integer i =0;i<12;i+=3 ){
                if(quarterlyBilling.addMonths(i) <=system.Today()){
                    
                    totalAmountDue += perQuarterAmount;
                    
                } else if(i==0 && quarterlyBilling <= system.Today()){
                    
                    totalAmountDue += perQuarterAmount;
                    
                } else {
                    Integer day;
                    
                    if(quarterlyBilling.day()>28){
                        
                        Date startDate = quarterlyBilling.addMonths(i).toStartOfMonth(); 
                        Date endDate = startDate.addMonths(1).toStartOfMonth().addDays(-1);
                        
                        if(startDate.day() <= quarterlyBilling.day() && endDate.day() >=quarterlyBilling.day()){
                            
                            day = quarterlyBilling.day();
                            
                        } else {
                            
                            day = endDate.day();
                        }
                        
                    } else {
                        
                        day = quarterlyBilling.day();
                    }
                    System.debug('quarterlyBilling'+quarterlyBilling);
                    paymentQuarters.add('('+ day+' '+DateTime.newInstanceGMT(System.Date.newInstance(quarterlyBilling.addMonths(i).year(), quarterlyBilling.month()+i, day),System.Time.newInstance(0, 0, 0, 0)).formatGMT('MMM') +  ' \' '+  quarterlyBilling.addMonths(i).year()  + ')');
                    
                    finalPaymentQuarters.add(DateTime.newInstanceGMT(System.Date.newInstance(quarterlyBilling.addMonths(i).year(), quarterlyBilling.month()+i, day), System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM') + '/'+ (String.valueOf(day).length() == 1 ? ('0'+day): ''+day) +'/' +  quarterlyBilling.addMonths(i).year()); 
                    if(paymentQuartersDt == null){
                        
                        paymentQuartersDt = quarterlyBilling.addMonths(i);// System.Date.newInstance((quarterlyBilling.addMonths(i)).year(), quarterlyBilling.month()+i, day);
                        
                    }
                    
                    firstInstallmentDate = paymentQuartersDt;
                    System.debug('paymentQuartersDt'+paymentQuartersDt);
                }
            }
            
            if(totalAmountDue == 0){
                
                perTotalQuarterAmount = perQuarterAmount;
                
            } else {
                
                perTotalQuarterAmount = totalAmountDue ;
            }
            
        } else {
            firstInstallment = billing.AcctSeed__Balance__c;
            lasttime = 'Full';
            //if(billing.AcctSeed__Due_Date2__c > System.today()){
            if(warpperObj.effectiveDate > System.today()){
                totalAmountDue = 0;
                //firstInstallmentDate = billing.AcctSeed__Due_Date2__c;
                policy.Effective_Date__c = warpperObj.effectiveDate;
                enablePaymentDate = true;
                firstInstallmentDate = warpperObj.effectiveDate;
                
                // (29 Nov ' 2021)
                //firstInstallmentDateString = '('+ firstInstallmentDate.day()+' '+DateTime.newInstanceGMT(System.Date.newInstance(firstInstallmentDate.year(), firstInstallmentDate.month(), firstInstallmentDate.day()),System.Time.newInstance(0, 0, 0, 0)).formatGMT('MMM') +  ' \' '+  firstInstallmentDate.year()  + ')';
            	
                // (11/29/2021)
				firstInstallmentDateString = '('+ DateTime.newInstanceGMT(System.Date.newInstance(firstInstallmentDate.year(), firstInstallmentDate.month(), firstInstallmentDate.day()),System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM/dd/yyyy')  + ')';

                
            }else{
                totalAmountDue = billing.AcctSeed__Balance__c;
            }
            
        }
        paymentTypeFunction();
    }
    public void processPayment(){
        Savepoint sp;
        try{
            paymentError =false;
            paymentErrorMessage='';
            String ipAddress = ApexPages.currentPage().getHeaders().get('True-Client-IP');
            if (ipAddress == '') {
                ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
            }
            System.debug('baseAmountToPay' + baseAmountToPay);
            System.debug(totalAmountDue);
            ForteUtil util;
            String transactionAction = '';
            if(warpperObj.paymentTypeVar=='check' && String.isBlank(warpperObj.accountType)){
                currentStage='contactDetails';
                paymentErrorMessage = 'An error has occurred with the Account Type';
                paymentError = true;
            }else if((warpperObj.paymentTypeVar=='creditCard' || (warpperObj.paymentTypeVar == 'Existing' && warpperObj.cardNumber !=null)) && warpperObj.balanceDue > 20000){
                currentStage='contactDetails';
                paymentErrorMessage = 'Credit Card payments not available for transactions exceeding $20,000';
                paymentError = true;
            }else{
                boolean paymentSuccess = false;
                if(totalAmountDue == 0){
                    util = ForteUtil.authorizeTransaction(firstInstallment,ipAddress,warpperObj);
                    System.debug(util + 'util');
                    if(util.response.response_code == 'POS' || util.response.response_code == 'A01' || (util.response.response_code == 'U80' && util.response.preauth_desc == 'P15:HIGH RISK')){
                        paymentSuccess = true;
                    }
                    transactionAction = 'authorize';
                }else{
                    util = ForteUtil.createTransaction(baseAmountToPay,ipAddress,warpperObj);
                    transactionAction = 'sale';
                    if(util.response.response_code == 'A01'){
                        paymentSuccess = true;
                    }else if((util.response.response_code == 'U80' && util.response.preauth_desc == 'P15:HIGH RISK')){
                        util = ForteUtil.createForceTransaction(baseAmountToPay,ipAddress,warpperObj);
                        transactionAction = 'force';
                        if(util.response.response_code == 'A01'){
                            paymentSuccess = true;
                        }
                    }
                }
                ForteUtil util1;
                if(util.response.response_code == 'A01'){
                    if(totalAmountDue - baseAmountToPay>0){
                        //util1 = ForteUtil.createTransaction(totalAmountDue - baseAmountToPay,ipAddress,warpperObj);
                    }
                }
                //  sp = database.setSavepoint();`
                if(paymentSuccess){    
                    
                    String jsonBody = '';
                    
                    jsonBody = '{"warpperObj" :'+JSON.serialize(warpperObj)+',"UtilTranId" : {"UtilTranId" : "'+util.transaction_id+'"},"Billing" :{"Id": '+JSON.serialize(billing.id) +'},"paymentQuartersDt" : {"paymentQuartersDt" : "'+paymentQuartersDt+'"},"baseAmountToPay" : {"baseAmountToPay" : "'+baseAmountToPay+'"},"paymentMonthsDt" : {"paymentMonthsDt" : "'+paymentMonthsDt+'"},"totalAmountDue" : {"totalAmountDue" : "'+totalAmountDue+'"},"receiptNumber" : {"receiptNumber" : "'+receiptNumber+'"},"firstInstallment" : {"firstInstallment" : "'+firstInstallment+'"},"firstInstallmentDate" : {"firstInstallmentDate" : "'+firstInstallmentDate+'"}}';
                    system.debug('jsonBody'+jsonBody);
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint('callout:CashReceipt_Api/services/apexrest/DynamicPayment');
                    request.setMethod('POST');
                    request.setHeader('Content-Type','application/json'); 
                    request.setBody(jsonBody);
                    request.setTimeout(120000);
                    Http http = new Http();
                    HTTPResponse APIresponse = new  HTTPResponse ();
                    if(!test.isRunningTest()){
                        APIresponse = http.send(request);
                        system.debug('APIresponse :: ' + APIresponse);
                    }else{
                        APIresponse.setHeader('Content-Type', 'application/json');
                        APIresponse.setBody('{"id": "a0C5w000011iNqW"}');
                        APIresponse.setStatusCode(200);
                    }
                    system.debug('APIresponse.getStatusCode :: '+APIresponse.getStatusCode());
                    system.debug('APIresponse.getBody :: '+APIresponse.getBody());
                    
                    PaymentRestApi.PaymentRestApiWrapper wrapper = (PaymentRestApi.PaymentRestApiWrapper) System.JSON.deserialize(APIresponse.getBody(), PaymentRestApi.PaymentRestApiWrapper.class);
                    
                    if(wrapper.error != null){
                        //currentStage='contactDetails';
                        //paymentErrorMessage = 'An error occurred while processing your payment.';
                        //paymentError = true;
                        Integration_Log__c log = new Integration_Log__c();
                        log.Billing__c =billing.id;
                        log.Status__c='Processed With Errors';
                        log.Transaction_Amount__c=totalAmountDue;
                        log.Transaction_Id__c=util.transaction_id;
                        log.Transaction_Action__c = transactionAction;
                        if(util1!=null){
                            log.Transaction_Id__c= log.Transaction_Id__c + ',' + util1.transaction_id;
                        }
                        log.Description__c='Error : '+ wrapper.error;
                        log.User_Session__c = userSession;
                        insert log;
                    }
                    else{
                        /*
Account acc = new Account();
acc.id=billing.AcctSeed__Customer__c;
acc.Billing_Confirmation_Email__c=warpperObj.confirmationEmail;
acc.Billing_First_Name__c=warpperObj.firstName;
acc.Billing_Last_Name__c=warpperObj.lastName;
if(warpperObj.paymentTypeVar=='check'){
acc.Billing_Account_Holder_Name__c=warpperObj.accountHolderName;
acc.Billing_Account_Number__c=String.valueOf(warpperObj.accountNumber);
acc.Billing_Account_Type__c=warpperObj.accountType;
acc.Billing_Routing_Number__c=warpperObj.routingNumber;
}else if(warpperObj.paymentTypeVar=='creditCard'){
acc.Billing_Card_Expire_Month__c=Decimal.valueOf(warpperObj.expireMonth);
acc.Billing_Card_Expire_Year__c=Decimal.valueOf(warpperObj.expireYear);
acc.Billing_Card_Number__c=String.valueof(warpperObj.cardNumber);
acc.Billing_Card_Type__c=warpperObj.cardTypeVar;
acc.Billing_Card_Verification_Number__c=warpperObj.verificationNumber;
acc.Billing_Name_On_Card__c=warpperObj.nameOnCard;
}

update acc;*/		receiptNumber = wrapper.receiptNumber;
                        List<OrgWideEmailAddress> orgWideEmailAddress = [SELECT Id, Address FROM OrgWideEmailAddress where Address = 'accounting@isbamutual.com'];
                        try{
                            if(warpperObj.confirmationEmail!=null || warpperObj.confirmationEmail!=''){
                                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                //mail.setSenderDisplayName('ISBA Mutual Insurance');
                                List<OrgWideEmailAddress> oweaList = [select Id,DisplayName from OrgWideEmailAddress Where DisplayName =: Label.OrganizationWideEmail];
                                if (!oweaList.isEmpty()) {
                                    mail.setOrgWideEmailAddressId(oweaList.get(0).Id);
                                } 
                                mail.setToAddresses(new String[]{warpperObj.confirmationEmail});
                                mail.setSubject('ISBA Mutual Insurance - Payment Received (Invoice #'+warpperObj.invoiceId+')');
                                mail.setBccAddresses(new String[]{Label.ISBA_Accounting_Automation_Email_Address });
                                mail.setInReplyTo(Label.ISBA_Accounting_Email_Address);
                                String body = 'Dear ' + warpperObj.firstName+' '+warpperObj.lastName + '<br/><br/>';
                                if(warpperObj.paymentScheduleVar=='Full' && totalAmountDue > 0){
                                    body += 'Your payment to ISBA Mutual for $'+totalAmountDue.setScale(2) +' has been successfully processed.<br/>';
                                    body += 'For your reference, the transaction number for this payment is: '+ receiptNumber + '<br/><br/>';
                                }else if(warpperObj.paymentScheduleVar=='Full' && totalAmountDue == 0){
                                    body += 'Your payment to ISBA Mutual for $'+firstInstallment.setScale(2) +' will be processed on ' + firstInstallmentDate.format() +'.<br/>';
                                    //body += 'For your reference, the transaction number for this is: '+ receiptNumber + '<br/><br/>';
                                }else{
                                    if(totalAmountDue == 0){
                                        body += 'Your first installment to ISBA Mutual for $'+firstInstallment.setScale(2) +' will be processed on ' + firstInstallmentDate.format() +'.<br/>';
                                    }else{
                                        body += 'Your first installment to ISBA Mutual for $'+totalAmountDue.setScale(2) +' has been successfully processed.<br/>';
                                    	body += 'For your reference, the transaction number for this is: '+ receiptNumber + '<br/>';
                                    }
                                    
                                    body += '<br/>Your future payments will be executed as follows;<br/><br/><br/>Payment Schedule:<br/><br/>';
                                    if(warpperObj.paymentScheduleVar=='Quarter'){
                                        for(String str : finalpaymentQuarters){
                                            body += '$'+firstInstallment.setScale(2);
                                            if(warpperObj.paymentTypeVar=='creditCard'){
                                                //body += ' + $'+creditCardServiceFee.setScale(2);
                                            }
                                            body += '     ('+ str +')<br/>';
                                        }
                                    }else if(warpperObj.paymentScheduleVar=='Month'){
                                        for(String str : finalpaymentMonths){
                                            body += '$'+firstInstallment.setScale(2);
                                            if(warpperObj.paymentTypeVar=='creditCard'){
                                                //body += ' + $'+creditCardServiceFee.setScale(2);
                                            }
                                            body += '     ('+ str +')<br/>';
                                        }
                                    }
                                    body += '<br/>' ;
                                } 
                                body += 'Thank you,<br/>ISBA Mutual Accounting Department<br/>312-379-2005';
                                mail.setHtmlBody(body);
                                mail.setWhatId(billing.id);
                                mail.setSaveAsActivity(true);
                                allmsg.add(mail);
                                Messaging.sendEmail(allmsg,false);
                            }
                            
                            
                            Integration_Log__c log = new Integration_Log__c();
                            log.Billing__c =billing.id;
                            log.Status__c='Processed Successfully';
                            log.Transaction_Amount__c=totalAmountDue;
                            log.Transaction_Id__c=util.transaction_id;
                            log.Transaction_Action__c = transactionAction;
                            log.Cash_Receipt__c = wrapper.cashReceiptId;
                            if(util1!=null){
                                log.Transaction_Id__c= log.Transaction_Id__c + ',' + util1.transaction_id;
                            }
                            if(totalAmountDue == 0){
                                log.Description__c='Verify Processed Successfully';
                            }else{
                                log.Description__c='Payment Processed Successfully';
                            }
                            log.User_Session__c = userSession;
                            insert log;
                            
                            
                        }catch(Exception e){
                            System.debug('Error--'+e.getMessage()+'--Line--'+e.getLineNumber());
                            Database.rollback(sp);
                            //currentStage='contactDetails';
                            //paymentErrorMessage = 'An error occurred while generating cash receipt. Your transaction id is : '+util.transaction_id;
                            //paymentError = true;
                            Integration_Log__c log = new Integration_Log__c();
                            log.Billing__c =billing.id;
                            log.Status__c='Processed With Errors';
                            log.Transaction_Amount__c=totalAmountDue;
                            log.Transaction_Id__c=util.transaction_id;
                            log.Transaction_Action__c = transactionAction;
                            if(util1!=null){
                                log.Transaction_Id__c= log.Transaction_Id__c + ',' + util1.transaction_id;
                            }
                            log.Description__c='Error : '+e.getMessage() + '\n' + e.getStackTraceString() + '\n';
                            log.User_Session__c = userSession;
                            insert log;
                        }
                    }
                }else{
                    if(!paymentSuccess){
                        currentStage='contactDetails';
                        paymentErrorMessage = 'An error occurred while processing your payment (Error Code :'+ util.response.response_code + ' - ' + util.response.response_desc + ').';
                        paymentError = true;
                        Integration_Log__c log = new Integration_Log__c();
                        log.Billing__c =billing.id;
                        log.Status__c='Processed With Errors';
                        log.Transaction_Amount__c=totalAmountDue;
                        log.Description__c='(Error Code :'+ util.response.response_code + ' - ' + util.response.response_desc + ').';
                        log.Transaction_Action__c = transactionAction;
                        if(util.response.response_code == 'U80'){
                            log.Description__c += ('\n' + util.response.preauth_desc + '\n' + util.response.preauth_result + '\n' + util.response.preauth_neg_report );
                            if(util.response.preauth_desc != null){
                                paymentErrorMessage += ('(' + util.response.preauth_desc + ')');
                            }
                        }
                        log.JSON_Body__c = (ApexPages.currentPage().getHeaders().get('User-Agent') !=null ? ApexPages.currentPage().getHeaders().get('User-Agent') : '' )+ '\n' + JSON.serialize(warpperObj);
                        log.User_Session__c = userSession;
                        insert log;
                    }else if(util1.response.response_code != 'A01'){
                        currentStage='contactDetails';
                        paymentErrorMessage = 'An error occurred while processing your payment (Error Code :'+ util1.response.response_code + ' - ' + util1.response.response_desc + ').';
                        paymentError = true;
                        Integration_Log__c log = new Integration_Log__c();
                        log.Transaction_Action__c = transactionAction;
                        log.Billing__c =billing.id;
                        log.Status__c='Processed With Errors';
                        log.Transaction_Amount__c=totalAmountDue;
                        log.Transaction_Action__c = transactionAction;
                        log.Description__c='(Error Code :'+ util1.response.response_code + ' - ' + util1.response.response_desc + ').';
                        log.User_Session__c = userSession;
                        insert log;
                    }
                    
                }
                AcctSeed__Billing__c  billToUpdate = new AcctSeed__Billing__c ();
                billToUpdate.Id = billing.id;
                billToUpdate.Online_Payment_User__c = UserInfo.getUserId();
                update billToUpdate;
            }
        }catch(Exception e){
            currentStage='contactDetails';
            paymentErrorMessage = 'An error occurred while processing your payment.';
            paymentError = true;
            Integration_Log__c log = new Integration_Log__c();
            log.Billing__c =billing.id;
            log.Status__c='Processed With Errors';
            log.Transaction_Amount__c=totalAmountDue;
            log.Description__c='Error : '+e.getMessage() + '\n' + e.getStackTraceString() + '\n';
            log.User_Session__c = userSession;
            insert log;
        }
    }
    public static string processEncryption(String name, String key){ 
        Blob cryptoKey = Blob.valueOf(key);
        Blob data = Blob.valueOf(name); 
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey, data); 
        String b64Data = EncodingUtil.base64Encode(encryptedData);  
        System.debug(b64Data);
        return b64Data; 
    } 
    
    public static String processDecryption(String encryptedData, String key){ 
        System.debug(encryptedData);
        String decryptedData; 
        Blob data = EncodingUtil.base64Decode(encryptedData); 
        Blob privateKey = Blob.valueOf(key);  
        String expMsg;
        try{ 
            Blob dataToDecrypt = Crypto.decryptWithManagedIV('AES128', privateKey, data); 
            decryptedData = dataToDecrypt.toString(); 
        } 
        catch(Exception e){ 
            expMsg = e.getMessage();  
        } 
        return (string.isEmpty(expMsg) ?  decryptedData :  expMsg);  
    } 
    public Decimal getCHECK_TRANSACTION_FEE(){
        return CHECK_TRANSACTION_FEE;
    }
    public Decimal getCREDIT_CARD_SERVICE_FEE_VISA(){
        return CREDIT_CARD_SERVICE_FEE_VISA;
    }
    public Decimal getCREDIT_CARD_SERVICE_FEE_MasterCard(){
        return CREDIT_CARD_SERVICE_FEE_MasterCard;
    }
    public Decimal getCREDIT_CARD_SERVICE_FEE_Discovery(){
        return CREDIT_CARD_SERVICE_FEE_Discovery;
    }
    public Decimal getCREDIT_CARD_SERVICE_FEE_American_Express(){
        return CREDIT_CARD_SERVICE_FEE_American_Express;
    }
    public void paymentTypeFunction(){
        system.debug('paymentTypeVar=>'+warpperObj.paymentTypeVar);
        if(warpperObj.paymentTypeVar=='check' && warpperObj.paymentScheduleVar=='Full'){
            //totalAmountDue = billing.AcctSeed__Balance__c;
            baseAmountToPay = totalAmountDue;
        }else if(warpperObj.paymentTypeVar=='check' && warpperObj.paymentScheduleVar=='Month'){
            totalServiceFee = CHECK_TRANSACTION_FEE;
            baseAmountToPay = perTotalMonthAmount;
            //totalAmountDue = perTotalMonthAmount+CHECK_TRANSACTION_FEE;
            //totalAmountDue = perTotalMonthAmount;
        }else if(warpperObj.paymentTypeVar=='check' && warpperObj.paymentScheduleVar=='Quarter'){
            totalServiceFee = CHECK_TRANSACTION_FEE;
            baseAmountToPay = perTotalQuarterAmount;
            //totalAmountDue = perTotalQuarterAmount+CHECK_TRANSACTION_FEE;
            //totalAmountDue = perTotalQuarterAmount;
        }else if(warpperObj.paymentTypeVar == 'Existing' && warpperObj.paymentScheduleVar=='Full'){
            //totalAmountDue = billing.AcctSeed__Balance__c;
            baseAmountToPay = totalAmountDue;
        }else if(warpperObj.paymentTypeVar == 'Existing' && warpperObj.paymentScheduleVar=='Month'){
            baseAmountToPay = perTotalMonthAmount;
            //totalAmountDue = perTotalMonthAmount;
        }else if(warpperObj.paymentTypeVar == 'Existing' && warpperObj.paymentScheduleVar=='Quarter'){
            baseAmountToPay = perTotalQuarterAmount;
            //totalAmountDue = perTotalQuarterAmount;
        }
        if(warpperObj.cardTypeVar!=null){
            cardTypeFunction();
        }
        //totalAmountDue = totalAmountDue;
        baseAmountToPay = totalAmountDue;
    }
    public void cardTypeFunction(){
        System.debug(creditCardfee);
        System.debug(warpperObj.cardTypeVar);
        /*if(warpperObj.cardTypeVar=='amex'){
            creditCardfee=CREDIT_CARD_SERVICE_FEE_American_Express;
        }else if(warpperObj.cardTypeVar=='disc'){
            creditCardfee=CREDIT_CARD_SERVICE_FEE_Discovery;
        }else if(warpperObj.cardTypeVar=='mast'){
            creditCardfee=CREDIT_CARD_SERVICE_FEE_MasterCard;
        }else if(warpperObj.cardTypeVar=='visa'){
            creditCardfee=CREDIT_CARD_SERVICE_FEE_VISA;
        }*/
        if(warpperObj.paymentTypeVar == 'creditCard'){
            creditCardfee = CREDIT_CARD_SERVICE_FEE_VISA;
        }
        System.debug(creditCardfee);
        if(warpperObj.paymentTypeVar=='creditCard' && warpperObj.paymentScheduleVar=='Full'){
            totalServiceFee = ((billing.AcctSeed__Balance__c * creditCardfee)/100);
            baseAmountToPay = billing.AcctSeed__Balance__c;
            //totalAmountDue = billing.AcctSeed__Balance__c + totalServiceFee;
            //totalAmountDue = billing.AcctSeed__Balance__c ;
        }else if(warpperObj.paymentTypeVar=='creditCard' && warpperObj.paymentScheduleVar=='Month'){
            totalServiceFee = ((billing.AcctSeed__Balance__c * creditCardfee)/100);
            creditCardServiceFee = (totalServiceFee/12);
            baseAmountToPay = perTotalMonthAmount;
            //totalAmountDue = perTotalMonthAmount+creditCardServiceFee; 
            //totalAmountDue = perTotalMonthAmount; 
        }else if(warpperObj.paymentTypeVar=='creditCard' && warpperObj.paymentScheduleVar=='Quarter'){
            totalServiceFee = ((billing.AcctSeed__Balance__c * creditCardfee)/100);
            creditCardServiceFee = (totalServiceFee/4);
            baseAmountToPay = perTotalQuarterAmount;
            //totalAmountDue = perTotalQuarterAmount+creditCardServiceFee; 
            //totalAmountDue = perTotalQuarterAmount; 
        }
    }
    public List<SelectOption> getExpireMonthsList(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('',''));
        options.add(new SelectOption('1','1-Jan'));
        options.add(new SelectOption('2','2-Feb'));
        options.add(new SelectOption('3','3-Mar'));
        options.add(new SelectOption('4','4-Apr'));
        options.add(new SelectOption('5','5-May '));
        options.add(new SelectOption('6','6-Jun'));
        options.add(new SelectOption('7','7-July'));
        options.add(new SelectOption('8','8-Aug'));
        options.add(new SelectOption('9','9-Sep'));
        options.add(new SelectOption('10','10-Oct '));
        options.add(new SelectOption('11','11-Nov'));
        options.add(new SelectOption('12','12-Dec'));
        return options;
        
    }
    public List<SelectOption> getExpireYearsList(){
        List<SelectOption> options = new List<SelectOption>();
        Integer currentYear = System.Today().year();
        options.add(new SelectOption('',''));
        for(Integer i =currentYear;i<(currentYear+15);i++){
            options.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
        return options;
    }
    public class PaymentGateway_Ctrl_Wrapper{
        public String policyInvoiceNumber{get;set;}
        public String firmId{get;set;}
        public String invoiceId{get;set;}
        public String firmName{get;set;}
        public String zipCode{get;set;}
        public String paymentScheduleVar{get;set;}
        public String paymentTypeVar{get;set;}
        public String cardTypeVar{get;set;}
        public String firstName{get;set;}
        public String lastName{get;set;}
        /* Card information */
        public String cardNumber{get;set;}
        public String verificationNumber{get;set;}
        public String expireMonth{get;set;}
        public String expireYear{get;set;}
        public String nameOnCard{get;set;}
        /* Account information */
        public String accountNumber{get;set;}
        public String routingNumber{get;set;}
        public String accountType{get;set;}
        public String accountHolderName{get;set;}
        
        public String confirmationEmail{get;set;}
        
        public String billingStreet{get;set;}
        public String billingCity{get;set;}
        public String billingState{get;set;}
        public String billingPostal{get;set;}
        public Date effectiveDate{get;set;}
        public Decimal balanceDue{get;set;}
        
        public String description{get;set;}
        public String nextPaymentDate{get;set;}
        
        public PaymentGateway_Ctrl_Wrapper(){
            this.policyInvoiceNumber = '';
            this.zipCode = '';
            this.paymentScheduleVar='';
            this.paymentTypeVar='';
            this.cardTypeVar='';
        }
    }
}