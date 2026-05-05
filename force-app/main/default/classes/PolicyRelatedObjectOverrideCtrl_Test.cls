@isTest
public class PolicyRelatedObjectOverrideCtrl_Test {
    
    @testSetup 
    static void testData(){
        
        // Insert Accounts
        Account acc                   = TestDataFactory.createAccounts('Bucket Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        // Insret Contact        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        con.FirstName                 = 'Test';
        con.Type__c                   = 'Lawyer';
        con.Contact_Role__c           = 'P';
        con.AccountId                 = acc.Id;
        insert con;
        
        // Insert Opportunity        
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        // Insert Master factor fro Step Rate        
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        // Insert County        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        // Insert geo factor        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        
        // Insret Account Contact Junction       
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        // Insert master factor        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor','Deductible');
        insert mas12;
        
        Map<String,String> mapRecordTypes = new Map<String,String>();
        
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        // Insert Master Factor coverage        
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        // Insert ILF Coverage factor        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoverageFactor(MasterFactorCoverage.Id);
        FactorCoverage.Percentage_5X5_Step_0__c =3;
        FactorCoverage.Percentage_5X5_Step_1__c=4;
        FactorCoverage.Percentage_5X5_Step_2__c=5;
        FactorCoverage.Percentage_5X5_Step_3__c=6;
        FactorCoverage.Percentage_5X5_Step_4__c=8;
        FactorCoverage.Premium_Rate_5X5__c = 33;
        FactorCoverage.Is_5X5_Coverage__c = true;
        insert FactorCoverage;
        
        // Insert   Deductible Factor     
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        Insert DedFac; 
        
        // Insert Policy
        Policy__c pol                 = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Policy');
        pol.Status__c                 = 'Policy Sent';
        pol.Base_Amount__c = 100;
        pol.Firm_Mod__c = 2;
        pol.Limit__c = FactorCoverage.Id;
        pol.Deductible_ID__c = DedFac.id;
        insert pol;

        // Insert Master Factor for AOP       
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        // Insert AOP Factor        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        // Insert Policy AOP        
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,pol.id);
        insert aop;
        
        // Insert Policy Lawyer
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(pol.Account__c,pol.Id,acj.Id);
        law.Active__c = true;
        insert law;
        
        // Insert Policy Quote
       /** Policy_Quote__c objpolQut = TestDataFactory.createPolicyQuote(pol.Id,FactorCoverage.Id,DedFac.Id);
        objpolQut.Adj_R_O__c = true;
        insert objpolQut;
        **/
    }
    
    @isTest
    static void isOperationAllowed_Test(){
        
        List<Policy_AOP__c> aopList = [Select id from Policy_AOP__c];
        
        Test.startTest();
        PolicyRelatedObjectOverrideCtrl.isOperationAllowed(aopList[0].id,'Delete');
        Test.stopTest();
    }
    
    @isTest
    static void isOperationAllowed_Test_0_1(){
        
        List<Policy__c> policyList = [Select id,RecordTypeId from Policy__c];
        for(Policy__c po : policyList){
            po.RecordTypeId = Schema.SObjectType.Policy__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();

        }
        //update policyList;   
        
        List<Policy_AOP__c> aopList = [Select id from Policy_AOP__c];
        
        Test.startTest();
        PolicyRelatedObjectOverrideCtrl.isOperationAllowed(aopList[0].id,'Delete');
        Test.stopTest();
    }
    
    
    @isTest
    static void isOperationAllowed_Test_1(){
        
        List<Policy_Quote__c> pqList = [Select id from Policy_Quote__c];
        
        Test.startTest();
      //  PolicyRelatedObjectOverrideCtrl.isOperationAllowed(pqList[0].id,'Delete');
        Test.stopTest();
    }
    
    @isTest
    static void isOperationAllowed_Test_1_1(){
        
        List<Policy__c> policyList = [Select id,RecordTypeId from Policy__c];
        for(Policy__c po : policyList){
            po.RecordTypeId = Schema.SObjectType.Policy__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();

        }
        //update policyList;   
        
        List<Policy_Quote__c> pqList = [Select id from Policy_Quote__c];
        
        Test.startTest();
      //  PolicyRelatedObjectOverrideCtrl.isOperationAllowed(pqList[0].id,'Delete');
        Test.stopTest();
    }
    
    @isTest
    static void isOperationAllowed_Test_2(){
        
        List<Policy_Lawyer__c> plawList = [Select id from Policy_Lawyer__c];
        
        Test.startTest();
        PolicyRelatedObjectOverrideCtrl.isOperationAllowed(plawList[0].id,'Delete');
        Test.stopTest();
    }
    
    @isTest
    static void isOperationAllowed_Test_2_1(){
        
        
        List<Policy__c> policyList = [Select id,RecordTypeId from Policy__c];
        for(Policy__c po : policyList){
            po.RecordTypeId = Schema.SObjectType.Policy__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();

        }
        //update policyList;   

        List<Policy_Lawyer__c> plawList = [Select id from Policy_Lawyer__c];
        
        Test.startTest();
        PolicyRelatedObjectOverrideCtrl.isOperationAllowed(plawList[0].id,'Delete');
        Test.stopTest();
    }
    
    @isTest
    static void isOperationAllowed_Test_3(){
        
        List<Policy_Lawyer__c> plawList = [Select id from Policy_Lawyer__c];
        
        Test.startTest();
        PolicyRelatedObjectOverrideCtrl.isOperationAllowed(plawList[0].id,'Save');
        Test.stopTest();
    }
    
    
    
}