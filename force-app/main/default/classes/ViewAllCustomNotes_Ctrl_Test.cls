@isTest
public class ViewAllCustomNotes_Ctrl_Test {
    
    @testSetup static void setup() {
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.Vendor_Account__c = true;
        insert acc;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        con.FirstName                 = 'Test';
        con.Type__c                   = 'Lawyer';
        con.AccountId                 = acc.Id;
        insert con;
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.Id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        List<AcctSeed__GL_Account__c> glAccounts = TestDataFactory.createGLAccounts();
        insert glAccounts;
        
        List<AcctSeed__Billing_Format__c> billingFormats = TestdataFactory.createBillingFormats();
        insert billingFormats;
        
        List<AcctSeed__Ledger__c> ledgers = TestdataFactory.createLedgers(glAccounts[0].id,billingFormats[0].id,billingFormats[1].id,billingFormats[2].id,billingFormats[3].id,billingFormats[4].id);
        insert ledgers;
        
        List<AcctSeed__Accounting_Period__c> lstAccountingPeriod = new List<AcctSeed__Accounting_Period__c>();
        Date currentDate = Date.newInstance(2018, 9,1);
        
        for(Integer i = 0; i < 36; i++){
            
            AcctSeed__Accounting_Period__c objAccountingPeriod = new AcctSeed__Accounting_Period__c();
            
            objAccountingPeriod.AcctSeed__Start_Date__c = currentDate.addMonths(i);
            objAccountingPeriod.AcctSeed__End_Date__c = objAccountingPeriod.AcctSeed__Start_Date__c.addMonths(1).toStartOfMonth() - 1;
            objAccountingPeriod.Name = objAccountingPeriod.AcctSeed__Start_Date__c.year() + '-' + (string.valueOf(objAccountingPeriod.AcctSeed__Start_Date__c.month()).length() == 1?'0':'') + objAccountingPeriod.AcctSeed__Start_Date__c.month();
            lstAccountingPeriod.add(objAccountingPeriod);
        }
        
        insert lstAccountingPeriod;
        
        AcctSeed__Accounting_Settings__c settings = TestDataFactory.createAccountsetting(ledgers[0].id,glAccounts[0].Id,glAccounts[1].Id,glAccounts[2].Id,glAccounts[3].Id,glAccounts[4].Id,glAccounts[5].Id,glAccounts[6].Id,billingFormats[0].Id);
        insert settings;
        
        Opportunity opp               = TestDataFactory.createOpp(acc.Id);
        insert opp;
        
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor', 'Geo');
        insert mas;
        
        County__c county              = TestDataFactory.createCounty();
        insert county;
        
        Geo_Factor__c geo             = TestDataFactory.createGeoFactor(mas.Id, county.Id);
        insert geo;
        
        Master_Factor__c masterFactor = TestDataFactory.createMasterfactor('Test Master Factor0', 'Step Rate');
        insert masterFactor;
        
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(masterFactor.Id);
        insert stepRateFactor;
        
        Master_Factor__c masterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1', 'Base Value');
        insert masterFactor1;
        
        Base_Factor__c baseFactor = new Base_Factor__c(Master_Factor__c=masterFactor1.Id, Base_Amount__c=100);
        insert baseFactor;
        
        List<Policy__c> policyList = new List<Policy__c>();
        
        Policy__c pol                 = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Application');
        pol.Status__c                 = 'Accepted';
        pol.SCH_Mod__c                = 1.00;
        pol.Active1__c = true;
        pol.Cancel_Date__c = date.today().addDays(5);
        pol.Expiration_Date__c = date.today().addDays(5);
        policyList.add(pol);
        
        Policy__c activePolicy = TestDataFactory.createActivePolicy(acc.Id,opp.id,geo.id,'Policy');
        policyList.add(activePolicy);
        
        Insert policyList;
        System.assertEquals(2, policyList.size());
        
        List<Policy__c> Poll = [select id,Name,Expiration_Date__c,Cancel_Date__c,Active__c from Policy__c where id =: policyList[1].id];
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('','','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,policyList[0].id,'General');
        insert objPolEndorse;
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,policyList[1].id);
        insert aop;  
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        insert calimset;
    }
    
    @isTest static void testMethod1() {
        
        Test.startTest();
        
        List<Policy__c> policies = [SELECT Id,Active__c,Account__c FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id,NAME FROM AcctSeed__GL_Account__c WHERE Name='4000-product Revenue'];
        
        Policy__c  policy = policies[1];
        
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(policies[1].Account__C, conList[0].Id);
        insert junc;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(policies[1].Account__c,policies[1].Id,junc.Id);
        insert law; 
        
        Policy_Claim__c claim = TestDataFactory.createPolicyClaim(policies[1].Id,law.Id);
        insert claim;
        
        PageReference pageRef = Page.ViewAllCustomNotes;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('Id',claim.id);
        ApexPages.currentPage().getParameters().put('obj','Claim');
        ViewAllCustomNotes_Ctrl ec = new ViewAllCustomNotes_Ctrl();
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod2() {
        
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        
        Policy__c  policy = policies[0];
        
        Test.startTest();
        PageReference pageRef = Page.ViewAllCustomNotes;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('Id',policy.Id);
        ApexPages.currentPage().getParameters().put('obj','Policy');
        
        ViewAllCustomNotes_Ctrl ec = new ViewAllCustomNotes_Ctrl();
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod3() {
        
        List<Account> accList = [SELECT Id,Name FROM Account];
       
        Test.startTest();
        PageReference pageRef = Page.ViewAllCustomNotes;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('Id',accList[0].Id);
        ApexPages.currentPage().getParameters().put('obj','Account');
        
        ViewAllCustomNotes_Ctrl ec = new ViewAllCustomNotes_Ctrl();
        
        Test.stopTest();
        
    }
    
}