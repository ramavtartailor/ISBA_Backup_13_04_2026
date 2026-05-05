@isTest
public class PrintPoliciesController_Test {
    
    @testSetup 
    static void testData(){
        
        // Insert Account
        Account acc = TestDataFactory.createAccounts('Test');
        acc.Name = 'Test';
        insert acc;
        
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
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarddd@testorg.com');
        insert u;
        
        // Create Policy
        Policy__c policy = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Policy');
        policy.Application_Received_Date__c = date.today();
        policy.Underwriter_User__c = u.id;
        policy.Status__c = 'Bound';
        policy.Date_Signed__c = date.today();
        Insert policy;
    }
    
    
    @isTest
    static void fetchPolicy_Test(){
        
        List<Policy__c> policyList =  [select id,Application_Received_Date__c,Date_Signed__c,Underwriter_User__c,Status__c from Policy__c];
        System.debug('sta--'+policyList[0].Status__c);
        PrintPoliciesController ctrl = new PrintPoliciesController();
        ctrl.samplePolicy = policyList[0];
        ctrl.searchFirmName = 'Test';
        ctrl.selectedUnderWriter = policyList[0].Underwriter_User__c;
        ctrl.searchPolicyStatus = policyList[0].Status__c;
        ctrl.rowIdx = policyList[0].id;
        ctrl.sendPolicyStatus();
        ctrl.getUnderwriter();
        ctrl.getPolicyStatus();
        
    }
    
}