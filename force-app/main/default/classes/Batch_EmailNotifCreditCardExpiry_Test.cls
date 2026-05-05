@isTest
private class Batch_EmailNotifCreditCardExpiry_Test {
	@isTest static void testBatchPaymentGateway(){
        Account acc                   = new Account();
        acc.Name                      = 'Dummy Billing Account';
        acc.AccountNumber             = '123456';
        acc.billingstreet = 'testStreet';
        acc.billingstate = 'testStreet';
        acc.billingCity = 'testStreet';
        acc.billingPostalCode = 'testStreet';
        acc.BillingCountry = 'testStreet';
        insert acc;
        
        List<AcctSeed__GL_Account__c> glAccountList = new List<AcctSeed__GL_Account__c>();
        
        glAccountList.add(new AcctSeed__GL_Account__c(Name='4000-Premium',AcctSeed__Active__c = true,AcctSeed__Type__c = 'Revenue',AcctSeed__Sub_Type_1__c='Service Revenue'));
        
        glAccountList.add(new AcctSeed__GL_Account__c(Name='1300-Accounts Receivable',AcctSeed__Active__c = true,AcctSeed__Type__c = 'Balance Sheet',AcctSeed__Sub_Type_1__c='Assets',AcctSeed__Sub_Type_2__c='Accounts Receivable'));
        
        glAccountList.add(new AcctSeed__GL_Account__c(Name='6420-Service Charges',AcctSeed__Active__c = true,AcctSeed__Type__c = 'Balance Sheet',AcctSeed__Sub_Type_1__c='Assets',AcctSeed__Sub_Type_2__c='Accounts Receivable'));
        
        
        for(Integer i = 0;i <10 ;i++){
            AcctSeed__GL_Account__c glAcc = new AcctSeed__GL_Account__c();
            glAccountList.add(glAcc);
            glAcc.name='Test GL Account '+i;
            glAcc.AcctSeed__Type__c='Balance Sheet';
            glAcc.AcctSeed__Sub_Type_1__c='Assets';
            glAcc.AcctSeed__Sub_Type_2__c='Cash';
        }
        glAccountList[8].AcctSeed__Bank__c=true;
        insert glAccountList;
        AcctSeed__Billing_Format__c pdfFormat = new AcctSeed__Billing_Format__c();
        pdfFormat.name='Test PDF';
        pdfFormat.AcctSeed__Type__c='Activity Statement';
        pdfFormat.AcctSeed__Visualforce_PDF_Page__c='BillingActivityStatementPDF';
        pdfFormat.AcctSeed__Default_Email_Template__c='Activity_Statement_Email_Template';
        insert pdfFormat; 
        
        List<AcctSeed__Billing_Format__c> formats = new List<AcctSeed__Billing_Format__c>();
        AcctSeed__Billing_Format__c billingformatObj = new AcctSeed__Billing_Format__c();
        billingformatObj.name = 'test';
        billingformatObj.AcctSeed__Type__c = 'Billing';
        billingformatObj.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        billingformatObj.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        formats.add(billingformatObj);
        
        billingformatObj = new AcctSeed__Billing_Format__c();
        billingformatObj.name = 'test1';
        billingformatObj.AcctSeed__Type__c = 'Purchase Order';
        billingformatObj.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        billingformatObj.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        formats.add(billingformatObj);
        
        billingformatObj = new AcctSeed__Billing_Format__c();
        billingformatObj.name = 'test2';
        billingformatObj.AcctSeed__Type__c = 'Activity Statement';
        billingformatObj.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        billingformatObj.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        formats.add(billingformatObj);
        
        billingformatObj = new AcctSeed__Billing_Format__c();
        billingformatObj.name = 'test3';
        billingformatObj.AcctSeed__Type__c = 'Outstanding Statement';
        billingformatObj.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        billingformatObj.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        formats.add(billingformatObj);
        
        billingformatObj = new AcctSeed__Billing_Format__c();
        billingformatObj.name = 'test4';
        billingformatObj.AcctSeed__Type__c = 'Packing Slip';
        billingformatObj.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        billingformatObj.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        formats.add(billingformatObj);
        
        insert formats;
        
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
        ledger.Name = 'Actual';
        ledger.AcctSeed__Type__c = 'Transactional';
        ledger.AcctSeed__Billing_Activity_Statement_Format__c = formats[2].Id;
        ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = formats[3].Id;
        ledger.AcctSeed__Default_Bank_Account__c = glAccountList[8].Id;
        ledger.AcctSeed__Default_Billing_Format__c = formats[0].Id;
        ledger.AcctSeed__Default_Packing_Slip_Format__c = formats[4].Id;
        ledger.AcctSeed__Default_Purchase_Order_Format__c = formats[1].Id;
        insert ledger;
        
        AcctSeed__Accounting_Settings__c accountSetting = new AcctSeed__Accounting_Settings__c();
        accountSetting.AcctSeed__Unapplied_Cash_GL_Account__c=glAccountList[2].Id;
        accountSetting.AcctSeed__AP_Control_GL_Account__c=glAccountList[3].Id;
        accountSetting.AcctSeed__AR_Control_GL_Account__c=glAccountList[4].Id;
        accountSetting.AcctSeed__Billing_Activity_Statement_Format__c=pdfFormat.id;
        accountSetting.AcctSeed__Billing_Outstanding_Statement_Format__c=pdfFormat.id;
        accountSetting.AcctSeed__Current_Year_Earnings_GL_Account__c=glAccountList[5].Id;
        accountSetting.AcctSeed__Default_Billing_Format__c=pdfFormat.id;
        accountSetting.AcctSeed__Default_Ledger__c=ledger.id;
        accountSetting.AcctSeed__Retained_Earnings_GL_Account__c=glAccountList[6].Id;
        accountSetting.AcctSeed__Revenue_GL_Account__c=glAccountList[7].Id;
        accountSetting.AcctSeed__Default_Bank_Account__c=glAccountList[8].Id;
        insert accountSetting;
        
        AcctSeed__Accounting_Period__c period = new AcctSeed__Accounting_Period__c();
        period.name='2017-03';
        period.AcctSeed__Start_Date__c= System.today();
        period.AcctSeed__End_Date__c=System.today()+1;
        period.AcctSeed__Status__c='Open';
        insert period;
        
        Transaction_Credit_And_Debits__c customSetting = new Transaction_Credit_And_Debits__c();
        customSetting.Name='Billing Line';
        customSetting.Credit_GL__c='1300-Accounts Receivable';
        customSetting.Debit_GL__c='4000-Premium';
        insert customSetting;
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.TextAttachment inAtt = new Messaging.InboundEmail.TextAttachment();
        
        email.subject = 'test';
        env.fromAddress = 'test@test.com';
        
        // set the body of the attachment
        inAtt.body = 'policyID,invoiceID,invoiceType,invoiceAmount,firmName,zipCode,issueDate,Message\n 12345,12346,bank,100.54,Banking,123456,'+System.today()+',onetest\n';
        inAtt.fileName = 'payment_gateway.csv';
        inAtt.mimeTypeSubType = 'plain/txt';
        
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] {inAtt }; 
        
