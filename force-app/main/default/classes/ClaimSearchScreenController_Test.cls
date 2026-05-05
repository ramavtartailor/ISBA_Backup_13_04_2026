@isTest
public class ClaimSearchScreenController_Test {
    @testSetup
    static void createTestData() {
           Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Account acc1                   = TestDataFactory.createAccounts('Test Account');
        acc1.AccountNumber             = '123456';
        acc1.Vendor_Account__c         = true;
       // insert acc1;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
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
        
        /*
        Policy__c pol                 = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Application');
        pol.Status__c                 = 'Application created';
        pol.SCH_Mod__c                = 1.00;
        insert pol;
        
        Policy__c pol1                 = TestDataFactory.createPolicy(acc1.Id,opp.id,geo.id,'Application');
        pol1.Status__c                 = 'Application created';
        pol1.SCH_Mod__c                = 1.00;
        insert pol1;
		*/
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorNew.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        insert acctivePolicy;
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('','','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        insert objPolEndorse;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,acctivePolicy.id);
        insert aop;
    }
    
    @IsTest
    static void unitTest1() {
        Policy_Claim__c sampleClaim= new Policy_Claim__c();
        
        Test.startTest();
        ClaimSearchScreenController ctrl = new ClaimSearchScreenController();
        ctrl.sampleClaim= sampleClaim;
        ctrl.searchClaimNumber = '00011';
        ctrl.searchLawyerName = 'Test';
        ctrl.hasOpen = 'Yes';
        ctrl.searchClaimantName = 'Test1';
        ctrl.fetchClaim();
        ctrl.updateRadioValues();
        ctrl.renewMassClaimsFunc();
        ClaimSearchScreenController.ClaimSearchScreenControllerWrapper wrap = new ClaimSearchScreenController.ClaimSearchScreenControllerWrapper();
        Test.stopTest();
    }
    @IsTest
    static void unitTest2() {
        Policy_Claim__c sampleClaim= new Policy_Claim__c();
        
        Test.startTest();
        ClaimSearchScreenController ctrl = new ClaimSearchScreenController();
        ctrl.sampleClaim= sampleClaim;
        ctrl.searchClaimNumber = '00011';
        ctrl.hasOpen = 'Yes';
        ctrl.searchClaimantName = 'Test1';
        ctrl.fetchClaim();
        ctrl.updateRadioValues();
        ctrl.renewMassClaimsFunc();
        Test.stopTest();
    }
    @IsTest
    static void unitTest3() {
        Policy_Claim__c sampleClaim= new Policy_Claim__c();
        
        Test.startTest();
        ClaimSearchScreenController ctrl = new ClaimSearchScreenController();
        ctrl.sampleClaim= sampleClaim;
        ctrl.searchClaimNumber = '00011';
        ctrl.hasOpen = 'Yes';
        ctrl.fetchClaim();
        ctrl.updateRadioValues();
        ctrl.renewMassClaimsFunc();
        Test.stopTest();
    }
    @IsTest
    static void unitTest4() {
        Policy_Claim__c sampleClaim= new Policy_Claim__c();
        
        Test.startTest();
        ClaimSearchScreenController ctrl = new ClaimSearchScreenController();
        ctrl.sampleClaim= sampleClaim;
        ctrl.searchClaimNumber = '00011';
        ctrl.hasOpen = 'No';
        ctrl.fetchClaim();
        ctrl.updateRadioValues();
        ctrl.renewMassClaimsFunc();
        Test.stopTest();
    }
    
    @IsTest
    static void unitTest5() {
        Policy_Claim__c sampleClaim= new Policy_Claim__c();
        
        Test.startTest();
        ClaimSearchScreenController ctrl = new ClaimSearchScreenController();
        ctrl.sampleClaim= sampleClaim;
        ctrl.hasOpen = 'No';
        ctrl.fetchClaim();
        ctrl.updateRadioValues();
        ctrl.renewMassClaimsFunc();
        Test.stopTest();
    }
    
    @IsTest
    static void unitTest6() {
        Policy_Claim__c sampleClaim= new Policy_Claim__c();
        
        Test.startTest();
        ClaimSearchScreenController ctrl = new ClaimSearchScreenController();
        ctrl.sampleClaim= sampleClaim;
        ctrl.hasOpen = 'Yes';
        ctrl.fetchClaim();
        ctrl.updateRadioValues();
        ctrl.renewMassClaimsFunc();
        Test.stopTest();
    }
    
    @isTest
    static void unitTest7() {
        Policy_Claim__c sampleClaim= new Policy_Claim__c();
        
        Test.startTest();
        ClaimSearchScreenController ctrl = new ClaimSearchScreenController();
        ctrl.searchFirmName = 'Test';
        ctrl.sampleClaim= sampleClaim;
        ctrl.searchClaimNumber = '00011';
        ctrl.hasOpen = 'Yes';
        ctrl.searchClaimantName = 'Test1';
        ctrl.fetchClaim();
        ctrl.updateRadioValues();
        ctrl.renewMassClaimsFunc();
        Test.stopTest();
    }
    
    @isTest
    static void Testing_p(){
        Test.startTest();
         List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        Policy__c  policy = policies[0];
        
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(policies[0].Account__C, conList[0].Id);
        insert junc;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(policies[0].Account__c,policies[0].Id,junc.Id);
        insert law; 
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        insert calimset;
        
        Policy_Claim__c claim = TestDataFactory.createPolicyClaim(policies[0].Id,law.Id);
        claim.Is_Non_Lawyer__c = true;
        insert claim;
         
        Policy_Claim__c claim2 = TestDataFactory.createPolicyClaim(policies[0].Id,law.Id);
        claim2.Claim_Status__c ='Closed';
        insert claim2;
        
        
        ClaimSearchScreenController.ClaimSearchScreenControllerWrapper TestWrap = new ClaimSearchScreenController.ClaimSearchScreenControllerWrapper();
        TestWrap.claim = claim;
        TestWrap.isSelected=true;
        
        List< ClaimSearchScreenController.ClaimSearchScreenControllerWrapper> WrapList = new List< ClaimSearchScreenController.ClaimSearchScreenControllerWrapper>();
        WrapList.add(TestWrap);
        
        
        ClaimSearchScreenController ctrl = new ClaimSearchScreenController();
        ctrl.radioValue ='hasOpen';
        ctrl.radioName='hasOpen';
        ctrl.updateRadioValues();
        ctrl.clearDataFunc();
        ctrl.searchedResults = WrapList;
        ctrl.renewMassClaimsFunc();
        ctrl.fetchClaim();
        
        Test.stopTest();
        
    }
    
    @isTest
    static void fetchClaim_1() {
       
        Test.startTest();
        ClaimSearchScreenController ctrl = new ClaimSearchScreenController();
        ctrl.searchClaimNumber = null;
        ctrl.searchFirmName = 'Test';
        ctrl.fetchClaim();
        Test.stopTest();
    }
    
    
    @isTest
    static void fetchClaim_2() {
       
        Test.startTest();
        ClaimSearchScreenController ctrl = new ClaimSearchScreenController();
        ctrl.searchClaimNumber = null;
        ctrl.searchFirmName = null;
        ctrl.searchLawyerName = 'Test';
        ctrl.fetchClaim();
        Test.stopTest();
    }
    
    @isTest
    static void fetchClaim_3() {
       
        Test.startTest();
        ClaimSearchScreenController ctrl = new ClaimSearchScreenController();
        ctrl.searchClaimNumber = null;
        ctrl.searchFirmName = null;
        ctrl.searchLawyerName = null;
        ctrl.searchClaimantName = 'Test';
        ctrl.fetchClaim();
        Test.stopTest();
    }
    
}