@isTest
public class MultipleCashRecieptExt_Test {
    @testSetup
    static void testSetup(){
        Account acc = TestDataFactory.createAccounts('Bucket Account');
        acc.AccountNumber = '123456';
        acc.Vendor_Account__c = true;
        acc.BillingStreet = 'PA';
        acc.BillingCity = 'Allentown';
        acc.BillingPostalCode = '123456';
        acc.BillingState = 'IL';
        acc.BillingCountry = 'US';
        acc.ShippingStreet = 'PA';
        acc.ShippingCity = 'Allentown';
        acc.ShippingState = 'IL';
        acc.ShippingPostalCode = '123456';
        acc.ShippingCountry = 'US';
        acc.Claims_Folder_Id__c = '1234';
        acc.Policies_Folder_Id__c = '1234';
        
        insert acc;
        
        Contact con = TestDataFactory.createContact('Contact',acc.id);
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.AccountId = acc.Id;
        con.Type__c   = 'Lawyer';
        con.Contact_Role__c = 'P';
        con.Title = 'Test';
        con.Email = 'Test@mail.com';
        con.Phone = 'Test';
        con.ISBA__c = 'Test';
        con.Account_Number__c = 'Test';
        con.Middle_Name__c = 'Test';
        con.Primary_Contact__c = True;
        con.ARDC_Number__c = '1234';
        con.ARDC__c = 'Test';
        con.Birthdate = System.today();
        con.Phone_Ext__c = 'test';
        con.Gender__c = 'test';
        con.MailingStreet = 'test';
        con.MailingCity = 'test';
        con.MailingState = 'test';
        con.MailingPostalCode = 'test';
        con.Request_No_Contact__c = 12345566;
        con.Bar_Status__c = 'test';
        con.Bar_Membership_Geo__c = 'test';
        con.Specialty_Bar_Association__c = 'test';
        con.Full_licensed_name_ARDC__c = 'test';
        con.ARDC_Insurance_Report__c = 'test';
        con.Authorized_To_Practice__c = 'test';
        con.Do_not_mail__c = True;
        con.DoNotCall = True;
        con.AcctSeed__X1099_Vendor__c = True;
        con.AcctSeed__Default_1099_Box__c = 'Test';
        con.MailingCountry = 'Test';
        con.Bar_entry_date__c = system.today();
        con.Firm_ID__c = 'Test';
        con.Prior_Acts_Date__c = system.today();
        con.Converted_from_lead__c = system.today();
        con.Best_times_to_reach__c = 'Test';
        con.Contacted_us__c = system.today();
        con.Policy_Expiration_Date__c = System.today();
        con.Paid_Through__c = System.today();
        con.ISBA_Paid_through__c = System.today();
        con.Last_telemarketing_list_submitted__c = System.today();
        con.Last_emailed__c = System.today();
        con.Completed_form__c = System.today();
        con.Lead_returned_by_QCSS__c = System.today();
        con.QCSS_Date__c = System.today();
        con.Do_Not_Email__c = True;
        con.Category__c = 'Test';
        con.Admitted_in_Illinois__c = System.today();
        con.Joined_Firm__c = System.today();
        con.Description = 'Test';
        con.AOP_1__c = 'Test';
        con.AOP_2__c = 'Test';
        con.Court__c = 123456;
        con.Address_Purpose__c = 'Test';
        con.Act_On_Lead_Score__c = 123456;
        con.Lead_Week__c = 'Week1';
        con.Suffix__c = 'Test';
        
        insert con;
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        AccountContactJunction__c acj1 = TestDataFactory.createAccConJunc(acc.Id, con.id);
        insert acj1;
        
        List<AcctSeed__GL_Account__c> glAccounts = TestDataFactory.createGLAccounts();        
        insert glAccounts;
        //glAccounts[1]
        
        List<AcctSeed__Billing_Format__c> billingFormats = TestDataFactory.createBillingFormats();        
        insert billingFormats ;
        
        List<AcctSeed__Ledger__c> ledgers = TestDataFactory.createLedgers(glAccounts[0].id,billingFormats[0].id,billingFormats[1].id,billingFormats[2].id,billingFormats[3].id,billingFormats[4].id);
        insert ledgers;
        
        AcctSeed__Accounting_Settings__c settings = TestDataFactory.createAccountsetting(ledgers[0].id,glAccounts[0].Id,glAccounts[1].Id,glAccounts[2].Id,glAccounts[3].Id,glAccounts[4].Id,glAccounts[5].Id,glAccounts[6].Id,billingFormats[0].Id);
        insert settings;
        
        // insert 1 Accounting Period
         AcctSeed__Accounting_Period__c periods = new AcctSeed__Accounting_Period__c(
                 Name = '1991-10',
                 AcctSeed__Start_Date__c = Date.newinstance(1991, 10, 1),
                 AcctSeed__End_Date__c = Date.newinstance(2050, 10, 31),
                 AcctSeed__Status__c = 'Open');
        insert periods;        
        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        opp.Name = 'Test';
        opp.StageName                 = 'closed won';
        opp.CloseDate                 = System.today().addMonths(1);
        insert opp;
        
        
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Geo');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.id,county.Id);
        //geo.County__c                 = county.Id;
        insert geo;
        
        Master_Factor__c masterFactor = TestDataFactory.createMasterfactor('Test Master Factor0','Step Rate');
        insert masterFactor;
        
        
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(masterFactor.Id);
        insert stepRateFactor;
        
        Master_Factor__c masterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert masterFactor1;
        
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(masterFactor1.Id);
        insert baseFactor;
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorNew.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        insert acctivePolicy; 
        
        Attachment attach = new Attachment();
        attach.Body = Blob.valueOf('UNIT.TEST');
        attach.ParentId = acctivePolicy.Id;
        attach.Name = 'Test'+ acctivePolicy.Id+'.pdf';
        
        insert attach;
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('','','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        objPolEndorse.Endorsement_Effective_Date__c = system.today().addDays(-1);
        insert objPolEndorse;
        
        objPolEndorse.Event_Status__c = 'Complete';
        
        update objPolEndorse;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,acctivePolicy.id);
        insert aop;
        
        List<AcctSeed__Billing__c> objBilling = new List<AcctSeed__Billing__c>();
        objBilling.add(
            new AcctSeed__Billing__c(     
                AcctSeed__Opportunity__c = opp.id,
                AcctSeed__Billing_Contact__c = con.id,
                AcctSeed__Date__c = system.today() ,
                AcctSeed__Status__c = 'Approved',
                AcctSeed__Customer__c = acc.Id,
                AcctSeed__Accounting_Period__c = periods.Id
            )
        );
        
        objBilling.add(
            new AcctSeed__Billing__c(     
                AcctSeed__Opportunity__c = opp.id,
                AcctSeed__Billing_Contact__c = con.id,
                AcctSeed__Date__c = system.today() ,
                AcctSeed__Status__c = 'Approved',
                AcctSeed__Customer__c = acc.Id,
                AcctSeed__Accounting_Period__c = periods.Id
            )
        );
        insert objBilling;
        
        List<AcctSeed__Billing_Line__c> billingLine = new List<AcctSeed__Billing_Line__c>();
        billingLine.add(
            new AcctSeed__Billing_Line__c(AcctSeed__Billing__c = objBilling[0].Id,
                                          AcctSeed__Rate__c = 20, 
                                          AcctSeed__Hours_Units__c = 1, 
                                          AcctSeed__Revenue_GL_Account__c = glAccounts[10].Id,
                                          AcctSeed__Date__c = system.today(), 
                                          AcctSeed__Expense_GL_Account__c = glAccounts[3].id
                                         )
        );      
        billingLine.add( 
            new AcctSeed__Billing_Line__c(AcctSeed__Billing__c = objBilling[0].Id,
                                          AcctSeed__Rate__c = 10, 
                                          AcctSeed__Hours_Units__c = 1, 
                                          AcctSeed__Revenue_GL_Account__c = glAccounts[10].Id,
                                          AcctSeed__Date__c = system.today(), 
                                          AcctSeed__Expense_GL_Account__c = glAccounts[3].id
                                         )
        );
        
        billingLine.add(
            new AcctSeed__Billing_Line__c(AcctSeed__Billing__c = objBilling[1].Id,
                                          AcctSeed__Rate__c = 20, 
                                          AcctSeed__Hours_Units__c = 1, 
                                          AcctSeed__Revenue_GL_Account__c = glAccounts[10].Id,
                                          AcctSeed__Date__c = system.today(), 
                                          AcctSeed__Expense_GL_Account__c = glAccounts[3].id
                                         )
        );      
        billingLine.add( 
            new AcctSeed__Billing_Line__c(AcctSeed__Billing__c = objBilling[1].Id,
                                          AcctSeed__Rate__c = 10, 
                                          AcctSeed__Hours_Units__c = 1, 
                                          AcctSeed__Revenue_GL_Account__c = glAccounts[10].Id,
                                          AcctSeed__Date__c = system.today(), 
                                          AcctSeed__Expense_GL_Account__c = glAccounts[3].id
                                         )
        );
        insert billingLine;
        
        //Call the post billings service
        AcctSeed.PostResult[] postResults = AcctSeed.BillingPostService.postBillings(objBilling);
        
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
        /*      
AcctSeed__Cash_Receipt__c cashReceipt = TestDataFactory.createCashReceipt(acc.Id, ledgers.id);
insert cashReceipt;
*/
        
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c(Name='PPMG', AcctSeed__Active__c= true, 
                                                                                       AcctSeed__Type__c='GL Account Variable 1'
                                                                                      );
        insert accVar;
        
        List<AcctSeed__Cash_Receipt__c> crList = new List<AcctSeed__Cash_Receipt__c>();
        AcctSeed__Cash_Receipt__c cashReceipt = new AcctSeed__Cash_Receipt__c(
            AcctSeed__Account__c = acc.Id, 
            AcctSeed__Status__c = 'In Process',
            
            AcctSeed__Receipt_Date__c = System.today(), 
            AcctSeed__Payment_Reference__c = 'ref_12345',
            AcctSeed__Amount__c = 100,
            AcctSeed__Ledger__c = ledgers[0].Id,
            AcctSeed__Accounting_Period__c = periods.Id,
            AcctSeed__Credit_GL_Account__c = glAccounts[19].Id
        );
        
        crList.add(cashReceipt);
        
        AcctSeed__Cash_Receipt__c cashReceipt1 = new AcctSeed__Cash_Receipt__c(
            AcctSeed__Account__c = acc.Id,  
            AcctSeed__Status__c = 'In Process',
            AcctSeed__Receipt_Date__c = System.today(), 
            AcctSeed__Payment_Reference__c = 'ref_12345',
            AcctSeed__Amount__c = 100,
            AcctSeed__Ledger__c = ledgers[0].Id,
            AcctSeed__Accounting_Period__c = periods.Id,
            AcctSeed__Credit_GL_Account__c = glAccounts[19].Id
        );
        
        crList.add(cashReceipt1);
        
        AcctSeed__Cash_Receipt__c cashReceipt2 = new AcctSeed__Cash_Receipt__c(
            AcctSeed__Account__c = acc.Id,  
            AcctSeed__Status__c = 'In Process',
            AcctSeed__Receipt_Date__c = System.today(), 
            AcctSeed__Payment_Reference__c = 'ref_12345',
            AcctSeed__Amount__c = 50,
            AcctSeed__Ledger__c = ledgers[0].Id,
            AcctSeed__Accounting_Period__c = periods.Id,
            AcctSeed__Credit_GL_Account__c = glAccounts[19].Id
        );
        
        crList.add(cashReceipt2);
        
        AcctSeed__Cash_Receipt__c cashReceipt3 = new AcctSeed__Cash_Receipt__c(
            AcctSeed__Account__c = acc.Id,  
            AcctSeed__Status__c = 'In Process',
            AcctSeed__Receipt_Date__c = System.today(), 
            AcctSeed__Payment_Reference__c = 'ref_12345',
            AcctSeed__Amount__c = 50,
            AcctSeed__Ledger__c = ledgers[0].Id,
            AcctSeed__Accounting_Period__c = periods.Id,
            AcctSeed__Credit_GL_Account__c = glAccounts[19].Id
        );
        
        crList.add(cashReceipt3);
        
        insert crList;
        
    }
    @isTest 
    static void method1() {
        list<Account> listAcc = [Select Id from Account];
        list<AcctSeed__Cash_Receipt__c> listCR = [Select Id from AcctSeed__Cash_Receipt__c];
        list<AcctSeed__Billing__c> listBilling = [Select Id, AcctSeed__Balance__c, name, AS_Transaction_Description__c, AcctSeed__Date__c, Policy__r.Name, Claim__r.Name from AcctSeed__Billing__c];
		        
        PageReference pg = Page.MultipleCashReciept;
        pg.getParameters().put('Id',listCR[0].Id);
        Test.setCurrentPageReference(pg);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listCR[0]); 
        MultipleCashRecieptExt objRecipet = new MultipleCashRecieptExt (sc); 
        MultipleCashRecieptExt.CashRecieptWrapper objWrapper = new MultipleCashRecieptExt.CashRecieptWrapper();
        
