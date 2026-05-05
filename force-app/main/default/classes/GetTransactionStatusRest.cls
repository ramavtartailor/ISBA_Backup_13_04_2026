@RestResource(urlMapping='/transaction/*')
global without sharing class GetTransactionStatusRest {
    @HttpPost
    global static void doGet() {    
        system.debug(RestContext.request.toString());
        system.debug(JSON.serialize(RestContext.request.params));
        Map<String,Object> response = (Map<String,Object>)RestContext.request.params;
        System.debug('response => '+response.keySet());
        
        system.debug(userInfo.getuserId());        /*Integration_Log__c log = new Integration_Log__c();
log.JSON_Body__c = JSON.serialize(RestContext.request.params);
log.Status__c = 'Processed Successfully';
log.Description__c= 'Webhook Log'; 
Insert log;*/
        
        for(String key : response.keySet()){
            system.debug(response.get(key));
        }
        
        /*if(response.containsKey('xStatus') && response.get('xStatus') == 'Approved'){
        String transactionId = String.valueOf(response.get('xRefNum'));
        List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>([SELECT Id FROM Payment_Schedule__c WHERE Status__c = 'Pending' AND Payment_Reference__c =: transactionId LIMIT 1]);
        
        if(!paymentSchedules.isEmpty()){
        paymentSchedules[0].Status__c = 'Paid';
        paymentSchedules[0].Settled_Date__c = system.today();
        //Update paymentSchedules;
        }
        }
        else*/
        if(response.containsKey('xCommand') &&  response.get('xCommand') == 'Check:Adjust'){
            String transactionId = String.valueOf(response.get('xRefNum'));
            List<Integer> statusList = new List<Integer>{20,5,14,18};
                system.debug('transactionId => '+transactionId);
            if(response.containsKey('xStatus') && statusList.contains(Integer.valueOf(String.valueOf(response.get('xStatus'))))){
                //Call negative cash receipt function
                //paymentFailed(transactionId, JSON.serialize(response));
            }
            else if(response.containsKey('xStatus') && response.get('xStatus') == '16'){
                list<AcctSeed__Cash_Receipt__c> receiptList = new List<AcctSeed__Cash_Receipt__c>([SELECT Id,ISBAM_Settlement_Date__c,AcctSeed__Description__c  FROM AcctSeed__Cash_Receipt__c WHERE AcctSeed__Payment_Reference__c =:transactionId LIMIT 1]);
                if(!receiptList.isEmpty()){
                    AcctSeed__Cash_Receipt__c receipt = receiptList[0];
                    receipt.ISBAM_Settlement_Date__c = system.today();
                    receipt.AcctSeed__Description__c = (receipt.AcctSeed__Description__c == null ?
                                                        ('[Settle: ' + receipt.ISBAM_Settlement_Date__c + ']') :
                                                        (receipt.AcctSeed__Description__c + '\n' + ('[Settle: ' + receipt.ISBAM_Settlement_Date__c + ']')));
                    
                    
                    List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>([SELECT Id, Cash_Receipt__c FROM Payment_Schedule__c WHERE Payment_Reference__c =: transactionId LIMIT 1]);
                    paymentSchedules[0].Webhook_JSON__c = JSON.serialize(response);
                    Update paymentSchedules;
                    
                    Update receipt;
                }
            }	
        }
        
    }
    
    global static void paymentFailed(String reference, String jsonBody){
        List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>([SELECT Id, Cash_Receipt__c FROM Payment_Schedule__c WHERE Payment_Reference__c =: reference LIMIT 1]);
        
        if(!paymentSchedules.isEmpty()){
            if(paymentSchedules[0].Cash_Receipt__c != null){
                List<AcctSeed__Cash_Receipt__c> crList = new List<AcctSeed__Cash_Receipt__c>([SELECT Id, Name, AcctSeed__Description__c, Processing_Type__c, AcctSeed__Credit_GL_Account__c, AcctSeed__Ledger__c, AcctSeed__Account__c, AcctSeed__Accounting_Period__c, AcctSeed__Amount__c, AcctSeed__Payment_Reference__c, AcctSeed__GL_Account_Variable_1__c,
                                                                                              (SELECT Id, AcctSeed__Adjustment_GL_Account__c, AcctSeed__Adjustment_Amount__c, AcctSeed__Accounting_Period__c, AcctSeed__Applied_Amount__c, AcctSeed__Billing__c, AcctSeed__Billing__r.ISBAM_Error_Description__c FROM AcctSeed__Billing_Cash_Receipts__r) FROM AcctSeed__Cash_Receipt__c WHERE Id =: paymentSchedules[0].Cash_Receipt__c AND AcctSeed__Payment_Reference__c =: reference LIMIT 1]);
                
                Set<String> billIds = new Set<String>();
                
                if(!crList.isEmpty()){
                    //Negetive Cash Receipt
                    AcctSeed__Cash_Receipt__c cr = new AcctSeed__Cash_Receipt__c();
                    cr.AcctSeed__Amount__c = -crList[0].AcctSeed__Amount__c;
                    //cr.AcctSeed__Accounting_Period__c = 'a1U4A0000071yTUUAY';//crList[0].AcctSeed__Accounting_Period__c;
                    cr.AcctSeed__Status__c = 'Approved';
                    cr.AcctSeed__Account__c = crList[0].AcctSeed__Account__c;
                    cr.AcctSeed__Receipt_Date__c = System.today();
                    cr.AcctSeed__Ledger__c = crList[0].AcctSeed__Ledger__c;
                    cr.AcctSeed__Credit_GL_Account__c = crList[0].AcctSeed__Credit_GL_Account__c;
                    cr.AcctSeed__Payment_Reference__c = 'rejected_'+crList[0].AcctSeed__Payment_Reference__c;
                    cr.AcctSeed__Description__c = crList[0].AcctSeed__Description__c;
                    cr.Processing_Type__c = crList[0].Processing_Type__c;
                    cr.AcctSeed__GL_Account_Variable_1__c = crList[0].AcctSeed__GL_Account_Variable_1__c;
                    //Insert cr;
                    
                    system.debug('cr => '+cr);
                    // Post the cash receipts
                    String postResults = postRecords(new List<AcctSeed__Cash_Receipt__c>{cr} , 'AcctSeed__Cash_Receipt__c');
                    //AcctSeed.PostResult[] postResults = AcctSeed.CashReceiptPostService.postCashReceipts(new List<AcctSeed__Cash_Receipt__c>{cr});
                    system.debug('postResults => '+postResults);
                    
                    List<AcctSeed__Cash_Receipt__c> updatedCR = (List<AcctSeed__Cash_Receipt__c>) System.JSON.deserializeStrict(postResults, List<AcctSeed__Cash_Receipt__c>.class);
                    cr.Id = updatedCR[0].Id;
                    
                    List<AcctSeed__Billing_Cash_Receipt__c> bcrList = new List<AcctSeed__Billing_Cash_Receipt__c>();
                    List<AcctSeed__Billing__c> billingsToUpdate = new List<AcctSeed__Billing__c>();
                    
                    for(AcctSeed__Billing_Cash_Receipt__c bcr: crList[0].AcctSeed__Billing_Cash_Receipts__r){
                        system.debug('bcr => '+bcr);
                        AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
                        bill.Id = bcr.AcctSeed__Billing__c;
                        bill.ISBAM_Error__c = 'Rejected Cash Receipt';
                        bill.ISBAM_Error_Description__c = (bcr.AcctSeed__Billing__r.ISBAM_Error_Description__c != null ? bcr.AcctSeed__Billing__r.ISBAM_Error_Description__c + '\nRejected Cash Receipt ' + crList[0].Name :  'Rejected Cash Receipt ' + crList[0].Name);
                        billingsToUpdate.add(bill);
                        billIds.add(bill.Id);
                        //Createing Billing Cash Receipt
                        AcctSeed__Billing_Cash_Receipt__c billingCashReceipt = new AcctSeed__Billing_Cash_Receipt__c();
                        billingCashReceipt.AcctSeed__Applied_Amount__c = -bcr.AcctSeed__Applied_Amount__c;
                        billingCashReceipt.AcctSeed__Billing__c = bcr.AcctSeed__Billing__c;
                        billingCashReceipt.AcctSeed__Cash_Receipt__c = cr.Id;
                        billingCashReceipt.AcctSeed__Applied_Date__c = System.today();
                        billingCashReceipt.AcctSeed__Status__c = 'Approved';
                        //billingCashReceipt.AcctSeed__Accounting_Period__c = 'a1U4A0000071yTUUAY';//bcr.AcctSeed__Accounting_Period__c;   
                        if(String.isNotBlank(bcr.AcctSeed__Adjustment_GL_Account__c)){
                            billingCashReceipt.AcctSeed__Adjustment_Amount__c = bcr.AcctSeed__Adjustment_Amount__c != null ? -bcr.AcctSeed__Adjustment_Amount__c: null;
                            billingCashReceipt.AcctSeed__Adjustment_GL_Account__c = bcr.AcctSeed__Adjustment_GL_Account__c;
                        }
                        
                        system.debug(billingCashReceipt);
                        bcrList.add(billingCashReceipt);
                    }
                    //Insert bcrList;
                    
                    System.debug('bcrList => '+bcrList);
                    String bcrPostResults = postRecords(bcrList , 'AcctSeed__Billing_Cash_Receipt__c');
                    //AcctSeed.PostResult[] bcrPostResults = AcctSeed.BillingCashReceiptPostService.postBillingCashReceipts(bcrList);
                    system.debug('bcrPostResults => '+bcrPostResults);
                    
                    
                    if(!billingsToUpdate.isEmpty()){
                        Update billingsToUpdate;
                        //send Email On Error
                        sendEmail(billIds, reference);
                        
                    }
                    
                }
            }
            else{
                paymentSchedules[0].Manual_Attention_Required__c = true;
            } 
            paymentSchedules[0].Webhook_JSON__c = jsonBody;
            paymentSchedules[0].Status__c = 'Rejected';
            paymentSchedules[0].Settled_Date__c = null;
            paymentSchedules[0].Cash_Receipt__c = null;
            paymentSchedules[0].Paid_Amount__c = 0;
            Update paymentSchedules;
        }
    } 
    
    
    @future
    public static void sendEmail(Set<String> billIds, String reference){
        List<Payment_Schedule__c> paymentSchedules = new List<Payment_Schedule__c>([SELECT Id, Cash_Receipt__c FROM Payment_Schedule__c WHERE Payment_Reference__c =: reference LIMIT 1]);
        List<AcctSeed__Billing__c> billings = [SELECT Id,AcctSeed__Billing_Contact__c, Billing_Confirmation_Email__c FROM AcctSeed__Billing__c WHERE Id=: billIds];
        List<EmailTemplate> templateList = new List<EmailTemplate>([Select id,Subject,Body,HtmlValue from EmailTemplate where name ='ACH Reject Template']);
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
        
        String orgWideEmailAddressId = [select Id,Address from OrgWideEmailAddress where Address = 'accounting@isbamutual.com'].Id;
        
        for(AcctSeed__Billing__c bill : billings){
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateList[0].Id,bill.AcctSeed__Billing_Contact__c,paymentSchedules[0].Id);
            
            Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
            
            emailMsg.setSubject(email.getSubject());
            emailMsg.setToAddresses(new String[] {bill.Billing_Confirmation_Email__c});
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
        Messaging.SendEmailResult [] r = Messaging.sendEmail(emailList);
    }
    
    
    public static String postRecords(List<Sobject> records, String obj){
        try{
            String msg = '';
            String jsonBody = '{"Records" : '+JSON.serialize(records)+',"obj":'+JSON.serialize(obj)+'}';
            
            system.debug(jsonBody);
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:CashReceipt_Api/services/apexrest/posting');
            request.setMethod('POST');
            request.setHeader('Content-Type','application/json');
            request.setBody(jsonBody);
            request.setTimeout(120000);
            Http http = new Http();
            HttpResponse response = new HttpResponse();
            system.debug('796::');
            if(!test.isRunningTest()) {
                response = http.send(request); 
                msg  = response.getBody(); 
                system.debug(msg); 
                return msg;  
            }
            else{
                response.setHeader('Content-Type', 'application/json');
                response.setStatusCode(200);
                system.debug('records => '+records);
                insert records;
                return JSON.serialize(records);
            }
        }
        Catch(Exception e){
            system.debug('Error at '+e.getLineNumber()+'   '+ e.getMessage());
            return null;
        }
    }
    
}