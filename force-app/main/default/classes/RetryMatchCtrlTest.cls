@IsTest(seeAllData=true)
public class RetryMatchCtrlTest {
    @IsTest
    static void testRematchUpdatesRelatedRecords() {
        // Initial application without related matches present in the system.
        String uniqueToken = String.valueOf(Datetime.now().getTime());
        String firmName = 'Retry Firm ' + uniqueToken;
        String firmEmail = 'retry' + uniqueToken + '@example.com';

        Customer_Application__c application = new Customer_Application__c(
            Full_Legal_Name_of_the_Firm__c = firmName,
            Contact_E_mail_Address__c = firmEmail
        );
        insert application;

        Account firm = new Account(Name = firmName, Phone = '555-1212');
        insert firm;

        Contact matchedContact = new Contact(
            FirstName = 'Retry',
            LastName = 'Lawyer',
            Email = firmEmail,
            AccountId = firm.Id,
            ARDC_Number__c = 'ARDC123',
            ISBA__c = 'ISBA123'
        );
        insert matchedContact;

        Customer_Application_Lawyer__c lawyerWithArdc = new Customer_Application_Lawyer__c(
            Customer_Application__c = application.Id,
            ARDC_Number__c = 'ARDC123'
        );
        Customer_Application_Lawyer__c lawyerWithIsba = new Customer_Application_Lawyer__c(
            Customer_Application__c = application.Id,
            ISBA_Number__c = 'ISBA123'
        );
        insert new List<Customer_Application_Lawyer__c>{ lawyerWithArdc, lawyerWithIsba };

        Test.startTest();
        String result = RetryMatchCtrl.reMatch(application.Id);
        Test.stopTest();

        Customer_Application__c refreshedApp = [
            SELECT Account__c, Contact__c FROM Customer_Application__c WHERE Id = :application.Id
        ];
        List<Customer_Application_Lawyer__c> refreshedLawyers = [
            SELECT Contact__c, ARDC_Number__c, ISBA_Number__c
            FROM Customer_Application_Lawyer__c
            WHERE Customer_Application__c = :application.Id
        ];

        System.assertEquals('success', result, 'Method should return success.');
        System.assertEquals(firm.Id, refreshedApp.Account__c, 'Account should be matched by firm name.');
        System.assertEquals(matchedContact.Id, refreshedApp.Contact__c, 'Contact should be matched by email.');

        for (Customer_Application_Lawyer__c lawyer : refreshedLawyers) {
            System.assertEquals(matchedContact.Id, lawyer.Contact__c, 'Lawyer should be linked to matched contact.');
        }
    }

    @IsTest
    static void testRematchWithoutAnyMatches() {
        String uniqueToken = String.valueOf(Datetime.now().getTime());

        Customer_Application__c application = new Customer_Application__c(
            Full_Legal_Name_of_the_Firm__c = 'Unknown Firm ' + uniqueToken,
            Contact_E_mail_Address__c = 'unknown' + uniqueToken + '@example.com'
        );
        insert application;

        Test.startTest();
        String result = RetryMatchCtrl.reMatch(application.Id);
        Test.stopTest();

        Customer_Application__c refreshedApp = [
            SELECT Account__c, Contact__c FROM Customer_Application__c WHERE Id = :application.Id
        ];

        System.assertEquals('success', result, 'Method should still return success.');
        System.assertEquals(null, refreshedApp.Account__c, 'No account should be linked when none match.');
        System.assertEquals(null, refreshedApp.Contact__c, 'No contact should be linked when none match.');
    }
}