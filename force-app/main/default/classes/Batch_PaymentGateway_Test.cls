@isTest
private class Batch_PaymentGateway_Test {
    
    @isTest static void testBatchPaymentGateway4(){
        Account acc                   = new Account();
        acc.Name                      = 'Test';
        acc.AccountNumber             = '123456';
        acc.billingstreet = 'testStreet';
        acc.billingstate = 'testStreet';
        acc.billingCity = 'testStreet';
        acc.billingPostalCode = 'testStreet';
        acc.BillingCountry = 'testStreet';
        
        insert acc;
        
        List<AcctSeed__GL_Account__c> glAccountList = new List<AcctSeed__GL_Account__c>();
        
        glAccountList.add(new AcctSeed__GL_Account__c(Name='1101-Main Cash (CIBC)',AcctSeed__Active__c = true,AcctSeed__Type__c = 'Revenue',AcctSeed__Sub_Type_1__c='Service Revenue'));
        
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
        
        
        
        AcctSeed__Accounting_Period__c period = new AcctSeed__Accounting_Period__c();
        period.name='2017-03';
        period.AcctSeed__Start_Date__c= System.today()-15;
        period.AcctSeed__End_Date__c=System.today()+15;
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
        inAtt.body = 'policyID,invoiceID,invoiceType,invoiceAmount,firmName,zipCode,issueDate,Message\n 12345,12346,bank,1000.54,Banking,123456,'+System.today()+',onetest\n 123425,123246,bank,1000.54,Banking,123456,'+System.today()+',onetest';
        inAtt.fileName = 'payment_gateway.csv';
        inAtt.mimeTypeSubType = 'plain/txt';
        
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] {inAtt }; 
            
            // call the class and test it with the data in the testMethod
            Email_Service_Handler emailServiceObj = new Email_Service_Handler();
        emailServiceObj.handleInboundEmail(email, env );
        
        
        
        AcctSeed__Billing__c billing = new AcctSeed__Billing__c();
        billing.Mode_Of_Payment__c='eCheck/ACH';
        billing.IsPaymentProcessed__c=true;
        billing.Next_Payment_Date__c=System.today();
        //      billing.Next_Payment_Service_Fee__c=10;
        billing.Billing_Account_Number__c='1212';
        billing.Billing_Account_Holder_Name__c='Test';
        billing.Billing_Routing_Number__c='1212121';
        billing.AcctSeed__Customer__c=acc.Id;
        billing.Billing_First_Name__c='Approved';
        billing.IsPaymentProcessed__c=true;
        billing.Next_Payment_Date__c=System.today();
        billing.Next_Payment_Base_Amount__c= 8.25;
        //billing.AcctSeed__Balance__c=100;  
        billing.Billing_First_Name__c = 'test';
        billing.Billing_Last_Name__c='testing';
        billing.AcctSeed__Ledger__c = ledger.Id;
        billing.Mode_Of_Payment__c='Credit Card';
        billing.IsPaymentProcessed__c=true;
        billing.Next_Payment_Date__c=System.today();
        billing.Next_Payment_Base_Amount__c=100;
        billing.Next_Payment_Service_Fee__c=10;
        billing.Payment_Frequency__c='Monthly';
        billing.Billing_Confirmation_Email__c = 'test@cmentor.com';
        
        insert billing;
        
        billing.Mode_Of_Payment__c='eCheck/ACH';
        billing.IsPaymentProcessed__c=true;
        billing.Next_Payment_Date__c=System.today();
        billing.Next_Payment_Base_Amount__c=0;
        billing.Next_Payment_Service_Fee__c=10;
        billing.Billing_Account_Number__c='1212';
        billing.Billing_Account_Holder_Name__c='Test';
        billing.Billing_Routing_Number__c='1212121';
        billing.AcctSeed__Customer__c=acc.Id;
        billing.Billing_First_Name__c='Approved';
        billing.IsPaymentProcessed__c=true;
        billing.Next_Payment_Date__c=System.today();
        billing.Next_Payment_Base_Amount__c= 8.25;
        billing.Mode_Of_Payment__c='Credit Card';
        billing.IsPaymentProcessed__c=true;
        billing.Next_Payment_Date__c=System.today();
        //     billing.Next_Payment_Service_Fee__c=10;
        billing.Payment_Frequency__c='Monthly';
        
        update billing;
        
        AcctSeed__Billing_Line__c line = new AcctSeed__Billing_Line__c();
        
