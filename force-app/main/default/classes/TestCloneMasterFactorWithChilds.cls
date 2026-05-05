/*
 * 
 * Created By     : Ali Zaidi
 * Created Date   : 11/19/2016
 * Purpose        : This class is the test class for CloneMasterFactorWithChilds Controller.
 * Name           : TestCloneMasterFactorWithChilds
 * Referenced     : Currently at the time of creation this class is referenced by CloneMasterFactorWithChilds Controller.
 * 
 *  
 */
@isTest
private class TestCloneMasterFactorWithChilds {

    @testSetup static void setup() {
        Map<String,String> mapRecordTypes = new Map<String,String>();
        
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        Master_Factor__c MasterFactorAOP = new Master_Factor__c();
        MasterFactorAOP.Name = 'AOP';
        MasterFactorAOP.RecordTypeId = mapRecordTypes.get('Area_of_Practice');
        MasterFactorAOP.Factor_Type__c = 'AOP';
        MasterFactorAOP.Default__c = true;
        MasterFactorAOP.From_Date__c = Date.today();
        MasterFactorAOP.To_Date__c = Date.today() + 1;
        insert MasterFactorAOP;
        
        AOP_Factor__c FactorAOP = new AOP_Factor__c();
        FactorAOP.Name = 'Admirality';
        FactorAOP.AOP_Mod__c = 0.86;
        FactorAOP.Law_Area_Category__c = 'Admirality';
        FactorAOP.Master_Factor__c = MasterFactorAOP.Id;
        insert FactorAOP;
        
        Master_Factor__c MasterFactorCoverage = new Master_Factor__c();
        MasterFactorCoverage.Name = 'Coverage';
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        MasterFactorCoverage.Factor_Type__c = 'Coverage';
        MasterFactorCoverage.Default__c = true;
        MasterFactorCoverage.From_Date__c = Date.today();
        MasterFactorCoverage.To_Date__c = Date.today() + 1;
        insert MasterFactorCoverage;
        
        ILF_Coverage_Factor__c FactorCoverage = new ILF_Coverage_Factor__c();
        FactorCoverage.Name = '250,000 / 500,000';
        FactorCoverage.Lowest_Coverage__c = true;
        FactorCoverage.Master_Factor__c = MasterFactorCoverage.Id;
        FactorCoverage.Coverage_Max_Per_Claim__c = 500000;
        FactorCoverage.Full_Coverage__c = 250000;
        FactorCoverage.Factor_Value__c = 0.96;
        insert FactorCoverage;
        
        Master_Factor__c MasterFactorDeductible = new Master_Factor__c();
        MasterFactorDeductible.Name = 'Coverage';
        MasterFactorDeductible.RecordTypeId = mapRecordTypes.get('Deductible');
        MasterFactorDeductible.Factor_Type__c = 'Deductible';
        MasterFactorDeductible.Default__c = true;
        MasterFactorDeductible.From_Date__c = Date.today();
        MasterFactorDeductible.To_Date__c = Date.today() + 1;
        insert MasterFactorDeductible;
        
        Deductible_Factor__c FactorDeductible = new Deductible_Factor__c();
        FactorDeductible.Name = '1000';
        FactorDeductible.Deductible_Amount__c = 1000;
        FactorDeductible.Factor_Value__c = 0.96;
        FactorDeductible.Master_Factor__c = MasterFactorDeductible.Id;
        insert FactorDeductible;
        
        Master_Factor__c MasterFactorStepRate = new Master_Factor__c();
        MasterFactorStepRate.Name = 'Step Rate';
        MasterFactorStepRate.RecordTypeId = mapRecordTypes.get('Step_Rate');
        MasterFactorStepRate.Factor_Type__c = 'Step Rate';
        MasterFactorStepRate.Default__c = true;
        MasterFactorStepRate.From_Date__c = Date.today();
        MasterFactorStepRate.To_Date__c = Date.today() + 1;
        insert MasterFactorStepRate;
        
        Step_Rate_Factor__c FactorStepRate = new Step_Rate_Factor__c();
        FactorStepRate.Name = 'Step Rate';
        FactorStepRate.Factor_Value_Step_Rate_0__c = 1;
        FactorStepRate.Factor_Value_Step_Rate_1__c = 1;
        FactorStepRate.Factor_Value_Step_Rate_2__c = 1;
        FactorStepRate.Factor_Value_Step_Rate_3__c = 1;
        FactorStepRate.Factor_Value_Step_Rate_4__c = 1;
        FactorStepRate.Factor_Value_Step_Rate_5__c = 1;
        FactorStepRate.Factor_Value_Step_Rate_6__c = 1;
        FactorStepRate.Factor_Value_Step_Rate_7__c = 1;
        FactorStepRate.Master_Factor__c = MasterFactorStepRate.Id;
        insert FactorStepRate;
        
        Master_Factor__c MasterFactorGEO = new Master_Factor__c();
        MasterFactorGEO.Name = 'GEO';
        MasterFactorGEO.RecordTypeId = mapRecordTypes.get('GEO_Mode');
        MasterFactorGEO.Factor_Type__c = 'GEO';
        MasterFactorGEO.Default__c = true;
        MasterFactorGEO.From_Date__c = Date.today();
        MasterFactorGEO.To_Date__c = Date.today() + 1;
        insert MasterFactorGEO;
        
        County__c county = new County__c();
        county.Name = 'ADAMS';
        county.Region__c = '5';
        insert county;
        
        GEO_Factor__c FactorGEO = new GEO_Factor__c();
        FactorGEO.Name = 'GEO Factor';
        FactorGEO.County__c = county.Id;
        FactorGEO.Master_Factor__c = MasterFactorGEO.Id;
        FactorGEO.Region_Factor_Value__c = 5;
        insert FactorGEO;
        
        Master_Factor__c MasterFactorBase = new Master_Factor__c();
        MasterFactorBase.Name = 'Base Value';
        MasterFactorBase.RecordTypeId = mapRecordTypes.get('Base_Value');
        MasterFactorBase.Factor_Type__c = 'Base Value';
        MasterFactorBase.Default__c = true;
        MasterFactorBase.From_Date__c = Date.today();
        MasterFactorBase.To_Date__c = Date.today() + 1;
        insert MasterFactorBase;
        
        Base_Factor__c FactorBase = new Base_Factor__c();
        FactorBase.Name = 'Base Factor';
        FactorBase.Base_Amount__c = 1067;
        FactorBase.Master_Factor__c = MasterFactorBase.Id;
        insert FactorBase;
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