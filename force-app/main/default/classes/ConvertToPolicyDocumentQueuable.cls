public class ConvertToPolicyDocumentQueuable  implements Queueable, Database.AllowsCallouts {
	public String policyId;
    public String policyDocVersion;
    public Id queueId;
    
    public ConvertToPolicyDocumentQueuable (String policyId, String policyDocVersion,Id queueId) {
        this.policyId = policyId;
        this.policyDocVersion = policyDocVersion;
        this.queueId = queueId;
    }
    
    public void execute(QueueableContext context) {
        AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:queueId];
        if(jobInfo.Status == 'Completed' || jobInfo.Status == 'Failed'){
            ConvertToPolicyLtng.createDocuments(policyId, policyDocVersion);
        }else{
            System.enqueueJob(new ConvertToPolicyDocumentQueuable(policyId,policyDocVersion,queueId));
        }
    }
}