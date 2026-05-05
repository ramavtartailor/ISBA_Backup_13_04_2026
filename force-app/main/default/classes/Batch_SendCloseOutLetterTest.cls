@isTest public with sharing class Batch_SendCloseOutLetterTest {
    @testSetup
    public static void testSetup(){
        Cardknox_Creds__c creds = Cardknox_Creds__c.getOrgDefaults();
        creds.SB_Transaction_URL__c = 'test.com';
        creds.Software_Version__c = '1.0';
        creds.SB_Base_URL__c = 'test.com';
        creds.Software_Name__c = 'test';
        creds.SB_xKey__c = 'key';
        creds.Base_URL__c = 'test.com';
        creds.xKey__c = 'key';
        creds.Transaction_URL__c = 'test.com';
        Upsert creds;
        
        Account acc                   = TestDataFactory.createAccounts('Dummy Billing Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        acc.Payment_Link_Activation_Started_at__c = system.today();
        insert acc;
        
        AcctSeed__Payment_Method__c payMethod2 = new AcctSeed__Payment_Method__c();
        payMethod2.AcctSeed__External_Id__c = 'paymethod_token';
        payMethod2.AcctSeed__Customer__c = acc.Id;
        payMethod2.AcctSeed__Payment_Method_Type__c = 'Credit Card';
        payMethod2.Name_On_Card__c ='name_on_card';
        payMethod2.AcctSeed__Account_Number__c = '4xxxxxxxxxxx1111';
        payMethod2.AcctSeed__Last_Four_Digits__c  ='1111';
        payMethod2.AcctSeed__Expiration_Month__c = String.valueOf(02);
        payMethod2.AcctSeed__Expiration_Year__c = String.valueOf(system.today().addYears(5).year());
        payMethod2.AcctSeed__Type__c = 'VISA';
        Insert payMethod2;

        List<Payment_Method__c> paymentMethodList = new List<Payment_Method__c>();
        Payment_Method__c payMethod = new Payment_Method__c();
        payMethod.Payment_Method_Token__c = 'paymethod_token';
        payMethod.Account__c = acc.Id;
        payMethod.Type__c = 'Credit_Card';
        payMethod.Name_On_Card__c ='name_on_card';
        payMethod.Masked_Account_Number__c = 'masked_account_number';
        payMethod.Expiry_Month__c = 02;
        payMethod.Expiry_Year__c = system.today().addYears(5).year();
        payMethod.Card_Type__c = 'AMEX';
        payMethod.Account_Type__c = 'Checking';
        paymentMethodList.add(payMethod);
        
        Payment_Method__c payMethod1 = new Payment_Method__c();
        payMethod1.Card_Holder_Name__c = 'test';
        payMethod1.Payment_Method_Token__c = 'paymethod_token';
        payMethod1.Account__c = acc.Id;
        payMethod1.Type__c = 'Credit_Card';
        payMethod1.Name_On_Card__c ='name_on_card';
        payMethod1.Masked_Account_Number__c = 'masked_account_number';
        payMethod1.Expiry_Month__c = 02;
        payMethod1.Expiry_Year__c = system.today().addYears(5).year();
        payMethod1.Card_Type__c = 'AMEX';
        payMethod1.Account_Type__c = 'Checking';
        paymentMethodList.add(payMethod1);
        Insert paymentMethodList;
        
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
        
        // create GL Accounts
        AcctSeed__GL_Account__c[] glAccounts = new List<AcctSeed__GL_Account__c>();
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
                AcctSeed__Sub_Type_1__c = 'Liabilities',
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
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Equity'
            )
        );
        
        // 8
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '4000-Premium',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = ' Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Product Family 1'
            )
        );
        
        // 9
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5010-Inventory Cost Variance',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = ' Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Materials'
            )
        );
        
        // 10
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5040-Vendor Payment Discounts',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
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
                AcctSeed__Sub_Type_1__c = 'Product Revenue',
                AcctSeed__Sub_Type_2__c = 'Product Family 1'
            )
        );
        
        // 14
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1400-Prepaid Expenses',
                AcctSeed__Active__c = true,
                AcctSeed__Bank__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        
        // 15
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1300-Accounts Receivable',
                AcctSeed__Active__c = true,
                AcctSeed__Bank__c = false,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        
        // 16
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '6420-Service Charges',
                AcctSeed__Active__c = true,
                AcctSeed__Bank__c = false,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        
        insert glAccounts;
        
        // insert 1 Ledger records
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(
            Name = 'Actual',
            AcctSeed__Type__c = 'Transactional',
            AcctSeed__Default_Bank_Account__c = glAccounts[0].id,
            AcctSeed__Default_Billing_Format__c = PDFformats[0].Id,
            AcctSeed__Billing_Outstanding_Statement_Format__c = PDFformats[2].Id,
            AcctSeed__Billing_Activity_Statement_Format__c = PDFformats[3].Id,
            AcctSeed__Default_Purchase_Order_Format__c = PDFformats[4].Id,
            AcctSeed__Default_Packing_Slip_Format__c = PDFformats[5].Id);
        
        insert ledger;
        
        
        AcctSeed__Payment_Processor__c payProcessor = new AcctSeed__Payment_Processor__c();
        payProcessor.Name = 'Cardknox';
        payProcessor.AcctSeed__Type__c = 'Cardknox';
        payProcessor.AcctSeed__Default_Ledger__c = ledger.Id;
        payProcessor.AcctSeed__Bank_GL_Account__c = glAccounts[0].Id;
        payProcessor.AcctSeed__Merchant_GL_Account__c = glAccounts[14].Id;
        payProcessor.AcctSeed__Merchant_Fees_GL_Account__c = glAccounts[12].Id;
        Insert payProcessor;
        
        Transaction_Credit_And_Debits__c customSetting = new Transaction_Credit_And_Debits__c();
        customSetting.Name='Billing Line';
        customSetting.Credit_GL__c='1300-Accounts Receivable';
        customSetting.Debit_GL__c='4000-Premium';
        insert customSetting;
        
        // insert 1 Accounting Period
        AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
            Name = '1991-10',
            AcctSeed__Start_Date__c = System.today().toStartOfMonth(),
            AcctSeed__End_Date__c = System.today().toStartOfMonth().addMonths(1),
            AcctSeed__Status__c = 'Open');
        insert acctPeriod;
        
        AcctSeed__Accounting_Settings__c settings = new AcctSeed__Accounting_Settings__c(
            Name = 'Test Settings',
            
            AcctSeed__Default_Ledger__c = ledger.Id,
            AcctSeed__Legacy_Default_Ledger__c = ledger.Id,
            AcctSeed__Enable_Product_Costing__c = true,
            AcctSeed__Display_Billable_Flag_in_Time_Card_Entry__c = true,
            AcctSeed__Enable_Billing_Period_Sensitive_Aging__c = true,
            AcctSeed__Enable_AP_Period_Sensitive_Aging__c = true,
            AcctSeed__Work_in_Process_GL_Account__c = glAccounts[3].Id,
            AcctSeed__Vouchers_Payable_GL_Account__c = glAccounts[5].Id,
            AcctSeed__Inventory_Variance_GL_Account__c = glAccounts[13].Id,
            AcctSeed__Payment_Discount_GL_Account__c = glAccounts[14].Id
        );
        insert settings;
        Contact con = new Contact(
            FirstName = 'APPROVED',
            LastName = 'TEST',
            AccountId = acc.Id,
            Email = 'test@test.com'
        );
        Insert con;
        
        acc.AcctSeed__Billing_Contact__c = con.Id;
        update acc;
        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
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
        
        //RecordType recType  = [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Policy__c' and name='Policy' limit 1];
        Policy__c pol= TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Policy');
        pol.Base_Amount__c = 100;
        pol.Firm_Mod__c = 2;
        pol.Limit__c = FactorCoverage.Id;
        pol.Deductible_ID__c = DedFac.id;
        pol.Premium__c =500;
        pol.IBF_Contribtuion__c = 'No IBF Contribution';
        pol.ISBAM_policy_dividend__c = 10;
        pol.Expiration_Date__c = System.today().addDays(-1);
        pol.Cancel_Date__c = null;
        pol.Next_Policy__c = null;
        //pol.RecordTypeId = recType.id;
        insert pol;
    }
    
    @isTest
    public static void testMethod1(){
        test.startTest();
        Database.executeBatch(new Batch_SendCloseOutLetter(),1);
        test.stoptest();
    }
    
    @isTest
    public static void testMethod2(){
        List<Policy__c> policyList = new List<Policy__c>();
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Geo_Factor__c geo = [SELECT Id FROM Geo_Factor__c LIMIT 1];
        ILF_Coverage_Factor__c FactorCoverage = [SELECT Id FROM ILF_Coverage_Factor__c LIMIT 1];
        Deductible_Factor__c DedFac = [SELECT Id FROM Deductible_Factor__c LIMIT 1];
            
        for(Integer i = 0; i < 10; i++){
            Policy__c pol= TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Policy');
            pol.Base_Amount__c = 100;
            pol.Firm_Mod__c = 2;
            pol.Limit__c = FactorCoverage.Id;
            pol.Deductible_ID__c = DedFac.id;
            pol.Premium__c =500;
            pol.IBF_Contribtuion__c = 'No IBF Contribution';
            pol.ISBAM_policy_dividend__c = 10;
            pol.Expiration_Date__c = System.today().addDays(-1);
            pol.Cancel_Date__c = null;
            pol.Next_Policy__c = null;
            policyList.add(pol);
        }
        
        Insert policyList;
        
        test.startTest();
        Database.executeBatch(new Batch_SendCloseOutLetter());
        test.stoptest();
    }
    
}