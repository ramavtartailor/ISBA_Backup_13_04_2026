@isTest
public class PolicyDeductibleInvoiceHandler_Test {
    
    @testSetup static void setup() {
        
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Account acc1                   = TestDataFactory.createAccounts('Test Account');
        acc1.AccountNumber             = '123456';
        acc1.Vendor_Account__c         = true;
       // insert acc1;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        con.FirstName                 = 'Test';
        con.Type__c                   = 'Lawyer';
        con.Contact_Role__c           = 'P';
        con.AccountId                 = acc.Id;
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
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        // County
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        // Insert GEO
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        // Deductible Factor
        Deductible_Factor__c  deductibleFactor = TestDataFactory.createDeductiblefactor(mas.id);
        deductibleFactor.Deductible_Amount__c = 201;
        insert deductibleFactor;
        
        // Create Policy
        Policy__c policy = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Policy');
        policy.Deductible_ID__c = deductibleFactor.id;
        Insert policy;
         
        // Create Account Contact Junction     
        AccountContactJunction__c accConJunc = TestDataFactory.createAccConJunc(acc.id,con.id);
        insert accConJunc;
        
        // Insert Policy Lawyer
        Policy_Lawyer__c policyLawyer = TestDataFactory.createPolicyLawyer(policy.Account__c,policy.id,accConJunc.id);
        policyLawyer.Active__c = true;
        insert policyLawyer;
        
        // Custom Setting
        Claim_Setting__c  customSetting = TestDataFactory.createClaimSetting();
        insert customSetting;
        
        // Insert Policy Claim
        Policy_Claim__c policyClaim = TestDataFactory.createPolicyClaim(policy.id,policyLawyer.id);
        insert policyClaim;
        
        // Create Billing
        AcctSeed__Billing__c objBilling = TestDataFactory.createBilling(acc.Id,accountingPeriod.Id,ledgers[0].id);
        objBilling.Claim__c = policyClaim.id;
        insert objBilling;
        
        // Create BillingLine
        AcctSeed__Billing_Line__c billLine = TestDataFactory.createBillingLine(objBilling.Id,glAccounts[15].Id);
        insert billLine;
            
    }
    
    @isTest static void testMethod1() {
        
        List<AcctSeed__Billing__c> billList = [Select id,AcctSeed__Date__c,AcctSeed__Billing_Contact__c,AcctSeed__Billing_Street__c,AcctSeed__Billing_City__c,AcctSeed__Billing_State__c,Claim__c,
               AcctSeed__Billing_PostalCode__c,Claim__r.Name,Claim__r.Policy_Deductible__r.Deductible_Amount__c,Claim__r.Aggregate_Limit__c,
               Claim__r.Per_Claim_Limit__c,Claim__r.Claimant__c,Claim__r.File_Type__c,Claim__r.Policy__r.Policy_Number__c,Claim__r.Payment_Direct_Loss__c,Claim__r.Payment_Direct_LAE__c from AcctSeed__Billing__c];
        
        List<Policy__c> PolList =[select id from policy__c];
        
        Test.startTest();        
        ApexPages.StandardController sc = new ApexPages.StandardController(billList[0]);
        PolicyDeductibleInvoiceHandler obj = new PolicyDeductibleInvoiceHandler(sc);
        obj.pcc=PolList[0];
        Test.stopTest();
    } 
    
}