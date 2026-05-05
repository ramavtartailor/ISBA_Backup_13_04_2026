/*
Created By      :   Shoukat Hussain
Created Date    :   11/27/2016
Purpose         :   1) Create Policy_Claim_Detial record for Reserve when Create a new Claim    


*/
trigger Policy_Claim_Trg on Policy_Claim__c  (Before Insert,  Before Update,  Before Delete, 
                                              After  Insert,  After  Update,  After  Delete, After Undelete) 
{
    
    TriggerFactory.createHandler(Policy_Claim__c.sObjectType); 
    if(trigger.isAfter && trigger.isUpdate){
        Set<String> recIds = new Set<String>();
        for(Policy_Claim__c pc : trigger.new ){
            system.debug(pc.GL_5051__c);
            system.debug(trigger.oldMap.get(pc.Id).GL_5051__c);
            if(pc.GL_5051__c != null && pc.GL_5051__c >= 20000 && (trigger.oldMap.get(pc.Id).GL_5051__c == null || trigger.oldMap.get(pc.Id).GL_5051__c < 20000 )){
                recIds.add(pc.Id);
            }
        }
        if(!recIds.isEmpty()){
           QuickClaimController.sendEmailAlert(recIds, 'ARDC_Coverage_alert_email');
        }
    }
}