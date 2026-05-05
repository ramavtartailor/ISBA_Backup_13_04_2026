@isTest
public class TriggerOnCustomerAppControllerTest {

    @isTest
    public static void testMethod1(){
        Customer_Application__c objCustomerApp = new Customer_Application__c();
        objCustomerApp.Is_the_firm_currently_insured__c = 'No';
        insert objCustomerApp; 
    }
}