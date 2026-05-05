public class FirmERECtrl {
    @AuraEnabled
    public static List<Policy_Endorsement__c> get107Endorsements(String policyId){
        return [select id,Name,Endorsement_Number__c,Name_Of_Insured__c,Coverage_Term__c from Policy_Endorsement__c where Policy__c =:  policyId and Endorsement_Number__c like 'IL 107%' order by Endorsement_Number__c];
    }
}