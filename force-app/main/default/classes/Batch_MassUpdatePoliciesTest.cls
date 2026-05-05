@isTest
public class Batch_MassUpdatePoliciesTest {
    
    @testSetup static void setup() {
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Account acc1                   = TestDataFactory.createAccounts('Test Account second');
        acc1.AccountNumber             = '123456987';
        acc1.Vendor_Account__c         = true;
        //insert acc1;
        
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
        
        Test.startTest();
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorNew.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Treaty_Version_Transaction__c treatVer = new Treaty_Version_Transaction__c();
        treatVer.GL_Account__c = glAccounts[0].Id;
        treatVer.Transaction_Type__c = '5x5';
        
        Treaty_Versions__c treat = new Treaty_Versions__c();
        treat.Start_Date__c = system.today();
        treat.End_Date__c = system.today()+55;
        insert treat;
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy.Policy_Series_Effective_Date__c = system.today()+10;
        acctivePolicy.Effective_Date__c = system.today()+10;
        acctivePolicy.Expiration_Date__c = system.today()+35;
        acctivePolicy.Treaty_Version__c = NULL;
        insert acctivePolicy;
        
        Policy__c acctivePolicy2 = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy2.Limit__c = coverageFactorObj.Id;
        acctivePolicy2.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy2.Policy_Series_Effective_Date__c = system.today();
        acctivePolicy2.Effective_Date__c = system.today();
        acctivePolicy2.Expiration_Date__c = system.today()+45;
        acctivePolicy2.Treaty_Version__c = NULL;
        insert acctivePolicy2;
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('','','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        objPolEndorse.Endorsement_Effective_Date__c = system.today().addDays(+11);
        insert objPolEndorse;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,acctivePolicy.id);
        insert aop;
        
        AcctSeed__Billing__c objBilling = TestDataFactory.createBilling(acc.Id, lstPeriod.Id, ledgers[0].id);
        insert objBilling;
        
        
        Test.stopTest();
        
    }
    @isTest static void unitTest(){
        list<Policy__c> polList = [SELECT id, Effective_Date__c, Expiration_Date__c FROM Policy__c];
        
        
        Test.startTest();
        //Batch_MassUpdatePolicies obj = new Batch_MassUpdatePolicies();
        Batch_MassUpdatePolicies obj = New Batch_MassUpdatePolicies();
        
        Database.QueryLocator ql = obj.start(null);
        obj.execute(null,polList);
        obj.Finish(null);
        Test.stopTest();
    }
    @isTest static void unitTest1(){
        list<Policy__c> polList = [SELECT id, Effective_Date__c, Expiration_Date__c FROM Policy__c];
        
        
        Test.startTest();
        //Batch_MassUpdatePolicies obj = new Batch_MassUpdatePolicies();
        Batch_MassUpdatePolicies obj = New Batch_MassUpdatePolicies('select id,(select id,Effective_Date__c,Expiration_Date__c,Cancel_Date__c from Policies__r where RecordType.Name = \'Policy\' order by Effective_Date__c) from Account','Update Policy Series');
        Database.ExecuteBatch(obj);
        Test.stopTest();
    }
    @isTest static void unitTest2(){
        list<Policy__c> polList = [SELECT id, Effective_Date__c, Expiration_Date__c FROM Policy__c];
        
        
        Test.startTest();
        //Batch_MassUpdatePolicies obj = new Batch_MassUpdatePolicies();
        Batch_MassUpdatePolicies obj = New Batch_MassUpdatePolicies(null,'Dividend Update');
        try{
            Database.ExecuteBatch(obj);
        }Catch(Exception e){
            
        }
        
        Test.stopTest();
    }
}