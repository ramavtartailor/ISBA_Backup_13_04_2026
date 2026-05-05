public class OverDueTaskComponentExt {
	
    @AuraEnabled
    public static List<Task> getOpenTask(String objRecordId){
        
        List<Task> taskObjList = [SELECT Id, ActivityDate, Status, Subject FROM Task WHERE WhatId =: objRecordId 
                        AND Status != 'Completed' ORDER BY ActivityDate DESC];
        
        system.debug('taskObjList :: ' + taskObjList);
        return taskObjList;
        
    }
}