        line.AcctSeed__Hours_Units__c = 10; 
        line.AcctSeed__Rate__c = 10;
        line.AcctSeed__Billing__c=billing.Id;
        line.AcctSeed__Revenue_GL_Account__c= glAccountList[7].Id;
        
        insert line;
        
        
        AcctSeed__Payment_Method__c PaymentMethod = new AcctSeed__Payment_Method__c();
        PaymentMethod.AcctSeed__Customer__c = acc.id;
        PaymentMethod.AcctSeed__Payment_Method_Type__c = 'Bank Account';
        PaymentMethod.AcctSeed__Bank_Account_Type__c = 'Checking';
        PaymentMethod.AcctSeed__Routing_Number__c ='1234';
        PaymentMethod.Account_Number__c ='123456';
        PaymentMethod.AcctSeed__Card_Holder_Name__c='Test';
        //PaymentMethod.AcctSeed__Type__c ='American Express';
        //PaymentMethod.AcctSeed__Expiration_Month__c ='05';
        //PaymentMethod.AcctSeed__Expiration_Year__c='2024';
        PaymentMethod.AcctSeed__External_Id__c='#testingId';
        PaymentMethod.AcctSeed__Last_Four_Digits__c ='1234';
        insert PaymentMethod;
        
        
        Test.startTest();
        
        Batch_PaymentGateway gateway = new Batch_PaymentGateway();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = ' 0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.schedule('Sample_Test', CRON_EXP, gateway );
        
