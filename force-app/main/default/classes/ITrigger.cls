/*
 * 
 * Created By     : Ali Zaidi
 * Created Date   : 11/19/2016
 * Purpose        : Interface containing methods Trigger Handlers must implement to enforce best practice and bulkification of triggers.
 * Name           : ITrigger
 * Referenced     : Currently at the time of creation this class is referenced by TriggerFactory.
 * 
 *  
 */
public interface ITrigger 
{
	/*
	 * bulkBefore
	 *
	 * This method is called prior to execution of a BEFORE trigger. Use this to cache
	 * any data required into maps prior execution of the trigger.
	 */
	void bulkBefore();
	
	/*
	 * bulkAfter
	 *
	 * This method is called prior to execution of an AFTER trigger. Use this to cache
	 * any data required into maps prior execution of the trigger.
	 */
	void bulkAfter();
	
	/*
	 * beforeInsert
	 *
	 * This method is called iteratively for each record to be inserted during a BEFORE
	 * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
	 */
	void beforeInsert(List<SObject> newItems);
	
	/*
	 * beforeUpdate
	 *
	 * This method is called iteratively for each record to be updated during a BEFORE
	 * trigger.
	 */
	void beforeUpdate(Map<Id,SObject> oldItems, Map<Id,SObject> newItems);

	/*
	 * beforeDelete
	 *
	 * This method is called iteratively for each record to be deleted during a BEFORE
	 * trigger.
	 */
	void beforeDelete(Map<Id,SObject> oldItems);

	/*
	 * afterInsert
	 *
	 * This method is called iteratively for each record inserted during an AFTER
	 * trigger. Always put field validation in the 'After' methods in case another trigger
	 * has modified any values. The record is 'read only' by this point.
	 */
	void afterInsert(Map<Id,SObject> newItems);

	/*
	 * afterUpdate
	 *
	 * This method is called iteratively for each record updated during an AFTER
	 * trigger.
	 */
	void afterUpdate(Map<Id,SObject> oldItems, Map<Id,SObject> newItems);

	/*
	 * afterDelete
	 *
	 * This method is called iteratively for each record deleted during an AFTER
	 * trigger.
	 */
	void afterDelete(Map<Id,SObject> oldItems);

	/*
	 * andFinally
	 *
	 * This method is called once all records have been processed by the trigger. Use this 
	 * method to accomplish any final operations such as creation or updates of other records.
	 */
	void andFinally();
}