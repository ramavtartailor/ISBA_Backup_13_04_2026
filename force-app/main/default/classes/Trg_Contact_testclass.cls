/*
Created By		:	Shoukat Hussain
Created Date	: 	6/1/2016
Purpose			:   Test calss for Trg_Contact - Only system adminstrator can delete contacts.
*/

@isTest
private class Trg_Contact_testclass {
public static testMethod void DeleteContact() {
    // This code run as system user
    List<contact> Lstcontact = new List<contact>();
    for(integer i=1; i<=5; i++){
        Lstcontact.add(new contact(firstname='first name'+i,lastname='last name '+i));
    }   
    insert Lstcontact;
    delete Lstcontact;
    
    // This code run as other user
    List<contact> Lstcontact2 = new List<contact>();
    Profile p = [SELECT Id FROM Profile WHERE Name='Sales']; 
    User u = new User(Alias = 'standt12', Email='standarduser123xs@testorg.com', 
    EmailEncodingKey='UTF-8', LastName='Testing123xs', LanguageLocaleKey='en_US', 
    LocaleSidKey='en_US', ProfileId = p.Id, 
    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123xs@testorg.com');
    System.runAs(u) {
    for(integer i=1; i<=5; i++){
        Lstcontact2.add(new contact(firstname='first name Smith'+i,lastname='last name Jhon '+i));
    }   
    insert Lstcontact2;
    try{
        delete Lstcontact2;
       } catch (Exception e) 
	   {}		
     }
   	
}
}