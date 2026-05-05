public class NAS_EOC_Template_Ctrl {
	public String recordId;
    public Policy__c policy{get;set;}
    public void setrecordId(String recordId){
        policy = [select id,Firm_Name_History__c,Policy_Number_History__c,Effective_Date_History__c,Expiration_Date_History__c,Firm_Billing_Address_History__c,Full_Prior_Acts__c,Policy_Retroactive_Date__c from Policy__C where id=: recordId];
    }
    public String getrecordId(){
        return recordId;
    }
}