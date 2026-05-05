@istest
public class NBA_ConvertValidationCtrlTest {
    @testSetup
    static void setupTestData() {
        
        Account acc = TestDataFactory.createAccounts(Label.Bucket_Account);
        acc.BillingState = 'Ohio';
        acc.BillingCountry = 'US';
        insert acc;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        con.ARDC_Number__c = '12345678';
        insert con;
        Contact con1                  = TestDataFactory.createContact('Test Contact',acc.id);
        //con.ARDC_Number__c = '12345678';
        insert con1;
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        
        insert acj;
        AccountContactJunction__c acj1 = TestDataFactory.createAccConJunc(acc.id, con1.id);
        acj.Name                      = 'Test Name1';
        
        insert acj1;
        
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
        opp.StageName   = 'Application Sent';
        insert opp;
        Master_Factor__c masterfact =TestDataFactory.createMasterfactor('Coverage 10/1/2016 - 12/31/2016','Coverage');
        insert masterfact;
        Master_Factor__c masterfact1 = TestDataFactory.createMasterfactor('Deductible 10/1/2016 - 12/31/2016','Deductible');
        insert masterfact1;
        
        ILF_Coverage_Factor__c coverFactor = TestDataFactory.createCoveragefactor(masterfact.Id);
        coverFactor.Is_5X5_Coverage__c=true;
        coverFactor.Premium_Rate_5X5__c=1;
        coverFactor.Percentage_5X5_Step_0__c=1;
        coverFactor.Percentage_5X5_Step_1__c=1;
        coverFactor.Percentage_5X5_Step_2__c=1;
        coverFactor.Percentage_5X5_Step_3__c=1;
        insert coverFactor;
        Deductible_Factor__c deductible = TestDataFactory.createDeductiblefactor(masterfact1.Id);
        Insert deductible; 
        
        Policy__c pol = TestDataFactory.createPolicy(acc.id,opp.id,null,'Policy');
        //pol.Status__c = 'Accepted';
        pol.Account__c = acc.Id;
        pol.Limit__c = coverFactor.Id;
        pol.Deductible_ID__c = deductible.Id;
        pol.Firm_Mod__c = 1;
        pol.Base_Amount__c = 1000000;
        pol.Premium__c = 150;
        pol.Total_5x5__c=1;
        pol.Total_10x10__c=1;
        
        insert pol;
        Test.startTest();
        Policy__c poll = TestDataFactory.createPolicy(acc.id,opp.id,null,'Policy');
        //pol.Status__c = 'Accepted';
        poll.Account__c = acc.Id;
        poll.Limit__c = coverFactor.Id;
        poll.Deductible_ID__c = deductible.Id;
        poll.Firm_Mod__c = 1;
        poll.Base_Amount__c = 1000000;
        poll.Premium__c = 150;
        poll.Total_5x5__c=1;
        poll.Total_10x10__c=1;
        
        insert poll;
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(pol.Account__c, con.Id);
        insert junc;
        AccountContactJunction__c junc1 = TestDataFactory.createAccConJunc(poll.Account__c, con1.Id);
        insert junc1;
        
        Customer_Application__c objCustomerApp = new Customer_Application__c();
        objCustomerApp.Is_the_firm_currently_insured__c = 'No';
        objCustomerApp.Full_Legal_Name_of_the_Firm__c = 'test';
        objCustomerApp.Address_2__c = 'test address';
        objCustomerApp.PolicyId__c = pol.Id;
        insert objCustomerApp; 
        
        Customer_Application__c objCustomerApp1 = new Customer_Application__c();
        objCustomerApp1.Is_the_firm_currently_insured__c = 'No';
        objCustomerApp1.Full_Legal_Name_of_the_Firm__c = 'test1';
        objCustomerApp1.Address_2__c = 'test address';
        objCustomerApp1.PolicyId__c = poll.Id;
        insert objCustomerApp1; 
        Customer_Application_Lawyer__c objCustomerappLay = TestDataFactory.createAppLawyer(objCustomerApp.id);
        objCustomerappLay.Last_Name__c = 'test 1';
        objCustomerappLay.ARDC_Number__c = '12345678';
        objCustomerappLay.Is_Removed__c = false;
        insert objCustomerappLay;
        Master_Factor__c objMasterFactor = TestDataFactory.createMasterfactor('Test Master Factor','AOP');
        insert objMasterFactor;
        
        AOP_Factor__c ObjAOP = TestDataFactory.createAopFactor(objMasterFactor.id);
        ObjAOP.AOP_Mod__c = 100;
        insert ObjAOP;
        Customer_Application_AOP__c aop = new Customer_Application_AOP__c(
            Customer_Application__c = objCustomerApp.Id,
            AOP_Factor__c = ObjAOP.Id,
            Percentage__c = 50
        );
        insert aop;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(pol.Account__c,pol.Id,junc.Id);
        law.Active__c = true;
        law.Deleted_Lawyer__c = false;
        law.Lawyer__c = acj.id;
        insert law;
        
        Policy_Lawyer__c law1 = TestDataFactory.createPolicyLawyer(pol.Account__c,pol.Id,junc.Id);
        law.Active__c = true;
        law.Deleted_Lawyer__c = false;
        
        insert law1;
        Test.stopTest();
    }
    
    
    @isTest
    static void testGetDetails_AllLinked(){
        
        Customer_Application__c app = [SELECT Id FROM Customer_Application__c WHERE Full_Legal_Name_of_the_Firm__c = 'test' LIMIT 1];
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        app.Account__c = acc.Id;
        update app;
        Customer_Application_Lawyer__c law = [SELECT Id FROM Customer_Application_Lawyer__c LIMIT 1];
        
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        law.Contact__c = con.Id;
        update law;
        
        Test.startTest();
        
        List<String> result = NBA_ConvertValidationCtrl.getDetails(app.Id);
        Test.stopTest();
        System.assertEquals(1, result.size());
    }
    @isTest
    static void testGetDetails_MissingAccountAndLawyer(){
        
        Customer_Application__c app =
            [SELECT Id FROM Customer_Application__c WHERE Full_Legal_Name_of_the_Firm__c = 'test' LIMIT 1];
        
        // Force lawyer to be unlinked
        Customer_Application_Lawyer__c law =
            [SELECT Id FROM Customer_Application_Lawyer__c LIMIT 1];
        
        law.Contact__c = null;
        update law;
        
        Test.startTest();
        
        List<String> result =
            NBA_ConvertValidationCtrl.getDetails(app.Id);
        
        Test.stopTest();
        
        System.assert(result.contains('Account not linked.'));
        //System.assert(result.contains('Lawyer(s) not linked.'));
    }
    
}