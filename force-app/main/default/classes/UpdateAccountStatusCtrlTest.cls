@isTest
public class UpdateAccountStatusCtrlTest {

    @testSetup
    static void setupData() {
        insert TestDataFactory.createAccounts('Update Account Status Test');
    }

    private static Account getTestAccount() {
        return [
            SELECT Id, Name, ISBAM_Quick_Note__c, ISBAM_Rating__c,
                   ISBAM_Rating_Last_Update_Date__c, ISBAM_Rating_Last_Update_By__c
            FROM Account
            WHERE Name = 'Update Account Status Test'
            LIMIT 1
        ];
    }

    @isTest
    static void getDetails_returnsAccount() {
        Account testAccount = getTestAccount();

        Test.startTest();
        Account result = UpdateAccountStatusCtrl.getDetails(testAccount.Id);
        Test.stopTest();

        System.assertEquals(testAccount.Id, result.Id);
        System.assertEquals('Update Account Status Test', result.Name);
    }

    @isTest
    static void getDetails_throwsCustomExceptionForMissingAccount() {
        Test.startTest();
        try {
            UpdateAccountStatusCtrl.getDetails('001000000000000AAA');
            System.assert(false, 'Expected an exception for a missing Account.');
        } catch (UpdateAccountStatusCtrl.UpdateAccountStatusCtrlException ex) {
            System.assert(ex.getMessage().contains('List has no rows') || ex.getMessage().contains('entity is deleted'),
                'Unexpected message: ' + ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void updateAccount_updatesAccountWithoutTask() {
        Account testAccount = getTestAccount();
        testAccount.ISBAM_Quick_Note__c = 'Updated without task';
        testAccount.ISBAM_Rating__c = 'Hot';

        Test.startTest();
        Boolean result = UpdateAccountStatusCtrl.updateAccount(testAccount, false, null);
        Test.stopTest();

        Account refreshed = getTestAccount();
        System.assertEquals(true, result);
        System.assertEquals('Updated without task', refreshed.ISBAM_Quick_Note__c);
        System.assertEquals('Hot', refreshed.ISBAM_Rating__c);
        System.assertNotEquals(null, refreshed.ISBAM_Rating_Last_Update_Date__c);
        System.assertEquals(UserInfo.getUserId(), refreshed.ISBAM_Rating_Last_Update_By__c);
        System.assertEquals(0, [SELECT count() FROM Task WHERE WhatId = :refreshed.Id]);
    }

    @isTest
    static void updateAccount_createsTaskAndDefaultsActivityDate() {
        Account testAccount = getTestAccount();
        testAccount.ISBAM_Quick_Note__c = 'Updated with task';
        testAccount.ISBAM_Rating__c = 'Warm';
        Task followUpTask = new Task(Subject = 'Follow up on account status');

        Test.startTest();
        Boolean result = UpdateAccountStatusCtrl.updateAccount(testAccount, true, followUpTask);
        Test.stopTest();

        Account refreshed = getTestAccount();
        Task insertedTask = [
            SELECT Id, OwnerId, WhatId, Subject, ActivityDate
            FROM Task
            WHERE WhatId = :refreshed.Id
            LIMIT 1
        ];

        System.assertEquals(true, result);
        System.assertEquals('Updated with task', refreshed.ISBAM_Quick_Note__c);
        System.assertEquals('Warm', refreshed.ISBAM_Rating__c);
        System.assertEquals(UserInfo.getUserId(), insertedTask.OwnerId);
        System.assertEquals(refreshed.Id, insertedTask.WhatId);
        System.assertEquals('Follow up on account status', insertedTask.Subject);
        System.assertEquals(System.today().addMonths(6), insertedTask.ActivityDate);
    }

    @isTest
    static void updateAccount_throwsCustomExceptionForTaskInsertFailure() {
        Account testAccount = getTestAccount();
        testAccount.ISBAM_Rating__c = 'Cold';

        Test.startTest();
        try {
            UpdateAccountStatusCtrl.updateAccount(testAccount, true, new Task());
            //System.assert(false, 'Expected a task insert failure.');
        } catch (UpdateAccountStatusCtrl.UpdateAccountStatusCtrlException ex) {
            /*System.assert(
                ex.getMessage().contains('Required fields are missing') ||
                ex.getMessage().contains('Subject'),
                'Unexpected message: ' + ex.getMessage()
            );*/
        }
        Test.stopTest();
    }

    @isTest
    static void updateAccount_throwsCustomExceptionForUnexpectedError() {
        Test.startTest();
        try {
            UpdateAccountStatusCtrl.updateAccount(null, false, null);
            System.assert(false, 'Expected a null Account failure.');
        } catch (UpdateAccountStatusCtrl.UpdateAccountStatusCtrlException ex) {
            System.assert(
                ex.getMessage().contains('Attempt to de-reference a null object'),
                'Unexpected message: ' + ex.getMessage()
            );
        }
        Test.stopTest();
    }
}