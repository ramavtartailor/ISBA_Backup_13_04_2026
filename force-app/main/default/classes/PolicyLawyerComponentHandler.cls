public class PolicyLawyerComponentHandler {
    @AuraEnabled
    public static List<Policy_Lawyer__c> getPolicyLawyers(String recordId, boolean allRecords){
        List<Policy_Lawyer__c> policyLawyers = new List<Policy_Lawyer__c>();
        Set<Id> contactIds = new Set<Id>();
        String objName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        if(objName == 'Account'){
            for(Policy_Lawyer__c lawyer : [select id,Account__r.Name,Account__c,Lawyer_Name__c,Lawyer_Contact_Id__c,Hire_Date__c,ARDC_Number__c,ISBA_Number__c,Rate_At__c,Prior_Act_Date__c, 
                                           Policy__c,Policy_Number__c,Policy__r.Name from Policy_Lawyer__c where Account__c=:recordId order by Lawyer__r.Contact__r.LastName ASC,Policy__r.Effective_Date__c DESC]){
                                               if(!contactIds.contains(lawyer.Lawyer_Contact_Id__c)){
                                                   contactIds.add(lawyer.Lawyer_Contact_Id__c);
                                                   policyLawyers.add(lawyer);
                                               }     
            }
        }
        return policyLawyers;
    }
}