        objRecipet.addRow();
        
        //List<MultipleCashRecieptExt.CashRecieptWrapper> wrpparList = new List<MultipleCashRecieptExt.CashRecieptWrapper>();
        MultipleCashRecieptExt.CashRecieptWrapper cw = new MultipleCashRecieptExt.CashRecieptWrapper();
        
        
        objRecipet.cashRecieptWrpList[0].cashReceipt.AcctSeed__Account__c = listAcc[0].Id;
        objRecipet.cashRecieptWrpList[0].reference = 'ref_12345';
        objRecipet.cashRecieptWrpList[0].containsRef = false;
        objRecipet.cashRecieptWrpList[0].accountId = listAcc[0].id;
        objRecipet.cashRecieptWrpList[0].amount =30;
        objRecipet.cashRecieptWrpList[0].hasAnyBillSelected = true;
        
        ApexPages.CurrentPage().getparameters().put('listIndex','1');
        ApexPages.CurrentPage().getparameters().put('rowno','1'); 
        ApexPages.CurrentPage().getparameters().put('AccountId',listAcc[0].id); 
        
        MultipleCashRecieptExt.BillingWrapper bill = new MultipleCashRecieptExt.BillingWrapper(listBilling[0],true,5);
        bill.selected = true;
        bill.billId = listBilling[0].id;
        bill.balance = 5;
        
