@isTest
public class EndorsementHandler_Test {
    
    @testSetup static void setup()
    {   
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
    
    @isTest static void testMethod1(){
        
        Test.startTest();
        Map<Id,Endorsement__c> newMap = new Map<Id,Endorsement__c>();
        Map<Id,Endorsement__c> oldMap = new Map<Id,Endorsement__c>();
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        
        List<Endorsement__c> lstEndo = [select id,Endorsement_Record_Type_ID__c from Endorsement__c];
        List<Endorsement__c> lstEndo1 = [select id,Endorsement_Record_Type_ID__c from Endorsement__c];
        newMap.put(lstEndo[0].id,lstEndo[0]);
        oldMap.put(lstEndo1[0].id,lstEndo1[0]);
        
        system.debug('----policies --'+policies );
        
        List<Contact> conList = [SELECT Id FROM Contact];
        
        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id,NAME FROM AcctSeed__GL_Account__c WHERE Name='4000-product Revenue'];
        
        Policy__c  policy = policies[0];
        
        PageReference pageRef = Page.RegularRenewalPDF;
        pageref.getParameters().put('Id',policy.Id);
        
        EndorsementHandler objHandler = new EndorsementHandler();
        objHandler.beforeUpdate(newMap,OldMap);
        objHandler.beforeDelete(oldmap);
        objHandler.afterDelete(oldMap);
        //EndorsementGateway.checkEndorsementRecordTypeId(newMap,OldMap);
        system.Test.setCurrentPage(pageRef); 
        
        Test.stopTest();
    }
    @isTest static void testMethod22(){
        
        Test.startTest();
        Map<Id,Endorsement__c> newMap = new Map<Id,Endorsement__c>();
        Map<Id,Endorsement__c> oldMap = new Map<Id,Endorsement__c>();
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        
        List<Endorsement__c> lstEndo = [select id,Endorsement_Record_Type_ID__c from Endorsement__c];
        List<Endorsement__c> lstEndo1 = [select id,Endorsement_Record_Type_ID__c from Endorsement__c];
        newMap.put(lstEndo[0].id,lstEndo[0]);
        oldMap.put(lstEndo1[0].id,lstEndo1[0]);
        
        system.debug('----policies --'+policies );
        
        List<Contact> conList = [SELECT Id FROM Contact];
        
        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id,NAME FROM AcctSeed__GL_Account__c WHERE Name='4000-product Revenue'];
        
        Policy__c  policy = policies[0];
        
        PageReference pageRef = Page.RegularRenewalPDF;
        pageref.getParameters().put('Id',policy.Id);  
        system.debug('>........new.>>>>>'+NewMap);
        system.debug('>.......old>>>>>>'+oldMap);
        
        EndorsementHandler objHandler = new EndorsementHandler();
        objHandler.afterInsert(NewMap);
        objHandler.bulkBefore();
        objHandler.bulkAfter();
        objHandler.beforeInsert(policies);
        objHandler.afterUpdate(oldMap, NewMap);
        system.Test.setCurrentPage(pageRef); 
        
        Test.stopTest();
    }
    
}