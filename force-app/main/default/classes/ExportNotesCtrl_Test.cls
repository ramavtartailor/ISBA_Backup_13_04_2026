@isTest
public class ExportNotesCtrl_Test {
    
    @testSetup
    static void testData(){
        
        // Insert Accounts
        Account acc = TestDataFactory.createAccounts('Bucket Account');
        insert acc;
        
        // Insret Contact        
        Contact con = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        // Insert Opportunity        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        // Insert Master factor fro Step Rate        
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        // Insert County        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        // Insert geo factor        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        // Insert Policy
        Policy__c policy = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Policy');
        insert policy;
        
         // Create Account Contact Junction     
        AccountContactJunction__c accConJunc = TestDataFactory.createAccConJunc(acc.id,con.id);
        insert accConJunc;
        
        // Insert Policy Lawyer
        Policy_Lawyer__c policyLawyer = TestDataFactory.createPolicyLawyer(policy.Account__c,policy.id,accConJunc.id);
        policyLawyer.Active__c = true;
        insert policyLawyer;
        
        // Custom Setting
        Claim_Setting__c  customSetting = TestDataFactory.createClaimSetting();
        insert customSetting;
        
        // Insert Policy Claim
        Policy_Claim__c policyClaim = TestDataFactory.createPolicyClaim(policy.id,policyLawyer.id);
        policyClaim.Account__c = acc.id;
        insert policyClaim;
     
    }
    
    
    /************************
     * For : Account Record
     * 
     * ***********************/
    
