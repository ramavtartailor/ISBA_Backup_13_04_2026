@isTest
private class EZRenewal2_Ctrl_Test {
    
    @testSetup static void setup() {
        
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
        insert opp;
        
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        
        insert geo;
        
        Master_Factor__c masterFactor = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert masterFactor;
        
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(masterFactor.Id);
        insert stepRateFactor;
        test.startTest();
        Master_Factor__c masterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert masterFactor1;
        
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(masterFactor1.Id);
        insert baseFactor;
        
        Map<String,String> mapRecordTypes = new Map<String,String>();
        
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoveragefactor(MasterFactorCoverage.Id);
        insert FactorCoverage;
        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor1','Deductible');
        insert mas12;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        Insert DedFac; 
        /*
        Policy__c pol                 = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Application');
        pol.Base_Amount__c = 100;
        pol.Firm_Mod__c = 2;
        pol.Limit__c = FactorCoverage.Id;
        pol.Deductible_ID__c = DedFac.id;
        
        insert pol;
        */
         
        ILF_Coverage_Factor__c ilfCoverageLowest = TestDataFactory.createCoveragefactor(mas.id);
        insert ilfCoverageLowest;
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorNew.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Policy__c pol = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        pol.Limit__c = coverageFactorObj.Id;
        pol.Deductible_ID__c = dedFactorObj.Id;
        pol.Base_Amount__c = 100;
        pol.Firm_Mod__c = 2;
        pol.Limit__c = FactorCoverage.Id;
        pol.Deductible_ID__c = DedFac.id;
        insert pol;
        
        EZRenewal2_Ctrl  objEz1 = new EZRenewal2_Ctrl ();
        objEz1.setrecordId(pol.Id);
        objEz1.getrecordId();
            
        
        Policy_Quote__c objPolQuote = TestDataFactory.createPolicyQuote(pol.Id,coverageFactorObj.Id,DedFac.id);
        objPolQuote.Mod_230__c=10;
        objPolQuote.Mod_234__c=10;
        objPolQuote.Mod_261__c=2;
        insert objPolQuote;
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,pol.id,'General');
        poicyEndorse.Endorsement_Effective_Date__c = system.today()-2;
        insert poicyEndorse;
       
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        PageReference pageRef = Page.EndorsementEditPage;
        System.Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('name','test');
        // ApexPages.currentPage().getParameters().put('effectiveDate',string.valueof(System.today().addDays(-1)));
        ApexPages.currentPage().getParameters().put('id',pol.id);
        ApexPages.currentPage().getParameters().put('RecordType',devRecordTypeId);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(poicyEndorse);
        EndorsementEditVFCtrl objEndorsement = new EndorsementEditVFCtrl(sc); 
        
        Test.stopTest();
    }
    @isTest static void TestMethod2() {
        test.starttest();
        PageReference pageRef = Page.EndorsementEditPage;
        System.Test.setCurrentPage(pageRef);
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<policy__c> lstPolicy = [select id from policy__c];
        
        List<Policy_Endorsement__c> lstpoicyEndorse = [select id,policy__c from Policy_Endorsement__c where policy__c in : lstPolicy ];
        system.debug('-------endors-------'+lstpoicyEndorse);
        
        Policy_Endorsement__c objEndors = lstpoicyEndorse[0];
        ApexPages.currentPage().getParameters().put('name','test');
        ApexPages.currentPage().getParameters().put('id',lstPolicy[0].id);
        ApexPages.currentPage().getParameters().put('RecordType',devRecordTypeId);
        EZRenewal2_Ctrl  objEZ = new EZRenewal2_Ctrl ();
        
        objEz.setrecordId(lstPolicy[0].Id);
        objEz.getrecordId();
        Test.stopTest();
    }
}