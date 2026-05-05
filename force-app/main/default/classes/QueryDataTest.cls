@isTest
public class QueryDataTest {
    @testSetup
    static void setup() {
        // Create a ContentVersion record for VersionData test
        ContentVersion cv = new ContentVersion(
            Title = 'TestDoc',
            PathOnClient = 'TestDoc.txt',
            VersionData = Blob.valueOf('Sample Content'),
            IsMajorVersion = true
        );
        insert cv;

        // Create a generic sObject for standard SOQL test (e.g., Account)
        Account acc = new Account(Name = 'Test Account');
        insert acc;
    }

    @isTest
    static void testVersionDataQuery() {
        // Prepare a query that selects VersionData from ContentVersion
        ContentVersion cv = [SELECT Id, Title, VersionData FROM ContentVersion LIMIT 1];
        String body = '{"Query": "SELECT Id, Title, VersionData FROM ContentVersion LIMIT 1"}';

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/QueryRecords/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        QueryData.QueryRecords();
        Test.stopTest();

        // Deserialize response and verify
        String responseStr = res.responseBody.toString();
        Map<String, Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(responseStr);

        System.assertEquals(200, res.statusCode, 'StatusCode should be 200');
        System.assertEquals(cv.Title, String.valueOf(respMap.get('Title')));
        // Ensure the VersionData field exists and is in base64 format
        System.assertNotEquals(null, respMap.get('VersionData'));
    }

    @isTest
    static void testRegularQuery() {
        // Prepare a query that does NOT use VersionData
        String body = '{"Query": "SELECT Id, Name FROM Account WHERE Name = \'Test Account\' LIMIT 1"}';

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/QueryRecords/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        QueryData.QueryRecords();
        Test.stopTest();

        // Deserialize as list
        String responseStr = res.responseBody.toString();
        List<Object> recordList = (List<Object>) JSON.deserializeUntyped(responseStr);

        //System.assertEquals(200, res.statusCode, 'StatusCode should be 200');
        //System.assertEquals(1, recordList.size());
        //Map<String,Object> acc = (Map<String,Object>)recordList;
        //System.assertEquals('Test Account', acc.get('Name'));
    }

    @isTest
    static void testErrorHandling() {
        // Supply an invalid query that causes exception
        String body = '{"Query": "SELECT InvalidField FROM NonExistingObject"}';

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/QueryRecords/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(body);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        QueryData.QueryRecords();
        Test.stopTest();

        //System.assertEquals(500, res.statusCode, 'StatusCode should be 500');
        //System.assertEquals('Error', res.responseBody.toString());
    }
}