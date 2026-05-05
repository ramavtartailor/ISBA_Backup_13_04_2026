@isTest
public class EndoresementFieldSetInformationCtrl_Test {
    @isTest static void testMethod1(){
        
        Test.startTest();
        
        Account objAccount = new Account();
        objAccount.Name='test';
        insert objAccount;
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        insert endorse;
        
        system.debug('==========endorse======'+endorse);
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor','Deductible');
        insert mas12;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        DedFac.Factor_Value__c =10;
        Insert DedFac; 
        
        Map<String,String> mapRecordTypes = new Map<String,String>();
        
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        // Insert Master Factor coverage        
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        // Insert ILF Coverage factor        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoverageFactor(MasterFactorCoverage.Id);
        insert FactorCoverage;
        
        Master_Factor__c masterFactor = new Master_Factor__c(Factor_Type__c='Step Rate', Default__c=true,From_Date__c= Date.today(),
                                                             To_Date__c= Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day()),
                                                             Name  = 'Test Master Factor0');
        insert masterFactor;
        
        Step_Rate_Factor__c stepRateFactor = new Step_Rate_Factor__c(Master_Factor__c=masterFactor.Id, Factor_Value_Step_Rate_0__c=0,
                                                                     Factor_Value_Step_Rate_1__c=1, Factor_Value_Step_Rate_2__c=2, Factor_Value_Step_Rate_3__c=3, 
                                                                     Factor_Value_Step_Rate_4__c=4, Factor_Value_Step_Rate_5__c=5, Factor_Value_Step_Rate_6__c=6,
                                                                     Factor_Value_Step_Rate_7__c=7);
        insert stepRateFactor;
        
        Policy__c objPolicy = new Policy__c();
        objPolicy.Name = 'test3';
        objPolicy.Effective_Date__c = System.today();
        objPolicy.Expiration_Date__c = System.today().addDays(1);
        objPolicy.Account__c = objAccount.Id;
        objPolicy.Base_Amount__c = 100;
        objPolicy.Firm_Mod__c = 120;
        objPolicy.Limit__c = FactorCoverage.Id;
        objPolicy.Deductible_ID__c = DedFac.id;
        objPolicy.Expiration_Date__c = date.today().addMonths(2);
        insert objPolicy; 
        
