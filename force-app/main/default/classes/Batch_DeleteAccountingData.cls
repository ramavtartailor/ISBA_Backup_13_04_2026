public class Batch_DeleteAccountingData implements Database.Batchable<Sobject>{
    public String soql;
    public String sObjectName;
    public Batch_DeleteAccountingData(String soql,String sObjectName){
        this.soql = soql;
        this.sObjectName = sObjectName;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(soql);
    }
    public void execute(Database.BatchableContext BC, List<sObject> batch) {
        if(sObjectName == 'AcctSeed__Journal_Entry__c'){
            List<AcctSeed__Journal_Entry__c> jes = batch;
            AcctSeed.PostResult[] postResults = AcctSeed.JournalEntryPostService.unpostJournalEntries(jes);
            delete jes;
        }else if(sObjectName == 'AcctSeed__Billing__c'){
            List<AcctSeed__Billing__c> billings = batch;
            AcctSeed.PostResult[] postResults = AcctSeed.BillingPostService.unpostBillings(billings);
            delete billings;
        }else if(sObjectName == 'AcctSeed__Scheduled_Revenue_Expense__c'){
            List<AcctSeed__Scheduled_Revenue_Expense__c> amortization = batch;
            AcctSeed.PostResult[] postResults = AcctSeed.ScheduledRevenueExpensePostService.unpostScheduledRevenueExpenses(amortization);
            delete amortization;
        }
    }
    public void finish(Database.BatchableContext BC) {
        
    }
}