        Test.stopTest();
    }
    
    @isTest static void testBatchPaymentGateway3(){
        Account acc                   = new Account();
        acc.Name                      = 'Test';
        acc.AccountNumber             = '123456';
        acc.billingstreet = 'testStreet';
        acc.billingstate = 'testStreet';
        acc.billingCity = 'testStreet';
        acc.billingPostalCode = 'testStreet';
        acc.BillingCountry = 'testStreet';
        
        insert acc;
        
        List<AcctSeed__GL_Account__c> glAccountList = new List<AcctSeed__GL_Account__c>();
        
        glAccountList.add(new AcctSeed__GL_Account__c(Name='1101-Main Cash (CIBC)',AcctSeed__Active__c = true,AcctSeed__Type__c = 'Revenue',AcctSeed__Sub_Type_1__c='Service Revenue'));
        
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
        
        
        
        AcctSeed__Accounting_Period__c period = new AcctSeed__Accounting_Period__c();
        period.name='2017-03';
        period.AcctSeed__Start_Date__c= System.today()-15;
        period.AcctSeed__End_Date__c=System.today()+15;
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
        inAtt.body = 'policyID,invoiceID,invoiceType,invoiceAmount,firmName,zipCode,issueDate,Message\n 12345,12346,bank,1000.54,Banking,123456,'+System.today()+',onetest\n 123425,123246,bank,1000.54,Banking,123456,'+System.today()+',onetest';
        inAtt.fileName = 'payment_gateway.csv';
        inAtt.mimeTypeSubType = 'plain/txt';
        
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] {inAtt }; 
            
            // call the class and test it with the data in the testMethod
            Email_Service_Handler emailServiceObj = new Email_Service_Handler();
        emailServiceObj.handleInboundEmail(email, env );
        
        
        
        AcctSeed__Billing__c billing = new AcctSeed__Billing__c();
        billing.Mode_Of_Payment__c='eCheck/ACH';
        billing.IsPaymentProcessed__c=true;
        billing.Next_Payment_Date__c=System.today();
        //      billing.Next_Payment_Service_Fee__c=10;
        billing.Billing_Account_Number__c='1212';
        billing.Billing_Account_Holder_Name__c='Test';
        billing.Billing_Routing_Number__c='1212121';
        billing.AcctSeed__Customer__c=acc.Id;
        billing.Billing_First_Name__c='Approved';
        billing.IsPaymentProcessed__c=true;
        billing.Next_Payment_Date__c=System.today();
        billing.Next_Payment_Base_Amount__c= 8.25;
        //billing.AcctSeed__Balance__c=100;  
        billing.Billing_First_Name__c = 'test';
        billing.Billing_Last_Name__c='testing';
        billing.AcctSeed__Ledger__c = ledger.Id;
        billing.Mode_Of_Payment__c='Credit Card';
        billing.IsPaymentProcessed__c=true;
        billing.Next_Payment_Date__c=System.today();
        billing.Next_Payment_Base_Amount__c=100;
        billing.Next_Payment_Service_Fee__c=10;
        billing.Payment_Frequency__c='Monthly';
        billing.Billing_Confirmation_Email__c = 'test@cmentor.com';
        
        insert billing;
        
        billing.Mode_Of_Payment__c='eCheck/ACH';
        billing.IsPaymentProcessed__c=true;
        billing.Next_Payment_Date__c=System.today();
        billing.Next_Payment_Base_Amount__c=0;
        billing.Next_Payment_Service_Fee__c=10;
        billing.Billing_Account_Number__c='1212';
        billing.Billing_Account_Holder_Name__c='Test';
        billing.Billing_Routing_Number__c='1212121';
        billing.AcctSeed__Customer__c=acc.Id;
        billing.Billing_First_Name__c='Approved';
        billing.IsPaymentProcessed__c=true;
        billing.Next_Payment_Date__c=System.today();
        billing.Next_Payment_Base_Amount__c= 8.25;
        billing.Mode_Of_Payment__c='Credit Card';
        billing.IsPaymentProcessed__c=true;
        billing.Next_Payment_Date__c=System.today();
        //     billing.Next_Payment_Service_Fee__c=10;
        billing.Payment_Frequency__c='Monthly';
        
        update billing;
        
        AcctSeed__Billing_Line__c line = new AcctSeed__Billing_Line__c();
        
        line.AcctSeed__Hours_Units__c = 10; 
        line.AcctSeed__Rate__c = 10;
        line.AcctSeed__Billing__c=billing.Id;
        line.AcctSeed__Revenue_GL_Account__c= glAccountList[7].Id;
        
        insert line;
        
        
        AcctSeed__Payment_Method__c PaymentMethod = new AcctSeed__Payment_Method__c();
        PaymentMethod.AcctSeed__Customer__c = acc.id;
        PaymentMethod.AcctSeed__Payment_Method_Type__c = 'Bank Account';
        PaymentMethod.AcctSeed__Bank_Account_Type__c = 'Checking';
        PaymentMethod.AcctSeed__Routing_Number__c ='1234';
        PaymentMethod.Account_Number__c ='123456';
        PaymentMethod.AcctSeed__Card_Holder_Name__c='Test';
        //PaymentMethod.AcctSeed__Type__c ='American Express';
        //PaymentMethod.AcctSeed__Expiration_Month__c ='05';
        //PaymentMethod.AcctSeed__Expiration_Year__c='2024';
        PaymentMethod.AcctSeed__External_Id__c='#testingId';
        PaymentMethod.AcctSeed__Last_Four_Digits__c ='1234';
        insert PaymentMethod;
        
        
        Test.startTest();
        
        Batch_PaymentGateway gateway = new Batch_PaymentGateway(new Set<Id>{billing.Id});
        Database.ExecuteBatch(gateway,1);
        //Datetime dt = Datetime.now().addMinutes(1);
        //String CRON_EXP = ' 0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        //System.schedule('Sample_Test', CRON_EXP, gateway );
        
        Test.stopTest();
    }	
    
    @isTest static void testBatchPaymentGateway2(){
        Account acc                   = new Account();
        acc.Name                      = 'Test';
        acc.AccountNumber             = '123456';
        acc.billingstreet = 'testStreet';
        acc.billingstate = 'testStreet';
        acc.billingCity = 'testStreet';
        acc.billingPostalCode = 'testStreet';
        acc.BillingCountry = 'testStreet';
        
        insert acc;
        
        List<AcctSeed__GL_Account__c> glAccountList = new List<AcctSeed__GL_Account__c>();
        
        glAccountList.add(new AcctSeed__GL_Account__c(Name='1101-Main Cash (CIBC)',AcctSeed__Active__c = true,AcctSeed__Type__c = 'Revenue',AcctSeed__Sub_Type_1__c='Service Revenue'));
        
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
        
        
        
        AcctSeed__Accounting_Period__c period = new AcctSeed__Accounting_Period__c();
        period.name='2017-03';
        period.AcctSeed__Start_Date__c= System.today()-15;
        period.AcctSeed__End_Date__c=System.today()+15;
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
        inAtt.body = 'policyID,invoiceID,invoiceType,invoiceAmount,firmName,zipCode,issueDate,Message\n 12345,12346,bank,1000.54,Banking,123456,'+System.today()+',onetest\n 123425,123246,bank,1000.54,Banking,123456,'+System.today()+',onetest';
        inAtt.fileName = 'payment_gateway.csv';
        inAtt.mimeTypeSubType = 'plain/txt';
        
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] {inAtt }; 
            
            // call the class and test it with the data in the testMethod
            Email_Service_Handler emailServiceObj = new Email_Service_Handler();
        emailServiceObj.handleInboundEmail(email, env );
        
        
        
        AcctSeed__Billing__c billing = new AcctSeed__Billing__c();
        billing.Mode_Of_Payment__c='eCheck/ACH';
        billing.IsPaymentProcessed__c=true;
        billing.Next_Payment_Date__c=System.today();
        //      billing.Next_Payment_Service_Fee__c=10;
        billing.Billing_Account_Number__c='1212';
        billing.Billing_Account_Holder_Name__c='Test';
        billing.Billing_Routing_Number__c='1212121';
        billing.AcctSeed__Customer__c=acc.Id;
        billing.Billing_First_Name__c='Approved';
        billing.IsPaymentProcessed__c=true;
        billing.Next_Payment_Date__c=System.today();
        billing.Next_Payment_Base_Amount__c= 8.25;
        //billing.AcctSeed__Balance__c=100;  
        billing.Billing_First_Name__c = 'test';
        billing.Billing_Last_Name__c='testing';
        billing.AcctSeed__Ledger__c = ledger.Id;
        billing.Mode_Of_Payment__c='Credit Card';
        billing.IsPaymentProcessed__c=true;
        billing.Next_Payment_Date__c=System.today();
        billing.Next_Payment_Base_Amount__c=100;
        billing.Next_Payment_Service_Fee__c=10;
        billing.Payment_Frequency__c='Monthly';
        billing.Billing_Confirmation_Email__c = 'test@cmentor.com';
        
        insert billing;
        
        billing.Mode_Of_Payment__c='eCheck/ACH';
        billing.IsPaymentProcessed__c=true;
        billing.Next_Payment_Date__c=System.today();
        billing.Next_Payment_Base_Amount__c=0;
        billing.Next_Payment_Service_Fee__c=10;
        billing.Billing_Account_Number__c='1212';
        billing.Billing_Account_Holder_Name__c='Test';
        billing.Billing_Routing_Number__c='1212121';
        billing.AcctSeed__Customer__c=acc.Id;
        billing.Billing_First_Name__c='Approved';
        billing.IsPaymentProcessed__c=true;
        billing.Next_Payment_Date__c=System.today();
        billing.Next_Payment_Base_Amount__c= 8.25;
        billing.Mode_Of_Payment__c='Credit Card';
        billing.IsPaymentProcessed__c=true;
        billing.Next_Payment_Date__c=System.today();
        //     billing.Next_Payment_Service_Fee__c=10;
        billing.Payment_Frequency__c='Monthly';
        
        update billing;
        
        AcctSeed__Billing_Line__c line = new AcctSeed__Billing_Line__c();
        
        line.AcctSeed__Hours_Units__c = 10; 
        line.AcctSeed__Rate__c = 10;
        line.AcctSeed__Billing__c=billing.Id;
        line.AcctSeed__Revenue_GL_Account__c= glAccountList[7].Id;
        
        insert line;
        
        
        AcctSeed__Payment_Method__c PaymentMethod = new AcctSeed__Payment_Method__c();
        PaymentMethod.AcctSeed__Customer__c = acc.id;
        PaymentMethod.AcctSeed__Payment_Method_Type__c = 'Bank Account';
        PaymentMethod.AcctSeed__Bank_Account_Type__c = 'Checking';
        PaymentMethod.AcctSeed__Routing_Number__c ='1234';
        PaymentMethod.Account_Number__c ='123456';
        PaymentMethod.AcctSeed__Card_Holder_Name__c='Test';
        //PaymentMethod.AcctSeed__Type__c ='American Express';
        //PaymentMethod.AcctSeed__Expiration_Month__c ='05';
        //PaymentMethod.AcctSeed__Expiration_Year__c='2024';
        PaymentMethod.AcctSeed__External_Id__c='#testingId';
        PaymentMethod.AcctSeed__Last_Four_Digits__c ='1234';
        insert PaymentMethod;
        
        
        Test.startTest();
        
         Batch_PaymentGateway gateway = new Batch_PaymentGateway(billing.Next_Payment_Date__c);
         Database.ExecuteBatch(gateway,1);
        //Datetime dt = Datetime.now().addMinutes(1);
        //String CRON_EXP = ' 0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        //System.schedule('Sample_Test', CRON_EXP, gateway );
        
        Test.stopTest();
    }
}