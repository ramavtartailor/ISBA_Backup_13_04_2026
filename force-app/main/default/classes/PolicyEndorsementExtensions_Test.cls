@isTest
private class PolicyEndorsementExtensions_Test {
    
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
        
        Policy__c pol                 = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Application');
        pol.Base_Amount__c = 100;
        pol.Firm_Mod__c = 2;
        pol.Limit__c = FactorCoverage.Id;
        pol.Deductible_ID__c = DedFac.id;
        
        insert pol;
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,pol.id,'General');
        insert poicyEndorse;
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
      
        test.stopTest();
        
    }
    
    @isTest static void testMethod1() {
        
        List<Policy_Endorsement__c> policies = [SELECT Id,RecordTypeId,Account__c,Policy__c FROM Policy_Endorsement__c];
        
        Policy_Endorsement__c  policy = policies[0];
        
        Test.startTest();
        PageReference pageRef = Page.PolicyEndorsement;
        pageRef.getParameters().put('Id', policy.Id);
        system.Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(policy);
        PolicyEndorsementExtensions Ctrl = new PolicyEndorsementExtensions(sc);
        ctrl.getFirmContacts();
        ctrl.getPolicyLawyer();
        ctrl.lawyercall();
        Test.stopTest();
        
    }
    
    @isTest static void testMethod2() {
        
        List<Policy_Endorsement__c> policies = [SELECT Id,RecordTypeId,Account__c,Policy__c FROM Policy_Endorsement__c];
        
        Policy_Endorsement__c  policy = policies[0].clone();
        
        Test.startTest();
        PageReference pageRef = Page.PolicyEndorsement;
        pageRef.getParameters().put('Id', policy.Id);
        system.Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('Name', 'IL 152 Adding an Attorney Endorsement');
        
        System.currentPageReference().getParameters().put('RecordType', policies[0].RecordTypeId);
        System.currentPageReference().getParameters().put('CF00NR0000001kx9I_lkid', policies[0].Account__c);
        
        System.currentPageReference().getParameters().put('CF00NR0000001jPr4_lkid', policies[0].Policy__c);
        System.currentPageReference().getParameters().put('00NR0000001jPrY', '10/11/2017');
        System.currentPageReference().getParameters().put('00NR0000001jPtt', '10/11/2017');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(policy);
        PolicyEndorsementExtensions Ctrl = new PolicyEndorsementExtensions(sc);
        ctrl.getFirmContacts();
        ctrl.getPolicyLawyer();
        ctrl.lawyercall();
        Test.stopTest();
        
    }
}