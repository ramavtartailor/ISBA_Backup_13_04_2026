public class RecalculateScheduledPayments {
    public class RecalculateScheduledPaymentsException extends Exception{}
    
    @AuraEnabled
    public Static Boolean getDetails(String recId){
        try{
            List<AcctSeed__Billing__c> bill = [SELECT Id, AcctSeed__Balance__c,(SELECT Id,Due_Amount__c FROM Payment_Schedules__r WHERE Status__c = 'Unpaid' ) FROM AcctSeed__Billing__c WHERE Id =: recId];
            if(bill.isEmpty()){
                throw new RecalculateScheduledPaymentsException('We could not find any records.');
            }

            Decimal psAmount = 0;
            
            if(!bill[0].Payment_Schedules__r.IsEmpty()){
                for(Payment_Schedule__c ps : bill[0].Payment_Schedules__r){                    
                    psAmount += ps.Due_Amount__c;
                }
            }
            return (bill[0].AcctSeed__Balance__c != psAmount);
        }
        Catch(Exception e){
            throw new RecalculateScheduledPaymentsException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public Static void RecalculatePayments(String recId){
        try{
            List<AcctSeed__Billing__c> bill = [SELECT Id, AcctSeed__Balance__c,(SELECT Id,Due_Amount__c FROM Payment_Schedules__r WHERE Status__c = 'Unpaid' ) FROM AcctSeed__Billing__c WHERE Id =: recId];
            
            Decimal psAmount = (bill[0].AcctSeed__Balance__c) / (bill[0].Payment_Schedules__r.size());
            
            Decimal scheduledAmount = 0;
            
            if(!bill[0].Payment_Schedules__r.IsEmpty()){
                List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>();
                for(Payment_Schedule__c ps : bill[0].Payment_Schedules__r){                    
                    ps.Amount__c = psAmount.setScale(2);
                    scheduledAmount += ps.Amount__c;
                    paymentSchedules.add(ps);
                }
                
                if(scheduledAmount != bill[0].AcctSeed__Balance__c){
                    Payment_Schedule__c ps  = paymentSchedules[paymentSchedules.Size() - 1];
                    ps.Amount__c += (bill[0].AcctSeed__Balance__c - scheduledAmount);
                }
                
                Update paymentSchedules;
            }
             
        }
        Catch(DmlException e){
            throw new RecalculateScheduledPaymentsException(e.getDmlMessage(0));
        }
        Catch(Exception e){
            throw new RecalculateScheduledPaymentsException(e.getMessage());
        }
    }
}