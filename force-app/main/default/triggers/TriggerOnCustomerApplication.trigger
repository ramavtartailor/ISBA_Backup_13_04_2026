trigger TriggerOnCustomerApplication on Customer_Application__c (before insert, before update, after update, after insert) {
	
    if(trigger.isAfter){        
        if(trigger.isInsert){
            TriggerOnCustomerApplicationController.afterInsert(trigger.new, trigger.oldMap);
        }
    }
    if(trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate){
            TriggerOnCustomerApplicationController.assignContact(trigger.new, trigger.oldMap);
            TriggerOnCustomerApplicationController.assignAccount(trigger.new, trigger.oldMap);
        }
    }
}