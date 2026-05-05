@isTest
public class ContactPoliciesComponentHandlerTest {
    @testSetup static void setup() {
        
        List<AcctSeed__GL_Account__c> glAccounts = new List<AcctSeed__GL_Account__c>();
        // 0
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
        
        // 1
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1050-Unapplied Cash',
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
                Name = '2020-Accrued Expenses',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Liabilities',
                AcctSeed__Sub_Type_2__c = 'Current Liabilities'     
            )
        ); 
        
        
        // 7 
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '3000-Owners Equity',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Equity'      
            )
        ); 
        
        // 8
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '3050-Retained Earnings',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Equity'  
            )
        ); 
        
        // 9
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '3060-Current Year Earnings',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Equity'  
            )
        ); 
        
        // 10
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '4000-Product Revenue',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Revenue',
                AcctSeed__Sub_Type_1__c = 'Product Revenue',
                AcctSeed__Sub_Type_2__c = 'Product Family 1'    
            )
        ); 
        
        // 11
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '4010-Services Revenue',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Revenue',
                AcctSeed__Sub_Type_1__c = 'Service Revenue',
                AcctSeed__Sub_Type_2__c = 'Service Family 1'    
            )
        ); 
        
        // 12
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5000-Cost of Goods Sold',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
                AcctSeed__Sub_Type_2__c = 'Materials'
            )
        ); 
        
        // 13
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5010-Inventory Cost Variance',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
                AcctSeed__Sub_Type_2__c = 'Materials'
            )
        ); 
        
        // 14
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5040-Vendor Payment Discounts',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
                AcctSeed__Sub_Type_2__c = 'Materials'
            )
        ); 
        
        // 15
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '5050-Labor',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold',
                AcctSeed__Sub_Type_2__c = 'Salaries & Wages'
            )
        ); 
        
        // 16
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '6000-Marketing Expense',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Sales & Marketing',
                AcctSeed__Sub_Type_2__c = 'Marketing Events'
            )
        ); 
        
        // 17
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '7000-Facilities Expense',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Facilities',
                AcctSeed__Sub_Type_2__c = 'Rent'         
            )
        ); 
        
        // 18
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '7050-Telecomunications',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Sub_Type_1__c = 'Facilities',
                AcctSeed__Sub_Type_2__c = 'Utilities'            
            )
        );
        
        // 19
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = 'zLabor Clearing',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense'            
            )
        );       
        
        // 20
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = 'zProject Labor',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense'            
            )
        );     
        
        // 21
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
        
        // 22
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1500-Inventory',
                AcctSeed__Active__c = true,
                AcctSeed__Bank__c = false,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'           
            )
        );
        
        insert glAccounts;
        
        County__c objCount = TestDataFactory.createCountyNew();
        insert objCount;
        
        Account acc = TestDataFactory.createAccounts('Bucket Account');
        acc.AccountNumber = '123456';
        acc.BillingStreet = 'PA';
        acc.BillingCity = 'Allentown';
        acc.BillingPostalCode = '123456';
        //acc.BillingState = 'IL';
        acc.BillingCountry = 'US';
        acc.ShippingStreet = 'PA';
        acc.ShippingCity = 'Allentown';
        //acc.ShippingState = 'IL';
        acc.ShippingPostalCode = '123456';
        acc.ShippingCountry = 'US';
        insert acc;
        
        Account acc1 = TestDataFactory.createAccountsNew('Bucket Account',objCount.Id);
        acc1.AccountNumber = '123456';
        acc1.BillingStreet = 'PA';
        acc1.BillingCity = 'Allentown';
        acc1.BillingPostalCode = '123456';
        // acc1.BillingState = 'IL';
        acc1.BillingCountry = 'US';
        acc1.ShippingStreet = 'PA';
        acc1.ShippingCity = 'Allentown';
        // acc1.ShippingState = 'IL';
        acc1.ShippingPostalCode = '123456';
        acc1.ShippingCountry = 'US';
        
        //insert acc1;
        
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
        
        List<AcctSeed__Billing_Format__c> billingFormats = TestDataFactory.createBillingFormats();        
        insert billingFormats ;
        
        List<AcctSeed__Ledger__c> ledgers = TestDataFactory.createLedgers(glAccounts[0].id,billingFormats[0].id,billingFormats[1].id,billingFormats[2].id,billingFormats[3].id,billingFormats[4].id);
        insert ledgers;
        
        //AcctSeed__Accounting_Settings__c settings = TestDataFactory.createAccountsetting(ledgers[0].id,glAccounts[0].Id,glAccounts[1].Id,billingFormats[0].Id);
        //insert settings;
        //
        List<AcctSeed__Accounting_Settings__c> settings = new List<AcctSeed__Accounting_Settings__c>();
        
        settings.add(
            new AcctSeed__Accounting_Settings__c(
                AcctSeed__AR_Control_GL_Account__c = glAccounts[2].Id,
                AcctSeed__AP_Control_GL_Account__c = glAccounts[4].Id,
                AcctSeed__Labor_GL_Account__c = glAccounts[19].Id,
                AcctSeed__Payment_Discount_GL_Account__c = glAccounts[14].Id,
                AcctSeed__Unapplied_Cash_GL_Account__c = glAccounts[1].Id,
                AcctSeed__Retained_Earnings_GL_Account__c = glAccounts[8].Id,
                AcctSeed__Default_Ledger__c = ledgers[0].Id,
                AcctSeed__Default_Bank_Account__c = glAccounts[0].Id,
                AcctSeed__Revenue_GL_Account__c = glAccounts[10].Id,
                AcctSeed__Default_Project_Task_Labor_GL_Account__c = glAccounts[20].Id,
                AcctSeed__Default_Billing_Format__c = billingFormats[0].Id,
                AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormats[2].Id,
                AcctSeed__Billing_Activity_Statement_Format__c = billingFormats[3].Id,                          
                AcctSeed__Current_Year_Earnings_GL_Account__c = glAccounts[9].Id,
                AcctSeed__Enable_Product_Costing__c = true,
                AcctSeed__Work_in_Process_GL_Account__c = glAccounts[3].Id,
                AcctSeed__Vouchers_Payable_GL_Account__c = glAccounts[5].Id,
                AcctSeed__Inventory_Variance_GL_Account__c =  glAccounts[13].Id,
                AcctSeed__Customer_Payment_Adjustment_GL_Account__c = glAccounts[21].Id,
                AcctSeed__Display_Billable_Flag_in_Time_Card_Entry__c = true,
                AcctSeed__Enable_Billing_Period_Sensitive_Aging__c = true,
                AcctSeed__Enable_AP_Period_Sensitive_Aging__c = true
            )
        );
        insert settings;
        
        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        opp.StageName                 = 'Application Sent';
        opp.CloseDate                 = Date.today();
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
        
        Map<String,String> mapRecordTypes = new Map<String,String>();
        
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoverageFactor(MasterFactorCoverage.Id);
        FactorCoverage.Percentage_5X5_Step_0__c =3;
        FactorCoverage.Percentage_5X5_Step_1__c=4;
        FactorCoverage.Percentage_5X5_Step_2__c=5;
        FactorCoverage.Percentage_5X5_Step_3__c=6;
        FactorCoverage.Percentage_5X5_Step_4__c=8;
        FactorCoverage.Premium_Rate_5X5__c = 33;
        FactorCoverage.Is_5X5_Coverage__c = true;
        
        insert FactorCoverage;
        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor','Deductible');
        insert mas12;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        Insert DedFac; 
        
        Master_Factor__c masterFactorNew1 = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew1;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew1.Id);
        insert dedFactorObj;
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = FactorCoverage.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy.Effective_Date__c = system.today().addDays(10);
        acctivePolicy.Expiration_Date__c = system.today().addDays(10);
        //insert acctivePolicy;
        
        Policy__c pol                 = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Application');
        pol.Status__c                 = 'Application created';
        pol.SCH_Mod__c                = 1.00;
        pol.Limit__c = FactorCoverage.Id;
        pol.Deductible_ID__c = dedFactorObj.Id;
        pol.Effective_Date__c = system.today().addDays(10);
        pol.Expiration_Date__c = system.today().addDays(10);   
        insert pol;
        
        
        
    }
    
    @isTest
    Public static void testMethod1() {
        
        
        List<Contact> conList = [SELECT Id FROM Contact]; 
        List<Policy__c> polList = [SELECT ID from Policy__c];
         List<Account> accList = [SELECT Id FROM Account]; 
        system.debug('++'+conList);
        system.debug('++'+polList);
        
       AccountContactJunction__c objLawyer = new AccountContactJunction__c();
        objLawyer.Name = 'test';
        objLawyer.Contact__c = conList[0].id;
        objLawyer.Account__c = accList[0].id;
        insert objLawyer;
        
        Policy_Lawyer__c objPolicyLawyer = new Policy_Lawyer__c();
        
        objPolicyLawyer.Lawyer__c = objLawyer.Id;
        objPolicyLawyer.Policy__c = polList[0].id;
        objPolicyLawyer.Added_Date__c = system.today();
        objPolicyLawyer.Prior_Act_Date__c = system.today();
        insert objPolicyLawyer;
        
        ContactPoliciesComponentHandler.getPolicies(String.valueOf(conList[0].id), True); 
        
        
        
      
        ContactPoliciesComponentHandler.getPolicies(String.valueOf(polList[0].id), True); 
        
        
    }
    
    
}