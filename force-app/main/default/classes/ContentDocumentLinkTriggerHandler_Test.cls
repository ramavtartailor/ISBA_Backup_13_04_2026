@isTest
public class ContentDocumentLinkTriggerHandler_Test {
    @isTest static void testMethod1(){
        Test.startTest();
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Note__c objNote = TestDataFactory.createNoteForAccount(acc.id,'AAAF/RAAF');
        insert objNote ;
        
        ContentVersion contentVersion = TestDataFactory.createContentVersoion('Penguins','Penguins.jpg');
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> objLink = TestDataFactory.createContentDocumentLink(objNote.id,documents[0].Id);
        insert objLink;
        
        ContentDocumentLinkTriggerHandler.countNumberOfFilesForNotes(objLink);
        
        Test.stopTest();
    }
    
    
}