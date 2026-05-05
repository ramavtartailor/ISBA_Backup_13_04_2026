@isTest
private class EZRenewalExtension_Test {
    
    
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
    static void ValidateStandardController(){
        
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        
        PageReference pageRef = Page.EZRenewal;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(policies[0]);
        ApexPages.currentPage().getParameters().put('Id',policies[0].Id);
        
        Test.startTest();
        EZRenewalExtension Ctrl = new EZRenewalExtension(sc);
        Test.stopTest();
    }
}