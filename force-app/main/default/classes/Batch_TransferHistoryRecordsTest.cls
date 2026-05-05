/*
* Created Date    : 12/07/2022
* Class Name      : Batch_TransferHistoryRecords
* Test Class Name : Batch_TransferHistoryRecordsTest
___________________________________________________________________________Change Log_____________________________________________________________________
Modifiedby              Case-Log        Version         Change Date         Description
__________________________________________________________________________________________________________________________________________________________
*/
@IsTest
public class Batch_TransferHistoryRecordsTest {
/*
 * Method Name : testContactHistoryObjectCreation
 * Description : This method is used to test whether the contact History object records are copied to the custom contact history object.
 */
    @isTest
    private static void  testContactHistoryObjectCreation(){
        Contact con = new Contact(LastName = 'Test', Email='Other@test.com');
        insert con;
        for(Integer i=0;i<10;i++){
            ContactHistory conhistoryRecord = new ContactHistory(Field = 'Email',ContactId = con.Id);
            insert conhistoryRecord;
        }
        Test.startTest();
        Batch_TransferHistoryRecords obj = new Batch_TransferHistoryRecords();
        Database.executeBatch(obj);
        Test.stopTest();
        List<ContactHistory> updatedList = [Select Id, Field,ContactId From ContactHistory];
        System.assertEquals(10, updatedList.size());
        List<Contact_History__c> fetchCustomList = [Select Id,Contact__c,Field__c,Created_Date__c From Contact_History__c];
        System.assertEquals(10, fetchCustomList.size());
        System.assertEquals(con.Id, fetchCustomList[0].Contact__c);
    }
/*
 * Method Name : testAccountHistoryObjectCreation
 * Description : This method is used to test whether the account History object records are copied to the custom account history object.
 */
    @isTest
    private static void  testAccountHistoryObjectCreation(){
        Account acc = new Account(Name = 'Test');
        insert acc;
        for(Integer i=0;i<10;i++){
            AccountHistory acchistoryRecord = new AccountHistory(Field = 'TextName',AccountId = acc.Id);
            insert acchistoryRecord;
        }
        Test.startTest();
        Batch_TransferHistoryRecords obj = new Batch_TransferHistoryRecords();
        Database.executeBatch(obj);
        Test.stopTest();
        List<AccountHistory> updatedList = [Select Id, Field,AccountId From AccountHistory];
        System.assertEquals(10, updatedList.size());
        List<Account_History__c> fetchCustomList = [Select Id,Account__c,Field__c,Created_Date__c From Account_History__c];
        System.assertEquals(10, fetchCustomList.size());
        System.assertEquals(acc.Id, fetchCustomList[0].Account__c);
        System.assertEquals('TextName', fetchCustomList[0].Field__c);
    }
/*
 * Method Name : testContactandAccountHistoryObjectCreation
 * Description : This method is used to test whether the account,Contact History object records are copied to custom account,contact history object.
 */
    @isTest
    private static void  testContactandAccountHistoryObjectCreation(){
        Contact con = new Contact(LastName = 'Test', Email='Other@test.com');
        insert con;
        ContactHistory conhistoryRecord = new ContactHistory(Field = 'Email',ContactId = con.Id);
        insert conhistoryRecord;
        Account acc = new Account(Name = 'Test');
        insert acc;
        AccountHistory acchistoryRecord = new AccountHistory(Field = 'TextName',AccountId = acc.Id);
        insert acchistoryRecord;
        Test.startTest();
        Batch_TransferHistoryRecords obj = new Batch_TransferHistoryRecords();
        Database.executeBatch(obj);
        Test.stopTest();
        List<AccountHistory> accHistList = [Select Id,CreatedDate From AccountHistory];
        List<Account_History__c> fetchCustomAccounttList = [Select Id,Account__c,Field__c,Created_Date__c From Account_History__c];
        
        List<ContactHistory> conHistList = [Select Id,CreatedDate From ContactHistory];
        List<Contact_History__c> fetchCustomContactList = [Select Id,Contact__c,Field__c,Created_Date__c From Contact_History__c];
        
    }
    
}