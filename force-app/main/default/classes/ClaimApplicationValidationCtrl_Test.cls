@isTest
public class ClaimApplicationValidationCtrl_Test {
    @isTest
    public static void testMethod1(){
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
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
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        insert calimset;
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        insert acctivePolicy;
        
        Policy_Lawyer__c policyLawyerObj = TestDataFactory.createPolicyLawyer(acc.Id,acctivePolicy.Id,acj.Id);
        insert policyLawyerObj;
        
        Policy_Claim__c  policyClaimObj = TestDataFactory.createPolicyClaim(acctivePolicy.Id,policyLawyerObj.Id);
        insert policyClaimObj;
        
        ClaimApplicationValidationCtrl.getPolicyClaim(policyClaimObj.Id);  
        
    }
}