@isTest
public class CMRenewPolicy6MonthPriorSendEmailBTest {

    
    static testMethod void setup() {
        
        // Insert Account
        Account acc                   = TestDataFactory.createAccounts('Bucket Account');
        insert acc;
        
         // Insert Opportunity
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
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
        
        // Insert Master Factor
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor','Deductible');
        insert mas12;
        
        // Insert Deductible Factor
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        Insert DedFac; 
        
        // Insert Master Factor
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        // Insert Deductible Factor
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        con.Email = 'test@test.com';
        insert con;
        
        
        // Insert Policy
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Renew_Application__c = false;
        acctivePolicy.Limit__c = FactorCoverage.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy.Effective_Date__c = system.today().addDays(10);
        acctivePolicy.Expiration_Date__c = system.today().addDays(185);
        acctivePolicy.ClonedBy__c = '';
        acctivePolicy.Cancel_Date__c = Null;
        acctivePolicy.Firm_Contact__c = con.Id;
       insert acctivePolicy;
        
      
        Test.startTest();
        CMRenewPolicy6MonthPriorSendEmailBatch ba= new CMRenewPolicy6MonthPriorSendEmailBatch();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();
     }
    
    
}