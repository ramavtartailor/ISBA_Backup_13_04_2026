@isTest
public class Quotepdf_Ctrl_Test {
    
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
        
        // Insert Billing Format
        List<AcctSeed__Billing_Format__c> billFormat = TestDataFactory.createBillingFormats();
        insert billFormat;
        
        // Insert Ledgers
        List<AcctSeed__Ledger__c> ledgers = TestDataFactory.createLedgers(glAccounts[0].id,billFormat[0].id,billFormat[1].id,billFormat[2].id,billFormat[3].id,billFormat[4].id);
        insert ledgers;
        
        // Insert AccountingSetting
        AcctSeed__Accounting_Settings__c accSetting = TestDataFactory.createAccountsetting(ledgers[0].id, glAccounts[0].id,glAccounts[1].id, glAccounts[2].id, glAccounts[3].id,glAccounts[4].id, glAccounts[5].id,glAccounts[6].id,billFormat[0].id);
        insert accSetting;
        
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
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = FactorCoverage.Id;
        acctivePolicy.Deductible_ID__c = DedFac.id;
        insert acctivePolicy;
        
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
        
        List<Policy__c> policies = [SELECT Id,Active__c,Account__c FROM Policy__c where Active__c=:True];
        List<Contact> conList = [SELECT Id FROM Contact];
        
        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id,NAME FROM AcctSeed__GL_Account__c];
        
        
        Policy__c  policy = policies[0];
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(policies[0].Account__C, conList[0].Id);
        insert junc;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(policies[0].Account__c,policies[0].Id,junc.Id);
        law.Active__c = true;
        insert law;
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        insert calimset;
        
        Policy_Claim__c claim = TestDataFactory.createPolicyClaim(policy.Id,law.id);
        insert claim;
        
        AcctSeed__Accounting_Period__c period = TestDataFactory.createAcctPeriod();
        Insert period;
        
        Test.startTest();
        
        Master_Factor__c masterfact = TestDataFactory.createMasterfactor('Coverage','Coverage');
        insert masterfact;
        
        ILF_Coverage_Factor__c coverFactor = TestDataFactory.createCoveragefactor(masterfact.Id);
        insert coverFactor;
        
        Master_Factor__c masterfact1 = TestDataFactory.createMasterfactor('Deductible 10/1/2016 - 12/31/2016','Deductible');
        insert masterfact1;
        
        Deductible_Factor__c deductible = TestDataFactory.createDeductiblefactor(masterfact1.Id);
        Insert deductible; 
        
        Policy_Quote__c policyQuote = TestDataFactory.createPolicyQuote(policy.Id,coverFactor.Id,deductible.id);
        policyQuote.Quote_Premium_Step_0__c=12; 
        insert policyQuote;
        
        Quotepdf_Ctrl Ctrl = new Quotepdf_Ctrl();
        Ctrl.policyId='1234';
        Ctrl.setrecordId(policyQuote.Id);
        String Idrecord = Ctrl.getrecordId();
        
        Test.stopTest();
        
    }
    
}