public class HighlightsPanelCtrl {
    @AuraEnabled
    public static Policy__c getPolicyDetails(String policyId){
        Policy__c objPolicy = [select Id,Name,Billing__c, Customer_Application__c, Customer_Application__r.Form_Link__c,Record_Type__c,Account__c,Account__r.Policy_Series_Age_display__c ,Lost_Reason__c,Lost_Reason_Sub1__c, Lost_Reason_Sub2__c ,Account__r.Name,Premium__c,Effective_Date__c,Expiration_Date__c,Limits__c,Deductible__c,Renewal_Type__c,Status__c,
                               Account__r.Phone,Account__r.Recent_Policy_ID__c,Account__r.Recent_Policy__c,Account__r.Recent_Application_Id__c,Account__r.Recent_Application__c,
                               Firm_Contact__r.Email,Firm_Contact__r.Phone,Account__r.BillingStreet,Account__r.BillingCity,Account__r.BillingState,Account__r.BillingPostalCode,Sales_User__r.Name,Full_Prior_Acts__c,Policy_Retroactive_Date__c,
                               Underwriter_User__r.Name,ERE_Date__c,Account__r.AccountNumber,RecordType.Name,Limit__r.Name,
                               Additional_Premium__c,Firm_Contact__r.Name,Total_Additional_Premium__c,Cancel_Date__c,Deductible_ID__r.Name,Limit__c,Support_Staff__c,Number_of_Lawyers__c,Account__r.Website__c,Account__r.Retroactive_Date__c,County__r.Name,
                               Account__r.AcctSeed__Billing_Contact__r.Name,Account__r.AcctSeed__Billing_Contact__r.Email,Account__r.AcctSeed__Billing_Contact__r.Phone,Account__r.AcctSeed__Billing_Contact__c,
                               Policy_Dividend__c,
                               ISBAM_policy_dividend__c,
                               Total_CLE_Credit__c,
                               Total_Credit__c 
                               from Policy__c where Id =: policyId];
        system.debug('RecordType----' + objPolicy.RecordType.Name);
        system.debug('Premium-------' + objPolicy.Premium__c);
        System.debug('Limit---------'+objPolicy.Limit__r.Name);
        if(objPolicy.Account__r.Website__c != null && !(objPolicy.Account__r.Website__c.startsWith('http'))){
            objPolicy.Account__r.Website__c = 'https://'+objPolicy.Account__r.Website__c;
        }
        System.debug('Website-----'+objPolicy.Account__r.Website__c);
        if(objPolicy.RecordType.Name == 'Application' && (objPolicy.Limit__r.Name==null || objPolicy.Premium__c==null)){
            List<Policy_Quote__c> quotes = new List<Policy_Quote__c>([select id,Quote_Final_Premium__c,Coverage__r.Name,Deductible__r.Name from Policy_Quote__c where Policy__c=:objPolicy.Id ]);
            if(quotes.size() == 1){
                objPolicy.Limit__r = quotes[0].Coverage__r;
                objPolicy.Premium__c = quotes[0].Quote_Final_Premium__c;
                objPolicy.Deductible_ID__r = quotes[0].Deductible__r;
            }
        }
        return objPolicy;
    }
    
    @AuraEnabled
    public static Contact getContactDetail(String conId){
        Contact con = [SELECT Id, Name, Latest_Policy__c, Latest_Policy__r.Name, Latest_Application__c, Latest_Application__r.Name, Latest_Activity_Date__c, Email, ISBA__c, ARDC__c, ARDC_Number__c,MobilePhone,Personal_Email__c FROM Contact WHERE Id =: conId];
        return con;
    }
    
