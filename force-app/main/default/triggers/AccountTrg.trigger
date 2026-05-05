/*
 * 
 * Created By     : Ali Zaidi
 * Created Date   : 11/17/2016
 * Purpose        : This trigger at the time of creation was made to replace the flow that was written in the first phase to populate the Id and Policy Number of active policy on Account.
 * Name           : AccountTrg
 * Referenced     : Currently at the time of creation this trigger is referenced on Account Object.
 * 
 *  
 */
trigger AccountTrg on Account (Before Insert, Before Update, Before Delete, After Insert, After Update, After Delete, After Undelete) {
    TriggerFactory.createHandler(Account.sObjectType);
}