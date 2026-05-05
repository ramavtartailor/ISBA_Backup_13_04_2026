@isTest
public class EmailMessaageTriggerHandlerTest {

     @isTest
     public static void testEmailMessage() {
 
     // —— DATA PREPARATION ——
     // insert 1 Account
         Account acct = new Account(
                 Name = 'Test Account');
         insert acct;
 
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
 
     // insert 2 cash flow GL Accounts
         AcctSeed__GL_Account__c [] glAccounts = new List<AcctSeed__GL_Account__c>();
         //#0
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = '1000-Cash',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Balance Sheet',
                         AcctSeed__Bank__c = true,
                         AcctSeed__Sub_Type_1__c = 'Assets',
                         AcctSeed__Sub_Type_2__c = 'Cash'
                 )
         );
 
         //#1
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = '1205-Unapplied A/R',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Balance Sheet',
                         AcctSeed__Sub_Type_1__c = 'Assets',
                         AcctSeed__Sub_Type_2__c = 'Cash'
 
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
 
     // insert 1 Accounting Period
         AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
                 Name = '1991-10',
                 AcctSeed__Start_Date__c = Date.newinstance(1991, 10, 1),
                 AcctSeed__End_Date__c = Date.newinstance(1991, 10, 31),
                 AcctSeed__Status__c = 'Open');
         insert acctPeriod;
 
     // --- START HERE ---
     // Create BILLING RECORDS to post and unpost
         AcctSeed__Billing__c[] billings = new List <AcctSeed__Billing__c> ();
 
         billings.add(
                 new AcctSeed__Billing__c(
                         AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
                         AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
                         AcctSeed__Date__c = System.today(),
                         AcctSeed__Customer__c = [Select Id From Account limit 1].Id,
                         AcctSeed__Status__c = 'Approved',
                         AcctSeed__Due_Date2__c = System.today() + 30,
                         AcctSeed__Ledger__c = ledger.Id,
                         AcctSeed__Billing_Format__c = PDFformats[0].Id,
                         AcctSeed__Accounting_Period__c = [Select Id From AcctSeed__Accounting_Period__c limit 1].Id
                 )
         );
 
         billings.add(
                 new AcctSeed__Billing__c(
                         AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
                         AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
                         AcctSeed__Date__c = System.today(),
                         AcctSeed__Customer__c = [Select Id From Account limit 1].Id,
                         AcctSeed__Status__c = 'Approved',
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
         
         Test.startTest();
            EmailMessage email = new EmailMessage();
            email.FromAddress = 'test@abc.org';
            email.Incoming = false;
            email.ToAddress= 'test@cmentor.com';
            email.Subject = 'Test email';
            email.HtmlBody = 'Test email body';
            email.RelatedToId = billings[0].Id; 
            insert email;
             
         
         Test.stopTest();
         
         
     }
}