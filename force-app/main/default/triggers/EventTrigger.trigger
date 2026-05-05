trigger EventTrigger on Event (after insert) {

    if(trigger.isAfter && Trigger.isInsert){
        PolicyAndBillingActivityUpdateHandler.onAfterInsertEvent(trigger.new);
    }
}