trigger TriggerOnPolicyAOP on Policy_AOP__c (before delete,before insert,before update) {
    if(Trigger.isDelete && Trigger.isBefore){
        PolicyAOPTriggerHandler.onBeforeDelete(Trigger.old);
    }else if(Trigger.isInsert && Trigger.isBefore){
        PolicyAOPTriggerHandler.onBeforeInsert(Trigger.new);
    }else if(Trigger.isUpdate && Trigger.isBefore){
        PolicyAOPTriggerHandler.onBeforeUpdate(Trigger.new,Trigger.oldMap);
    }
}