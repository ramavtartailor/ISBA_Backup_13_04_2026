@isTest
public class AccountNotesComponentHandler_Test {
    @testSetup static void setup() {
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
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
        
        AcctSeed__Accounting_Settings__c accSetting = TestDataFactory.createAccountsetting(ledgers[0].id, glAccounts[0].id,glAccounts[1].id, glAccounts[2].id, glAccounts[3].id,glAccounts[4].id, glAccounts[5].id,glAccounts[6].id,billingFormats[0].id);
        insert accSetting;
        
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
        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoveragefactor(MasterFactorCoverage.Id);
        insert FactorCoverage;
        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor1','Deductible');
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
        
        Note__c nots =  TestDataFactory.createNote( acctivePolicy.id);
        Insert nots;
        
       
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        poicyEndorse.Endorsement_Effective_Date__c = system.today()+2;
        insert poicyEndorse;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,acctivePolicy.id);
        insert aop;
        
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(acctivePolicy.Account__c, con.Id);
        insert junc;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(acctivePolicy.Account__c,acctivePolicy.Id,junc.Id);
        law.Active__c = true;
        insert law;
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        insert calimset;
        
        Policy_Claim__c claim = TestDataFactory.createPolicyClaim(acctivePolicy.Id,law.id);
        insert claim;
        
        Master_Factor__c masterfact = TestDataFactory.createMasterfactor('Coverage','Coverage');
        insert masterfact;
        
        Master_Factor__c masterfact1 = TestDataFactory.createMasterfactor('Deductible 10/1/2016 - 12/31/2016','Deductible');
        insert masterfact1;
        
        Deductible_Factor__c deductible = TestDataFactory.createDeductiblefactor(masterfact1.Id);
        Insert deductible;
        
