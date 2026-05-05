@isTest
private class PaymentGateway_Ctrl_Test {
    
    
    @testSetup 
    static void testData(){
        
        // —— DATA PREPARATION ——
        List<Account> accList = new List<Account>();
        
        // 0
        accList.add(
            new Account(
                Name = 'Dummy Billing Account'
            )
        );
        
        // 0
        accList.add(
            new Account(
                Name = 'Test'
            )
        );
        insert accList;
        
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
        
        // --- START HERE ---
        // Create BILLING RECORDS to post and unpost
        AcctSeed__Billing__c[] billings = new List <AcctSeed__Billing__c> ();
        
        billings.add(
            new AcctSeed__Billing__c(
                AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
                AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
                AcctSeed__Date__c = System.today(),
                AcctSeed__Customer__c = accList[0].id,
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
                AcctSeed__Customer__c = accList[1].id,
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
        MyAPM.AcctSeed__Customer__c = accList[0].id;
        MyAPM.AcctSeed__Payment_Method_Type__c='Credit Card';
        MyAPM.AcctSeed__Type__c='Visa';
        MyAPM.AcctSeed__Expiration_Month__c='02';
        MyAPM.AcctSeed__Expiration_Year__c='2022';
        MyApm.AcctSeed__External_Id__c='test';
        MyAPM.AcctSeed__Last_Four_Digits__c='1234';
        insert MyAPM;
        
        
        
    }
    
  /*  @isTest 
    static void nextFunction_Test(){
        
        Test.startTest();
        List<AcctSeed__Billing__c> billingList = [SELECT Id, Allow_CatchUp_Schedule__c  FROM AcctSeed__Billing__c Limit 1];
        PaymentGateway_Ctrl ctrl = new PaymentGateway_Ctrl();
        ctrl.billing = billingList[0];
        ctrl.totalAmountDue = null;
        ctrl.currentStage = 'schedule';
        ctrl.nextFunction();
        
         PaymentGateway_Ctrl ctrl1 = new PaymentGateway_Ctrl();
        ctrl1.billing = billingList[0];
        ctrl1.totalAmountDue = null;
        ctrl1.currentStage = 'payment';
        ctrl1.warpperObj.paymentScheduleVar = 'Full';
        ctrl1.nextFunction();
        Test.stopTest();
        
    }*/
    
    @isTest 
    static void nextFunction_Test_1(){
        
        Test.startTest();
        
        PaymentGateway_Ctrl ctrl = new PaymentGateway_Ctrl();
        ctrl.totalAmountDue = null;
        ctrl.currentStage = 'schedule';
        
        
        ctrl.lasttime = 'Test';
        ctrl.nextFunction();
        ctrl.paymentInvalidDateError = 'test';
        ctrl.paymentInvalidDate = false;
        Test.stopTest();
        
    }
    
    @isTest 
    static void paymentScheduleFunction_Test(){
        
        Test.startTest();
        List<AcctSeed__Billing__c> billingList = [SELECT Id,AcctSeed__Balance__c,AcctSeed__Due_Date2__c, Allow_CatchUp_Schedule__c,AcctSeed__Customer__c  FROM AcctSeed__Billing__c Limit 1];
        PaymentGateway_Ctrl ctrl = new PaymentGateway_Ctrl();
        ctrl.billing = billingList[0];
        ctrl.warpperObj.paymentScheduleVar = 'Month';
        ctrl.warpperObj.effectiveDate = System.today();
        ctrl.paymentScheduleFunction();
        List<SelectOption> lst = ctrl.ExistingList;
        Test.stopTest();
        
    }
    
    @isTest 
    static void paymentScheduleFunction_Test_1(){
        
        Test.startTest();
        List<AcctSeed__Billing__c> billingList = [SELECT Id,AcctSeed__Balance__c,AcctSeed__Due_Date2__c, Allow_CatchUp_Schedule__c  FROM AcctSeed__Billing__c Limit 1];
        PaymentGateway_Ctrl ctrl = new PaymentGateway_Ctrl();
        ctrl.billing = billingList[0];
        ctrl.warpperObj.paymentScheduleVar = 'Quarter';
        ctrl.warpperObj.effectiveDate = System.today();
        ctrl.paymentScheduleFunction();
        Test.stopTest();
        
    }
    
    @isTest 
    static void processPayment_Test(){
        
        Test.startTest();
        List<AcctSeed__Billing__c> billingList = [SELECT Id,AcctSeed__Balance__c,AcctSeed__Due_Date2__c, Allow_CatchUp_Schedule__c  FROM AcctSeed__Billing__c Limit 1];
        PaymentGateway_Ctrl ctrl = new PaymentGateway_Ctrl();
        ctrl.billing = billingList[0];
        ctrl.processPayment();
        Test.stopTest();
        
    }
    
    @isTest
    static void voidTestMethod(){
        
        PaymentGateway_Ctrl ctrl = new PaymentGateway_Ctrl();
        ctrl.getCHECK_TRANSACTION_FEE();
        ctrl.getCREDIT_CARD_SERVICE_FEE_American_Express();
        ctrl.getCREDIT_CARD_SERVICE_FEE_Discovery();
        ctrl.getCREDIT_CARD_SERVICE_FEE_MasterCard();
        ctrl.getCREDIT_CARD_SERVICE_FEE_VISA();
        ctrl.getExpireMonthsList();
        ctrl.getExpireYearsList();
    }
    
    @isTest
    static void cardTypeFunction(){
        
        List<AcctSeed__Billing__c> billingList = [SELECT Id,AcctSeed__Balance__c,AcctSeed__Due_Date2__c, Allow_CatchUp_Schedule__c  FROM AcctSeed__Billing__c Limit 1];
        PaymentGateway_Ctrl ctrl = new PaymentGateway_Ctrl();
        ctrl.warpperObj.cardTypeVar = 'amex';
        ctrl.cardTypeFunction();
        
        ctrl.warpperObj.cardTypeVar = 'disc';
        ctrl.cardTypeFunction();
        
        ctrl.warpperObj.cardTypeVar = 'mast';
        ctrl.cardTypeFunction();
        
        ctrl.warpperObj.cardTypeVar = 'visa';
        ctrl.cardTypeFunction();
        
        ctrl.billing = billingList[0];
        ctrl.warpperObj.paymentTypeVar = 'creditCard';
        ctrl.warpperObj.paymentScheduleVar = 'Full';
        ctrl.cardTypeFunction();
        
        ctrl.billing = billingList[0];
        ctrl.warpperObj.paymentTypeVar = 'creditCard';
        ctrl.warpperObj.paymentScheduleVar = 'Month';
        ctrl.cardTypeFunction();
        
        ctrl.billing = billingList[0];
        ctrl.warpperObj.paymentTypeVar = 'creditCard';
        ctrl.warpperObj.paymentScheduleVar = 'Quarter';
        ctrl.cardTypeFunction();
    }
    
    
    @isTest
    static void paymentTypeFunction(){
        
        List<AcctSeed__Billing__c> billingList = [SELECT Id,AcctSeed__Balance__c,AcctSeed__Due_Date2__c FROM AcctSeed__Billing__c Limit 1];
        PaymentGateway_Ctrl ctrl = new PaymentGateway_Ctrl();
        
        ctrl.billing = billingList[0];
        ctrl.warpperObj.paymentTypeVar = 'check';
        ctrl.warpperObj.paymentScheduleVar = 'Full';
        ctrl.paymentTypeFunction();
        
        ctrl.billing = billingList[0];
        ctrl.warpperObj.paymentTypeVar = 'check';
        ctrl.warpperObj.paymentScheduleVar = 'Month';
        ctrl.paymentTypeFunction();
        
        ctrl.billing = billingList[0];
        ctrl.warpperObj.paymentTypeVar = 'check';
        ctrl.warpperObj.paymentScheduleVar = 'Quarter';
        ctrl.paymentTypeFunction();
        
    }
    
    
    @isTest static void testPayment() {
        
        
        List<AcctSeed__Billing__c> billingList = [SELECT Id,AcctSeed__Balance__c,AcctSeed__Due_Date2__c,AcctSeed__Customer__c, Payment_Frequency__c  FROM AcctSeed__Billing__c Limit 1];
        Transaction_Credit_And_Debits__c customSetting = new Transaction_Credit_And_Debits__c();
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.TextAttachment inAtt = new Messaging.InboundEmail.TextAttachment();
        
        email.subject = 'test';
        env.fromAddress = 'test@test.com';
        
        // set the body of the attachment
        inAtt.body ='policyID,invoiceID,invoiceType,invoiceAmount,firmName,zipCode,issueDate,firmId,effectiveDate\n 12345,12346,bank,100.54,onetest,123456,'+System.today()+',12342,'+System.today()+',test,test,test,test';
        //inAtt.body = 'policyID,invoiceID,invoiceType,invoiceAmount,firmName,zipCode,issueDate,Message\n 12345,12346,bank,100.54,Banking,123456,'+System.today()+',onetest';
        inAtt.fileName = 'payment_gateway.csv';
        inAtt.mimeTypeSubType = 'plain/txt';
        
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] {inAtt }; 
            
            // call the class and test it with the data in the testMethod
            Email_Service_Handler emailServiceObj = new Email_Service_Handler();
        emailServiceObj.handleInboundEmail(email, env );
        
        
        PaymentGateway_Ctrl.processDecryption('test', 'key');
        PaymentGateway_Ctrl ctrl = new PaymentGateway_Ctrl();
        Test.startTest();
        ctrl.billing = billingList[0];
        ctrl.warpperObj.firstName='APPROVED';
        ctrl.warpperObj.expireMonth='12';
        ctrl.warpperObj.expireYear='2017';
        ctrl.warpperObj.cardNumber='1213';
        ctrl.warpperObj.policyInvoiceNumber='12346';
        ctrl.warpperObj.zipCode='123';
        ctrl.currentStage='schedule';
        ctrl.nextFunction();
        ctrl.currentStage='schedule';
        ctrl.warpperObj.zipCode='123456';
        ctrl.nextFunction();
        ctrl.warpperObj.paymentScheduleVar='Month';
        ctrl.warpperObj.paymentTypeVar='check';
        ctrl.paymentScheduleFunction();
        
        ctrl.warpperObj.paymentTypeVar='creditCard';
        ctrl.warpperObj.cardTypeVar='amex';
        ctrl.paymentScheduleFunction();
        
        ctrl.warpperObj.cardTypeVar='disc';
        ctrl.paymentScheduleFunction();
        
        ctrl.warpperObj.cardTypeVar='mast';
        ctrl.paymentScheduleFunction();
        
        ctrl.warpperObj.cardTypeVar='visa';
        ctrl.paymentScheduleFunction();
        
        ctrl.warpperObj.paymentScheduleVar='Quarter';
        ctrl.warpperObj.paymentTypeVar='check';
        ctrl.paymentScheduleFunction();
        
        ctrl.warpperObj.paymentTypeVar='creditCard';
        ctrl.warpperObj.cardTypeVar='amex';
        ctrl.paymentScheduleFunction();
        
        ctrl.warpperObj.cardTypeVar='disc';
        ctrl.paymentScheduleFunction();
        
        ctrl.warpperObj.cardTypeVar='mast';
        ctrl.paymentScheduleFunction();
        
        ctrl.warpperObj.cardTypeVar='visa';
        ctrl.paymentScheduleFunction();
        
        ctrl.warpperObj.paymentScheduleVar='Full';
        ctrl.warpperObj.paymentTypeVar='check';
        ctrl.paymentScheduleFunction();
        
        ctrl.warpperObj.paymentTypeVar='creditCard';
        ctrl.warpperObj.cardTypeVar='amex';
        ctrl.paymentScheduleFunction();
        
        ctrl.warpperObj.cardTypeVar='disc';
        ctrl.paymentScheduleFunction();
        
        ctrl.warpperObj.cardTypeVar='mast';
        ctrl.paymentScheduleFunction();
        
        ctrl.warpperObj.cardTypeVar='visa';
        ctrl.paymentScheduleFunction();
        
        ctrl.getCHECK_TRANSACTION_FEE();
        ctrl.getCREDIT_CARD_SERVICE_FEE_American_Express();
        ctrl.getCREDIT_CARD_SERVICE_FEE_Discovery();
        ctrl.getCREDIT_CARD_SERVICE_FEE_MasterCard();
        ctrl.getCREDIT_CARD_SERVICE_FEE_VISA();
        ctrl.getExpireMonthsList();
        ctrl.getExpireYearsList();
        ctrl.currentStage='processPayment';
        ctrl.nextFunction();
         ctrl.currentStage='payment';
         ctrl.nextFunction();
        //ctrl.processDecryption('test','test');
        ctrl.warpperObj.paymentScheduleVar='Full';
        ctrl.warpperObj.paymentTypeVar='check';
        ctrl.paymentScheduleFunction();
        Test.stopTest();
        /*
        ctrl.currentStage='processPayment';
        ctrl.nextFunction();
        
        
        ctrl.warpperObj.paymentScheduleVar='Month';
        ctrl.warpperObj.paymentTypeVar='creditCard';
        ctrl.paymentScheduleFunction();
        
        ctrl.currentStage='processPayment';
        ctrl.nextFunction();
        
        ctrl.warpperObj.paymentScheduleVar='Quarter';
        ctrl.warpperObj.paymentTypeVar='creditCard';
        ctrl.paymentScheduleFunction();
        
        ctrl.currentStage='processPayment';
        ctrl.nextFunction();
        
        ctrl.totalAmountDue = 200;
        ctrl.baseAmountToPay =45;
        ctrl.processPayment();*/
        
    }
    
     @isTest static void testPayment_2() {
          
         PaymentGateway_Ctrl ctrl = new PaymentGateway_Ctrl();
         try{
         ctrl.processPayment();
         }catch(exception e){
             system.debug(e.getMessage());
         }
         
     }
    
    @isTest static void testPayment_P() {
        
        
        List<AcctSeed__Billing__c> billingList = [SELECT Id,AcctSeed__Balance__c,AcctSeed__Due_Date2__c,AcctSeed__Customer__c, Allow_CatchUp_Schedule__c,Payment_Frequency__c  FROM AcctSeed__Billing__c Limit 1];
  
        Test.startTest();
        List<AcctSeed__Payment_Method__c> APMList = [select id from AcctSeed__Payment_Method__c];
       
        PaymentGateway_Ctrl.processDecryption('test', 'key');
     
        PaymentGateway_Ctrl ctrl = new PaymentGateway_Ctrl();
        ctrl.billing = billingList[0];
        ctrl.currentStage='contactDetails';
         ctrl.nextFunction();
        ctrl.SelectedMethod = 'test';
        ctrl.nextFunction();
        ctrl.SelectedMethod = APMList[0].Id;
        ctrl.nextFunction();
        ctrl.warpperObj.firstName='APPROVED';
        ctrl.warpperObj.expireMonth='12';
        ctrl.warpperObj.expireYear='2017';
        ctrl.warpperObj.cardNumber='1213';
        ctrl.warpperObj.policyInvoiceNumber='12346';
        ctrl.warpperObj.zipCode='123';
        ctrl.currentStage='schedule';
        ctrl.warpperObj.zipCode='123456';
        ctrl.nextFunction();
        ctrl.warpperObj.paymentScheduleVar='Month';
        ctrl.warpperObj.paymentTypeVar='check';
        ctrl.warpperObj.effectiveDate = System.today();
        ctrl.paymentScheduleFunction();
        
   
        Test.stopTest();
    }
}