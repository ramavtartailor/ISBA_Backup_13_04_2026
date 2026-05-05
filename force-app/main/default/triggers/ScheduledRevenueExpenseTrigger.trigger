trigger ScheduledRevenueExpenseTrigger on AcctSeed__Scheduled_Revenue_Expense__c (before insert) {
    
    if(trigger.isBefore && trigger.isInsert){
        ScheduledRevenueExpenseHandler.mapPolicyToAmortizedRevenue(trigger.new);
    }
    
}