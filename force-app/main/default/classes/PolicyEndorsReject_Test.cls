@isTest
private class PolicyEndorsReject_Test {
    @isTest static void testMethod1(){
        Test.startTest();
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
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
        
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
        opp.StageName                 = 'Application Sent';
        insert opp;
        
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor1','geo');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        Master_Factor__c masterFactor = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert masterFactor;
        
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(masterFactor.Id);
        insert stepRateFactor;
        
        Master_Factor__c masterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert masterFactor1;
        
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(masterFactor1.Id);
        insert baseFactor;
        
        Master_Factor__c masterFactor2 = TestDataFactory.createMasterfactor('Test Master Factor0','Coverage');
        insert masterFactor2;
        
        ILF_Coverage_Factor__c ilfCoverageLowest = TestDataFactory.createCoveragefactor(masterFactor2.Id);
        insert ilfCoverageLowest;
        
        Master_Factor__c masterFactorDeductible = TestDataFactory.createMasterfactor('Test Master Factor1','Deductible');
        insert masterFactorDeductible;
        
        Deductible_Factor__c deductibles = TestDataFactory.createDeductiblefactor(masterFactorDeductible.Id);
        insert deductibles;
        
        Policy__c pol                 = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Application');
        pol.Status__c                 = 'Application created';
        pol.Base_Amount__c            = 1;
        pol.Firm_Mod__c               = 1;
        pol.Limit__c                  = ilfCoverageLowest.Id;
        pol.Deductible_ID__c          = deductibles.Id;
        pol.Lost_Reason__c            = 'ISBAM - Other';
        pol.Premium__c                = 100;
        insert pol;
        
        Id devRecordEndorseTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='CP_Cancel_Policy_Transaction' LIMIT 1].id;
        
        Endorsement__c endorse191= TestDataFactory.createEndorsement('IL 191','Functional','IL 190 Cancellation of Coverage');
        insert endorse191;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse191.Id);
        insert endorseVersion;
        
        Endorsement_Version__c endorseVersion2 = TestDataFactory.createEndorsementVersion(endorse191.Id);
        endorseVersion2.Endorsement_Version_Number__c='2';
        insert endorseVersion2;
        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,pol.id,'IL 190 Cancellation of Coverage');
        insert poicyEndorse;
        
        poicyEndorse.Event_Status__c = 'Complete';
        update poicyEndorse;
        
        // delete poicyEndorse; 
        
        PolicyEndorsReject.getPolicyEndorse(poicyEndorse.id);
        PolicyEndorsReject.deletePolicy(poicyEndorse.id);
        
        Test.stopTest();
    }
}