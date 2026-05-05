@isTest
public class QuickPolicyController_Test {
    
    @isTest static void TestMethod1() {
        
        Account acc = TestDataFactory.createAccounts('Bucket Account');
        insert acc;
        
        
        Master_Factor__c objMasterFactor = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert objMasterFactor;
        
        Step_Rate_Factor__c objStep = TestDataFactory.createStepFactor(objMasterFactor.Id);
        insert objStep;     
        
        Master_Factor__c objMasterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert objMasterFactor1;
        
        Base_Factor__c objBase = TestDataFactory.createBaseFactor(objMasterFactor1.Id);
        insert objBase;
        
        
        Claim_Setting__c objClaims = TestDataFactory.createClaimSetting();
        insert objClaims;
        
        Policy__c objPol = TestDataFactory.createPolicy(acc.id,null,null,'Application');
        objPol.Is_Accepted_Confirm__c = true;
        objPol.Is_Allow_to_Generate_AS__c = true;
        insert objPol;
        
        QuickPolicyController objQuickPolicy = new QuickPolicyController();
        QuickPolicyController.getPolicy(objPol.id);
        QuickPolicyController.getPolicies(objPol.id);
        QuickPolicyController.updatePolicy(objPol.id);
    }

}