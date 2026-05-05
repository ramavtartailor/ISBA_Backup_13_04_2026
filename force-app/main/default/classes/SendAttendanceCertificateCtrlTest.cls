@isTest
public class SendAttendanceCertificateCtrlTest {
    @isTest
    public static void testmethod1(){
        CLE_Event__c e= new CLE_Event__c();
        e.Name = 'test';
        e.Date__c = system.today();
        Insert e;
        
        Account acc                   = TestDataFactory.createAccounts('Dummy Billing Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        acc.Payment_Link_Activation_Started_at__c = system.today();
        insert acc;
        
        Contact con = new Contact(
            FirstName = 'APPROVED',
            LastName = 'TEST',
            AccountId = acc.Id,
            Email = 'test@Cmentor.com'
        );
        Insert con;
        
        CLE_Attendance__c attendee = new CLE_Attendance__c();
        attendee.CLE_Event__c = e.Id;
        attendee.Contact__c = con.Id;
        Insert attendee;
			
        SendAttendanceCertificateCtrl.callBatch(e.Id);
        PageReference pageRef = Page.AttendanceCertificatePdf;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',attendee.Id);
        AttendanceCertificatePdfController cls = new AttendanceCertificatePdfController();
    }
}