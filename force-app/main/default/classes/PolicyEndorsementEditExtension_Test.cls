@isTest
public class PolicyEndorsementEditExtension_Test {
    
    @testSetup static void setup() {
 
    }
    
    @isTest
    static void returnToEditPage_Test(){
        
        // Insert Accounts
        Account acc = TestDataFactory.createAccounts('Bucket Account');
        insert acc;
        
        // Insret Contact        
        Contact con = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        // Insert Opportunity        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        // Insert Master factor fro Step Rate        
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        // Insert County        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        // Insert geo factor        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        // Insert Policy
        Policy__c pol = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Policy');
        insert pol;
        
        // Insert  Endorsment      
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 102','Functional','General');
        insert endorse;
        
        // Insert Endorsment Version
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        // Insert Policy Endorsement        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,pol.id,'General');
        insert poicyEndorse;
        
        List<Policy_Endorsement__c> policyEndorsmentList = [select id,name,Endorsement_Number__c from Policy_Endorsement__c where Endorsement_Number__c=:'IL 102'];
        ApexPages.StandardController sc = new ApexPages.StandardController(policyEndorsmentList[0]);
        PolicyEndorsementEditExtension obj = new PolicyEndorsementEditExtension(sc);
        obj.returnToEditPage();
        
    }
    
    
    @isTest
    static void returnToEditPage_Test1(){
        
        // Insert Accounts
        Account acc = TestDataFactory.createAccounts('Bucket Account');
        insert acc;
        
        // Insret Contact        
        Contact con = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        // Insert Opportunity        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        // Insert Master factor fro Step Rate        
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        // Insert County        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        // Insert geo factor        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        Map<String,String> mapRecordTypes = new Map<String,String>();
        
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
         // Insert Master Factor coverage        
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        // Insert ILF Coverage factor        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoverageFactor(MasterFactorCoverage.Id);
        FactorCoverage.Percentage_5X5_Step_0__c =3;
        FactorCoverage.Percentage_5X5_Step_1__c=4;
        FactorCoverage.Percentage_5X5_Step_2__c=5;
        FactorCoverage.Percentage_5X5_Step_3__c=6;
        FactorCoverage.Percentage_5X5_Step_4__c=8;
        FactorCoverage.Premium_Rate_5X5__c = 33;
        FactorCoverage.Is_5X5_Coverage__c = true;
        insert FactorCoverage;
        
         // Insert master factor        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor','Deductible');
        insert mas12;
        
        // Insert   Deductible Factor     
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        Insert DedFac; 
        
        // Insert Policy
        Policy__c pol = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Application');
        pol.Limit__c = FactorCoverage.Id;
        pol.Deductible_ID__c = DedFac.id;
        insert pol;
        
        // Insert  Endorsment      
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        insert endorse;
        
        // Insert Endorsment Version
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        // Insert Policy Endorsement        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,pol.id,'General');
        insert poicyEndorse;
        
        List<Policy_Endorsement__c> policyEndorsmentList = [select id,name,Endorsement_Number__c from Policy_Endorsement__c where Endorsement_Number__c=:'IL 152'];
        ApexPages.StandardController sc = new ApexPages.StandardController(policyEndorsmentList[0]);
        PolicyEndorsementEditExtension obj = new PolicyEndorsementEditExtension(sc);
        obj.returnToEditPage();
        
    }
    
    
    @isTest
    static void returnToEditPage_Test2(){
        
        // Insert Accounts
        Account acc = TestDataFactory.createAccounts('Bucket Account');
        insert acc;
        
        // Insret Contact        
        Contact con = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        // Insert Opportunity        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        // Insert Master factor fro Step Rate        
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        // Insert County        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        // Insert geo factor        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        Map<String,String> mapRecordTypes = new Map<String,String>();
        
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
         // Insert Master Factor coverage        
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        // Insert ILF Coverage factor        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoverageFactor(MasterFactorCoverage.Id);
        FactorCoverage.Percentage_5X5_Step_0__c =3;
        FactorCoverage.Percentage_5X5_Step_1__c=4;
        FactorCoverage.Percentage_5X5_Step_2__c=5;
        FactorCoverage.Percentage_5X5_Step_3__c=6;
        FactorCoverage.Percentage_5X5_Step_4__c=8;
        FactorCoverage.Premium_Rate_5X5__c = 33;
        FactorCoverage.Is_5X5_Coverage__c = true;
        insert FactorCoverage;
        
         // Insert master factor        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor','Deductible');
        insert mas12;
        
        // Insert   Deductible Factor     
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        Insert DedFac; 
        
        // Insert Policy
        Policy__c pol = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Application');
        pol.Limit__c = FactorCoverage.Id;
        pol.Deductible_ID__c = DedFac.id;
        insert pol;
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = FactorCoverage.Id;
        acctivePolicy.Deductible_ID__c = DedFac.Id;
        acctivePolicy.Effective_Date__c = system.today().addDays(10);
        acctivePolicy.Expiration_Date__c = system.today().addDays(10);
        insert acctivePolicy;
        
        Policy_Lawyer__c polLawyer = TestDataFactory.createPolicyLawyer(acc.Id,acctivePolicy.Id,acj.Id);
        insert polLawyer;
        
        // Insert  Endorsment      
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        insert endorse;
        
        // Insert Endorsment Version
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        // Insert Policy Endorsement        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        poicyEndorse.Policy_Lawyer__c = polLawyer.Id;
        insert poicyEndorse;
        
        List<Policy_Endorsement__c> policyEndorsmentList = [select id,name,Endorsement_Number__c from Policy_Endorsement__c where Endorsement_Number__c=:'IL 153'];
        ApexPages.StandardController sc = new ApexPages.StandardController(policyEndorsmentList[0]);
        PolicyEndorsementEditExtension obj = new PolicyEndorsementEditExtension(sc);
        obj.returnToEditPage();
        
    }   
}