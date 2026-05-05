@isTest
private class CM_AutoPayment_Batch_Test {

    @testSetup
    private static void testSetup() {
        
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
        
        // Test data setup
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;

        AcctSeed__Payment_Method__c payMethod = new AcctSeed__Payment_Method__c();
        payMethod.AcctSeed__External_Id__c = 'paymethod_token';
        payMethod.AcctSeed__Customer__c = acc.Id;
        payMethod.AcctSeed__Payment_Method_Type__c = 'Credit Card';
        payMethod.Name_On_Card__c ='name_on_card';
        payMethod.AcctSeed__Account_Number__c = '4xxxxxxxxxxx1111';
        payMethod.AcctSeed__Last_Four_Digits__c  ='1111';
        payMethod.AcctSeed__Expiration_Month__c = String.valueOf(02);
        payMethod.AcctSeed__Expiration_Year__c = String.valueOf(system.today().addYears(5).year());
        payMethod.AcctSeed__Type__c = 'AMEX';
        Insert payMethod;
        
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
        Contact con = new Contact(
            FirstName = 'APPROVED',
            LastName = 'TEST',
            AccountId = acc.Id
        );
        Insert con;
         
        AcctSeed__Payment_Processor__c payProcessor = new AcctSeed__Payment_Processor__c();
        payProcessor.Name = 'Cardknox';
        payProcessor.AcctSeed__Type__c = 'Cardknox';
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
                Billing_Confirmation_Email__c = 'test@test.com',
                AcctSeed__Customer__c = acc.id,
                AcctSeed__Payment_Processor__c = payProcessor.id,
                AcctSeed__Status__c = 'Approved',
                AcctSeed__Due_Date2__c = System.today() + 30,
                AcctSeed__Ledger__c = ledger.Id,
                IsPaymentProcessed__c = false,
                AcctSeed__Billing_Format__c = PDFformats[0].Id,
                AcctSeed__Billing_Contact__c  = con.Id,
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
            objBillingLine.AcctSeed__Hours_Units__c = 2;
            objBillingLine.AcctSeed__Revenue_GL_Account__c = glAccounts[1].id;
            bLines.add(objBillingLine);
            
            objBillingLine = new AcctSeed__Billing_Line__c();
            objBillingLine.AcctSeed__Billing__c = bill.id;
            objBillingLine.AcctSeed__Date__c = System.today();
            objBillingLine.AcctSeed__Rate__c = 25;
            objBillingLine.AcctSeed__Hours_Units__c = 4;
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

        List<Payment_Schedule__c> Schedules = new List<Payment_Schedule__c>();
        Payment_Schedule__c pSch1 = new Payment_Schedule__c();
        pSch1.Due_Date__c = system.today();
        pSch1.Billing__c = billings[0].id;
        pSch1.Payment_Method__c = payMethod.Id;
        pSch1.Amount__c =  75;
        pSch1.Status__c = 'Unpaid';//pSch1.Status__c = 'Paid';
        pSch1.Frequency__c = 'Month';        
        Schedules.add(pSch1);
        
        Payment_Schedule__c pSch = new Payment_Schedule__c();
        pSch.Due_Date__c = system.today().addMonths(1);
        pSch.Billing__c = billings[0].id;
        pSch.Payment_Method__c = payMethod.Id;
        pSch.Amount__c =  75;
        pSch.Status__c = 'Unpaid';//pSch1.Status__c = 'Paid';
        pSch.Frequency__c = 'Month';        
        Schedules.add(pSch);
        Insert Schedules;
    }

    @IsTest
    static void testPaymentFailNew(){
        Payment_Schedule__c pSch = [SELECT Id,Amount__c FROM Payment_Schedule__c WHERE Due_Date__c = TODAY LIMIT 1];
        pSch.Amount__c += 1000;
        Update pSch;
        
        Test.startTest();        
        CM_AutoPayment_Batch b = new CM_AutoPayment_Batch();
        Database.executeBatch(b);
        Test.stopTest();
        
    }
    
    @isTest
    private static void testPaymentSuccess() {
        // Actual test
        Test.startTest();
        CM_AutoPayment_Batch b = new CM_AutoPayment_Batch();
        Database.executeBatch(b);
        Test.stopTest();

        // Asserts
    }
    @IsTest
    static void testPaymentFail(){
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        con.FirstName = 'Rejected';
        update con;

        Test.startTest();        
        CM_AutoPayment_Batch b = new CM_AutoPayment_Batch();
        Database.executeBatch(b);
        Test.stopTest();
        
    }
    
   

}