      /**  Policy_Quote__c objpolQut = TestDataFactory.createPolicyQuote(acctivePolicy.Id,coverageFactorObj.Id,dedFactorObj.Id);
        objpolQut.Adj_R_O__c = true;
        objpolQut.Policy__c = acctivePolicy.Id;
        insert objpolQut;**/
    }
    
    @isTest static void testMethod1() {
        
        Test.startTest(); 
        List<Account> lstAccount = [Select Id FROM Account];
        List<Policy__c> lstPolicy = [Select Id FROM Policy__c limit 1];
        List<Note__c> objNotes = [Select Id FROM Note__c limit 1];
        List<Policy_Claim__c> PolClaim = [Select Id FROM Policy_Claim__c limit 1];
        
        AccountNotesComponentHandler objAccNote = new AccountNotesComponentHandler ();
        AccountNotesComponentHandler.getNotes('CreatedDate',true,lstAccount[0].Id,'View All Notes',7,5,'ALL','Note__c','Type__c',true);
        AccountNotesComponentHandler.getNotes('CreatedDate',true,lstAccount[0].Id,'View All Notes',7,5,'FALL','Note__c','Type__c',true);
        AccountNotesComponentHandler.getNotes('CreatedDate',true,lstAccount[0].Id,'View All',7,5,'ALL','Note__c','Type__c',true);
        AccountNotesComponentHandler.getNotes('CreatedDate',true,lstAccount[0].Id,'View All',7,5,'FALL','Note__c','Type__c',true);
        AccountNotesComponentHandler.saveNotes(lstAccount[0].Id, objNotes[0]);
         
        Test.stopTest();
    }
    
    
    
    @isTest static void testMethod2(){
        
        Test.startTest(); 
        List<Account> lstAccount = [Select Id FROM Account];
        List<Policy__c> lstPolicy = [Select Id FROM Policy__c limit 1];
        List<Note__c> objNotes = [Select Id FROM Note__c limit 1];
        List<Policy_Claim__c> PolClaim = [Select Id FROM Policy_Claim__c limit 1];
        
        AccountNotesComponentHandler objAccNote = new AccountNotesComponentHandler ();
        AccountNotesComponentHandler.getNotes('CreatedDate',false,lstPolicy[0].Id,'View This Policy Notes',7,5,'ALL','Note__c','Type__c',true);//Piyush
        AccountNotesComponentHandler.getNotes('CreatedDate',false,PolClaim[0].Id,'View This Policy Notes',7,5,'ALL','Note__c','Type__c',true);
        AccountNotesComponentHandler.saveNotes(PolClaim[0].Id, objNotes[0]);
        Test.stopTest();
        
        
    }
    
    /*@isTest static void testMethod2() {
        
        Test.startTest(); 
        List<Account> lstAccount = [select id from account];
        List<Contact> conList = [SELECT Id FROM Contact];
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(lstAccount[0].id, conList[0].id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        Opportunity opp               = TestDataFactory.createOpp(lstAccount[0].id);
        insert opp;
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorNew.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(lstAccount[0].id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        insert acctivePolicy;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(acctivePolicy.Account__c,acctivePolicy.Id,acj.Id);
        law.Active__c = true;
        insert law;
        
        Policy_Claim__c polClaim = TestDataFactory.createPolicyClaim(acctivePolicy.Id,law.id);   
        polClaim.Account__c = lstAccount[0].Id;
        insert polClaim;
        
        AccountNotesComponentHandler objAccNote = new AccountNotesComponentHandler ();
        
        AccountNotesComponentHandler.getNotes('CreatedDate',true,polClaim.Id,'View All Notes',7,5,'ALL','Note__c','Type__c',true);
        AccountNotesComponentHandler.getNotes('CreatedDate',true,polClaim.Id,'View All Notes',7,5,'FALL','Note__c','Type__c',true);
        
        AccountNotesComponentHandler.getNotes('CreatedDate',true,polClaim.Id,'View This Claim Policy Notes',7,5,'ALL','Note__c','Type__c',true);
        AccountNotesComponentHandler.getNotes('CreatedDate',true,polClaim.Id,'View This Claim Policy Notes',7,5,'FALL','Note__c','Type__c',true);
        
        AccountNotesComponentHandler.getNotes('CreatedDate',true,polClaim.Id,'View This Claim',7,5,'ALL','Note__c','Type__c',true);
        AccountNotesComponentHandler.getNotes('CreatedDate',true,polClaim.Id,'View This Claim',7,5,'FALL','Note__c','Type__c',true);
        
        AccountNotesComponentHandler.getNotes('CreatedDate',true,conList[0].Id,'View All Notes',7,5,'ALL','Note__c','Type__c',true);
        
    }*/
    
    
    @isTest static void testMethod3() {
        
        Test.startTest(); 
        List<Policy__c> lstPolicy = [Select Id FROM Policy__c limit 1];
        List<Note__c> objNotes = [Select Id FROM Note__c limit 1];
        
        List<Policy__c> policies = [SELECT Id,Premium__c,Effective_Date__c,Deductible_ID__c,Firm_Mod__c,Limit__c,Base_Amount__c,Account__c FROM Policy__c];
        
        AccountNotesComponentHandler objAccNote = new AccountNotesComponentHandler ();
        AccountNotesComponentHandler.getNotes('CreatedDate',true,policies[0].Id,'View All Notes',7,5,'ALL','Note__c','Type__c',true);
        AccountNotesComponentHandler.getNotes('CreatedDate',true,policies[0].Id,'View All Notes',7,5,'Test','Note__c','Type__c',true);
        
        
        
        AccountNotesComponentHandler.getNotes('CreatedDate',true,policies[0].Id,'View All Policy Notes',7,5,'ALL','Note__c','Type__c',true);
        AccountNotesComponentHandler.getNotes('CreatedDate',true,policies[0].Id,'View All Policy Notes',7,5,'FALL','Note__c','Type__c',true);
        
        AccountNotesComponentHandler.getNotes('CreatedDate',true,policies[0].Id,'View This Policy Claim Notes',7,5,'ALL','Note__c','Type__c',true);
        AccountNotesComponentHandler.getNotes('CreatedDate',true,policies[0].Id,'View This Policy Claim Notes',7,5,'FALL','Note__c','Type__c',true);
        
        AccountNotesComponentHandler.getNotes('CreatedDate',true,policies[0].Id,'View This Policy ',7,5,'ALL','Note__c','Type__c',true);
        AccountNotesComponentHandler.getNotes('CreatedDate',true,policies[0].Id,'View This Policy ',7,5,'FALL','Note__c','Type__c',true);
        AccountNotesComponentHandler.getNotes(null,true,policies[0].Id,'View This Policy ',7,5,'FALL','Note__c','Type__c',true);
        AccountNotesComponentHandler.saveNotes(lstPolicy[0].Id, objNotes[0]);
        Test.stopTest();
    }
    
    
    /*@isTest static void testMethod4() {
        
        test.startTest(); 
        List<Account> lstAccount = [select id from account];
        List<Policy__c> policies = [SELECT Id,Premium__c,Effective_Date__c,Deductible_ID__c,Firm_Mod__c,Limit__c,Base_Amount__c,Account__c FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<Note__c> lstNotes = [select id from Note__c];
        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id,NAME FROM AcctSeed__GL_Account__c];
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(lstAccount[0].id, conList[0].id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        Opportunity opp               = TestDataFactory.createOpp(lstAccount[0].id);
        insert opp;
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorNew.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(lstAccount[0].id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        insert acctivePolicy;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(acctivePolicy.Account__c,acctivePolicy.Id,acj.Id);
        law.Active__c = true;
        insert law;
        
        Policy_Claim__c polClaim = TestDataFactory.createPolicyClaim(acctivePolicy.Id,law.id);   
        polClaim.Account__c = lstAccount[0].Id;
        insert polClaim;
        
        List<POLICY_ENDORSEMENT__c> PolicyEndorsList = [SELECT Id,Name FROM POLICY_ENDORSEMENT__c Limit 1];
        test.stopTest();        
        Policy__c  policy = policies[0];
        
        AcctSeed__Accounting_Period__c period = new AcctSeed__Accounting_Period__c();
        period.Name = String.valueOf(date.today().year()) + '-'+ (date.today().month() < 10 ? '0'+ String.valueOf(date.today().month()) : String.valueOf(date.today().month()));
        period.AcctSeed__Start_Date__c = Date.today();
        period.AcctSeed__End_Date__c = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
        period.AcctSeed__Status__c ='Open';
        
        insert period;
        
        AccountNotesComponentHandler objAccNote = new AccountNotesComponentHandler ();
        
        AccountNotesComponentHandler.getRecordTypeId(lstAccount[0].Id);
        AccountNotesComponentHandler.getRecordTypeId(policies[0].Id);
        AccountNotesComponentHandler.getRecordTypeId(conList[0].Id);
        
        AccountNotesComponentHandler.getNotesRowCount(polClaim.Id,'View All Notes','ALL');
        AccountNotesComponentHandler.getNotesRowCount(polClaim.Id,'View All Notes','FALL');
                
        AccountNotesComponentHandler.getNotesRowCount(polClaim.Id,'View This Claim Policy Notes','ALL');
        AccountNotesComponentHandler.getNotesRowCount(polClaim.Id,'View This Claim Policy Notes','FALL');
        
        AccountNotesComponentHandler.getNotesRowCount(polClaim.Id,'View This Claim','ALL');
        AccountNotesComponentHandler.getNotesRowCount(polClaim.Id,'View This Claim','FALL');
        
        AccountNotesComponentHandler.getTypeOfRecord(lstAccount[0].Id);
        //AccountNotesComponentHandler.getPicklistvalues('Account','Name',true);
        
    }
    
    @isTest static void testMethod5() {
        
        List<Account> lstAccount = [select id from account];
        AccountNotesComponentHandler.getNotesRowCount(lstAccount[0].Id,'View All Notes','ALL');
        AccountNotesComponentHandler.getNotesRowCount(lstAccount[0].Id,'View All Notes','FALL');
        
        AccountNotesComponentHandler.getNotesRowCount(lstAccount[0].Id,'Notes','ALL');
        AccountNotesComponentHandler.getNotesRowCount(lstAccount[0].Id,'Notes','FALL');
    }*/
    
    @isTest static void testMethod6() {
        test.startTest();
        List<Policy__c> policies = [SELECT Id,Premium__c,Effective_Date__c,Deductible_ID__c,Firm_Mod__c,Limit__c,Base_Amount__c,Account__c FROM Policy__c];
        AccountNotesComponentHandler.getNotesRowCount(policies[0].Id,'View All Notes','ALL');
        AccountNotesComponentHandler.getNotesRowCount(policies[0].Id,'View All Policy Notes','ALL');
        AccountNotesComponentHandler.getNotesRowCount(policies[0].Id,'View This Policy Claim Notes','ALL');
        
        AccountNotesComponentHandler.getNotesRowCount(policies[0].Id,'View All Notes','FALL');
        AccountNotesComponentHandler.getNotesRowCount(policies[0].Id,'View All Policy Notes','FALL');
        AccountNotesComponentHandler.getNotesRowCount(policies[0].Id,'View This Policy Claim Notes','FALL');
        test.stopTest();
    }
    
    @isTest static void testMethod7() {
        
        Test.startTest(); 
        
        List<Policy__c> policies = [SELECT Id,Premium__c,Effective_Date__c,Deductible_ID__c,Firm_Mod__c,Limit__c,Base_Amount__c,Account__c FROM Policy__c];
        
        AccountNotesComponentHandler objAccNote = new AccountNotesComponentHandler ();
        //AccountNotesComponentHandler.getNotes('CreatedDate',true,policies[0].Id,'View All Notes',7,5,'ALL');
        Test.stopTest();
    }
    
}