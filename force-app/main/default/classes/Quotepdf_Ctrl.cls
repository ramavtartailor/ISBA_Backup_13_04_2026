public class Quotepdf_Ctrl {
    public String recordId;
    public String policyId{get;set;}
    public Policy_Quote__c quote{get;set;}
    public List<Policy_Endorsement__c> endorsements{get;set;}
    public void setrecordId(String recordId){
        
        quote = new Policy_Quote__c();
        
        List<Policy_Quote__c> quoteList = [select id,name,POLICY_EFFECTIVE_DATE__C,POLICY_FIRM__C,FIRM_BILLINGSTREET__C,FIRM_BILLINGCITY__C,FIRM_BILLINGSTATE__C,FIRM_BILLINGZIP__C,CREATEDDATE,QUOTE_EXPIRE_DATE__C,Policy__C,
                 FIRM_PRIOR_ACTS_DATE__c,COVERAGE_MAX_PER_CLAIM__c,FULL_COVERAGE__C,DEDUCTIBLE_AMOUNT__C,QUOTE_FINAL_PREMIUM__c,QUOTE_FINAL_PREMIUM_QRTLY__c,QUOTE_FINAL_PREMIUM_MONTHLY__c from Policy_Quote__c where id=: recordId];
        
        if(!quoteList.isEmpty()){
            quote = quoteList[0];
            endorsements = [select id, name from Policy_Endorsement__C where Policy__C =: quote.Policy__c];
        }
    }
    public String getrecordId(){
        return recordId;
    }
    
}