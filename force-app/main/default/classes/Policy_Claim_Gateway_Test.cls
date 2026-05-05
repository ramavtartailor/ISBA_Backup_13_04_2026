@isTest
private class Policy_Claim_Gateway_Test {

    @testSetup
    static void setup(){
        
        Account acc                   = TestDataFactory.createAccounts('Bucket Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        con.FirstName                 = 'Test';
        con.Type__c                   = 'Lawyer';
        con.Contact_Role__c           = 'P';
        con.AccountId                 = acc.Id;
        insert con;
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        List<AcctSeed__GL_Account__c> glAccounts = TestDataFactory.createGLAccounts();        
        insert glAccounts;
        
        List<AcctSeed__Billing_Format__c> billingFormats = TestDataFactory.createBillingFormats();        
        insert billingFormats ;
        
        List<AcctSeed__Ledger__c> ledgers = TestDataFactory.createLedgers(glAccounts[0].id,billingFormats[0].id,billingFormats[1].id,billingFormats[2].id,billingFormats[3].id,billingFormats[4].id);
        insert ledgers;
        
        AcctSeed__Accounting_Settings__c settings = TestDataFactory.createAccountsetting(ledgers[0].id,glAccounts[0].Id,glAccounts[1].Id,glAccounts[2].Id,glAccounts[3].Id,glAccounts[4].Id,glAccounts[5].Id,glAccounts[6].Id,billingFormats[0].Id);
        insert settings;
        
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
        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoverageFactor(MasterFactorCoverage.Id);
        FactorCoverage.Percentage_5X5_Step_0__c =3;
        FactorCoverage.Percentage_5X5_Step_1__c=4;
        FactorCoverage.Percentage_5X5_Step_2__c=5;
        FactorCoverage.Percentage_5X5_Step_3__c=6;
        FactorCoverage.Percentage_5X5_Step_4__c=8;
        FactorCoverage.Premium_Rate_5X5__c = 33;
        FactorCoverage.Is_5X5_Coverage__c = true;
        insert FactorCoverage;
        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor','Deductible');
        insert mas12;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        Insert DedFac; 
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorNew.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        insert acctivePolicy;
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Endorsement_Version__c endorseVersion2 = TestDataFactory.createEndorsementVersion(endorse.Id);
        endorseVersion2.Endorsement_Version_Number__c='2';
        insert endorseVersion2;
        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        insert poicyEndorse;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Claim_Setting__c claimSet = TestDataFactory.createClaimSetting();
        insert claimSet;
        
        Policy_Lawyer__c polLawyerObj = TestDataFactory.createPolicyLawyer(acc.Id,acctivePolicy.Id,acj.Id);
        insert polLawyerObj;
        
        Policy_Claim__c  polClaimObj = TestDataFactory.createPolicyClaim(acctivePolicy.Id,polLawyerObj.Id);
        insert polClaimObj;
        polClaimObj.Reserve_LAE__c = 0;
        update polClaimObj;
        
        List<Policy_Claim_Detail__c> PCDList =  new List<Policy_Claim_Detail__c>();
        
        Policy_Claim_Detail__c polClaimDetailObj = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Claim Payment', polClaimObj.Id,'Loss Payment'); 
        //polClaimDetailObj.LAE_Amount__c = 7000;
        PCDList.add(polClaimDetailObj);
        
        Policy_Claim_Detail__c polClaimDetailObj1 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Claim Payment', polClaimObj.Id,'LAE Payment');
        //polClaimDetailObj1.LAE_Amount__c = 5000;
        PCDList.add(polClaimDetailObj1);
        
        Policy_Claim_Detail__c polClaimDetailObj2 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Deductible', polClaimObj.Id,'Deductible Loss');
        PCDList.add(polClaimDetailObj2);
        
        Policy_Claim_Detail__c polClaimDetailObj2_1 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Deductible', polClaimObj.Id,'Deductible Expense');
        PCDList.add(polClaimDetailObj2_1);
        
        Policy_Claim_Detail__c polClaimDetailObj3 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Deductible', polClaimObj.Id,'Deductible Expense New');
        PCDList.add(polClaimDetailObj3);
        
        Policy_Claim_Detail__c polClaimDetailObj4 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Reinsurance', polClaimObj.Id,'Change in Ceded LAE Reserve');
        PCDList.add(polClaimDetailObj4);
        
        Policy_Claim_Detail__c polClaimDetailObj5 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Reinsurance', polClaimObj.Id,'Change in Ceded Loss Reserve');
        PCDList.add(polClaimDetailObj5);
        
        Policy_Claim_Detail__c polClaimDetailObj6 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Reinsurance', polClaimObj.Id,'Due from Reins. - LAE');
        PCDList.add(polClaimDetailObj6);
        
        Policy_Claim_Detail__c polClaimDetailObj7 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Reinsurance', polClaimObj.Id,'Due from Reins. - Loss');
        PCDList.add(polClaimDetailObj7);
        
        Policy_Claim_Detail__c polClaimDetailObj8 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Unallocated LAE', polClaimObj.Id,'Unallocated LAE Payment');
        PCDList.add(polClaimDetailObj8);
        
        Policy_Claim_Detail__c polClaimDetailObj9 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Reserve', polClaimObj.Id,'User Reserve');
        //polClaimDetailObj9.LAE_Amount__c = 0;
        //polClaimDetailObj9.Loss_Amount__c = 0;
        PCDList.add(polClaimDetailObj9);
        
        Policy_Claim_Detail__c polClaimDetailObj10 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Reserve', polClaimObj.Id,'Reopen Reserve');
        PCDList.add(polClaimDetailObj10);
        
        Policy_Claim_Detail__c polClaimDetailObj11 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Reserve', polClaimObj.Id,'Close Reserve');
        PCDList.add(polClaimDetailObj11);
        
        Policy_Claim_Detail__c polClaimDetailObj12 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Reserve', polClaimObj.Id,'Claim Coverage - ARDC');
        //PCDList.add(polClaimDetailObj12);
        
        
        insert PCDList;
        
    }
    
    
    @isTest
    static void InsertReserveOpenRecord_Test(){
        List<Policy_Claim__c> policyClaimList =  [Select id,Is_Reserve_Creation_Block__c,Legacy_Import__c,Reserve_Loss__c,
                                                  Reserve_LAE__c,Report_Date__c,File_Type__c from Policy_Claim__c Limit 200];
        
        Test.startTest();
        Policy_Claim_Gateway.InsertReserveOpenRecord(policyClaimList);
        Test.stopTest();
    }
    
    @isTest
    static void UpdateClaimCheck_Test(){
        List<Policy_Claim__c> policyClaimList =  [Select id,Is_Reserve_Creation_Block__c,Legacy_Import__c,Reserve_Loss__c,
                                                  Reserve_LAE__c,Report_Date__c,File_Type__c,Claim__c from Policy_Claim__c Limit 200];
        
        Test.startTest();
        Policy_Claim_Gateway.UpdateClaimCheck(policyClaimList);
        Test.stopTest();
    }
    
    @isTest
    static void UpdateClaimCheck_Test_1(){
        List<Policy_Claim__c> policyClaimList =  [Select id,Is_Reserve_Creation_Block__c,Legacy_Import__c,Reserve_Loss__c,
                                                  Reserve_LAE__c,Report_Date__c,File_Type__c,Claim__c,Incident__c from Policy_Claim__c Limit 200];
        
        for(Policy_Claim__c pcl : policyClaimList){
            pcl.File_Type__c = 'Incident';
            pcl.Incident__c = false;
        }
        Test.startTest();
        Policy_Claim_Gateway.UpdateClaimCheck(policyClaimList);
        Test.stopTest();
    }
    
    @isTest
    static void UpdateClaimCheck_Test_2(){
        List<Policy_Claim__c> policyClaimList =  [Select id,Is_Reserve_Creation_Block__c,Legacy_Import__c,Reserve_Loss__c,
                                                  Reserve_LAE__c,Report_Date__c,File_Type__c,Claim__c,Suit__c from Policy_Claim__c Limit 200];
        
        for(Policy_Claim__c pcl : policyClaimList){
            pcl.File_Type__c = 'Suit';
            pcl.Suit__c = false;
        }
        Test.startTest();
        Policy_Claim_Gateway.UpdateClaimCheck(policyClaimList);
        Test.stopTest();
    }
    
    
    @isTest
    static void InsertReserveRecord_Test(){
        Map<id,Policy_Claim__c> newClaimMap = new Map<id,Policy_Claim__c>([Select id,Is_Reserve_Creation_Block__c,Legacy_Import__c,Reserve_Loss__c,Ceded_Cutoff_Amount__c,
                                                  Reserve_LAE__c,Report_Date__c,File_Type__c,Claim__c,Claim_Status__c,Payment_Direct_Loss__c,
                                                                           Unpaid_Reserves_Direct_Loss__c,Payment_Direct_LAE__c from Policy_Claim__c Limit 200]);
        
        Map<id,Policy_Claim__c> oldClaimMap = new Map<id,Policy_Claim__c>([Select id,Is_Reserve_Creation_Block__c,Legacy_Import__c,Reserve_Loss__c,Ceded_Cutoff_Amount__c,
                                                  Reserve_LAE__c,Report_Date__c,File_Type__c,Claim__c,Claim_Status__c from Policy_Claim__c Limit 200]);
        for(Policy_Claim__c pcl : newClaimMap.values()){
            pcl.Claim_Status__c = 'Open';
            pcl.Reserve_LAE__c = 100;
            pcl.Reserve_Loss__c=200;
            pcl.GL_5010__c = 10;
            pcl.GL_5035__c = 10;
            pcl.GL_5000__c = 10;
            pcl.GL_2120__c = 10;
            pcl.GL_2160__c = 10;
            pcl.GL_5030__c = 10;
            
            pcl.Per_Claim_Deductible__c = 5;
            
        }
        Test.startTest();
        Policy_Claim_Gateway.InsertReserveRecord(oldClaimMap,newClaimMap);
        Test.stopTest();
    }
    
    @isTest
    static void InsertReserveRecord_Test_2(){
        Map<id,Policy_Claim__c> newClaimMap = new Map<id,Policy_Claim__c>([Select id,Is_Reserve_Creation_Block__c,Legacy_Import__c,Reserve_Loss__c,
                                                  Reserve_LAE__c,Report_Date__c,File_Type__c,Claim__c,Claim_Status__c,Payment_Direct_Loss__c,
                                                                           Unpaid_Reserves_Direct_LAE__c,Unpaid_Reserves_Direct_Loss__c from Policy_Claim__c Limit 200]);
        
        Map<id,Policy_Claim__c> oldClaimMap = new Map<id,Policy_Claim__c>([Select id,Is_Reserve_Creation_Block__c,Legacy_Import__c,Reserve_Loss__c,
                                                  Reserve_LAE__c,Report_Date__c,File_Type__c,Claim__c,Claim_Status__c from Policy_Claim__c Limit 200]);
        for(Policy_Claim__c pcl : newClaimMap.values()){
            pcl.Claim_Status__c = 'Closed';
        }
        Test.startTest();
        Policy_Claim_Gateway.InsertReserveRecord(oldClaimMap,newClaimMap);
        Test.stopTest();
    }
}