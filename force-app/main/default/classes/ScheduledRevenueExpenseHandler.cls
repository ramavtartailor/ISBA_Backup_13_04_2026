public class ScheduledRevenueExpenseHandler{
    
    public static void mapPolicyToAmortizedRevenue(List<AcctSeed__Scheduled_Revenue_Expense__c> scheduledRevList){
        
        Map<Id, Id> billPolicyMap = new Map<Id, Id>();
        Set<Id> billingIds = new Set<Id>();
        
        for(AcctSeed__Scheduled_Revenue_Expense__c scheduledRev: scheduledRevList){
            if(scheduledRev.AcctSeed__Billing__c != null && scheduledRev.Policy__c == null){
                billingIds.add(scheduledRev.AcctSeed__Billing__c);
            }
        }
        
        for(AcctSeed__Billing__c bill: [SELECT Id,Policy__c FROM AcctSeed__Billing__c WHERE Id IN: billingIds]){
            billPolicyMap.put(bill.Id, bill.Policy__c);
        }
        
        for(AcctSeed__Scheduled_Revenue_Expense__c scheduledRev: scheduledRevList){
            if(scheduledRev.AcctSeed__Billing__c != null && scheduledRev.Policy__c == null && billPolicyMap.containsKey(scheduledRev.AcctSeed__Billing__c)){
                scheduledRev.Policy__c = billPolicyMap.get(scheduledRev.AcctSeed__Billing__c);
            }
        }
    }
    
}