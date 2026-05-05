@isTest
public class AccountContactJunctionHandler_Test {
    
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
    static void AccountContactJunctionHandler_Test(){
        
        Map<id,AccountContactJunction__c> accContJunctMap = new Map<id,AccountContactJunction__c>([select id,Account__c,Contact__c from AccountContactJunction__c]);
        List<AccountContactJunction__c> accContJunctList = [select id,Account__c,Contact__c from AccountContactJunction__c];
        AccountContactJunctionHandler ctrl = new AccountContactJunctionHandler();
        ctrl.bulkBefore();
        ctrl.bulkAfter();
        ctrl.beforeInsert(accContJunctList);
        ctrl.beforeUpdate(accContJunctMap, accContJunctMap);
        ctrl.beforeDelete(accContJunctMap);
        ctrl.afterInsert(accContJunctMap);
        ctrl.afterUpdate(accContJunctMap, accContJunctMap);
        ctrl.afterDelete(accContJunctMap);
        ctrl.andFinally();
   
    }

}