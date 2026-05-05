@isTest
private class EndorsementEditVFCtrl_Test {
    
    @testSetup
    static void testData(){
        
        Account acc                   = TestDataFactory.createAccounts('Bucket Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        con.FirstName                 = 'Test';
        con.LastName                  =  'Last Name';
        con.Type__c                   = 'Lawyer';
        con.Contact_Role__c           = 'P';
        con.AccountId                 = acc.Id;
        con.ARDC_Number__c = '12345';
        con.Middle_Name__c = 'Middle';
        con.Email = 'Test@gmail.com';
        con.Suffix__c = 'suffix';
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
        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoverageFactor(MasterFactorCoverage.Id);
        FactorCoverage.Percentage_5X5_Step_0__c =3;
        FactorCoverage.Percentage_5X5_Step_1__c=4;
        FactorCoverage.Percentage_5X5_Step_2__c=5;
        FactorCoverage.Percentage_5X5_Step_3__c=6;
        FactorCoverage.Percentage_5X5_Step_4__c=8;
        FactorCoverage.Premium_Rate_5X5__c = 33;
        FactorCoverage.Is_5X5_Coverage__c = true;
        insert FactorCoverage;
        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor','Deductible');
        insert mas12;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        Insert DedFac; 
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorNew.Id);
        coverageFactorObj.Is_5X5_Coverage__c = false;
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy.Effective_Date__c = system.today();
        acctivePolicy.Cancel_Date__c =  system.today()+2;
        acctivePolicy.Expiration_Date__c = date.today().addDays(10);
        acctivePolicy.Policy_Series_Effective_Date__c = date.valueOf('2019-09-06')  ;
        insert acctivePolicy;
       
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Endorsement_Version__c endorseVersion2 = TestDataFactory.createEndorsementVersion(endorse.Id);
        endorseVersion2.Endorsement_Version_Number__c='2';
        insert endorseVersion2;
        
        Policy_Lawyer__c polLawyer = TestDataFactory.createPolicyLawyer(acc.Id,acctivePolicy.Id,acj.Id);
        insert polLawyer;
        
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,acctivePolicy.id);
        insert aop;
        
        List<AccountContactJunction__c> accConjunctList = [select id,Account__c,Contact__c from AccountContactJunction__c];
        
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        objPolEndorse.Name = 'IL 150 POLICY ENDORSEMENT';
        objPolEndorse.Override_Rating__c = false;
        objPolEndorse.Step_Override__c = true;
        objPolEndorse.Step_Override_Value__c = 4;
        objPolEndorse.Lawyer__c = accConjunctList[0].id;
        objPolEndorse.Effective_Date__c =  System.Today();
        objPolEndorse.Endorsement_Effective_Date__c = System.today().adddays(10);
        objPolEndorse.Policy_Lawyer__c = polLawyer.Id;
       objPolEndorse.Endorsement_Number__c='IL 106';
        insert objPolEndorse;
      
