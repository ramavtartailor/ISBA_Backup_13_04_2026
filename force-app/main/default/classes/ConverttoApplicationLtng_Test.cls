@isTest (seealldata = true) 
private class ConverttoApplicationLtng_Test { 
    @isTest static void TestMethod1() {
        Test.startTest();
        
            Account acc                   = TestDataFactory.createAccounts('Test Account');
            acc.AccountNumber             = '123456';
            acc.Vendor_Account__c         = true;
            insert acc;
        
            Policy__c pol                 = TestDataFactory.createPolicy(acc.Id,null,null,'Application');
            pol.Status__c                 = 'Application created';
            pol.SCH_Mod__c                = 1.00;
            insert pol;
            
        
        ConverttoApplicationLtng ConApp = new ConverttoApplicationLtng();
        ConverttoApplicationLtng.getProfileName();
        ConverttoApplicationLtng.getCongaMsg(Pol.id);    
        Test.stopTest();
    }

}