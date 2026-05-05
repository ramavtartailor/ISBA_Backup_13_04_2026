public class Terms_Of_Service_Template_Ctrl {
	public String recordId;
    public Policy__c policy{get;set;}
    public void setrecordId(String recordId){
        policy = [select id, 
                  Terms_Conditions__C, 
                  FIRM_NAME__c, 
                  Underwriter_User__r.LastName, 
                  Underwriter_User__r.FirstName, 
                  Underwriter_User__r.Title, 
                  Underwriter_User__r.Phone, 
                  Underwriter_User__r.Email,
                  Application_Type__c,
                  Sales_User__r.LastName, 
                  Sales_User__r.FirstName, 
                  Sales_User__r.Title,
                  Sales_User__r.Phone, 
                  Sales_User__r.Email,
                  NAME,Sales_User__c from Policy__C 
                  where id=: recordId];
    }
    public String getrecordId(){
        return recordId;
    }
}