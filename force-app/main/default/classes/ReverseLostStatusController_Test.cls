@isTest
public class ReverseLostStatusController_Test {
    
    @testSetup 
    static void testData(){
        
        Account acc = TestDataFactory.createAccounts('Test');
        insert acc;
        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        Policy__c policy = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Policy');
        Insert policy;
    }
    
    @isTest
    static void convertToApplication_Test(){
        
        Test.startTest();
        
        List<Policy__c> policies = [select id from Policy__c];
        ReverseLostStatusController.convertToApplication(policies[0].id);
        
        Test.stopTest();
    }
    
}