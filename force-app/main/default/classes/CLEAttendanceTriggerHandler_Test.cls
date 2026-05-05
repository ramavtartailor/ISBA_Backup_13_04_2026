@isTest
public class CLEAttendanceTriggerHandler_Test {
    @isTest
    public static void testMethod1(){
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
         Contact con1                   = TestDataFactory.createContact('Test Contact1',acc.id);
        insert con1;
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        CLE_Event__c cleEventObj = new CLE_Event__c();
        cleEventObj.Date__c = system.today();
        cleEventObj.Description__c = 'Test Desc';
        cleEventObj.Hours__c = 7;
        insert cleEventObj;
        
        
        Master_Factor__c mas  = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);        
        insert geo;
       
        
        Policy__c policyObj = TestDataFactory.createPolicy(acc.Id,opp.Id, geo.Id,'Application');
        policyObj.Application_Type__c = 'Renewal';
        //policyObj.Effective_Date__c =  Date.newinstance(2023, 2, 26);
        insert policyObj;
        
        Policy_Lawyer__c policyLawObj = TestDataFactory.createPolicyLawyer(acc.Id,policyObj.Id,acj.Id);
        insert policyLawObj;
        
        CLE_Attendance__c cleAttn = new CLE_Attendance__c();
        //cleAttn.Event_Date__c =  Date.newinstance(1991, 2, 1);
        cleAttn.CLE_Event__c = cleEventObj.Id;
        cleAttn.Contact__c = con.Id;
        insert cleAttn;
        
		cleAttn.Contact__c = con1.Id;
        update cleAttn;
        //Event_Date__c <= pol.Policy__r.Effective_Date__c.addMonths(-3)
        //Event_Date__c > pol.Policy__r.Effective_Date__c.addMonths(-15)
        delete cleAttn;
        
        
        undelete cleAttn;
        
    }
}