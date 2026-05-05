@isTest
public class AccountContactJunctionGateway_Test {
    
    @testSetup 
    static void testData(){
        
         // Insert Account
        Account acc = TestDataFactory.createAccounts('Test');
        insert acc;
        
        // Insert Contact
        Contact con =  TestDataFactory.createContact('Last Name',acc.id);
        insert con;
        
        // Create Account Contact Junction     
        AccountContactJunction__c accConJunc = TestDataFactory.createAccConJunc(acc.id,con.id);
        insert accConJunc;
    }
    
    @isTest
    static void populateACJName_Test(){

        Map<id,AccountContactJunction__c> accContJunctMap = new Map<id,AccountContactJunction__c>([select id,Account__c,Contact__c from AccountContactJunction__c]);
        AccountContactJunctionGateway.populateACJName(accContJunctMap);
    }

}