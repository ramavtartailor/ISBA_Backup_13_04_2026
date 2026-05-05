public class ContactPoliciesComponentHandler {
    @AuraEnabled
    public static List<Policy__c> getPolicies(String recordId, boolean allRecords){
        String sObjName = ((Id)recordId).getSObjectType().getDescribe().getName();
        if(sObjName == 'Contact'){
            Map<Id,Date> lawyerEffectiveDateMap = new Map<Id,Date>();
            for(Policy_Lawyer__c lawyer : [select id,Policy__c,Added_Date__c,Policy_Effective_Date__c from Policy_Lawyer__c where Lawyer__r.Contact__c =: recordId]){
                if(lawyer.Added_Date__c == null){
                    lawyerEffectiveDateMap.put(lawyer.Policy__c,lawyer.Policy_Effective_Date__c);
                }else{
                    lawyerEffectiveDateMap.put(lawyer.Policy__c,lawyer.Added_Date__c);
                }
                
            }
            List<Policy__c> policies = new List<Policy__c>();
            for(Policy__c policy : [select Id,Name,Firm_Name__c,Policy_Number__c,Effective_Date__c,Premium_Amount__c,Expiration_Date__c,Status__c,Limits__c,Deductible__c,Print_Date__c from Policy__c where Id in: lawyerEffectiveDateMap.keySet() order by Effective_Date__c desc ]){
                policy.Print_Date__c = lawyerEffectiveDateMap.get(policy.id);
                policies.add(policy);
            }
            return policies;
        }else{
            List<Policy__c> policies = new List<Policy__c>();
            return policies;
        }
    }
}