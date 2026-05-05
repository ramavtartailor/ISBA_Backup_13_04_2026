public class Policy_Letter_Template_Ctrl {
	public String recordId;
    public Policy__c policy{get;set;}
    public void setrecordId(String recordId){
        policy = [select id,name,PRIMARY_CONTACT_NAME_History__C,RELATED_FIRM_ID_History__C,FIRM_NAME_History__C,FIRM_BILLING_ADDRESS_History__C,EFFECTIVE_DATE_History__C,EXPIRATION_DATE_History__C,Policy_Number_History__c from Policy__C where id=: recordId];
    }
    public String getrecordId(){
        return recordId;
    }
}