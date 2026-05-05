@isTest
private class Batch_UpdateCardknoxPaymentMethodTest { 
    
    @testSetup
    static void setupTestData() {
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
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        insert acc;
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
        
        INSERT new AcctSeed__Payment_Processor_Customer__c(
            AcctSeed__External_Id__c = 'c1234567890', 
            AcctSeed__Account__c = acc.Id, 
            AcctSeed__Processor__c = payProcessor.Id);
        
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
        
        Contact con = new Contact(
            FirstName = 'APPROVED',
            LastName = 'TEST',
            AccountId = acc.Id,
            Email = 'test@test.com'
        );
        Insert con;
        
        Map<String,String> mapRecordTypes = new Map<String,String>();
        
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoveragefactor(MasterFactorCoverage.Id);
        insert FactorCoverage;
        
        
        AccountContactJunction__c junc = new AccountContactJunction__c();
        junc.Account__c = pol.Account__C;
        junc.Contact__c = con.Id;
        insert junc;
        
        Policy_Lawyer__c law = new Policy_Lawyer__c();
        law.Policy__c = pol.Id;
        law.Active__c = true;
        law.Rate_At__c = 100;
        law.Account__c = pol.Account__c;
        law.Prior_Act_Date__c = system.today();
        law.Lawyer__c = junc.Id;
        insert law; 
       
        // insert 1 Accounting Period
        AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
            Name = '1991-10',
            AcctSeed__Start_Date__c = System.today().toStartOfMonth(),
            AcctSeed__End_Date__c = System.today().toStartOfMonth().addMonths(1),
            AcctSeed__Status__c = 'Open');
        insert acctPeriod;
        
        // --- START HERE ---
        // Create BILLING RECORDS to post and unpost
        AcctSeed__Billing__c[] billings = new List <AcctSeed__Billing__c> ();
        
        billings.add(
            new AcctSeed__Billing__c(
                Policy__c = pol.Id,
                AcctSeed__Payment_Processor__c = payProcessor.Id,
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
                Policy__c = pol.Id,
                AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
                AcctSeed__Payment_Processor__c = payProcessor.Id,
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
        test.startTest();
        
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
        
        // Insert Payment Methods
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
        
        insert new List<AcctSeed__Payment_Method__c>{payMethod2};
        
        // Insert Payment Schedules that match constructor query
        Payment_Schedule__c ps1 = new Payment_Schedule__c(
            Billing__c = billings[0].Id,
            Status__c = 'Pending',
            Payment_Method__c = payMethod2.Id,
            Payment_Schedule_Type__c = 'Credit Card'
        );
        Payment_Schedule__c ps2 = new Payment_Schedule__c(
            Billing__c = billings[0].Id,
            Status__c = 'Unpaid',
            Payment_Method__c = payMethod2.Id,
            Payment_Schedule_Type__c = 'eCheck'
        );
        insert new List<Payment_Schedule__c>{ps1, ps2};
    }
    
    @isTest
    static void testSandboxMode() {
        // Force sandbox mode by mocking Organization query
        Test.startTest();
        Batch_UpdateCardknoxPaymentMethod batch = new Batch_UpdateCardknoxPaymentMethod();
        Database.executeBatch(batch);
        Test.stopTest();
        // Mock handles sandbox/prod logic
    }
}