@isTest
public class Contact_Trg_TestClass {
Public static testMethod Void Delete_Contact(){
        List<contact> Lstcontact = new List<contact>();
        for(integer i=1; i<=5; i++){
        	Lstcontact.add(new contact(firstname='first name'+i,lastname='last name '+i));
        }
   
        insert Lstcontact;
        delete Lstcontact;
   	
}
}