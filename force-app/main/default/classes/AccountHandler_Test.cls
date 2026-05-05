@isTest
public class AccountHandler_Test {
    
    @testSetup
    static void testData(){
        
        // Insert Account
        Account acc = TestDataFactory.createAccounts('Test');
        insert acc;
    }
    
    @isTest
    static void AccountHandler_testMethod(){
        
        Map<id,Account> accountMap = new Map<id,Account>([select id from Account]);
        List<Account> accList = [select id from Account];
        AccountHandler ctrl = new AccountHandler();
        ctrl.bulkBefore();
        ctrl.bulkAfter();
        ctrl.beforeInsert(accList);
        ctrl.beforeUpdate(accountMap, accountMap);
        ctrl.beforeDelete(accountMap);
        ctrl.afterInsert(accountMap);
        ctrl.afterUpdate(accountMap, accountMap);
        ctrl.afterDelete(accountMap);
        ctrl.andFinally();
        
    }
    
}