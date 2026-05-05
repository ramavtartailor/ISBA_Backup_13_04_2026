/*
 * 
 * Created By     : Ali Zaidi
 * Created Date   : 11/20/2016
 * Purpose        : This trigger at the time of creation was made for completing the functional endorsement customization.
 * Name           : PolicyEndorsementTrg
 * Referenced     : Currently at the time of creation this trigger is referenced on Policy_Endorsement__c Object.
 * 
 *  
 */
trigger PolicyEndorsementTrg on Policy_Endorsement__c (Before Insert, Before Update, Before Delete, After Insert, After Update, After Delete, After Undelete) {
    System.debug('1---PolicyEndorsementTrg'); 
    TriggerFactory.createHandler(Policy_Endorsement__c.sObjectType);
        
    if(Trigger.isBefore && Trigger.isUpdate){
        //update Link
        for(Policy_Endorsement__c pe: Trigger.new){
            if(!String.isNotBlank(pe.Application_Form_Link__c)){
                pe.Application_Form_Link__c = getUrl() + '?id=' + EncodingUtil.urlEncode(EZQOnlineApplicationFormCtrl.processEncryption(pe.Id,Label.Encryption_key_Policy_Id),'UTF-8');
            }
        }
    }
    else if(Trigger.isAfter && Trigger.isInsert){
        //update Link
        List<Policy_Endorsement__c> updatedRecords = new List<Policy_Endorsement__c>();
        
        for(Policy_Endorsement__c pe: Trigger.new){            
            Policy_Endorsement__c peNew = new Policy_Endorsement__c();
            peNew.Id = pe.Id;            
            peNew.Application_Form_Link__c = getUrl() + '?id=' + EncodingUtil.urlEncode(EZQOnlineApplicationFormCtrl.processEncryption(pe.Id,Label.Encryption_key_Policy_Id),'UTF-8');
            updatedRecords.add(peNew);
        }
        
        if(!updatedRecords.isEmpty()){
            Update updatedRecords;
        }
        
    }
    
    public static string getUrl(){
        boolean isSb = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        if(isSb){
            return 'https://sb-portal.isbamutual.com/';
        }else{
            return 'https://portal.isbamutual.com/';
        }
	}
}