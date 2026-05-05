public class SendPolicyDocumentsQueueable implements Queueable, Database.AllowsCallouts {
    public String policyId;
    public SendPolicyDocumentsQueueable (String policyId) {
        this.policyId= policyId;
    }
    public void execute(QueueableContext context) {
        Policy__c policy = [SELECT Id, Bind_Policy_JSON__c, Status__c FROM Policy__c WHERE Id=: policyId];
        
        if(String.isNotBlank(policy.Bind_Policy_JSON__c) && policy.Status__c =='Bound'){
            SendEmailExt.EmailWrapper wrap = SendEmailExt.getDetails(policy.Id, 'printPolicyDocs');
            contentVersion cv = new contentVersion();
            for(SendEmailExt.attchWrapper att :wrap.attachments){
                if(att.attached && att.attachment.Document_Type__c == 'Policy Bundle'){
                    cv = att.attachment;
                    break;
                }
            }
            if(cv.Id != null){
                cv.Physical_document_delivery__c = true;
                Update cv;
            }
            
            SendEmailExt.SendEmail(wrap,'printPolicyDocs');
        }
    }
}