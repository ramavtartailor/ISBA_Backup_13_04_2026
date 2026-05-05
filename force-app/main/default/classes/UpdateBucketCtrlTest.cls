@isTest
public class UpdateBucketCtrlTest {
	@isTest
    public static void test1(){
        Account acc =  new Account();
        acc.Name =  'Test';
        acc.ISBAM_Cannot_Delete__c = true;
        acc.CountyPicklist__c = 'ALEXANDER';
        Insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.FirstName = 'test';
        con.LastName = 'test';
        Insert con;
        
        con.ISBAM_Quick_Note__c = 'test';
        UpdateBucketCtrl.getContact(con.Id);
        UpdateBucketCtrl.updateRecord(con, 'Test');
        try{
            UpdateBucketCtrl.updateRecord(con, 'accName');
        }
        Catch(Exception e){
            Assert.areEqual('The Account named "accName" was not found.', e.getMessage());
        }
        try{
            delete acc;
        }
        Catch(Exception e){
            system.debug(e.getMessage());
            //Assert.areEqual('The Account named "accName" was not found.', e.getMessage());
        }
    }
}