@isTest
private class CreateAndRetriveContentVersion_test {
    @testSetup
    static void setupData() {

        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        opp.StageName                 = 'Application Sent';
        opp.CloseDate                 = Date.today();
        insert opp;
        
         Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Step Rate');
        insert mas;
        ILF_Coverage_Factor__c ilfCoverageLowest = TestDataFactory.createCoveragefactor(mas.id);
        insert ilfCoverageLowest;
        County__c county = TestDataFactory.createCounty();
        insert county ;
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas.Id);
        Insert DedFac;
         Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.id,county.Id);
        insert geo;

        ContentVersion cv = TestDataFactory.createContentVersoion('TestFile','TestFile.txt');
        cv.Document_Type__c =  'Certificate Of Insurance';
        insert cv;
         Policy__c pol                 = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Application');
        pol.Status__c                 = 'Accepted';
        pol.SCH_Mod__c                = 1.00;
        pol.Policy_Document_Version__c    = '1/18';
        pol.Premium__c                 = 100;
        pol.Base_Amount__c = 123;
        pol.Firm_Mod__c = 112;
        pol.Limit__c = ilfCoverageLowest.id;
        pol.Deductible_ID__c = DedFac.id;
        pol.Premium_Amount__c = 120;
        insert pol;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> AllobjLink = new List<ContentDocumentLink>();
        
        for(ContentDocument Obj : documents){
            List<ContentDocumentLink> objLink = TestDataFactory.createContentDocumentLink(Pol.id,Obj.Id);
            AllobjLink.addAll(objLink);
        }
        
        insert AllobjLink;
        
    }

    @isTest
    static void testPostRecords_CreateContentVersion() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createContentVersion/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"type":"Create","fileName":"TestFile.txt","vaesionData":"' + EncodingUtil.base64Encode(Blob.valueOf('TestData')) + '"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        CreateAndRetriveContentVersion.postRecords();
        Test.stopTest();
        
        
    }

    @isTest
    static void testPostRecords_QueryContentVersion() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createContentVersion/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"type":"Query","relatedRecordId":"' + [SELECT Id FROM Account LIMIT 1].Id + '"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        CreateAndRetriveContentVersion.postRecords();
        Test.stopTest();
        
        
    }

    @isTest
    static void testPostRecords_DeleteContentVersion() {
        ContentDocument cd = [SELECT Id FROM ContentDocument LIMIT 1];
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createContentVersion/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"type":"Deletion","cdId":"' + cd.Id + '"}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        CreateAndRetriveContentVersion.postRecords();
        Test.stopTest();
        
        
    }
     @isTest
    static void testPostRecords_DmlLawyer() {
        List<Account> accList = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2')
        };
        insert accList;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/createContentVersion/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"type":"dmlLawyer","dml":"Upsert","records":' + JSON.serialize(accList) + '}');
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        CreateAndRetriveContentVersion.postRecords();
        Test.stopTest();
        
        
    }
}