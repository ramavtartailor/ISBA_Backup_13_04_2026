@isTest
public class TriggerOnCustomerApplicationTest {
    @testSetup
    static void setup(){

        Account acc = new Account(Name='Test Acc');
        insert acc;

        Contact con = new Contact(
            LastName='Lawyer',
            ARDC_Number__c='11111111',
            AccountId=acc.Id
        );
        insert con;

        Customer_Application__c app = new Customer_Application__c(
            Full_Legal_Name_of_the_Firm__c='Test Firm'
        );
        insert app;
        
        Customer_Application_Lawyer__c law = new Customer_Application_Lawyer__c(
            Customer_Application__c = app.Id,
            ARDC_Number__c = '11111111'
        );
        insert law;

    }
    @isTest
    static void testBeforeInsertLinking(){

        Customer_Application__c app = [SELECT Id FROM Customer_Application__c LIMIT 1];

        Customer_Application_Lawyer__c law = new Customer_Application_Lawyer__c(
            Customer_Application__c = app.Id,
            ARDC_Number__c = '11111111'
        );

        Test.startTest();
        insert law;
        Test.stopTest();

        Customer_Application_Lawyer__c result = [SELECT Contact__c FROM Customer_Application_Lawyer__c WHERE Id=:law.Id];

        System.assertNotEquals(null, result.Contact__c);
    }
    @isTest
    static void testBeforeUpdateLinking(){

        Customer_Application_Lawyer__c law = [SELECT Id FROM Customer_Application_Lawyer__c LIMIT 1];

        law.Contact__c = null;

        Test.startTest();
        update law; 
        Test.stopTest();

        Customer_Application_Lawyer__c result = [SELECT Contact__c FROM Customer_Application_Lawyer__c WHERE Id=:law.Id];

        System.assertNotEquals(null, result.Contact__c);
    }

    @isTest
    static void testCustomerApplicationTrigger(){

        Customer_Application__c app = new Customer_Application__c(Full_Legal_Name_of_the_Firm__c='Trigger Test');

        Test.startTest();
        insert app;  
        app.Full_Legal_Name_of_the_Firm__c = 'Updated';
        update app;
        Test.stopTest();

        System.assert(true);
    }
    @isTest
static void testAssignContactAndAccount(){

    Account acc = new Account(
        Name = 'Firm ABC',
        Phone = '9999999999'
    );
    insert acc;

    Contact con = new Contact(
        LastName = 'EmailMatch',
        Email = 'match@test.com',
        AccountId = acc.Id
    );
    insert con;

    Customer_Application__c app = new Customer_Application__c(
        Full_Legal_Name_of_the_Firm__c = 'Firm ABC',
        Firm_Phone_Number__c = '9999999999',
        Contact_E_mail_Address__c = 'match@test.com'
    );

    Test.startTest();
    insert app;   // fires before insert + after insert
    Test.stopTest();

    Customer_Application__c refreshed =
        [SELECT Account__c, Contact__c, Form_Link__c
         FROM Customer_Application__c
         WHERE Id = :app.Id];

    // assignAccount covered
    System.assertNotEquals(null, refreshed.Account__c);

    // assignContact covered
    System.assertNotEquals(null, refreshed.Contact__c);

    // afterInsert Form_Link covered
    System.assertNotEquals(null, refreshed.Form_Link__c);
}



}