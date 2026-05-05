@isTest
public class PreviewContentVersionCtrlTest {
    @isTest
    public static void test(){
        Account acc = new Account();
        acc.Name = 'test';
        Insert acc;
        
        ContentVersion cv = new ContentVersion();
        cv.Title= 'test';
        cv.VersionData = blob.valueOf('text');
        cv.PathOnClient = acc.Id;
        insert cv;
        
        PageReference pageRef = Page.FilePreviewPage;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',cv.Id);
        PreviewContentVersionCtrl ctrl= new PreviewContentVersionCtrl();
    }

}