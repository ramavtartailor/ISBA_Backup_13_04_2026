trigger LeadTrigger on Lead (after update) {
    if(trigger.isAfter && trigger.isUpdate){
            LeadTriggerHandler.onAfterUpdate(trigger.new);
    }    
}