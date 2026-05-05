@isTest
public class ManageEndorsementsExt_Test {
    @testSetup static void setup() {
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
        opp.StageName   = 'Application Sent';
        insert opp;
        
        Master_Factor__c masterfact =TestDataFactory.createMasterfactor('Coverage 10/1/2016 - 12/31/2016','Coverage');
        insert masterfact;
        
        ILF_Coverage_Factor__c coverFactor = TestDataFactory.createCoveragefactor(masterfact.Id);
        insert coverFactor;
        
        Master_Factor__c masterfact1 = TestDataFactory.createMasterfactor('Deductible 10/1/2016 - 12/31/2016','Deductible');
        insert masterfact1;
        
        Deductible_Factor__c deductible = TestDataFactory.createDeductiblefactor(masterfact1.Id);
        Insert deductible; 
        
        Policy__c pol = TestDataFactory.createPolicy(acc.id,opp.id,null,'Policy');
        //pol.Status__c = 'Accepted';
        pol.Account__c = acc.Id;
        pol.Limit__c = coverFactor.Id;
        pol.Deductible_ID__c = deductible.Id;
        pol.Firm_Mod__c = 1;
        pol.Base_Amount__c = 1000000;
        pol.Premium__c = 150;
        insert pol;
        
        List<Endorsement__c> objEndorsementList = new List<Endorsement__c>();
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
     
        objEndorsementList.add(endorse);
       
        insert objEndorsementList;
        
        
        
        
        
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
       
        
        Attachment attach = new Attachment(Name='Test Attach', Body= Blob.valueOf('test'), ParentId=pol.Id);
        insert attach;
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        
        Test.startTest();
        
        Policy__c  policy = policies[0];
        
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(policies[0].Account__c, conList[0].Id);
        insert junc;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(policies[0].Account__c,policies[0].Id,junc.Id);
        law.Active__c = true;
        law.Deleted_Lawyer__c = false;
        insert law;
        
        List<Policy_Endorsement__c> lstPolicyEndorsements = new List<Policy_Endorsement__c>();
        
        Policy_Endorsement__c policyEnd = TestDataFactory.createPolicyEndorsement(acc.id,policies[0].Id,'General');
        policyEnd.Event_Status__c = 'Pending';
        policyEnd.Lawyer__c = junc.id;
        policyEnd.Refund_Amount__c = 10;
        policyEnd.Additional_Premium__c = 100;
        
        lstPolicyEndorsements.add(policyEnd);
        
        insert lstPolicyEndorsements;
        
        AS_Transaction__c as_trans = TestDataFactory.createTransaction(lstPolicyEndorsements[0].Id,'Add Lawyer',100,pol.Id,null,pol.account__c,null,'Add Lawyer');
        insert as_trans;    
    }
    
    @isTest static void unitTest(){
        List<Endorsement__c> LstEnd = [select id,Endorsement_Record_Type_ID__c from Endorsement__c LIMIT 2];
    Endorsement__c endObj = new Endorsement__c();
        Test.startTest();
        List<Policy__c> Pollst = [Select id from Policy__c ];
        ApexPages.StandardController sc = new ApexPages.StandardController(LstEnd[0]);
            PageReference myVfPage = Page.ManageEndorsements;
           Test.setCurrentPage(myVfPage);
       String RecId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('origin','true');
         ApexPages.currentPage().getParameters().put('relatedId',Pollst[0].id);
        ManageEndorsementsExt Obj = new ManageEndorsementsExt(sc);
        obj.recordTypeId = RecId;
        obj.endorsementId = LstEnd[0].id;
        obj.addEndorsementFunc();
        obj.getRecordTypeNames();
        obj.removeEndorsementFunc(); 
        Test.stopTest();
    }
    
    
     
    @isTest static void unitTest1(){
        List<Endorsement__c> LstEnd = [select id,Endorsement_Record_Type_ID__c from Endorsement__c LIMIT 2];
        
        
    	Endorsement__c endObj = new Endorsement__c();
        Test.startTest();
        List<Policy__c> Pollst = [Select id from Policy__c ];
        Policy__c myPol = Pollst[0];
        myPol.Cancel_Date__c =null;
        upsert myPol;
        
        Endorsement__c myEnd =LstEnd[0];
        myEnd.Endorsement_Sub_Type__c='IL 102';
        upsert myEnd;
        
        List<Policy_Endorsement__c> PolEnd = [Select id from Policy_Endorsement__c];
        Policy_Endorsement__c myPolEnd = PolEnd[0];
        myPolEnd.Endorsement_Number__c ='IL 102';
        upsert myPolEnd;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(LstEnd[0]);
            PageReference myVfPage = Page.ManageEndorsements;
           Test.setCurrentPage(myVfPage);
           String RecId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('origin','false');
         ApexPages.currentPage().getParameters().put('relatedId',Pollst[0].id);
        ManageEndorsementsExt Obj = new ManageEndorsementsExt(sc);
        obj.recordTypeId = RecId;
        obj.endorsementId = LstEnd[0].id;
        obj.addEndorsementFunc();
        obj.getRecordTypeNames();
        obj.removeEndorsementFunc(); 
        
        
        myPolEnd.Endorsement_Number__c ='IL 153';
        upsert myPolEnd;
        
        myEnd.Endorsement_Sub_Type__c='IL 153';
        
        upsert myEnd;
        
        ApexPages.currentPage().getParameters().put('origin','false');
         ApexPages.currentPage().getParameters().put('relatedId',Pollst[0].id);
        ManageEndorsementsExt Obj2 = new ManageEndorsementsExt(sc);
        obj2.recordTypeId = RecId;
        obj2.endorsementId = LstEnd[0].id;
        obj2.index=0;
        obj2.addEndorsementFunc();
        obj2.removeEndorsementFunc();
        Test.stopTest();
    }
     
    @isTest static void unitTest2(){
         Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
         insert endorse;
    Endorsement__c endObj = new Endorsement__c();
        Test.startTest();
        List<Policy__c> Pollst = [Select id from Policy__c ];
        ApexPages.StandardController sc = new ApexPages.StandardController(endorse);
            PageReference myVfPage = Page.ManageEndorsements;
           Test.setCurrentPage(myVfPage);
       String RecId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        ApexPages.currentPage().getParameters().put('origin','true');
         ApexPages.currentPage().getParameters().put('relatedId',Pollst[0].id);
        ManageEndorsementsExt Obj = new ManageEndorsementsExt(sc);
       // obj.recordTypeId = RecId;
        obj.endorsementId = endorse.id;
        obj.addEndorsementFunc();
        obj.getRecordTypeNames();
        obj.removeEndorsementFunc(); 
        Test.stopTest();
    }


}