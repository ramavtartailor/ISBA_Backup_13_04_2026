global class CMRenewPolicy6MonthPriorSendEmailBatch implements Database.Batchable<sObject>, Database.Stateful,Schedulable  {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date startTimeFrame = system.today();
        Date timeFrame = system.today().addDays(181);
        Id RecordTypeId = Schema.SObjectType.Policy__c.getRecordTypeInfosByName().get('Policy').getRecordTypeId();
        String query = 'select id,ClonedBy__c,Policy_Number__c,Firm_Contact__r.Email from Policy__c where RecordTypeId=:RecordTypeId AND Renew_Application__c = false AND Account__r.Count_of_Application__c<1 and Expiration_Date__c =:timeFrame and ClonedBy__c = null and Expiration_Date__c >:startTimeFrame and Cancel_Date__c = null';
        //query = 'select id,ClonedBy__c,Policy_Number__c,Firm_Contact__r.Email from Policy__c where Id = \'a0s05000004LrnYAAS\'' ;
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<Policy__c> records) {
        List<Messaging.SingleEmailMessage> allEmailmsg = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [Select id, Subject, Body,HtmlValue From EmailTemplate Where DeveloperName = 'Renew_Policy_6_Month_Prior_Template_Classic'];
        List<OrgWideEmailAddress> add = [select id from OrgWideEmailAddress where address = 'underwriting@isbamutual.com'];
        String DocumentListString= LABEL.CMRenewPolicy6MonthPriorSendEmailDocumentId ;
        
        Set<String> documentStringSet = New Set<String>();
        if(string.isNotBlank(DocumentListString) && DocumentListString.contains(',')){
            for(string str : DocumentListString.split(',')){
                documentStringSet.add(str);
            }
        }
        
        //List<Contact> contacts = new List<Contact>([select id from Contact where Email = 'underwriting_automation@isbamutual.com']);
		List<Messaging.EmailFileAttachment> emailFileAttachments= new List<Messaging.EmailFileAttachment>();
        for(ContentVersion cv : [select id,VersionData,Title,FileExtension from ContentVersion where ContentDocumentId in: documentStringSet AND IsLatest = true]){
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.body = cv.versiondata;
            efa.fileName = cv.Title;
            if(!efa.fileName.endsWith('.'+cv.FileExtension)){
                efa.fileName = cv.Title + '.' + cv.FileExtension;
            }
            emailFileAttachments.add(efa);
        }
        for(Policy__c Obj : records)  {
            if(Obj.Firm_Contact__c != NULL && Obj.Firm_Contact__r.Email != NULL){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                mail.setTemplateID(emailTemplate.Id); 
                mail.setWhatId(Obj.Id); 
                /*if(contacts.size() > 0){
                    mail.setTargetObjectId(contacts[0].Id);
                }*/
                mail.setTargetObjectId(Obj.Firm_Contact__c);
                mail.setBccAddresses(new String[]{'underwriting_automation@isbamutual.com'});
                mail.setFileAttachments(emailFileAttachments);
                if(add.size() > 0){
                    mail.setOrgWideEmailAddressId(add[0].Id);
                }
                allEmailmsg.add(mail);
            }
        }
        
        
        if(!allEmailmsg.isEmpty()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(allEmailmsg,false);
            
            for(integer i=0;i< results.size();i++){
                if (results[i].success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: '
                                 + results[i].errors[0].message);
                }
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC){           
        
    }
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(new CMRenewPolicy6MonthPriorSendEmailBatch(),10);
    }
}