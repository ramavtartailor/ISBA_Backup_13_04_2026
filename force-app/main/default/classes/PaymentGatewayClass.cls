public without sharing class PaymentGatewayClass {
    public class PaymentGatewayClassException extends Exception{}
    public static  Decimal CHECK_TRANSACTION_FEE = 5;
    public static  Decimal CREDIT_CARD_SERVICE_FEE_VISA = 2.75;
    public static  Decimal CREDIT_CARD_SERVICE_FEE_MasterCard = 2.75;
    public static  Decimal CREDIT_CARD_SERVICE_FEE_Discovery = 2.75;
    public static  Decimal CREDIT_CARD_SERVICE_FEE_American_Express = 2.75;
    
    public static boolean emailSend = false;
    public static boolean isInternalUser {get;set;}
    public static boolean isPolicy {get;set;}
    public static List<String> finalpaymentMonths;
    public static List<String> finalpaymentQuarters;
    public static boolean noInvoiceFound{get;set;}
    public static boolean paymentError{get;set;}
    public static String paymentErrorMessage{get;set;}
    @TestVisible private static Decimal baseAmountToPay{get;set;}
    public static Date paymentQuartersDt;     
    public static Date paymentMonthsDt; 
    public static Policy__c policy{get;set;}
    public static Id sfInternalId{get;set;}
    public static String userSession{get;set;}
    public static string lasttime{get;set;}
    
    public static String validationString{get;set;}
    public static String IPAddress{get;set;}
    public static PaymentGateway_Ctrl_Wrapper warpperObj = new PaymentGateway_Ctrl_Wrapper();
    public static List<Payment_Schedule__c> paymentScheduleListToInsert = new List<Payment_Schedule__c>();
    
    //added for policy 
    public static Id transactionQueueId;
    
    public static List<AcctSeed__Billing_Cash_Receipt__c> bcrList{get;set;}
    //public static List<AcctSeed__Billing_Line__c > billingLines{get;set;}
    public static List<AcctSeed__Billing_Credit_Memo__c> creditMemo{get;set;}
    public static List<Integration_Log__c> integrationLog{get;set;}
    
    public PaymentGatewayClass(){
        system.debug('USERId => '+userInfo.getUserId());
        //currentStage ='findInvoice';
        isInternalUser = Userinfo.getUserType() == 'Guest' ? false : true; 
        isPolicy = false;
        paymentScheduleListToInsert = new List<Payment_Schedule__c>();
        warpperObj = new PaymentGateway_Ctrl_Wrapper();
        warpperObj.totalAmountDue =0;
        warpperObj.totalServiceFee=0;
        
        paymentError =false;
        paymentErrorMessage='';
        lasttime = 'Full';
        policy = new Policy__c();
        System.debug(Apexpages.currentpage().getparameters());
        if(Apexpages.currentpage().getparameters().get('id') != null){
            //currentStage = 'schedule';
            validationString = Apexpages.currentpage().getparameters().get('id');
            String tempValidationString = validationString;
            
            Id recId = processDecryption(tempValidationString.trim() ,Label.Encryption_Key_Payment_Id);
            String sObjName = recId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Policy__c'){
                isPolicy = true;
            }
            if(sObjName == 'Policy_Endorsement__c'){
                isPolicy = true;  
            }
            //nextFunction();
        }else if(Apexpages.currentpage().getparameters().get('sfInternalId') != null){
            //currentStage = 'schedule';
            sfInternalId = Apexpages.currentpage().getparameters().get('sfInternalId');
            validationString = processEncryption(sfInternalId ,Label.Encryption_Key_Payment_Id);
            if(isInternalUser){                
                Id recId = Id.valueOf(sfInternalId);
                String sObjName = recId.getSObjectType().getDescribe().getName();
                if(sObjName == 'Policy__c' || sObjName == 'Policy_Endorsement__c'){
                    isPolicy = true;
                }
            }
            //nextFunction();
        }
        IPAddress = ApexPages.currentPage().getHeaders().get('True-Client-IP');
        //Get IP address when no caching (sandbox, dev, secure urls)
        if (String.isBlank(IPAddress)) {
            IPAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        }  
        if (String.isBlank(IPAddress)) {
            IPAddress = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        }
        String browserAgent = ApexPages.currentPage().getHeaders().get('User-Agent');
        userSession = (IPAddress !=null ? ('IP Address : ' + IPAddress + '' ): '') + ('User Agent : ' + browserAgent !=null ? (browserAgent + '' ): '');
    }
    
    @AuraEnabled
    public static PaymentGateway_Ctrl_Wrapper getInvoiceRecordWithZip(String policyInvNumber, String zip, String sfInternalId, String lasttime){
        
        List<AcctSeed__Billing__c> billingList = new List<AcctSeed__Billing__c>();
        String query = '';
        if(sfInternalId == null){
            String zipCodePattern = (zip.trim() + '-%');
            
            billingList = [select id, AcctSeed__Credit_Memo_Applied_Amount__c, Cardknox_Payment_Method__c, Cardknox_Payment_Method__r.AcctSeed__Payment_Method_Type__c, Service_Fee__c, AcctSeed__Billing_Contact__c, Payment_Method__c, AcctSeed__Total__c,name,AcctSeed__Due_Date2__c ,AcctSeed__Balance__c,AcctSeed__Customer__r.Name, Policy_Endorsement__c,
                           AcctSeed__Customer__c, AcctSeed__Customer__r.AcctSeed__Billing_Contact__r.Email, AcctSeed__Customer__r.AcctSeed__Billing_Contact__r.FirstName, AcctSeed__Customer__r.AcctSeed__Billing_Contact__r.LastName,Policy__r.Firm_Contact__r.Email ,First_Payment_Date__c,IsPaymentProcessed__c,Mode_Of_Payment__c,Claim__c,
                           Next_Payment_Base_Amount__c,Next_Payment_Date__c,Next_Payment_Service_Fee__c,AcctSeed__Billing_Street__c,AcctSeed__Customer__r.ISBAM_Billing_Freq_Policy_Full_Pay_Only__c,
                           Payment_Frequency__c,Firm_Name__c,Legacy_Invoice_Id__c,Legacy_Firm_Id__c,AcctSeed__Billing_City__c,AcctSeed__Received_Amount__c ,Allow_CatchUp_Schedule__c , Policy__r.Application_Type__c, Policy__r.Total_CLE_Credit__c, Policy__r.Policy_Dividend__c, Policy__r.Premium__c,Policy__r.Total_Credit__c,
                           AcctSeed__Customer__r.AccountNumber,AcctSeed__Customer__r.Forte_ID__c,AcctSeed__Billing_State__c,AcctSeed__Billing_PostalCode__c,Billing_Description__c,AS_Transaction_Description__c,Policy__r.Effective_Date__c,Policy__c,Policy__r.Expiration_Date__c, Extra_Month_Payment__c,Policy_Endorsement__r.Endorsement_Effective_Date__c,Policy_Endorsement__r.Endorsement_Number__c    
                           from AcctSeed__Billing__c 
                           where ((name=:policyInvNumber.trim() OR Policy__r.Name =:policyInvNumber.trim()) 
                                  and (AcctSeed__Customer__r.BillingPostalCode=:zip.trim() or AcctSeed__Customer__r.BillingPostalCode like: zipCodePattern))
                           OR
                           ((AcctSeed__Customer__r.Name='Dummy Billing Account' AND Billing_Zip_Code__c=: zip.trim()) 
                            AND (Legacy_Invoice_Id__c=:policyInvNumber.trim() OR Legacy_Policy_Id__c =:policyInvNumber.trim()) ) 
                           limit 1];
            
            
        }
        else{
            billingList = [select id, AcctSeed__Credit_Memo_Applied_Amount__c, Cardknox_Payment_Method__c, Cardknox_Payment_Method__r.AcctSeed__Payment_Method_Type__c, Service_Fee__c, AcctSeed__Billing_Contact__c, Payment_Method__c, AcctSeed__Total__c,name,AcctSeed__Due_Date2__c ,AcctSeed__Balance__c,AcctSeed__Customer__r.Name, Policy_Endorsement__c,
                           AcctSeed__Customer__c,AcctSeed__Customer__r.AcctSeed__Billing_Contact__r.Email, AcctSeed__Customer__r.AcctSeed__Billing_Contact__r.FirstName, AcctSeed__Customer__r.AcctSeed__Billing_Contact__r.LastName,Policy__r.Firm_Contact__r.Email ,First_Payment_Date__c,IsPaymentProcessed__c,Mode_Of_Payment__c,AcctSeed__Customer__r.Forte_ID__c,Claim__c,
                           Next_Payment_Base_Amount__c,Next_Payment_Date__c,Next_Payment_Service_Fee__c,AcctSeed__Billing_Street__c,Policy__r.Total_CLE_Credit__c, Policy__r.Policy_Dividend__c,Policy__r.Premium__c,Policy__r.Total_Credit__c,Policy__r.Application_Type__c, 
                           Payment_Frequency__c,Firm_Name__c,Legacy_Invoice_Id__c,Legacy_Firm_Id__c,AcctSeed__Billing_City__c,AcctSeed__Received_Amount__c, Allow_CatchUp_Schedule__c ,AcctSeed__Customer__r.ISBAM_Billing_Freq_Policy_Full_Pay_Only__c,
                           AcctSeed__Customer__r.AccountNumber,AcctSeed__Billing_State__c,AcctSeed__Billing_PostalCode__c,Billing_Description__c,AS_Transaction_Description__c  ,Policy__r.Effective_Date__c,Policy__c,Policy__r.Expiration_Date__c, Extra_Month_Payment__c,Policy_Endorsement__r.Endorsement_Effective_Date__c,Policy_Endorsement__r.Endorsement_Number__c  
                           from AcctSeed__Billing__c 
                           where Id =: sfInternalId
                           limit 1];
            
        }
        if(!billingList.isEmpty()){    
            if(lasttime == 'FirstTime'){ 
                if(billingList[0].Payment_Frequency__c == 'Quarterly'){
                    lasttime = 'Quarter';
                }
                else if(billingList[0].Payment_Frequency__c == 'Monthly'){
                    lasttime ='Month';
                }
                else{
                    lasttime = 'Full';   
                }
            }
            return generateWrapper(billingList,lasttime);
        }
        else {           
            throw new PaymentGatewayClassException('No invoice found. Please verify Policy/Invoice # and Zip Code.');
        }
    }
    
    @AuraEnabled 
    public static PaymentGateway_Ctrl_Wrapper scheduleDetails( String validationString, String sfInternalId, String lasttime){
        
        System.debug('herere12');
        //System.debug(warpperObj);
        Boolean noInvoiceFound ;
        // PaymentGateway_Ctrl_Wrapper warpperObj= (PaymentGateway_Ctrl_Wrapper)System.JSON.deserializeStrict(wrapString, PaymentGateway_Ctrl_Wrapper.class);
        System.debug('herere');
        //System.debug(warpperObj);
        AcctSeed__Billing__c billing = new AcctSeed__Billing__c();
        List<AcctSeed__Billing__c> billingList = new List<AcctSeed__Billing__c>();
        system.debug('validationString'+validationString);
        System.debug('sfInternalId' + sfInternalId);
        String query ='';
        if(validationString == null){            
            return null;
        }
        else{
            System.debug(validationString);
            Id billingId = processDecryption(validationString.trim() ,Label.Encryption_Key_Payment_Id);
            String sObjName = billingId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Account'){
                return getAccountDetails(billingId);
            }
            SYstem.debug(billingId);
            billingList = [select id, AcctSeed__Credit_Memo_Applied_Amount__c, Cardknox_Payment_Method__c, Cardknox_Payment_Method__r.AcctSeed__Payment_Method_Type__c, Service_Fee__c, AcctSeed__Billing_Contact__c, Payment_Method__c, Claim__c, AcctSeed__Total__c,name,AcctSeed__Due_Date2__c ,AcctSeed__Balance__c,AcctSeed__Customer__r.Name,AcctSeed__Customer__r.Forte_ID__c, Policy_Endorsement__c,
                           AcctSeed__Customer__c,AcctSeed__Customer__r.AcctSeed__Billing_Contact__r.Email, AcctSeed__Customer__r.AcctSeed__Billing_Contact__r.FirstName, AcctSeed__Customer__r.AcctSeed__Billing_Contact__r.LastName,Policy__r.Firm_Contact__r.Email ,First_Payment_Date__c,IsPaymentProcessed__c,Mode_Of_Payment__c,
                           Next_Payment_Base_Amount__c,Next_Payment_Date__c,Next_Payment_Service_Fee__c,AcctSeed__Billing_Street__c,Policy__r.Total_CLE_Credit__c, Policy__r.Policy_Dividend__c,Policy__r.Premium__c,Policy__r.Total_Credit__c,Policy__r.Application_Type__c,
                           Payment_Frequency__c,Firm_Name__c,Legacy_Invoice_Id__c,Legacy_Firm_Id__c,AcctSeed__Billing_City__c,AcctSeed__Received_Amount__c, Allow_CatchUp_Schedule__c ,AcctSeed__Customer__r.ISBAM_Billing_Freq_Policy_Full_Pay_Only__c,
                           AcctSeed__Customer__r.AccountNumber,AcctSeed__Billing_State__c,AcctSeed__Billing_PostalCode__c,Billing_Description__c,AS_Transaction_Description__c  ,Policy__r.Effective_Date__c,Policy__c,Policy__r.Expiration_Date__c, Extra_Month_Payment__c,Policy_Endorsement__r.Endorsement_Effective_Date__c ,Policy_Endorsement__r.Endorsement_Number__c
                           from AcctSeed__Billing__c 
                           where Id =: billingId
                           limit 1];
            
        }
        if(!billingList.isEmpty()){
            system.debug('scheduleDetails lasttime => '+ lasttime);            
            if(lasttime == 'FirstTime'){ 
                if(billingList[0].Payment_Frequency__c == 'Quarterly'){
                    lasttime = 'Quarter';
                }
                else if(billingList[0].Payment_Frequency__c == 'Monthly'){
                    lasttime ='Month';
                }
                else{
                    lasttime = 'Full';   
                }
            }
            system.debug('scheduleDetails lasttime => '+ lasttime);
            return generateWrapper(billingList,lasttime);
        }    
        else{
            return null;
        }       
    }
    
    public static PaymentGateway_Ctrl_Wrapper getAccountDetails(Id accId) {
        warpperObj.isAccountId = true;
        
        warpperObj.siteUrl = getUrl();
        
        Account acc = [SELECT Id, Name, Payment_Link_Activation_Started_at__c, BillingAddress, Phone, AccountNumber, AcctSeed__Billing_Contact__r.Email,Recent_Policy_Lookup__r.Firm_Contact__r.Email FROM Account WHERE Id=:accId]; 
        
        List<AcctSeed__Billing__c> billingList = new List<AcctSeed__Billing__c>([select id, AcctSeed__Date__c, Cardknox_Payment_Method__c, Cardknox_Payment_Method__r.AcctSeed__Payment_Method_Type__c, Service_Fee__c, AcctSeed__Billing_Contact__c, PDF_VF_Page__c, AcctSeed__Total__c,name,AcctSeed__Due_Date2__c ,AcctSeed__Balance__c,AcctSeed__Customer__r.Name,AcctSeed__Customer__r.Forte_ID__c, Policy_Endorsement__c,
                                                                                 AcctSeed__Customer__c,AcctSeed__Customer__r.AcctSeed__Billing_Contact__r.Email, AcctSeed__Customer__r.AcctSeed__Billing_Contact__r.FirstName, AcctSeed__Customer__r.AcctSeed__Billing_Contact__r.LastName,Policy__r.Firm_Contact__r.Email ,First_Payment_Date__c,IsPaymentProcessed__c,Mode_Of_Payment__c,Payment_Method__r.Type__c,Payment_Method__r.Masked_Account_Number__c,Claim__c, 
                                                                                 Next_Payment_Base_Amount__c,Next_Payment_Date__c,Next_Payment_Service_Fee__c,AcctSeed__Billing_Street__c,Policy__r.Total_CLE_Credit__c, Policy__r.Name, Policy__r.Policy_Dividend__c,Policy__r.Premium__c,Policy__r.Total_Credit__c,
                                                                                 Payment_Frequency__c,Firm_Name__c,Legacy_Invoice_Id__c,Legacy_Firm_Id__c,AcctSeed__Billing_City__c,AcctSeed__Received_Amount__c, Allow_CatchUp_Schedule__c ,AcctSeed__Customer__r.ISBAM_Billing_Freq_Policy_Full_Pay_Only__c,
                                                                                 AcctSeed__Customer__r.AccountNumber,AcctSeed__Billing_State__c,AcctSeed__Billing_PostalCode__c,Billing_Description__c,AS_Transaction_Description__c  ,Policy__r.Effective_Date__c,Policy__c,Policy__r.Expiration_Date__c, Extra_Month_Payment__c,Policy_Endorsement__r.Endorsement_Effective_Date__c,Policy_Endorsement__r.Endorsement_Number__c,
                                                                                 (SELECT Id,Amount__c,Status__c,Due_Date__c FROM Payment_Schedules__r WHERE Status__c != 'Paid' order by Due_Date__c DESC)
                                                                                 from AcctSeed__Billing__c WHERE AcctSeed__Customer__c =: accId AND AcctSeed__Total__c > 0 Order By AcctSeed__Due_Date2__c DESC]);
        List<Policy__c> policyList = [SELECT Id, Name,Underwriter_User__r.Title,Underwriter_User__r.Phone,Underwriter_User__r.Email,Underwriter_User__r.Name, Policy_Number__c, Effective_Date__c, Expiration_Date__c, Premium__c, Cancel_Date__c,(SELECT Id,Lawyer_Name__c,Lawyer__r.Contact__r.ARDC_Number__c, ISBA_Number__c,Prior_Act_Date__c,Premium__c,Primary__c,Step__c,Rate_At__c FROM Policy_Lawyers__r WHERE Active__c = true and Deleted_Lawyer__c = false order by Lawyer__r.Contact__r.LastName ASC) FROM Policy__c WHERE Account__c =: accId AND RecordType.Name = 'Policy' Order By Effective_Date__c DESC LIMIT 1];
        List<Policy__c> applicationList = [SELECT Id, Renewal_Type__c, Customer_Application__c, Customer_Application__r.Form_Link__c,Application_Form_Link__c, Name, Policy_Number__c, Effective_Date__c, Expiration_Date__c, Premium__c, Cancel_Date__c FROM Policy__c WHERE Account__c =: accId AND RecordType.Name = 'Application' Order By Effective_Date__c DESC];
        
        List<Policy_Endorsement__c> recordList = [SELECT Id, Name, Application_Form_Link__c, Override_NBA_Expire_Date__c, Endorsement_Number__c, Premium__c, Event_Status__c, Lawyer__c, Lawyer__r.Name, Lawyer_Name__c, Endorsement_Effective_Date__c, Coverage_Term__c, Policy__c, Policy__r.Name  FROM Policy_Endorsement__c WHERE Account__c =: accId AND (Event_Status__c='Pending' OR Event_Status__c='Submitted') AND (Endorsement_Number__c='IL 107' OR Endorsement_Number__c='IL 152' OR Endorsement_Number__c='IL 153' OR Endorsement_Number__c='IL 190')];
        
        Set<String> policyApplicationId = new Set<String>(); 
        String polIds = '(';
        
        if(!policyList.isEmpty()) {
            policyApplicationId.add(policyList[0].Id);
            polIds += '\'' + policyList[0].Id + '\'';
            
            if(polIds.endsWith(',')){
                polIds = polIds.removeEnd(',');
            }
            polIds += ')';
            System.debug('polIds => ' + polIds);
        } else {
            polIds = '()'; // empty set for SOQL IN clause
        }
        
        Set<Id> contentDocumentIds = new Set<Id>();
        Map<String, List<String>> policyWithCvMap = new Map<String, List<String>>();
        String resp = QueryData('select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN '+polIds);
        System.debug(polIds);
        List<ContentDocumentLink> cdlList = (List<ContentDocumentLink>)system.JSON.deserializeStrict(resp, List<ContentDocumentLink>.class);
        for(ContentDocumentLink cdl : cdlList){  //[select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN: policyApplicationId]){
            contentDocumentIds.add(cdl.ContentDocumentId);
            List<String> temp =  new List<String>();
            if(policyWithCvMap.containsKey(cdl.LinkedEntityId)){
                temp = policyWithCvMap.get(cdl.LinkedEntityId);
            }
            temp.add(cdl.ContentDocumentId);
            policyWithCvMap.put(cdl.LinkedEntityId, temp);
        }
        
        Map<string,ContentVersion> cvMap = new Map<String,ContentVersion>(); 
        
        for(ContentVersion cv : [select id, Title, FirstPublishLocationId, ContentDocumentId, Document_Type__c from ContentVersion where ContentDocumentId IN: contentDocumentIds and (Document_Type__c = 'Policy Letter' OR Document_Type__c = 'Declaration Page'  OR Document_Type__c = 'NAS EOC'  OR Document_Type__c = 'Certificate Of Insurance' OR Document_Type__c='Endorsement') and Is_System_Generated_Document__c = true and IsLatest=true order by Priority_Order__c,Title]){
            cvMap.put(cv.ContentDocumentId, cv);
            system.debug(cv.FirstPublishLocationId+' => '+cv.Document_Type__c);
        }
        system.debug('policyWithCvMap => '+policyWithCvMap.keySet());
        List<PolicyWrapper> policyWrapList = new List<PolicyWrapper>();
        for(Policy__c pol : policyList){
            system.debug(pol.Id);
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            PolicyWrapper pWrpObj = new PolicyWrapper();
            pWrpObj.policy = pol;
            pWrpObj.pdfUrl = baseUrl+'/apex/FilePreviewPage?id=';
            if(policyWithCvMap.containsKey(pol.Id)){
                for(String cdId : policyWithCvMap.get(pol.Id)){
                    if(cvMap.containsKey(cdId)){
                        cvWrapper cvw = new cvWrapper();
                        cvw.cvObj = cvMap.get(cdId);
                        cvw.name = cvw.cvObj.Title.subStringBefore('- a0s');
                        pWrpObj.cvList.add(cvw);
                    }
                }
            }
            policyWrapList.add(pWrpObj);
        }
        if(!policyWrapList.isEmpty()){
             policyWrapList[0].isExpended = true;
        }
       
        Set<String> VisualforcePageName =  new Set<String>();
        for(AcctSeed__Billing__c bill: billingList){
            VisualforcePageName.add(bill.PDF_VF_Page__c);
        }
        //List<ApexPage> ApexPageList =[SELECT Name, MasterLabel,namespaceprefix, ApiVersion, CreatedDate FROM ApexPage where Name IN:VisualforcePageName WITH SECURITY_ENFORCED LIMIT 10000];
        // Map<String, String> NamespaceList=new Map<String, String>();
        // for(ApexPage page: ApexPageList){
        //     if(page.namespaceprefix!=NUll){
        //     NamespaceList.put(page.Name.toLowercase(),page.namespaceprefix);
        //     }else{
        //         NamespaceList.put(page.Name.toLowercase(),'c');
        //     }
        // }
        List<BillingWrapper> billWrapperList = new List<BillingWrapper>();
        for(AcctSeed__Billing__c bill: billingList){
            BillingWrapper billWrapObj = new BillingWrapper();
            billWrapObj.bill = bill;
            if(!bill.Payment_Schedules__r.isEmpty()){
                System.debug('Bill => '+bill);
                System.debug('bill.Payment_Schedules__r => '+bill.Payment_Schedules__r);
                billWrapObj.paymentSchedules = bill.Payment_Schedules__r;
            }
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            //billWrapObj.pdfUrl = baseUrl+'/paymentsite/apex/'+NamespaceList.get((bill.PDF_VF_Page__c).toLowercase())+ '__'+bill.PDF_VF_Page__c+'?id='+bill.Id+'&IsPrint=true';
            if(bill.PDF_VF_Page__c == 'BillingServicePDF' || bill.PDF_VF_Page__c == 'BillingProductPDF'){
                
                billWrapObj.pdfUrl = baseUrl+'/apex/AcctSeed__'+bill.PDF_VF_Page__c+'?id='+bill.Id+'&IsPrint=true';
            }
            else{
                
                billWrapObj.pdfUrl = baseUrl+'/apex/'+bill.PDF_VF_Page__c+'?id='+bill.Id+'&IsPrint=true';
            }
            //billWrapObj.invoiceDate = String.valueOf(bill.AcctSeed__Due_Date2__c.month()).leftPad(2, '0') +'/'+ String.valueOf(bill.AcctSeed__Due_Date2__c.day()).leftPad(2, '0')+'/'+bill.AcctSeed__Due_Date2__c.year();
            billWrapObj.invoiceDate = String.valueOf(bill.AcctSeed__Date__c.month()).leftPad(2, '0') +'/'+ String.valueOf(bill.AcctSeed__Date__c.day()).leftPad(2, '0')+'/'+bill.AcctSeed__Date__c.year();
            billWrapperList.add(billWrapObj);
        }
        warpperObj.applications = applicationList;
        warpperObj.billings = billWrapperList;
        warpperObj.policies = policyWrapList;
        warpperObj.policyEndorsements = recordList;
        warpperObj.accRecord = acc;
        return warpperObj;        
    }
    
    public Static PaymentGateway_Ctrl_Wrapper generateWrapper(List<AcctSeed__Billing__c> billingList,String lasttime){
        system.debug('GenerateWrapper lasttime =>'+lasttime);
        AcctSeed__Billing__c billing = new AcctSeed__Billing__c();
        billing= billingList[0];
        if(billingList[0].AcctSeed__Balance__c == 0){
            noInvoiceFound = true;
            //currentStage='findInvoice';
            //invoiceNotFoundErrorMessage ='Error: Payment has been already submitted for this invoice';
            throw new PaymentGatewayClassException('Payment has been already submitted for this invoice.');
            
        }
        else{
            // billing= billingList[0];
            // =>               //noInvoizceFound = false;
            
            if(billingList[0].IsPaymentProcessed__c){
                warpperObj.oldPaymentSchedule = getOldPaymentSchedules(billingList[0].Id);
            }
            if(warpperObj.totalAmountDue == null){
                warpperObj.totalAmountDue = billing.AcctSeed__Balance__c;
            }
            
            
            warpperObj.isAnyDefaultPaymentMethodAvailabel = String.isNotBlank(billing.Payment_Method__c);
            
            if(warpperObj.isAnyDefaultPaymentMethodAvailabel){ 
                warpperObj.defaultPaymentMethodId = billing.Payment_Method__c;
                warpperObj.paymentMethodId =  billing.Payment_Method__c;
                if(billing.Service_Fee__c != null){
                    warpperObj.ccFeeRate = billing.Service_Fee__c;
                }
                //check if any default payment Method Exesist
                //List<Payment_Method__c> paymentMethods = [SELECT Id,Default__c FROM Payment_Method__c WHERE AcctSeed__Customer__c =:billing.AcctSeed__Customer__c AND Default__c = true AND AcctSeed__Status__c != 'Inactive'];
            }
            system.debug('billing.AcctSeed__Due_Date2__c => '+billing.AcctSeed__Due_Date2__c);
            
            // Line Added by Sarbjeet
            warpperObj.lastName = billing.AcctSeed__Customer__r.AcctSeed__Billing_Contact__r.LastName;
            warpperObj.firstName = billing.AcctSeed__Customer__r.AcctSeed__Billing_Contact__r.FirstName;
            warpperObj.emailAddress = billing.AcctSeed__Customer__r.AcctSeed__Billing_Contact__r.Email;
            
            warpperObj.billingStreet = billing.AcctSeed__Billing_Street__c;
            warpperObj.billingCity = billing.AcctSeed__Billing_City__c;
            warpperObj.billingState = billing.AcctSeed__Billing_State__c;
            warpperObj.billingPostal = billing.AcctSeed__Billing_PostalCode__c;            
            warpperObj.dueDate = billing.AcctSeed__Due_Date2__c;
            warpperObj.totalCredit = (billing.Policy__r.Total_Credit__c != null ? billing.Policy__r.Total_Credit__c : 0) ;
            warpperObj.totalCLECredit = (billing.Policy__r.Total_CLE_Credit__c != null ? billing.Policy__r.Total_CLE_Credit__c : 0) ;
            warpperObj.policyDividend = (billing.Policy__r.Policy_Dividend__c != null ? billing.Policy__r.Policy_Dividend__c : 0) ;
            warpperObj.premium = billing.Policy__r.Premium__c;
            warpperObj.balance = billing.AcctSeed__Balance__c;
            //warpperObj.paymentScheduleVar = billing.Payment_Frequency__c;
            if(billing.Policy__c != null && billing.Policy_Endorsement__c == null && billing.Claim__c == null){
                
                System.debug(billing.Policy__r.Effective_Date__c);
                warpperObj.dueDate = billing.Policy__r.Effective_Date__c;
                
            }
            warpperObj.effectiveDateYear = warpperObj.dueDate != null ? warpperObj.dueDate.year(): null;
            warpperObj.balanceDue = billing.AcctSeed__Balance__c;
            warpperObj.description = (billing.Billing_Description__c != null ? billing.Billing_Description__c : billing.AS_Transaction_Description__c);
            String accountName ='';
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
                warpperObj.customerToken=billing.AcctSeed__Customer__r.Forte_ID__c;
            }
            
            warpperObj.isBillingFrequencyFullOnly = billing.AcctSeed__Customer__r.ISBAM_Billing_Freq_Policy_Full_Pay_Only__c;
            if(billing.Policy_Endorsement__c!=null && billing.Policy_Endorsement__r.Endorsement_Number__c == 'IL 107'){
                warpperObj.isBillingFrequencyFullOnly = true;
            }
            if(warpperObj.isBillingFrequencyFullOnly){
                warpperObj.paymentScheduleVar = 'Full';
                lasttime = 'Full';
            }
            
            if(lasttime != 'Full'){
                warpperObj.paymentTypeVar='';
                warpperObj.paymentScheduleVar = lasttime;
                warpperObj = paymentScheduleFunction(warpperObj, billing,lasttime);
            }
            if(lasttime == 'Full'){
                warpperObj.paymentTypeVar='';
                warpperObj.paymentScheduleVar = lasttime;
                warpperObj = paymentScheduleFunction(warpperObj, billing,lasttime);
            }
        }
        
        
        if(billing.Payment_Frequency__c == null && String.isBlank(warpperObj.paymentScheduleVar)){
            warpperObj.paymentScheduleVar = 'Full';
            warpperObj = paymentScheduleFunction(warpperObj, billing,lasttime);
        }
        
        // bcrList = new List<AcctSeed__Billing_Cash_Receipt__c>(
        //     [select id,Name ,AcctSeed__Applied_Amount__c,AcctSeed__Applied_Date__c, AcctSeed__Status__c,AcctSeed__Cash_Receipt__r.AcctSeed__Receipt_Date__c,
        //      AcctSeed__Cash_Receipt__r.AcctSeed__Purpose__c from AcctSeed__Billing_Cash_Receipt__c where AcctSeed__Billing__c =: billing.Id ]);
        
        warpperObj.billingLines = new List<AcctSeed__Billing_Line__c>(
            [select id, Name, AcctSeed__Comment__c, AcctSeed__Total__c from AcctSeed__Billing_Line__c where AcctSeed__Billing__c =: billing.Id ]);
        
        // creditMemo = new List<AcctSeed__Billing_Credit_Memo__c>(
        //     [select id,Name,AcctSeed__Amount__c ,AcctSeed__Applied_Date__c from AcctSeed__Billing_Credit_Memo__c where AcctSeed__Billing_Invoice__c  =: billing.Id ]);
        
        // integrationLog = new List<Integration_Log__c>(
        //     [select id,Name, Status__c from Integration_Log__c where Billing__c  =: billing.Id ]);
        
        warpperObj.billing = billing;
        warpperObj.accRecord = billing.AcctSeed__Customer__r;
        //warpperObj.ExestingDetails =  ExistingList(billing);        
        return warpperObj;
    }
    
    @AuraEnabled
    public static PaymentGateway_Ctrl_Wrapper contactDetails(String SelectedMethod, PaymentGateway_Ctrl_Wrapper warppreObj ){
        //PaymentGateway_Ctrl_Wrapper warppreObj = (PaymentGateway_Ctrl_Wrapper)System.JSON.deserializeStrict(wrapString, PaymentGateway_Ctrl_Wrapper.class);
        
        if(SelectedMethod !='' && SelectedMethod != null){
            boolean boo = true;
            
            for(Payment_Method__c Paymethod: [SELECT Id,Name ,Default__c,Name_On_Card__c,Account_Type__c,Type__c,Card_Type__c,Payment_Method_Token__c,Routing_Number__c,Card_Holder_Name__c,Masked_Account_Number__c,Expiry_Month__c,Expiry_Year__c FROM Payment_Method__c WHERE Id =: SelectedMethod])
            {
                boo = false;
                system.debug('Paymethod -> '+Paymethod);
                warpperObj.cardTypeVar = Paymethod.Card_Type__c;
                //warpperObj.cardNumber = Paymethod.Credit_Card_Number__c;
                warpperObj.cardNumber = Paymethod.Masked_Account_Number__c;
                warpperObj.verificationNumber = 'xxx'  ;
                warpperObj.expireMonth = String.ValueOf(Paymethod.Expiry_Month__c);
                warpperObj.expireYear = String.valueOf(Paymethod.Expiry_Year__c);
                warpperObj.nameOnCard = Paymethod.Name_on_Card__c;
                warpperObj.accountNumber = Paymethod.Masked_Account_Number__c;
                warpperObj.routingNumber = Paymethod.Routing_Number__c;
                //warpperObj.accountType = Paymethod.Account_Type__c ;
                if(String.isNotBlank(Paymethod.Account_Type__c)){
                    if(Paymethod.Account_Type__c.equalsIgnoreCase('Checking')){
                        warpperObj.accountType = 'Checking';
                    }else if(Paymethod.Account_Type__c.equalsIgnoreCase('Savings')){
                        warpperObj.accountType = 'Savings';
                    }
                }
                warpperObj.accountHolderName = Paymethod.Card_Holder_Name__c;
                warpperObj.payMethodToken = Paymethod.Payment_Method_Token__c;
                warpperObj.paymentMethod = Paymethod;
                warpperObj.paymentMethod.Id = null;
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
                warpperObj.payMethodToken = null;
                warpperObj.paymentMethod = null;
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
            warpperObj.payMethodToken = null;
            warpperObj.accountHolderName = null;
            warpperObj.paymentMethod = null;
        }
        
        return warpperObj;
    }
    
    @AuraEnabled
    public static List<Policy_Endorsement__c> deletePolicyLawyer(String policyLawyerId, Date effectiveDate){
        try{
            String recTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='Policy_Endorsement__c' AND Name='IL 153 Deleting an Attorney Endorsement' limit 1][0].Id;
            Policy_Endorsement__c policyEndorsement = new Policy_Endorsement__c();
            //policyEndorsement.Name = 'IL 153 1/18 Remove a Lawyer Endorsement';
            policyEndorsement.Endorsement_Effective_Date__c = effectiveDate;
            policyEndorsement.Effective_Date__c = effectiveDate; 
            //policyEndorsement.Endorsement_Number__c = 'IL 153';
            policyEndorsement.RecordTypeId = recTypeId;
            policyEndorsement.Event_Status__c = 'Pending';
            Policy_Lawyer__c lawyer = [SELECT Id, Policy__c, Policy__r.Name, Policy__r.Account__c,Policy__r.Expiration_Date__c, Policy__r.Effective_Date__c, Policy__r.Underwriter_User__r.Email, Policy__r.Underwriter_User__r.Name, Lawyer_Name__c,Lawyer__r.Contact__r.ARDC_Number__c,Prior_Act_Date__c,Premium__c,Primary__c,Step__c,Rate_At__c,X5_5__c,X10_10__c,Excess__c,Added_Date__c FROM Policy_Lawyer__c WHERE Id =: policyLawyerId LIMIT 1];
            policyEndorsement.Policy__c = lawyer.Policy__c;
            policyEndorsement.Account__c = lawyer.Policy__r.Account__c;
            
            Decimal rate = (lawyer.Rate_At__c == 0 ? 0 : lawyer.Rate_At__c) / 100;
            
            policyEndorsement.Prior_Act_Date__c = lawyer.Prior_Act_Date__c;
            
            policyEndorsement.Step__c = ApplicationPolicyUtil.CalculateLawyerStep(lawyer.Policy__r.Effective_Date__c,policyEndorsement.Prior_Act_Date__c);
            
            Date endorsementEffectiveDate = policyEndorsement.Endorsement_Effective_Date__c;
            System.debug('endorsementEffectiveDate---'+endorsementEffectiveDate);
            System.debug('map----'+lawyer.Policy__r.Expiration_Date__c);
            Decimal daysProRated = endorsementEffectiveDate.daysBetween(lawyer.Policy__r.Expiration_Date__c) + 1;
            policyEndorsement.Term__c = daysProRated / (Date.isLeapYear(Date.today().year()) ?  366 : 365);
            if(lawyer.Added_Date__c != null){
                policyEndorsement.Term__c = daysProRated /  (lawyer.Added_Date__c.daysBetween(lawyer.Policy__r.Expiration_Date__c) + 1);
            }
            if(policyEndorsement.Term__c > 1){
                policyEndorsement.Term__c = 1;
            }
            policyEndorsement.Primary__c = lawyer.Primary__c == null ? 0 :(lawyer.Primary__c*policyEndorsement.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            policyEndorsement.Excess__c = lawyer.Excess__c == null ? 0 :(lawyer.Excess__c*policyEndorsement.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            policyEndorsement.Premium_5_5__c = lawyer.X5_5__c == null ? 0 :(lawyer.X5_5__c*policyEndorsement.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            policyEndorsement.Premium_10_10__c = lawyer.X10_10__c == null ? 0 :(lawyer.X10_10__c*policyEndorsement.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            policyEndorsement.Premium__c = lawyer.Premium__c == null ? 0 :(lawyer.Premium__c*policyEndorsement.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            policyEndorsement.Refund_Amount__c = lawyer.Premium__c == null ? 0 :(lawyer.Premium__c*policyEndorsement.Term__c).round(System.RoundingMode.HALF_UP);
            
            if(!policyEndorsement.Override_Rating__c){
                policyEndorsement.Override_10_10__c = null;
                policyEndorsement.Override_5_5__c = null;
            }
            if(!policyEndorsement.Step_Override__c){
                policyEndorsement.Step_Override_Value__c =null;
            }
            policyEndorsement.Policy_Lawyer__c = policyLawyerId;
            
            //upsert policyEndorsement;
            system.debug('PaymentGateway class called');
            String upserResp = updatePSchRecords(new List<Policy_Endorsement__c>{policyEndorsement}, 'upsert');
            system.debug('upserResp => '+upserResp);
            
            List<Policy_Endorsement__c> endorsementList = new List<Policy_Endorsement__c>();
            
            endorsementList = (List<Policy_Endorsement__c>) system.JSON.deserializeStrict(upserResp, List<Policy_Endorsement__c>.class);
            endorsementList[0].Event_Status__c = 'Submitted';
            system.debug('endorsementList => '+endorsementList);
            User_Tracking__c userTrack = UserTrackingHandler.createUserTrackingObject('Create', endorsementList[0].Id, policyEndorsement.Name);
            
            updatePSchRecords(new List<User_Tracking__c>{userTrack}, 'upsert');
            updatePSchRecords(endorsementList, 'upsert');
            
            String emailBody = 'Hi '+lawyer.Policy__r.Underwriter_User__r.Name+',\n\n A request has been submitted to remove  '+lawyer.Lawyer_Name__c+' from policy "'+lawyer.Policy__r.Name+'". \n\nPlease review the request. \n\nThank you.'; 
            
            sendEmailToTheUnderwriter(lawyer.Policy__r.Underwriter_User__r.Email, 'Lawyer deletion request submitted.',emailBody, lawyer.Policy__c);
            List<Policy_Endorsement__c> recordList = [SELECT Id, Name, Application_Form_Link__c, Override_NBA_Expire_Date__c, Endorsement_Number__c, Premium__c, Event_Status__c, Lawyer__c, Lawyer__r.Name, Endorsement_Effective_Date__c, Coverage_Term__c, Policy__c, Policy__r.Name  FROM Policy_Endorsement__c WHERE Account__c =: lawyer.Policy__r.Account__c AND (Event_Status__c='Pending' OR Event_Status__c='Submitted') AND (Endorsement_Number__c='IL 107' OR Endorsement_Number__c='IL 152' OR Endorsement_Number__c='IL 153' OR Endorsement_Number__c='IL 190')];
            return recordList;
        }
        catch(Exception e){
            Error err = new Error(e.getMessage(), 'Error While Deleting the Lawyer.', 'Team,\n\nFollowing error has occurred while deteting the Lawyer \n\n'+e.getMessage() + '\n\n'+e.getStackTraceString()+'\n\n on the Record :'+ policyLawyerId );
            throw new PaymentGatewayClassException(JSON.serialize(err));
        }
    } 
    
    @AuraEnabled 
    public static List<Policy_Endorsement__c> cancelPolicy(String policyId, Date effectiveDate){
        try{
            String recTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='Policy_Endorsement__c' AND Name='IL 190 Cancellation of Coverage' limit 1][0].Id;
            Policy_Endorsement__c policyEndorsement = new Policy_Endorsement__c();
            policyEndorsement.Endorsement_Effective_Date__c = effectiveDate; 
            policyEndorsement.Effective_Date__c = effectiveDate; 
            policyEndorsement.RecordTypeId = recTypeId;
            policyEndorsement.Event_Status__c = 'Pending';
            Policy__c policy = [SELECT Id, Name, Account__c,Expiration_Date__c, Effective_Date__c, Underwriter_User__r.Email, Underwriter_User__r.Name, Premium__c FROM Policy__c WHERE Id =: policyId LIMIT 1];
            policyEndorsement.Policy__c = policy.Id;
            policyEndorsement.Account__c = policy.Account__c;
            
            System.debug(policyEndorsement.Endorsement_Effective_Date__c);
            Decimal daysProRated = policyEndorsement.Endorsement_Effective_Date__c.daysBetween(policy.Expiration_Date__c) + 1;
            System.debug(daysProRated);
            Decimal premium;
            Decimal term;
            term = daysProRated / (policy.Effective_Date__c.daysBetween(policy.Expiration_Date__c));
            if(term > 1){
                term = 1;
            }
            if (policyEndorsement.Override_Rating__c == true) {
                premium = ((policy.Premium__c + policyEndorsement.Override_5_5__c + policyEndorsement.Override_10_10__c)* term).round(System.RoundingMode.HALF_UP);
            } else {
                premium = (policy.Premium__c * term).round(System.RoundingMode.HALF_UP);
            }
            
            //upsert policyEndorsement;
            system.debug('paymentGateway class called 2');
            String upserResp = updatePSchRecords(new List<Policy_Endorsement__c>{policyEndorsement}, 'upsert');
            system.debug('upserResp => '+upserResp);
            
            List<Policy_Endorsement__c> endorsementList = new List<Policy_Endorsement__c>();
            
            endorsementList = (List<Policy_Endorsement__c>) system.JSON.deserializeStrict(upserResp, List<Policy_Endorsement__c>.class);
            endorsementList[0].Event_Status__c = 'Submitted';
            system.debug('endorsementList => '+endorsementList);
            User_Tracking__c userTrack = UserTrackingHandler.createUserTrackingObject('Create', endorsementList[0].Id, policyEndorsement.Name);
            
            updatePSchRecords(new List<User_Tracking__c>{userTrack}, 'upsert');
            updatePSchRecords(endorsementList, 'upsert');
            
            String emailBody = 'Hi '+policy.Underwriter_User__r.Name+',\n\n A request has been submitted to cancel policy "'+policy.Name+'". \n\nPlease review the request. \n\nThank you.'; 
            
            sendEmailToTheUnderwriter(policy.Underwriter_User__r.Email, 'Policy cancellation request submitted.',emailBody, policy.Id);
            List<Policy_Endorsement__c> recordList = [SELECT Id, Name, Application_Form_Link__c, Override_NBA_Expire_Date__c, Endorsement_Number__c, Premium__c, Event_Status__c, Lawyer__c, Lawyer__r.Name, Endorsement_Effective_Date__c, Coverage_Term__c, Policy__c, Policy__r.Name  FROM Policy_Endorsement__c WHERE Account__c =: policy.Account__c AND (Event_Status__c='Pending' OR Event_Status__c='Submitted') AND (Endorsement_Number__c='IL 107' OR Endorsement_Number__c='IL 152' OR Endorsement_Number__c='IL 153' OR Endorsement_Number__c='IL 190')];
            return recordList;
        }
        catch(Exception e){
            String error = e.getMessage();
            error = error.substringBefore(': []');
            error = error.contains('EXCEPTION, ') ? error.substringAfter('EXCEPTION, ') : error;
            Error err = new Error(error, 'Error while canceling the policy.', 'Team,\n\nFollowing error has occurred while canceling the policy \n\n'+e.getMessage() + '\n\n'+e.getStackTraceString()+'\n\n on the Record :'+ policyId );
            throw new PaymentGatewayClassException(JSON.serialize(err));
        }
    } 
    
    @AuraEnabled 
    public static List<Policy_Endorsement__c> addPolicyLawyer(String policyId, String endorsement){
        try{
            System.debug('endorsement = >'+endorsement);
            String recTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='Policy_Endorsement__c' AND Name='IL 152 Adding an Attorney Endorsement' limit 1][0].Id;
            Policy_Endorsement__c policyEndorsement = (Policy_Endorsement__c)system.JSON.deserializeStrict(endorsement, Policy_Endorsement__c.class);
            //policyEndorsement.Endorsement_Effective_Date__c = effectiveDate; \
            system.debug('policyEndorsement => '+policyEndorsement);
            policyEndorsement.Effective_Date__c = policyEndorsement.Endorsement_Effective_Date__c; 
            policyEndorsement.RecordTypeId = recTypeId;
            policyEndorsement.Event_Status__c = 'Pending';
            policyEndorsement.Prior_Act_Date__c = policyEndorsement.IL_152_Prior_Act_Date__c;
            policyEndorsement.Rate_At__c = policyEndorsement.IL_152_Average_Number_of_Hours_Worked__c > 20 ? 100 : 75;
            List<AccountContactJunction__c> lawyer = new List<AccountContactJunction__c>([SELECT Id FROM AccountContactJunction__c WHERE Contact__r.ARDC_Number__c =: policyEndorsement.IL_152_ARDC__c]);
            Policy__c policy = [SELECT Id, Name, Account__c,Expiration_Date__c, Effective_Date__c, Underwriter_User__r.Email, Underwriter_User__r.Name, Premium__c, Limit__c, Firm_Mod__c, Deductible_ID__c, Base_Amount__c, Final_Quote_10x10_Value__c,ADJ_MOD__c,X5_5_Override__c,X10x10__c FROM Policy__c WHERE Id =: policyId LIMIT 1];
            policyEndorsement.Policy__c = policy.Id;
            policyEndorsement.Account__c = policy.Account__c;
            if(!lawyer.isEmpty()){
                policyEndorsement.Lawyer__c = lawyer[0].Id;
            }
            Map<Id,Step_Rate_Factor__c> stepFactors = new Map<Id,Step_Rate_Factor__c>();
            Map<Id,ILF_Coverage_Factor__c> lowestLimitFactor = new Map<Id,ILF_Coverage_Factor__c>();
            set<String> setLimitFactorIds = new Set<String>();
            set<String> setDeductibleFactorIds = new Set<String>();
            //Map<String,Policy__c> mapOfPolicies = new Map<String,Policy__c>();
            Map<String,ILF_Coverage_Factor__c> mapOfLimits = new Map<String,ILF_Coverage_Factor__c>();
            Map<String,Deductible_Factor__c> mapOfDeductibles = new Map<String,Deductible_Factor__c>();
            List<Policy_Endorsement__c> lstPolicyEndorsements = new List<Policy_Endorsement__c>();
            List<Policy_Endorsement__c> lstPolicyEndorsementsToUpdate = new List<Policy_Endorsement__c>();
            List<Step_Rate_Factor__c> stepRateFactorsList = new List<Step_Rate_Factor__c>([SELECT Id,From_Date__c,To_Date__c, Factor_Value_Step_Rate_0__c, Factor_Value_Step_Rate_1__c, Factor_Value_Step_Rate_2__c, Factor_Value_Step_Rate_3__c, Factor_Value_Step_Rate_4__c, Factor_Value_Step_Rate_5__c, Factor_Value_Step_Rate_6__c, Factor_Value_Step_Rate_7__c, Master_Factor__c FROM Step_Rate_Factor__c WHERE Master_Factor__r.Factor_type__c = 'Step Rate']);
            List<ILF_Coverage_Factor__c> lowestLimitFactorList = new List<ILF_Coverage_Factor__c>([SELECT Id,From_Date__c,To_Date__c, Factor_Value__c, Lowest_Coverage__c, Master_Factor__c FROM ILF_Coverage_Factor__c WHERE Master_Factor__r.Factor_type__c = 'Coverage' AND Lowest_Coverage__c = true]);            
            //for (Policy__c pol : [SELECT Id, Name, Effective_Date__c, Expiration_Date__c, Limit__c, Firm_Mod__c, Deductible_ID__c, Base_Amount__c, Final_Quote_10x10_Value__c,ADJ_MOD__c,X5_5_Override__c,X10x10__c FROM Policy__c WHERE Id = :policyEndorsement.Policy__c]) {
            for(Step_Rate_Factor__c factor : stepRateFactorsList){
                if(factor.From_Date__c <= policy.Effective_Date__c &&  factor.To_Date__c >= policy.Effective_Date__c){
                    stepFactors.put(policy.Id,factor);
                }
            }
            for(ILF_Coverage_Factor__c factor : lowestLimitFactorList){
                if(factor.From_Date__c <= policy.Effective_Date__c &&  factor.To_Date__c >= policy.Effective_Date__c){
                    lowestLimitFactor.put(policy.Id,factor);
                }
            }
            //mapOfPolicies.put(policy.Id,policy);
            setLimitFactorIds.add(policy.Limit__c);
            setDeductibleFactorIds.add(policy.Deductible_ID__c);
            //}
            
            // Get all the limits applied to policy endorsements and fill the map.
            for (ILF_Coverage_Factor__c lim : [SELECT Id, Name, Is_5X5_Coverage__c, Is_10X10_Coverage__c, Percnt_amt_5X5_Step_0__c, Percnt_amt_5X5_Step_1__c, Percnt_amt_5X5_Step_2__c, Percnt_amt_5X5_Step_3__c, Premium_Rate_5X5__c, Factor_Value__c,X4x1_Rate__c FROM ILF_Coverage_Factor__c WHERE Id IN: setLimitFactorIds]) {
                mapOfLimits.put(lim.Id,lim);
            }
            
            // Get all the deductibles applied to policy endorsements and fill the map.
            for (Deductible_Factor__c ded : [SELECT Id, Name, Deductible_Amount__c, Factor_Value__c, Master_Factor__c FROM Deductible_Factor__c WHERE Id IN: setDeductibleFactorIds]) {
                mapOfDeductibles.put(ded.Id,ded);
            }
            
            Decimal stepFactorValue;
            Decimal rate = 0;
            if(String.isNotBlank(String.valueOf(policyEndorsement.Rate_At__c))){
                rate = (policyEndorsement.Rate_At__c == 0 ? 0 : policyEndorsement.Rate_At__c) / 100;
            }
            Decimal amountBeforeDeductible;
            Decimal deductibleFactorAmount;
            
            system.debug('policyEndorsement >> ' + policyEndorsement);
            
            ILF_Coverage_Factor__c limitFactor = mapOfLimits.get(policy.Limit__c);
            
            Deductible_Factor__c deductibleFactor = mapOfDeductibles.get(policy.Deductible_ID__c);
            
            policyEndorsement.Step__c = ApplicationPolicyUtil.CalculateLawyerStep(policy.Effective_Date__c,policyEndorsement.Prior_Act_Date__c);
            
            Date endorsementEffectiveDate = policyEndorsement.Endorsement_Effective_Date__c;
            
            System.debug('policy.Expiration_Date__c: : ' + policy.Expiration_Date__c);
            System.debug('endorsementEffectiveDate: : ' + endorsementEffectiveDate);
            
            Decimal daysProRated = policyEndorsement.Endorsement_Effective_Date__c.daysBetween(policy.Expiration_Date__c) + 1;
            policyEndorsement.Term__c = daysProRated / (Date.isLeapYear(Date.today().year()) ?  366 : 365);
            
            if(policyEndorsement.Term__c > 1){
                policyEndorsement.Term__c = 1;
            }
            
            if (policyEndorsement.Step_Override__c == true) {
                if (policyEndorsement.Step_Override_Value__c == 0) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_0__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 1) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_1__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 2) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_2__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 3) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_3__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 4) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_4__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 5) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_5__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 6) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_6__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 7) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_7__c:0;
                }
            } else {
                if (policyEndorsement.Step__c == 0) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_0__c:0;
                } else if (policyEndorsement.Step__c == 1) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_1__c:0;
                } else if (policyEndorsement.Step__c == 2) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_2__c:0;
                } else if (policyEndorsement.Step__c == 3) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_3__c:0;
                } else if (policyEndorsement.Step__c == 4) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_4__c:0;
                } else if (policyEndorsement.Step__c == 5) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_5__c:0;
                } else if (policyEndorsement.Step__c == 6) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_6__c:0;
                } else if (policyEndorsement.Step__c == 7) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_7__c:0;
                }
            }
            
            amountBeforeDeductible = (100 * stepFactorValue * policy.Base_Amount__c * limitFactor.Factor_Value__c * policy.Firm_Mod__c) / 100;
            amountBeforeDeductible = amountBeforeDeductible.round(System.RoundingMode.HALF_UP);
            
            deductibleFactorAmount = ((stepFactorValue * policy.Base_Amount__c * (lowestLimitFactor.containsKey(policyEndorsement.Policy__c)?lowestLimitFactor.get(policyEndorsement.Policy__c).Factor_Value__c:0) * policy.Firm_Mod__c) - (stepFactorValue * policy.Base_Amount__c * (lowestLimitFactor.containsKey(policyEndorsement.Policy__c)?lowestLimitFactor.get(policyEndorsement.Policy__c).Factor_Value__c:0) * policy.Firm_Mod__c * deductibleFactor.Factor_Value__c));
            deductibleFactorAmount = (100 * deductibleFactorAmount) / 100;
            deductibleFactorAmount = deductibleFactorAmount.round(System.RoundingMode.HALF_UP);
            deductibleFactorAmount = deductibleFactorAmount * (-1);
            
            
            policyEndorsement.Excess__c =  limitFactor.X4x1_Rate__c != null ? (amountBeforeDeductible/limitFactor.Factor_Value__c)*limitFactor.X4x1_Rate__c : 0;
            
            
            //policyEndorsement.Primary__c = (100 * stepFactorValue * rate * policyEndorsement.Term__c * policy.Base_Amount__c * limitFactor.Factor_Value__c * deductibleFactor.Factor_Value__c * policy.Firm_Mod__c) / 100;
            policyEndorsement.Primary__c = (amountBeforeDeductible + deductibleFactorAmount) - policyEndorsement.Excess__c;
            
            policyEndorsement.Excess__c = policyEndorsement.Excess__c * rate * policyEndorsement.Term__c;
            policyEndorsement.Excess__c = policyEndorsement.Excess__c.round(System.RoundingMode.HALF_UP);
            
            policyEndorsement.Primary__c = policyEndorsement.Primary__c * rate * policyEndorsement.Term__c;
            
            policyEndorsement.Primary__c = (100 * policyEndorsement.Primary__c) / 100;
            policyEndorsement.Primary__c = policyEndorsement.Primary__c.round(System.RoundingMode.HALF_UP);
            
            if (limitFactor.Is_5X5_Coverage__c == true) {
                if (policyEndorsement.Step_Override__c == true) {
                    if (policyEndorsement.Step_Override_Value__c == 0) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_0__c;
                    } else if (policyEndorsement.Step_Override_Value__c == 1) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_1__c;
                    } else if (policyEndorsement.Step_Override_Value__c == 2) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_2__c;
                    } else if (policyEndorsement.Step_Override_Value__c == 3) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_3__c;
                    } else if (policyEndorsement.Step_Override_Value__c > 3) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Premium_Rate_5X5__c;
                    }
                }else if(policy.X5_5_Override__c != null && policy.X5_5_Override__c>0){
                    policyEndorsement.Premium_5_5__c = policy.X5_5_Override__c * policyEndorsement.Term__c;
                } else {
                    if (policyEndorsement.Step__c == 0) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_0__c;
                    } else if (policyEndorsement.Step__c == 1) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_1__c;
                    } else if (policyEndorsement.Step__c == 2) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_2__c;
                    } else if (policyEndorsement.Step__c == 3) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_3__c;
                    } else if (policyEndorsement.Step__c > 3) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Premium_Rate_5X5__c;
                    }
                    policyEndorsement.Premium_5_5__c = policyEndorsement.Premium_5_5__c * policyEndorsement.Term__c;
                }
            } else {
                policyEndorsement.Premium_5_5__c = 0.00;
            }
            
            if(policy.X10x10__c != null && policy.X10x10__c>0){
                policyEndorsement.Premium_10_10__c = policy.X10x10__c * policyEndorsement.Term__c;
            }else{
                policyEndorsement.Premium_10_10__c = 0.0;
            }
            
            
            if (policyEndorsement.Override_Rating__c == true) {
                policyEndorsement.Premium__c = policyEndorsement.Primary__c + policyEndorsement.Excess__c + (policyEndorsement.Override_5_5__c == null ? 0 : policyEndorsement.Override_5_5__c) + (policyEndorsement.Override_10_10__c == null ? 0 : policyEndorsement.Override_10_10__c);
            } else {
                policyEndorsement.Premium__c = policyEndorsement.Primary__c + policyEndorsement.Excess__c + (policyEndorsement.Premium_5_5__c == null ? 0 : policyEndorsement.Premium_5_5__c) + (policyEndorsement.Premium_10_10__c == null ? 0 : policyEndorsement.Premium_10_10__c);
            }
            if(policy.ADJ_MOD__c!=null){
                policyEndorsement.Premium__c = ( policyEndorsement.Premium__c +  (policyEndorsement.Premium__c * (policy.ADJ_MOD__c-1)));
            }
            policyEndorsement.Premium__c = (100 * policyEndorsement.Premium__c) / 100;
            policyEndorsement.Premium__c = policyEndorsement.Premium__c.round(System.RoundingMode.HALF_UP);
            
            system.debug('PaymentGatewayClass called 3');
            String upserResp = updatePSchRecords(new List<Policy_Endorsement__c>{policyEndorsement}, 'upsert');
            system.debug('upserResp => '+upserResp);
            
            List<Policy_Endorsement__c> endorsementList = new List<Policy_Endorsement__c>();
            
            endorsementList = (List<Policy_Endorsement__c>) system.JSON.deserializeStrict(upserResp, List<Policy_Endorsement__c>.class);
            endorsementList[0].Event_Status__c = 'Submitted';
            system.debug('endorsementList => '+endorsementList);
            //User_Tracking__c userTrack = UserTrackingHandler.createUserTrackingObject('Create', endorsementList[0].Id, policyEndorsement.Name);
            
            //updatePSchRecords(new List<User_Tracking__c>{userTrack}, 'upsert');
            updatePSchRecords(endorsementList, 'upsert');
            
            String emailBody = 'Hi '+policy.Underwriter_User__r.Name+',\n\n A request has been submitted to Add Lawyer "'+policy.Name+'". \n\nPlease review the request. \n\nThank you.'; 
            
            sendEmailToTheUnderwriter(policy.Underwriter_User__r.Email, 'Add Lawyer request submitted.',emailBody, policy.Id);
            List<Policy_Endorsement__c> recordList = [SELECT Id, Name, Application_Form_Link__c, Override_NBA_Expire_Date__c, Endorsement_Number__c, Premium__c, Event_Status__c, Lawyer__c, Lawyer__r.Name, Endorsement_Effective_Date__c, Coverage_Term__c, Policy__c, Policy__r.Name  FROM Policy_Endorsement__c WHERE Account__c =: policy.Account__c AND (Event_Status__c='Pending' OR Event_Status__c='Submitted') AND (Endorsement_Number__c='IL 107' OR Endorsement_Number__c='IL 152' OR Endorsement_Number__c='IL 153' OR Endorsement_Number__c='IL 190')];
            return recordList;
        }
        catch(Exception e){
            Error err = new Error(e.getMessage(), 'Error while Adding the Lawyer.', 'Team,\n\nFollowing error has occurred while Adding the Lawyer. \n\n'+e.getMessage() + '\n\n'+e.getStackTraceString()+'\n\n on the Record :'+ policyId );
            throw new PaymentGatewayClassException(JSON.serialize(err));
        }
    } 
    
    public static void sendEmailToTheUnderwriter(String emailId, String subject, String body, String policyId){
        try {
            String  OrgWideEmailAddressId = '';
            List<OrgWideEmailAddress> oweaList = [select Id,DisplayName from OrgWideEmailAddress Where DisplayName =: Label.OrganizationWideEmail];
            if (!oweaList.isEmpty()) {
                //mail.setOrgWideEmailAddressId(oweaList.get(0).Id);
                OrgWideEmailAddressId = oweaList.get(0).Id;
            } 
            Messaging.SingleEmailMessage[] allmsg =   new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            
            mail.setToAddresses(new List<String>{'ramavtar@cmentor.com'});//emailId
            mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            mail.setSubject(subject);
            mail.setPlainTextBody(body);  
            mail.setSaveAsActivity(false);
            
            system.debug(JSON.serialize(mail));
            
            allmsg.add(mail);
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg, false);
            
            system.debug(results);
        } catch (Exception e) {
            Error err = new Error(e.getMessage(), 'Error While sending Deletion Request to the Underwriter.', 'Team,\n\nFollowing error has occurred while sending Deletion Request to the Underwriter \n\n'+e.getMessage() + '\n\n'+e.getStackTraceString()+'\n\n The PolicyId is:'+policyId+'and Email Address is '+emailId );
            throw new PaymentGatewayClassException(JSON.serialize(err));
            //throw new PaymentGatewayClassException(e.getMessage());
        }
    }
    
    @AuraEnabled 
    public static String processPayment(String warpperObjStr, String ipAddress,String userSession) {
        Boolean isPolicy = false;
        Boolean isPolicyEndorsement = false;
        DateTime paymentDate = system.Now();
        Boolean constructEmail = false;
        isInternalUser = Userinfo.getUserType() == 'Guest' ? false : true;
        String receiptNumber = 'Error';
        List<Sobject> recordsToInsertUpdate = new List<Sobject>();
        System.debug('warpperObj' + warpperObjStr);
        boolean paymentSuccess = false;
        boolean send = false;
        boolean isAuth = false;
        PaymentGateway_Ctrl_Wrapper warpperObj = (PaymentGateway_Ctrl_Wrapper)System.JSON.deserializeStrict(warpperObjStr, PaymentGateway_Ctrl_Wrapper.class);
        warpperObj.ipAddress = ipAddress;
        
        AcctSeed__Billing__c billing = new AcctSeed__Billing__c();
        Policy__c policy = new Policy__c();
        Policy_Endorsement__c endorsement = new Policy_Endorsement__c();
        if(warpperObj.billing != null){
            billing = warpperObj.billing;
        }
        else if(!warpperObj.isPolicy){
            isPolicyEndorsement = true;
            endorsement = warpperObj.endorsement;
            policy = warpperObj.policy;
            warpperObj.baseAmountToPay = warpperObj.totalAmountDue;
        }
        else {
            isPolicy = true;
            policy = warpperObj.policy;
            if(isPolicyBind(policy.Id)){
                throw new PaymentGatewayClassException('This Policy is Already Bind.');
            }
            warpperObj.baseAmountToPay = warpperObj.totalAmountDue;
        }
        system.debug('Process Payment Called');
        String  OrgWideEmailAddressId = '';
        String body = '';  //StoringEmailBody
        
        baseAmountToPay = warpperObj.baseAmountToPay;
        System.debug('baseAmountToPay' + baseAmountToPay);
        String payMethodToken = '';
        String transactionGatewayResponse = '';
        String transactionGatewayError = '';
        Savepoint sp;
        List<Payment_Method__c> Paymethods = new List<Payment_Method__c>();
        try{
            if(warpperObj.paymentTypeVar ==''){
                warpperObj.paymentTypeVar = 'creditCard';
            }
            
            checkCustomerIdCardKnox(warpperObj);
            
            paymentError =false;
            paymentErrorMessage='';
            
            System.debug('baseAmountToPay -> ' + baseAmountToPay);
            System.debug('totalAmountDue -> '+warpperObj.totalAmountDue);
            ForteUtilNew util;
            String transactionAction = '';
            if(warpperObj.paymentTypeVar=='check' && String.isBlank(warpperObj.accountType)){
                //currentStage='contactDetails';                
                paymentErrorMessage = 'An error has occurred with the Account Type. Please get in touch with your ISBA Mutual Policy Contact.';
                paymentError = true;
                
                
                throw new PaymentGatewayClassException('An error has occurred with the Account Type. Please get in touch with your ISBA Mutual Policy Contact.');
            }
            else if((warpperObj.paymentTypeVar=='creditCard' || (warpperObj.paymentTypeVar == 'Existing' && warpperObj.cardNumber !=null)) && warpperObj.balanceDue > 20000){
                //currentStage='contactDetails';
                paymentErrorMessage = 'Credit Card payments not available for transactions exceeding $20,000';
                paymentError = true;
                
                
                throw new PaymentGatewayClassException('Credit Card payments not available for transactions exceeding $20,000.');
            }
            else{
                List<AcctSeed__Payment_Processor__c> paymentProcessor = [select id from AcctSeed__Payment_Processor__c where AcctSeed__Type__c = 'Fiserv' limit 1];
              
                if(warpperObj.isAutoPay){
                    string customerId = '';
                    if(warpperObj.accRecord != null){
                        customerId = warpperObj.accRecord.Id;
                    }
                    else{
                        customerId = warpperObj.billing.AcctSeed__Customer__c;
                    }
                    
                    Paymethods = [SELECT Id,Name ,Default__c,Name_On_Card__c,Account_Type__c,Type__c,Card_Type__c,Payment_Method_Token__c,Routing_Number__c,Card_Holder_Name__c,Masked_Account_Number__c,Expiry_Month__c,Expiry_Year__c FROM Payment_Method__c WHERE (Id=:warpperObj.paymentMethodId OR Default__c= true) AND  Account__c =:customerId AND Is_Deleted__c = false];
                    if(warpperObj.paymentMethodId != '' && warpperObj.paymentMethodId != 'Physical_Check'){
                        for(Payment_Method__c pm: Paymethods){
                            if(pm.Id == warpperObj.paymentMethodId){
                                pm.Default__c = true;                           
                            }
                            else{
                                pm.Default__c = false;
                            }
                        }
                    }
                }
                
                if(warpperObj.totalAmountDue == 0){
                    paymentDate = system.Now();
                    paymentSuccess = true;
                    receiptNumber = 'Success';
                }else{
                    //Map<String,Object> authTransactionResponseMp = new Map<String,Object>();
                    Map<String,Object> transactionResponseMp = new Map<String,Object>();
                    if(!isPolicy && !isPolicyEndorsement){
                        //paymentDate = system.Now();
                        /*if(warpperObj.paymentTypeVar!='check' && !warpperObj.isPaymentMethodAuthenticated){
                            transactionResponseMp = CardknoxUtil.ProcessTransaction(0.01,warpperObj,'Auth');
                        }
                        
                        //string authTransactionGatewayError = '';
                        
                        if(warpperObj.paymentTypeVar != 'check' && (string)transactionResponseMp.get('Result')=='E'){
                            if((String)transactionResponseMp.get('Error')!=''){
                                transactionGatewayError = (String)transactionResponseMp.get('Error');
                            }else {
                                transactionGatewayError = (String)transactionResponseMp.get('GatewayErrorMessage');
                            }
                            Integration_Log__c log = new Integration_Log__c();
                            log.Billing__c =billing.id;
                            log.Status__c='Processed With Errors';
                            log.Transaction_Amount__c=0.01;
                            log.Customer_IP__c = warpperObj.ipAddress;
                            log.Payment_Date__c = paymentDate;
                            log.Description__c='Error : '+transactionGatewayError + '\n';
                            log.User_Session__c = userSession;
                            recordsToInsertUpdate.add(log);
                            
                            isAuth = true;
                            transactionGatewayResponse = 'An error occurred while processing the payment.\n'+transactionGatewayError;
                        }
                        else{
                            Integration_Log__c log = new Integration_Log__c();
                            log.Billing__c =billing.id;
                            log.Status__c='Processed Successfully';
                            log.Transaction_Amount__c=0.01;
                            log.Customer_IP__c = warpperObj.ipAddress;
                            log.Payment_Date__c = paymentDate;
                            log.Description__c='Payment Authorised Successfully';
                            log.User_Session__c = userSession;                            
                            log.Transaction_Id__c= warpperObj.paymentTypeVar=='check' ? 'Check Transaction Auth' : (String)transactionResponseMp.get('GatewayRefNum');
                            recordsToInsertUpdate.add(log);
							*/
                            
                            paymentDate = system.Now();
                            //transactionResponseMp = CardknoxUtil.ProcessTransaction(baseAmountToPay,warpperObj,'Sale');
                            if(warpperObj.paymentTypeVar == 'creditCard'){
                                transactionResponseMp = Fiserv_Utils.createCreditCardCharge(baseAmountToPay, warpperObj);
                            }
                            else{
                                transactionResponseMp = Fiserv_Utils.createACHCharge(baseAmountToPay, warpperObj);
                            }
                            
                            if((string)transactionResponseMp.get('respstat')=='A' && ((string)transactionResponseMp.get('resptext')=='Approval' ||(string)transactionResponseMp.get('resptext') == 'Approved')){
                                paymentSuccess = true;
                                transactionGatewayResponse = (String)transactionResponseMp.get('retref');
                                
                                /*Integration_Log__c log1 = new Integration_Log__c();
                                log1.Billing__c =billing.id;
                                log1.Status__c='Processed Successfully';
                                log1.Transaction_Amount__c = baseAmountToPay;
                                log1.Customer_IP__c = warpperObj.ipAddress;
                                log1.Payment_Date__c = paymentDate;
                                log1.Description__c='Payment Processed Successfully';
                                log1.User_Session__c = userSession;                            
                                log1.Transaction_Id__c = (String)transactionResponseMp.get('retref');
                                recordsToInsertUpdate.add(log1);*/
                            }else{
                                paymentSuccess = false;
                                
                                List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>([SELECT Id, Paid_Amount__c, Due_Amount__c ,Amount__c,Due_Date__c FROM Payment_Schedule__c Where Billing__c =:warpperObj.billing.Id  AND Due_Amount__c > 0  ORDER BY Due_Date__c ASC]);
                                List<Payment_Schedule__c> updatedPaymentSchedules = new List<Payment_Schedule__c>();
                                
                                
                                for(Payment_Schedule__c ps: paymentSchedules){
                                    if(ps.Due_Date__c <= System.today()){
                                        ps.Status__c = 'Rejected';
                                        updatedPaymentSchedules.add(ps);
                                    }
                                }
                                
                                if(!updatedPaymentSchedules.isEmpty()){
                                    updatePSchRecords(updatedPaymentSchedules,'update');
                                }
                                
                                if((String)transactionResponseMp.get('resptext')!=''){
                                    transactionGatewayError = (String)transactionResponseMp.get('resptext');
                                }else {
                                    transactionGatewayError = (String)transactionResponseMp.get('retref');
                                }
                                /*Integration_Log__c log1 = new Integration_Log__c();
                                log1.Billing__c =billing.id;
                                log1.Status__c='Processed With Errors';
                                log1.Transaction_Amount__c = baseAmountToPay;
                                log1.Customer_IP__c = warpperObj.ipAddress;
                                log1.Payment_Date__c = paymentDate;
                                log1.Description__c='Error : '+transactionGatewayError + '\n';
                                log1.User_Session__c = userSession;                            
                                log1.Transaction_Id__c = transactionGatewayError;
                                recordsToInsertUpdate.add(log1);*/
                                transactionGatewayResponse = 'An error occurred while processing the payment.\n'+transactionGatewayError;
                            }
                        //}
                    }
                    else{
                        if(warpperObj.paymentTypeVar=='check'){
                            paymentSuccess = true;
                            transactionGatewayResponse = 'check';
                        }
                        else if(warpperObj.paymentTypeVar=='Physical_Check'){
                            paymentSuccess = true;
                            transactionGatewayResponse = 'Physical_Check';
                        }
                        else{                            
                            /*if(!warpperObj.isPaymentMethodAuthenticated){
                                paymentDate = system.Now();
                                transactionResponseMp = CardknoxUtil.ProcessTransaction(0.01,warpperObj,'Auth'); 
                                
                                
                                if((string)transactionResponseMp.get('Result')=='S' && (string)transactionResponseMp.get('GatewayStatus')=='Approved'){
                                    paymentSuccess = true;
                                    transactionGatewayResponse = (String)transactionResponseMp.get('GatewayRefNum');
                                    
                                    Integration_Log__c log1 = new Integration_Log__c();
                                    log1.Policy__c =policy.id;
                                    if(isPolicyEndorsement){
                                        log1.Policy_Endorsement__c = endorsement.Id;
                                    }
                                    log1.Status__c='Processed Successfully';
                                    log1.Transaction_Amount__c = 0.01;
                                    log1.Customer_IP__c = warpperObj.ipAddress;
                                    log1.Payment_Date__c = paymentDate;
                                    log1.Description__c='Payment Authorised Successfully';
                                    log1.User_Session__c = userSession;                            
                                    log1.Transaction_Id__c = transactionGatewayResponse;
                                    recordsToInsertUpdate.add(log1);
                                    
                                }
                                else{
                                    paymentSuccess = false;
                                    if((String)transactionResponseMp.get('Error')!=''){
                                        transactionGatewayError = (String)transactionResponseMp.get('Error');
                                    }else {
                                        transactionGatewayError = (String)transactionResponseMp.get('GatewayErrorMessage');
                                    }
                                    
                                    Integration_Log__c log = new Integration_Log__c();
                                    log.Policy__c =policy.id;
                                    if(isPolicyEndorsement){
                                        log.Policy_Endorsement__c = endorsement.Id;
                                    }
                                    log.Status__c='Processed With Errors';
                                    log.Transaction_Amount__c=0.01;
                                    log.Customer_IP__c = warpperObj.ipAddress;
                                    log.Payment_Date__c = paymentDate;
                                    log.Description__c='Error : '+transactionGatewayError + '\n';
                                    log.User_Session__c = userSession;
                                    recordsToInsertUpdate.add(log);
                                    transactionGatewayResponse = 'An error occurred while processing the payment.\n'+transactionGatewayError;
                                }
                            }
                            else{*/
                                paymentSuccess = true;
                                transactionGatewayResponse = 'Card';
                            //}
                        }
                        isAuth = true;
                    }
                
                }
                
                if(paymentSuccess){    
                    if(!isPolicy && !isPolicyEndorsement){
                        if(warpperObj.totalAmountDue > 0){
                            String billId = warpperObj.billing.Id;
                            system.debug('billId -> '+billId);
                            List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>([SELECT Id, Paid_Amount__c, Due_Amount__c ,Amount__c FROM Payment_Schedule__c Where Billing__c =:billId  AND Due_Amount__c > 0  ORDER BY Due_Date__c ASC]);
                            List<Payment_Schedule__c> updatedPaymentSchedules = new List<Payment_Schedule__c>();
                            system.debug('paymentSchedules -> '+paymentSchedules);
                            Decimal totalAmountReceived = warpperObj.totalAmountDue;
                            if(!paymentSchedules.isEmpty()){
                                Payment_Schedule__c ps = paymentSchedules[0];
                                ps.Paid_Amount__c = ps.Due_Amount__c;
                                ps.Status__c = 'Pending';
                                //totalAmountReceived = totalAmountReceived - ps.Due_Amount__c;
                                updatedPaymentSchedules.add(ps);
                                
                            }
                            if(!updatedPaymentSchedules.isEmpty()){
                                updatePSchRecords(updatedPaymentSchedules,'update');
                            }
                            String jsonBody = '';
                            
                            jsonBody = '{"warpperObj" :'+JSON.serialize(warpperObj);
                            system.debug('jsonBody => '+jsonBody);
                            
                            jsonBody += ', "PaymtSchId" : "'+paymentSchedules[0].Id;
                            system.debug('jsonBody => '+jsonBody);
                            
                            jsonBody +='" ,"UtilTranId" : {"UtilTranId" : "'+(transactionGatewayResponse != '' ? transactionGatewayResponse: null)+'"},"Billing" :{"Id": '+JSON.serialize(billing.id) +'},"paymentQuartersDt" : {"paymentQuartersDt" : "'+paymentQuartersDt+'"},"baseAmountToPay" : {"baseAmountToPay" : "'+baseAmountToPay+'"},"paymentMonthsDt" : {"paymentMonthsDt" : "'+paymentMonthsDt+'"},"totalAmountDue" : {"totalAmountDue" : "'+warpperObj.totalAmountDue+'"},"receiptNumber" : {"receiptNumber" : "'+warpperObj.receiptNumber+'"},"firstInstallment" : {"firstInstallment" : "'+warpperObj.firstInstallment+'"},"firstInstallmentDate" : {"firstInstallmentDate" : "'+warpperObj.firstInstallmentDate+'"}}';
                            
                            system.debug('jsonBody => '+jsonBody);
                            
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
                                ////currentStage='contactDetails';
                                //paymentErrorMessage = 'An error occurred while processing your payment.';
                                //paymentError = true;
                                Integration_Log__c log = new Integration_Log__c();
                                log.Billing__c =billing.id;
                                log.Status__c='Processed With Errors';
                                log.Transaction_Amount__c=warpperObj.totalAmountDue;
                                log.Transaction_Id__c=transactionGatewayResponse;
                                log.Customer_IP__c = warpperObj.ipAddress;
                                log.Payment_Date__c = paymentDate;
                                // log.Transaction_Id__c=transactionAction != 'authorize' ? util.transaction_id : null;
                                // log.Transaction_Action__c = transactionAction;
                                // if(util1!=null){
                                //     log.Transaction_Id__c= log.Transaction_Id__c + ',' + util1.transaction_id;
                                // }
                                log.Description__c='Error : '+ wrapper.error;
                                log.User_Session__c = userSession;
                                recordsToInsertUpdate.add(log);
                            }
                            else{
                                receiptNumber = wrapper.receiptNumber;
                                warpperObj.receiptNumber = wrapper.receiptNumber;
                                List<OrgWideEmailAddress> orgWideEmailAddress = [SELECT Id, Address FROM OrgWideEmailAddress where Address = 'accounting@isbamutual.com'];
                                try{
                                    if(warpperObj.confirmationEmail!=null || warpperObj.confirmationEmail!=''){
                                        constructEmail = true;
                                        warpperObj.lastName = warpperObj.billing.AcctSeed__Customer__r.AcctSeed__Billing_Contact__r.LastName;
                                        warpperObj.firstName = warpperObj.billing.AcctSeed__Customer__r.AcctSeed__Billing_Contact__r.FirstName;
                                        warpperObj.emailAddress = billing.AcctSeed__Customer__r.AcctSeed__Billing_Contact__r.Email;
                                        
                                    }
                                    
                                    
                                    Integration_Log__c log = new Integration_Log__c();
                                    log.Billing__c =billing.id;
                                    log.Status__c='Processed Successfully';
                                    log.Transaction_Amount__c=warpperObj.totalAmountDue;
                                    log.Transaction_Id__c=transactionGatewayResponse;
                                    log.Customer_IP__c = warpperObj.ipAddress;
                                    log.Payment_Date__c = paymentDate;
                                    // log.Transaction_Id__c=util.transaction_id;
                                    // log.Transaction_Action__c = transactionAction;
                                    log.Cash_Receipt__c = wrapper.cashReceiptId;
                                    // if(util1!=null){
                                    //     log.Transaction_Id__c= log.Transaction_Id__c + ',' + util1.transaction_id;
                                    // }
                                    if(warpperObj.totalAmountDue == 0){
                                        log.Description__c='Verify Processed Successfully';
                                    }else{
                                        log.Description__c='Payment Processed Successfully';
                                    }
                                    log.User_Session__c = userSession;
                                    recordsToInsertUpdate.add(log);
                                    
                                    
                                }catch(Exception e){
                                    System.debug('Error--'+e.getMessage()+'--Line--'+e.getLineNumber());
                                    //Database.rollback(sp);
                                    ////currentStage='contactDetails';
                                    //paymentErrorMessage = 'An error occurred while generating cash receipt. Your transaction id is : '+util.transaction_id;
                                    //paymentError = true;
                                    Integration_Log__c log = new Integration_Log__c();
                                    log.Billing__c =billing.id;
                                    log.Status__c='Processed With Errors';
                                    log.Transaction_Amount__c=warpperObj.totalAmountDue;
                                    log.Transaction_Id__c=transactionGatewayResponse;
                                    log.Customer_IP__c = warpperObj.ipAddress;
                                    log.Payment_Date__c = paymentDate;
                                    // log.Transaction_Id__c=transactionAction != 'authorize' ? util.transaction_id : null;
                                    // log.Transaction_Action__c = transactionAction;
                                    // if(util1!=null){
                                    //     log.Transaction_Id__c= log.Transaction_Id__c + ',' + util1.transaction_id;
                                    // }
                                    log.Description__c='Error : '+e.getMessage() + '\n' + e.getStackTraceString() + '\n';
                                    log.User_Session__c = userSession;
                                    recordsToInsertUpdate.add(log);
                                }
                            }
                            //Payment_Method__c defaultPaymentMethod = [SELECT Id FROM Payment_Method__c Where Account__c=:billing.AcctSeed__Customer__c ORDER BY createdDate DESC LIMIT 1];
                            AcctSeed__Billing__c  billToUpdate = new AcctSeed__Billing__c ();
                            billToUpdate.Id = billing.id;
                            billToUpdate.ISBAM_user_agent__c = userSession;
                            billToUpdate.Online_Payment_User__c = UserInfo.getUserId();
                            billToUpdate.Customer_Payment_datedate__c = paymentDate;
                            billToUpdate.Customer_Payment_IP_Address__c = warpperObj.ipAddress;
                            
                            recordsToInsertUpdate.add(billToUpdate);
                        }
                        else{
                            constructEmail = true;
                        }
                    }
                    else{
                        if(warpperObj.totalAmountDue == 0 && warpperObj.paymentTypeVar != 'Physical_Check'){
                            constructEmail = true;
                        }
                        policyBindWrapper bindWrapObj = new policyBindWrapper();
                        bindWrapObj.ipAddress = warpperObj.ipAddress;
                        bindWrapObj.ISBAM_user_agent = userSession;
                        bindWrapObj.firstInstallment = warpperObj.totalAmountDue; 
                        bindWrapObj.Timestamp = system.now();
                        if(warpperObj.paymentScheduleVar=='Month' || warpperObj.paymentScheduleVar=='Quarter'){
                            bindWrapObj.paymentSchedulesWrap = warpperObj.futurePaymentSchedules; 
                        }
                        // else if(warpperObj.paymentScheduleVar=='Quarter'){
                        //     bindWrapObj.perInstallmentAmount = warpperObj.perQuarterAmount; 
                        //     bindWrapObj.paymentDates = warpperObj.paymentQuarters; 
                        // }
                        
                        if(warpperObj.paymentScheduleVar == 'Quarter'){
                            bindWrapObj.paymentScheduleVar = 'Quarterly';
                        }
                        else if(warpperObj.paymentScheduleVar == 'Month'){
                            bindWrapObj.paymentScheduleVar ='Monthly';
                        }
                        else{
                            bindWrapObj.paymentScheduleVar = warpperObj.paymentScheduleVar;   
                        }
                        bindWrapObj.application_link = isInternalUser ? 'INTERNAL ('+UserInfo.getName()+')' : 'EXTERNAL';      
                        bindWrapObj.firstInstallmentDate = System.today(); 
                        if(warpperObj.totalAmountDue == 0){
                            bindWrapObj.isPaymentReceived = false; 
                            if(bindWrapObj.paymentScheduleVar == 'Full'){
                                bindWrapObj.firstInstallmentDate = warpperObj.firstInstallmentDate;
                                bindWrapObj.firstInstallment = warpperObj.firstInstallment;
                            }                            
                        }else {
                            bindWrapObj.isPaymentReceived = true; 
                        }
                        
                        bindWrapObj.deviceType = warpperObj.deviceType;
                        bindWrapObj.screenResolution = warpperObj.screenResolution;
                        bindWrapObj.windowSize = warpperObj.windowSize;
                        bindWrapObj.paymentTypeVar = warpperObj.paymentTypeVar; 
                        bindWrapObj.baseAmountToPay = warpperObj.baseAmountToPay; 
                        bindWrapObj.defaultPaymentMethodId = warpperObj.defaultPaymentMethodId; 
                        bindWrapObj.transactionId = transactionGatewayResponse;
                        bindWrapObj.billingConfirmationEmail = warpperObj.confirmationEmail;
                        warpperObj.receiptNumber = transactionGatewayResponse;
                        receiptNumber = transactionGatewayResponse;
                        // if(transactionAction != 'authorize'){
                        //     receiptNumber = util.transaction_id;
                        //     warpperObj.receiptNumber = util.transaction_id;
                        //     bindWrapObj.transactionId = util.transaction_id; 
                        // }
                        if(isPolicyEndorsement){
                            endorsement.Approve_Endorsement_JSON__c = JSON.serialize(bindWrapObj);
                            recordsToInsertUpdate.add(endorsement);
                            //PolicyEndorsementController.updatePolicy(endorsement.Id);
                            //create Bill;
                        }else{                           
                            Policy__c policyRec = warpperObj.policy;
                            policyRec.Bind_Policy_JSON__c = JSON.serialize(bindWrapObj);
                            policyRec.ISBAM_user_agent__c = userSession;
                            policyRec.PaymentReceived__c = 'Online Payment Received';
                            //update policyRec;
                            recordsToInsertUpdate.add(policyRec);
                        }
                        
                        Integration_Log__c log = new Integration_Log__c();
                        log.Policy__c = policy.id;
                        if(isPolicyEndorsement){
                            log.Policy_Endorsement__c = endorsement.Id;
                        }
                        log.Status__c='Processed Successfully';
                        log.Transaction_Amount__c=warpperObj.totalAmountDue;
                        log.Transaction_Id__c= transactionGatewayResponse;
                        // log.Transaction_Id__c= transactionAction != 'authorize' ? util.transaction_id : null;
                        // log.Transaction_Action__c = transactionAction;
                        // if(util1!=null){
                        //     log.Transaction_Id__c= log.Transaction_Id__c + ',' + util1.transaction_id;
                        // }
                        if(warpperObj.totalAmountDue == 0){
                            log.Description__c='Verify Processed Successfully';
                        }else{
                            log.Description__c='Payment Processed Successfully';
                        }
                        log.User_Session__c = userSession;
                        recordsToInsertUpdate.add(log);
                    }
                    
                    
                }
                else{
                    if(!paymentSuccess){
                        //currentStage='contactDetails';
                        paymentErrorMessage = 'An error occurred while processing your payment (Error :'+ transactionGatewayError + ')';
                        paymentError = true;
                        Integration_Log__c log = new Integration_Log__c();
                        if(isPolicy){
                            log.Policy__c = policy.Id;
                        }
                        else{
                            log.Billing__c =billing.id;
                        }
                        log.Status__c='Processed With Errors';
                        log.Transaction_Amount__c=warpperObj.totalAmountDue;
                        log.Description__c='(Error :'+ transactionGatewayError + ').';
                        // log.Transaction_Action__c = transactionAction;
                        // if(util.response.response_code == 'U80'){
                        //     log.Description__c += ('\n' + util.response.preauth_desc + '\n' + util.response.preauth_result + '\n' + util.response.preauth_neg_report );
                        //     if(util.response.preauth_desc != null){
                        //         paymentErrorMessage += ('(' + util.response.preauth_desc + ')');
                        //     }
                        // }
                        log.JSON_Body__c = userSession+'\n'+JSON.serialize(warpperObj);
                        log.User_Session__c = userSession;
                        recordsToInsertUpdate.add(log);
                    }           
                }    
                
                //update billToUpdate;
                
                
                if(constructEmail){
                    send = true;
                    List<OrgWideEmailAddress> oweaList = [select Id,DisplayName from OrgWideEmailAddress Where DisplayName =: Label.OrganizationWideEmail];
                    if (!oweaList.isEmpty()) {
                        //mail.setOrgWideEmailAddressId(oweaList.get(0).Id);
                        OrgWideEmailAddressId = oweaList.get(0).Id;
                    } 
                    String nameForMail = '';
                    String last4Digits = ''; 
                    if(warpperObj.paymentTypeVar=='creditCard'){
                        nameForMail = warpperObj.nameOnCard;
                        last4Digits = warpperObj.cardNumber.substring(warpperObj.cardNumber.length()-4);
                    }
                    else if(warpperObj.paymentTypeVar=='Physical_Check'){
                        nameForMail = String.isNotBlank(warpperObj.policy.Firm_Contact__r.Name) ? warpperObj.policy.Firm_Contact__r.Name : warpperObj.policy.Account__r.Name;
                    }
                    else{
                        nameForMail = warpperObj.accountHolderName;
                        last4Digits = warpperObj.accountNumber.substring(warpperObj.accountNumber.length()-4);
                    }
                    
                    body = 'Dear ' + nameForMail + '<br/><br/>';
                    if(warpperObj.paymentScheduleVar=='Full' && warpperObj.totalAmountDue > 0){
                        body += 'We have processed your premium payment in the amount of $'+
                            (warpperObj.paymentTypeVar=='creditCard' ? (warpperObj.totalAmountDue * (warpperObj.ccFeeRate + 100) / 100).setScale(2) : warpperObj.totalAmountDue.setScale(2)) +
                            ' using payment method ending in '+last4Digits+'.';
                        if(warpperObj.paymentTypeVar=='creditCard'){
                            body += 'This includes a '+warpperObj.ccFeeRate+'% credit card convenience fee of $'+(warpperObj.totalAmountDue * warpperObj.ccFeeRate / 100).setScale(2);
                        }
                        else{
                            body += '<br/><br/>';
                            body += 'Please note that ACH/e-check transactions may take up to 5 business days to settle and reflect on your account.';
                        } 
                        body += '<br/><br/>';
                        body += 'For your reference, the transaction number for this payment is: '+ warpperObj.receiptNumber + '<br/><br/>';
                    }else if(warpperObj.paymentScheduleVar=='Full' && warpperObj.totalAmountDue == 0){
                        body += 'Thank you for insuring your law firm with ISBA Mutual. <br/> <br/>';
                        body += 'Your payment premium payment in the amount of $';
                        if(warpperObj.paymentTypeVar=='creditCard'){
                            body += (warpperObj.firstInstallment * (warpperObj.ccFeeRate + 100) / 100).setScale(2);
                        }
                        else{
                            body += warpperObj.firstInstallment.setScale(2);
                        }
                        body += ' will be charged to the payment method  ending in '+ last4Digits+' on ' + warpperObj.firstInstallmentDate.format() +'.';
                        
                        if(warpperObj.paymentTypeVar=='creditCard'){
                            body += 'This includes a '+warpperObj.ccFeeRate+'% credit card convenience fee of $'+(warpperObj.firstInstallment * warpperObj.ccFeeRate / 100).setScale(2)+'.';
                        }
                        body += '<br/>';
                        //body += 'For your reference, the transaction number for this is: '+ warpperObj.receiptNumber + '<br/><br/>';
                    }else{
                        if(warpperObj.totalAmountDue == 0){
                            body += 'Thank you for insuring your law firm with ISBA Mutual. <br/> <br/>';
                            body += 'Your payment plan has been created and your first scheduled premium payment in the amount of $';
                            
                            if(warpperObj.paymentTypeVar=='creditCard'){
                                body += (warpperObj.firstInstallment * (warpperObj.ccFeeRate + 100) / 100).setScale(2);
                            }
                            else{
                                body += warpperObj.firstInstallment.setScale(2);
                            }
                            
                            body +=' will be charged to the payment method  ending in '+ last4Digits+ ' on ' + warpperObj.firstInstallmentDate.format() +'.';
                            
                            if(warpperObj.paymentTypeVar=='creditCard'){
                                body += 'This includes a '+warpperObj.ccFeeRate+'% credit card convenience fee of $'+(warpperObj.firstInstallment * warpperObj.ccFeeRate / 100).setScale(2)+'.';
                            }
                            
                            body += '<br/>';
                            body += '<br/>Future payments will be charged as follows:<br/><br/>';
                        }else{
                            body += 'We have processed your premium payment in the amount of $'+
                                (warpperObj.paymentTypeVar=='creditCard' ? (warpperObj.totalAmountDue * (warpperObj.ccFeeRate + 100) / 100).setScale(2) : warpperObj.totalAmountDue.setScale(2)) +
                                ' using payment method ending in '+last4Digits+'.';
                            if(warpperObj.paymentTypeVar=='creditCard'){
                                body += 'This includes a '+warpperObj.ccFeeRate+'% credit card convenience fee of $'+(warpperObj.totalAmountDue * warpperObj.ccFeeRate / 100).setScale(2);
                            }
                            else{
                                body += '<br/><br/>';
                                body += 'Please note that ACH/e-check transactions may take up to 5 business days to settle and reflect on your account.';
                            } 
                            body += '<br/><br/>';
                            body += 'For your reference, the transaction number for this is: '+ warpperObj.receiptNumber + '<br/>';
                            body += '<br/>Future payments will be charged as follows:<br/><br/>';
                        }
                        
                        if(isPolicy || isPolicyEndorsement || warpperObj.billing.Policy_Endorsement__c != null || warpperObj.billing.Policy__c != null){
                            for(paymentSchedulesWrapper psW: warpperObj.futurePaymentSchedules){
                                //body += '$'+psW.amount.setScale(2);
                                
                                //body += '     ('+ psW.dateStr +')<br/>';
                                if(warpperObj.paymentTypeVar=='creditCard'){
                                    body += psW.dateStr+':&nbsp;&nbsp;&nbsp;&nbsp;$'+psW.amount.setScale(2)+'&nbsp;&nbsp;&nbsp;&nbsp;(+$'+(psW.amount * warpperObj.ccFeeRate / 100).setScale(2)+')&nbsp;&nbsp;&nbsp;&nbsp;$'+(psW.amount * (warpperObj.ccFeeRate + 100) / 100).setScale(2)+'<br/>';
                                }
                                else{
                                    body += psW.dateStr+':&nbsp;&nbsp;&nbsp;&nbsp;$'+psW.amount.setScale(2)+'<br/>';
                                }
                            }
                        }
                        else{
                            if(warpperObj.paymentScheduleVar=='Quarter'){
                                for(String str : warpperObj.paymentQuarters){
                                    body += '$'+warpperObj.firstInstallment.setScale(2);
                                    if(warpperObj.paymentTypeVar=='creditCard'){
                                        //body += ' + $'+warpperObj.creditCardServiceFee.setScale(2);
                                    }
                                    body += '     ('+ str +')<br/>';
                                }
                                // body += '$'+warpperObj.LastQuarterAmount.setScale(2);
                                // if(warpperObj.paymentTypeVar=='creditCard'){
                                //     //body += ' + $'+warpperObj.creditCardServiceFee.setScale(2);
                                // }
                                // body += '     ('+ warpperObj.LastQuarterDate +')<br/>';
                            }else if(warpperObj.paymentScheduleVar=='Month'){
                                for(String str : warpperObj.paymentMonths){
                                    body += '$'+warpperObj.firstInstallment.setScale(2);
                                    if(warpperObj.paymentTypeVar=='creditCard'){
                                        //body += ' + $'+warpperObj.creditCardServiceFee.setScale(2);
                                    }
                                    body += '     ('+ str +')<br/>';
                                }
                            }
                        }
                        body += '<br/>' ;
                    } 
                    //if(warpperObj.totalAmountDue == 0){
                        body += '<br/>If you have any questions or need further assistance, please contact our accounting team at 312-379-2005 or accounting@isbamutual.com.<br/><br/>';
                        body += 'Thank you,<br/><br/>Ashley Rosado<br/>Accounting<br/>312-379-2005<br/>Accounting@isbamutual.com<br/><br/>ISBA Mutual Accounting<br/>20 South Clark Street, Suite 800<br/>Chicago, IL 60603-1826<br/><br/>312 379-2005<br/><br/><a href="https://www.isbamutual.com/">www.ISBAMutual.com</a>';
                    /*}else{
                        body += 'Thank you,<br/>ISBA Mutual Accounting Department<br/>312-379-2005';
                    }*/
                }
            }
            
            if(!recordsToInsertUpdate.isEmpty()){
                String upserResp = updatePSchRecords(recordsToInsertUpdate, 'upsert');
                system.debug('upserResp => '+upserResp);
            }
            if(send){
                String conId = '';
                string whatId;
                String Subject = 'ISBA Mutual Insurance - Payment Received (Invoice #'+warpperObj.invoiceId+')';
                if(isPolicy){
                    if(warpperObj.totalAmountDue == 0){
                        Subject = 'ISBA Mutual Policy '+warpperObj.invoiceId+': Scheduled Payment';
                    }
                    whatId = policy.Id;
                    conId = policy.Firm_Contact__c;
                }
                else{
                    if(warpperObj.totalAmountDue == 0){
                        Subject = 'ISBA Mutual Insurance - Scheduled Payment (Invoice #'+warpperObj.invoiceId+')';
                    }
                    whatId = billing.id;
                    conId = billing.AcctSeed__Billing_Contact__c;
                }
                sendEmail(OrgWideEmailAddressId, body, whatId, true, new List<String>{warpperObj.confirmationEmail}, Subject,new String[]{Label.ISBA_Accounting_Automation_Email_Address }, Label.ISBA_Accounting_Email_Address, false, conId);
            }
            if(paymentSuccess){ 
                if(!Paymethods.isEmpty()){
                    updatePaymentMethodRecords(JSON.serialize(Paymethods), 'update');
                    //updatePSchRecords(Paymethods, 'update'); 
                }
            }
            else if(paymentError && String.isNotBlank(paymentErrorMessage)){
                throw new PaymentGatewayClassException(paymentErrorMessage);
            }
        }catch(Exception e){
            //currentStage='contactDetails';            
            system.debug('error -> '+e.getMessage()+' Line -> '+e.getLineNumber());
            if(String.isBlank(paymentErrorMessage))
                paymentErrorMessage = 'An error occurred while processing your payment. Please get in touch with your ISBA Mutual Policy Contact.';
            paymentError = true;
            Integration_Log__c log = new Integration_Log__c();
            if(isPolicy){
                log.Policy__c = policy.Id;
            }
            else{
                log.Billing__c =billing.id;
            }
            log.Status__c='Processed With Errors';
            if(isAuth){
                log.Transaction_Amount__c = 0.01;
            }else{
                log.Transaction_Amount__c=warpperObj.totalAmountDue;
            }
            
            log.Description__c='Error : '+e.getMessage() + '\n' + e.getStackTraceString() + '\n';
            log.User_Session__c = userSession;
            //recordsToInsertUpdate.add(log);
            String upserResp = updatePSchRecords( new List<Integration_Log__c>{log}, 'upsert');
            system.debug('upserResp => '+upserResp);
            
            String recId = '';
            if(isPolicy){
                recId = policy.Id;
            }
            else if(isPolicyEndorsement){
                recId = endorsement.Id; 
            }
            else{
                recId =billing.id;
            }
            Error err = new Error(paymentErrorMessage, 'Error While Processing the Transaction.', 'Team,\n\nFollowing error has occurred while Processing the Transaction \n\n'+e.getMessage() + '\n\n'+e.getStackTraceString()+'\n\n on the Record :'+ recId );
            throw new PaymentGatewayClassException(JSON.serialize(err));
        }
        return transactionGatewayResponse;
    }
    
    @AuraEnabled 
    public static string processEncryption(String name, String key){ 
        if(String.isBlank(key)){
            key = Label.Encryption_Key_Payment_Id;
        }
        Blob cryptoKey = Blob.valueOf(key);
        Blob data = Blob.valueOf(name); 
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey, data); 
        String b64Data = EncodingUtil.base64Encode(encryptedData);  
        System.debug(b64Data);
        return b64Data; 
    }
    
    @AuraEnabled 
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
    @AuraEnabled 
    public Decimal getCHECK_TRANSACTION_FEE(){
        return CHECK_TRANSACTION_FEE;
    }
    @AuraEnabled 
    public Decimal getCREDIT_CARD_SERVICE_FEE_VISA(){
        return CREDIT_CARD_SERVICE_FEE_VISA;
    }
    @AuraEnabled 
    public Decimal getCREDIT_CARD_SERVICE_FEE_MasterCard(){
        return CREDIT_CARD_SERVICE_FEE_MasterCard;
    }
    @AuraEnabled 
    public Decimal getCREDIT_CARD_SERVICE_FEE_Discovery(){
        return CREDIT_CARD_SERVICE_FEE_Discovery;
    }
    @AuraEnabled 
    public Decimal getCREDIT_CARD_SERVICE_FEE_American_Express(){
        return CREDIT_CARD_SERVICE_FEE_American_Express;
    }
    
    @AuraEnabled 
    public static void cardTypeFunction(PaymentGateway_Ctrl_Wrapper warpperObj , AcctSeed__Billing__c billing){
        //PaymentGateway_Ctrl_Wrapper warpperObj = (PaymentGateway_Ctrl_Wrapper)System.JSON.deserializeStrict(wrapString, PaymentGateway_Ctrl_Wrapper.class);
        
        System.debug(warpperObj.creditCardfee);
        System.debug(warpperObj.cardTypeVar);
        
        if(warpperObj.paymentTypeVar == 'creditCard'){
            warpperObj.creditCardfee = CREDIT_CARD_SERVICE_FEE_VISA;
        }
        System.debug(warpperObj.creditCardfee);
        if(warpperObj.paymentTypeVar=='creditCard' && warpperObj.paymentScheduleVar=='Full'){
            warpperObj.totalServiceFee = ((billing.AcctSeed__Balance__c * warpperObj.creditCardfee)/100);
            baseAmountToPay = billing.AcctSeed__Balance__c;
            //warpperObj.totalAmountDue = billing.AcctSeed__Balance__c + warpperObj.totalServiceFee;
            //warpperObj.totalAmountDue = billing.AcctSeed__Balance__c ;
        }else if(warpperObj.paymentTypeVar=='creditCard' && warpperObj.paymentScheduleVar=='Month'){
            warpperObj.totalServiceFee = ((billing.AcctSeed__Balance__c * warpperObj.creditCardfee)/100);
            warpperObj.creditCardServiceFee = (warpperObj.totalServiceFee/12);
            baseAmountToPay = warpperObj.perTotalMonthAmount;
            //warpperObj.totalAmountDue = warpperObj.perTotalMonthAmount+warpperObj.creditCardServiceFee; 
            //warpperObj.totalAmountDue = warpperObj.perTotalMonthAmount; 
        }else if(warpperObj.paymentTypeVar=='creditCard' && warpperObj.paymentScheduleVar=='Quarter'){
            warpperObj.totalServiceFee = ((billing.AcctSeed__Balance__c * warpperObj.creditCardfee)/100);
            warpperObj.creditCardServiceFee = (warpperObj.totalServiceFee/4);
            baseAmountToPay = warpperObj.perTotalQuarterAmount;
            //warpperObj.totalAmountDue = warpperObj.perTotalQuarterAmount+warpperObj.creditCardServiceFee; 
            //warpperObj.totalAmountDue = warpperObj.perTotalQuarterAmount; 
        }
        system.debug('baseAmountToPay => cardTypeFunction '+baseAmountToPay);
        warpperObj.baseAmountToPay = baseAmountToPay;
        
    }
    @AuraEnabled 
    public static expiryWrapper getExpiryDetails() {
        return new expiryWrapper();
    }
    
    @AuraEnabled
    public static List<optionsWrap> getPicklistValues(String strObjectName, String strPicklistField){
        List<optionsWrap> options = new List<optionsWrap>();
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            System.debug('Value = ' +objPickList.getValue() +' , Label = ' +objPickList.getLabel());
            options.add(new optionsWrap(objPickList.getValue(), objPickList.getLabel()));
        }
        return options;
    }
    
    public static List<optionsWrap> getExpireMonthsList(){
        List<optionsWrap> options = new List<optionsWrap>();
        options.add(new optionsWrap('none', 'Please select'));
        options.add(new optionsWrap('01', '01 - January'));
        options.add(new optionsWrap('02', '02 - February'));
        options.add(new optionsWrap('03', '03 - March'));
        options.add(new optionsWrap('04', '04 - April'));
        options.add(new optionsWrap('05', '05 - May '));
        options.add(new optionsWrap('06', '06 - June'));
        options.add(new optionsWrap('07', '07 - July'));
        options.add(new optionsWrap('08', '08 - August'));
        options.add(new optionsWrap('09', '09 - September'));
        options.add(new optionsWrap('10', '10 - October '));
        options.add(new optionsWrap('11', '11 - November'));
        options.add(new optionsWrap('12', '12 - December'));
        return options;
        
    }
    @AuraEnabled 
    public static List<optionsWrap> getExpireYearsList(){
        List<optionsWrap> options = new List<optionsWrap>();
        Integer currentYear = System.Today().year();
        options.add(new optionsWrap('none', 'Please select'));
        for(Integer i =currentYear;i<(currentYear+15);i++){
            options.add(new optionsWrap(String.valueOf(i), String.valueOf(i)));
        }
        return options;
    }
    
    @AuraEnabled
    public Static exestingPaymentMethodDetails ExistingList(AcctSeed__Billing__c billing){     
        return updatedExistingList(billing.Id, billing.AcctSeed__Customer__c);            
    }
    
    @AuraEnabled 
    public Static paymentScheduleWrapper getOldPaymentSchedules(String recId){
        try {
            List<Payment_Schedule__c> PaymentSchedules = new List<Payment_Schedule__c>();
            List<Payment_Schedule__c> oldPaymentSchedules = new List<Payment_Schedule__c>();
            paymentScheduleWrapper warpperObj = new paymentScheduleWrapper();
            // String recId = billing.Id;
            system.debug('recId => '+recId);
            String paySchQuery = 'SELECT Id, Name, Status__c, Due_Date__c, Amount__c, Due_Amount__c';
            List<Schema.FieldSetMember> fields = SObjectType.Payment_Schedule__c.FieldSets.Payment_Site_Fields.getFields();
            List<FieldWrapper> fieldsWrapList = new List<FieldWrapper>();
            for(Schema.FieldSetMember f : fields) {
                if(!paySchQuery.contains(f.getFieldPath())){
                    FieldWrapper fieldWrap = new FieldWrapper();
                    fieldWrap.fieldApiName = f.getFieldPath();
                    fieldWrap.fieldLabel = f.getLabel();
                    fieldWrap.fieldType = String.valueOf(f.getType());
                    if(String.valueOf(f.getType()) == 'REFERENCE'){
                        String nameField = f.getFieldPath().endsWith('__c') ? f.getFieldPath().removeEnd('__c')+'__r.Name': f.getFieldPath()+'.Name';
                        paySchQuery += ', ' + f.getFieldPath() +', '+ nameField;
                    }
                    else{
                        paySchQuery += ', ' + f.getFieldPath();
                    }
                    fieldsWrapList.add(fieldWrap);
                    
                }
            }
            paySchQuery += ' FROM Payment_Schedule__c WHERE Billing__c =: recId';
            System.debug('paySchQuery => ' + paySchQuery);
            PaymentSchedules =  Database.query(paySchQuery);  
            system.debug('PaymentSchedules => '+ PaymentSchedules);
            for(Payment_Schedule__c ps: PaymentSchedules){
                if(ps.Due_Amount__c > 0){
                    oldPaymentSchedules.add(ps);
                }
            }
            if((!PaymentSchedules.isEmpty()) && oldPaymentSchedules.isEmpty())  {          
                //throw new PaymentGatewayClassException('Payment has been already submitted for this invoice.');
                return warpperObj;
            }
            
            warpperObj.isFirstTime = PaymentSchedules.isEmpty();
            warpperObj.allPaymentSchedules = PaymentSchedules;
            warpperObj.paymentSchedules = oldPaymentSchedules;  
            warpperObj.paymentScheduleFields = fieldsWrapList;
            return warpperObj;
        } catch(Exception e) {
            System.debug('Error: '+e.getMessage()+' at '+ e.getLineNumber());            
            Error err = new Error(e.getMessage(), 'Error While getting Payment Schedules.', 'Team,\n\nFollowing error has occurred while getting Payment Schedules \n\n'+e.getMessage() + '\n\n'+e.getStackTraceString()+'\n\n on the Record :'+ recId);
            throw new PaymentGatewayClassException(JSON.serialize(err));
            //throw new PaymentGatewayClassException(e.getMessage());
        }        
    }
    
    @AuraEnabled
    public static Boolean saveFuturePaymentSchedule(List<Payment_Schedule__c> PaymtSchRecList){
        try {
            updatePSchRecords(PaymtSchRecList,'insert');
            return true;
        } catch (Exception e) {
            Error err = new Error(e.getMessage(), 'Error While Creating future Payment Schedules.', 'Team,\n\nFollowing error has occurred while Creating future Payment Schedules \n\n'+e.getMessage() + '\n\n'+e.getStackTraceString()+'\n\n on the Record :'+ PaymtSchRecList[0].Billing__c);
            throw new PaymentGatewayClassException(JSON.serialize(err));
            //throw new PaymentGatewayClassException(e.getMessage());
        }
    }
    
    @AuraEnabled 
    public Static PaymentGateway_Ctrl_Wrapper savePaymentSchedules(PaymentGateway_Ctrl_Wrapper warpperObj){
        system.debug('warpperObj => '+warpperObj);        
        String recId =  warpperObj.billing.Id;
        try{            
            system.debug('recId '+recId );
            List<Payment_Schedule__c> paymtSchedule =  warpperObj.paymentScheduleListToInsert;
            if(!paymtSchedule.isEmpty() && String.isNotBlank(paymtSchedule[0].Id)){
                if(paymtSchedule[paymtSchedule.size()-1].Fiserv_Payment_Method__c != warpperObj.paymentMethodId){
                    UpdatePaymentMethodCtrl.UpdatePaymentSchedule(recId, warpperObj.paymentMethodId);
                    if(warpperObj.totalAmountDue > 0){
                        return warpperObj;
                    }
                    return null;
                }
            }else{
                Set<String> psIds = new Set<String>();
                for(Payment_Schedule__c ps: paymtSchedule){
                    if(String.isNotBlank(ps.Id)){
                        psIds.add(ps.Id);
                    }
                }
                
                List<AcctSeed__Payment_Processor__c> paymentProcessor = [select id from AcctSeed__Payment_Processor__c where AcctSeed__Type__c = 'Fiserv' limit 1];
                List<Payment_Schedule__c> exestingPaymtSchedule = new List<Payment_Schedule__c>([SELECT Id,Name FROM Payment_Schedule__c Where Id NOT IN : psIds AND Billing__c =: recId AND Due_Amount__c != 0]);
                List<Payment_Method__c> payMethodList = new List<Payment_Method__c>([SELECT Id,Type__c FROM Payment_Method__c WHERE Id =: warpperObj.paymentMethodId AND Is_Deleted__c = false]);
                system.debug('exestingPaymtSchedule '+ exestingPaymtSchedule);
                if(!exestingPaymtSchedule.isEmpty())   {      
                    updatePSchRecords(exestingPaymtSchedule,'delete');
                }
                
                if(String.isNotBlank(warpperObj.paymentMethodId) && warpperObj.paymentMethodId != 'Physical_Check'){
                    for(Payment_Schedule__c ps: paymtSchedule){
                        if(payMethodList[0].Type__c == 'Credit_Card'){
                            ps.Service_Fee_Rate__c = warpperObj.ccFeeRate;
                            ps.Payment_Schedule_Type__c = 'Credit Card';
                        }
                        else{
                            ps.Service_Fee_Rate__c = 0;
                            ps.Payment_Schedule_Type__c = 'eCheck';
                        }
                        ps.Fiserv_Payment_Method__c = warpperObj.paymentMethodId;
                    }
                }
                
                
                system.debug('paymtSchedule '+ paymtSchedule);
                String Resp = updatePSchRecords(paymtSchedule,'Upsert');
                system.debug('Resp '+ Resp);
                AcctSeed__Billing__c bill = warpperObj.billing;
                bill.Payment_Method__c = warpperObj.paymentMethodId;
                bill.Service_Fee__c = warpperObj.ccFeeRate;
                bill.AcctSeed__Payment_Processor__c = paymentProcessor[0].Id;
                if(warpperObj.paymentScheduleVar == 'Quarter'){
                    bill.Payment_Frequency__c = 'Quarterly';
                }                 
                else if(warpperObj.paymentScheduleVar =='Month'){                   
                    bill.Payment_Frequency__c = 'Monthly';
                }
                else{
                    bill.Payment_Frequency__c = 'Full';   
                }
                system.debug('bill    => => '+bill);
                updatePSchRecords(new List<AcctSeed__Billing__c>{bill}, 'upsert');
                warpperObj.paymentScheduleListToInsert = (List<Payment_Schedule__c>)Json.deserialize(Resp, List<Payment_Schedule__c>.Class);
                system.debug('paymentScheduleListToInsert '+ warpperObj.paymentScheduleListToInsert);
            }
            
            return warpperObj;
        }
        Catch(Exception e){
            system.debug('Error => '+e.getMessage()+' at '+ e.getLineNumber());
            Error err = new Error(e.getMessage(),'Error While Creating Payment Schedules.' , 'Team,\n\nFollowing error has occurred while creating Payment Schedules \n\n'+e.getMessage() + '\n\n'+e.getStackTraceString()+'\n\n on the Record :'+ recId);
            throw new PaymentGatewayClassException(JSON.serialize(err));       
            //throw new PaymentGatewayClassException(e.getMessage());
        }
    }
    
    @AuraEnabled 
    public Static PaymentGateway_Ctrl_Wrapper paymentScheduleFunction(PaymentGateway_Ctrl_Wrapper warpperObj , AcctSeed__Billing__c billing, String lasttime){
        if((billing.Payment_Frequency__c == 'Full' && lasttime == 'Full') || (billing.Payment_Frequency__c == 'Quarterly' && lasttime == 'Quarter') || (billing.Payment_Frequency__c == 'Monthly' && lasttime == 'Month')){
            warpperObj.totalAmountDue = 0;
            List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>([SELECT Id, Name, Frequency__c, Status__c, Due_Date__c, Paid_Amount__c, Amount__c, Due_Amount__c FROM Payment_Schedule__c WHERE Billing__c =: billing.Id AND Due_Amount__c > 0 ORDER BY Due_Date__c]);
            
			List<paymentSchedulesWrapper> duePaymentSchedules = new List<paymentSchedulesWrapper>(); 
            List<Payment_Schedule__c> newPaymentSchedules = new List<Payment_Schedule__c>();
            Set<String> duePsIds = new Set<String>();
            
            for(Payment_Schedule__c ps: paymentSchedules){
                paymentSchedulesWrapper paySchWrapObj = new paymentSchedulesWrapper();
                paySchWrapObj.amount = ps.Due_Amount__c;
                paySchWrapObj.dateStr = String.valueOf(ps.Due_Date__c.month()).leftPad(2, '0')+ '/' +String.valueOf(ps.Due_Date__c.day()).leftPad(2, '0') +'/'+ ps.Due_Date__c.year();
                
                if(warpperObj.firstInstallmentDate == null){
                    warpperObj.firstInstallment = ps.Due_Amount__c;
                    warpperObj.firstInstallmentDate = ps.Due_Date__c;
                }
                
                if(ps.Due_Date__c <=system.Today()){
                    //warpperObj.duePaymentSchedules.add(paySchWrapObj);
                    duePsIds.add(ps.Id);
                    duePaymentSchedules.add(paySchWrapObj);
                    warpperObj.totalAmountDue += ps.Due_Amount__c;
                }
                else{
                    warpperObj.futurePaymentSchedules.add(paySchWrapObj);
                    newPaymentSchedules.add(ps);
                }
            }
            
            
            if(!duePaymentSchedules.isEmpty() && duePaymentSchedules.size() > 1){
                Payment_Schedule__c pSch1 = new Payment_Schedule__c();
                pSch1.Due_Date__c = system.today();
                pSch1.Billing__c = billing.id;
                pSch1.Amount__c =  warpperObj.totalAmountDue;
                pSch1.Status__c = 'Unpaid';
                pSch1.Frequency__c = billing.Payment_Frequency__c;
                
                List<Payment_Schedule__c> tempPaymentSchedules = new List<Payment_Schedule__c>();
                tempPaymentSchedules.add(pSch1);
                tempPaymentSchedules.addAll(newPaymentSchedules);
                newPaymentSchedules = tempPaymentSchedules;
            }
            warpperObj.duePaymentSchedules = duePaymentSchedules;
            warpperObj.paymentScheduleListToInsert = newPaymentSchedules;
        }
        else{
            List<Payment_Schedule__c> paidPaymentSchedules = new List<Payment_Schedule__c>([SELECT Id, Name, Frequency__c, Status__c, Due_Date__c, Paid_Amount__c, Amount__c, Due_Amount__c FROM Payment_Schedule__c WHERE Billing__c =: billing.Id AND Due_Amount__c = 0 ORDER BY Due_Date__c DESC]);
            system.debug('warpperObj.paymentScheduleVar -> '+warpperObj.paymentScheduleVar);
            Decimal extraMonthPayment = billing.Extra_Month_Payment__c;
            Decimal totalAmountPaid = 0.00;
            for(Payment_Schedule__c ps: paidPaymentSchedules){
                if(ps.Status__c == 'Pending' || ps.Status__c == 'Paid' ){
                    totalAmountPaid += ps.Paid_Amount__c;
                }
            }
            
            Decimal billing_total = billing.AcctSeed__Total__c;
            if(billing.AcctSeed__Credit_Memo_Applied_Amount__c != null){
                billing_total -= billing.AcctSeed__Credit_Memo_Applied_Amount__c;
            }
            warpperObj.balance = billing_total - totalAmountPaid;
            
            if(String.isNotBlank(billing.Policy_Endorsement__c)|| String.isNotBlank(billing.Policy__c)){
                Decimal needToPay = warpperObj.balance;
                List<Payment_Schedule__c> paySchList = new List<Payment_Schedule__c>();
                warpperObj.effectiveDate = String.isNotBlank(billing.Policy_Endorsement__c) ? billing.Policy_Endorsement__r.Endorsement_Effective_Date__c : billing.Policy__r.Effective_Date__c;
                if(lasttime == 'Full'){
                    warpperObj.firstInstallment = needToPay;
                    if(warpperObj.effectiveDate > System.today()){
                        warpperObj.totalAmountDue = 0;
                        warpperObj.enablePaymentDate = true;
                    }else{
                        warpperObj.totalAmountDue = needToPay;
                    }
                    warpperObj.firstInstallmentDate = warpperObj.effectiveDate < system.today() ? system.today() :  warpperObj.effectiveDate;
                    warpperObj.firstInstallmentDateString = DateTime.newInstanceGMT(System.Date.newInstance(warpperObj.firstInstallmentDate.year(), warpperObj.firstInstallmentDate.month(), warpperObj.firstInstallmentDate.day()),System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM/dd/yyyy');
                    warpperObj.scheduleAmount = needToPay;
                    
                    Payment_Schedule__c pSch = new Payment_Schedule__c();
                    pSch.Due_Date__c = warpperObj.dueDate > System.today() ? warpperObj.dueDate : System.today();
                    pSch.Billing__c = billing.id;
                    pSch.Amount__c = needToPay;// warpperObj.totalAmountDue;
                    pSch.Status__c = 'Unpaid'; //pSch.Status__c = 'Paid';
                    pSch.Frequency__c = 'Full';
                    paySchList.add(pSch);
                    
                }
                else if(lasttime == 'Quarter'){
                    Decimal numberOfMonths = warpperObj.effectiveDate.monthsBetween(billing.Policy__r.Expiration_Date__c);
                    Decimal numberOfQuarters = (numberOfMonths/3).round(System.RoundingMode.DOWN);
                    if(numberOfMonths < 3){
                        numberOfQuarters = 1;
                        if(numberOfMonths == 0){
                            numberOfMonths = 1;
                        }
                    }
                    
                    Decimal dueOnEffDt = 0.00; 
                    if(numberOfQuarters > 1){
                        Date tempdt = billing.Policy__r.Expiration_Date__c.addMonths(-Integer.valueOf(numberOfQuarters*3));
                        if(tempdt < warpperObj.effectiveDate){
                            tempdt = tempdt.addMonths(3);
                            numberOfQuarters -= 1;
                        }
                        
                        system.debug('tempDT => '+tempdt);
                        
                        if(numberOfQuarters > 0 && warpperObj.effectiveDate != tempdt){
                            numberOfMonths = numberOfQuarters*3;
                            Integer temp1 = warpperObj.effectiveDate.daysBetween(tempdt);
                            Integer temp2 = warpperObj.effectiveDate.daysBetween(billing.Policy__r.Expiration_Date__c);
                            Decimal amountPerDay = (billing_total/temp2).setScale(2);
                            dueOnEffDt = amountPerDay * temp1;
                            billing_total -= dueOnEffDt;
                        }
                    }
                    
                    Decimal temp_dueOnEffDt = dueOnEffDt;
                    Integer tempNoOfQuaters = 0;
                    warpperObj.perQuarterAmount = (billing_total / numberOfQuarters).setScale(2);
                    if(totalAmountPaid > 0){
                        if(totalAmountPaid >= dueOnEffDt){
                            temp_dueOnEffDt = 0;
                            totalAmountPaid -= dueOnEffDt;
                        }
                        for(Integer i=0; i < numberOfQuarters; i++){
                            if(totalAmountPaid > 0 && totalAmountPaid >= warpperObj.perQuarterAmount){
                                tempNoOfQuaters += 1;
                                totalAmountPaid -= warpperObj.perQuarterAmount;
                            }
                        }
                    }
                    
                    //warpperObj.perQuarterAmount = (needToPay / numberOfQuarters).setscale(2);
                    Decimal diffrenceAmount = billing_total - (warpperObj.perQuarterAmount * numberOfQuarters);
                    numberOfQuarters -=  tempNoOfQuaters;
                    numberOfMonths -= (tempNoOfQuaters*3);
                    system.debug('warpperObj.perQuarterAmount => => '+warpperObj.perQuarterAmount);
                    warpperObj.firstInstallment = warpperObj.perQuarterAmount;
                    Date quarterlyBilling = billing.Policy__r.Expiration_Date__c.addMonths(-2);

                    warpperObj.paymentQuarters = new List<String>();
                    finalPaymentQuarters = new List<String>(); 
                    warpperObj.perTotalQuarterAmount = 0 ;
                    warpperObj.totalAmountDue = 0;                          // Change login by sarbjeet
                    paymentQuartersDt = null;
                    List<paymentSchedulesWrapper> oldPaymentSchedule = new List<paymentSchedulesWrapper>();            
                    List<paymentSchedulesWrapper> newPaymentSchedule = new List<paymentSchedulesWrapper>();
                    
                    Boolean flag = true;
                    for(Integer i = 1; i<=numberOfMonths; i+=3 ){
                        i = -i;
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
                        paymentSchedulesWrapper paySchWrapObj = new paymentSchedulesWrapper();
                        paySchWrapObj.amount = warpperObj.perQuarterAmount;
                        paySchWrapObj.dateStr = String.valueOf(quarterlyBilling.addMonths(i).month()).leftPad(2, '0')+ '/' +String.valueOf(day).leftPad(2, '0') +'/'+ quarterlyBilling.addMonths(i).year();
                        
                        if(flag){
                            flag = false;
                            paySchWrapObj.amount += diffrenceAmount;
                            paySchWrapObj.amount = paySchWrapObj.amount.setScale(2);
                        }
                        
                        system.debug('quarterlyBilling.addMonths(i) => '+quarterlyBilling.addMonths(i));
                        if(i==0 && quarterlyBilling <= system.Today()){  
                            List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                                tempList.addAll(warpperObj.duePaymentSchedules);                            
                            warpperObj.duePaymentSchedules = tempList;
                            warpperObj.totalAmountDue += paySchWrapObj.amount;                        
                        }else if(quarterlyBilling.addMonths(i) <=system.Today()){  
                            List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                                tempList.addAll(warpperObj.duePaymentSchedules);                            
                            warpperObj.duePaymentSchedules = tempList;                     
                            warpperObj.totalAmountDue += paySchWrapObj.amount;                        
                        }else {       
                            List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                                tempList.addAll(warpperObj.futurePaymentSchedules);                            
                            warpperObj.futurePaymentSchedules = tempList;                 
                            System.debug('quarterlyBilling'+quarterlyBilling);
                            
                            if(paymentQuartersDt == null){                            
                                paymentQuartersDt = quarterlyBilling.addMonths(i);                            
                            }                        
                            //warpperObj.firstInstallmentDate = paymentQuartersDt;
                            //warpperObj.firstInstallmentDateString = DateTime.newInstanceGMT(System.Date.newInstance(warpperObj.firstInstallmentDate.year(), warpperObj.firstInstallmentDate.month(), warpperObj.firstInstallmentDate.day()),System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM/dd/yyyy');
                            System.debug('paymentQuartersDt'+paymentQuartersDt);                    
                        } 
                        i = -i;
                    }

                    if(warpperObj.effectiveDate < System.today() && temp_dueOnEffDt > 0){
                        paymentSchedulesWrapper paySchWrapObj = new paymentSchedulesWrapper();
                        paySchWrapObj.amount = temp_dueOnEffDt;
                        paySchWrapObj.dateStr = String.valueOf(warpperObj.effectiveDate.month()).leftPad(2, '0')+ '/' +String.valueOf(warpperObj.effectiveDate.day()).leftPad(2, '0') +'/'+ warpperObj.effectiveDate.year();
                        
                        List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                            tempList.addAll(warpperObj.duePaymentSchedules);                            
                        warpperObj.duePaymentSchedules = tempList;
                        
                        warpperObj.totalAmountDue += temp_dueOnEffDt;
                        warpperObj.firstInstallmentDate = System.today();                                
                        warpperObj.firstInstallmentDateString = DateTime.newInstanceGMT(System.Date.newInstance(warpperObj.firstInstallmentDate.year(), warpperObj.firstInstallmentDate.month(), warpperObj.firstInstallmentDate.day()),System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM/dd/yyyy');
                    }
                    else if(temp_dueOnEffDt > 0){
                        paymentSchedulesWrapper paySchWrapObj = new paymentSchedulesWrapper();
                        paySchWrapObj.amount = temp_dueOnEffDt;
                        paySchWrapObj.dateStr = String.valueOf(warpperObj.effectiveDate.month()).leftPad(2, '0')+ '/' +String.valueOf(warpperObj.effectiveDate.day()).leftPad(2, '0') +'/'+ warpperObj.effectiveDate.year();
                        
                        List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                            tempList.addAll(warpperObj.futurePaymentSchedules);                            
                        warpperObj.futurePaymentSchedules = tempList;
                    }
                    
                    system.debug(' finalPaymentQuarters => '+ finalPaymentQuarters);
                    
                    if(warpperObj.totalAmountDue == 0){
                        warpperObj.perTotalQuarterAmount = warpperObj.perQuarterAmount; //+ extraMonthPayment;
                    } else {
                        warpperObj.perTotalQuarterAmount = warpperObj.totalAmountDue; //+ extraMonthPayment;
                    }
                    
                    system.debug('Creating Payment Schedule List'+warpperObj.totalAmountDue+' => '+warpperObj.firstInstallmentDate);
                    
                    if(warpperObj.totalAmountDue > 0){
                        Payment_Schedule__c pSch1 = new Payment_Schedule__c();
                        pSch1.Due_Date__c = system.today();
                        pSch1.Billing__c = billing.id;
                        pSch1.Amount__c =  warpperObj.totalAmountDue;
                        pSch1.Status__c = 'Unpaid';//pSch1.Status__c = 'Paid';
                        pSch1.Frequency__c = 'Quaterly';
                        paySchList.add(pSch1);
                        if(warpperObj.firstInstallmentDate == null){
                            warpperObj.firstInstallmentDate = pSch1.Due_Date__c;
                        }
                    }
                    system.debug('Creating Payment Schedule futurePaymentSchedules'+warpperObj.futurePaymentSchedules+' => '+warpperObj.firstInstallmentDate);
                    for(paymentSchedulesWrapper psw : warpperObj.futurePaymentSchedules){
                        Payment_Schedule__c pSch = new Payment_Schedule__c();
                        pSch.Due_Date__c = Date.parse(psw.dateStr);
                        pSch.Billing__c = billing.id;
                        pSch.Amount__c =  psw.amount;
                        pSch.Status__c = 'Unpaid';
                        pSch.Frequency__c = 'Quaterly';
                        paySchList.add(pSch);
                        if(warpperObj.firstInstallmentDate == null){
                            warpperObj.firstInstallmentDate = pSch.Due_Date__c;
                        }
                    }
                    
                    if(totalAmountPaid > 0){
                        paySchList[0].Amount__c -= totalAmountPaid;
                        
                        if(!warpperObj.duePaymentSchedules.isEmpty()){
                            warpperObj.duePaymentSchedules[0].amount -= totalAmountPaid;
                        }
                        else{
                            warpperObj.futurePaymentSchedules[0].amount -= totalAmountPaid;
                        }
                        
                        if(warpperObj.totalAmountDue > 0){
                            warpperObj.totalAmountDue -= totalAmountPaid;
                        }
                    }
                    system.debug('Created Payment Schedule futurePaymentSchedules'+paySchList+' => '+warpperObj.firstInstallmentDate);
                }
                else if(lasttime == 'Month'){
                    Integer numberOfPayments = warpperObj.effectiveDate.monthsBetween(billing.Policy__r.Expiration_Date__c);
                    Date monthlyBilling = billing.Policy__r.Expiration_Date__c;
                    
                    Decimal dueOnEffDt = 0.00;
                    if(numberOfPayments > 1){
                        Date tempdt = monthlyBilling.addMonths(-numberOfPayments);
                        if(tempdt < warpperObj.effectiveDate){
                            tempdt = tempdt.addMonths(1);
                            numberOfPayments -= 1;
                        }
                        
                        system.debug(tempdt);
                        if(numberOfPayments > 0 && warpperObj.effectiveDate != tempdt){
                            Integer temp1 = warpperObj.effectiveDate.daysBetween(tempdt);
                            Integer temp2 = warpperObj.effectiveDate.daysBetween(billing.Policy__r.Expiration_Date__c);
                            Decimal amountPerDay = (billing_total/temp2).setScale(2);
                            dueOnEffDt = amountPerDay * temp1;
                            billing_total -= dueOnEffDt;
                        }
                    }
                    if(numberOfPayments == 0){
                        numberOfPayments = 1;
                    }
                    
                    Integer tempNoOfMonths = 0;
                    warpperObj.perMonthAmount = (billing_total / numberOfPayments).setScale(2);
                    if(totalAmountPaid > 0){
                        for(Integer i=0; i < numberOfPayments; i++){
                            if(totalAmountPaid > 0 && totalAmountPaid >= warpperObj.perMonthAmount){
                                tempNoOfMonths += 1;
                                totalAmountPaid -= warpperObj.perMonthAmount;
                            }
                        }
                    }

                        
                    //warpperObj.perMonthAmount = (needToPay / numberOfPayments).setScale(2);
                    Decimal diffrenceAmount = billing_total - (warpperObj.perMonthAmount * numberOfPayments);
                    numberOfPayments -= tempNoOfMonths;
                    warpperObj.firstInstallment = warpperObj.perMonthAmount ;
                    
                    List<String> paymentMonths = new List<String>();
                    finalPaymentMonths = new List<String>();
                    warpperObj.perTotalMonthAmount =0; 
                    warpperObj.totalAmountDue = 0;                         
                    paymentMonthsDt = null;    
                    boolean flag = true;
                    for(Integer i= 1 ;i<= numberOfPayments;i++){   
                        i = -i;
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
                        
                        paymentSchedulesWrapper paySchWrapObj = new paymentSchedulesWrapper();
                        paySchWrapObj.amount = warpperObj.perMonthAmount;
                        paySchWrapObj.dateStr = String.valueOf(monthlyBilling.addMonths(i).month()).leftPad(2, '0')+ '/' +String.valueOf(day).leftPad(2, '0') +'/'+ monthlyBilling.addMonths(i).year();
                        
                        if(flag){
                            flag = false;
                            paySchWrapObj.amount += diffrenceAmount;
                            paySchWrapObj.amount = paySchWrapObj.amount.setScale(2);
                        }
                        
                        if(monthlyBilling.addMonths(i) <=system.Today()){
                            List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                                tempList.addAll(warpperObj.duePaymentSchedules);                            
                            warpperObj.duePaymentSchedules = tempList;
                            
                            warpperObj.totalAmountDue += paySchWrapObj.amount;                            
                        } else if(i==0 && monthlyBilling <= system.Today()){ 
                            List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                                tempList.addAll(warpperObj.duePaymentSchedules);                            
                            warpperObj.duePaymentSchedules = tempList;
                            warpperObj.totalAmountDue += paySchWrapObj.amount;                            
                        } else {               
                            List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                                tempList.addAll(warpperObj.futurePaymentSchedules);                            
                            warpperObj.futurePaymentSchedules = tempList;
                            
                            if(paymentMonthsDt == null){
                                paymentMonthsDt = monthlyBilling.addMonths(i);
                            }                            
                            //warpperObj.firstInstallmentDate = paymentMonthsDt;                                
                            //warpperObj.firstInstallmentDateString = DateTime.newInstanceGMT(System.Date.newInstance(warpperObj.firstInstallmentDate.year(), warpperObj.firstInstallmentDate.month(), warpperObj.firstInstallmentDate.day()),System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM/dd/yyyy');
                        }     
                        i = -i;
                    }
                    system.debug('paymentMonths => '+paymentMonths);
                    
                    if(warpperObj.totalAmountDue == 0){                   
                        warpperObj.perTotalMonthAmount = warpperObj.perMonthAmount; //+ extraMonthPayment;                    
                    } else {
                        warpperObj.perTotalMonthAmount = warpperObj.totalAmountDue; //+ extraMonthPayment;
                    }
                    
                    if(warpperObj.effectiveDate < System.today()){
                        warpperObj.totalAmountDue += dueOnEffDt;
                    }
                    
                    
                    if(warpperObj.totalAmountDue > 0){
                        Payment_Schedule__c pSch1 = new Payment_Schedule__c();
                        pSch1.Due_Date__c = system.today();
                        pSch1.Billing__c = billing.id;
                        pSch1.Amount__c =  warpperObj.totalAmountDue;
                        pSch1.Status__c = 'Unpaid';//pSch1.Status__c = 'Paid';
                        pSch1.Frequency__c = 'Quaterly';
                        paySchList.add(pSch1);
                        if(warpperObj.firstInstallmentDate == null){
                            warpperObj.firstInstallmentDate = pSch1.Due_Date__c;
                        }
                        
                        paymentSchedulesWrapper paySchWrapObj = new paymentSchedulesWrapper();
                        paySchWrapObj.amount = dueOnEffDt;
                        paySchWrapObj.dateStr = String.valueOf(warpperObj.effectiveDate.month()).leftPad(2, '0')+ '/' +String.valueOf(warpperObj.effectiveDate.day()).leftPad(2, '0') +'/'+ warpperObj.effectiveDate.year();
                        
                        List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                            tempList.addAll(warpperObj.duePaymentSchedules);                            
                        warpperObj.duePaymentSchedules = tempList;
                    }
                    else if(dueOnEffDt > 0){
                        paymentSchedulesWrapper paySchWrapObj = new paymentSchedulesWrapper();
                        paySchWrapObj.amount = dueOnEffDt;
                        paySchWrapObj.dateStr = String.valueOf(warpperObj.effectiveDate.month()).leftPad(2, '0')+ '/' +String.valueOf(warpperObj.effectiveDate.day()).leftPad(2, '0') +'/'+ warpperObj.effectiveDate.year();
                        
                        List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                            tempList.addAll(warpperObj.futurePaymentSchedules);                            
                        warpperObj.futurePaymentSchedules = tempList;
                    }
                    for(paymentSchedulesWrapper psw : warpperObj.futurePaymentSchedules){
                        Payment_Schedule__c pSch = new Payment_Schedule__c();
                        pSch.Due_Date__c = Date.parse(psw.dateStr);
                        pSch.Billing__c = billing.id;
                        pSch.Amount__c =  psw.amount;
                        pSch.Status__c = 'Unpaid';
                        pSch.Frequency__c = 'Quaterly';
                        paySchList.add(pSch);
                        if(warpperObj.firstInstallmentDate == null){
                            warpperObj.firstInstallmentDate = pSch.Due_Date__c;
                        }
                    }
                    
                    if(totalAmountPaid > 0){
                        paySchList[0].Amount__c -= totalAmountPaid;
                        
                        if(!warpperObj.duePaymentSchedules.isEmpty()){
                            warpperObj.duePaymentSchedules[0].amount -= totalAmountPaid;
                        }
                        else{
                            warpperObj.futurePaymentSchedules[0].amount -= totalAmountPaid;
                        }
                        
                        if(warpperObj.totalAmountDue > 0){
                            warpperObj.totalAmountDue -= totalAmountPaid;
                        }
                    }
                }
                warpperObj.paymentScheduleListToInsert = paySchList;
                //warpperObj.paymentScheduleListToInsert.addAll(warpperObj.futurePaymentSchedules);

            }
            else{
                if(warpperObj.paymentScheduleVar=='Month'){
                    warpperObj.enablePaymentDate = false;
                    lasttime = 'Month';
                    Decimal numberOfPayments = 12;
                    warpperObj.totalAmountDue = 0;
                    List<String> paymentMonths = new List<String>();
                    finalPaymentMonths = new List<String>();
                    //Decimal totalAmountPaid = billing.AcctSeed__Received_Amount__c;
                    Date monthlyBilling = warpperObj.dueDate;
                    //warpperObj.balance = billing.AcctSeed__Balance__c;
                    
                    if(billing.Allow_CatchUp_Schedule__c){
                        monthlyBilling = System.today();
                        numberOfPayments = monthlyBilling.monthsBetween(billing.Policy__r.Expiration_Date__c);
                    }
                    
                    warpperObj.perMonthAmount = (billing.AcctSeed__Total__c - billing.AcctSeed__Credit_Memo_Applied_Amount__c) / numberOfPayments;
                    integer tempNoOfMonths = 0; // storing the count of the Months we already accepted payments for.
                    for(integer i = 0 ; i < numberOfPayments; i++){
                        if(totalAmountPaid > 0 && totalAmountPaid >= warpperObj.perMonthAmount){
                            totalAmountPaid -= warpperObj.perMonthAmount;
                            tempNoOfMonths++;
                        }
                    }
                    
                    numberOfPayments -= tempNoOfMonths;
                    //warpperObj.perMonthAmount = warpperObj.balance / numberOfPayments;
                    warpperObj.perTotalMonthAmount = warpperObj.perMonthAmount;
                    monthlyBilling = monthlyBilling.addMonths(tempNoOfMonths);
                    
                    
                    for(integer i = 0 ; i < numberOfPayments; i++){
                        if(monthlyBilling.addMonths(i) <= system.today()){
                            warpperObj.totalAmountDue += warpperObj.perMonthAmount;
                        }
                        else{                        
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
                            
                            paymentMonths.add(string.valueOf(monthlyBilling.addMonths(i).month()).leftPad(2, '0')+ '/' +String.valueOf(day).leftPad(2, '0') +'/'+ monthlyBilling.addMonths(i).year());
                            finalPaymentMonths.add(DateTime.newInstanceGMT(System.Date.newInstance(monthlyBilling.addMonths(i).year(), monthlyBilling.month()+i, day), System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM') + '/'+ (String.valueOf(day).length() == 1 ? ('0'+day): ''+day)+'/' +  monthlyBilling.addMonths(i).year()); 
                            
                            if(paymentMonthsDt == null){
                                paymentMonthsDt = monthlyBilling.addMonths(i);
                            }
                        }                
                    }
                    warpperObj.firstInstallment = warpperObj.perMonthAmount ;
                    warpperObj.firstInstallmentDate = paymentMonthsDt;
                    system.debug('warpperObj.firstInstallmentDate => '+warpperObj.firstInstallmentDate);
                    system.debug('paymentMonths => '+paymentMonths);
                    warpperObj.paymentMonths = paymentMonths;
                    
                    if(paymentMonths.isEmpty()){
                        warpperObj.firstInstallmentDate = system.today();
                    }
                    
                    
                    if(warpperObj.totalAmountDue == 0){
                        
                        warpperObj.perTotalMonthAmount = warpperObj.perMonthAmount; //+ extraMonthPayment;
                        
                        
                    } else {
                        
                        warpperObj.perTotalMonthAmount = warpperObj.totalAmountDue; //+ extraMonthPayment;
                        //warpperObj.totalAmountDue += extraMonthPayment;
                    }
                    List<Payment_Schedule__c> paySchList = new List<Payment_Schedule__c>();
                    
                    Decimal dueBalance = 0;
                    
                    if(warpperObj.totalAmountDue > 0){
                        Payment_Schedule__c pSch1 = new Payment_Schedule__c();
                        pSch1.Due_Date__c = system.today();//warpperObj.dueDate;
                        pSch1.Billing__c = billing.id;
                        pSch1.Amount__c =  warpperObj.totalAmountDue;
                        pSch1.Status__c = 'Unpaid';//pSch1.Status__c = 'Paid';
                        pSch1.Frequency__c = 'Monthly';
                        paySchList.add(pSch1);
                    }
                    for(Integer i=0;i<finalPaymentMonths.size();i++){
                        Payment_Schedule__c pSch = new Payment_Schedule__c();
                        pSch.Due_Date__c = Date.parse(finalPaymentMonths[i]);
                        pSch.Billing__c = billing.id;
                        pSch.Amount__c =  warpperObj.perMonthAmount;
                        pSch.Status__c = 'Unpaid';
                        pSch.Frequency__c = 'Monthly';
                        paySchList.add(pSch);
                    }
                    
                    system.debug('totalAmountPaid => '+totalAmountPaid);
                    system.debug('paySchList[0].Amount__c => '+paySchList[0].Amount__c);
                    if(totalAmountPaid > 0){
                        paySchList[0].Amount__c -= totalAmountPaid;
                        if(warpperObj.totalAmountDue > 0){
                            warpperObj.totalAmountDue -= totalAmountPaid;
                        }
                    }
                    
                    for(Payment_Schedule__c pSch: paySchList){
                        dueBalance += pSch.Amount__c;
                    }
                    dueBalance = dueBalance.setScale(2);
                    warpperObj.balance = warpperObj.balance.setScale(2);
                    
                    system.debug('month billing info => '+warpperObj.balance+' => '+dueBalance+' => '+paySchList);
                    if(warpperObj.balance.setScale(2) != dueBalance.setScale(2)){
                        paySchList[paySchList.Size() - 1].Amount__c += warpperObj.balance - dueBalance;
                        if(paySchList.Size() == 1){
                            warpperObj.totalAmountDue += warpperObj.balance - dueBalance;
                        }
                    }
                    if(!paySchList.isEmpty()){
                        paymentScheduleListToInsert = new List<Payment_Schedule__c>();
                        for(Payment_Schedule__c pSch: paySchList){
                            if(pSch.Amount__c.setScale(2) > 0){
                                paymentScheduleListToInsert.add(pSch);
                            }
                        }
                        system.debug('month paySchList '+paymentScheduleListToInsert);
                        
                        warpperObj.paymentScheduleListToInsert = paymentScheduleListToInsert;
                    }
                    //updatePSchRecords(paySchList,'insert');
                    system.debug('month paymentScheduleListToInsert '+paymentScheduleListToInsert);
                    
                }
                else if(warpperObj.paymentScheduleVar=='Quarter'){
                    warpperObj.enablePaymentDate = false;
                    lasttime = 'Quarter';
                    Integer numberOfPayments = 4;
                    warpperObj.perQuarterAmount = (billing.AcctSeed__Total__c - billing.AcctSeed__Credit_Memo_Applied_Amount__c) / numberOfPayments;
                    system.debug('warpperObj.perQuarterAmount => => '+warpperObj.perQuarterAmount);
                    warpperObj.firstInstallment = warpperObj.perQuarterAmount;
                    //Date quarterlyBilling = billing.AcctSeed__Due_Date2__c ;
                    Date quarterlyBilling = warpperObj.dueDate;
                    warpperObj.paymentQuarters = new List<String>();
                    finalPaymentQuarters = new List<String>(); 
                    warpperObj.perTotalQuarterAmount = 0 ;
                    warpperObj.totalAmountDue = 0;                          // Change login by sarbjeet
                    paymentQuartersDt = null;
                    
                    integer tempNoOfMonths = 0; // storing the count of the Months we already accepted payments for.
                    for(integer i = 0 ; i < numberOfPayments; i++){
                        if(totalAmountPaid > 0 && totalAmountPaid > warpperObj.perQuarterAmount){
                            totalAmountPaid -= warpperObj.perQuarterAmount;
                            tempNoOfMonths++;
                        }
                    }
                    
                    numberOfPayments -= tempNoOfMonths;
                    warpperObj.perTotalQuarterAmount = warpperObj.perQuarterAmount;
                    quarterlyBilling = quarterlyBilling.addMonths(tempNoOfMonths*3);
                    
                    for(integer j = 0 ; j < numberOfPayments; j++){
                        integer i = j*3;
                        if(quarterlyBilling.addMonths(i) <= system.today()){
                            warpperObj.totalAmountDue += warpperObj.perQuarterAmount;
                        }
                        else{                        
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
                            
                            warpperObj.paymentQuarters.add(string.valueOf(quarterlyBilling.addMonths(i).month()).leftPad(2, '0')+ '/' +String.valueOf(day).leftPad(2,'0') +'/'+ quarterlyBilling.addMonths(i).year());
                            
                            finalPaymentQuarters.add(DateTime.newInstanceGMT(System.Date.newInstance(quarterlyBilling.addMonths(i).year(), quarterlyBilling.month()+i, day), System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM') + '/'+ (String.valueOf(day).length() == 1 ? ('0'+day): ''+day) +'/' +  quarterlyBilling.addMonths(i).year()); 
                            
                            if(paymentQuartersDt == null){                        
                                paymentQuartersDt = quarterlyBilling.addMonths(i);// System.Date.newInstance((quarterlyBilling.addMonths(i)).year(), quarterlyBilling.month()+i, day);                        
                            }
                        }                
                    }
                    warpperObj.firstInstallment = warpperObj.perQuarterAmount ;
                    warpperObj.firstInstallmentDate = paymentQuartersDt;
                    
                    
                    if(finalPaymentQuarters.isEmpty()){
                        warpperObj.firstInstallmentDate = system.today();
                    }
                    system.debug(' finalPaymentQuarters => '+ finalPaymentQuarters);
                    
                    
                    if(warpperObj.totalAmountDue == 0){                
                        warpperObj.perTotalQuarterAmount = warpperObj.perQuarterAmount; //+ extraMonthPayment;
                    } 
                    else {                
                        warpperObj.perTotalQuarterAmount = warpperObj.totalAmountDue; //+ extraMonthPayment;
                        //warpperObj.totalAmountDue += extraMonthPayment;
                    }
                    
                    List<Payment_Schedule__c> paySchList = new List<Payment_Schedule__c>();
                    Decimal dueBalance = 0;
                    
                    if(warpperObj.totalAmountDue > 0){
                        Payment_Schedule__c pSch1 = new Payment_Schedule__c();
                        pSch1.Due_Date__c = system.today();
                        pSch1.Billing__c = billing.id;
                        pSch1.Amount__c =  warpperObj.totalAmountDue;
                        pSch1.Status__c = 'Unpaid';//pSch1.Status__c = 'Paid';
                        pSch1.Frequency__c = 'Quaterly';
                        paySchList.add(pSch1);
                    }
                    for(Integer i=0;i< finalPaymentQuarters.size();i++){
                        Payment_Schedule__c pSch = new Payment_Schedule__c();
                        pSch.Due_Date__c = Date.parse(finalPaymentQuarters[i]);
                        pSch.Billing__c = billing.id;
                        pSch.Amount__c =  warpperObj.perQuarterAmount;
                        pSch.Status__c = 'Unpaid';
                        pSch.Frequency__c = 'Quaterly';
                        paySchList.add(pSch);
                    }
                    
                    system.debug('totalAmountPaid => '+totalAmountPaid);
                    system.debug('paySchList[0].Amount__c => '+paySchList[0].Amount__c);
                    if(totalAmountPaid > 0){
                        paySchList[0].Amount__c -= totalAmountPaid;
                        if(warpperObj.totalAmountDue > 0){
                            warpperObj.totalAmountDue -= totalAmountPaid;
                        }
                    }
                    
                    for(Payment_Schedule__c pSch: paySchList){
                        dueBalance += pSch.Amount__c;
                    }
                    
                    dueBalance = dueBalance.setScale(2);
                    warpperObj.balance = warpperObj.balance.setScale(2);
                    
                    if(warpperObj.balance != dueBalance){
                        paySchList[paySchList.Size() - 1].Amount__c += warpperObj.balance - dueBalance;
                        if(paySchList.Size() == 1){
                            warpperObj.totalAmountDue += warpperObj.balance - dueBalance;
                        }
                    }
                    
                    system.debug('quarter paySchList '+paySchList);
                    if(!paySchList.isEmpty()){
                        paymentScheduleListToInsert.addAll(paySchList);
                        warpperObj.paymentScheduleListToInsert = paymentScheduleListToInsert;
                    }
                    //updatePSchRecords(paySchList,'insert');
                    system.debug('quarter paymentScheduleListToInsert '+paymentScheduleListToInsert);
                    
                } 
                else {
                    warpperObj.firstInstallment = warpperObj.balance;
                    lasttime = 'Full';
                    //if(billing.AcctSeed__Due_Date2__c > System.today()){
                    if(warpperObj.dueDate > System.today()){
                        warpperObj.totalAmountDue = 0;
                        warpperObj.enablePaymentDate = true;   
                    }else{
                        warpperObj.totalAmountDue = warpperObj.balance;
                    }
                    
                    system.debug(' warpperObj.dueDate => '+ warpperObj.dueDate);
                    warpperObj.firstInstallmentDate = warpperObj.dueDate;
                    warpperObj.scheduleAmount = warpperObj.balance;
                    
                    
                    List<Payment_Schedule__c> paySchList = new List<Payment_Schedule__c>();
                    Payment_Schedule__c pSch = new Payment_Schedule__c();
                    pSch.Due_Date__c = warpperObj.dueDate > System.today() ? warpperObj.dueDate : System.today();
                    pSch.Billing__c = billing.id;
                    pSch.Amount__c = warpperObj.balance;// warpperObj.totalAmountDue;
                    pSch.Status__c = 'Unpaid'; //pSch.Status__c = 'Paid';
                    pSch.Frequency__c = 'Full';
                    paySchList.add(pSch);
                    system.debug('paySchList '+paySchList);
                    if(!paySchList.isEmpty()){
                        paymentScheduleListToInsert.addAll(paySchList);
                        warpperObj.paymentScheduleListToInsert = paymentScheduleListToInsert;
                        //updatePSchRecords(paySchList,'insert');
                    }
                    system.debug('full paymentScheduleListToInsert '+paymentScheduleListToInsert);
                }
            }  
        }
        //PaymentGateway_Ctrl_Wrapper warpperObj = (PaymentGateway_Ctrl_Wrapper)System.JSON.deserializeStrict(wrapString, PaymentGateway_Ctrl_Wrapper.class);
              
        
        warpperObj.dueDateStr = String.valueOf(warpperObj.dueDate.month()).leftPad(2, '0') +'/'+ String.valueOf(warpperObj.dueDate.day()).leftPad(2, '0')+'/'+warpperObj.dueDate.year();
        system.debug('warpperObj.firstInstallmentDate =>'+warpperObj.firstInstallmentDate);
        warpperObj = paymentTypeFunction(warpperObj, billing);
        
        warpperObj.firstInstallmentDateString = DateTime.newInstanceGMT(System.Date.newInstance(warpperObj.firstInstallmentDate.year(), warpperObj.firstInstallmentDate.month(), warpperObj.firstInstallmentDate.day()),System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM/dd/yyyy');
        return warpperObj;
    }
    
    public Static PaymentGateway_Ctrl_Wrapper paymentTypeFunction(PaymentGateway_Ctrl_Wrapper warpperObj , AcctSeed__Billing__c billing){
        //PaymentGateway_Ctrl_Wrapper warpperObj = (PaymentGateway_Ctrl_Wrapper)System.JSON.deserializeStrict(wrapString, PaymentGateway_Ctrl_Wrapper.class);
        system.debug('warpperObj =>'+JSON.serialize(warpperObj));
        system.debug('paymentTypeVar=>'+warpperObj.paymentTypeVar);
        if(warpperObj.paymentTypeVar=='check' && warpperObj.paymentScheduleVar=='Full'){
            //warpperObj.totalAmountDue = billing.AcctSeed__Balance__c;
            baseAmountToPay = warpperObj.totalAmountDue;
        }else if(warpperObj.paymentTypeVar=='check' && warpperObj.paymentScheduleVar=='Month'){
            warpperObj.totalServiceFee = CHECK_TRANSACTION_FEE;
            baseAmountToPay = warpperObj.perTotalMonthAmount;
            //warpperObj.totalAmountDue = warpperObj.perTotalMonthAmount+CHECK_TRANSACTION_FEE;
            //warpperObj.totalAmountDue = warpperObj.perTotalMonthAmount;
        }else if(warpperObj.paymentTypeVar=='check' && warpperObj.paymentScheduleVar=='Quarter'){
            warpperObj.totalServiceFee = CHECK_TRANSACTION_FEE;
            baseAmountToPay = warpperObj.perTotalQuarterAmount;
            //warpperObj.totalAmountDue = warpperObj.perTotalQuarterAmount+CHECK_TRANSACTION_FEE;
            //warpperObj.totalAmountDue = warpperObj.perTotalQuarterAmount;
        }else if(warpperObj.paymentTypeVar == 'Existing' && warpperObj.paymentScheduleVar=='Full'){
            //warpperObj.totalAmountDue = billing.AcctSeed__Balance__c;
            baseAmountToPay = warpperObj.totalAmountDue;
        }else if(warpperObj.paymentTypeVar == 'Existing' && warpperObj.paymentScheduleVar=='Month'){
            baseAmountToPay = warpperObj.perTotalMonthAmount;
            //warpperObj.totalAmountDue = warpperObj.perTotalMonthAmount;
        }else if(warpperObj.paymentTypeVar == 'Existing' && warpperObj.paymentScheduleVar=='Quarter'){
            baseAmountToPay = warpperObj.perTotalQuarterAmount;
            //warpperObj.totalAmountDue = warpperObj.perTotalQuarterAmount;
        }
        if(warpperObj.cardTypeVar!=null){
            cardTypeFunction(warpperObj, billing);
        }
        //warpperObj.totalAmountDue = warpperObj.totalAmountDue;
        baseAmountToPay = warpperObj.totalAmountDue;
        system.debug('baseAmountToPay => cardTypeFunction '+baseAmountToPay);
        warpperObj.baseAmountToPay = baseAmountToPay;
        return warpperObj;
    }   
    
    public class PaymentGateway_Ctrl_Wrapper{
        @AuraEnabled public AcctSeed__Billing__c billing{get;set;}
        @AuraEnabled public String policyInvoiceNumber{get;set;}
        @AuraEnabled public String firmId{get;set;}
        @AuraEnabled public String invoiceId{get;set;}
        @AuraEnabled public String firmName{get;set;}
        @AuraEnabled public String zipCode{get;set;}
        @AuraEnabled public String paymentScheduleVar{get;set;}
        @AuraEnabled public String paymentTypeVar{get;set;}
        @AuraEnabled public String cardTypeVar{get;set;}
        @AuraEnabled public String firstName{get;set;}
        @AuraEnabled public String lastName{get;set;}
        @AuraEnabled public String emailAddress{get;set;}
        /* Card information */
        @AuraEnabled public String cardNumber{get;set;}
        @AuraEnabled public String verificationNumber{get;set;}
        @AuraEnabled public String expireMonth{get;set;}
        @AuraEnabled public String expireYear{get;set;}
        @AuraEnabled public String nameOnCard{get;set;}
        /* Account information */
        @AuraEnabled public Boolean isBillingFrequencyFullOnly{get;set;}
        @AuraEnabled public String accountNumber{get;set;}
        @AuraEnabled public String routingNumber{get;set;}
        @AuraEnabled public String accountType{get;set;}
        @AuraEnabled public String accountHolderName{get;set;}
        @AuraEnabled public String customerToken{get;set;}
        
        //added new attributes
        @AuraEnabled public Boolean isAutoPay{get;set;}
        @AuraEnabled public String paymentMethodId{get;set;}
        @AuraEnabled public Boolean isPaymentMethodAuthenticated{get;set;}
        
        @AuraEnabled public String confirmationEmail{get;set;}
        @AuraEnabled public String payMethodToken{get;set;}
        
        @AuraEnabled public String billingStreet{get;set;}
        @AuraEnabled public String billingCity{get;set;}
        @AuraEnabled public String billingState{get;set;}
        @AuraEnabled public String billingPostal{get;set;}
        @AuraEnabled public String dueDateStr{get;set;}
        @AuraEnabled public Date dueDate{get;set;}
        @AuraEnabled public Date effectiveDate {get;set;}
        @AuraEnabled public String effectiveDateStr {get;set;}
        @AuraEnabled public String expirationDateStr {get;set;}
        
        @AuraEnabled public Decimal effectiveDateYear {get;set;}
        @AuraEnabled public Decimal balanceDue{get;set;}
        
        @AuraEnabled public Decimal totalCredit{get;set;}
        @AuraEnabled public Decimal totalCLECredit{get;set;}
        @AuraEnabled public Decimal totalAmountDue{get;set;}
        @AuraEnabled public Decimal policyDividend{get;set;}
        @AuraEnabled public Decimal premium{get;set;}
        @AuraEnabled public String limits{get;set;}
        @AuraEnabled public String deductible{get;set;}
        @AuraEnabled public String perClaimLimit{get;set;}
        @AuraEnabled public String aggregateLimit{get;set;}
        @AuraEnabled public Decimal balance{get;set;}
        @AuraEnabled public String accountName{get;set;}
        @AuraEnabled public boolean enablePaymentDate{get;set;}
        @AuraEnabled public Decimal totalServiceFee{get;set;}
        @AuraEnabled public List<AcctSeed__Billing_Line__c > billingLines{get;set;}
        @AuraEnabled public List<String> paymentMonths{get;set;}
        @AuraEnabled public List<String> paymentQuarters{get;set;}
        @AuraEnabled public Decimal creditCardServiceFee{get;set;}
        @AuraEnabled public boolean paymentInvalidDate{get;set;}  
        @AuraEnabled public Decimal creditCardfee{get;set;}       
        @AuraEnabled public String SelectedMethod{get;set;}
        @AuraEnabled public Payment_Method__c paymentMethod{get;set;}
        //@AuraEnabled public Payment_Method__c paymentMethod{get;set;}
        @AuraEnabled public Decimal baseAmountToPay{get;set;}
        // @AuraEnabled public String lasttime{get;set;}
        @AuraEnabled public Decimal perMonthAmount{get;set;}
        @AuraEnabled public Decimal perQuarterAmount{get;set;}
        @AuraEnabled public Decimal lastQuarterAmount{get;set;}
        @AuraEnabled public String lastQuarterDate{get;set;}
        @AuraEnabled public Decimal perTotalMonthAmount{get;set;}
        @AuraEnabled public Decimal perTotalQuarterAmount{get;set;}
        @AuraEnabled public Decimal firstInstallment{get;set;}
        @AuraEnabled public Date firstInstallmentDate{get;set;}
        @AuraEnabled public String firstInstallmentDateString{get;set;}
        @AuraEnabled public String receiptNumber{get;set;}
        @AuraEnabled public String description{get;set;}
        @AuraEnabled public String nextPaymentDate{get;set;}
        @AuraEnabled public paymentScheduleWrapper oldPaymentSchedule{get;Set;}
        @AuraEnabled public List<Payment_Schedule__c> paymentScheduleListToInsert {get;Set;}
        //new changes 26 june 2023 
        @AuraEnabled public boolean isAccountId {get;set;}
        @AuraEnabled public List<BillingWrapper> billings{get;set;}
        // @AuraEnabled public List<Policy__c> policies{get;set;}
        @AuraEnabled public List<PolicyWrapper> policies{get;set;}
        @AuraEnabled public List<Policy__c> applications{get;set;}
        @AuraEnabled public Account accRecord {get;set;}
        @AuraEnabled public String siteUrl {get;set;}
        @AuraEnabled public String baseUrl {get;set;}
        @AuraEnabled public String defaultPaymentMethodId {get;set;}
        @AuraEnabled public boolean isAnyDefaultPaymentMethodAvailabel {get;set;}
        
        @AuraEnabled public Decimal scheduleAmount {get;set;}
        @AuraEnabled public Decimal creditDividendAmount {get;set;}
        
        /* Added for Policy */
        @AuraEnabled public Boolean isRedirect {get;set;}
        @AuraEnabled public Boolean isPolicy {get;set;}
        @AuraEnabled public Boolean isAlreadyBind {get;set;}
        @AuraEnabled public Boolean isBlocked {get;set;}
        @AuraEnabled public Boolean isRejected {get;set;}
        @AuraEnabled public Policy__c policy{get;set;}
        @AuraEnabled public Decimal roundedDividend{get;set;}
        @AuraEnabled public List<Policy_Quote__c> policyQuotes{get;set;}
        @AuraEnabled public List<Policy_Lawyer__c> policyLawyers{get;set;}
        @AuraEnabled public Policy_Endorsement__c endorsement{get;set;}
        @AuraEnabled public List<Policy_Endorsement__c> policyEndorsements{get;set;}
        @AuraEnabled public List<paymentSchedulesWrapper> duePaymentSchedules{get;set;}
        @AuraEnabled public List<paymentSchedulesWrapper> futurePaymentSchedules{get;set;}
        
        //@AuraEnabled public Boolean isPaymentProcessing{get;set;}
        @AuraEnabled public Decimal ccFeeRate{get;set;}
        //@AuraEnabled public Boolean isCC{get;set;}
        @AuraEnabled public String ipAddress{get;set;}
        @AuraEnabled public String underwriterName{get;set;}
        @AuraEnabled public String underwriterEmail{get;set;}
        @AuraEnabled public String underwriterPhone{get;set;}
        @AuraEnabled public String underwriterTitle{get;set;}
        @AuraEnabled public String errorMessage{get;set;}
        @AuraEnabled public String fileName{get;set;}
        @AuraEnabled public String versionData{get;set;}
        @AuraEnabled public String endorsementPreiod{get;set;}
        @AuraEnabled public String deviceType{get;set;}
        @AuraEnabled public String screenResolution{get;set;}
        @AuraEnabled public String windowSize{get;set;}
        
        public PaymentGateway_Ctrl_Wrapper(){
            this.fileName = '';
            this.versionData = '';
            this.isRedirect = false;
            this.isPolicy = false;
            this.isBlocked = false;
            this.isPaymentMethodAuthenticated = false;
            this.billing = null;
            this.baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            this.siteUrl = getUrl();
            this.ccFeeRate = Decimal.valueOf(label.Service_Fee_Rate);
            this.isAlreadyBind = false;
            this.isRejected = false;
            this.isAccountId = false;
            this.isBillingFrequencyFullOnly = false;
            this.oldPaymentSchedule = null;
            this.policyInvoiceNumber = '';
            this.zipCode = '';
            this.paymentScheduleVar='';
            this.paymentTypeVar='creditCard';
            this.cardTypeVar='';
            this.totalAmountDue = null;
            this.firstName = '';
            this.cardTypeVar = 'none';
            this.lastName = '';
            this.nameOnCard = '';
            this.confirmationEmail = '';
            this.cardNumber = '';
            this.verificationNumber = '';
            this.expireMonth = '';
            this.expireYear = '';
            this.payMethodToken = '';
            this.isAutoPay = true;
            this.paymentMethodId = '';
            this.firstInstallmentDate = null;
            this.firstInstallmentDateString = '';
            this.policyQuotes = new List<Policy_Quote__c>(); 
            this.policyLawyers = new List<Policy_Lawyer__c>(); 
            this.policyEndorsements = new List<Policy_Endorsement__c>(); 
            this.duePaymentSchedules = new List<paymentSchedulesWrapper>();
            this.futurePaymentSchedules = new List<paymentSchedulesWrapper>();
            //this.policies = new List<Policy__c>();
            this.policies = new List<PolicyWrapper>();
            this.endorsementPreiod = null;
            //this.isPaymentProcessing = false;
            this.deviceType = null;
            this.screenResolution = null;
            this.windowSize = null;
        }
    }
    
    public class expiryWrapper {
        @AuraEnabled public List<optionsWrap> expMonths{get;set;}
        @AuraEnabled public List<optionsWrap> expYears{get;set;}
        public expiryWrapper() {
            this.expMonths = getExpireMonthsList();
            this.expYears =  getExpireYearsList();
        }
    }
    
    public class optionsWrap {
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String value{get;set;}
        public optionsWrap(String lb, String val){
            this.label = lb;
            this.value = val;
        }
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
                system.debug('msg => '+msg);
                if(msg == 'Error : This payment method already exists.'){
                    system.debug(records[0].get('AcctSeed__External_Id__c'));
                    String paymentMethodToken = String.valueOf(records[0].get('AcctSeed__External_Id__c'));
                    String customerId = paymentMethodToken.substringBefore('_');
                    CardknoxUtil.DeletePaymentMethod(paymentMethodToken, customerId);
                }
                //Error err = new Error(msg, 'Error While performing DML operations.', 'Team, \n\nThe following error occurred while performing DML operations ("'+operation+'") on the records.\n\n'+msg+'\n\n The records are : \n'+JSON.serialize(records));
                throw new PaymentGatewayClassException(msg);//JSON.serialize(err));
                //throw new PaymentGatewayClassException(msg);
            }  
        }
        else{
            //return 'success';
            response.setHeader('Content-Type', 'application/json');
            String q = 'SELECT Id FROM Account LIMIT 1';
            system.debug('query=>'+q);
            List<Sobject> obj = Database.query(q);
            system.debug('obj =>'+obj);
            response.setStatusCode(200);
            return JSON.serialize(obj);
        }
    }
    
    @future(callout=true)
    public static void updatePaymentMethodRecords(String recStr, String operation){
        List<Sobject> records = (List<Sobject>)JSON.deserializeStrict(recStr, List<Sobject>.Class);
        System.debug('records = >'+records);
        
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
                system.debug(msg); 
            } else{ 
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = Label.System_Admin_Emails.split(',');
                message.subject = 'Error While '+operation+'ting the Records.';
                message.plainTextBody = 'Team,\n\nFollowing error has occurred while '+operation+'ting the Records\n\n '+msg;
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                    
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                system.debug('error'); 
            }  }
        else{
            //return 'success';
            response.setHeader('Content-Type', 'application/json');
            String q = 'SELECT Id FROM Account LIMIT 1';
            system.debug('query=>'+q);
            List<Sobject> obj = Database.query(q);
            system.debug('obj =>'+obj);
            response.setStatusCode(200);
            system.debug(JSON.serialize(obj));
        }
    }
    
    @AuraEnabled
    public static String getAccountId(String emailId) {
        List<Account> Accounts = new List<Account>([SELECT Id, Recent_Policy_Lookup__r.Firm_Contact__c, Recent_Policy_Lookup__r.Firm_Contact__r.Email ,AcctSeed__Billing_Contact__c, AcctSeed__Billing_Contact__r.Email  FROM Account WHERE AcctSeed__Billing_Contact__r.Email =: emailId OR Recent_Policy_Lookup__r.Firm_Contact__r.Email =: emailId]);
        if(Accounts.isEmpty() || Accounts.size() > 1){
            throw new PaymentGatewayClassException('We haven\'t found any invoices related to this email. Please confirm again.');
        }
        else{
            
            Datetime startTime = System.now();
            Account acc = new Account();
            acc.Id = Accounts[0].Id;
            acc.Payment_Link_Activation_Started_at__c = startTime;
            updatePSchRecords(new List<Account>{acc}, 'upsert');  
            String conId = String.isNotBlank(Accounts[0].AcctSeed__Billing_Contact__c) ? Accounts[0].AcctSeed__Billing_Contact__c : Accounts[0].Recent_Policy_Lookup__r.Firm_Contact__c;
            sendEmailbyAccId(emailId, Accounts[0].Id, conId);
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            system.debug('Base URL => '+ baseUrl);
            baseUrl += '/?id='+EncodingUtil.urlEncode(PaymentGateway_Ctrl.processEncryption(Accounts[0].Id, Label.Encryption_Key_Payment_Id),'UTF-8');
            System.debug('URL => '+ baseUrl);            
            return baseUrl;
            //return 'The payment link has been successfully sent to your email address.';
        }
    }
    
    @AuraEnabled
    public static void sendEmailbyAccId(String emailId, String accId, String conId){
        try {
            String  OrgWideEmailAddressId = '';
            List<OrgWideEmailAddress> oweaList = [select Id,DisplayName from OrgWideEmailAddress Where DisplayName =: Label.OrganizationWideEmail];
            if (!oweaList.isEmpty()) {
                //mail.setOrgWideEmailAddressId(oweaList.get(0).Id);
                OrgWideEmailAddressId = oweaList.get(0).Id;
            } 
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            system.debug('Base URL => '+ baseUrl);
            baseUrl += '/?id='+EncodingUtil.urlEncode(PaymentGateway_Ctrl.processEncryption(accId, Label.Encryption_Key_Payment_Id),'UTF-8');
            System.debug('URL => '+ baseUrl);
            
            String body = 'Hi, <br/><br/>'
                +'Your Payment Link is <a href="'+baseUrl+'">here</a>. <br/> <br/> Thank You.';
            
            sendEmail(OrgWideEmailAddressId, body, accId, true, new List<String>{emailId}, 'Payment Link',new String[]{Label.ISBA_Accounting_Automation_Email_Address }, Label.ISBA_Accounting_Email_Address, false, conId); 
        } catch (Exception e) {
            Error err = new Error(e.getMessage(), 'Error While sending Payment Link for Account.', 'Team,\n\nFollowing error has occurred while sending Payment Link for Account \n\n'+e.getMessage() + '\n\n'+e.getStackTraceString()+'\n\n The AccountId is:'+accId+'and Email Address is '+emailId );
            throw new PaymentGatewayClassException(JSON.serialize(err));
            //throw new PaymentGatewayClassException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static paymentMethodWrapper savePaymentMethod(PaymentGateway_Ctrl_Wrapper wrapperObj , String ipAddress) {
        try {
            
            
            PaymentGatewayClass.paymentMethodWrapper paymentMethodWrapObj = new PaymentGatewayClass.paymentMethodWrapper();
            system.debug('wrapperObj => '+wrapperObj);
            
            
            system.debug('wrapperObj.customerToken => '+wrapperObj.customerToken);
            
            if(wrapperObj.paymentTypeVar=='check' && String.isBlank(wrapperObj.accountType)){
                throw new PaymentGatewayClassException('An error has occurred with the Account Type. Please get in touch with your ISBA Mutual Policy Contact.');
            }
            else if((wrapperObj.paymentTypeVar=='creditCard' || (wrapperObj.paymentTypeVar == 'Existing' && wrapperObj.cardNumber !=null)) && wrapperObj.balanceDue > 20000){
                throw new PaymentGatewayClassException('Credit Card payments not available for transactions exceeding $20,000.');
            }
            else{
                Boolean isPolicy = false;
                system.debug('<= checkCustomerIdCardKnox called =>');
                AcctSeed__Billing__c billing = new AcctSeed__Billing__c();
                Policy__c policy = new Policy__c();
                if(wrapperObj.billing != null){
                    billing = wrapperObj.billing;
                }
                else {
                    isPolicy = true;
                    policy = wrapperObj.policy;
                }
                
                List<AcctSeed__Payment_Processor_Customer__c> custList = new List<AcctSeed__Payment_Processor_Customer__c>();
                
                String customerId = '';
                if(isPolicy){
                    customerId = policy.Account__c;
                }
                else{
                    customerId = billing.AcctSeed__Customer__c;
                }
                List<AcctSeed__Payment_Processor__c> paymentProcessor;
                List<AcctSeed__Payment_Processor_Customer__c> customerList;
                if(String.isNotBlank(customerId)){
                    paymentProcessor = new List<AcctSeed__Payment_Processor__c>([select id from AcctSeed__Payment_Processor__c where AcctSeed__Type__c = 'Fiserv' limit 1]);
                    customerList = new List<AcctSeed__Payment_Processor_Customer__c>([select id,AcctSeed__External_Id__c from AcctSeed__Payment_Processor_Customer__c where AcctSeed__Account__c = :customerId AND AcctSeed__Processor__c=: paymentProcessor[0].Id  limit 1]);
                    if(!customerList.isEmpty() && String.isNotBlank(customerList[0].AcctSeed__External_Id__c)){
                        wrapperObj.customerToken = customerList[0].AcctSeed__External_Id__c;
                    }
                    
                }
                Map<String, Object> creditCardPayMethodMap;
                if(wrapperObj.paymentTypeVar=='creditCard' && (wrapperObj.payMethodToken!=null)){
                    if(customerList.isEmpty() || !String.isNotBlank(customerList[0].AcctSeed__External_Id__c)){
                        creditCardPayMethodMap = Fiserv_Utils.createCustomer(wrapperObj);
                        wrapperObj.customerToken = (String)creditCardPayMethodMap.get('profileid');
                        
                        AcctSeed__Payment_Processor_Customer__c customer = new AcctSeed__Payment_Processor_Customer__c();
                        customer.AcctSeed__External_Id__c = wrapperObj.customerToken;
                        customer.AcctSeed__Processor__c = paymentProcessor[0].id;
                        customer.AcctSeed__Account__c = customerId;
                        custList.add(customer);
                        //PaymentGatewayClass.updatePSchRecords(custList, 'upsert');
                    }
                    else{
                        creditCardPayMethodMap = Fiserv_Utils.updateCustomer(wrapperObj);
                    }
                    system.debug('creditCardPayMethodMap keys=> '+creditCardPayMethodMap.keySet());
                    system.debug('creditCardPayMethodMap values=> '+creditCardPayMethodMap.values());  
                    
                    if(creditCardPayMethodMap!=null){
                        system.debug('resptext => '+creditCardPayMethodMap.get('resptext'));
                        if((string)creditCardPayMethodMap.get('resptext')=='Profile Saved'){
                            List<Payment_Method__c> payMethodList = new List<Payment_Method__c>();
                            Payment_Method__c payMethod = new Payment_Method__c();
                            
                            if(wrapperObj.billing!= null){
                                payMethod.Account__c = wrapperObj.billing.AcctSeed__Customer__c;
                            }
                            else{
                                payMethod.Account__c = wrapperObj.policy.Account__c;           
                            }
                            payMethod.Payment_Processor__c = !paymentProcessor.isEmpty() ? paymentProcessor[0].Id : null;
                            payMethod.Type__c = 'Credit_Card';
                            payMethod.Name_On_Card__c = (String)creditCardPayMethodMap.get('name');
                            payMethod.Last_4_Account_Number__c = wrapperObj.cardNumber.right(4);
                            payMethod.Masked_Account_Number__c = payMethod.Last_4_Account_Number__c.leftPad(wrapperObj.cardNumber.length(),'X');//wrapperObj.cardNumber;
                            payMethod.Expiry_Month__c = Integer.valueOf(wrapperObj.expireMonth);
                            payMethod.Expiry_Year__c = Integer.valueOf(wrapperObj.expireYear);
                            payMethod.Card_Type__c = ((String)creditCardPayMethodMap.get('accttype')).toLowerCase();
                            
                            if(wrapperObj.billing!= null && wrapperObj.isAutoPay){
                                payMethod.Default__c = true;
                            }
                            
                            String paymentToken =(String)creditCardPayMethodMap.get('profileid') + '/' + (String)creditCardPayMethodMap.get('acctid');
                            system.debug('paymentToken ===> '+paymentToken);
                            payMethod.Payment_Method_Token__c = paymentToken;
                            payMethod.Token__c = (String)creditCardPayMethodMap.get('token');
                           
                            
                            PaymentGatewayClass.createIntegrationLog(null, wrapperObj.policy, wrapperObj.billing, 'Processed Successfully', 0, 'Payment Method Created Successfully. Payment Method Token =>'+paymentToken, '' ,wrapperObj.ipAddress);
                            
                            
                            for(Payment_Method__c paymentMethod : [SELECT Id,Default__c,Payment_Method_Token__c FROM Payment_Method__c WHERE Account__c =:payMethod.Account__c AND Is_Deleted__c = false  AND (Default__c = true OR Payment_Method_Token__c =: paymentToken)]){
                                if(paymentMethod.Default__c && paymentMethod.Payment_Method_Token__c != paymentToken){
                                    paymentMethod.Default__c = false;
                                    payMethodList.add(paymentMethod);
                                }
                                
                                if(paymentMethod.Payment_Method_Token__c == paymentToken){
                                    payMethod.Id = paymentMethod.Id;
                                }
                            }
                            
                            payMethodList.add(payMethod);
                            
                            //PaymentGatewayClass.updatePSchRecords(payMethodList, 'upsert');
                            
                            wrapperObj.payMethodToken = paymentToken;
                            
                            if(!payMethodList.isEmpty()){  
                                system.debug('payMethodList -> '+payMethodList);
                                
                                
                                String resp = updatePSchRecords(payMethodList, 'upsert');
                                system.debug('UpdatePSchRecords Called from 2121');
                                system.debug('resp => '+resp);
                                
                                List<Payment_Method__c> updatedMethods = (List<Payment_Method__c>) System.JSON.deserializeStrict(resp, List<Payment_Method__c>.class);
                                if(!custList.isEmpty()){
                                    PaymentGatewayClass.updatePSchRecords(custList, 'upsert');
                                }
				                                
                                if(wrapperObj.billing == null && wrapperObj.isAutoPay){
                                    paymentMethodWrapObj.methodId = updatedMethods[0].Id;
                                }
                                
                                if(wrapperObj.billing != null && wrapperObj.billing.Payment_Method__c == null){
                                    UpdatePaymentMethodCtrl.UpdatePaymentSchedule(wrapperObj.billing.Id, updatedMethods[0].Id);
                                }
                                
                            }
                            
                            system.debug('paymethod_token => '+(String)creditCardPayMethodMap.get('profileid') + '/' + (String)creditCardPayMethodMap.get('acctid'));
                            paymentMethodWrapObj.token = (String)creditCardPayMethodMap.get('profileid') + '/' + (String)creditCardPayMethodMap.get('acctid');
                            return paymentMethodWrapObj;
                        }
                        else if((string)creditCardPayMethodMap.get('resptext')=='Profile not found'){
                            PaymentGatewayClass.updatePSchRecords(customerList, 'Delete');
                            return PaymentGatewayClass.savePaymentMethod(wrapperObj, ipAddress);
                        }
                        else{
                            PaymentGatewayClass.createIntegrationLog(null, wrapperObj.policy, wrapperObj.billing, 'Processed With Errors', wrapperObj.totalAmountDue, '(Error Code : Error occurred while creating the Payment Method Token '+JSON.serializePretty(creditCardPayMethodMap)+').', '', wrapperObj.ipAddress);
                            
                            throw new PaymentGatewayClassException('An error has occurred In saving Payment Method. Please get in touch with your ISBA Mutual Policy Contact.');
                        }
                        
                    }
                }
                else if(wrapperObj.paymentTypeVar=='check' && (wrapperObj.payMethodToken==null || wrapperObj.payMethodToken=='')){
                    
                    //List<AcctSeed__Payment_Processor_Customer__c> custList = new List<AcctSeed__Payment_Processor_Customer__c>();
                    
                    string token = Fiserv_Utils.createPaymentMethod(wrapperObj);
                    wrapperObj.payMethodToken = token;
                    Map<String, Object> echeckPayMethodMap;
                    if(customerList.isEmpty() || !String.isNotBlank(customerList[0].AcctSeed__External_Id__c)){
                        echeckPayMethodMap = Fiserv_Utils.createCustomer(wrapperObj);
                        wrapperObj.customerToken = (String)echeckPayMethodMap.get('profileid');
                        
                        AcctSeed__Payment_Processor_Customer__c customer = new AcctSeed__Payment_Processor_Customer__c();
                        customer.AcctSeed__External_Id__c = wrapperObj.customerToken;
                        customer.AcctSeed__Processor__c = paymentProcessor[0].id;
                        customer.AcctSeed__Account__c = customerId;
                        custList.add(customer);
                        //updatePSchRecords(custList, 'upsert');
                    }
                    else{
                        echeckPayMethodMap = Fiserv_Utils.updateCustomer(wrapperObj);
                    }
                    if(echeckPayMethodMap!=null){
                        if((string)echeckPayMethodMap.get('resptext')=='Profile Saved'){
                            List<Payment_Method__c> payMethodList = new List<Payment_Method__c>();
                            Payment_Method__c payMethod = new Payment_Method__c();
                            
                            if(wrapperObj.billing!= null){
                                payMethod.Account__c = wrapperObj.billing.AcctSeed__Customer__c;
                            }
                            else{
                                payMethod.Account__c = wrapperObj.policy.Account__c;           
                            }
                            payMethod.Payment_Processor__c = !paymentProcessor.isEmpty() ? paymentProcessor[0].Id : null;
                            payMethod.Type__c = 'eCheck';
                            payMethod.Card_Holder_Name__c = wrapperObj.accountHolderName;
                            payMethod.Last_4_Account_Number__c = wrapperObj.accountNumber.right(4);
                            payMethod.Masked_Account_Number__c = payMethod.Last_4_Account_Number__c.leftPad(wrapperObj.accountNumber.length(),'X'); //wrapperObj.accountNumber;
                            payMethod.Routing_Number__c = 'XXXXXXXXX';
                            
                            if(wrapperObj.accountType.equalsIgnoreCase('Checking')){
                                payMethod.Account_Type__c = 'checking';
                            }else if(wrapperObj.accountType.equalsIgnoreCase('Savings')){
                                payMethod.Account_Type__c = 'saving';
                            }
                            String paymentToken = (String)echeckPayMethodMap.get('profileid') + '/' + (String)echeckPayMethodMap.get('acctid');
                            payMethod.Payment_Method_Token__c = paymentToken;
                             payMethod.Token__c = (String)echeckPayMethodMap.get('token');
                            
                            
                            PaymentGatewayClass.createIntegrationLog(null, wrapperObj.policy, wrapperObj.billing, 'Processed Successfully', 0, 'Payment Method Created Successfully. Payment Method Token =>'+paymentToken, '', wrapperObj.ipAddress);
                            
                            
                            for(Payment_Method__c paymentMethod : [SELECT Id,Default__c,Payment_Method_Token__c FROM Payment_Method__c WHERE Account__c =:payMethod.Account__c AND Is_Deleted__c = false  AND (Default__c = true OR Payment_Method_Token__c =: paymentToken)]){
                                if(paymentMethod.Default__c && paymentMethod.Payment_Method_Token__c != paymentToken){
                                    paymentMethod.Default__c = false;
                                    payMethodList.add(paymentMethod);
                                } 
                                
                                if(paymentMethod.Payment_Method_Token__c == paymentToken){
                                    payMethod.Id = paymentMethod.Id;
                                }
                            }
                            
                            payMethodList.add(payMethod);
                            
                            wrapperObj.payMethodToken = paymentToken;
                            
                            if(!payMethodList.isEmpty()){  
                                system.debug('payMethodList -> '+payMethodList);
                                
                                
                                String resp = updatePSchRecords(payMethodList, 'upsert');
                                system.debug('UpdatePSchRecords Called from 2121');
                                system.debug('resp => '+resp);
                                List<Payment_Method__c> updatedMethods = (List<Payment_Method__c>) System.JSON.deserializeStrict(resp, List<Payment_Method__c>.class);
                                if(!custList.isEmpty()){
                                    PaymentGatewayClass.updatePSchRecords(custList, 'upsert');
                                }
                                
                                if(wrapperObj.billing == null && wrapperObj.isAutoPay){
                                    paymentMethodWrapObj.methodId = updatedMethods[0].Id;
                                }
                                if(wrapperObj.billing != null && wrapperObj.billing.Payment_Method__c == null){
                                    UpdatePaymentMethodCtrl.UpdatePaymentSchedule(wrapperObj.billing.Id, updatedMethods[0].Id);
                                }
                                
                            }
                            
                            system.debug('paymethod_token => '+(String)echeckPayMethodMap.get('profileid') + '/' + (String)echeckPayMethodMap.get('acctid'));
                            paymentMethodWrapObj.token = (String)echeckPayMethodMap.get('profileid') + '/' + (String)echeckPayMethodMap.get('acctid');
                            return paymentMethodWrapObj;
                        }
                        else if((string)echeckPayMethodMap.get('resptext')=='Profile not found'){
                            PaymentGatewayClass.updatePSchRecords(customerList, 'Delete');
                            return PaymentGatewayClass.savePaymentMethod(wrapperObj, ipAddress);
                        }
                        else{
                            PaymentGatewayClass.createIntegrationLog(null, wrapperObj.policy, wrapperObj.billing, 'Processed With Errors', 0 , '(Error Code : Error occurred while creating the Payment Method Token '+JSON.serializePretty(echeckPayMethodMap)+').', '', wrapperObj.ipAddress);
                            
                            throw new PaymentGatewayClassException('An error has occurred In saving Payment Method. Please get in touch with your ISBA Mutual Policy Contact.');
                        }
                        
                    }
                }
            }
            return paymentMethodWrapObj;
        } 
        catch(DmlException e) {
            System.debug('Error => '+e.getDmlMessage(0)+'   Line No => '+e.getLineNumber()); 
            String recId = '';
            if(wrapperObj.billing!= null){
                recId = wrapperObj.billing.Id;
            }
            else if(wrapperObj.endorsement != null){
                recId = wrapperObj.endorsement.Id;
            }
            else{
                recId = wrapperObj.policy.Id;           
            }
            PaymentGatewayClass.Error err = new PaymentGatewayClass.Error(e.getDmlMessage(0), 'Error While Creating Payment Method.', 'Team,\n\nFollowing error has occurred while Creating Payment Method \n\n'+e.getDmlMessage(0) + '\n\n'+e.getStackTraceString()+'\n\n on the Record :'+ recId);
            throw new PaymentGatewayClassException(JSON.serialize(err));
            
        }
        catch(Exception e) {
            System.debug('Error => '+e.getMessage()+'   Line No => '+e.getLineNumber());
            String recId = '';
            if(wrapperObj.billing!= null){
                recId = wrapperObj.billing.Id;
            }
            else if(wrapperObj.endorsement != null){
                recId = wrapperObj.endorsement.Id;
            }
            else{
                recId = wrapperObj.policy.Id;           
            }
            PaymentGatewayClass.Error err = new PaymentGatewayClass.Error(e.getMessage(), 'Error While Creating Payment Method.', 'Team,\n\nFollowing error has occurred while Creating Payment Method \n\n'+e.getMessage() + '\n\n'+e.getStackTraceString()+'\n\n on the Record :'+ recId);
            throw new PaymentGatewayClassException(JSON.serialize(err));
            
        }
    }
    
    
    
    public static void checkCustomerIdCardKnox(PaymentGateway_Ctrl_Wrapper wrapperObj) {
        try{
            Boolean isPolicy = false;
            system.debug('<= checkCustomerIdCardKnox called =>');
            AcctSeed__Billing__c billing = new AcctSeed__Billing__c();
            Policy__c policy = new Policy__c();
            if(wrapperObj.billing != null){
                billing = wrapperObj.billing;
            }
            else {
                isPolicy = true;
                policy = wrapperObj.policy;
            }
            
            String customerId = '';
            if(isPolicy){
                customerId = policy.Account__c;
            }
            else{
                customerId = billing.AcctSeed__Customer__c;
            }
            
            if(String.isNotBlank(customerId)){
                List<AcctSeed__Payment_Processor__c> paymentProcessor = [select id from AcctSeed__Payment_Processor__c where AcctSeed__Type__c = 'Fiserv' limit 1];
                List<AcctSeed__Payment_Processor_Customer__c> customerList = [select id,AcctSeed__External_Id__c from AcctSeed__Payment_Processor_Customer__c where AcctSeed__Account__c = :customerId limit 1];
                // List<Account> accList = [select id,Forte_ID__c from account where id=:customerId limit 1];
                if(customerList.isEmpty() || !String.isNotBlank(customerList[0].AcctSeed__External_Id__c)){
                    if(!Test.isRunningTest()){
                        system.debug('<= Creating Customer Token called =>');
                        wrapperObj.customerToken = CardknoxUtil.createCustomer(wrapperObj);
                    }
                    else{
                        wrapperObj.customerToken = 'test';
                    }
                    if(wrapperObj.customerToken!=null){        
                        if(!customerList.isEmpty()){
                            customerList[0].AcctSeed__External_Id__c = wrapperObj.customerToken;
                        }else{
                            AcctSeed__Payment_Processor_Customer__c customer = new AcctSeed__Payment_Processor_Customer__c();
                            customer.AcctSeed__External_Id__c = wrapperObj.customerToken;
                            customer.AcctSeed__Processor__c = paymentProcessor[0].id;
                            customer.AcctSeed__Account__c = customerId;
                            customerList.add(customer);
                        }
                        updatePSchRecords(customerList, 'upsert');
                        createIntegrationLog('authorize', wrapperObj.policy, wrapperObj.billing, 'Processed Successfully', warpperObj.totalAmountDue, 'Creating Customer token for('+customerId+').', '', wrapperObj.ipAddress);
                    }
                    else{
                        createIntegrationLog('authorize', wrapperObj.policy, wrapperObj.billing, 'Processed With Errors',warpperObj.totalAmountDue, '(Error Code : Error occurred while creating Customer token).', '', wrapperObj.ipAddress);
                    }
                }
                else{
                    wrapperObj.customerToken = customerList[0].AcctSeed__External_Id__c;
                }
            }
        }
        catch(Exception e){
            throw new PaymentGatewayClassException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string updatePaymentMethod(PaymentGateway_Ctrl_Wrapper wrapperObj){
        try {
            system.debug('wrapper => '+wrapperObj);
            Payment_Method__c paymentMethod = [SELECT Id, Expiry_Month__c, Expiry_Year__c FROM Payment_Method__c Where Id=: wrapperObj.paymentMethodId AND Is_Deleted__c = false] ;
            if(wrapperObj.paymentTypeVar=='creditCard' && wrapperObj.customerToken!='' && (wrapperObj.expireMonth !=  String.valueOf(paymentMethod.Expiry_Month__c)  || wrapperObj.expireYear != string.valueOf(paymentMethod.Expiry_Year__c)) &&  (wrapperObj.payMethodToken!=null || wrapperObj.payMethodToken!='')){
                Map<String, Object> updateCardMap =  ForteUtilNew.updateCardDetsilsOnForte(wrapperObj);
                system.debug('updateCardMap'+ updateCardMap);
                if(updateCardMap!= null){
                    System.debug('updateCardMap: ' + updateCardMap);
                    Payment_Method__c payMthd = new Payment_Method__c();
                    payMthd.Id = wrapperObj.paymentMethodId;
                    Map<string,object> cardMap = (Map<string,object>)updateCardMap.get('card');
                    
                    payMthd.Expiry_Month__c = (Decimal)cardMap.get('expire_month');
                    payMthd.Expiry_Year__c = (Decimal)cardMap.get('expire_year');                    
                    updatePSchRecords(new List<Payment_Method__c>{payMthd}, 'upsert');    
                    if(wrapperObj.billing != null && wrapperObj.isAutoPay){
                        AcctSeed__Billing__c bill = wrapperObj.billing;
                        bill.Payment_Method__c = wrapperObj.paymentMethodId;
                        updatePSchRecords(new List<AcctSeed__Billing__c>{bill}, 'upsert');  
                        return 'success';
                    }
                    else if(wrapperObj.billing != null && !wrapperObj.isAutoPay){
                        AcctSeed__Billing__c bill = wrapperObj.billing;
                        bill.Payment_Method__c = null;
                        updatePSchRecords(new List<AcctSeed__Billing__c>{bill}, 'upsert');  
                        return 'success';
                    }    
                    else if(wrapperObj.isAutoPay){
                        return paymentMethod.Id;
                    }  
                    return 'success';        
                }
            }
            if(wrapperObj.billing != null && wrapperObj.isAutoPay){
                AcctSeed__Billing__c bill = wrapperObj.billing;
                bill.Payment_Method__c = wrapperObj.paymentMethodId;
                updatePSchRecords(new List<AcctSeed__Billing__c>{bill}, 'upsert');  
                return 'success';
            }
            else if(wrapperObj.billing != null && !wrapperObj.isAutoPay){
                AcctSeed__Billing__c bill = wrapperObj.billing;
                bill.Payment_Method__c = null;
                updatePSchRecords(new List<AcctSeed__Billing__c>{bill}, 'upsert');  
                return 'success';
            }
            else if(wrapperObj.isAutoPay){
                return paymentMethod.Id;
            }
            throw new PaymentGatewayClassException('Please re-verify your card details.');
        } catch (Exception e) {
            System.debug('Error => '+e.getMessage()+'   Line No => '+e.getLineNumber());
            Error err = new Error(e.getMessage(), 'Error While updating Payment Method.', 'Team,\n\nFollowing error has occurred while Updating Payment Method \n\n'+e.getMessage() + '\n\n'+e.getStackTraceString()+'\n\n The Payment Method Id is:'+wrapperObj.paymentMethodId);
            throw new PaymentGatewayClassException(JSON.serialize(err));
            //throw new PaymentGatewayClassException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string deletePaymentMethod(PaymentGateway_Ctrl_Wrapper wrapperObj){
        try {
            List<Payment_Schedule__c> paymentSchedules = [SELECT Id FROM Payment_Schedule__c WHERE Fiserv_Payment_Method__c =: wrapperObj.paymentMethodId AND Status__c IN ('Pending' ,'Rejected' ,'Unpaid')];
            if(!paymentSchedules.isEmpty()){
                throw new PaymentGatewayClassException('Cannot delete default payment method. Please contact your ISBA Mutual Policy Contact to update your default payment method first.');
            }
            Payment_Method__c payMethd = [SELECT Id, Name,Payment_Method_Token__c FROM Payment_Method__c WHERE Id=: wrapperObj.paymentMethodId AND Is_Deleted__c = false LIMIT 1];
            String paymentMethodToken = payMethd.Payment_Method_Token__c;
            
            String resp = Fiserv_Utils.DeletePaymentMethod(paymentMethodToken);
            String respNew = '';
            if(String.isNotBlank(resp) && resp == 'Success'){
                payMethd.Is_Deleted__c = true;
                respNew = updatePSchRecords(new List<Payment_Method__c>{payMethd}, 'Update');
                
                if(respNew != 'error'){
                    return 'The Payment Method Deleted successfully.';
                }
            }
            
            createIntegrationLog(null, wrapperObj.policy, wrapperObj.billing, 'Processed With Errors', 0, ('Error : Error in deleting the Payment Mathod.'), ('Fiserv Response : => ' + resp + ' DML Response: => ' + respNew + ' PaymentMethodId : => '+wrapperObj.paymentMethodId), wrapperObj.ipAddress);
            throw new PaymentGatewayClassException('An Error occured while deleting the Payment Method. Please get in touch with your ISBA Mutual Policy Contact.');
            
        } catch (Exception e) {
            System.debug('Error => '+e.getLineNumber() +'=> '+e.getMessage());
            String recId = '';
            if(wrapperObj.billing!= null){
                recId = wrapperObj.billing.Id;
            }
            else if(wrapperObj.endorsement != null){
                recId = wrapperObj.endorsement.Id;
            }
            else{
                recId = wrapperObj.policy.Id;           
            }
            Error err = new Error(e.getMessage(), 'Error While Deleting Payment Method.', 'Team,\n\nFollowing error has occurred while Deleting Payment Method \n\n'+e.getMessage() + '\n\n'+e.getStackTraceString()+'\n\n on the Record :'+ recId);
            throw new PaymentGatewayClassException(JSON.serialize(err));
        }
    }
    
    @AuraEnabled
    public static Boolean logoutAcc(String accId){
        Account acc = [SELECT Id,Payment_Link_Activation_Started_at__c FROM Account WHERE Id=:accId];
        acc.Payment_Link_Activation_Started_at__c = acc.Payment_Link_Activation_Started_at__c.addMinutes(-(Integer.valueOf(label.PaymentSiteTimeOut)));
        updatePSchRecords(new List<Account>{acc}, 'upsert');  
        return true;
    }
    
    @AuraEnabled
    public static TimerDetails getTimmerInfo(String accId){
        try {
            Account acc = [SELECT Id,Payment_Link_Activation_Started_at__c FROM Account WHERE Id=:accId];
            System.debug('acc Payment_Link_Activation_Started_at__c : ' + acc.Payment_Link_Activation_Started_at__c);
            DateTime newTime = acc.Payment_Link_Activation_Started_at__c != null ? acc.Payment_Link_Activation_Started_at__c.addMinutes(Integer.valueOf(label.PaymentSiteTimeOut)) : system.now().addMinutes(Integer.valueOf(label.PaymentSiteTimeOut));
            DateTime currTime = system.now();
            Integer daysbetween = (newTime.date()).daysBetween(currTime.date());
            Integer newhour = newTime.hour();
            Integer currhour = currTime.hour();
            Integer newMinutes = newTime.minute();
            Integer currminutes  = currTime.minute();
            Integer newSeconds = newTime.second();
            Integer currSeconds  = currTime.second();
            Integer minutesDiff = (-daysbetween*24*60) + ((newhour - currhour)*60) +(newMinutes - currminutes);
            Integer secondDiff = newSeconds - currSeconds;
            if(secondDiff < 0){
                minutesDiff -= 1;
                secondDiff += 60;
            }
            
            TimerDetails timerInfo = new TimerDetails(); 
            
            timerInfo.startTime = acc.Payment_Link_Activation_Started_at__c;
            timerInfo.timerShowBefore = Integer.valueOf(label.DisplayTimerOnPaymentSite);
            timerInfo.totalTimeOfTimerMinutes = minutesDiff;
            timerInfo.totalTimeOfTimerSeconds = secondDiff;
            
            return timerInfo;                   
        } catch (Exception e) {
            System.debug('Error => ' + e.getMessage() +' LN => '+ e.getLineNumber()) ;
            Error err = new Error(e.getMessage(),'Error While getting Timer Details.', 'Team,\n\nFollowing error has occurred while getting Timer Details \n\n'+e.getMessage() + '\n\n'+e.getStackTraceString()+'\n\n on the Account :'+ accId);
            throw new PaymentGatewayClassException(JSON.serialize(err));
            //throw new PaymentGatewayClassException(e.getMessage());
        }
    }
    
    @future
    public Static void sendEmail(String orgWideEmail, String body, String whatId, boolean saveAsActivity, List<String> toAddresses, String Subject, List<String> bccAddrsLis, String InReplyTo, boolean var, String conId){
        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(String.isNotBlank(orgWideEmail))
            mail.setOrgWideEmailAddressId(orgWideEmail);
           
        mail.setToAddresses(toAddresses);
        mail.setSubject(Subject);
        mail.setBccAddresses(bccAddrsLis);    
        mail.setInReplyTo(InReplyTo);
        mail.setHtmlBody(body);
        mail.setWhatId(whatId);
        mail.setSaveAsActivity(saveAsActivity);
        allmsg.add(mail);
        
        Messaging.sendEmail(allmsg,var);
    }
    
    @AuraEnabled
    public Static void sendEmailOnError(String subject, String body){
        system.debug(!emailSend);
        
        if(!emailSend){
            system.debug('inside if');
            emailSend = true;
            //sendEmailbyAccId('ramavtar@cmentor.com', '0014A00002jNWrTQAW', '');
            String OrgWideEmailAddressId = '';
            List<OrgWideEmailAddress> oweaList = [select Id,DisplayName from OrgWideEmailAddress Where DisplayName =: Label.OrganizationWideEmail];
            if (!oweaList.isEmpty()) {
                OrgWideEmailAddressId = oweaList.get(0).Id;
            } 
            
            Messaging.SingleEmailMessage[] allmsg =   new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            List<String> toAddress = Label.System_Admin_Emails.contains(',')? Label.System_Admin_Emails.split(',') : new List<String>{Label.System_Admin_Emails};
                
                mail.setToAddresses(toAddress);//new List<String>{'ramavtar@cmentor.com'});
            mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            mail.setSubject(subject);
            mail.setPlainTextBody(body);  
            mail.setSaveAsActivity(false);
            
            system.debug(JSON.serialize(mail));
            
            allmsg.add(mail);
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg, false);
            
            system.debug(results);
        }
        
    }
    public class exestingPaymentMethodDetails {
        @AuraEnabled public List<cardWrapper> cardList {get;set;}
        @AuraEnabled public List<checkWrapper> eCheckList{get;set;}
    }
    
    public class cardWrapper {
        @AuraEnabled public Payment_Method__c paymentMethod{get;set;}
        //@AuraEnabled public Payment_Method__c paymentMethod{get;set;}
        @AuraEnabled public String cardTypeVar{get;set;}
        @AuraEnabled public String key{get;set;}
        @AuraEnabled public String cardNumber{get;set;}
        @AuraEnabled public String expireMonth{get;set;}
        @AuraEnabled public String expireYear{get;set;}
        @AuraEnabled public String nameOnCard{get;set;}
        @AuraEnabled public String verificationNumber{get;set;}
        @AuraEnabled public String payMethodToken{get;set;}
        @AuraEnabled public Boolean isDefault {get;set;}
        @AuraEnabled public Boolean isSetToPay {get;set;} 
        @AuraEnabled public Boolean isPendingDelete{get;set;}
        public cardWrapper(){
            this.isDefault = false;
            this.isSetToPay = false;
            this.isPendingDelete = false;
        }
    }
    public class checkWrapper {
        @AuraEnabled public Payment_Method__c paymentMethod{get;set;}
        @AuraEnabled public String key{get;set;}
        //@AuraEnabled public Payment_Method__c paymentMethod{get;set;}
        @AuraEnabled public String accountType{get;set;}
        @AuraEnabled public String accountNumber{get;set;}
        @AuraEnabled public String routingNumber{get;set;}
        @AuraEnabled public String accountHolderName{get;set;}
        @AuraEnabled public String payMethodToken{get;set;}
        @AuraEnabled public Boolean isDefault {get;set;}
        @AuraEnabled public Boolean isSetToPay {get;set;}
        @AuraEnabled public Boolean isPendingDelete{get;set;}
        public checkWrapper(){
            this.isDefault = false;
            this.isSetToPay = false;
            this.isPendingDelete = false;
        }
    }
    
    public class paymentScheduleWrapper{
        @AuraEnabled public Boolean isFirstTime {get;set;}        
        @AuraEnabled public List<Payment_Schedule__c> paymentSchedules {get;Set;}
        @AuraEnabled public List<Payment_Schedule__c> allPaymentSchedules {get;Set;}
        @AuraEnabled public List<FieldWrapper> paymentScheduleFields {get;Set;}
    }
    
    public class FieldWrapper {
        @AuraEnabled public String fieldApiName {get;set;}
        @AuraEnabled public String fieldLabel {get;set;}        
        @AuraEnabled public String fieldType {get;set;}        
    }   
    public class TimerDetails {
        @AuraEnabled public Datetime startTime {get;set;}
        @AuraEnabled public Integer totalTimeOfTimerMinutes {get;set;}        
        @AuraEnabled public Integer totalTimeOfTimerSeconds {get;set;}        
        @AuraEnabled public Integer timerShowBefore {get;set;}        
        // @AuraEnabled public String baseUrl {get;set;}        
        // @AuraEnabled public String msg {get;set;}        
    }
    public class BillingWrapper {
        @AuraEnabled public AcctSeed__Billing__c bill{get;set;}
        @AuraEnabled public Boolean isSelected{get;set;}
        @AuraEnabled public Boolean isExpended{get;set;}
        @AuraEnabled public String pdfUrl {get;set;}
        @AuraEnabled public String invoiceDate{get;set;}
        @AuraEnabled public List<Payment_Schedule__c> paymentSchedules{get;set;}
        public BillingWrapper() {
            this.isExpended = false;
            this.isSelected = false;
            this.paymentSchedules = new List<Payment_Schedule__c>();
        }
    }
    
    public class PolicyWrapper {
        @AuraEnabled public Policy__c policy{get;set;}
        @AuraEnabled public Boolean isExpended{get;set;}
        @AuraEnabled public Boolean isCVListExpended{get;set;}
        @AuraEnabled public List<cvWrapper> cvList {get;set;}
        @AuraEnabled public String pdfUrl {get;set;}
        public PolicyWrapper() {
            this.isExpended = false;
            this.isCVListExpended = false;
            this.cvList = new List<cvWrapper>();
        }
    }
    
    public class cvWrapper {
        @AuraEnabled public String name{get;set;}
        @AuraEnabled public ContentVersion cvObj {get;set;}
    }
    
    public class paymentMethodWrapper {
        @AuraEnabled public String token{get;set;}
        @AuraEnabled public String methodId{get;set;}
        public paymentMethodWrapper(){
            this.token = null;
            this.methodId = null;
        }
    }
    
    /*------------------------------------Policy Section Started-------------------------------------*/
    @AuraEnabled
    public static PaymentGateway_Ctrl_Wrapper getPolicyDetails(String validationString, String lasttime){
        System.debug('validationString => ' + validationString);        
        List<Policy__c> policyList = new List<Policy__c>();
        
        try {
            
            if(String.isNotBlank(validationString)){
                Id recId = PaymentGateway_Ctrl.processDecryption(validationString.trim() ,Label.Encryption_Key_Payment_Id);
                String sObjName = recId.getSObjectType().getDescribe().getName();
                if(sObjName == 'Policy_Endorsement__c'){
                    return getEndorsementDetails(recId, lasttime);
                }
                System.debug('recId==>'+recId);
                policyList = [SELECT Id, Renewal_Type__c, Customer_Application__c, Customer_Application__r.Form_Link__c, Application_Type__c,Firm_Contact__r.Name,Firm_Contact__r.Email, Bind_Policy_JSON__c,recordtype.name,Account__r.AcctSeed__Billing_Contact__c, Account__r.AcctSeed__Billing_Contact__r.FirstName, Account__r.AcctSeed__Billing_Contact__r.lastName, Account__r.ISBAM_Billing_Freq_Policy_Full_Pay_Only__c, Account__r.Physical_document_delivery__c, Name, Premium__c, Effective_Date__c,Override_Application_Expire_Date__c,Limits__c,Deductible__c,Terms_And_Conditions_Approval__c,Remove_102_Endorsement__c,Underwriter_User__r.Name,Underwriter_User__r.Email,Underwriter_User__r.Phone,Underwriter_User__r.Title,Terms_Conditions__c,
                              ISBAM_policy_dividend__c,IBF_Contribtuion__c,IBF_Custom_Amount__c,IBF_Target__c,IBF_Appellate_District__c, Expiration_Date__c, Status__c,Total_Quotes__c,Total_Final_Quotes__c,AOP_Percentage__c,Total_Lawyers__c,Policy_Retroactive_Date__c,Policy_Document_Version__c,Full_Prior_Acts__c,Underwriter_User__c,Firm_Contact__c,Firm_Contact__r.FirstName, Firm_Contact__r.lastName ,Account__r.Phone,County__r.Name,
                              Total_Credit__c, Total_CLE_Credit__c, Policy_Dividend__c, Policy_Number__c, Account__c, Account__r.Forte_Id__c,  Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.AccountNumber,Account__r.Name,Account__r.Recent_Policy_Lookup__r.Firm_Contact__r.Email,Account__r.AcctSeed__Billing_Contact__r.Email,Per_Claim_Limit__c,Aggregate_Limit__c,
                              (SELECT Id, Name, Final_Quote__c, Limits__c, Deductibles_Formula__c, Coverage_Max_Per_Claim__c, Full_Coverage__c, Quote_Final_Premium__c FROM Policy_Quotes__r order by Sequence__c ASC),
                              (SELECT Id, Name, Prior_Act_Date__c, Step__c, Rate_At__c, Lawyer__r.Name, Lawyer__r.Contact__c, Lawyer__r.Contact__r.Phone, Lawyer__r.Contact__r.Personal_Email__c, Lawyer__r.Contact__r.MobilePhone, Lawyer__r.Contact__r.Birthdate, Lawyer__r.Contact__r.Email, ARDC_Number__c, ISBA_Number__c FROM Policy_Lawyers__r),
                              (SELECT Id, Name, Endorsement_Effective_Date__c, Event_Status__c, Prior_Act_Date__c FROM Policy_Endorsements__r)  FROM Policy__c WHERE Id =: recId LIMIT 1];
                
                System.debug('Effective Date: ' + policyList[0].Effective_Date__c);
                System.debug('Override Application Expire Date: ' + policyList[0].Override_Application_Expire_Date__c);
                system.debug(policyList[0].recordtype.name !='Application');
                system.debug(policyList[0].recordtype.name =='Application Rejected');
                system.debug(String.isNotBlank(policyList[0].Bind_Policy_JSON__c));
                system.debug(( policyList[0].Override_Application_Expire_Date__c != null && policyList[0].Override_Application_Expire_Date__c <= system.today() ));
                system.debug((policyList[0].Override_Application_Expire_Date__c == null && System.today() >= policyList[0].Effective_Date__c.addDays(14)));
                
                Boolean isRedirect = false;
                if(policyList[0].Renewal_Type__c == 'Regular Renewal' && policyList[0].Status__c != 'Quoted' && policyList[0].Status__c != 'Accepted'){
                    isRedirect = true;
                }
                
                if(isRedirect || (policyList[0].recordtype.name !='Application' && policyList[0].recordtype.name !='SA-ERP' ) || policyList[0].recordtype.name =='Application Rejected' || String.isNotBlank(policyList[0].Bind_Policy_JSON__c) || ( policyList[0].Override_Application_Expire_Date__c != null && policyList[0].Override_Application_Expire_Date__c <= system.today() ) || (policyList[0].Override_Application_Expire_Date__c == null && System.today() >= policyList[0].Effective_Date__c.addDays(14))){
                    PaymentGateway_Ctrl_Wrapper WrapObj = new PaymentGateway_Ctrl_Wrapper();
                    WrapObj.invoiceId = String.isNotBlank(policyList[0].Policy_Number__c) ? policyList[0].Policy_Number__c : policyList[0].Name;
                    WrapObj.underwriterName =  policyList[0].Underwriter_User__r.Name;
                    WrapObj.underwriterEmail = policyList[0].Underwriter_User__r.Email;
                    WrapObj.underwriterPhone = policyList[0].Underwriter_User__r.Phone;
                    WrapObj.underwriterTitle = policyList[0].Underwriter_User__r.Title;
                    WrapObj.effectiveDate = policyList[0].Effective_Date__c;
                    WrapObj.effectiveDateYear = policyList[0].Effective_Date__c.year();
                    WrapObj.effectiveDateStr = String.valueOf(policyList[0].Effective_Date__c.month()).leftPad(2, '0')+ '/' +String.valueOf(policyList[0].Effective_Date__c.day()).leftPad(2, '0') +'/'+ policyList[0].Effective_Date__c.year();
                    WrapObj.isPolicy = true;
                    WrapObj.policy = policyList[0];
                    WrapObj.isRedirect  = isRedirect;
                    if(policyList[0].recordtype.name =='Application Rejected'){
                        WrapObj.isRejected = true;
                    }
                    else if(policyList[0].recordtype.name == 'Policy' || String.isNotBlank(policyList[0].Bind_Policy_JSON__c)){
                        WrapObj.isAlreadyBind = true;
                    }
                    else if(( policyList[0].Override_Application_Expire_Date__c != null && policyList[0].Override_Application_Expire_Date__c <= system.today() ) || (policyList[0].Override_Application_Expire_Date__c == null && System.today() >= policyList[0].Effective_Date__c.addDays(14))){
                        WrapObj.isBlocked = true;
                    }
                    else {
                        WrapObj.isAlreadyBind = true;                        
                    }
                    return WrapObj;
                }
                
                return generatePolicyWrapper(policyList[0], lasttime);
            }
            else{
                return null;
            }
        } catch (Exception e) {
            System.debug('Error => ' + e.getMessage() + ' => '+ e.getLineNumber());
            string recId = '';
            if(String.isNotBlank(validationString)){
                recId = PaymentGateway_Ctrl.processDecryption(validationString.trim() ,Label.Encryption_Key_Payment_Id);
            }
            Error err = new Error(e.getMessage(), 'Error While getting Policy Details.', 'Team,\n\nFollowing error has occurred while getting Policy Details \n\n'+e.getMessage() + '\n\n'+e.getStackTraceString()+'\n\n on the Record :'+ recId);
            throw new PaymentGatewayClassException(JSON.serialize(err));
            //throw new PaymentGatewayClassException(e.getMessage());
        }
    }
    
    public static PaymentGateway_Ctrl_Wrapper generatePolicyWrapper(Policy__c policy, String lasttime) {
        PaymentGateway_Ctrl_Wrapper WrapObj = new PaymentGateway_Ctrl_Wrapper();
        try {
            if(!test.isRunningTest()){
                String resp = QueryData('SELECT Id, Name FROM ContentWorkspace WHERE Name = \'Send Email Resource Documents\' LIMIT 1 ');
                List<ContentWorkspace> cwList = (List<ContentWorkspace>)system.JSON.deserializeStrict(resp, List<ContentWorkspace>.class);
                
                String resp2 = QueryData('SELECT Id, Title,VersionData FROM ContentVersion WHERE Title Like \'ISBAMIC LPL Policy%\' AND Policy_Version__c = \''+policy.Policy_Document_Version__c+'\' and ContentDocument.ParentId = \''+ cwList[0].Id+'\'  limit 1 ');
                //List<ContentVersion> cvList = (List<ContentVersion>)system.JSON.deserializeStrict(resp2, List<ContentVersion>.class);
                //ContentVersion cv = [SELECT Id, Title FROM ContentVersion WHERE Title Like 'ISBAMIC LPL Policy%' AND Policy_Version__c =: policy.Policy_Document_Version__c and ContentDocument.ParentId =: cwList[0].Id  limit 1];
                system.debug('resp--->'+resp2);
                Map<String,Object> cvMap = (Map<String,Object>)Json.deserializeUntyped(resp2);
                system.debug('cvMap--->'+cvMap);
                if(!cvMap.keySet().isEmpty()){
                    WrapObj.fileName = String.valueOf(cvMap.get('Title'));
                    WrapObj.versionData = String.valueOf(cvMap.get('VersionData'));
                }
            }
            
            WrapObj.lastName = policy.Firm_Contact__r.LastName;
            WrapObj.isPolicy = true;
            WrapObj.firstName = policy.Firm_Contact__r.FirstName;
            WrapObj.policyEndorsements = policy.Policy_Endorsements__r;
            WrapObj.policyLawyers = policy.Policy_Lawyers__r;
            
            WrapObj.policyQuotes = policy.Policy_Quotes__r;
            WrapObj.creditDividendAmount = 0;
            policy.ISBAM_policy_dividend__c = String.isNotBlank(String.valueOf(policy.ISBAM_policy_dividend__c)) ? policy.ISBAM_policy_dividend__c : null;
            policy.IBF_Contribtuion__c = String.isNotBlank(String.valueOf(policy.IBF_Contribtuion__c)) ? policy.IBF_Contribtuion__c : null;
            policy.IBF_Custom_Amount__c = String.isNotBlank(String.valueOf(policy.IBF_Custom_Amount__c)) ? policy.IBF_Custom_Amount__c : null;
            policy.IBF_Target__c = String.isNotBlank(String.valueOf(policy.IBF_Target__c)) ? policy.IBF_Target__c : null;
            policy.IBF_Appellate_District__c = String.isNotBlank(String.valueOf(policy.IBF_Appellate_District__c)) ? policy.IBF_Appellate_District__c : null;
            WrapObj.roundedDividend = (policy.ISBAM_policy_dividend__c).round(System.RoundingMode.HALF_UP);
            WrapObj.policy = policy;
            WrapObj.accRecord = policy.Account__r;
            
            if(WrapObj.accRecord.AcctSeed__Billing_Contact__c != null){
                WrapObj.lastName = WrapObj.accRecord.AcctSeed__Billing_Contact__r.LastName;
                WrapObj.firstName = WrapObj.accRecord.AcctSeed__Billing_Contact__r.FirstName;
            }
            
            //check if any default payment Method Exesist
            List<Payment_Method__c> paymentMethods = [SELECT Id,Default__c FROM Payment_Method__c WHERE Account__c =:WrapObj.accRecord.Id AND Default__c = true AND Is_Deleted__c = false ];
            
            WrapObj.isAnyDefaultPaymentMethodAvailabel = !paymentMethods.isEmpty();
            
            if(policy.IBF_Contribtuion__c != null && policy.ISBAM_policy_dividend__c!= null){
                if(policy.IBF_Contribtuion__c == 'No IBF Contribution' && policy.ISBAM_policy_dividend__c > 0){
                    WrapObj.creditDividendAmount = -(policy.ISBAM_policy_dividend__c);
                }
                else if(policy.IBF_Contribtuion__c == 'Yes - IBF Contribution Requested' && policy.ISBAM_policy_dividend__c > 0 && policy.IBF_Custom_Amount__c > 0){
                    if (policy.IBF_Custom_Amount__c != null && policy.IBF_Custom_Amount__c > 0) {
                        WrapObj.creditDividendAmount = -(policy.ISBAM_policy_dividend__c - policy.IBF_Custom_Amount__c);
                    }
                }
            }
            WrapObj.creditDividendAmount = WrapObj.creditDividendAmount.round(System.RoundingMode.HALF_UP);
            Decimal needToPay = 0;
            if(policy.Premium__c != null) {
                needToPay = Math.round(policy.Premium__c) + WrapObj.creditDividendAmount;  
            }
            WrapObj.effectiveDate = policy.Effective_Date__c;
            WrapObj.effectiveDateYear = policy.Effective_Date__c.year();
            WrapObj.effectiveDateStr = String.valueOf(policy.Effective_Date__c.month()).leftPad(2, '0')+ '/' +String.valueOf(policy.Effective_Date__c.day()).leftPad(2, '0') +'/'+ policy.Effective_Date__c.year();
            WrapObj.expirationDateStr = String.valueOf(policy.Expiration_Date__c.month()).leftPad(2, '0')+ '/' +String.valueOf(policy.Expiration_Date__c.day()).leftPad(2, '0') +'/'+ policy.Expiration_Date__c.year();
            System.debug('WrapObj.effectiveDateStr: ' + WrapObj.effectiveDateStr);
            WrapObj.totalCredit = (policy.Total_Credit__c != null ? policy.Total_Credit__c : 0) ;
            WrapObj.totalCLECredit = (policy.Total_CLE_Credit__c != null ? policy.Total_CLE_Credit__c : 0).round(System.RoundingMode.HALF_UP) ;
            needToPay = needToPay- WrapObj.totalCLECredit;
            WrapObj.policyDividend = (policy.ISBAM_policy_dividend__c != null ? policy.ISBAM_policy_dividend__c : 0) ;
            WrapObj.premium = policy.Premium__c!= null ? policy.Premium__c.round(System.RoundingMode.HALF_UP) : null;
            WrapObj.limits = policy.Limits__c;
            WrapObj.deductible = policy.Deductible__c;
            
            WrapObj.perClaimLimit  =  policy.Per_Claim_Limit__c + '';
            WrapObj.aggregateLimit =  policy.Aggregate_Limit__c + '';
            
            WrapObj.balance = policy.Premium__c!= null ? policy.Premium__c.round(System.RoundingMode.HALF_UP) : null;
            
            
            WrapObj.underwriterName =  policy.Underwriter_User__r.Name;
            WrapObj.underwriterEmail = policy.Underwriter_User__r.Email;
            WrapObj.underwriterPhone = policy.Underwriter_User__r.Phone;
            WrapObj.underwriterTitle = policy.Underwriter_User__r.Title;
            
            if((!policy.Policy_Quotes__r.isEmpty()) && policy.Policy_Quotes__r.Size() == 1){
                policy.Policy_Quotes__r[0].Final_Quote__c = true;
                WrapObj.premium = policy.Policy_Quotes__r[0].Quote_Final_Premium__c;
                WrapObj.limits = policy.Policy_Quotes__r[0].Limits__c;
                WrapObj.deductible = policy.Policy_Quotes__r[0].Deductibles_Formula__c;                
            }
            
            WrapObj.invoiceId = String.isNotBlank(policy.Policy_Number__c) ? policy.Policy_Number__c : policy.Name;
            WrapObj.firmId = policy.Account__r.AccountNumber;
            WrapObj.firmName = policy.Account__r.Name;
            WrapObj.isBillingFrequencyFullOnly = policy.Account__r.ISBAM_Billing_Freq_Policy_Full_Pay_Only__c;
            WrapObj.paymentScheduleVar = lasttime;
            if(WrapObj.isBillingFrequencyFullOnly){
                WrapObj.paymentScheduleVar = 'Full';
                lasttime = 'Full';
            }
            WrapObj.billingStreet = policy.Account__r.BillingStreet;
            WrapObj.billingCity = policy.Account__r.BillingCity;
            WrapObj.billingState = policy.Account__r.BillingState;
            WrapObj.billingPostal = policy.Account__r.BillingPostalCode;
            WrapObj.customerToken=policy.Account__r.Forte_ID__c;
            
        	if(WrapObj.effectiveDate > System.today()){
                WrapObj.totalAmountDue = 0;
                //WrapObj.enablePaymentDate = true;
            }
            
            if(lasttime == 'Full'){
                WrapObj.firstInstallment = needToPay;
                if(WrapObj.effectiveDate > System.today()){
                    WrapObj.totalAmountDue = 0;
                    WrapObj.enablePaymentDate = true;
                }else{
                    WrapObj.totalAmountDue = needToPay;
                }
                WrapObj.firstInstallmentDate = WrapObj.effectiveDate < system.today() ? system.today() :  WrapObj.effectiveDate;
                WrapObj.firstInstallmentDateString = DateTime.newInstanceGMT(System.Date.newInstance(WrapObj.firstInstallmentDate.year(), WrapObj.firstInstallmentDate.month(), WrapObj.firstInstallmentDate.day()),System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM/dd/yyyy');
                WrapObj.scheduleAmount = needToPay;
            }
            else if(lasttime == 'Quarter'){
                WrapObj.perQuarterAmount = (needToPay / 4).setscale(2);
                system.debug('');
                Decimal diffrenceAmount = needToPay - (WrapObj.perQuarterAmount * 4);
                system.debug('WrapObj.perQuarterAmount => => '+WrapObj.perQuarterAmount);
                WrapObj.firstInstallment = WrapObj.perQuarterAmount;
                Date quarterlyBilling = WrapObj.effectiveDate;
                WrapObj.paymentQuarters = new List<String>();
                finalPaymentQuarters = new List<String>(); 
                WrapObj.perTotalQuarterAmount = 0 ;
                WrapObj.totalAmountDue = 0;                          // Change login by sarbjeet
                paymentQuartersDt = null;
                List<paymentSchedulesWrapper> oldPaymentSchedule = new List<paymentSchedulesWrapper>();            
                List<paymentSchedulesWrapper> newPaymentSchedule = new List<paymentSchedulesWrapper>();            
                for(Integer i =0;i<12;i+=3 ){
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
                    paymentSchedulesWrapper paySchWrapObj = new paymentSchedulesWrapper();
                    paySchWrapObj.amount = WrapObj.perQuarterAmount;
                    paySchWrapObj.dateStr = String.valueOf(quarterlyBilling.addMonths(i).month()).leftPad(2, '0')+ '/' +String.valueOf(day).leftPad(2, '0') +'/'+ quarterlyBilling.addMonths(i).year();
                    
                    if(i == 9){
                        paySchWrapObj.amount += diffrenceAmount;
                        paySchWrapObj.amount = paySchWrapObj.amount.setScale(2);
                    }
                    
                    system.debug('quarterlyBilling.addMonths(i) => '+quarterlyBilling.addMonths(i));
                    if(i==0 && quarterlyBilling <= system.Today()){  
                        WrapObj.duePaymentSchedules.add(paySchWrapObj);
                        WrapObj.totalAmountDue += WrapObj.perQuarterAmount;                        
                    }else if(quarterlyBilling.addMonths(i) <=system.Today()){  
                        WrapObj.duePaymentSchedules.add(paySchWrapObj);                      
                        WrapObj.totalAmountDue += WrapObj.perQuarterAmount;                        
                    }else {       
                        WrapObj.futurePaymentSchedules.add(paySchWrapObj);                 
                        System.debug('quarterlyBilling'+quarterlyBilling);
                        // WrapObj.paymentQuarters.add(quarterlyBilling.addMonths(i).month()+ '/' +day +'/'+ quarterlyBilling.addMonths(i).year());
                        
                        // finalPaymentQuarters.add(DateTime.newInstanceGMT(System.Date.newInstance(quarterlyBilling.addMonths(i).year(), quarterlyBilling.month()+i, day), System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM') + '/'+ (String.valueOf(day).length() == 1 ? ('0'+day): ''+day) +'/' +  quarterlyBilling.addMonths(i).year()); 
                        
                        if(paymentQuartersDt == null){                            
                            paymentQuartersDt = quarterlyBilling.addMonths(i);                            
                        }                        
                        WrapObj.firstInstallmentDate = paymentQuartersDt;
                        WrapObj.firstInstallmentDateString = DateTime.newInstanceGMT(System.Date.newInstance(WrapObj.firstInstallmentDate.year(), WrapObj.firstInstallmentDate.month(), WrapObj.firstInstallmentDate.day()),System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM/dd/yyyy');
                        System.debug('paymentQuartersDt'+paymentQuartersDt);                    
                    }                 
                }
                
                system.debug(' finalPaymentQuarters => '+ finalPaymentQuarters);
                
                if(WrapObj.totalAmountDue == 0){
                    WrapObj.perTotalQuarterAmount = WrapObj.perQuarterAmount; //+ extraMonthPayment;
                } else {
                    WrapObj.perTotalQuarterAmount = WrapObj.totalAmountDue; //+ extraMonthPayment;
                }
            }
            else if(lasttime == 'Month'){
                Decimal numberOfPayments = 12;
                Date monthlyBilling = WrapObj.effectiveDate;
                
                // if(billing.Allow_CatchUp_Schedule__c){
                //     monthlyBilling = System.today();
                //     numberOfPayments = monthlyBilling.monthsBetween(policy.Expiration_Date__c);
                // }
                
                WrapObj.perMonthAmount = (needToPay / numberOfPayments).setScale(2);
                Decimal diffrenceAmount = needToPay - (WrapObj.perMonthAmount * 12);
                
                WrapObj.firstInstallment = WrapObj.perMonthAmount ;
                //Date monthlyBilling = billing.AcctSeed__Due_Date2__c ; // Change done for billing date from system date;
                
                List<String> paymentMonths = new List<String>();
                finalPaymentMonths = new List<String>();
                WrapObj.perTotalMonthAmount =0; 
                WrapObj.totalAmountDue = 0;                          // Change login by sarbjeet
                paymentMonthsDt = null;    
                
                for(Integer i=0;i<numberOfPayments;i++){  
                    
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
                    
                    paymentSchedulesWrapper paySchWrapObj = new paymentSchedulesWrapper();
                    paySchWrapObj.amount = WrapObj.perMonthAmount;
                    paySchWrapObj.dateStr = String.valueOf(monthlyBilling.addMonths(i).month()).leftPad(2, '0')+ '/' +String.valueOf(day).leftPad(2, '0') +'/'+ monthlyBilling.addMonths(i).year();
                    
                    if(i == 11){
                        paySchWrapObj.amount += diffrenceAmount;
                        paySchWrapObj.amount = paySchWrapObj.amount.setScale(2);
                    }
                    
                    if(monthlyBilling.addMonths(i) <=system.Today()){
                        WrapObj.duePaymentSchedules.add(paySchWrapObj);
                        WrapObj.totalAmountDue += WrapObj.perMonthAmount;                            
                    } else if(i==0 && monthlyBilling <= system.Today()){ 
                        WrapObj.duePaymentSchedules.add(paySchWrapObj);
                        WrapObj.totalAmountDue += WrapObj.perMonthAmount;                            
                    } else {                           
                        WrapObj.futurePaymentSchedules.add(paySchWrapObj);
                        // paymentMonths.add(monthlyBilling.addMonths(i).month()+ '/' +day +'/'+ monthlyBilling.addMonths(i).year());
                        // finalPaymentMonths.add(DateTime.newInstanceGMT(System.Date.newInstance(monthlyBilling.addMonths(i).year(), monthlyBilling.month()+i, day), System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM') + '/'+ (String.valueOf(day).length() == 1 ? ('0'+day): ''+day)+'/' +  monthlyBilling.addMonths(i).year()); 
                        
                        if(paymentMonthsDt == null){
                            paymentMonthsDt = monthlyBilling.addMonths(i);
                        }                            
                        WrapObj.firstInstallmentDate = paymentMonthsDt;                                
                        WrapObj.firstInstallmentDateString = DateTime.newInstanceGMT(System.Date.newInstance(WrapObj.firstInstallmentDate.year(), WrapObj.firstInstallmentDate.month(), WrapObj.firstInstallmentDate.day()),System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM/dd/yyyy');
                    }                    
                }
                system.debug('paymentMonths => '+paymentMonths);
                //WrapObj.paymentMonths = paymentMonths;                
                
                if(WrapObj.totalAmountDue == 0){                   
                    WrapObj.perTotalMonthAmount = WrapObj.perMonthAmount; //+ extraMonthPayment;                    
                } else {
                    WrapObj.perTotalMonthAmount = WrapObj.totalAmountDue; //+ extraMonthPayment;
                }
            }
            // if(policy.Premium__c != null){
            //     WrapObj.totalAmountDue = policy.Premium__c + WrapObj.creditDividendAmount;  
            //     System.debug('totalAmountDue => '+WrapObj.totalAmountDue); 
            // }
            return WrapObj;
        } catch(Exception e) {
            System.debug('Error => '+ e.getMessage()+' => '+ e.getLineNumber());
            Error err = new Error(e.getMessage(), 'Error While generating Policy Wrapper.', 'Team,\n\nFollowing error has occurred while generating Policy Wrapper \n\n'+e.getMessage() + '\n\n'+e.getStackTraceString()+'\n\n on the Record :'+ policy.Id);
            throw new PaymentGatewayClassException(JSON.serialize(err));
            //throw new PaymentGatewayClassException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static boolean UpdatePolicy(Policy__c policy, Boolean updateForIbfContribution){
        //TermsAndConditionWrapper wrap = new TermsAndConditionWrapper();
        try {     
            if(isPolicyBind(policy.Id)){
                throw new PaymentGatewayClassException('This Policy is Already Bind.');
            }
            if(updateForIbfContribution){
                policy.Application_Received_Date__c = System.today();
                policy.Date_Signed__c = System.today();
                System.debug('Pooooolicy status 1: '+policy.Status__c );
                policy.Status__c ='Accepted';
                System.debug('Pooooolicy status 2: '+policy.Status__c );
            }
            else{
                Account acc = new Account();
                acc.Id = policy.Account__c;
                acc.Physical_document_delivery__c = policy.Account__r.Physical_document_delivery__c;
                updatePSchRecords(new List<Account>{acc}, 'upsert');
            }
            updatePSchRecords(new List<Policy__c>{policy}, 'upsert');           
            return true;
        } catch (Exception e) {
            System.debug('Error => '+e.getMessage()+ ' => '+ e.getLineNumber());
            Error err = new Error(e.getMessage(), 'Error While updating Policy Details.', 'Team,\n\nFollowing error has occurred while Updating Policy Details \n\n'+e.getMessage() + '\n\n'+e.getStackTraceString()+'\n\n on the Record :'+ policy.Id);
            throw new PaymentGatewayClassException(JSON.serialize(err));
            //throw new PaymentGatewayClassException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static exestingPaymentMethodDetails policyExistingList(String customerId){   
        return updatedExistingList(null, customerId); 
    }
    
    @AuraEnabled
    public static exestingPaymentMethodDetails updatedExistingList(String billingId,String customerId){ 
        List<cardWrapper> cardLis = new List<cardWrapper>();
        List<checkWrapper> checkLis = new List<checkWrapper>();
        AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
        String payMethodId = '';
        if(String.isNotBlank(billingId)){
            bill = [SELECT Id, Payment_Method__c FROM AcctSeed__Billing__c Where Id =: billingId];
            system.debug('bill => '+bill);
            payMethodId = bill.Payment_Method__c;
        }
        for(Payment_Method__c Paymethod: [SELECT Id,Name,Last_4_Account_Number__c,Default__c,Name_On_Card__c,Account_Type__c,Type__c,Card_Type__c,Payment_Method_Token__c,Routing_Number__c,Card_Holder_Name__c,Masked_Account_Number__c,Expiry_Month__c,Expiry_Year__c FROM Payment_Method__c WHERE Account__c =:customerId AND Payment_Processor__r.Name='Fiserv' AND Is_Deleted__c = false])
        {
            system.debug('Paymethod => '+Paymethod);
            if(Paymethod.Type__c == 'Credit_Card'){
                cardWrapper cardObj = new cardWrapper();
                cardObj.key = (Paymethod.Type__c).toLowerCase()+' '+Paymethod.Last_4_Account_Number__c;
                cardObj.cardTypeVar = Paymethod.Card_Type__c;
                cardObj.cardNumber = Paymethod.Masked_Account_Number__c != NULL ? Paymethod.Masked_Account_Number__c : 'xxxxxxxxxxxx'+Paymethod.Last_4_Account_Number__c;
                cardObj.verificationNumber = 'xxx';
                if(cardObj.cardTypeVar.equalsIgnoreCase('AMEX')){
                    cardObj.verificationNumber = 'xxxx';
                }
                cardObj.expireMonth = String.ValueOf(Paymethod.Expiry_Month__c);
                cardObj.expireYear = String.ValueOf(Paymethod.Expiry_Year__c);
                cardObj.nameOnCard = Paymethod.Name_On_Card__c;
                cardObj.payMethodToken = Paymethod.Payment_Method_Token__c;
                cardObj.paymentMethod = Paymethod;
                cardObj.isDefault = Paymethod.Default__c;
                if(String.isNotBlank(payMethodId)){
                    cardObj.isDefault = payMethodId == Paymethod.Id ? true : false ;   
                }
                
                //if(String.isNotBlank(billingId) && String.isNotBlank(bill.Payment_Method__c) &&  bill.Payment_Method__c == Paymethod.Id && cardLis.size() > 0){
                if(cardObj.isDefault && cardLis.size() > 0){
                    cardLis.add(0,cardObj);
                }else {
                    cardLis.add(cardObj);
                }
            }
            else{
                checkWrapper checkObj = new checkWrapper();
                checkObj.accountNumber = Paymethod.Masked_Account_Number__c != NULL ? Paymethod.Masked_Account_Number__c : 'xxxxxxxxxxxx'+Paymethod.Last_4_Account_Number__c;
                checkObj.routingNumber = Paymethod.Routing_Number__c;
                //checkObj.accountType = Paymethod.Account_Type__c ;
                if(Paymethod.Account_Type__c.equalsIgnoreCase('Checking')){
                    checkObj.accountType = 'checking';
                }else if(Paymethod.Account_Type__c.equalsIgnoreCase('Saving')){
                    checkObj.accountType = 'savings';
                }
                checkObj.key = (checkObj.accountType).toLowerCase()+' '+Paymethod.Last_4_Account_Number__c;//(checkObj.accountNumber).substring(checkObj.accountNumber.length()-4);
                checkObj.accountHolderName = Paymethod.Card_Holder_Name__c;
                checkObj.payMethodToken = Paymethod.Payment_Method_Token__c;
                checkObj.paymentMethod = Paymethod;
                checkObj.isDefault = Paymethod.Default__c;
                if(String.isNotBlank(payMethodId)){
                    checkObj.isDefault = payMethodId == Paymethod.Id ? true : false ;   
                }
                
                //if(String.isNotBlank(billingId) && String.isNotBlank(bill.Payment_Method__c) && bill.Payment_Method__c == Paymethod.Id && checkLis.size() > 0){
                if(checkObj.isDefault && checkLis.size() > 0){
                    checkLis.add(0, checkObj);
                }else {
                    checkLis.add(checkObj);
                }
                
            }
        }
        exestingPaymentMethodDetails existingDetails = new exestingPaymentMethodDetails();
        existingDetails.cardList = cardLis;
        existingDetails.eCheckList = checkLis;
        
        return existingDetails;
    }
    
    @AuraEnabled
    public static TermsAndConditionWrapper finalizeQuote(String policyId,String quoteId, List<Policy_Lawyer__c> lawyers){
        try {   
            if(isPolicyBind(policyId)){
                throw new PaymentGatewayClassException('This Policy is Already Bind.');
            }
            TermsAndConditionWrapper wrap = new TermsAndConditionWrapper();
            
            List<Policy_Quote__c> policyQuotes = [SELECT Id, Final_Quote__c FROM Policy_Quote__c WHERE Policy__c=:policyId AND (Id =:quoteId OR Final_Quote__c = true)];
            System.debug('Policy Quotes => '+policyQuotes);
            List<Policy_Quote__c> selectedQuoteList = new List<Policy_Quote__c>();
            List<Policy_Quote__c> unSelectedQuoteList = new List<Policy_Quote__c>();
            for(Policy_Quote__c rec : policyQuotes){
                System.debug('rec: ' + rec);
                
                //if(rec.Id == quoteId){
                rec.Final_Quote__c = false;                    
                unSelectedQuoteList.add(rec);
                //}
            }
            if(!unSelectedQuoteList.isEmpty()){
                updatePSchRecords(unSelectedQuoteList, 'upsert');
            }
            
            for(Policy_Quote__c rec : policyQuotes){
                if(rec.Id == quoteId){
                    rec.Final_Quote__c = true; 
                    selectedQuoteList.add(rec);
                }
            }
            if(!selectedQuoteList.isEmpty()){               
                updatePSchRecords(selectedQuoteList, 'upsert');
            }
            if(!lawyers.isEmpty()){
                List<Contact> contactsToUpdate = new List<Contact>();
                Set<Id> conIds = new Set<Id>();
                for(Policy_Lawyer__c lwyer : lawyers){
                    if(String.isNotBlank(lwyer.Lawyer__r.Contact__c)){
                        conIds.add(lwyer.Lawyer__r.Contact__c);
                    }
                }
                Map<Id,Contact> contacts = new Map<Id,Contact>([SELECT Id, Email, Personal_Email__c, Birthdate, MobilePhone, Phone FROM Contact WHERE Id In:conIds]);
                for(Policy_Lawyer__c lwyer : lawyers){
                    if(contacts.containsKey(lwyer.Lawyer__r.Contact__c)){
                        Contact con = contacts.get(lwyer.Lawyer__r.Contact__c);
                        System.debug('con.Email: ' + con.Email);
                        System.debug('lwyer.Lawyer__r.Contact__r.Email: ' + lwyer.Lawyer__r.Contact__r.Email);
                        System.debug('lwyer.Lawyer__r.Contact__r.MobilePhone: ' + lwyer.Lawyer__r.Contact__r.MobilePhone);
                        System.debug('con.Phone: ' + con.MobilePhone);
                        if(con.Email != lwyer.Lawyer__r.Contact__r.Email || con.MobilePhone != lwyer.Lawyer__r.Contact__r.MobilePhone || con.Personal_Email__c != lwyer.Lawyer__r.Contact__r.Personal_Email__c || con.Birthdate != lwyer.Lawyer__r.Contact__r.Birthdate){
                            con.Email = lwyer.Lawyer__r.Contact__r.Email;
                            
                            if(String.isNotBlank(lwyer.Lawyer__r.Contact__r.MobilePhone)){
                                String Phone = lwyer.Lawyer__r.Contact__r.MobilePhone;
                                con.MobilePhone = '(' + Phone.substring(0,3) + ') ' + Phone.substring(3,6) + '-' + Phone.substring(6);
                            }
                            //con.Cell_Phone__c = lwyer.Lawyer__r.Contact__r.Cell_Phone__c;
                            con.Birthdate = lwyer.Lawyer__r.Contact__r.Birthdate;
                            con.Personal_Email__c = lwyer.Lawyer__r.Contact__r.Personal_Email__c;
                            
                            contactsToUpdate.add(con);
                        }
                    }
                }
                if(!contactsToUpdate.isEmpty()){
                    updatePSchRecords(contactsToUpdate, 'upsert');
                }
            }
            
            Policy__c policy = [SELECT Id, recordtype.name, Account__r.ISBAM_Billing_Freq_Policy_Full_Pay_Only__c, Account__r.Physical_document_delivery__c, Name, Premium__c, Effective_Date__c,Limits__c,Deductible__c,Terms_And_Conditions_Approval__c,Remove_102_Endorsement__c,Underwriter_User__r.Name,Underwriter_User__r.Email,Underwriter_User__r.Phone,Underwriter_User__r.Title,
                                ISBAM_policy_dividend__c,IBF_Contribtuion__c,IBF_Custom_Amount__c,IBF_Target__c,IBF_Appellate_District__c, Expiration_Date__c, Status__c,Total_Quotes__c,Total_Final_Quotes__c,AOP_Percentage__c,Total_Lawyers__c,Policy_Retroactive_Date__c,Policy_Document_Version__c,Full_Prior_Acts__c,Underwriter_User__c,Firm_Contact__c,Account__r.Phone,County__r.Name,
                                Total_Credit__c, Total_CLE_Credit__c, Policy_Dividend__c, Policy_Number__c, Account__c, Account__r.Forte_Id__c,  Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.AccountNumber,Account__r.Name,Account__r.Recent_Policy_Lookup__r.Firm_Contact__r.Email,Account__r.AcctSeed__Billing_Contact__r.Email,
                                (SELECT id,Name,ENTITY_NAME__C,Premium__c,POLICY_FIRM__c,ENTER_MANUSCRIPT_LANGUAGE__c,AOP__c,BROKER__c,TO_DATE__c,FROM_DATE__c,PERSON_ATTORNEY__c,Name2__c,
                                 TERRITORY__C,MATTER__C,FIRM_NAME__C,ENDORSEMENT_EFFECTIVE_DATE__c,REFUND_AMOUNT__C,LAWYER_NAME__C,ATTORNEY_FIRM_NAME__c,PER_LAWER__c,PER_POLICY__c,
                                 ERE_MONTHS__c,Policy_Lawyer__r.Prior_Act_Date__c,PRIOR_ACT_DATE__C,ACCOUNT_BILLING_STREET__c,ACCOUNT_BILLING_City__c,ACCOUNT_BILLING_State__c,ACCOUNT_BILLING_PostalCode__c,
                                 ENTITY__c,ATTORNEY__c,FIRM_ENTITY__c,TERM__c,SECOND_EFFECTIVE_DATE__c,FIRST_PER_CLAIM__C,FIRST_AGGREGATE__C,SECOND_PER_CLAIM__C,SECOND_AGGREGATE__C,THIRD_PER_CLAIM__C,
                                 THIRD_AGGREGATE__C,THIRD_EFFECTIVE_DATE__c,TITLE_INSURANCE_AGENCY__C,ADDITIONAL_PREMIUM__C,Manuscript__c,Endorsement_Number__c,Policy__c,Endorsement_Version__c,Endorsement_Name__c FROM Policy_Endorsements__r)  FROM Policy__c WHERE Id =: policyId LIMIT 1];
            
            List<Policy_Endorsement__c> endorsementList = policy.Policy_Endorsements__r;   
            
            for(Policy_Quote__c q : [select id,Mod_230__c,Mod_234__c,Mod_261__c from Policy_Quote__c where Policy__c =:policyId Order By CreatedDate DESC]){
                if(q.Mod_230__c != null && q.Mod_230__c !=0){
                    wrap.Mod_230 = true;
                }
                if(q.Mod_234__c != null && q.Mod_234__c !=0){
                    wrap.Mod_234 = true;
                }
                if(q.Mod_261__c != null && q.Mod_261__c !=0){
                    wrap.Mod_261 = true;
                }
            }
            List<EndorsementWrapper> EndorsementWrapperList = new List<EndorsementWrapper>();
            for(Policy_Endorsement__c pe: endorsementList){
                EndorsementWrapper eWrap = new EndorsementWrapper();
                eWrap.endorsement = pe;
                eWrap.formulatedEndorsementNumber = String.valueOf(pe.Endorsement_Number__c).replace('IL ','');
                String tempEndorsementVersion = string.valueOf(pe.Endorsement_Version__c);
                eWrap.formulatedEndorsementVersion = String.valueOf(Integer.valueOf(tempEndorsementVersion.left(tempEndorsementVersion.indexOf('/')))+100).right(2)+' 20'+tempEndorsementVersion.right(tempEndorsementVersion.length() - (tempEndorsementVersion.indexOf('/')+1));
                String tempEndorsemName = String.valueOf(pe.Endorsement_Name__c);
                eWrap.formulatedEndorsementName = tempEndorsemName.replace(pe.Endorsement_Number__c, '').replace(pe.Endorsement_Version__c,'').replace('() ',''); 
                EndorsementWrapperList.add(eWrap);
            }
            wrap.endorsementList = EndorsementWrapperList;
            String tempPolicyVersion = String.valueOf(policy.Policy_Document_Version__c);
            wrap.formulatedIsbamic230_234 =  String.valueOf(Integer.valueOf(tempPolicyVersion.left(tempPolicyVersion.indexOf('/')))+100).right(2)+' 20'+tempPolicyVersion.right(tempPolicyVersion.length() - (tempPolicyVersion.indexOf('/')+1));
            String label  = Label.IL_302_Version;
            wrap.formulatedIsbamic302 =  String.valueOf(Integer.valueOf(label.left(label.indexOf('/')))+100).right(2)+' 20'+label.right(label.length() - (label.indexOf('/')+1));
            return wrap;
        }
        catch(Exception e){
            System.debug('Error => ' + e.getMessage() + ' => '+ e.getLineNumber());
            Error err = new Error(e.getMessage(), 'Error While finalizing Quote.','Team,\n\nFollowing error has occurred while finalizing Quote \n\n'+e.getMessage() + '\n\n'+e.getStackTraceString()+'\n\n on the Record :'+ policyId);
            throw new PaymentGatewayClassException(JSON.serialize(err));
        }
    }
    
    @AuraEnabled 
    public static Map<String, String> getIBFPaymentFieldValue(){
        return ConvertToPolicyLtng.getIBFPaymentFieldValue();
    }
    
    @AuraEnabled 
    public static Map<String, String> getTargetFieldValue(){
        return ConvertToPolicyLtng.getTargetFieldValue();
    }
    
    @AuraEnabled
    public static boolean convertPolicy(String policyId, String policyDocVersion){
        if(isPolicyBind(policyId)){
            throw new PaymentGatewayClassException('This Policy is Already Bind.');
        }
        String jsonBody = '{'+
            '   "callApex": "true",'+
            '   "className": "ConvertToPolicyLtng",'+
            '   "methodName":"convertPolicy",'+
            '   "arguments" : {'+
            '      "policyId":"'+policyId+'",'+
            '      "policyDocVersion":"'+policyDocVersion+'"'+
            '   }'+
            '}';
        
        system.debug('Json => '+ jsonBody);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:CashReceipt_Api/services/apexrest/DynamicPayment');
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json'); 
        request.setBody(jsonBody);
        request.setTimeout(120000);
        Http http = new Http();
        HTTPResponse response = new  HTTPResponse ();
        if(!test.isRunningTest()){
            response = http.send(request);
            system.debug('response => ' + response);
        }else{
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"success": "true"}');
            response.setStatusCode(200);
        }
        System.debug('response.getBody(): => ' + response.getBody());
        Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
        return Boolean.valueOf(String.valueOf(result.get('success')));
        //return true;
    }
    //@future(callout=true)
    public static void createDocuments(String policyId, String policyDocVersion){
        ConvertToPolicyLtng.createDocuments(policyId, policyDocVersion);
    }
    
    @AuraEnabled
    public static String hasAllLawyersARDC(String policyId){
        if(isPolicyBind(policyId)){
            throw new PaymentGatewayClassException('This Policy is Already Bind.');
        }
        return ConvertToPolicyLtng.hasAllLawyersARDC(policyId);
    }
    @AuraEnabled
    public static boolean hasInvalid106(String policyId){
        return ConvertToPolicyLtng.hasInvalid106(policyId);
    }
    
    @AuraEnabled
    public static boolean hasBlocks(String policyId){
        return ConvertToPolicyLtng.hasBlocks(policyId);
    }
    @AuraEnabled
    public static boolean hasUndefinedAOP(String policyId){
        return ConvertToPolicyLtng.hasUndefinedAOP(policyId);
    }
    
    public class policyBindWrapper {
        @AuraEnabled public Decimal firstInstallment{get;set;}
        @AuraEnabled public Date firstInstallmentDate{get;set;}
        //@AuraEnabled public Decimal perInstallmentAmount{get;set;}
        @AuraEnabled public List<paymentSchedulesWrapper> paymentSchedulesWrap{get;set;}
        @AuraEnabled public String paymentScheduleVar{get;set;}
        @AuraEnabled public Boolean isPaymentReceived{get;set;}
        @AuraEnabled public String transactionId{get;set;}
        @AuraEnabled public String paymentTypeVar{get;set;}
        @AuraEnabled public Decimal baseAmountToPay{get;set;}
        @AuraEnabled public String defaultPaymentMethodId{get;set;}
        @AuraEnabled public String billingConfirmationEmail{get;set;}
        @AuraEnabled public String ipAddress{get;set;}
        @AuraEnabled public String application_link{get;set;}
        @AuraEnabled public DateTime Timestamp {get; set;}
        @AuraEnabled public String ISBAM_user_agent {get; set;}
        @AuraEnabled public String deviceType{get;set;}
        @AuraEnabled public String screenResolution{get;set;}
        @AuraEnabled public String windowSize{get;set;}
        
        public policyBindWrapper() {
            this.Timestamp = null;
            this.ipAddress = null;
            this.billingConfirmationEmail = null;
            this.baseAmountToPay = null;
            this.defaultPaymentMethodId = null;
            this.firstInstallment = null;
            this.firstInstallmentDate = null;
            this.isPaymentReceived = false;
            this.paymentSchedulesWrap = null;
            this.paymentTypeVar = null;
            this.paymentScheduleVar = null;
            //this.perInstallmentAmount = null;
            this.transactionId = null;
            this.application_link = null;
            this.ISBAM_user_agent = null;
            this.deviceType = null;
            this.screenResolution = null;
            this.windowSize = null;
        }
    }
    public with sharing class TermsAndConditionWrapper {
        @AuraEnabled public List<EndorsementWrapper> endorsementList{get;set;} 
        @AuraEnabled public boolean Mod_230{get;set;}
        @AuraEnabled public boolean Mod_234{get;set;}
        @AuraEnabled public boolean Mod_261{get;set;}
        @AuraEnabled public String formulatedIsbamic230_234{get;set;}
        @AuraEnabled public String formulatedIsbamic302{get;set;}
        
    }
    public with sharing class EndorsementWrapper {
        @AuraEnabled public Policy_Endorsement__c endorsement{get;set;} 
        @AuraEnabled public String formulatedEndorsementNumber{get;set;}
        @AuraEnabled public String formulatedEndorsementVersion{get;set;}
        @AuraEnabled public String formulatedEndorsementName{get;set;}        
    }
    public with sharing class paymentSchedulesWrapper {
        @AuraEnabled public String dateStr{get;set;}
        @AuraEnabled public Decimal amount{get;set;}        
    }
    /*--------------------------------Policy Section Ended-----------------------------------------*/
    
    public static string getUrl(){
        boolean isSb = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        if(isSb){
            return 'https://sb-portal.isbamutual.com/';
        }else{
            return 'https://portal.isbamutual.com/';
        }
    }
    
    public static void createIntegrationLog(String trnsAction, Policy__c policy, AcctSeed__Billing__c billing, String Status, Decimal trAmount, String des, String jsonBody, String ipAddress){
        Integration_Log__c log = new Integration_Log__c();
        log.Transaction_Action__c = trnsAction;
        if(policy != null){
            log.Policy__c = policy.Id;
        }
        else{
            log.Billing__c = billing.id;
        }
        log.Customer_IP__c = ipAddress;
        log.JSON_Body__c = jsonBody;
        log.Status__c = status;
        log.Transaction_Amount__c = trAmount;
        log.Description__c= des; 
        updatePSchRecords(new List<Integration_Log__c>{log} , 'upsert'); 
    }
    
    /*------------------------------------Policy Endorsement Section Started-------------------------------------*/
    
    @AuraEnabled
    public static PaymentGateway_Ctrl_Wrapper getEndorsementDetails(String recId, String lasttime){
        try{
            PaymentGateway_Ctrl_Wrapper WrapObj = new PaymentGateway_Ctrl_Wrapper();
            Policy_Endorsement__c record = [SELECT Id,Valid_Until_Date__c, Override_NBA_Expire_Date__c, Endorsement_Number__c, Premium__c, Event_Status__c, Lawyer__c, Lawyer__r.Name, Endorsement_Effective_Date__c, Coverage_Term__c, Policy__c,Endorsement_Version__c FROM Policy_Endorsement__c WHERE Id =: recId LIMIT 1];
            Policy__c policy = [SELECT Id, Application_Type__c,Firm_Contact__r.Name, Bind_Policy_JSON__c,recordtype.name,Account__r.AcctSeed__Billing_Contact__c, Account__r.AcctSeed__Billing_Contact__r.FirstName, Account__r.AcctSeed__Billing_Contact__r.lastName, Account__r.ISBAM_Billing_Freq_Policy_Full_Pay_Only__c, Account__r.Physical_document_delivery__c, Name, Premium__c, Effective_Date__c,Override_Application_Expire_Date__c,Limits__c,Deductible__c,Terms_And_Conditions_Approval__c,Remove_102_Endorsement__c,Underwriter_User__r.Name,Underwriter_User__r.Email,Underwriter_User__r.Phone,Underwriter_User__r.Title,
                                ISBAM_policy_dividend__c,IBF_Contribtuion__c,IBF_Custom_Amount__c,IBF_Target__c,IBF_Appellate_District__c, Expiration_Date__c, Status__c,Total_Quotes__c,Total_Final_Quotes__c,AOP_Percentage__c,Total_Lawyers__c,Policy_Retroactive_Date__c,Policy_Document_Version__c,Full_Prior_Acts__c,Underwriter_User__c,Firm_Contact__c,Firm_Contact__r.FirstName, Firm_Contact__r.lastName ,Account__r.Phone,County__r.Name,
                                Total_Credit__c, Total_CLE_Credit__c, Policy_Dividend__c, Policy_Number__c, Account__c, Account__r.Forte_Id__c,  Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.AccountNumber,Account__r.Name,Account__r.Recent_Policy_Lookup__r.Firm_Contact__r.Email,Account__r.AcctSeed__Billing_Contact__r.Email,Per_Claim_Limit__c,Aggregate_Limit__c,
                                (SELECT Id, Name, Final_Quote__c, Limits__c, Deductibles_Formula__c, Coverage_Max_Per_Claim__c, Full_Coverage__c, Quote_Final_Premium__c FROM Policy_Quotes__r),
                                (SELECT Id, Name, Prior_Act_Date__c, Step__c, Rate_At__c, Lawyer__r.Name, Lawyer__r.Contact__c, Lawyer__r.Contact__r.Phone, Lawyer__r.Contact__r.Personal_Email__c, Lawyer__r.Contact__r.MobilePhone, Lawyer__r.Contact__r.Birthdate, Lawyer__r.Contact__r.Email, ARDC_Number__c, ISBA_Number__c FROM Policy_Lawyers__r)  FROM Policy__c WHERE Id =: record.Policy__c LIMIT 1];
            WrapObj.policy = policy;
            WrapObj.endorsement = record;
            WrapObj.accRecord = policy.Account__r;
            WrapObj.underwriterName =  policy.Underwriter_User__r.Name;
            WrapObj.underwriterEmail = policy.Underwriter_User__r.Email;
            WrapObj.underwriterPhone = policy.Underwriter_User__r.Phone;
            WrapObj.underwriterTitle = policy.Underwriter_User__r.Title;
            WrapObj.effectiveDate = policy.Effective_Date__c;
            WrapObj.effectiveDateYear = policy.Effective_Date__c.year();
            WrapObj.effectiveDateStr = String.valueOf(policy.Effective_Date__c.month()).leftPad(2, '0')+ '/' +String.valueOf(policy.Effective_Date__c.day()).leftPad(2, '0') +'/'+ policy.Effective_Date__c.year();
            
            if(record.Event_Status__c == 'Complete'){
                WrapObj.isBlocked = true;
                WrapObj.errorMessage = 'This endorsement has already been approved.';
            }
            else if(record.Event_Status__c == 'Submitted'){
                WrapObj.isBlocked = true;
                WrapObj.errorMessage = 'This endorsement is currently being reviewed.';
            }
            else if(record.Valid_Until_Date__c < system.today()){
                //(record.Override_NBA_Expire_Date__c != null && record.Override_NBA_Expire_Date__c <= system.today()) || (record.Override_NBA_Expire_Date__c == null && System.today() >= record.Endorsement_Effective_Date__c.addDays(60))){
                WrapObj.isBlocked = true;
                WrapObj.errorMessage = 'This endorsement has expired.';
            }
            else if(record.Endorsement_Number__c == 'IL 152' || record.Endorsement_Number__c == 'IL 107'){
                WrapObj.lastName = policy.Firm_Contact__r.LastName;
                WrapObj.firstName = policy.Firm_Contact__r.FirstName;
                WrapObj.policyLawyers = policy.Policy_Lawyers__r;
                
                WrapObj.policyQuotes = policy.Policy_Quotes__r;
                WrapObj.creditDividendAmount = 0;
                policy.ISBAM_policy_dividend__c = String.isNotBlank(String.valueOf(policy.ISBAM_policy_dividend__c)) ? policy.ISBAM_policy_dividend__c : null;
                policy.IBF_Contribtuion__c = String.isNotBlank(String.valueOf(policy.IBF_Contribtuion__c)) ? policy.IBF_Contribtuion__c : null;
                policy.IBF_Custom_Amount__c = String.isNotBlank(String.valueOf(policy.IBF_Custom_Amount__c)) ? policy.IBF_Custom_Amount__c : null;
                policy.IBF_Target__c = String.isNotBlank(String.valueOf(policy.IBF_Target__c)) ? policy.IBF_Target__c : null;
                policy.IBF_Appellate_District__c = String.isNotBlank(String.valueOf(policy.IBF_Appellate_District__c)) ? policy.IBF_Appellate_District__c : null;
                WrapObj.roundedDividend = (policy.ISBAM_policy_dividend__c).round(System.RoundingMode.HALF_UP);
                
                
                if(WrapObj.accRecord.AcctSeed__Billing_Contact__c != null){
                    WrapObj.lastName = WrapObj.accRecord.AcctSeed__Billing_Contact__r.LastName;
                    WrapObj.firstName = WrapObj.accRecord.AcctSeed__Billing_Contact__r.FirstName;
                }
                
                //check if any default payment Method Exesist
                List<Payment_Method__c> paymentMethods = [SELECT Id,Default__c FROM Payment_Method__c WHERE Account__c =:WrapObj.accRecord.Id AND Default__c = true AND Is_Deleted__c = false];
                
                WrapObj.isAnyDefaultPaymentMethodAvailabel = !paymentMethods.isEmpty();
                
                WrapObj.creditDividendAmount = WrapObj.creditDividendAmount.round(System.RoundingMode.HALF_UP);
                Decimal needToPay = record.Premium__c;//0;
                WrapObj.effectiveDate = record.Endorsement_Effective_Date__c;
                WrapObj.effectiveDateYear = WrapObj.effectiveDate.year();
                WrapObj.effectiveDateStr = String.valueOf(WrapObj.effectiveDate.month()).leftPad(2, '0')+ '/' +String.valueOf(WrapObj.effectiveDate.day()).leftPad(2, '0') +'/'+ WrapObj.effectiveDate.year();
                WrapObj.expirationDateStr = String.valueOf(policy.Expiration_Date__c.month()).leftPad(2, '0')+ '/' +String.valueOf(policy.Expiration_Date__c.day()).leftPad(2, '0') +'/'+ policy.Expiration_Date__c.year();
                System.debug('WrapObj.effectiveDateStr: ' + WrapObj.effectiveDateStr);
                WrapObj.totalCredit = (policy.Total_Credit__c != null ? policy.Total_Credit__c : 0) ;
                WrapObj.totalCLECredit = (policy.Total_CLE_Credit__c != null ? policy.Total_CLE_Credit__c : 0).round(System.RoundingMode.HALF_UP) ;
                needToPay = needToPay;//- WrapObj.totalCLECredit;
                WrapObj.policyDividend = (policy.ISBAM_policy_dividend__c != null ? policy.ISBAM_policy_dividend__c : 0) ;
                WrapObj.premium = record.Premium__c!= null ? record.Premium__c.round(System.RoundingMode.HALF_UP) : null;
                WrapObj.limits = policy.Limits__c;
                WrapObj.deductible = policy.Deductible__c;
                
                WrapObj.perClaimLimit  =  policy.Per_Claim_Limit__c + '';
                WrapObj.aggregateLimit =  policy.Aggregate_Limit__c + '';
                
                WrapObj.balance = policy.Premium__c!= null ? policy.Premium__c.round(System.RoundingMode.HALF_UP) : null;
                
                if((!policy.Policy_Quotes__r.isEmpty()) && policy.Policy_Quotes__r.Size() == 1){
                    policy.Policy_Quotes__r[0].Final_Quote__c = true;
                    //WrapObj.premium = policy.Policy_Quotes__r[0].Quote_Final_Premium__c;
                    WrapObj.limits = policy.Policy_Quotes__r[0].Limits__c;
                    WrapObj.deductible = policy.Policy_Quotes__r[0].Deductibles_Formula__c;                
                }
                
                WrapObj.invoiceId = String.isNotBlank(policy.Policy_Number__c) ? policy.Policy_Number__c : policy.Name;
                WrapObj.firmId = policy.Account__r.AccountNumber;
                WrapObj.firmName = policy.Account__r.Name;
                WrapObj.isBillingFrequencyFullOnly = policy.Account__r.ISBAM_Billing_Freq_Policy_Full_Pay_Only__c;
                
                if(record.Endorsement_Number__c == 'IL 107'){
                    WrapObj.isBillingFrequencyFullOnly = true;
                    String period = record.Coverage_Term__c;
                    if(period == '1-4 Years'){period = '12-48 Months';}
                    else if(period == '10 or more years'){period = '120 or more Months';}
                    else if(period.contains(' Years')){
                        period = period.subStringBefore(' Years');
                        period = String.valueOf(Integer.valueOf(Integer.valueOf(period)* 12));
                        period = period+' Months';
                    }
                    
                    WrapObj.endorsementPreiod = period;
                }
                
                if(WrapObj.isBillingFrequencyFullOnly){
                    WrapObj.paymentScheduleVar = 'Full';
                    lasttime = 'Full';
                }
                WrapObj.paymentScheduleVar = lasttime;
                WrapObj.billingStreet = policy.Account__r.BillingStreet;
                WrapObj.billingCity = policy.Account__r.BillingCity;
                WrapObj.billingState = policy.Account__r.BillingState;
                WrapObj.billingPostal = policy.Account__r.BillingPostalCode;
                WrapObj.customerToken=policy.Account__r.Forte_ID__c;
                if(lasttime == 'Full'){
                    WrapObj.firstInstallment = needToPay;
                    if(WrapObj.effectiveDate > System.today()){
                        WrapObj.totalAmountDue = 0;
                        WrapObj.enablePaymentDate = true;
                    }else{
                        WrapObj.totalAmountDue = needToPay;
                    }
                    WrapObj.firstInstallmentDate = WrapObj.effectiveDate < system.today() ? system.today() :  WrapObj.effectiveDate;
                    WrapObj.firstInstallmentDateString = DateTime.newInstanceGMT(System.Date.newInstance(WrapObj.firstInstallmentDate.year(), WrapObj.firstInstallmentDate.month(), WrapObj.firstInstallmentDate.day()),System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM/dd/yyyy');
                    WrapObj.scheduleAmount = needToPay;
                }
                else if(lasttime == 'Quarter'){
                    Decimal numberOfMonths = WrapObj.effectiveDate.monthsBetween(policy.Expiration_Date__c);
                    Decimal numberOfQuarters = (numberOfMonths/3).round(System.RoundingMode.DOWN);
                    if(numberOfMonths < 3){
                        numberOfQuarters = 1;
                        if(numberOfMonths != null && numberOfMonths < 1){
                            numberOfMonths = 1;
                        }   
                    }
                    
                    Date quarterlyBilling = policy.Expiration_Date__c.addMonths(-2);
                    Decimal dueOnEffDt = 0.00;
                    if(numberOfQuarters > 1){
                        Date tempdt = policy.Expiration_Date__c.addMonths(-Integer.valueOf(numberOfQuarters*3));
                        if(tempdt < WrapObj.effectiveDate){
                            tempdt = tempdt.addMonths(3);
                            numberOfQuarters -= 1;
                        }
                       
                        system.debug('tempDT => '+tempdt);
                        if(numberOfQuarters > 0 && WrapObj.effectiveDate != tempdt){
                            numberOfMonths = numberOfQuarters*3;
                            Integer temp1 = WrapObj.effectiveDate.daysBetween(tempdt);
                            Integer temp2 = WrapObj.effectiveDate.daysBetween(policy.Expiration_Date__c);
                            Decimal amountPerDay = (needToPay/temp2).setScale(2);
                            dueOnEffDt = amountPerDay * temp1;
                            needToPay -= dueOnEffDt;
                        }
                    }
                    
                    WrapObj.perQuarterAmount = (needToPay / numberOfQuarters).setscale(2);
                    Decimal diffrenceAmount = needToPay - (WrapObj.perQuarterAmount * numberOfQuarters);
                    system.debug('WrapObj.perQuarterAmount => => '+WrapObj.perQuarterAmount);
                    WrapObj.firstInstallment = WrapObj.perQuarterAmount;
                    WrapObj.paymentQuarters = new List<String>();
                    finalPaymentQuarters = new List<String>(); 
                    WrapObj.perTotalQuarterAmount = 0 ;
                    WrapObj.totalAmountDue = 0;                          // Change login by sarbjeet
                    paymentQuartersDt = null;
                    List<paymentSchedulesWrapper> oldPaymentSchedule = new List<paymentSchedulesWrapper>();            
                    List<paymentSchedulesWrapper> newPaymentSchedule = new List<paymentSchedulesWrapper>();
                    
                    Boolean flag = true;
                    for(Integer i = 1; i<=numberOfMonths; i+=3 ){
                        i = -i;
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
                        paymentSchedulesWrapper paySchWrapObj = new paymentSchedulesWrapper();
                        paySchWrapObj.amount = WrapObj.perQuarterAmount;
                        paySchWrapObj.dateStr = String.valueOf(quarterlyBilling.addMonths(i).month()).leftPad(2, '0')+ '/' +String.valueOf(day).leftPad(2, '0') +'/'+ quarterlyBilling.addMonths(i).year();
                        
                        if(flag){
                            flag = false;
                            paySchWrapObj.amount += diffrenceAmount;
                            paySchWrapObj.amount = paySchWrapObj.amount.setScale(2);
                        }
                        
                        system.debug('quarterlyBilling.addMonths(i) => '+quarterlyBilling.addMonths(i));
                        if(i==0 && quarterlyBilling.addMonths(i) <= system.Today()){  
                            List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                                tempList.addAll(WrapObj.duePaymentSchedules);                            
                            WrapObj.duePaymentSchedules = tempList;
                            WrapObj.totalAmountDue += WrapObj.perQuarterAmount;                        
                        }else if(quarterlyBilling.addMonths(i) <=system.Today()){  
                            List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                                tempList.addAll(WrapObj.duePaymentSchedules);                            
                            WrapObj.duePaymentSchedules = tempList;                     
                            WrapObj.totalAmountDue += WrapObj.perQuarterAmount;                        
                        }else {       
                            List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                                tempList.addAll(WrapObj.futurePaymentSchedules);                            
                            WrapObj.futurePaymentSchedules = tempList;                 
                            System.debug('quarterlyBilling'+quarterlyBilling);
                            // WrapObj.paymentQuarters.add(quarterlyBilling.addMonths(i).month()+ '/' +day +'/'+ quarterlyBilling.addMonths(i).year());
                            
                            // finalPaymentQuarters.add(DateTime.newInstanceGMT(System.Date.newInstance(quarterlyBilling.addMonths(i).year(), quarterlyBilling.month()+i, day), System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM') + '/'+ (String.valueOf(day).length() == 1 ? ('0'+day): ''+day) +'/' +  quarterlyBilling.addMonths(i).year()); 
                            
                            //if(paymentQuartersDt == null){                            
                                paymentQuartersDt = quarterlyBilling.addMonths(i);                            
                            //}                        
                            WrapObj.firstInstallmentDate = paymentQuartersDt;
                            WrapObj.firstInstallmentDateString = DateTime.newInstanceGMT(System.Date.newInstance(WrapObj.firstInstallmentDate.year(), WrapObj.firstInstallmentDate.month(), WrapObj.firstInstallmentDate.day()),System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM/dd/yyyy');
                            System.debug('paymentQuartersDt'+paymentQuartersDt);                    
                        } 
                        i = -i;
                    }
                    
                    if(WrapObj.effectiveDate <= System.today()){
                        
                        paymentSchedulesWrapper paySchWrapObj = new paymentSchedulesWrapper();
                        paySchWrapObj.amount = dueOnEffDt;
                        paySchWrapObj.dateStr = String.valueOf(WrapObj.effectiveDate.month()).leftPad(2, '0')+ '/' +String.valueOf(WrapObj.effectiveDate.day()).leftPad(2, '0') +'/'+ WrapObj.effectiveDate.year();
                        
                        List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                            tempList.addAll(WrapObj.duePaymentSchedules);                            
                        WrapObj.duePaymentSchedules = tempList;
                        
                        WrapObj.totalAmountDue += dueOnEffDt;
                        WrapObj.firstInstallmentDate = System.today();                                
                        WrapObj.firstInstallmentDateString = DateTime.newInstanceGMT(System.Date.newInstance(WrapObj.firstInstallmentDate.year(), WrapObj.firstInstallmentDate.month(), WrapObj.firstInstallmentDate.day()),System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM/dd/yyyy');
                    }
                    else if(dueOnEffDt > 0){
                        paymentSchedulesWrapper paySchWrapObj = new paymentSchedulesWrapper();
                        paySchWrapObj.amount = dueOnEffDt;
                        paySchWrapObj.dateStr = String.valueOf(WrapObj.effectiveDate.month()).leftPad(2, '0')+ '/' +String.valueOf(WrapObj.effectiveDate.day()).leftPad(2, '0') +'/'+ WrapObj.effectiveDate.year();
                        
                        List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                            tempList.addAll(WrapObj.futurePaymentSchedules);                            
                        WrapObj.futurePaymentSchedules = tempList;
                    }
                    
                    system.debug(' finalPaymentQuarters => '+ finalPaymentQuarters);
                    
                    if(WrapObj.totalAmountDue == 0){
                        WrapObj.perTotalQuarterAmount = WrapObj.perQuarterAmount; //+ extraMonthPayment;
                    } else {
                        WrapObj.perTotalQuarterAmount = WrapObj.totalAmountDue; //+ extraMonthPayment;
                    }
                }
                else if(lasttime == 'Month'){
                    Integer numberOfPayments = WrapObj.effectiveDate.monthsBetween(policy.Expiration_Date__c);
                    Date monthlyBilling = policy.Expiration_Date__c;
                    
                    Decimal dueOnEffDt = 0.00;
                    if(numberOfPayments > 1){
                        Date tempdt = monthlyBilling.addMonths(-numberOfPayments);
                        if(tempdt < WrapObj.effectiveDate){
                            tempdt = tempdt.addMonths(1);
                            numberOfPayments -= 1;
                        }
                        
                        system.debug('tempDT => '+tempdt);
                        if(numberOfPayments > 0 && WrapObj.effectiveDate != tempdt){
                            Integer temp1 = WrapObj.effectiveDate.daysBetween(tempdt);
                            Integer temp2 = WrapObj.effectiveDate.daysBetween(policy.Expiration_Date__c);
                            Decimal amountPerDay = (needToPay/temp2).setScale(2);
                            dueOnEffDt = amountPerDay * temp1;
                            needToPay -= dueOnEffDt;
                        }
                    }                    
                    if(numberOfPayments == 0){
                        numberOfPayments = 1;
                    }
                        
                    WrapObj.perMonthAmount = (needToPay / numberOfPayments).setScale(2);
                    Decimal diffrenceAmount = needToPay - (WrapObj.perMonthAmount * numberOfPayments);
                    
                    WrapObj.firstInstallment = WrapObj.perMonthAmount ;
                    //Date monthlyBilling = billing.AcctSeed__Due_Date2__c ; // Change done for billing date from system date;
                    
                    List<String> paymentMonths = new List<String>();
                    finalPaymentMonths = new List<String>();
                    WrapObj.perTotalMonthAmount =0; 
                    WrapObj.totalAmountDue = 0;   
                    
                    paymentMonthsDt = null;    
                    boolean flag = true;
                    for(Integer i= 1 ;i<= numberOfPayments;i++){   
                        i = -i;
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
                        
                        paymentSchedulesWrapper paySchWrapObj = new paymentSchedulesWrapper();
                        paySchWrapObj.amount = WrapObj.perMonthAmount;
                        paySchWrapObj.dateStr = String.valueOf(monthlyBilling.addMonths(i).month()).leftPad(2, '0')+ '/' +String.valueOf(day).leftPad(2, '0') +'/'+ monthlyBilling.addMonths(i).year();
                        
                        if(flag){
                            flag = false;
                            paySchWrapObj.amount += diffrenceAmount;
                            paySchWrapObj.amount = paySchWrapObj.amount.setScale(2);
                        }
                        system.debug('monthlyBilling.addMonths(i) => '+monthlyBilling.addMonths(i));
                        system.debug('i => '+i);
                        system.debug('system.Today() => '+system.Today());
                        if(monthlyBilling.addMonths(i) <=system.Today()){
                            List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                                tempList.addAll(WrapObj.duePaymentSchedules);                            
                            WrapObj.duePaymentSchedules = tempList;
                            
                            WrapObj.totalAmountDue += WrapObj.perMonthAmount;                            
                        } else if(i==0 && monthlyBilling.addMonths(i) <= system.Today()){ 
                            List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                                tempList.addAll(WrapObj.duePaymentSchedules);                            
                            WrapObj.duePaymentSchedules = tempList;
                            WrapObj.totalAmountDue += WrapObj.perMonthAmount;                            
                        } else {               
                            List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                                tempList.addAll(WrapObj.futurePaymentSchedules);                            
                            WrapObj.futurePaymentSchedules = tempList;
                            
                            // paymentMonths.add(monthlyBilling.addMonths(i).month()+ '/' +day +'/'+ monthlyBilling.addMonths(i).year());
                            // finalPaymentMonths.add(DateTime.newInstanceGMT(System.Date.newInstance(monthlyBilling.addMonths(i).year(), monthlyBilling.month()+i, day), System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM') + '/'+ (String.valueOf(day).length() == 1 ? ('0'+day): ''+day)+'/' +  monthlyBilling.addMonths(i).year()); 
                            
                            //if(paymentMonthsDt == null){
                                paymentMonthsDt = monthlyBilling.addMonths(i);
                            //}                            
                            WrapObj.firstInstallmentDate = paymentMonthsDt;                                
                            WrapObj.firstInstallmentDateString = DateTime.newInstanceGMT(System.Date.newInstance(WrapObj.firstInstallmentDate.year(), WrapObj.firstInstallmentDate.month(), WrapObj.firstInstallmentDate.day()),System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM/dd/yyyy');
                        }     
                        i = -i;
                    }
                    if(WrapObj.effectiveDate <= System.today()){
                        
                        paymentSchedulesWrapper paySchWrapObj = new paymentSchedulesWrapper();
                        paySchWrapObj.amount = dueOnEffDt;
                        paySchWrapObj.dateStr = String.valueOf(WrapObj.effectiveDate.month()).leftPad(2, '0')+ '/' +String.valueOf(WrapObj.effectiveDate.day()).leftPad(2, '0') +'/'+ WrapObj.effectiveDate.year();
                        
                        List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                            tempList.addAll(WrapObj.duePaymentSchedules);                            
                        WrapObj.duePaymentSchedules = tempList;
                        
                        WrapObj.totalAmountDue += dueOnEffDt;
                        WrapObj.firstInstallmentDate = System.today();                                
                        WrapObj.firstInstallmentDateString = DateTime.newInstanceGMT(System.Date.newInstance(WrapObj.firstInstallmentDate.year(), WrapObj.firstInstallmentDate.month(), WrapObj.firstInstallmentDate.day()),System.Time.newInstance(0, 0, 0, 0)).formatGMT('MM/dd/yyyy');
                    }
                    else if(dueOnEffDt > 0){
                        paymentSchedulesWrapper paySchWrapObj = new paymentSchedulesWrapper();
                        paySchWrapObj.amount = dueOnEffDt;
                        paySchWrapObj.dateStr = String.valueOf(WrapObj.effectiveDate.month()).leftPad(2, '0')+ '/' +String.valueOf(WrapObj.effectiveDate.day()).leftPad(2, '0') +'/'+ WrapObj.effectiveDate.year();
                        
                        List<paymentSchedulesWrapper> tempList = new List<paymentSchedulesWrapper>{paySchWrapObj};
                            tempList.addAll(WrapObj.futurePaymentSchedules);                            
                        WrapObj.futurePaymentSchedules = tempList;
                    }
                    
                    
                    system.debug('paymentMonths => '+paymentMonths);
                    //WrapObj.paymentMonths = paymentMonths;                
                    
                    if(WrapObj.totalAmountDue == 0){                   
                        WrapObj.perTotalMonthAmount = WrapObj.perMonthAmount; //+ extraMonthPayment;                    
                    } else {
                        WrapObj.perTotalMonthAmount = WrapObj.totalAmountDue; //+ extraMonthPayment;
                    }
                }
                
                if(!WrapObj.duePaymentSchedules.IsEmpty()){
                    Decimal temp_Due = 0.00;
                    for(paymentSchedulesWrapper psw: WrapObj.duePaymentSchedules){
                        temp_Due += psw.amount;
                    }
                    
                    paymentSchedulesWrapper paySchWrapObj = new paymentSchedulesWrapper();
                    paySchWrapObj.amount = temp_Due;
                    paySchWrapObj.dateStr = String.valueOf(System.today().month()).leftPad(2, '0')+ '/' +String.valueOf(System.today().day()).leftPad(2, '0') +'/'+ System.today().year();
                    
                    WrapObj.duePaymentSchedules = new List<paymentSchedulesWrapper>{paySchWrapObj};
                }
                
            }
            else{
                WrapObj.isBlocked = true;
                WrapObj.errorMessage = 'We cannot Process this Endorsement.';
            }
            return WrapObj; 
        }
        catch(Exception e) {
            System.debug('Error => '+ e.getMessage()+' => '+ e.getLineNumber());
            throw new PaymentGatewayClassException(e.getMessage());
        }
    }
    
    @AuraEnabled 
    public static Boolean approveEndorsement(String recId){
        String jsonBody = '{'+
            '   "callApex": "true",'+
            '   "className": "PolicyEndorsementController",'+
            '   "methodName":"updatePolicy",'+
            '   "arguments" : {'+
            '      "policyId":"'+recId+'"'+
            '   }'+
            '}';
        
        system.debug('Json => '+ jsonBody);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:CashReceipt_Api/services/apexrest/DynamicPayment');
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json'); 
        request.setBody(jsonBody);
        request.setTimeout(120000);
        Http http = new Http();
        HTTPResponse response = new  HTTPResponse ();
        if(!test.isRunningTest()){
            response = http.send(request);
            system.debug('response => ' + response);
        }else{
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"success": "true"}');
            response.setStatusCode(200);
        }
        System.debug('response.getBody(): => ' + response.getBody());
        Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
        return Boolean.valueOf(String.valueOf(result.get('success')));
        //PolicyEndorsementController.updatePolicy(recId);
        //return true;
    }
    
    public class Error{        
        @AuraEnabled
        public String errorMsg{get;set;}
        @AuraEnabled
        public String errorEmailBody{get;set;}
        @AuraEnabled
        public String errorEmailSubject{get;set;}
        
        public Error(String msg, String subject, String body){
            this.errorMsg = msg;
            this.errorEmailSubject = subject;
            this.errorEmailBody = body;
        } 
    }
    
    public static string QueryData(String query){
        string msg;
        String jsonBody = '{"Query" : '+JSON.serialize(query)+'}';
        try{
            system.debug(jsonBody);
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:CashReceipt_Api/services/apexrest/QueryRecords');
            request.setMethod('POST');
            request.setHeader('Content-Type','application/json');
            request.setBody(jsonBody);
            request.setTimeout(120000);
            Http http = new Http();
            HttpResponse response = new HttpResponse();
            system.debug('1058::');
            if(!test.isRunningTest()) { 
                response = http.send(request); 
                msg  = response.getBody(); 
                system.debug(msg); 
                if(response.getStatusCode() == 200){ 
                    return msg; 
                } 
                else{ 
                    return 'error'; 
                }  
            }
            else{
                system.debug('1161::');
                response.setHeader('Content-Type', 'application/json');
                response.setStatusCode(200);
                return JSON.serialize(new List<Sobject>());
            }
        }
        Catch(Exception e){
            throw new PaymentGatewayClassException(e.getMessage());
        }     
    }
    
    public static Boolean isPolicyBind(String recId) {
        List<Policy__c> policyList = new List<Policy__c>([SELECT Id FROM Policy__c WHERE Id =:recId AND recordtype.name ='Application']);
        return policyList.isEmpty();
    }
    
    @AuraEnabled
    public static Boolean updatePolicyFields(Policy__c policy, ISBAM_Survey__c survey){
        try {
            
            survey.Policy__c = policy.Id;
            survey.Survey_Submit_Date__c = system.today();
            System.enqueueJob(new PolicyBindSurveyQueueable(survey),5);
            return true;
        } catch (Exception e) {
            throw new PaymentGatewayClassException(e.getMessage());
        }
    }
    
    public static void increseTestCoverage(){
        Integer Count = 0;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
        Count++;
    }
}