@isTest
public class PolicyController_Test {
    
    @testSetup 
    static void testData(){
        /*
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
        /*
        Deductible_Factor__c deductible = TestDataFactory.createDeductiblefactor(masterFactor.Id);
       // Insert deductible; 
        
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(masterFactor1.Id);
        insert baseFactor;
        
        Policy__c pol                 = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'policy');
        pol.Status__c                 = 'Application created';
        pol.SCH_Mod__c                = 1.00;
        insert pol;
        
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('','','IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,pol.id,'IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT');
        insert objPolEndorse;
        
        objPolEndorse.Endorsement_Number__c = 'IL 102';
        update objPolEndorse;
        
        Policy_Lawyer__c polLawyer = TestDataFactory.createPolicyLawyer(acc.Id,pol.Id,acj.Id);
        insert polLawyer;
        
          
        Master_Factor__c masterfact =TestDataFactory.createMasterfactor('Coverage 10/1/2016 - 12/31/2016','Coverage');
        insert masterfact;
        
        ILF_Coverage_Factor__c coverFactor = TestDataFactory.createCoveragefactor(masterfact.Id);
        insert coverFactor;
        
        Master_Factor__c masterfact1 = TestDataFactory.createMasterfactor('Deductible 10/1/2016 - 12/31/2016','Deductible');
        insert masterfact1;
        
        Deductible_Factor__c deductible = TestDataFactory.createDeductiblefactor(masterfact1.Id);
        Insert deductible; 
        
        Policy_Quote__c polQuote =TestDataFactory.createPolicyQuote(pol.id, coverFactor.id, deductible.id);
       // insert polQuote;
        
        
        Policy_Quote__c PolQuote = new Policy_Quote__c();
        PolQuote.Customer_Application__c = pol.id;
        PolQuote.Coverage__c = coverFactor.id;
        PolQuote.Deductible__c= deductible.Id;
        insert PolQuote;
        */
        
          
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
        
        // Create Active Policy
        Policy__c policy =  TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Policy');
        policy.Limit__c = FactorCoverage.Id;
        policy.Deductible_ID__c = DedFac.id;
        policy.Policy_Document_Version__c = '1/18';
        policy.Premium__c = 100;
        policy.Base_Amount__c = 123;
        policy.Firm_Mod__c = 112;
        policy.Premium_Amount__c = 120;
        insert policy;
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,policy.id,'General');
        insert poicyEndorse;
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,policy.id);
        insert aop;
        test.stopTest();
    }
    
    @isTest
    static void fetchLawyer_test(){
        
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
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
                
        Master_Factor__c masterfact = TestDataFactory.createMasterfactor('Coverage 10/1/2016 - 12/31/2016','Coverage');
        insert masterfact;
        
        ILF_Coverage_Factor__c coverFactor = TestDataFactory.createCoveragefactor(masterfact.Id);
        insert coverFactor;
        
        Master_Factor__c masterfact1 = TestDataFactory.createMasterfactor('Deductible 10/1/2016 - 12/31/2016','Deductible');
        insert masterfact1;
        
        Deductible_Factor__c deductible = TestDataFactory.createDeductiblefactor(masterfact1.Id);
        Insert deductible;
        /**
        Policy_Quote__c policyQuote = TestDataFactory.createPolicyQuote(policy.Id,coverFactor.Id,deductible.id);
        insert policyQuote;
         **/      
        PolicyController.fetchLawyer(policies[0].id);
        
    }

     @isTest
    static void fetchLawyer_test2(){
        
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id,NAME FROM AcctSeed__GL_Account__c];
        
        Policy__c  policy = policies[0];
        policy.Base_Amount__c=NULL;
        policy.Firm_Mod__c=NULL;
        update policy;
        
        
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(policies[0].Account__C, conList[0].Id);
        insert junc;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(policies[0].Account__c,policies[0].Id,junc.Id);
        law.Active__c = true;
        insert law;
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        insert calimset;
        
        Policy_Claim__c claim = TestDataFactory.createPolicyClaim(policy.Id,law.id);
        insert claim;
                
        Master_Factor__c masterfact = TestDataFactory.createMasterfactor('Coverage 10/1/2016 - 12/31/2016','Coverage');
        insert masterfact;
        
        ILF_Coverage_Factor__c coverFactor = TestDataFactory.createCoveragefactor(masterfact.Id);
        insert coverFactor;
        
        Master_Factor__c masterfact1 = TestDataFactory.createMasterfactor('Deductible 10/1/2016 - 12/31/2016','Deductible');
        insert masterfact1;
        
        Deductible_Factor__c deductible = TestDataFactory.createDeductiblefactor(masterfact1.Id);
        Insert deductible;
        /**
        Policy_Quote__c policyQuote = TestDataFactory.createPolicyQuote(policy.Id,coverFactor.Id,deductible.id);
        //policyQuote.Deductibles_Formula__c=NULL;
        policyQuote.ADJ_MOD__c=1;
        policyQuote.Mod_230__c=1;
        policyQuote.Mod_234__c=1;
        policyQuote.Mod_261__c=1;
        policyQuote.Deductible_Factor__c=1;
        policyQuote.Coverage_Factor__c=1;
        //policyQuote.Limits__c=NULL;
        insert policyQuote;
         **/      
        PolicyController.fetchLawyer(policies[0].id);
        
    }

}