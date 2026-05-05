public class PolicyEndorsReject {
    @AuraEnabled
        public static Policy_Endorsement__c getPolicyEndorse(String policyId){
            Policy_Endorsement__c objPolicyEndorse = [SELECT Id,Name,Event_Status__c,Endorsement_Number__c,Endorsement_Version__c,Policy__c
                                                    FROM Policy_Endorsement__c WHERE Id =: policyId];
            return objPolicyEndorse ;
        }
        @AuraEnabled
        public static void deletePolicy(String policyId){
            Policy_Endorsement__c objPoliceEndor = new Policy_Endorsement__c(id = policyId);             
            delete objPoliceEndor;
        }
}