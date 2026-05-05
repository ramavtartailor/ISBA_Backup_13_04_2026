@isTest
public class ApplicationPolicyUtil_Test {
    
    
    @testSetup 
    static void testData(){
        
        // Insert Account
        Account acc = TestDataFactory.createAccounts('Test Account');
        insert acc;
        
        // Insert Contact 
        Contact con = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        // Insert AccountContactJunction
        List<AccountContactJunction__c>acjList = new List<AccountContactJunction__c>();
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name = 'Test Name';
        
        insert acj;
        
        AccountContactJunction__c acj1 = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj1.Name = 'Test Name1';
        acjList.add(acj1);
        
         AccountContactJunction__c acj2 = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj2.Name = 'Test Name2';
        acjList.add(acj2);
        
         AccountContactJunction__c acj3 = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj3.Name = 'Test Name3';
        acjList.add(acj3);
        
         AccountContactJunction__c acj4 = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj4.Name = 'Test Name4';
        acjList.add(acj4);
        
         AccountContactJunction__c acj5 = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj5.Name = 'Test Name5';
        acjList.add(acj5);
        
         AccountContactJunction__c acj6 = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj6.Name = 'Test Name6';
        acjList.add(acj6);
        
         AccountContactJunction__c acj7 = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj7.Name = 'Test Name7';
        acjList.add(acj7);
        
        insert acjList;
        
        // Insert Master Factor
        Master_Factor__c mas          = new Master_Factor__c();
        mas.Name                      = 'Test Master Factor';
        mas.Factor_Type__c            = 'Geo';
        mas.From_Date__c              = Date.today();
        mas.To_Date__c                = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day());
        mas.Default__c                = true;
        insert mas;
        
        
        County__c county              = new County__c();
        county.Name                   = 'Test County';
        county.Region__c              = '5';
        insert county;
        
        Geo_Factor__c geo             = new Geo_Factor__c();
        geo.Name                      = 'Test County';
        geo.Master_Factor__c          = mas.Id;
        geo.Region_Factor_Value__c    = 0.88;
        geo.County__c                 = county.Id;
        insert geo;
        
        Master_Factor__c masterFactor = new Master_Factor__c(Factor_Type__c='Step Rate', Default__c=true,From_Date__c= Date.today().addDays(-1),
                                                             To_Date__c= Date.today().addDays(3),
                                                             Name  = 'Test Master Factor0');
        insert masterFactor;
        
        Step_Rate_Factor__c stepRateFactor = new Step_Rate_Factor__c(Master_Factor__c=masterFactor.Id, Factor_Value_Step_Rate_0__c=0,
                                                                     Factor_Value_Step_Rate_1__c=1, Factor_Value_Step_Rate_2__c=2, Factor_Value_Step_Rate_3__c=3, 
                                                                     Factor_Value_Step_Rate_4__c=4, Factor_Value_Step_Rate_5__c=5, Factor_Value_Step_Rate_6__c=6,
                                                                     Factor_Value_Step_Rate_7__c=7);
        insert stepRateFactor;
        
