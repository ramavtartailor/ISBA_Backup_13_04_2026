@isTest
public class ForteUtilTest {
    
    @testSetup static void setUp() {
        
        // Insert Account
        Account acc = TestDataFactory.createAccounts('Test1');
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
        cr.AcctSeed__Credit_GL_Account__c = glAccounts[9].Id;
        insert cr;
        
        // Insert Payable
        AcctSeed__Account_Payable__c payable = TestDataFactory.createAccountPayable(accountingPeriod.id,ledgers[0].id,acc.id,policyClaim.id);
        insert payable;
        
        // Insert PaybaleLine
        AcctSeed__Account_Payable_Line__c  payableLine = TestDataFactory.createAccountPayableLine(payable.id,glAccounts[10].id);
        Insert payableLine;
    }
    
    
    @isTest static void testMethod1() {
        PaymentGateway_Ctrl.PaymentGateway_Ctrl_Wrapper wrapObj = new PaymentGateway_Ctrl.PaymentGateway_Ctrl_Wrapper();
        wrapObj.policyInvoiceNumber = 'Test';
        wrapObj.firmId = 'test';
        wrapObj.invoiceId = 'Test';
        wrapObj.firmName  = 'Test';
        wrapObj.zipCode = 'Test';
        wrapObj.paymentScheduleVar = 'Test';
        wrapObj.paymentTypeVar  = 'check';
        wrapObj.cardTypeVar = 'Test';
        wrapObj.firstName = 'Test';
        wrapObj.lastName = 'Test';
        wrapObj.cardNumber = 'Test';
        wrapObj.verificationNumber = 'Test';
        wrapObj.expireMonth = 'Test';
        wrapObj.expireYear = 'Test';
        wrapObj.nameOnCard = 'Test';
        wrapObj.accountNumber = 'Test';
        wrapObj.routingNumber = 'Test';
        wrapObj.accountType = 'Test';
        wrapObj.accountHolderName = 'Test';
        wrapObj.confirmationEmail = 'Test';
        wrapObj.billingStreet = 'Test';
        wrapObj.billingCity = 'Test';
        wrapObj.billingState = 'Test';
        wrapObj.billingPostal = 'Test';
        wrapObj.effectiveDate = System.today();
        wrapObj.balanceDue = 5555 ;
        wrapObj.description = 'Test1243' ;
        wrapObj.nextPaymentDate = 'Test';
        
        Test.startTest();
        ForteUtil forteUtilObj = new ForteUtil();
        ForteUtil.createTransaction(13243546,'12234434',wrapObj);
        ForteUtil.createForceTransaction(13243546,'12234434',wrapObj);
        ForteUtil.authorizeTransaction(13243546,'12234434',wrapObj);
        ForteUtil.getTransaction('12234434');
        ForteUtil.getAllTransactions(null);
        
        
    }
}