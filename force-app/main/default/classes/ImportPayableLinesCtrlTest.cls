@isTest
public class ImportPayableLinesCtrlTest {
	@testSetup static void setup() {
        
        Test.startTest();
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        system.debug('acc "" ' + acc);
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        List<AcctSeed__GL_Account__c> glAccounts = TestDataFactory.createGLAccounts();

        // 
       glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '6141 - LAE Pay Bill Line',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        
        // 
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '6201 - Loss Pay Bill Line',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
          
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
        acctivePolicy.Aggregate_Limit__c = 5;
        insert acctivePolicy;
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
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
        claim.Deductible_LAE_Applied_Limit__c = 0;
        insert claim;
        
        Policy_Claim_Detail__c polClaimDetail = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c ,'Claim Payment',claim.Id,'LAE Payment');
        polClaimDetail.Date__c = system.today();
        polClaimDetail.ISBA_First_Payment__c = 10;
        polClaimDetail.ISBA_Contribution__c = 20;
        insert polClaimDetail;
        
        Master_Factor__c masterfact = TestDataFactory.createMasterfactor('Coverage','Coverage');
        insert masterfact;
        
        Master_Factor__c masterfact1 = TestDataFactory.createMasterfactor('Deductible 10/1/2016 - 12/31/2016','Deductible');
        insert masterfact1;
        
        Deductible_Factor__c deductible = TestDataFactory.createDeductiblefactor(masterfact1.Id);
        Insert deductible;
        
        List<AcctSeed__Accounting_Period__c> accountingPeriod = new List<AcctSeed__Accounting_Period__c>();
        Date currentDate = System.today();
        
        for(Integer i = 0; i < 36; i++){
            
            AcctSeed__Accounting_Period__c objAccountingPeriod = new AcctSeed__Accounting_Period__c();
            
            objAccountingPeriod.AcctSeed__Start_Date__c = currentDate.addMonths(i);
            objAccountingPeriod.AcctSeed__End_Date__c = objAccountingPeriod.AcctSeed__Start_Date__c.addMonths(1).toStartOfMonth() - 1;
            objAccountingPeriod.Name = objAccountingPeriod.AcctSeed__Start_Date__c.year() + '-' + (string.valueOf(objAccountingPeriod.AcctSeed__Start_Date__c.month()).length() == 1?'0':'') + objAccountingPeriod.AcctSeed__Start_Date__c.month();
            accountingPeriod.add(objAccountingPeriod);
        }
        
        insert accountingPeriod;
        
        List<Transaction_Credit_And_Debits__c> transCandDList = new List<Transaction_Credit_And_Debits__c>();
        
        Transaction_Credit_And_Debits__c transCandD = new Transaction_Credit_And_Debits__c();
        transCandD.Name = 'LAE Pay Bill Line';
        transCandD.Credit_GL__c = 'LAE Pay Bill Line';
        transCandD.Debit_GL__c = 'Loss Pay Bill Line';
        //transCandD.GL_Variable__c='test';// piyush
        transCandDList.add(transCandD); 
        
        Transaction_Credit_And_Debits__c transCandD1 = new Transaction_Credit_And_Debits__c();
        transCandD1.Name = 'Loss Pay Bill Line';
        transCandD1.Credit_GL__c = 'Loss Pay Bill Line';
        transCandD1.Debit_GL__c = 'LAE Pay Bill Line';
        transCandDList.add(transCandD1); 
        
        Test.stopTest();
        insert transCandDList;
        
        AcctSeed__Account_Payable__c  payableObj = TestDataFactory.createAccountPayable(accountingPeriod[0].Id,ledgers[0].Id,acctivePolicy.Account__c ,claim.Id);
        insert payableObj;
    }
    
    @isTest
    public Static void method1(){
        AcctSeed__Account_Payable__c ap = [SELECT Id FROM AcctSeed__Account_Payable__c limit 1];
        ImportPayableLinesCtrl.DataWrapper dw = ImportPayableLinesCtrl.getGLList();
        List<ImportPayableLinesCtrl.csvWrapper> wrapList = ImportPayableLinesCtrl.getCSVObject('dt,"receipt",des,cardMember,accountNum,amount \n 09/26/2024,"","des","cardMember",515554,10');
        wrapList[0].gl = dw.glList[0].Id;
        ImportPayableLinesCtrl.createPayableLines(ap.Id, wrapList);
    }
}