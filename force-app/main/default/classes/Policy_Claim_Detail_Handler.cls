/*
 * 
 * Created By     : Shoukat Hussain
 * Created Date   : 12/28/2016
 * Purpose        : Trigger Handler for the Policy_claim_Detail SObject. This class implements the ITrigger interface to help ensure the trigger code is bulkified and all in one place.
 * Name           : Policy_Claim_Detail_Handler
 * Referenced     : Currently at the time of creation this class is referenced by TriggerFactory.
 * 
 *  
 */
public class Policy_Claim_Detail_Handler implements ITrigger {
//public with sharing class EndorsementHandler implements ITrigger {
	public Policy_Claim_Detail_Handler() {
	}

	public void bulkBefore() {
	}
	
	public void bulkAfter() {
	}
		
	public void beforeInsert(List<SObject> newItems) {} public void beforeUpdate(Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {} 	public void beforeDelete(Map<Id,SObject> oldItems) {}
	
	public void afterInsert(Map<Id,SObject> newItems) {
        List<Policy_Claim_Detail__c> newItemsLst =  newItems.values();  
        // Create All list which will use for different purposes
        List<Policy_Claim_Detail__c> CreateAccountingSeeds = new List<Policy_Claim_Detail__c>();
        List<Policy_Claim_Detail__c> CreateAutoDeductible  = new List<Policy_Claim_Detail__c>();
        
        //Data segrigate 
        for(Policy_Claim_Detail__c pcd : newItemsLst){
            
			If(pcd.Type__c == 'Open Reserve' || pcd.Type__c == 'User Reserve' || pcd.Type__c == 'Close Reserve' 	 || pcd.Type__c == 'Reopen Reserve' ||pcd.Type__c == 'LAE Payment'  || pcd.Type__c == 'Loss Payment' || pcd.Type__c == 'Deductible Expense' || pcd.Type__c == 'Deductible Loss' || pcd.Type__c == 'Deductible Expense New' ||pcd.Type__c == 'Change in Ceded LAE Reserve' || pcd.Type__c == 'Change in Ceded Loss Reserve' || pcd.Type__c == 'Due from Reins. - LAE' ||pcd.Type__c == 'Due from Reins. - Loss' 		|| pcd.Type__c == 'Unallocated LAE Payment' 	 || pcd.Type__c == 'Claim Coverage - ARDC' ){
				CreateAccountingSeeds.add(pcd);
               }                        

            If(pcd.Type__c=='Loss Payment' || pcd.Type__c=='LAE Payment' ){
                CreateAutoDeductible.add(pcd);
            }
        }
          System.debug(CreateAccountingSeeds.size()+'<===CreateAccountingSeeds===>'+CreateAccountingSeeds.size());      
		//Create Accounting Seeds transaction 
        If(CreateAccountingSeeds.size()>0){
        	Policy_Claim_Detail_Gateway.CreateAccountingSeedsTransaction(CreateAccountingSeeds);    
        }
          System.debug(CreateAutoDeductible.size()+'<===CreateAccountingSeeds===>'+CreateAutoDeductible.size());            
        //Create Auto deductible transaction
        if(CreateAutoDeductible.size()>0){
        	Policy_Claim_Detail_Gateway.CreateAutoDedcutibleRecord(CreateAutoDeductible);    
        }
       
	}
	
	public void afterUpdate(Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {} public void afterDelete(Map<Id,SObject> oldItems) {} public void andFinally() {}
}