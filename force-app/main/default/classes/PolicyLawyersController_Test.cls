@isTest
private class PolicyLawyersController_Test {
    
    @testSetup static void setup() {
        
        Account acc                   = TestDataFactory.createAccounts(Label.Bucket_Account);
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
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        //insert poicyEndorse;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,acctivePolicy.id);
        insert aop;
        test.stopTest();
        
    }
    /*
    @isTest static void testMethod1() {
        
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        List<Account> ListAcc=[select id from Account];
        
        Account acc = ListAcc[0];              
        
        Contact con1                   = TestDataFactory.createContact('Test Contact',acc.id);
        insert con1;
        
        Policy__c  policy = policies[0];
        List<AccountContactRelation> lstAccCon = [Select id from AccountContactRelation];
        
        AccountContactJunction__c junc = new AccountContactJunction__c();
        junc.Account__c = policies[0].Account__c;
        junc.Contact__c = con1.Id;
        insert junc;
        
        Policy_Lawyer__c lawyerobj = TestDataFactory.createPolicyLawyer(acc.Id,policies[0].Id,junc.Id);
        lawyerobj.Prior_Act_Date__c =date.today();
        lawyerobj.Rate_At__c =123;
        insert lawyerobj;
        
        PageReference pageRef = Page.PolicyLawyers;
        pageRef.getParameters().put('Id', policy.Id);
        system.Test.setCurrentPage(pageRef);
        
        PolicyLawyersController Ctrl = new PolicyLawyersController();
       
        for(PolicyLawyersController.WrapperClass wrap : Ctrl.modalList){
            wrap.isStatus = true;
            wrap.policyLawyerObj = lawyerobj;
        }
        Ctrl.firstName = 'test12';
        Ctrl.lastName = 'test2';
        Ctrl.AddLawyer();
        Ctrl.insertContact();
      //  Ctrl.contactRec.LastName = 'Test';
        Ctrl.saveContact();
        Ctrl.contactRec.FirstName = 'Test';
        Ctrl.contactRec.LastName = 'Test2';
        Ctrl.selectedContacts = con1.id;
        Ctrl.associateContacts();
        Ctrl.searchContact(); 
        Ctrl.redirectToFirstPage();
        Ctrl.savePolicyLawyer();
        Ctrl.cancelMethod();
        
        Test.startTest();
        
        List<Policy_Lawyer__c> lawList = [SELECT Id FROM Policy_Lawyer__c ];
        
        Ctrl.policyLawyerId = String.valueof(lawList[0].id);
        // Ctrl.removePolicyLawyer();
        Test.stopTest();
        
    }

    */
    
    
    
    
    @isTest static void searchContact_Test() {
             
        Test.startTest();
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        
        List<Account> ListAcc=[select id from Account];
        
        Account acc = ListAcc[0];    
        
        Contact con1                   = TestDataFactory.createContact('Test Contact',acc.id);
        insert con1;
        
        Policy__c  policy = policies[0];
        List<AccountContactRelation> lstAccCon = [Select id from AccountContactRelation];
        
        AccountContactJunction__c junc = new AccountContactJunction__c();
        junc.Account__c = policies[0].Account__c;
        junc.Contact__c = con1.Id;
        insert junc;
        
        Policy_Lawyer__c lawyerobj = TestDataFactory.createPolicyLawyer(acc.Id,policies[0].Id,junc.Id);
        insert lawyerobj;
        
        PageReference pageRef = Page.PolicyLawyers;
        pageRef.getParameters().put('Id', policy.Id);
        system.Test.setCurrentPage(pageRef);
        
        
        PolicyLawyersController Ctrl = new PolicyLawyersController();
        Ctrl.firstName = null;
        Ctrl.lastName = 'Test';
        Ctrl.searchContact();
        Test.stopTest();
        
    }
    
