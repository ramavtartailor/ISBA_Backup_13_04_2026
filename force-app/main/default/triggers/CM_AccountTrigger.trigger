//-----Description: This trigger is used to remove the entering of picklist field

trigger CM_AccountTrigger on Account (before insert, before update, /*after update,*/ before Delete) {
    if(!trigger.isDelete){
        set<string> setOfCountyNames = new set<string>();
        for(Account acc : trigger.new){
            if(acc.AcctSeed__X1099_Vendor__c == false && String.isNotBlank(acc.X1099_Vendor__c)){
                acc.X1099_Vendor__c = null;
            }
            if(acc.CountyPicklist__c != null){
                setOfCountyNames.add(acc.CountyPicklist__c);
            }
        }   
        if(setOfCountyNames.size()>0){
            map<string, string> nameVsCountyMap = new map<string, string>();
            for(County__c c : [select id, name, County_External_ID__c, Region__c from County__c where Name IN:setOfCountyNames]){
                nameVsCountyMap.put(c.Name, c.Id);
            }
            
            for(Account acc : trigger.new){
                if(acc.CountyPicklist__c != null && nameVsCountyMap != null && nameVsCountyMap.containsKey(acc.CountyPicklist__c)){
                    acc.Billing_Address_County__c = nameVsCountyMap.get(acc.CountyPicklist__c);
                }
            }
        }
    }
    /*if(trigger.isBefore && trigger.isInsert){
        AccountTriggerHandler.onBeforeInsert(trigger.new);
    } 
    if(trigger.isAfter && trigger.isUpdate){
        AccountTriggerHandler.onAfterUpdate(trigger.new, trigger.oldMap);
    }*/
    if(trigger.isBefore && trigger.isDelete){
        //AccountTriggerHandler.onBeforeDelete(trigger.old); 
        for(Account acc: trigger.old){
            if(acc.ISBAM_Cannot_Delete__c){
                acc.addError('You cannot delete this Account.');
            }
        }
    }
    
    
}