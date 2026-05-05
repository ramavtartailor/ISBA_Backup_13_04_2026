@RestResource(urlMapping='/sendPaymentFailedError/*')
global class SendEmailHelper {
    @HttpPost
    global static void emailRecords(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String RequestedBody = req.requestBody.toString();
        try{
            system.debug('RequestedBody -- > ' + RequestedBody);
            object bodyRequest = JSON.deserializeUntyped(RequestedBody);
            
            Map<String,Object> Requestedmap = (Map<String,Object>) bodyRequest;
            
            Object recordList = (object) Requestedmap.get('billIds');
            List<String> ObjLis = (List<String>)Json.deserialize(JSON.serialize(recordList),List<String>.class);
            String reference = (String) Requestedmap.get('ref');
            
            sendEmail(ObjLis, reference);
            res.responseBody = Blob.valueOf('Success');
            res.statusCode = 200;
        }
        catch(Exception e){
            res.statusCode = 500;
            system.debug('Error : '+e.getMessage());
            res.responseBody = Blob.valueOf('Error : '+e.getMessage());
        }
        
    }
    
    global static void sendEmail(List<String> billIds, String reference){
        List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>([SELECT Id, Cash_Receipt__c FROM Payment_Schedule__c WHERE Payment_Reference__c =: reference LIMIT 1]);
        List<AcctSeed__Billing__c> billings = [SELECT Id,AcctSeed__Billing_Contact__c,AcctSeed__Billing_Contact__r.Email, Billing_Confirmation_Email__c,Policy__r.Firm_Contact_Email__c FROM AcctSeed__Billing__c WHERE Id=: billIds];
        List<EmailTemplate> templateList = new List<EmailTemplate>([Select id,Subject,Body,HtmlValue from EmailTemplate where name ='ACH Reject Template']);
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
        
        String orgWideEmailAddressId = [select Id,Address from OrgWideEmailAddress where Address = 'accounting@isbamutual.com'].Id;
        
        for(AcctSeed__Billing__c bill : billings){
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateList[0].Id,bill.AcctSeed__Billing_Contact__c,paymentSchedules[0].Id);
            
            Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
            String emailAddress = '';
            List<String> ccEmailAddress = new List<String>();
            
            if(String.isNotBlank(bill.Billing_Confirmation_Email__c)){
                emailAddress = bill.Billing_Confirmation_Email__c;
            } 
            
            if(String.isNotBlank(bill.AcctSeed__Billing_Contact__c) && String.isNotBlank(bill.AcctSeed__Billing_Contact__r.Email) ){
                if(String.isNotBlank(emailAddress)){
                    emailAddress = bill.AcctSeed__Billing_Contact__r.Email;
                }
                else{
                    ccEmailAddress.add(bill.AcctSeed__Billing_Contact__r.Email);
                }
            }else if(String.isNotBlank(bill.Policy__r.Firm_Contact_Email__c)){
                if(String.isNotBlank(emailAddress)){
                    emailAddress = bill.Policy__r.Firm_Contact_Email__c;
                }
                else{
                    ccEmailAddress.add(bill.Policy__r.Firm_Contact_Email__c);
                }
            }
            
            if(String.isNotBlank(emailAddress)){
                emailMsg.setSubject(email.getSubject());
                emailMsg.setToAddresses(new String[] {emailAddress});
                if(!ccEmailAddress.isEmpty()){
                   emailMsg.setCcAddresses(ccEmailAddress); 
				}
                emailMsg.setOrgWideEmailAddressId(orgWideEmailAddressId);
                
                String emailBody = email.getHtmlBody();
                emailBody = emailBody.replaceAll('<p><br></p>','<br><br>');
                emailBody = emailBody.replaceAll('</p><p>','<br/>');
                emailBody = emailBody.replaceAll('</p>','');
                emailBody = emailBody.replaceAll('<p>','');
                
                emailMsg.setHtmlBody(emailBody);
                emailMsg.setWhatId(bill.Id);
                emailMsg.setSaveAsActivity(true);
                emailList.add(emailMsg);
            }
        }
        
        if(!emailList.isEmpty()){
            Messaging.SendEmailResult [] r = Messaging.sendEmail(emailList);
        }
    }
}