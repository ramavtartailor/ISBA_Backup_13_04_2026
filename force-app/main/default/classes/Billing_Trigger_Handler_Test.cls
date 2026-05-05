@isTest
private class Billing_Trigger_Handler_Test {
    @isTest
    private static void testMethod1() {
        
        
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
                Name = '6430-Cardknox Convenience Fees',
                AcctSeed__Active__c = true,
                AcctSeed__Bank__c = false,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        
        insert glAccounts;
        
        //creating tax Setting's record 
        AcctSeed__AvaTax_License__c avaTax = new AcctSeed__AvaTax_License__c(
            Name = 'test',
            AcctSeed__AvaTax_License_Key__c = 'test',
            AcctSeed__AvaTax_Account_ID__c = 'test',
            AcctSeed__Active_AvaTax_Endpoint__c = 'Sandbox'
        );
        Insert avaTax;
        
        AcctSeed__Address__c address = new AcctSeed__Address__c(
            AcctSeed__Country_Code__c = 'US',
            AcctSeed__Postal_Code__c = '21045',
            AcctSeed__State_Province__c ='MD',
            AcctSeed__Street__c = '127 main Street',
            Name = 'test',
            AcctSeed__City__c ='Columbia'
        ); 
        Insert address;
        
        Product2 product = new Product2(
            Name = 'Acme Widget',
            ProductCode = 'ACM1234',
            Description = 'High-efficiency widget suitable for manufacturing needs.',
            IsActive = true,
            Family = 'Widgets',
            QuantityUnitOfMeasure = 'Each');
        insert product;
        AcctSeed__Tax_Settings__c txSet = new AcctSeed__Tax_Settings__c(
            Name = 'N AvaTax',
            AcctSeed__Tax_Settings_Method__c = 'AvaTax',
            AcctSeed__Sales_Tax_Calculation_Mode__c = 'Shipment',
            AcctSeed__Sales_Tax_GL_Account__c = glAccounts[0].Id,
            AcctSeed__AvaTax_License__c = avaTax.Id,
            AcctSeed__Sales_Tax_Product__c = product.Id,
            AcctSeed__Origin_Address__c= address.Id);
        Insert txSet;
        
        // insert 1 Ledger records
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(
            Name = 'Actual',
            AcctSeed__Type__c = 'Transactional',
            AcctSeed__Default_Bank_Account__c = glAccounts[0].id,
            AcctSeed__Default_Billing_Format__c = PDFformats[0].Id,
            AcctSeed__Billing_Outstanding_Statement_Format__c = PDFformats[2].Id,
            AcctSeed__Billing_Activity_Statement_Format__c = PDFformats[3].Id,
            AcctSeed__Default_Purchase_Order_Format__c = PDFformats[4].Id,
            AcctSeed__Default_Packing_Slip_Format__c = PDFformats[5].Id,
            AcctSeed__Tax_Settings__c = txSet.Id,
            AcctSeed__Sales_Tax_Company_Code__c = 'US');
        
        insert ledger;
        
        AcctSeed__Payment_Processor__c payProcessor = new AcctSeed__Payment_Processor__c();
        payProcessor.Name = 'Fiserv';
        payProcessor.AcctSeed__Type__c = 'Fiserv';
        payProcessor.AcctSeed__Default_Ledger__c = ledger.Id;
        payProcessor.AcctSeed__Bank_GL_Account__c = glAccounts[0].Id;
        payProcessor.AcctSeed__Merchant_GL_Account__c = glAccounts[14].Id;
        payProcessor.AcctSeed__Merchant_Fees_GL_Account__c = glAccounts[12].Id;
        Insert payProcessor;
        
        
        
        Payment_Method__c payMethod = new Payment_Method__c(
            
            Account__c = acc.Id,
            Payment_Processor__c = payProcessor.Id,
            Type__c = 'Credit_Card',
            Card_Type__c = 'VISA',
            Last_4_Account_Number__c = '1234',
            Masked_Account_Number__c = 'xxxxxxxxxxxx1234',
            Expiry_Month__c = 12,
            Expiry_Year__c = 2030,
            Name_On_Card__c = 'Test User',
            Payment_Method_Token__c = 'tok_card',
            Default__c = true
        );
        insert payMethod;
        
        
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
        
        PaymentGatewayClass.policyBindWrapper bindWrapObj = new PaymentGatewayClass.policyBindWrapper();
        bindWrapObj.firstInstallment = 75; 
        bindWrapObj.paymentScheduleVar = 'Full'; 
        bindWrapObj.firstInstallmentDate = System.today(); 
        bindWrapObj.isPaymentReceived = true; 
        bindWrapObj.paymentTypeVar = 'creditCard'; 
        bindWrapObj.baseAmountToPay = 75; 
        bindWrapObj.defaultPaymentMethodId = payMethod.Id;
        bindWrapObj.transactionId = 'testTransactionId'; 
        PaymentGatewayClass.paymentSchedulesWrapper wrap = new PaymentGatewayClass.paymentSchedulesWrapper();
        wrap.amount = 19;
        wrap.dateStr = '05/01/2030';
        
        bindWrapObj.paymentSchedulesWrap =new List<PaymentGatewayClass.paymentSchedulesWrapper>{wrap};
            
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
        pol.Bind_Policy_JSON__c = JSON.serialize(bindWrapObj);
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
       
        
        
        
        
       
        
       
        
        
        
        // --- START HERE ---
        // Create BILLING RECORDS to post and unpost
        AcctSeed__Billing__c[] billings = new List <AcctSeed__Billing__c> ();
        
        billings.add(
            new AcctSeed__Billing__c(
                Policy__c = pol.Id,
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
         test.stopTest();
    }
    @isTest
    private static void testMethod2() {
       
        
        Account acc                   = TestDataFactory.createAccounts('Test Account 1');
        acc.AccountNumber             = '123400';
        acc.Vendor_Account__c         = true;
        insert acc;
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        opp.StageName                 = 'Application Sent';
        opp.CloseDate                 = Date.today();
        insert opp;
        
        
        /*AcctSeed__Payment_Method__c payMethod = new AcctSeed__Payment_Method__c();
payMethod.AcctSeed__External_Id__c = 'paymethod_token';
payMethod.AcctSeed__Customer__c = acc.Id;
payMethod.AcctSeed__Payment_Method_Type__c = 'Credit Card';
payMethod.Name_On_Card__c ='name_on_card';
payMethod.AcctSeed__Account_Number__c = '4xxxxxxxxxxx1111';
payMethod.AcctSeed__Last_Four_Digits__c  ='1111';
payMethod.AcctSeed__Expiration_Month__c = String.valueOf(02);
payMethod.AcctSeed__Expiration_Year__c = String.valueOf(system.today().addYears(5).year());
payMethod.AcctSeed__Type__c = 'VISA';
Insert payMethod;*/
        
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
                Name = '6430-Cardknox Convenience Fees',
                AcctSeed__Active__c = true,
                AcctSeed__Bank__c = false,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        
        insert glAccounts;
        
        //creating tax Setting's record 
        AcctSeed__AvaTax_License__c avaTax = new AcctSeed__AvaTax_License__c(
            Name = 'test',
            AcctSeed__AvaTax_License_Key__c = 'test',
            AcctSeed__AvaTax_Account_ID__c = 'test',
            AcctSeed__Active_AvaTax_Endpoint__c = 'Sandbox'
        );
        Insert avaTax;
        
        AcctSeed__Address__c address = new AcctSeed__Address__c(
            AcctSeed__Country_Code__c = 'US',
            AcctSeed__Postal_Code__c = '21045',
            AcctSeed__State_Province__c ='MD',
            AcctSeed__Street__c = '127 main Street',
            Name = 'test',
            AcctSeed__City__c ='Columbia'
        ); 
        Insert address;
        
        Product2 product = new Product2(
            Name = 'Acme Widget',
            ProductCode = 'ACM1234',
            Description = 'High-efficiency widget suitable for manufacturing needs.',
            IsActive = true,
            Family = 'Widgets',
            QuantityUnitOfMeasure = 'Each');
        insert product;
        
        AcctSeed__Tax_Settings__c txSet = new AcctSeed__Tax_Settings__c(
            Name = 'N AvaTax',
            AcctSeed__Tax_Settings_Method__c = 'AvaTax',
            AcctSeed__Sales_Tax_Calculation_Mode__c = 'Shipment',
            AcctSeed__Sales_Tax_GL_Account__c = glAccounts[0].Id,
            AcctSeed__Sales_Tax_Product__c = product.Id,
            AcctSeed__AvaTax_License__c = avaTax.Id,
            AcctSeed__Origin_Address__c= address.Id);
        Insert txSet;
        
        // insert 1 Ledger records
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(
            Name = 'Actual',
            AcctSeed__Type__c = 'Transactional',
            AcctSeed__Default_Bank_Account__c = glAccounts[0].id,
            AcctSeed__Default_Billing_Format__c = PDFformats[0].Id,
            AcctSeed__Billing_Outstanding_Statement_Format__c = PDFformats[2].Id,
            AcctSeed__Billing_Activity_Statement_Format__c = PDFformats[3].Id,
            AcctSeed__Default_Purchase_Order_Format__c = PDFformats[4].Id,
            AcctSeed__Default_Packing_Slip_Format__c = PDFformats[5].Id,
            AcctSeed__Tax_Settings__c = txSet.Id,
            AcctSeed__Sales_Tax_Company_Code__c = 'US');
        
        insert ledger;
        
        AcctSeed__Payment_Processor__c payProcessor = new AcctSeed__Payment_Processor__c();
        payProcessor.Name = 'Fiserv';
        payProcessor.AcctSeed__Type__c = 'Fiserv';
        payProcessor.AcctSeed__Default_Ledger__c = ledger.Id;
        payProcessor.AcctSeed__Bank_GL_Account__c = glAccounts[0].Id;
        payProcessor.AcctSeed__Merchant_GL_Account__c = glAccounts[14].Id;
        payProcessor.AcctSeed__Merchant_Fees_GL_Account__c = glAccounts[12].Id;
        Insert payProcessor;
        
        
        
        Payment_Method__c payMethod = new Payment_Method__c(
            
            Account__c = acc.Id,
            Payment_Processor__c = payProcessor.Id,
            Type__c = 'Credit_Card',
            Card_Type__c = 'VISA',
            Last_4_Account_Number__c = '1234',
            Masked_Account_Number__c = 'xxxxxxxxxxxx1234',
            Expiry_Month__c = 12,
            Expiry_Year__c = 2030,
            Name_On_Card__c = 'Test User',
            Payment_Method_Token__c = 'tok_card',
            Default__c = true
        );
        insert payMethod;
        
        
        
        
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
        
        PaymentGatewayClass.policyBindWrapper bindWrapObj = new PaymentGatewayClass.policyBindWrapper();
        bindWrapObj.firstInstallment = 75; 
        bindWrapObj.paymentScheduleVar = 'Full'; 
        bindWrapObj.firstInstallmentDate = System.today(); 
        bindWrapObj.isPaymentReceived = true; 
        bindWrapObj.paymentTypeVar = 'Physical_Check'; 
        bindWrapObj.baseAmountToPay = 75; 
        bindWrapObj.defaultPaymentMethodId = payMethod.Id;
        bindWrapObj.transactionId = 'testTransactionId'; 
        PaymentGatewayClass.paymentSchedulesWrapper wrap = new PaymentGatewayClass.paymentSchedulesWrapper();
        wrap.amount = 19;
        wrap.dateStr = '05/01/2030';
        
        bindWrapObj.paymentSchedulesWrap =new List<PaymentGatewayClass.paymentSchedulesWrapper>{wrap};
            
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
        pol.Bind_Policy_JSON__c = JSON.serialize(bindWrapObj);
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
        
         List<Endorsement__c> objEndorsementList = new List<Endorsement__c>();
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        objEndorsementList.add(endorse);
        Endorsement__c endorse1 = TestDataFactory.createEndorsement('IL 151','Functional','General');
        objEndorsementList.add(endorse1);
        Endorsement__c endorse2 = TestDataFactory.createEndorsement('IL 151A','Functional','General');
        objEndorsementList.add(endorse2);
        Endorsement__c endorse3 = TestDataFactory.createEndorsement('IL 152','Functional','General');
        objEndorsementList.add(endorse3);
        insert objEndorsementList;
        
        
        
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        Endorsement_Version__c endorseVersion1 = TestDataFactory.createEndorsementVersion(endorse1.Id);
        insert endorseVersion1;
        Endorsement_Version__c endorseVersion2 = TestDataFactory.createEndorsementVersion(endorse2.Id);
        insert endorseVersion2;
        Endorsement_Version__c endorseVersion3 = TestDataFactory.createEndorsementVersion(endorse3.Id);
        insert endorseVersion3;
        
        Attachment attach = new Attachment(Name='Test Attach', Body= Blob.valueOf('test'), ParentId=pol.Id);
        insert attach;
        
        List<Policy_Endorsement__c> lstPolicyEndorsements = new List<Policy_Endorsement__c>();
        
        Policy_Endorsement__c policyEnd = TestDataFactory.createPolicyEndorsement(acc.id,pol.Id,'General');
        policyEnd.Endorsement_Version__c = '6/24';
        policyEnd.Policy__c= pol.id;
        //policyEnd.Endorsement_Number__c= 'IL 152';
        policyEnd.Lawyer__c = junc.id;
        policyEnd.Event_Status__c = 'Pending';
        policyEnd.Policy_Lawyer__c = law.id;
        policyEnd.Refund_Amount__c = 10;
        policyEnd.New_Limits__c= FactorCoverage.id;
        policyEnd.Additional_Premium__c = 100;
        policyEnd.Coverage_Term__c='1 Year';
        //policyEnd.Approve_Endorsement_JSON__c = '{"transactionId":"Card","Timestamp":"2025-09-26T17:29:04.149Z","paymentTypeVar":"creditCard","paymentScheduleVar":"Monthly","paymentSchedulesWrap":[{"dateStr":"10/01/2025","amount":235},{"dateStr":"11/01/2025","amount":235},{"dateStr":"12/01/2025","amount":235}],"isPaymentReceived":true,"ISBAM_user_agent":"IP Address : 73.247.102.67Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 Edg/140.0.0.0","ipAddress":"73.247.102.67","firstInstallmentDate":"2025-09-26","firstInstallment":235,"defaultPaymentMethodId":"a4zEm000005KMkfIAG","billingConfirmationEmail":"kyle.hoker@isbamutual.com","baseAmountToPay":235,"application_link":"EXTERNAL"}';
        policyEnd.Endorsement_Number__c = 'IL 152';
        policyEnd.Approve_Endorsement_JSON__c =
            '{"transactionId":"Card","Timestamp":"2025-09-26T17:29:04.149Z","paymentTypeVar":"creditCard","paymentScheduleVar":"Monthly","paymentSchedulesWrap":[{"dateStr":"10/01/2025","amount":75},{"dateStr":"11/01/2025","amount":75},{"dateStr":"12/01/2025","amount":75}],"isPaymentReceived":true,"ISBAM_user_agent":"IP Address : 73.247.102.67Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36 Edg/140.0.0.0","ipAddress":"73.247.102.67","firstInstallmentDate":"2025-09-26","firstInstallment":75,"defaultPaymentMethodId":"' 
            + payMethod.Id + 
            '","billingConfirmationEmail":"kyle.hoker@isbamutual.com","baseAmountToPay":75,"application_link":"EXTERNAL"}';
        policyEnd.Premium__c=1;
        policyEnd.Premium_10_10__c=1;
        policyEnd.Premium_5_5__c=1;
        policyEnd.Primary__c=1;
        policyEnd.Excess__c=1;
        
        lstPolicyEndorsements.add(policyEnd);
        
        insert lstPolicyEndorsements;
        
        
        
        
        
        
        // --- START HERE ---
        // Create BILLING RECORDS to post and unpost
        AcctSeed__Billing__c[] billings = new List <AcctSeed__Billing__c> ();
        
        billings.add(
            new AcctSeed__Billing__c(
                Policy__c = pol.Id,
                AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
                AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
                AcctSeed__Date__c = System.today(),
                AcctSeed__Customer__c = acc.id,
                AcctSeed__Status__c = 'Approved',
                Policy_Endorsement__c = lstPolicyEndorsements[0].id,
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
                AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
                AcctSeed__Date__c = System.today(),
                AcctSeed__Customer__c = acc.id,
                AcctSeed__Status__c = 'Approved',
                IsPaymentProcessed__c = true,
                Policy_Endorsement__c = lstPolicyEndorsements[0].id,
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
         test.stopTest();
    }
}