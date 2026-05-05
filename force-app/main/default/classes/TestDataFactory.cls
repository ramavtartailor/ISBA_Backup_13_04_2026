/*
Name   : TestDataFactory
Auther : Jitendra Pratap Singh
Date   : 13 Feb 2019
Description : Data Factory for cover test coverage. It contains methods for each objects which used in test classes.

*/

@isTest
public class TestDataFactory{
    
    // Create CountyNew    
    public static County__c createCountyNew(){
        County__c county1              = new County__c();
        county1.Name                   = 'Test County';
        county1.Region__c              = '5';
        
        return county1;
    }
    
    
    // Creating Account
    public static Account createAccounts(String name) {
        Account acc = new Account(Name=name);
        acc.AccountNumber  = '123456';
        acc.billingstreet = 'testStreet';
        acc.billingstate = 'testStreet';
        acc.billingCity = 'testStreet';
        acc.billingPostalCode = 'testStreet';
        acc.BillingCountry = 'testStreet';
        return acc;
    }
    // Creating AccountNew
    public static Account createAccountsNew(String name, Id countyId) {
        Account acc = new Account(Name=name);
        acc.AccountNumber = '123456';
        acc.billingstreet = 'testStreet';
        acc.billingstate = 'testStreet';
        acc.billingCity = 'testStreet';
        acc.billingPostalCode = 'testStreet';
        acc.BillingCountry = 'testStreet';
        acc.Billing_Address_County__c = countyId;
        return acc;
    }
    
    // Create Contact   
    public static Contact createContact(String LastName,Id accountId) {
        Contact Con = new Contact(firstname='test',LastName = LastName,Contact_Role__c = 'P',Type__c = 'Lawyer',AccountId = accountId);
        return con;
    }
    
    //  Create AccountContactRelation
    public static AccountContactRelation createAccContRelation(Id contactId, Id accountId){
        
        AccountContactRelation objAccCon = new AccountContactRelation();
        objAccCon.contactId = contactId;
        objAccCon.accountId = accountId;
        return objAccCon;
    }
    
    // Create Ledger Conditionally
    public static AcctSeed__Ledger__c createLedgerAcct (){
        return new AcctSeed__Ledger__c(Name= 'Actual', AcctSeed__Type__c = 'Transactional');
    }
    
