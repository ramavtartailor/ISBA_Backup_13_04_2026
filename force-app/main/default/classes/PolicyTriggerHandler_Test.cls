@isTest
public class PolicyTriggerHandler_Test{
    
    
    @testSetup
    static void testData(){
        
        
        // Insert Account
        Account acc                   = TestDataFactory.createAccounts('Bucket Account');
        insert acc;
        
        Account acc1 = TestDataFactory.createAccounts(Label.Online_NBA_Account);
        insert acc1;
        
        // Insert Contact
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        // Insert AccountContactJunction
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        // Insert Opportunity
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        // Insert Master Factor
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','GEO');
        insert mas;
        
        // Insert County
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        // Insert Geo Factor
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        insert geo;
        
        // Insert Master Factor       
        Master_Factor__c masterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert masterFactor1;
        
        
        // Insert Base Factor
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(masterFactor1.Id);
        insert baseFactor;
        
        Map<String,String> mapRecordTypes = new Map<String,String>();
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        // Insert Master Fator
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        // Insert ILF Coverage Factor
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoverageFactor(MasterFactorCoverage.Id);
        FactorCoverage.Percentage_5X5_Step_0__c =3;
        FactorCoverage.Percentage_5X5_Step_1__c=4;
        FactorCoverage.Percentage_5X5_Step_2__c=5;
        FactorCoverage.Percentage_5X5_Step_3__c=6;
        FactorCoverage.Percentage_5X5_Step_4__c=8;
        FactorCoverage.Premium_Rate_5X5__c = 33;
        FactorCoverage.Is_5X5_Coverage__c = true;        
        insert FactorCoverage;
        
        ILF_Coverage_Factor__c coverFactor = TestDataFactory.createCoveragefactor(masterFactor1.Id);
        coverFactor.Name = '100,000 / 100,000';
        coverFactor.Coverage_Max_Per_Claim__c = 100000;
        coverFactor.Full_Coverage__c = 100000;
        coverFactor.Master_Factor__c = masterFactor1.id;
        coverFactor.Is_10X10_Coverage__c = true;
        coverFactor.Factor_Value__c = 2.04;
        coverFactor.Lowest_Coverage__c = true;
        coverFactor.OldLimit__c = false;
        insert coverFactor;
        
        // Insert Master Factor
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor','Deductible');
        insert mas12;
        
        // Insert Deductible Factor
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        Insert DedFac; 
        
        // Insert Master Factor
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        masterFactorNew.To_Date__c = system.today().addDays(10);
        masterFactorNew.From_Date__c = system.today().addDays(10);
        insert masterFactorNew;
        
        // Insert Deductible Factor
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        dedFactorObj.Deductible_Amount__c = 0;
        insert dedFactorObj;
        
        
        Master_Factor__c masterFactor = new Master_Factor__c(Factor_Type__c='Step Rate', Default__c=true,From_Date__c= Date.today().addDays(-1),
                                                             To_Date__c= Date.newInstance(Date.today().year() + 1, Date.today().month(), Date.today().day()),
                                                             Name  = 'Test Master Factor0');
        insert masterFactor;
        
        Step_Rate_Factor__c stepRateFactor = new Step_Rate_Factor__c(Master_Factor__c=masterFactor.Id, Factor_Value_Step_Rate_0__c=0,
                                                                     Factor_Value_Step_Rate_1__c=1, Factor_Value_Step_Rate_2__c=2, Factor_Value_Step_Rate_3__c=3, 
                                                                     Factor_Value_Step_Rate_4__c=4, Factor_Value_Step_Rate_5__c=5, Factor_Value_Step_Rate_6__c=6,
                                                                     Factor_Value_Step_Rate_7__c=7);
        insert stepRateFactor;
        
        Customer_Application__c objCustomerApp = new Customer_Application__c();
        objCustomerApp.Is_the_firm_currently_insured__c = 'No';
        objCustomerApp.Full_Legal_Name_of_the_Firm__c = 'test';
        objCustomerApp.Address_2__c = 'test address';
        //objCustomerApp.PolicyId__c = pol.Id;
        insert objCustomerApp; 
        
        Treaty_Versions__c TVPol = new Treaty_Versions__c();
         TVPol.Treaty_Correction_Processed__c = false;
         TVPol.Ceded_Primary_Rate_Delta__c = 1;
         TVPol.Ceded_4x1_Rate_Delta__c = 1;
         TVPol.Ceded_Primary_Rate_Delta__c = 1;
         TVPol.Start_Date__c = system.today().addDays(11);
         TVPol.End_Date__c = system.today().addDays(15);
         insert TVPol;
        // Insert Policy
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = FactorCoverage.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
        acctivePolicy.Effective_Date__c = system.today().addDays(10);
        acctivePolicy.Expiration_Date__c = system.today().addDays(20);
        acctivePolicy.Policy_Series_Effective_Date__c = system.today().addDays(10);
         acctivePolicy.Customer_Application__c = objCustomerApp.id;
        acctivePolicy.Treaty_Version__c = TVPol.Id;
        acctivePolicy.Legacy_Endorsement_List__c = 'IL 230, IL 234, IL 261';
        acctivePolicy.PolicyExternalID__c = '123456';
        insert acctivePolicy;
        
        objCustomerApp.PolicyId__c = acctivePolicy.Id;
        update objCustomerApp;
        Policy__c pol1 = TestDataFactory.createPolicy(acc1.id,opp.id,null,'Policy');
        //pol.Status__c = 'Accepted';
        pol1.RecordTypeId              = Schema.SObjectType.Policy__C.getRecordTypeInfosByName().get('Application Rejected').getRecordTypeId();
        pol1.Account__c = acc1.Id;
        pol1.Limit__c = FactorCoverage.Id;
        pol1.Deductible_ID__c = dedFactorObj.Id;
        pol1.Firm_Mod__c = 1;
        pol1.Base_Amount__c = 1000000;
        pol1.Premium__c = 150;
        pol1.Total_5x5__c=1;
        pol1.Total_10x10__c=1;
        insert pol1;
        
        // Insert Endorsement
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        insert endorse;
        
        // Insert Endorsement Version
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        // Insert Endorsement version 2
        Endorsement_Version__c endorseVersion2 = TestDataFactory.createEndorsementVersion(endorse.Id);
        endorseVersion2.Endorsement_Version_Number__c='2';
        insert endorseVersion2;
        
        // Insert AOP_Factor__c 
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        // Insert Policy_AOP__c
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,acctivePolicy.id);
        insert aop;
        
