public class Policy_Header_Ctrl {
    public String recordId;
    public Policy__c policy{get;set;}
    public POLICY_ENDORSEMENT__c endorsement{get;set;}
	public Policy_Quote__c quote{get;set;}    
    public void setrecordId(String recordId){
        
        Schema.SObjectType token = Id.valueOf(recordId).getSObjectType();
        Schema.DescribeSObjectResult dr = token.getDescribe();
        if(dr.getName().equalsIgnoreCase('Policy__c')){
            if(policy==null){
                policy = [select id,name,EFFECTIVE_DATE__C, POLICY_NUMBER__C , Account__r.Name  from Policy__C where id=: recordId];
            }
        }else if(dr.getName().equalsIgnoreCase('Policy_Endorsement__c')){
            if(endorsement==null){
                endorsement = [select id,RecordType.Name,Policy__c,Policy__r.Cancel_Date__c,Policy__r.Expiration_Date__c,name,ENDORSEMENT_EFFECTIVE_DATE__C, POLICY_NUMBER__C , POLICY_FIRM__C from POLICY_ENDORSEMENT__c where id=: recordId];
                
            }
        }else if(dr.getName().equalsIgnoreCase('Policy_Quote__c')){
            if(quote == null){
                quote = [select id,Policy__r.EFFECTIVE_DATE__C,Policy__r.Name,Policy__r.Account__r.Name,Name from Policy_Quote__c where id=:recordId];
            }
        }
    }
    public String getrecordId(){
        return recordId;
    }
}