        list<MultipleCashRecieptExt.BillingWrapper> billList = new list<MultipleCashRecieptExt.BillingWrapper>();
        billList.add(bill);
        
        objRecipet.cashRecieptWrpList[0].billingList = billList;
        
        
        String csvContent = 'Origination Date,Settle Date,Account Type,Client ID,Consumer ID,Total Amount,Transaction ID,Credit Card Processor,Cardholder Name,BillTo Company Name,Transaction Type,Entered By,Service Fee,test,test,test,test,test,test\r\n ,9/1/2020 2:52:00,38277585,,123456,30,Marv Raidbard,Marv Raidbard Attorn,10,Scheduled,123532,,,test,test,9/1/2020,9/1/2020,test,test,test,test\n ,9/1/2020 2:52:00,38277585,,123456,30,Marv Raidbard,Marv Raidbard Attorn,10,Scheduled,123532,,,test,tes,9/1/2020,9/1/2020,test,test,test,testt';
        apexpages.currentpage().getParameters().put('file',csvContent);
        Test.startTest();
        objRecipet.ManualEntry();
        objRecipet.ProcessFile();
        
        objRecipet.cashRecieptWrpList[0].cashReceipt.AcctSeed__Account__c = listAcc[0].Id;
        objRecipet.cashRecieptWrpList[0].reference = 'ref_12345';
        objRecipet.cashRecieptWrpList[0].containsRef = false;
        objRecipet.cashRecieptWrpList[0].accountId = listAcc[0].id;
        objRecipet.cashRecieptWrpList[0].amount =30;
        objRecipet.cashRecieptWrpList[0].hasAnyBillSelected = true;
        
        
        
