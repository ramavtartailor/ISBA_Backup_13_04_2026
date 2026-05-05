/*
 * 
 * Created By     : Ali Zaidi
 * Created Date   : 11/17/2016
 * Purpose        : This trigger at the time of creation was made to automate the Master Endorsement records and to put in custom validation rules.
 * Name           : EndorsementTrg
 * Referenced     : Currently at the time of creation this trigger is referenced on Endorsement Object.
 * 
 *  
 */
trigger EndorsementTrg on Endorsement__c (Before Insert, Before Update, Before Delete, After Insert, After Update, After Delete, After Undelete) {
    TriggerFactory.createHandler(Endorsement__c.sObjectType);
}