public class RegularRenewalDoc_Ctrl {
    public String recordId{get;set;}
    public String policyId {get; set;}
    public AccountContactRelation primaryConRole {get; set;}
    public Policy__c policy {get; set;}
    public List<Policy_Lawyer__c> policyLawyers {get; set;}
    public Policy_Quote__c quote{get;set;}
    public List<Policy_Quote__c> quoteList{get;set;}
    public Date tenDayPriorEffectiveDt{get; set;}
    
    public Map<String, String> contactRoles {get; set;}
    public Date expirationDate{get;set;}
    public Date dividendYear{get;set;}
    public Date EffectiveDatePlus60{get; set;}
    
    public RegularRenewalDoc_Ctrl(){
        if (apexpages.currentpage().getparameters().get('id') != null){
            recordId = apexpages.currentpage().getparameters().get('id'); 
        }else{
            recordId = policyId;
        }
        if(String.isNotBlank(recordId)){
            setrecordId(recordId);
            getPolicyRec();
        }
    }
    
    
    
    public void setrecordId(String recordId){
        
        policyLawyers = new List<Policy_Lawyer__c>();
        contactRoles = new Map<String, String>{'Owner' => 'O', 'Officer' => 'OF', 'Partner' => 'P', 'Employee' => 'E', 'Associate' => 'A', 'Shareholder' => 'SH', 
            'Member' => 'M', 'Director' => 'D', 'Independent Contractor' => 'IC', 'Of Counsel' => 'OC', 'Contract Employee' => 'CE',
            'Temporary Staff Lawyer' => 'TSL'};
                
                
                System.debug('recordId-----'+recordId);
        
        quoteList = [select id,name,POLICY_EFFECTIVE_DATE__C,POLICY_FIRM__C,FIRM_BILLINGSTREET__C,FIRM_BILLINGCITY__C,FIRM_BILLINGSTATE__C,FIRM_BILLINGZIP__C,CREATEDDATE,QUOTE_EXPIRE_DATE__C,Policy__C,
                     FIRM_PRIOR_ACTS_DATE__c,COVERAGE_MAX_PER_CLAIM__c,FULL_COVERAGE__C,DEDUCTIBLE_AMOUNT__C,QUOTE_FINAL_PREMIUM__c,QUOTE_FINAL_PREMIUM_QRTLY__c,QUOTE_FINAL_PREMIUM_MONTHLY__c from Policy_Quote__c where Policy__c=: recordId Order By QUOTE_FINAL_PREMIUM__c ASC];
        
        System.debug('quoteList-----'+quoteList);
        
        if(!quoteList.isEmpty()){
            quote = quoteList[0];
        }
        
        policy = [SELECT Name, Account__c, Effective_Date__c, County__r.Name, Account__r.Account_Number_External_ID__c, Account__r.Name, 
                  Account__r.Phone, Account__r.Fax, Expiration_Date__c, Per_Claim_Limit__c, Deductible_ID__r.Name, Premium__c,Policy_Effective_Year__c,
                  Aggregate_Limit__c,Account__r.BillingStreet,Account__r.BillingCity,Account__r.BillingState,Account__r.BillingPostalCode,Firm_Contact__r.Email,
                  Firm_Contact__r.Name,Firm_Contact__r.FirstName,Firm_Contact__r.Website__c,Firm_Contact__r.Title,Account__r.Website__c,Firm_Contact__r.Contact_Role__c,Total_CLE_Credit__c,DataLoader__c,Underwriter_User__r.FirstName,Underwriter_User__r.LastName,Dividend_Credit__c,Total_Credit__c,
                  Underwriter_User__r.Title,Underwriter_User__r.Phone,Underwriter_User__r.Email, ISBAM_policy_dividend__c,
                  Previous_Policy__r.Name, Previous_Policy__r.Expiration_Date__c, Firm_Contact__r.LastName
                  FROM Policy__c WHERE Id =: recordId];
        
        policy.DataLoader__c = false;
        
        tenDayPriorEffectiveDt = policy.Effective_Date__c.addDays(-10);
        
        //if(!Test.isRunningTest()){
        policyLawyers = [SELECT Lawyer__r.Name, Prior_Act_Date__c, Lawyer__r.Contact__r.ARDC_Number__c, Lawyer__r.Contact__r.ISBA__c,
                         Lawyer__r.Contact__r.Contact_Role__c,Contact_Role__c,Lawyer__r.Contact__r.Email
                         FROM Policy_Lawyer__c WHERE Policy__c =: policy.Id order by Lawyer__r.Contact__r.LastName ASC];  
        
        for(AccountContactRelation accConRole: [SELECT AccountId, Account.Name, Account.BillingCity, Account.BillingStreet, Account.BillingState,
                                                Contact.Email, Contact.Website__c,
                                                Account.BillingCountry, Account.BillingPostalCode, ContactId, Contact.Name  
                                                FROM AccountContactRelation 
                                                WHERE AccountId =: policy.Account__c AND Contact.Primary_Contact__c = true LIMIT 1])
        {
            primaryConRole = accConRole;
        }
        expirationDate = policy.Effective_Date__c.addYears(1);
        dividendYear =  policy.Effective_Date__c.AddYears(-1);
        EffectiveDatePlus60 = policy.Effective_Date__c.AddDays(60);
        
        
        system.debug('policy -- > ' + policy);
        // }
    }
    
