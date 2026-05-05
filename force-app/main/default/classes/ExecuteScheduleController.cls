public class ExecuteScheduleController {
    
    public class ExecuteScheduleControllerException extends Exception{}

    @AuraEnabled
    public Static Boolean getDetails(String recId){
        try{
            List<Payment_Schedule__c> ps = [SELECT Id, Due_Date__c FROM Payment_Schedule__c WHERE Id =: recId];
            if(ps.isEmpty()){
                throw new ExecuteScheduleControllerException('We could not find any records.');
            }
            return (ps[0].Due_Date__c <= system.today());
        }
        Catch(Exception e){
            throw new ExecuteScheduleControllerException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public Static String getPayment(String recId){
        try{
            List<Payment_Schedule__c> ps = [SELECT Id, Due_Date__c, Billing__r.AcctSeed__Payment_Processor__r.Name FROM Payment_Schedule__c WHERE Id =: recId];
            
            String s = '';
            
            if(ps[0].Billing__r.AcctSeed__Payment_Processor__r.Name == 'Cardknox'){
                CM_AutoPayment_Batch b = new CM_AutoPayment_Batch(recId);
            	s = database.executeBatch(b);
            }
            else if(ps[0].Billing__r.AcctSeed__Payment_Processor__r.Name == 'Fiserv'){
                CM_Fiserv_AutoPayment_Batch b = new CM_Fiserv_AutoPayment_Batch(recId);
            	s = database.executeBatch(b);
            }
            return s;
        }
        Catch(Exception e){
            throw new ExecuteScheduleControllerException(e.getMessage());
        }
    }
}