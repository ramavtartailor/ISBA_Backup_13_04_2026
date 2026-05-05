public class StatusDescriptionCompCtrl {
    @AuraEnabled
    public static Policy__c getRecord(string RecordId){
        Policy__c pol = [select Id,Status_Description__c from Policy__c where Id =: RecordId];
        return pol;
    }
    
    @AuraEnabled
    public static string saveRecord(Policy__c pol){
        try{
            update pol;
            return 'Success';
        }catch(Exception e){
            system.debug('e.get'+e.getMessage()+'number::'+e.getLineNumber());
            system.debug('++'+e.getStackTraceString());
            return e.getMessage();
        }
    }
    
        @AuraEnabled
    public static Customer_Application__c getOnlineApp(String RecordId){
        Customer_Application__c app = [
            SELECT Id, Status_Description__c
            FROM Customer_Application__c
            WHERE Id = :RecordId
        ];
        return app;
    }

    @AuraEnabled
    public static String saveOnlineApp(Customer_Application__c app){
        try{
            update app;
            return 'Success';
        }catch(Exception e){
            System.debug('e.get'+e.getMessage()+'number::'+e.getLineNumber());
            System.debug('++'+e.getStackTraceString());
            return e.getMessage();
        }
    }
}