public class CERTIFICATION_OF_INSURANCE_Template_Ctrl {
    public String recordId;
    public Policy__c policy{get;set;}
    public void setrecordId(String recordId){
        policy = [select id,name,FIRM_NAME_History__C, FIRM_BILLING_ADDRESS_History__C , POLICY_NUMBER_History__C,EFFECTIVE_DATE_History__C,EXPIRATION_DATE_History__C, PER_CLAIM_LIMIT_History__C,
                  AGGREGATE_LIMIT_History__C ,PER_CLAIM_DEDUCTIBLE_AMOUNT_History__C from Policy__C where id=: recordId];
    }
    public String getrecordId(){
        return recordId;
    }
}