     @isTest static void searchContact_Test_P() {
             
        Test.startTest();
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        
        List<Account> ListAcc=[select id from Account];
        
        Account acc = ListAcc[0];    
        
        Contact con1  = TestDataFactory.createContact('Test Contact2',acc.id);
         con1.Email='test@gmail.com';
        insert con1;
        
        Policy__c  policy = policies[0];
        List<AccountContactRelation> lstAccCon = [Select id from AccountContactRelation];
        
        AccountContactJunction__c junc = new AccountContactJunction__c();
        junc.Account__c = policies[0].Account__c;
        junc.Contact__c = con1.Id;
        insert junc;
        
        Policy_Lawyer__c lawyerobj = TestDataFactory.createPolicyLawyer(acc.Id,policies[0].Id,junc.Id);
        lawyerobj.Prior_Act_Date__c=date.today();
        lawyerobj.Rate_At__c=2;
        insert lawyerobj;
        
        PageReference pageRef = Page.PolicyLawyers;
        pageRef.getParameters().put('Id', policy.Id);
        system.Test.setCurrentPage(pageRef);
         
         
        PolicyLawyersController.WrapperClass MyWrapper = new PolicyLawyersController.WrapperClass(true,junc,junc.Id);
        MyWrapper.policyLawyerObj=lawyerobj;
         
        List< PolicyLawyersController.WrapperClass> WrapList = new  List< PolicyLawyersController.WrapperClass>();
        WrapList.add(MyWrapper);
         
        List<Policy_Lawyer__c> LawList = new List<Policy_Lawyer__c>();
        LawList.add(lawyerobj);
        
        
        PolicyLawyersController Ctrl = new PolicyLawyersController();
        Ctrl.modalList=WrapList;
        Ctrl.firstName = 'test';
        Ctrl.lastName = 'Test';
        Ctrl.status=true;
        Ctrl.indexPolicyLawyer=0;
        Ctrl.policyLawyerList =LawList;
        Ctrl.searchContact();
        Ctrl.AddLawyer();
        Ctrl.insertContact();
        Ctrl.selectedContacts = con1.id;
        Ctrl.saveContact();
        Ctrl.savePolicyLawyer();
        Ctrl.redirectToFirstPage();
        //Ctrl.removePolicyLawyer();
        Ctrl.cancelMethod();
        Test.stopTest();
        
    }
    
     @isTest static void searchContact_Test_1() {
             
        Test.startTest();
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        List<Account> ListAcc=[select id from Account];
        
        Account acc = ListAcc[0];    
        
        Contact con1                   = TestDataFactory.createContact('Test Contact',acc.id);
        insert con1;
        
        Policy__c  policy = policies[0];
        List<AccountContactRelation> lstAccCon = [Select id from AccountContactRelation];
        
        AccountContactJunction__c junc = new AccountContactJunction__c();
        junc.Account__c = policies[0].Account__c;
        junc.Contact__c = con1.Id;
        insert junc;
        
        Policy_Lawyer__c lawyerobj = TestDataFactory.createPolicyLawyer(acc.Id,policies[0].Id,junc.Id);
        insert lawyerobj;
        
        PageReference pageRef = Page.PolicyLawyers;
        pageRef.getParameters().put('Id', policy.Id);
        system.Test.setCurrentPage(pageRef);
        
        
        PolicyLawyersController Ctrl = new PolicyLawyersController();
        Ctrl.firstName = null;
        Ctrl.lastName = 'Test';
        Ctrl.ardcNumber = '123456789';
        Ctrl.searchContact();
        Test.stopTest();
        
    }

    
     @isTest static void searchContact_Test_2() {
             
        Test.startTest();
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        List<Account> ListAcc=[select id from Account];
        
        Account acc = ListAcc[0];    
        
        Contact con1                   = TestDataFactory.createContact('Test Contact',acc.id);
        insert con1;
        
        Policy__c  policy = policies[0];
        List<AccountContactRelation> lstAccCon = [Select id from AccountContactRelation];
        
        AccountContactJunction__c junc = new AccountContactJunction__c();
        junc.Account__c = policies[0].Account__c;
        junc.Contact__c = con1.Id;
        insert junc;
        
        Policy_Lawyer__c lawyerobj = TestDataFactory.createPolicyLawyer(acc.Id,policies[0].Id,junc.Id);
        insert lawyerobj;
        
        PageReference pageRef = Page.PolicyLawyers;
        pageRef.getParameters().put('Id', policy.Id);
        system.Test.setCurrentPage(pageRef);
        
        
        PolicyLawyersController Ctrl = new PolicyLawyersController();
        Ctrl.indexPolicyLawyer = 1;
        Ctrl.firstName = null;
        Ctrl.lastName = null;
        Ctrl.ardcNumber = '123456789';
        Ctrl.searchContact();
        Ctrl.removePolicyLawyer();
        Test.stopTest();
        
    }


}