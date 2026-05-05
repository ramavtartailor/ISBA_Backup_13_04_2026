/*
 * 
 * Created By     : Ali Zaidi
 * Created Date   : 11/20/2016
 * Purpose        : Trigger Handler for the Policy Endorsement SObject. This class implements the ITrigger interface to help ensure the trigger code is bulkified and all in one place.
 * Name           : PolicyEndorsementHandler
 * Referenced     : Currently at the time of creation this class is referenced by TriggerFactory.
 * 
 *  
 */
public with sharing class PolicyEndorsementHandler implements ITrigger {
    public PolicyEndorsementHandler() {
    }

    public void bulkBefore() {
    }
    
    public void bulkAfter() {
    }
        
    public void beforeInsert(List<SObject> newItems) {
        // Check Endorsement Status Before Insert.
        PolicyEndorsementGateway.checkStatusValidation(newItems);
    }
    
    public void beforeUpdate(Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {
        // Check Endorsement Status Before Update.
        PolicyEndorsementGateway.checkStatusValidation(oldItems,newItems);
    }
    
    public void beforeDelete(Map<Id,SObject> oldItems) {
        System.debug('3---PolicyEndorsementHandler');
        PolicyEndorsementGateway.rollBackEndorsementOperation(oldItems);
    }
    
    public void afterInsert(Map<Id,SObject> newItems) {
        // Call the Gateway Function to set the fields for versioning and conga template.
        PolicyEndorsementGateway.setEndorsementVersion(newItems);
        // Call the Gateway Function to see if the Lawyer is already added in the system.
        PolicyEndorsementGateway.policyLawyerValidation(newItems);
        // Call Gateway Function to Perform Endorsement calculation based on Record Type.
        PolicyEndorsementGateway.performPolicyEndorsementFunctions(newItems);
    }
    
    public void afterUpdate(Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {
        // Call the Gateway Function to update the fields for versioning and conga template.
        PolicyEndorsementGateway.updateEndorsementVersion(oldItems, newItems);
        // Call Gateway function to perform policy endorsement updates.
        PolicyEndorsementGateway.updatePolicyEndorsements(oldItems,newItems);
        
    }
    
    public void afterDelete(Map<Id,SObject> oldItems) {
    }

    public void andFinally() {
    }
}