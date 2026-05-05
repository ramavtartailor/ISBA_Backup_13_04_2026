@isTest
public class HighlightsPanelCtrl_Test {
    
    
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
    
    
    @isTest
    static void getPolicyDetails_Test(){
        
        List<Policy__c> policyList = [select id,RecordType.Name,Account__c,Account__r.Website__c,Limit__r.Name from Policy__c Where RecordType.Name=:'Application'];
        System.assertEquals('Application', policyList[0].RecordType.Name);
        
        List<Policy__c> policyList1 = [select id,RecordType.Name from Policy__c Where RecordType.Name=:'Policy'];
        HighlightsPanelCtrl.getPolicyDetails(String.valueOf(policyList[0].id));
        HighlightsPanelCtrl.hasBlocks(String.valueOf(policyList[0].id));
        //HighlightsPanelCtrl.typeOfPolicy(String.valueOf(policyList[0].id));
        HighlightsPanelCtrl.typeOfPolicy(String.valueOf(policyList1[0].id));
        HighlightsPanelCtrl.has107(String.valueOf(policyList[0].id));
        HighlightsPanelCtrl.getCurrentPolicy(String.valueOf(policyList[0].id));
       
        
    }
    @isTest
    static void getContactDetails_Test(){
        Contact con = [SELECT id from Contact limit 1];
        HighlightsPanelCtrl.getContactDetail(con.Id);
    }
    @isTest
    static void getPolicyDetails_Test2515(){
        
        //List<Policy__c> policyList = [select id,RecordType.Name from Policy__c Where (NOT Account__r.Website__c=Null) AND (NOT Account__r.Website__c LIKE 'http%')];
        //System.assertEquals('Application', policyList[0].RecordType.Name);
        
        
        /*List<Policy__c> policyList = [select id,RecordType.Name from Policy__c LIMIT 10];
        for(Policy__c currPolicy:  policyList){
            HighlightsPanelCtrl.getPolicyDetails(String.valueOf(currPolicy.id));
        }*/
        
        List<Policy__c> policyList = [select id,RecordType.Name,Account__c,Account__r.Website__c,Limit__r.Name from Policy__c Where RecordType.Name=:'Application'];
        ILF_Coverage_Factor__c coverageFactorObj = [SELECT Id FROM ILF_Coverage_Factor__c LIMIT 1];
        Deductible_Factor__c dedFactorObj = [SELECT Id FROM Deductible_Factor__c LIMIT 1];
        
        Policy__c currPolicy= policyList[0];
        //currPolicy.RecordType.Name = 'Application';
        currPolicy.Limit__r.Name=null;
        currPolicy.Premium__c=null;
        
        System.assertEquals('Application', currPolicy.RecordType.Name);
        System.assertEquals(null, currPolicy.Limit__r.Name);
        System.assertEquals(null, currPolicy.Premium__c);
        //HighlightsPanelCtrl.getPolicyDetails(currPolicy.id);
                
        //Policy__c newPolicy= new Policy__c();
        currPolicy.Account__r.Website__c='ttp://salesforce.com';
        //insert currPolicy;
        
        System.assertEquals(currPolicy.Account__r.Website__c,'ttp://salesforce.com');
        
        Policy_Quote__c currQuote = TestDataFactory.createPolicyQuote(currPolicy.Id,coverageFactorObj.Id,dedFactorObj.id);
        currQuote.Policy__c=currPolicy.Id;
        //if(quotes.size() == 1) should be true;
        insert currQuote;
        
        HighlightsPanelCtrl.getPolicyDetails(String.valueOf(currPolicy.id));
        HighlightsPanelCtrl.hasBlocks(String.valueOf(currPolicy.id));
        HighlightsPanelCtrl.typeOfPolicy(String.valueOf(currPolicy.id));
        HighlightsPanelCtrl.typeOfPolicy(String.valueOf(currPolicy.id));
        HighlightsPanelCtrl.has107(String.valueOf(currPolicy.id));
        HighlightsPanelCtrl.getCurrentPolicy(String.valueOf(currPolicy.id));
        
    }
    
     @isTest
    static void getPolicyDetails_Test_P(){
        date mydate = date.today().addDays(1);
        List<Policy__c> policyList1 = [select id,RecordType.Name from Policy__c Where RecordType.Name=:'Policy' AND ERE_Date__c=: mydate];
        List<Policy_Endorsement__c> PolEnd = [select id,Event_Status__c from Policy_Endorsement__c WHERE Policy__c =: policyList1[0].Id];
        Policy_Endorsement__c MypolEnd= PolEnd[0];
        MypolEnd.Event_Status__c='Complete';
        MypolEnd.Endorsement_Number__c='IL 107';
        MypolEnd.ERE_Expiration_Date__c = date.today().addDays(2);
        //update MypolEnd;
        
        
        HighlightsPanelCtrl.getPolicyDetails(policyList1[0].Id);
        HighlightsPanelCtrl.hasBlocks(policyList1[0].Id);
        HighlightsPanelCtrl.typeOfPolicy(policyList1[0].Id);
        HighlightsPanelCtrl.typeOfPolicy(policyList1[0].Id);
        HighlightsPanelCtrl.has107(policyList1[0].Id);
        HighlightsPanelCtrl.getCurrentPolicy(policyList1[0].Id);
        
        
        MypolEnd.Endorsement_Number__c='IL 107B';
        //upsert MypolEnd;
        
        HighlightsPanelCtrl.has107(policyList1[0].Id);
        
        MypolEnd.Endorsement_Number__c='IL 107C';
        //upsert MypolEnd;
        
        HighlightsPanelCtrl.has107(policyList1[0].Id);
        
        MypolEnd.Endorsement_Number__c='IL 107D';
        //upsert MypolEnd;
        
        HighlightsPanelCtrl.has107(policyList1[0].Id);
        
    }
    
