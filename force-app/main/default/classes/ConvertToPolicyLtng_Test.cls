@isTest
public class ConvertToPolicyLtng_Test {
    
    @testSetup static void setup(){
        Test.startTest();
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        opp.StageName                 = 'Application Sent';
        opp.CloseDate                 = Date.today();
        insert opp;
        
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Step Rate');
        insert mas;
        
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(mas.Id);
        insert stepRateFactor;
        
        ILF_Coverage_Factor__c ilfCoverageLowest = TestDataFactory.createCoveragefactor(mas.id);
        insert ilfCoverageLowest;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas.Id);
        Insert DedFac;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.id,county.Id);
        insert geo;
        
        Policy__c pol                 = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Application');
        pol.Status__c                 = 'Accepted';
        pol.SCH_Mod__c                = 1.00;
        pol.Policy_Document_Version__c    = '1/18';
        pol.Premium__c                 = 100;
        pol.Base_Amount__c = 123;
        pol.Firm_Mod__c = 112;
        pol.Limit__c = ilfCoverageLowest.id;
        pol.Deductible_ID__c = DedFac.id;
        pol.Premium_Amount__c = 120;
        insert pol;
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorNew.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy.Effective_Date__c = date.today();//.addDays(7);
        insert acctivePolicy;
        
        
        // Policy_Quote__c objPolQuote = TestDataFactory.createPolicyQuote(acctivePolicy.Id,coverageFactorObj.Id,DedFac.id);
        // insert objPolQuote;
        
        
        
        Contact con  = TestDataFactory.createContact('Test Contact',acc.id);
        con.ARDC_Number__c=null;
        insert con;
        
        
        
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(acctivePolicy.Account__C, con.Id);
        insert junc;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(acctivePolicy.Account__c,acctivePolicy.Id,junc.Id);
        insert law;
        
        Endorsement__c endorse191= TestDataFactory.createEndorsement('','descriptive','IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT');
        insert endorse191;
        
        Endorsement_Version__c endorseVersion1 = TestDataFactory.createEndorsementVersion(endorse191.Id);
        endorseVersion1.Endorsement_Version_Number__c='1';
        insert endorseVersion1;
        
        
        Endorsement_Version__c endorseVersion2 = TestDataFactory.createEndorsementVersion(endorse191.Id);
        endorseVersion1.Endorsement_Version_Number__c='2';
        insert endorseVersion2;
        
        Endorsement__c endorse302= TestDataFactory.createEndorsement('','descriptive','IL 302 AMENDMENT OF EXTENDED REPORTING PERIOD OPTIONS ENDORSEMENT');
        insert endorse302;
        
        Endorsement_Version__c endorseVersion3 = TestDataFactory.createEndorsementVersion(endorse302.Id);
        endorseVersion3.Endorsement_Version_Number__c='1';
        insert endorseVersion3;
        Test.stopTest();
        
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT');
        
        insert objPolEndorse;
        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT');
        poicyEndorse.Lawyer__c=junc.id;
        poicyEndorse.New_Limits__c=ilfCoverageLowest.Id;
        insert poicyEndorse;
        
        poicyEndorse.Effective_Date__c = date.today().addDays(4);
        poicyEndorse.Endorsement_Effective_Date__c =date.today().addDays(1);
        update poicyEndorse;
        
        
    }
    
    @isTest
    static void TestgetPolicy(){
        
        List<Policy__c> policies = [SELECT Id,Account__c,Policy_Document_Version__c FROM Policy__c];
        Policy__c  pol = policies[0];
        
        ConvertToPolicyLtng objPolToLghtng  = new ConvertToPolicyLtng();
        
        ConvertToPolicyLtng.getPolicy(pol.id);
        ConvertToPolicyLtng.convertPolicy(pol.id,pol.Policy_Document_Version__c);
        ConvertToPolicyLtng.hasAllLawyersARDC(pol.id);
        ConvertToPolicyLtng.hasInvalid106(pol.id);
        ConvertToPolicyLtng.hasBlocks(pol.id);
        ConvertToPolicyLtng.hasUndefinedAOP(pol.id);
    }
    
    
    static testMethod void ConvertToPolicyLtngTest1 () {
        Test.startTest();
        List<Policy__c> policies = [SELECT Id,Account__c,Policy_Document_Version__c FROM Policy__c];
        Policy__c  pol = policies[1];
        ConvertToPolicyLtng objPolToLghtng  = new ConvertToPolicyLtng();
        
        ConvertToPolicyLtng.getPolicy(pol.id);
        //ConvertToPolicyLtng.getPolicy('');
        ConvertToPolicyLtng.convertPolicy(pol.id,pol.Policy_Document_Version__c);
        Test.stopTest(); 
        ConvertToPolicyLtng.convertPolicy(pol.id,'');
        ConvertToPolicyLtng.hasAllLawyersARDC(pol.id);
        ConvertToPolicyLtng.hasInvalid106(pol.id);
        ConvertToPolicyLtng.getStatus();
        ConvertToPolicyLtng.getPaymentReceivedFieldValue();
        ConvertToPolicyLtng.getIBFPaymentFieldValue();
        ConvertToPolicyLtng.getTargetFieldValue();
        ConvertToPolicyLtng.updatePolicy(pol);
        
    }
    
    static testMethod void ConvertToPolicyLtngTest2 () {
        Test.startTest();
        List<Policy__c> policies = [SELECT Id,Account__c,Policy_Document_Version__c FROM Policy__c];
        Policy__c  pol = policies[1];
        ConvertToPolicyLtng objPolToLghtng  = new ConvertToPolicyLtng();
        
        ConvertToPolicyLtng.getPolicy(pol.id);
        ConvertToPolicyLtng.convertPolicy(pol.id,pol.Policy_Document_Version__c);
        Test.stopTest(); 
        ConvertToPolicyLtng.convertPolicy(pol.id,'');
        ConvertToPolicyLtng.hasAllLawyersARDC(pol.id);
        ConvertToPolicyLtng.hasInvalid106(pol.id);
        ConvertToPolicyLtng.getStatus();
        ConvertToPolicyLtng.getPaymentReceivedFieldValue();
        ConvertToPolicyLtng.getIBFPaymentFieldValue();
        ConvertToPolicyLtng.getTargetFieldValue();
        ConvertToPolicyLtng.updatePolicy(pol);
        
    }
}