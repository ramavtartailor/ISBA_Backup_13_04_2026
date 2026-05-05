global class Batch_InvoiceDueNotification implements Database.Batchable<Sobject>,Schedulable,Database.AllowsCallouts{
	global Database.QueryLocator start(Database.BatchableContext BC) {
        Date day14Interval = System.today().addDays(14);
        Date day5Interval = System.today().addDays(5);
        Date day1Interval = System.today().addDays(1);
        return Database.getQueryLocator([Select Id,AcctSeed__Due_Date2__c,AcctSeed__Billing_Format__r.AcctSeed__Visualforce_PDF_Page__c,AcctSeed__Billing_Contact__c, 
                                         AcctSeed__Billing_Format__r.AcctSeed__Default_Email_Template__c,AcctSeed__Billing_Contact__r.Email
                                         from AcctSeed__Billing__c 
                                         where AcctSeed__Balance__c >0
                                         and Claim__c = null and Policy_Endorsement__c = null and Policy__c != null
                                         and AcctSeed__Due_Date2__c > TODAY and Policy__r.PaymentReceived__c = 'No Payment Received'
                                         and Computed_Payment_Type__c = null
                                        and (AcctSeed__Due_Date2__c =: day14Interval OR AcctSeed__Due_Date2__c =: day5Interval OR AcctSeed__Due_Date2__c =: day1Interval)]);
    }
    global void execute(Database.BatchableContext BC, List<AcctSeed__Billing__c> batch) {
        Map<String,Id>  emailTemplateMap =   getAllEmailTemplates();
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address = 'accounting@isbamutual.com'];
        List<Messaging.SingleEmailMessage> masterListMails = new List<Messaging.SingleEmailMessage>();
        for(AcctSeed__Billing__c inst : batch){
            PageReference pdf = new PageReference('/apex/'+inst.AcctSeed__Billing_Format__r.AcctSeed__Visualforce_PDF_Page__c);
            // add parent id to the parameters for standardcontroller
            pdf.getParameters().put('id',inst.Id);
            // the contents of the attachment from the pdf
            Blob body;
            pdf.setRedirect(true);
            if(!test.isRunningTest()){
                body = pdf.getContentasPdf();
            }
            else{
                body = blob.valueOf('Unit.Test');
            }
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType('application/pdf');
            attach.setFileName('attachment.pdf');
            attach.setInline(false);
            attach.Body = body;   
            
            Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
            message.setTargetObjectId(inst.AcctSeed__Billing_Contact__c); 
            message.setSaveAsActivity(true);
            // message.setReplyTo('no-reply@company.com');
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(true); 
            message.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
            
            message.setOrgWideEmailAddressId(owea.Id);
            message.setTemplateID(emailTemplateMap.get(inst.AcctSeed__Billing_Format__r.AcctSeed__Default_Email_Template__c)); 
            message.setWhatId(inst.Id); 
            message.toAddresses = new String[] {inst.AcctSeed__Billing_Contact__r.Email};
                
                masterListMails.add(message);
        }
        
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(masterListMails);
        
        
        for (Messaging.SendEmailResult mr : results) 
        {
            if (mr.isSuccess()) {
                System.debug('mrrr'+mr);
            }  else {
                // Operation failed, so get all errors                
                for(Messaging.SendEmailError err : mr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) { 
    }
    global void execute(SchedulableContext sc){
        Database.executeBatch(new Batch_InvoiceDueNotification(),50);
    }
    
    public static Map<String,Id> getAllEmailTemplates(){
        try{
            Map<String,Id> emailTemplateMap = new Map<String,Id>();
            List<EmailTemplate> emailTemplateList = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                     from EmailTemplate];
            
            for(EmailTemplate temp : emailTemplateList){
                emailTemplateMap.put(temp.developerName,temp.Id);
            }
            return emailTemplateMap;
        }
        catch(Exception e){
            System.debug(e.getMessage());
            return null;
        }
    }
    
}