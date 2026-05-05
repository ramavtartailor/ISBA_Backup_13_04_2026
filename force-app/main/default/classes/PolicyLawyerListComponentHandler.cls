public class PolicyLawyerListComponentHandler {
    @AuraEnabled
    public static List<Policy_Lawyer__c> getPolicyLawyers(String recordId){
        List<Policy_Lawyer__c> policyLawyers = new List<Policy_Lawyer__c>([select id,Lawyer_Name__c,Prior_Act_Date__c,Step__c,Overriding_Step_Value__c,Rate_At__c,Primary__c,X5_5__c,X10_10__c,ADJ_MOD__c,Premium__c,Mod_230__c,Mod_234__c,Mod_261__c,CLE_Credit__c,Excess__c,Term__c,Premium_Formula__c from Policy_Lawyer__c where Policy__c =: recordId order by Lawyer__r.Contact__r.LastName]);
    	return policyLawyers;
    }
}