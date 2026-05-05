@isTest
public class TransactionTriggerHandler_Test {
    
    @testSetUp
    static void testData(){
        
        // Insert Account
        Account acc = TestDataFactory.createAccounts('Test');
        insert acc;
        
        // Insert Contact
        Contact con =  TestDataFactory.createContact('Last Name',acc.id);
        insert con;
        
        // Insert GL Accounts
        List<AcctSeed__GL_Account__c> glAccounts = TestDataFactory.createGLAccounts();
        insert glAccounts;
        
        // Accounting Period
        AcctSeed__Accounting_Period__c accountingPeriod =  TestDataFactory.createAcctPeriod();
        insert accountingPeriod;
        
        // Insert Billing Format
        List<AcctSeed__Billing_Format__c> billFormat = TestDataFactory.createBillingFormats();
        insert billFormat;
        
        // Insert Ledgers
        List<AcctSeed__Ledger__c> ledgers = TestDataFactory.createLedgers(glAccounts[0].id,billFormat[0].id,billFormat[1].id,billFormat[2].id,billFormat[3].id,billFormat[4].id);
        insert ledgers;
        
        // Insert AccountingSetting
        AcctSeed__Accounting_Settings__c accSetting = TestDataFactory.createAccountsetting(ledgers[0].id, glAccounts[0].id,glAccounts[1].id, glAccounts[2].id, glAccounts[3].id,glAccounts[4].id, glAccounts[5].id,glAccounts[6].id,billFormat[0].id);
        insert accSetting;
        
        // Insert Opportunity
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        // Insert Master Factor
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        // County
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        // Insert GEO
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        // Create Policy
        Policy__c policy = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Policy');
        Insert policy;
        
        // Insert Journal Entry
        AcctSeed__Journal_Entry__c journalEntry = TestDataFactory.createJournalEntry(accountingPeriod.id ,ledgers[0].id);
        journalEntry.Policy__c = policy.id;
        insert journalEntry;
        
        // Insert JE Line
        List<AcctSeed__Journal_Entry_Line__c> jeLines = TestDataFactory.createJournalEntryLine(journalEntry.id,glAccounts[10].id);
        insert jeLines;
        
        // Insert Billing
        AcctSeed__Billing__c billing = TestDataFactory.createBilling(acc.id,accountingPeriod.id,ledgers[0].id);
        billing.Policy__c = policy.id;
        insert billing;
        
        // Create Account Contact Junction     
        AccountContactJunction__c accConJunc = TestDataFactory.createAccConJunc(acc.id,con.id);
        insert accConJunc;
        
        // Billing Line
        AcctSeed__Billing_Line__c billLIne = TestDataFactory.createBillingLine(billing.id,glAccounts[10].id);
        billLIne.AcctSeed__Rate__c = 100;
        insert billLIne;
        
        // Insert Policy Lawyer
        Policy_Lawyer__c policyLawyer = TestDataFactory.createPolicyLawyer(policy.Account__c,policy.id,accConJunc.id);
        policyLawyer.Active__c = true;
        insert policyLawyer;
        
        // Custom Setting
        Claim_Setting__c  customSetting = TestDataFactory.createClaimSetting();
        insert customSetting;
        
        // Insert Policy Claim
        Policy_Claim__c policyClaim = TestDataFactory.createPolicyClaim(policy.id,policyLawyer.id);
        //policyClaim.RecordTypeId = Schema.SObjectType.Policy_Claim_Detail__C.getRecordTypeInfosByName().get('Reserve').getRecordTypeId();
        insert policyClaim;
        
        AcctSeed__Cash_Receipt__c cr = TestDataFactory.createCashReceipt(ledgers[0].id,acc.id,accountingPeriod.id);
        insert cr;
        
        // Insert Payable
        AcctSeed__Account_Payable__c payable = TestDataFactory.createAccountPayable(accountingPeriod.id,ledgers[0].id,acc.id,policyClaim.id);
        insert payable;
        
        // Insert PaybaleLine
        AcctSeed__Account_Payable_Line__c  payableLine = TestDataFactory.createAccountPayableLine(payable.id,glAccounts[10].id);
        Insert payableLine;
	
    }
    
