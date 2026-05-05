@isTest
private class CM_TransactionTriggerHelper_Test {
    
    @testSetup static void setup() {
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Account acc1                   = TestDataFactory.createAccounts('Test Account');
        acc1.AccountNumber             = '123456';
        acc1.Vendor_Account__c         = true;
        insert acc1;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        con.Email = 'sanyam@cmentor.com';
        insert con;
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        List<AcctSeed__GL_Account__c> glAccounts = TestDataFactory.createGLAccounts();        
        insert glAccounts;
        
        List<AcctSeed__Billing_Format__c> billingFormats = TestDataFactory.createBillingFormats();        
        insert billingFormats ;
        
        AcctSeed__Accounting_Period__c lstPeriod = TestDataFactory.createAcctPeriod();
        insert lstPeriod;
        
        List<AcctSeed__Ledger__c> ledgers = TestDataFactory.createLedgers(glAccounts[0].id,billingFormats[0].id,billingFormats[1].id,billingFormats[2].id,billingFormats[3].id,billingFormats[4].id);
        insert ledgers;
        
        AcctSeed__Accounting_Settings__c settings = TestDataFactory.createAccountsetting(ledgers[0].id,glAccounts[0].Id,glAccounts[1].Id,glAccounts[2].Id,glAccounts[3].Id,glAccounts[4].Id,glAccounts[5].Id,glAccounts[6].Id,billingFormats[0].Id);        
        insert settings;
        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        opp.StageName                 = 'Application Sent';
        opp.CloseDate                 = Date.today();
        insert opp;
        
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Geo');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.id,county.Id);
        insert geo;
        
        Master_Factor__c masterFactor = TestDataFactory.createMasterfactor('Test Master Factor0','Step Rate');
        insert masterFactor;
        
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(masterFactor.Id);
        insert stepRateFactor;
        
        Master_Factor__c masterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert masterFactor1;
        
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(masterFactor1.Id);
        insert baseFactor;
        
        Test.startTest();
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorNew.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Treaty_Versions__c objTV=new Treaty_Versions__c ();
        objTV.Ceded_4x1_Rate__c=6.75;
        objTV.Ceded_Primary_Rate__c=8.25;
        objTV.End_Date__c=System.Date.today();
        objTV.Start_Date__c =System.Date.today().addMonths(4);
        objTV.Reinsurance_Limit__c=500000;
        insert objTV;
        
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy.Effective_Date__c = system.today();
        acctivePolicy.Expiration_Date__c = System.today().addMonths(1);
        acctivePolicy.Treaty_Version__c=objTV.Id;
        insert acctivePolicy;
        
        /*
Policy__c pol1                 = TestDataFactory.createPolicy(acc1.Id,opp.id,geo.id,'Application');
pol1.Status__c                 = 'Application created';
pol1.SCH_Mod__c                = 1.00;
insert pol1;
*/
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('','','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        insert objPolEndorse;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,acctivePolicy.id);
        insert aop;
        
        AcctSeed__Billing__c objBilling = TestDataFactory.createBilling(acc.Id, lstPeriod.Id, ledgers[0].id);
        insert objBilling;
        
        // AcctSeed__Scheduled_Revenue_Expense__c objSRE = TestDataFactory.createSchdRevExpence(lstPeriod.Id, glAccounts[2].Id, objBilling.Id);
        //insert objSRE;
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod1() {
        
        
        List<Transaction_Credit_And_Debits__c> transSettingList = new List<Transaction_Credit_And_Debits__c>();
        Transaction_Credit_And_Debits__c transCandD =  new Transaction_Credit_And_Debits__c();
        transCandD.Name = 'Billing Line';
        transCandD.Credit_GL__c = '1500-Prepaid Expenses';
        transCandD.Debit_GL__c = '6023-Ceded Commission';
        transSettingList.add(transCandD); 
        
        Transaction_Credit_And_Debits__c transCandD1 =  new Transaction_Credit_And_Debits__c();
        transCandD1.Name = 'Billing Schedule';
        transCandD1.Credit_GL__c = '1500-Prepaid Expenses';
        transCandD1.Debit_GL__c = '6023-Ceded Commission';
        transSettingList.add(transCandD1); 
        
        Transaction_Credit_And_Debits__c transCandD2 =  new Transaction_Credit_And_Debits__c();
        transCandD2.Name = 'Open Reserve Loss';
        transCandD2.Credit_GL__c = '1500-Prepaid Expenses';
        transCandD2.Debit_GL__c = '6023-Ceded Commission';
        transSettingList.add(transCandD2);
        
        Transaction_Credit_And_Debits__c transCandD3 =  new Transaction_Credit_And_Debits__c();
        transCandD3.Name = 'Open Reserve LAE';
        transCandD3.Credit_GL__c = '1500-Prepaid Expenses';
        transCandD3.Debit_GL__c = '6023-Ceded Commission';
        transSettingList.add(transCandD3);
        
        Transaction_Credit_And_Debits__c transCandD4 =  new Transaction_Credit_And_Debits__c();
        transCandD4.Name = 'Close Reserve LAE';
        transCandD4.Credit_GL__c = '1500-Prepaid Expenses';
        transCandD4.Debit_GL__c = '6023-Ceded Commission';
        transSettingList.add(transCandD4);
        
        Transaction_Credit_And_Debits__c transCandD5 =  new Transaction_Credit_And_Debits__c();
        transCandD5.Name = 'Close Reserve Loss';
        transCandD5.Credit_GL__c = '1500-Prepaid Expenses';
        transCandD5.Debit_GL__c = '6023-Ceded Commission';
        transSettingList.add(transCandD5);
        
        Transaction_Credit_And_Debits__c transCandD6 =  new Transaction_Credit_And_Debits__c();
        transCandD6.Name = 'Ceded Reserve LAE';
        transCandD6.Credit_GL__c = '1500-Prepaid Expenses';
        transCandD6.Debit_GL__c = '6023-Ceded Commission';
        transSettingList.add(transCandD6);
        
         Transaction_Credit_And_Debits__c transCandD7 =  new Transaction_Credit_And_Debits__c();
        transCandD7.Name = 'Change in Ceded Loss Reserve';
        transCandD7.Credit_GL__c = '1500-Prepaid Expenses';
        transCandD7.Debit_GL__c = '6023-Ceded Commission';
        transSettingList.add(transCandD7);
        
        Transaction_Credit_And_Debits__c transCandD8 =  new Transaction_Credit_And_Debits__c();
        transCandD8.Name = 'Ceded Reserve Loss';
        transCandD8.Credit_GL__c = '1500-Prepaid Expenses';
        transCandD8.Debit_GL__c = '6023-Ceded Commission';
        transSettingList.add(transCandD8);
        
        Transaction_Credit_And_Debits__c transCandD9 =  new Transaction_Credit_And_Debits__c();
        transCandD9.Name = 'Delete Lawyer';
        transCandD9.Credit_GL__c = '1500-Prepaid Expenses';
        transCandD9.Debit_GL__c = '6023-Ceded Commission';
        transSettingList.add(transCandD9);
        
        Transaction_Credit_And_Debits__c transCandD10 =  new Transaction_Credit_And_Debits__c();
        transCandD10.Name = 'Ceded Primary';
        transCandD10.Credit_GL__c = '1500-Prepaid Expenses';
        transCandD10.Debit_GL__c = '6023-Ceded Commission';
        transSettingList.add(transCandD10);
        
        Transaction_Credit_And_Debits__c transCandD11 =  new Transaction_Credit_And_Debits__c();
        transCandD11.Name = 'Ceded Primary Amortize';
        transCandD11.Credit_GL__c = '1500-Prepaid Expenses';
        transCandD11.Debit_GL__c = '6023-Ceded Commission';
        transSettingList.add(transCandD11);
        
        Transaction_Credit_And_Debits__c transCandD12 =  new Transaction_Credit_And_Debits__c();
        transCandD12.Name = 'Ceded 4x1';
        transCandD12.Credit_GL__c = '1500-Prepaid Expenses';
        transCandD12.Debit_GL__c = '6023-Ceded Commission';
        transSettingList.add(transCandD12);
        
        Transaction_Credit_And_Debits__c transCandD13 =  new Transaction_Credit_And_Debits__c();
        transCandD13.Name = 'Ceded 4x1 Amortize';
        transCandD13.Credit_GL__c = '1500-Prepaid Expenses';
        transCandD13.Debit_GL__c = '6023-Ceded Commission';
        transSettingList.add(transCandD13);
        
         
        insert transSettingList;
        
        
        List<Account> acc = [SELECT Id FROM Account];
        
        List<Contact> conList = [SELECT Id FROM Contact];
        List<Policy__c> policies = [SELECT Id,Account__c,Account__r.Name, Effective_Date__c, Expiration_Date__c FROM Policy__c];
        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id,NAME FROM AcctSeed__GL_Account__c where name = '4000-Product Revenue'];
        List<AcctSeed__Ledger__c> ledgers = [SELECT Id FROM AcctSeed__Ledger__c];
        List<AcctSeed__Accounting_Period__c> period = [SELECT Id,NAME FROM AcctSeed__Accounting_Period__c];
        List<AcctSeed__Billing__c> lstBill = [SELECT Id FROM AcctSeed__Billing__c];
        
        Policy__c  policy = policies[0];
        
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(policies[0].Account__C, conList[0].Id);
        insert junc;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(policies[0].Account__c,policies[0].Id,junc.Id);
        insert law; 
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        insert calimset;
        
        Policy_Claim__c claim = TestDataFactory.createPolicyClaim(policies[0].Id,law.Id);
        insert claim;
        
        Test.startTest();
        
        List<Policy_Claim_Detail__c> calimList = new List<Policy_Claim_Detail__c>();
        
        Policy_Claim_Detail__c claimDetail = TestDataFactory.createPolClaimDetail(policy.Account__c,'Claim Payment',claim.Id,'Loss Payment');
        insert claimDetail;
        
        List<Policy_Endorsement__c> policyEndoslist = [SELECT Id FROM Policy_Endorsement__c LIMIT 1];
        
        AcctSeed__Billing__c objBilling = TestDataFactory.createBilling(acc[0].Id, period[0].Id, ledgers[0].id);
        insert objBilling;
        
        AcctSeed__Scheduled_Revenue_Expense__c objSRE = TestDataFactory.createSchdRevExpence(period[0].Id, glAccounts[0].Id, lstBill[0].Id);
        insert objSRE;
        
        List<AS_Transaction__c> asTransList = new List<AS_Transaction__c>();
        
        AS_Transaction__c objTrans = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Issue Policy',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Open Reserve Loss');
        objTrans.Credit_Amount__c = 100;
        //objTrans.CreatedDate = system.today();
        asTransList.add(objTrans);
        
        AS_Transaction__c objTrans1 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Issue Policy',-100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Premium');
        objTrans1.Credit_Amount__c = 100;
        asTransList.add(objTrans1);
        
