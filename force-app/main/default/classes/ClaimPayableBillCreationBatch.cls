global class ClaimPayableBillCreationBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        DateTime cutoff = DateTime.newInstanceGMT(2026, 2, 24, 0, 0, 0);
        String queryStr = 'SELECT Id, Claim__c, Type__c, AcctSeed__Total__c, AcctSeed__Balance__c, AcctSeed__Date__c FROM AcctSeed__Account_Payable__c WHERE CreatedDate >= :cutoff AND (Type__c = \'LAE Pay\' OR Type__c = \'Loss Pay\') ORDER BY CreatedDate';
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext bc, List<AcctSeed__Account_Payable__c> payables){
        AccountPayableTriggerHandler.afterupdate(payables);
    }
    
    global void finish(Database.BatchableContext bc){
    }
}