        objRecipet.submit();
        objRecipet.removeRow();
        MultipleCashRecieptExt.getLookupRecord('1234');
        objRecipet.onChangeAccount();
        objRecipet.convertDate('10/12/2021');
        objRecipet.crReference();
        
        Test.stopTest();
    }
    
    @isTest 
    static void method2() {
        list<Account> listAcc = [Select Id from Account];
        list<AcctSeed__Cash_Receipt__c> listCR = [Select Id from AcctSeed__Cash_Receipt__c];
        list<AcctSeed__Billing__c> listBilling = [Select Id, AcctSeed__Balance__c, name, AS_Transaction_Description__c, AcctSeed__Date__c, Policy__r.Name, Claim__r.Name from AcctSeed__Billing__c];
		
        PageReference pg = Page.MultipleCashReciept;
        pg.getParameters().put('Id',listCR[0].Id);
        Test.setCurrentPageReference(pg);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(listCR[0]); 
        MultipleCashRecieptExt objRecipet = new MultipleCashRecieptExt (sc); 
        MultipleCashRecieptExt.CashRecieptWrapper objWrapper = new MultipleCashRecieptExt.CashRecieptWrapper();
        
        objRecipet.addRow();
        
        //List<MultipleCashRecieptExt.CashRecieptWrapper> wrpparList = new List<MultipleCashRecieptExt.CashRecieptWrapper>();
        MultipleCashRecieptExt.CashRecieptWrapper cw = new MultipleCashRecieptExt.CashRecieptWrapper();
        
        
        objRecipet.cashRecieptWrpList[0].cashReceipt.AcctSeed__Account__c = listAcc[0].Id;
        objRecipet.cashRecieptWrpList[0].reference = '';
        objRecipet.cashRecieptWrpList[0].containsRef = false;
        objRecipet.cashRecieptWrpList[0].accountId = listAcc[0].id;
        objRecipet.cashRecieptWrpList[0].amount =30;
        objRecipet.cashRecieptWrpList[0].hasAnyBillSelected = true;
        
        ApexPages.CurrentPage().getparameters().put('listIndex','1');
        ApexPages.CurrentPage().getparameters().put('rowno','1'); 
        ApexPages.CurrentPage().getparameters().put('AccountId',listAcc[0].id); 
        
        MultipleCashRecieptExt.BillingWrapper bill = new MultipleCashRecieptExt.BillingWrapper(listBilling[0],true,5);
        bill.selected = true;
        bill.billId = listBilling[0].id;
        bill.balance = 5;
        
        list<MultipleCashRecieptExt.BillingWrapper> billList = new list<MultipleCashRecieptExt.BillingWrapper>();
        billList.add(bill);
        
        objRecipet.cashRecieptWrpList[0].billingList = billList;
        
        
        String csvContent = 'Origination Date,Settle Date,Account Type,Client ID,Consumer ID,Total Amount,Transaction ID,Credit Card Processor,Cardholder Name,BillTo Company Name,Transaction Type,Entered By,Service Fee,test,test,test,test,test,test\r\n ,""9/1/2020 2:52:00"","38277585",,123456,30,Marv Raidbard,"Marv Raidbard Attorn",10,Scheduled,123532,",,"test","test",9/1/2020,9/1/2020,test,test,test,test\n ,"9/1/2020 2:52:00","38277585,,123456",30,ref_12345,ref_12345,10,Scheduled,123532,,,test,tes,9/1/2020,9/1/2020,test,test,test,testt';
        apexpages.currentpage().getParameters().put('file',csvContent);
        Test.startTest();
        objRecipet.ManualEntry();
        objRecipet.ProcessFile();
        
        objRecipet.cashRecieptWrpList[0].cashReceipt.AcctSeed__Account__c = listAcc[0].Id;
        objRecipet.cashRecieptWrpList[0].reference = '';
        objRecipet.cashRecieptWrpList[0].containsRef = false;
        objRecipet.cashRecieptWrpList[0].accountId = listAcc[0].id;
        objRecipet.cashRecieptWrpList[0].amount =30;
        objRecipet.cashRecieptWrpList[0].hasAnyBillSelected = true;
        
        objRecipet.cashRecieptWrpList[1].cashReceipt.AcctSeed__Account__c = listAcc[0].Id;
        objRecipet.cashRecieptWrpList[1].reference = 'ref_12345';
        objRecipet.cashRecieptWrpList[1].containsRef = false;
        objRecipet.cashRecieptWrpList[1].accountId = listAcc[0].id;
        objRecipet.cashRecieptWrpList[1].amount =30;
        objRecipet.cashRecieptWrpList[1].hasAnyBillSelected = true;
        
        
        objRecipet.submit();
        objRecipet.removeRow();
        MultipleCashRecieptExt.getLookupRecord('1234');
        objRecipet.onChangeAccount();
        objRecipet.convertDate('10/12/2021');
        objRecipet.crReference();
        
        Test.stopTest();
    }
    
}