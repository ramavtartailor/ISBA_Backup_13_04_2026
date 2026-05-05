global class Batch_CardExpirationEmail implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.Stateful {
global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Due_Date__c, Status__c, Billing__r.Billing_Confirmation_Email__c, Billing__r.AcctSeed__Billing_Contact__r.Email, Fiserv_Payment_Method__r.Expiry_Month__c, Fiserv_Payment_Method__r.Expiry_Year__c, Billing__r.Policy__r.Firm_Contact_Email__c 
                                         FROM Payment_Schedule__c WHERE (Status__c = 'Unpaid' OR Status__c = 'Rejected') AND Due_Date__c >= TODAY AND Due_Date__c <= NEXT_N_DAYS:20 AND Fiserv_Payment_Method__r.Type__c = 'Credit_Card' 
                                         AND Fiserv_Payment_Method__r.Expiry_Month__c <=: System.today().month() AND Fiserv_Payment_Method__r.Expiry_Year__c <=: System.today().year()]);
    }
    global void execute(Database.BatchableContext BC, List<Payment_Schedule__c> scope){
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        //List<User> userList= [select id,email from User where name='IT User'];
        List<OrgWideEmailAddress> oweaList = [select Id,DisplayName from OrgWideEmailAddress Where DisplayName =: Label.OrganizationWideEmail];
        
        List<EmailTemplate> templateList = new List<EmailTemplate>([Select id,Subject,Body,HtmlValue from EmailTemplate where name = 'Credit_Card_Expiry_Notification_Template']);
        if (templateList.isEmpty()) {
            return;
        }
        Id templateId = templateList[0].Id;                
        String emailAdmin='';
        for (Payment_Schedule__c ps : scope) {
            List<String> toAddresses = new List<String>();
            List<String> ccAddresses = new List<String>(); 

            // TO ADDRESSES

            // Billing confirmation email
            if (ps.Billing__r != null && ps.Billing__r.Billing_Confirmation_Email__c != null) {
                toAddresses.add(ps.Billing__r.Billing_Confirmation_Email__c);
                if(ps.Billing__r.AcctSeed__Billing_Contact__c != null && ps.Billing__r.AcctSeed__Billing_Contact__r.Email != null){
                    ccAddresses.add(ps.Billing__r.AcctSeed__Billing_Contact__r.Email);
				}
                else if(String.isNotBlank(ps.Billing__r.Policy__r.Firm_Contact_Email__c)){
                    ccAddresses.add(ps.Billing__r.Policy__r.Firm_Contact_Email__c);
                }
            }
            else if (ps.Billing__r != null && ps.Billing__r.AcctSeed__Billing_Contact__c != null && ps.Billing__r.AcctSeed__Billing_Contact__r.Email != null) {
                toAddresses.add(ps.Billing__r.AcctSeed__Billing_Contact__r.Email);
                if(String.isNotBlank(ps.Billing__r.Policy__r.Firm_Contact_Email__c)){
                    ccAddresses.add(ps.Billing__r.Policy__r.Firm_Contact_Email__c);
                }
            }   
        

            Id targetContactId;
            if (ps.Billing__c != null && ps.Billing__r.AcctSeed__Billing_Contact__c != null) {
                targetContactId = ps.Billing__r.AcctSeed__Billing_Contact__c;
            }
            else if (ps.Billing__c != null && ps.Billing__r.Policy__r != null && ps.Billing__r.Policy__r.Primary_Contact__c != null) {
                targetContactId = ps.Billing__r.Policy__r.Primary_Contact__c;
            }
            if (targetContactId == null || toAddresses.isEmpty()) {
                continue;
            }
                Messaging.SingleEmailMessage renderedEmail = Messaging.renderStoredEmailTemplate(templateId,targetContactId,ps.Id);
            
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);
                mail.setBccAddresses(new String[]{Label.ISBA_Accounting_Automation_Email_Address });
                mail.setSubject(renderedEmail.getSubject());
                mail.setHtmlBody(renderedEmail.getHtmlBody());
                mail.setSaveAsActivity(true);

                if (!ccAddresses.isEmpty()) {
                    mail.setCcAddresses(ccAddresses);
                }

                if (!oweaList.isEmpty()) {
                    mail.setOrgWideEmailAddressId(oweaList[0].Id);
                }

                mail.setInReplyTo(Label.ISBA_Accounting_Email_Address);

                allmsg.add(mail);



        }
        if (!allmsg.isEmpty()) {
            Messaging.sendEmail(allmsg, false);
        }

    }

    global void finish(Database.BatchableContext bc) {
        
    }

    global void execute(SchedulableContext sc) {
        
    }
}