        Policy_Endorsement__c objPolEndorse = new Policy_Endorsement__c();
        objPolEndorse.Name = 'test';
        objPolEndorse.Account__c = objAccount.id;
        objPolEndorse.Policy__c = objPolicy.id;
        objPolEndorse.Effective_Date__c = system.today();
        objPolEndorse.Prior_Act_Date__c = system.today().addDays(2);
        objPolEndorse.RecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        objPolEndorse.Endorsement_Effective_Date__c = date.today();    
        insert objPolEndorse;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objPolEndorse);
        EndoresementFieldSetInformation_Ctrl objEndorsment = new EndoresementFieldSetInformation_Ctrl(sc);
        
        objEndorsment.getLayouts();
        objEndorsment.getFields();
        
        Test.stopTest();
    }
    
    @isTest static void testMethod2(){
        
        Test.startTest();
        
        Account objAccount = new Account();
        objAccount.Name='test';
        insert objAccount;
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 107B U.S. Active Duty Military Service Extended Reporting Period Election').getRecordTypeId();
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','IL 107B U.S. Active Duty Military Service Extended Reporting Period Election');
        insert endorse;
        
        system.debug('==========endorse======'+endorse);
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor','Deductible');
        insert mas12;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        DedFac.Factor_Value__c =10;
        Insert DedFac; 
        
        Map<String,String> mapRecordTypes = new Map<String,String>();
        
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        // Insert Master Factor coverage        
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        // Insert ILF Coverage factor        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoverageFactor(MasterFactorCoverage.Id);
        insert FactorCoverage;
        
        Policy__c objPolicy = new Policy__c();
        objPolicy.Name = 'test3';
        objPolicy.Effective_Date__c = System.today();
        objPolicy.Account__c = objAccount.Id;
        objPolicy.Base_Amount__c = 100;
        objPolicy.Firm_Mod__c = 120;
        objPolicy.Limit__c = FactorCoverage.Id;
        objPolicy.Deductible_ID__c = DedFac.id;
        objPolicy.Expiration_Date__c = date.today().addMonths(2);
        insert objPolicy; 
        
        Policy_Endorsement__c objPolEndorse = new Policy_Endorsement__c();
        objPolEndorse.Name = 'test';
        objPolEndorse.Account__c = objAccount.id;
        objPolEndorse.Policy__c = objPolicy.id;
        objPolEndorse.Effective_Date__c = system.today();
        objPolEndorse.Prior_Act_Date__c = system.today().addDays(2);
        objPolEndorse.RecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 107B U.S. Active Duty Military Service Extended Reporting Period Election').getRecordTypeId();
        objPolEndorse.Endorsement_Effective_Date__c = date.today(); 
        insert objPolEndorse;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objPolEndorse);
        EndoresementFieldSetInformation_Ctrl objEndorsment = new EndoresementFieldSetInformation_Ctrl(sc);
        
        objEndorsment.getLayouts();
        objEndorsment.getFields();
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod3(){
        
        Test.startTest();
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 101A SPECIFIC ATTORNEY(S) EXCLUSION ENDORSEMENT').getRecordTypeId();
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','IL 101A SPECIFIC ATTORNEY(S) EXCLUSION ENDORSEMENT');
        insert endorse;
        
        system.debug('==========endorse======'+endorse);
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Account objAccount = new Account();
        objAccount.Name='test';
        insert objAccount;
        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor','Deductible');
        insert mas12;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        DedFac.Factor_Value__c =10;
        Insert DedFac; 
        
        Map<String,String> mapRecordTypes = new Map<String,String>();
        
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        // Insert Master Factor coverage        
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        // Insert ILF Coverage factor        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoverageFactor(MasterFactorCoverage.Id);
        insert FactorCoverage;
        
        Policy__c objPolicy = new Policy__c();
        objPolicy.Name = 'test3';
        objPolicy.Effective_Date__c = System.today();
        objPolicy.Account__c = objAccount.Id;
        objPolicy.Base_Amount__c = 100;
        objPolicy.Firm_Mod__c = 120;
        objPolicy.Limit__c = FactorCoverage.Id;
        objPolicy.Deductible_ID__c = DedFac.id;
        objPolicy.Expiration_Date__c = date.today().addMonths(2);
        insert objPolicy; 
        
        Policy_Endorsement__c objEndo = new Policy_Endorsement__c();
        objEndo.Name = 'test1';
        //objEndo.Account__c = objAccount.Id;
        objEndo.Policy__c = objPolicy.Id;
        
        
        objEndo.Effective_Date__c = system.today();
        objEndo.Prior_Act_Date__c = system.today().addDays(2);
        objEndo.Endorsement_Effective_Date__c = system.today();
        
        insert objEndo;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objEndo);
        EndoresementFieldSetInformation_Ctrl objEndorsment = new EndoresementFieldSetInformation_Ctrl(sc);
        
        //objEndorsment.getLayouts();
        objEndorsment.endorsementName='IL 107C Unlimited Death or Disability Extended Reporting Period Election';
        objEndorsment.getFields();
        
        Test.stopTest();
        
    }
    @isTest static void testMethod4(){
        
        Test.startTest();
        
        Account objAccount = new Account();
        objAccount.Name='test';
        insert objAccount;
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 107D Unlimited Retirement Extended Reporting Period Election Endorsement').getRecordTypeId();
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','IL 107D Unlimited Retirement Extended Reporting Period Election Endorsement');
        insert endorse;
        
        system.debug('==========endorse======'+endorse);
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor','Deductible');
        insert mas12;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        DedFac.Factor_Value__c =10;
        Insert DedFac; 
        
        Map<String,String> mapRecordTypes = new Map<String,String>();
        
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        // Insert Master Factor coverage        
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        // Insert ILF Coverage factor        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoverageFactor(MasterFactorCoverage.Id);
        insert FactorCoverage;
        
        Policy__c objPolicy = new Policy__c();
        objPolicy.Name = 'test3';
        objPolicy.Effective_Date__c = System.today();
        objPolicy.Account__c = objAccount.Id;
        objPolicy.Base_Amount__c = 100;
        objPolicy.Firm_Mod__c = 120;
        objPolicy.Limit__c = FactorCoverage.Id;
        objPolicy.Deductible_ID__c = DedFac.id;
        objPolicy.Expiration_Date__c = date.today().addMonths(2);
        insert objPolicy; 
        
        Policy_Endorsement__c objPolEndorse = new Policy_Endorsement__c();
        objPolEndorse.Name = 'test';
        objPolEndorse.Account__c = objAccount.id;
        objPolEndorse.Policy__c = objPolicy.id;
        objPolEndorse.Effective_Date__c = system.today();
        objPolEndorse.Prior_Act_Date__c = system.today().addDays(2);
        objPolEndorse.RecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 107D Unlimited Retirement Extended Reporting Period Election Endorsement').getRecordTypeId();
        objPolEndorse.Endorsement_Effective_Date__c = date.today();    
        insert objPolEndorse;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objPolEndorse);
        EndoresementFieldSetInformation_Ctrl objEndorsment = new EndoresementFieldSetInformation_Ctrl(sc);
        
        objEndorsment.getLayouts();
        objEndorsment.getFields();
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod5(){
        
        Test.startTest();
        
        Account objAccount = new Account();
        objAccount.Name='test';
        insert objAccount;
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 151 Name Change Endorsement').getRecordTypeId();
      
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','IL 151 Name Change Endorsement');
        insert endorse;
        
        system.debug('==========endorse======'+endorse);
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor','Deductible');
        insert mas12;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        DedFac.Factor_Value__c =10;
        Insert DedFac; 
        
        Map<String,String> mapRecordTypes = new Map<String,String>();
        
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        // Insert Master Factor coverage        
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        // Insert ILF Coverage factor        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoverageFactor(MasterFactorCoverage.Id);
        insert FactorCoverage;
        
        Policy__c objPolicy = new Policy__c();
        objPolicy.Name = 'test3';
        objPolicy.Effective_Date__c = System.today();
        objPolicy.Account__c = objAccount.Id;
        objPolicy.Base_Amount__c = 100;
        objPolicy.Firm_Mod__c = 120;
        objPolicy.Limit__c = FactorCoverage.Id;
        objPolicy.Deductible_ID__c = DedFac.id;
        objPolicy.Expiration_Date__c = date.today().addMonths(2);
        insert objPolicy; 
        
        Policy_Endorsement__c objPolEndorse = new Policy_Endorsement__c();
        objPolEndorse.Name = 'test';
        objPolEndorse.Account__c = objAccount.id;
        objPolEndorse.Policy__c = objPolicy.id;
        objPolEndorse.Effective_Date__c = system.today();
        objPolEndorse.Prior_Act_Date__c = system.today().addDays(2);
        objPolEndorse.RecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 151 Name Change Endorsement').getRecordTypeId();
        objPolEndorse.Endorsement_Effective_Date__c = date.today();    
        insert objPolEndorse;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objPolEndorse);
        EndoresementFieldSetInformation_Ctrl objEndorsment = new EndoresementFieldSetInformation_Ctrl(sc);
        
        objEndorsment.getLayouts();
        objEndorsment.getFields();
        
        Test.stopTest();
    }
    @isTest static void testMethod6(){
        
        Test.startTest();
        
        Account objAccount = new Account();
        objAccount.Name='test';
        insert objAccount;
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 151 Name Change Endorsement').getRecordTypeId();
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','IL 151 Name Change Endorsement');
        insert endorse;
        
        system.debug('==========endorse======'+endorse);
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor','Deductible');
        insert mas12;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        DedFac.Factor_Value__c =10;
        Insert DedFac; 
        
        Map<String,String> mapRecordTypes = new Map<String,String>();
        
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        // Insert Master Factor coverage        
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        // Insert ILF Coverage factor        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoverageFactor(MasterFactorCoverage.Id);
        insert FactorCoverage;
        
        Policy__c objPolicy = new Policy__c();
        objPolicy.Name = 'test3';
        objPolicy.Effective_Date__c = System.today();
        objPolicy.Account__c = objAccount.Id;
        objPolicy.Base_Amount__c = 100;
        objPolicy.Firm_Mod__c = 120;
        objPolicy.Limit__c = FactorCoverage.Id;
        objPolicy.Deductible_ID__c = DedFac.id;
        objPolicy.Expiration_Date__c = date.today().addMonths(2);
        insert objPolicy; 
        
        Policy_Endorsement__c objPolEndorse = new Policy_Endorsement__c();
        objPolEndorse.Name = 'test';
        objPolEndorse.Account__c = objAccount.id;
        objPolEndorse.Policy__c = objPolicy.id;
        objPolEndorse.Effective_Date__c = system.today();
        objPolEndorse.Prior_Act_Date__c = system.today().addDays(2);
        objPolEndorse.RecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('IL 151 Name Change Endorsement').getRecordTypeId();
        objPolEndorse.Endorsement_Effective_Date__c = date.today();    
        insert objPolEndorse;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(objPolEndorse);
        EndoresementFieldSetInformation_Ctrl objEndorsment = new EndoresementFieldSetInformation_Ctrl(sc);
        
        objEndorsment.getLayouts();
        objEndorsment.getFields();
        
        //objEndorsment.getLayouts();
        objEndorsment.endorsementName='IL 151A Address Change Endorsement';
        
        objEndorsment.getFields();
        
        objEndorsment.endorsementName='IL 190 Cancellation of Coverage';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 191 Reinstatement Notice';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 101A SPECIFIC ATTORNEY(S) EXCLUSION ENDORSEMENT';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 101B SPECIFIC ATTORNEY(S) EXCLUSION ENDORSEMENT';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 104 SPECIFIC ENTITY EXCLUSIONS ENDORSEMENT';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 106 AMENDMENT OF EXTENDED REPORTING PERIOD';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 110 SECURITIES, BOND AND LIMITED PARTNERSHIP EXCLUSION';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 130 LIMIT OF LIABILITY ENDORSEMENT';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 150 POLICY ENDORSEMENT';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 160 CONTRACTUAL LIABILITY EXCLUSION ENDORSEMENT';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 169 SECURITIES EXCLUSION ENDORSEMENT';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 174A CLAIM AND DISCIPLINARY PROCEEDINGS EXCLUSION ENDORSEMENT';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 175 PREDECESSOR FIRM ENDORSEMENT';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 176A ENTITY ENDORSEMENT';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 177 DISCIPLINARY PROCEEDINGS COVERAGE ENDORSEMENT';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 200 PAST ACTS COVERAGE BUYBACK ENDORSEMENT';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 177 DISCIPLINARY PROCEEDINGS COVERAGE ENDORSEMENT';
        objEndorsment.getFields();
        
        objEndorsment.endorsementName='IL 210 SEPARATELY OWNED TITLE AGENCY';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 230 ANNUAL AGGREGATE DEDUCTIBLE ENDORSEMENT';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 232 ANNUAL AGGREGATE DEDUCTIBLE';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 234 LOSS ONLY DEDUCTIBLE ENDORSEMENT';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 260 Past Acts Coverage Endorsement';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 301 Amendment of EXTENDED REPORTING PERIOD Options Endorsement';
        objEndorsment.getFields();
        objEndorsment.endorsementName='IL 261 Claim Expenses Outside the Policy Limits Endorsement';
        objEndorsment.getFields();
        
        Test.stopTest();
    }
}