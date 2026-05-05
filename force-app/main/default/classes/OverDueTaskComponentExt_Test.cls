@isTest
public class OverDueTaskComponentExt_Test {
    @isTest
    public static void TestMethod_Test(){
        
        Account acc = TestDataFactory.createAccounts('Test');
        insert acc;
        
        Contact con =  TestDataFactory.createContact('Last Name',acc.id);
        insert con;
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorNew.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy.ARDC_Cliam_Sublimit_Per_Policy__c = 10000;
        insert acctivePolicy;
        
        Task taskObj1 = new Task();
        taskObj1.Status = 'In Progress';
        taskObj1.Subject = 'Test Two';
        taskObj1.WhatId = acctivePolicy.id;
        taskObj1.ActivityDate = System.Today() - 2;
        insert taskObj1;
        
        Task taskObj = new Task();
        taskObj.Status = 'In Progress';
        taskObj.Subject = 'Test Two';
        taskObj.WhatId = acctivePolicy.id;
        taskObj.ActivityDate = System.Today();
        insert taskObj;
        
        //OverDueTaskComponentExt.getOverDueTask(taskObj1.Id);
        OverDueTaskComponentExt.getOpenTask(taskObj.Id);
        
        
    }
}