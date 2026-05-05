@isTest
public class CloneToOnlineAppCtrlTest {
    public static final String AVAILABLE_ACCOUNT_NAME = 'Clone Available Account';
    public static final String BLOCKED_ACCOUNT_NAME = 'Clone Blocked Account';

    @testSetup
    static void setupData() {
        Account availableAccount = TestDataFactory.createAccounts(AVAILABLE_ACCOUNT_NAME);
        availableAccount.Trade_Name_or_D_B_A__c = 'Available Trade Name';
        availableAccount.BillingStreet = '123 Main St';
        availableAccount.BillingCity = 'Chicago';
        availableAccount.BillingState = 'IL';
        availableAccount.BillingPostalCode = '60601';
        availableAccount.Phone = '3125550101';
        availableAccount.Website__c = 'https://available.example.com';
        availableAccount.Establish_Date__c = Date.newInstance(2000, 1, 1);
        insert availableAccount;

        Contact availableContact = TestDataFactory.createContact('Available Lawyer', availableAccount.Id);
        availableContact.FirstName = 'Ava';
        availableContact.Phone = '3125550102';
        availableContact.MobilePhone = '3125550103';
        availableContact.Email = 'ava.lawyer@example.com';
        availableContact.Personal_Email__c = 'ava.personal@example.com';
        availableContact.Birthdate = Date.newInstance(1990, 1, 1);
        availableContact.ARDC_Number__c = '10000001';
        availableContact.ISBA__c = 'ISBA-1001';
        insert availableContact;

        AccountContactJunction__c availableJunction = TestDataFactory.createAccConJunc(availableAccount.Id, availableContact.Id);
        availableJunction.Name = 'Available Junction';
        insert availableJunction;

        Opportunity availableOpportunity = TestDataFactory.createOpp(availableAccount.Id);
        insert availableOpportunity;

        Policy__c availableApplication = TestDataFactory.createPolicy(availableAccount.Id, availableOpportunity.Id, null, 'Policy');
        availableApplication.Name = 'APP-AVAILABLE';
        availableApplication.Firm_Contact__c = availableContact.Id;
        insert availableApplication;

        Policy_Lawyer__c availableLawyer = TestDataFactory.createPolicyLawyer(
            availableAccount.Id,
            availableApplication.Id,
            availableJunction.Id
        );
        availableLawyer.Lawyer__c = availableJunction.Id;
        insert availableLawyer;

        Account blockedAccount = TestDataFactory.createAccounts(BLOCKED_ACCOUNT_NAME);
        blockedAccount.BillingStreet = '456 State St';
        blockedAccount.BillingCity = 'Springfield';
        blockedAccount.BillingState = 'IL';
        blockedAccount.BillingPostalCode = '62701';
        insert blockedAccount;

        Contact blockedContact = TestDataFactory.createContact('Blocked Lawyer', blockedAccount.Id);
        blockedContact.FirstName = 'Blake';
        blockedContact.Email = 'blocked.lawyer@example.com';
        insert blockedContact;

        Opportunity blockedOpportunity = TestDataFactory.createOpp(blockedAccount.Id);
        insert blockedOpportunity;
    }

    @isTest
    static void testGetPolicyCreatesOnlineApplication() {
        Policy__c sourceApplication = [
            SELECT Id, Account__c
            FROM Policy__c
            WHERE Account__r.Name = :AVAILABLE_ACCOUNT_NAME
            AND RecordType.DeveloperName = 'Policy'
            LIMIT 1
        ];

        Test.startTest();
        String onlineApplicationId = CloneToOnlineAppCtrl.getPolicy(sourceApplication.Id);
        Test.stopTest();

        Customer_Application__c onlineApplication = [
            SELECT Id, RecordType.DeveloperName, Account__c, Full_Legal_Name_of_the_Firm__c,
                   Trade_Name_or_D_B_A__c, Street__c, City__c, State__c, Zip_Code__c,
                   Firm_Phone_Number__c, Website__c, Date_Firm_Established__c, Contact__c,
                   Contact_Name__c, Contact_Last_Name__c, Contact_Phone_Number__c,
                   Contact_E_mail_Address__c
            FROM Customer_Application__c
            WHERE Id = :onlineApplicationId
        ];


        List<Customer_Application_Lawyer__c> applicationLawyers = [
            SELECT Name, Contact__c, Middle_Initial__c, Last_Name__c, ISBA_Number__c,
                   ARDC_Number__c, Cell_Phone__c, Birthday__c, Firm_Email_Address__c,
                   Personal_Email_Address__c
            FROM Customer_Application_Lawyer__c
            WHERE Customer_Application__c = :onlineApplication.Id
        ];
    }

    
}