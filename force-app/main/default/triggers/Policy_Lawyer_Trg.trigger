/*
Created By      :   Shoukat Hussain
Created Date    :   11/02/2016
Purpose         :   Generage Step
                :   Roll up Step  on Policy.Total Lawyers In Step 0 to 7 
*/
trigger Policy_Lawyer_Trg on Policy_Lawyer__c (Before Insert, Before Update, Before Delete, After Insert, After Update, After Delete, After Undelete) {
    TriggerFactory.createHandler(Policy_Lawyer__c.sObjectType);
    if(trigger.isAfter && trigger.isInsert){
        Policy_Lawyer_Trg_Handler.onAfterInsert(trigger.new);
    }   
    if(trigger.isAfter && trigger.isUpdate){
        Policy_Lawyer_Trg_Handler.onAfterUpdate(trigger.new, trigger.oldMap);
    }
    if(trigger.isBefore && trigger.isDelete){
        Policy_Lawyer_Trg_Handler.onBeforeDelete(trigger.oldMap);
    }
}