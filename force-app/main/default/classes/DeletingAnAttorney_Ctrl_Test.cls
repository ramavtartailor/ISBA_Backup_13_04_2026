@isTest
public class DeletingAnAttorney_Ctrl_Test {
    
    @testSetup
    static void testData(){
        
        // Insert Account
        Account acc                   = TestDataFactory.createAccounts('Bucket Account');
        insert acc;
        
        // Insert Contact
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        // Insert AccountContactJunction
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        // Insert Opportunity
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        // Insert Master Factor
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        // Insert County
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        // Insert Geo Factor
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        // Insert Master Factor       
        Master_Factor__c masterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert masterFactor1;
        
        
        // Insert Base Factor
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(masterFactor1.Id);
        insert baseFactor;
        
        Map<String,String> mapRecordTypes = new Map<String,String>();
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        // Insert Master Fator
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        // Insert ILF Coverage Factor
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoverageFactor(MasterFactorCoverage.Id);
        FactorCoverage.Percentage_5X5_Step_0__c =3;
        FactorCoverage.Percentage_5X5_Step_1__c=4;
        FactorCoverage.Percentage_5X5_Step_2__c=5;
        FactorCoverage.Percentage_5X5_Step_3__c=6;
        FactorCoverage.Percentage_5X5_Step_4__c=8;
        FactorCoverage.Premium_Rate_5X5__c = 33;
        FactorCoverage.Is_5X5_Coverage__c = true;        
        insert FactorCoverage;
        
        // Insert Master Factor
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor','Deductible');
        insert mas12;
        
        // Insert Deductible Factor
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        Insert DedFac; 
        
        // Insert Master Factor
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        // Insert Deductible Factor
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        // Insert Policy
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = FactorCoverage.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy.Effective_Date__c = system.today().addDays(10);
        acctivePolicy.Expiration_Date__c = system.today().addDays(10);
        insert acctivePolicy;
        
        // Insert Endorsement
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        insert endorse;
        
        // Insert Endorsement Version
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        // Insert Endorsement version 2
        Endorsement_Version__c endorseVersion2 = TestDataFactory.createEndorsementVersion(endorse.Id);
        endorseVersion2.Endorsement_Version_Number__c='2';
        insert endorseVersion2;
        
        // Insert AOP_Factor__c 
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        // Insert Policy_AOP__c
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,acctivePolicy.id);
        insert aop;
        
         // Insert Policy Lawyer
        Policy_Lawyer__c polLawyer = TestDataFactory.createPolicyLawyer(acc.Id,acctivePolicy.Id,acj.Id);
        polLawyer.Rate_At__c=0;
        insert polLawyer;
        
