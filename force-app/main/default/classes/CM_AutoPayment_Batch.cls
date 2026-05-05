Global class CM_AutoPayment_Batch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.stateful{
    
    Global String paymtSchId{get;set;}
    Global CM_AutoPayment_Batch(String recId){
        this.paymtSchId = recId;
    }
    Global CM_AutoPayment_Batch(){
        this.paymtSchId = '';
    }
    
    Global Database.QueryLocator start(Database.BatchableContext BC) {
        Date d = system.toDay();
        String query = 'SELECT Id, Payment_Method__c, Service_Fee_Rate__c, Billing__c, Billing__r.AcctSeed__Customer__c, Billing__r.AcctSeed__Balance__c, Frequency__c, Due_Amount__c, Amount__c, Due_Date__c FROM Payment_Schedule__c WHERE Due_Amount__c > 0 AND Billing__r.AcctSeed__Balance__c > 0 AND Payment_Schedule_Type__c != \'Physical Check\' AND Billing__r.AcctSeed__Payment_Processor__r.Name = \'Cardknox\'';
        if(String.isNotBlank(paymtSchId)){
            query += ' AND Status__c IN (\'Unpaid\',\'Rejected\') AND Due_Date__c <=: d  AND Id =: paymtSchId';
        }
        else{
            query += ' AND Due_Date__c =: d  AND Status__c IN (\'Unpaid\')'; 
        }
        system.debug('query => '+query);
        return Database.getQueryLocator(query);
    }
    
    Global void execute(Database.BatchableContext BC, List<Payment_Schedule__c> paymentSchedules) {
        system.debug('execute');
        system.debug('paymentSchedules =>'+paymentSchedules);
        Set<String> billIds = new Set<String>();
        Set<String> accIds = new Set<String>();
        Set<String> payMethodIds = new Set<String>();
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        
        Map<String, Payment_Schedule__c> bill_Id_with_PaymentSchedule_Map = new Map<String, Payment_Schedule__c>();
        for (Payment_Schedule__c ps : paymentSchedules) {
            system.debug('Payment Schedule => '+ps);
            payMethodIds.add(ps.Payment_Method__c);
            billIds.add(ps.Billing__c);
            accIds.add(ps.Billing__r.AcctSeed__Customer__c);
            bill_Id_with_PaymentSchedule_Map.put(ps.Billing__c, ps);
        }
        List<AcctSeed__Billing__c> billings = new List<AcctSeed__Billing__c>([SELECT Id, Name, AcctSeed__Balance__c, ISBAM_Error_Description__c, Billing_First_Name__c, Billing_Last_Name__c, Policy__c, Billing_Confirmation_Email__c, Legacy_Invoice_Id__c, Legacy_Firm_Id__c, AcctSeed__Due_Date2__c, Firm_Name__c, AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c, AcctSeed__Accounting_Period__c , AcctSeed__Billing_Contact__r.FirstName, AcctSeed__Billing_Contact__r.LastName, AcctSeed__Customer__c, AcctSeed__Customer__r.Forte_Id__c, Payment_Frequency__c,(SELECT Id,AcctSeed__GL_Account_Variable_1__c FROM AcctSeed__Project_Billing_Lines__r), (SELECT Id, Amount__c, Service_Fee_Amount__c, Due_Date__c FROM Payment_Schedules__r WHERE Due_Date__c > TODAY order by Due_Date__c ) FROM AcctSeed__Billing__c WHERE Id IN: billIds]);
        
        List<Integration_Log__c> logList = new List<Integration_Log__c>();  
        
        List<OrgWideEmailAddress> oweaList = [select Id,DisplayName,Address from OrgWideEmailAddress Where DisplayName =: Label.OrganizationWideEmail];
        
        Map<String,AcctSeed__Payment_Method__c> paymentMethodMap = new Map<String,AcctSeed__Payment_Method__c>([SELECT Id, AcctSeed__External_Id__c, AcctSeed__Account_Number__c, AcctSeed__Payment_Method_Type__c FROM AcctSeed__Payment_Method__c WHERE Id IN : payMethodIds]);
        
        Map<String, AcctSeed__Cash_Receipt__c> bill_cashReceipt_Map = new Map<String, AcctSeed__Cash_Receipt__c>(); 
        
        List<AcctSeed__Billing_Cash_Receipt__c> billingCashReceiptList = new List<AcctSeed__Billing_Cash_Receipt__c>();
        
        Id accountPeriodId = [SELECT id,name,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM  AcctSeed__Accounting_Period__c  WHERE AcctSeed__Status__c = 'Open' and AcctSeed__Start_Date__c<=TODAY and AcctSeed__End_Date__c>=TODAY limit 1][0].id;
        
        for(AcctSeed__Billing__c bill: billings){            
            Payment_Schedule__c paySchedule = bill_Id_with_PaymentSchedule_Map.get(bill.Id);
            try{                
                if(bill.AcctSeed__Balance__c >= paySchedule.Due_Amount__c){                    
                    boolean paymentSuccess = false;
                    boolean send = false;
                    String payMethodToken = '';
                    Boolean isCheck = false;
                    // ForteUtilNew util;
                    
                    AcctSeed__Payment_Method__c Paymethod = paymentMethodMap.get(paySchedule.Payment_Method__c);
                    PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper wrapperObj = new PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper();
                    wrapperObj.firstName= bill.AcctSeed__Billing_Contact__r.FirstName;
                    wrapperObj.lastName= bill.AcctSeed__Billing_Contact__r.LastName;
                    wrapperObj.firmId= bill.Legacy_Firm_Id__c;
                    wrapperObj.firmName= bill.Firm_Name__c;
                    if(paySchedule.Frequency__c == 'Quaterly'){
                        wrapperObj.nextPaymentDate = String.valueOf(System.today().addMonths(3));
                    }
                    else {
                        wrapperObj.nextPaymentDate = String.valueOf(System.today().addMonths(1));
                    }
                    
                    wrapperObj.invoiceId= bill.Legacy_Invoice_Id__c;
                    if(Paymethod.AcctSeed__Payment_Method_Type__c == 'Credit Card'){
                        wrapperObj.paymentTypeVar = 'creditCard';
                    }
                    else{
                        wrapperObj.paymentTypeVar = 'check';
                        isCheck = true;
                    }
                    wrapperObj.accountNumber= Paymethod.AcctSeed__Account_Number__c;
                    wrapperObj.payMethodToken= Paymethod.AcctSeed__External_Id__c;
                    wrapperObj.cardNumber= Paymethod.AcctSeed__Account_Number__c;
                    wrapperObj.totalAmountDue = paySchedule.Due_Amount__c < paySchedule.Billing__r.AcctSeed__Balance__c ? paySchedule.Due_Amount__c : paySchedule.Billing__r.AcctSeed__Balance__c;
                    wrapperObj.ccFeeRate = paySchedule.Service_Fee_Rate__c == null ? 0 : paySchedule.Service_Fee_Rate__c;
                    
                    
                    //Map<String,Object> authResponseMp = CardknoxUtil.ProcessTransaction(0.01 ,wrapperObj, 'Auth');
                    
                    wrapperObj.billing = new AcctSeed__Billing__c(id = bill.id);
                    string transactionGatewayResponse = '';
                    string transactionGatewayError = '';
                    
                    Map<String,Object> transactionResponseMp = CardknoxUtil.ProcessTransaction(wrapperObj.totalAmountDue ,wrapperObj, null);
                    system.debug('transactionResponseMp => '+transactionResponseMp);
                    
                    if((string)transactionResponseMp.get('Result')=='S' && (string)transactionResponseMp.get('GatewayStatus')=='Approved'){
                        paymentSuccess = true;
                        transactionGatewayResponse = (String)transactionResponseMp.get('GatewayRefNum');
                        
                        if(bill.Billing_Confirmation_Email__c != null){
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setSaveAsActivity(true);
                            mail.setWhatId(bill.id);
                            //mail.setSenderDisplayName('ISBA Mutual Insurance');
                            mail.setToAddresses(new String[]{bill.Billing_Confirmation_Email__c});
                            mail.setSubject('ISBA Mutual Insurance - Payment Received');
                            if(oweaList!= null && oweaList.size() > 0){
                                mail.setOrgWideEmailAddressId(oweaList[0].Id);
                            }
                            String body = 'Dear ' + wrapperObj.firstName+' '+wrapperObj.lastName + ', <br/>';
                            String billing='';
                            if(bill.Legacy_Invoice_Id__c!=null){
                                billing = bill.Legacy_Invoice_Id__c;
                            }else{
                                billing = bill.Name;
                            }
                            body += 'Your payment of $'+wrapperObj.totalAmountDue.setScale(2) +' for bill #'+ billing + ' have been successfully processed.<br/>';
                            body += 'For your reference, the transaction number for this is: '+ transactionGatewayResponse + '<br/>';
                            
                            if(!bill.Payment_Schedules__r.isEmpty()){
                                body += '<br/>Your future payments will be executed as follows;<br/><br/><br/>Payment Schedule:<br/><br/>';
                                for(Payment_Schedule__c ps : bill.Payment_Schedules__r){
                                    
                                    Decimal amount = ps.Amount__c + ps.Service_Fee_Amount__c;
                                    body += '$'+amount.setScale(2) +'     ('+ ps.Due_Date__c.format() +')<br/>';
                                    
                                }
                                body += '<br/>' ;
                            }
                            
                            body += 'Thank you,<br/>ISBA Mutual Accounting Department<br/>312-379-2005';
                            mail.setHtmlBody(body);
                            allmsg.add(mail);
                        }
                        
                    }else{
                        paymentSuccess = false;
                        if((String)transactionResponseMp.get('Error')!=''){
                            transactionGatewayError = 'in Processing Transaction at Line no. 108. => '+(String)transactionResponseMp.get('Error');
                        }else {
                            transactionGatewayError = 'in Processing Transaction at Line no. 108. => '+(String)transactionResponseMp.get('GatewayErrorMessage');
                        }
                    }
                    
                    if(paymentSuccess){    
                        paySchedule.Paid_Amount__c = paymentSchedules[0].Amount__c;
                        paySchedule.Status__c = 'Pending';
                        paySchedule.Payment_Reference__c = transactionGatewayResponse;
                        
                        Integration_Log__c log = new Integration_Log__c();
                        log.Billing__c =bill.id;
                        log.Payment_Schedule__c = paySchedule.Id;
                        log.Status__c='Processed Successfully';
                        log.Transaction_Amount__c=wrapperObj.totalAmountDue;
                        log.Description__c='Payment Processed succesfully.';
                        log.Transaction_Id__c = transactionGatewayResponse;
                        log.JSON_Body__c = JSON.serialize(wrapperObj);
                        log.Response_Body__c = JSON.serialize(transactionResponseMp);
                        logList.add(log);
                        
                    }else{
                        paySchedule.Status__c = 'Rejected';
                        
                        Integration_Log__c log = new Integration_Log__c();
                        log.Billing__c =bill.id;
                        log.Payment_Schedule__c = paySchedule.Id;
                        log.Status__c='Processed With Errors';
                        log.Transaction_Amount__c=wrapperObj.totalAmountDue;
                        log.Description__c='(Error : '+ transactionGatewayError+').';
                        log.JSON_Body__c = JSON.serialize(wrapperObj);
                        log.Response_Body__c = JSON.serialize(transactionResponseMp);
                        logList.add(log);
                        
                        bill.ISBAM_Error__c='Rejected Payment';
                        bill.ISBAM_Error_Description__c = (bill.ISBAM_Error_Description__c != null ? bill.ISBAM_Error_Description__c + '\n[' + (System.now().format('MM/dd/yyyy')) + '] Cardknox Error ' + log.Description__c :  '[' + (System.now().format('MM/dd/yyyy')) + '] Cardknox Error ' + log.Description__c);
                        //billingList.add(new AcctSeed__Billing__c(id=billing.Id,,ISBAM_Error_Description__c = (billing.ISBAM_Error_Description__c != null ? billing.ISBAM_Error_Description__c + '\n[' + (System.now().format('MM/dd/yyyy')) + '] Forte Error ' + log.Description__c :  '[' + (System.now().format('MM/dd/yyyy')) + '] Forte Error ' + log.Description__c)));
                    }
                }
                else{
                    paySchedule.Status__c = 'Rejected';
                    
                    Integration_Log__c log = new Integration_Log__c();
                    log.Billing__c =bill.id;
                    log.Payment_Schedule__c = paySchedule.Id;
                    log.Status__c='Processed With Errors';
                    log.Transaction_Amount__c = bill.AcctSeed__Balance__c;
                    log.Description__c = '(Error : Payment Schedule exceeds Billing balance).';
                    logList.add(log);
                    
                    bill.ISBAM_Error__c='Rejected Payment';
                    bill.ISBAM_Error_Description__c = (bill.ISBAM_Error_Description__c != null ? bill.ISBAM_Error_Description__c + '\n[' + (System.now().format('MM/dd/yyyy')) + '] Schedule Error ' + log.Description__c :  '[' + (System.now().format('MM/dd/yyyy')) + '] Schedule Error ' + log.Description__c);
                }
                //Updating  bill Record
                bill.Online_Payment_User__c = UserInfo.getUserId();
                
                
            }catch(Exception e){
                //currentStage='contactDetails';
                system.debug('error -> '+e.getMessage()+' Line -> '+e.getLineNumber());
                Integration_Log__c log = new Integration_Log__c();
                log.Billing__c =bill.id;
                log.Status__c='Processed With Errors';
                log.Transaction_Amount__c=paySchedule.Due_Amount__c;
                log.Description__c='Error : '+e.getMessage() + '\n' + e.getStackTraceString() + '\n';
                logList.add(log);
            }
            
        }
        
        system.debug('Billings => '+billings);
        if(!billings.isEmpty()){
            Update billings;
        }
        
        system.debug('Log List  => '+logList);
        if(!logList.isEmpty()){
            String csvString = 'Invoice,Amount,Transaction Id,Status,Description\n';
            for(Integration_Log__c logs:logList){
                csvString = csvString + logs.Billing__c + ',' + logs.Transaction_Amount__c + ',' + logs.Transaction_Id__c + ',' + logs.Status__c + ',' + logs.Description__c + '\n';
            }
            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
            Blob csvBlob = blob.valueOf(csvString);
            String csvName = 'Scheduled_Payment_Status_'+Date.today()+'.csv';
            csvAttachment.setFileName(csvName);
            csvAttachment.setBody(csvBlob);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSaveAsActivity(false);
            //mail.setSenderDisplayName('ISBA Mutual Insurance');
            //List<OrgWideEmailAddress> oweaList = [select Id,DisplayName,Address from OrgWideEmailAddress Where DisplayName =: Label.OrganizationWideEmail];
            if (!oweaList.isEmpty()) {
                mail.setOrgWideEmailAddressId(oweaList.get(0).Id);
            }
            mail.setToAddresses(new String[]{Label.ISBA_Accounting_Automation_Email_Address});
            mail.setSubject('Scheduled Payments Processing Status');
            String body = 'Dear, <br/><br/>';
            body += 'Please find attached file for the scheduled payment processing status.';
            mail.setHtmlBody(body);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
            allmsg.add(mail);
            Insert logList;
        }
        
        system.debug('allmsg => '+allmsg);
        
        if(!allmsg.isEmpty()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsg,false);
            
            for(Messaging.SendEmailResult res : results){
                system.debug('res => '+res);
            }
        }
        
        system.debug('PaymentSchedules => '+paymentSchedules);
        if(!paymentSchedules.isEmpty()){
            Update paymentSchedules;
        }
    }
    
    Global void finish(Database.BatchableContext BC) {
    }
    
    Global void execute(SchedulableContext sc){
        Database.executeBatch(new CM_AutoPayment_Batch(),1);
    }
}