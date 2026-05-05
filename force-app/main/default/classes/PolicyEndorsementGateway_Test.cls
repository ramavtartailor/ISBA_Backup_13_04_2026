@isTest
public class PolicyEndorsementGateway_Test {
    
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
        
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
        opp.StageName   = 'Application Sent';
        insert opp;
        
        Master_Factor__c masterfact =TestDataFactory.createMasterfactor('Coverage 10/1/2016 - 12/31/2016','Coverage');
        insert masterfact;
        
        ILF_Coverage_Factor__c coverFactor = TestDataFactory.createCoveragefactor(masterfact.Id);
        coverFactor.Is_5X5_Coverage__c=true;
        coverFactor.Premium_Rate_5X5__c=1;
        coverFactor.Percentage_5X5_Step_0__c=1;
        coverFactor.Percentage_5X5_Step_1__c=1;
        coverFactor.Percentage_5X5_Step_2__c=1;
        coverFactor.Percentage_5X5_Step_3__c=1;
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
        pol.Total_5x5__c=1;
        pol.Total_10x10__c=1;
        
        insert pol;
        
        List<Endorsement__c> objEndorsementList = new List<Endorsement__c>();
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        objEndorsementList.add(endorse);
        Endorsement__c endorse1 = TestDataFactory.createEndorsement('IL 151','Functional','General');
        objEndorsementList.add(endorse1);
        Endorsement__c endorse2 = TestDataFactory.createEndorsement('IL 151A','Functional','General');
        objEndorsementList.add(endorse2);
        Endorsement__c endorse3 = TestDataFactory.createEndorsement('IL 152','Functional','General');
        objEndorsementList.add(endorse3);
        insert objEndorsementList;
        
        
        
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        Endorsement_Version__c endorseVersion1 = TestDataFactory.createEndorsementVersion(endorse1.Id);
        insert endorseVersion1;
        Endorsement_Version__c endorseVersion2 = TestDataFactory.createEndorsementVersion(endorse2.Id);
        insert endorseVersion2;
        Endorsement_Version__c endorseVersion3 = TestDataFactory.createEndorsementVersion(endorse3.Id);
        insert endorseVersion3;
        
        Attachment attach = new Attachment(Name='Test Attach', Body= Blob.valueOf('test'), ParentId=pol.Id);
        insert attach;
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<ILF_Coverage_Factor__c> CLimit=[Select id from ILF_Coverage_Factor__c];
        
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
        policyEnd.Policy__c= pol.id;
        policyEnd.Lawyer__c = acj.id;
        policyEnd.Event_Status__c = 'Pending';
        policyEnd.Policy_Lawyer__c = law.id;
        policyEnd.Refund_Amount__c = 10;
        policyEnd.New_Limits__c= CLimit[0].id;
        policyEnd.Additional_Premium__c = 100;
        policyEnd.Coverage_Term__c='1 Year';
        policyEnd.Premium__c=1;
        policyEnd.Premium_10_10__c=1;
        policyEnd.Premium_5_5__c=1;
        policyEnd.Primary__c=1;
        policyEnd.Excess__c=1;
        
        lstPolicyEndorsements.add(policyEnd);
        
        insert lstPolicyEndorsements;
        
         Policy_Endorsement_Term__c polEndTerm = new Policy_Endorsement_Term__c();
        polEndTerm.Endorsement__c = lstPolicyEndorsements[0].Id;
        insert polEndTerm;
        
