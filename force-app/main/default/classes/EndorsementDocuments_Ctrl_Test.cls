@isTest
private class EndorsementDocuments_Ctrl_Test {
    
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
        
        Policy__c pol                 = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Policy');
        pol.Base_Amount__c = 100;
        pol.Firm_Mod__c = 2;
        pol.Limit__c = FactorCoverage.Id;
        pol.Deductible_ID__c = DedFac.id;
        insert pol;

        test.startTest();
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,pol.id,'General');
        insert poicyEndorse;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(acc.Id,pol.Id,acj.Id);
        insert law;
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        /**
        Policy_Quote__c objpolQut = TestDataFactory.createPolicyQuote(pol.Id,FactorCoverage.Id,DedFac.Id);
        objpolQut.Adj_R_O__c = true;
        objpolQut.Final_Quote__c = true;
        insert objpolQut;
        
        
        Policy_Quote__c objpolQut2 = TestDataFactory.createPolicyQuote(pol.Id,FactorCoverage.Id,DedFac.Id);
        objpolQut2.Adj_R_O__c = true;
        objpolQut2.Final_Quote__c = true;
        insert objpolQut2;
        **/
        test.stopTest();
        
    }
    
    @isTest static void testMethod1() {
        
        List<Policy_Endorsement__c> policyEndorseMentList = [SELECT Id,NAME,Policy__c,Endorsement_Number__c,Policy_Lawyer_Json__c,
                                                             Policy__r.Total_Final_Quotes__c,Policy__r.Total_Quotes__c
                                                             FROM Policy_Endorsement__c];
        
        List<Policy_Quote__c> PolQuote = [select id from Policy_Quote__c];
        
        for(Policy_Endorsement__c pE : policyEndorseMentList){
            pE.Endorsement_Number__c = 'IL 230';
            pe.Manuscript__c = 'test';
        }
        
        update policyEndorseMentList;
        Test.startTest();
        
        EndorsementDocuments_Ctrl Ctrl = new EndorsementDocuments_Ctrl();
        Ctrl.hasOneNonFinalQuote = false;
        //Ctrl.quote=PolQuote[0];
        Ctrl.setrecordId(policyEndorseMentList[0].Id);
        String Idrecord = Ctrl.getrecordId();
        Ctrl.endorsementVersion = 'test';
        Ctrl.setrecordId(policyEndorseMentList[0].Policy__c );
        
        Test.stopTest();
        
    }
 
}