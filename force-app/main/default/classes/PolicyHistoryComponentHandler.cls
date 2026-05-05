public class PolicyHistoryComponentHandler {
	@AuraEnabled
    public static List<Policy__c> getPolicies(String recordId, boolean allRecords){
        String sObjName = ((Id)recordId).getSObjectType().getDescribe().getName();
        if(sObjName == 'Policy__c'){
            Policy__c policy = [select Id,Account__c from Policy__c where  id =: recordId];
            List<Policy__c> policies = new List<Policy__c>([select Id,Name,Policy_Number__c,Effective_Date__c,Premium_Amount__c,Expiration_Date__c,Status__c,Limits__c,Deductible__c from Policy__c where Account__c =: policy.Account__c order by Effective_Date__c desc ]);
            return policies;
        }else{
            List<Policy__c> policies = new List<Policy__c>();
            return policies;
        }
    }
}