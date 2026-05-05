/*
 * 
 * Created By     : Ali Zaidi
 * Created Date   : 01/16/2017
 * Purpose        : Trigger Handler for the AccountContactJunction SObject. This class implements the ITrigger interface to help ensure the trigger code is bulkified and all in one place.
 * Name           : AccountContactJunctionHandler
 * Referenced     : Currently at the time of creation this class is referenced by TriggerFactory.
 * 
 *  
 */
public with sharing class AccountContactJunctionHandler implements ITrigger {
    public AccountContactJunctionHandler() {
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
        // Populate the name of AccountContactJunction with the record type name.
        AccountContactJunctionGateway.populateACJName(newItems);
	}
	
	public void afterUpdate(Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {
	}
	
	public void afterDelete(Map<Id,SObject> oldItems) {
	}

	public void andFinally() {
	}
}