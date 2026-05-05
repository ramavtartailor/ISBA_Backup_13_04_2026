@isTest
public class PolicyLawyerHandler_Test {
    
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
        
        
        CLE_Attendance__c attendance = new CLE_Attendance__c();
        attendance.Contact__c = junc.Contact__c;
        //attendance.CLE_Event__c  = ; Required
        //insert attendance;
        
        
        List<Policy_Lawyer__c> policyLawyerList = new List<Policy_Lawyer__c>();
        
        // Policy Lawyer
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(policy.Account__c,policy.Id,junc.Id);
        law.Account__c = acc.id;
        law.Is_Application_Lawyer__c = true;
        law.Deleted_Lawyer__c = false;
        policyLawyerList.add(law);
        
        // Policy Lawyer
        Policy_Lawyer__c law1 = TestDataFactory.createPolicyLawyer(policy.Account__c,policy.Id,junc.Id);
        law1.Account__c = acc.id;
        law1.Is_Application_Lawyer__c = true;
        law1.Deleted_Lawyer__c = false;
        policyLawyerList.add(law1);
        
        insert policyLawyerList;
        
    }
    
    @isTest
    static void PolicyLawyerHandler_Test(){
        
        List<Policy_Lawyer__c> policyLawyerList = [SELECT ID,Name,Policy_Effective_Date__c,Is_Application_Lawyer__c,Prior_Act_Date__c, Step__c,Overriding_Step_Value__c,Rate_At__C,Policy__c,Lawyer__c,Deleted_Lawyer__c FROM Policy_Lawyer__c];
        Map<id,Policy_Lawyer__c> policyLawyerMap = new Map<id,Policy_Lawyer__c>([SELECT ID,Name,Policy_Effective_Date__c,Is_Application_Lawyer__c,Prior_Act_Date__c, Step__c,Overriding_Step_Value__c,Rate_At__C,Policy__c,Lawyer__c,Deleted_Lawyer__c FROM Policy_Lawyer__c]);
        PolicyLawyerHandler ctrl = new PolicyLawyerHandler();
        ctrl.beforeInsert(policyLawyerList);
        ctrl.afterDelete(policyLawyerMap);
        ctrl.beforeDelete(policyLawyerMap);
    }
    
}