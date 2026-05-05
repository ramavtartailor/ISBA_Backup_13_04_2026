@isTest
public class Policy_Lawyer_Trg_Handler_Test {
    
    @TestSetup
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
        
        
        Master_Factor__c masterFactorAop = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorAop;
        
        Step_Rate_Factor__c stepRateFactorAOP = new Step_Rate_Factor__c(Master_Factor__c=masterFactorAop.Id, Factor_Value_Step_Rate_0__c=0,
                                                                        Factor_Value_Step_Rate_1__c=1, Factor_Value_Step_Rate_2__c=2, Factor_Value_Step_Rate_3__c=3, 
                                                                        Factor_Value_Step_Rate_4__c=4, Factor_Value_Step_Rate_5__c=5, Factor_Value_Step_Rate_6__c=6,
                                                                        Factor_Value_Step_Rate_7__c=7);
        insert stepRateFactorAOP;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorAop.Id);
        coverageFactorObj.Coverage_Max_Per_Claim__c = 1000000;
        coverageFactorObj.Full_Coverage__c = 1000000;
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorAop.Id);
        dedFactorObj.Deductible_Amount__c = 0;
        insert dedFactorObj;
        
        Opportunity opp  = TestDataFactory.createOpp(acc.id);
        
        
        
        Treaty_Versions__c TVPol = new Treaty_Versions__c();
        TVPol.Treaty_Correction_Processed__c = false;
        TVPol.Ceded_Primary_Rate_Delta__c = 1;
        TVPol.Ceded_4x1_Rate_Delta__c = 1;
        TVPol.Ceded_Primary_Rate_Delta__c = 1;
        
        insert TVPol;
        
        
        Id recTypeId = Schema.SObjectType.Policy__c.getRecordTypeInfosByName().get('SA-ERP').getRecordTypeId();
        
        Policy__c acctivePolicy1 = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy1.Limit__c = coverageFactorObj.Id;
        acctivePolicy1.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy1.Effective_Date__c = system.today();
        acctivePolicy1.Cancel_Date__c =  system.today()+2;
        acctivePolicy1.Expiration_Date__c = date.today().addDays(10);
        acctivePolicy1.Policy_Series_Effective_Date__c = system.today();
        acctivePolicy1.Policy_Number__c = 'IL 106';
        //acctivePolicy1.RecordTypeId = recTypeId;
        acctivePolicy1.Opportunity__c = opp.Id;
        acctivePolicy1.Account__c = acc.Id;
        acctivePolicy1.Treaty_Version__c = TVPol.Id;
        insert acctivePolicy1;
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Application');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy.Effective_Date__c = system.today();
        acctivePolicy.Cancel_Date__c =  system.today()+2;
        acctivePolicy.Previous_Policy__c = acctivePolicy1.Id;       
        acctivePolicy.Expiration_Date__c = date.today().addDays(10);
        acctivePolicy.Policy_Series_Effective_Date__c = system.today();
        acctivePolicy.Policy_Number__c = 'IL 106';
        //acctivePolicy.RecordTypeId = recTypeId;
        acctivePolicy.Opportunity__c = opp.Id;
        acctivePolicy.Account__c = acc.Id;
        acctivePolicy.Treaty_Version__c = TVPol.Id;
        insert acctivePolicy;
        
        Customer_Application__c objCustomerApp = new Customer_Application__c();
        objCustomerApp.Is_the_firm_currently_insured__c = 'No';
        objCustomerApp.PolicyId__c = acctivePolicy.Id;
        insert objCustomerApp;
        
        acctivePolicy.Customer_Application__c = objCustomerApp.Id;
        Update acctivePolicy;
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
        
        TEST.startTest();
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
        objQuote.Final_Quote__c = true;
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
    }
    
    @isTest
    static void test1(){
        test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1]; 
        Policy__c acctivePolicy = [SELECT Id FROM Policy__c WHERE Previous_Policy__c = null LIMIT 1];
        List<AccountContactJunction__c> acjList = [SELECT Id FROM AccountContactJunction__c];
        
        List<Policy_Lawyer__c> polLawyerList = new List<Policy_Lawyer__c>();
        Policy_Lawyer__c polLaw1       = new Policy_Lawyer__c();
        polLaw1.Account__c             = acc.Id;
        polLaw1.Policy__c              = acctivePolicy.Id;
        polLaw1.Prior_Act_Date__c      = date.today();
        polLaw1.Lawyer__c              = acjList[0].Id;
        polLaw1.Rate_At__c = 100;
        polLaw1.Overriding_Step_Value__c = '1';
        polLawyerList.add(polLaw1);
        
        /*Policy_Lawyer__c polLaw2       = new Policy_Lawyer__c();
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
        polLawyerList.add(polLaw7);*/
        TriggerFactory.isUpdatePremium = false; 
        insert polLawyerList;
        
        polLaw1.Deleted_Date__c = system.today();
        Update polLaw1;
        test.stopTest();
    }
}