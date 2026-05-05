trigger Billing_Trigger on AcctSeed__Billing__c (before insert,after insert,before update, after update) {
    if(Trigger.isBefore && Trigger.isInsert){
        List<AcctSeed__Payment_Processor__c> paymentProcesssor = new List<AcctSeed__Payment_Processor__c>([SELECT Id FROM AcctSeed__Payment_Processor__c WHERE Name='Fiserv']);
        for(AcctSeed__Billing__c billing : Trigger.new){
            billing.IsPaymentProcessed__c = false;
            if(!paymentProcesssor.isEmpty()){
                billing.AcctSeed__Payment_Processor__c = paymentProcesssor[0].Id;
                billing.Service_Fee__c  = String.isNotBlank(label.Service_Fee_Rate) ? Decimal.valueOf(label.Service_Fee_Rate) : null;
            }
        }
    }else if(Trigger.isAfter && Trigger.isInsert){
        //Site mySite = [select Id from Site where Name = 'Payment'];
        //SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite.Id];
        
        List<AcctSeed__Billing__c> billings = new List<AcctSeed__Billing__c>();
        for(AcctSeed__Billing__c billing : Trigger.new){
            AcctSeed__Billing__c newBilling = new AcctSeed__Billing__c();
            newBilling.Id = billing.Id; 
            newBilling.Payment_Link__c  = getUrl() + '?id=' + EncodingUtil.urlEncode(PaymentGateway_Ctrl.processEncryption(billing.Id,Label.Encryption_Key_Payment_Id),'UTF-8');
            newBilling.Internal_Payment_Link__c = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/PaymentGatewaySitePage?id=' + EncodingUtil.urlEncode(PaymentGateway_Ctrl.processEncryption(billing.Id,Label.Encryption_Key_Payment_Id),'UTF-8');
            //newBilling.Payment_Link__c  = mySiteDetail.SecureURL + '?id=' + EncodingUtil.urlEncode(PaymentGateway_Ctrl.processEncryption(billing.Id,Label.Encryption_Key_Payment_Id),'UTF-8');
            //newBilling.Internal_Payment_Link__c = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/PaymentGateway?id=' + EncodingUtil.urlEncode(PaymentGateway_Ctrl.processEncryption(billing.Id,Label.Encryption_Key_Payment_Id),'UTF-8');
            billings.add(newBilling);
        }
        
        update billings;
    }else if(Trigger.isBefore && Trigger.isUpdate){
        //Site mySite = [select Id from Site where Name = 'Payment'];
        //Site mySite = [select Id from Site where Name = 'PaymentGateway'];

        //SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite.Id];
        for(AcctSeed__Billing__c billing : Trigger.new){
            if(billing.Payment_Link__c  == null){
                billing.Payment_Link__c  = getUrl() + '?id=' + EncodingUtil.urlEncode(PaymentGateway_Ctrl.processEncryption(billing.Id,Label.Encryption_Key_Payment_Id),'UTF-8');
                //billing.Payment_Link__c  = mySiteDetail.SecureURL + '?id=' + EncodingUtil.urlEncode(PaymentGateway_Ctrl.processEncryption(billing.Id,Label.Encryption_Key_Payment_Id),'UTF-8');
            }
            if(billing.Internal_Payment_Link__c == null){
                billing.Internal_Payment_Link__c = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/PaymentGatewaySitePage?id=' + EncodingUtil.urlEncode(PaymentGateway_Ctrl.processEncryption(billing.Id,Label.Encryption_Key_Payment_Id),'UTF-8');
                //billing.Internal_Payment_Link__c = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/PaymentGateway?id=' + EncodingUtil.urlEncode(PaymentGateway_Ctrl.processEncryption(billing.Id,Label.Encryption_Key_Payment_Id),'UTF-8');
            }
        }
    }
    switch on Trigger.OperationType  {
        when AFTER_UPDATE
        {   
            Billing_Trigger_Handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    
    public static string getUrl(){
        boolean isSb = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        if(isSb){
            return 'https://sb-portal.isbamutual.com/';
        }else{
            return 'https://portal.isbamutual.com/';
        }
	}
}