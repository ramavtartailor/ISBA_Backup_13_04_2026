/*
 * 
 * Created By     : Ali Zaidi
 * Created Date   : 11/19/2016
 * Purpose        : This class is the test class for CloneMasterFactorWithChilds Controller.
 * Name           : TestCloneMasterFactorWithChilds
 * Referenced     : Currently at the time of creation this class is referenced by CloneMasterFactorWithChilds Controller.
 * 
 */

@isTest
public class CloneMasterFactorWithChilds_Test {
	@testSetup static void setup() {
        Map<String,String> mapRecordTypes = new Map<String,String>();
        
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
                
        Master_Factor__c MasterFactorAOP = TestDataFactory.createMasterfactor('AOP','AOP');
        MasterFactorAOP.RecordTypeId = mapRecordTypes.get('Area_of_Practice');
        insert MasterFactorAOP;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(MasterFactorAOP.Id);
        insert aopFactor;
        
        AOP_Factor__c FactorAOP = new AOP_Factor__c();
        FactorAOP.Name = 'Admirality';
        FactorAOP.AOP_Mod__c = 0.86;
        FactorAOP.Law_Area_Category__c = 'Admirality';
        FactorAOP.Master_Factor__c = MasterFactorAOP.Id;
        insert FactorAOP;
        
        
        
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoveragefactor(MasterFactorCoverage.Id);
        insert FactorCoverage;
        
        Master_Factor__c MasterFactorDeductible = TestDataFactory.createMasterfactor('Coverage','Deductible');
        MasterFactorDeductible.RecordTypeId = mapRecordTypes.get('Deductible');
        insert MasterFactorDeductible;
        
        Deductible_Factor__c FactorDeductible = TestDataFactory.createDeductiblefactor(MasterFactorDeductible.Id);
        insert FactorDeductible;
        
        Master_Factor__c MasterFactorStepRate = TestDataFactory.createMasterfactor('Step Rate','Step Rate');
        MasterFactorStepRate.RecordTypeId = mapRecordTypes.get('Step_Rate');
        insert MasterFactorStepRate;
        
        Step_Rate_Factor__c FactorStepRate = TestDataFactory.createStepFactor(MasterFactorStepRate.Id);
        insert FactorStepRate;
        
        Master_Factor__c MasterFactorGEO = TestDataFactory.createMasterfactor('GEO','GEO');
        MasterFactorGEO.RecordTypeId = mapRecordTypes.get('GEO_Mode');
        insert MasterFactorGEO;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        GEO_Factor__c FactorGEO = TestDataFactory.createGeoFactor(MasterFactorGEO.Id,county.Id);
        insert FactorGEO;
        
        Master_Factor__c MasterFactorBase = TestDataFactory.createMasterfactor('Base Value','Base Value');
        MasterFactorBase.RecordTypeId = mapRecordTypes.get('Base_Value');
        insert MasterFactorBase;
        
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(MasterFactorBase.Id);
        insert baseFactor;
        
    }
    
    @isTest static void cloneAOPFactor() {
        Master_Factor__c MasterFactorAOP = [SELECT Id, Name, Factor_Type__c, Default__c, From_Date__c, To_Date__c FROM Master_Factor__c WHERE Factor_Type__c = 'AOP'];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(MasterFactorAOP);
        CloneMasterFactorWithChilds ctrl = new CloneMasterFactorWithChilds(sc);
        
        ctrl.Cancel();
        
        ctrl.Save();
        Test.stopTest();
    }
    
    @isTest static void cloneCoverageFactor() {
        Master_Factor__c MasterFactorCoverage = [SELECT Id, Name, Factor_Type__c, Default__c, From_Date__c, To_Date__c FROM Master_Factor__c WHERE Factor_Type__c = 'Coverage'];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(MasterFactorCoverage);
        CloneMasterFactorWithChilds ctrl = new CloneMasterFactorWithChilds(sc);
        
        ctrl.Cancel();
        
        ctrl.Save();
        Test.stopTest();
    }
    
    @isTest static void cloneDeductibleFactor() {
        Master_Factor__c MasterFactorCoverage = [SELECT Id, Name, Factor_Type__c, Default__c, From_Date__c, To_Date__c FROM Master_Factor__c WHERE Factor_Type__c = 'Deductible'];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(MasterFactorCoverage);
        CloneMasterFactorWithChilds ctrl = new CloneMasterFactorWithChilds(sc);
        
        ctrl.Cancel();
        
        ctrl.Save();
        Test.stopTest();
    }
    
    @isTest static void cloneStepRateFactor() {
        Master_Factor__c MasterFactorStepRate = [SELECT Id, Name, Factor_Type__c, Default__c, From_Date__c, To_Date__c FROM Master_Factor__c WHERE Factor_Type__c = 'Step Rate'];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(MasterFactorStepRate);
        CloneMasterFactorWithChilds ctrl = new CloneMasterFactorWithChilds(sc);
        
        ctrl.Cancel();
        
        ctrl.Save();
        Test.stopTest();
    }
    
    @isTest static void cloneGEOFactor() {
        Master_Factor__c MasterFactorGEO = [SELECT Id, Name, Factor_Type__c, Default__c, From_Date__c, To_Date__c FROM Master_Factor__c WHERE Factor_Type__c = 'GEO'];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(MasterFactorGEO);
        CloneMasterFactorWithChilds ctrl = new CloneMasterFactorWithChilds(sc);
        
        ctrl.Cancel();
        
        ctrl.Save();
        Test.stopTest();
    }
    
    @isTest static void cloneBaseFactor() {
        Master_Factor__c MasterFactorBase = [SELECT Id, Name, Factor_Type__c, Default__c, From_Date__c, To_Date__c FROM Master_Factor__c WHERE Factor_Type__c = 'Base Value'];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(MasterFactorBase);
        CloneMasterFactorWithChilds ctrl = new CloneMasterFactorWithChilds(sc);
        
        ctrl.Cancel();
        
        ctrl.Save();
        Test.stopTest();
    }
}