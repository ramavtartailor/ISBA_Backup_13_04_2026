public class CM_TransactionTriggerQueueable  implements Queueable, Database.AllowsCallouts {
    public String transactionJSON;
    
    public CM_TransactionTriggerQueueable (String transactionJSON) {
        this.transactionJSON= transactionJSON;
    }
    
    public void execute(QueueableContext context) {
        CM_TransactionTriggerHelper.handleTransactionInsert(transactionJSON);
    }
}