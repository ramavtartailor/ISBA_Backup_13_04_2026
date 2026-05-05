@isTest
public class LawyerAddedFlagCtrlTest {
    
    @isTest
    static void testGetDetails_WithLawyers() {
        Account availableAccount = TestDataFactory.createAccounts('test');
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
        
        Customer_Application__c app = new Customer_Application__c(PolicyId__c = availableApplication.Id);
        insert app;
        
        Customer_Application_Lawyer__c appLawyer = new Customer_Application_Lawyer__c(
            Customer_Application__c = app.Id,
            Is_Removed__c = false,
            Is_New__c = true,
            ARDC_Number__c = 'ARD12345'
        );
        insert appLawyer;
        
        // Test the controller method
        Test.startTest();
        String result = LawyerAddedFlagCtrl.getDetails(app.Id);
        Test.stopTest();
        
    }
    
}