        AS_Transaction__c objTrans121 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Issue Policy',-100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Primary');
        objTrans121.Credit_Amount__c = 100;
        asTransList.add(objTrans121);
        
        AS_Transaction__c objTrans131 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Issue Policy',-100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'PrimaryAndExcess');
        objTrans131.Credit_Amount__c = 100;
        asTransList.add(objTrans131);
        
        
        AS_Transaction__c objTrans2 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Add Lawyer',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Add Lawyer');
        asTransList.add(objTrans2);
        
        AS_Transaction__c objTrans3 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Adjust Premium',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Open Reserve Loss');
        asTransList.add(objTrans3);
        
        AS_Transaction__c objTrans4 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Adjust Premium',-100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Open Reserve Loss');
        asTransList.add(objTrans4);
        
        AS_Transaction__c objTrans5 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Change Lawyer',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Open Reserve Loss');
        asTransList.add(objTrans5);
        
        AS_Transaction__c objTrans6 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Change Lawyer',-100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Open Reserve Loss');
        asTransList.add(objTrans6);
        
        AS_Transaction__c objTrans7 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Delete Lawyer',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Delete Lawyer');
        asTransList.add(objTrans7);
        
        AS_Transaction__c objTrans8 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'ERE',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'ERE');
        asTransList.add(objTrans8);
        
        AS_Transaction__c objTrans9 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Cancel Policy',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Open Reserve Loss');
        asTransList.add(objTrans9);
        
        AS_Transaction__c objTrans10 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Cancel Policy',-100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Open Reserve Loss');
        asTransList.add(objTrans10); 
        
        AS_Transaction__c objTrans11 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Reinstate Policy',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Open Reserve Loss');
        asTransList.add(objTrans11);
        
        AS_Transaction__c objTrans12 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Reinstate Policy',-100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Open Reserve Loss');
        asTransList.add(objTrans12);
        
        AS_Transaction__c objTrans13 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Change Coverage',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Open Reserve Loss');
        asTransList.add(objTrans13);
        
        AS_Transaction__c objTrans14 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Change Coverage',-100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Open Reserve Loss');
        asTransList.add(objTrans14);
        
        AS_Transaction__c objTrans15 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Issue Policy',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Open Reserve Loss');
        asTransList.add(objTrans15);
        
        AS_Transaction__c objTrans16 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Issue Policy',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Open Reserve LAE');
        asTransList.add(objTrans16);
        
        AS_Transaction__c objTrans17 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Close Reserve',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Close Reserve Loss');
        asTransList.add(objTrans17);
        
        AS_Transaction__c objTrans18 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Close Reserve',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Close Reserve LAE');
        asTransList.add(objTrans18);   
        
        AS_Transaction__c objTrans19 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Change in Ceded LAE Reserve',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Open Reserve Loss');
        asTransList.add(objTrans19);
        
        AS_Transaction__c objTrans20 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Change in Ceded Loss Reserve',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Open Reserve Loss');
        asTransList.add(objTrans20);  
        
        AS_Transaction__c objTrans21 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'LAE Payment',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'LAE Payment');
        asTransList.add(objTrans21);
        
        AS_Transaction__c objTrans22 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Loss Payment',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Loss Payment');
        asTransList.add(objTrans22); 
        
        AS_Transaction__c objTrans23 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Deductible Loss',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Open Reserve Loss');
        asTransList.add(objTrans23);
        
        AS_Transaction__c objTrans24 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Deductible Expense',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Open Reserve Loss');
        asTransList.add(objTrans24);
        
        AS_Transaction__c objTrans25 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Reopen Reserve',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Re-Open Reserve LAE');
        asTransList.add(objTrans25);
        
        AS_Transaction__c objTrans26 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Reopen Reserve',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Re-Open Reserve Loss');
        asTransList.add(objTrans26);
        
        AS_Transaction__c objTrans27 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Unallocated LAE Payment',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Re-Open Reserve Loss');
        asTransList.add(objTrans27);
        
        AS_Transaction__c objTrans28 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'User Reserve',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'User Reserve LAE');
        asTransList.add(objTrans28);
        
        AS_Transaction__c objTrans29 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'User Reserve',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'User Reserve Loss');
        asTransList.add(objTrans29);
        
        AS_Transaction__c objTrans30 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Claim Coverage - ARDC',100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'Close Reserve Loss');
        asTransList.add(objTrans30);
        
        AS_Transaction__c objTrans31 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Issue Policy',-100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'5x5');
        asTransList.add(objTrans31);
        
        AS_Transaction__c objTrans32 = TestDataFactory.createTransaction(policyEndoslist[0].Id,'Issue Policy',-100,policy.Id,claim.Id,policy.Account__c,claimDetail.Id,'10x10');
        asTransList.add(objTrans32);
        
        insert asTransList;
        Set<Id> transactionId = new Set<Id>();
        for(AS_Transaction__c t: asTransList){
          t.Credit_Amount__c=50;
          transactionId.add(t.id);
        }
        update asTransList;
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c];
        
        Map<String,AcctSeed__Accounting_Period__c> NameAccPeriodMap = new Map<String,AcctSeed__Accounting_Period__c>();
        
        string acKey = 'key'+date.today().month()+'year'+date.today().year();
        
        NameAccPeriodMap.put(acKey,period[0]);
        
        CM_TransactionTriggerHelper ctrl = new CM_TransactionTriggerHelper();
        
        List<AS_Transaction__c> lstTrans = [SELECT Id,Policy_Id__c,createdDate,Transaction_Type__c,Name,Claim_Id__c,Policy_Claim_Detail__c,
                                            Firm_Id__c, Policy_Endorsement_Id__c,Credit_Amount__c,Amount__c
                                            FROM AS_Transaction__c];
        
        lstTrans[0].Credit_Amount__c=100;
        Update lstTrans;
        system.debug(lstTrans[0].Credit_Amount__c);
        
        
        
        List<Policy__c> dsfas = [SELECT Id,Account__c,Account__r.Name, Effective_Date__c, Expiration_Date__c 
                                 FROM Policy__c WHERE Id =: policy.Id ];
        
        asTransList[0].Policy_Id__c = dsfas[0].Id;
        update asTransList[0];
        
        AS_Transaction__c ASa =[select id,Firm_Id__c,Firm_Id__r.Name,Policy_Id__r.Effective_Date__c,Policy_Id__r.Expiration_Date__c,Credit_Amount__c,Policy_Endorsement_Id__r.Endorsement_Effective_Date__c,
                                Amount__c,createdDate,Transaction_Type__c,Name,Claim_Id__c,Policy_Claim_Detail__c,Policy_Id__c,Policy_Endorsement_Id__c,Policy_Id__r.GL_Processing_Date__c,Policy_Endorsement_Id__r.GL_Processing_Date__c,Policy_Claim_Detail__r.Date__c
                                FROM AS_Transaction__c WHERE Id =: asTransList[0].Id ];
          System.debug('ASa.id====>'+ASa);   
        CM_TransactionTriggerHelper.createRevenueSchedules(ASa, NameAccPeriodMap, string.valueOf(objSRE.AcctSeed__Credit_GL_Account__c),string.valueOf(objSRE.AcctSeed__Debit_GL_Account__c) );
        
        CM_TransactionTriggerHelper.createRevenueSchedulesForComingMonths(ASa, NameAccPeriodMap, string.valueOf(objSRE.AcctSeed__Credit_GL_Account__c),string.valueOf(objSRE.AcctSeed__Debit_GL_Account__c) );
        
        CM_TransactionTriggerHelper.scheduleForFullAmount(ASa, NameAccPeriodMap, string.valueOf(objSRE.AcctSeed__Credit_GL_Account__c),string.valueOf(objSRE.AcctSeed__Debit_GL_Account__c) );
        
        CM_TransactionTriggerHelper.createAccountsPayable(ASa, NameAccPeriodMap);
        
        CM_TransactionTriggerHelper.createAPLineItems(10, ASa, glAccList[0].Id);
        
       CM_TransactionTriggerHelper.journalLineItems(ASa, string.valueOf(objSRE.AcctSeed__Credit_GL_Account__c),string.valueOf(objSRE.AcctSeed__Debit_GL_Account__c),50);
        
        CM_TransactionTriggerHelper.journalLineItem(ASa, 'Debit', string.valueOf(glAccList[0].Id), 50);
        CM_TransactionTriggerHelper.journalLineItem(ASa, 'Credit', string.valueOf(glAccList[0].Id), 50);
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address = 'accounting@isbamutual.com'];
        CM_TransactionTriggerHelper.createEmailMessage(new Set<Id>{lstBill[0].Id}, owea.Id);
        // CM_TransactionTriggerHelper.handleTransactionInsert(JSON.serialize(transactionId));
        
        Test.stopTest();
        
    }
      
   


      
}