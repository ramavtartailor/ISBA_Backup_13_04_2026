@RestResource(urlMapping='/DynamicPayment/*')
global class PaymentRestApi {
    @HttpPost //HttpPost annotation exposes the method as a REST resource and called when an HTTP POST request is sent
    global static PaymentRestApiWrapper callMethods() {
        String RequestedBody = '';
        RestResponse res = RestContext.response;
        
        RestRequest r = RestContext.request;
        system.debug('r.requestedBody'+  r.requestBody.toString());
        RequestedBody = r.requestBody.toString();
        
        Map<String,Object> requestMap = (Map<String,Object>) JSON.deserializeUntyped(RequestedBody);

        if(requestMap.containsKey('callApex') && Boolean.valueOf(String.valueOf(requestMap.get('callApex')))){
            return PaymentRestApi.callApexMethod(requestMap);
        }
        else if(requestMap.containsKey('PaymtSchId')){
            return PaymentRestApi.taskCreationLogic(RequestedBody);
        }
        else{
            return PaymentRestApi.taskCreationLogicOld(RequestedBody);
        }
    }

    global static PaymentRestApiWrapper callApexMethod(Map<String,Object> requestMap) {
        PaymentRestApiWrapper wrap = new PaymentRestApiWrapper();
        System.debug('Arguments => : ' + String.valueOf(requestMap.get('arguments')));
        Map<String,Object> arguments =(Map<String, Object>) requestMap.get('arguments');
        if(String.valueOf(requestMap.get('className')) == 'ConvertToPolicyLtng' && String.valueOf(requestMap.get('methodName')) == 'convertPolicy'){
            wrap.success = ConvertToPolicyLtng.convertPolicy(String.valueOf(arguments.get('policyId')), String.valueOf(arguments.get('policyDocVersion')));
        }
        else if(String.valueOf(requestMap.get('className')) == 'PolicyEndorsementController' && String.valueOf(requestMap.get('methodName')) == 'updatePolicy'){
            try{  
                PolicyEndorsementController.updatePolicy(String.valueOf(arguments.get('policyId')));
                wrap.success = true;
            }
            catch(Exception e){
                system.debug('Error =>'+e.getMessage()+' => '+e.getLineNumber());
                wrap.success = false;
            }
        }
        return wrap;
    }
    global static PaymentRestApiWrapper taskCreationLogicOld(String RequestedBody) {
        try{
            object bodyRequest = JSON.deserializeUntyped(RequestedBody);
            
            system.debug('bodyRequest'+bodyRequest);
            
            map<String,Object> Requestedmap = (map<String,Object>) bodyRequest;
            map<String,Object> billingObj = (map<String,Object>) Requestedmap.get('Billing');
            String objBillingId = (string)billingObj.get('Id');
            
            map<String,Object> warpperObj = (map<String,Object>) Requestedmap.get('warpperObj');
            
            map<String,Object> baseAmountToPayMap = (map<String,Object>) Requestedmap.get('baseAmountToPay');
            map<String,Object> paymentMonthsDtMap = (map<String,Object>) Requestedmap.get('paymentMonthsDt');
            map<String,Object> totalAmountDueMap = (map<String,Object>) Requestedmap.get('totalAmountDue');
            map<String,Object> receiptNumberMap = (map<String,Object>) Requestedmap.get('receiptNumber');
            map<String,Object> firstInstallmentMap = (map<String,Object>) Requestedmap.get('firstInstallment');
            map<String,Object> paymentQuartersDtMap = (map<String,Object>) Requestedmap.get('paymentQuartersDt');
            map<String,Object> firstInstallmentDtMap = (map<String,Object>) Requestedmap.get('firstInstallmentDate');
            map<String,Object> UtilTranIdMap = (map<String,Object>) Requestedmap.get('UtilTranId');
            string baseAmountToPayStr = (String) baseAmountToPayMap.get('baseAmountToPay');
            string paymentMonthsDtStr = paymentMonthsDtMap.get('paymentMonthsDt') == null ? null :(string) paymentMonthsDtMap.get('paymentMonthsDt');
            String totalAmountDueStr = (string) totalAmountDueMap.get('totalAmountDue');
            string receiptNumber = (string) receiptNumberMap.get('receiptNumber');
            String firstInstallmentStr = (String)firstInstallmentMap.get('firstInstallment');
            String UtilTranId = (string) UtilTranIdMap.get('UtilTranId');
            String paymentQuartersDtStr = paymentQuartersDtMap.get('paymentQuartersDt') == null ? null :(string)paymentQuartersDtMap.get('paymentQuartersDt');
            String firstInstallmentDtStr = firstInstallmentDtMap.get('firstInstallmentDate') == null ? null :(string)firstInstallmentDtMap.get('firstInstallmentDate');
            Decimal baseAmountToPay = Decimal.valueOf(baseAmountToPayStr); 
            Decimal totalAmountDue = Decimal.valueOf(totalAmountDueStr); 
            Decimal firstInstallment = Decimal.valueOf(firstInstallmentStr);
            Date paymentMonthsDt = (String.isBlank(paymentMonthsDtStr) || paymentMonthsDtStr == 'null')? null : Date.valueOf(paymentMonthsDtStr);
            Date paymentQuartersDt = (String.isBlank(paymentQuartersDtStr) || paymentQuartersDtStr == 'null' ) ? null : Date.valueOf(paymentQuartersDtStr);
            Date firstInstallmentDate = (String.isBlank(firstInstallmentDtStr) || firstInstallmentDtStr == 'null' ) ? null : Date.valueOf(firstInstallmentDtStr);
            Id cashReceiptId;
            AcctSeed__Billing__c billing = [select id,name,AcctSeed__Due_Date2__c ,AcctSeed__Balance__c,AcctSeed__Customer__r.Name,
                                   AcctSeed__Customer__c,First_Payment_Date__c,IsPaymentProcessed__c,Mode_Of_Payment__c,
                                   Next_Payment_Base_Amount__c,Next_Payment_Date__c,Next_Payment_Service_Fee__c,AcctSeed__Billing_Street__c,
                                   Payment_Frequency__c,Firm_Name__c,Legacy_Invoice_Id__c,Legacy_Firm_Id__c,AcctSeed__Billing_City__c,
                                   AcctSeed__Customer__r.AccountNumber,AcctSeed__Billing_State__c,AcctSeed__Billing_PostalCode__c,AcctSeed__Accounting_Period__c,AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c,Policy__c,Policy__r.Effective_Date__c,
                                   (select id,AcctSeed__GL_Account_Variable_1__c from AcctSeed__Project_Billing_Lines__r )      
                                   from AcctSeed__Billing__c 
                                   where Id =: objBillingId];
           
            //if(totalAmountDue - baseAmountToPay>0){
                // AcctSeed__Cash_Receipt__c serviceChargecashReceipt = new AcctSeed__Cash_Receipt__c();
                // serviceChargecashReceipt.AcctSeed__Account__c=billing.AcctSeed__Customer__c;
                // serviceChargecashReceipt.AcctSeed__Payment_Reference__c=util1.transaction_id;
                // serviceChargecashReceipt.AcctSeed__Amount__c=totalAmountDue - baseAmountToPay;
                // serviceChargecashReceipt.AcctSeed__Receipt_Date__c=System.today();
                // serviceChargecashReceipt.AcctSeed__Credit_GL_Account__c=[select id from AcctSeed__GL_Account__c where name=:Label.Service_Charge_GL_Account limit 1].id;
                // if(warpperObj.paymentTypeVar=='check'){
                // serviceChargecashReceipt.Processing_Type__c='ACH';
                // }else if(warpperObj.paymentTypeVar=='creditCard'){
                // serviceChargecashReceipt.Processing_Type__c='Credit Card';
                // }

                // insert serviceChargecashReceipt;
            //}
            
            if(baseAmountToPay > 0){
                    billing.First_Payment_Date__c = System.today();
            }
            
            billing.IsPaymentProcessed__c = true;
            
            billing.Billing_Confirmation_Email__c=(string)warpperObj.get('confirmationEmail');
            billing.Billing_First_Name__c=(string)warpperObj.get('firstName');
            billing.Billing_Last_Name__c=(string)warpperObj.get('lastName');
            if(warpperObj.get('paymentTypeVar')=='check' || warpperObj.get('accountNumber') != null){
                billing.Billing_Account_Holder_Name__c=(string)warpperObj.get('accountHolderName');
                billing.Billing_Account_Number__c=String.valueOf(warpperObj.get('accountNumber'));
                billing.Billing_Account_Type__c=(string)warpperObj.get('accountType');
                billing.Billing_Routing_Number__c=(string)warpperObj.get('routingNumber');
                billing.Mode_Of_Payment__c= 'eCheck/ACH';
            }else if(warpperObj.get('paymentTypeVar')=='creditCard' || warpperObj.get('cardNumber') != null){
                billing.Billing_Card_Expire_Month__c= Decimal.valueOf((String)warpperObj.get('expireMonth'));
              	billing.Billing_Card_Expire_Year__c= Decimal.valueOf((String)warpperObj.get('expireYear'));
                billing.Billing_Card_Number__c=String.valueof(warpperObj.get('cardNumber'));
                billing.Billing_Card_Type__c=(String)warpperObj.get('cardTypeVar');
                billing.Billing_Card_Verification_Number__c=(String)warpperObj.get('verificationNumber');
                billing.Billing_Name_On_Card__c=(String)warpperObj.get('nameOnCard');
                billing.Mode_Of_Payment__c= 'Credit Card';
            }
            if(warpperObj.get('paymentScheduleVar')=='Month'){
                // if(baseAmountToPay > 0){
                //     billing.Next_Payment_Base_Amount__c = baseAmountToPay;
                // }else{
                //     billing.Next_Payment_Base_Amount__c = firstInstallment;
                // }
                billing.Next_Payment_Base_Amount__c = firstInstallment.setScale(2);
                billing.Next_Payment_Date__c = paymentMonthsDt;
                if(warpperObj.get('paymentTypeVar')=='creditCard'){
                    billing.Next_Payment_Service_Fee__c = totalAmountDue - baseAmountToPay;
                }else if(warpperObj.get('paymentTypeVar')=='check'){
                    billing.Next_Payment_Service_Fee__c = 0;
                }
                
                billing.Payment_Frequency__c='Monthly';
            }else if(warpperObj.get('paymentScheduleVar')=='Quarter'){
                // if(baseAmountToPay > 0){
                //     billing.Next_Payment_Base_Amount__c = baseAmountToPay;
                // }else{
                //     billing.Next_Payment_Base_Amount__c = firstInstallment;
                // }
                billing.Next_Payment_Base_Amount__c = firstInstallment.setScale(2);
                billing.Next_Payment_Date__c = paymentQuartersDt;
                if(warpperObj.get('paymentTypeVar')=='creditCard'){
                    billing.Next_Payment_Service_Fee__c = totalAmountDue - baseAmountToPay;
                }else if(warpperObj.get('paymentTypeVar')=='check'){
                    billing.Next_Payment_Service_Fee__c = 0;
                }
                billing.Payment_Frequency__c='Quarterly';
            }else if(warpperObj.get('paymentScheduleVar')=='Full'){
                billing.Payment_Frequency__c='Full';
                if(baseAmountToPay == 0){
                    billing.Next_Payment_Base_Amount__c = billing.AcctSeed__Balance__c;
                    // billing.Next_Payment_Date__c = billing.AcctSeed__Due_Date2__c;
                    // if(billing.Policy__c != null){
                    //     billing.Next_Payment_Date__c = billing.Policy__r.Effective_Date__c;
                    // }
                    billing.Next_Payment_Date__c = firstInstallmentDate;
                }
            }
            update billing;
            
            //if(baseAmountToPay >0 && (warpperObj.get('paymentTypeVar')=='creditCard' || (warpperObj.get('paymentTypeVar')=='Existing' && warpperObj.get('cardNumber') != null))){
            if(baseAmountToPay >0){


                AcctSeed__Cash_Receipt__c cashReceipt = new AcctSeed__Cash_Receipt__c();
                cashReceipt.AcctSeed__Account__c=billing.AcctSeed__Customer__c;
                cashReceipt.AcctSeed__Payment_Reference__c=UtilTranId;
                
                cashReceipt.AcctSeed__Amount__c=baseAmountToPay;
                cashReceipt.AcctSeed__Receipt_Date__c=System.today();
                if(warpperObj.get('paymentTypeVar')=='check'){
                    cashReceipt.Processing_Type__c='ACH';
                }else if(warpperObj.get('paymentTypeVar')=='creditCard'){
                    cashReceipt.Processing_Type__c='Credit Card';
                }
                
                String bankAccId = [SELECT Id FROM AcctSeed__GL_Account__c WHERE Name = '1101-Main Cash (CIBC)' LIMIT 1].Id;
                cashReceipt.AcctSeed__Bank_Account__c = bankAccId;
                
                cashReceipt.AcctSeed__GL_Account_Variable_1__c = billing.AcctSeed__Project_Billing_Lines__r[0].AcctSeed__GL_Account_Variable_1__c;
                
                insert cashReceipt;
                
                Id accountPeriodId = [SELECT id,name,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM  AcctSeed__Accounting_Period__c  WHERE AcctSeed__Status__c = 'Open' and AcctSeed__Start_Date__c<=TODAY and AcctSeed__End_Date__c>=TODAY limit 1][0].id;
                system.debug('accountPeriodId+'+accountPeriodId);
                AcctSeed__Billing_Cash_Receipt__c billingCashReceipt = new AcctSeed__Billing_Cash_Receipt__c();
                billingCashReceipt.AcctSeed__Applied_Amount__c = baseAmountToPay;
                billingCashReceipt.AcctSeed__Billing__c= billing.id;
                billingCashReceipt.AcctSeed__Cash_Receipt__c=cashReceipt.Id;
                billingCashReceipt.AcctSeed__Accounting_Period__c=accountPeriodId;
                billingCashReceipt.AcctSeed__Applied_Date__c = System.today();
                
                if(billing.AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c > System.today() ){
                    billingCashReceipt.AcctSeed__Accounting_Period__c = billing.AcctSeed__Accounting_Period__c;
                    billingCashReceipt.AcctSeed__Applied_Date__c = billing.AcctSeed__Due_Date2__c;
                }else{
                    billingCashReceipt.AcctSeed__Accounting_Period__c = accountPeriodId;   
                }
                
                system.debug('billingCashReceipt+'+billingCashReceipt);
                insert billingCashReceipt;
                
                receiptNumber = [select id,name from AcctSeed__Cash_Receipt__c where id=: cashReceipt.Id limit 1][0].name;
                cashReceiptId = cashReceipt.Id;
            }else{
                receiptNumber = UtilTranId;
            }
            
            Map<String,AcctSeed__Payment_Method__c> paymentMethods = new Map<String,AcctSeed__Payment_Method__c>();
            
            for(AcctSeed__Payment_Method__c method : [select id,AcctSeed__Payment_Method_Type__c,Account_Number__c,AcctSeed__Routing_Number__c,Credit_Card_Number__c from AcctSeed__Payment_Method__c where AcctSeed__Customer__c =: billing.AcctSeed__Customer__c]){
                if(method.AcctSeed__Payment_Method_Type__c == 'Bank Account'){
                    paymentMethods.put(method.AcctSeed__Payment_Method_Type__c + method.Account_Number__c + method.AcctSeed__Routing_Number__c,method);
                }else{
                    paymentMethods.put(method.AcctSeed__Payment_Method_Type__c + method.Credit_Card_Number__c,method);
                }
            }
            
            if(warpperObj.get('paymentTypeVar')=='check'){
                AcctSeed__Payment_Method__c PayMethod = new AcctSeed__Payment_Method__c();
                Datetime x =  Datetime.now();
                PayMethod.AcctSeed__External_Id__c = String.valueOf(x.getTime());
                if(paymentMethods.containsKey('Bank Account'+String.valueOf(warpperObj.get('accountNumber'))+(string)warpperObj.get('routingNumber'))){
                	PayMethod = paymentMethods.get('Bank Account'+String.valueOf(warpperObj.get('accountNumber'))+(string)warpperObj.get('routingNumber'));
                }
                PayMethod.AcctSeed__Customer__c = billing.AcctSeed__Customer__c;
                PayMethod.AcctSeed__Default__c = true;
                PayMethod.AcctSeed__Last_Four_Digits__c = String.valueof(warpperObj.get('accountNumber')).substring(String.valueof(warpperObj.get('accountNumber')).length()-4, String.valueof(warpperObj.get('accountNumber')).length());
                PayMethod.AcctSeed__Card_Holder_Name__c = (string)warpperObj.get('accountHolderName');
                PayMethod.AcctSeed__Payment_Method_Type__c = 'Bank Account';
                PayMethod.Account_Number__c =String.valueOf(warpperObj.get('accountNumber'));
                PayMethod.AcctSeed__Routing_Number__c = (string)warpperObj.get('routingNumber');
                PayMethod.AcctSeed__Bank_Account_Type__c =(string)warpperObj.get('accountType');
                upsert PayMethod; 
            }
            else if(warpperObj.get('paymentTypeVar')=='creditCard'){
                AcctSeed__Payment_Method__c PayMethod = new AcctSeed__Payment_Method__c();
                Datetime x =  Datetime.now();
                PayMethod.AcctSeed__External_Id__c = String.valueOf(x.getTime());
                if(paymentMethods.containsKey('Credit Card'+String.valueOf(warpperObj.get('cardNumber')))){
                    PayMethod = paymentMethods.get('Credit Card'+String.valueOf(warpperObj.get('cardNumber')));
                }
                PayMethod.AcctSeed__Customer__c = billing.AcctSeed__Customer__c;
                PayMethod.AcctSeed__Default__c = true;
                PayMethod.Name_on_Card__c = (String)warpperObj.get('nameOnCard');
                PayMethod.AcctSeed__Payment_Method_Type__c = 'Credit Card';
                PayMethod.AcctSeed__Type__c = (String)warpperObj.get('cardTypeVar');
                PayMethod.Credit_Card_Number__c = String.valueof(warpperObj.get('cardNumber'));
                PayMethod.Card_Verification_Number__c  = (String)warpperObj.get('verificationNumber');
                PayMethod.AcctSeed__Expiration_Year__c = (String)warpperObj.get('expireYear');
                PayMethod.AcctSeed__Last_Four_Digits__c = String.valueof(warpperObj.get('cardNumber')).substring(String.valueof(warpperObj.get('cardNumber')).length()-4, String.valueof(warpperObj.get('cardNumber')).length());
                PayMethod.AcctSeed__Expiration_Month__c = (String)warpperObj.get('expireMonth');
                upsert PayMethod;  
            }
            
            
            
            PaymentRestApiWrapper wrapper = new PaymentRestApiWrapper();
            wrapper.receiptNumber = receiptNumber;
            wrapper.cashReceiptId = cashReceiptId;
            return wrapper;
        }
        catch( exception ex){
            system.debug('ex'+ex.getMessage()+ex.getLineNumber());
            PaymentRestApiWrapper wrapper = new PaymentRestApiWrapper();
            wrapper.error = ex.getMessage();
            return wrapper;
        }
    }
    global static PaymentRestApiWrapper taskCreationLogic(String RequestedBody) {
        try{
            object bodyRequest = JSON.deserializeUntyped(RequestedBody);
            
            system.debug('bodyRequest'+bodyRequest);
            
            map<String,Object> Requestedmap = (map<String,Object>) bodyRequest;
            map<String,Object> billingObj = (map<String,Object>) Requestedmap.get('Billing');
            String objBillingId = (string)billingObj.get('Id');
            
            map<String,Object> warpperObj = (map<String,Object>) Requestedmap.get('warpperObj');
            
            map<String,Object> baseAmountToPayMap = (map<String,Object>) Requestedmap.get('baseAmountToPay');
            map<String,Object> paymentMonthsDtMap = (map<String,Object>) Requestedmap.get('paymentMonthsDt');
            map<String,Object> totalAmountDueMap = (map<String,Object>) Requestedmap.get('totalAmountDue');
            map<String,Object> receiptNumberMap = (map<String,Object>) Requestedmap.get('receiptNumber');
            map<String,Object> firstInstallmentMap = (map<String,Object>) Requestedmap.get('firstInstallment');
            map<String,Object> paymentQuartersDtMap = (map<String,Object>) Requestedmap.get('paymentQuartersDt');
            map<String,Object> firstInstallmentDtMap = (map<String,Object>) Requestedmap.get('firstInstallmentDate');
            map<String,Object> UtilTranIdMap = (map<String,Object>) Requestedmap.get('UtilTranId');
            string baseAmountToPayStr = (String) baseAmountToPayMap.get('baseAmountToPay');
            string paymentMonthsDtStr = paymentMonthsDtMap.get('paymentMonthsDt') == null ? null :(string) paymentMonthsDtMap.get('paymentMonthsDt');
            String totalAmountDueStr = (string) totalAmountDueMap.get('totalAmountDue');
            string receiptNumber = (string) receiptNumberMap.get('receiptNumber');
            String firstInstallmentStr = (String)firstInstallmentMap.get('firstInstallment');
            String UtilTranId = (string) UtilTranIdMap.get('UtilTranId');
            String paymentQuartersDtStr = paymentQuartersDtMap.get('paymentQuartersDt') == null ? null :(string)paymentQuartersDtMap.get('paymentQuartersDt');
            String firstInstallmentDtStr = firstInstallmentDtMap.get('firstInstallmentDate') == null ? null :(string)firstInstallmentDtMap.get('firstInstallmentDate');
            Decimal baseAmountToPay = Decimal.valueOf(baseAmountToPayStr); 
            Decimal totalAmountDue = Decimal.valueOf(totalAmountDueStr); 
            Decimal firstInstallment = Decimal.valueOf(firstInstallmentStr);
            Date paymentMonthsDt = (String.isBlank(paymentMonthsDtStr) || paymentMonthsDtStr == 'null')? null : Date.valueOf(paymentMonthsDtStr);
            Date paymentQuartersDt = (String.isBlank(paymentQuartersDtStr) || paymentQuartersDtStr == 'null' ) ? null : Date.valueOf(paymentQuartersDtStr);
            Date firstInstallmentDate = (String.isBlank(firstInstallmentDtStr) || firstInstallmentDtStr == 'null' ) ? null : Date.valueOf(firstInstallmentDtStr);
            Id cashReceiptId;
            AcctSeed__Billing__c billing = [select id,name,AcctSeed__Due_Date2__c ,AcctSeed__Balance__c,AcctSeed__Customer__r.Name,
                                   AcctSeed__Customer__c,First_Payment_Date__c,IsPaymentProcessed__c,Mode_Of_Payment__c,Service_Fee__c,
                                   Next_Payment_Base_Amount__c,Next_Payment_Date__c,Next_Payment_Service_Fee__c,AcctSeed__Billing_Street__c,
                                   Payment_Frequency__c,Firm_Name__c,Legacy_Invoice_Id__c,Legacy_Firm_Id__c,AcctSeed__Billing_City__c,
                                   AcctSeed__Customer__r.AccountNumber,AcctSeed__Billing_State__c,AcctSeed__Billing_PostalCode__c,AcctSeed__Accounting_Period__c,AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c,Policy__c,Policy__r.Effective_Date__c,
                                   (select id,AcctSeed__GL_Account_Variable_1__c from AcctSeed__Project_Billing_Lines__r )      
                                   from AcctSeed__Billing__c 
                                   where Id =: objBillingId];
            
			AcctSeed__Payment_Processor__c fiservProcessor = [SELECT Id, Name FROM AcctSeed__Payment_Processor__c WHERE Name='Fiserv' LIMIT 1];        
            
            
            billing.IsPaymentProcessed__c = true;
            
            if(warpperObj.get('paymentScheduleVar')=='Month'){
                billing.Payment_Frequency__c='Monthly';
            }else if(warpperObj.get('paymentScheduleVar')=='Quarter'){
                billing.Payment_Frequency__c='Quarterly';
            }else if(warpperObj.get('paymentScheduleVar')=='Full'){
                billing.Payment_Frequency__c='Full';
            }
            update billing;
            
            String paySchId = String.valueOf(Requestedmap.get('PaymtSchId'));
            Payment_Schedule__c paymentSchedule = new Payment_Schedule__c (id = paySchId);
            paymentSchedule.Payment_Reference__c = UtilTranId;
            paymentSchedule.Status__c = 'Pending';
            
            //Update paymentSchedule;
            if(baseAmountToPay >0){
                AcctSeed__Cash_Receipt__c cashReceipt = new AcctSeed__Cash_Receipt__c();
                cashReceipt.AcctSeed__Account__c = billing.AcctSeed__Customer__c;
                cashReceipt.AcctSeed__Payment_Reference__c = UtilTranId;
                cashReceipt.AcctSeed__Amount__c = baseAmountToPay;
                cashReceipt.AcctSeed__Receipt_Date__c = System.today();
                cashReceipt.AcctSeed__Payment_Processor__c = fiservProcessor.Id;
                
                Decimal ServiceFeeAmount = 0.00;
                
                if(warpperObj.get('paymentTypeVar')=='check'){
                    cashReceipt.Processing_Type__c='ACH';
                    paymentSchedule.Service_Fee_Rate__c = null;
                }else if(warpperObj.get('paymentTypeVar')=='creditCard'){
                    cashReceipt.Processing_Type__c='Credit Card';
                    ServiceFeeAmount = ((baseAmountToPay/100) * billing.Service_Fee__c).setScale(2);
                    cashReceipt.AcctSeed__Amount__c = baseAmountToPay + ServiceFeeAmount;
                    paymentSchedule.Service_Fee_Rate__c = billing.Service_Fee__c;
                }
                
                cashReceipt.AcctSeed__GL_Account_Variable_1__c = billing.AcctSeed__Project_Billing_Lines__r[0].AcctSeed__GL_Account_Variable_1__c;
                
                insert cashReceipt;
                
                List<AcctSeed__GL_Account__c> glList = [SELECT Id, Name FROM AcctSeed__GL_Account__c WHERE Name =: label.Adjustment_GL_Account LIMIT 1]; 
                
                //Updateing Cash Receipt Id on Payment Schedule.
                //String paySchId = String.valueOf(Requestedmap.get('PaymtSchId'));
                //Payment_Schedule__c paymentSchedule = [SELECT Id,Amount__c FROM Payment_Schedule__c Where Id =: paySchId];

                paymentSchedule.Cash_Receipt__c = cashReceipt.Id;
                PaymentSchedule.Status__c = 'Paid';
                PaymentSchedule.Paid_Amount__c = baseAmountToPay;

                Id accountPeriodId = [SELECT id,name,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM  AcctSeed__Accounting_Period__c  WHERE AcctSeed__Status__c = 'Open' and AcctSeed__Start_Date__c<=TODAY and AcctSeed__End_Date__c>=TODAY limit 1][0].id;
                system.debug('accountPeriodId+'+accountPeriodId);
                AcctSeed__Billing_Cash_Receipt__c billingCashReceipt = new AcctSeed__Billing_Cash_Receipt__c();
                billingCashReceipt.AcctSeed__Applied_Amount__c = baseAmountToPay + ServiceFeeAmount;
                billingCashReceipt.AcctSeed__Billing__c= billing.id;
                billingCashReceipt.AcctSeed__Cash_Receipt__c=cashReceipt.Id;
                billingCashReceipt.AcctSeed__Accounting_Period__c=accountPeriodId;
                billingCashReceipt.AcctSeed__Applied_Date__c = System.today();
                billingCashReceipt.AcctSeed__Adjustment_GL_Account__c = glList[0].Id;
            	billingCashReceipt.AcctSeed__Adjustment_Amount__c = -ServiceFeeAmount;
                
                if(billing.AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c > System.today() ){
                    billingCashReceipt.AcctSeed__Accounting_Period__c = billing.AcctSeed__Accounting_Period__c;
                    billingCashReceipt.AcctSeed__Applied_Date__c = billing.AcctSeed__Due_Date2__c;
                }else{
                    billingCashReceipt.AcctSeed__Accounting_Period__c = accountPeriodId;   
                }
                
                system.debug('billingCashReceipt+'+billingCashReceipt);
                insert billingCashReceipt;
                
                receiptNumber = [select id,name from AcctSeed__Cash_Receipt__c where id=: cashReceipt.Id limit 1][0].name;
                cashReceiptId = cashReceipt.Id;
            }else{ 
                receiptNumber = UtilTranId;
            }
            
            Update paymentSchedule;
            
            PaymentRestApiWrapper wrapper = new PaymentRestApiWrapper();
            wrapper.receiptNumber = receiptNumber;
            wrapper.cashReceiptId = cashReceiptId;
            return wrapper;
        }
        catch( exception ex){
            system.debug('ex'+ex.getMessage()+ex.getLineNumber());
            PaymentRestApiWrapper wrapper = new PaymentRestApiWrapper();
            wrapper.error = ex.getMessage()+ '\n' + ex.getStackTraceString();
            return wrapper;
        }
    }
    global class PaymentRestApiWrapper{
        public String error;
        public String receiptNumber;
        public String cashReceiptId;
        public Boolean success;
    }
    // global class callApexResponseWrapper {
    //     public Boolean success;
    // }
}