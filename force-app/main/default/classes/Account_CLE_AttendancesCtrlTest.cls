@isTest
public class Account_CLE_AttendancesCtrlTest {
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
        Account acc = [Select id from Account limit 1];
        Account_CLE_AttendancesCtrl.getCLE_Attendances(acc.Id);
    }
}