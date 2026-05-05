public class TriggerPaymentCtrl {
	@AuraEnabled
    public static String triggerPaymentCtrl(String recordId,String noteText){
        try{
            Note__c note = new Note__c();
            AcctSeed__Billing__c billing = [select id,AcctSeed__Customer__c  from AcctSeed__Billing__c where id=: recordId];
            note.Account__c = billing.AcctSeed__Customer__c ;
            note.RecordTypeId = Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Account').getRecordTypeId();
            note.Subject__c = 'Trigger Payment';
            note.Description__c = noteText;
            insert note;
            return 'success';
        }
        catch(exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}