public class EZRenewalCtrl {
    public List<Policy_Quote__c> quoteList{get;set;}
    public List<Policy_Lawyer__c> policyLawyers{get;set;}
    Id policyApplicationId;
    public Date expirationDate{get;set;}
    public Policy__c policy {get;set;}
    public EZRenewalCtrl(){
        policyApplicationId = apexpages.currentpage().getparameters().get('id');
        policy = [select id,name,Account__r.Name,Policy_Document_Version__c,RecordType.Name,Account__r.Account_Number_External_ID__c,
                      Effective_Date__c,County__c,Total_Lawyers__c,Policy_Number__c,Per_Claim_Limit__c,Aggregate_Limit_For_All_Claims__c,Application_Type__c,
                      Deductible_Amount__c,Premium__c,Expiration_Date__c,Account__c,Account__r.BillingStreet,Account__r.BillingCity, 
                       Account__r.BillingState,Account__r.BillingPostalCode,Account__r.Phone,Account__r.Trade_Name_or_D_B_A__c,Firm_Contact__r.Email,Firm_Contact__r.Phone,Firm_Contact__r.Name,
                       Total_Credit__c, Policy_Dividend__c, ISBAM_policy_dividend__c, Total_CLE_Credit__c, Account__r.Fax,Account__r.email__c,Remove_102_Endorsement__c,County__r.Name 
                       , Account__r.AcctSeed__Billing_Contact__r.Name, Account__r.AcctSeed__Billing_Contact__r.Email, Account__r.AcctSeed__Billing_Contact__r.Phone
                  from Policy__C where id = :policyApplicationId];
        expirationDate = policy.Effective_Date__c.addYears(1);
        quoteList = [select id,name,POLICY_EFFECTIVE_DATE__C,POLICY_FIRM__C,FIRM_BILLINGSTREET__C,FIRM_BILLINGCITY__C,FIRM_BILLINGSTATE__C,FIRM_BILLINGZIP__C,CREATEDDATE,QUOTE_EXPIRE_DATE__C,Policy__C,
                     FIRM_PRIOR_ACTS_DATE__c,COVERAGE_MAX_PER_CLAIM__c,FULL_COVERAGE__C,DEDUCTIBLE_AMOUNT__C,QUOTE_FINAL_PREMIUM__c,QUOTE_FINAL_PREMIUM_QRTLY__c,QUOTE_FINAL_PREMIUM_MONTHLY__c,
                     Policy__r.Total_CLE_Credit__c, Policy__r.Total_Credit__c, Policy__r.Policy_Dividend__c, Policy__r.Effective_Date__c
                     from Policy_Quote__c where Policy__c=: policyApplicationId ];
        policyLawyers = [SELECT Lawyer__r.Name, Lawyer__r.Lawyer_Name__c, Prior_Act_Date__c, Lawyer__r.Contact__r.ARDC_Number__c, Lawyer__r.Contact__r.ISBA__c,
                         Lawyer__r.Contact__r.Contact_Role__c,Contact_Role__c,Lawyer__r.Contact__r.Email
                         FROM Policy_Lawyer__c WHERE Policy__c =: policyApplicationId order by Lawyer__r.Contact__r.LastName ASC];  
    }
}