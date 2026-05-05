@isTest
public class TriggerFactory_Test {
    
    @testsetup static void setup() {
        
        Account acc                   = new Account();
        acc.Name                      = 'Test Account';
        acc.AccountNumber             = '123456';
        acc.BillingState              = 'PA';
        acc.BillingCountry            = 'USA';
        insert acc;
        
        Contact con                   = new Contact();
        con.FirstName                 = 'Test';
        con.LastName                  = 'Contact';
        con.Type__c                   = 'Lawyer';
        con.Contact_Role__c           = 'M';
        con.AccountId                 = acc.Id;
        insert con;
        
        AccountContactJunction__c acj = new AccountContactJunction__c();
        acj.Account__c                = acc.Id;
        acj.Contact__c                = con.Id;
        acj.Name                      = 'Test Name';
        insert acj;
        
        List<AcctSeed__GL_Account__c> glAccounts = new List<AcctSeed__GL_Account__c>();
        
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1000-Cash',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = false,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash'
            )
        );
        
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1050-Unapplied Cash',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = false,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash'                
            )
        );
        
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1200-Accounts Receivable',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'              
            )
        );
        
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1600-Work In Process',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'      
            )
        );
        
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '2000-Accounts Payable',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Liabilities',
                AcctSeed__Sub_Type_2__c = 'Current Liabilities'     
            )
        );          
        
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '2010-Vouchers Payable',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Liabilities',
                AcctSeed__Sub_Type_2__c = 'Current Liabilities'     
            )
        );  
        
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '2020-Accrued Expenses',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Liabilities',
                AcctSeed__Sub_Type_2__c = 'Current Liabilities'     
            )
        ); 
        
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '3000-Owners Equity',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Equity'      
            )
        ); 
        
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '3050-Retained Earnings',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Equity'  
            )
        ); 
        
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '3060-Current Year Earnings',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Owners Equity',
                AcctSeed__Sub_Type_2__c = 'Equity'  
            )
        ); 
        
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '4000-Product Revenue',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Revenue',
                AcctSeed__Sub_Type_1__c = 'Product Revenue',
                AcctSeed__Sub_Type_2__c = 'Product Family 1'    
            )
        ); 
        
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
        
        // 23
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
        
        insert glAccounts;
        
        List<AcctSeed__GL_Account__c> glAccountsExpense = new List<AcctSeed__GL_Account__c>();
        
        // 0
        glAccountsExpense.add(
            new AcctSeed__GL_Account__c(
                Name = '6050-Travel Expenses',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Expense_Report_Name__c = 'Travel Expenses',
                AcctSeed__Billing_Description__c = 'Travel Expenses',
                AcctSeed__TM_Revenue_Conversion__c = glAccounts[11].Id,
                AcctSeed__Sub_Type_1__c = 'Sales & Marketing',
                AcctSeed__Sub_Type_2__c = 'Sales Travel'
            )
        ); 
        
        // 1
        glAccountsExpense.add(
            new AcctSeed__GL_Account__c(
                Name = '6060-Meals and Entertainment',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Used_In_Expense_Reports__c = true,
                AcctSeed__Expense_Report_Name__c = 'Meals and Entertainment',
                AcctSeed__Billing_Description__c = 'Meals and Entertainment',
                AcctSeed__TM_Revenue_Conversion__c = glAccounts[11].Id,
                AcctSeed__Sub_Type_1__c = 'Sales & Marketing',
                AcctSeed__Sub_Type_2__c = 'Sales Travel'  
            )
        ); 
        
        // 2
        glAccountsExpense.add(
            new AcctSeed__GL_Account__c(
                Name = '6070-Mileage',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Expense',
                AcctSeed__Used_In_Expense_Reports__c = true,
                AcctSeed__Expense_Report_Name__c = 'Mileage',
                AcctSeed__Billing_Description__c = 'Mileage',
                AcctSeed__Mileage_Account__c = true,
                AcctSeed__Mileage_Rate__c = .52,
                AcctSeed__TM_Revenue_Conversion__c = glAccounts[11].Id,
                AcctSeed__Sub_Type_1__c = 'Sales & Marketing',
                AcctSeed__Sub_Type_2__c = 'Sales Travel'           
            )
        ); 
        
        insert glAccountsExpense;
        glAccounts.addAll(glAccountsExpense);
        
        List<AcctSeed__Billing_Format__c> billingFormats = new List<AcctSeed__Billing_Format__c>();
        billingFormats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Billing Product',
                AcctSeed__Visualforce_PDF_Page__c = 'AccountPayable_Edit',
                AcctSeed__Default_Email_Template__c = 'Online_NBA_Creation_Notification',
                AcctSeed__Type__c = 'Billing',  
                AcctSeed__Sort_Field__c = 'Name'
            )
        );  
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c(
                Name = 'Default Billing Service',
                AcctSeed__Visualforce_PDF_Page__c = 'AccountPayable_Edit',
                AcctSeed__Default_Email_Template__c = 'Online_NBA_Creation_Notification',
                AcctSeed__Type__c = 'Billing', 
                AcctSeed__Sort_Field__c = 'Name'
            )
        );      
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Billing Outstanding Statment',
                AcctSeed__Visualforce_PDF_Page__c = 'AccountPayable_Edit',
                AcctSeed__Default_Email_Template__c = 'Online_NBA_Creation_Notification',
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com', 
                AcctSeed__Type__c = 'Outstanding Statement'
            )
        );    
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Billing Activity Statment',
                AcctSeed__Visualforce_PDF_Page__c = 'AccountPayable_Edit',
                AcctSeed__Default_Email_Template__c = 'Online_NBA_Creation_Notification',
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',  
                AcctSeed__Type__c = 'Activity Statement'  
            )
        ); 
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Default Packing Slip',
                AcctSeed__Visualforce_PDF_Page__c = 'AccountPayable_Edit',
                AcctSeed__Default_Email_Template__c = 'Online_NBA_Creation_Notification',
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',  
                AcctSeed__Type__c = 'Packing Slip'  
            )
        ); 
        
        billingFormats.add(
            new AcctSeed__Billing_Format__c (
                Name = 'Default Purchase Orde',
                AcctSeed__Visualforce_PDF_Page__c = 'AccountPayable_Edit',
                AcctSeed__Default_Email_Template__c = 'Online_NBA_Creation_Notification',
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com', 
                AcctSeed__Type__c = 'Purchase Order'  
            )
        );                 
        insert billingFormats;
        
        List<AcctSeed__Ledger__c> ledgers = new List<AcctSeed__Ledger__c>();
        
        ledgers.add(
            new AcctSeed__Ledger__c(
                Name = 'Actual',
                AcctSeed__Type__c = 'Transactional',
                AcctSeed__Default_Bank_Account__c = glAccounts[23].Id,
                AcctSeed__Default_Billing_Format__c = billingFormats[0].Id,
                AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormats[2].Id,
                AcctSeed__Billing_Activity_Statement_Format__c = billingFormats[3].Id,
                AcctSeed__Default_Purchase_Order_Format__c = billingFormats[5].id,
                AcctSeed__Default_Packing_Slip_Format__c  = billingFormats[4].id
            )
        );
        
        ledgers.add(
            new AcctSeed__Ledger__c(
                Name = 'Budget',
                AcctSeed__Type__c = 'Budget',
                AcctSeed__Default_Bank_Account__c = glAccounts[23].Id,
                AcctSeed__Default_Billing_Format__c = billingFormats[0].Id,
                AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormats[2].Id,
                AcctSeed__Billing_Activity_Statement_Format__c = billingFormats[3].Id,
                AcctSeed__Default_Purchase_Order_Format__c = billingFormats[5].id,
                AcctSeed__Default_Packing_Slip_Format__c  = billingFormats[4].id
            )
        );
        insert ledgers;
        
        List<AcctSeed__Accounting_Period__c> lstAccountingPeriod = new List<AcctSeed__Accounting_Period__c>();
        Date currentDate = Date.newInstance(2018, 9,1);
        
        for(Integer i = 0; i < 36; i++){
            
            AcctSeed__Accounting_Period__c objAccountingPeriod = new AcctSeed__Accounting_Period__c();
            
            objAccountingPeriod.AcctSeed__Start_Date__c = currentDate.addMonths(i);
            objAccountingPeriod.AcctSeed__End_Date__c = objAccountingPeriod.AcctSeed__Start_Date__c.addMonths(1).toStartOfMonth() - 1;
            objAccountingPeriod.Name = objAccountingPeriod.AcctSeed__Start_Date__c.year() + '-' + (string.valueOf(objAccountingPeriod.AcctSeed__Start_Date__c.month()).length() == 1?'0':'') + objAccountingPeriod.AcctSeed__Start_Date__c.month();
            lstAccountingPeriod.add(objAccountingPeriod);
        }
        
        insert lstAccountingPeriod;
        
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
                AcctSeed__Default_Bank_Account__c = glAccounts[1].Id,
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
        
        Opportunity opp               = new Opportunity();
        opp.Name                      = 'Test Opportunity';
        opp.AccountId                 = acc.Id;
        opp.StageName                 = 'Application Sent';
        opp.CloseDate                 = Date.today();
        insert opp;
        
        Master_Factor__c mas          = new Master_Factor__c();
        mas.Name                      = 'Test Master Factor';
        mas.Factor_Type__c            = 'Geo';
        mas.From_Date__c              = Date.today();
        mas.To_Date__c                = Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day());
        mas.Default__c                = true;
        insert mas;
        
        County__c county              = new County__c();
        county.Name                   = 'Test County';
        county.Region__c              = '5';
        insert county;
        
        Geo_Factor__c geo             = new Geo_Factor__c();
        geo.Name                      = 'Test County';
        geo.Master_Factor__c          = mas.Id;
        geo.Region_Factor_Value__c    = 0.88;
        geo.County__c                 = county.Id;
        insert geo;
        
        Master_Factor__c masterFactor = new Master_Factor__c(Factor_Type__c='Step Rate', Default__c=true,From_Date__c= Date.today().addDays(-1),
                                                             To_Date__c= Date.today().addDays(3),
                                                             Name  = 'Test Master Factor0');
        insert masterFactor;
        
        Step_Rate_Factor__c stepRateFactor = new Step_Rate_Factor__c(Master_Factor__c=masterFactor.Id, Factor_Value_Step_Rate_0__c=0,
                                                                     Factor_Value_Step_Rate_1__c=1, Factor_Value_Step_Rate_2__c=2, Factor_Value_Step_Rate_3__c=3, 
                                                                     Factor_Value_Step_Rate_4__c=4, Factor_Value_Step_Rate_5__c=5, Factor_Value_Step_Rate_6__c=6,
                                                                     Factor_Value_Step_Rate_7__c=7);
        insert stepRateFactor;
        
        Master_Factor__c masterFactor1 = new Master_Factor__c(Factor_Type__c='Base Value', Default__c=true,From_Date__c= Date.today(),
                                                              To_Date__c= Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day()),
                                                              Name  = 'Test Master Factor1');
        insert masterFactor1;
        
        Base_Factor__c baseFactor = new Base_Factor__c(Master_Factor__c=masterFactor1.Id, Base_Amount__c=100);
        insert baseFactor;
        
        Master_Factor__c masterFactorAop = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorAop;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorAop.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorAop.Id);
        insert dedFactorObj;
        
        Policy__c pol                 = new Policy__c();
        pol.RecordTypeId              = Schema.SObjectType.Policy__C.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        pol.Name                      = 'Test Policy';
        pol.Status__c                 = 'Application Created';
        pol.Account__c                = acc.Id;
        pol.Opportunity__c            = opp.Id;
        pol.Effective_Date__c         = System.today().addDays(-1);
        pol.Expiration_Date__c        = System.today().addDays(2);
        pol.Cancel_Date__c            = System.today().addDays(2);
        pol.SCH_Mod__c                = 1.00;
        pol.County__c                 = geo.Id;
        pol.Base_Amount__c            = 10;
        pol.Deductible_ID__c = dedFactorObj.Id;
        pol.Limit__c = coverageFactorObj.Id;
        pol.Firm_Mod__c               =15;
        insert pol;
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        
        Endorsement__c endorse = new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                    Description__c='Test desc');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = new Endorsement_Version__c(Master_Endorsement__c=endorse.Id,Endorsement_Version_Number__c='1',
                                                                           Effective_From__c=System.today());
        insert endorseVersion;
        
        
        Policy_Endorsement__c poicyEndorse = new Policy_Endorsement__c(Account__c =acc.Id ,Name='Test Policy Endorsement', Policy__c =pol.Id,Endorsement_Effective_Date__c = system.today(),
                                                                       RecordTypeId=devRecordTypeId);
        insert poicyEndorse;
        
        Master_Factor__c masterFactorNew = new Master_Factor__c(Default__c=true,Factor_Type__c='Step Rate',From_Date__c=System.today(),To_Date__c=System.today().addDays(1),
                                                                Name  = 'Test Master Factor');
        
        insert masterFactorNew;
        
        ILF_Coverage_Factor__c objfactor = new ILF_Coverage_Factor__c();
        objfactor.name = '250,000 / 500,000';
        objfactor.Coverage_Max_Per_Claim__c = 250000.00;
        objfactor.Full_Coverage__c = 500;
        objfactor.Factor_Value__c =12;
        objfactor.Master_Factor__c = masterFactorNew.id;
        objfactor.Lowest_Coverage__c = true;
        insert objfactor;
        
        Deductible_Factor__c objDed = new Deductible_Factor__c();
        objDed.Name = '12';
        objDed.Deductible_External_ID__c = '12345';
        objDed.Deductible_Amount__c = 124;
        objDed.Factor_Value__c = 1233;
        objDed.Master_Factor__c = masterFactorNew.id;
        insert objDed;
        
        Policy_Quote__c objQuote = new Policy_Quote__c();
        objQuote.Policy__c =pol.id ;
        objQuote.Coverage__c = objfactor.id;
        objQuote.Deductible__c = objDed.id;
        objQuote.Lowest_Coverage_Factor__c = 12;
        insert objQuote;
        
        AOP_Factor__c aopFactor = new AOP_Factor__c(Master_Factor__c=masterFactorNew.Id,Name='Test AOP Factor');
        aopFactor.AOP_Mod__c = 45.55;
        insert aopFactor;
        
        Policy_AOP__c aop = new Policy_AOP__c(Policy__c=pol.Id,AOP__c=aopFactor.Id, Factor_Mod__c=2,Percentage__c=5);
        //insert aop;
        
    }
    
    @isTest static void TestMethod1() {
        Test.startTest();
        TriggerFactory.GetPolicyBaseAmt();
        TriggerFactory objfactory = new TriggerFactory();
        //objfactory.updatePremiumOfPolicy();
        Test.stopTest();
    }
    
}