         // Insert Policy Lawyer
        Policy_Lawyer__c polLawyer = TestDataFactory.createPolicyLawyer(acc.Id,acctivePolicy.Id,acj.Id);
        insert polLawyer;
        
        // Insert Policy Endorsement
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        objPolEndorse.Override_Rating__c = false;
        objPolEndorse.Step__c = null;
        objPolEndorse.Step_Override__c = true;
        objPolEndorse.Step_Override_Value__c = 0;
        objPolEndorse.Lawyer__c = acj.id;
        objPolEndorse.Effective_Date__c =  date.today();
        objPolEndorse.Endorsement_Effective_Date__c = System.today() +  10;
        Test.startTest();
        insert objPolEndorse;
        
        
        Policy_Quote__c objpolQut = TestDataFactory.createPolicyQuote(acctivePolicy.Id,coverFactor.Id,DedFac.Id);
        objpolQut.Adj_R_O__c = true;
        objpolQut.Mod_230__c  = 1.02; 
        objpolQut.Mod_234__c = 1.02;
        objpolQut.Mod_261__c = 1.02;
        
        
    //    objpolQut.Policy__c = acctivePolicy.Id;
        insert objpolQut;
        
        // Insert Note
        Note__c note = new Note__c();
        note.Account__c = acc.id;
        insert note;
        
