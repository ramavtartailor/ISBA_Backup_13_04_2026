@isTest 
public class TransactionComponentHandlerTest {
    
    @testSetUp
    static void testData(){
        
        Account acc                   = TestDataFactory.createAccounts('Bucket Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        con.FirstName                 = 'Test';
        con.Type__c                   = 'Lawyer';
        con.Contact_Role__c           = 'P';
        con.AccountId                 = acc.Id;
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
        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoverageFactor(MasterFactorCoverage.Id);
        FactorCoverage.Percentage_5X5_Step_0__c =3;
        FactorCoverage.Percentage_5X5_Step_1__c=4;
        FactorCoverage.Percentage_5X5_Step_2__c=5;
        FactorCoverage.Percentage_5X5_Step_3__c=6;
        FactorCoverage.Percentage_5X5_Step_4__c=8;
        FactorCoverage.Premium_Rate_5X5__c = 33;
        FactorCoverage.Is_5X5_Coverage__c = true;
        insert FactorCoverage;
        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor','Deductible');
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
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Endorsement_Version__c endorseVersion2 = TestDataFactory.createEndorsementVersion(endorse.Id);
        endorseVersion2.Endorsement_Version_Number__c='2';
        insert endorseVersion2;
        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        insert poicyEndorse;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Claim_Setting__c claimSet = TestDataFactory.createClaimSetting();
        insert claimSet;
        
        Policy_Lawyer__c polLawyerObj = TestDataFactory.createPolicyLawyer(acc.Id,acctivePolicy.Id,acj.Id);
        insert polLawyerObj;
        
        Policy_Claim__c  polClaimObj = TestDataFactory.createPolicyClaim(acctivePolicy.Id,polLawyerObj.Id);
        insert polClaimObj;
        polClaimObj.Reserve_LAE__c = null;
        //   update polClaimObj;
        // AcctSeed__Transaction__c
        /* AcctSeed__Transaction__c acct = new AcctSeed__Transaction__c();
acct.AcctSeed__Date__c = system.today();
acct.AcctSeed__Amount__c = 1000;
acct.Claim__c = polClaimObj.id;
acct.AcctSeed__GL_Account__c = glAccounts[0].id;
insert acct; */
        
        
        List<Policy_Claim_Detail__c> PCDList =  new List<Policy_Claim_Detail__c>();
        
        Policy_Claim_Detail__c polClaimDetailObj = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Claim Payment', polClaimObj.Id,'Loss Payment'); 
        PCDList.add(polClaimDetailObj);
        
        Policy_Claim_Detail__c polClaimDetailObj1 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Claim Payment', polClaimObj.Id,'LAE Payment');
        PCDList.add(polClaimDetailObj1);
        
        Policy_Claim_Detail__c polClaimDetailObj2 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Deductible', polClaimObj.Id,'Deductible Loss');
        PCDList.add(polClaimDetailObj2);
        
        Policy_Claim_Detail__c polClaimDetailObj2_1 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Deductible', polClaimObj.Id,'Deductible Expense');
        PCDList.add(polClaimDetailObj2_1);
        
        Policy_Claim_Detail__c polClaimDetailObj3 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Deductible', polClaimObj.Id,'Deductible Expense New');
        PCDList.add(polClaimDetailObj3);
        
        Policy_Claim_Detail__c polClaimDetailObj4 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Reinsurance', polClaimObj.Id,'Change in Ceded LAE Reserve');
        PCDList.add(polClaimDetailObj4);
        
        Policy_Claim_Detail__c polClaimDetailObj5 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Reinsurance', polClaimObj.Id,'Change in Ceded Loss Reserve');
        PCDList.add(polClaimDetailObj5);
        
        Policy_Claim_Detail__c polClaimDetailObj6 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Reinsurance', polClaimObj.Id,'Due from Reins. - LAE');
        PCDList.add(polClaimDetailObj6);
        
        Policy_Claim_Detail__c polClaimDetailObj7 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Reinsurance', polClaimObj.Id,'Due from Reins. - Loss');
        PCDList.add(polClaimDetailObj7);
        
        Policy_Claim_Detail__c polClaimDetailObj8 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Unallocated LAE', polClaimObj.Id,'Unallocated LAE Payment');
        PCDList.add(polClaimDetailObj8);
        
        Policy_Claim_Detail__c polClaimDetailObj9 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Reserve', polClaimObj.Id,'User Reserve');
        PCDList.add(polClaimDetailObj9);
        
        Policy_Claim_Detail__c polClaimDetailObj10 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Reserve', polClaimObj.Id,'Reopen Reserve');
        PCDList.add(polClaimDetailObj10);
        
        Policy_Claim_Detail__c polClaimDetailObj11 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Reserve', polClaimObj.Id,'Close Reserve');
        PCDList.add(polClaimDetailObj11);        
        
        insert PCDList;
        
        AcctSeed__Accounting_Period__c app = TestDataFactory.createAcctPeriod();
        insert app;
        // —— DATA PREPARATION ——
        // insert 1 Account
        Account acct = new Account(
            Name = 'Test Account');
        insert acct;
        
        // insert 4 billing formats
        AcctSeed__Billing_Format__c[] PDFformats = new List<AcctSeed__Billing_Format__c>();
        PDFformats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Billing Product',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Billing',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );
        
        PDFformats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Billing Service',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Billing',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );
        
