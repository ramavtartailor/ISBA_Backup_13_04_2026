@isTest
private class CMRenewPolicy3MonthPriorBatchTest {
	@testSetup static void setup() {
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Account acc1                   = TestDataFactory.createAccounts('Test Account1');
        acc1.AccountNumber             = '1234567';
        acc1.Vendor_Account__c         = true;
        insert acc1;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        con.Email = 'sanyam@cmentor.com';
        insert con;
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        List<AcctSeed__GL_Account__c> glAccounts = TestDataFactory.createGLAccounts();        
        insert glAccounts;
        
        List<AcctSeed__Billing_Format__c> billingFormats = TestDataFactory.createBillingFormats();        
        insert billingFormats ;
        
        AcctSeed__Accounting_Period__c lstPeriod = TestDataFactory.createAcctPeriod();
        insert lstPeriod;
        
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
        
        Test.startTest();
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorNew.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Treaty_Versions__c objTV=new Treaty_Versions__c ();
        objTV.Ceded_4x1_Rate__c=6.75;
        objTV.Ceded_Primary_Rate__c=8.25;
        objTV.End_Date__c=System.Date.today();
        objTV.Start_Date__c =System.Date.today().addMonths(4);
        objTV.Reinsurance_Limit__c=500000;
        insert objTV;
        
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy.Effective_Date__c = system.today();
        acctivePolicy.Expiration_Date__c = System.today().addMonths(1);
        acctivePolicy.Treaty_Version__c=objTV.Id;
        acctivePolicy.Expiration_Date__c = system.today().addDays(45);
        acctivePolicy.Cancel_Date__c=null;
        insert acctivePolicy;
        
        Policy__c pol = [select id,ClonedBy__c,RecordType.Name,Renew_Application__c,Account__c,Account__r.Count_of_Application__c,Expiration_Date__c,Cancel_Date__c from Policy__c where id =:acctivePolicy.id];
        System.debug(pol.Cancel_Date__c);
         System.debug(pol.ClonedBy__c);
        //system.debug('query--->'+[select id,ClonedBy__c,RecordType.Name,Renew_Application__c,Account__c,Account__r.Count_of_Applications__c,Expiration_Date__c from Policy__c where id =:acctivePolicy.id]);
       
        Test.stopTest();
        
    }
    
    @isTest static void testMethod1() {
        database.executeBatch(new CMRenewPolicy3MonthPriorBatch(),1);
    }
}