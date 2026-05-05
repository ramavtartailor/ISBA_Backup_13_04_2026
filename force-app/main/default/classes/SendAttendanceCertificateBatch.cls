global class SendAttendanceCertificateBatch implements Database.Batchable<Sobject>, Database.Stateful{
    
    global String eventId;
    
    global SendAttendanceCertificateBatch(String eventId){
        this.eventId = eventId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Email__c, CLE_Event__c, CLE_Event_Date__c, Contact__c, Contact__r.Email,Contact__r.FirstName, Contact__r.LastName FROM CLE_Attendance__c WHERE CLE_Event__c=:eventId AND Certificate_Send_Date__c = null';
        return database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<CLE_Attendance__c> attendanceList) {
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> templateList = new List<EmailTemplate>([Select id,Subject,Body,HtmlValue from EmailTemplate where name = 'CLEAttendanceCertificateTemplate']);
        String oweId =[select Id,Address from OrgWideEmailAddress where Address = 'lossprevention@isbamutual.com' LIMIT 1].Id;
        for(CLE_Attendance__c atd: attendanceList){
            List<Messaging.EmailFileAttachment> emailFileAttachments = new List<Messaging.EmailFileAttachment>();
            
            PageReference pg = Page.AttendanceCertificatePdf;
            pg.getParameters().put('id',(String)atd.Id);
            Blob body;
            if(!test.isRunningTest())
                body= pg.getContent();
            else
                body = Blob.valueOf('test');
            
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.body = body;
            String dateString = atd.CLE_Event_Date__c.Month()+'-'+atd.CLE_Event_Date__c.Day()+'-'+String.valueOf(atd.CLE_Event_Date__c.Year()).substring(2, 4);
            efa.fileName = atd.Contact__r.FirstName+' '+atd.Contact__r.LastName+' MCLE '+dateString+'.pdf';
            emailFileAttachments.add(efa);
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            Messaging.SingleEmailMessage tempEmail = Messaging.renderStoredEmailTemplate(templateList[0].Id,atd.Contact__c,atd.CLE_Event__c);
            List<String> toAddressList = new List<String>();
            
            if(String.isNotBlank(atd.Contact__r.Email)){
                toAddressList.add(atd.Contact__r.Email);
            }
            if(String.isNotBlank(atd.Email__c)){
                toAddressList.add(atd.Email__c);
            }
            if(!emailFileAttachments.isEmpty()){
                email.setFileAttachments(emailFileAttachments);
            }
            email.setOrgWideEmailAddressId(oweId);
            email.setSubject(tempEmail.getSubject());
            email.setToAddresses(toAddressList);
            String emailBody = String.valueOf(tempEmail.getHtmlBody());
            email.setHtmlBody(emailBody);
            allMails.add(email);
        }
        
        if(!allMails.isEmpty()){
            Messaging.SendEmailResult [] r = Messaging.sendEmail(allMails,false);
            for(CLE_Attendance__c atd: attendanceList){
                atd.Certificate_Send_Date__c = system.today();
            }
            Update attendanceList;
        }
    }
    global void finish(Database.BatchableContext BC) { 
    }
}