    @isTest
    static void ExportNotesCtrl_testMethod(){
        
        List<Account> accList = [select id from Account];
        
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',accList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View All Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','All');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    @isTest
    static void ExportNotesCtrl_testMethod_1(){
        
        List<Account> accList = [select id from Account];
        
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',accList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View All Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','Test');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    @isTest
    static void ExportNotesCtrl_testMethod_2(){
        
        List<Account> accList = [select id from Account];
        
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',accList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','Test');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','All');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    @isTest
    static void ExportNotesCtrl_testMethod_3(){
        
        List<Account> accList = [select id from Account];
        
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',accList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','Test');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','Test');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
     /************************
     * For : Policy__c
     * 
     * ***********************/
    
    
    @isTest
    static void ExportNotesCtrl_testMethod_4(){
        
        List<Policy__c> policyList = [select id from Policy__c];
        
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View All Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','All');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
     @isTest
    static void ExportNotesCtrl_testMethod_P(){
        
        List<Policy__c> policyList = [select id from Policy__c];
        
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('recordId',policyList[0].id);
        pageRef.getParameters().put('selectedFilterValue','View This Policy Notes');
        pageRef.getParameters().put('selectedNoteTypeFilterValue','All');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        pageRef.getParameters().put('selectedNoteTypeFilterValue','test');
        ExportNotesCtrl ctrl2 = new ExportNotesCtrl();
        
        Test.stopTest();
    }
    
    @isTest
    static void ExportNotesCtrl_testMethod_5(){
        
        List<Policy__c> policyList = [select id from Policy__c];
        
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View All Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','Test');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    @isTest
    static void ExportNotesCtrl_testMethod_6(){
        
        List<Policy__c> policyList = [select id from Policy__c];
        
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View All Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','All');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    @isTest
    static void ExportNotesCtrl_testMethod_7(){
        
        List<Policy__c> policyList = [select id from Policy__c];
        
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View All Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','Test');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    
    @isTest
    static void ExportNotesCtrl_testMethod_8(){
        
        List<Policy__c> policyList = [select id from Policy__c];
        
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View All Policy Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','All');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    @isTest
    static void ExportNotesCtrl_testMethod_9(){
        
        List<Policy__c> policyList = [select id from Policy__c];
        
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View All Policy Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','Test');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    @isTest
    static void ExportNotesCtrl_testMethod_10(){
        
        List<Policy__c> policyList = [select id from Policy__c];
        
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View All Policy Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','All');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    @isTest
    static void ExportNotesCtrl_testMethod_11(){
        
        List<Policy__c> policyList = [select id from Policy__c];
        
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View All Policy Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','Test');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    
    @isTest
    static void ExportNotesCtrl_testMethod_12(){
        
        List<Policy__c> policyList = [select id from Policy__c];
        
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View This Policy Claim Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','All');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    @isTest
    static void ExportNotesCtrl_testMethod_13(){
        
        List<Policy__c> policyList = [select id from Policy__c];
        
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View This Policy Claim Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','Test');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    @isTest
    static void ExportNotesCtrl_testMethod_14(){
        
        List<Policy__c> policyList = [select id from Policy__c];
        
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View This Policy Claim Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','All');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    @isTest
    static void ExportNotesCtrl_testMethod_15(){
        
        List<Policy__c> policyList = [select id from Policy__c];
        
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View This Policy Claim Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','Test');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
     /************************
     * For : Policy_Claim__c
     * 
     * ***********************/
    
    
    @isTest
    static void ExportNotesCtrl_testMethod_16(){
        
        List<Policy_Claim__c> policyClaimList = [select id,Account__c from Policy_Claim__c];
        System.debug('policyClaimList--'+policyClaimList);
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyClaimList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View All Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','All');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    @isTest
    static void ExportNotesCtrl_testMethod_17(){
        
        List<Policy_Claim__c> policyClaimList = [select id,Account__c from Policy_Claim__c];
        System.debug('policyClaimList--'+policyClaimList);
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyClaimList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View All Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','Test');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    
     @isTest
    static void ExportNotesCtrl_testMethod_18(){
        
        List<Policy_Claim__c> policyClaimList = [select id,Account__c from Policy_Claim__c];
        
        System.debug('policyClaimList--'+policyClaimList);
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyClaimList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View All Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','All');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    @isTest
    static void ExportNotesCtrl_testMethod_19(){
        
        List<Policy_Claim__c> policyClaimList = [select id,Account__c from Policy_Claim__c];
        
        System.debug('policyClaimList--'+policyClaimList);
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyClaimList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View All Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','Test');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
     @isTest
    static void ExportNotesCtrl_testMethod_20(){
        
        List<Policy_Claim__c> policyClaimList = [select id,Account__c from Policy_Claim__c];
        System.debug('policyClaimList--'+policyClaimList);
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyClaimList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View This Claim Policy Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','All');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    @isTest
    static void ExportNotesCtrl_testMethod_21(){
        
        List<Policy_Claim__c> policyClaimList = [select id,Account__c from Policy_Claim__c];
        System.debug('policyClaimList--'+policyClaimList);
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyClaimList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View This Claim Policy Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','Test');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    
     @isTest
    static void ExportNotesCtrl_testMethod_22(){
        
        List<Policy_Claim__c> policyClaimList = [select id,Account__c from Policy_Claim__c];
        
        System.debug('policyClaimList--'+policyClaimList);
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyClaimList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View This Claim Policy Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','All');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    @isTest
    static void ExportNotesCtrl_testMethod_23(){
        
        List<Policy_Claim__c> policyClaimList = [select id,Account__c from Policy_Claim__c];
        
        System.debug('policyClaimList--'+policyClaimList);
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyClaimList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','View This Claim Policy Notes');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','Test');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    @isTest
    static void ExportNotesCtrl_testMethod_24(){
        
        List<Policy_Claim__c> policyClaimList = [select id,Account__c from Policy_Claim__c];
        
        System.debug('policyClaimList--'+policyClaimList);
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyClaimList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','Test');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','All');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    
    @isTest
    static void ExportNotesCtrl_testMethod_25(){
        
        List<Policy_Claim__c> policyClaimList = [select id,Account__c from Policy_Claim__c];
        
        System.debug('policyClaimList--'+policyClaimList);
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',policyClaimList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','Test');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','Test');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
    
    @isTest
    static void ExportNotesCtrl_testMethod_26(){
        
        List<Contact> conList = [select id from Contact];
        
        Test.startTest();
        PageReference pageRef = Page.ExportNotes;
        ApexPages.currentPage().getParameters().put('recordId',conList[0].id);
        ApexPages.currentPage().getParameters().put('selectedFilterValue','Test');
        ApexPages.currentPage().getParameters().put('selectedNoteTypeFilterValue','Test');
        ExportNotesCtrl ctrl = new ExportNotesCtrl();
        Test.stopTest();
    }
 
    
}