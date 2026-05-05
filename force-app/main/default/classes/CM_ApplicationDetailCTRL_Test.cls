@isTest
public class CM_ApplicationDetailCTRL_Test {
    
    @testSetup 
    static void testData(){
        
        // Insert Account
        Account acc = TestDataFactory.createAccounts('Test Account');
        insert acc;
        
        // Insert Contact
        Contact con = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        // Insert Opportunity
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        // Insert Master Factor
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        // Insert County
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        // Insert GEO factor
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        // Insert Policy
        Policy__c pol = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Policy');
        pol.Aggregate_Limit__c = 100;
        insert pol;
        
        
    }
    
    @isTest 
    static void testMethod1() {
        
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        Policy__c  policy = policies[0];
        
        Test.startTest();
        
        //PageReference pageRef = Page.CM_DetailApplicationPage; //Page CM_DetailApplicationPage does not exist
        //pageRef.getParameters().put('Id', policy.Id);
        //system.Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(policy);
        CM_ApplicationDetailCTRL Ctrl = new CM_ApplicationDetailCTRL(sc);
        
        Test.stopTest();
        
    }
    
    
}