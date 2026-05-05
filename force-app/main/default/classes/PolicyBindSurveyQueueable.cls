public class PolicyBindSurveyQueueable implements Queueable, Database.AllowsCallouts {
    public ISBAM_Survey__c survey;
    public PolicyBindSurveyQueueable (ISBAM_Survey__c surObj) {
        this.survey = surObj;
    }
    
    public void execute(QueueableContext context) {
        PaymentGatewayClass.updatePSchRecords(new List<ISBAM_Survey__c>{survey} , 'Insert');
    }
}