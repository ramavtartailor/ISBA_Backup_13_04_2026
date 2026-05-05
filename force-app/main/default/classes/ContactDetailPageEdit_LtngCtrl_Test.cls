@isTest
public class ContactDetailPageEdit_LtngCtrl_Test {
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
        
        ApexPages.StandardController sc = new ApexPages.StandardController(conObj );
        ContactDetailPageEdit_LtngController obj = new ContactDetailPageEdit_LtngController(sc);
        
        ContactDetailPageEdit_LtngController.getLookupRecord('Test','Account');
        ContactDetailPageEdit_LtngController.getLookupRecord('','');
        
        // Callling Methods            
        obj.saveContactRecord();
        
        sc = new ApexPages.StandardController(conObj );
        obj = new ContactDetailPageEdit_LtngController(sc);
        
        
        ContactDetailPageEdit_LtngController.getLookupRecord('Test','Contact');
        ContactDetailPageEdit_LtngController.getLookupRecord('','');
        
        list<AccountContactRelation> acr = new list<AccountContactRelation>();
        acr = [select id,accountid from AccountContactRelation where accountid  =: accObj.id];
        
        Contact conObj2 = New Contact (LastName = 'Test');
        insert conObj2;
        
        sc = new ApexPages.StandardController(conObj1);
        obj = new ContactDetailPageEdit_LtngController(sc);
        
        ContactDetailPageEdit_LtngController.getLookupRecord('Test','Contact');
        ContactDetailPageEdit_LtngController.getLookupRecord('','');
        
        Test.stopTest();
        
    }
    
    @isTest
    public Static void testMethod2(){
        
        Test.startTest();
        
        Account accObj = TestDataFactory.createAccounts('Test');
        insert accObj;
        
        Contact accObj1 = TestDataFactory.createContact(Label.Bucket_Account,accObj.Id);
        insert accObj1;
        
        Contact con = new Contact();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(con);
        ContactDetailPageEdit_LtngController obj = new ContactDetailPageEdit_LtngController(sc);
        
        obj.saveContactRecord();
        
        Test.stopTest();
    }
    
}