/*
Created By      :   Shoukat Hussain
Created Date    :   11/27/2016
Purpose         :   1) Create Policy_Claim_Detial record for Reserve when Create a new Claim    


*/
trigger Policy_Quote_Trg on Policy_Quote__c  (Before Insert,  Before Update, Before Delete, After  Insert,  After  Update,  After  Delete, After Undelete) {
    if(Policy_Quote_Handler.isUpdateQuote){
        TriggerFactory.createHandler(Policy_Quote__c.sObjectType); 
        System.debug('1----Policy_Quote_Trg ');
        // this method update the Premium Of Policy Modified Date 19 April 2017
        New TriggerFactory().updatePremiumOfPolicy();
    }
}