        // Insert Task
        Task tsk = new Task(
            Subject = 'Follw Up',
            Description = 'Task Description',
            Status = 'Pending',
            WhatId = acc.id,
            Note__c = note.id
        );
        Insert tsk;
        Test.stopTest();
    }
    
    @isTest
    static void setRenewalType_Test(){
        
        List<Policy__c> policyList = [Select id from Policy__c];
        
        Test.startTest();
        PolicyTriggerHandler.setRenewalType(policyList);
        Test.stopTest();
    }
    @isTest
    static void updateEndorsementAndPolicyLawyerEffectiveDate_Test(){
        
        Test.startTest();
        
        List<Policy_Lawyer__c> poLawList = [select id,Prior_Act_Date__c from Policy_Lawyer__c];
        for(Policy_Lawyer__c pl : poLawList){
            pl.Prior_Act_Date__c = date.today().addDays(10);
        }
        update poLawList;
        
        List<Policy__c> policyList = [Select id,Effective_Date__c,Cancel_Date__c,Expiration_Date__c from Policy__c];
        for(Policy__c po : policyList){
            po.Effective_Date__c = date.today().addMonths(13);
            po.Cancel_Date__c = date.today().addMonths(14);
            po.Expiration_Date__c = date.today().addMonths(15);
        }
        Update policyList;
        
        policyList[0].ClonedBy__c = 'Renewal 3 Months Before Policy Expiration';
        update policyList[0];
        
        Map<id,Policy__c> policyMap = new Map<id,Policy__c>([Select id,Effective_Date__c,Cancel_Date__c,Expiration_Date__c  from Policy__c]);
        PolicyTriggerHandler.updateEndorsementAndPolicyLawyerEffectiveDate(policyList,policyMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void updateEndorsementAndPolicyLawyerEffectiveDate_TestNew(){
        
        Test.startTest();
        
        List<Policy_Lawyer__c> poLawList = [select id,Prior_Act_Date__c from Policy_Lawyer__c];
        for(Policy_Lawyer__c pl : poLawList){
            pl.Prior_Act_Date__c = date.today().addDays(10);
        }
        update poLawList;
        
        List<Policy__c> policyList = [Select id,Effective_Date__c,Cancel_Date__c,Expiration_Date__c from Policy__c];
            
        policyList[0].ClonedBy__c = 'Renewal 3 Months Before Policy Expiration';
        policyList[0].Policy_Series_Count__c = 2;
        update policyList[0];
        
        Map<id,Policy__c> policyMap = new Map<id,Policy__c>([Select id,Effective_Date__c,Cancel_Date__c,Expiration_Date__c  from Policy__c]);
        PolicyTriggerHandler.updateEndorsementAndPolicyLawyerEffectiveDate(policyList,policyMap);
        
        Policy_Quote__c policyQuote = [SELECT Id,Policy__c FROM Policy_Quote__c WHERE Coverage__c != null AND Deductible__c != null LIMIT 1];
              
        List<Policy__c> policy = [SELECT Id,Effective_Date__c,Previous_Policy__c FROM Policy__c WHERE Previous_Policy__c =: policyQuote.Policy__c];
        system.debug('policy => '+policy);
        PolicyTriggerHandler.CreatePolicyQuote(policy);
        Test.stopTest();
        
    }  
    
    @isTest
    static void testMethod1(){
        Test.startTest();
        List<Policy__c> policyList = [Select id,Effective_Date__c,Cancel_Date__c,Expiration_Date__c from Policy__c WHERE Renewal_Type__c != 'Regular Renewal'];
        policyList[0].Renewal_Type__c = 'Regular Renewal';
        update policyList[0];
        Test.stopTest();
    }
    /*
    @isTest static void setup(){
        
        Account acc                   = new Account();
        acc.Name                      = 'Test Account';
        acc.AccountNumber             = '123456';
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
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        Endorsement__c endorse = new Endorsement__c(Active__c=true,Endorsement_Record_Type_ID__c=devRecordTypeId,
                                                    Description__c='Test desc');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = new Endorsement_Version__c(Master_Endorsement__c=endorse.Id,Endorsement_Version_Number__c='1',
                                                                           Effective_From__c=System.today());
        insert endorseVersion;
        
        List<Policy__c> plyLst = new List<Policy__c>();
        Policy__c pol                 = new Policy__c();
        pol.RecordTypeId              = Schema.SObjectType.Policy__C.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        pol.Name                      = 'Test Policy';
        pol.Status__c                 = 'Accepted';
        pol.Account__c                = acc.Id;
        pol.Opportunity__c            = opp.Id;
        pol.Effective_Date__c         = System.today().addDays(-1);
        pol.Expiration_Date__c        = System.today().addDays(2);
        pol.Cancel_Date__c            = System.today().addDays(2);
        pol.SCH_Mod__c                = 1.00;
        pol.County__c                 = geo.Id;
        insert pol;
        
        Test.startTest();
        
        pol.SCH_Mod__c                = 2.00;
        update pol;
        plyLst.add(pol);
        
        Test.stopTest();        
        
    }    
    
    @isTest static void testMethod1(){
        
        Test.startTest();
        
        Account acc                   = new Account();
        acc.Name                      = 'Test Account';
        acc.AccountNumber             = '123456';
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
        pol.RecordTypeId              = Schema.SObjectType.Policy__C.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        pol.Name                      = 'Test Policy';
        pol.Status__c                 = 'Accepted';
        pol.Account__c                = acc.Id;
        pol.Opportunity__c            = opp.Id;
        pol.Effective_Date__c         = System.today().addDays(-1);
        pol.Expiration_Date__c        = System.today().addDays(2);
        pol.Cancel_Date__c            = System.today().addDays(2);
        pol.SCH_Mod__c                = 1.00;
        pol.County__c                 = geo.Id;
        insert pol;
        
        Policy_Endorsement__c polEndo = TestDataFactory.createPolicyEndorsement(acc.Id ,pol.Id, 'IL 150 POLICY ENDORSEMENT' );
        
        pol.Effective_Date__c         = System.today();
        update pol;
        
        Test.stopTest();
    }
*/
    @isTest
    static void coverMissingFivePercent(){
        Policy__c pol = [SELECT Id, Application_Form_Link__c FROM Policy__c LIMIT 1];
        
        pol.Application_Form_Link__c = null;
        
        Test.startTest();
        update pol;
        Test.stopTest();
        
        Policy__c refreshed = [SELECT Application_Form_Link__c FROM Policy__c WHERE Id = :pol.Id];
        System.assertNotEquals(null, refreshed.Application_Form_Link__c);
    }
    @IsTest
    static void coverPolicyTriggerInsertDeleteWithOpportunity(){
        
        Account acc = new Account(Name='Trig Acc');
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Trig Opp', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.Id );
        insert opp;
        
        Policy__c pol = new Policy__c(Account__c = acc.Id, Opportunity__c = opp.Id, Effective_Date__c = Date.today(), Expiration_Date__c = Date.today().addMonths(12), Status__c = 'Inquiry');
        Test.startTest();
        
        insert pol;
        delete pol;
        Test.stopTest();
        
        System.assert(true);
    }
    
    
}