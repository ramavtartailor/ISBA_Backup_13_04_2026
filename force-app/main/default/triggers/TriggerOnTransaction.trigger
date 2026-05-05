trigger TriggerOnTransaction on AcctSeed__Transaction__c (before insert,after insert,before delete) {
    if(Trigger.isBefore && Trigger.isInsert){
        TransactionTriggerHandler.onBeforeInsert(Trigger.new);
    }else if(Trigger.isAfter && Trigger.isInsert){
        TransactionTriggerHandler.onAfterInsert(Trigger.new, Trigger.newMap);
    }else if(Trigger.isBefore && Trigger.isDelete){
        TransactionTriggerHandler.onBeforeDelete(Trigger.old);
    }
}