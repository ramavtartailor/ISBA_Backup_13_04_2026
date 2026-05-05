@isTest
public class CustomerApplicationRenewalEmail_CtrlTest {

    @isTest 
    static void testCustomerAppCreation(){
        Test.startTest();
        CustomerApplicationRenewalEmail_Ctrl cust = new CustomerApplicationRenewalEmail_Ctrl();
        Customer_Application__c objCustomerApp = new Customer_Application__c();
        objCustomerApp.Is_the_firm_currently_insured__c = 'No';
        insert objCustomerApp;
        cust.setCustomerAppId(objCustomerApp.Id);
        cust.getCustomerAppId();
        Test.stopTest();
    }
}