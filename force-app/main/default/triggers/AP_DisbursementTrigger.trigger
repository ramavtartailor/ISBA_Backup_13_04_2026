/*
    Name : AP_DisbursementTrigger 
    Author : Shweta Fulara
    Date : 28th June 2017
    Description : Trigger on AcctSeed__AP_Disbursement__c .
*/
trigger AP_DisbursementTrigger on AcctSeed__AP_Disbursement__c (after insert,before insert) {

    if(trigger.isAfter && trigger.isInsert){
    
        System.debug('trigger.new----'+trigger.new);
        //ApDisburseTriggerHandler.reverseJournalEntries(trigger.new);
    
    } else if(trigger.isBefore && trigger.isInsert) {
        
        ApDisburseTriggerHandler.beforeinsertUpdateClaim(trigger.new);    
        
    }

}