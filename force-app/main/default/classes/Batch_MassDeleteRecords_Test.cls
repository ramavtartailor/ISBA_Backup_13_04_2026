@isTest
public class Batch_MassDeleteRecords_Test {
    
    @testSetup
    static void testData(){
        
        Account acc = TestDataFactory.createAccounts('Test Account');
        insert acc;
        
        Contact con = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Geo');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.id,county.Id);
        insert geo;
        
        Policy__c pol = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Policy');
        insert pol;
        
        List<Note__c> noteList = new List<Note__c>();
        Note__c objNote = TestDataFactory.createNote(pol.id);
        noteList.add(objNote);
        
        insert noteList;
    }
    
    
    @isTest
    static void method(){
        
        List<Note__c> testnotes = [select id from Note__c];
        
        Batch_MassDeleteRecords obj = new Batch_MassDeleteRecords();
        
        Database.QueryLocator ql = obj.start(null);
        obj.execute(null,testnotes);
        obj.Finish(null);
        
        /*
        String testLbl = Label.Batch_Mass_Delete_Query;
        Test.startTest();
        DataBase.executeBatch(obj);
        Test.stopTest();
        */
    }
    
}