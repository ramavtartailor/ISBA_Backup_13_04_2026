public with sharing class QuickPolicyController {

    @AuraEnabled
    public static Policy__c getPolicy(Id policyId) {
        return [SELECT Id,Name,Renewal_Type__c,AOP_Percentage__c,Total_Lawyers__c,Total_Quotes__c,Is_Allow_Calculate_Premium__c  
                FROM Policy__c WHERE Id = :policyId];
    }
    
    @AuraEnabled
    public static List<Policy__c> getPolicies(Id policyId) {
        return [SELECT Id,Name,Renewal_Type__c,AOP_Percentage__c,Total_Lawyers__c,Total_Quotes__c,Is_Allow_Calculate_Premium__c  
                FROM Policy__c limit 500];
    }
    
    @AuraEnabled
    public static void updatePolicy(Id policyId){
        
        List<Policy__c> lstPolicy = [SELECT Id,Name,Renewal_Type__c,AOP_Percentage__c,Total_Lawyers__c,Total_Quotes__c,Is_Allow_Calculate_Premium__c  
                FROM Policy__c WHERE Id = :policyId];
                    
        lstPolicy[0].Is_Allow_Calculate_Premium__c = true;
        
        update lstPolicy;
    }
    
}