        Master_Factor__c masterFactor1 = new Master_Factor__c(Factor_Type__c='Base Value', Default__c=true,From_Date__c= Date.today(),
                                                              To_Date__c= Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day()),
                                                              Name  = 'Test Master Factor1');
        insert masterFactor1;
        
        Step_Rate_Factor__c stepRateFactor1 = new Step_Rate_Factor__c(Master_Factor__c=masterFactor1.Id, Factor_Value_Step_Rate_0__c=0,
                                                                      Factor_Value_Step_Rate_1__c=1, Factor_Value_Step_Rate_2__c=2, Factor_Value_Step_Rate_3__c=3, 
                                                                      Factor_Value_Step_Rate_4__c=4, Factor_Value_Step_Rate_5__c=5, Factor_Value_Step_Rate_6__c=6,
                                                                      Factor_Value_Step_Rate_7__c=7);
        insert stepRateFactor1;
        
        Base_Factor__c baseFactor = new Base_Factor__c(Master_Factor__c=masterFactor1.Id, Base_Amount__c=100);
        insert baseFactor;
        
               
        /*  Policy__c pol                 = new Policy__c();
pol.RecordTypeId              = Schema.SObjectType.Policy__C.getRecordTypeInfosByName().get('Application').getRecordTypeId();
pol.Name                      = 'Test Policy';
pol.Status__c                 = 'Application Created';
pol.Account__c                = acc.Id;
pol.Opportunity__c            = opp.Id;
pol.Effective_Date__c         = System.today().addDays(-1);
pol.Expiration_Date__c        = System.today().addDays(2);
pol.Cancel_Date__c            = System.today().addDays(2);
pol.SCH_Mod__c                = 1.00;
pol.County__c                 = geo.Id;
pol.Base_Amount__c            = 10;
pol.Firm_Mod__c               =15;
pol.Total_5x5__c              = 1000;
pol.Total_10x10__c            = 1000;
pol.Primary__c                = 1000;
pol.Excess_Premium__c         = 1000;
insert pol;
*/
        
        
        
        
        Master_Factor__c masterFactorAop = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorAop;
        
        Step_Rate_Factor__c stepRateFactorAOP = new Step_Rate_Factor__c(Master_Factor__c=masterFactorAop.Id, Factor_Value_Step_Rate_0__c=0,
                                                                        Factor_Value_Step_Rate_1__c=1, Factor_Value_Step_Rate_2__c=2, Factor_Value_Step_Rate_3__c=3, 
                                                                        Factor_Value_Step_Rate_4__c=4, Factor_Value_Step_Rate_5__c=5, Factor_Value_Step_Rate_6__c=6,
                                                                        Factor_Value_Step_Rate_7__c=7);
        insert stepRateFactorAOP;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorAop.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorAop.Id);
        insert dedFactorObj;
        
        /*Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
acctivePolicy.Limit__c = coverageFactorObj.Id;
acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
acctivePolicy.Premium__c = null;
acctivePolicy.Total_5x5__c = 1000;
acctivePolicy.Total_10x10__c = 1000;
acctivePolicy.Primary__c = 1000;
acctivePolicy.Excess_Premium__c = 1000;
insert acctivePolicy;*/
        
        /*   Policy__c pol = TestDataFactory.createPolicy(acc.id,opp.id,null,'Policy');
//pol.Status__c = 'Accepted';
pol.Account__c = acc.Id;
pol.Limit__c = coverageFactorObj.Id;
pol.Deductible_ID__c = dedFactorObj.Id;
pol.Firm_Mod__c = 1;
pol.Base_Amount__c = 1000000;
pol.Premium__c = 150;
pol.Total_5x5__c=1;
pol.Total_10x10__c=1;
insert pol;
*/
        Opportunity opp  = TestDataFactory.createOpp(acc.id);
        

        
        Id recTypeId = Schema.SObjectType.Policy__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy.Effective_Date__c = system.today();
        acctivePolicy.Cancel_Date__c =  system.today()+2;
        acctivePolicy.Expiration_Date__c = date.today().addDays(10);
        acctivePolicy.Policy_Series_Effective_Date__c = system.today();
        acctivePolicy.Policy_Number__c = 'IL 106';
        acctivePolicy.RecordTypeId = recTypeId;
        acctivePolicy.Opportunity__c = opp.Id;
        acctivePolicy.Account__c = acc.Id;
        insert acctivePolicy;
        
        opp.Application_Policy__c = acctivePolicy.Id;
        insert opp;
        
         List<Policy_Lawyer__c> polLawyerList = new List<Policy_Lawyer__c>();
        Policy_Lawyer__c polLaw       = new Policy_Lawyer__c();
        polLaw.Account__c             = acc.Id;
        polLaw.Policy__c              = acctivePolicy.Id;
        polLaw.Prior_Act_Date__c      = date.today();
        polLaw.Lawyer__c              = acj.Id;
        polLaw.Rate_At__c = 100;
     //   polLaw.Overriding_Step_Value__c = 0;
        polLawyerList.add(polLaw);
        
         Policy_Lawyer__c polLaw1       = new Policy_Lawyer__c();
        polLaw1.Account__c             = acc.Id;
        polLaw1.Policy__c              = acctivePolicy.Id;
        polLaw1.Prior_Act_Date__c      = date.today();
        polLaw1.Lawyer__c              = acjList[0].Id;
        polLaw1.Rate_At__c = 100;
        polLaw1.Overriding_Step_Value__c = '1';
        polLawyerList.add(polLaw1);
        
         Policy_Lawyer__c polLaw2       = new Policy_Lawyer__c();
        polLaw2.Account__c             = acc.Id;
        polLaw2.Policy__c              = acctivePolicy.Id;
        polLaw2.Prior_Act_Date__c      = date.today();
        polLaw2.Lawyer__c              = acjList[1].Id;
        polLaw2.Rate_At__c = 100;
        polLaw2.Overriding_Step_Value__c = '2';
        polLawyerList.add(polLaw2);
        
        Policy_Lawyer__c   polLaw3     = new Policy_Lawyer__c();
        polLaw3.Account__c             = acc.Id;
        polLaw3.Policy__c              = acctivePolicy.Id;
        polLaw3.Prior_Act_Date__c      = date.today();
        polLaw3.Lawyer__c              = acjList[2].Id;
        polLaw3.Rate_At__c = 100;
        polLaw3.Overriding_Step_Value__c = '3';
        polLawyerList.add(polLaw3);
        
        Policy_Lawyer__c   polLaw4     = new Policy_Lawyer__c();
        polLaw4.Account__c             = acc.Id;
        polLaw4.Policy__c              = acctivePolicy.Id;
        polLaw4.Prior_Act_Date__c      = date.today();
        polLaw4.Lawyer__c              = acjList[3].Id;
        polLaw4.Rate_At__c = 100;
        polLaw4.Overriding_Step_Value__c = '4';
        polLawyerList.add(polLaw4);
        
        Policy_Lawyer__c   polLaw5     = new Policy_Lawyer__c();
        polLaw5.Account__c             = acc.Id;
        polLaw5.Policy__c              = acctivePolicy.Id;
        polLaw5.Prior_Act_Date__c      = date.today();
        polLaw5.Lawyer__c              = acjList[4].Id;
        polLaw5.Rate_At__c = 100;
        polLaw5.Overriding_Step_Value__c = '5';
        polLawyerList.add(polLaw5);
        
        Policy_Lawyer__c   polLaw6     = new Policy_Lawyer__c();
        polLaw6.Account__c             = acc.Id;
        polLaw6.Policy__c              = acctivePolicy.Id;
        polLaw6.Prior_Act_Date__c      = date.today();
        polLaw6.Lawyer__c              = acjList[5].Id;
        polLaw6.Rate_At__c = 100;
        polLaw6.Overriding_Step_Value__c = '6';
        polLawyerList.add(polLaw6);
        
        Policy_Lawyer__c   polLaw7     = new Policy_Lawyer__c();
        polLaw7.Account__c             = acc.Id;
        polLaw7.Policy__c              = acctivePolicy.Id;
        polLaw7.Prior_Act_Date__c      = date.today();
        polLaw7.Lawyer__c              = acjList[6].Id;
        polLaw7.Rate_At__c = 100;
        polLaw7.Overriding_Step_Value__c = '7';
        polLawyerList.add(polLaw7);
        
        insert polLawyerList;
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        
        Endorsement__c endorse = new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,Type__c = 'Descriptive',
                                                    Description__c='Test desc');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = new Endorsement_Version__c(Master_Endorsement__c=endorse.Id,Endorsement_Version_Number__c='1',
                                                                           Effective_From__c=System.today());
        insert endorseVersion;
        
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =acc.Id ,Name='Test Policy Endorsement', Policy__c =acctivePolicy.Id,Endorsement_Effective_Date__c = system.today(),
                                                                       RecordTypeId=devRecordTypeId);
        insert poicyEndorse;
        
        // Insert Master Factor
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
        
        Step_Rate_Factor__c stepRateFactorNew = new Step_Rate_Factor__c(Master_Factor__c=masterFactorNew.Id, Factor_Value_Step_Rate_0__c=0,
                                                                        Factor_Value_Step_Rate_1__c=1, Factor_Value_Step_Rate_2__c=2, Factor_Value_Step_Rate_3__c=3, 
                                                                        Factor_Value_Step_Rate_4__c=4, Factor_Value_Step_Rate_5__c=5, Factor_Value_Step_Rate_6__c=6,
                                                                        Factor_Value_Step_Rate_7__c=7);
        insert stepRateFactorNew;
        
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
        
        //  Policy_Lawyer__c polLawyer = TestDataFactory.createPolicyLawyer(acc.Id,acctivePolicy.Id,acj.Id);
        
        
        
        // polLawyer.Step__c = 1;
        //  insert polLawyer; 
        
        // Insert Policy Lawyer
        /* Policy_Lawyer__c polLawyer = TestDataFactory.createPolicyLawyer(acc.Id,acctivePolicy.Id,acj.Id);
polLawyer.Rate_At__c = 1000;
insert polLawyer;
*/ 
    }
    
    @isTest
    static void GetPolicyStepRateFactor_Test(){
        
        Map<integer,Decimal> intDecMap = new Map<integer,Decimal>();
        Test.startTest();
        ApplicationPolicyUtil.GetPolicyStepRateFactor(intDecMap);
        Test.stopTest();
    }
    
    @isTest
    static void GetPolicyAOPMod_Test(){
        
        Map<id,Decimal> intDecMap = new Map<id,Decimal>();
        Set<id> policyIdSet = new Set<id>();
        List<Policy__c> policyList = [Select id From Policy__c];
        for(Policy__c pol : policyList){
            policyIdSet.add(pol.id);
        }
        Test.startTest();
        ApplicationPolicyUtil.GetPolicyAOPMod(policyIdSet,intDecMap);
        Test.stopTest();
    }
    
    @isTest
    static void UpdateFinalQuote_ToLawyer_Test(){
        
        Map<id,Policy_Quote__c> policyQuoteMap = new Map<id,Policy_Quote__c>();
        List<Policy_Lawyer__C> lawyerList = [SELECT Id,Policy__c FROM Policy_Lawyer__c];
        List<Policy_Quote__c> policyQuoteList = [Select ID, Policy__c, Excess_Step_0__c, Excess_Step_1__c, Excess_Step_2__c, Excess_Step_3__c, Excess_Step_4__c,
                                                 Excess_Step_5__c,Excess_Step_6__c,Excess_Step_7__c,Primary_Step_0__c,Primary_Step_1__c,Primary_Step_2__c,
                                                 Primary_Step_3__c,Primary_Step_4__c,Primary_Step_5__c,Primary_Step_6__c,Primary_Step_7__c,
                                                 Quote_Premium_Step_0__c,Quote_Premium_Step_1__c,Quote_Premium_Step_2__c,Quote_Premium_Step_3__c,
                                                 Quote_Premium_Step_4__c,Quote_Premium_Step_5__c,Quote_Premium_Step_6__c,Quote_Premium_Step_7__c,
                                                 Mod_230__c,Mod_234__c,Mod_261__c,Quote_Premium_Step0_For_5X5__c,Quote_Premium_Step1_For_5X5__c,Quote_Premium_Step2_For_5X5__c,
                                                 Quote_Premium_Step3_For_5X5__c,Quote_Premium_Step4_For_5X5__c,Quote_Premium_Step5_For_5X5__c,Quote_Premium_Step6_For_5X5__c,
                                                 Quote_Premium_Step7_For_5X5__c,ADJ_MOD__c,X5X5_Override__c,X10X10__c
                                                 From Policy_Quote__c];
        if(!lawyerList.isEmpty()){
            for(Policy_Quote__c pq : policyQuoteList){
                policyQuoteMap.put(lawyerList[0].Policy__c,pq);
            }
        }
        system.debug('policyQuoteMap'+policyQuoteMap);
        Test.startTest();
        ApplicationPolicyUtil.UpdateFinalQuote_ToLawyer(policyQuoteMap, True);
        Test.stopTest();
    }
    
   /* @isTest
    static void UpdateFinalQuote_ToLawyer_Test_1(){
       // List<Policy__c> polList = [Select Id from Policy__c Limit 1];
       // system.debug('polListpolList '+ polList);
        
        // Insert Account
        Account acc                   = TestDataFactory.createAccounts('Bucket Account');
        insert acc;
        
        // Insert Contact
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        // Insert AccountContactJunction
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
         Master_Factor__c mas          = new Master_Factor__c();
        mas.Name                      = 'Test Master Factor';
        mas.Factor_Type__c            = 'Geo';
        mas.From_Date__c              = Date.today();
        mas.To_Date__c                = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day());
        mas.Default__c                = true;
        insert mas;
        
        
        County__c county              = new County__c();
        county.Name                   = 'Test County';
        county.Region__c              = '5';
        insert county;
        
        Geo_Factor__c geo             = new Geo_Factor__c();
        geo.Name                      = 'Test County';
        geo.Master_Factor__c          = mas.Id;
        geo.Region_Factor_Value__c    = 0.88;
        geo.County__c                 = county.Id;
        insert geo;

        
        Opportunity opp  = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        
          Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert masterFactorNew;      
        
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
        
        // Insert Policy Lawyer
       // Policy_Lawyer__c polLawyer = TestDataFactory.createPolicyLawyer(acc.Id,polList[0].Id,acj.Id);
        //polLawyer.Step__c = 1;
        //insert polLawyer;
       
         Id recTypeId = Schema.SObjectType.Policy__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = objfactor.Id;
        acctivePolicy.Deductible_ID__c = objDed.Id;
        acctivePolicy.Effective_Date__c = system.today();
        acctivePolicy.Cancel_Date__c =  system.today()+2;
        acctivePolicy.Expiration_Date__c = date.today().addDays(10);
        acctivePolicy.Policy_Series_Effective_Date__c = system.today();
        acctivePolicy.Policy_Number__c = 'IL 106';
        acctivePolicy.RecordTypeId = recTypeId;
        acctivePolicy.Opportunity__c = opp.Id;
        acctivePolicy.Account__c = acc.Id;
        insert acctivePolicy;
        
        Policy_Lawyer__c polLaw       = new Policy_Lawyer__c();
        polLaw.Account__c             = acc.Id;
        polLaw.Policy__c              = acctivePolicy.Id;
        polLaw.Prior_Act_Date__c      = date.today();
        polLaw.Lawyer__c              = acj.Id;
        polLaw.Rate_At__c = 100;
         polLaw.Step__c = 1;
        insert polLaw;    
        
        
        Map<id,Policy_Quote__c> policyQuoteMap = new Map<id,Policy_Quote__c>();
        List<Policy_Quote__c> policyQuoteList = [Select id,Policy__c,Primary_Step_1__c,Excess_Step_1__c,Primary_Step_0__c,Quote_Premium_Step_0__c,Mod_234__c,Mod_261__c,
                                                 Quote_Premium_Step0_For_5X5__c,Quote_Premium_Step1_For_5X5__c,Quote_Premium_Step_1__c,ADJ_MOD__c,
                                                 X10X10__c,X5X5_Override__c,Mod_230__c,Excess_Step_0__c
                                                 From Policy_Quote__c];
        
        for(Policy_Quote__c pq : policyQuoteList){
            policyQuoteMap.put(pq.Policy__c,pq);
        }
        
        //  List<Policy_Lawyer__c> polLawyerList = [Select id,Policy__c,Step__c from Policy_Lawyer__c];
        //  system.debug('polLawyerList275 '+ polLawyerList.size());
        //polLawyerList[0].Step__c = 1;
        
        //    if(!polLawyerList.isEmpty()){
        //    for(Policy_Lawyer__c poLaw : polLawyerList ){
        //       poLaw.Policy__c = policyQuoteList[0].Policy__c;
        //       poLaw.Step__c = 1;
        //   }
        //    
        //    Update polLawyerList;
        //    system.debug('polLawyerListpolLawyerList '+ polLawyerList);
        
        //  }
        
        Test.startTest();
        ApplicationPolicyUtil.UpdateFinalQuote_ToLawyer(policyQuoteMap, True);
        Test.stopTest();
    }*/
    
    @isTest
    static void UpdateFinalQuote_ToLawyer_Test_2(){
        
        
       /* List<Policy_Lawyer__c> polLawyerList = [Select id,Policy__c,Step__c from Policy_Lawyer__c];
        for(Policy_Lawyer__c poLaw : polLawyerList ){
             poLaw.Step__c = 2;
        }*/
       // Update polLawyerList;
        
        Map<id,Policy_Quote__c> policyQuoteMap = new Map<id,Policy_Quote__c>();
        List<Policy_Quote__c> policyQuoteList = [Select ID, Policy__c, Excess_Step_0__c, Excess_Step_1__c, Excess_Step_2__c, Excess_Step_3__c, Excess_Step_4__c,
                                                 Excess_Step_5__c,Excess_Step_6__c,Excess_Step_7__c,Primary_Step_0__c,Primary_Step_1__c,Primary_Step_2__c,
                                                 Primary_Step_3__c,Primary_Step_4__c,Primary_Step_5__c,Primary_Step_6__c,Primary_Step_7__c,
                                                 Quote_Premium_Step_0__c,Quote_Premium_Step_1__c,Quote_Premium_Step_2__c,Quote_Premium_Step_3__c,
                                                 Quote_Premium_Step_4__c,Quote_Premium_Step_5__c,Quote_Premium_Step_6__c,Quote_Premium_Step_7__c,
                                                 Mod_230__c,Mod_234__c,Mod_261__c,Quote_Premium_Step0_For_5X5__c,Quote_Premium_Step1_For_5X5__c,Quote_Premium_Step2_For_5X5__c,
                                                 Quote_Premium_Step3_For_5X5__c,Quote_Premium_Step4_For_5X5__c,Quote_Premium_Step5_For_5X5__c,Quote_Premium_Step6_For_5X5__c,
                                                 Quote_Premium_Step7_For_5X5__c,ADJ_MOD__c,X5X5_Override__c,X10X10__c
                                                 From Policy_Quote__c];
        for(Policy_Quote__c pq : policyQuoteList){
            policyQuoteMap.put(pq.Policy__c,pq);
        }
        Test.startTest();
        ApplicationPolicyUtil.UpdateFinalQuote_ToLawyer(policyQuoteMap, True);
        Test.stopTest();
    }
    
    
    @isTest
    static void UpdateFinalQuote_ToLawyer_Test_3(){
        
        List<Policy_Lawyer__c> polLawyerList = [Select id,Policy__c,Step__c from Policy_Lawyer__c];
        for(Policy_Lawyer__c poLaw : polLawyerList ){
            // poLaw.Step__c = 3;
        }
        Update polLawyerList;
        
        Map<id,Policy_Quote__c> policyQuoteMap = new Map<id,Policy_Quote__c>();
        List<Policy_Quote__c> policyQuoteList = [Select ID, Policy__c, Excess_Step_0__c, Excess_Step_1__c, Excess_Step_2__c, Excess_Step_3__c, Excess_Step_4__c,
                                                 Excess_Step_5__c,Excess_Step_6__c,Excess_Step_7__c,Primary_Step_0__c,Primary_Step_1__c,Primary_Step_2__c,
                                                 Primary_Step_3__c,Primary_Step_4__c,Primary_Step_5__c,Primary_Step_6__c,Primary_Step_7__c,
                                                 Quote_Premium_Step_0__c,Quote_Premium_Step_1__c,Quote_Premium_Step_2__c,Quote_Premium_Step_3__c,
                                                 Quote_Premium_Step_4__c,Quote_Premium_Step_5__c,Quote_Premium_Step_6__c,Quote_Premium_Step_7__c,
                                                 Mod_230__c,Mod_234__c,Mod_261__c,Quote_Premium_Step0_For_5X5__c,Quote_Premium_Step1_For_5X5__c,Quote_Premium_Step2_For_5X5__c,
                                                 Quote_Premium_Step3_For_5X5__c,Quote_Premium_Step4_For_5X5__c,Quote_Premium_Step5_For_5X5__c,Quote_Premium_Step6_For_5X5__c,
                                                 Quote_Premium_Step7_For_5X5__c,ADJ_MOD__c,X5X5_Override__c,X10X10__c
                                                 From Policy_Quote__c];
        for(Policy_Quote__c pq : policyQuoteList){
            policyQuoteMap.put(pq.Policy__c,pq);
        }
        Test.startTest();
        ApplicationPolicyUtil.UpdateFinalQuote_ToLawyer(policyQuoteMap, True);
        Test.stopTest();
    }
    
    @isTest
    static void UpdateFinalQuote_ToLawyer_Test_4(){
        
        List<Policy_Lawyer__c> polLawyerList = [Select id,Policy__c,Step__c from Policy_Lawyer__c];
        for(Policy_Lawyer__c poLaw : polLawyerList ){
            // poLaw.Step__c = 4;
        }
        Update polLawyerList;
        
        Map<id,Policy_Quote__c> policyQuoteMap = new Map<id,Policy_Quote__c>();
        List<Policy_Quote__c> policyQuoteList = [Select ID, Policy__c, Excess_Step_0__c, Excess_Step_1__c, Excess_Step_2__c, Excess_Step_3__c, Excess_Step_4__c,
                                                 Excess_Step_5__c,Excess_Step_6__c,Excess_Step_7__c,Primary_Step_0__c,Primary_Step_1__c,Primary_Step_2__c,
                                                 Primary_Step_3__c,Primary_Step_4__c,Primary_Step_5__c,Primary_Step_6__c,Primary_Step_7__c,
                                                 Quote_Premium_Step_0__c,Quote_Premium_Step_1__c,Quote_Premium_Step_2__c,Quote_Premium_Step_3__c,
                                                 Quote_Premium_Step_4__c,Quote_Premium_Step_5__c,Quote_Premium_Step_6__c,Quote_Premium_Step_7__c,
                                                 Mod_230__c,Mod_234__c,Mod_261__c,Quote_Premium_Step0_For_5X5__c,Quote_Premium_Step1_For_5X5__c,Quote_Premium_Step2_For_5X5__c,
                                                 Quote_Premium_Step3_For_5X5__c,Quote_Premium_Step4_For_5X5__c,Quote_Premium_Step5_For_5X5__c,Quote_Premium_Step6_For_5X5__c,
                                                 Quote_Premium_Step7_For_5X5__c,ADJ_MOD__c,X5X5_Override__c,X10X10__c
                                                 From Policy_Quote__c];
        for(Policy_Quote__c pq : policyQuoteList){
            policyQuoteMap.put(pq.Policy__c,pq);
        }
        Test.startTest();
        ApplicationPolicyUtil.UpdateFinalQuote_ToLawyer(policyQuoteMap, True);
        Test.stopTest();
    }
    
    @isTest
    static void UpdateFinalQuote_ToLawyer_Test_5(){
        
        List<Policy_Lawyer__c> polLawyerList = [Select id,Policy__c,Step__c from Policy_Lawyer__c];
        for(Policy_Lawyer__c poLaw : polLawyerList ){
            // poLaw.Step__c = 5;
        }
        Update polLawyerList;
        
        Map<id,Policy_Quote__c> policyQuoteMap = new Map<id,Policy_Quote__c>();
        List<Policy_Quote__c> policyQuoteList = [Select ID, Policy__c, Excess_Step_0__c, Excess_Step_1__c, Excess_Step_2__c, Excess_Step_3__c, Excess_Step_4__c,
                                                 Excess_Step_5__c,Excess_Step_6__c,Excess_Step_7__c,Primary_Step_0__c,Primary_Step_1__c,Primary_Step_2__c,
                                                 Primary_Step_3__c,Primary_Step_4__c,Primary_Step_5__c,Primary_Step_6__c,Primary_Step_7__c,
                                                 Quote_Premium_Step_0__c,Quote_Premium_Step_1__c,Quote_Premium_Step_2__c,Quote_Premium_Step_3__c,
                                                 Quote_Premium_Step_4__c,Quote_Premium_Step_5__c,Quote_Premium_Step_6__c,Quote_Premium_Step_7__c,
                                                 Mod_230__c,Mod_234__c,Mod_261__c,Quote_Premium_Step0_For_5X5__c,Quote_Premium_Step1_For_5X5__c,Quote_Premium_Step2_For_5X5__c,
                                                 Quote_Premium_Step3_For_5X5__c,Quote_Premium_Step4_For_5X5__c,Quote_Premium_Step5_For_5X5__c,Quote_Premium_Step6_For_5X5__c,
                                                 Quote_Premium_Step7_For_5X5__c,ADJ_MOD__c,X5X5_Override__c,X10X10__c
                                                 From Policy_Quote__c];
        for(Policy_Quote__c pq : policyQuoteList){
            policyQuoteMap.put(pq.Policy__c,pq);
        }
        Test.startTest();
        ApplicationPolicyUtil.UpdateFinalQuote_ToLawyer(policyQuoteMap, True);
        Test.stopTest();
    }
    
    @isTest
    static void UpdateFinalQuote_ToLawyer_Test_6(){
        
        List<Policy_Lawyer__c> polLawyerList = [Select id,Policy__c,Step__c from Policy_Lawyer__c];
        for(Policy_Lawyer__c poLaw : polLawyerList ){
            // poLaw.Step__c = 6;
        }
        Update polLawyerList;
        
        Map<id,Policy_Quote__c> policyQuoteMap = new Map<id,Policy_Quote__c>();
        List<Policy_Quote__c> policyQuoteList = [Select ID, Policy__c, Excess_Step_0__c, Excess_Step_1__c, Excess_Step_2__c, Excess_Step_3__c, Excess_Step_4__c,
                                                 Excess_Step_5__c,Excess_Step_6__c,Excess_Step_7__c,Primary_Step_0__c,Primary_Step_1__c,Primary_Step_2__c,
                                                 Primary_Step_3__c,Primary_Step_4__c,Primary_Step_5__c,Primary_Step_6__c,Primary_Step_7__c,
                                                 Quote_Premium_Step_0__c,Quote_Premium_Step_1__c,Quote_Premium_Step_2__c,Quote_Premium_Step_3__c,
                                                 Quote_Premium_Step_4__c,Quote_Premium_Step_5__c,Quote_Premium_Step_6__c,Quote_Premium_Step_7__c,
                                                 Mod_230__c,Mod_234__c,Mod_261__c,Quote_Premium_Step0_For_5X5__c,Quote_Premium_Step1_For_5X5__c,Quote_Premium_Step2_For_5X5__c,
                                                 Quote_Premium_Step3_For_5X5__c,Quote_Premium_Step4_For_5X5__c,Quote_Premium_Step5_For_5X5__c,Quote_Premium_Step6_For_5X5__c,
                                                 Quote_Premium_Step7_For_5X5__c,ADJ_MOD__c,X5X5_Override__c,X10X10__c
                                                 From Policy_Quote__c];
        for(Policy_Quote__c pq : policyQuoteList){
            policyQuoteMap.put(pq.Policy__c,pq);
        }
        Test.startTest();
        ApplicationPolicyUtil.UpdateFinalQuote_ToLawyer(policyQuoteMap, True);
        Test.stopTest();
    }
    
    @isTest
    static void UpdateFinalQuote_ToLawyer_Test_7(){
        
        List<Policy_Lawyer__c> polLawyerList = [Select id,Policy__c,Step__c from Policy_Lawyer__c];
        for(Policy_Lawyer__c poLaw : polLawyerList ){
            //  poLaw.Step__c = 7;
        }
        Update polLawyerList;
        
        Map<id,Policy_Quote__c> policyQuoteMap = new Map<id,Policy_Quote__c>();
        List<Policy_Quote__c> policyQuoteList = [Select ID, Policy__c, Excess_Step_0__c, Excess_Step_1__c, Excess_Step_2__c, Excess_Step_3__c, Excess_Step_4__c,
                                                 Excess_Step_5__c,Excess_Step_6__c,Excess_Step_7__c,Primary_Step_0__c,Primary_Step_1__c,Primary_Step_2__c,
                                                 Primary_Step_3__c,Primary_Step_4__c,Primary_Step_5__c,Primary_Step_6__c,Primary_Step_7__c,
                                                 Quote_Premium_Step_0__c,Quote_Premium_Step_1__c,Quote_Premium_Step_2__c,Quote_Premium_Step_3__c,
                                                 Quote_Premium_Step_4__c,Quote_Premium_Step_5__c,Quote_Premium_Step_6__c,Quote_Premium_Step_7__c,
                                                 Mod_230__c,Mod_234__c,Mod_261__c,Quote_Premium_Step0_For_5X5__c,Quote_Premium_Step1_For_5X5__c,Quote_Premium_Step2_For_5X5__c,
                                                 Quote_Premium_Step3_For_5X5__c,Quote_Premium_Step4_For_5X5__c,Quote_Premium_Step5_For_5X5__c,Quote_Premium_Step6_For_5X5__c,
                                                 Quote_Premium_Step7_For_5X5__c,ADJ_MOD__c,X5X5_Override__c,X10X10__c
                                                 From Policy_Quote__c];
        for(Policy_Quote__c pq : policyQuoteList){
            policyQuoteMap.put(pq.Policy__c,pq);
        }
        Test.startTest();
        ApplicationPolicyUtil.UpdateFinalQuote_ToLawyer(policyQuoteMap, True);
        Test.stopTest();
    }
    
    
    @isTest
    static void UpdateFinalQuoteToPolicy_Test(){
        
        List<Policy_Quote__c> policyQuoteList = [Select id,Policy__c,Final_Quote__c From Policy_Quote__c];
        Test.startTest();
        ApplicationPolicyUtil.UpdateFinalQuoteToPolicy(policyQuoteList, True);
        Test.stopTest();
    }
    
    @isTest
    static void UpdateFinalQuoteToPolicy_Test_1(){
        
        List<Policy_Quote__c> policyQuoteList = [Select id,Policy__c,Quote_Final_Premium__c,Deductible_Amount__c,Deductible__c, Coverage__c,Coverage_Max_Per_Claim__c,Full_Coverage__c,ADJ_MOD__c,Mod_230__c,Mod_234__c,Mod_261__c,Primary_Final__c,Excess_Final__c ,Final_Quote__c,X5X5_Override__c,X10x10__c,Quote_Premium_AllStep_For_5X5__c  From Policy_Quote__c];
        for(Policy_Quote__c pq : policyQuoteList){
            pq.Final_Quote__c = true;
        }
        
        Test.startTest();
        ApplicationPolicyUtil.UpdateFinalQuoteToPolicy(policyQuoteList, False);
        Test.stopTest();
    }
    
    
    @isTest
    static void CreateAccuntingSeedsForPolicy_Test(){
        
        Set<id> policyIdSet = new Set<id>();
        List<Policy__c> policyList = [Select id,Total_5x5__c,Total_10x10__c From Policy__c];
        
        policyIdSet.add(policyList[0].id);
        
        Test.startTest();
        ApplicationPolicyUtil.CreateAccuntingSeedsForPolicy(policyIdSet);
        Test.stopTest();
    }
    
    
    @isTest
    static void UpdateAccountContactjunction_Test(){
        
        Set<id> policyIdSet = new Set<id>();
        List<Policy__c> policyList = [Select id From Policy__c];
        for(Policy__c pol : policyList){
            policyIdSet.add(pol.id);
        }
        
        Test.startTest();
        ApplicationPolicyUtil.UpdateAccountContactjunction(policyIdSet);
        Test.stopTest();
    }
    @isTest
    static void createLSAonRenewal_Test(){
        
        Set<id> policyIdSet = new Set<id>();
        List<Policy__c> policyList = [Select id From Policy__c];
        for(Policy__c pol : policyList){
            policyIdSet.add(pol.id);
        }
        
        Test.startTest();
        ApplicationPolicyUtil.createLSAonRenewal(policyIdSet);
        Test.stopTest();
    }
    
    @isTest
    static void updatePolicyWithOpportunity_Test(){
        
        Set<id> policyIdSet = new Set<id>();
        List<Policy__c> policyList = [Select id From Policy__c];
        for(Policy__c pol : policyList){
            policyIdSet.add(pol.id);
        }
        
        Test.startTest();
        ApplicationPolicyUtil.updatePolicyWithOpportunity(policyIdSet);
        Test.stopTest();
    }
    
    
    @isTest
    static void CalculateLawyerStep_Test(){
        
        Test.startTest();
        ApplicationPolicyUtil.CalculateLawyerStep(Date.today(), Date.today());
        Test.stopTest();
    }
    
    
    /**
@isTest
static void createOpportuniies_Test(){




List<Opportunity> oppList = [Select id from Opportunity];
system.debug('oppList222 ' +  oppList);

oppList[0].CloseDate= Date.today();
oppList[0].StageName='Closed Won';
oppList[1].CloseDate= Date.today();
oppList[1].StageName='Closed Won';
oppList[2].CloseDate= Date.today();
oppList[2].StageName='Closed Won';

update oppList;
system.debug('oppList223 ' +  oppList);

List<Policy__c> policyList = [Select id From Policy__c];
policyList[0].Opportunity__c = oppList[0].Id;
Update policyList;
system.debug('oppList492policyList ' +  policyList);

Test.startTest();
ApplicationPolicyUtil ctrl = new ApplicationPolicyUtil();
ctrl.createOpportuniies(policyList);
Test.stopTest();
}
**/
    @isTest
    static void GetPolicyBaseAmt_Test(){
        
        Test.startTest();
        ApplicationPolicyUtil.GetPolicyBaseAmt();
        Test.stopTest();
    }
    
}