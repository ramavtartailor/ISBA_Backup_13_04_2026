@isTest
public class MassRenewalPolicyCtrl_Test {
    @testSetup static void setup() {
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Account acc1                   = TestDataFactory.createAccounts('Test Account');
        acc1.AccountNumber             = '123456';
        acc1.Vendor_Account__c         = true;
        insert acc1;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        opp.StageName                 = 'Application Sent';
        opp.CloseDate                 = Date.today();
        insert opp;
        
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
        
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Geo');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.id,county.Id);
        //geo.County__c                 = county.Id;
        insert geo;
        
        Master_Factor__c masterFactor = TestDataFactory.createMasterfactor('Test Master Factor0','Step Rate');
        insert masterFactor;
        
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(masterFactor.Id);
        insert stepRateFactor;
        
        Master_Factor__c masterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert masterFactor1;
        
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(masterFactor1.Id);
        insert baseFactor;
        
        Policy__c pol                 = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Policy');
        pol.Status__c                 = 'Bound';
        pol.ClonedBy__c = 'Manual Renewal';
        insert pol;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(acc.id,pol.id,acj.Id);
        insert law; 
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        insert calimset;
        
        Policy_Claim__c claim = TestDataFactory.createPolicyClaim(pol.id,law.id);
        insert claim;
        
    }
    
    
   
    @isTest static void testMethod1() {
        
        Test.startTest();
        
        List<Policy__c> policies = [SELECT Id,Name,Account__c FROM Policy__c];
        
        PageReference PageRef = Page.MassRenewalPolicy;
        Test.setCurrentPageReference(PageRef);
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(policies);
        sc.setSelected(policies);
        MassRenewalPolicyCtrl objMassRenewal = new MassRenewalPolicyCtrl(sc);
        
        objMassRenewal.massRenewPolicies();
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod2() {
        
        Test.startTest();
        
        List<Policy__c> policies = [SELECT Id,Name,Account__c FROM Policy__c];
        policies[0].Renew_Application__c =true;
        policies[0].Reason__c = 'test2';
        
        update policies;
        
        PageReference PageRef = Page.MassRenewalPolicy;
        Test.setCurrentPageReference(PageRef);
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(policies);
        sc.setSelected(policies);
        MassRenewalPolicyCtrl objMassRenewal = new MassRenewalPolicyCtrl(sc);
        
        objMassRenewal.massRenewPolicies();
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod3() {
        
        Test.startTest();
        
        List<Policy__c> policies = [SELECT Id,Name,Account__c FROM Policy__c];
        
        PageReference PageRef = Page.MassRenewalPolicy;
        Test.setCurrentPageReference(PageRef);
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(policies);
        //sc.setSelected(policies);
        MassRenewalPolicyCtrl objMassRenewal = new MassRenewalPolicyCtrl(sc);
        
        objMassRenewal.massRenewPolicies();
        
        Test.stopTest();
        
    }
    
    
    @isTest static void testMethod4() {
        
        Test.startTest();
        
        List<Policy__c> policies = [SELECT Id,Name,Account__c FROM Policy__c];
        policies[0].ClonedBy__c = 'Manual Renewal';
        policies[0].RecordTypeId = Schema.SObjectType.Policy__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();

        update policies; 
       
        PageReference PageRef = Page.MassRenewalPolicy;
        Test.setCurrentPageReference(PageRef);
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(policies);
        sc.setSelected(policies);
        MassRenewalPolicyCtrl objMassRenewal = new MassRenewalPolicyCtrl(sc);
        
        objMassRenewal.massRenewPolicies();
        
        Test.stopTest();
    }
    
    @isTest static void testMethod5() {
        
        Test.startTest();
        
        List<Policy__c> policies = [SELECT Id,Name,Account__c,RecordType.Name FROM Policy__c];
        policies[0].RecordType.Name = 'Application';
        policies[0].Reason__c = 'test2';
        update policies;
        
        PageReference PageRef = Page.MassRenewalPolicy;
        Test.setCurrentPageReference(PageRef);
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(policies);
        sc.setSelected(policies);
        MassRenewalPolicyCtrl objMassRenewal = new MassRenewalPolicyCtrl(sc);
        
        objMassRenewal.massRenewPolicies();
        
        Test.stopTest();
    }
    
    
    @isTest static void testMethod6() {
        
        Test.startTest();    

        List<Policy__c> policies = [SELECT Id,Name,Account__c,ClonedBy__c,RecordType.Name FROM Policy__c Limit 1];
        policies[0].ClonedBy__c = 'Test';
        System.assertEquals('Test', policies[0].ClonedBy__c);
        
        PageReference PageRef = Page.MassRenewalPolicy;
        Test.setCurrentPageReference(PageRef);
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(policies);
        sc.setSelected(policies);
        MassRenewalPolicyCtrl objMassRenewal = new MassRenewalPolicyCtrl(sc);
        objMassRenewal.massRenewPolicies();
        Test.stopTest();
    }
     @isTest static void testMethod7() {
        
        Test.startTest();
        
        List<Policy__c> policies = [SELECT Id,Name,Renew_Application__c,Account__c FROM Policy__c];
        policies[0].ClonedBy__c = 'Clone Opportunity Without Application';
         policies[0].Renew_Application__c = False;         
        policies[0].RecordTypeId = Schema.SObjectType.Policy__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();

        update policies; 
       
        PageReference PageRef = Page.MassRenewalPolicy;
        Test.setCurrentPageReference(PageRef);
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(policies);
        sc.setSelected(policies);
        MassRenewalPolicyCtrl objMassRenewal = new MassRenewalPolicyCtrl(sc);
        
        objMassRenewal.massRenewPolicies();
        
        Test.stopTest();
    }
    
}