        // call the class and test it with the data in the testMethod
        Email_Service_Handler emailServiceObj = new Email_Service_Handler();
        emailServiceObj.handleInboundEmail(email, env );
        
         Account objAccount = new Account();
         objAccount.Name = 'test';
         insert objAccount;
        
        Acctseed__Billing__c bill = new Acctseed__Billing__c();
         
        bill.Billing_Card_Expire_Month__c=System.today().addMonths(2).month();
        bill.Billing_Card_Expire_Year__c=System.today().addMonths(2).year();
        bill.Billing_Confirmation_Email__c='test.name@newTest.com.co.in.uk';
        bill.Billing_First_Name__c='Test First Name';
        bill.Billing_Last_Name__c='Test Last Name';
        bill.Next_Payment_Date__c=System.today()+1;
        bill.AcctSeed__Customer__c=objAccount.Id;
        bill.AcctSeed__Accounting_Period__c=period.Id;
        bill.AcctSeed__Billing_Format__c=pdfFormat.Id;
        bill.AcctSeed__Ledger__c=ledger.Id;
        insert bill;
        
        bill.Billing_Card_Expire_Month__c=System.today().addMonths(2).month();
        bill.Billing_Card_Expire_Year__c=System.today().addMonths(2).year();
        bill.Billing_Confirmation_Email__c='test@test.com';
        bill.Billing_First_Name__c='First Name';
        bill.Billing_Last_Name__c='Last Name';
        bill.Next_Payment_Date__c=System.today()+1;
        bill.AcctSeed__Customer__c=objAccount.Id;
        bill.AcctSeed__Accounting_Period__c=period.Id;
        bill.AcctSeed__Billing_Format__c=pdfFormat.Id;
     // bill.AcctSeed__Ledger_Amount__c=ledger.Id;
        update bill;
        
        Test.startTest();
        Batch_EmailNotificationCreditCardExpiry gateway = new Batch_EmailNotificationCreditCardExpiry();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.schedule('Sample_Test', CRON_EXP, gateway );
        
