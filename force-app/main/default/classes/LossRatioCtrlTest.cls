@isTest
public class LossRatioCtrlTest {
    
    
    @testSetup
    static void testData(){
        
        // Insert Account
        Account acc = new Account();
        acc.Name = 'Test Account';
        Insert acc;
        
        // Insert Contact
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        Insert con;
        
        // Insert Policy
        Policy__c pol = new Policy__c();
        pol.RecordTypeId = Schema.SObjectType.Policy__c.getRecordTypeInfosByName().get('Policy').getRecordTypeId();
        pol.Account__c = acc.id;
        pol.Premium__c = 1000;
        pol.Effective_Date__c = date.today();
        pol.Expiration_Date__c = date.today();
        pol.Policy_Retroactive_Date__c = date.today();
        Insert pol;
        
        // Insert Lawyer
        AccountContactJunction__c lawyer = new AccountContactJunction__c();
        lawyer.Account__c = acc.id;
        lawyer.Contact__c = con.id;
        Insert lawyer;
        
        // Insert Claim Setting to prevert Policy_Claim_Gateway trigger at Line 102: List Index outofbound
        Claim_Setting__c claimSetting = new Claim_Setting__c();
        claimSetting.Deductible_LAE_Applied_After__c = 100;
        Insert claimSetting;
        
        // Insert Policy Lawyer
        Policy_Lawyer__c policyLawyer = new Policy_Lawyer__c();
        policyLawyer.Policy__c = pol.id;
        policyLawyer.Lawyer__c = lawyer.id;
        policyLawyer.Prior_Act_Date__c = date.today();
        Insert policyLawyer;
        
        // Insert Claim
        Policy_Claim__c claim = new Policy_Claim__c();
        claim.File_Type__c = 'Claim';
        claim.Account__c = acc.id;
        claim.Policy__c = pol.id;
        claim.Occur_Date__c = date.today();
        claim.Claim_Made_Date__c = date.today();
        claim.Report_Date__c = date.today();
        claim.Lawyer__c = policyLawyer.id;
        claim.GL_5000__c  = 100;
        claim.GL_2100__c  = 100;
        claim.GL_5030__c  = 100;
        claim.GL_2140__c  = 100;
        Insert claim;
        
    }
    
    @isTest 
    static void testForAccountRecord(){
        Test.startTest();
        List<Account> accList = [SELECT ID FROM Account];
        LossRatioCtrl.checkSobjectType(accList[0].id);
        Test.stopTest();
    }
    
    
    @isTest 
    static void testForPolicyRecord(){
        Test.startTest();
        List<Policy__c> polList = [SELECT ID FROM Policy__c];
        LossRatioCtrl.checkSobjectType(polList[0].id);
        Test.stopTest();
    }
    
    @isTest 
    static void testForNullRecord(){
        Test.startTest();
        LossRatioCtrl.checkSobjectType(null);
        Test.stopTest();
    }
    
    @isTest 
    static void testForNull_getPolicyRecord(){
        Test.startTest();
        LossRatioCtrl.getPolicyRecord(null);
        Test.stopTest();
    }
    
    @isTest 
    static void testForNull_getAccountPolicyRecord(){
        Test.startTest();
        LossRatioCtrl.getAccountPolicyRecord(null);
        Test.stopTest();
    }

}