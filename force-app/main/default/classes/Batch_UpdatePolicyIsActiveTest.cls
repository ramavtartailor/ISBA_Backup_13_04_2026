@isTest
public class Batch_UpdatePolicyIsActiveTest {
    @isTest
    public static void testmethod1(){
        // Insert Accounts
        Account acc = TestDataFactory.createAccounts('Bucket Account');
        insert acc;
        
        // Insret Contact        
        Contact con = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        // Insert Opportunity        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        // Insert Master factor fro Step Rate        
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        // Insert County        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        // Insert geo factor        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        // Insert Policy
        Policy__c pol = TestDataFactory.createActivePolicy(acc.Id,opp.id,geo.id,'Policy');
        pol.Cancel_Date__c = null;
        pol.Active1__c = false;
        insert pol;
        
        
        Policy__c polObj = [SELECT ID,Active1__c,Active__c FROM Policy__c Where Id =:pol.Id ];
        system.debug(polObj);
        
        Batch_UpdatePolicyIsActive b = new Batch_UpdatePolicyIsActive();
        database.executeBatch(b);
    }

}