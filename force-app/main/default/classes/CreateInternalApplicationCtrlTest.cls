@isTest
public class CreateInternalApplicationCtrlTest {

    @isTest
    public static void testMethod1(){
        
        Customer_Application__c custApp = new Customer_Application__c(        
            Contact_Name__c = 'Test'
        );
        
        insert custApp;
        
        CreateInternalApplicationCtrl.CreateInternalApp(custApp);
    }
}