    @AuraEnabled
    public static Wrapper getCustomerApplication(String appId) {
        wrapper wrap = new wrapper();
        Customer_Application__c app = [
            SELECT Id,
            Account__c,
            Account__r.Name,
            Full_Legal_Name_of_the_Firm__c,
            Contact_Name__c,
            Contact_Last_Name__c,
            Contact_E_mail_Address__c,
            Contact_Phone_Number__c,
            Prior_Insurance_Effective_Date__c,
            Form_Link__c,
            Application_Status__c,
            Effective_Date_Requested__c,
            PolicyId__c,
            PolicyId__r.Name,
            RecordType.DeveloperName,RecordType.Name,
            Underwriter_User__c , Underwriter_User__r.Name,
            Sales_User__c , Sales_User__r.Name,
            (SELECT Id FROM Customer_Application_Lawyers__r WHERE Is_Removed__c = false) 
            FROM Customer_Application__c WHERE Id = :appId LIMIT 1
        ];
        wrap.app = app;
        String profileName = 'Underwriting';
        
        if(app.RecordType.DeveloperName == 'New_Business'){
            profileName = 'Sales';
        }
        
        wrap.usrList = new List<User>([SELECT Id,Name,Profile.Name FROM User WHERE Profile.Name IN ('Sales', 'Underwriting') AND isActive = true ]);
        
        return wrap;
    }
    
    @AuraEnabled
    public static String updateApplicationUser(String recordId, String salesUserId, String underwritingUserId){
        Customer_Application__c app = new Customer_Application__c();
        app.Id = recordId;
        if(String.isNotBlank(underwritingUserId)){
            app.Underwriter_User__c = underwritingUserId;
            app.Sales_User__c = null;
            
        }
        if(String.isNotBlank(salesUserId)){
            app.Sales_User__c = salesUserId;
            app.Underwriter_User__c = null;
        }
        Update app;
        return 'Success';
    }
    
    public class wrapper {
        @AuraEnabled
        public Customer_Application__c app{get;set;}
        @AuraEnabled
        public List<User> usrList{get;set;}
    }
    
    @AuraEnabled
    public static Account getAccountDetails(String accountId){
        Account acc = [select Id,Name,Phone,Recent_Policy_ID__c,Recent_Policy__c,Recent_Application_Id__c,Recent_Application__c,
                       BillingStreet,BillingCity,BillingState,BillingPostalCode,AccountNumber,Website__c,Policy_Series_Age_display__c,
                       AcctSeed__Billing_Contact__r.Name,AcctSeed__Billing_Contact__r.Email,AcctSeed__Billing_Contact__r.Phone,AcctSeed__Billing_Contact__c
                       from Account where Id =: accountId];
        if(acc.Website__c != null && !(acc.Website__c.startsWith('http'))){
            acc.Website__c = 'https://'+acc.Website__c;
        }
        return acc;
    }
    
    @AuraEnabled
    public static Policy_Claim__c getClaimDetails(String claimId){
        Policy_Claim__c objClaim = [select Policy__r.Account__c, Policy__r.Account__r.Policy_Series_Age_display__c, Policy__r.Account__r.Name,Policy__r.Premium__c,Policy__r.Effective_Date__c,Policy__r.Expiration_Date__c,Policy__r.Limits__c,Policy__r.Deductible__c,
                                    Policy__r.Account__r.Phone,Policy__r.Account__r.Recent_Policy_ID__c,Policy__r.Account__r.Recent_Policy__c,Policy__r.Account__r.Recent_Application_Id__c,Policy__r.Account__r.Recent_Application__c,
                                    Policy__r.Firm_Contact__r.Email,Policy__r.Firm_Contact__r.Phone,Policy__r.Account__r.BillingStreet,Policy__r.Account__r.BillingCity,Policy__r.Account__r.BillingState,Policy__r.Account__r.BillingPostalCode,
                                    Policy__r.ERE_Date__c,Policy__r.Account__r.AccountNumber,File_Type__c,CreatedBy.Name,Policy__r.Additional_Premium__c,Policy__r.Firm_Contact__r.Name,Claimant__c,LawyerNew__r.Contact__r.Name,
                                    Policy__r.Policy_Remaining_By_All_Claims__c,Remaining_Deductible__c,Policy__r.Total_Additional_Premium__c,Claim_Handler_Lookup__r.Name,Reserve_LAE__c,Reserve_Loss__c,Claim_Status__c,Claim_Firm_Name__c,GL_5010__c,GL_5035__c,Per_Claim_Deductible_Balance__c,
                                    (SELECT Id,AcctSeed__Balance__c, AcctSeed__Total__c FROM Billings__r)
                                    from Policy_Claim__c where Id =: claimId];
        
        return objClaim;
    }
    @AuraEnabled
    public static AcctSeed__Billing__c getBillingDetail(String billingId){
        AcctSeed__Billing__c billing = [select Name
                                        , Id
                                        , AcctSeed__Customer__r.Name
                                        , AcctSeed__Billing_Contact__r.Name
                                        , Has_234_Endorsement__c
                                        , ISBAM_Overdue__c 
                                        , Computed_Payment_Frequency__c 
                                        , Computed_Payment_Type__c 
                                        , Latest_Cash_Receipt__c 
                                        , Billing_Description__c 
                                        , Policy__r.Name
                                        , Policy__r.Limit__r.Name
                                        , Policy__r.Deductible_ID__r.Name
                                        , Claim__r.Name
                                        , Policy_Endorsement__r.Name
                                        , Policy_Bound_Date__c
                                        , Policy_Effective_Date__c
                                        , AcctSeed__Date__c 
                                        , AcctSeed__Total__c 
                                        , AcctSeed__Received_Amount__c 
                                        , AcctSeed__Balance__c
                                        , AcctSeed__Status__c 
                                        , AcctSeed__PDF_Email_Status__c 
                                        , Next_Payment_Date__c
                                        , Next_Payment_Base_Amount__c
                                        , Is_Credit_Memo__c 
                                        , Is_Policy_Billing__c 
                                        , Is_Endorsement_Billing__c 
                                        , Is_Claim_Billing__c 
                                        , Latest_Activity_Date__c
                                        , ISBAM_Error__c 
                                        , ISBAM_Error_Description__c
                                        , AcctSeed__Payment_Processor__r.Name
                                        , Computed_Schedule_Overdue_Date__c 
                                        , Days_Overdue__c
                                        , Is_Forte_Schedule__c,
                                        Remaining_Payments__c,
                                        (SELECT Id, Due_Date__c,Status__c, Due_Amount__c,Service_Fee_Amount__c FROM Payment_Schedules__r Where Status__c='Unpaid' OR Status__c='Rejected' ORDER BY Due_Date__c)
                                        from AcctSeed__Billing__c where Id =: billingId];
        
        return billing;
    }
    
