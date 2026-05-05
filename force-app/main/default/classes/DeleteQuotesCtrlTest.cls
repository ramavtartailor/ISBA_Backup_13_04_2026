@isTest
public class DeleteQuotesCtrlTest {
	@isTest
    static void testmethod1(){
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
        
        // Insert AccountingSetting
        AcctSeed__Accounting_Settings__c accSetting = TestDataFactory.createAccountsetting(ledgers[0].id, glAccounts[0].id,glAccounts[1].id, glAccounts[2].id, glAccounts[3].id,glAccounts[4].id, glAccounts[5].id,glAccounts[6].id,billingFormats[0].id);
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
        
        
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorNew.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Application');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        insert acctivePolicy;
        Test.stopTest();
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        insert poicyEndorse;
       
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,acctivePolicy.id);
        insert aop;
        
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(acctivePolicy.Account__c, con.Id);
        insert junc;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(acctivePolicy.Account__c,acctivePolicy.Id,junc.Id);
        law.Active__c = true;
        insert law;
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        insert calimset;
        
        Policy_Claim__c claim = TestDataFactory.createPolicyClaim(acctivePolicy.Id,law.id);
        insert claim;
        
        Master_Factor__c masterfact = TestDataFactory.createMasterfactor('Coverage','Coverage');
        insert masterfact;
        
        ILF_Coverage_Factor__c coverFactor = TestDataFactory.createCoveragefactor(masterfact.Id);
        coverFactor.Name = '10,000,000 / 10,000,000';
        coverFactor.Coverage_Max_Per_Claim__c = 10000000;
        coverFactor.Full_Coverage__c = 10000000;
        coverFactor.Master_Factor__c = masterfact.id;
        coverFactor.Is_10X10_Coverage__c = true;
        coverFactor.Factor_Value__c = 2.04;
        coverFactor.Lowest_Coverage__c = true;
        coverFactor.OldLimit__c = false;
        insert coverFactor;
        
        ILF_Coverage_Factor__c coverFactor1 = TestDataFactory.createCoveragefactor(masterfact.Id);
        coverFactor1.Name = '20,000,000 / 20,000,000';
        coverFactor1.Coverage_Max_Per_Claim__c = 20000000;
        coverFactor1.Full_Coverage__c = 20000000;
        coverFactor1.Is_10X10_Coverage__c = false;
        coverFactor1.Factor_Value__c = 2.04;
        coverFactor1.Lowest_Coverage__c = true;
        coverFactor1.OldLimit__c = false;
        insert coverFactor1;
        
        ILF_Coverage_Factor__c coverFactor2 = TestDataFactory.createCoveragefactor(masterfact.Id);
        coverFactor2.Name = '1,000,000 / 1,000,000';
        coverFactor2.Coverage_Max_Per_Claim__c = 1000000;
        coverFactor2.Full_Coverage__c = 1000000; 
        coverFactor2.Is_5X5_Coverage__c = true;
        coverFactor2.Factor_Value__c = 2.04;
        coverFactor2.Lowest_Coverage__c = true; 
        coverFactor2.OldLimit__c = false;
        coverFactor2.Percentage_5X5_Step_0__c=10; 
        coverFactor2.Percentage_5X5_Step_1__c=20; 
        coverFactor2.Percentage_5X5_Step_2__c=30; 
        coverFactor2.Percentage_5X5_Step_3__c=40; 
        coverFactor2.Premium_Rate_5X5__c=20;
        insert coverFactor2;
        
        ILF_Coverage_Factor__c coverFactor3 = TestDataFactory.createCoveragefactor(masterfact.Id);
        coverFactor3.Name = '2,000,000 / 2,000,000';
        coverFactor3.Coverage_Max_Per_Claim__c = 2000000; 
        coverFactor3.Full_Coverage__c = 2000000;
        coverFactor3.Is_5X5_Coverage__c = false;
        coverFactor3.Factor_Value__c = 2.04;
        coverFactor3.Lowest_Coverage__c = true; 
        coverFactor3.OldLimit__c = false;
        insert coverFactor3;
        
        Master_Factor__c masterfact1 = TestDataFactory.createMasterfactor('Deductible 10/1/2016 - 12/31/2016','Deductible');
        insert masterfact1;
        
        Deductible_Factor__c deductible = TestDataFactory.createDeductiblefactor(masterfact1.Id);
        Insert deductible;
        
        Policy_Quote__c objpolQut = TestDataFactory.createPolicyQuote(acctivePolicy.Id,coverFactor.Id,DedFac.Id);
        objpolQut.Adj_R_O__c = true;
        insert objpolQut;
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(new List<Policy_Quote__c>{objpolQut});
        DeleteQuotesCtrl dq = new DeleteQuotesCtrl(sc);
        
        DeleteQuotesCtrl.deleteQuotes(objpolQut.Id);
        
    }
}