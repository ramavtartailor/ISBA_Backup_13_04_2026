@isTest
private class PolicyLawyerEditErrorExt_Test {
    
    @testSetup static void setup() {
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        insert calimset;
        
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
        
        // Insert Account 
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        // Insert Account 2        
        Account acc1                   = TestDataFactory.createAccounts('Test Account');
        acc1.AccountNumber             = '123456';
        acc1.Vendor_Account__c         = true;
        //insert acc1;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        //List<AcctSeed__GL_Account__c> glAccounts = TestDataFactory.createGLAccounts();        
        //insert glAccounts;
        
        List<AcctSeed__Billing_Format__c> billingFormats = TestDataFactory.createBillingFormats();        
        insert billingFormats ;
        
        AcctSeed__Accounting_Period__c lstPeriod = TestDataFactory.createAcctPeriod();
        insert lstPeriod;
        
        List<AcctSeed__Ledger__c> ledgers = TestDataFactory.createLedgers(glAccounts[0].id,billingFormats[0].id,billingFormats[1].id,billingFormats[2].id,billingFormats[3].id,billingFormats[4].id);
        insert ledgers;
        
        //AcctSeed__Accounting_Settings__c settings = TestDataFactory.createAccountsetting(ledgers[0].id,glAccounts[0].Id,glAccounts[1].Id,billingFormats[0].Id);
        //insert settings;
        
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
        
        Master_Factor__c masterFactor = new Master_Factor__c(Factor_Type__c='Step Rate', Default__c=true,From_Date__c= Date.today(),
                                                             To_Date__c= Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day()),
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
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorNew.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Policy__c pol = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        pol.Limit__c = coverageFactorObj.Id;
        pol.Deductible_ID__c = dedFactorObj.Id;
        insert pol;
        
         Policy__c pol2 = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Application');
        pol2.Limit__c = coverageFactorObj.Id;
        pol2.Deductible_ID__c = dedFactorObj.Id;
        insert pol2;
        
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
        
        AOP_Factor__c aopFactor = new AOP_Factor__c(Master_Factor__c=masterFactorNew.Id,Name='Test AOP Factor');
        insert aopFactor;
        
        
    }
    
    @isTest static void testMethod1() {
        
        List<Policy__c> policies = [SELECT Id,RecordType.Name,Account__c FROM Policy__c where RecordType.Name =: 'Application'];
        List<Contact> conList = [SELECT Id FROM Contact];
        Policy__c  policy = policies[0];
        
        AccountContactJunction__c junc = new AccountContactJunction__c();
        junc.Account__c = policies[0].Account__C;
        junc.Contact__c = conList[0].Id;
        insert junc;
        
        Policy_Lawyer__c law = new Policy_Lawyer__c();
        law.Policy__c = policies[0].Id;
        law.Active__c = true;
        law.Account__c = policies[0].Account__c;
        law.Prior_Act_Date__c = date.today();
        law.Rate_At__c = 100;
        law.Lawyer__c = junc.Id;
        insert law; 
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(law);
        
        PolicyLawyerEditErrorExt Ctrl = new PolicyLawyerEditErrorExt(sc);
        
        PageReference pageRef = Page.PolicyLawyerError;
        pageRef.getParameters().put('Id', law.Id);
        system.Test.setCurrentPage(pageRef);
        ctrl.getRedir();
        
        Test.stopTest();
    }
    
     @isTest static void testMethod2() {
        
        List<Policy__c> policies = [SELECT Id,RecordType.Name,Account__c FROM Policy__c where RecordType.Name =: 'Policy'];
        List<Contact> conList = [SELECT Id FROM Contact];
        Policy__c  policy = policies[0];
        
        AccountContactJunction__c junc = new AccountContactJunction__c();
        junc.Account__c = policies[0].Account__C;
        junc.Contact__c = conList[0].Id;
        insert junc;
        
        Policy_Lawyer__c law = new Policy_Lawyer__c();
        law.Policy__c = policies[0].Id;
        law.Active__c = true;
        law.Account__c = policies[0].Account__c;
        law.Prior_Act_Date__c = date.today();
        law.Lawyer__c = junc.Id;
        insert law; 
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(law);
        
        PolicyLawyerEditErrorExt Ctrl = new PolicyLawyerEditErrorExt(sc);
        
        PageReference pageRef = Page.PolicyLawyerError;
        pageRef.getParameters().put('Id', law.Id);
        system.Test.setCurrentPage(pageRef);
        ctrl.getRedir();
        
        Test.stopTest();
    }
    
}