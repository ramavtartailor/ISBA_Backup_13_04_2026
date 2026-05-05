/*
Name : AccountGateway_Test
Auther : Jitendra Pratap Singh
Date : 18 Feb 2019
Description : Test Class for AccountGateway
*/
@isTest
private class AccountGateway_Test {
    
    
    @testSetup 
    static void testData(){
        
        // Insert Account List
        List<Account> accList = new List<Account>();
        // 0
        Account objAcc = TestDataFactory.createAccounts('Test Account');  
        accList.add(objAcc);
       
        Insert accList;
        
        // Insert Policy
        Policy__c objPolicy = TestDataFactory.createPolicyOnlyAcocunt(accList[0].id,'Policy');
        objPolicy.Name = 'Test';
        insert objPolicy;
    }
    
    @isTest static void testMethod1(){
        
        Test.startTest();
        
        Map<Id,Sobject> oldItems = new Map<Id,Sobject>();
        Map<Id,Sobject> newItems = new Map<Id,Sobject>();
        
        
        Account objAcc = TestDataFactory.createAccounts('Test');
        objAcc.AcctSeed__Accounting_Active__c = false;
        objAcc.AccountNumber    = '1233';        
        insert objAcc;
            
        Policy__c objPolicy = TestDataFactory.createPolicyOnlyAcocunt(objAcc.id,'Policy');
        objPolicy.Name = 'Test';
        insert objPolicy;
           
        Account acc = [select id,Count_Active_Policies__c from account where id =: objAcc.id]; 
        oldItems.put(objAcc.id,acc);
         
        Policy__c objPolicy1 = TestDataFactory.createPolicyOnlyAcocunt(objAcc.id,'Policy');
        objPolicy1.Name = 'Test1';
        objPolicy1.Cancel_Date__c = null;
        insert objPolicy1;
        
        Account acc1 = [select id,Count_Active_Policies__c from account where id =: objAcc.id]; 
        newItems.put(objAcc.id,acc1);
        
        AccountGateway.updateAccountWithRecentPolicy(oldItems, newItems);
        
        
        Test.stopTest();        
    }
    
    @isTest static void testMethod2(){
        
        
        List<Account> accList = [Select id from Account];
        
        Map<Id,Sobject> oldItems = new  Map<Id,Sobject>([SELECT id,Count_Active_Policies__c FROM Account]);
        
        // Insert Policy
        Policy__c objPolicy = TestDataFactory.createPolicyOnlyAcocunt(accList[0].id,'Policy');
        objPolicy.Name = 'Test';
        //objPolicy.Cancel_Date__c= accList[0].
        insert objPolicy;
        
        Map<Id,Sobject> newItems = new  Map<Id,Sobject>([SELECT id,Count_Active_Policies__c FROM Account]);

        Test.startTest();
        AccountGateway.updateAccountWithRecentPolicy(oldItems, newItems);
        Test.stopTest();              
    }
    
    
    
}