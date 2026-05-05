@isTest
private class Billing_Edit_Controller_Test {
    
    @testSetup static void setup() {
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Account acc1                   = TestDataFactory.createAccounts('Test Account');
        acc1.AccountNumber             = '123456';
        acc1.Vendor_Account__c         = true;
        //insert acc1;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        con.FirstName                 = 'Test';
        con.Type__c                   = 'Lawyer';
        con.Contact_Role__c           = 'P';
        con.AccountId                 = acc.Id;
        insert con;
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        List<AcctSeed__GL_Account__c> glAccounts = TestDataFactory.createGLAccounts();        
        insert glAccounts;
        
        List<AcctSeed__Billing_Format__c> billingFormats = TestDataFactory.createBillingFormats();        
        insert billingFormats ;
        
        List<AcctSeed__Ledger__c> ledgers = TestDataFactory.createLedgers(glAccounts[0].id,billingFormats[0].id,billingFormats[1].id,billingFormats[2].id,billingFormats[3].id,billingFormats[4].id);
        insert ledgers;
        
        AcctSeed__Accounting_Settings__c settings = TestDataFactory.createAccountsetting(ledgers[0].id,glAccounts[0].Id,glAccounts[1].Id,glAccounts[2].Id,glAccounts[3].Id,glAccounts[4].Id,glAccounts[5].Id,glAccounts[6].Id,billingFormats[0].Id);
        insert settings;
        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        opp.StageName                 = 'Application Sent';
        opp.CloseDate                 = Date.today();
        insert opp;
        
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Geo');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.id,county.Id);
        insert geo;
        
        Master_Factor__c masterFactor = TestDataFactory.createMasterfactor('Test Master Factor0','Step Rate');
        insert masterFactor;
        
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(masterFactor.Id);
        insert stepRateFactor;
        
        Master_Factor__c masterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert masterFactor1;
        
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(masterFactor1.Id);
        insert baseFactor;
        
        Policy__c pol                 = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Application');
        pol.Status__c                 = 'Application created';
        pol.SCH_Mod__c                = 1.00;
        insert pol;
        
        Policy__c pol1                 = TestDataFactory.createPolicy(acc1.Id,opp.id,geo.id,'Application');
        pol1.Status__c                 = 'Application created';
        pol1.SCH_Mod__c                = 1.00;
        //insert pol1;
        
        Test.startTest();
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        AcctSeed__Accounting_Period__c lstPeriod = TestDataFactory.createAcctPeriod();
        insert lstPeriod;
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('','','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,pol.id,'General');
        insert objPolEndorse;
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod1() {
        
        List<Account> accList = [SELECT Id FROM Account];
        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id,NAME FROM AcctSeed__GL_Account__c];
        List<AcctSeed__Accounting_Period__c> period = [SELECT Id,NAME FROM AcctSeed__Accounting_Period__c];
        List<AcctSeed__Ledger__c> ledgers = [SELECT Id FROM AcctSeed__Ledger__c];
              
        AcctSeed__Billing__c objBilling = TestDataFactory.createBilling(accList[0].Id,period[0].Id,ledgers[0].id);
        insert objBilling;
        
        AcctSeed__Billing_Line__c billLine = TestDataFactory.createBillingLine(objBilling.Id,glAccounts[2].Id);
        insert billLine;
        
        Test.startTest();
        
        PageReference pageRef = Page.Billing_Edit_Page;
        system.Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objBilling);
        Billing_Edit_Controller Ctrl = new Billing_Edit_Controller(sc);
        Ctrl.addNewLine();
        Ctrl.indexOfLineItemToBeRemoved ='1';
        Ctrl.removeRow();
        Ctrl.accountId = accList[0].Id;
        Ctrl.onAccountSelect();
        Ctrl.CreateBilling();
        
        Test.stopTest();
        
    }
    
}