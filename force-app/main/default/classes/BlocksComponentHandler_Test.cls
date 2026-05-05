@isTest
private class BlocksComponentHandler_Test {
    
    @testSetup 
    static void testData(){
        
        // Insert Account
        Account acc = TestDataFactory.createAccounts('Test Account');
        insert acc;
        
        // Insert Contact
        Contact con = TestDataFactory.createContact('Test', acc.id);
        insert con;
        
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        Master_Factor__c masterFactor = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert masterFactor;
        
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(masterFactor.Id);
        insert stepRateFactor;
        test.startTest();
        Master_Factor__c masterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert masterFactor1;
        
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(masterFactor1.Id);
        insert baseFactor;
        
        Map<String,String> mapRecordTypes = new Map<String,String>();
        
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoveragefactor(MasterFactorCoverage.Id);
        insert FactorCoverage;
        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor1','Deductible');
        insert mas12;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        Insert DedFac; 
        
        // Insert Policy
        Policy__c pol = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Application');
        pol.Limit__c = FactorCoverage.Id;
        pol.Deductible_ID__c = DedFac.id;
        insert pol;
    }
    
    @isTest
    static void getBlocks_Test(){
        List<Account> accList = [SELECT id FROM Account];
        BlocksComponentHandler.getBlocks(String.valueOf(accList[0].id),1,10,'CreatedDate',true);
        BlocksComponentHandler.getRecordTypeId(String.valueOf(accList[0].id));
        //BlocksComponentHandler.getTypeOfRecord(String.valueOf(accList[0].id));
    }
    
    @isTest
    static void Test1(){
        List<policy__c> polList =[select id from policy__c];
         BlocksComponentHandler.getBlocks(polList[0].id , 1 , 10, 'CreatedDate',true);
          BlocksComponentHandler.getRecordTypeId(polList[0].id);
        
        
    }
    
    
    @isTest
    static void getBlocks_Test2(){
        List<Contact> conList = [SELECT id FROM Contact];
        List<Account> accList = [SELECT id FROM Account];
        Application_Block__c Ab= New Application_Block__c();
        //Ab.Name = 'test AB';
        Ab.Status__c = 'Active';
        Insert Ab;
        
        BlocksComponentHandler.getBlocks(String.valueOf(conList[0].id),1,10,'CreatedDate',true);
        BlocksComponentHandler.getRecordTypeId(String.valueOf(conList[0].id));
        BlocksComponentHandler.getRecord();
        BlocksComponentHandler.changeStatusMethod(Ab.Id);
        BlocksComponentHandler.saveBlocks(accList[0].id,Ab);
    }
}