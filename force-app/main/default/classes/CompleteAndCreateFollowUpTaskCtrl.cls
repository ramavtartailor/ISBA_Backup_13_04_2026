public class CompleteAndCreateFollowUpTaskCtrl {
    @AuraEnabled
    public static CompleteAndCreateFollowUpTaskWrapper getRecordDetails(Id recordId){
        CompleteAndCreateFollowUpTaskWrapper wrapper = new CompleteAndCreateFollowUpTaskWrapper(); 
        Task taskObj = [select Id,Note__c,Subject,Description,WhatId,Note__r.Subject__c,Note__r.Description__c,Note__r.Type__c from Task where id=: recordId];
        String whatIdName = taskObj.WhatId.getSObjectType().getDescribe().getName();
        
        wrapper.parentRecordId = taskObj.WhatId;
        wrapper.parentRecordType = whatIdName;
        
        if(whatIdName == 'Policy_Claim__c'){
            wrapper.recordTypeId = Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
        }else if(whatIdName == 'Account'){
            wrapper.recordTypeId = Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        }else if(whatIdName == 'Opportunity'){
            wrapper.recordTypeId = Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Opportunity').getRecordTypeId();
        }else{
            wrapper.recordTypeId = Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Application/Policy').getRecordTypeId();
        }
        
        if(taskObj.Note__r.Subject__c != null){
            wrapper.subject = taskObj.Note__r.Subject__c;
        }else{
            wrapper.subject = taskObj.Subject;
        }
        if(taskObj.Note__r.Subject__c != null){
            wrapper.description = taskObj.Note__r.Description__c;
        }else{
            wrapper.description = taskObj.Description;
        }
        
        wrapper.noteType = taskObj.Note__r.Type__c;
        wrapper.taskOwner = UserInfo.getUserId();
        
        return wrapper;
    }
	public class CompleteAndCreateFollowUpTaskWrapper {
        @AuraEnabled public Id parentRecordId;
        @AuraEnabled public Id recordTypeId;
        @AuraEnabled public String parentRecordType;
        @AuraEnabled public String subject;
        @AuraEnabled public String description;
        @AuraEnabled public String noteType;
        @AuraEnabled public Id taskOwner;
    }
}