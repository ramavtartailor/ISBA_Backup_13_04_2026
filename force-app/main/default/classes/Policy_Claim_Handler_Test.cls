@isTest
private class Policy_Claim_Handler_Test {
    
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
        insert DedFac; 
        
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
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        insert poicyEndorse;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        test.stopTest();
        
    }
    
    @isTest static void testMethod1() {
        
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<Policy_Claim__c> polClaim = new  List<Policy_Claim__c>();
        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id,NAME FROM AcctSeed__GL_Account__c WHERE Name='4000-product Revenue'];
        
        Account acc                   = new Account();
        acc.Name                      = 'Test Account';
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c = true;
        insert acc;
        
        Policy__c  policy = policies[0];
        AccountContactJunction__c junc = new AccountContactJunction__c();
        junc.Account__c = policies[0].Account__C;
        junc.Contact__c = conList[0].Id;
        insert junc;
        
        Policy_Lawyer__c law = new Policy_Lawyer__c();
        law.Policy__c = policies[0].Id;
        law.Active__c = true;
        law.Account__c = policies[0].Account__c;
        law.Prior_Act_Date__c = date.today();
        law.Lawyer__c = junc.Id;
        insert law; 
        
        Claim_Setting__c calimset = new Claim_Setting__c ();
        calimset.Deductible_LAE_Applied_After__c =10;
        insert  calimset;
        
        Test.startTest();
        
        Policy_Claim__c claim = new Policy_Claim__c();
        claim.Account__c = acc.Id;
        claim.Name = 'text';
        claim.Policy__c = policy.Id;
        claim.File_Type__c = 'Claim';
        claim.Lawyer__c = law.Id;
        claim.Report_Date__c = date.today();
        claim.Occur_Date__c = date.today().adddays(-2);
        claim.Claim_Made_Date__c = date.today();
        claim.State__c = 'test';
        claim.Claim_Status__c = 'Open';
        polClaim.add(claim);
        insert polClaim;
        
        /*claim.Claim_Close_Reasons__c = 'No tender';
        claim.Claim_Close_Payment_Resolutions__c = 'Closed with lae payment only';
        claim.ClaimCloseDAte__c = system.today();
        claim.Claim_Status__c = 'Closed';
        update claim;*/
        
        policy.Aggregate_Limit__c = 100;
        update policy;
        
        claim.Reserve_Loss__c= 50;
        update polClaim;
        
        claim.File_Type__c = 'Incident';
        update polClaim;
        
        claim.File_Type__c = 'Suit';
        
        update polClaim;
        
        Policy_Claim__c claim1 = new Policy_Claim__c();
        claim1.Account__c = acc.Id;
        claim1.Name = 'text2';
        claim1.Policy__c = policy.Id;
        claim1.File_Type__c = 'Claim';
        claim1.Lawyer__c = law.Id;
        claim1.Report_Date__c = date.today();
        claim1.Occur_Date__c = date.today().adddays(-2);
        claim1.Claim_Made_Date__c = date.today();
        claim1.State__c = 'test';
        claim1.Claim_Status__c = 'Open';
        insert claim1;
        
        //delete polClaim;
        Map<Id, Policy_Claim__c> MyMap= new Map<Id, Policy_Claim__c>();
        MyMap.put(claim1.id,claim1);
        
        
        
        claim1.Claim_Close_Reasons__c = 'No tender';
        claim1.Claim_Close_Payment_Resolutions__c = 'Closed with lae payment only';
        claim1.Claim_Status__c = 'Closed';
        claim1.ClaimCloseDAte__c = system.today();
        update claim1;
        
        Map<Id, Policy_Claim__c> MyNewMap= new Map<Id, Policy_Claim__c>();
        MyNewMap.put(claim1.id,claim1);
        
        Policy_Claim_Handler objclaimHandler = new Policy_Claim_Handler();
        objclaimHandler.beforeInsert(polClaim); 
        objclaimHandler.afterDelete(MyMap);
        objclaimHandler.beforeDelete(MyMap);
        objclaimHandler.beforeUpdate(MyMap,MyNewMap);  
        Test.stopTest();        
    }
    
    
}