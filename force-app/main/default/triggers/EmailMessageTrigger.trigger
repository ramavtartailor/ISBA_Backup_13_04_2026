trigger EmailMessageTrigger on EmailMessage (before insert, after insert) {
    Set<Id> successEmailBill = new Set<Id>();
    try{
        if(Trigger.isBefore && trigger.isInsert){
            for(EmailMessage message: Trigger.New){
                //List<String> emailAddress = new List<String>{'rachit@cmentor.com','sanyam@cmentor.com'};
                List<String> emailDomains = System.label.Allowed_Email_Domain.split(',');
                System.debug(message.toAddress);
                if(System.label.Enable_Stop_Sending_Email == 'Y'){
                    for(String str : message.toAddress.split(';')){
                        if(!emailDomains.contains(str.split('@')[1])){
                            message.addError('Email Alert: You are not allowed to send an email outside your organization. Please use another email address and try again');
                        }
                    }
                }
            }
            
        }
        else if(Trigger.isAfter && Trigger.isInsert){
            for(EmailMessage message: Trigger.New){
                Id recordId = message.RelatedToId;
                if(recordId != null && String.valueOf(recordId.getsobjecttype()) == 'AcctSeed__Billing__c'){
                    successEmailBill.add(recordId);
                }
            }
            if(!successEmailBill.isEmpty()){
                EmailMessageTriggerHandler.updateEmailStatus(successEmailBill);
            }
            
            
            PolicyAndBillingActivityUpdateHandler.onAfterInsertEmailMessage(trigger.new);
            
        }
        
    }
    catch(Exception e){
        System.debug(e.getStackTraceString());
    }
}