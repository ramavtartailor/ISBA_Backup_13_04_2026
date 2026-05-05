@isTest
public class Batch_GetAllTransactionsTest {
    @testSetup static void setup() {
        Profile pf= [Select Id from profile where Name='System Administrator'];
        String orgId=UserInfo.getOrganizationId();
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000));
        String uniqueName=orgId+dateString+RandomId;
        User AU=new User(firstname = 'ABC',
                         lastName = 'XYZ',
                         email = uniqueName + '@test' + orgId + '.org',
                         Username = uniqueName + '@test' + orgId + '.org',
                         EmailEncodingKey = 'ISO-8859-1',
                         Alias = uniqueName.substring(18, 23),
                         TimeZoneSidKey = 'America/Los_Angeles',
                         LocaleSidKey = 'en_US',
                         LanguageLocaleKey = 'en_US',
                         ProfileId = pf.Id
                        );
        insert AU;
        
            ContentWorkspace workSpace = New ContentWorkspace();
            workSpace.Name = Label.Accounting_File_Library;
            //insert workSpace;
            
            ContentFolder folder = New ContentFolder();
        folder.Name = Label.Accounting_Forte_File_Library;
        insert folder;
        
        
    }
    
    @isTest static void testMethod1() {
        
        // Insert Account
        Account acc = TestDataFactory.createAccounts('Test');
        insert acc;
        
        // Insert Contact
        Contact con =  TestDataFactory.createContact('Last Name',acc.id);
        insert con;
        
        // Insert GL Accounts
        List<AcctSeed__GL_Account__c> glAccounts = TestDataFactory.createGLAccounts();
        insert glAccounts;
        
        // Accounting Period
        AcctSeed__Accounting_Period__c accountingPeriod =  TestDataFactory.createAcctPeriod();
        insert accountingPeriod;
        
        // Insert Billing Format
        List<AcctSeed__Billing_Format__c> billFormat = TestDataFactory.createBillingFormats();
        insert billFormat;
        
        // Insert Ledgers
        List<AcctSeed__Ledger__c> ledgers = TestDataFactory.createLedgers(glAccounts[0].id,billFormat[0].id,billFormat[1].id,billFormat[2].id,billFormat[3].id,billFormat[4].id);
        insert ledgers;
        
        // Insert AccountingSetting
        AcctSeed__Accounting_Settings__c accSetting = TestDataFactory.createAccountsetting(ledgers[0].id, glAccounts[0].id,glAccounts[1].id, glAccounts[2].id, glAccounts[3].id,glAccounts[4].id, glAccounts[5].id,glAccounts[6].id,billFormat[0].id);
        insert accSetting;
        
        
        
        
        
        AcctSeed__Cash_Receipt__c cr = TestDataFactory.createCashReceipt(ledgers[0].id,acc.id,accountingPeriod.id);
        cr.AcctSeed__Credit_GL_Account__c = glAccounts[3].id;
        insert cr;
        
        List<ContentFolder> workspace = new List<ContentFolder>([SELECT Id FROM ContentFolder WHERE Name =: Label.Accounting_Forte_File_Library]);
        system.debug('workSpace--'+workspace);
        Test.startTest();
        Batch_GetAllTransactions AllTrans = new Batch_GetAllTransactions();
        database.executeBatch(AllTrans);
        Test.stopTest();
        // Perform some testing
    }
}