@isTest
private class PolicyEndorsementController_Test{
    
    
    @testSetup 
    static void testData(){
        
        // Insert Account
        Account acc = TestDataFactory.createAccounts('Test Account');
        insert acc;
  
        // Insert Contact
        Contact con = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        // Insert AccountContactJunction
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
         
        // Insert Opportunity
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        opp.StageName                 = 'Application Sent';
        opp.CloseDate                 = Date.today();
        insert opp;
        
        // Insert Master Factor
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Geo');
        insert mas;

        // Insert County
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        // Insert Geo Factor
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.id,county.Id);
        insert geo;
        
        // Insert Policy
        Policy__c pol                 = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Application');
        pol.Status__c                 = 'Application created';
        pol.SCH_Mod__c                = 1.00;
        insert pol;
        
        // Insert Endorsement
        Endorsement__c endorse = TestDataFactory.createEndorsement('','','IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT');
        insert endorse;
        
        // Insert Endorsement Version
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        // Insert Policy Endorsement
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,pol.id,'IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT');
        objPolEndorse.Endorsement_Number__c = 'IL 102';
        insert objPolEndorse;
        
        // Insert Policy Lawyer
        Policy_Lawyer__c polLawyer = TestDataFactory.createPolicyLawyer(acc.Id,pol.Id,acj.Id);
        insert polLawyer;

        List<Policy_Lawyer__c> lawyer = [select id,Policy__c,Prior_Act_Date__c,Lawyer_Name__c from Policy_Lawyer__c where Policy__c =: pol.id];
        System.debug('lawyer---'+lawyer);
    }
    
    @isTest 
    static void getPolicyEndorse_Test(){
        
        List<Policy_Endorsement__c> policyEndorList = [SELECT id FROM Policy_Endorsement__c];
        Test.startTest();
        PolicyEndorsementController.getPolicyEndorse(String.valueof(policyEndorList[0].Id));
        
        PolicyEndorsementController.cancelEndorsement(policyEndorList[0].Id);
        Test.stopTest(); 
        
    }
    
    
    @isTest 
    static void updatePolicy_Test(){
        
        List<Policy_Endorsement__c> policyEndorList = [SELECT id,Policy__c,Endorsement_Number__c FROM Policy_Endorsement__c];
        policyEndorList[0].Endorsement_Number__c = 'IL 102';
        Update policyEndorList[0];
        System.debug('policyEndorList==='+policyEndorList);
        Test.startTest();
        PolicyEndorsementController.updatePolicy(String.valueof(policyEndorList[0].Id));
        Test.stopTest(); 
        
    }
}