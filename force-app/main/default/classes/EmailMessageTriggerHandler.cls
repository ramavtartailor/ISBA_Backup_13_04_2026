public class EmailMessageTriggerHandler {
    
    public Static void updateEmailStatus(Set<Id> successEmailBill){
        try{
         List<AcctSeed__Billing__c> billList = [select id,AcctSeed__PDF_Email_Status__c from AcctSeed__Billing__c
                                                where id in : successEmailBill];
        for(AcctSeed__Billing__c inst : billList){
            inst.AcctSeed__PDF_Email_Status__c = 'Sent';
        }
        
        update billList;
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
    }

}