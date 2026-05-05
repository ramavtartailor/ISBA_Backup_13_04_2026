@isTest
public class CloseApplicationCtrlTest {
    @testSetup
    static void testData(){
        
        // Insert Account
        Account acc                   = TestDataFactory.createAccounts('Bucket Account');
        insert acc;
        
        // Insert Contact
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        // Insert AccountContactJunction
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        // Insert Opportunity
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        // Insert Master Factor
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','GEO');
        insert mas;
        
        // Insert County
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        // Insert Geo Factor
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        // Insert Master Factor       
        Master_Factor__c masterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert masterFactor1;
        
        
        // Insert Base Factor
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(masterFactor1.Id);
        insert baseFactor;
        
        Map<String,String> mapRecordTypes = new Map<String,String>();
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        // Insert Master Fator
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        // Insert ILF Coverage Factor
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoverageFactor(MasterFactorCoverage.Id);
        FactorCoverage.Percentage_5X5_Step_0__c =3;
        FactorCoverage.Percentage_5X5_Step_1__c=4;
        FactorCoverage.Percentage_5X5_Step_2__c=5;
        FactorCoverage.Percentage_5X5_Step_3__c=6;
        FactorCoverage.Percentage_5X5_Step_4__c=8;
        FactorCoverage.Premium_Rate_5X5__c = 33;
        FactorCoverage.Is_5X5_Coverage__c = true;        
        insert FactorCoverage;
        
        ILF_Coverage_Factor__c coverFactor = TestDataFactory.createCoveragefactor(masterFactor1.Id);
        coverFactor.Name = '100,000 / 100,000';
        coverFactor.Coverage_Max_Per_Claim__c = 100000;
        coverFactor.Full_Coverage__c = 100000;
        coverFactor.Master_Factor__c = masterFactor1.id;
        coverFactor.Is_10X10_Coverage__c = true;
        coverFactor.Factor_Value__c = 2.04;
        coverFactor.Lowest_Coverage__c = true;
        coverFactor.OldLimit__c = false;
        insert coverFactor;
        
        // Insert Master Factor
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor','Deductible');
        insert mas12;
        
        // Insert Deductible Factor
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        Insert DedFac; 
        
        // Insert Master Factor
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        masterFactorNew.To_Date__c = system.today().addDays(10);
        masterFactorNew.From_Date__c = system.today().addDays(10);
        insert masterFactorNew;
        
        // Insert Deductible Factor
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        dedFactorObj.Deductible_Amount__c = 0;
        insert dedFactorObj;
        
        
        Master_Factor__c masterFactor = new Master_Factor__c(Factor_Type__c='Step Rate', Default__c=true,From_Date__c= Date.today().addDays(-1),
                                                             To_Date__c= Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day()),
                                                             Name  = 'Test Master Factor0');
        insert masterFactor;
        
        Step_Rate_Factor__c stepRateFactor = new Step_Rate_Factor__c(Master_Factor__c=masterFactor.Id, Factor_Value_Step_Rate_0__c=0,
                                                                     Factor_Value_Step_Rate_1__c=1, Factor_Value_Step_Rate_2__c=2, Factor_Value_Step_Rate_3__c=3, 
                                                                     Factor_Value_Step_Rate_4__c=4, Factor_Value_Step_Rate_5__c=5, Factor_Value_Step_Rate_6__c=6,
                                                                     Factor_Value_Step_Rate_7__c=7);
        insert stepRateFactor;
        
        
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
    }
    @isTest
    static void testCloseApplication(){
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        Customer_Application__c app = new Customer_Application__c(Account__c = acc.Id,Contact__c=con.Id, Application_Status__c='Open');
        
        Test.startTest();
        insert app;
        
        Note__c note = new Note__c();
        note.Customer_Application__c = app.id;
        insert note;
        
        List<String> pickListValues = CloseApplicationCtrl.getPickListVal('Customer_Application__c', app.Id, 'Close_Reason__c');
        
        Boolean result = CloseApplicationCtrl.save(app.Id, pickListValues[0], 'Test Close Description');
        
        
        Test.stopTest();
        
        System.assertEquals(true, result);
    }
    
    @isTest
    static void testCloseApplicationAccException(){
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        Customer_Application__c app = new Customer_Application__c(Application_Status__c='Open');
        
        Test.startTest();
        try{
        insert app;
        
        Note__c note = new Note__c();
        note.Customer_Application__c = app.id;
        insert note;
        
        List<String> pickListValues = CloseApplicationCtrl.getPickListVal('Customer_Application__c', app.Id, 'Close_Reason__c');
        
        Boolean result = CloseApplicationCtrl.save(app.Id, pickListValues[0], 'Test Close Description');
        
        }
        catch(Exception e){
            System.debug(e.getMessage());
            System.assertEquals('Account not linked.', e.getMessage());
        }
        Test.stopTest();
    }
    @isTest
    static void testCloseApplicationConException(){
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        Customer_Application__c app = new Customer_Application__c(Account__c = acc.Id, Application_Status__c='Open');
        
        Test.startTest();
        try{
        insert app;
        
        Note__c note = new Note__c();
        note.Customer_Application__c = app.id;
        insert note;
        
        List<String> pickListValues = CloseApplicationCtrl.getPickListVal('Customer_Application__c', app.Id, 'Close_Reason__c');
        
        Boolean result = CloseApplicationCtrl.save(app.Id, pickListValues[0], 'Test Close Description');
        
        }
        catch(Exception e){
            System.debug(e.getMessage());
            System.assertEquals('Contact not linked.', e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCloseApplication_Exception(){
        
        Boolean exceptionThrown = false;
        
        try{
            // Passing null Id to force DML exception
            CloseApplicationCtrl.save(null, 'Test', 'Desc');
        }
        catch(Exception e){
            exceptionThrown = true;
        }
        
        System.assertEquals(true, exceptionThrown);
    }
    
    
}