        Test.stopTest();
    }
    
      static testMethod void testMethod1() 
     {    
        Test.startTest();
         
         Account objAccount = new Account();
         objAccount.Name = 'test';
         insert objAccount;
         
        AcctSeed__Accounting_Period__c period = new AcctSeed__Accounting_Period__c();
        period.name='2017-03';
        period.AcctSeed__Start_Date__c= System.today()-15;
        period.AcctSeed__End_Date__c=System.today()+15;
        period.AcctSeed__Status__c='Close';
        insert period;
         
        AcctSeed__Billing_Format__c pdfFormat = new AcctSeed__Billing_Format__c();
        pdfFormat.name='Test PDF';
        pdfFormat.AcctSeed__Type__c='Activity Statement';
         pdfFormat.AcctSeed__Visualforce_PDF_Page__c='BillingActivityStatementPDF';
         pdfFormat.AcctSeed__Default_Email_Template__c='Activity_Statement_Email_Template';
         insert pdfFormat; 
         
         AcctSeed__GL_Account__c glAccount = new AcctSeed__GL_Account__c();
         glAccount.Name = 'Test';
         glAccount.AcctSeed__Bank__c = true;
         glAccount.AcctSeed__Active__c = true;
         glAccount.AcctSeed__Type__c = 'Expense';
         insert glAccount;
         
        List<AcctSeed__Billing_Format__c> formats = new List<AcctSeed__Billing_Format__c>();
        AcctSeed__Billing_Format__c billingformatObj = new AcctSeed__Billing_Format__c();
        billingformatObj.name = 'test';
        billingformatObj.AcctSeed__Type__c = 'Billing';
        billingformatObj.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        billingformatObj.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        formats.add(billingformatObj);
        
        billingformatObj = new AcctSeed__Billing_Format__c();
        billingformatObj.name = 'test1';
        billingformatObj.AcctSeed__Type__c = 'Purchase Order';
        billingformatObj.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        billingformatObj.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        formats.add(billingformatObj);
        
        billingformatObj = new AcctSeed__Billing_Format__c();
        billingformatObj.name = 'test2';
        billingformatObj.AcctSeed__Type__c = 'Activity Statement';
        billingformatObj.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        billingformatObj.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        formats.add(billingformatObj);
        
        billingformatObj = new AcctSeed__Billing_Format__c();
        billingformatObj.name = 'test3';
        billingformatObj.AcctSeed__Type__c = 'Outstanding Statement';
        billingformatObj.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        billingformatObj.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        formats.add(billingformatObj);
        
        billingformatObj = new AcctSeed__Billing_Format__c();
        billingformatObj.name = 'test4';
        billingformatObj.AcctSeed__Type__c = 'Packing Slip';
        billingformatObj.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        billingformatObj.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        formats.add(billingformatObj);
        
        insert formats;
        
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
        ledger.Name = 'Actual';
        ledger.AcctSeed__Type__c = 'Transactional';
        ledger.AcctSeed__Billing_Activity_Statement_Format__c = formats[2].Id;
        ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = formats[3].Id;
        ledger.AcctSeed__Default_Bank_Account__c = glAccount.Id;
        ledger.AcctSeed__Default_Billing_Format__c = formats[0].Id;
        ledger.AcctSeed__Default_Packing_Slip_Format__c = formats[4].Id;
        ledger.AcctSeed__Default_Purchase_Order_Format__c = formats[1].Id;
        insert ledger;
        
         
        Acctseed__Billing__c bill = new Acctseed__Billing__c();
         
        bill.Billing_Card_Expire_Month__c=System.today().addMonths(2).month();
        bill.Billing_Card_Expire_Year__c=System.today().addMonths(2).year();
        bill.Billing_Confirmation_Email__c='test.name@newTest.com.co.in.uk';
        bill.Billing_First_Name__c='Test First Name';
        bill.Billing_Last_Name__c='Test Last Name';
        bill.Next_Payment_Date__c=System.today()+1;
        bill.AcctSeed__Customer__c=objAccount.Id;
        bill.AcctSeed__Accounting_Period__c=period.Id;
        bill.AcctSeed__Billing_Format__c=pdfFormat.Id;   
     	bill.AcctSeed__Ledger__c=ledger.Id;
        insert bill;
        
        bill.Billing_Card_Expire_Month__c=System.today().addMonths(2).month();
        bill.Billing_Card_Expire_Year__c=System.today().addMonths(2).year();
        bill.Billing_Confirmation_Email__c='test@test.com';
        bill.Billing_First_Name__c='First Name';
        bill.Billing_Last_Name__c='Last Name';
        bill.Next_Payment_Date__c=System.today()+1;
        bill.AcctSeed__Customer__c=objAccount.Id;
        bill.AcctSeed__Accounting_Period__c=period.Id;
        bill.AcctSeed__Billing_Format__c=pdfFormat.Id;
     // bill.AcctSeed__Ledger_Amount__c=ledger.Id;
        update bill;
                  
        
        Batch_EmailNotifCreditCardExpiry_Test obj = new Batch_EmailNotifCreditCardExpiry_Test();
        //Database.executeBatch(obj);
    //    testBatchPaymentGateway(); 
        
        Test.stopTest();
    }
}