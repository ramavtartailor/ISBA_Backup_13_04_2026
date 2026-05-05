global class Batch_PaymentGateway implements Database.Batchable<Sobject>,Schedulable,Database.AllowsCallouts{
    public Set<Id> billingIds;
    public Date dateOfPaymentToProcess;
    global Batch_PaymentGateway(Date dateOfPaymentToProcess){
        this.dateOfPaymentToProcess = dateOfPaymentToProcess;
    }
    
    global Batch_PaymentGateway(Set<Id> billingIds){
        this.billingIds = billingIds;
    }
    
    global Batch_PaymentGateway(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(dateOfPaymentToProcess != null){
            return Database.getQueryLocator([select id,First_Payment_Date__c,Mode_Of_Payment__c,Next_Payment_Base_Amount__c,Next_Payment_Service_Fee__c,Payment_Frequency__c,AcctSeed__Balance__c,Next_Payment_Date__c,
                                             Billing_Account_Holder_Name__c,Billing_Account_Number__c,Billing_Account_Type__c,
                                             Billing_Routing_Number__c,Billing_Card_Expire_Month__c,Billing_Card_Expire_Year__c,
                                             Billing_Card_Number__c,Billing_Card_Type__c,Billing_Card_Verification_Number__c,
                                             Billing_Name_On_Card__c,Billing_Confirmation_Email__c,Billing_First_Name__c,AcctSeed__Date__c,ISBAM_Error_Description__c,
                                             Billing_Last_Name__c,name,Legacy_Invoice_Id__c,AcctSeed__Customer__c,AcctSeed__Customer__r.Name,Legacy_Firm_Id__c,Firm_Name__c,AcctSeed__Customer__r.AccountNumber,AcctSeed__Accounting_Period__c,AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c,
                                             (select id,AcctSeed__GL_Account_Variable_1__c from AcctSeed__Project_Billing_Lines__r )
                                             from AcctSeed__Billing__c where IsPaymentProcessed__c = true and Next_Payment_Date__c =: dateOfPaymentToProcess  and AcctSeed__Balance__c > 0 and Next_Payment_Base_Amount__c > 0]);
        }else if(billingIds != null){
            return Database.getQueryLocator([select id,First_Payment_Date__c,Mode_Of_Payment__c,Next_Payment_Base_Amount__c,Next_Payment_Service_Fee__c,Payment_Frequency__c,AcctSeed__Balance__c,Next_Payment_Date__c,
                                             Billing_Account_Holder_Name__c,Billing_Account_Number__c,Billing_Account_Type__c,
                                             Billing_Routing_Number__c,Billing_Card_Expire_Month__c,Billing_Card_Expire_Year__c,
                                             Billing_Card_Number__c,Billing_Card_Type__c,Billing_Card_Verification_Number__c,
                                             Billing_Name_On_Card__c,Billing_Confirmation_Email__c,Billing_First_Name__c,AcctSeed__Date__c,ISBAM_Error_Description__c,
                                             Billing_Last_Name__c,name,Legacy_Invoice_Id__c,AcctSeed__Customer__c,AcctSeed__Customer__r.Name,Legacy_Firm_Id__c,Firm_Name__c,AcctSeed__Customer__r.AccountNumber,AcctSeed__Accounting_Period__c,AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c,
                                             (select id,AcctSeed__GL_Account_Variable_1__c from AcctSeed__Project_Billing_Lines__r )
                                             from AcctSeed__Billing__c where IsPaymentProcessed__c = true and Id in: billingIds  and AcctSeed__Balance__c > 0 and Next_Payment_Date__c <=: System.today()  and Next_Payment_Base_Amount__c > 0]);
        }else{
            return Database.getQueryLocator([select id,First_Payment_Date__c,Mode_Of_Payment__c,Next_Payment_Base_Amount__c,Next_Payment_Service_Fee__c,Payment_Frequency__c,AcctSeed__Balance__c,Next_Payment_Date__c,
                                             Billing_Account_Holder_Name__c,Billing_Account_Number__c,Billing_Account_Type__c,
                                             Billing_Routing_Number__c,Billing_Card_Expire_Month__c,Billing_Card_Expire_Year__c,
                                             Billing_Card_Number__c,Billing_Card_Type__c,Billing_Card_Verification_Number__c,
                                             Billing_Name_On_Card__c,Billing_Confirmation_Email__c,Billing_First_Name__c,AcctSeed__Date__c,ISBAM_Error_Description__c,
                                             Billing_Last_Name__c,name,Legacy_Invoice_Id__c,AcctSeed__Customer__c,AcctSeed__Customer__r.Name,Legacy_Firm_Id__c,Firm_Name__c,AcctSeed__Customer__r.AccountNumber,AcctSeed__Accounting_Period__c,AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c,
                                             (select id,AcctSeed__GL_Account_Variable_1__c from AcctSeed__Project_Billing_Lines__r )
                                             from AcctSeed__Billing__c where IsPaymentProcessed__c = true and Next_Payment_Date__c = TODAY  and AcctSeed__Balance__c > 0  and Next_Payment_Base_Amount__c > 0]);
        }
    }
    global void execute(Database.BatchableContext BC, List<AcctSeed__Billing__c> batch) {
        System.debug(batch.size());
        try{
            List<Integration_Log__c> logsList = new List<Integration_Log__c>();
            Id accountPeriodId = [SELECT id,name,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM  AcctSeed__Accounting_Period__c  WHERE AcctSeed__Status__c = 'Open' and AcctSeed__Start_Date__c<=TODAY and AcctSeed__End_Date__c>=TODAY limit 1][0].id;
            List<AcctSeed__Cash_Receipt__c> cashReceiptList = new List<AcctSeed__Cash_Receipt__c>();
            List<AcctSeed__Cash_Receipt__c> serviceChargecashReceiptList = new List<AcctSeed__Cash_Receipt__c>();
            List<AcctSeed__Billing_Cash_Receipt__c> billingCashReceiptList = new List<AcctSeed__Billing_Cash_Receipt__c>();
            List<AcctSeed__Billing__c> billingList = new List<AcctSeed__Billing__c>();
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            //Map<Id,Messaging.SingleEmailMessage> emailMessageMap = new Map<Id,Messaging.SingleEmailMessage>();
            Id serviceGLAccount = [select id from AcctSeed__GL_Account__c where name=:Label.Service_Charge_GL_Account limit 1].id;
            List<OrgWideEmailAddress> orgWideEmailAddress = [select Id,DisplayName,Address from OrgWideEmailAddress Where Address = 'accounting@isbamutual.com'];
            String bankAccId = [SELECT Id FROM AcctSeed__GL_Account__c WHERE Name = '1101-Main Cash (CIBC)' LIMIT 1].Id;
            
            /*Set<Id> accountIds = new Set<Id>();
            Map<Id,AcctSeed__Payment_Method__c> paymentMethodMap = new Map<Id,AcctSeed__Payment_Method__c>();
            for(AcctSeed__Billing__c billing : batch){
                accountIds.add(billing.AcctSeed__Customer__c);
            }
            for(AcctSeed__Payment_Method__c payMap : [select id,AcctSeed__Customer__c, Name,Credit_Card_Number__c,AcctSeed__Routing_Number__c,AcctSeed__Card_Holder_Name__c,Account_Number__c,Name_on_Card__c,AcctSeed__Type__c,AcctSeed__External_Id__c,AcctSeed__Last_Four_Digits__c,AcctSeed__Expiration_Month__c,AcctSeed__Expiration_Year__c, Card_Verification_Number__c, AcctSeed__Bank_Account_Type__c,AcctSeed__Payment_Method_Type__c from AcctSeed__Payment_Method__c where AcctSeed__Customer__c in: accountIds order by AcctSeed__Default__c,CreatedDate]){
                paymentMethodMap.put(payMap.AcctSeed__Customer__c,payMap);
            }*/
            for(AcctSeed__Billing__c billing : batch){
                String transactionAction = '';
                try{
                    PaymentGateway_Ctrl.PaymentGateway_Ctrl_Wrapper wrapperObj = new PaymentGateway_Ctrl.PaymentGateway_Ctrl_Wrapper();
                    wrapperObj.firstName=billing.Billing_First_Name__c;
                    wrapperObj.lastName=billing.Billing_Last_Name__c;
                    if(billing.AcctSeed__Customer__r.Name=='Dummy Billing Account'){
                        wrapperObj.invoiceId=billing.Legacy_Invoice_Id__c;
                        wrapperObj.firmId=billing.Legacy_Firm_Id__c;
                        wrapperObj.firmName=billing.Firm_Name__c;
                    }else{
                        wrapperObj.invoiceId=billing.Name;
                        wrapperObj.firmId=billing.AcctSeed__Customer__r.AccountNumber;
                        wrapperObj.firmName=billing.AcctSeed__Customer__r.Name;
                    }
                    wrapperObj.nextPaymentDate = String.valueOf(billing.Next_Payment_Date__c);
                    /*if(paymentMethodMap.containsKey(billing.AcctSeed__Customer__c)){
                        if(paymentMethodMap.get(billing.AcctSeed__Customer__c).AcctSeed__Payment_Method_Type__c == 'Bank Account'){
                            wrapperObj.paymentTypeVar='check';
                            wrapperObj.accountType=paymentMethodMap.get(billing.AcctSeed__Customer__c).AcctSeed__Bank_Account_Type__c ;
                            wrapperObj.routingNumber=String.valueOf(paymentMethodMap.get(billing.AcctSeed__Customer__c).AcctSeed__Routing_Number__c );
                            wrapperObj.accountNumber=paymentMethodMap.get(billing.AcctSeed__Customer__c).Account_Number__c;
                            wrapperObj.accountHolderName=paymentMethodMap.get(billing.AcctSeed__Customer__c).AcctSeed__Card_Holder_Name__c ;
                        }else if(paymentMethodMap.get(billing.AcctSeed__Customer__c).AcctSeed__Payment_Method_Type__c == 'Credit Card'){
                            wrapperObj.paymentTypeVar='creditCard';
                            wrapperObj.cardTypeVar=paymentMethodMap.get(billing.AcctSeed__Customer__c).AcctSeed__Type__c ;
                            wrapperObj.nameOnCard=paymentMethodMap.get(billing.AcctSeed__Customer__c).Name_on_Card__c ;
                            wrapperObj.cardNumber=String.valueOf(paymentMethodMap.get(billing.AcctSeed__Customer__c).Credit_Card_Number__c );
                            wrapperObj.expireMonth=String.valueOf(Integer.valueOf(paymentMethodMap.get(billing.AcctSeed__Customer__c).AcctSeed__Expiration_Month__c ));
                            wrapperObj.expireYear=String.valueOf(Integer.valueOf(paymentMethodMap.get(billing.AcctSeed__Customer__c).AcctSeed__Expiration_Year__c ));
                            wrapperObj.verificationNumber=String.valueOf(paymentMethodMap.get(billing.AcctSeed__Customer__c).Card_Verification_Number__c );
                        }
                    }*/
                    if(billing.Mode_Of_Payment__c=='eCheck/ACH'){
                        wrapperObj.paymentTypeVar='check';
                        wrapperObj.accountType=billing.Billing_Account_Type__c;
                        wrapperObj.routingNumber=String.valueOf(billing.Billing_Routing_Number__c);
                        wrapperObj.accountNumber=billing.Billing_Account_Number__c;
                        wrapperObj.accountHolderName=billing.Billing_Account_Holder_Name__c;
                    }else if(billing.Mode_Of_Payment__c=='Credit Card'){
                        wrapperObj.paymentTypeVar='creditCard';
                        wrapperObj.cardTypeVar=billing.Billing_Card_Type__c;
                        wrapperObj.nameOnCard=billing.Billing_Name_On_Card__c;
                        wrapperObj.cardNumber=String.valueOf(billing.Billing_Card_Number__c);
                        wrapperObj.expireMonth=String.valueOf(Integer.valueOf(billing.Billing_Card_Expire_Month__c));
                        wrapperObj.expireYear=String.valueOf(Integer.valueOf(billing.Billing_Card_Expire_Year__c));
                        wrapperObj.verificationNumber=String.valueOf(billing.Billing_Card_Verification_Number__c);
                    }
                    Decimal amountDueToday;
                    if(billing.AcctSeed__Balance__c > billing.Next_Payment_Base_Amount__c){
                        amountDueToday = billing.Next_Payment_Base_Amount__c;
                    }else{
                        amountDueToday = billing.AcctSeed__Balance__c;
                    }
                    ForteUtil util = ForteUtil.createTransaction(amountDueToday,'',wrapperObj);
                    ForteUtil util1;
                    if(util.response.response_code == 'A01'){
                        if(billing.Next_Payment_Service_Fee__c>0){
                            util1 = ForteUtil.createTransaction(billing.Next_Payment_Service_Fee__c,'',wrapperObj);
                        }
                        transactionAction = 'sale';
                    }else if(util.response.response_code == 'U80' && util.response.preauth_desc == 'P15:HIGH RISK'){
                        util = ForteUtil.createForceTransaction(amountDueToday,'',wrapperObj);
                        transactionAction = 'force';
                    }
                    if((util.response.response_code == 'A01' && util1 ==null) || (util.response.response_code == 'A01' && util1 !=null && util1.response.response_code == 'A01')){
                        try{
                            Decimal totalAmountDue = amountDueToday;//billing.Next_Payment_Base_Amount__c;// + billing.Next_Payment_Service_Fee__c;
                            //if(paymentMethodMap.get(billing.AcctSeed__Customer__c).AcctSeed__Payment_Method_Type__c == 'Credit Card'){
                            //if(billing.Mode_Of_Payment__c=='Credit Card'){
                                AcctSeed__Cash_Receipt__c cashReceipt = new AcctSeed__Cash_Receipt__c();
                                cashReceipt.AcctSeed__Account__c=billing.AcctSeed__Customer__c;
                                cashReceipt.AcctSeed__Payment_Reference__c=util.transaction_id;
                                cashReceipt.AcctSeed__Amount__c = totalAmountDue; // billing.Next_Payment_Base_Amount__c;
                                cashReceipt.AcctSeed__Receipt_Date__c=System.today();
                                cashReceipt.AcctSeed__Bank_Account__c = bankAccId;
                            
                                if(billing.Mode_Of_Payment__c == 'eCheck/ACH'){
                                    cashReceipt.Processing_Type__c='ACH';
                                }else if(billing.Mode_Of_Payment__c == 'Credit Card'){
                                    cashReceipt.Processing_Type__c='Credit Card';
                                }
                                
                                //cashReceipt.Processing_Type__c='Credit Card';
                                
                                cashReceipt.AcctSeed__GL_Account_Variable_1__c = billing.AcctSeed__Project_Billing_Lines__r[0].AcctSeed__GL_Account_Variable_1__c;
                                
                                AcctSeed__Billing_Cash_Receipt__c billingCashReceipt = new AcctSeed__Billing_Cash_Receipt__c();
                                billingCashReceipt.AcctSeed__Applied_Amount__c = totalAmountDue; //billing.Next_Payment_Base_Amount__c;
                                billingCashReceipt.AcctSeed__Billing__c = billing.id;
                                if(billing.AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c > System.today() ){
                                    billingCashReceipt.AcctSeed__Accounting_Period__c = billing.AcctSeed__Accounting_Period__c;
                                    billingCashReceipt.AcctSeed__Applied_Date__c = billing.AcctSeed__Date__c;
                                }else{
                                    billingCashReceipt.AcctSeed__Accounting_Period__c = accountPeriodId;  
                                    billingCashReceipt.AcctSeed__Applied_Date__c = System.today();
                                }
                            	
                                
                                /*if(billing.Next_Payment_Service_Fee__c>0){
                                    AcctSeed__Cash_Receipt__c serviceChargecashReceipt = new AcctSeed__Cash_Receipt__c();
                                    serviceChargecashReceipt.AcctSeed__Account__c=billing.AcctSeed__Customer__c;
                                    serviceChargecashReceipt.AcctSeed__Payment_Reference__c=util1.transaction_id;
                                    serviceChargecashReceipt.AcctSeed__Amount__c=billing.Next_Payment_Service_Fee__c;
                                    serviceChargecashReceipt.AcctSeed__Receipt_Date__c=System.today();
                                    serviceChargecashReceipt.AcctSeed__Credit_GL_Account__c=serviceGLAccount;
                                    if(paymentMethodMap.get(billing.AcctSeed__Customer__c).AcctSeed__Payment_Method_Type__c == 'Bank Account'){
                                        cashReceipt.Processing_Type__c='ACH';
                                    }else if(paymentMethodMap.get(billing.AcctSeed__Customer__c).AcctSeed__Payment_Method_Type__c == 'Credit Card'){
                                        cashReceipt.Processing_Type__c='Credit Card';
                                    }
                                    
                                    serviceChargecashReceiptList.add(serviceChargecashReceipt); 
                                }*/
                                cashReceiptList.add(cashReceipt); 
                                billingCashReceiptList.add(billingCashReceipt);
                            //}
                            
                            
                            if(billing.AcctSeed__Balance__c - billing.Next_Payment_Base_Amount__c >1 ){
                                if(billing.Payment_Frequency__c=='Monthly'){
                                    billingList.add(new AcctSeed__Billing__c(id=billing.Id,Next_Payment_Base_Amount__c=billing.Next_Payment_Base_Amount__c,Next_Payment_Service_Fee__c=billing.Next_Payment_Service_Fee__c,Next_Payment_Date__c=billing.Next_Payment_Date__c.addMonths(1)));
                                }else if(billing.Payment_Frequency__c=='Quarterly'){
                                    billingList.add(new AcctSeed__Billing__c(id=billing.Id,Next_Payment_Base_Amount__c=billing.Next_Payment_Base_Amount__c,Next_Payment_Service_Fee__c=billing.Next_Payment_Service_Fee__c,Next_Payment_Date__c=billing.Next_Payment_Date__c.addMonths(3)));
                                }
                            }else{
                                billingList.add(new AcctSeed__Billing__c(id=billing.Id,Next_Payment_Base_Amount__c=0,Next_Payment_Service_Fee__c=0,Next_Payment_Date__c=null));
                            }
                            
                            
                            
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setSaveAsActivity(true);
                            mail.setWhatId(billing.id);
                            mail.setSenderDisplayName('ISBA Mutual Insurance');
                            mail.setToAddresses(new String[]{billing.Billing_Confirmation_Email__c});
                            mail.setSubject('ISBA Mutual Insurance - Payment Received');
                            if(orgWideEmailAddress!= null && orgWideEmailAddress.size() > 0){
                                mail.setOrgWideEmailAddressId(orgWideEmailAddress[0].Id);
                            }
                            String body = 'Dear ' + billing.Billing_First_Name__c+' '+billing.Billing_Last_Name__c + ', <br/>';
                            String bill='';
                            if(billing.Legacy_Invoice_Id__c!=null){
                                bill = billing.Legacy_Invoice_Id__c;
                            }else{
                                bill = billing.Name;
                            }
                            body += 'Your payment of $'+totalAmountDue.setScale(2) +' for bill #'+ bill + ' have been successfully processed.<br/>';
                            body += 'For your reference, the transaction number for this is: '+ util.transaction_id + '<br/>';
                            if(billing.Payment_Frequency__c=='Monthly' || billing.Payment_Frequency__c=='Quarterly'){
                                Decimal remainingBalance = billing.AcctSeed__Balance__c - billing.Next_Payment_Base_Amount__c;
                                Integer intMonth = 1;
                                Integer intQuarter = 3;
                                if(remainingBalance > 0){
                                    body += '<br/>Your future payments will be executed as follows;<br/><br/><br/>Payment Schedule:<br/><br/>';
                                }
                                while(remainingBalance > 1){
                                    Decimal nextAmount = billing.Next_Payment_Base_Amount__c.setScale(2);
                                    if(remainingBalance >= nextAmount){
                                        body += '$'+nextAmount;
                                    }else{
                                        body += '$'+remainingBalance.setScale(2);
                                    }
                                    if(billing.Payment_Frequency__c=='Quarterly'){
                                        body += '     ('+ System.today().addMonths(intQuarter).format() +')<br/>';
                                        intQuarter += 3;
                                    }else if(billing.Payment_Frequency__c=='Monthly'){
                                        body += '     ('+ System.today().addMonths(intMonth).format() +')<br/>';
                                        intMonth += 1;
                                    }
                                    remainingBalance = remainingBalance - nextAmount;
                                }
                                body += '<br/>' ;
                            }
                            body += 'Thank you,<br/>ISBA Mutual Accounting Department<br/>312-379-2005';
                            mail.setHtmlBody(body);
                            allmsg.add(mail);
                            //emailMessageMap.put(billing.Id,mail);
                        }catch(Exception e){ Integration_Log__c log = new Integration_Log__c(); log.Billing__c =billing.id; log.Status__c='Processed With Errors'; log.Transaction_Amount__c=billing.Next_Payment_Base_Amount__c; log.Transaction_Id__c=util.transaction_id; log.Transaction_Action__c = transactionAction; log.Description__c='Error : '+e.getMessage() + '\n' + e.getStackTraceString() + '\n'; logsList.add(log); }
                    }else{
                        Integration_Log__c log = new Integration_Log__c();
                        log.Billing__c =billing.id;
                        log.Status__c='Processed With Errors';
                        log.Transaction_Amount__c=billing.Next_Payment_Base_Amount__c;// + billing.Next_Payment_Service_Fee__c;
                        log.Transaction_Action__c = transactionAction;
                        if(util.response.response_code != 'A01'){
                            log.Description__c='(Error Code :'+ util.response.response_code + ' - ' + util.response.response_desc + ').';
                            
                        }else if(util1.response.response_code != 'A01'){
                            log.Description__c='(Error Code :'+ util1.response.response_code + ' - ' + util1.response.response_desc + ').';
                        }
                        logsList.add(log);
                        
                        billingList.add(new AcctSeed__Billing__c(id=billing.Id,ISBAM_Error__c='Rejected Payment',ISBAM_Error_Description__c = (billing.ISBAM_Error_Description__c != null ? billing.ISBAM_Error_Description__c + '\n[' + (System.now().format('MM/dd/yyyy')) + '] Forte Error ' + log.Description__c :  '[' + (System.now().format('MM/dd/yyyy')) + '] Forte Error ' + log.Description__c)));
                    }
                }catch(Exception e){ Integration_Log__c log = new Integration_Log__c(); log.Billing__c =billing.id; log.Status__c='Processed With Errors'; log.Transaction_Action__c = transactionAction; log.Transaction_Amount__c=billing.Next_Payment_Base_Amount__c; log.Description__c='Error : '+e.getMessage() + '\n' + e.getStackTraceString() + '\n'; logsList.add(log);}
            }
            
            List<Database.SaveResult> resultList =  Database.insert(cashReceiptList,false);
            List<Database.SaveResult> resultserviceChargecashReceiptList =  Database.insert(serviceChargecashReceiptList,false);
            for(Integer i=0;i<resultserviceChargecashReceiptList.size();i++){
                if(!resultserviceChargecashReceiptList[i].isSuccess()){
                    String errorString = '';
                    for(Database.Error err : resultserviceChargecashReceiptList[i].getErrors()) {
                        errorString = errorString +'Insert Service Cash Receipt-'+ err.getMessage()+'\n';
                    }
                    Integration_Log__c log = new Integration_Log__c();
                    log.Status__c='Processed With Errors';
                    log.Transaction_Amount__c=serviceChargecashReceiptList[i].AcctSeed__Amount__c;
                    log.Transaction_Id__c=serviceChargecashReceiptList[i].AcctSeed__Payment_Reference__c;
                    log.Description__c='Error : '+errorString;
                    logsList.add(log);
                }
            }
            for(Integer i=0;i<cashReceiptList.size();i++){
                billingCashReceiptList[i].AcctSeed__Cash_Receipt__c=cashReceiptList[i].id;
            }
            List<Database.SaveResult> resultListBillingCashReceipt = Database.insert(billingcashReceiptList,false);
            List<Database.SaveResult> resultBillingList = Database.update(billingList,false);
            for(Integer i=0;i<resultList.size();i++){
                if(!resultList[i].isSuccess() || !resultListBillingCashReceipt[i].isSuccess() || !resultBillingList[i].isSuccess()){
                    String errorString = '';
                    for(Database.Error err : resultList[i].getErrors()) {
                        errorString = errorString +'Insert Cash Receipt-'+ err.getMessage()+'\n';
                    }
                    for(Database.Error err : resultListBillingCashReceipt[i].getErrors()) {
                        errorString = errorString +'Insert Billing Cash Receipt-'+ err.getMessage()+'\n';
                    }
                    for(Database.Error err : resultBillingList[i].getErrors()) {
                        errorString = errorString +'Update Billing'+ err.getMessage()+'\n';
                    }
                    Integration_Log__c log = new Integration_Log__c();
                    log.Billing__c =billingcashReceiptList[i].AcctSeed__Billing__c;
                    log.Status__c='Processed With Errors';
                    log.Transaction_Amount__c=cashReceiptList[i].AcctSeed__Amount__c;
                    log.Transaction_Id__c=cashReceiptList[i].AcctSeed__Payment_Reference__c;
                    log.Description__c='Error : '+errorString;
                    logsList.add(log);
                }else{Integration_Log__c log = new Integration_Log__c(); log.Billing__c =billingcashReceiptList[i].AcctSeed__Billing__c; log.Status__c='Processed Successfully'; log.Transaction_Amount__c=cashReceiptList[i].AcctSeed__Amount__c; log.Transaction_Id__c=cashReceiptList[i].AcctSeed__Payment_Reference__c; log.Description__c='Payment Processed Successfully'; logsList.add(log); }
            }
            String csvString = 'Invoice,Amount,Transaction Id,Status,Description\n';
            for(Integration_Log__c logs:logsList){
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
            List<OrgWideEmailAddress> oweaList = [select Id,DisplayName,Address from OrgWideEmailAddress Where DisplayName =: Label.OrganizationWideEmail];
            if (!oweaList.isEmpty()) {
                mail.setOrgWideEmailAddressId(oweaList.get(0).Id);
            }
            mail.setToAddresses(new String[]{Label.ISBA_Accounting_Automation_Email_Address });
            mail.setSubject('Scheduled Payments Processing Status');
            String body = 'Dear, <br/><br/>';
            body += 'Please find attached file for the scheduled payment processing status.';
            mail.setHtmlBody(body);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
            allmsg.add(mail);
            Messaging.sendEmail(allmsg,false);
            Database.insert(logsList,false);
        }catch(Exception e){Integration_Log__c log = new Integration_Log__c(); log.Status__c='Processed With Errors'; log.Description__c='Error :'+e.getMessage() + '\n' + e.getStackTraceString(); insert log; }
    }
    global void finish(Database.BatchableContext BC) { 
    }
    global void execute(SchedulableContext sc){
        Database.executeBatch(new Batch_PaymentGateway(),1);
    }
}