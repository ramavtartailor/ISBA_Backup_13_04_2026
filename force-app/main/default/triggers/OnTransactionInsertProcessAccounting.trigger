trigger OnTransactionInsertProcessAccounting on AS_Transaction__c (after insert) {
    //TransactionTriggerHandler cntrl = new TransactionTriggerHandler();
    //cntrl.processTransaction();
    
    list<AS_Transaction__c> tempList = new list<AS_Transaction__c>();
    tempList = [SELECT Id,name,Transaction_Type__c,Firm_Id__c,Amount__c,Policy_Id__c,createdDate,Transaction_Sub_Type__c,Credit_Amount__c,Dividend_Credit__c ,
                Policy_Endorsement_Id__c,Claim_Id__c,Policy_Id__r.Effective_Date__c, Policy_Id__r.Expiration_Date__c,Policy_Claim_Detail__c 
                FROM AS_Transaction__c 
                WHERE Id IN : trigger.new];
    
    system.debug('***tempList--'+tempList[0]);
    set<string> transactionIdSet = new set<string>();
    
    for(AS_Transaction__c t : trigger.new){
        transactionIdSet.add(t.Id);
    }
    system.debug('transactionIdSet :: ' + transactionIdSet);
    //CM_TransactionTriggerHelper.handleTransactionInsert(JSON.serialize(tempList));
    //CM_TransactionTriggerHelper.handleTransactionInsert(JSON.serialize(transactionIdSet));
    ConvertToPolicyLtng.transactionQueueId = System.enqueueJob(new CM_TransactionTriggerQueueable(JSON.serialize(transactionIdSet)));
    
    
}