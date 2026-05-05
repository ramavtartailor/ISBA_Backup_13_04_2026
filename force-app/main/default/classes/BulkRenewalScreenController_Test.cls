@isTest
private class BulkRenewalScreenController_Test {
    @testSetup static void setup() {
        
        Account acc                   = new Account();
        acc.Name                      = 'Test';
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c = true;
        insert acc;
        
        Contact con                   = new Contact();
        con.FirstName                 = 'Test';
        con.LastName                  = 'Contact';
        con.Type__c                   = 'Lawyer';
        con.Contact_Role__c           = 'P';
        con.AccountId                 = acc.Id;
        insert con;
        
        AccountContactJunction__c acj = new AccountContactJunction__c();
        acj.Account__c                = acc.Id;
        acj.Contact__c                = con.Id;
        acj.Name                      = 'Test Name';
        insert acj;
        
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
        
        //   insert new CaseNumber__c(SetupOwnerId=UserInfo.getOrganizationId(), Case_Number__c=1);
        
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
                AcctSeed__Default_Bank_Account__c = glAccounts[0].Id,
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
                AcctSeed__Default_Bank_Account__c = glAccounts[0].Id,
                AcctSeed__Default_Billing_Format__c = billingFormats[0].Id,
                AcctSeed__Billing_Outstanding_Statement_Format__c = billingFormats[2].Id,
                AcctSeed__Billing_Activity_Statement_Format__c = billingFormats[3].Id,
                AcctSeed__Default_Purchase_Order_Format__c = billingFormats[5].id,
                AcctSeed__Default_Packing_Slip_Format__c  = billingFormats[4].id
            )
        );
        
        insert ledgers;
        /*
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
*/           
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
        geo.Region_Factor_Value__c    = 0.87;
        geo.County__c                 = county.Id;
        insert geo;
        
        
        
        
        Policy__c pol                 = new Policy__c();
        pol.RecordTypeId              = Schema.SObjectType.Policy__C.getRecordTypeInfosByName().get('Policy').getRecordTypeId();
        pol.Name                      = 'Test';
        pol.Status__c                 = 'Bound';
        pol.Account__c                = acc.Id;
        pol.Opportunity__c            = opp.Id;
        pol.Effective_Date__c         = System.today().adddays(-1);
        pol.Expiration_Date__c        = System.today().addMonths(3);
        pol.Cancel_Date__c            = null;
        pol.SCH_Mod__c                = 1.00;
        pol.County__c                 = geo.Id;
        pol.Renewal_Type__c           = 'Regular Renewal';
        pol.Premium__c                = 120;
        pol.Renew_Application__c      = True;
        pol.Reason__c                 = 'Bad value';
        pol.ERE_Date__c 			  = date.today();
        insert pol;
        
        system.debug('pol-------'+pol);
        
    }
    
    @isTest 
    static void fetchPolicy(){
        
        BulkRenewalScreenController Ctrl = new BulkRenewalScreenController();
        Ctrl.samplePolicy.Effective_Date__c = null;
        Ctrl.samplePolicy.Expiration_Date__c = null;
        Ctrl.fetchPolicy();
    }
    
    @isTest 
    static void fetchPolicy_1(){
        
        BulkRenewalScreenController Ctrl = new BulkRenewalScreenController();
        Ctrl.samplePolicy.Effective_Date__c = null;
        Ctrl.samplePolicy.Expiration_Date__c = null;
        Ctrl.hasCancelled = null;
        Ctrl.fetchPolicy();
    }
    
    @isTest 
    static void fetchPolicy_2(){
        
        BulkRenewalScreenController Ctrl = new BulkRenewalScreenController();
        Ctrl.searchFirmName = null;
        Ctrl.fetchPolicy();
    }
    
    @isTest 
    static void fetchPolicy_3(){
        
        BulkRenewalScreenController Ctrl = new BulkRenewalScreenController();
        Ctrl.searchFirmName = null;
        Ctrl.samplePolicy.Effective_Date__c = null;
        Ctrl.fetchPolicy();
    }
    
    @isTest 
    static void fetchPolicy_4(){
        
        BulkRenewalScreenController Ctrl = new BulkRenewalScreenController();
        Ctrl.searchFirmName = null;
        Ctrl.samplePolicy.Effective_Date__c = null;
        Ctrl.samplePolicy.Expiration_Date__c = null;
        Ctrl.searchRenewalType = 'Test';
        Ctrl.fetchPolicy();
    }
    
    @isTest 
    static void fetchPolicy_5(){
        
        BulkRenewalScreenController Ctrl = new BulkRenewalScreenController();
        Ctrl.searchFirmName = null;
        Ctrl.samplePolicy.Effective_Date__c = null;
        Ctrl.samplePolicy.Expiration_Date__c = null;
        Ctrl.searchRenewalType = null;
        Ctrl.premium = 1;
        Ctrl.fetchPolicy();
    }
    
    @isTest 
    static void fetchPolicy_P(){
         Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        list<Policy__c> listPol =[select id from Policy__c];
        Policy__c testing = listPol[0];
        
        
        Policy__c testnewPol = new policy__c();
        testnewPol.Account__c=acc.id;
        testnewPol.Effective_Date__c= date.today();
        testnewPol.ERE_Date__c=Null;
        insert testnewPol;
        
        Test.StartTest();
        BulkRenewalScreenController.BulkRenewalScreenControllerWrapper testwrap1 = new BulkRenewalScreenController.BulkRenewalScreenControllerWrapper();
  			testwrap1.policy = listPol[0];
        	testwrap1.isSelected =true;
        
        BulkRenewalScreenController.BulkRenewalScreenControllerWrapper testwrap2 = new BulkRenewalScreenController.BulkRenewalScreenControllerWrapper();
  			testwrap2.policy = testnewPol;
        	testwrap2.isSelected =true;
        
        List<BulkRenewalScreenController.BulkRenewalScreenControllerWrapper> MyWrapList = new List<BulkRenewalScreenController.BulkRenewalScreenControllerWrapper>();
           MyWrapList.add(testwrap1);
         MyWrapList.add(testwrap2);
        
        BulkRenewalScreenController Ctrl = new BulkRenewalScreenController();
        
        Ctrl.searchedResults = MyWrapList;
         Ctrl.renewMassPoliciesFunc();
        Ctrl.searchFirmName ='test';
        Ctrl.samplePolicy.Effective_Date__c = null;
        Ctrl.samplePolicy.Expiration_Date__c = null;
        Ctrl.searchRenewalType = null;
        //Ctrl.samplePolicy = testing;
        Ctrl.selectedUnderWriter = acc.id;
        Ctrl.premium = 1;
        Ctrl.renewMassPoliciesFunc();
        Ctrl.fetchPolicy();
        
        
          Test.StopTest();
        
       /* BulkRenewalScreenController Ctrl = new BulkRenewalScreenController();
        Ctrl.searchedResults = 
        Ctrl.searchFirmName ='';
        Ctrl.samplePolicy.Effective_Date__c = null;
        Ctrl.samplePolicy.Expiration_Date__c = null;
        Ctrl.searchRenewalType = null;
        //Ctrl.samplePolicy = testing;
        Ctrl.selectedUnderWriter = acc.id;
        Ctrl.premium = 1;
        Ctrl.fetchPolicy();
        
        */
    }
    
      
    @isTest 
    static void fetchPolicy_6(){
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        BulkRenewalScreenController Ctrl = new BulkRenewalScreenController();
        Ctrl.searchFirmName = null;
        Ctrl.samplePolicy.Effective_Date__c = null;
        Ctrl.samplePolicy.Expiration_Date__c = null;
        Ctrl.searchRenewalType = null;
        Ctrl.premium = null;
        Ctrl.selectedUnderWriter = acc.id;
        
        Ctrl.fetchPolicy();
    }
    
    @isTest 
    static void fetchPolicy_7(){
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        BulkRenewalScreenController Ctrl = new BulkRenewalScreenController();
        Ctrl.searchFirmName = null;
        Ctrl.samplePolicy.Effective_Date__c = null;
        Ctrl.samplePolicy.Expiration_Date__c = null;
        Ctrl.searchRenewalType = null;
        Ctrl.premium = 1;
        Ctrl.selectedUnderWriter = acc.id;
        
        Ctrl.fetchPolicy();
    }
    
  
    @isTest static void testMethod1() {
        
        List<Account> lstAccount = [select id from account];
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        BulkRenewalScreenController objBulk = new BulkRenewalScreenController();
        
        BulkRenewalScreenController.BulkRenewalScreenControllerWrapper objWrap = new BulkRenewalScreenController.BulkRenewalScreenControllerWrapper();
        objWrap.policy = policies[0];
        //  objWrap.isSelected = True;
        
        objBulk.searchFirmName = 'Test';
        objBulk.searchExpirationStart = System.today().addDays(1);
        objBulk.searchExpirationEnd  = System.today().addDays(3);
        objBulk.searchRenewalType  = 'Regular Renewal';
        objBulk.premium = 123;
        objBulk.hasCancelled = 'No';
        
        objBulk.fetchPolicy();
        objBulk.radioName = 'hasCancelled';
        objBulk.updateRadioValues();
        objBulk.renewMassPoliciesFunc();
        objBulk.getUnderwriter();
        objBulk.getRenewalType();
        
    }
    @isTest static void testMethod2() {
        
        List<Account> lstAccount = [select id from account];
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        BulkRenewalScreenController objBulk = new BulkRenewalScreenController();
        
        BulkRenewalScreenController.BulkRenewalScreenControllerWrapper objWrap = new BulkRenewalScreenController.BulkRenewalScreenControllerWrapper();
        objWrap.policy = policies[0];
        // objWrap.isSelected = True;
        
        objBulk.searchFirmName = 'Test';
        objBulk.searchExpirationStart = System.today().addDays(1);
        objBulk.searchExpirationEnd  = System.today().addDays(3);
        objBulk.searchRenewalType  = 'Regular Renewal';
        objBulk.premium = 123;
        objBulk.hasCancelled = 'No';
        
        objBulk.fetchPolicy();
        objBulk.radioName = 'hasBlock';
        objBulk.updateRadioValues();
        objBulk.renewMassPoliciesFunc();
        objBulk.getUnderwriter();
        objBulk.getRenewalType();
        
    }
    
    @isTest static void testMethod3() {
        
        List<Account> lstAccount = [select id from account];
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        BulkRenewalScreenController objBulk = new BulkRenewalScreenController();
        
        BulkRenewalScreenController.BulkRenewalScreenControllerWrapper objWrap = new BulkRenewalScreenController.BulkRenewalScreenControllerWrapper();
        objWrap.policy = policies[0];
        // objWrap.isSelected = True;
        
        objBulk.searchFirmName = 'Test';
        objBulk.searchExpirationStart = System.today().addDays(1);
        objBulk.searchExpirationEnd  = System.today().addDays(3);
        objBulk.searchRenewalType  = 'Regular Renewal';
        objBulk.premium = 123;
        objBulk.hasCancelled = 'No';
        
        objBulk.fetchPolicy();
        objBulk.radioName = 'hasOpenClaim';
        objBulk.updateRadioValues();
        objBulk.renewMassPoliciesFunc();
        objBulk.getUnderwriter();
        objBulk.getRenewalType();
        
    }
    @isTest static void testMethod4() {
        
        List<Account> lstAccount = [select id from account];
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        BulkRenewalScreenController objBulk = new BulkRenewalScreenController();
        
        BulkRenewalScreenController.BulkRenewalScreenControllerWrapper objWrap = new BulkRenewalScreenController.BulkRenewalScreenControllerWrapper();
        objWrap.policy = policies[0];
        // objWrap.isSelected = True;
        
        objBulk.searchFirmName = 'Test';
        objBulk.searchExpirationStart = System.today().addDays(1);
        objBulk.searchExpirationEnd  = System.today().addDays(3);
        objBulk.searchRenewalType  = 'Regular Renewal';
        objBulk.premium = 123;
        objBulk.hasCancelled = 'No';
        
        objBulk.fetchPolicy();
        objBulk.radioName = 'hasPastClaim';
        objBulk.updateRadioValues();
        objBulk.renewMassPoliciesFunc();
        objBulk.getUnderwriter();
        objBulk.getRenewalType();
        
    }
    @isTest static void testMethod5() {
        
        List<Account> lstAccount = [select id from account];
        List<Policy__c> policies = [SELECT Id,Account__c FROM Policy__c];
        BulkRenewalScreenController objBulk = new BulkRenewalScreenController();
        
        BulkRenewalScreenController.BulkRenewalScreenControllerWrapper objWrap = new BulkRenewalScreenController.BulkRenewalScreenControllerWrapper();
        objWrap.policy = policies[0];
        // objWrap.isSelected = True;
        
        objBulk.searchFirmName = 'Test';
        objBulk.searchExpirationStart = System.today().addDays(1);
        objBulk.searchExpirationEnd  = System.today().addDays(3);
        objBulk.searchRenewalType  = 'Regular Renewal';
        objBulk.premium = 123;
        objBulk.hasCancelled = 'No';
        
        objBulk.fetchPolicy();
        objBulk.radioName = 'hasPendingApplication';
        objBulk.updateRadioValues();
        objBulk.renewMassPoliciesFunc();
        objBulk.getUnderwriter();
        objBulk.getRenewalType();
        
    }
    
    @isTest static void testMethod6() {
        
        BulkRenewalScreenController.BulkRenewalScreenControllerWrapper objWrap = new BulkRenewalScreenController.BulkRenewalScreenControllerWrapper();
        objWrap.isSelected = True;
        
    }
    
    
    
}