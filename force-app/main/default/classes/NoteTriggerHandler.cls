public class NoteTriggerHandler {
    public static void onBeforeDelete(List<Note__c> oldList){
        List<String> profileNames = Label.Notes_Delete_Update_Permission.split(',');
        Map<Id,Profile> profilesMap = new Map<Id,Profile>([select id from Profile where Name in: profileNames]);
        for(Note__c note : oldList){
            if(note.CreatedDate.addDays(5) < System.today() && !profilesMap.containsKey(UserInfo.getProfileId())){
                note.addError('Only System Administrator can delete note after 5 days from created date.');
            }
        }
    }
    public static void onBeforeUpdate(List<Note__c> newList, List<Note__c> oldList, Map<Id,Note__c> newMap, Map<Id,Note__c> oldMap){
        List<String> profileNames = Label.Notes_Delete_Update_Permission.split(',');
        Map<Id,Profile> profilesMap = new Map<Id,Profile>([select id from Profile where Name in: profileNames]);
        for(Note__c note : newList){
            if(note.CreatedDate.addDays(5) < System.today() && !profilesMap.containsKey(UserInfo.getProfileId())){
                note.addError('Only System Administrator can update note after 5 days from created date.');
            }
        }
    }
    public static void onAfterInsert(List<Note__c> newList,Map<Id,Note__c> newMap){
        List<Task> tasksList = new List<Task>();
        
        for(Note__c note : newList){
            if(note.Create_Task__c){
                Id whatId;
                if(note.Policy__c!=null){
                    whatId = note.Policy__c;
                }else if(note.Claim__c!=null){
                    whatId = note.Claim__c;
                }else if(note.Account__c!=null){
                    whatId = note.Account__c;
                } 
                Task tsk = new Task(OwnerId=(note.Task_Owner__c==null?note.CreatedById:note.Task_Owner__c),Subject=note.Subject__c,ActivityDate=note.Due_Date__c,Description=note.Description__c!=null?note.Description__c.replaceAll('<br>','\n').replaceAll('\\<.*?\\>', ''):'',WhatId=whatId,Status='In Progress',Note__c=note.Id,Type__c = note.Type__c);
                if(note.Reminder_Set__c){
                    tsk.IsReminderSet  = note.Reminder_Set__c;
                    tsk.ReminderDateTime = note.Reminder_Time__c;
                }
                tasksList.add(tsk);
            }
            if(note.Cloned_Task_Id__c!=null){
                system.debug('note.Cloned_Task_Id__c :: ' + note.Cloned_Task_Id__c);
                tasksList.add(new Task(Id=note.Cloned_Task_Id__c,Status='Completed'));
            }
        }
        upsert tasksList;
    }
    
    //added on 1 Aug 2024
    public static void UpdateLatestNoteOnClaim(List<Note__c> newList){
        List<Policy_Claim__c> updatedClaims = new List<Policy_Claim__c>();
        for(Note__c note: newList){
            if(note.Claim__c != null){
                Policy_Claim__c claim = new Policy_Claim__c();
                claim.Id = note.Claim__c;
                claim.Latest_Claim_Note__c = note.Id;
                updatedClaims.add(claim);
            }
        }
        
        if(!updatedClaims.isEmpty()){
            Update updatedClaims;
        }
    }
    
}