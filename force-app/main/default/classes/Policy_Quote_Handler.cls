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
public without sharing  class Policy_Quote_Handler implements ITrigger {
    
    public Static Boolean isUpdateQuote = true;
    
    //public with sharing class EndorsementHandler implements ITrigger {
    public Policy_Quote_Handler() {
    }
    
    public void bulkBefore() {
    }
    
    public void bulkAfter() {
    }
    
    public void beforeInsert(List<SObject> newItems) {
    }
    
    public void beforeUpdate(Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {
        List<Policy_Quote__c> QuoteLst =  newItems.values();        
        List<Policy_Quote__c> QuoteOldLst =  oldItems.values();
        Policy_Quote_Gateway.UpdateFinalQuoteToPolicy(QuoteOldLst,QuoteLst);
    }
    
    public void beforeDelete(Map<Id,SObject> oldItems) {
        
        List<Policy_Quote__c> QuoteOldLst =  oldItems.values();
        Policy_Quote_Gateway.UpdateDeletedFinalQuoteToPolicy(QuoteOldLst);
        Policy_Quote_Gateway.preventQuoteDeletionForPolicy(QuoteOldLst);
        
    }
    
    public void afterInsert(Map<Id,SObject> newItems) {} public void afterUpdate(Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {} public void afterDelete(Map<Id,SObject> oldItems) {} public void andFinally() {}
}