        AS_Transaction__c as_trans = TestDataFactory.createTransaction(lstPolicyEndorsements[0].Id,'Add Lawyer',100,pol.Id,null,pol.account__c,null,'Add Lawyer');
        insert as_trans;    
        
        
        
        
        /*
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

AcctSeed__Accounting_Settings__c settings = TestDataFactory.createAccountsetting(ledgers[0].id,glAccounts[0].Id,glAccounts[1].Id,glAccounts[2].Id,glAccounts[3].Id,glAccounts[4].Id,glAccounts[5].Id,glAccounts[6].Id,billingFormats[0].Id);
insert settings;

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
test.startTest();
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

Policy__c pol                 = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Application');
pol.Base_Amount__c = 100;
pol.Firm_Mod__c = 2;
pol.Limit__c = FactorCoverage.Id;
pol.Deductible_ID__c = DedFac.id;

insert pol;

Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();


Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
insert endorse;

Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
insert endorseVersion;

Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,pol.id,'General');
insert poicyEndorse;

Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
insert masterFactorNew;

AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
insert aopFactor;


test.stopTest();
*/
    }
    
    @isTest static void testMethod_test1() {
        List<Policy__c> policyList = [SELECT Id,Additional_Premium__c,Premium__c FROM Policy__c];
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,Excess__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,Premium_5_5__c,Premium_10_10__c,
                                                     Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, Primary__c,
                                                     Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c];
        List<Endorsement__c> endorseList = [SELECT Id, Type__c, Endorsement_Sub_Type__c FROM Endorsement__c];
        
        List<AccountContactJunction__c> acjObjList = [Select id from AccountContactJunction__c]; 
        
        Policy_Endorsement__c polEndorseOld = polEndorseList[0];
        Policy_Endorsement__c polEndorse = polEndorseList[0];
        
        Endorsement__c currentEnd = endorseList[0];
        currentEnd.Endorsement_Sub_Type__c = 'IL 107B';
        update currentEnd;
        
        polEndorse.Lawyer__c = acjObjList[0].id;
        polEndorse.Endorsement_Effective_Date__c = System.today().adddays(5);
        update polEndorse;
        
        Test.startTest();
        
        PolicyEndorsementGateway objPolicyEndorGateway = new PolicyEndorsementGateway();
        PolicyEndorsementGateway.updateEndorsementVersion(new Map<Id,SObject>{polEndorse.Id => polEndorseOld}, new Map<Id,SObject>{polEndorse.Id => polEndorse});
        PolicyEndorsementGateway.updatePolicyEndorsements(new Map<Id,SObject>{polEndorse.Id => polEndorseOld}, new Map<Id,SObject>{polEndorse.Id => polEndorse});
        //PolicyEndorsementGateway.completeEREOnly(polEndorseList);
        system.debug('--------polEndorseList----'+polEndorseList);       
        
        PolicyEndorsementGateway.performEREEndorsementDelete(polEndorseList);
        
      //  PolicyEndorsementGateway.completeAddLawyer(polEndorseList);
      //  PolicyEndorsementGateway.CompleteChangeAccount(polEndorseList,True);
      //  PolicyEndorsementGateway.pendingChangeLawyer(polEndorseList);
    //    PolicyEndorsementGateway.completeChangeLawyer(polEndorseList);
        //PolicyEndorsementGateway.completeChangeCoverage(polEndorseList);
        //PolicyEndorsementGateway.pendingCancelPolicy(polEndorseList);
        //PolicyEndorsementGateway.completeCancelPolicy(polEndorseList);
       // PolicyEndorsementGateway.pendingReinstatePolicy(polEndorseList);
       // PolicyEndorsementGateway.completeReinstatePolicy(polEndorseList);
       // PolicyEndorsementGateway.pendingERE(polEndorseList);
        PolicyEndorsementGateway.pendingEREUnlimited(polEndorseList);
     //   PolicyEndorsementGateway.completeERE(polEndorseList);
        //PolicyEndorsementGateway.rollBackAttorneyDeletionOperation(new Map<Id,SObject>{polEndorse.Id => polEndorse});
        PolicyEndorsementGateway.completeDescriptiveEndorsements(polEndorseList);
        //PolicyEndorsementGateway.performEndorsementDelete(polEndorseList);
        //PolicyEndorsementGateway.performAddEndorsementDelete(polEndorseList);
      //  PolicyEndorsementGateway.completeAdditionalPremium(polEndorseList);
      //  PolicyEndorsementGateway.completeTitlePremium(polEndorseList);
        Test.stopTest();
    }
    
    
    @isTest
    static void updateEndorsementVersion_Test(){
        
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Endorsement_Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updateEndorsementVersion(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void Test_P(){
        
        List<Policy_Endorsement__c> PEList = [select id,Premium__c,Account__c,Policy__c,Excess__c,Primary__c from Policy_Endorsement__c];
        Policy_Endorsement__c SinglePE = PEList[0];
        test.startTest();
        SinglePE.Premium_5_5__c=1;
        SinglePE.Premium_10_10__c=1;
        SinglePE.Primary__c=1;
        SinglePE.Endorsement_Number__c='IL 107';
        update SinglePE;
        
        PolicyEndorsementGateway.getIL_153_Transactions(SinglePE);
        PolicyEndorsementGateway.getIL_190_Transactions(SinglePE);
        PolicyEndorsementGateway.getIL_152_Transactions(SinglePE);
        // PolicyEndorsementGateway.pendingERE(PEList);
        // completeDescriptiveEndorsements
        // completeAddLawyer
        PolicyEndorsementGateway.getERE_Transactions(SinglePE);
        // PolicyEndorsementGateway.pendingChangeCoverage(PEList);
        // PolicyEndorsementGateway.completeChangeCoverage(PEList);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test(){
         
        Policy__c acctivePolicy = [select id from Policy__c limit 1];
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert masterFactorNew;        
        
        // Insert ILF Coverage Factor
        ILF_Coverage_Factor__c objfactor = new ILF_Coverage_Factor__c();
        objfactor.name = '250,000 / 500,000';
        objfactor.Coverage_Max_Per_Claim__c = 250000.00;
        objfactor.Full_Coverage__c = 500;
        objfactor.Factor_Value__c =12;
        objfactor.Master_Factor__c = masterFactorNew.id;
        objfactor.Lowest_Coverage__c = true;
        insert objfactor;
        
        Deductible_Factor__c objDed = new Deductible_Factor__c();
        objDed.Name = '12';
        objDed.Deductible_External_ID__c = '12345';
        objDed.Deductible_Amount__c = 124;
        objDed.Factor_Value__c = 1233;
        objDed.Master_Factor__c = masterFactorNew.id;
        insert objDed;
        
        
        Policy_Quote__c objQuote = new Policy_Quote__c();
        objQuote.Policy__c =acctivePolicy.id ;
        objQuote.Coverage__c = objfactor.id;
        objQuote.Deductible__c = objDed.id;
        objQuote.Lowest_Coverage_Factor__c = 12;
        objQuote.Quote_Premium_Step_0__c =1000;
        objQuote.Quote_Premium_Step_1__c = 1000;
        objQuote.Quote_Premium_Step_2__c = 1000;
        objQuote.Quote_Premium_Step_3__c = 1000;
        objQuote.Quote_Premium_Step_4__c = 1000;
        objQuote.Quote_Premium_Step_5__c = 1000;
        objQuote.Quote_Premium_Step_6__c = 1000;
        objQuote.Quote_Premium_Step_7__c = 1000;
        objQuote.Primary_Step_0__c = 1000;
        objQuote.Primary_Step_1__c = 1000;
        objQuote.Primary_Step_2__c = 1000;
        objQuote.Primary_Step_3__c = 1000;
        objQuote.Primary_Step_4__c = 1000;
        objQuote.Primary_Step_5__c = 1000;
        objQuote.Primary_Step_6__c = 1000;
        objQuote.Primary_Step_7__c = 1000;
        objQuote.Excess_Step_0__c = 1000;
        objQuote.Excess_Step_1__c = 1000;
        objQuote.Excess_Step_2__c = 1000;
        objQuote.Excess_Step_3__c = 1000;
        objQuote.Excess_Step_4__c = 1000;
        objQuote.Excess_Step_5__c = 1000;
        objQuote.Excess_Step_6__c = 1000;
        objQuote.Excess_Step_7__c = 1000;
        insert objQuote;
        
         List<Policy_Endorsement_Term__c> polEndTermList = [SELECT Id, Name, Endorsement__c FROM Policy_Endorsement_Term__c];
        
         AOP_Factor__c aopFactor = new AOP_Factor__c(Master_Factor__c=masterFactorNew.Id,Name='Test AOP Factor');
        aopFactor.AOP_Mod__c = 55.7;
        insert aopFactor;
        
        Policy_AOP__c aop = new Policy_AOP__c(
            AOP__c=aopFactor.Id,
            Policy__c=acctivePolicy.Id,
            Factor_Mod__c=2,
            Percentage__c=5
        );
        insert aop;
        
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_1(){
        
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';   
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_2(){
        
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';   
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        //PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_3(){
        
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void';   
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_4(){
        
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';   
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(newMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_5(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 151','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';   
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(newMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_6(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 151','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';   
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_7(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 151','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,Account_ID__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';   
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,Account_ID__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_8(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 151A','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';  
            pE.Effective_Date__c = date.today().addDays(5);
            
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }   
    
    @isTest
    static void updatePolicyEndorsements_Test_9(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 151A','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, Account_ID__c,
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';  
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, Account_ID__c,
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }   
    
    @isTest
    static void updatePolicyEndorsements_Test_10(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 151A','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void';  
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }   
    
    
    @isTest
    static void updatePolicyEndorsements_Test_11(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 151A','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,Primary__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,Step__c,Premium_10_10__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c,Premium_5_5__c,
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';  
        }
        
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(newMap,newMap);
        Test.stopTest();
        
    }   
    
    @isTest
    static void updatePolicyEndorsements_Test_12(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 151A','Functional','General');
        endorse.Endorsement_Sub_Type__c = 'Change Lawyer';
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId,Name FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            System.debug(pE.Name);
            System.debug(pE.Policy_Lawyer__c);
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }   
    
    
    @isTest
    static void updatePolicyEndorsements_Test_13(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 151A','Functional','General');
        endorse.Endorsement_Sub_Type__c = 'Change Lawyer';
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';  
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }   
    
    @isTest
    static void updatePolicyEndorsements_Test_14(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 151A','Functional','General');
        endorse.Endorsement_Sub_Type__c = 'Change Lawyer';
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,Premium_5_5__c,Premium_10_10__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, Primary__c,
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';  
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,Premium_5_5__c,Premium_10_10__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, Primary__c,
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }   
    
    @isTest
    static void updatePolicyEndorsements_Test_15(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 151A','Functional','General');
        endorse.Endorsement_Sub_Type__c = 'Change Lawyer';
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void';  
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }   
    
    @isTest
    static void updatePolicyEndorsements_Test_16(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 151A','Functional','General');
        endorse.Endorsement_Sub_Type__c = 'Change Lawyer';
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';  
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(newMap,newMap);
        Test.stopTest();
        
    }  
    
    @isTest
    static void updatePolicyEndorsements_Test_17(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){ 
            pE.Effective_Date__c = date.today().addDays(5);
            
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }   
    
    @isTest
    static void updatePolicyEndorsements_Test_18(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';  
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }   
    
    @isTest
    static void updatePolicyEndorsements_Test_19(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,Excess__c,Premium_10_10__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, Step__c,Premium_5_5__c,Primary__c,
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';  
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,Premium_10_10__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,Premium_5_5__c,Primary__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, Step__c,Excess__c,
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }   
    
    
    @isTest
    static void updatePolicyEndorsements_Test_20(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,Premium_10_10__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, Premium_5_5__c,
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void';
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }   
    
    @isTest
    static void updatePolicyEndorsements_Test_21(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';
        }
        
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(newMap,newMap);
        Test.stopTest();
        
    }   
    
    
    @isTest
    static void updatePolicyEndorsements_Test_22(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        endorse.Endorsement_Sub_Type__c = 'Adjust Premium';
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Pending';  
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }   
    
    @isTest
    static void updatePolicyEndorsements_Test_23(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        endorse.Endorsement_Sub_Type__c = 'Adjust Premium';
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';  
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Primary__c,Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }   
    
    @isTest
    static void updatePolicyEndorsements_Test_24(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        endorse.Endorsement_Sub_Type__c = 'Adjust Premium';
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,Premium_5_5__c,Premium_10_10__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, Primary__c,
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';  
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,Premium_5_5__c,Premium_10_10__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Primary__c,Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }   
    
    @isTest
    static void updatePolicyEndorsements_Test_25(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        endorse.Endorsement_Sub_Type__c = 'Adjust Premium';
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Primary__c,Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void';
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Primary__c,Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }   
    
    @isTest
    static void updatePolicyEndorsements_Test_26(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        endorse.Endorsement_Sub_Type__c = 'Adjust Premium';
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Primary__c,Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(newMap,newMap);
        Test.stopTest();
        
    }
    
    
    @isTest
    static void updatePolicyEndorsements_Test_27(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 190','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Pending';
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Primary__c,Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }   
    
    @isTest
    static void updatePolicyEndorsements_Test_28(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 190','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Primary__c,Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_29(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 190','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Pending';
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Primary__c,Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_30(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 190','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Pending';
        }
        
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Primary__c,Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_31(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 190','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void';
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Primary__c,Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_32(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 190','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void';
        }
        
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Primary__c,Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_33(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 190','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';
        }
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(newMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_34(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 120','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Pending';
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Primary__c,Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        //PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_35(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 120','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Primary__c,Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_36(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 120','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';
        }
        
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,New_Limits__c,Primary__c,Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        //PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_37(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 120','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void';
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Primary__c,Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_38(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 120','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void';
        }
        
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,New_Limits__c,Primary__c,Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_39(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 120','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete';
        }
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(newMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_40(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 107','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Pending'; 
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_41(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 107','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete'; 
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    
    @isTest
    static void updatePolicyEndorsements_Test_42(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 107','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,Policy_Expiration_Date__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,Coverage_Term__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, Policy_Canel_Date__c,
                                                                                  Attachment_Record_Id__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete'; 
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,Policy_Expiration_Date__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,Coverage_Term__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c,Policy_Canel_Date__c,
                                                                                  Attachment_Record_Id__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_43(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 191','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void'; 
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_44(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 191','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete'; 
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(newMap,newMap);
        Test.stopTest();
        
    }
    
    
    @isTest
    static void updatePolicyEndorsements_Test_45(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 191','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void'; 
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_46(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 191','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Pending'; 
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_47(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 191','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete'; 
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    
    @isTest
    static void updatePolicyEndorsements_Test_48(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 191','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete'; 
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_49(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 191','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void'; 
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_50(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 191','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete'; 
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(newMap,newMap);
        Test.stopTest();
        
    }
    
    
    @isTest
    static void updatePolicyEndorsements_Test_51(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 107','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void'; 
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_52(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 107B','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Pending'; 
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_53(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 107B','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete'; 
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_54(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 107B','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,Lawyer_Name__c,Name,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, Name_Of_Insured__c,
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete'; 
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,Name,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c,Lawyer_Name__c,
                                                                                  Attachment_Record_Id__c,Name_Of_Insured__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_55(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 107B','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void'; 
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_56(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 107B','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, Name_Of_Insured__c,
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void'; 
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Name_Of_Insured__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_57(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 107B','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete'; 
        }
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(newMap,newMap);
        Test.stopTest();
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_58(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 230','Descriptive','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Pending'; 
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_59(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 230','Descriptive','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete'; 
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_60(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 230','Descriptive','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Endorsement_Mod__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete'; 
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Endorsement_Mod__c,Name_Of_Insured__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_61(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 230','Descriptive','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void'; 
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_62(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 230','Descriptive','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Endorsement_Mod__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void'; 
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Endorsement_Mod__c,Name_Of_Insured__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_63(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 230','Descriptive','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete'; 
        }
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(newMap,newMap);
        Test.stopTest();
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_64(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 130','Descriptive','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete'; 
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_65(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 130','Descriptive','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete'; 
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_66(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 130','Descriptive','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, Endorsement_Number__c,
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete'; 
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, Endorsement_Number__c,
                                                                                  Attachment_Record_Id__c,Name_Of_Insured__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_67(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 130','Descriptive','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void'; 
            pE.Effective_Date__c = date.today().addDays(5);
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_68(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 130','Descriptive','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Void'; 
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Name_Of_Insured__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updatePolicyEndorsements_Test_69(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 130','Descriptive','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){
            pE.Event_Status__c = 'Complete'; 
        }
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(newMap,newMap);
        Test.stopTest();
    }
    
    @isTest
    static void performPolicyEndorsementFunctions_Test(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('Adjust Premium','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        for(Policy_Endorsement__c pE : newMap.Values()){
            pE.Event_Status__c = 'Complete';
        }
        
        Test.startTest();
        PolicyEndorsementGateway.performPolicyEndorsementFunctions(newMap);
        Test.stopTest();
        
    }
    
    
    
    @isTest
    static void checkStatusValidation_Test(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('Adjust Premium','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        for(Policy_Endorsement__c pE : newMap.Values()){
            pE.Event_Status__c = 'Complete';
        }
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c,Coverage_Term__c,New_Limits__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        Test.startTest();
        PolicyEndorsementGateway.checkStatusValidation(newMap,oldMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void checkStatusValidation_Test_1(){
        
    }
    
    @isTest
    static void policyLawyerValidation_Test(){
        
        Policy__c pol  = [Select id from Policy__c limit 1];
        
        Map<Id,Policy_Endorsement__c> polEndorseList = new Map<Id,Policy_Endorsement__c> ([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                           Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                           Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                           Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                           Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                                                           Endorsement_Number__c,RecordTypeId,Account_ID__c,Primary__c,Refund_Amount__c,New_Limits__c
                                                                                           FROM Policy_Endorsement__c Limit 200]);
        
        Policy_Lawyer__c polLaw = [SELECT Id, Name, Policy__c, Lawyer__c, Deleted_Lawyer__c FROM Policy_Lawyer__c ];
        
        
        Test.startTest();
        PolicyEndorsementGateway.policyLawyerValidation(polEndorseList);
        Test.stopTest();
    }
    
    @isTest
    static void policyLawyerValidation_Test2(){
        
        Policy__c pol  = [Select id,Account__c from Policy__c limit 1];
        List<Policy_Endorsement__c> polendList = [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                           Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                           Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                           Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                           Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                                                           Endorsement_Number__c,RecordTypeId,Account_ID__c,Primary__c,Refund_Amount__c,New_Limits__c
                                                                                           FROM Policy_Endorsement__c Limit 200];
        
        polendList[0].Step_Override__c = false;
        polendList[0].Step_Override_Value__c = null;
        update polendList;
        
        Map<Id,Policy_Endorsement__c> polEndorseList = new Map<Id,Policy_Endorsement__c> (polendList);
        
       
        Policy_Lawyer__c polLaw = [SELECT Id, Name, Policy__c, Lawyer__c, Deleted_Lawyer__c FROM Policy_Lawyer__c ];
        
        AccountContactJunction__c junct = [SELECT Id FROM AccountContactJunction__c limit 1 ];
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(pol.Account__c,pol.Id,junct.Id);
        law.Active__c = true;
        law.Deleted_Lawyer__c = false;
        insert law;
        
        
        Test.startTest();
        PolicyEndorsementGateway.policyLawyerValidation(polEndorseList);
        Test.stopTest();
    }
    
    @isTest
    static void pendingAddLawyer_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Account_ID__c,Primary__c,Refund_Amount__c,New_Limits__c
                                                     FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.pendingAddLawyer(polEndorseList);
        Test.stopTest();
        
    }
    
    @isTest
    static void pendingAddLawyer_Test_1(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Account_ID__c,Primary__c,Refund_Amount__c,New_Limits__c
                                                     FROM Policy_Endorsement__c Limit 200];
        for(Policy_Endorsement__c pE : polEndorseList){
            pE.Step_Override_Value__c = 1;
        }
        update polEndorseList;
        Test.startTest();
        PolicyEndorsementGateway.pendingAddLawyer(polEndorseList);
        Test.stopTest();
        
    }
    
    @isTest
    static void pendingAddLawyer_Test_2(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Account_ID__c,Primary__c,Refund_Amount__c,New_Limits__c
                                                     FROM Policy_Endorsement__c Limit 200];
        for(Policy_Endorsement__c pE : polEndorseList){
            pE.Step_Override_Value__c = 2;
        }
        update polEndorseList;
        Test.startTest();
        PolicyEndorsementGateway.pendingAddLawyer(polEndorseList);
        Test.stopTest();
        
    }
    
    @isTest
    static void pendingAddLawyer_Test_3(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Account_ID__c,Primary__c,Refund_Amount__c,New_Limits__c
                                                     FROM Policy_Endorsement__c Limit 200];
        for(Policy_Endorsement__c pE : polEndorseList){
            pE.Step_Override_Value__c = 3;
        }
        update polEndorseList;
        Test.startTest();
        PolicyEndorsementGateway.pendingAddLawyer(polEndorseList);
        Test.stopTest();
        
    }
    
    @isTest
    static void pendingAddLawyer_Test_4(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Account_ID__c,Primary__c,Refund_Amount__c,New_Limits__c
                                                     FROM Policy_Endorsement__c Limit 200];
        for(Policy_Endorsement__c pE : polEndorseList){
            pE.Step_Override_Value__c = 4;
        }
        update polEndorseList;
        Test.startTest();
        PolicyEndorsementGateway.pendingAddLawyer(polEndorseList);
        Test.stopTest();
        
    }
    
    
    @isTest
    static void pendingAddLawyer_Test_5(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Account_ID__c,Primary__c,Refund_Amount__c,New_Limits__c
                                                     FROM Policy_Endorsement__c Limit 200];
        for(Policy_Endorsement__c pE : polEndorseList){
            pE.Step_Override_Value__c = 5;
        }
        update polEndorseList;
        Test.startTest();
        PolicyEndorsementGateway.pendingAddLawyer(polEndorseList);
        Test.stopTest();
        
    }
    
    @isTest
    static void pendingAddLawyer_Test_6(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Account_ID__c,Primary__c,Refund_Amount__c,New_Limits__c
                                                     FROM Policy_Endorsement__c Limit 200];
        for(Policy_Endorsement__c pE : polEndorseList){
            pE.Step_Override_Value__c = 6;
        }
        update polEndorseList;
        Test.startTest();
        PolicyEndorsementGateway.pendingAddLawyer(polEndorseList);
        Test.stopTest();
        
    }
    
    
    @isTest
    static void pendingAddLawyer_Test_7(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Account_ID__c,Primary__c,Refund_Amount__c,New_Limits__c
                                                     FROM Policy_Endorsement__c Limit 200];
        for(Policy_Endorsement__c pE : polEndorseList){
            pE.Step_Override_Value__c = 7;
        }
        update polEndorseList;
        Test.startTest();
        PolicyEndorsementGateway.pendingAddLawyer(polEndorseList);
        Test.stopTest();
        
    }
    
    @isTest
    static void completeAddLawyer_Test(){
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Term__c, Excess__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Account_ID__c,Primary__c,Refund_Amount__c,New_Limits__c
                                                     FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.completeAddLawyer(polEndorseList);
        Test.stopTest();
        
    }
    
    @isTest
    static void pendingChangeAccount_Test(){
        
    }
    
    @isTest
    static void CompleteChangeAccount_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Account_ID__c,Refund_Amount__c,New_Limits__c
                                                     FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.CompleteChangeAccount(polEndorseList,True);
        PolicyEndorsementGateway.CompleteChangeAccount(polEndorseList,False);
        Test.stopTest();
        
    }
    
    @isTest
    static void pendingChangeLawyer_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Refund_Amount__c,New_Limits__c
                                                     FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        //PolicyEndorsementGateway.pendingChangeLawyer(polEndorseList);
        Test.stopTest();
        
    }
    
    /*static void pendingChangeLawyer_Test_1(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Refund_Amount__c,New_Limits__c
                                                     FROM Policy_Endorsement__c Limit 200];
        for(Policy_Endorsement__c pE : polEndorseList){
            pE.Step_Override_Value__c = 1;
        }
        update polEndorseList;
        
        Test.startTest();
        PolicyEndorsementGateway.pendingChangeLawyer(polEndorseList);
        Test.stopTest();
        
    }*/
    
    /*@isTest
    static void completeChangeLawyer_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Refund_Amount__c,New_Limits__c,Excess__c,Primary__c,Step__c
                                                     FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.completeChangeLawyer(polEndorseList);
        Test.stopTest();
        
    }*/
    
    @isTest
    static void pendingDeleteLawyer_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Refund_Amount__c,New_Limits__c
                                                     FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.pendingDeleteLawyer(polEndorseList);
        Test.stopTest();
        
    }
    
    @isTest
    static void pendingDeleteLawyer_Test_1(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Refund_Amount__c,New_Limits__c
                                                     FROM Policy_Endorsement__c Limit 200];
        for(Policy_Endorsement__c pE : polEndorseList){
            pE.Override_Rating__c = true;
        }
        //update polEndorseList;
        
        Test.startTest();
        PolicyEndorsementGateway.pendingDeleteLawyer(polEndorseList);
        Test.stopTest();
        
    }
    
    @isTest
    static void pendingDeleteLawyer_Test_2(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){ 
            pE.Effective_Date__c = date.today().addDays(5);
            pE.Step_Override_Value__c = 1;
        }
        update newMap.values();
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
    }
    
    @isTest
    static void pendingDeleteLawyer_Test_3(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){ 
            pE.Effective_Date__c = date.today().addDays(5);
            pE.Step_Override_Value__c = 2;
        }
        update newMap.values();
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
    }
    
    @isTest
    static void pendingDeleteLawyer_Test_4(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){ 
            pE.Effective_Date__c = date.today().addDays(5);
            pE.Step_Override_Value__c = 3;
        }
        update newMap.values();
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
    }
    
    @isTest
    static void pendingDeleteLawyer_Test_5(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){ 
            pE.Effective_Date__c = date.today().addDays(5);
            pE.Step_Override_Value__c = 4;
        }
        update newMap.values();
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
    }
    
    @isTest
    static void pendingDeleteLawyer_Test_6(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){ 
            pE.Effective_Date__c = date.today().addDays(5);
            pE.Step_Override_Value__c = 5;
        }
        update newMap.values();
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
    }
    
    @isTest
    static void pendingDeleteLawyer_Test_7(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){ 
            pE.Effective_Date__c = date.today().addDays(5);
            pE.Step_Override_Value__c = 6;
        }
        update newMap.values();
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
    }
    
    @isTest
    static void pendingDeleteLawyer_Test_8(){
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 153','Functional','General');
        Insert endorse;
        Map<id,Policy_Endorsement__c> newMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        for(Policy_Endorsement__c pE : newMap.values()){ 
            pE.Effective_Date__c = date.today().addDays(5);
            pE.Step_Override_Value__c = 7;
        }
        update newMap.values();
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200]);
        
        Test.startTest();
        PolicyEndorsementGateway.updatePolicyEndorsements(oldMap,newMap);
        Test.stopTest();
    }
    
    @isTest
    static void completeDeleteLawyer_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Refund_Amount__c,New_Limits__c,Step__c,Excess__c,Primary__c
                                                     FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.completeDeleteLawyer(polEndorseList);
        Test.stopTest();
        
    }
    
    /*@isTest
    static void pendingAdjustPremium_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Refund_Amount__c,New_Limits__c
                                                     FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.pendingAdjustPremium(polEndorseList);
        Test.stopTest();
        
    }*/
    
    /*@isTest
    static void completeAdjustPremium_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Refund_Amount__c,New_Limits__c
                                                     FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.completeAdjustPremium(polEndorseList);
        Test.stopTest();
        
        
    }*/
    
    @isTest
    static void pendingChangeCoverage_Test(){
        
        Policy__c pol  = [Select id,Account__c from Policy__c limit 1];
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Refund_Amount__c,New_Limits__c
                                                     FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.pendingChangeCoverage(polEndorseList);
        Test.stopTest();
        
    }
    
    @isTest
    static void completeChangeCoverage_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Refund_Amount__c,New_Limits__c
                                                     FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.completeChangeCoverage(polEndorseList);
        Test.stopTest();
        
    }
    
    
    @isTest
    static void pendingCancelPolicy_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Refund_Amount__c FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.pendingCancelPolicy(polEndorseList);
        Test.stopTest();
        
    }
    
    @isTest
    static void completeCancelPolicy_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId,Refund_Amount__c,Excess__c,Primary__c FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.completeCancelPolicy(polEndorseList);
        Test.stopTest();
        
    }
    
    
    @isTest
    static void pendingReinstatePolicy_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.pendingReinstatePolicy(polEndorseList);
        Test.stopTest();
        
    }
    
    
    @isTest
    static void completeReinstatePolicy_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.completeReinstatePolicy(polEndorseList);
        Test.stopTest();
        
    }
    
    
    @isTest
    static void pendingERE_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.pendingERE(polEndorseList);
        Test.stopTest();
        
    }
    
    
    /*@isTest
    static void pendingEREUnlimited_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId FROM Policy_Endorsement__c Limit 200];
        for(Policy_Endorsement__c pE : polEndorseList){
            pE.Coverage_Term__c = '1-4 Years';
        }
        update polEndorseList;
        Test.startTest();
        PolicyEndorsementGateway.pendingEREUnlimited(polEndorseList);
        Test.stopTest();
    }*/
    
    
    @isTest
    static void completeERE_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c,Premium_10_10__c,Premium_5_5__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,ERE_Expiration_Date__c,
                                                     Endorsement_Number__c,RecordTypeId FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.completeERE(polEndorseList);
        
          for(Policy_Endorsement__c pE : polEndorseList){
            pE.Coverage_Term__c = '3 Years';
        }
        update polEndorseList;
        PolicyEndorsementGateway.pendingERE(polEndorseList);
        Test.stopTest();
        
        
    }
    
    
    @isTest
    static void completeDescriptiveEndorsements_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,Endorsement_Number__c,RecordTypeId FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        //PolicyEndorsementGateway.completeDescriptiveEndorsements(polEndorseList);
       for(Policy_Endorsement__c pE : polEndorseList){
            pE.Coverage_Term__c = '6 Years';
        }
        update polEndorseList;
        PolicyEndorsementGateway.pendingERE(polEndorseList);
        Test.stopTest();
        
    }
    
    
    @isTest
    static void rollBackAttorneyDeletionOperation_Test(){
        
        Map<id,Policy_Endorsement__c> oldMap = new Map<id,Policy_Endorsement__c>([SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                                                  Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                                                  Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                                                  Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                                                  Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c]);
        Test.startTest();
        PolicyEndorsementGateway.rollBackEndorsementOperation(oldMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void performEndorsementDelete_Test(){
        
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c,Premium_5_5__c,Premium_10_10__c, Excess__c,Primary__c,
                                                     Attachment_Record_Id__c, Account_Billing_City__c,Endorsement_Number__c,RecordTypeId FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.performDeleteEndorsementDelete(polEndorseList);
        
       
        Test.stopTest();
        
    }
    
    @isTest
    static void performAddEndorsementDelete_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,Endorsement_Number__c,RecordTypeId,Premium_5_5__c,Premium_10_10__c,Excess__c,Primary__c  FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.performCancelEndorsementDelete(polEndorseList);
        PolicyEndorsementGateway.performAddEndorsementDelete(polEndorseList);
        
        Test.stopTest();
        
    }
    
    
    @isTest
    static void performEREEndorsementDelete_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,Endorsement_Number__c,RecordTypeId FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.performEREEndorsementDelete(polEndorseList);
        Test.stopTest();
        
    }
    
    /*@isTest
static void completeEREOnly_Test(){

List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
Attachment_Record_Id__c, Account_Billing_City__c,Endorsement_Number__c,RecordTypeId FROM Policy_Endorsement__c Limit 200];

Test.startTest();
PolicyEndorsementGateway.completeEREOnly(polEndorseList);
Test.stopTest();

}*/
    
    
    @isTest
    static void completeAdditionalPremium_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c,Endorsement_Number__c,RecordTypeId FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.completeAdditionalPremium(polEndorseList);
        Test.stopTest();
        
    }
    
    @isTest
    static void completeTitlePremium_Test(){
        
        List<Policy_Endorsement__c> polEndorseList= [SELECT Id,Account__c, Policy__c,Additional_Premium__c, Endorsement_Effective_Date__c, Event_Status__c, Effective_Date__c, Lawyer__c, Rate_At__c,
                                                     Premium__c, Prior_Act_Date__c, Step_Override__c, Step_Override_Value__c, Override_Rating__c,
                                                     Override_5_5__c, Override_10_10__c, Days_Pro_Rated__c, Policy_Lawyer__c, Account_Name__c,
                                                     Account_Billing_Street__c, Account_Billing_State__c, Account_Billing_PostalCode__c, 
                                                     Attachment_Record_Id__c, Account_Billing_City__c, RecordTypeId FROM Policy_Endorsement__c Limit 200];
        
        Test.startTest();
        PolicyEndorsementGateway.completeTitlePremium(polEndorseList);
        Test.stopTest();
        
    }
    
}