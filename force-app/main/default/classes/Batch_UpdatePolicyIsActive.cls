global class Batch_UpdatePolicyIsActive implements Database.Batchable<sObject>,Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,Active1__c,Active__c FROM Policy__c WHERE (Active1__c = false and Active__c = true) OR (Active1__c = true and Active__c = false)';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Policy__c> policyList) {
        for(Policy__c pol: policyList){
            pol.Active1__c = pol.Active__c;
        }
        Update policyList;
    }
    
    global void finish(Database.BatchableContext bc) {
    }
    global void execute(SchedulableContext sc){
        Database.executeBatch(new Batch_UpdatePolicyIsActive(),20);
    }
}