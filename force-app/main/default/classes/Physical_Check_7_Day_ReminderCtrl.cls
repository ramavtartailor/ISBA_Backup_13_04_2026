public class Physical_Check_7_Day_ReminderCtrl {
    
    public String recordId;
    public Payment_Schedule__c ps{get;set;}
    public void setrecordId(String recordId){
        ps = [SELECT Id,Billing_Contact_Name__c,Due_Amount__c,Due_Date__c,Billing__r.Payment_Link__c FROM Payment_Schedule__c where id=: recordId];
    }
    public String getrecordId(){
        return recordId;
    }

}