        Policy_Endorsement_Term__c polEndTerm = new Policy_Endorsement_Term__c();
        polEndTerm.Endorsement__c = objPolEndorse.Id;
        insert polEndTerm;
        
    }
    
    @isTest
    static void saveEndorsement_Test(){
        List<Policy__c> policyList = [SELECT Id from Policy__c];
        List<Policy_Endorsement__c> poEndorsmentList = [SELECT Id,Name,Policy_Lawyer__c,Endorsement_Number__c,Effective_Date__c,RecordTypeId,Account__c,Rate_At__c,
                                                        Policy__c,Prior_Act_Date__c,Override_Rating__c,Step_Override__c,Lawyer__c,
                                                        Step_Override_Value__c,Endorsement_Effective_Date__c,Event_Status__c
                                                        FROM Policy_Endorsement__c where Policy__c =: policyList[0].Id];
        poEndorsmentList[0].Endorsement_Number__c = 'IL 106';
        update poEndorsmentList;
        
        List<Policy_Endorsement_Term__c> polEndTermList = [SELECT Id, Name, Endorsement__c FROM Policy_Endorsement_Term__c];
        system.debug('polEndTermList :: ' + polEndTermList);
         system.debug('polEndTermList162 :: ' + poEndorsmentList);
        
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        poEnd = poEndorsmentList[0];
        poEnd.Endorsement_Number__c='IL 106';
           poEnd.Name='IL 107 PURCHASE EXTENDED REPORTING ENDORSEMENT';
        //ApexPages.currentPage().getParameters().put('Endorsement_Number__c','IL 106');
       // ApexPages.currentPage().getParameters().put('policyId', poEndorsmentList[0].Policy__c);
        ApexPages.currentPage().getParameters().put('name', poEndorsmentList[0].Name);
        ApexPages.currentPage().getParameters().put('effectiveDate','10/02/2020');
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 107 PURCHASE EXTENDED REPORTING ENDORSEMENT').getRecordTypeId());
        //ApexPages.currentPage().getParameters().put('id', poEndorsmentList[0].Id);
        ApexPages.currentPage().getParameters().put('fromPage','ManageEndorsements');
        
        system.debug('poEnd174 :: ' + poEnd);
         system.debug('poEnd174 :: ' + poEnd.Endorsement_Number__c);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.singleColumnLayout  =true;
        ctrl.termEndorsement =true;
        ctrl.effectiveDateDisabled =true;
        Test.startTest();
        
        ctrl.removeRow();
        //ctrl.save();
        //ctrl.saveAndNew();
        ctrl.getFields();
        
        Test.stopTest();
    }
    
    
     @isTest
    static void saveEndorsement_Test_1(){
        
        List<Policy_Endorsement__c> poEndorsmentList = [SELECT Id,Name,Policy_Lawyer__c,Effective_Date__c,Endorsement_Number__c,RecordTypeId,Account__c,Rate_At__c,
                                                        Policy__c,Prior_Act_Date__c,Override_Rating__c,Step_Override__c,Lawyer__c,
                                                        Step_Override_Value__c,Endorsement_Effective_Date__c,Event_Status__c
                                                        FROM Policy_Endorsement__c];
        
        List<Policy_Endorsement_Term__c> polEndTermList = [SELECT Id, Name, Endorsement__c FROM Policy_Endorsement_Term__c];
        system.debug('polEndTermList :: ' + polEndTermList);
        
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('policyId', poEndorsmentList[0].Policy__c);
        ApexPages.currentPage().getParameters().put('name', poEndorsmentList[0].Name);
        ApexPages.currentPage().getParameters().put('effectiveDate','10/02/2020');
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 191 Reinstatement Notice').getRecordTypeId());
        //ApexPages.currentPage().getParameters().put('id', poEndorsmentList[0].Id);
        ApexPages.currentPage().getParameters().put('fromPage','ManageEndorsements');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.singleColumnLayout  =true;
        ctrl.termEndorsement =true;
        ctrl.effectiveDateDisabled =true;
        Test.startTest();
        
        ctrl.removeRow();
        ctrl.save();
        ctrl.saveAndNew();
        ctrl.getFields();
        
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_P(){
         List<Policy__c> polObj = [SELECT ID,Limit__r.Is_5X5_Coverage__c from Policy__c];
        List<Policy_Endorsement__c> PolEnd = [select id,Policy_Lawyer__c,Policy__c,Endorsement_Number__c,Policy__r.Policy_Series_Effective_Date__c,Policy__r.Effective_Date__c from Policy_Endorsement__c];
        List<Policy_Endorsement_Term__c> polEndTermList = [SELECT Id, Name, Endorsement__c FROM Policy_Endorsement_Term__c];
        List<Policy_Lawyer__c> polLawyer = [SELECT Id, Name FROM Policy_Lawyer__c];
        system.debug('polObjpolObj ' + polObj);
        system.debug('PolEndPolEnd ' + PolEnd);
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        poEnd = PolEnd[0];
        poEnd.Endorsement_Number__c='IL 106';
        poEnd.Name='IL 107 PURCHASE EXTENDED REPORTING ENDORSEMENT';
        poEnd.Coverage_Term__c='1 Year';
        poEnd.Override_Rating__c=false;
        //poEnd.Override_5_5__c = 100;
       // poEnd.Event_Status__c = 'Complete';
        poEnd.Endorsement_Effective_Date__c = date.today().addDays(10);
        	poEnd.Policy_Lawyer__c = polLawyer[0].Id;
        
        
        PageReference PageRef = Page.EndorsementEditPage;
        test.setCurrentPageReference(pageRef);
        PageRef.getParameters().put('id',poEnd.Id);
        PageRef.getParameters().put('manageIndex','0');
        
        system.debug('PolEndPolEnd256 ' + poEnd);
        
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 107 PURCHASE EXTENDED REPORTING ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.rowIdx=0;
        ctrl.termList = polEndTermList;
        ctrl.has106=true;
        ctrl.policyEndorsement = PolEnd[0];
        ctrl.save();
        ctrl.saveAndNew();
        ctrl.canRemoved=true;
        ctrl.manageIndex=0;
        ctrl.premiumCalculator();
        ctrl.getLawyersList();
        ctrl.addRow();
        ctrl.removeRow();
        Test.stopTest();
    }
    
       @isTest
    static void getFields_Test_P_1(){
         List<Policy__c> polObj = [SELECT ID,Limit__r.Is_5X5_Coverage__c from Policy__c];
        List<Policy_Endorsement__c> PolEnd = [select id,Policy_Lawyer__c,Policy__c,Endorsement_Number__c from Policy_Endorsement__c];
        List<Policy_Endorsement_Term__c> polEndTermList = [SELECT Id, Name, Endorsement__c FROM Policy_Endorsement_Term__c];
        List<Policy_Lawyer__c> polLawyer = [SELECT Id, Name FROM Policy_Lawyer__c];
        system.debug('polObjpolObj ' + polObj);
        system.debug('PolEndPolEnd ' + PolEnd);
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        poEnd = PolEnd[0];
        poEnd.Endorsement_Number__c='IL 106';
        poEnd.Name='IL 107 PURCHASE EXTENDED REPORTING ENDORSEMENT';
        poEnd.Coverage_Term__c='3 Years';
        poEnd.Override_Rating__c=false;
        //poEnd.Override_5_5__c = 100;
       // poEnd.Event_Status__c = 'Complete';
        poEnd.Endorsement_Effective_Date__c = date.today().addDays(10);
        	poEnd.Policy_Lawyer__c = polLawyer[0].Id;
        
        
        PageReference PageRef = Page.EndorsementEditPage;
        test.setCurrentPageReference(pageRef);
        PageRef.getParameters().put('id',poEnd.Id);
        PageRef.getParameters().put('manageIndex','0');
        
        system.debug('PolEndPolEnd256 ' + poEnd);
        
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 107 PURCHASE EXTENDED REPORTING ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        
        ctrl.premiumCalculator();
       
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_P_2(){
         List<Policy__c> polObj = [SELECT ID,Limit__r.Is_5X5_Coverage__c from Policy__c];
        List<Policy_Endorsement__c> PolEnd = [select id,Policy_Lawyer__c,Policy__c,Endorsement_Number__c from Policy_Endorsement__c];
        List<Policy_Endorsement_Term__c> polEndTermList = [SELECT Id, Name, Endorsement__c FROM Policy_Endorsement_Term__c];
        List<Policy_Lawyer__c> polLawyer = [SELECT Id, Name FROM Policy_Lawyer__c];
        system.debug('polObjpolObj ' + polObj);
        system.debug('PolEndPolEnd ' + PolEnd);
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        poEnd = PolEnd[0];
        poEnd.Endorsement_Number__c='IL 106';
        poEnd.Name='IL 107 PURCHASE EXTENDED REPORTING ENDORSEMENT';
        poEnd.Coverage_Term__c='6 Years';
        poEnd.Override_Rating__c=false;
        //poEnd.Override_5_5__c = 100;
       // poEnd.Event_Status__c = 'Complete';
        poEnd.Endorsement_Effective_Date__c = date.today().addDays(10);
        	poEnd.Policy_Lawyer__c = polLawyer[0].Id;
        
        
        PageReference PageRef = Page.EndorsementEditPage;
        test.setCurrentPageReference(pageRef);
        PageRef.getParameters().put('id',poEnd.Id);
        PageRef.getParameters().put('manageIndex','0');
        
        system.debug('PolEndPolEnd256 ' + poEnd);
        
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 107 PURCHASE EXTENDED REPORTING ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        
        ctrl.premiumCalculator();
       
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_P_3(){
         List<Policy__c> polObj = [SELECT ID,Limit__r.Is_5X5_Coverage__c from Policy__c];
        List<Policy_Endorsement__c> PolEnd = [select id,Policy_Lawyer__c,Policy__c,Endorsement_Number__c from Policy_Endorsement__c];
        List<Policy_Endorsement_Term__c> polEndTermList = [SELECT Id, Name, Endorsement__c FROM Policy_Endorsement_Term__c];
        List<Policy_Lawyer__c> polLawyer = [SELECT Id, Name FROM Policy_Lawyer__c];
        system.debug('polObjpolObj ' + polObj);
        system.debug('PolEndPolEnd ' + PolEnd);
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        poEnd = PolEnd[0];
        poEnd.Endorsement_Number__c='IL 106';
        poEnd.Name='IL 107 PURCHASE EXTENDED REPORTING ENDORSEMENT';
        poEnd.Coverage_Term__c='Unlimited';
        poEnd.Override_Rating__c=false;
        //poEnd.Override_5_5__c = 100;
       // poEnd.Event_Status__c = 'Complete';
        poEnd.Endorsement_Effective_Date__c = date.today().addDays(10);
        	poEnd.Policy_Lawyer__c = polLawyer[0].Id;
        
        
        PageReference PageRef = Page.EndorsementEditPage;
        test.setCurrentPageReference(pageRef);
        PageRef.getParameters().put('id',poEnd.Id);
        PageRef.getParameters().put('manageIndex','0');
        
        system.debug('PolEndPolEnd256 ' + poEnd);
        
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 107 PURCHASE EXTENDED REPORTING ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        
        ctrl.premiumCalculator();
       
        Test.stopTest();
    }
   
         @isTest
    static void getFields_Test_P2(){
        
        List<Policy_Endorsement__c> PolEnd = [select id from Policy_Endorsement__c];
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        poEnd = PolEnd[0];
        poEnd.Endorsement_Effective_Date__c = date.today().addDays(10);
        poEnd.Name='IL 190 Cancellation of Coverage';
        poEnd.Coverage_Term__c='Unlimited';
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 190 Cancellation of Coverage').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.premiumCalculator();
        Test.stopTest();
    }
        
    @isTest
    static void getFields_Test_0(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 107B U.S. Active Duty Military Service Extended Reporting Period Election').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_1(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 107C Unlimited Death or Disability Extended Reporting Period Election').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_2(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 107D Unlimited Retirement Extended Reporting Period Election Endorsement').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    
    @isTest
    static void getFields_Test_3(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 120 Limit of Liability Endorsement').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_4(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 151 Name Change Endorsement').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_5(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 151A Address Change Endorsement').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_6(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 190 Cancellation of Coverage').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_7(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 191 Reinstatement Notice').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_8(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 101A SPECIFIC ATTORNEY(S) EXCLUSION ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    
    @isTest
    static void getFields_Test_9(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 101B SPECIFIC ATTORNEY(S) EXCLUSION ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_10(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 104 SPECIFIC ENTITY EXCLUSIONS ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_11(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 106 AMENDMENT OF EXTENDED REPORTING PERIOD').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_12(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 110 SECURITIES, BOND AND LIMITED PARTNERSHIP EXCLUSION').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_13(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 130 LIMIT OF LIABILITY ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_14(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 150 POLICY ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_15(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 160 CONTRACTUAL LIABILITY EXCLUSION ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_16(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 162 FDCPA ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_17(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 169 SECURITIES EXCLUSION ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_18(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 174A CLAIM AND DISCIPLINARY PROCEEDINGS EXCLUSION ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_19(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 175 PREDECESSOR FIRM ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_20(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 176A ENTITY ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_21(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 177 DISCIPLINARY PROCEEDINGS COVERAGE ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_22(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 200 PAST ACTS COVERAGE BUYBACK ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_23(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 210 SEPARATELY OWNED TITLE AGENCY').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    
    @isTest
    static void getFields_Test_24(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 230 ANNUAL AGGREGATE DEDUCTIBLE ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_25(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 232 ANNUAL AGGREGATE DEDUCTIBLE').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_26(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 234 LOSS ONLY DEDUCTIBLE ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_27(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 260 Past Acts Coverage Endorsement').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_28(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 301 Amendment of EXTENDED REPORTING PERIOD Options Endorsement').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_29(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 261 Claim Expenses Outside the Policy Limits Endorsement').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    @isTest
    static void getFields_Test_30(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 302 AMENDMENT OF EXTENDED REPORTING PERIOD OPTIONS ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }
    
    /**
    @isTest
    static void getFields_Test_31(){
        
        Test.startTest();
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        Account acc = new Account(Name='testing31');
        insert acc;
        Policy__c pol = new Policy__c(Account__c=acc.id,Name='test31',Effective_Date__c=System.Today(),Expiration_Date__c=System.Today().addDays(20));
        ApexPages.currentPage().getParameters().put('RecordType',Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 107 PURCHASE EXTENDED REPORTING ENDORSEMENT').getRecordTypeId());
        ApexPages.StandardController sc = new ApexPages.StandardController(poEnd);
        EndorsementEditVFCtrl ctrl = new EndorsementEditVFCtrl(sc);
        ctrl.getFields();
        Test.stopTest();
    }**/
    
}