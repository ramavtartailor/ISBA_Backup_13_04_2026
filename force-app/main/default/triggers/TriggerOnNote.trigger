trigger TriggerOnNote on Note__c (before delete,before update,after insert, after Update) {
    if(Trigger.isBefore && Trigger.isDelete){
        NoteTriggerHandler.onBeforeDelete(Trigger.old);
    }else if(Trigger.isBefore && Trigger.isUpdate){
        NoteTriggerHandler.onBeforeUpdate(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);
    }else if(Trigger.isAfter && Trigger.isInsert){
        NoteTriggerHandler.onAfterInsert(Trigger.new,Trigger.newMap);
        NoteTriggerHandler.UpdateLatestNoteOnClaim(trigger.new);
    }
    else if(Trigger.isAfter && trigger.isUpdate){
        NoteTriggerHandler.UpdateLatestNoteOnClaim(Trigger.new);
    } 
}