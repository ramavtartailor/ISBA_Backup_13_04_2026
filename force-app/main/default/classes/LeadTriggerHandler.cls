public class LeadTriggerHandler{
    public static void onAfterUpdate(List<Lead> newList){
        Set<Id> convertedContactId = new Set<Id>();
        Map<String, String> leadWithConIdMap = new Map<String, String>();
        for(Lead objLead : newList) {
            if(objLead.IsConverted){
                convertedContactId.add(objLead.ConvertedContactId);
                leadWithConIdMap.put(objLead.Id, objLead.ConvertedContactId);
            }   
        }
        
        ID accountId = [select id,name from Account where name =: Label.Bucket_Account limit 1].id;
        List<Contact> conList = [select id,AccountId from contact where id in : convertedContactId];
        system.debug('conList'+conList);
        For(Contact con : conList) {
            con.AccountId = accountId;
        }
        
        List<CLE_Attendance__c> attenedanceList = [SELECT Id, Lead__c, Contact__c, Event_Hours__c, Event_Date__c FROM CLE_Attendance__c WHERE Lead__c IN: leadWithConIdMap.keySet() AND Contact__c = null];
        system.debug('attenedanceList => '+attenedanceList);
        
        if(!attenedanceList.isEmpty()){
            for(CLE_Attendance__c att: attenedanceList){
                att.Contact__c = leadWithConIdMap.get(att.Lead__c);
            }
            
            Update attenedanceList;
            CLEAttendanceTriggerHandler.updateLawyersCredit(attenedanceList);
        }
        
        if(! conList.isEmpty()) {
            update conList;
        }
    }
}