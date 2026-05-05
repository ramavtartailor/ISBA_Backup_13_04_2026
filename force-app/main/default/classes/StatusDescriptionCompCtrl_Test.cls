@IsTest
public class StatusDescriptionCompCtrl_Test {
     @testSetup
    static void testData(){
        
        Test.startTest();
        
        Account acc = TestDataFactory.createAccounts('Test');
        acc.Phone = '1234567890';
        acc.Recent_Policy_ID__c='test123';
        acc.Recent_Policy__c = 'test124';
        acc.Recent_Application_Id__c = 'test125';
        acc.Recent_Application__c = 'test126';
        acc.BillingCity = 'Chicago';
        acc.BillingState = 'Taxes';
        acc.BillingStreet = 'HJarrision Street';
        acc.AccountNumber = '234556';
        acc.Account_Number_External_ID__c = 'qscvbnhgfrt54756378';
        insert acc;
      
        Contact con = TestDataFactory.createContact('test127',acc.Id);
        con.Email = 'ee@gmail.com';
        con.Phone = '1234567890';
        insert con;
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
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
        coverageFactorObj.Name = null;
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy.Premium__c = null;
        acctivePolicy.ERE_Date__c = date.today().addDays(1);
        insert acctivePolicy;
        
        Policy__c Policy = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Application');
        Policy.Limit__c = coverageFactorObj.Id;
        Policy.Deductible_ID__c = dedFactorObj.Id;
        Policy.Premium__c = null;
        Policy.Account__c = acc.id;
        Policy.Effective_Date__c = date.today().addDays(-5);
        Policy.Expiration_Date__c = date.today();
        Policy.Cancel_Date__c = null;
        insert Policy;
        
        Policy__c Policy1 = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Policy');
        Policy.Limit__c = coverageFactorObj.Id;
        Policy.Deductible_ID__c = dedFactorObj.Id;
        Policy1.Premium__c = null;
        Policy1.Expiration_Date__c = date.today().addDays(17);
        Policy1.Cancel_Date__c = date.today().addDays(16);
        Policy1.Effective_Date__c = date.today().addDays(15);
        insert Policy1;
        
       
        
        Test.stopTest();
        /**
        Policy_Quote__c objPolQuote = TestDataFactory.createPolicyQuote(Policy.Id,coverageFactorObj.Id,dedFactorObj.id);
        insert objPolQuote;
        **/
        
        Master_Factor__c masterFactor = TestDataFactory.createMasterfactor('Test Master Factor0','Step Rate');
        insert masterFactor;
        
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(masterFactor.Id);
        insert stepRateFactor;
        
        Master_Factor__c masterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert masterFactor1;
        
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(masterFactor1.Id);
        insert baseFactor;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(acc.id,acctivePolicy.id,acj.Id);
        insert law; 
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        insert calimset;
        
        Policy_Claim__c claim = TestDataFactory.createPolicyClaim(acctivePolicy.id,law.id);
        insert claim;
        
        Note__c objNote = TestDataFactory.createNote(acctivePolicy.id);
        insert objNote;
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('','','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        AcctSeed__Accounting_Period__c lstPeriod = TestDataFactory.createAcctPeriod();
        insert lstPeriod;
        
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        objPolEndorse.Event_Status__c='Pending';
        objPolEndorse.Endorsement_Number__c='IL 107B';
        objPolEndorse.Endorsement_Effective_Date__c = system.today().addDays(-1);
        insert objPolEndorse;
        
       
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,acctivePolicy.id);
        insert aop;
    }

    @IsTest
    static void getRecord_Test() {

        Policy__c pol = [
            SELECT Id, Status_Description__c
            FROM Policy__c
            LIMIT 1
        ];

        Test.startTest();
        Policy__c result = StatusDescriptionCompCtrl.getRecord(pol.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(pol.Id, result.Id);
    }

    @IsTest
    static void saveRecord_Test() {

        Policy__c pol = [
            SELECT Id, Status_Description__c
            FROM Policy__c
            LIMIT 1
        ];

        pol.Status_Description__c = 'Updated from test';

        Test.startTest();
        String res = StatusDescriptionCompCtrl.saveRecord(pol);
        Test.stopTest();

        Policy__c updated = [
            SELECT Status_Description__c
            FROM Policy__c
            WHERE Id = :pol.Id
        ];

        System.assertEquals('Success', res);
        System.assertEquals('Updated from test', updated.Status_Description__c);
    }

    @IsTest
    static void getOnlineApp_Test() {

        Customer_Application__c app = new Customer_Application__c(
            Status_Description__c = 'Initial App Status'
        );
        insert app;

        Test.startTest();
        Customer_Application__c result =
            StatusDescriptionCompCtrl.getOnlineApp(app.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(app.Id, result.Id);
    }

    @IsTest
    static void saveOnlineApp_Test() {

        Customer_Application__c app = new Customer_Application__c(
            Status_Description__c = 'Before Update'
        );
        insert app;

        app.Status_Description__c = 'After Update';

        Test.startTest();
        String res = StatusDescriptionCompCtrl.saveOnlineApp(app);
        Test.stopTest();

        Customer_Application__c updated = [
            SELECT Status_Description__c
            FROM Customer_Application__c
            WHERE Id = :app.Id
        ];

        System.assertEquals('Success', res);
        System.assertEquals('After Update', updated.Status_Description__c);
    }
    
}