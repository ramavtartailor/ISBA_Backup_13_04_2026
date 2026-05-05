trigger TriggerOnCLEAttendance on CLE_Attendance__c (before insert, after insert,after update, after delete, after undelete) {
    Set<String> conIds = new Set<String>();
    if(Trigger.isBefore && Trigger.isInsert){
        CLEAttendanceTriggerHandler.onBeforeInsert(Trigger.new);   
    }else if(Trigger.isAfter && Trigger.isInsert){
        CLEAttendanceTriggerHandler.onAfterInsert(Trigger.new,Trigger.newMap);
        
        for(CLE_Attendance__c att:Trigger.new){
            if(String.isNotBlank(att.Contact__c)){
                conIds.add(att.Contact__c);
            }
        }

    }else if(Trigger.isAfter && Trigger.isDelete){
        CLEAttendanceTriggerHandler.onAfterDelete(Trigger.old);

        for(CLE_Attendance__c att:Trigger.old){
            if(String.isNotBlank(att.Contact__c)){
                conIds.add(att.Contact__c);
            }
        }
    }

    else if(Trigger.isAfter && Trigger.isUndelete){
        for(CLE_Attendance__c att:Trigger.new){
            if(String.isNotBlank(att.Contact__c)){
                conIds.add(att.Contact__c);
            }
        }
    }

    else if(Trigger.isAfter && Trigger.isUpdate){
        for(CLE_Attendance__c att:Trigger.new){
            if(String.isNotBlank(att.Contact__c) && String.isNotBlank(Trigger.oldMap.get(att.Id).Contact__c)){
                if(att.Contact__c != Trigger.oldMap.get(att.Id).Contact__c){
                    conIds.add(att.Contact__c);
                    conIds.add(Trigger.oldMap.get(att.Id).Contact__c);
                }
            }
            else if(String.isNotBlank(att.Contact__c)){
                conIds.add(att.Contact__c);
            }
            else if(String.isNotBlank(Trigger.oldMap.get(att.Id).Contact__c)){
                conIds.add(Trigger.oldMap.get(att.Id).Contact__c);
            }
        }
    }

    if(!conIds.isEmpty()){
        CLEAttendanceTriggerHandler.updateAttendanceCount(conIds);
    }
}