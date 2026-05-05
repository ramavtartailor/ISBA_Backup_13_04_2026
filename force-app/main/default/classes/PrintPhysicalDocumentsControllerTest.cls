@isTest
public class PrintPhysicalDocumentsControllerTest {
    @istest
    static void testMet1(){
        ContentVersion content = new ContentVersion();
        content.VersionData = blob.valueOf('Test this is not important....!');
        string title = 'test map.pdf';
        content.Title = title;
        content.PathOnClient = title;
        content.Document_Type__c = 'Close Out Letter';
        content.Physical_document_delivery__c = true;
        insert content;
        
        PrintPhysicalDocumentsController ctrl = new PrintPhysicalDocumentsController();
        ctrl.fetchFiles();
        ctrl.selectedFileIds = content.id;
        ctrl.printSelectedFiles();
    }
}