public class CLEAttendanceTriggerHandler {
    public static void onAfterInsert(List<CLE_Attendance__c> newList,Map<Id,CLE_Attendance__c> newMap){
        updateLawyersCredit(newList);
        updateContact(newList);
    }
    public static void onAfterDelete(List<CLE_Attendance__c> oldList){
        removeLawyersCredit(oldList);
    }
    
    public static void onBeforeInsert(List<CLE_Attendance__c> newList){
        
        Set<Id> CleEventIds = new Set<Id>();
        
        for(CLE_Attendance__c CLEAObj: newList){
            CleEventIds.add(CLEAObj.CLE_Event__c);
        }
        
        Map<Id,CLE_Event__c > CleEventMap = new   Map<Id,CLE_Event__c >([Select Id, Date__c from CLE_Event__c Where ID IN:CleEventIds]);
        
        
       for(CLE_Attendance__c CLEAObj: newList){
           if(CleEventMap.containsKey(CLEAObj.CLE_Event__c) && CleEventMap.get(CLEAObj.CLE_Event__c).Date__c != NULL)
           CLEAObj.CLE_Event_Date__c = CleEventMap.get(CLEAObj.CLE_Event__c).Date__c;
       }
        
    }

    public static void updateContact(List<CLE_Attendance__c> newList) {
        List<Contact> updateContactList = new List<Contact>();
        Set<String> conIds = new Set<String>();
        for(CLE_Attendance__c cleAttend : newList){
            if(cleAttend.Contact__c != NULL){
               conIds.add(cleAttend.Contact__c);
            }
        }
        if(!conIds.isEmpty()){
            Map<String, Contact> conMap = new Map<String, Contact>([SELECT Id, Latest_CLE_Event_Date__c FROM Contact WHERE ID IN :conIds ]);
            for(CLE_Attendance__c cleAttend : newList){
                if(cleAttend.Contact__c != NULL && conMap.containsKey(cleAttend.Contact__c) && (conMap.get(cleAttend.Contact__c).Latest_CLE_Event_Date__c == null || conMap.get(cleAttend.Contact__c).Latest_CLE_Event_Date__c < cleAttend.Event_Date__c)){
                    Contact con = new Contact();
                    con.Id = cleAttend.Contact__c;
                    con.Latest_CLE_Event_Date__c = cleAttend.Event_Date__c;
                    updateContactList.add(con);
                }
            }
            if(!updateContactList.isEmpty()){
                update updateContactList;
            }
        }
    }

    public static void updateLawyersCredit(List<CLE_Attendance__c> newList){
        Map<Id,CLE_Attendance__c> contactCLEMap = new Map<Id,CLE_Attendance__c>();
        List<Policy_Lawyer__c> policyLawyerList = new List<Policy_Lawyer__c>();
        for(CLE_Attendance__c attendance : newList){
            if(attendance.Event_Hours__c > 0 && ((contactCLEMap.containsKey(attendance.Contact__c) && attendance.Event_Date__c > contactCLEMap.get(attendance.Contact__c).Event_Date__c) || (!contactCLEMap.containsKey(attendance.Contact__c)))){
                contactCLEMap.put(attendance.Contact__c,attendance);
                system.debug('contactCLEMap :: ' + contactCLEMap.keySet());
            }
        }
        for(Policy_Lawyer__c pol : [select id,Policy__c,Policy__r.Effective_Date__c,CLE_Credit__c,Lawyer__r.Contact__c from Policy_Lawyer__c where Lawyer__r.Contact__c in: contactCLEMap.keySet() and Policy__r.RecordType.Name = 'Application' and  Policy__r.Application_Type__c = 'Renewal']){
            system.debug('pol :: ' + pol);
            if(pol.Lawyer__r.Contact__c!=null &&  contactCLEMap.containsKey(pol.Lawyer__r.Contact__c) && contactCLEMap.get(pol.Lawyer__r.Contact__c).Event_Date__c <= pol.Policy__r.Effective_Date__c.addMonths(-3) && contactCLEMap.get(pol.Lawyer__r.Contact__c).Event_Date__c > pol.Policy__r.Effective_Date__c.addMonths(-15)){
                //pol.CLE_Credit__c = 100;
                policyLawyerList.add(pol);
            }
        }
        if(policyLawyerList.size()>0){
            update policyLawyerList;
        }
    }
    public static void removeLawyersCredit(List<CLE_Attendance__c> oldList){
        Map<Id,CLE_Attendance__c> contactCLEMap = new Map<Id,CLE_Attendance__c>();
        List<Policy_Lawyer__c> policyLawyerList = new List<Policy_Lawyer__c>();
        for(CLE_Attendance__c attendance : oldList){
            if((contactCLEMap.containsKey(attendance.Contact__c) && attendance.Event_Date__c > contactCLEMap.get(attendance.Contact__c).Event_Date__c) || (!contactCLEMap.containsKey(attendance.Contact__c))){
                contactCLEMap.put(attendance.Contact__c,attendance);
                system.debug('contactCLEMap :: ' + contactCLEMap.keySet());
            }
        }
        for(Policy_Lawyer__c pol : [select id,Policy__c,Policy__r.Effective_Date__c,CLE_Credit__c,Lawyer__r.Contact__c from Policy_Lawyer__c where Lawyer__r.Contact__c in: contactCLEMap.keySet() and Policy__r.RecordType.Name = 'Application' and  Policy__r.Application_Type__c = 'Renewal']){
            system.debug('pol :: ' + pol);
            if(pol.Lawyer__r.Contact__c!=null &&  contactCLEMap.containsKey(pol.Lawyer__r.Contact__c) && contactCLEMap.get(pol.Lawyer__r.Contact__c).Event_Date__c <= pol.Policy__r.Effective_Date__c.addMonths(-3) && contactCLEMap.get(pol.Lawyer__r.Contact__c).Event_Date__c > pol.Policy__r.Effective_Date__c.addMonths(-15)){
                pol.CLE_Credit__c = null;
                policyLawyerList.add(pol);
            }
        }
        if(policyLawyerList.size()>0){
            update policyLawyerList;
        }
    }

    public static void updateAttendanceCount(Set<String> conIds) {
        List<Contact> conList = [SELECT Id , (SELECT Id, Event_Date__c FROM CLE_Attendances__r) FROM Contact WHERE Id IN :conIds];

        for(Contact con : conList){
            if(!con.CLE_Attendances__r.isEmpty()){
                con.CLE_Attendance_Count__c = con.CLE_Attendances__r.size();
            }
            else {
                con.CLE_Attendance_Count__c = 0;
            }
        }
        update conList;
    }
}