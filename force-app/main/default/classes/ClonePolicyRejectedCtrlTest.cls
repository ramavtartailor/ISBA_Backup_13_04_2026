@isTest
public class ClonePolicyRejectedCtrlTest {
	@isTest
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
        coverFactor.Name = '10,000,000 / 10,000,000';
        coverFactor.Coverage_Max_Per_Claim__c = 10000000;
        coverFactor.Full_Coverage__c = 10000000;
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
        
        
        
        // Insert Policy
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = FactorCoverage.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy.Effective_Date__c = system.today().addDays(10);
        acctivePolicy.Expiration_Date__c = system.today().addDays(10);
        acctivePolicy.Policy_Series_Effective_Date__c = system.today().addDays(10);
        insert acctivePolicy;
        
        // Insert Endorsement
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        insert endorse;
        
        // Insert Endorsement Version
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        // Insert Endorsement version 2
        Endorsement_Version__c endorseVersion2 = TestDataFactory.createEndorsementVersion(endorse.Id);
        endorseVersion2.Endorsement_Version_Number__c='2';
        insert endorseVersion2;
        
        // Insert AOP_Factor__c 
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        // Insert Policy_AOP__c
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,acctivePolicy.id);
        insert aop;
        
         // Insert Policy Lawyer
        Policy_Lawyer__c polLawyer = TestDataFactory.createPolicyLawyer(acc.Id,acctivePolicy.Id,acj.Id);
        insert polLawyer;
        
        // Insert Policy Endorsement
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        objPolEndorse.Override_Rating__c = false;
        objPolEndorse.Step__c = null;
        objPolEndorse.Step_Override__c = true;
        objPolEndorse.Step_Override_Value__c = 0;
        objPolEndorse.Lawyer__c = acj.id;
        objPolEndorse.Effective_Date__c =  date.today();
        objPolEndorse.Endorsement_Effective_Date__c = System.today() +  10;
        insert objPolEndorse;
        
        Policy_Quote__c objpolQut = TestDataFactory.createPolicyQuote(acctivePolicy.Id,coverFactor.Id,DedFac.Id);
        objpolQut.Adj_R_O__c = true;
        
    //    objpolQut.Policy__c = acctivePolicy.Id;
        insert objpolQut;
        
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
        try{
            ClonePolicyRejectedCtrl.clonePolicy(acctivePolicy.Id, system.today().addMonths(10)); 
             
        }
        catch(exception e){
            system.debug(e.getMessage());
        }
    }
    @isTest
    static void testData1(){
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
        coverFactor.Name = '10,000,000 / 10,000,000';
        coverFactor.Coverage_Max_Per_Claim__c = 10000000;
        coverFactor.Full_Coverage__c = 10000000;
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
        
        
        
        // Insert Policy
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Application');
        acctivePolicy.Limit__c = FactorCoverage.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy.Effective_Date__c = system.today().addDays(10);
        acctivePolicy.Expiration_Date__c = system.today().addDays(10);
        acctivePolicy.Policy_Series_Effective_Date__c = system.today().addDays(10);
        insert acctivePolicy;
        
        // Insert Endorsement
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        insert endorse;
        
        // Insert Endorsement Version
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        // Insert Endorsement version 2
        Endorsement_Version__c endorseVersion2 = TestDataFactory.createEndorsementVersion(endorse.Id);
        endorseVersion2.Endorsement_Version_Number__c='2';
        insert endorseVersion2;
        
        // Insert AOP_Factor__c 
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        // Insert Policy_AOP__c
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,acctivePolicy.id);
        insert aop;
        
         // Insert Policy Lawyer
        Policy_Lawyer__c polLawyer = TestDataFactory.createPolicyLawyer(acc.Id,acctivePolicy.Id,acj.Id);
        insert polLawyer;
        
        // Insert Policy Endorsement
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        objPolEndorse.Override_Rating__c = false;
        objPolEndorse.Step__c = null;
        objPolEndorse.Step_Override__c = true;
        objPolEndorse.Step_Override_Value__c = 0;
        objPolEndorse.Lawyer__c = acj.id;
        objPolEndorse.Effective_Date__c =  date.today();
        objPolEndorse.Endorsement_Effective_Date__c = System.today() +  10;
        insert objPolEndorse;
        
        Policy_Quote__c objpolQut = TestDataFactory.createPolicyQuote(acctivePolicy.Id,coverFactor.Id,DedFac.Id);
        objpolQut.Adj_R_O__c = true;
        
    //    objpolQut.Policy__c = acctivePolicy.Id;
        insert objpolQut;
        
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
        try{
            ClonePolicyRejectedCtrl.clonePolicy(acctivePolicy.Id, system.today().addMonths(10)); 
             
        }
        catch(exception e){
            system.debug(e.getMessage());
        }
    }
}