    @AuraEnabled
    public static String has107(String policyId){
        if(Id.valueOf(policyId).getSObjectType().getDescribe().getName() == 'Account'){
            Policy__c pol = getCurrentPolicy(policyId);
            if(pol != null){
                policyId = pol.Id;
            }
        }
        List<Policy_Endorsement__c> endorsement = new List<Policy_Endorsement__c>([select id,Coverage_Term__c,Endorsement_Number__c,ERE_Expiration_Date__c from Policy_Endorsement__c where Event_Status__c = 'Complete' and  (Endorsement_Number__c = 'IL 107' OR Endorsement_Number__c = 'IL 107B' OR Endorsement_Number__c = 'IL 107C' OR Endorsement_Number__c = 'IL 107D') and Policy__c =: policyId order by Endorsement_Number__c limit 1]);
        if(endorsement.size() > 0){
            String str = '';
            /*if(endorsement[0].Endorsement_Number__c == 'IL 107'){
            if(endorsement[0].Coverage_Term__c == 'Unlimited'){
            str = '107 : Unlimited';
            }else{
            Datetime dt = Datetime.newInstance(endorsement[0].ERE_Expiration_Date__c.year(), endorsement[0].ERE_Expiration_Date__c.month(),endorsement[0].ERE_Expiration_Date__c.day());
            str = '107 : '+ dt.format('MMM d, YYYY');
            }
            }else if(endorsement[0].Endorsement_Number__c == 'IL 107B'){
            str = '107B : Active Duty';
            }else if(endorsement[0].Endorsement_Number__c == 'IL 107C'){
            str = '107C : Unlimited';
            }else if(endorsement[0].Endorsement_Number__c == 'IL 107D'){
            str = '107D : Unlimited';
            }*/
            return 'False';
        }else{
            List<Policy__c> lstPolicy = [select id,ERE_Date__c from Policy__c where id =: policyId];
            if(lstPolicy.size() > 0 && lstPolicy[0].ERE_Date__c != null){
                Datetime dt = Datetime.newInstance(lstPolicy[0].ERE_Date__c.year(), lstPolicy[0].ERE_Date__c.month(),lstPolicy[0].ERE_Date__c.day());
                return dt.format('MMM d, YYYY');
            }else{
                return 'False';
            }
        }
    }
    @AuraEnabled
    public static boolean hasBlocks(Id relatedId){
        String sObjName = relatedId.getSObjectType().getDescribe().getName();
        if(sObjName == 'Account'){
            List<Policy__C> lstPolicies = [select id,Account__c from Policy__c where Account__C=:relatedId ];
            List<Application_Block__c> blocksList = new List<Application_Block__c>([select id from Application_Block__c where (Account__c=:relatedId OR Application_Policy__c in : lstPolicies)  and Status__c = 'Active']);
            if(blocksList.size()>0){
                
                return true;
            }else{
                return false;
            }
        }else if(sObjName == 'Policy__c'){
            List<Policy__C> lstPolicies = [select id,Account__c from Policy__c where Id=:relatedId ];
            if(lstPolicies.size()>0 && lstPolicies[0].Account__C!=null){
                lstPolicies = [select id,Account__c from Policy__c where Account__C=:lstPolicies[0].Account__C ];
                List<Application_Block__c> blocksList = new List<Application_Block__c>([select id from Application_Block__c where (Account__c=:lstPolicies[0].Account__C OR Application_Policy__c in : lstPolicies)  and Status__c = 'Active']);
                if(blocksList.size()>0){
                    return true;
                }else{
                    return false;
                }
            }else if(lstPolicies.size()>0){
                List<Application_Block__c> blocksList = new List<Application_Block__c>([select id from Application_Block__c where Application_Policy__c in : lstPolicies and Status__c = 'Active']);
                if(blocksList.size()>0){
                    return true;
                }else{
                    return false;
                }
            }else{
                return false;
            }
        }else if(sObjName == 'Policy_Claim__c'){
            List<Policy_Claim__c> lstClaims = [select id,Policy__r.Account__c from Policy_Claim__c where id=:relatedId];
            if(lstClaims.size()>0 && lstClaims[0].Policy__r.Account__c!=null){
                List<Policy__c> lstPolicies = [select id,Account__c from Policy__c where Account__C=:lstClaims[0].Policy__r.Account__c ];
                List<Application_Block__c> blocksList = new List<Application_Block__c>([select id from Application_Block__c where (Account__c=:lstClaims[0].Policy__r.Account__c OR Application_Policy__c in : lstPolicies)  and Status__c = 'Active']);
                if(blocksList.size()>0){
                    return true;
                }else{
                    return false;
                }
            }else{
                return false;
            }
        }else{
            return false;
        }
    }
    @AuraEnabled
    public static String typeOfPolicy(String policyId){
        Policy__c objPolicy = [select Id,RecordType.Name,Account__r.Recent_Policy_ID__c,Account__r.Recent_Application_Id__c,Effective_Date__c,Expiration_Date__c,Cancel_Date__c from Policy__c where Id =: policyId];
        if(objPolicy.RecordType.Name == 'Application'){
            if(objPolicy.Id == objPolicy.Account__r.Recent_Application_Id__c){
                return 'latestApplication';
            }else{
                return 'isApplication';
            }
        }else if(objPolicy.RecordType.Name == 'Policy'){
            if(objPolicy.Effective_Date__c <= System.today() && objPolicy.Expiration_Date__c >= System.today() && (objPolicy.Cancel_Date__c == null || objPolicy.Cancel_Date__c > System.today()  )){
                return 'latestPolicy';
            }else if(objPolicy.Effective_Date__c > System.today()){
                return 'futurePolicy';
            }else{
                return 'isPolicy';
            }
        }else{
            return '';
        }
    }
    @AuraEnabled
    public static Policy__c getCurrentPolicy(String accountId){
        List<Policy__c> objPolicy = [select Id,Name,Record_Type__c,Account__c,Account__r.Name,Premium__c,Effective_Date__c,Expiration_Date__c,Limits__c,Deductible__c,Renewal_Type__c,
                                     Account__r.Phone,Account__r.Recent_Policy_ID__c,Account__r.Recent_Policy__c,Account__r.Recent_Application_Id__c,Account__r.Recent_Application__c,
                                     Firm_Contact__r.Email,Firm_Contact__r.Phone,Account__r.BillingStreet,Account__r.BillingCity,Account__r.BillingState,Account__r.BillingPostalCode,Full_Prior_Acts__c,Policy_Retroactive_Date__c,
                                     Underwriter_User__r.Name,Sales_User__r.Name,RecordType.Name,Status__c,Firm_Contact__r.Name,Account__r.Retroactive_Date__c,County__r.Name,Support_Staff__c,Number_of_Lawyers__c,Deductible_ID__r.Name,Total_Additional_Premium__c
                                     from Policy__c where Account__c =: accountId and (Cancel_Date__c = null OR Cancel_Date__c > TODAY )    and RecordType.Name = 'Policy' order by Expiration_Date__c DESC];//and Effective_Date__c<= TODAY and Expiration_Date__c >= TODAY
        if(objPolicy!=null && objPolicy.size()>0){
            return objPolicy[0];
        }else{
            return null;
        }
    }
    @AuraEnabled
    public static List<AccountContactRelation> getContacts(String accountId) {
        List<AccountContactRelation> accountContactRelationList = [select id,contactid,Contact.Name from AccountContactRelation where AccountId =: accountId ORDER BY Contact.Name limit 1000];
        return accountContactRelationList;
    }
    @AuraEnabled
    public static String updateContact(String contactId,String policyId) {
        try{
            Policy__c pol = new Policy__c();
            pol.Id = policyId;
            pol.Firm_Contact__c = contactId;
            update pol;
            return 'Success';
        }catch(Exception e){
            System.debug(e.getStackTraceString() + '---' + e.getMessage());
            return e.getMessage();
        }
    }
    @AuraEnabled
    public static String updateBillingContact(String contactId,String accountId) {
        try{
            Account acc = new Account();
            acc.Id = accountId;
            acc.AcctSeed__Billing_Contact__c  = contactId;
            update acc;
            return 'Success';
        }catch(Exception e){
            System.debug(e.getStackTraceString() + '---' + e.getMessage());
            return e.getMessage();
        }
    }  
    
