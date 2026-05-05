/*
    Name : AccountDetailPageEdit_LtngCtrl_Test
    Auther : Jitendra Pratap Singh
    Date : 14 Feb 2019
    Description : Test Class for AccountDetailPageEdit_LtngController
*/

@isTest
public class AccountDetailPageEdit_LtngCtrl_Test {
    @IsTest
    public Static void testMethod1(){
        
        Test.startTest();

// Insert Account        
            Account accObj = TestDataFactory.createAccounts('Test');
            insert accObj;

// Insert Contact               
            Contact conObj = TestDataFactory.createContact('Test Contact',accObj.Id);
            conObj.FirstName = 'Tester';
            conObj.AccountId = accObj.Id;
            conObj.Type__c = 'Lawyer';
            insert conObj;

// Insert Contact 2            
            Contact conObj1 = TestDataFactory.createContact('Test Contact',accObj.Id);
            conObj1.FirstName = 'Tester';
            conObj1.AccountId = accObj.Id;
            conObj1.Type__c = 'Lawyer';
            conObj1.ARDC_Number__c='12348765';
            insert conObj1;

// Insert County          
            County__c county = TestDataFactory.createCounty();
            insert county ;
            
// Calling Standard Controller
            
            ApexPages.StandardController sc = new ApexPages.StandardController(accObj );
            AccountDetailPageEdit_LtngController obj = new AccountDetailPageEdit_LtngController(sc);
            
            AccountDetailPageEdit_LtngController.getLookupRecord('Test','Account');
            AccountDetailPageEdit_LtngController.getLookupRecord('','');

// Callling Methods            
            obj.appContactList = [select id,Type__c,LastName from contact];
            obj.fillWrapper();
            obj.filterContactByType();
            obj.getCounty();
            
            obj.contactRecord.LastName = 'Test Contact 2';
            obj.contactRecord.Type__c = 'Lawyer';
            obj.createContact();
            
            obj.edIndex = '0';
            obj.editRecordModalContact();
            obj.edIndex = '0';
            obj.createContact();
            
            obj.edIndex = '0';
            obj.deleteRecordContact();
            
            sc = new ApexPages.StandardController(accObj );
            obj = new AccountDetailPageEdit_LtngController(sc);
            
            
            AccountDetailPageEdit_LtngController.getLookupRecord('Test','Account');
            AccountDetailPageEdit_LtngController.getLookupRecord('','');
            
            obj.lastName = 'Test Contact';
            obj.searchContact();
            
            obj.cancelMethod();
            
            obj.ardcNumber = '12348765';
            obj.searchContact();
            
            obj.cancelMethod();
            
            
            obj.firstName = 'Tester';
            obj.lastName = 'Test Contact';
            obj.ardcNumber = '12348765';
            obj.searchContact();
            
            obj.cancelMethod();
            
            obj.appContactList = [select id,Type__c,LastName from contact];
            obj.fillWrapper();
            obj.filterContactByType();
            
            obj.contactRecord.LastName = 'Test Contact 3';
            obj.contactRecord.Type__c = 'Lawyer';
            obj.createContact();
            
            obj.selectedContacts = conObj.Id;
            obj.associateContacts();
            
            obj.saveAccount();
            
            list<AccountContactRelation> acr = new list<AccountContactRelation>();
            acr = [select id,accountid from AccountContactRelation where accountid  =: accObj.id];
            
            system.assertequals(true,acr.size() > 0);
            system.assertequals(1,[select id from account].size());
            system.assertequals(1,[select id from contact].size());
            
            Account accObj1 = New Account (Name = 'Test');
            //Insert accObj1;
                    
            sc = new ApexPages.StandardController(accObj1);
            obj = new AccountDetailPageEdit_LtngController(sc);
            
            
            AccountDetailPageEdit_LtngController.getLookupRecord('Test','Account');
            AccountDetailPageEdit_LtngController.getLookupRecord('','');
            
            obj.appContactList = [select id,Type__c,LastName from contact];
            obj.fillWrapper();
            obj.filterContactByType();
            
            obj.contactRecord.LastName = 'Test Contact 3';
            obj.contactRecord.Type__c = 'Lawyer';
            obj.createContact();
            
            obj.saveAccount();
       
        Test.stopTest();
        
    }
// second method for cover else condition
    
    @IsTest
    public Static void testMethod2(){
        
        Test.startTest();
        
// Insert Account
            Account accObj1 = TestDataFactory.createAccounts(Label.Bucket_Account);
            insert accObj1;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(accObj1);
            AccountDetailPageEdit_LtngController obj = new AccountDetailPageEdit_LtngController(sc);
            
            obj.appContactList = [select id,Type__c,LastName from contact];
            obj.fillWrapper();
            obj.filterContactByType();
            
            obj.contactRecord.LastName = 'Test Contact 3';
            obj.contactRecord.Type__c = 'Lawyer';
            obj.createContact();
            obj.getState();
            
            obj.saveAccount();
        
        Test.stopTest();
    }

}