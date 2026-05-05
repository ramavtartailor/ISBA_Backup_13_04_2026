@isTest
private class CM_AccountPayable_edit_controller_Test {
    
    @testSetup static void setup() {
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Account acc1                   = TestDataFactory.createAccounts('Test Account');
        acc1.AccountNumber             = '123456';
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
        
        /*
        Policy__c pol                 = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Application');
        pol.Status__c                 = 'Application created';
        pol.SCH_Mod__c                = 1.00;
        insert pol;
        
        
        Policy__c pol1                 = TestDataFactory.createPolicy(acc1.Id,opp.id,geo.id,'Application');
        pol1.Status__c                 = 'Application created';
        pol1.SCH_Mod__c                = 1.00;
        insert pol1;
        Test.startTest();
        
        Policy__c pol1                 = TestDataFactory.createActivePolicy(acc1.Id,opp.id,geo.id,'Application');
        insert pol1;
        */
        
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
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('','','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        insert objPolEndorse;
        
        Test.startTest();
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,acctivePolicy.id);
        insert aop;
        Test.stopTest();
        
    }
    
    @isTest static void testMethod1() {
        Test.startTest(); 
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<AcctSeed__Ledger__c> ledgers = [SELECT Id FROM AcctSeed__Ledger__c];
        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id,NAME FROM AcctSeed__GL_Account__c];
        List<AcctSeed__Accounting_Period__c> period = [SELECT Id,NAME FROM AcctSeed__Accounting_Period__c];
        
        Policy__c  policy = policies[0];
        
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(policies[0].Account__c, conList[0].Id);
        insert junc;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(policies[0].Account__c,policies[0].Id,junc.Id);
        insert law; 
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        insert calimset;
        
        Policy_Claim__c claim = TestDataFactory.createPolicyClaim(policies[0].Id,law.Id);
        claim.Aggregate_Limit__c = 100000;
        claim.LAE_Pay__c = 100;
        claim.Claim_Closed__c = true;
        insert claim;
        
        AcctSeed__Account_Payable__c payable = TestDataFactory.createAccountPayable(Period[0].Id,ledgers[0].Id,policies[0].Account__c,null);
        payable.Claim__c = claim.Id; 
        insert payable;
        
        PageReference pageRef = Page.AccountPayable_Edit;
        pageRef.getParameters().put('id', payable.id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(payable);
        CM_AccountPayable_edit_controller Ctrl = new CM_AccountPayable_edit_controller(sc);
        Ctrl.indexOfLineItemToBeRemoved = '0';
        //       Ctrl.removeLineItemRow();
        Ctrl.addAccPayNewLine();
        
        for(CM_AccountPayable_edit_controller.HIC_AccountPayableLineItemWrapper obj: Ctrl.accPayLineWrapList){
            obj.accPayabaleObj.AcctSeed__Expense_GL_Account__c = glAccounts[0].Id;
            obj.accPayabaleObj.AcctSeed__Amount__c = 100;
        }
        
        Ctrl.selectedAppPolicy = policy.id;
        Ctrl.selectedPolicyClaimId =claim.id;
        Ctrl.onUpdateClick();
        Ctrl.removeLineItemRow();
        
        Test.stopTest();
    }
    
    @isTest static void testMethod2() {
        Test.startTest(); 
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<AcctSeed__Ledger__c> ledgers = [SELECT Id FROM AcctSeed__Ledger__c];
        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id,NAME FROM AcctSeed__GL_Account__c];
        List<AcctSeed__Accounting_Period__c> period = [SELECT Id,NAME FROM AcctSeed__Accounting_Period__c];
        Policy__c  policy = policies[0];
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(policies[0].Account__C, conList[0].Id);
        insert junc;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(policies[0].Account__c,policies[0].Id,junc.Id);
        insert law; 
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        insert calimset;
        
        Policy_Claim__c claim = TestDataFactory.createPolicyClaim(policies[0].Id,law.Id);
        claim.Aggregate_Limit__c = 100000;
        claim.LAE_Pay__c = 100;
        claim.Claim_Closed__c = true;
        insert claim;
        
        AcctSeed__Account_Payable__c payable = TestDataFactory.createAccountPayable(Period[0].Id,ledgers[0].Id,policies[0].Account__c,null);
        insert payable;
        
        PageReference pageRef = Page.AccountPayable_Edit;
        pageRef.getParameters().put('id', payable.id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(payable);
        CM_AccountPayable_edit_controller Ctrl = new CM_AccountPayable_edit_controller(sc);
        Ctrl.getVendorAccountOptions();
        Ctrl.addAccPayNewLine();
        Ctrl.removeLineItemRow();
        
        Test.stopTest();
        
    }
    
    
    
     @isTest static void testMethod_p() {
        Test.startTest(); 
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<AcctSeed__Ledger__c> ledgers = [SELECT Id FROM AcctSeed__Ledger__c];
        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id,NAME FROM AcctSeed__GL_Account__c];
        List<AcctSeed__Accounting_Period__c> period = [SELECT Id,NAME FROM AcctSeed__Accounting_Period__c];
        Policy__c  policy = policies[0];
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(policies[0].Account__C, conList[0].Id);
        insert junc;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(policies[0].Account__c,policies[0].Id,junc.Id);
        insert law; 
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        insert calimset;
        
        Policy_Claim__c claim = TestDataFactory.createPolicyClaim(policies[0].Id,law.Id);
        claim.Aggregate_Limit__c = 100000;
        claim.LAE_Pay__c = 100;
        claim.Claim_Closed__c = true;
        insert claim;
        
        AcctSeed__Account_Payable__c payable = TestDataFactory.createAccountPayable(Period[0].Id,ledgers[0].Id,policies[0].Account__c,null);
       // insert payable;
        
        PageReference pageRef = Page.AccountPayable_Edit;
       // pageRef.getParameters().put('id', payable.id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(payable);
        CM_AccountPayable_edit_controller Ctrl = new CM_AccountPayable_edit_controller(sc);
        Ctrl.selectedVendorId='test';
        Ctrl.getVendorAccountOptions();
        Ctrl.addAccPayNewLine();
        Ctrl.removeLineItemRow();
        
        Test.stopTest();
        
    }
    
}