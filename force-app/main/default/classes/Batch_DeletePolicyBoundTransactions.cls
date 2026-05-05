public class Batch_DeletePolicyBoundTransactions implements Database.Batchable<Sobject>{
    public String soql;
    public Batch_DeletePolicyBoundTransactions(String soql){
        this.soql = soql;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(soql);
    }
    public void execute(Database.BatchableContext BC, List<Policy__c> batch) {
        List<AS_Transaction__c> asTransactions = new List<AS_Transaction__c>([select id from AS_Transaction__c where Policy_Id__c=: batch]);
        List<AcctSeed__Billing__c> billings = new List<AcctSeed__Billing__c>([select id from AcctSeed__Billing__c where Policy__c =: batch]);
        List<AcctSeed__Journal_Entry__c> jes = new List<AcctSeed__Journal_Entry__c>([select id from AcctSeed__Journal_Entry__c where Policy__c =: batch]);
        List<AcctSeed__Scheduled_Revenue_Expense__c> amortization = new List<AcctSeed__Scheduled_Revenue_Expense__c>([select id from AcctSeed__Scheduled_Revenue_Expense__c where Policy__c =: batch]);
        
        AcctSeed.PostResult[] postResults = AcctSeed.BillingPostService.unpostBillings(billings);
        postResults = AcctSeed.JournalEntryPostService.unpostJournalEntries(jes);
        postResults = AcctSeed.ScheduledRevenueExpensePostService.unpostScheduledRevenueExpenses(amortization);
        
        delete asTransactions;
        
        delete jes;
        delete amortization;
        delete billings;
    }
    public void finish(Database.BatchableContext BC) {
        
    }
}