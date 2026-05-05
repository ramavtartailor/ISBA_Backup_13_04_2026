trigger CashReceiptTrigger on AcctSeed__Cash_Receipt__c (before Insert, after insert) {
    if(trigger.isAfter && trigger.isInsert){
        CashReceiptTriggerHandler.onAfterInsert(trigger.new);
    }
}