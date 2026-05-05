@IsTest
public class NBAConversionControllerTest {
    
    @TestSetup
    static void setupData() {
        
        County__c county = new County__c(Name = 'Cook');
        insert county;
        Account bucketAcc = new Account(Name = Label.Bucket_Account);
        insert bucketAcc;
        
        Account acc = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Main St',
            BillingCity = 'Chicago',
            BillingState = 'IL',
            BillingPostalCode = '60601',
            Billing_Address_County__c = county.Id
        );
        insert acc;
        Contact con = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            AccountId = acc.Id
        );
        insert con;
        
        Customer_Application__c app = new Customer_Application__c(
            Full_Legal_Name_of_the_Firm__c = 'Test Firm',
            Trade_Name_or_D_B_A__c = 'Test DBA',
            Street__c = '123 Main St',
            City__c = 'Chicago',
            State__c = 'IL',
            Zip_Code__c = '60601',
            County__c = county.Id,
            Application_Status__c = 'New',
            Signed_Date__c = Date.today(),
            Effective_Date_Requested__c = Date.today().addDays(10)
        );
        insert app;
        
        Customer_Application_Lawyer__c lawyer = new Customer_Application_Lawyer__c(
            Customer_Application__c = app.Id,
            Name = 'John',
            Last_Name__c = 'Doe',
            Average_Number_of_Hours_Worked__c = 40,
            Date_of_Hire__c = Date.today().addYears(-5),
            Contact__c = con.Id
        );
        insert lawyer;
    }
    
    
    @IsTest
    static void testGetMethods() {
        
        Customer_Application__c app =[SELECT Id FROM Customer_Application__c LIMIT 1];
        
        Test.startTest();
        NBAConversionController.getAccount();
        NBAConversionController.getContact();
        NBAConversionController.getcurentNBA(app.Id);
        NBAConversionController.getCustomerApplication(app.Id);
        Test.stopTest();
        System.assert(true);
    }
    
    @IsTest
    static void testCreateObject_WithExistingContact() {
        
        Customer_Application__c app =[SELECT Id FROM Customer_Application__c LIMIT 1];
        
        Account acc =[SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        List<Customer_Application_Lawyer__c> lawyers =[SELECT Id, Contact__c FROM Customer_Application_Lawyer__c];
        
        List<String> oldContacts = new List<String>();
        for (Customer_Application_Lawyer__c l : lawyers) {
            oldContacts.add(l.Contact__c);
        }
        
        Map<String, String> lawyerContactMap = new Map<String, String>();
        lawyerContactMap.put(lawyers[0].Id, lawyers[0].Contact__c);
        
        Test.startTest();
        Id policyId = NBAConversionController.createObject(app.Id,new List<String>(),acc.Id,oldContacts,lawyerContactMap);
        Test.stopTest();
        
        System.assertNotEquals(null, policyId);
        
        Customer_Application__c updatedApp =[SELECT Application_Status__c, PolicyId__c FROM Customer_Application__c WHERE Id = :app.Id];
        System.assertEquals('Converted', updatedApp.Application_Status__c);
        System.assertEquals(policyId, updatedApp.PolicyId__c);
        
        List<Policy_Lawyer__c> polLawyers =[SELECT Id FROM Policy_Lawyer__c WHERE Policy__c = :policyId];
        System.assertEquals(1, polLawyers.size());
    }
    
    @IsTest
    static void testCheckRecord_NoPolicy() {
        
        Customer_Application__c app =[SELECT Id FROM Customer_Application__c LIMIT 1];
        
        Test.startTest();
        Boolean result = NBAConversionController.checkRecord(app.Id);
        Test.stopTest();
        
        System.assertEquals(true, result);
    }
    
    @IsTest
    static void testCheckRecord_WithPolicy() {
        
        Customer_Application__c app =[SELECT Id FROM Customer_Application__c LIMIT 1];
        
        Policy__c pol = new Policy__c(
            Account__c = [SELECT Id FROM Account LIMIT 1].Id,
            Effective_Date__c = Date.today(),
            Status__c = 'Inquiry'
        );
        insert pol;
        
        app.PolicyId__c = pol.Id;
        update app;
        
        Test.startTest();
        Boolean result = NBAConversionController.checkRecord(app.Id);
        Test.stopTest();
        
        System.assertEquals(false, result);
        
        Customer_Application__c refreshed =[SELECT Application_Status__c FROM Customer_Application__c WHERE Id = :app.Id];
        System.assertEquals('Converted', refreshed.Application_Status__c);
    }
    @IsTest
    static void testCreateObject_WithNewContact() {
        
        Customer_Application__c app = [SELECT Id FROM Customer_Application__c LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Customer_Application_Lawyer__c lawyer = [SELECT Id, Contact__c FROM Customer_Application_Lawyer__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        lawyer.Contact__c = con.Id;
        update lawyer;
        AccountContactJunction__c acj = new AccountContactJunction__c(
            Account__c = acc.Id,
            Contact__c = con.Id
        );
        insert acj;
        List<String> newContacts = new List<String>{ lawyer.Id };
            List<String> oldContacts = new List<String>{ con.Id };                
                Test.startTest();
        Id policyId = NBAConversionController.createObject(
            app.Id,
            newContacts,
            acc.Id,
            oldContacts,               
            new Map<String, String>()  
        );
        
        Test.stopTest();
        
        System.assertNotEquals(null, policyId);
        List<Policy_Lawyer__c> polLawyers = [SELECT Id FROM Policy_Lawyer__c WHERE Policy__c = :policyId];
        System.assertEquals(1, polLawyers.size());
    }
    
}