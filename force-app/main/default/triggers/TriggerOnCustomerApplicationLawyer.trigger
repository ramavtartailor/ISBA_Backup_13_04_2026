//TriggerOnCustomerApplicationTest
trigger TriggerOnCustomerApplicationLawyer on Customer_Application_Lawyer__c (before insert,before update) {
    if(Trigger.isBefore && Trigger.isInsert){
        CustomerApplicationLawyerTriggerHandler.onBeforeInsert(Trigger.new);   
    }else if(Trigger.isBefore && Trigger.isUpdate){
        CustomerApplicationLawyerTriggerHandler.onBeforeUpdate(Trigger.old,Trigger.oldMap,Trigger.new,Trigger.newMap);   
    }
}