public class CashReceiptTriggerHandler {
	
    public static void onAfterInsert(List<AcctSeed__Cash_Receipt__c> newList){
        Map<String, String> transactionIdMap = new Map<String, String>();
        
        for(AcctSeed__Cash_Receipt__c cr: newList){
            transactionIdMap.put(cr.AcctSeed__Payment_Reference__c, cr.Id);
        }
        
        List<Payment_Schedule__c> paymentSchedules= [SELECT Id, Billing__c, Payment_Reference__c, Frequency__c, Due_Amount__c, Amount__c, Due_Date__c FROM Payment_Schedule__c WHERE Status__c = 'Pending' AND Payment_Reference__c IN: transactionIdMap.keySet()];
        for(Payment_Schedule__c ps: paymentSchedules){
            ps.Status__c = 'Paid';
            ps.Cash_Receipt__c = transactionIdMap.get(ps.Payment_Reference__c);
        }
        Update paymentSchedules;
    }
    
    public static void onAfterUpdate(List<AcctSeed__Cash_Receipt__c> newList, Map<Id, AcctSeed__Cash_Receipt__c> oldMap){
        Set<String> transactionIds = new Set<String>();
        
        for(AcctSeed__Cash_Receipt__c cr: newList){
            if(oldMap.containsKey(cr.Id)&& String.isNotBlank(cr.AcctSeed__Payment_Reference__c) && oldMap.get(cr.Id).AcctSeed__Void__c == false && cr.AcctSeed__Void__c == true){
                transactionIds.add(cr.AcctSeed__Payment_Reference__c);
            }
        }
        
        
        List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>([SELECT Id, Cash_Receipt__c FROM Payment_Schedule__c WHERE Payment_Reference__c IN: transactionIds]);
        for(Payment_Schedule__c ps: paymentSchedules){
            ps.Status__c = 'Rejected';
            ps.Settled_Date__c = null;
            ps.Cash_Receipt__c = null;
            ps.Paid_Amount__c = 0;
        }
        Update paymentSchedules;
    }
}