    // Create Gl Acocunt   
    public static List<AcctSeed__GL_Account__c> createGLAccounts(){
        List<AcctSeed__GL_Account__c> glAccounts = new List<AcctSeed__GL_Account__c>();
        // 0
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1000-Cash',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = true,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash')
        );
        
        // 1
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1205-Unapplied A/R',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash'
            )
        );
        
        // 2
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1200-Accounts Receivable',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        
        // 3
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1600-Work In Process',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        
        // 4
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '2000-Accounts Payable',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Liabilities'
            )
        );
        
        // 5
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '2010-Vouchers Payable',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Liabilities',
                AcctSeed__Sub_Type_2__c = 'Current Liabilities'
            )
        );
        
        // 6
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '3050-Retained Earnings',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Equity'
            )
        );
        
        // 7
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '3060-Current Year Earnings',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Equity'
            )
        );
        
        // 8
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '4000-Product Revenue',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Revenue',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Product Family 1'
            )
        );
        
        // 9
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5010-Inventory Cost Variance',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Materials'
            )
        );
        
        // 10
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5040-Change in Ceded LAE Reserve',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Materials'
            )
        );
        
        // 11
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = 'zLabor Clearing',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense'
            )
        );
        
        // 12
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = 'zProject Labor',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense'
            )
        );
        
        // 13
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '4900-Customer Payment Discounts',
                AcctSeed__Active__c = true,
                AcctSeed__Bank__c = false,
                AcctSeed__Type__c = 'Revenue',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Product Family 1'
            )
        );
        
        // 14
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1400-Prepaid Expenses',
                AcctSeed__Active__c = true,
                AcctSeed__Bank__c = false,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        
        // 15
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1400-Prepaid Expenses',
                AcctSeed__Active__c = true,
                AcctSeed__Bank__c = false,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = 'LAE Pay Bill Line',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = 'Loss Pay Bill Line',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1500-Prepaid Expenses',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '2232-Ceded Prem Due Facultative & Cyber',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '6023-Ceded Commission',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        
        
        return glAccounts;
    }
    
    // Create Gl Acocunt 2    
    public static List<AcctSeed__GL_Account__c> createGLAccounts1 (){
        List<AcctSeed__GL_Account__c> glAccounts = new List<AcctSeed__GL_Account__c>();
        glAccounts.add(new AcctSeed__GL_Account__c(
            Name = '1000-cash', 
            AcctSeed__Active__c = true,
            AcctSeed__Bank__c=true,
            AcctSeed__Type__c= 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            AcctSeed__Sub_Type_2__c = 'Cash'
        )
                      );
        glAccounts.add(new AcctSeed__GL_Account__c(
            Name = '4000-Product Revenue',
            AcctSeed__Active__c = true,
            AcctSeed__Bank__c=false,
            AcctSeed__Type__c= 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Assets',
            AcctSeed__Sub_Type_2__c = 'Product Family 1'
        )
                      );
        return glAccounts;
    }
    
    // Create Acocunt Period  
    public static AcctSeed__Accounting_Period__c createAcctPeriod(){
        String acctPeriodName = string.valueOf(System.today().year())+'-';
        acctPeriodName += string.valueOf(system.today().month()).length() ==1 ?'0'+String.valueOf(system.today().month()) : String.valueOf(system.today().month());
        
        AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(Name=acctPeriodName,
                                                                                       AcctSeed__Start_Date__c =system.today().addDays(9) ,
                                                                                       AcctSeed__End_Date__c= system.today().addDays(9).addMonths(12),
                                                                                       AcctSeed__Status__c= 'Open'  );
        return acctPeriod;
    }      
    
    
    // Create Billing Format   
    public static List<AcctSeed__Billing_Format__c> createBillingFormats(){
        
        List<AcctSeed__Billing_Format__c> billingFormats = new List<AcctSeed__Billing_Format__c>();
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Billing Product',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Billing',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );  
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Billing Service',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__Type__c = 'Billing',
                AcctSeed__Sort_Field__c = 'Name'
            )
        );      
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Billing Outstanding Statment',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Outstanding Statement'
            )
        );    
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Billing Activity Statment',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Activity Statement'  
            )
        ); 
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Default Packing Slip',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = 'Billing_Email_Template',
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Packing Slip'  
            )
        ); 
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Default Purchase Orde',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = 'Billing_Email_Template',
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Purchase Order'  
            )
        ); 
        
        return billingFormats;
        
    }     
    // Create Ledger full        
    public static List<AcctSeed__Ledger__c> createLedgers(Id glAccountID,Id billingFormatId,Id billingFormatId1,Id billingFormatId2,Id billingFormatId3,Id billingFormatId4){
        
        List<AcctSeed__Ledger__c> ledgers = new List<AcctSeed__Ledger__c>();
        
        ledgers.add(
            new AcctSeed__Ledger__c(
                Name = 'Actual',
                AcctSeed__Type__c = 'Transactional',
                AcctSeed__Default_Bank_Account__c = glAccountID,
                AcctSeed__Default_Billing_Format__c = billingFormatId,
                AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormatId1,
                AcctSeed__Billing_Activity_Statement_Format__c = billingFormatId2,
                AcctSeed__Default_Purchase_Order_Format__c = billingFormatId4,
                AcctSeed__Default_Packing_Slip_Format__c  = billingFormatId3
            )
        );
        
        ledgers.add(
            new AcctSeed__Ledger__c(
                Name = 'Budget',
                AcctSeed__Type__c = 'Budget',
                AcctSeed__Default_Bank_Account__c = glAccountID,
                AcctSeed__Default_Billing_Format__c = billingFormatId,
                AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormatId1,
                AcctSeed__Billing_Activity_Statement_Format__c = billingFormatId2,
                AcctSeed__Default_Purchase_Order_Format__c = billingFormatId4,
                AcctSeed__Default_Packing_Slip_Format__c  = billingFormatId3
            )
        );
        
        return ledgers;
    }    
    
    // Create Account Setting    
    public static  AcctSeed__Accounting_Settings__c  createAccountsetting(Id ledgerId, Id glAccountID,Id glAccountID1, Id glAccountID2, Id glAccountID3, Id glAccountID4, Id glAccountID5, Id glAccountID6, Id BillingFormatId){
        
        AcctSeed__Accounting_Settings__c acctSetting = new AcctSeed__Accounting_Settings__c
            (AcctSeed__Default_Ledger__c =ledgerId ,
             AcctSeed__Default_Bank_Account__c =glAccountID ,
             AcctSeed__Current_Year_Earnings_GL_Account__c= glAccountID1 , 
             AcctSeed__Retained_Earnings_GL_Account__c =glAccountID2,
             AcctSeed__Revenue_GL_Account__c = glAccountID3, 
             AcctSeed__AR_Control_GL_Account__c =glAccountID4,
             AcctSeed__Unapplied_Cash_GL_Account__c =glAccountID5,
             AcctSeed__AP_Control_GL_Account__c =glAccountID6,
             AcctSeed__Default_Billing_Format__c=BillingFormatId,
             AcctSeed__Billing_Activity_Statement_Format__c=BillingFormatId,
             AcctSeed__Billing_Outstanding_Statement_Format__c =BillingFormatId );
        return acctSetting;
        
    }
    
    // Create Account Setting New  
    public static  AcctSeed__Accounting_Settings__c  createAccountsettingNew(Id ledgerId, Id glAccountID, Id glAccountID2, Id BillingFormatId){
        
        AcctSeed__Accounting_Settings__c acctSetting = new AcctSeed__Accounting_Settings__c(
            AcctSeed__Default_Ledger__c = ledgerId,
            AcctSeed__Default_Bank_Account__c = glAccountID, 
            AcctSeed__Revenue_GL_Account__c = glAccountID2,
            AcctSeed__AR_Control_GL_Account__c = glAccountID2,
            AcctSeed__Unapplied_Cash_GL_Account__c = glAccountID2,
            AcctSeed__AP_Control_GL_Account__c = glAccountID2,
            AcctSeed__Default_Billing_Format__c= BillingFormatId,
            AcctSeed__Billing_Activity_Statement_Format__c= BillingFormatId,
            AcctSeed__Billing_Outstanding_Statement_Format__c = BillingFormatId 
        );
        return acctSetting;
        
    }
    
    
    //  Create Cash Receipt
    public static AcctSeed__Cash_Receipt__c createCashReceipt(Id ledgerId, Id accountId, id accPeriod){
        
        AcctSeed__Cash_Receipt__c CashReceipt = new AcctSeed__Cash_Receipt__c();
        CashReceipt.AcctSeed__Ledger__c = ledgerId;
        CashReceipt.AcctSeed__Account__c = accountId;
        CashReceipt.AcctSeed__Status__c = 'In Process';
        CashReceipt.AcctSeed__Payment_Reference__c = 'Test';
        CashReceipt.AcctSeed__Receipt_Date__c = System.today();
        CashReceipt.AcctSeed__Amount__c = 100;
        CashReceipt.AcctSeed__Accounting_Period__c = accPeriod;
        
        return CashReceipt;
    }
    
    // Create Account Contact Junction     
    public static AccountContactJunction__c createAccConJunc(Id accountId, Id contactId){
        AccountContactJunction__c acj = new AccountContactJunction__c();
        acj.Account__c                = accountId;
        acj.Contact__c                = contactId;
        acj.Name                      = 'Test Name';
        
        return acj;
    }
    
    
    // Create Opportunity    
    public static Opportunity createOpp(Id accountid){
        Opportunity opp               = new Opportunity();
        opp.Name                      = 'Test Opportunity';
        opp.AccountId                 = accountid;
        opp.StageName                 = 'Application Sent';
        opp.CloseDate                 = Date.today();
        return opp;
    }
    
    // Create Master Factor
    public static Master_Factor__c createMasterfactor(string factorname, string factortype){
        Master_Factor__c MFactor = new Master_Factor__c();
        MFactor.Name                      = factorname;
        MFactor.Factor_Type__c            = factortype;
        MFactor.From_Date__c              = Date.today();
        MFactor.To_Date__c                = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day());
        MFactor.Default__c                = true;
        
        return MFactor;
    }
    
    // Create Step rate Factor    
    public static Step_Rate_Factor__c createStepFactor(Id mFactorId){
        Step_Rate_Factor__c STF         = new Step_Rate_Factor__c();
        STF.Name                        = 'Step Rate Factor';
        STF.Master_Factor__c            =  MFactorId; 
        STF.Factor_Value_Step_Rate_0__c = 1.25;
        STF.Factor_Value_Step_Rate_1__c = 1.25;
        STF.Factor_Value_Step_Rate_2__c = 1.25;
        STF.Factor_Value_Step_Rate_3__c = 1.25;
        STF.Factor_Value_Step_Rate_4__c = 1.25;
        STF.Factor_Value_Step_Rate_5__c = 1.25;
        STF.Factor_Value_Step_Rate_6__c = 1.25;
        STF.Factor_Value_Step_Rate_7__c = 1.25;
        
        return STF;
    }
    
    // Create Base Factor    
    public static Base_Factor__c createBaseFactor(Id mFactorId){
        Base_Factor__c BaseFactor    = new Base_Factor__c();
        BaseFactor.Name              = 'Base Factor value';
        BaseFactor.Master_Factor__c  =  mFactorId; 
        BaseFactor.Base_Amount__c    = 1067;
        
        return BaseFactor;
    }
    
    // Create County    
    public static County__c createCounty(){
        County__c county              = new County__c();
        county.Name                   = 'Test County';
        county.Region__c              = '5';
        
        return county;
    }
    
    // Create Policy
    public static Policy__c createPolicy(Id accountId, Id oppId, Id geoId,String recordTypeName){
        Map<String,Id> mapOfRecordTypes = new Map<String,Id>();
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Policy__c']) {
            mapOfRecordTypes.put(rt.DeveloperName, rt.Id);
        }
        Policy__c pol                 = new Policy__c();
        pol.RecordTypeId              = mapOfRecordTypes.get(recordTypeName);
        pol.Name                      = '100001-1';
        //pol.Status__c                 = 'Received';
        pol.Account__c                = accountId; 
        pol.Opportunity__c            = oppId;
        pol.Aggregate_Limit__c         =       1;
        //pol.All_Claims_Incurred__c     =  1.6;
        pol.Effective_Date__c         = System.today().addDays(-1);
        pol.Expiration_Date__c        = System.today().addDays(10);
        pol.Cancel_Date__c            = System.today().addDays(10);
        pol.SCH_Mod__c                = 1.00;
        pol.County__c                 = geoId;
        Pol.Premium__c = 100;
        
        return pol;
    }
    
    // Create Policy Conditionally    
    public static Policy__c createPolicy1(Id accountId, Id oppId, Id geoId,String recordTypeName,Id createCoveragefactorId){
        Map<String,Id> mapOfRecordTypes = new Map<String,Id>();
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Policy__c']) {
            mapOfRecordTypes.put(rt.DeveloperName, rt.Id);
        }
        Policy__c pol                 = new Policy__c();
        pol.RecordTypeId              = mapOfRecordTypes.get(recordTypeName);
        pol.Name                      = '100001-1';
        pol.Status__c                 = 'sent';
        pol.Account__c                = accountId;
        pol.Opportunity__c            = oppId;
        pol.Effective_Date__c         = System.today().addDays(-1);
        pol.Expiration_Date__c        = System.today().addDays(2);
        pol.Cancel_Date__c            = System.today().addDays(2);
        pol.SCH_Mod__c                = 1.00;
        pol.County__c                 = geoId;
        pol.Limit__c                  = createCoveragefactorId;
        Pol.Premium__c = 100;
        
        return pol;
    }
    
    
    // Create Active
    public static Policy__c createActivePolicy(Id accountId, Id oppId, Id geoId,String recordTypeName){
        Map<String,Id> mapOfRecordTypes = new Map<String,Id>();
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Policy__c']) {
            mapOfRecordTypes.put(rt.DeveloperName, rt.Id);
        }
        Policy__c acctivePolicy                 = new Policy__c();
        acctivePolicy.RecordTypeId              = mapOfRecordTypes.get(recordTypeName);
        acctivePolicy.Name                      = '10000-Active';
        acctivePolicy.Account__c                = accountId;
        acctivePolicy.Opportunity__c            = oppId;
        acctivePolicy.Effective_Date__c         = System.today().addDays(-1);
        acctivePolicy.Expiration_Date__c        = System.today().addDays(10);
        acctivePolicy.Cancel_Date__c            = System.today().addDays(10);
        acctivePolicy.SCH_Mod__c                = 1.00;
        acctivePolicy.County__c                 = geoId;
        acctivePolicy.Premium__c = 100;
        acctivePolicy.Base_Amount__c = 100;
        acctivePolicy.Firm_Mod__c = 2;
        
        return acctivePolicy;
    }
    
    // Create policy with only account    
    public static Policy__c createPolicyOnlyAcocunt(Id accountId,String recordTypeName){
        Map<String,Id> mapOfRecordTypes = new Map<String,Id>();
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Policy__c']) {
            mapOfRecordTypes.put(rt.DeveloperName, rt.Id);
        }
        Policy__c objPolicy = new Policy__c();
        objPolicy.Account__c = accountId;
        objPolicy.RecordTypeId = mapOfRecordTypes.get(recordTypeName);
        objPolicy.Effective_Date__c = System.today().addDays(-2);
        objPolicy.Expiration_Date__c = System.today().addDays(2); 
        objPolicy.Cancel_Date__c = System.today(); 
        objPolicy.Cancel_Date__c = System.today().addDays(1);
        
        return objPolicy;
    }
    
    // Create Geo Factor    
    public static Geo_Factor__c createGeoFactor(Id mfactorId,Id countyId){
        Geo_Factor__c geo             = new Geo_Factor__c();
        geo.Name                      = 'Test County';
        geo.Master_Factor__c          = mfactorId;
        geo.Region_Factor_Value__c    = 0.87;
        geo.County__c                 = countyId;
        
        return geo;
    }
    
    
    // Create Policy Lawyer    
    public static Policy_Lawyer__c createPolicyLawyer(Id accountId,Id policyId,Id acntContJunId){
        Policy_Lawyer__c polLaw       = new Policy_Lawyer__c();
        polLaw.Account__c             = accountId;
        polLaw.Policy__c              = policyId;
        polLaw.Prior_Act_Date__c      = date.today();
        polLaw.Lawyer__c              = acntContJunId;
        polLaw.Rate_At__c = 100;
        polLaw.Step__c = 0;
        return polLaw;
    }
    
    // Create Claim setting (Custom Settting )
    public static Claim_Setting__c createClaimSetting(){
        Claim_Setting__c customSetting = new Claim_Setting__c ();
        customSetting.Deductible_LAE_Applied_After__c = 5000;
        customSetting.ARDC_ISBA_First_Contribution__c = 5000;
        customSetting.ARDC_Sublimit_Per_Policy__c = 100000;
        customSetting.ARDC_Sublimit_Per_Lawyer__c = 20000;
        customSetting.Open_Reserve_Loss_Value__c = 10000;
        customSetting.Open_Reserve_LAE_Value__c = 5000;
        
        return customSetting;
    }
    
    // Cretae Policy Claim    
    public static Policy_Claim__c  createPolicyClaim(Id policyId,Id lawyerId){
        
        Policy_Claim__c claim = new Policy_Claim__c();
        claim.name = 'test';
        claim.Policy__c = policyId;
        claim.File_Type__c = 'Claim';
        claim.Lawyer__c = lawyerId;
        claim.Report_Date__c = date.today();
        claim.Occur_Date__c = date.today().adddays(-2);
        claim.Claim_Made_Date__c = date.today();
        claim.State__c = 'test';
        claim.Reserve_Loss__c = 100000;
        claim.Reserve_LAE__c = 0;
        claim.Per_Claim_Deductible__c = 100;
        
        return claim;
    }
    
    // Create Endorsement    
    public static Endorsement__c createEndorsement(String subType,String type,String recordTypeName){
        
        // This recordType id is of Policy_Endorsement__c, there is no record type on endorsment
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Endorsement__c endorse = new Endorsement__c();
        endorse.Active__c=true;
        endorse.Endorsement_Sub_Type__c=subType;
        endorse.Type__c = type;
        endorse.Endorsement_Record_Type_ID__c= devRecordTypeId;
        endorse.Description__c='Test desc';
        
        return endorse;
    }
    
    // Create Endorsment Version
    public static Endorsement_Version__c  createEndorsementVersion(Id endorsmentId){
        
        Endorsement_Version__c endorseVersion = new Endorsement_Version__c();
        endorseVersion.Master_Endorsement__c=endorsmentId;
        endorseVersion.Endorsement_Version_Number__c='1';
        endorseVersion.Effective_From__c=System.today();
        
        return endorseVersion;
    }
    
    // Create Policy Endorsment    
    public static Policy_Endorsement__c createPolicyEndorsement(Id accountId,Id policyId,String recordTypeName){
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Policy_Endorsement__c policyEndorse = new Policy_Endorsement__c();
        policyEndorse.Account__c =accountId;
        policyEndorse.Name='Test Policy Endorsement';
        policyEndorse.Policy__c =policyId;
        policyEndorse.RecordTypeId=devRecordTypeId;
        policyEndorse.Endorsement_Effective_Date__c = System.today();
        policyEndorse.Rate_At__c=10;
        policyEndorse.Effective_Date__c = System.today();
        policyEndorse.Premium__c=10;
        policyEndorse.Event_Status__c = 'Pending';
        policyEndorse.Step_Override__c = true;
        policyEndorse.Step_Override_Value__c = 0;
        policyEndorse.Prior_Act_Date__c = System.today();
        return policyEndorse;
    }
    /*    
// Create Policy EndorsmentNew    
public static Policy_Endorsement__c createPolicyEndorsementNew(Id accountId,Id policyId,String recordTypeName){

Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
Policy_Endorsement__c policyEndorse = new Policy_Endorsement__c();
policyEndorse.Account__c =accountId;
policyEndorse.Name='Test1 Policy Endorsement';
policyEndorse.Policy__c =policyId;
policyEndorse.RecordTypeId=devRecordTypeId;
policyEndorse.Endorsement_Effective_Date__c = System.today();
policyEndorse.Rate_At__c=10;
policyEndorse.Effective_Date__c = System.today();
policyEndorse.Premium__c=10;
policyEndorse.Event_Status__c = 'Pending';
policyEndorse.Step_Override__c = true;
policyEndorse.Step_Override_Value__c = 0;
policyEndorse.Prior_Act_Date__c = System.today();
return policyEndorse;
}    
*/    
    // Create Aop Factor    
    public static AOP_Factor__c createAopFactor(Id mastorFactorId){
        
        AOP_Factor__c aopFactor = new AOP_Factor__c();
        aopFactor.Master_Factor__c=mastorFactorId;
        aopFactor.Name='Test AOP Factor';
        
        return aopFactor;
    }
    
    // Create Policy AOP    
    public static Policy_AOP__c  createPolicyAop(Id aopFactorId,Id policyId){
        
        Policy_AOP__c aop = new Policy_AOP__c();
        aop.Policy__c=policyId;
        aop.AOP__c=aopFactorId;
        aop.Factor_Mod__c=2;
        aop.Percentage__c=5;
        
        return aop;
    }
    
    // Create Account Payable    
    public static AcctSeed__Account_Payable__c  createAccountPayable(Id periodId,Id ledgerId,Id policyAccountId,Id claimId){
        
        AcctSeed__Account_Payable__c payable = new AcctSeed__Account_Payable__c();
        payable.AcctSeed__Accounting_Period__c = periodId;
        payable.Type__c = 'LAE Pay';
        payable.AcctSeed__Payee_Reference__c = 'Test Payable';
        payable.AcctSeed__Vendor__c= policyAccountId;
        payable.Claim__c = claimId;
        payable.AcctSeed__Ledger__c = ledgerId;
        
        return payable;
    }
    
    // Create Payable Line    
    public static AcctSeed__Account_Payable_Line__c  createAccountPayableLine(Id payableId,Id glAccountId){
        
        AcctSeed__Account_Payable_Line__c payableLine = new AcctSeed__Account_Payable_Line__c ();
        
        payableLine.AcctSeed__Expense_GL_Account__c = glAccountId;
        payableLine.AcctSeed__Amount__c = 6000;
        payableLine.AcctSeed__Account_Payable__c = payableId; 
        
        return payableLine;
    }
    
    // Create Custom Setting Transaction Credit and Debit    
    public static Transaction_Credit_And_Debits__c createTranscredDebit(string creditGl, String debitGl){
        
        Transaction_Credit_And_Debits__c customSetting = new Transaction_Credit_And_Debits__c();
        customSetting.Name='Billing Line';
        customSetting.Credit_GL__c=creditGl;
        customSetting.Debit_GL__c=debitGl;
        
        return customSetting;
    }
    
    // Create Billing    
    public static AcctSeed__Billing__c createBilling(Id accountId,Id periodId,Id ledgerId){
        
        AcctSeed__Billing__c objBilling = new AcctSeed__Billing__c();
        objBilling.AcctSeed__Credit_Memo_Applied_Amount__c=10;
        objBilling.AcctSeed__Customer__c = accountId;
        objBilling.AcctSeed__Billing_Country__c = 'US';
        objBilling.AcctSeed__Status__c = 'Approved';
        objBilling.AcctSeed__Accounting_Period__c = periodId;
        objBilling.AcctSeed__Date__c = System.today();
        objBilling.AcctSeed__Due_Date2__c = System.today();
        objBilling.AcctSeed__Ledger__c = ledgerId;
        
        return objBilling;
    }
    
    // Create Billing Line    
    public static AcctSeed__Billing_Line__c createBillingLine(Id billingId,Id glAccountId){
        
        AcctSeed__Billing_Line__c billLine = new AcctSeed__Billing_Line__c();
        billLine.AcctSeed__Billing__c = billingId;
        billLine.AcctSeed__Revenue_GL_Account__c = glAccountId;
        billLine.AcctSeed__Comment__c ='test';
        billLine.AcctSeed__Rate__c = 3;
        billLine.AcctSeed__Hours_Units__c = 1;
        
        return billLine;
    }
    
    // Create Note (Custom Object)    
    public static Note__c createNote(Id policyId){
        Note__c objNote = new Note__c();
        objNote.Policy__c = policyId;
        return objNote;
    }
    
    // Create Note With Account Object(Custom Object)    
    public static Note__c createNoteForAccount(Id accountId,String type){
        Note__c objNote = new Note__c();
        objNote.Type__c = type;
        objNote.Account__c = accountId;  
        return objNote ;
    }
    
    // Create ContentVersion     
    public static ContentVersion createContentVersoion(String title, String pathOnClient){
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = title;
        contentVersion.PathOnClient = pathOnClient;
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;   
        contentVersion.Endorsement_Id__c = 'abc';
        return contentVersion;
    }
    
    // Create ContentDocumentLink    
    public static List<ContentDocumentLink> createContentDocumentLink(Id entityId, Id documentId){
        
        List<ContentDocumentLink> lstDocLink = new List<ContentDocumentLink>();
        ContentDocumentLink objLink = New ContentDocumentLink();
        objLink.LinkedEntityId = entityId;
        objLink.ContentDocumentId = documentId;
        objLink.shareType = 'V';
        lstDocLink.add(objLink);
        return lstDocLink;
    }
    
    // Create ILF Coverage Factor
    public static ILF_Coverage_Factor__c createCoveragefactor(Id masterfactorCoverageId){
        ILF_Coverage_Factor__c FactorCoverage = new ILF_Coverage_Factor__c();
        FactorCoverage.Name = '250,000 / 500,000';
        FactorCoverage.Lowest_Coverage__c = true;
        FactorCoverage.Master_Factor__c = masterfactorCoverageId;
        FactorCoverage.Coverage_Max_Per_Claim__c = 500000;
        FactorCoverage.Full_Coverage__c = 250000;
        FactorCoverage.Factor_Value__c = 0.96;
        return FactorCoverage;
    }
    
    // Create Deductible Factor    
    public static  Deductible_Factor__c createDeductiblefactor(Id MasterFactorDeductibleId){
        Deductible_Factor__c FactorDeductible = new Deductible_Factor__c();
        FactorDeductible.Name = '1000';
        FactorDeductible.Deductible_Amount__c = 1000;
        FactorDeductible.Factor_Value__c = 0.96;
        FactorDeductible.Master_Factor__c = MasterFactorDeductibleId;
        return FactorDeductible;
    }
    
    // Create Journal Entry    
    public static AcctSeed__Journal_Entry__c  createJournalEntry(Id periodId, id ledgerid){
        
        AcctSeed__Journal_Entry__c jEntry = new AcctSeed__Journal_Entry__c();
        jEntry.Name = 'tEST 1';
        jEntry.AcctSeed__Status__c = 'Approved';
        jEntry.AcctSeed__Journal_Date__c = date.today();
        jEntry.AcctSeed__Accounting_Period__c = periodId;
        jEntry.AcctSeed__Ledger__c = ledgerid;
        
        return jEntry;
    }
    
    public static List<AcctSeed__Journal_Entry_Line__c>  createJournalEntryLine(Id JeId, Id glAccountId){
        
        List<AcctSeed__Journal_Entry_Line__c> jeLine = new List<AcctSeed__Journal_Entry_Line__c>();
        jeLine.add( new AcctSeed__Journal_Entry_Line__c (
            AcctSeed__Units__c = 1,
            AcctSeed__Date__c  = date.today(),
            AcctSeed__GL_Account__c = glAccountId,
            AcctSeed__Credit__c = 100,
            AcctSeed__Journal_Entry__c =JeId
        )
                  );
        
        jeLine.add( new AcctSeed__Journal_Entry_Line__c (
            AcctSeed__Units__c = 1,
            AcctSeed__Date__c  = date.today(),
            AcctSeed__GL_Account__c = glAccountId,
            AcctSeed__Debit__c = 100,
            AcctSeed__Journal_Entry__c =JeId
        )
                  );
        
        return jeLine;
    }
    
    // Create As Transaction
    public static AS_Transaction__c createTransaction(Id policyEndorsId,String TransactioType ,Decimal Amount,Id policyId,Id claimId,  Id policyAccount, Id claimDetailId, String subtype){
        
        AS_Transaction__c objTrans = new AS_Transaction__c ();
        objTrans.Policy_Endorsement_Id__c = policyEndorsId;
        objTrans.Transaction_Type__c = TransactioType ;
        objTrans.Amount__c =Amount;
        objTrans.Policy_Id__c=policyId;
        objTrans.Claim_Id__c=claimId;
        objTrans.Firm_Id__c= policyAccount;
        objTrans.Policy_Claim_Detail__c=claimDetailId;
        objTrans.Transaction_Sub_Type__c = subtype;
        
        return objTrans;
    }
    
    // Create Policy Claim details    
    public static Policy_Claim_Detail__c createPolClaimDetail(Id policyAccountId,string recordTypeName, Id policyClaimId,String type){
        
        Policy_Claim_Detail__c objDetail = new Policy_Claim_Detail__c();
        objDetail.Vendor__c= policyAccountId;
        objDetail.RecordTypeId = Schema.SObjectType.Policy_Claim_Detail__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        objDetail.Date__c=date.today();
        objDetail.Policy_Claim__c=policyClaimId;
        objDetail.Type__c=type;
        
        return objDetail;
    }
    
    // Create Policy Claim details New   
    /*   public static Policy_Claim_Detail__c createPolClaimDetailNew(Id policyAccountId,string recordTypeName, Id policyClaimId){

Policy_Claim_Detail__c objDetail = new Policy_Claim_Detail__c();
objDetail.Vendor__c= policyAccountId;
objDetail.RecordTypeId = Schema.SObjectType.Policy_Claim_Detail__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
objDetail.Date__c=date.today();
objDetail.Policy_Claim__c=policyClaimId;
objDetail.Type__c= 'User Reserve';

return objDetail;
}
*/
    
    // Create Customer Application Lawyer
    public static Customer_Application_Lawyer__c createAppLawyer(Id customerApplicationId){
        
        Customer_Application_Lawyer__c objCustomerappLay = new Customer_Application_Lawyer__c();
        objCustomerappLay.Customer_Application__c = customerApplicationId;
        objCustomerappLay.ARDC_Number__c = 'test22';
        objCustomerappLay.Average_Number_of_Hours_Worked__c = 10;
        objCustomerappLay.Name = 'testing';
        objCustomerappLay.Date_of_Hire__c = system.today();
        objCustomerappLay.Designation__c = 'Associate or Employed Lawyer';
        objCustomerappLay.ISBA_Number__c = 'tstt1';   
        return objCustomerappLay;
        
    }
    
    // Create Policy Quote    
    public static Policy_Quote__c createPolicyQuote(id policyId,Id coverFactorId, Id deductableId){
        
        Policy_Quote__c policyQuote = new Policy_Quote__c();
        policyQuote.Policy__c = policyId;
        policyQuote.Coverage__c = coverFactorId;  
        policyQuote.Deductible__c = deductableId;   
        policyQuote.Final_Quote__c = true;
        
        return policyQuote;
    }
    
    // Create related Contacts    
    public static Related_Contacts__c createRelatedContact(Id claimId, Id accountId, Id contactId){
        Related_Contacts__c objRelatedCon = new Related_Contacts__c();
        objRelatedCon.Type__c = 'Defense Firm';
        objRelatedCon.Claim__c = claimId;
        objRelatedCon.Account__c = accountId;
        objRelatedCon.Contact__c = contactId;
        return objRelatedCon;
    }
    
    // Create Schedule Revenue expense    
    public static AcctSeed__Scheduled_Revenue_Expense__c createSchdRevExpence(Id periodId,Id glAccountId, Id BillingId){
        AcctSeed__Scheduled_Revenue_Expense__c objSchedule = new AcctSeed__Scheduled_Revenue_Expense__c();
        objSchedule.AcctSeed__Accounting_Period__c = periodId;
        objSchedule.AcctSeed__Amount__c = 10;
        objSchedule.AcctSeed__Credit_GL_Account__c = glAccountId;
        objSchedule.AcctSeed__Debit_GL_Account__c = glAccountId;
        objSchedule.AcctSeed__Billing__c = BillingId;
        
        return objSchedule;  
        
    }
    
    // Create Cash Disburshment Batch    
    public static AcctSeed__Cash_Disbursement_Batch__c createCashDisbrBatch(){
        AcctSeed__Cash_Disbursement_Batch__c cashDisburseBatch = new AcctSeed__Cash_Disbursement_Batch__c();
        cashDisburseBatch.AcctSeed__Starting_Check_Number__c=1;
        return cashDisburseBatch;
    }
    
    // Create Cash Disburshment    
    public static AcctSeed__Cash_Disbursement__c createCashDisbrhment(Id periodId,String type,Id accountId,Id glAccountId,Id cashDisbrshBatchId,Id ledgerId){
        AcctSeed__Cash_Disbursement__c cashDisburse = new AcctSeed__Cash_Disbursement__c();
        cashDisburse.AcctSeed__Accounting_Period__c = periodId;
        cashDisburse.AcctSeed__Type__c=type;
        cashDisburse.AcctSeed__Vendor__c= accountId;
        cashDisburse.AcctSeed__Status__c='In Process';
        cashDisburse.AcctSeed__Payment_Status__c='Paid';
        cashDisburse.AcctSeed__Disbursement_Date__c=System.today();
        cashDisburse.AcctSeed__Amount__c=200;
        cashDisburse.AcctSeed__Bank_Account__c=glAccountId;
        cashDisburse.AcctSeed__Source__c='Manual';
        cashDisburse.AcctSeed__Cash_Disbursement_Batch__c=cashDisbrshBatchId;
        cashDisburse.AcctSeed__Ledger__c=ledgerId;
        
        return cashDisburse;
    }
    
    // Create AP Disburshment    
    public static AcctSeed__AP_Disbursement__c createApDisbrBatch(Id cashDursbirshmentId,Id payableId){
        AcctSeed__AP_Disbursement__c apDisburse = new AcctSeed__AP_Disbursement__c();
        apDisburse.AcctSeed__Cash_Disbursement__c = cashDursbirshmentId; 
        apDisburse.AcctSeed__Account_Payable__c= payableId;
        apDisburse.AcctSeed__Paid_Amount__c=200;
        return apDisburse;
    }
    
    // Create BCR
    Public Static AcctSeed__Billing_Cash_Receipt__c createBCR(id billingID,id crID){
        AcctSeed__Billing_Cash_Receipt__c bcr = new AcctSeed__Billing_Cash_Receipt__c();
        bcr.AcctSeed__Billing__c = billingID;
        bcr.AcctSeed__Cash_Receipt__c = crID;
        
        return bcr;
    }
    
}