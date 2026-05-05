public class QuoteTemplate_Ctrl {
    public String recordId;
    public Policy_Quote__c quote{get;set;}

	    //public List<Policy_Quote__c> quoteList{get;set;}
    	//public Policy__c policy {get;set;}
    
    public List<Policy_Endorsement__c> endorsements{get;set;}
    public void setrecordId(String recordId){
        quote = [select id,name,POLICY_EFFECTIVE_DATE__C,POLICY_FIRM__C,FIRM_BILLINGSTREET__C,FIRM_BILLINGCITY__C,FIRM_BILLINGSTATE__C,FIRM_BILLINGZIP__C,CREATEDDATE,QUOTE_EXPIRE_DATE__C,Policy__C,Policy__r.Full_Prior_Acts__c,Policy__r.Remove_102_Endorsement__c, 
                 FIRM_PRIOR_ACTS_DATE__c,COVERAGE_MAX_PER_CLAIM__c,FULL_COVERAGE__C,DEDUCTIBLE_AMOUNT__C,QUOTE_FINAL_PREMIUM__c,QUOTE_FINAL_PREMIUM_QRTLY__c,QUOTE_FINAL_PREMIUM_MONTHLY__c,Policy__r.Policy_Document_Version__c,
                 Mod_230__c,Mod_234__c,Mod_261__c,
                 Policy__r.Is_New_Business__c, Policy__r.Name, Policy__r.Total_CLE_Credit__c, Policy__r.Total_Credit__c, Policy__r.Policy_Dividend__c, Policy__r.ISBAM_policy_dividend__c, Policy__r.Effective_Date__c
                 from Policy_Quote__c where id=: recordId];
        
        	//policy = [select id,name,Account__r.Name,Policy_Document_Version__c,RecordType.Name,Account__r.Account_Number_External_ID__c,
            //          Effective_Date__c,County__c,Total_Lawyers__c,Policy_Number__c,Per_Claim_Limit__c,Aggregate_Limit_For_All_Claims__c,Renewal_Type__c,Application_Type__c,
            //          Deductible_Amount__c,Premium__c,Expiration_Date__c,Account__c,Account__r.BillingStreet,Account__r.BillingCity, 
            //           Account__r.BillingState,Account__r.BillingPostalCode,Account__r.Phone,Account__r.Trade_Name_or_D_B_A__c,Firm_Contact__r.Email,Firm_Contact__r.Phone,Firm_Contact__r.Name,
            //           Account__r.Fax,Account__r.email__c,Remove_102_Endorsement__c,County__r.Name from Policy__C where id = :recordId];
        
        String removeIL102 ='';
        if(quote.Policy__r.Remove_102_Endorsement__c){
            removeIL102 = 'IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT';
        }
        endorsements = [select id, name,Endorsement_Number__c,Endorsement_Version__c,Endorsement_Name__c from Policy_Endorsement__C where Policy__C =: quote.Policy__c and RecordType.Name!= :removeIL102];
    }
    public String getrecordId(){
        return recordId;
    }
}