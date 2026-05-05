@isTest
public class QuickQuoteCtrl_Test {
    @testSetup 
    static void testData(){
        
        // Insert Account
        Account acc = TestDataFactory.createAccounts('Test Account');
        insert acc;
        
        // Insert Contact 
        Contact con = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        // Insert AccountContactJunction
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name = 'Test Name';
        insert acj;
        
        // Insert Opportunity
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        insert opp;
        
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
        
        
        
        Base_Factor__c baseFactor = new Base_Factor__c(Master_Factor__c=masterFactor1.Id, Base_Amount__c=100);
        insert baseFactor;
        
        
        Policy__c pol                 = new Policy__c();
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
        insert pol;
        
        
        Master_Factor__c masterFactorAop = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        masterFactorAop.From_Date__c = system.today();
        masterFactorAop.To_Date__c = system.today()+7;
        insert masterFactorAop;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorAop.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorAop.Id);
        insert dedFactorObj;
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy.Effective_Date__c = system.today();
        acctivePolicy.Primary__c = 100;
        acctivePolicy.Excess_Premium__c = 100;
        acctivePolicy.Premium__c = null;
        
        
        insert acctivePolicy;
        
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        
        Endorsement__c endorse = new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
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
        masterFactorNew.From_Date__c = system.today()-10;
        masterFactorNew.To_Date__c = system.today()+10;
        insert masterFactorNew;
        
        // Insert Master Factor
        Master_Factor__c masterFactorNewBase = TestDataFactory.createMasterfactor('Test Master Factor','Base Value');
        masterFactorNewBase.From_Date__c = system.today()-10;
        masterFactorNewBase.To_Date__c = system.today()+10;
        insert masterFactorNewBase;
        
        //Base_Factor__c
        Base_Factor__c baseObj = new Base_Factor__c();
        baseObj.Master_Factor__c = masterFactorNewBase.id;
        baseObj.Base_Amount__c = 100;
        insert baseObj;
        
        // Insert ILF Coverage Factor
        ILF_Coverage_Factor__c objfactor = new ILF_Coverage_Factor__c();
        objfactor.name = '250,000 / 500,000';
        objfactor.Coverage_Max_Per_Claim__c = 250000.00;
        objfactor.Full_Coverage__c = 500;
        objfactor.Factor_Value__c =12;
        objfactor.Master_Factor__c = masterFactorNew.id;
        objfactor.Lowest_Coverage__c = true;
        objfactor.X4x1_Rate__c = 100;
        objfactor.Is_5X5_Coverage__c = TRUE;
        objfactor.Is_10X10_Coverage__c = TRUE;
        objfactor.Premium_Rate_5X5__c = 100;
        objfactor.Percentage_5X5_Step_0__c = 10;
        objfactor.Percentage_5X5_Step_1__c = 10;
        objfactor.Percentage_5X5_Step_2__c = 10;
        objfactor.Percentage_5X5_Step_3__c = 10;
        objfactor.Percentage_5X5_Step_4__c = 10;
        objfactor.Percentage_5X5_Step_5__c = 10;
        objfactor.Percentage_5X5_Step_6__c = 10;
        objfactor.Percentage_5X5_Step_7__c = 10;
        insert objfactor;
        
       /*ILF_Coverage_Factor__c ilfFactor = [select id,Name,Factor_Value__c,X4x1_Rate__c,Is_5X5_Coverage__c,Coverage_Max_Per_Claim__c,Full_Coverage__c,Is_10X10_Coverage__c,
                                                Percnt_amt_5X5_Step_0__c,Percnt_amt_5X5_Step_1__c,Percnt_amt_5X5_Step_2__c,Percnt_amt_5X5_Step_3__c,Percnt_amt_5X5_Step_4__c,
                                                Percnt_amt_5X5_Step_5__c,Percnt_amt_5X5_Step_6__c,Percnt_amt_5X5_Step_7__c from ILF_Coverage_Factor__c where id=: selectedLimit];
        */
    
        
        Deductible_Factor__c objDed = new Deductible_Factor__c();
        objDed.Name = '12';
        objDed.Deductible_External_ID__c = '12345';
        objDed.Deductible_Amount__c = 124;
        objDed.Factor_Value__c = 1233;
        objDed.Master_Factor__c = masterFactorNew.id;
        insert objDed;
        
        /**
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
        objQuote.Primary_Step_0__c = 2000;
        objQuote.Excess_Step_0__c = 2000;
        objQuote.Excess_Step_1__c = 2000;
        objQuote.Excess_Step_2__c = 2000;
        objQuote.Excess_Step_3__c = 2000;
        objQuote.Excess_Step_4__c = 2000;
        objQuote.Excess_Step_5__c = 2000;
        objQuote.Excess_Step_6__c = 2000;
        objQuote.Excess_Step_7__c = 2000;
        objQuote.Primary_Step_1__c = 2000;
        objQuote.Primary_Step_2__c = 2000;
        objQuote.Primary_Step_3__c = 2000;
        objQuote.Primary_Step_4__c = 2000;
        objQuote.Primary_Step_5__c = 2000;
        objQuote.Primary_Step_6__c = 2000;
        objQuote.Primary_Step_7__c = 2000;
        
        
        insert objQuote;
        **/
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
        
