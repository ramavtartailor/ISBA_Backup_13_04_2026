@isTest
public class RegenerateCustomerApplicationCtrl_Test {
    @testSetup
    static void setupTestData() {
        Account acc = TestDataFactory.createAccounts(Label.Bucket_Account);
        acc.BillingState = 'Ohio';
        acc.BillingCountry = 'US';
        
        acc.BillingStreet = '123 Test St';
        acc.BillingCity = 'Test City';
        
        //acc.Billing_Address_County__c = 'Test County';
        acc.Phone = '1234567890';
        acc.Website__c = 'http://test.com';
        acc.Establish_Date__c = Date.today();
        insert acc;
        
        Account acc1 = TestDataFactory.createAccounts(Label.Online_NBA_Account);
        insert acc1;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        con.ARDC_Number__c = '12345678';
        insert con;
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        
        insert acj;
         
        
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
        
        Customer_Application__c objCustomerApp = new Customer_Application__c();
        objCustomerApp.Is_the_firm_currently_insured__c = 'No';
        objCustomerApp.Full_Legal_Name_of_the_Firm__c = 'test';
        objCustomerApp.Address_2__c = 'test address';
        //objCustomerApp.PolicyId__c = pol.Id;
        insert objCustomerApp; 
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
        pol.Customer_Application__c = objCustomerApp.id;
        
        
        insert pol;
        
        
        Policy__c pol1 = TestDataFactory.createPolicy(acc1.id,opp.id,null,'Policy');
        //pol.Status__c = 'Accepted';
        pol1.Account__c = acc1.Id;
        pol1.Limit__c = coverFactor.Id;
        pol1.Deductible_ID__c = deductible.Id;
        pol1.Firm_Mod__c = 1;
        pol1.Base_Amount__c = 1000000;
        pol1.Premium__c = 150;
        pol1.Total_5x5__c=1;
        pol1.Total_10x10__c=1;
        insert pol1;
        
        objCustomerApp.PolicyId__c = pol.Id;
        update objCustomerApp;
         
        
        Policy_Quote__c polQuote = new Policy_Quote__c(
            Policy__c = pol.Id,
            Coverage__c = coverFactor.id,
            Deductible__c = deductible.id//,
            //Customer_Application__c = objCustomerApp.id
        );
        insert polQuote;
        
         AccountContactJunction__c junc = TestDataFactory.createAccConJunc(pol.Account__c, con.Id);
        insert junc;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(pol.Account__c,pol.Id,junc.Id);
        law.Active__c = true;
        law.Deleted_Lawyer__c = false;
        law.Lawyer__c = acj.id;
        insert law;
        
    }
     @isTest
    static void testUpdateDetails() {
      
        Policy__c testPolicy = [SELECT Id,Customer_Application__c FROM Policy__c where Customer_Application__c != null LIMIT 1];

        Test.startTest();
        Boolean result = RegenerateCustomerApplicationCtrl.updateDetails(testPolicy.Id);
        try{
            Boolean result1 = RegenerateCustomerApplicationCtrl.updateDetails(null);
        }
        catch(Exception e){
            
        }
        Test.stopTest();

        
    }
}