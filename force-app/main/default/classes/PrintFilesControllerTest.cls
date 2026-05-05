@isTest
public class PrintFilesControllerTest {
    @istest
    static void testMet1(){
        ContentVersion content = new ContentVersion();
        content.VersionData = blob.valueOf('Test this is not important....!');
        string title = 'test map.pdf';
        content.Title = title;
        content.PathOnClient = title;
        content.Document_Type__c = 'Close Out Letter';
        insert content;
        
        PrintFilesController ctrl = new PrintFilesController();
        ctrl.getDocumentTypes();
        ctrl.searchDocumentType = 'Close Out Letter';
        ctrl.fetchFiles();
        ctrl.selectedFileIds = content.id;
        ctrl.printSelectedFiles();
    }
}