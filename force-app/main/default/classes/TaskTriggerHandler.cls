public class TaskTriggerHandler {
    //public static boolean isNoteUpdateFromTask = false;
    public static void onAfterUpdate(List<Task> newList,Map<Id,Task> newMap,List<Task> oldList,Map<Id,Task> oldMap){
        //updateRelatedNote(newList,oldMap);
    }
    public static void onAfterInsert(List<Task> newList,Map<Id,Task> newMap){
        //createNewNote(newList);
    }
    /*public static void updateRelatedNote(List<Task> newList,Map<Id,Task> oldMap){
        Map<Id,Note__c> notesMap = new Map<Id,Note__c>();
        for(Task tsk : newList){
            if(tsk.Note__c !=null){
                if(tsk.Status == 'Completed' && tsk.Status != oldMap.get(tsk.Id).Status){
                    if(notesMap.containsKey(tsk.Note__c)){
                        Note__c note = notesMap.get(tsk.Note__c);
                        note.Status__c = 'Complete';
                        notesMap.put(tsk.Note__c,note);
                    }else{
                        Note__c note = new Note__c();
                        note.Id = tsk.Note__c;
                        note.Status__c = 'Complete';
                        notesMap.put(tsk.Note__c,note);
                    }
                }
                if(tsk.ActivityDate != oldMap.get(tsk.Id).ActivityDate){
                    if(notesMap.containsKey(tsk.Note__c)){
                        Note__c note = notesMap.get(tsk.Note__c);
                        note.Due_Date__c = tsk.ActivityDate;
                        notesMap.put(tsk.Note__c,note);
                    }else{
                        Note__c note = new Note__c();
                        note.Id = tsk.Note__c;
                        note.Due_Date__c = tsk.ActivityDate;
                        notesMap.put(tsk.Note__c,note);
                    }
                }
            }
        }
        if(notesMap.size()>0){
            TaskTriggerHandler.isNoteUpdateFromTask = true;
            update notesMap.values();
            TaskTriggerHandler.isNoteUpdateFromTask = false;
        }
    }*/
    /*public static void createNewNote(List<Task> newList){
        Map<Id,Note__c> notesMap = new Map<Id,Note__c>();
        for(Task tsk : newList){
            Note__c note = new Note__c();
            note.Description__c = tsk.Description;
            note.Subject__c = tsk.Subject;
            note.Type__c = tsk.Type__c;
            note.Status__c = (tsk.Status == 'Completed' ? 'Complete ':'Pending');
            //system.debug('sObjName---'+tsk.WhatId.getSObjectType().getDescribe().getName());
            String sObjName = tsk.WhatId.getSObjectType().getDescribe().getName();
            
            if(sObjName  == 'Account'){
                note.Account__c = tsk.WhatId;
                note.RecordTypeId = Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Account').getRecordTypeId();
            }else if(sObjName  == 'Policy__c'){
                note.Policy__c = tsk.WhatId;
                note.RecordTypeId = Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Application/Policy').getRecordTypeId();
            }else if(sObjName  == 'Policy_Claim__c'){
                note.Claim__c = tsk.WhatId;
                note.RecordTypeId = Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
            }else if(sObjName  == 'Opportunity'){
                note.Opportunity__c = tsk.WhatId;
                note.RecordTypeId = Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Opportunity').getRecordTypeId();
            }
            notesMap.put(tsk.Id,note);
        }
        if(notesMap.size()>0){
            insert notesMap.values();
            List<Task> tasksToUpdate = new List<Task>();
            for(Id ids : notesMap.keySet()){
                if(String.isNotBlank(notesMap.get(ids).Id)){
                    tasksToUpdate.add(new Task(Id = ids ,Note__c = notesMap.get(ids).Id));
                }
            }
            if(tasksToUpdate.size() > 0){
                update tasksToUpdate;
            }
        }
    }*/
}