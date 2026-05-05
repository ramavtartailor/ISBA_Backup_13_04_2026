public with sharing class Billing_Trigger_Handler {
    public static void onAfterUpdate(List<AcctSeed__Billing__c> billList, Map<Id,AcctSeed__Billing__c> oldMap){
        
        Set<String> billIds = new Set<String>();
        
        for(AcctSeed__Billing__c bill : billList){
            system.debug('bill.Policy__c => '+bill.Policy__c);
            system.debug('bill.AcctSeed__Status__c => '+bill.AcctSeed__Status__c);
            system.debug('oldMap.get(bill.Id).AcctSeed__Status__c => '+oldMap.get(bill.Id).AcctSeed__Status__c);
            if(String.isNotBlank(bill.Policy__c) &&  bill.AcctSeed__Status__c == 'Posted' && bill.AcctSeed__Status__c != oldMap.get(bill.Id).AcctSeed__Status__c){
                billIds.add(bill.Id);
            }
        }
        system.debug('billIds => '+billIds);
        if(!billIds.isEmpty()){
            CreatePaymentScheduleAndCashReceipts(billIds);
        }
    }
    
    public static void CreatePaymentScheduleAndCashReceipts(Set<String> billIds) {
        Map<Id,AcctSeed__Billing__c> billingsMap= new Map<Id, AcctSeed__Billing__c>([SELECT Id, AcctSeed__Due_Date2__c, AcctSeed__Accounting_Period__c,Policy_Endorsement__c, Policy_Endorsement__r.Approve_Endorsement_JSON__c,Policy_Endorsement__r.Endorsement_Number__c, 
                                                                                     AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c, AcctSeed__Customer__c, Policy__c,AcctSeed__Billing_Contact__c, AcctSeed__Billing_Contact__r.Email,Policy__r.Firm_Contact__c, Policy__r.Firm_Contact__r.Email,  
                                                                                     Policy__r.Is_First_Billing_Created__c, Policy__r.Bind_Policy_JSON__c,
                                                                                     
                                                                                     (select id,AcctSeed__GL_Account_Variable_1__c from AcctSeed__Project_Billing_Lines__r )
                                                                                     From AcctSeed__Billing__c WHERE Id In: billIds]);
        
        List<Wrapper> transWrapperList = new List<Wrapper>();
        List<Payment_Schedule__c> paymentSchedulesToCreate = new List<Payment_Schedule__c>();
        
        List<AcctSeed__Payment_Processor__c> paymentProcesssor = [SELECT Id FROM AcctSeed__Payment_Processor__c WHERE Name='Fiserv'];
        
        
        Map<String,Payment_Schedule__c> billWithPaymentSchedule = new Map<String,Payment_Schedule__c>();
        
        Map<Id,Policy__c> updatedPolicies = new Map<Id,Policy__c>();
        
        List<AcctSeed__Billing__c> UpdatedBills = new List<AcctSeed__Billing__c>();
        Set<String> endorsement_billIds = new Set<String>();
        for(AcctSeed__Billing__c bill : billingsMap.values()){
            if((!bill.Policy__r.Is_First_Billing_Created__c && String.isNotBlank(bill.Policy__r.Bind_Policy_JSON__c)) || (String.isNotBlank(bill.Policy_Endorsement__c) && String.isNotBlank(bill.Policy_Endorsement__r.Approve_Endorsement_JSON__c))){
                String json = '';
                Boolean isPolicy = true;
                if(String.isNotBlank(bill.Policy_Endorsement__c) && String.isNotBlank(bill.Policy_Endorsement__r.Approve_Endorsement_JSON__c)){
                    json = bill.Policy_Endorsement__r.Approve_Endorsement_JSON__c;
                    isPolicy =false;
                }
                else{
                    json = bill.Policy__r.Bind_Policy_JSON__c;
                }
                PaymentGatewayClass.policyBindWrapper bindWrapObj = (PaymentGatewayClass.policyBindWrapper) System.JSON.deserializeStrict(json, PaymentGatewayClass.policyBindWrapper.Class);
                
                if(bindWrapObj.defaultPaymentMethodId != 'Physical_Check'){
                    bill.Payment_Method__c = bindWrapObj.defaultPaymentMethodId;
                }
                bill.Customer_Payment_IP_Address__c = bindWrapObj.ipAddress;
                bill.Payment_Frequency__c = bindWrapObj.paymentScheduleVar;                
                bill.Service_Fee__c = Decimal.valueOf(label.Service_Fee_Rate);
                bill.AcctSeed__Payment_Processor__c = paymentProcesssor[0].Id;
                bill.Billing_Confirmation_Email__c = bindWrapObj.billingConfirmationEmail;	
                bill.ISBAM_user_agent__c = bindWrapObj.ISBAM_user_agent;
                bill.Device_Type__c = bindWrapObj.deviceType;
                UpdatedBills.add(bill);
                
                Decimal amountReceived = bindWrapObj.baseAmountToPay;
                if(bindWrapObj.firstInstallment > 0){
                    
                    Payment_Schedule__c pSch1 = new Payment_Schedule__c();
                    pSch1.Due_Date__c = bindWrapObj.firstInstallmentDate;
                    pSch1.Billing__c = bill.id;                    
                    pSch1.Amount__c =  bindWrapObj.firstInstallment;
                    pSch1.Status__c = 'Unpaid'; 
                    
                    if(bindWrapObj.paymentTypeVar == 'creditCard'){
                        pSch1.Service_Fee_Rate__c = Decimal.valueOf(label.Service_Fee_Rate);
                        pSch1.Payment_Schedule_Type__c = 'Credit Card';
                    }
                    else if(bindWrapObj.paymentTypeVar == 'Physical_Check'){
                        pSch1.Payment_Schedule_Type__c = 'Physical Check';
                    }
                    else{
                        pSch1.Payment_Schedule_Type__c = 'eCheck';
                    }
                    
                    pSch1.Frequency__c = bindWrapObj.paymentScheduleVar;
                    
                    if(bindWrapObj.defaultPaymentMethodId != 'Physical_Check'){
                        pSch1.Fiserv_Payment_Method__c = bindWrapObj.defaultPaymentMethodId;
                    }
                    
                    if(bindWrapObj.isPaymentReceived && bindWrapObj.defaultPaymentMethodId != 'Physical_Check'){
                        
                        String PaymethodToken = bindWrapObj.defaultPaymentMethodId;
                        String paymentTypeVar = bindWrapObj.paymentTypeVar;                        
                        
                        Wrapper wrp = new Wrapper();
                        wrp.ipAddress = bindWrapObj.ipAddress;
                        wrp.paymentTypeVar = paymentTypeVar;
                        wrp.pmtMethodToken = PaymethodToken;
                        wrp.billId = bill.Id;
                        wrp.amount = pSch1.Amount__c;
                        wrp.isEndorsement = !isPolicy;
                        transWrapperList.add(wrp);                            
                    }
                    
                    paymentSchedulesToCreate.add(pSch1);
                    
                }
                else if(!isPolicy && !bindWrapObj.isPaymentReceived){
                    endorsement_billIds.add(bill.Id);
                } 
                if(bindWrapObj.paymentSchedulesWrap != null && !(bindWrapObj.paymentSchedulesWrap).isEmpty()){
                    for(PaymentGatewayClass.paymentSchedulesWrapper wrap: bindWrapObj.paymentSchedulesWrap){
                        Payment_Schedule__c pSch = new Payment_Schedule__c();
                        pSch.Due_Date__c = Date.parse(wrap.dateStr);
                        pSch.Billing__c = bill.id;
                        pSch.Amount__c =  wrap.amount; 
                        
                        if(bindWrapObj.defaultPaymentMethodId != 'Physical_Check'){
                            pSch.Fiserv_Payment_Method__c = bindWrapObj.defaultPaymentMethodId;
                        }
                        
                        if(bindWrapObj.paymentTypeVar == 'creditCard'){
                            pSch.Service_Fee_Rate__c = Decimal.valueOf(label.Service_Fee_Rate);
                            pSch.Payment_Schedule_Type__c = 'Credit Card';
                        }
                        else if(bindWrapObj.paymentTypeVar == 'Physical_Check'){
                            pSch.Payment_Schedule_Type__c = 'Physical Check';
                        }
                        else{
                            pSch.Payment_Schedule_Type__c = 'eCheck';
                        }
                        
                        pSch.Status__c = 'Unpaid';                        
                        pSch.Frequency__c = bindWrapObj.paymentScheduleVar;
                        paymentSchedulesToCreate.add(pSch);
                    }
                }
                
                if(isPolicy){
                    Policy__c policy = new Policy__c();
                    policy.Id = bill.Policy__c; 
                    policy.Is_First_Billing_Created__c = true;
                    
                    updatedPolicies.put(policy.Id, policy);
                }
                
            }
            else if(String.isNotBlank(bill.Policy_Endorsement__c) && (bill.Policy_Endorsement__r.Endorsement_Number__c == 'IL 152' || bill.Policy_Endorsement__r.Endorsement_Number__c == 'IL 107')){
                endorsement_billIds.add(bill.Id);
            }
        }
        
        if(!UpdatedBills.isEmpty()){
            Update UpdatedBills;
        }
        
        if(!paymentSchedulesToCreate.isEmpty()){
            Insert paymentSchedulesToCreate;
        }
        
        if(!updatedPolicies.KeySet().isEmpty()){
            Update updatedPolicies.values(); 
        }
        if(!transWrapperList.isEmpty()){
            for(Wrapper wrp : transWrapperList){
                CreateTransaction(wrp.amount, wrp.billId, wrp.pmtMethodToken, wrp.paymentTypeVar, wrp.ipAddress, wrp.isEndorsement);
            }
        }
        system.debug('endorsement_billIds => '+endorsement_billIds);
        if(!endorsement_billIds.isEmpty()){
            mailEndorsementDocuments(endorsement_billIds);
        }
            
    }

    @future(callout= true)
    public static void mailEndorsementDocuments(Set<String> billIds){
        system.debug('<==mailEndorsementDocuments called==>');
        List<OrgWideEmailAddress> oweaList = [select Id,DisplayName from OrgWideEmailAddress Where DisplayName =: Label.OrganizationWideEmail];
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<AcctSeed__Billing__c> billings = [SELECT Id, Name, Service_Fee__c,  Policy__c, Policy__r.Name, AcctSeed__Billing_Contact__c, AcctSeed__Billing_Contact__r.Email, Policy__r.Firm_Contact__c, Policy__r.Firm_Contact__r.Email, Policy_Endorsement__c, Policy_Endorsement__r.Endorsement_Number__c, Policy_Endorsement__r.Endorsement_Version__c , ISBAM_Error_Description__c, Billing_Confirmation_Email__c, AcctSeed__Customer__c,AcctSeed__Customer__r.Name,AcctSeed__Customer__r.AccountNumber, AcctSeed__Accounting_Period__c, AcctSeed__Due_Date2__c, AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c, (select id,AcctSeed__GL_Account_Variable_1__c from AcctSeed__Project_Billing_Lines__r )
                                     From AcctSeed__Billing__c WHERE Id IN: billIds];
        
        for(AcctSeed__Billing__c bill : billings){
            if(!oweaList.isEmpty()){
                mailList.add(generateEndorsementEmail(bill, oweaList[0].Id));
            }
        }
        if(!mailList.isEmpty()){
            Messaging.sendEmail(mailList,false);
        }
    }
    
    @future(callout= true)
    public static void CreateTransaction(Decimal amount, String billId, String pmtMethodToken, String paymentTypeVar, String ipAddress, Boolean isEndorsement){       
        DateTime paymentDate = system.now(); 
        
        AcctSeed__Payment_Processor__c fiservProcessor = [SELECT Id, Name FROM AcctSeed__Payment_Processor__c WHERE Name='Fiserv' LIMIT 1];        
        
        Payment_Method__c pm = [SELECT Id, Name_on_Card__c, Card_Holder_Name__c, Type__c, Account_Type__c , Last_4_Account_Number__c, Payment_Method_Token__c FROM Payment_Method__c WHERE Id =:pmtMethodToken LIMIT 1];
        
        AcctSeed__Billing__c bill = [SELECT Id, Name, Service_Fee__c,  Policy__c, Policy__r.Name, AcctSeed__Billing_Contact__c, AcctSeed__Billing_Contact__r.Email, Policy__r.Firm_Contact__c, Policy__r.Firm_Contact__r.Email, Policy_Endorsement__c, Policy_Endorsement__r.Endorsement_Number__c, Policy_Endorsement__r.Endorsement_Version__c , ISBAM_Error_Description__c, Billing_Confirmation_Email__c, AcctSeed__Customer__c,AcctSeed__Customer__r.Name,AcctSeed__Customer__r.AccountNumber, AcctSeed__Accounting_Period__c, AcctSeed__Due_Date2__c, AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c, (select id,AcctSeed__GL_Account_Variable_1__c from AcctSeed__Project_Billing_Lines__r )
                                     From AcctSeed__Billing__c WHERE Id =: billId LIMIT 1];
        system.debug('bill->' + bill);
        
        PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj = new PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper();
        warpperObj.billing = bill;
        warpperObj.payMethodToken = pm.Payment_Method_Token__c;
        warpperObj.paymentTypeVar = paymentTypeVar;
        warpperObj.accountType = pm.Account_Type__c;
        warpperObj.ccFeeRate = Decimal.valueOf(label.Service_Fee_Rate);
        warpperObj.accRecord = (Account) bill.getSobject('AcctSeed__Customer__r');
        paymentDate = system.now(); 
        
        Map<String,Object> transactionResponseMp = new Map<String,Object>();
        if(warpperObj.paymentTypeVar == 'creditCard'){
            transactionResponseMp = Fiserv_Utils.createCreditCardCharge(amount, warpperObj);
        }
        else{
            transactionResponseMp = Fiserv_Utils.createACHCharge(amount, warpperObj);
        }
        
		system.debug(transactionResponseMp.keySet());
        
        system.debug(transactionResponseMp.values());
        //transactionResponseMp = CardknoxUtil.ProcessTransaction(amount, warpperObj, 'Sale');
        
        
        
        List<Payment_Schedule__c> PaymentSchedule = [SELECT Id, Due_Date__c, Amount__c, Service_Fee_Rate__c from Payment_Schedule__c WHERE Status__c = 'Unpaid' AND Billing__c =: billId ORDER By CreatedDate ASC];
        if((string)transactionResponseMp.get('respstat')=='A' && ((string)transactionResponseMp.get('resptext')=='Approval' ||(string)transactionResponseMp.get('resptext') == 'Approved')){
             
            String transactionId = (String)transactionResponseMp.get('retref');
            
            Id accountPeriodId = [SELECT id,name,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM  AcctSeed__Accounting_Period__c  WHERE AcctSeed__Status__c = 'Open' and AcctSeed__Start_Date__c<=TODAY and AcctSeed__End_Date__c>=TODAY limit 1][0].id;
            
            Decimal ServiceFeeAmount = 0.00;
            if(warpperObj.paymentTypeVar == 'creditCard'){
                ServiceFeeAmount = ((amount/100) * warpperObj.ccFeeRate).setScale(2);
            }
            //Creating Cash Receipt             
            AcctSeed__Cash_Receipt__c cashReceipt = new AcctSeed__Cash_Receipt__c();
            cashReceipt.AcctSeed__Account__c = bill.AcctSeed__Customer__c;
            cashReceipt.AcctSeed__Payment_Reference__c = transactionId;
            cashReceipt.AcctSeed__Amount__c = amount+ServiceFeeAmount; 
            cashReceipt.AcctSeed__Receipt_Date__c=System.today();
            cashReceipt.AcctSeed__Payment_Processor__c = fiservProcessor.Id;
            
            if(paymentTypeVar=='creditCard'){
                cashReceipt.Processing_Type__c='Credit Card';
            }else{
                cashReceipt.Processing_Type__c='ACH';
            }
            cashReceipt.AcctSeed__GL_Account_Variable_1__c = bill.AcctSeed__Project_Billing_Lines__r[0].AcctSeed__GL_Account_Variable_1__c;
            
            Insert cashReceipt;
                        
            //Updating Payment Schedule
            PaymentSchedule[0].Status__c = 'Paid';
            PaymentSchedule[0].Payment_Reference__c = transactionId;
            PaymentSchedule[0].Paid_Amount__c = amount;
            PaymentSchedule[0].Cash_Receipt__c = cashReceipt.Id;
            Update PaymentSchedule[0];
            
            List<AcctSeed__GL_Account__c> glList = [SELECT Id, Name FROM AcctSeed__GL_Account__c WHERE Name =: label.Adjustment_GL_Account LIMIT 1]; 
            
            //Createing Billing Cash Receipt
            AcctSeed__Billing_Cash_Receipt__c billingCashReceipt = new AcctSeed__Billing_Cash_Receipt__c();
            billingCashReceipt.AcctSeed__Applied_Amount__c = amount+ServiceFeeAmount;
            billingCashReceipt.AcctSeed__Billing__c = billId;
            billingCashReceipt.AcctSeed__Cash_Receipt__c = cashReceipt.Id;
            billingCashReceipt.AcctSeed__Accounting_Period__c = accountPeriodId;
            billingCashReceipt.AcctSeed__Applied_Date__c = System.today();
            billingCashReceipt.AcctSeed__Adjustment_GL_Account__c = glList[0].Id;
            billingCashReceipt.AcctSeed__Adjustment_Amount__c = -ServiceFeeAmount;
            if(bill.AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c > System.today() ){
                billingCashReceipt.AcctSeed__Accounting_Period__c = bill.AcctSeed__Accounting_Period__c;
                billingCashReceipt.AcctSeed__Applied_Date__c = bill.AcctSeed__Due_Date2__c;
            }else{
                billingCashReceipt.AcctSeed__Accounting_Period__c = accountPeriodId;   
            }
            system.debug(billingCashReceipt);
            Insert billingCashReceipt;
            
            /*Transaction_Credit_And_Debits__c glDetails =  Transaction_Credit_And_Debits__c.getInstance('Cardknox Service Fee');
            
            String creditGL;
            String debitGL;
            List<AcctSeed__GL_Account__c> glList = [SELECT Id, Name FROM AcctSeed__GL_Account__c WHERE Name =:glDetails.Credit_GL__c OR Name =:glDetails.Debit_GL__c]; 
            for(AcctSeed__GL_Account__c gl: glList){
            if(gl.Name == glDetails.Credit_GL__c){
            creditGL = gl.Id;
            }
            else if(gl.Name == glDetails.Debit_GL__c){
            debitGL = gl.Id; 
            }
            }
            //creating Journal Entry
            AcctSeed__Journal_Entry__c je = new AcctSeed__Journal_Entry__c();
            je.AcctSeed__Journal_Date__c = system.today();
            je.GL_Credit_Account__c = creditGL;
            je.GL_Debit_Account__c = debitGL;
            je.AcctSeed__Accounting_Period__c = billingCashReceipt.AcctSeed__Accounting_Period__c;
            je.Policy__c = bill.Policy__c;
            
            Insert je;
            
            List<AcctSeed__Journal_Entry_Line__c> jeLines = new List<AcctSeed__Journal_Entry_Line__c>();
            
            Decimal ServiceFeeAmount = ((amount/100) * warpperObj.ccFeeRate).setScale(2);
            
            AcctSeed__Journal_Entry_Line__c dLine = new AcctSeed__Journal_Entry_Line__c();
            dLine.AcctSeed__Account__c = bill.AcctSeed__Customer__c;
            dLine.AcctSeed__Units__c = 1;
            dLine.AcctSeed__Journal_Entry__c = je.Id;
            dLine.AcctSeed__Date__c = system.today();
            dLine.AcctSeed__GL_Account__c = debitGL;
            dLine.AcctSeed__Debit__c = ServiceFeeAmount;
            jeLines.add(dLine);
            
            AcctSeed__Journal_Entry_Line__c cLine = new AcctSeed__Journal_Entry_Line__c();
            cLine.AcctSeed__Account__c = bill.AcctSeed__Customer__c;
            cLine.AcctSeed__Units__c = 1;
            cLine.AcctSeed__Journal_Entry__c = je.Id;
            cLine.AcctSeed__Date__c = system.today();
            cLine.AcctSeed__GL_Account__c = creditGL;
            cLine.AcctSeed__Credit__c = ServiceFeeAmount;
            jeLines.add(cLine);
            
            Insert jeLines;
            */
            
            //Create success Integartion log 
            Integration_Log__c log = new Integration_Log__c();
            log.Billing__c =billId;
            log.Status__c='Processed Successfully';
            log.Transaction_Amount__c=amount;
            log.Customer_IP__c = ipAddress;
            log.Payment_Date__c = paymentDate;
            log.Transaction_Id__c=(String)transactionResponseMp.get('retref');
            log.Cash_Receipt__c = cashReceipt.Id;
            log.Description__c='Payment Processed Successfully';
            insert log;
            
            //Send Email Section
            String OrgWideEmailAddressId = '';
            List<OrgWideEmailAddress> oweaList = [select Id,DisplayName from OrgWideEmailAddress Where DisplayName =: Label.OrganizationWideEmail];
            if (!oweaList.isEmpty()) {
                OrgWideEmailAddressId = oweaList.get(0).Id;
            } 
            
            Map<String,String> emailDataMap = generateEmail(pm, /*PaymentSchedule,*/ amount, warpperObj, transactionId, true);
            
            //PaymentGatewayClass.sendEmail(OrgWideEmailAddressId, body, bill.id, true, new List<String>{bill.Billing_Confirmation_Email__c}, Subject,new String[]{Label.ISBA_Accounting_Automation_Email_Address }, Label.ISBA_Accounting_Email_Address, false, bill.AcctSeed__Billing_Contact__c);
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(String.isNotBlank(OrgWideEmailAddressId)){
                mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            }
            mail.setToAddresses(new List<String>{bill.Billing_Confirmation_Email__c});
            mail.setSubject(emailDataMap.get('subject'));
            mail.setBccAddresses(new String[]{Label.ISBA_Accounting_Automation_Email_Address });    
            mail.setInReplyTo(Label.ISBA_Accounting_Email_Address);
            mail.setHtmlBody(emailDataMap.get('body'));
            mail.setWhatId(bill.id);
            mail.setSaveAsActivity(true);
            allmsg.add(mail);
            
            if(isEndorsement && (bill.Policy_Endorsement__r.Endorsement_Number__c == 'IL 152' || bill.Policy_Endorsement__r.Endorsement_Number__c == 'IL 107')){
                Messaging.SingleEmailMessage mail1 = generateEndorsementEmail(bill,OrgWideEmailAddressId);
                allmsg.add(mail1);
            }
            
            system.debug(Messaging.sendEmail(allmsg,false));
        }
        else{
            //Create Error Integartion log 
            String transactionGatewayError='';
            if((String)transactionResponseMp.get('resptext')!=''){
                transactionGatewayError = (String)transactionResponseMp.get('resptext');
            }else {
                transactionGatewayError = (String)transactionResponseMp.get('retref');
            }
            
            //Updating Payment Schedule
            PaymentSchedule[0].Status__c = 'Rejected';
            Update PaymentSchedule[0];
            
            Integration_Log__c log = new Integration_Log__c();
            log.Billing__c =billId;            
            log.Status__c='Processed With Errors';
            log.Customer_IP__c = ipAddress;
            log.Payment_Date__c = paymentDate;
            log.Transaction_Amount__c=warpperObj.totalAmountDue;
            log.Description__c='(Error :'+ transactionGatewayError + ').';
            log.JSON_Body__c = JSON.serialize(warpperObj);
            insert log;
            
            bill.ISBAM_Error__c='Rejected Payment';
            bill.ISBAM_Error_Description__c = (bill.ISBAM_Error_Description__c != null ? bill.ISBAM_Error_Description__c + '\n[' + (System.now().format('MM/dd/yyyy')) + '] Schedule Error ' + log.Description__c :  '[' + (System.now().format('MM/dd/yyyy')) + '] Schedule Error ' + log.Description__c);
               
        }
        
        bill.Customer_Payment_IP_Address__c = ipAddress;
        bill.Customer_Payment_datedate__c = paymentDate;
        Update bill;
    }
    
    public static Map<String,String> generateEmail(Payment_Method__c pm, /*List<Payment_Schedule__c> PaymentSchedule,*/ Decimal amount, PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj, String transactionId, Boolean isFirstPayment){
        String nameForMail = String.isNotBlank(pm.Name_on_Card__c) ? pm.Name_on_Card__c : pm.Card_Holder_Name__c;

        String billId = warpperObj.billing.Id;

        List<Payment_Schedule__c> PaymentSchedule = [SELECT Id, Amount__c, Service_Fee_Amount__c, Due_Date__c FROM Payment_Schedule__c WHERE  Due_Date__c > TODAY AND Billing__c =: billId  AND Status__c != 'Paid' order by Due_Date__c];
        
        String body = 'Dear ' + nameForMail + ',<br/><br/>Thank you for insuring your law firm with ISBA Mutual. <br/> <br/>';
        if(PaymentSchedule.Size() == 1){
            
            body += 'We have processed your premium payment in the amount of $';
            if(pm.Type__c == 'Credit_Card'){
                body += (amount * (warpperObj.ccFeeRate + 100) / 100).setScale(2);
            }
            else{
                body += amount.setScale(2);
            }
            
            body += ' using payment method ending in '+pm.Last_4_Account_Number__c+'. ';
            
            if(pm.Type__c == 'Credit_Card'){
                body += 'This includes a '+warpperObj.ccFeeRate+'% credit card convenience fee of $'+(amount * warpperObj.ccFeeRate / 100).setScale(2)+'.';
            }   
            else{
                body += '<br/>';
                body += 'Please note that ACH/e-check transactions may take up to 5 business days to settle and reflect on your account.';
            }
            body += '<br/>';
            
            //body += 'Your payment to ISBA Mutual for $'+amount.setScale(2) +' has been successfully processed.<br/>';
            body += 'For your reference, the transaction number for this payment is: '+ transactionId + '<br/><br/>';
        }
        else{  
            if(isFirstPayment){
                body += 'Your payment plan has been created and we have processed your first scheduled premium payment in the amount of $';
            }
            else{
                body += 'We have processed your premium payment in the amount of $';
            }
            
            if(pm.Type__c == 'Credit_Card'){
                body += (amount * (warpperObj.ccFeeRate + 100) / 100).setScale(2);
            }
            else{
                body += amount.setScale(2);
            }
            
            body += ' using payment method ending in '+pm.Last_4_Account_Number__c+'. ';
            if(pm.Type__c == 'Credit_Card'){
                body += 'This includes a '+warpperObj.ccFeeRate+'% credit card convenience fee of $'+(amount * warpperObj.ccFeeRate / 100).setScale(2)+'.';
            }  
            else{
                body += '<br/><br/>';
                body += 'Please note that ACH/e-check transactions may take up to 5 business days to settle and reflect on your account.';
            } 
            
            body += '<br/><br/>';      
            body += 'For your reference, the transaction number for this is: '+ transactionId + '<br/>';
            
            body += '<br/>Future payments will be charged as follows:<br/><br/>';
            
            for(Integer i = 0; i < PaymentSchedule.Size(); i++){
                Payment_Schedule__c ps = PaymentSchedule[i];
                
                String tempDt = String.valueOf(ps.Due_Date__c.month()).leftPad(2, '0')+ '/' +String.valueOf(ps.Due_Date__c.day()).leftPad(2, '0') +'/'+ ps.Due_Date__c.year();
                
                if(pm.Type__c == 'Credit_Card'){
                    body += tempDt+':&nbsp;&nbsp;&nbsp;&nbsp;$'+ps.Amount__c.setScale(2)+'&nbsp;&nbsp;&nbsp;&nbsp;(+$'+(ps.Amount__c * warpperObj.ccFeeRate / 100).setScale(2)+')&nbsp;&nbsp;&nbsp;&nbsp;$'+(ps.Amount__c * (warpperObj.ccFeeRate + 100) / 100).setScale(2)+'<br/>';
                }
                else{
                    body += tempDt+':&nbsp;&nbsp;&nbsp;&nbsp;$'+ps.Amount__c.setScale(2)+'<br/>';
                }
            }
            
            body += '<br/>' ;
        } 
        
        body += '<br/>If you have any questions or need further assistance, please contact our accounting team at 312-379-2005 or accounting@isbamutual.com.<br/><br/>';
        body += 'Thank you,<br/><br/>Ashley Rosado<br/>Accounting<br/>312-379-2005<br/>Accounting@isbamutual.com<br/><br/>ISBA Mutual Accounting<br/>20 South Clark Street, Suite 800<br/>Chicago, IL 60603-1826<br/><br/>312 379-2005<br/><br/><a href="https://www.isbamutual.com/">www.ISBAMutual.com</a>';
        
        Map<String,String> emailDataMap = new Map<String,String>();
        emailDataMap.put('body',body);
        emailDataMap.put('subject','ISBA Mutual Insurance '+warpperObj.billing.Policy__r.Name+' Payment Processed');
        return emailDataMap;
    }
    
    public static Messaging.SingleEmailMessage generateEndorsementEmail(AcctSeed__Billing__c bill, String OrgWideEmailAddressId){
        emailWrapper emailWrap = new emailWrapper();
        String contactId = '';
        String emailBody = '';
        String templateName = '';
        List<String> toAddressList = new List<String>(); 
        
        if(String.isNotBlank(bill.Billing_Confirmation_Email__c)){
            toAddressList.add(bill.Billing_Confirmation_Email__c);
        }
        
        if(String.isNotBlank(bill.AcctSeed__Billing_Contact__c)){
            contactId = bill.AcctSeed__Billing_Contact__c;
            if(toAddressList.isEmpty()){
                toAddressList.add(bill.AcctSeed__Billing_Contact__r.Email);
            }
        }
        else{
            contactId = bill.Policy__r.Firm_Contact__c;
            if(toAddressList.isEmpty()){
                toAddressList.add(bill.Policy__r.Firm_Contact__r.Email);
            }
        }
        
        if(bill.Policy_Endorsement__r.Endorsement_Number__c == 'IL 152'){
            templateName  = 'CONFIRMATION - IL152 Add Lawyer';
        }
        else if(bill.Policy_Endorsement__r.Endorsement_Number__c == 'IL 107'){
            templateName  = 'CONFIRMATION - IL107 ERE';
        }
        
        List<EmailTemplate> templateList = new List<EmailTemplate>([Select id,Subject,Body,HtmlValue from EmailTemplate where name =: templateName]);
        List<Messaging.EmailFileAttachment> emailFileAttachments = new List<Messaging.EmailFileAttachment>();
        
        PageReference pg = Page.Endorsement_Pdf;
        pg.getParameters().put('id', bill.Policy_Endorsement__c);
        pg.getParameters().put('number', bill.Policy_Endorsement__r.Endorsement_Number__c);
        pg.getParameters().put('version', bill.Policy_Endorsement__r.Endorsement_Version__c);  
        
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        if (Test.isRunningTest()) {
            efa.body = Blob.valueOf('Mock PDF content for test');
        } else {
            efa.body = pg.getContent();
        }
        //efa.body = pg.getContent();
        efa.fileName = 'Endorsement.pdf'; 
        emailFileAttachments.add(efa);
        
        //Messaging.SingleEmailMessage tempEmail = Messaging.renderStoredEmailTemplate(templateList[0].Id, contactId, bill.Policy_Endorsement__c);
		Messaging.SingleEmailMessage tempEmail;
        if (Test.isRunningTest()) {
            tempEmail = new Messaging.SingleEmailMessage();
            tempEmail.setSubject('Test Subject - ' + templateName);
            tempEmail.setHtmlBody('<p>Mock email body for ' + templateName + '</p>');
        } else {
            tempEmail = Messaging.renderStoredEmailTemplate(
                templateList[0].Id,
                contactId,
                bill.Policy_Endorsement__c
            );
        }
        
        Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
        if(String.isNotBlank(OrgWideEmailAddressId)){
            mail1.setOrgWideEmailAddressId(OrgWideEmailAddressId);
        }
        mail1.setToAddresses(toAddressList);
        mail1.setSubject(String.valueOf(tempEmail.getSubject())); 
        mail1.setBccAddresses(new String[]{Label.ISBA_Accounting_Automation_Email_Address });
        
        if(tempEmail.getHtmlBody() != null){
            emailBody = String.valueOf(tempEmail.getHtmlBody());
        }else{
            emailBody = tempEmail.getPlainTextBody().replaceAll('\n','<br/>');
            emailBody = emailBody.replaceAll('<p>','');
            emailBody = emailBody.replaceAll('</p>','');
        }
        
        mail1.setInReplyTo(Label.ISBA_Accounting_Email_Address);
        mail1.setHtmlBody(emailBody);
        mail1.setWhatId(bill.Policy_Endorsement__c);
        if(!emailFileAttachments.isEmpty()){
            mail1.setFileAttachments(emailFileAttachments);
        }
        mail1.setSaveAsActivity(true);
        
        return mail1;
    }
    
    public class emailWrapper{
        public Messaging.SingleEmailMessage tempEmail{get;set;}
        public List<Messaging.EmailFileAttachment> emailFileAttachments{get;set;}
    }
    
    Public Class Wrapper{
        public Decimal amount {get;Set;} 
        public String billId{get;Set;}
        public String pmtMethodToken{get;Set;}
        public String paymentTypeVar{get;Set;}
        public String ipAddress{get;Set;}
        public Boolean isEndorsement{get;set;}
        
        public Wrapper(){
            this.isEndorsement = false;
        }
    }
}