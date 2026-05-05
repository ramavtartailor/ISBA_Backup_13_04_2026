/*
 * 
 * Created By     : Ali Zaidi
 * Created Date   : 11/19/2016
 * Purpose        : Trigger Handler for the Account SObject. This class implements the ITrigger interface to help ensure the trigger code is bulkified and all in one place.
 * Name           : AccountHandler
 * Referenced     : Currently at the time of creation this class is referenced by TriggerFactory.
 * 
 *  
 */
public with sharing class AccountHandler implements ITrigger {    
    public AccountHandler() {
	}

	public void bulkBefore() {
	}
	
	public void bulkAfter() {
	}
		
	public void beforeInsert(List<SObject> newItems) {
	}
	
	public void beforeUpdate(Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {
	}
	
	public void beforeDelete(Map<Id,SObject> oldItems) {
	}
	
	public void afterInsert(Map<Id,SObject> newItems) {
       
	}
	
	public void afterUpdate(Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {
        //system.debug('Account trigger fired');
        //AccountGateway.updateAccountWithRecentPolicy(oldItems, newItems);
        /*Map<Id,Account> oldMap = (Map<Id,Account>)oldItems;
        for (Account a : (List<Account>)newItems.values()) {
            if(a.name!=oldMap.get(a.Id).Name){
                AccountGateway.UpdateAccountFolderName(a.Id);
            }
        }*/
	}
	
	public void afterDelete(Map<Id,SObject> oldItems) {
	}

	public void andFinally() {
	}
}