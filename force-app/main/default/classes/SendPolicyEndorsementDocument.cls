public class SendPolicyEndorsementDocument implements Queueable, Database.AllowsCallouts {
    public String recId;
    public SendPolicyEndorsementDocument (String recId) {
        this.recId= recId;
    }
    public void execute(QueueableContext context) {
        
        List<EmailTemplate> templateList = new List<EmailTemplate>([Select id,Subject,Body,HtmlValue from EmailTemplate where name ='Endorsement Document']);
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
        
        String orgWideEmailAddressId = [select Id,Address from OrgWideEmailAddress where Address = 'underwriting@isbamutual.com'].Id;
        
        Policy_Endorsement__c endorsement = [SELECT Id,Endorsement_Version__c,Endorsement_Number__c,Policy__r.Firm_Contact__c, Policy__r.Firm_Contact_Email__c  FROM Policy_Endorsement__c WHERE Id =: recId ];
        
        Messaging.SingleEmailMessage emailMsg = Messaging.renderStoredEmailTemplate(templateList[0].Id,endorsement.Policy__r.Firm_Contact__c,endorsement.Id);
        
        String toEmail = endorsement.Policy__r.Firm_Contact_Email__c ;
        String subject = emailMsg.getSubject();
        String emailBody = emailMsg.getHtmlBody();
        emailBody = emailBody.replaceAll('<p><br></p>','<br><br>');
        emailBody = emailBody.replaceAll('</p><p>','<br/>');
        emailBody = emailBody.replaceAll('</p>','');
        emailBody = emailBody.replaceAll('<p>','');
            
        PageReference pdfPage = new PageReference('/apex/Endorsement_Pdf');
        pdfPage.getParameters().put('id', endorsement.Id);
        pdfPage.getParameters().put('number', endorsement.Endorsement_Number__c);
        pdfPage.getParameters().put('version', endorsement.Endorsement_Version__c);
        
        Blob pdfBlob;
        if (Test.isRunningTest()) {
            pdfBlob = Blob.valueOf('Test PDF Content');
        } else {
            pdfBlob = pdfPage.getContentAsPDF();
        }

        // Create email attachment
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('Endorsement_Pdf.pdf');
        attachment.setContentType('application/pdf');
        attachment.setBody(pdfBlob);

        // Prepare email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setOrgWideEmailAddressId(orgWideEmailAddressId);
        email.setToAddresses(new String[] { toEmail });
        email.setSubject(subject);
        email.setPlainTextBody(emailBody);
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        email.setWhatId(endorsement.Id);
        email.setSaveAsActivity(true);

        // Send email
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}