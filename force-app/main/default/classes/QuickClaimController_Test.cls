@isTest
private class QuickClaimController_Test {
    @isTest static void TestMethod1() {
        
        Test.startTest();
        
        Account acc = TestDataFactory.createAccounts('Bucket Account');
        insert acc;
        
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        Master_Factor__c objMasterFactor = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert objMasterFactor;

        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoveragefactor(objMasterFactor.Id);
        insert FactorCoverage;
        
        Step_Rate_Factor__c objStep = TestDataFactory.createStepFactor(objMasterFactor.Id);
        insert objStep;     
        
        Master_Factor__c objMasterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert objMasterFactor1;
        
        Base_Factor__c objBase = TestDataFactory.createBaseFactor(objMasterFactor1.Id);
        insert objBase;
        
        Claim_Setting__c objClaims = TestDataFactory.createClaimSetting();
        insert objClaims;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(objMasterFactor1.Id,county.Id);
        insert geo;
        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor1','Deductible');
        insert mas12;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        Insert DedFac; 
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = FactorCoverage.Id;
        acctivePolicy.Is_Accepted_Confirm__c = true;
        acctivePolicy.Is_Allow_to_Generate_AS__c = true;
        acctivePolicy.Deductible_ID__c = DedFac.id;
        insert acctivePolicy;
        
        Policy_Claim__c objPolClam = TestDataFactory.createPolicyClaim(acctivePolicy.Id,null);
        insert objPolClam;
        objPolClam.GL_5030__c = 0;
        objPolClam.GL_5035__c = 0;
        objPolClam.GL_5000__c = 0;
        objPolClam.GL_5010__c = 0;
        objPolClam.GL_2120__c = 100;
        objPolClam.GL_2160__c = 100;
        objPolClam.Reserve_LAE__c = 0;
        objPolClam.Per_Claim_Deductible__c = 0;
        update objPolClam;
        
        AcctSeed__Accounting_Period__c objPeriod = TestDataFactory.createAcctPeriod();
        objPeriod.AcctSeed__Start_Date__c = date.today().toStartOfMonth();
        objPeriod.AcctSeed__End_Date__c = date.today().toStartOfMonth().addMonths(1).addDays(-1); 
        insert objPeriod;
        
        date datt = date.today();
        QuickClaimController objQuickClaim = new QuickClaimController();
        QuickClaimController.getClaim(objPolClam.id);
        QuickClaimController.updateReserve(100,10,objPolClam,datt );
        QuickClaimController.updateClaimSummary(objPolClam.id);
        QuickClaimController.sendEmailAlert(new Set<String>{objPolClam.Id}, 'Incurred_Total_alert_email');
        Test.stopTest();
    }
   
}