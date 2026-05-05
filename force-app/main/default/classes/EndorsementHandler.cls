/*
 * 
 * Created By     : Ali Zaidi
 * Created Date   : 11/30/2016
 * Purpose        : Trigger Handler for the Endorsement SObject. This class implements the ITrigger interface to help ensure the trigger code is bulkified and all in one place.
 * Name           : EndorsementHandler
 * Referenced     : Currently at the time of creation this class is referenced by TriggerFactory.
 * 
 *  
 */
public with sharing class EndorsementHandler implements ITrigger {
	public EndorsementHandler() {
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
        // Call Endorsement Gateway Helper Function To Validate Record Type Id.
        EndorsementGateway.checkEndorsementRecordTypeId(newItems.values());
	}
	
	public void afterUpdate(Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {
        // Call Endorsement Gateway Helper Function To Validate Record Type Id.
        EndorsementGateway.checkEndorsementRecordTypeId(oldItems,newItems);
	}
	
	public void afterDelete(Map<Id,SObject> oldItems) {
	}

	public void andFinally() {
	}
}