        // Insert Policy Endorsement
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        objPolEndorse.Override_Rating__c = false;
        objPolEndorse.Step__c = null;
        objPolEndorse.Step_Override__c = true;
        objPolEndorse.Step_Override_Value__c = 0;
        objPolEndorse.Policy_Lawyer__c = polLawyer.id;
        objPolEndorse.Effective_Date__c =  date.today();
        objPolEndorse.Endorsement_Effective_Date__c = System.today() +  10;
        insert objPolEndorse;
        
         
    }
    
    @isTest
    static void premiumCalculator_Test(){
        
        Test.startTest();
         List<Policy__c> acctivePolicy = [Select id,RecordType.name, Name, Account__c,Expiration_Date__c,Effective_Date__c,Limit__c 
                                         From Policy__c Limit 1];
        
        List<Policy_Endorsement__c> objPolEndorse = [Select id,Lawyer__c,RecordType.Name,Override_Rating__c,Step_Override_Value__c, Name ,
                                                     Policy__c,Effective_Date__c,Endorsement_Effective_Date__c,Step_Override__c
                                                     From Policy_Endorsement__c Limit 1];

        List<Policy_Lawyer__c> poLawList = [Select id from Policy_Lawyer__c ];
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('policyId', acctivePolicy[0].Id);
        ApexPages.currentPage().getParameters().put('id', objPolEndorse[0].Id);
        ApexPages.currentPage().getParameters().put('name', 'Test');
        ApexPages.currentPage().getParameters().put('effectiveDate', '02/06/2010');
        ApexPages.currentPage().getParameters().put('RecordType', devRecordTypeId);
        ApexPages.currentPage().getParameters().put('fromPolicyLawyerRelatedList', 'policyLawyer');
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(poEnd);
        
        DeletingAnAttorney_Ctrl cMethod = new DeletingAnAttorney_Ctrl(stdcontroller);
        cMethod.policyEndorsement.Endorsement_Effective_Date__c = date.today();
        cMethod.policyEndorsement.Step_Override__c = true;
        cMethod.policyEndorsement.Step_Override_Value__c = 0;
        cMethod.selectedLawyer = poLawList[0].id;
        cMethod.premiumCalculator();
        cMethod.saveEndorsement();
        Test.stopTest();
    }
    
    @isTest
    static void premiumCalculator_Test_1(){
        
        Test.startTest();
         List<Policy__c> acctivePolicy = [Select id,RecordType.name, Name, Account__c,Expiration_Date__c,Effective_Date__c,Limit__c 
                                         From Policy__c Limit 1];
        
        List<Policy_Endorsement__c> objPolEndorse = [Select id,Lawyer__c,RecordType.Name,Override_Rating__c,Step_Override_Value__c, Name ,
                                                     Policy__c,Effective_Date__c,Endorsement_Effective_Date__c,Step_Override__c
                                                     From Policy_Endorsement__c Limit 1];

        List<Policy_Lawyer__c> poLawList = [Select id from Policy_Lawyer__c];
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('policyId', acctivePolicy[0].Id);
        ApexPages.currentPage().getParameters().put('id', objPolEndorse[0].Id);
        ApexPages.currentPage().getParameters().put('name', 'Test');
        ApexPages.currentPage().getParameters().put('effectiveDate', '02/06/2010');
        ApexPages.currentPage().getParameters().put('RecordType', devRecordTypeId);
        ApexPages.currentPage().getParameters().put('fromPolicyLawyerRelatedList', 'policyLawyer');
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(poEnd);
        
        DeletingAnAttorney_Ctrl cMethod = new DeletingAnAttorney_Ctrl(stdcontroller);
        cMethod.policyEndorsement.Endorsement_Effective_Date__c = date.today();
        cMethod.policyEndorsement.Step_Override__c = true;
        cMethod.policyEndorsement.Step_Override_Value__c = 1;
        cMethod.selectedLawyer = poLawList[0].id;
        cMethod.premiumCalculator();
        cMethod.saveEndorsement();
        Test.stopTest();
    }
    
    @isTest
    static void premiumCalculator_Test_2(){
        
        Test.startTest();
         List<Policy__c> acctivePolicy = [Select id,RecordType.name, Name, Account__c,Expiration_Date__c,Effective_Date__c,Limit__c 
                                         From Policy__c Limit 1];
        
        List<Policy_Endorsement__c> objPolEndorse = [Select id,Lawyer__c,RecordType.Name,Override_Rating__c,Step_Override_Value__c, Name ,
                                                     Policy__c,Effective_Date__c,Endorsement_Effective_Date__c,Step_Override__c
                                                     From Policy_Endorsement__c Limit 1];

        List<Policy_Lawyer__c> poLawList = [Select id from Policy_Lawyer__c];
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('policyId', acctivePolicy[0].Id);
        ApexPages.currentPage().getParameters().put('id', objPolEndorse[0].Id);
        ApexPages.currentPage().getParameters().put('name', 'Test');
        ApexPages.currentPage().getParameters().put('effectiveDate', '02/06/2010');
        ApexPages.currentPage().getParameters().put('RecordType', devRecordTypeId);
        ApexPages.currentPage().getParameters().put('fromPolicyLawyerRelatedList', 'policyLawyer');
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(poEnd);
        
        DeletingAnAttorney_Ctrl cMethod = new DeletingAnAttorney_Ctrl(stdcontroller);
        cMethod.policyEndorsement.Endorsement_Effective_Date__c = date.today();
        cMethod.policyEndorsement.Step_Override__c = true;
        cMethod.policyEndorsement.Step_Override_Value__c = 2;
        cMethod.selectedLawyer = poLawList[0].id;
        cMethod.premiumCalculator();
        cMethod.saveEndorsement();
        Test.stopTest();
    }
    
    @isTest
    static void premiumCalculator_Test_3(){
        
        Test.startTest();
         List<Policy__c> acctivePolicy = [Select id,RecordType.name, Name, Account__c,Expiration_Date__c,Effective_Date__c,Limit__c 
                                         From Policy__c Limit 1];
        
        List<Policy_Endorsement__c> objPolEndorse = [Select id,Lawyer__c,RecordType.Name,Override_Rating__c,Step_Override_Value__c, Name ,
                                                     Policy__c,Effective_Date__c,Endorsement_Effective_Date__c,Step_Override__c
                                                     From Policy_Endorsement__c Limit 1];

        List<Policy_Lawyer__c> poLawList = [Select id from Policy_Lawyer__c];
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('policyId', acctivePolicy[0].Id);
        ApexPages.currentPage().getParameters().put('id', objPolEndorse[0].Id);
        ApexPages.currentPage().getParameters().put('name', 'Test');
        ApexPages.currentPage().getParameters().put('effectiveDate', '02/06/2010');
        ApexPages.currentPage().getParameters().put('RecordType', devRecordTypeId);
        ApexPages.currentPage().getParameters().put('fromPolicyLawyerRelatedList', 'policyLawyer');
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(poEnd);
        
        DeletingAnAttorney_Ctrl cMethod = new DeletingAnAttorney_Ctrl(stdcontroller);
        cMethod.policyEndorsement.Endorsement_Effective_Date__c = date.today();
        cMethod.policyEndorsement.Step_Override__c = true;
        cMethod.policyEndorsement.Step_Override_Value__c = 3;
        cMethod.selectedLawyer = poLawList[0].id;
        cMethod.premiumCalculator();
        cMethod.saveEndorsement();
        Test.stopTest();
    }
    
    @isTest
    static void premiumCalculator_Test_4(){
        
        Test.startTest();
         List<Policy__c> acctivePolicy = [Select id,RecordType.name, Name, Account__c,Expiration_Date__c,Effective_Date__c,Limit__c 
                                         From Policy__c Limit 1];
        
        List<Policy_Endorsement__c> objPolEndorse = [Select id,Lawyer__c,RecordType.Name,Override_Rating__c,Step_Override_Value__c, Name ,
                                                     Policy__c,Effective_Date__c,Endorsement_Effective_Date__c,Step_Override__c
                                                     From Policy_Endorsement__c Limit 1];

        List<Policy_Lawyer__c> poLawList = [Select id from Policy_Lawyer__c];
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('policyId', acctivePolicy[0].Id);
        ApexPages.currentPage().getParameters().put('id', objPolEndorse[0].Id);
        ApexPages.currentPage().getParameters().put('name', 'Test');
        ApexPages.currentPage().getParameters().put('effectiveDate', '02/06/2010');
        ApexPages.currentPage().getParameters().put('RecordType', devRecordTypeId);
        ApexPages.currentPage().getParameters().put('fromPolicyLawyerRelatedList', 'policyLawyer');
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(poEnd);
        
        DeletingAnAttorney_Ctrl cMethod = new DeletingAnAttorney_Ctrl(stdcontroller);
        cMethod.policyEndorsement.Endorsement_Effective_Date__c = date.today();
        cMethod.policyEndorsement.Step_Override__c = true;
        cMethod.policyEndorsement.Step_Override_Value__c = 4;
        cMethod.selectedLawyer = poLawList[0].id;
        cMethod.premiumCalculator();
        cMethod.saveEndorsement();
        Test.stopTest();
    }
    
    
    @isTest
    static void premiumCalculator_Test_5(){
        
         Test.startTest();
         List<Policy__c> acctivePolicy = [Select id,RecordType.name, Name, Account__c,Expiration_Date__c,Effective_Date__c,Limit__c 
                                         From Policy__c Limit 1];
        
        List<Policy_Endorsement__c> objPolEndorse = [Select id,Lawyer__c,RecordType.Name,Override_Rating__c,Step_Override_Value__c, Name ,
                                                     Policy__c,Effective_Date__c,Endorsement_Effective_Date__c,Step_Override__c
                                                     From Policy_Endorsement__c Limit 1];

        List<Policy_Lawyer__c> poLawList = [Select id from Policy_Lawyer__c];
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('policyId', acctivePolicy[0].Id);
        ApexPages.currentPage().getParameters().put('id', objPolEndorse[0].Id);
        ApexPages.currentPage().getParameters().put('name', 'Test');
        ApexPages.currentPage().getParameters().put('effectiveDate', '02/06/2010');
        ApexPages.currentPage().getParameters().put('RecordType', devRecordTypeId);
        ApexPages.currentPage().getParameters().put('fromPolicyLawyerRelatedList', 'policyLawyer');
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(poEnd);
        
        DeletingAnAttorney_Ctrl cMethod = new DeletingAnAttorney_Ctrl(stdcontroller);
        cMethod.policyEndorsement.Endorsement_Effective_Date__c = date.today();
        cMethod.policyEndorsement.Step_Override__c = true;
        cMethod.policyEndorsement.Step_Override_Value__c = 5;
        cMethod.selectedLawyer = poLawList[0].id;
        cMethod.premiumCalculator();
        cMethod.saveEndorsement();
        Test.stopTest();
    }
    
    @isTest
    static void premiumCalculator_Test_6(){
        
        Test.startTest();
         List<Policy__c> acctivePolicy = [Select id,RecordType.name, Name, Account__c,Expiration_Date__c,Effective_Date__c,Limit__c 
                                         From Policy__c Limit 1];
        
        List<Policy_Endorsement__c> objPolEndorse = [Select id,Lawyer__c,RecordType.Name,Override_Rating__c,Step_Override_Value__c, Name ,
                                                     Policy__c,Effective_Date__c,Endorsement_Effective_Date__c,Step_Override__c
                                                     From Policy_Endorsement__c Limit 1];

        List<Policy_Lawyer__c> poLawList = [Select id from Policy_Lawyer__c];
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('policyId', acctivePolicy[0].Id);
        ApexPages.currentPage().getParameters().put('id', objPolEndorse[0].Id);
        ApexPages.currentPage().getParameters().put('name', 'Test');
        ApexPages.currentPage().getParameters().put('effectiveDate', '02/06/2010');
        ApexPages.currentPage().getParameters().put('RecordType', devRecordTypeId);
        ApexPages.currentPage().getParameters().put('fromPolicyLawyerRelatedList', 'policyLawyer');
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(poEnd);
        
        DeletingAnAttorney_Ctrl cMethod = new DeletingAnAttorney_Ctrl(stdcontroller);
        cMethod.policyEndorsement.Endorsement_Effective_Date__c = date.today();
        cMethod.policyEndorsement.Step_Override__c = true;
        cMethod.policyEndorsement.Step_Override_Value__c = 6;
        cMethod.selectedLawyer = poLawList[0].id;
        cMethod.premiumCalculator();
        cMethod.saveEndorsement();
        Test.stopTest();
    }
    
    @isTest
    static void premiumCalculator_Test_7(){
        
        Test.startTest();
         List<Policy__c> acctivePolicy = [Select id,RecordType.name, Name, Account__c,Expiration_Date__c,Effective_Date__c,Limit__c 
                                         From Policy__c Limit 1];
        
        List<Policy_Endorsement__c> objPolEndorse = [Select id,Lawyer__c,RecordType.Name,Override_Rating__c,Step_Override_Value__c, Name ,
                                                     Policy__c,Effective_Date__c,Endorsement_Effective_Date__c,Step_Override__c
                                                     From Policy_Endorsement__c Limit 1];

        List<Policy_Lawyer__c> poLawList = [Select id from Policy_Lawyer__c];
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('policyId', acctivePolicy[0].Id);
        ApexPages.currentPage().getParameters().put('id', objPolEndorse[0].Id);
        ApexPages.currentPage().getParameters().put('name', 'Test');
        ApexPages.currentPage().getParameters().put('effectiveDate', '02/06/2010');
        ApexPages.currentPage().getParameters().put('RecordType', devRecordTypeId);
        ApexPages.currentPage().getParameters().put('fromPolicyLawyerRelatedList', 'policyLawyer');
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(poEnd);
        
        DeletingAnAttorney_Ctrl cMethod = new DeletingAnAttorney_Ctrl(stdcontroller);
        cMethod.policyEndorsement.Endorsement_Effective_Date__c = date.today();
        cMethod.policyEndorsement.Step_Override__c = true;
        cMethod.policyEndorsement.Step_Override_Value__c = 7;
        cMethod.selectedLawyer = poLawList[0].id;
        cMethod.premiumCalculator();
        cMethod.saveEndorsement();
        Test.stopTest();
    }
    
    
   //////////////////
   
    @isTest
    static void premiumCalculator_Test_8(){
        Test.startTest();
        
        List<Policy__c> acctivePolicy = [Select id,RecordType.name, Name, Account__c,Expiration_Date__c,Effective_Date__c,Limit__c 
                                         From Policy__c Limit 1];
        
        List<Policy_Endorsement__c> objPolEndorse = [Select id,Lawyer__c,RecordType.Name,Override_Rating__c,Step_Override_Value__c, Name ,
                                                     Policy__c,Effective_Date__c,Endorsement_Effective_Date__c,Step_Override__c
                                                     From Policy_Endorsement__c Limit 1];

        List<Policy_Lawyer__c> poLawList = [Select id from Policy_Lawyer__c ];
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('policyId', acctivePolicy[0].Id);
        ApexPages.currentPage().getParameters().put('id', objPolEndorse[0].Id);
        ApexPages.currentPage().getParameters().put('name', 'Test');
        ApexPages.currentPage().getParameters().put('effectiveDate', '02/06/2010');
        ApexPages.currentPage().getParameters().put('RecordType', devRecordTypeId);
        ApexPages.currentPage().getParameters().put('fromPolicyLawyerRelatedList', 'policyLawyer');
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(poEnd);
        
        DeletingAnAttorney_Ctrl cMethod = new DeletingAnAttorney_Ctrl(stdcontroller);
        cMethod.policyEndorsement.Endorsement_Effective_Date__c = date.today();
        cMethod.policyEndorsement.Step_Override__c = false;
        cMethod.policyEndorsement.Step__c = 0;
        cMethod.selectedLawyer = poLawList[0].id;
        cMethod.premiumCalculator();
        cMethod.saveEndorsement();
        Test.stopTest();
    }
    
    @isTest
    static void premiumCalculator_Test_9(){
        
        Test.startTest();
         List<Policy__c> acctivePolicy = [Select id,RecordType.name, Name,Cancel_Date__c, Account__c,Expiration_Date__c,Effective_Date__c,Limit__c 
                                         From Policy__c Limit 1];
        
        for(Policy__c po : acctivePolicy){
            po.Effective_Date__c = date.today().addMonths(13);
            po.Cancel_Date__c = date.today().addMonths(14);
            po.Expiration_Date__c = date.today().addMonths(15);
        }
        update acctivePolicy;
        
        List<Policy_Endorsement__c> objPolEndorse = [Select id,Lawyer__c,RecordType.Name,Override_Rating__c,Step_Override_Value__c, Name ,
                                                     Policy__c,Effective_Date__c,Endorsement_Effective_Date__c,Step_Override__c
                                                     From Policy_Endorsement__c limit 1];

        List<Policy_Lawyer__c> poLawList = [Select id from Policy_Lawyer__c];
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('policyId', acctivePolicy[0].Id);
        ApexPages.currentPage().getParameters().put('id', objPolEndorse[0].Id);
        ApexPages.currentPage().getParameters().put('name', 'Test');
        ApexPages.currentPage().getParameters().put('effectiveDate', '02/06/2010');
        ApexPages.currentPage().getParameters().put('RecordType', devRecordTypeId);
        ApexPages.currentPage().getParameters().put('fromPolicyLawyerRelatedList', 'policyLawyer');
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(poEnd);
        
        DeletingAnAttorney_Ctrl cMethod = new DeletingAnAttorney_Ctrl(stdcontroller);
        cMethod.policyEndorsement.Endorsement_Effective_Date__c = date.today();
        cMethod.policyEndorsement.Step_Override__c = false;
        cMethod.policyEndorsement.Step__c = 1;
        cMethod.selectedLawyer = poLawList[0].id;
        cMethod.premiumCalculator();
        cMethod.saveEndorsement();
        
        Test.stopTest();
    }
    
    @isTest
    static void premiumCalculator_Test_10(){
        
        Test.startTest();
         List<Policy__c> acctivePolicy = [Select id,RecordType.name, Name,Cancel_Date__c, Account__c,Expiration_Date__c,Effective_Date__c,Limit__c 
                                         From Policy__c Limit 1];
        
        for(Policy__c po : acctivePolicy){
            po.Effective_Date__c = date.today().addMonths(26);
            po.Cancel_Date__c = date.today().addMonths(28);
            po.Expiration_Date__c = date.today().addMonths(30);
        }
        update acctivePolicy;
        
        List<Policy_Endorsement__c> objPolEndorse = [Select id,Lawyer__c,RecordType.Name,Override_Rating__c,Step_Override_Value__c, Name ,
                                                     Policy__c,Effective_Date__c,Endorsement_Effective_Date__c,Step_Override__c
                                                     From Policy_Endorsement__c limit 1];

        List<Policy_Lawyer__c> poLawList = [Select id from Policy_Lawyer__c];
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('policyId', acctivePolicy[0].Id);
        ApexPages.currentPage().getParameters().put('id', objPolEndorse[0].Id);
        ApexPages.currentPage().getParameters().put('name', 'Test');
        ApexPages.currentPage().getParameters().put('effectiveDate', '02/06/2010');
        ApexPages.currentPage().getParameters().put('RecordType', devRecordTypeId);
        ApexPages.currentPage().getParameters().put('fromPolicyLawyerRelatedList', 'policyLawyer');
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(poEnd);
        
        DeletingAnAttorney_Ctrl cMethod = new DeletingAnAttorney_Ctrl(stdcontroller);
        cMethod.policyEndorsement.Endorsement_Effective_Date__c = date.today();
        cMethod.policyEndorsement.Step_Override__c = false;
        cMethod.policyEndorsement.Step__c = 2;
        cMethod.selectedLawyer = poLawList[0].id;
        cMethod.premiumCalculator();
        cMethod.saveEndorsement();
        
        Test.stopTest();
    }
    
    @isTest
    static void premiumCalculator_Test_11(){
        
        Test.startTest();
         List<Policy__c> acctivePolicy = [Select id,RecordType.name, Name,Cancel_Date__c, Account__c,Expiration_Date__c,Effective_Date__c,Limit__c 
                                         From Policy__c Limit 1];
        
        for(Policy__c po : acctivePolicy){
            po.Effective_Date__c = date.today().addMonths(27);
            po.Cancel_Date__c = date.today().addMonths(29);
            po.Expiration_Date__c = date.today().addMonths(30);
        }
        update acctivePolicy;
        
        List<Policy_Endorsement__c> objPolEndorse = [Select id,Lawyer__c,RecordType.Name,Override_Rating__c,Step_Override_Value__c, Name ,
                                                     Policy__c,Effective_Date__c,Endorsement_Effective_Date__c,Step_Override__c
                                                     From Policy_Endorsement__c limit 1];

        List<Policy_Lawyer__c> poLawList = [Select id from Policy_Lawyer__c];
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('policyId', acctivePolicy[0].Id);
        ApexPages.currentPage().getParameters().put('id', objPolEndorse[0].Id);
        ApexPages.currentPage().getParameters().put('name', 'Test');
        ApexPages.currentPage().getParameters().put('effectiveDate', '02/06/2010');
        ApexPages.currentPage().getParameters().put('RecordType', devRecordTypeId);
        ApexPages.currentPage().getParameters().put('fromPolicyLawyerRelatedList', 'policyLawyer');
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(poEnd);
        
        DeletingAnAttorney_Ctrl cMethod = new DeletingAnAttorney_Ctrl(stdcontroller);
        cMethod.policyEndorsement.Endorsement_Effective_Date__c = date.today();
        cMethod.policyEndorsement.Step_Override__c = false;
        cMethod.policyEndorsement.Step__c = 3;
        cMethod.selectedLawyer = poLawList[0].id;
        cMethod.premiumCalculator();
        cMethod.saveEndorsement();
        
        Test.stopTest();
    }
    
    @isTest
    static void premiumCalculator_Test_12(){
        
        Test.startTest();
         List<Policy__c> acctivePolicy = [Select id,RecordType.name, Name,Cancel_Date__c, Account__c,Expiration_Date__c,Effective_Date__c,Limit__c 
                                         From Policy__c Limit 1];
        
        for(Policy__c po : acctivePolicy){
            po.Effective_Date__c = date.today().addMonths(52);
            po.Cancel_Date__c = date.today().addMonths(56);
            po.Expiration_Date__c = date.today().addMonths(60);
        }
        update acctivePolicy;
        
        List<Policy_Endorsement__c> objPolEndorse = [Select id,Lawyer__c,RecordType.Name,Override_Rating__c,Step_Override_Value__c, Name ,
                                                     Policy__c,Effective_Date__c,Endorsement_Effective_Date__c,Step_Override__c
                                                     From Policy_Endorsement__c limit 1];

        List<Policy_Lawyer__c> poLawList = [Select id from Policy_Lawyer__c];
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('policyId', acctivePolicy[0].Id);
        ApexPages.currentPage().getParameters().put('id', objPolEndorse[0].Id);
        ApexPages.currentPage().getParameters().put('name', 'Test');
        ApexPages.currentPage().getParameters().put('effectiveDate', '02/06/2010');
        ApexPages.currentPage().getParameters().put('RecordType', devRecordTypeId);
        ApexPages.currentPage().getParameters().put('fromPolicyLawyerRelatedList', 'policyLawyer');
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(poEnd);
        
        DeletingAnAttorney_Ctrl cMethod = new DeletingAnAttorney_Ctrl(stdcontroller);
        cMethod.policyEndorsement.Endorsement_Effective_Date__c = date.today();
        cMethod.policyEndorsement.Step_Override__c = false;
        cMethod.policyEndorsement.Step__c = 4;
        cMethod.selectedLawyer = poLawList[0].id;
        cMethod.premiumCalculator();
        cMethod.saveEndorsement();
        
        Test.stopTest();
    }
    
    
    @isTest
    static void premiumCalculator_Test_13(){
        
        Test.startTest();
         List<Policy__c> acctivePolicy = [Select id,RecordType.name, Name,Cancel_Date__c, Account__c,Expiration_Date__c,Effective_Date__c,Limit__c 
                                         From Policy__c Limit 1];
        
        for(Policy__c po : acctivePolicy){
            po.Effective_Date__c = date.today().addMonths(65);
            po.Cancel_Date__c = date.today().addMonths(70);
            po.Expiration_Date__c = date.today().addMonths(75);
        }
        update acctivePolicy;
        
        List<Policy_Endorsement__c> objPolEndorse = [Select id,Lawyer__c,RecordType.Name,Override_Rating__c,Step_Override_Value__c, Name ,
                                                     Policy__c,Effective_Date__c,Endorsement_Effective_Date__c,Step_Override__c
                                                     From Policy_Endorsement__c limit 1];

        List<Policy_Lawyer__c> poLawList = [Select id from Policy_Lawyer__c];
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('policyId', acctivePolicy[0].Id);
        ApexPages.currentPage().getParameters().put('id', objPolEndorse[0].Id);
        ApexPages.currentPage().getParameters().put('name', 'Test');
        ApexPages.currentPage().getParameters().put('effectiveDate', '02/06/2010');
        ApexPages.currentPage().getParameters().put('RecordType', devRecordTypeId);
        ApexPages.currentPage().getParameters().put('fromPolicyLawyerRelatedList', 'policyLawyer');
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(poEnd);
        
        DeletingAnAttorney_Ctrl cMethod = new DeletingAnAttorney_Ctrl(stdcontroller);
        cMethod.fromPage='ManageEndorsements';
        cMethod.canRemoved=true;
        cMethod.manageIndex=0;
        cMethod.policyEndorsement.Endorsement_Effective_Date__c = date.today();
        cMethod.policyEndorsement.Step_Override__c = false;
        cMethod.policyEndorsement.Step__c = 5;
        cMethod.selectedLawyer = poLawList[0].id;
        cMethod.premiumCalculator();
        cMethod.saveEndorsement();
        
        Test.stopTest();
    }
    
    @isTest
    static void premiumCalculator_Test_14(){
        
        Test.startTest();
         List<Policy__c> acctivePolicy = [Select id,RecordType.name, Name,Cancel_Date__c, Account__c,Expiration_Date__c,Effective_Date__c,Limit__c 
                                         From Policy__c Limit 1];
        
        for(Policy__c po : acctivePolicy){
            po.Effective_Date__c = date.today().addMonths(78);
            po.Cancel_Date__c = date.today().addMonths(98);
            po.Expiration_Date__c = date.today().addMonths(105);
        }
        update acctivePolicy;
        
        List<Policy_Endorsement__c> objPolEndorse = [Select id,Lawyer__c,RecordType.Name,Override_Rating__c,Step_Override_Value__c, Name ,
                                                     Policy__c,Effective_Date__c,Endorsement_Effective_Date__c,Step_Override__c
                                                     From Policy_Endorsement__c limit 1];

        List<Policy_Lawyer__c> poLawList = [Select id from Policy_Lawyer__c];
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('policyId', acctivePolicy[0].Id);
        ApexPages.currentPage().getParameters().put('id', objPolEndorse[0].Id);
        ApexPages.currentPage().getParameters().put('name', 'Test');
        ApexPages.currentPage().getParameters().put('effectiveDate', '02/06/2010');
        ApexPages.currentPage().getParameters().put('RecordType', devRecordTypeId);
        ApexPages.currentPage().getParameters().put('fromPolicyLawyerRelatedList', 'policyLawyer');
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(poEnd);
        
        DeletingAnAttorney_Ctrl cMethod = new DeletingAnAttorney_Ctrl(stdcontroller);
        cMethod.policyEndorsement.Endorsement_Effective_Date__c = date.today();
        cMethod.policyEndorsement.Step_Override__c = false;
        cMethod.policyEndorsement.Step__c = 6;
        cMethod.selectedLawyer = poLawList[0].id;
        cMethod.premiumCalculator();
        cMethod.saveEndorsement();
        
        Test.stopTest();
    }
    
    @isTest
    static void premiumCalculator_Test_15(){
        
        Test.startTest();
         List<Policy__c> acctivePolicy = [Select id,RecordType.name, Name,Cancel_Date__c, Account__c,Expiration_Date__c,Effective_Date__c,Limit__c 
                                         From Policy__c Limit 1];
        
        for(Policy__c po : acctivePolicy){
            po.Effective_Date__c = date.today().addMonths(104);
            po.Cancel_Date__c = date.today().addMonths(112);
            po.Expiration_Date__c = date.today().addMonths(120);
        }
        update acctivePolicy;
        
        List<Policy_Endorsement__c> objPolEndorse = [Select id,Lawyer__c,RecordType.Name,Override_Rating__c,Step_Override_Value__c, Name ,
                                                     Policy__c,Effective_Date__c,Endorsement_Effective_Date__c,Step_Override__c
                                                     From Policy_Endorsement__c limit 1];

        List<Policy_Lawyer__c> poLawList = [Select id from Policy_Lawyer__c];
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('policyId', acctivePolicy[0].Id);
        ApexPages.currentPage().getParameters().put('id', objPolEndorse[0].Id);
        ApexPages.currentPage().getParameters().put('name', 'Test');
        ApexPages.currentPage().getParameters().put('effectiveDate', '02/06/2010');
        ApexPages.currentPage().getParameters().put('RecordType', devRecordTypeId);
        ApexPages.currentPage().getParameters().put('fromPolicyLawyerRelatedList', 'policyLawyer');
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(poEnd);
        
        DeletingAnAttorney_Ctrl cMethod = new DeletingAnAttorney_Ctrl(stdcontroller);
        cMethod.policyEndorsement.Endorsement_Effective_Date__c = date.today();
        cMethod.policyEndorsement.Step_Override__c = false;
        cMethod.policyEndorsement.Step__c = 7;
        cMethod.selectedLawyer = poLawList[0].id;
        cMethod.premiumCalculator();
        cMethod.saveEndorsement();
        
        Test.stopTest();
    }
    
    
     @isTest
    static void premiumCalculator_Test_16(){
        
        Test.startTest();
         List<Policy__c> acctivePolicy = [Select id,RecordType.name, Name,Cancel_Date__c, Account__c,Expiration_Date__c,Effective_Date__c,Limit__c 
                                         From Policy__c Limit 1];
        
        for(Policy__c po : acctivePolicy){
            po.Effective_Date__c = date.today().addMonths(104);
            po.Cancel_Date__c = date.today().addMonths(112);
            po.Expiration_Date__c = date.today().addMonths(120);
        }
        update acctivePolicy;
        
        List<Policy_Endorsement__c> objPolEndorse = [Select id,Lawyer__c,RecordType.Name,Override_Rating__c,Step_Override_Value__c, Name ,
                                                     Policy__c,Effective_Date__c,Endorsement_Effective_Date__c,Step_Override__c
                                                     From Policy_Endorsement__c limit 1];

        List<Policy_Lawyer__c> poLawList = [Select id from Policy_Lawyer__c];
        Policy_Endorsement__c poEnd = new Policy_Endorsement__c();
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('policyId', acctivePolicy[0].Id);
        ApexPages.currentPage().getParameters().put('id', objPolEndorse[0].Id);
        ApexPages.currentPage().getParameters().put('name', 'Test');
        ApexPages.currentPage().getParameters().put('effectiveDate', '02/06/2010');
        ApexPages.currentPage().getParameters().put('RecordType', devRecordTypeId);
        ApexPages.currentPage().getParameters().put('fromPolicyLawyerRelatedList', 'policyLawyer');
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(poEnd);
        
        DeletingAnAttorney_Ctrl cMethod = new DeletingAnAttorney_Ctrl(stdcontroller);
        cMethod.policyEndorsement.Endorsement_Effective_Date__c = date.today();
        cMethod.policyEndorsement.Override_Rating__c = true;
        cMethod.selectedLawyer = poLawList[0].id;
        cMethod.premiumCalculator();
        cMethod.saveEndorsement();
        
        Test.stopTest();
    }
    
}