/*
Name : AddRenewalAppLtng_Test 
Date : 18 Feb 2019
Description : Test Class for AddRenewalAppLtng

*/

@isTest
public class AddRenewalAppLtng_Test {
    
    @testSetup 
    static void testData(){
        
        // Insert Account    
        Account acc = TestDataFactory.createAccounts('Test Account');
        acc.BillingState = 'PA';
        acc.BillingCountry = 'USA';
        acc.Email__c = 'test@gmail.com';
        insert acc;
        
        // Insert Opportunity
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        opp.StageName = 'Renewal (Extremely Satisfied Customer)';
        opp.LeadSource = 'Agency';
        opp.CloseDate = System.today().addMonths(1);
        insert opp;
        
        // Insert Master Factor for Step Rate            
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','Step Rate');
        insert mas;
        
        // Insert Master Factor for base value        
        Master_Factor__c mas1          = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert mas1;
        
        // Insert County        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        // Insert geo factor 
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        // Insert Step rate Factor        
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(mas.Id);
        insert stepRateFactor;
        
        // Insert base Factor
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(mas1.Id);
        insert baseFactor;
        
        // Insert Policy                
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorNew.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        
        List<Policy__c> policyList = new List<Policy__c>();
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        //acctivePolicy.Renew_Application__c = true;
        policyList.add(acctivePolicy);
        
        Policy__c acctivePolicy1 = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy1.Limit__c = coverageFactorObj.Id;
        acctivePolicy1.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy1.Renew_Application__c = true;
        acctivePolicy1.Reason__c = 'Test';
        policyList.add(acctivePolicy1);   
        
        insert policyList;
    }
    
    @isTest static void getPolicy_Test() {
               
        List<Policy__c> lstPolicy = [Select Id,Renew_Application__c from Policy__c];
        Test.startTest();
        AddRenewalAppLtng.getPolicy(lstPolicy[0].id);
        Test.stopTest();
    }  
    
    @isTest static void getPolicy_Test_1() {
               
        List<Policy__c> lstPolicy = [Select Id,Renew_Application__c from Policy__c Where Renew_Application__c =: True];
        System.assertEquals(True, lstPolicy[0].Renew_Application__c);
        Test.startTest();
        AddRenewalAppLtng.getPolicy(lstPolicy[0].id);
        Test.stopTest();
    }  
}