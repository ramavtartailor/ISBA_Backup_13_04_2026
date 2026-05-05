@isTest
private class PaymentRestApiTest {
    @testSetup
    private static void testSetup() {
        Test.startTest();
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        opp.StageName                 = 'Application Sent';
        opp.CloseDate                 = Date.today();
        insert opp;
        
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Step Rate');
        insert mas;
        
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(mas.Id);
        insert stepRateFactor;
        
        ILF_Coverage_Factor__c ilfCoverageLowest = TestDataFactory.createCoveragefactor(mas.id);
        insert ilfCoverageLowest;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas.Id);
        Insert DedFac;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.id,county.Id);
        insert geo;
        
        Policy__c pol                 = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Application');
        pol.Status__c                 = 'Accepted';
        pol.SCH_Mod__c                = 1.00;
        pol.Policy_Document_Version__c    = '1/18';
        pol.Premium__c                 = 100;
        pol.Base_Amount__c = 123;
        pol.Firm_Mod__c = 112;
        pol.Limit__c = ilfCoverageLowest.id;
        pol.Deductible_ID__c = DedFac.id;
        pol.Premium_Amount__c = 120;
        insert pol;
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorNew.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy.Effective_Date__c = date.today();//.addDays(7);
        insert acctivePolicy;
        
        
        // Policy_Quote__c objPolQuote = TestDataFactory.createPolicyQuote(acctivePolicy.Id,coverageFactorObj.Id,DedFac.id);
        // insert objPolQuote;
        
        
        
        Contact con  = TestDataFactory.createContact('Test Contact',acc.id);
        con.ARDC_Number__c=null;
        insert con;
        
        
        
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(acctivePolicy.Account__C, con.Id);
        insert junc;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(acctivePolicy.Account__c,acctivePolicy.Id,junc.Id);
        insert law;
        
        Endorsement__c endorse191= TestDataFactory.createEndorsement('','descriptive','IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT');
        insert endorse191;
        
        Endorsement_Version__c endorseVersion1 = TestDataFactory.createEndorsementVersion(endorse191.Id);
        endorseVersion1.Endorsement_Version_Number__c='1';
        insert endorseVersion1;
        
        
        Endorsement_Version__c endorseVersion2 = TestDataFactory.createEndorsementVersion(endorse191.Id);
        endorseVersion1.Endorsement_Version_Number__c='2';
        insert endorseVersion2;
        
        Endorsement__c endorse302= TestDataFactory.createEndorsement('','descriptive','IL 302 AMENDMENT OF EXTENDED REPORTING PERIOD OPTIONS ENDORSEMENT');
        insert endorse302;
        
        Endorsement_Version__c endorseVersion3 = TestDataFactory.createEndorsementVersion(endorse302.Id);
        endorseVersion3.Endorsement_Version_Number__c='1';
        insert endorseVersion3;
        Test.stopTest();
        
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT');
        
        insert objPolEndorse;
        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT');
        poicyEndorse.Lawyer__c=junc.id;
        poicyEndorse.New_Limits__c=ilfCoverageLowest.Id;
        insert poicyEndorse;
        
        poicyEndorse.Effective_Date__c = date.today().addDays(4);
        poicyEndorse.Endorsement_Effective_Date__c =date.today().addDays(1);
        update poicyEndorse;
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
        
        // 17
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1101-Main Cash (CIBC)',
                AcctSeed__Active__c = true,
                AcctSeed__Bank__c = true,
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
            AcctSeed__Unapplied_Cash_GL_Account__c = glAccounts[15].Id,
            AcctSeed__AR_Control_GL_Account__c = glAccounts[2].Id,
            AcctSeed__Work_in_Process_GL_Account__c = glAccounts[3].Id,
            AcctSeed__AP_Control_GL_Account__c = glAccounts[4].Id,
            AcctSeed__Vouchers_Payable_GL_Account__c = glAccounts[5].Id,
            AcctSeed__Retained_Earnings_GL_Account__c = glAccounts[8].Id,
            AcctSeed__Current_Year_Earnings_GL_Account__c = glAccounts[9].Id,
            AcctSeed__Revenue_GL_Account__c = glAccounts[10].Id,
            AcctSeed__Inventory_Variance_GL_Account__c = glAccounts[13].Id,
            AcctSeed__Payment_Discount_GL_Account__c = glAccounts[14].Id
        );
        insert settings;
        
        AcctSeed__Payment_Processor__c payProcessor = new AcctSeed__Payment_Processor__c();
        payProcessor.Name = 'Fiserv';
        payProcessor.AcctSeed__Type__c = 'Fiserv';
        payProcessor.AcctSeed__Default_Ledger__c = ledger.Id;
        payProcessor.AcctSeed__Bank_GL_Account__c = glAccounts[0].Id;
        payProcessor.AcctSeed__Merchant_GL_Account__c = glAccounts[14].Id;
        payProcessor.AcctSeed__Merchant_Fees_GL_Account__c = glAccounts[12].Id;
        Insert payProcessor;
        
        // --- START HERE ---
        // Create BILLING RECORDS to post and unpost
        AcctSeed__Billing__c[] billings = new List <AcctSeed__Billing__c> ();
        
        billings.add(
            new AcctSeed__Billing__c(
                AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
                AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
                AcctSeed__Date__c = System.today(),
                AcctSeed__Customer__c = acc.id,
                AcctSeed__Status__c = 'Approved',
                AcctSeed__Due_Date2__c = System.today() + 30,
                AcctSeed__Ledger__c = ledger.Id,
                IsPaymentProcessed__c = false,
                AcctSeed__Billing_Format__c = PDFformats[0].Id,
                AcctSeed__Accounting_Period__c = [Select Id From AcctSeed__Accounting_Period__c limit 1].Id
            )
        );
        
        billings.add(
            new AcctSeed__Billing__c(
                AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
                AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
                AcctSeed__Date__c = System.today(),
                AcctSeed__Customer__c = acc.id,
                AcctSeed__Status__c = 'Approved',
                IsPaymentProcessed__c = true,
                AcctSeed__Due_Date2__c = System.today() + 30,
                AcctSeed__Ledger__c = ledger.Id,
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
            objBillingLine.AcctSeed__Revenue_GL_Account__c = glAccounts[1].id;
            bLines.add(objBillingLine);
            
            objBillingLine = new AcctSeed__Billing_Line__c();
            objBillingLine.AcctSeed__Billing__c = bill.id;
            objBillingLine.AcctSeed__Date__c = System.today();
            objBillingLine.AcctSeed__Rate__c = 25;
            objBillingLine.AcctSeed__Hours_Units__c = 2;
            objBillingLine.AcctSeed__Revenue_GL_Account__c = glAccounts[1].id;
            bLines.add(objBillingLine);
        }
        
        insert bLines;
        System.assertEquals(1, [Select count() FROM AcctSeed__Billing_Line__c WHERE Id = :bLines[0].Id LIMIT 1]);
        
        
        AcctSeed__Payment_Method__c MyAPM = new AcctSeed__Payment_Method__c();
        MyAPM.AcctSeed__Customer__c = acc.id;
        MyAPM.AcctSeed__Payment_Method_Type__c='Credit Card';
        MyAPM.AcctSeed__Type__c='Visa';
        MyAPM.AcctSeed__Expiration_Month__c='02';
        MyAPM.AcctSeed__Expiration_Year__c='2022';
        MyApm.AcctSeed__External_Id__c='test';
        MyAPM.AcctSeed__Last_Four_Digits__c='1234';
        insert MyAPM;
        
    }
    
    @isTest
    private static void testCallApexMethod() {
        // Test data setup
        List<Policy__c> policies = [SELECT Id,Account__c,Policy_Document_Version__c FROM Policy__c];
        Policy__c  pol = policies[1];
        ConvertToPolicyLtng objPolToLghtng  = new ConvertToPolicyLtng();
        
        ConvertToPolicyLtng.getPolicy(pol.id);
        String jsonBody = '{'+
            '   "callApex": "true",'+
            '   "className": "ConvertToPolicyLtng",'+
            '   "methodName":"convertPolicy",'+
            '   "arguments" : {'+
            '      "policyId":"'+pol.id+'",'+
            '      "policyDocVersion":"'+pol.Policy_Document_Version__c+'"'+
            '   }'+
            '}';
        system.debug('jsonBody => '+jsonBody);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestBody =blob.valueOf(jsonBody);
        req.addHeader('Content-Type', 'application/json');
        
        RestContext.request = req;
        RestContext.response = res;
        // Actual test
        Test.startTest();
        PaymentRestApi.callMethods();
        Test.stopTest();
        
        // Asserts
    }
    
    @isTest
    private static void testTtaskCreationLogic() {
        // Test data setup
        List<Policy__c> policies = [SELECT Id,Account__c,Policy_Document_Version__c FROM Policy__c];
        Policy__c  pol = policies[1];
        AcctSeed__Billing__c billing  = [SELECT Id FROM AcctSeed__Billing__c LIMIT 1];
        ConvertToPolicyLtng objPolToLghtng  = new ConvertToPolicyLtng();
        List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>();
        Payment_Schedule__c pSch1 = new Payment_Schedule__c();
        pSch1.Due_Date__c = system.today();
        pSch1.Billing__c = billing.id;
        pSch1.Amount__c =  75;
        pSch1.Status__c = 'Unpaid';//pSch1.Status__c = 'Paid';
        pSch1.Frequency__c = 'Month';
        paymentSchedules.add(pSch1);
        Insert paymentSchedules;
        
        ConvertToPolicyLtng.getPolicy(pol.id);
        PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj = new PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper();
        String jsonBody = '{"warpperObj" :'+JSON.serialize(warpperObj)+', "PaymtSchId" : "'+paymentSchedules[0].Id+'" ,"UtilTranId" : {"UtilTranId" : "testTransactionId"},"Billing" :{"Id": '+JSON.serialize(billing.id) +'},"paymentQuartersDt" : {"paymentQuartersDt" : null},"baseAmountToPay" : {"baseAmountToPay" : "75"},"paymentMonthsDt" : {"paymentMonthsDt" : null},"totalAmountDue" : {"totalAmountDue" : "75"},"receiptNumber" : {"receiptNumber" : "'+warpperObj.receiptNumber+'"},"firstInstallment" : {"firstInstallment" : "75"},"firstInstallmentDate" : {"firstInstallmentDate" : "'+warpperObj.firstInstallmentDate+'"}}';
        system.debug('jsonBody => '+jsonBody);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestBody =blob.valueOf(jsonBody);
        req.addHeader('Content-Type', 'application/json');
        
        RestContext.request = req;
        RestContext.response = res;
        // Actual test
        Test.startTest();
        PaymentRestApi.callMethods();
        Test.stopTest();
        
        // Asserts
        
    }
    @isTest
    private static void testTtaskCreationLogicOldCreditCardFull() {
        // Test data setup
        List<Policy__c> policies = [SELECT Id,Account__c,Policy_Document_Version__c FROM Policy__c];
        Policy__c  pol = policies[1];
        AcctSeed__Billing__c billing  = [SELECT Id FROM AcctSeed__Billing__c LIMIT 1];
        ConvertToPolicyLtng objPolToLghtng  = new ConvertToPolicyLtng();
        List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>();
        Payment_Schedule__c pSch1 = new Payment_Schedule__c();
        pSch1.Due_Date__c = system.today();
        pSch1.Billing__c = billing.id;
        pSch1.Amount__c =  75;
        pSch1.Status__c = 'Unpaid';//pSch1.Status__c = 'Paid';
        pSch1.Frequency__c = 'Month';
        paymentSchedules.add(pSch1);
        Insert paymentSchedules;
        
        ConvertToPolicyLtng.getPolicy(pol.id);
        PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj = new PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper();
        warpperObj.expireMonth = '2';
        warpperObj.expireYear = String.valueOf(system.today().addYears(1).year());
        warpperObj.cardNumber = '4242424242424242';
        warpperObj.cardTypeVar = 'VISA';
        warpperObj.verificationNumber = '121';
        warpperObj.nameOnCard = 'test test';
        warpperObj.paymentScheduleVar = 'Full';
        
        String jsonBody = '{"warpperObj" :'+JSON.serialize(warpperObj)+' ,"UtilTranId" : {"UtilTranId" : "testTransactionId"},"Billing" :{"Id": '+JSON.serialize(billing.id) +'},"paymentQuartersDt" : {"paymentQuartersDt" : null},"baseAmountToPay" : {"baseAmountToPay" : "75"},"paymentMonthsDt" : {"paymentMonthsDt" : null},"totalAmountDue" : {"totalAmountDue" : "75"},"receiptNumber" : {"receiptNumber" : "'+warpperObj.receiptNumber+'"},"firstInstallment" : {"firstInstallment" : "75"},"firstInstallmentDate" : {"firstInstallmentDate" : "'+warpperObj.firstInstallmentDate+'"}}';
        system.debug('jsonBody => '+jsonBody);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestBody =blob.valueOf(jsonBody);
        req.addHeader('Content-Type', 'application/json');
        
        RestContext.request = req;
        RestContext.response = res;
        // Actual test
        Test.startTest();
        PaymentRestApi.callMethods();
        Test.stopTest();
        
        // Asserts
        
    }
    @isTest
    private static void testTtaskCreationLogicOldCreditCardMonth() {
        // Test data setup
        List<Policy__c> policies = [SELECT Id,Account__c,Policy_Document_Version__c FROM Policy__c];
        Policy__c  pol = policies[1];
        AcctSeed__Billing__c billing  = [SELECT Id FROM AcctSeed__Billing__c LIMIT 1];
        ConvertToPolicyLtng objPolToLghtng  = new ConvertToPolicyLtng();
        List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>();
        Payment_Schedule__c pSch1 = new Payment_Schedule__c();
        pSch1.Due_Date__c = system.today();
        pSch1.Billing__c = billing.id;
        pSch1.Amount__c =  75;
        pSch1.Status__c = 'Unpaid';//pSch1.Status__c = 'Paid';
        pSch1.Frequency__c = 'Month';
        paymentSchedules.add(pSch1);
        Insert paymentSchedules;
        
        ConvertToPolicyLtng.getPolicy(pol.id);
        PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj = new PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper();
        warpperObj.expireMonth = '2';
        warpperObj.expireYear = String.valueOf(system.today().addYears(1).year());
        warpperObj.cardNumber = '4242424242424242';
        warpperObj.cardTypeVar = 'VISA';
        warpperObj.verificationNumber = '121';
        warpperObj.nameOnCard = 'test test';
        warpperObj.paymentScheduleVar = 'Month';
        
        String jsonBody = '{"warpperObj" :'+JSON.serialize(warpperObj)+' ,"UtilTranId" : {"UtilTranId" : "testTransactionId"},"Billing" :{"Id": '+JSON.serialize(billing.id) +'},"paymentQuartersDt" : {"paymentQuartersDt" : null},"baseAmountToPay" : {"baseAmountToPay" : "75"},"paymentMonthsDt" : {"paymentMonthsDt" : "'+system.today().addMonths(1)+'"},"totalAmountDue" : {"totalAmountDue" : "75"},"receiptNumber" : {"receiptNumber" : "'+warpperObj.receiptNumber+'"},"firstInstallment" : {"firstInstallment" : "75"},"firstInstallmentDate" : {"firstInstallmentDate" : "'+warpperObj.firstInstallmentDate+'"}}';
        system.debug('jsonBody => '+jsonBody);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestBody =blob.valueOf(jsonBody);
        req.addHeader('Content-Type', 'application/json');
        
        RestContext.request = req;
        RestContext.response = res;
        // Actual test
        Test.startTest();
        PaymentRestApi.callMethods();
        Test.stopTest();
        
        // Asserts
        
    }
    @isTest
    private static void testTtaskCreationLogicOldCreditCardQuarter() {
        // Test data setup
        List<Policy__c> policies = [SELECT Id,Account__c,Policy_Document_Version__c FROM Policy__c];
        Policy__c  pol = policies[1];
        AcctSeed__Billing__c billing  = [SELECT Id FROM AcctSeed__Billing__c LIMIT 1];
        ConvertToPolicyLtng objPolToLghtng  = new ConvertToPolicyLtng();
        List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>();
        Payment_Schedule__c pSch1 = new Payment_Schedule__c();
        pSch1.Due_Date__c = system.today();
        pSch1.Billing__c = billing.id;
        pSch1.Amount__c =  75;
        pSch1.Status__c = 'Unpaid';//pSch1.Status__c = 'Paid';
        pSch1.Frequency__c = 'Quarter';
        paymentSchedules.add(pSch1);
        Insert paymentSchedules;
        
        ConvertToPolicyLtng.getPolicy(pol.id);
        PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj = new PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper();
        warpperObj.expireMonth = '2';
        warpperObj.expireYear = String.valueOf(system.today().addYears(1).year());
        warpperObj.cardNumber = '4242424242424242';
        warpperObj.cardTypeVar = 'VISA';
        warpperObj.verificationNumber = '121';
        warpperObj.nameOnCard = 'test test';
        warpperObj.paymentScheduleVar = 'Quarter';
        
        String jsonBody = '{"warpperObj" :'+JSON.serialize(warpperObj)+' ,"UtilTranId" : {"UtilTranId" : "testTransactionId"},"Billing" :{"Id": '+JSON.serialize(billing.id) +'},"paymentQuartersDt" : {"paymentQuartersDt" : "'+system.today().addMonths(3)+'"},"baseAmountToPay" : {"baseAmountToPay" : "75"},"paymentMonthsDt" : {"paymentMonthsDt" : null},"totalAmountDue" : {"totalAmountDue" : "75"},"receiptNumber" : {"receiptNumber" : "'+warpperObj.receiptNumber+'"},"firstInstallment" : {"firstInstallment" : "75"},"firstInstallmentDate" : {"firstInstallmentDate" : "'+warpperObj.firstInstallmentDate+'"}}';
        system.debug('jsonBody => '+jsonBody);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestBody =blob.valueOf(jsonBody);
        req.addHeader('Content-Type', 'application/json');
        
        RestContext.request = req;
        RestContext.response = res;
        // Actual test
        Test.startTest();
        PaymentRestApi.callMethods();
        Test.stopTest();
        
        // Asserts
        
    }
    @isTest
    private static void testTtaskCreationLogicOldCheckFull() {
        // Test data setup
        List<Policy__c> policies = [SELECT Id,Account__c,Policy_Document_Version__c FROM Policy__c];
        Policy__c  pol = policies[1];
        AcctSeed__Billing__c billing  = [SELECT Id FROM AcctSeed__Billing__c LIMIT 1];
        ConvertToPolicyLtng objPolToLghtng  = new ConvertToPolicyLtng();
        List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>();
        Payment_Schedule__c pSch1 = new Payment_Schedule__c();
        pSch1.Due_Date__c = system.today();
        pSch1.Billing__c = billing.id;
        pSch1.Amount__c =  75;
        pSch1.Status__c = 'Unpaid';//pSch1.Status__c = 'Paid';
        pSch1.Frequency__c = 'Month';
        paymentSchedules.add(pSch1);
        Insert paymentSchedules;
        
        ConvertToPolicyLtng.getPolicy(pol.id);
        PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj = new PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper();
        warpperObj.paymentTypeVar = 'check';
        warpperObj.accountNumber = '1111111111111111';
        warpperObj.accountHolderName = 'test';
        warpperObj.accountType = 'Checking';
        warpperObj.routingNumber = '021000021';
        warpperObj.paymentScheduleVar = 'Full';
        
        String jsonBody = '{"warpperObj" :'+JSON.serialize(warpperObj)+' ,"UtilTranId" : {"UtilTranId" : "testTransactionId"},"Billing" :{"Id": '+JSON.serialize(billing.id) +'},"paymentQuartersDt" : {"paymentQuartersDt" : null},"baseAmountToPay" : {"baseAmountToPay" : "75"},"paymentMonthsDt" : {"paymentMonthsDt" : null},"totalAmountDue" : {"totalAmountDue" : "75"},"receiptNumber" : {"receiptNumber" : "'+warpperObj.receiptNumber+'"},"firstInstallment" : {"firstInstallment" : "75"},"firstInstallmentDate" : {"firstInstallmentDate" : "'+warpperObj.firstInstallmentDate+'"}}';
        system.debug('jsonBody => '+jsonBody);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestBody =blob.valueOf(jsonBody);
        req.addHeader('Content-Type', 'application/json');
        
        RestContext.request = req;
        RestContext.response = res;
        // Actual test
        Test.startTest();
        PaymentRestApi.callMethods();
        Test.stopTest();
        
        // Asserts
        
    }
    @isTest
    private static void testTtaskCreationLogicOldCheckMonth() {
        // Test data setup
        List<Policy__c> policies = [SELECT Id,Account__c,Policy_Document_Version__c FROM Policy__c];
        Policy__c  pol = policies[1];
        AcctSeed__Billing__c billing  = [SELECT Id FROM AcctSeed__Billing__c LIMIT 1];
        ConvertToPolicyLtng objPolToLghtng  = new ConvertToPolicyLtng();
        List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>();
        Payment_Schedule__c pSch1 = new Payment_Schedule__c();
        pSch1.Due_Date__c = system.today();
        pSch1.Billing__c = billing.id;
        pSch1.Amount__c =  75;
        pSch1.Status__c = 'Unpaid';//pSch1.Status__c = 'Paid';
        pSch1.Frequency__c = 'Month';
        paymentSchedules.add(pSch1);
        Insert paymentSchedules;
        
        ConvertToPolicyLtng.getPolicy(pol.id);
        PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj = new PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper();
        warpperObj.paymentTypeVar = 'check';
        warpperObj.accountNumber = '1111111111111111';
        warpperObj.accountHolderName = 'test';
        warpperObj.accountType = 'Checking';
        warpperObj.routingNumber = '021000021';
        warpperObj.paymentScheduleVar = 'Month';
        
        String jsonBody = '{"warpperObj" :'+JSON.serialize(warpperObj)+' ,"UtilTranId" : {"UtilTranId" : "testTransactionId"},"Billing" :{"Id": '+JSON.serialize(billing.id) +'},"paymentQuartersDt" : {"paymentQuartersDt" : null},"baseAmountToPay" : {"baseAmountToPay" : "75"},"paymentMonthsDt" : {"paymentMonthsDt" : "'+system.today().addMonths(1)+'"},"totalAmountDue" : {"totalAmountDue" : "75"},"receiptNumber" : {"receiptNumber" : "'+warpperObj.receiptNumber+'"},"firstInstallment" : {"firstInstallment" : "75"},"firstInstallmentDate" : {"firstInstallmentDate" : "'+warpperObj.firstInstallmentDate+'"}}';
        system.debug('jsonBody => '+jsonBody);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestBody =blob.valueOf(jsonBody);
        req.addHeader('Content-Type', 'application/json');
        
        RestContext.request = req;
        RestContext.response = res;
        // Actual test
        Test.startTest();
        PaymentRestApi.callMethods();
        Test.stopTest();
        
        // Asserts
        
    }
    @isTest
    private static void testTtaskCreationLogicOldCheckQuarter() {
        // Test data setup
        List<Policy__c> policies = [SELECT Id,Account__c,Policy_Document_Version__c FROM Policy__c];
        Policy__c  pol = policies[1];
        AcctSeed__Billing__c billing  = [SELECT Id FROM AcctSeed__Billing__c LIMIT 1];
        ConvertToPolicyLtng objPolToLghtng  = new ConvertToPolicyLtng();
        List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>();
        Payment_Schedule__c pSch1 = new Payment_Schedule__c();
        pSch1.Due_Date__c = system.today();
        pSch1.Billing__c = billing.id;
        pSch1.Amount__c =  75;
        pSch1.Status__c = 'Unpaid';//pSch1.Status__c = 'Paid';
        pSch1.Frequency__c = 'Quarter';
        paymentSchedules.add(pSch1);
        Insert paymentSchedules;
        
        ConvertToPolicyLtng.getPolicy(pol.id);
        PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj = new PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper();
        warpperObj.paymentTypeVar = 'check';
        warpperObj.accountNumber = '1111111111111111';
        warpperObj.accountHolderName = 'test';
        warpperObj.accountType = 'Checking';
        warpperObj.routingNumber = '021000021';
        warpperObj.paymentScheduleVar = 'Quarter';
        
        String jsonBody = '{"warpperObj" :'+JSON.serialize(warpperObj)+' ,"UtilTranId" : {"UtilTranId" : "testTransactionId"},"Billing" :{"Id": '+JSON.serialize(billing.id) +'},"paymentQuartersDt" : {"paymentQuartersDt" : "'+system.today().addMonths(3)+'"},"baseAmountToPay" : {"baseAmountToPay" : "75"},"paymentMonthsDt" : {"paymentMonthsDt" : null},"totalAmountDue" : {"totalAmountDue" : "75"},"receiptNumber" : {"receiptNumber" : "'+warpperObj.receiptNumber+'"},"firstInstallment" : {"firstInstallment" : "75"},"firstInstallmentDate" : {"firstInstallmentDate" : "'+warpperObj.firstInstallmentDate+'"}}';
        system.debug('jsonBody => '+jsonBody);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestBody =blob.valueOf(jsonBody);
        req.addHeader('Content-Type', 'application/json');
        
        RestContext.request = req;
        RestContext.response = res;
        // Actual test
        Test.startTest();
        PaymentRestApi.callMethods();
        Test.stopTest();
        
        // Asserts
        
    }
}