@isTest
public class Pdf_Lib_WatermarkHelperCtrlTest {

    @isTest
    static void testConstructor_withWatermark() {
        // Simulate Visualforce page parameters
        Test.startTest();
        PageReference pageRef = Page.Pdf_Lib_WatermarkHelper; // Substitute with an actual Visualforce page name
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('URL', 'TestPage');
        ApexPages.currentPage().getParameters().put('watermark', 'Yes');

        Pdf_Lib_WatermarkHelperCtrl ctrl = new Pdf_Lib_WatermarkHelperCtrl();
        System.assertEquals('/apex/TestPage', ctrl.url);
        System.assertEquals('Preview Copy', ctrl.watermarkText);

        Test.stopTest();
    }

    @isTest
    static void testConstructor_withoutWatermark() {
        Test.startTest();
        PageReference pageRef = Page.Pdf_Lib_WatermarkHelper;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('URL', 'TestPage');

        Pdf_Lib_WatermarkHelperCtrl ctrl = new Pdf_Lib_WatermarkHelperCtrl();
        System.assertEquals('/apex/TestPage', ctrl.url);
        System.assertEquals('', ctrl.watermarkText);

        Test.stopTest();
    }

    @isTest
    static void testHandlePrintQuotes() {
        PageReference pageRef = Page.Pdf_Lib_WatermarkHelper;
        Test.setCurrentPage(pageRef);

        // Setup parameters for PrintQuotes scenario
        ApexPages.currentPage().getParameters().put('URL', 'PrintQuotes');
        ApexPages.currentPage().getParameters().put('watermark', 'No');
        ApexPages.currentPage().getParameters().put('id', '001XXXXXXXXXXXX'); // Sample recordId
        ApexPages.currentPage().getParameters().put('type', 'Standard');
        ApexPages.currentPage().getParameters().put('fromPolicyBind', 'true');
        ApexPages.currentPage().getParameters().put('removeQuoteIds', 'someId');

        // Mock a ContentVersion record
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test PDF';
        cv.VersionData = Blob.valueOf('Sample PDF Data');
        cv.PathOnClient = 'Test PDF.pdf';
        insert cv;

        // Simulate how printQuotes returns a PageReference with the download Id
        Test.startTest();
        Pdf_Lib_WatermarkHelperCtrl ctrl = new Pdf_Lib_WatermarkHelperCtrl();

        // Replace or mock DocumentBundleVF_Ctrl behavior if needed here.
        // For advanced mocking, use a stub or the Stub API.

        ctrl.handlePrintQuotes();

        // Check expected changes
        System.assertNotEquals(null, ctrl.pdfBlob, 'pdfBlob should be populated');
        Test.stopTest();
    }
}