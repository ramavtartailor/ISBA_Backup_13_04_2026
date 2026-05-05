@isTest
private class InsertPaymentScheduleRecordsTest {

    @isTest
    private static void testTestCase() {
        // Test data setup
        Account acc = new Account();
        acc.Name = 'test';
        acc.BillingState = 'PA';
        acc.BillingCountry = 'USA';
        acc.Email__c = 'test@gmail.com';
        
        /* --------------Insert test------------------------*/
        String jsonBody = '{"Records" : '+JSON.serialize(new List<Account>{acc})+',"Opr": "insert"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestBody =blob.valueOf(jsonBody);
        req.addHeader('Content-Type', 'application/json');
        
        RestContext.request = req;
        RestContext.response = res;
        Test.startTest();
        InsertPaymentScheduleRecords.DMLRecords();
        system.debug(res.statusCode);
        
        // Asserts
        Assert.areEqual(200, res.statusCode, 'Expected Status Code.');
        
        /* --------------Update test------------------------*/
        List<Account> accList= [SELECT Id From Account]; 
		jsonBody = '{"Records" : '+JSON.serialize(accList)+',"Opr": "update"}';
        req.requestBody =blob.valueOf(jsonBody);
        InsertPaymentScheduleRecords.DMLRecords();
        system.debug(res.statusCode);
        
        // Asserts
        Assert.areEqual(200, res.statusCode, 'Expected Status Code.');
        
        /* --------------Upsert test------------------------*/
        //Catch Test 
        Contact con = new Contact();
        con.FirstName                 = 'Test';
        con.Type__c                   = 'Lawyer';
        con.Contact_Role__c           = 'P';
        con.AccountId                 = acc.Id;
        jsonBody = '{"Records" : '+JSON.serialize(new List<Contact>{con})+',"Opr": "upsert"}';
        req.requestBody =blob.valueOf(jsonBody);
        
        InsertPaymentScheduleRecords.DMLRecords();
        
        // Assert
        Assert.areEqual(500, res.statusCode, 'Expected Status Code.');
        
        /* --------------Delete test------------------------*/
        
        jsonBody = '{"Records" : '+JSON.serialize(accList)+',"Opr": "delete"}';
        req.requestBody =blob.valueOf(jsonBody);
        InsertPaymentScheduleRecords.DMLRecords();
        system.debug(res.statusCode);
        
        // Asserts
        Assert.areEqual(200, res.statusCode, 'Expected Status Code.');
        
        Test.stopTest();
    }

}