    @isTest 
    static void populateClaimAndPolicyOnTransaction_Test(){
        Test.startTest();
        // Journal Entry
        List<AcctSeed__Journal_Entry__c> jeList = [SELECT id FROM AcctSeed__Journal_Entry__c limit 1];

        // Call the post journal entry service
        AcctSeed.PostResult[] postResults = AcctSeed.JournalEntryPostService.postJournalEntries(jeList);
                
        // Loop through post results
        for (AcctSeed.PostResult theResult : postResults) {
            if (theResult.isSuccess) {
                System.debug('Successfully posted journal entry: ' + theResult.id);
            } 
            else {
                System.debug('Error posting journal Enrty ' + theResult.id);
                for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                    System.debug('Error status code ' + errorResult.statusCode);
                    System.debug('Error message ' + errorResult.message);
                }
            }
        }
        
        Test.stopTest();
    }
    
    @isTest 
    static void populateClaimAndPolicyOnTransaction_Test1(){
        
        Test.startTest();
        
        // Journal Entry
        List<AcctSeed__Billing__c> billings = [SELECT id FROM AcctSeed__Billing__c limit 1];
        
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
        
        Test.stopTest();
    }
    
    
    @isTest 
    static void populateClaimAndPolicyOnTransaction_Test2(){
        
        Test.startTest();
        
        List<AcctSeed__Accounting_Period__c> accountingPeriod = [select id from AcctSeed__Accounting_Period__c limit 1];
        List<Account> acc = [select id from Account];
        List<AcctSeed__Ledger__c> ledgers = [select id from AcctSeed__Ledger__c ];
        List<Policy_Claim__c> poClaim = [select id from Policy_Claim__c];
        
        AcctSeed__Cash_Receipt__c cr = TestDataFactory.createCashReceipt(ledgers[0].id,acc[0].id,accountingPeriod[0].id);
        cr.Claim__c = poClaim[0].id;
        insert cr;
        
        Test.stopTest();
    }
    
    @isTest 
    static void populateClaimAndPolicyOnTransaction_Test3(){
        
        Test.startTest();
        
        List<AcctSeed__Cash_Disbursement__c> cashDisbursements = [select id from AcctSeed__Cash_Disbursement__c limit 1];
        // Call the post service
        AcctSeed.PostResult[] postResults = AcctSeed.CashDisbursementPostService.postCashDisbursements(cashDisbursements);
        
        // Loop through post results
        for (AcctSeed.PostResult theResult : postResults) {
            if (theResult.isSuccess) {
                System.debug('Successfully posted cash disbursement: ' + theResult.id);
            } 
            else {
                System.debug('Error posting cash disbursement ' + theResult.id);
                for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                    System.debug('Error status code ' + errorResult.statusCode);
                    System.debug('Error message ' + errorResult.message);
                }
            }
        }
        
        Test.stopTest();
    }
    
    @isTest 
    static void populateClaimAndPolicyOnTransaction_Test4(){
        
        Test.startTest();

        List<AcctSeed__Account_Payable__c> payables = [select id from AcctSeed__Account_Payable__c];
        
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
        
        AcctSeed.PostResult[] unpostResults = AcctSeed.AccountPayablePostService.unpostAccountPayables(payables);
        
        // Loop through unpost results
        for (AcctSeed.PostResult theResult : unpostResults) {
            if (theResult.isSuccess) {
                System.debug('Successfully unposted account payable: ' + theResult.id);
            } 
            else {
                System.debug('Error unposting account payable ' + theResult.id);
                for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                    System.debug('Error status code ' + errorResult.statusCode);
                    System.debug('Error message ' + errorResult.message);
                }
            }
}
        
        Test.stopTest();
    }


}