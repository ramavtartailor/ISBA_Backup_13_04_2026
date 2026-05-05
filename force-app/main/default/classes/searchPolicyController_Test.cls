@isTest
public class searchPolicyController_Test {
    
    public static Map<String,Id> mapOfRecordTypes = new Map<String,Id>();
    
    @testSetup static void setCloningAndRenewalSetup() {
        
        test.startTest();
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(mas.Id);
        insert stepRateFactor;
        
        Master_Factor__c masterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert masterFactor1;
        
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(masterFactor1.Id);
        insert baseFactor;
        
        ILF_Coverage_Factor__c objCoverageFactor = TestDataFactory.createCoveragefactor(mas.id);
        insert objCoverageFactor;
        
        test.stopTest();
        
    }
    
    @isTest static void testMethod1() {
        
        Account acc                   = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity Opp               = [SELECT Id, Name FROM Opportunity LIMIT 1];
        AccountContactJunction__c acj = [SELECT Id, Name FROM AccountContactJunction__c LIMIT 1];
        ILF_Coverage_Factor__c covrage = [SELECT Id, Name FROM ILF_Coverage_Factor__c LIMIT 1];
        
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','Geo');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        Policy__c pol                 = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Policy');
        pol.Base_Amount__c = 100;
        pol.Firm_Mod__c = 2;
        pol.Policy_Renew_Status__c = 'test';
        pol.Application_Type__c = 'Renewal';
        pol.Limit__c = covrage.id;
        insert pol;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(pol.Account__c,pol.Id,acj.Id);
        law.Active__c = true;
        insert law;
        
        Test.StartTest();
        
        PageReference pageRef = Page.searchPolicy;
        
        Test.setCurrentPage(pageRef);
        
        searchPolicyController ctrl = new searchPolicyController();
        
        ctrl.startExpirDate = date.today();  
        ctrl.endExpirDate = date.today().addDays(5);
        ctrl.fatchPolicy();
        ctrl.startExpirDate = date.today();  
        ctrl.endExpirDate = date.today().addDays(10);
        ctrl.fatchPolicy();
        ctrl.renwalIds = pol.Id;
        ctrl.renewal();
        
        Test.stopTest();
    }
    
}