    @AuraEnabled
    public static String updateApplicationAccount(String recordId,String accountId) {
        try{
            Customer_Application__c app = new Customer_Application__c();
            app.Id = recordId;
            app.Account__c = null; 
            
            if(String.isNotBlank(accountId)){
                app.Account__c = accountId; 
            }
            
            update app;
            return 'Success';
        }catch(Exception e){
            System.debug(e.getStackTraceString() + '---' + e.getMessage());
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static Customer_Application__c getApplication(String recordId){
        try {
            List<Customer_Application__c> capp = new List<Customer_Application__c>([SELECT Id, Full_Legal_Name_of_the_Firm__c, Firm_Phone_Number__c, Street__c, Address_2__c, City__c, State__c, Zip_Code__c FROM Customer_Application__c WHERE Id =: recordId]);
            return capp[0];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Account> searchAccount(String companyName) {
        try {
        companyName = companyName.replaceAll('[^0-9a-zA-Z ]+', '*');
        companyName = '*' + companyName + '*';
        String query =
            'FIND \'' + companyName + '\' IN ALL FIELDS ' +
            'RETURNING Account(' +
                'Id, ' +'Name, ' +'Phone, ' +'BillingStreet, ' +'BillingCity, ' +'BillingState, ' +'BillingPostalCode ' +')';
        List<List<SObject>> objList = Search.query(query);
        return (List<Account>) objList[0];

    } catch (Exception e) {
        System.debug(e.getStackTraceString() + '---' + e.getMessage());
        return new List<Account>();
    }
       /* try{
            //String mungedSearchString = companyName.replaceAll('[^0-9a-zA-Z ]+', '%');
            mungedSearchString = mungedSearchString.toLowerCase();
            mungedSearchString = mungedSearchString.replace(' inc', '%');
            mungedSearchString = mungedSearchString.replace(' ', '%');
            mungedSearchString = '%'+mungedSearchString+'%';//
            
            companyName = companyName.replaceAll('[^0-9a-zA-Z ]+', '*');
            companyName = '*'+companyName+'*';
            String query = 'FIND \''+companyName+'\' IN ALL FIELDS RETURNING Account(Id,Name LIMIT 100)';
            List<List<Sobject>> objList = search.query(query);
            return (List<Account>)objList[0];
            //return CompanyNameFuzzyMatcher.findAccountsByFuzzyName(companyName, 100);
        }catch(Exception e){
            System.debug(e.getStackTraceString() + '---' + e.getMessage());
        }*/
    }
}