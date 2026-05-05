@isTest
public class LeadTriggerHandler_Test {
    @isTest
    public static void main(){
        
        
        String testLbl = Label.Bucket_Account;
        system.debug('testLbl'+testLbl);
        Account a = new Account();
        a.name = testLbl;
        insert a;
        
        
        // create a Lead
        Lead lead=new Lead(LastName='Doe',FirstName='John',Company='Test',Status='Inquiry');
        lead.IsConverted = false;
        lead.Size_of_Firm__c = true;
        lead.Headquartered_in_Illinois__c =true;
        lead.Authorized_to_Practice__c = true;
        lead.Is_Sales_Lead__c = true;
        lead.Private_Practice__c = true;
        insert lead;                
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        //lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Qualified');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
       
    }
    
}