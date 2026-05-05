/*
 * 
 * Created By     : Ali Zaidi
 * Created Date   : 01/16/2017
 * Purpose        : Trigger Handler for the Policy Lawyer SObject. This class implements the ITrigger interface to help ensure the trigger code is bulkified and all in one place.
 * Name           : PolicyLawyerHandler
 * Referenced     : Currently at the time of creation this class is referenced by TriggerFactory.
 * 
 *  
 */
public with sharing class PolicyLawyerHandler implements ITrigger {
    
    
    public PolicyLawyerHandler() {
	}

	public void bulkBefore() {
	}
	
	public void bulkAfter() {
	}
		
    public void beforeInsert(List<SObject> newItems) {
        // Duplicate Lawyer check on Application / Policy.
        PolicyLawyerGateway.validateLawyer(newItems);
        //PolicyLawyerGateway.updateCLECredit(newItems);
    }
	
	public void beforeUpdate(Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {
        if(PolicyLawyerGateway.boo){
            //PolicyLawyerGateway.updateCLECredit(newItems.values());
            PolicyLawyerGateway.generateLawyerStep(oldItems,newItems);
        }
	}
	
	public void beforeDelete(Map<Id,SObject> oldItems) {
        List<Policy_Lawyer__c> oldList = oldItems.values();
        PolicyLawyerGateway.preventLawyersDeletionForPolicy(oldList);
	}
	
	public void afterInsert(Map<Id,SObject> newItems) {
        // Validate the Account from Policy.
         PolicyLawyerGateway.validateAccount(newItems);
        // Generate Step for each lawyer added to the Application.
        PolicyLawyerGateway.generateLawyerStep(newItems);
        PolicyLawyerGateway.updateLatestPolicyOnLawyer(newItems);
	}
	
	public void afterUpdate(Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {
		// Update Step for each lawyer added to the Application, if Prior Act Date or Policy Effective Date changes.
        if(PolicyLawyerGateway.boo){
            PolicyLawyerGateway.boo = false;
            //PolicyLawyerGateway.generateLawyerStep(oldItems,newItems);
            PolicyLawyerGateway.updatePremiumOnRateChange(oldItems,newItems);
        }
    }
	
	public void afterDelete(Map<Id,SObject> oldItems) {
	}

	public void andFinally() {
	}
}