     @isTest
    static void getPolicyDetails_Test1(){
       
        List<Account> accList = [select id from Account];
        List<Policy__c> policyList = [select id,RecordType.Name,Effective_Date__c from Policy__c Where Effective_Date__c > today ];
        HighlightsPanelCtrl.typeOfPolicy(String.valueOf(policyList[0].id));
        HighlightsPanelCtrl.has107(accList[0].Id);
        
    }
    
    @isTest
    static void getPolicyDetails_Test2(){
       
        List<Policy__c> policyList = [select id,Account__c,RecordType.Name,Effective_Date__c from Policy__c Where Effective_Date__c > today ];
        HighlightsPanelCtrl.typeOfPolicy(String.valueOf(policyList[0].id));
        
    }
    
    @isTest
    static void getAccountDetails_Test(){
        
        List<Account> accList = [select id from Account];
        HighlightsPanelCtrl.getAccountDetails(String.valueOf(accList[0].id));
        HighlightsPanelCtrl.hasBlocks(String.valueOf(accList[0].id));
    }
    
    
    @isTest
    static void getClaimDetails_Test(){
        
        List<Policy_Claim__c> policyClaimList = [select id from Policy_Claim__c];
        HighlightsPanelCtrl.getClaimDetails(String.valueOf(policyClaimList[0].id));
        HighlightsPanelCtrl.hasBlocks(String.valueOf(policyClaimList[0].id));
    }
    
    @isTest
    static void getContacts_Test(){
        
        List<AccountContactRelation> acrList = [select id from AccountContactRelation];
        HighlightsPanelCtrl.getContacts(String.valueOf(acrList[0].id));
    }
    
    @isTest
    static void updateContact_Test(){
        List<Contact> conList = [select id from Contact];
        List<Policy__c> policyList = [select id,RecordType.Name from Policy__c Where RecordType.Name=:'Application'];
        HighlightsPanelCtrl.updateContact(String.valueOf(conList[0].id),String.valueOf(policyList[0].id));
    }
    
    
    @isTest
    static void updateContact_Test_1(){
        List<Account> accList = [select id from Account];
        List<Policy__c> policyList = [select id,RecordType.Name from Policy__c Where RecordType.Name=:'Application'];
        HighlightsPanelCtrl.updateContact(String.valueOf(accList[0].id),String.valueOf(policyList[0].id));
    }
    
    @isTest
    static void updateBillingContact_Test_1(){
        List<Account> accList = [select id from Account];
        List<Policy__c> policyList = [select id,RecordType.Name from Policy__c Where RecordType.Name=:'Application'];
        HighlightsPanelCtrl.updateBillingContact(String.valueOf(accList[0].id),String.valueOf(accList[0].id));
    }
    
    
    @isTest
    static void hasBlocks_Claim_Test(){
        Policy_Claim__c claim = [SELECT Id FROM Policy_Claim__c LIMIT 1];
        Boolean res = HighlightsPanelCtrl.hasBlocks(claim.Id);
        System.assertNotEquals(null, res);
    }
    
    @isTest
    static void hasBlocks_Policy_Test(){
        Policy__c pol = [SELECT Id FROM Policy__c LIMIT 1];
        Boolean res = HighlightsPanelCtrl.hasBlocks(pol.Id);
        System.assertNotEquals(null, res);
    }
    
    @isTest
    static void searchAccount_Test(){
        List<Account> accs = HighlightsPanelCtrl.searchAccount('Test');
        System.assertNotEquals(null, accs);
    }
    
    @isTest
    static void updateApplicationUser_Test(){
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        User u = [SELECT Id FROM User LIMIT 1];
        
        Customer_Application__c app = new Customer_Application__c(
            Account__c = acc.Id,
            Application_Status__c = 'New'
        );
        insert app;
        
        HighlightsPanelCtrl.updateApplicationUser(
            app.Id,
            u.Id,
            u.Id
        );
    }
    
    @isTest
    static void getCustomerApplication_Test(){
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Customer_Application__c app = new Customer_Application__c(
            Account__c = acc.Id,
            Application_Status__c = 'New'
        );
        insert app;
        
        HighlightsPanelCtrl.getCustomerApplication(app.Id);
    }
    
    @isTest
    static void updateApplicationAccount_Test(){
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Customer_Application__c app = new Customer_Application__c(
            Account__c = acc.Id,
            Application_Status__c = 'New'
        );
        insert app;
        
        HighlightsPanelCtrl.updateApplicationAccount(app.Id, acc.Id);
        HighlightsPanelCtrl.updateApplicationAccount(app.Id, null);
    }
    
 
    
    
    
   
    
    
    
   
    
    
    
    
}