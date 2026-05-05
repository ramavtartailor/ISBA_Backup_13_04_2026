@isTest
public class CERTIFICATION_OF_INS_Template_Ctrl_Test {
	@isTest
    public static void testMethod1(){
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);        
        insert geo;
        
        Policy__c policyObj = TestDataFactory.createPolicy(acc.Id,opp.Id,geo.Id,'Policy');
        insert policyObj;
        
        CERTIFICATION_OF_INSURANCE_Template_Ctrl ctrl = new CERTIFICATION_OF_INSURANCE_Template_Ctrl();
        ctrl.setrecordId(policyObj.Id);
        ctrl.getrecordId();
        
    }
}