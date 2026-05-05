global class Batch_EmailNotificationCreditCardExpiry  implements Database.Batchable<Sobject>,Schedulable{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Integer month = System.today().addMonths(2).month();
        Integer year = System.today().addMonths(2).year();
        Integer month1 = System.today().addDays(-7).addMonths(2).month();
        Integer year1 = System.today().addDays(-7).addMonths(2).year();
        return Database.getQueryLocator([select id,Billing_Card_Expire_Month__c,Billing_Card_Expire_Year__c,Billing_Confirmation_Email__c,Billing_First_Name__c,Billing_Last_Name__c
                                         from AcctSeed__Billing__c where ((Billing_Card_Expire_Month__c=:month and Billing_Card_Expire_Year__c=:year) OR (Billing_Card_Expire_Month__c=:month1 and Billing_Card_Expire_Year__c=:year1)) and Next_Payment_Date__c > TODAY]);
    }
    global void execute(Database.BatchableContext BC, List<AcctSeed__Billing__c> batch) {
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        //List<User> userList= [select id,email from User where name='IT User'];
        List<OrgWideEmailAddress> oweaList = [select Id,DisplayName from OrgWideEmailAddress Where DisplayName =: Label.OrganizationWideEmail];
        
        List<EmailTemplate> templateList = new List<EmailTemplate>([Select id,Subject,Body,HtmlValue from EmailTemplate where name = 'Credit_Card_Expiry_Notification_Template']);
        
        Id templateId = templateList[0].Id;                
        String emailAdmin='';
        /*if(userList.size()>0 && userList[0].email!=null){
            emailAdmin = userList[0].email;
        }*/
        for(AcctSeed__Billing__c obj : batch){
            
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId,UserInfo.getUserId(),obj.Id);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSaveAsActivity(false);
            //mail.setSenderDisplayName('ISBA Mutual Insurance');
            if (!oweaList.isEmpty()) {
                mail.setOrgWideEmailAddressId(oweaList.get(0).Id);
            }
            //mail.setToAddresses(new String[]{obj.Billing_Confirmation_Email__c,emailAdmin});
            mail.setToAddresses(new String[]{obj.Billing_Confirmation_Email__c});
            mail.setSubject(email.getSubject());
            mail.setBccAddresses(new String[]{Label.ISBA_Accounting_Automation_Email_Address });
            mail.setInReplyTo(Label.ISBA_Accounting_Email_Address);
            /*String body = 'Dear ' + obj.Billing_First_Name__c+' '+obj.Billing_Last_Name__c + '<br/><br/>';
            body += 'This is a notice to inform you that your card on record with ISBA Mutual will be expiring in two months.<br/>';
            body += 'Please contact the ISBA Mutual Accounting Department at 312-379-2000 to update your card information.<br/><br/>';
            body += 'Thank you,<br/>ISBA Mutual<br/>312-379-2000';*/
            mail.setHtmlBody(email.getHtmlBody());
            allmsg.add(mail);
        }
        Messaging.sendEmail(allmsg,false);

    }
    global void finish(Database.BatchableContext BC) { 
    }
    global void execute(SchedulableContext sc){
        Database.executeBatch(new Batch_EmailNotificationCreditCardExpiry());
    }
}