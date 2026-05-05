@isTest
public class RegularRenewalPDFExtn_Test {
    
    @testSetup static void setup() {
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        acc.BillingCity ='test City';
        acc.BillingStreet ='Test Street'; 
        acc.BillingState ='Test State';
        acc.BillingCountry='Test Country';
        acc.BillingPostalCode ='123456';
        insert acc;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
       // Id, LastName, Email, Website__c, Primary_Contact__c
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
        
        Claim_Setting__c calimset = new Claim_Setting__c ();
        calimset.Deductible_LAE_Applied_After__c =10;
        insert  calimset;
        
        Test.stopTest();
        
    }
    
    
    @isTest static void testMethod0() {
        
        Test.startTest();
        
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];        
        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id,NAME FROM AcctSeed__GL_Account__c WHERE Name='4000-product Revenue'];
        
        List<AccountContactJunction__c> juncObj = [SELECT Id,Name FROM AccountContactJunction__c];
        system.debug('juncObj========<>'+juncObj);
        list<Account> AccList =[select Id, Name, BillingCity, BillingStreet, BillingState, BillingCountry, BillingPostalCode from Account Limit 1];
        List<Contact> ConList1 =[Select Id, LastName, Email, Website__c, Primary_Contact__c from Contact Limit 1];
           
        Policy__c  policy = policies[0];  
        PageReference pageRef = Page.RegularRenewalPDF;
        pageref.getParameters().put('Id',policy.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(policy);
        RegularRenewalPDFExtn regularRenewalExtn = new RegularRenewalPDFExtn(sc);
        system.Test.setCurrentPage(pageRef);
        
        Test.stopTest();
        
    }
    
}