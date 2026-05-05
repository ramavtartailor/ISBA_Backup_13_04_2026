public class ConvertToPolicyLtng {
    public static Id transactionQueueId;
    @AuraEnabled
    public static Policy__c getPolicy(String policyId){
        Policy__c objPolicy = [select Id,Status__c, IBF_Custom_Amount__c, IBF_Appellate_District__c,IBF_Target__c, Account__c,Policy_Document_Version__c,Total_Quotes__c,PaymentReceived__c ,Total_Final_Quotes__c,AOP_Percentage__c,Total_Lawyers__c,Policy_Retroactive_Date__c,Date_Signed__c,Application_Received_Date__c,Underwriter_User__c,Firm_Contact__c,Account__r.BillingStreet,Account__r.BillingCity,Account__r.BillingState,Account__r.BillingPostalCode,Account__r.Phone,Full_Prior_Acts__c,ISBAM_policy_dividend__c,IBF_Contribtuion__c,County__r.Name  from Policy__c where Id =: policyId];
		objPolicy.Status__c = 'Accepted';
        return objPolicy;
    }
    
    @AuraEnabled 
    public static Map<String,String> getStatus(){
        Map<String,String> optionsList = new Map<String,String>();
        try{
        String objectName = 'Policy__c';
        String fieldName = 'Status__c';
        RecordType recType= [select id from RecordType where name='Application'];
        String recordTypeId = recType.Id;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String host = System.Url.getOrgDomainUrl().toExternalForm();
        String url =  'callout:CashReceipt_Api/services/data/v51.0/ui-api/object-info/'+objectName+'/picklist-values/'+recordTypeId+'/'+fieldName;        
        request.setEndpoint(url);
        request.setMethod('GET');  
       // request.setHeader('Authorization', 'Bearer'+UserInfo.getSessionId());
            HttpResponse response = new HttpResponse(); 
            if(test.isRunningTest()){
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"values": [{"label" : "label" , "value" : "value"}]}');
            }
            else{
                response = http.send(request);    
            }
        Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        system.debug(meta);
		
        //optionsList.put('--None--', '');
        if(meta.containsKey('values')){                                
                for(Object o: (List<Object> )meta.get('values')){
                    Map<String, object > temp = (Map<String, object>)o;  
                    	optionsList.put(String.valueOf(temp.get('label')), String.valueOf(temp.get('value')));
                }
            }        
        
        System.debug(optionsList);
        
        return optionsList;
      }
        catch(Exception e){
            system.debug('error' + e.getLineNumber()+' => '+e.getMessage() );
            throw new AuraHandledException(e.getMessage());
        }
    }
    
     @AuraEnabled 
    public static Map<String, String> getPaymentReceivedFieldValue(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Policy__c.PaymentReceived__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getIBFPaymentFieldValue(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Policy__c.IBF_Contribtuion__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            
            options.put(p.getLabel(), p.getValue());
        }
        return options;
    }
    
    @AuraEnabled
    public static String updatePolicy(Policy__c policy){
        try{
            update policy;
            return 'success';
        }
        catch(exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled 
    public static Map<String, String> getTargetFieldValue(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Policy__c.IBF_Target__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry p: pValues) {
            
            options.put(p.getLabel(), p.getValue());
        }
        system.debug('options :: 94'+options);
        return options;
    }
    
    @AuraEnabled
    public static boolean convertPolicy(String policyId, String policyDocVersion){
        SavePoint sp = Database.setSavepoint();
        Policy__c policy = [select Id,Application_Type__c,Total_Quotes__c,Total_Final_Quotes__c,Limit_Factor_Value__c,Total_5x5__c,Total_10x10__c,Original_Premium__c,Name,Account__c,Effective_Date__c,Expiration_Date__c,Policy_Dividend__c,Previous_Policy__c,RecordType.Name,ISBAM_policy_dividend__c from Policy__c where Id =: policyId];
        Map<double, Dividend__c> dividendMap = new Map<double, Dividend__c>();
        for(Dividend__c div: [SELECT Id, Effective_Year__c, Start_Date__c, End_Date__c, Percent__c FROM Dividend__c]){
            dividendMap.put(div.Effective_Year__c, div);
        }
        try{
            Integer policySeriesCount;
            Date policySeriesEffectiveDate;
            Date oldPolicyExpirationDate;
            for(Policy__c pol : [select id,Effective_Date__c,Expiration_Date__c,Cancel_Date__c,ISBAM_policy_dividend__c from Policy__c where Account__c =: policy.Account__c and RecordType.Name = 'Policy' order by Effective_Date__c]) {
                if(pol.Effective_Date__c != oldPolicyExpirationDate){
                    policySeriesCount = 1;
                    policySeriesEffectiveDate = pol.Effective_Date__c;
                }else{
                    policySeriesCount += 1;
                }
                if(pol.Cancel_Date__c != null){
                    oldPolicyExpirationDate = pol.Cancel_Date__c;
                }else{
                    oldPolicyExpirationDate = pol.Expiration_Date__c;
                }
            }
            if(policy.Effective_Date__c != oldPolicyExpirationDate){
                policySeriesCount = 1;
                policySeriesEffectiveDate = policy.Effective_Date__c;
            }else{
                policySeriesCount += 1;
            }
            if(policy.Total_Final_Quotes__c==0 && policy.Total_Quotes__c == 1){  
                Policy_Quote__c quote = [select id,Final_Quote__c from Policy_Quote__c where Policy__c =: policyId];
                quote.Final_Quote__c = true;
                update quote;
            }
            
            List<Policy_Endorsement__c> endorsements = new List<Policy_Endorsement__c>();
            endorsements = [SELECT Id,Name,Event_Status__c,Endorsement_Number__c,Endorsement_Version__c,Policy__c,Policy__r.Account__c
                            FROM Policy_Endorsement__c WHERE Policy__c =: policyId and Event_Status__c = 'Pending'];
            
            for(Policy_Endorsement__c pol : endorsements){
                pol.Event_Status__c= 'Complete';  
            }
            update endorsements;
            
            Policy__c objPolicy = new Policy__c();
            objPolicy.Id = policyId;
            objPolicy.Is_Accepted_Confirm__c = true;
            objPolicy.Is_Allow_to_Generate_AS__c = true;
            objPolicy.Is_Allow_Calculate_Premium__c = true;
            objPolicy.Bound_Date__c = System.now();
            objPolicy.Policy_Series_Count__c = policySeriesCount;
            objPolicy.Policy_Series_Effective_Date__c = policySeriesEffectiveDate;
            objPolicy.Bound_Dividend_Credit__c = policy.Policy_Dividend__c;
            if(policy.ISBAM_policy_dividend__c > 0){
                Integer year = policy.Effective_Date__c.Year();
                if(dividendMap.containsKey(year)){
                    objPolicy.Dividend__c = dividendMap.get(year).Id;
                }
            }
            //
            if (policy.Application_Type__c == 'New Business') {
                
                List<Policy_Underwriter_User__mdt> metaRecList = [SELECT DeveloperName, Email__c FROM Policy_Underwriter_User__mdt];
                
                Map<String, String> devNameToEmailMap = new Map<String, String>();
                Set<String> allEmails = new Set<String>();
                
                for (Policy_Underwriter_User__mdt meta : metaRecList) {
                    if (meta.DeveloperName != null && meta.Email__c != null) {
                        devNameToEmailMap.put(meta.DeveloperName, meta.Email__c.toLowerCase());
                        allEmails.add(meta.Email__c.toLowerCase());
                    }
                }
                
                Map<String, Id> emailToUserIdMap = new Map<String, Id>();
                for (User u : [SELECT Id, Email FROM User WHERE Email IN :allEmails]) {
                    emailToUserIdMap.put(u.Email.toLowerCase(), u.Id);
                }
                
                Date today = Date.today();
                Date firstDayOfYear = Date.newInstance(today.year(), 1, 1);
                Integer daysSinceStart = today.daysBetween(firstDayOfYear);
                Integer weekNumber = (daysSinceStart / 7) + 1;
                Boolean isEvenWeek = (Math.mod(weekNumber, 2) == 0);
                
                Decimal coverage = objPolicy.Limit__r.Full_Coverage__c;
                
                String devNameKey;
                
                if (coverage < 1000000) {
                    devNameKey = isEvenWeek ? 'Assign_underwriter_user_less_1M_even' : 'Assign_underwriter_user_less_1M_odd';
                } else if (coverage >= 1000000 && coverage < 3000000) {
                    devNameKey = 'Assign_underwriter_user_less_2M';
                } else if (coverage >= 3000000 && coverage < 5000000) {
                    devNameKey = 'Assign_underwriter_user_less_5M';
                }
                
                if (devNameKey != null && devNameToEmailMap.containsKey(devNameKey)) {
                    String email = devNameToEmailMap.get(devNameKey);
                    if (emailToUserIdMap.containsKey(email)) {
                        objPolicy.Underwriter_User__c = emailToUserIdMap.get(email);
                    }
                }
            }

            
            if(policy.RecordType.Name == 'SA-ERP'){
                objPolicy.Policy_Type__c = 'SA-ERP';
            }else{
                objPolicy.Policy_Type__c = 'Annual ';
            }
            update objPolicy;
            
            if(policy.Previous_Policy__c != null){
                Policy__c previousPolicy = new Policy__c();
                previousPolicy.Id = policy.Previous_Policy__c;
                previousPolicy.Next_Policy__c = policy.Id;
                update previousPolicy;
            }
            
            Policy_Premium_History__c premiumHistory = new Policy_Premium_History__c();
            premiumHistory.Policy__c = policyId;
            premiumHistory.Action__c = 'Bound';
            premiumHistory.Premium__c = policy.Original_Premium__c;
            premiumHistory.X10x10_value__c = policy.Total_10x10__c;
            premiumHistory.X5x5_value__c = policy.Total_5x5__c;
            insert premiumHistory;
            System.debug('transactionQueueId'+transactionQueueId);
            //createDocuments(policyId,policyDocVersion,transactionQueueId);
            if(transactionQueueId != null){
                System.enqueueJob(new ConvertToPolicyDocumentQueuable(policyId,policyDocVersion,transactionQueueId),2);
            }else{
                //ConvertToPolicyLtng.createDocuments(policyId, policyDocVersion);
            }
            Set<Id> contactIds = new Set<Id>();
            List<Policy_Lawyer__c> lstPolicyLawyers = [select id,Lawyer__c,Policy__c,Lawyer__r.Contact__c from Policy_Lawyer__c where Policy__c =: policyId];
            List<AccountContactJunction__c> lawyersToUpdate = new List<AccountContactJunction__c>();
            for(Policy_Lawyer__c lawyer : lstPolicyLawyers){
                lawyersToUpdate.add(new AccountContactJunction__c(Id=lawyer.Lawyer__c, Latest_Policy__c =lawyer.Policy__c, Latest_Application__c = null));
                contactIds.add(lawyer.Lawyer__r.Contact__c);
            }
            List<CLE_Attendance__c> cleAttendance = [select id,Event_Date__c  from CLE_Attendance__c where Contact__c in: contactIds and Policy_Applied_To__c = null];
            for(CLE_Attendance__c attendance : cleAttendance){
                if(attendance.Event_Date__c <= policy.Effective_Date__c.addMonths(-3) && attendance.Event_Date__c > policy.Effective_Date__c.addMonths(-15)){
                    attendance.Policy_Applied_To__c = policyId;
                }
            }
            if(cleAttendance.size() > 0){
                update cleAttendance;
            } 
            if(lawyersToUpdate.size() > 0){
                update lawyersToUpdate;
            }
            
            return true;
        }catch(Exception e){
            Database.rollback(sp);
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = Label.System_Admin_Emails.split(',');
            message.subject = 'Error while binding the application';
            message.plainTextBody = 'Team,\n\nFollowing error has occurred while binding the application\n\n '+e.getMessage() + '\n\n'+e.getStackTraceString() + '\n\n\nPolicy - ' + policy.Name;
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            return false;
        }
        
    }
    //@future(callout=true)
    public static void createDocuments(String policyId, String policyDocVersion){
        List<Policy__c> policy =  new List<Policy__c>([select id,Account__c ,Mod_230__c,Mod_234__c,Mod_261__c,Effective_Date__c, NAS_EOC_Version_Formula__c   from Policy__c where id =: policyId]);
        
        List<Policy_Endorsement__c> endorsements = new List<Policy_Endorsement__c>();
        
        boolean IL_230 = false,IL_234 = false,IL_261 = false;
        
        if(policy[0].Mod_230__c!=null && policy[0].Mod_230__c != 0){
            IL_230 = true;
        }
        if(policy[0].Mod_234__c!=null && policy[0].Mod_234__c != 0){
            IL_234 = true;
        }
        if(policy[0].Mod_261__c!=null && policy[0].Mod_261__c != 0){
            IL_261 = true;
        }
        
        endorsements = [SELECT Id,Name,Event_Status__c,Endorsement_Number__c,Endorsement_Version__c,Policy__c,Policy__r.Account__c
                        FROM Policy_Endorsement__c WHERE Policy__c =: policyId];
        
        
        for(Policy_Endorsement__c pol : endorsements){
            //pol.Event_Status__c= 'Complete';  
            PolicyDocumentsUtility.createEndorsement(pol.id,pol.Policy__c,pol.Name,pol.Endorsement_Number__c,pol.Endorsement_Version__c,pol.Policy__r.Account__c ,null,pol.Id);
        }
        //update endorsements;
        PolicyDocumentsUtility.createIL102(policyId, '9/24',policy[0],null);
        if(policyDocVersion == '1/18'){
            PolicyDocumentsUtility.createIL302(policyId, policyDocVersion,policy[0],null);
        }
        PolicyDocumentsUtility.createIL230_234_261(policyId, policyDocVersion, policy[0], IL_230, IL_234, IL_261);
        //PolicyDocumentsUtility.createPolicyLetter(policyId, policyDocVersion,policy[0].Account__c,null);
        
        Date naseocLastDate = date.newInstance(2024,04,01);
        
        if(policy[0].Effective_Date__c < naseocLastDate){
            PolicyDocumentsUtility.createNASEOC(policyId, policy[0].NAS_EOC_Version_Formula__c   ,policy[0].Account__c,null);
        }
        
        PolicyDocumentsUtility.createCertificationOfInsurance(policyId, policyDocVersion,policy[0].Account__c,null);
        //PolicyDocumentsUtility.createDeclarationPage(policyId, policyDocVersion,policy[0].Account__c,null);
        if(!Test.isRunningTest()){
            System.enqueueJob(new DeclarationPageQueueable(policyId, policyDocVersion,policy[0].Account__c));
        }
    }
    
    @AuraEnabled
    public static String hasAllLawyersARDC(String policyId){
        List<Policy_Lawyer__c> lawyers =  new List<Policy_Lawyer__c>([select id,Lawyer__r.Contact__r.Name from Policy_Lawyer__c where Policy__c =: policyId and Lawyer__r.Contact__r.ARDC_Number__c = null]);
        String str = '';
        if(lawyers.size()>0){
            for(Policy_Lawyer__c lawyer : lawyers){
                str = str + lawyer.Lawyer__r.Contact__r.Name + ' , ';
            }
            return str;
        }else{
            return 'Yes';
        }
    }
    @AuraEnabled
    public static boolean hasInvalid106(String policyId){
        List<Policy_Endorsement__c> endorsements =  new List<Policy_Endorsement__c>([select id,Policy__r.Total_Lawyers__c from Policy_Endorsement__c where RecordType.DeveloperName = 'IL_106_AMENDMENT_OF_EXTENDED_REPORTING_PERIOD' and Policy__c =: policyId]);
        if(endorsements.size()>0){
            if(endorsements[0].Policy__r.Total_Lawyers__c > 1){
                return true;
            }else{
                return false;
            }
        }else{
            return false;
        }
    }
    
    @AuraEnabled
    public static boolean hasBlocks(String policyId){
        return HighlightsPanelCtrl.hasBlocks(policyId);
    }
    @AuraEnabled
    public static boolean hasUndefinedAOP(String policyId){
        List<Policy_AOP__c> aops = new List<Policy_AOP__c>([Select id from Policy_AOP__c where Policy__c =: policyId and AOP__r.Name = 'Undefined']);
        if(aops.size()>0){
            return true;
        }else{
            return false;
        }
    }
}