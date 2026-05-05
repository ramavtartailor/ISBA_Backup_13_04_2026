@isTest
public class PolicyLawyerComponentHandler_Test {
    
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
        
        // Accouunt Junction
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(policy.Account__C, con.Id);
        insert junc;
        
        // Policy Lawyer
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(policy.Account__c,policy.Id,junc.Id);
        law.Account__c = acc.id;
        insert law;
        
    }
    
    @isTest
    static void getPolicyLawyers_Test(){
        
        List<Account> accList = [SELECT ID FROM Account];
        PolicyLawyerComponentHandler.getPolicyLawyers(String.valueof(accList[0].id),True);
        
    }
    
}