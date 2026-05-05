@isTest
public class Contact_PolicyHistoryCtrlTest {
    
    @testSetup static void setup() {
        
        Account acc                   = TestDataFactory.createAccounts('Bucket Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
    }
    
    @isTest
    public static void method1(){
        Contact con = [Select id from Contact limit 1];
        Contact_PolicyHistoryCtrl.getData(con.Id);
    }

}