    public String getrecordId(){
        return recordId;
    }
    public Policy__c getPolicyRec(){
        System.debug('Testing for recordid::'+recordId);
        return [SELECT Name, Account__c, Effective_Date__c, County__r.Name, Account__r.Account_Number_External_ID__c, Account__r.Name, 
                Account__r.Phone, Account__r.Fax, Expiration_Date__c, Per_Claim_Limit__c, Deductible_ID__r.Name, Premium__c,
                Aggregate_Limit__c,Account__r.BillingStreet,Account__r.BillingCity,Account__r.BillingState,Account__r.BillingPostalCode,Firm_Contact__r.Email,
                Firm_Contact__r.Name,Firm_Contact__r.FirstName,Firm_Contact__r.Website__c,Firm_Contact__r.Title,Account__r.Website__c,Firm_Contact__r.Contact_Role__c,Total_CLE_Credit__c,DataLoader__c,Underwriter_User__r.FirstName,Underwriter_User__r.LastName,Dividend_Credit__c,Total_Credit__c,
                Underwriter_User__r.Title,Underwriter_User__r.Phone,Underwriter_User__r.Email, ISBAM_policy_dividend__c,
                Previous_Policy__r.Name, Previous_Policy__r.Expiration_Date__c, Firm_Contact__r.LastName
                FROM Policy__c WHERE Id =: recordId];
    }
    
    public List<String> getPolicyLimit () {
        List<String> options = new List<String>();
        options.add('Same As Expiring');
        //if(!Test.isRunningTest()){
        ILF_Coverage_Factor__c[] threatMappings = [SELECT Id, Name, Coverage_Max_Per_Claim__c 
                                                   FROM ILF_Coverage_Factor__c WHERE OldLimit__c = false ORDER BY Coverage_Max_Per_Claim__c,Full_Coverage__c ASC LIMIT 1000];
        for (ILF_Coverage_Factor__c threatMapping : threatMappings) {
            if(threatMapping.Coverage_Max_Per_Claim__c <= 7000000){
                options.add(threatMapping.Name);
            }
        }
        options.add('Higher $______');
        //}
        return options;
    }
    
    public List<String> getPolicyDeductible () {
        List<String> options = new List<String>();
        //if(!Test.isRunningTest()){
        Deductible_Factor__c[] threatMappings = [SELECT Id, Name, Deductible_Amount__c FROM Deductible_Factor__c ORDER BY Deductible_Amount__c ASC LIMIT 1000];
        for (Deductible_Factor__c threatMapping : threatMappings) {
            if(threatMapping.Deductible_Amount__c <= 35000){
                options.add(threatMapping.Name);
            }
        }
        options.add('Higher $______');
        //}
        return options;
    }
    
}