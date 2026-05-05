@isTest
public class PolicyHistoryComponentHandler_Test {
    
     @testSetUp
    static void testData(){
        
        // Insert Account
        Account acc = TestDataFactory.createAccounts('Test');
        insert acc;
        
        // Insert Contact
        Contact con =  TestDataFactory.createContact('Last Name',acc.id);
        insert con;
        
        // Insert Opportunity
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        // Insert Master Factor
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        // County
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        // Insert GEO
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        // Create Policy
        Policy__c policy = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Policy');
        Insert policy;
        
    }
    
    
    @isTest
    static void getPolicies_Test(){
        List<Policy__c> policyList = [SELECT id FROM Policy__c];
        PolicyHistoryComponentHandler.getPolicies(policyList[0].id, True);
    }
    
    @isTest
    static void getPolicies_Test1(){
        List<Account> accList = [SELECT id FROM Account];
        PolicyHistoryComponentHandler.getPolicies(accList[0].id, True);
    }

}