        PDFformats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Billing Outstanding Statement',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Outstanding Statement'
            )
        );
        
        PDFformats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Billing Activity Statement',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Activity Statement'
            )
        );
        
        PDFformats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Purchase Order',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Purchase Order',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );
        
        PDFformats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Packing Slip',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Packing Slip',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );
        
        insert PDFformats;
        
        // insert 2 cash flow GL Accounts
        AcctSeed__GL_Account__c [] glAccounts1 = new List<AcctSeed__GL_Account__c>();
        //#0
        glAccounts1.add(
            new AcctSeed__GL_Account__c(
                Name = '1000-Cash',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = true,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash'
            )
        );
        
        //#1
        glAccounts1.add(
            new AcctSeed__GL_Account__c(
                Name = '1205-Unapplied A/R',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash'
                
            )
        );
        
        insert glAccounts1;
        
        
        
        // insert 1 Accounting Period
        AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
            Name = '1991-10',
            AcctSeed__Start_Date__c = Date.newinstance(1991, 10, 1),
            AcctSeed__End_Date__c = Date.newinstance(1991, 10, 31),
            AcctSeed__Status__c = 'Open');
        insert acctPeriod;
        /*
        // --- START HERE ---
        // Create BILLING RECORDS to post and unpost
        AcctSeed__Billing__c[] billings = new List <AcctSeed__Billing__c> ();
        
        billings.add(
            new AcctSeed__Billing__c(
                AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
                AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
                AcctSeed__Date__c = System.today(),
                AcctSeed__Customer__c = [Select Id From Account limit 1].Id,
                claim__c = polClaimObj.id,
                AcctSeed__Status__c = 'Approved',
                AcctSeed__Due_Date2__c = System.today() + 30,
                AcctSeed__Ledger__c = ledgers[0].Id,
                AcctSeed__Billing_Format__c = PDFformats[0].Id,
                AcctSeed__Accounting_Period__c = [Select Id From AcctSeed__Accounting_Period__c limit 1].Id
            )
        );
        
        
        insert billings;
        
        System.assertEquals(1, [Select count() FROM AcctSeed__Billing__c WHERE Id = :billings[0].Id]);
        
        
        // Create billing line records to post and unpost
        AcctSeed__Billing_Line__c[] bLines = new List <AcctSeed__Billing_Line__c> ();
        
        for (AcctSeed__Billing__c bill : billings) {
            AcctSeed__Billing_Line__c objBillingLine = new AcctSeed__Billing_Line__c();
            objBillingLine.AcctSeed__Billing__c = bill.id;
            objBillingLine.AcctSeed__Date__c = System.today();
            objBillingLine.AcctSeed__Rate__c = 25;
            objBillingLine.AcctSeed__Hours_Units__c = 1;
            objBillingLine.AcctSeed__Revenue_GL_Account__c = glAccounts1[1].id;
            bLines.add(objBillingLine);
            
            objBillingLine = new AcctSeed__Billing_Line__c();
            objBillingLine.AcctSeed__Billing__c = bill.id;
            objBillingLine.AcctSeed__Date__c = System.today();
            objBillingLine.AcctSeed__Rate__c = 25;
            objBillingLine.AcctSeed__Hours_Units__c = 2;
            objBillingLine.AcctSeed__Revenue_GL_Account__c = glAccounts1[1].id;
            bLines.add(objBillingLine);
        }
        
        insert bLines;
        System.assertEquals(1, [Select count() FROM AcctSeed__Billing_Line__c WHERE Id = :bLines[0].Id LIMIT 1]);
        // Call the post billings service
        AcctSeed.PostResult[] postResults = AcctSeed.BillingPostService.postBillings(billings);
        
        // Loop through post results
        for (AcctSeed.PostResult theResult : postResults) {
            if (theResult.isSuccess) {
                System.debug('Successfully posted billing: ' + theResult.id);
            } 
            else {
                System.debug('Error posting billing ' + theResult.id);
                for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                    System.debug('Error status code ' + errorResult.statusCode);
                    System.debug('Error message ' + errorResult.message);
                }
            }
        }*/
   
    
     
         }
    
    @isTest
    static void getTransactions_Test(){
        Test.startTest();
        Policy_Claim__c objpolicy = [select id from Policy_Claim__c];
        AcctSeed__Accounting_Period__c objapp = [select id from AcctSeed__Accounting_Period__c Limit 1];
        
        List<AcctSeed__Billing__c> billings = new List <AcctSeed__Billing__c> ();
        billings.add(
            new AcctSeed__Billing__c(
                AcctSeed__Customer__c = [Select Id From Account Limit 1].Id,
                Claim__c = objpolicy.id,
                AcctSeed__Accounting_Period__c = objapp.id
            )
        );
        
        
        
        insert billings;
        
        // Create billing line records to post and unpost:
        List <AcctSeed__Billing_Line__c> bLines = new List <AcctSeed__Billing_Line__c> ();
        
        for (AcctSeed__Billing__c bill : billings) {
            AcctSeed__Billing_Line__c objBillingLine = new AcctSeed__Billing_Line__c();
            objBillingLine.AcctSeed__Billing__c = bill.id;
            objBillingLine.AcctSeed__Rate__c = 25;
            objBillingLine.AcctSeed__Hours_Units__c = 1;
            bLines.add(objBillingLine);
            
        }
        
        insert bLines;
        
        // Call the post billings service
        AcctSeed.PostResult[] postResults = AcctSeed.BillingPostService.postBillings(billings);
        
        // Loop through post results
        for (AcctSeed.PostResult theResult : postResults) {
            if (theResult.isSuccess) {
                System.debug('Successfully posted billing: ' + theResult.id);
            } 
            else {
                System.debug('Error posting billing ' + theResult.id);
                for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                    System.debug('Error status code ' + errorResult.statusCode);
                    System.debug('Error message ' + errorResult.message);
                }
            }
        }
        
        List<Policy_Claim__c> claimList = [SELECT ID FROM Policy_Claim__c];
        TransactionComponentHandler.getTransactions(String.valueof(claimList[0].id),True);
        Test.stopTest();
        
    }
    
    @isTest
    static void getTransactions_Test2(){
        Test.startTest();
        Policy_Claim__c objpolicy = [select id from Policy_Claim__c];
        AcctSeed__Accounting_Period__c objapp = [select id from AcctSeed__Accounting_Period__c limit 1];
        
        AcctSeed__Account_Payable__c[] payables = new List <AcctSeed__Account_Payable__c> ();
        payables.add(
            new AcctSeed__Account_Payable__c(
                AcctSeed__Vendor__c = [Select Id From Account limit 1].Id,
                AcctSeed__Payee_Reference__c = 'ThisIsATestPayeeReference123',
                AcctSeed__Accounting_Period__c = objapp.id,
                Claim__c = objpolicy.id
            )
        );
        
        
        
        insert payables;
        
        // Create account payable line records to post and unpost
        AcctSeed__Account_Payable_Line__c[] apLines = new List <AcctSeed__Account_Payable_Line__c> ();
        AcctSeed__GL_Account__c glAccount = [Select Id From AcctSeed__GL_Account__c Where AcctSeed__Type__c = 'Expense' limit 1];
        
        for (AcctSeed__Account_Payable__c ap : payables) {
            AcctSeed__Account_Payable_Line__c apLine = new AcctSeed__Account_Payable_Line__c();
            apLine.AcctSeed__Account_Payable__c = ap.Id;
            apLine.AcctSeed__Amount__c = 45;
            apLine.AcctSeed__Expense_GL_Account__c = glAccount.Id;
            apLines.add(apLine);
        }
        
        insert apLines;
        
        // Call the post service
        AcctSeed.PostResult[] postResults = AcctSeed.AccountPayablePostService.postAccountPayables(payables);
        
        // Loop through post results
        for (AcctSeed.PostResult theResult : postResults) {
            if (theResult.isSuccess) {
                System.debug('Successfully posted account payable: ' + theResult.id);
            } 
            else {
                System.debug('Error posting account payable ' + theResult.id);
                for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                    System.debug('Error status code ' + errorResult.statusCode);
                    System.debug('Error message ' + errorResult.message);
                }
            }
        }
        
        
        
        List<Policy_Claim__c> claimList = [SELECT ID FROM Policy_Claim__c];
        TransactionComponentHandler.getTransactions(String.valueof(claimList[0].id),True);
        Test.stopTest();
    }    
    
}