        // Insert Policy Lawyer
        Policy_Lawyer__c polLawyer = TestDataFactory.createPolicyLawyer(acc.Id,acctivePolicy.Id,acj.Id);
        polLawyer.Rate_At__c = 1000;
        insert polLawyer;
        
    }
    
    @isTest static void testMethod1(){
         
        List<Master_Factor__c> MF = [Select Id From Master_Factor__c LIMIT 1];
        List<Policy__c> pol = [SELECT Id,Account__c,Deductible_ID__c,Firm_Mod__c,AOP_Factor__c,GEO_Mod__c,SCH_Mod__c,Account__r.Name,County__c, Effective_Date__c, Expiration_Date__c FROM Policy__c LIMIT 2];
        Pol[0].Limit__c = MF[0].id;
        Pol[1].Limit__c = MF[0].id;
        
        Test.startTest();
        
        QuickQuoteCtrl.getLookupRecord('a', 'Policy__c', 'test');
        QuickQuoteCtrl qCtrl = new QuickQuoteCtrl();
        qCtrl.x5x5 = 5;
        qCtrl.x10x10 = 10;
        qCtrl.firmMod = 100;
        qCtrl.application_policy = pol[0];
        qCtrl.existing_policy = pol[1];
        qCtrl.existingPolicyId = pol[1].Id;
        qCtrl.getPolicyCounty();
        qCtrl.getLimit();
        qCtrl.getDeductible();
        qCtrl.addQuickQuote();
        qCtrl.removeRow();
        qCtrl.updateCountyFunc();
        qCtrl.updateEffectiveDateFunc();
        qCtrl.preSetPolicyDataFunc();
        qCtrl.renderPolicyDataFunc();
        
        Test.stopTest();
    }
    
    @isTest static void testMethod2(){
        List<Policy__c> pol = [SELECT Id,Account__c,Deductible_ID__c,Firm_Mod__c,AOP_Factor__c,GEO_Mod__c,SCH_Mod__c,Account__r.Name,County__c, Effective_Date__c, Expiration_Date__c FROM Policy__c LIMIT 2];
        pol[0].Effective_Date__c = NULL;
        Test.startTest();
        QuickQuoteCtrl qCtrl = new QuickQuoteCtrl();
        qCtrl.application_policy = pol[0];
        qCtrl.existing_policy = pol[1];
        qCtrl.selectedLimit = 'Value';
        qCtrl.addQuickQuote();
        Test.stopTest();
    }
    
    @isTest static void testMethod3(){
        List<Policy__c> pol = [SELECT Id,Account__c,Deductible_ID__c,Firm_Mod__c,AOP_Factor__c,GEO_Mod__c,SCH_Mod__c,Account__r.Name,County__c, Effective_Date__c, Expiration_Date__c FROM Policy__c LIMIT 2];
        Test.startTest();
        QuickQuoteCtrl qCtrl = new QuickQuoteCtrl();
        qCtrl.application_policy = pol[0];
        qCtrl.existing_policy = pol[1];
        qCtrl.selectedLimit = 'Value';
        qCtrl.addQuickQuote();
        Test.stopTest();
    }
    @isTest static void testMethod4(){
        List<Policy__c> pol = [SELECT Id,Account__c,Deductible_ID__c,Firm_Mod__c,AOP_Factor__c,GEO_Mod__c,SCH_Mod__c,Account__r.Name,County__c, Effective_Date__c, Expiration_Date__c FROM Policy__c LIMIT 2];
        Test.startTest();
        QuickQuoteCtrl qCtrl = new QuickQuoteCtrl();
        qCtrl.application_policy = pol[0];
        qCtrl.existing_policy = pol[1];
        qCtrl.selectedDeductible = 'Value';
        qCtrl.addQuickQuote();
        Test.stopTest();
    }
    @isTest static void testMethod5(){
        List<Policy__c> pol = [SELECT Id,Account__c,Deductible_ID__c,Firm_Mod__c,AOP_Factor__c,GEO_Mod__c,SCH_Mod__c,Account__r.Name,County__c, Effective_Date__c, Expiration_Date__c FROM Policy__c LIMIT 2];
        Test.startTest();
        QuickQuoteCtrl qCtrl = new QuickQuoteCtrl();
        qCtrl.application_policy = pol[0];
        qCtrl.existing_policy = pol[1];
        qCtrl.step0 = 0;
        qCtrl.step1 = 0;
        qCtrl.step2 = 0;
        qCtrl.step3 = 0;
        qCtrl.step4 = 0;
        qCtrl.step5 = 0;
        qCtrl.step6 = 0;
        qCtrl.step7 = 0;
        qCtrl.selectedLimit = 'Value';
        qCtrl.selectedDeductible = 'Value';
        qCtrl.addQuickQuote();
        Test.stopTest();
    }
    
    @isTest static void testMethod6(){
        List<Policy__c> pol = [SELECT Id,Account__c,Deductible_ID__c,Firm_Mod__c,AOP_Factor__c,GEO_Mod__c,SCH_Mod__c,Account__r.Name,County__c, Effective_Date__c, Expiration_Date__c FROM Policy__c LIMIT 2];
        pol[0].County__c = NULL;
        Test.startTest();
        QuickQuoteCtrl qCtrl = new QuickQuoteCtrl();
        qCtrl.application_policy = pol[0];
        qCtrl.existing_policy = pol[1];
        qCtrl.step0 = 1;
        qCtrl.step1 = 0;
        qCtrl.step2 = 0;
        qCtrl.step3 = 0;
        qCtrl.step4 = 0;
        qCtrl.step5 = 0;
        qCtrl.step6 = 0;
        qCtrl.step7 = 0;
        qCtrl.selectedLimit = 'Value';
        qCtrl.selectedDeductible = 'Value';
        qCtrl.addQuickQuote();
        Test.stopTest();
    }
    @isTest static void testMethod7(){
        Test.startTest();
        list<Master_Factor__c> mList = [SELECT id FROM Master_Factor__c LIMIT 1];
        list<Deductible_Factor__c> dedList = [SELECT id FROM Deductible_Factor__c LIMIT 1];
        list<ILF_Coverage_Factor__c> listCOV = [SELECT id FROM ILF_Coverage_Factor__c LIMIT 1];
        List<Policy__c> pol = [SELECT Id,Account__c,Deductible_ID__c,Firm_Mod__c,AOP_Factor__c,GEO_Mod__c,SCH_Mod__c,Account__r.Name,County__c, Effective_Date__c, Expiration_Date__c FROM Policy__c LIMIT 2];
//        Test.startTest();
        QuickQuoteCtrl qCtrl = new QuickQuoteCtrl();
        qCtrl.application_policy = pol[0];
        qCtrl.existing_policy = pol[1];
        qCtrl.step0 = 1;
        qCtrl.step1 = 1;
        qCtrl.step2 = 1;
        qCtrl.step3 = 1;
        qCtrl.step4 = 1;
        qCtrl.step5 = 1;
        qCtrl.step6 = 1;
        qCtrl.step7 = 1;
        qCtrl.selectedLimit = listCOV[0].id; // change here
        qCtrl.selectedDeductible = dedList[0].id; // change here
        qCtrl.addQuickQuote();
        Test.stopTest();
    }
    
    @isTest static void testMethod10(){
        
        List<Policy_Lawyer__c> PolLaw = [Select ID,Step__c From Policy_Lawyer__c LIMIT 1 ];
        List<Master_Factor__c> MF = [Select Id From Master_Factor__c LIMIT 1];
        List<Policy__c> pol = [SELECT Id,Account__c,Deductible_ID__c,Firm_Mod__c,AOP_Factor__c,GEO_Mod__c,SCH_Mod__c,Account__r.Name,County__c, Effective_Date__c, Expiration_Date__c FROM Policy__c LIMIT 2];
        Pol[0].Limit__c = MF[0].id;
        Pol[1].Limit__c = MF[0].id;
        Test.startTest();
        QuickQuoteCtrl qCtrl = new QuickQuoteCtrl();
        qCtrl.x5x5 = 5;
        qCtrl.x10x10 = 10;
        qCtrl.firmMod = 100;
        qCtrl.application_policy = pol[0];
        qCtrl.existing_policy = pol[1];
        qCtrl.existingPolicyId = pol[1].Id;
        // change step and run func
        PolLaw[0].Step__c = 0;
        update PolLaw;
        qCtrl.preSetPolicyDataFunc();
        // change step and run func
        PolLaw[0].Step__c = 1;
        update PolLaw;
        qCtrl.preSetPolicyDataFunc();
        // change step and run func
        PolLaw[0].Step__c = 2;
        update PolLaw;
        qCtrl.preSetPolicyDataFunc();
        // change step and run func
        PolLaw[0].Step__c = 3;
        update PolLaw;
        qCtrl.preSetPolicyDataFunc();
        // end
        // change step and run func
        PolLaw[0].Step__c = 4;
        update PolLaw;
        qCtrl.preSetPolicyDataFunc();
        // change step and run func
        PolLaw[0].Step__c = 5;
        update PolLaw;
        qCtrl.preSetPolicyDataFunc();
        // change step and run func
        PolLaw[0].Step__c = 6;
        update PolLaw;
        qCtrl.preSetPolicyDataFunc();
        // change step and run func
        PolLaw[0].Step__c = 7;
        update PolLaw;
        qCtrl.preSetPolicyDataFunc();
        // end
        Test.stopTest();
    }
}