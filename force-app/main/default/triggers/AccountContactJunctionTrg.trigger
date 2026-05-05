/*
 * 
 * Created By     : Ali Zaidi
 * Created Date   : 11/17/2016
 * Purpose        : This trigger at the time of creation was made to populate the name of the AccountContactJunction record.
 * Name           : AccountContactJunctionTrg
 * Referenced     : Currently at the time of creation this trigger is referenced on AccountContactJunction Object.
 * 
 *  
 */
trigger AccountContactJunctionTrg on AccountContactJunction__c (Before Insert, Before Update, Before Delete, After Insert, After Update, After Delete, After Undelete) {
    TriggerFactory.createHandler(AccountContactJunction__c.sObjectType);
    
    if(trigger.isAfter && trigger.isUpdate){
        Set<Contact> contactsToUpdate = new Set<Contact>();
        for(AccountContactJunction__c acj : trigger.new){
            if(acj.Latest_Application__c != trigger.oldMap.get(acj.Id).Latest_Application__c || acj.Latest_Policy__c != trigger.oldMap.get(acj.Id).Latest_Policy__c){
                contactsToUpdate.add(new Contact(Id = acj.Contact__c, Latest_Application__c = acj.Latest_Application__c, Latest_Policy__c = acj.Latest_Policy__c));
            }
        }
        Update new List<Contact>(contactsToUpdate);
    }
    if(trigger.isAfter && trigger.isInsert){
        Set<Contact> contactsToUpdate = new Set<Contact>();
        for(AccountContactJunction__c acj : trigger.new){
            if(acj.Latest_Application__c != null || acj.Latest_Policy__c != null){
                contactsToUpdate.add(new Contact(Id = acj.Contact__c, Latest_Application__c = acj.Latest_Application__c, Latest_Policy__c = acj.Latest_Policy__c));
            }
        }
        Update new List<Contact>(contactsToUpdate); 
    }
}