@isTest
private class CreateApplicationEndorsementsEXT_Test {
    
    @testSetup static void setup() {
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Account acc1                   = TestDataFactory.createAccounts('Test Account');
        acc1.AccountNumber             = '123456';
        acc1.Vendor_Account__c         = true;
      //  insert acc1;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        con.FirstName                 = 'Test';
        con.Type__c                   = 'Lawyer';
        con.Contact_Role__c           = 'P';
        con.AccountId                 = acc.Id;
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
        //geo.County__c                 = county.Id;
        insert geo;
        
        Master_Factor__c masterFactor = TestDataFactory.createMasterfactor('Test Master Factor0','Step Rate');
        insert masterFactor;
        
        Test.startTest();       
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(masterFactor.Id);
        insert stepRateFactor;
        
        Master_Factor__c masterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert masterFactor1;
        
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(masterFactor1.Id);
        insert baseFactor;
        
        Policy__c pol                 = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Application');
        pol.Status__c                 = 'Application created';
        pol.SCH_Mod__c                = 1.00;
        insert pol;
        
        Policy__c pol1                 = TestDataFactory.createPolicy(acc1.Id,opp.id,geo.id,'Application');
        pol1.Status__c                 = 'Application created';
        pol1.SCH_Mod__c                = 1.00;
        //insert pol1;
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('','','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,pol.id,'General');
        insert objPolEndorse;
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Test.stopTest(); 
    }
    
    @isTest static void testMethod1() {
        
        List<Policy_Endorsement__c> policies = [SELECT Id,RecordTypeId,Account__c,Policy__c FROM Policy_Endorsement__c];
        
        Policy_Endorsement__c  policy = policies[0];
        
        Test.startTest();
        PageReference pageRef = Page.CreateApplicationEndorsementsVFP;
        pageRef.getParameters().put('Id', policy.Policy__c);
        system.Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('origin', 'true');
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(policies);
        CreateApplicationEndorsementsEXT Ctrl = new CreateApplicationEndorsementsEXT(sc);
        ctrl.recordTypeId = policies[0].RecordTypeId;
        ctrl.getRecordTypeNames();
        ctrl.CustomContinue(); 
        ctrl.Cancel(); 
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod2() {
        
        List<Policy_Endorsement__c> policies = [SELECT Id,RecordTypeId,Account__c,Policy__c FROM Policy_Endorsement__c];
        
        Policy_Endorsement__c  policy = policies[0];
        
        Test.startTest();
        PageReference pageRef = Page.CreateApplicationEndorsementsVFP;
        pageRef.getParameters().put('Id', policy.Policy__c);
        system.Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('origin', 'false');
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(policies);
        CreateApplicationEndorsementsEXT Ctrl = new CreateApplicationEndorsementsEXT(sc);
        ctrl.recordTypeId = policies[0].RecordTypeId;
        ctrl.getRecordTypeNames();
        ctrl.CustomContinue(); 
        ctrl.Cancel(); 
        
        delete [SELECT Id from AccountContactJunction__c];  
        Test.stopTest();
        
    }
    
    @isTest static void testMethod3() {
        
        List<Policy_Endorsement__c> policies = [SELECT Id,RecordTypeId,Account__c,Policy__c FROM Policy_Endorsement__c];
        
        Policy_Endorsement__c  policy = policies[0];
        
        Test.startTest();
        PageReference pageRef = Page.CreateApplicationEndorsementsVFP;
        pageRef.getParameters().put('Id', policy.Policy__c);
        system.Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('origin', 'false');
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(policies);
        CreateApplicationEndorsementsEXT Ctrl = new CreateApplicationEndorsementsEXT(sc);
        ctrl.recordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT').getRecordTypeId(); 
        ctrl.getRecordTypeNames();
        ctrl.CustomContinue(); 
        ctrl.recordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 152 Adding an Attorney Endorsement').getRecordTypeId(); 
        ctrl.CustomContinue(); 
        
        ctrl.recordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 153 Deleting an Attorney Endorsement').getRecordTypeId(); 
        ctrl.CustomContinue(); 
        ctrl.recordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 115 UNLIMITED PURCHASED EXTENDED').getRecordTypeId(); 
        ctrl.CustomContinue(); 
        
        
        ctrl.Cancel(); 
        
        delete [SELECT Id from AccountContactJunction__c];  
        ctrl.CustomContinue();
        
        Test.stopTest();
        
    }     
    
     @isTest static void testMethod_4() {
        
        List<Policy_Endorsement__c> policies = [SELECT Id,RecordTypeId,Account__c,Policy__c FROM Policy_Endorsement__c];
        
        Policy_Endorsement__c  policy = policies[0];
         Test.startTest();
        PageReference pageRef = Page.CreateApplicationEndorsementsVFP;
        pageRef.getParameters().put('Id', policy.Policy__c);
        system.Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('origin', 'false');
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(policies);
        CreateApplicationEndorsementsEXT Ctrl = new CreateApplicationEndorsementsEXT(sc);
         ctrl.CustomContinue(); 
        ctrl.recordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT').getRecordTypeId(); 
        ctrl.getRecordTypeNames();
        ctrl.CustomContinue(); 
        ctrl.recordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 152 Adding an Attorney Endorsement').getRecordTypeId(); 
        ctrl.CustomContinue(); 
        
        ctrl.recordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 153 Deleting an Attorney Endorsement').getRecordTypeId(); 
        ctrl.CustomContinue(); 
        ctrl.recordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 115 UNLIMITED PURCHASED EXTENDED').getRecordTypeId(); 
        ctrl.CustomContinue(); 
        
        
        ctrl.Cancel(); 
        
        delete [SELECT Id from AccountContactJunction__c];  
        ctrl.CustomContinue();
        
        Test.stopTest();
        
    }
}