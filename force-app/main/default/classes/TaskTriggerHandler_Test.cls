@isTest
public class TaskTriggerHandler_Test {
    
    @testSetup 
    static void testData(){
        
        // Insert Account
        Account acc = TestDataFactory.createAccounts('Test');
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
        insert opp;
       
        // Insert Master Factor
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        // Insert County
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        // Insert Geo Factor
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        // Insert Note
        Note__c note = new Note__c();
        note.Account__c = acc.id;
        insert note;
        
        // Insert Task
        Task tsk = new Task(
            Subject = 'Follw Up',
            Description = 'Task Description',
            Status = 'Pending',
            WhatId = acc.id,
            Note__c = note.id
        );
        Insert tsk;
        
        // Insert Policy
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        insert acctivePolicy;
        
        // Insert Policy Lawyer
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(acctivePolicy.Account__c,acctivePolicy.Id,acj.Id);
        law.Active__c = true;
        insert law;
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        insert calimset;
        
        // Insert Policy Claim
        Policy_Claim__c polClaim = TestDataFactory.createPolicyClaim(acctivePolicy.Id,law.id);   
        insert polClaim;

        
    }
    
    @isTest
    static void onAfterUpdate_Test(){
        List<Task> taskList =  [SELECT id,Note__c,Status,WhatId,Subject,Description,ActivityDate from Task];
        for(Task tsk : taskList){
            tsk.Status = 'Completed';
            tsk.ActivityDate = date.today().addDays(15);
        }
        Update taskList;
        
        Map<id,Task> taskMap = new Map<id,Task>([SELECT id,Note__c,Status,WhatId,Subject,Description,ActivityDate from Task]);
        
        Test.startTest();
        TaskTriggerHandler.onAfterUpdate(taskList, taskMap, taskList, taskMap);
        Test.stopTest();
    }
    
    @isTest
    static void createNewNote_Test(){
        
        List<Task> taskList =  [SELECT id,Note__c,Status,Type__c,WhatId,Subject,Description,ActivityDate from Task];
        
        Test.startTest();
        //TaskTriggerHandler.createNewNote(taskList);
        Test.stopTest();
    }
    
    @isTest
    static void createNewNote_Test_1(){
        
         
        List<Policy__c> policyList = [Select id from Policy__c Limit 1];
        
        List<Task> taskList =  [SELECT id,Note__c,Status,Type__c,WhatId,Subject,Description,ActivityDate from Task];
        for(Task tsk : taskList){
            tsk.WhatId = policyList[0].id;
        }
        Update taskList;
        
        Test.startTest();
        //TaskTriggerHandler.createNewNote(taskList);
        Test.stopTest();
    }
    
     @isTest
    static void createNewNote_Test_2(){
        
         
        List<Policy_Claim__c> policyClaimList = [Select id from Policy_Claim__c Limit 1];
        
        List<Task> taskList =  [SELECT id,Note__c,Status,Type__c,WhatId,Subject,Description,ActivityDate from Task];
        for(Task tsk : taskList){
            tsk.WhatId = policyClaimList[0].id;
        }
        Update taskList;
        
        Test.startTest();
        //TaskTriggerHandler.createNewNote(taskList);
        Test.stopTest();
    }

    
    @isTest
    static void createNewNote_Test_3(){
        
         
        List<Opportunity> oppList = [Select id from Opportunity Limit 1];
        
        List<Task> taskList =  [SELECT id,Note__c,Status,Type__c,WhatId,Subject,Description,ActivityDate from Task];
        for(Task tsk : taskList){
            tsk.WhatId = oppList[0].id;
        }
        Update taskList;
        
        Test.startTest();
        //TaskTriggerHandler.createNewNote(taskList);
        Test.stopTest();
    }

}