@istest
public class CreateEventAttendeeCmpControllerTest {
    @istest
    static void test_method1(){
        Account acc = new Account();
        acc.Name = Label.Bucket_Account;
        insert acc;
        
        Contact con = new Contact();
        con.lastName = 'test';
        con.FirstName = 'test';
        con.ARDC_Number__c = '6299962';
		INSERT con;
        
        CLE_Event__c evt = new CLE_Event__c(
            Name = 'test',
            Date__c = system.today(),
            Description__c = 'Testing',
            Hours__c = 2
        );
        insert evt;
        
        Test.startTest();
        CreateEventAttendeeCmpController.csvWrapper csvWrap = CreateEventAttendeeCmpController.getCSVObject('# Record Type,File Type,Provider Name,Provider Number,File Creation Date,Transaction Number,Total Rows in File,,,,,,,,,\n 100,1,ISBA Mutual Insurance Company,ISB0002,20250131,2.03E+11,3,,,,,,,,,\n # Record Type,PCAM Course ID,Attendance Completion Date,Attendance Method ,ARDC Number,First Name,Last Name,,,General Credit,PR MHSA,PR DIV,PR OTHER,E-mail Address,Company,Business Phone\n 500,615847,20250128,LVA,6299962,"Marissa",Hanson,,,1,0,0,1,omar.uddin@isbamutual.com,Serrano Hanson,6308448781\n 500,615847,20250128,LVA,6274216,Lidia,Serrano,,,1,0,0,1,kyle.hoker@isbamutual.com,Serrano Hanson,6308448781\n 500,615847,20250128,LVA,454647,Rachit,Parnami,,,1,0,0,1,rachit@cmentor.com,Law Offices of Rachit,1234567890\n 500,615847,20250128,LVA,,Marissa,,,,1,0,0,1,omar.uddin@isbamutual.com,Serrano Hanson,6308448781\n 500,615847,20250128,LVA,,Lidia,Serrano,,,1,0,0,1,kyle.hoker@isbamutual.com,Serrano Hanson,6308448781\n 500,615847,20250128,LVA,454647,Rachit,,,,1,0,0,1,rachit@cmentor.com,Law Offices of Rachit,1234567890\n 500,615847,20250128,LVA,6299962,Marissa,Hanson,,,1,0,0,1,_omar.uddin@isbamutual.com,Serrano Hanson,6308448781\n 500,615847,20250128,LVA,cvytcvav,Lidia,Serrano,,,1,0,0,1,kyle.hoker@isbamutual.com,Serrano Hanson,6308448781\n');
        system.debug('csvWrap => '+csvWrap);
        csvWrap.contactList[0][1] = '';
        CreateEventAttendeeCmpController.createRecord(csvWrap,evt.Id);
		CreateEventAttendeeCmpController.separateCommas('test,test1');
        Test.stopTest();
    }
}