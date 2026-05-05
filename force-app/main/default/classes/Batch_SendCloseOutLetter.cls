global class Batch_SendCloseOutLetter implements Database.Batchable<SObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext bc){        
        return Database.getQueryLocator('SELECT Id, Name, Expiration_Date__c, Account__c, Firm_Name__c, Firm_Contact__c, Firm_Contact__r.Email FROM Policy__c where RecordType.Name = \'Policy\' and Expiration_Date__c = YESTERDAY and Next_Policy__c = null and Is_Canceled__c = false order by Expiration_Date__c LIMIT 200');
    }
    
    global void execute(Database.BatchableContext bc, List<Policy__c> data){
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        String OrgWideEmailAddressId = [select Id,Address from OrgWideEmailAddress where Address = 'underwriting@isbamutual.com'].Id;
        
        if(data.Size() <= Integer.valueOf(label.Close_Out_Letter_Limit)){
            system.debug('data => '+data);
            List<Policy__C> updatedPolicies = new List<Policy__c>();
            
            Map<String, ContentVersion> policyWithContentVersion = new Map<String, ContentVersion>();
            
            Map<String, ContentVersion> cvMap = new Map<String, ContentVersion>();
            
            for(Policy__c pol : data){
                PageReference pg = Page.Closeout_Letter;
                pg.getParameters().put('id',pol.Id);
                
                String fileName = pol.Firm_Name__c +' - '+pol.Name + ' - Close Out Letter.pdf';
                
                Timezone tz = Timezone.getTimeZone('America/Chicago');
                Decimal currentMilliSeconds = System.now().getTime();
                
                ContentVersion content = new ContentVersion();
                if(Test.isRunningTest()) { 
                    content.VersionData = blob.valueOf('Unit.Test');
                } else {
                    content.VersionData = pg.getContent();
                }
                
                content.Title = fileName;
                content.PathOnClient = fileName;
                content.FirstPublishLocationId = pol.Id;
                content.Application_Policy__c = pol.Id;
                content.Account__c = pol.Account__c;
                content.Document_Type__c = 'Close Out Letter';
                content.Is_System_Generated_Document__c = true;
                content.Unique_Identifier__c = pol.Id + '_' + UserInfo.getUserId() +  '_' + currentMilliSeconds;
                policyWithContentVersion.put(pol.Id, content);
            }
            
            insert policyWithContentVersion.values();
            
            Set<String> cvIds = new Set<String>();
            for(ContentVersion cv : policyWithContentVersion.values()){
                cvIds.add(cv.Id);
            }
            
            cvMap =  new Map<String, ContentVersion>([SELECT id,VersionData,Title,FileExtension from ContentVersion where id in: cvIds]);
            
            List<EmailTemplate> templateList = new List<EmailTemplate>([Select id,Subject,Body,HtmlValue from EmailTemplate where name = 'Close Out Letter']);
            
            for(Policy__c pol : data){           
                
                Messaging.SingleEmailMessage tempEmail = Messaging.renderStoredEmailTemplate(templateList[0].Id , pol.Firm_Contact__c, pol.Id);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                email.setSubject(tempEmail.getSubject());
                email.setToAddresses(new String[] {pol.Firm_Contact__r.Email});
                email.setOrgWideEmailAddressId(OrgWideEmailAddressId);
                
                String emailBody = '';
                if(tempEmail.getHtmlBody() != null){
                    emailBody = String.valueOf(tempEmail.getHtmlBody());
                }else{
                    emailBody = tempEmail.getPlainTextBody().replaceAll('\n','<br/>');
                    emailBody = emailBody.replaceAll('<p>','');
                    emailBody = emailBody.replaceAll('</p>','');
                }           
                
                emailBody = emailBody.replaceAll('<p><br></p>','<br><br>');
                emailBody = emailBody.replaceAll('</p><p>','<br/>');
                emailBody = emailBody.replaceAll('</p>','');
                emailBody = emailBody.replaceAll('<p>','');
                
                email.setHtmlBody(emailBody);
                
                if(cvMap.containsKey(policyWithContentVersion.get(pol.Id).Id)){
                    ContentVersion cv = cvMap.get(policyWithContentVersion.get(pol.Id).Id);
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                    efa.body = cv.versiondata;
                    efa.fileName = cv.Title;
                    if(!efa.fileName.endsWith('.'+cv.FileExtension)){
                        efa.fileName = cv.Title + '.' + cv.FileExtension;
                    }
                    email.setFileAttachments(new List<Messaging.EmailFileAttachment>{efa});                
                }
                
                pol.COL_Sent_Date__c = system.today();
                updatedPolicies.add(pol); 
                
                email.setWhatId(pol.Id);
                email.setSaveAsActivity(true);
                allmsg.add(email);
            }            
            Update updatedPolicies;
        }
        else{
            List<EmailTemplate> templateList = new List<EmailTemplate>([Select id,Subject,Body,HtmlValue from EmailTemplate where name = 'Close Out Letter Error']);
            Messaging.SingleEmailMessage tempEmail = Messaging.renderStoredEmailTemplate(templateList[0].Id , UserInfo.getUserId(), UserInfo.getUserId());
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            List<String> toAddress = Label.System_Admin_Emails.contains(',')? Label.System_Admin_Emails.split(',') : new List<String>{Label.System_Admin_Emails};
            
                email.setSubject(tempEmail.getSubject());
            email.setToAddresses(toAddress);
            email.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            
            String emailBody = '';
            if(tempEmail.getHtmlBody() != null){
                emailBody = String.valueOf(tempEmail.getHtmlBody());
            }else{
                emailBody = tempEmail.getPlainTextBody().replaceAll('\n','<br/>');
                emailBody = emailBody.replaceAll('<p>','');
                emailBody = emailBody.replaceAll('</p>','');
            }           
            
            emailBody = emailBody.replaceAll('<p><br></p>','<br><br>');
            emailBody = emailBody.replaceAll('</p><p>','<br/>');
            emailBody = emailBody.replaceAll('</p>','');
            emailBody = emailBody.replaceAll('<p>','');
            
            email.setHtmlBody(emailBody);
            //email.setWhatId(UserInfo.getUserId());
            email.setSaveAsActivity(true);
            allmsg.add(email);
        }
        
        system.debug('allmsg => '+allmsg);
        
        Messaging.sendEmail(allmsg, false);
    }
    global void finish(Database.BatchableContext bc){
        
    }
    
    Global void execute(SchedulableContext sc){
        Database.executeBatch(new Batch_SendCloseOutLetter());
    }
}