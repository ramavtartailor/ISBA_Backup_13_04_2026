@isTest (SeeAllData='true')
public class ReportPdfConverterTest{
    
    
    @isTest(SeeAllData='true')
    public static void testAsyncReportWithTestData() {
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where
                                    id =: Label.Claim_Loss_Run_report];
        Apexpages.currentPage().getParameters().put('fv0',acc.id);
        ReportPdfConverter ctrl = new ReportPdfConverter();
       ReportPdfConverter.DataRow D = new  ReportPdfConverter.DataRow('test');
        
        Apexpages.currentPage().getParameters().put('fv1',String.valueOf(date.today()));
        ReportPdfConverter ctrl1 = new ReportPdfConverter();
        
    }
}