@isTest
public class CompleteAndCreateFollowUpTaskCtrl_Test {
    
    @testSetup 
    static void testSData(){
        // Insert Account
        Account acc = TestDataFactory.createAccounts('Test Account');
        insert acc;
        
        // Insert Contact
        Contact con = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        // Insert Opportunity
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        // Insert GlAccounts
        List<AcctSeed__GL_Account__c> glAccounts = TestDataFactory.createGLAccounts();        
        insert glAccounts;
        
        // Insert BillingFormats
        List<AcctSeed__Billing_Format__c> billingFormats = TestDataFactory.createBillingFormats();        
        insert billingFormats ;
        
        // Insert Accounting Period
        AcctSeed__Accounting_Period__c lstPeriod = TestDataFactory.createAcctPeriod();
        insert lstPeriod;
        
        // Insert Ledgers
        List<AcctSeed__Ledger__c> ledgers = TestDataFactory.createLedgers(glAccounts[0].id,billingFormats[0].id,billingFormats[1].id,billingFormats[2].id,billingFormats[3].id,billingFormats[4].id);
        insert ledgers;
        
        // Insert Accounting Setting
        AcctSeed__Accounting_Settings__c settings = TestDataFactory.createAccountsetting(ledgers[0].id,glAccounts[0].Id,glAccounts[1].Id,glAccounts[2].Id,glAccounts[3].Id,glAccounts[4].Id,glAccounts[5].Id,glAccounts[6].Id,billingFormats[0].Id);
        insert settings;
        
        // Insert MasterFactor
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Geo');
        insert mas;
        
        // Insert Master Factor / Step Rate
        Master_Factor__c masterFactor = TestDataFactory.createMasterfactor('Test Master Factor0','Step Rate');
        insert masterFactor;
        
        // Insert Master Factor / Base Value
        Master_Factor__c masterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert masterFactor1;
        
        // Insert Master Factor / AOP
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        // Insert County
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        // Insert Geo Factor
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.id,county.Id);
        insert geo;
        
        // Insert Step Rate Factor
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(masterFactor.Id);
        insert stepRateFactor;
        
        // Insert Base Factor
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(masterFactor1.Id);
        insert baseFactor;
        
        // Insert ILF Coverage Factor
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorNew.Id);
        insert coverageFactorObj;
        
        // Insert Deductible Factor
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        // Insert Policy
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        insert acctivePolicy;
        
        // Insert AccountContactJunction
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(acctivePolicy.Account__C, con.Id);
        insert junc;
        
        // Insert Policy Lawyer
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(acctivePolicy.Account__C,acctivePolicy.Id,junc.Id);
        insert law; 
        
        // Insert Custom Setting
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        insert calimset;
        
        // Policy Claim
        Policy_Claim__c claim = TestDataFactory.createPolicyClaim(acctivePolicy.Id,law.Id);
        insert claim;
        
        // Policy Claim Detail 
        Policy_Claim_Detail__c claimDetail = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Claim Payment',claim.Id,'Loss Payment');
        insert claimDetail;
        
    }
    
    @isTest
    static void getRecordDetails_Test(){
        
        
        List<Account> accList = [select id from Account];
        Note__c note = new Note__c();
        note.Subject__c = 'Subject';
        note.Description__c = 'Description';
        note.Type__c = 'AAAF/RAAF';
        insert note;
        
        Task tsk = new Task();
        tsk.Subject = 'Subject';
        tsk.Description = 'Description';
        tsk.Note__c = note.id;
        tsk.WhatId = accList[0].id;
        insert tsk;
        
        List<Task> tskList =  [select id,Note__c,Subject,Description,WhatId,Note__r.Subject__c,Note__r.Description__c,Note__r.Type__c from Task];
        CompleteAndCreateFollowUpTaskCtrl.getRecordDetails(String.valueOf(tskList[0].id));
        
    }
    
    
    @isTest
    static void getRecordDetails_Test1(){
        
       
        List<Policy_Claim__c> policyClaimList = [select id from Policy_Claim__c];
        
        Note__c note = new Note__c();
        //note.Subject__c = 'Subject';
        note.Description__c = 'Description';
        note.Type__c = 'AAAF/RAAF';
        insert note;
        
        Task tsk = new Task();
        tsk.Subject = 'Subject';
        tsk.Description = 'Description';
        tsk.Note__c = note.id;
        tsk.WhatId = policyClaimList[0].id;
        insert tsk;
        
        List<Task> tskList =  [select id,Note__c,Subject,Description,WhatId,Note__r.Subject__c,Note__r.Description__c,Note__r.Type__c from Task];
        CompleteAndCreateFollowUpTaskCtrl.getRecordDetails(String.valueOf(tskList[0].id));
        
    }
    
    @isTest
    static void getRecordDetails_Test2(){
        
       
        List<Opportunity> oppList = [select id from Opportunity];
        
        Note__c note = new Note__c();
        note.Subject__c = 'Subject';
        note.Description__c = 'Description';
        note.Type__c = 'AAAF/RAAF';
        insert note;
        
        Task tsk = new Task();
        tsk.Subject = 'Subject';
        tsk.Description = 'Description';
        tsk.Note__c = note.id;
        tsk.WhatId = oppList[0].id;
        insert tsk;
        
        List<Task> tskList =  [select id,Note__c,Subject,Description,WhatId,Note__r.Subject__c,Note__r.Description__c,Note__r.Type__c from Task];
        CompleteAndCreateFollowUpTaskCtrl.getRecordDetails(String.valueOf(tskList[0].id));
        
    }
}