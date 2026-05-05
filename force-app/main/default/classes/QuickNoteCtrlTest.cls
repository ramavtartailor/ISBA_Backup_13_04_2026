@isTest
public class QuickNoteCtrlTest {
	@isTest
    static void method1(){
        Contact con = new contact(lastName = 'test');
        insert con;
        QuickNoteCtrl.getData(con.Id);
        QuickNoteCtrl.updateData(con.Id, 'note');
    }
}