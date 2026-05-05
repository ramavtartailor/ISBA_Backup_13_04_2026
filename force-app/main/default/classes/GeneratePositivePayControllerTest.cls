@isTest
public with sharing class GeneratePositivePayControllerTest {
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
        
        AcctSeed__Accounting_Period__c period = TestDataFactory.createAcctPeriod();
        insert period;
        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoveragefactor(MasterFactorCoverage.Id);
        insert FactorCoverage;
        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor1','Deductible');
        insert mas12;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        insert DedFac; 
        
        Policy__c pol                 = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Policy');
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
        
        //Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,pol.id,'General');
        //insert poicyEndorse;
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,pol.id);
        insert aop;
        test.stopTest();
        
    }
    
    @isTest
    public static void testMethod1(){
        
        AcctSeed__Cash_Disbursement_Batch__c[] cashDisbursementBatch = new List<AcctSeed__Cash_Disbursement_Batch__c>();
        cashDisbursementBatch.add(
            new AcctSeed__Cash_Disbursement_Batch__c(
                AcctSeed__Starting_Check_Number__c = 1,
                Name = 'Test Batch'
            )
        );
        
        cashDisbursementBatch.add(
            new AcctSeed__Cash_Disbursement_Batch__c(
                AcctSeed__Starting_Check_Number__c = 2,
                Name = 'Test Batch 2'
            )
        );
        
        insert cashDisbursementBatch;
        
        AcctSeed__Cash_Disbursement__c[] cashDisbursements = new List<AcctSeed__Cash_Disbursement__c>();
        AcctSeed__GL_Account__c glAccount = [Select Id From AcctSeed__GL_Account__c Where AcctSeed__Bank__c = true limit 1];
        Account acct = [Select Id From Account Limit 1];
        Contact contact = [Select Id From Contact Limit 1];
        AcctSeed__Accounting_Period__c acctPeriod = [Select Id, AcctSeed__Start_Date__c From AcctSeed__Accounting_Period__c Where AcctSeed__Status__c = 'Open' Limit 1];
        
        cashDisbursements.add(
            new AcctSeed__Cash_Disbursement__c(
                AcctSeed__Cash_Disbursement_Batch__c = cashDisbursementBatch[0].Id,
                AcctSeed__Amount__c = 12,
                AcctSeed__Bank_Account__c = glAccount.Id,
                AcctSeed__Vendor__c = acct.Id,
                AcctSeed__Status__c = 'Approved',
                AcctSeed__Accounting_Period__c = acctPeriod.Id
            )
        );
        
        cashDisbursements.add(
            new AcctSeed__Cash_Disbursement__c(
                AcctSeed__Cash_Disbursement_Batch__c = cashDisbursementBatch[0].Id,
                AcctSeed__Amount__c = 123,
                AcctSeed__Bank_Account__c = glAccount.Id,
                AcctSeed__Contact__c = contact.Id,
                AcctSeed__Status__c = 'Approved',
                AcctSeed__Accounting_Period__c = acctPeriod.Id
            )
        );
        
        insert cashDisbursements;
        
        AcctSeed.PostResult[] postResults = AcctSeed.CashDisbursementPostService.postCashDisbursements(cashDisbursements);
        // Loop through post results
        for (AcctSeed.PostResult theResult : postResults) {
            if (theResult.isSuccess) {
                System.debug('Successfully posted cash disbursement: ' + theResult.id);
            } 
            else {
                System.debug('Error posting cash disbursement ' + theResult.id);
                for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                    System.debug('Error status code ' + errorResult.statusCode);
                    System.debug('Error message ' + errorResult.message);
                }
            }
        }
        GeneratePositivePayController.generateFile(cashDisbursementBatch[0].Id);
        
    }
    
}