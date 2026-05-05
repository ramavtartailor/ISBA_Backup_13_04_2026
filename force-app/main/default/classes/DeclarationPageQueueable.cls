public class DeclarationPageQueueable  implements Queueable, Database.AllowsCallouts {
    public String policyId;
    public String policyVersion;
    public Id accountId;
    
    public DeclarationPageQueueable (String policyId,String policyVersion,Id accountId) {
        this.policyId= policyId;
        this.policyVersion= policyVersion;
        this.accountId= accountId;
    }
    
    public void execute(QueueableContext context) {
        PolicyDocumentsUtility.createDeclarationPage(policyId, policyVersion,accountId,null);  
        if(!Test.isRunningTest()){
            System.enqueueJob(new SendPolicyDocumentsQueueable(policyId));
        }
    }    
}