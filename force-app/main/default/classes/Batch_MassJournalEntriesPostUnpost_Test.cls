@isTest
public class Batch_MassJournalEntriesPostUnpost_Test {
    
    
    @testSetup
    static void testData(){
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
        
        insert billingFormats;
        
        AcctSeed__GL_Account__c expenseGL1 = new AcctSeed__GL_Account__c(Name = 'Test', AcctSeed__Active__c = true,
                                                                         AcctSeed__Bank__c=false,
                                                                         AcctSeed__Type__c= 'Expense');
        
        
        AcctSeed__GL_Account__c expenseGL2 = new AcctSeed__GL_Account__c(Name = 'Main', AcctSeed__Active__c = true,
                                                                         AcctSeed__Bank__c=true,
                                                                         AcctSeed__Type__c= 'Balance Sheet',AcctSeed__Sub_Type_1__c='Assets');
        insert new AcctSeed__GL_Account__c[]{expenseGL1,expenseGL2};
            
            AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(
                Name = 'Actual',
                AcctSeed__Type__c = 'Transactional',
                AcctSeed__Default_Bank_Account__c = expenseGL2.Id,
                AcctSeed__Default_Billing_Format__c = billingFormats[0].Id,
                AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormats[2].Id,
                AcctSeed__Billing_Activity_Statement_Format__c = billingFormats[3].Id,
                AcctSeed__Default_Purchase_Order_Format__c = billingFormats[5].Id,
                AcctSeed__Default_Packing_Slip_Format__c  = billingFormats[4].Id
            );
        
        insert ledger; 
        
        String acctPeriodName = string.valueOf(System.today().year())+'-';
        acctPeriodName += string.valueOf(system.today().month()).length() ==1 ?'0'+String.valueOf(system.today().month()) : String.valueOf(system.today().month());
        
        AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(Name=acctPeriodName,
                                                                                       AcctSeed__Start_Date__c =system.today().toStartOfMonth() ,
                                                                                       AcctSeed__End_Date__c= system.today().toStartOfMonth().addMonths(1).addDays(-1),
                                                                                       AcctSeed__Status__c= 'Open'  );
        insert acctPeriod;
        
        List<AcctSeed__Journal_Entry__c> jeEntryList = new List<AcctSeed__Journal_Entry__c>();
        // 0
        jeEntryList.add(
            new AcctSeed__Journal_Entry__c(
                Name = 'Test 1',
                AcctSeed__Status__c = 'Approved',
                AcctSeed__Journal_Date__c = date.today(),
                AcctSeed__Ledger__c = ledger.Id
            )
        );
        
        // 1
        jeEntryList.add(
            new AcctSeed__Journal_Entry__c(
                Name = 'Test 2',
                AcctSeed__Status__c = 'Approved',
                AcctSeed__Journal_Date__c = date.today(),
                AcctSeed__Ledger__c = ledger.Id
            )
        );
        insert jeEntryList;
        
        List<AcctSeed__Journal_Entry_Line__c> jeEntryLineList = new List<AcctSeed__Journal_Entry_Line__c>();
        
        jeEntryLineList.add(
            new AcctSeed__Journal_Entry_Line__c (
                AcctSeed__Units__c = 1,
                AcctSeed__Date__c  = date.today(),
                AcctSeed__GL_Account__c = expenseGL1.Id,
                AcctSeed__Credit__c = 100,
                AcctSeed__Journal_Entry__c =jeEntryList[0].Id
            )
        );
        
        jeEntryLineList.add(
            new AcctSeed__Journal_Entry_Line__c (
                AcctSeed__Units__c = 1,
                AcctSeed__Date__c  = date.today(),
                AcctSeed__GL_Account__c = expenseGL1.Id,
                AcctSeed__Debit__c = 100,
                AcctSeed__Journal_Entry__c =jeEntryList[0].Id
            )
        );
        
        
        jeEntryLineList.add(
            new AcctSeed__Journal_Entry_Line__c (
                AcctSeed__Units__c = 1,
                AcctSeed__Date__c  = date.today(),
                AcctSeed__GL_Account__c = expenseGL1.Id,
                AcctSeed__Credit__c = 100,
                AcctSeed__Journal_Entry__c =jeEntryList[1].Id
            )
        );
        
        jeEntryLineList.add(
            new AcctSeed__Journal_Entry_Line__c (
                AcctSeed__Units__c = 1,
                AcctSeed__Date__c  = date.today(),
                AcctSeed__GL_Account__c = expenseGL1.Id,
                AcctSeed__Debit__c = 100,
                AcctSeed__Journal_Entry__c =jeEntryList[1].Id
            )
        );
        
        Insert jeEntryLineList;
        
        List<AcctSeed__Journal_Entry__c> jeEntryForPost = [SELECT id from AcctSeed__Journal_Entry__c WHERE Name=:'Test 2'];
        try{
            AcctSeed.PostResult[] postResults = AcctSeed.JournalEntryPostService.postJournalEntries(jeEntryForPost);
            for (AcctSeed.PostResult theResult : postResults) {
                if (theResult.isSuccess) {
                    System.debug('Successfully posted journal entry: ' + theResult.id);
                } 
                else {
                    System.debug('Error posting billing ' + theResult.id);
                    for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                        System.debug('Error status code ' + errorResult.statusCode);
                        System.debug('Error message ' + errorResult.message);
                    }
                }
            }
            
        } Catch(Exception e) {
            System.debug('Error--'+e.getMessage());
        }
        
    }
    
    @isTest 
    static void TestMethod_1() {
        
        Test.startTest();
        Database.executeBatch(new Batch_MassJournalEntriesPostUnpost('Post',false),1);
        Test.stopTest();
    }
    
    @isTest 
    static void TestMethod_2() {
        
        List<AcctSeed__Journal_Entry__c> ObjList = [select id from AcctSeed__Journal_Entry__c];
        
        Test.startTest();
       Batch_MassJournalEntriesPostUnpost obj = new Batch_MassJournalEntriesPostUnpost('Unpost',true);
        Database.QueryLocator ql = obj.start(null);
        obj.execute(null,ObjList);
        obj.Finish(null);
        //Database.executeBatch(new Batch_MassJournalEntriesPostUnpost('Unpost',true),1);
        Test.stopTest();
    }
}