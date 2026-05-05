/*
 * 
 * Created By     : Shoukat Hussain
 * Created Date   : 12/02/2016
 * Purpose        : Trigger Handler for the Policy_claim SObject. This class implements the ITrigger interface to help ensure the trigger code is bulkified and all in one place.
 * Name           : Policy_Claim_Handler
 * Referenced     : Currently at the time of creation this class is referenced by TriggerFactory.
 * 
 *  
 */
public class Policy_Claim_Handler implements ITrigger {
//public with sharing class EndorsementHandler implements ITrigger {
    public Policy_Claim_Handler() {
    }

    public void bulkBefore() {
    }
    
    public void bulkAfter() {
    }
        
    public void beforeInsert(List<SObject> newItems) {
        
        if(Label.Allow_Claim_For_Expired_Policies == 'N'){
            Policy_Claim_Gateway.validateClaimPolicy(newItems);
        }
        
        //Add Claim Ids increament counter
        PolicyClaimCounter.createClaimIds(newItems);
        
          // Update Policy information on new claim
          Policy_Claim_Gateway.UpdatePolicyInfoOnClaim(newItems);
          
          // Udate Claims Check 
          Policy_Claim_Gateway.UpdateClaimCheck(newItems);

          // Update Custom setting [Deductible LAE applied limit ] for claim 
         Policy_Claim_Gateway.UpdateCustomSettingInfoOnClaim(newItems);
        for(SObject sObj : newItems){
            Policy_Claim__c obj = (Policy_Claim__c)sObj;
            if(obj.Claim_Id__c!=null){
                obj.Name = obj.Claim_Id__c;
            }
            if(obj.Reserve_Loss__c==null){
                obj.Reserve_Loss__c=0.0;
            }
            if(obj.Reserve_LAE__c==null){
                obj.Reserve_LAE__c=0.0;
            }
        }

		Policy_Claim_Gateway.UpdateScheduleDate(newItems);	
        
        
        
    }
    
    public void beforeUpdate(Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {
          // Udate Claims Check 
          List<Policy_Claim__c> newItemsLst =  newItems.values(); 
        Map<Id,Policy_Claim__c> oldClaimMap =  (Map<Id,Policy_Claim__c>)oldItems;
          Policy_Claim_Gateway.UpdateClaimCheck(newItemsLst);

        for(Policy_Claim__c obj : newItemsLst){
            if(obj.Claim_Status__c == 'Closed' && oldClaimMap.get(obj.Id).Claim_Status__c!='Closed'){
                if(obj.ClaimCloseDAte__c == null){
                    obj.addError('In order to close the claim Claim close date not empty.');
                } else if(obj.GL_5035__c != 0){
                    obj.addError('In order to close the claim LAE Reserve must be 0.');
                } else if(obj.GL_5010__c !=0 ){
                    obj.addError('In order to close the claim Loss Reserve must be 0.');
                } else if(String.isBlank(obj.Claim_Close_Payment_Resolutions__c)){
                    obj.addError('In order to close the claim Claim Close Payment Resolutions not empty.');
                } else if(String.isBlank(obj.Claim_Close_Reasons__c)){
                    obj.addError('In order to close the claim Claim Close Reasons not empty.');
                }
            }
        }
    }
    
    public void beforeDelete(Map<Id,SObject> oldItems) {
    }
    
    public void afterInsert(Map<Id,SObject> newItems) {
        List<Policy_Claim__c> newItemsLst =  newItems.values();  
        Policy_Claim_Gateway.InsertReserveOpenRecord(newItemsLst);
        Policy_Claim_Gateway.createFollowUpTasks(newItemsLst);    }
    
    public void afterUpdate(Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {
        System.debug(oldItems);
        System.debug(newItems);
        //Policy_Claim_Gateway.InsertReserveRecord((Map<Id,Policy_Claim__c>)oldItems,(Map<Id,Policy_Claim__c>)newItems);
    }
    
    public void afterDelete(Map<Id,SObject> oldItems) {
    }

    public void andFinally() {
    }
}