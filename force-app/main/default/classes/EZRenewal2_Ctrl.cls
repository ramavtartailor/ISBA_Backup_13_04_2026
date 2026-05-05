public class EZRenewal2_Ctrl {
    public String recordId;
    public Policy__c policy {get; set;}
    public List<Policy_Endorsement__c> endorsementList{get;set;} 
    public boolean Mod_230{get;set;}
    public boolean Mod_234{get;set;}
    public boolean Mod_261{get;set;}
    public void setrecordId(String recordId){
        
        
        policy = [SELECT Name, Account__c, Effective_Date__c, County__r.Name, Account__r.Account_Number_External_ID__c, Account__r.Name, 
                  Account__r.Phone, Account__r.Fax, Expiration_Date__c, Per_Claim_Limit__c, Deductible_ID__r.Name, Premium__c, Remove_102_Endorsement__c,
                  Aggregate_Limit__c,Policy_Document_Version__c,Underwriter_User__r.FirstName,Underwriter_User__r.LastName,Underwriter_User__r.Phone,
                  Terms_Conditions__C 
                  FROM Policy__c WHERE Id =: recordId];
        
        endorsementList = [select id,Name,ENTITY_NAME__C,Premium__c,POLICY_FIRM__c,ENTER_MANUSCRIPT_LANGUAGE__c,AOP__c,BROKER__c,TO_DATE__c,FROM_DATE__c,PERSON_ATTORNEY__c,Name2__c,
                           TERRITORY__C,MATTER__C,FIRM_NAME__C,ENDORSEMENT_EFFECTIVE_DATE__c,REFUND_AMOUNT__C,LAWYER_NAME__C,ATTORNEY_FIRM_NAME__c,PER_LAWER__c,PER_POLICY__c,
                           ERE_MONTHS__c,Policy_Lawyer__r.Prior_Act_Date__c,PRIOR_ACT_DATE__C,ACCOUNT_BILLING_STREET__c,ACCOUNT_BILLING_City__c,ACCOUNT_BILLING_State__c,ACCOUNT_BILLING_PostalCode__c,
                           ENTITY__c,ATTORNEY__c,FIRM_ENTITY__c,TERM__c,SECOND_EFFECTIVE_DATE__c,FIRST_PER_CLAIM__C,FIRST_AGGREGATE__C,SECOND_PER_CLAIM__C,SECOND_AGGREGATE__C,THIRD_PER_CLAIM__C,
                           THIRD_AGGREGATE__C,THIRD_EFFECTIVE_DATE__c,TITLE_INSURANCE_AGENCY__C,ADDITIONAL_PREMIUM__C,Manuscript__c,Endorsement_Number__c,Policy__c,Endorsement_Version__c,Endorsement_Name__c from Policy_Endorsement__c where Policy__c =: recordId];            
        
        for(Policy_Quote__c q : [select id,Mod_230__c,Mod_234__c,Mod_261__c from Policy_Quote__c where Policy__c =:recordId Order By CreatedDate DESC]){
            if(q.Mod_230__c != null && q.Mod_230__c !=0){
                Mod_230 = true;
            }
            if(q.Mod_234__c != null && q.Mod_234__c !=0){
                Mod_234 = true;
            }
            if(q.Mod_261__c != null && q.Mod_261__c !=0){
                Mod_261 = true;
            }
        }
    }
    
    public String getrecordId(){
        return recordId;
    }
    
}