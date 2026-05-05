public with sharing class CM_ApplicationDetailCTRL {
    
    public list<string> statusList {get; set;}
    public string jsonString{get; set;}
    
    public CM_ApplicationDetailCTRL(Apexpages.standardController con){
    	statusList = new list<string>();
    	jsonString = '';
        SObjectType accountType = Schema.getGlobalDescribe().get('Policy__c');
        
        //-------checking recordtypes for this object
        //GetAvailableRecordTypeNamesForSObject(accountType);
        //------------ends here---------------//
        
            Schema.SObjectField mfields = accountType.getDescribe().fields.getMap().get('Status__c');
            Map<String,Schema.SObjectField> mfields2 = accountType.getDescribe().fields.getMap();
            Schema.DescribeFieldResult  describeResult = mFields.getDescribe();
            if(describeResult.getType() == Schema.DisplayType.Picklist && describeResult.isAccessible()){
                List<Schema.PicklistEntry> P = describeResult.getPicklistValues();
                for(Schema.PicklistEntry p_temp : p){
                    if(p_temp.isActive()){
                        statusList.add(p_temp.getValue());
                    }
                    
                }
               
            }
            jsonString = JSON.serialize(statusList);
       
    }
}