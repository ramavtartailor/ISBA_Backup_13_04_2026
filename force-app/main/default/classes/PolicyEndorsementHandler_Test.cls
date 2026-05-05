@isTest 
private class PolicyEndorsementHandler_Test {
    
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
        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoveragefactor(MasterFactorCoverage.Id);
        insert FactorCoverage;
        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor1','Deductible');
        insert mas12;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        Insert DedFac; 
        
        Policy__c pol                 = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Application');
        pol.Base_Amount__c = 100;
        pol.Firm_Mod__c = 2;
        pol.Limit__c = FactorCoverage.Id;
        pol.Deductible_ID__c = DedFac.id;
        pol.Premium__c =500;
        
        insert pol;
        
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(pol.Account__C, con.Id);
        insert junc;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(pol.Account__c,pol.Id,junc.Id);
        law.Active__c = true;
        insert law;
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Endorsement_Version__c endorseVersion2 = TestDataFactory.createEndorsementVersion(endorse.Id);
        endorseVersion2.Endorsement_Version_Number__c='2';
        insert endorseVersion2;
        
    }
    
    @isTest static void testMethod1pending() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        Endorsement__c endorse191 = new Endorsement__c(Endorsement_Sub_Type__c='IL 191',Type__c='Functional',Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                       Description__c='Test desc');
        insert endorse191;
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id,Premium__c=10);
        insert poicyEndorse;
        
        poicyEndorse.Endorsement_Effective_Date__c = System.today().addDays(1);
        update poicyEndorse;
        
        delete poicyEndorse;

        Test.stopTest();
        
    }
    
    @isTest static void testMethod1() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        Endorsement__c endorse191 = new Endorsement__c(Endorsement_Sub_Type__c='IL 191',Type__c='Functional',Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                       Description__c='Test desc');
        insert endorse191;
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id,Premium__c=10);
        insert poicyEndorse;
        
        poicyEndorse.Event_Status__c = 'Complete';
        //poicyEndorse.Endorsement_Effective_Date__c = System.today().addDays(1);
        update poicyEndorse;
        
        delete poicyEndorse;
        
        Test.stopTest();
        
    }
    
    
    @isTest static void testMethod2pending() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        
        Endorsement__c endorse152 = new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                       Description__c='Test desc',Endorsement_Sub_Type__c='IL 152',Type__c='Functional');
        insert endorse152;
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id);
        insert poicyEndorse;
        
        poicyEndorse.Endorsement_Effective_Date__c = System.today().addDays(1);
        update poicyEndorse;
        
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod3() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        List<AccountContactJunction__c> lawyerList = [SELECT Id FROM AccountContactJunction__c WHERE Account__c=: accList[0].Id LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        
        Endorsement__c endorse152 = new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                       Description__c='Test desc',Endorsement_Sub_Type__c='IL 152',Type__c='Functional');
        insert endorse152;
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id,Premium__c=10,
                                                                       Lawyer__c=lawyerList[0].Id);
        insert poicyEndorse;
        
        poicyEndorse.Event_Status__c= 'Complete';
       // update poicyEndorse;
        
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod3pending() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        
        Endorsement__c endorse152 = new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                       Description__c='Test desc',Endorsement_Sub_Type__c='IL 152',Type__c='Functional');
        insert endorse152;
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id,Premium__c=10);
        insert poicyEndorse;
        
        poicyEndorse.Endorsement_Effective_Date__c = System.today().addDays(1);
        update poicyEndorse;
        
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod4() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        
        Endorsement__c endorse151 = new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                       Description__c='Test desc',Endorsement_Sub_Type__c='IL 151',Type__c='Functional');
        insert endorse151;
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id,Premium__c=10);
        insert poicyEndorse;
        
        poicyEndorse.Event_Status__c = 'Complete';
        update poicyEndorse;
        
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod4pending() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        
        Endorsement__c endorse151 = new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                       Description__c='Test desc',Endorsement_Sub_Type__c='IL 151',Type__c='Functional');
        insert endorse151;
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id,Premium__c=10);
        insert poicyEndorse;
        
        poicyEndorse.Endorsement_Effective_Date__c = System.today().addDays(1);
        update poicyEndorse;
        
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod5() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        
        Endorsement__c endorseChangeLawyer = new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                                Description__c='Test desc',Endorsement_Sub_Type__c='Change Lawyer',Type__c='Functional');
        insert endorseChangeLawyer;
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id);
        insert poicyEndorse;
        
        poicyEndorse.Event_Status__c = 'Complete';
        update poicyEndorse;
        
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod5pending() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        
        Endorsement__c endorseChangeLawyer = new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                                Description__c='Test desc',Endorsement_Sub_Type__c='Change Lawyer',Type__c='Functional');
        insert endorseChangeLawyer;
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id);
        insert poicyEndorse;
        
        poicyEndorse.Endorsement_Effective_Date__c = System.today().addDays(1);
        update poicyEndorse;
        
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod6() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        List<AccountContactJunction__c> lawyerList = [SELECT Id FROM AccountContactJunction__c WHERE Account__c=: accList[0].Id LIMIT 1];
        
        
        Test.startTest();
        
        Endorsement__c endorse153 = new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                       Description__c='Test desc',Endorsement_Sub_Type__c='IL 153',Type__c='Functional');
        insert endorse153;
        
        Attachment attach = new Attachment(Name='Unit Test Attachment',Body=Blob.valueOf('Test'),ParentId=policyList[0].Id);
        insert attach;
        
      /*  Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Policy Endorsement153_Del', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),Premium__c=10,
                                                                       Attachment_Record_Id__c=attach.Id);
        insert poicyEndorse;
        
        poicyEndorse.Event_Status__c = 'Complete';
        update poicyEndorse;
        
        delete poicyEndorse; */
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod6pending() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        
        Endorsement__c endorse153 = new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                       Description__c='Test desc',Endorsement_Sub_Type__c='IL 153',Type__c='Functional');
        insert endorse153;
        
      /*  Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id,Premium__c=10);
        insert poicyEndorse;
        
        poicyEndorse.Endorsement_Effective_Date__c = System.today().addDays(1);
        update poicyEndorse; */
        
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod7() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        
        Endorsement__c endorse107 = new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                       Description__c='Test desc',Endorsement_Sub_Type__c='IL 107',Type__c='Functional');
        insert endorse107;
        
      /*  Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id,Premium__c=10);
        insert poicyEndorse;
        
        poicyEndorse.Event_Status__c = 'Complete';
        update poicyEndorse; */
        
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod7pending() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        
        Endorsement__c endorse107 = new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                       Description__c='Test desc',Endorsement_Sub_Type__c='IL 107',Type__c='Functional');
        insert endorse107;
        
      /*  Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id,Premium__c=10);
        insert poicyEndorse;
        
        poicyEndorse.Endorsement_Effective_Date__c = System.today().addDays(1);
        update poicyEndorse; */
        
        
        Test.stopTest();
         
    }
    
    @isTest static void testMethod8() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        
        Endorsement__c endorseAdjustPremium = new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                                 Description__c='Test desc',Endorsement_Sub_Type__c='Adjust Premium',Type__c='Functional');
        insert endorseAdjustPremium;
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id,
                                                                       Primary__c=15,Premium_5_5__c=5,Premium_10_10__c=10,Premium__c=10);
        insert poicyEndorse;
        
        poicyEndorse.Event_Status__c = 'Complete';
        update poicyEndorse;
        
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod8pending() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        
        Endorsement__c endorseAdjustPremium = new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                                 Description__c='Test desc',Endorsement_Sub_Type__c='Adjust Premium',Type__c='Functional');
        insert endorseAdjustPremium;
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id,
                                                                       Primary__c=15,Premium_5_5__c=5,Premium_10_10__c=10,Premium__c=10);
        insert poicyEndorse;
        
        poicyEndorse.Endorsement_Effective_Date__c = System.today().addDays(1);
        update poicyEndorse;
        
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod9() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        
        Endorsement__c endorse190= new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                      Description__c='Test desc',Endorsement_Sub_Type__c='IL 190',Type__c='Functional');
        insert endorse190;
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id,
                                                                       Premium__c=100,Term__c=1,Refund_Amount__c=10);
        insert poicyEndorse;
        
        poicyEndorse.Event_Status__c = 'Complete';
        update poicyEndorse;
        
        PolicyEndorsementGateway.completeCancelPolicy(new List<Policy_Endorsement__c>{poicyEndorse});
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod9pending() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        
        Endorsement__c endorse190= new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                      Description__c='Test desc',Endorsement_Sub_Type__c='IL 190',Type__c='Functional');
        insert endorse190;
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id,
                                                                       Premium__c=100,Term__c=1,Refund_Amount__c=10);
        insert poicyEndorse;
        
        poicyEndorse.Endorsement_Effective_Date__c = System.today().addDays(1);
        update poicyEndorse;
        
        PolicyEndorsementGateway.completeCancelPolicy(new List<Policy_Endorsement__c>{poicyEndorse});
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod10() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        Id devRecordEndorseTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='CP_Cancel_Policy_Transaction' LIMIT 1].Id;
        
        Endorsement__c endorse191= new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordEndorseTypeId,
                                                      Description__c='Test desc',Endorsement_Sub_Type__c='IL 191',Type__c='Functional');
        insert endorse191;
        
        Endorsement_Version__c endorseVersion1 = new Endorsement_Version__c(Master_Endorsement__c=endorse191.Id,Endorsement_Version_Number__c='1',
                                                                            Effective_From__c=System.today());
        insert endorseVersion1;
        
        
        Endorsement_Version__c endorseVersion2 = new Endorsement_Version__c(Master_Endorsement__c=endorse191.Id,Endorsement_Version_Number__c='2',
                                                                            Effective_From__c=System.today());
        insert endorseVersion2;
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordEndorseTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id,Premium__c=10);
        insert poicyEndorse;
        
        poicyEndorse.Event_Status__c = 'Complete';
        update poicyEndorse;
        
        
        Test.stopTest();
        
    }
    @isTest static void testMethodNew10() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        Id devRecordEndorseTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='CP_Cancel_Policy_Transaction' LIMIT 1].Id;
        
        Endorsement__c endorse191= new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordEndorseTypeId,
                                                      Description__c='Test desc',Endorsement_Sub_Type__c='IL 152',Type__c='Functional');
        insert endorse191;
        
        Endorsement_Version__c endorseVersion1 = new Endorsement_Version__c(Master_Endorsement__c=endorse191.Id,Endorsement_Version_Number__c='1',
                                                                            Effective_From__c=System.today());
        insert endorseVersion1;
        
        
        Endorsement_Version__c endorseVersion2 = new Endorsement_Version__c(Master_Endorsement__c=endorse191.Id,Endorsement_Version_Number__c='2',
                                                                            Effective_From__c=System.today());
        insert endorseVersion2;
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordEndorseTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id,Premium__c=10,
                                                                       Step_Override_Value__c=0,Step_Override__c = true);
        insert poicyEndorse;
        
        poicyEndorse.Event_Status__c = 'Pending';
        poicyEndorse.Step_Override_Value__c=1;
        update poicyEndorse;
        poicyEndorse.Step_Override_Value__c=2;
        update poicyEndorse;
        poicyEndorse.Step_Override_Value__c=3;
        update poicyEndorse;        
        
        
        Test.stopTest();
        
    }
    @isTest static void testMethodNew11() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        Id devRecordEndorseTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='CP_Cancel_Policy_Transaction' LIMIT 1].Id;
        
        Endorsement__c endorse191= new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordEndorseTypeId,
                                                      Description__c='Test desc',Endorsement_Sub_Type__c='IL 152',Type__c='Functional');
        insert endorse191;
        
        Endorsement_Version__c endorseVersion1 = new Endorsement_Version__c(Master_Endorsement__c=endorse191.Id,Endorsement_Version_Number__c='1',
                                                                            Effective_From__c=System.today());
        insert endorseVersion1;
        
        
        Endorsement_Version__c endorseVersion2 = new Endorsement_Version__c(Master_Endorsement__c=endorse191.Id,Endorsement_Version_Number__c='2',
                                                                            Effective_From__c=System.today());
        insert endorseVersion2;
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordEndorseTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id,Premium__c=10,
                                                                       Step_Override_Value__c=0,Step_Override__c = true);
        insert poicyEndorse;
        
        poicyEndorse.Event_Status__c = 'Pending';
        update poicyEndorse;            
        poicyEndorse.Step_Override_Value__c=4;
        update poicyEndorse;
        poicyEndorse.Step_Override_Value__c=5;
        update poicyEndorse;
        poicyEndorse.Step_Override_Value__c=6;
        update poicyEndorse;
        poicyEndorse.Step_Override_Value__c=7;
        update poicyEndorse;
        
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod10pending() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        Id devRecordEndorseTypeId = [SELECT Id FROM RecordType WHERE DeveloperName='CP_Cancel_Policy_Transaction' LIMIT 1].Id;
        
        Endorsement__c endorse191= new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordEndorseTypeId,
                                                      Description__c='Test desc',Endorsement_Sub_Type__c='IL 191',Type__c='Functional');
        insert endorse191;
        
        Endorsement_Version__c endorseVersion1 = new Endorsement_Version__c(Master_Endorsement__c=endorse191.Id,Endorsement_Version_Number__c='1',
                                                                            Effective_From__c=System.today());
        insert endorseVersion1;
        
        
        Endorsement_Version__c endorseVersion2 = new Endorsement_Version__c(Master_Endorsement__c=endorse191.Id,Endorsement_Version_Number__c='2',
                                                                            Effective_From__c=System.today());
        insert endorseVersion2;
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordEndorseTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id,Premium__c=10);
        insert poicyEndorse;
        
        poicyEndorse.Event_Status__c = 'Complete';
        update poicyEndorse;
        
        Test.stopTest();
        
    }
    
    
    @isTest static void testMethod11pending() {
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<Policy__c> policyList = [SELECT Id,Effective_Date__c,Base_Amount__c,Firm_Mod__c,Limit__c,Deductible_ID__c,Premium__c FROM Policy__c LIMIT 1];
        List<Master_Factor__c> masterFactorList = [SELECT Id FROM Master_Factor__c WHERE Factor_Type__c='Coverage' LIMIT 1];
        
        ILF_Coverage_Factor__c ilfCoverageLowest = new ILF_Coverage_Factor__c(Master_Factor__c=masterFactorList[0].Id,Factor_Value__c=1,
                                                                              Name='500,000 / 500,000',Full_Coverage__c=500000,Coverage_Max_Per_Claim__c=500000);
        insert ilfCoverageLowest;
        
        Test.startTest();
        
        Endorsement__c endorse120 = new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                       Description__c='Test desc',Endorsement_Sub_Type__c='IL 120',Type__c='Functional');
        insert endorse120;
        
      /*  Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =accList[0].Id ,Name='Test Policy Endorsement', Policy__c =policyList[0].Id,
                                                                       RecordTypeId=devRecordTypeId,Endorsement_Effective_Date__c = System.today(),Rate_At__c=0,
                                                                       Prior_Act_Date__c = System.today(),New_Limits__c=ilfCoverageLowest.Id,Premium__c=10);
        insert poicyEndorse; 
        
        poicyEndorse.Endorsement_Effective_Date__c = System.today().addDays(1);
        update poicyEndorse; */

        
        Test.stopTest();
        
    }
}