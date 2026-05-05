public class CreateInternalApplicationCtrl {

    @AuraEnabled
    public static Id CreateInternalApp(Customer_Application__c application) {
        
        Id recordTypeId = Schema.SObjectType.Customer_Application__c.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
        
        application.Highest_Stage__c = 'Internal Application';
        application.RecordTypeId = recordTypeId;
        upsert application;
        return application.Id;
    }
}