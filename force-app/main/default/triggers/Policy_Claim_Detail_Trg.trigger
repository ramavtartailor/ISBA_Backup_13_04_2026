/*
Created By      :   Shoukat Hussain
Created Date    :   12/28/2016
Purpose         :   1) Create Accounting seeds transaction    


*/
trigger Policy_Claim_Detail_Trg on Policy_Claim_Detail__c  (Before Insert,  Before Update,  Before Delete, 
                                              After  Insert,  After  Update,  After  Delete, After Undelete) {
    TriggerFactory.createHandler(Policy_Claim_Detail__c.sObjectType); 
    }