public class Account_CLE_AttendancesCtrl {
	@AuraEnabled
    public static Wrapper getCLE_Attendances(String recId){
        Wrapper wrap = new Wrapper();
        system.debug(recId);
        List<CLE_Attendance__c> cleAttendees = new List<CLE_Attendance__c>();
        List<AccountContactRelation> accConRelations = new List<AccountContactRelation>([SELECT Id, ContactId, Account.Name FROM AccountContactRelation WHERE AccountId =: recId]);
        if(!accConRelations.isEmpty()){
            Set<String> conIds = new Set<String>();
            for(AccountContactRelation acr: accConRelations){
                conIds.add(acr.ContactId);
            }
            wrap.recName = accConRelations[0].Account.Name;
            
            system.debug(conIds);
            cleAttendees = [SELECT Id, Name, Contact__c, Contact__r.Name, CLE_Event__c, CLE_Event__r.Name,CLE_Event__r.Hours__c, CLE_Event__r.Date__c FROM CLE_Attendance__c WHERE Contact__c IN: conIds];
        }
        wrap.cleAttendees = cleAttendees;
        return wrap;
    }
    public Class Wrapper{
        @AuraEnabled public string recName{get;set;}
        @AuraEnabled public List<CLE_Attendance__c> cleAttendees{get;set;}
    }
}