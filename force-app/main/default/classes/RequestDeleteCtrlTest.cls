@isTest
public class RequestDeleteCtrlTest {
	@isTest
    public static void test(){
        Account acc = new Account();
        acc.Name = 'ISBA Mutual Insurance Company';
        insert acc;
        Account acc1 = new Account();
        acc1.Name = 'test';
        insert acc1;
        RequestDeleteCtrl.CreateDeleteRequest(acc.Id, 'Duplicate');
    }
}