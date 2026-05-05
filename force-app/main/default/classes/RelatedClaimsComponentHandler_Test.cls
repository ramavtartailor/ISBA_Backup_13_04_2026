@isTest
public class RelatedClaimsComponentHandler_Test {
    
    
    @testSetup 
    static void testData(){
        
        Account acc = TestDataFactory.createAccounts('Test');
        insert acc;
        
        Contact con =  TestDataFactory.createContact('Last Name',acc.id);
        insert con;
        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        Policy__c policy = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Policy');
        Insert policy;
          
        AccountContactJunction__c accConJunc = TestDataFactory.createAccConJunc(acc.id,con.id);
        insert accConJunc;
        
        Policy_Lawyer__c policyLawyer = TestDataFactory.createPolicyLawyer(policy.Account__c,policy.id,accConJunc.id);
        policyLawyer.Active__c = true;
        insert policyLawyer;

        Claim_Setting__c  customSetting = TestDataFactory.createClaimSetting();
        insert customSetting;
        
        Policy_Claim__c policyClaim = TestDataFactory.createPolicyClaim(policy.id,policyLawyer.id);
        insert policyClaim;
        
        Related_Claim__c relClaim = new Related_Claim__c();
        relClaim.Claim1__c =  policyClaim.id;
        relClaim.Claim2__c =  policyClaim.id;
        insert relClaim;
        
    }
    
    @isTest
    static void getClaims_Test(){
        
        List<Policy_Claim__c> policyClaimList = [select id from Policy_Claim__c];
        RelatedClaimsComponentHandler.getClaims(policyClaimList[0].id, true);
        RelatedClaimsComponentHandler.typeOfRecord(policyClaimList[0].id);
    }
    
    @isTest
    static void getClaims_Test1(){
        
        List<Policy__c> policyList = [select id from Policy__c];
        RelatedClaimsComponentHandler.getClaims(policyList[0].id, true);
        RelatedClaimsComponentHandler.typeOfRecord(policyList[0].id);
    }
    
    @isTest
    static void getClaims_Test3(){
        
        List<Account> accList = [select id from Account];
        RelatedClaimsComponentHandler.getClaims(accList[0].id, true);
        RelatedClaimsComponentHandler.typeOfRecord(accList[0].id);
    }

}