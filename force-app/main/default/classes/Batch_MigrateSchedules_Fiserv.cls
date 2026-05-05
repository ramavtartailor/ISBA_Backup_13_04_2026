global class Batch_MigrateSchedules_Fiserv implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    global Set<String> recordIds {get;set;}
    
    global Batch_MigrateSchedules_Fiserv(Set<String> recIds){
        this.recordIds = recIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        return Database.getQueryLocator('SELECT Id,AcctSeed__Customer__c, Next_Payment_Date__c, Next_Payment_Base_Amount__c, AcctSeed__Balance__c, Payment_Frequency__c, Mode_Of_Payment__c, Billing_Card_Number__c, Billing_Card_Type__c, Billing_Account_Type__c, Billing_Card_Verification_Number__c, Billing_Card_Expire_Month__c, Billing_Card_Expire_Year__c, Billing_Account_Holder_Name__c, Billing_Account_Number__c, Billing_Name_On_Card__c, Billing_Routing_Number__c, Billing_Last_Name__c, Billing_First_Name__c  FROM AcctSeed__Billing__c WHERE Id IN : recordIds');
    }
    
    global void execute(Database.BatchableContext bc, List<AcctSeed__Billing__c> data){
        
        Map<String, AcctSeed__Billing__c> customerIds = new Map<String, AcctSeed__Billing__c>();//Storing  Customer Ids to get Customer's Cardknox External Ids or cerating customer in Cardknox 
        
        Map<String, Payment_Method__c> uniquePaymentMethodIds = new Map<String, Payment_Method__c>(); //Storing payment methods with unique Ids 
        
        List<AcctSeed__Billing__c> updatedBillings = new List<AcctSeed__Billing__c>();// storing updated Billings
        
        List<AcctSeed__Payment_Processor_Customer__c> newPayProcessorCustomers = new List<AcctSeed__Payment_Processor_Customer__c>(); // new Payment Processor Customer Records
        
        List<Payment_Schedule__c> newPaymentSchedules = new List<Payment_Schedule__c>(); // new Payment Schedule Records
        
        List<Payment_Method__c> newPaymentMethods = new List<Payment_Method__c>(); // new Payment Method Records
        
        try{
            for(AcctSeed__Billing__c bill : data){
                customerIds.put(bill.AcctSeed__Customer__c, bill);
            }
            
            AcctSeed__Payment_Processor__c fiservProcessor = [SELECT Id, Name FROM AcctSeed__Payment_Processor__c WHERE Name='Fiserv' LIMIT 1];
            
            List<Account> customers = [SELECT Id, Name, AccountNumber, AcctSeed__Billing_Contact__c, AcctSeed__Billing_Contact__r.FirstName, AcctSeed__Billing_Contact__r.LastName, AcctSeed__Billing_Contact__r.Email,(SELECT Id, Firm_Contact__r.FirstName, Firm_Contact__r.LastName FROM Policies__r WHERE (Cancel_Date__c = null OR Cancel_Date__c > TODAY ) AND RecordType.Name = 'Policy' order by Expiration_Date__c DESC LIMIT 1),
                                       (SELECT Id, AcctSeed__External_Id__c, AcctSeed__Account__c, AcctSeed__Processor__c FROM AcctSeed__Payment_Processor_Customers1__r WHERE AcctSeed__Processor__c =: fiservProcessor.Id), 
                                       (SELECT Id, Name_On_Card__c, Last_4_Account_Number__c, Expiry_Month__c, Expiry_Year__c, Card_Type__c, Type__c, Card_Holder_Name__c, Masked_Account_Number__c, Routing_Number__c, Account_Type__c FROM Payment_Methods__r WHERE Payment_Processor__c=: fiservProcessor.Id)
                                       FROM Account WHERE Id IN: customerIds.keySet()]; 
            Map<String,Account> accMap = new Map<String,Account>();
            
            
            Map<String, AcctSeed__Payment_Processor_Customer__c> accWithPayProcessorMap = new Map<String, AcctSeed__Payment_Processor_Customer__c>();
            
            
            //getting all Customer's Cardknox ExternalIds
            for(Account acc: customers){
                if(!acc.AcctSeed__Payment_Processor_Customers1__r.isEmpty()){
                    accWithPayProcessorMap.put(acc.Id, acc.AcctSeed__Payment_Processor_Customers1__r[0]);
                }
                
                accMap.put(acc.Id, acc);
                
                if(!acc.Payment_Methods__r.isEmpty()){
                    for(Payment_Method__c obj : acc.Payment_Methods__r){
                        String key = '';
                        if(obj.Type__c == 'Credit_Card'){
                            key = '-'+obj.Last_4_Account_Number__c+'-'+obj.Expiry_Month__c+'-'+obj.Expiry_Year__c+'-'+obj.Card_Type__c;
                        }
                        else{
                            key = '-'+obj.Last_4_Account_Number__c+'-'+(obj.Account_Type__c == 'Saving' ? obj.Account_Type__c+'s' : obj.Account_Type__c);
                        }
                        key = key.toLowerCase();
                        key = acc.Id+key;
                        
                        uniquePaymentMethodIds.put(key, obj);
                    }
                }
            }
            
            //Creating Payment Methods
            for(AcctSeed__Billing__c bill : data){
                String key = '';
                if(bill.Mode_Of_Payment__c == 'Credit Card'){
                    key = '-'+bill.Billing_Card_Number__c.right(4)+'-'+String.valueOf(bill.Billing_Card_Expire_Month__c).leftPad(2, '0')+'-'+bill.Billing_Card_Expire_Year__c+'-'+ bill.Billing_Card_Type__c;
                }
                else{
                    key = '-'+bill.Billing_Account_Number__c.right(4)+'-'+bill.Billing_Account_Type__c;
                }
                key = key.toLowerCase();
                key = bill.AcctSeed__Customer__c+key;
                
                if(!uniquePaymentMethodIds.containsKey(key)){
                    
                    //Create Payment Method
                    
                    PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj = new PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper();
                    warpperObj.billing = bill;
                    warpperObj.accRecord = accMap.get(bill.AcctSeed__Customer__c);
                    warpperObj.paymentTypeVar = bill.Mode_Of_Payment__c == 'Credit Card' ? 'creditCard' : 'check';
                    if(bill.Mode_Of_Payment__c == 'Credit Card'){
                        warpperObj.verificationNumber = bill.Billing_Card_Verification_Number__c;
                        warpperObj.expireMonth = String.valueOf(bill.Billing_Card_Expire_Month__c).leftPad(2, '0');
                        warpperObj.expireYear = String.valueOf(bill.Billing_Card_Expire_Year__c);
                        warpperObj.nameOnCard = bill.Billing_Name_On_Card__c;
                        warpperObj.cardNumber = bill.Billing_Card_Number__c;
                    }else{
                        warpperObj.accountNumber = bill.Billing_Account_Number__c;
                        warpperObj.accountHolderName = bill.Billing_Account_Holder_Name__c;
                        warpperObj.routingNumber = bill.Billing_Routing_Number__c;
                        warpperObj.accountType = bill.Billing_Account_Type__c;
                    }
                    
                    if(accWithPayProcessorMap.containsKey(bill.AcctSeed__Customer__c)){
                        warpperObj.customerToken = accWithPayProcessorMap.get(bill.AcctSeed__Customer__c).AcctSeed__External_Id__c;
                    }
                    
                    string token = Fiserv_Utils.createPaymentMethod(warpperObj);
                    warpperObj.payMethodToken = token;
                    Map<String, Object> payMethodMap;
                    if(String.isNotBlank(warpperObj.customerToken)){
                        payMethodMap = Fiserv_Utils.updateCustomer(warpperObj);
                    }
                    else{
                        payMethodMap = Fiserv_Utils.createCustomer(warpperObj);
                        warpperObj.customerToken = (String)payMethodMap.get('profileid');
                        AcctSeed__Payment_Processor_Customer__c customer = new AcctSeed__Payment_Processor_Customer__c();
                        customer.AcctSeed__External_Id__c = warpperObj.customerToken;
                        customer.AcctSeed__Processor__c = fiservProcessor.Id;
                        customer.AcctSeed__Account__c = bill.AcctSeed__Customer__c;
                        
                        if(payMethodMap!=null){
                            if((string)payMethodMap.get('resptext')=='Profile Saved'){
                                accWithPayProcessorMap.put(bill.AcctSeed__Customer__c, customer);
                                newPayProcessorCustomers.add(customer);
                            }
                        }
                    }
                    
                    if(payMethodMap!=null){
                        if((string)payMethodMap.get('resptext')=='Profile Saved'){
                            Payment_Method__c payMethod = new Payment_Method__c();
                            payMethod.Payment_Processor__c = fiservProcessor.Id;
                            
                            if(warpperObj.billing!= null){
                                payMethod.Account__c = warpperObj.billing.AcctSeed__Customer__c;
                            }
                            else{
                                payMethod.Account__c = warpperObj.policy.Account__c;           
                            }
                            
                            if(warpperObj.paymentTypeVar=='creditCard'){
                                payMethod.Type__c = 'Credit_Card';
                                payMethod.Name_On_Card__c = (String)payMethodMap.get('name');
                                payMethod.Last_4_Account_Number__c = warpperObj.cardNumber.right(4);
                                payMethod.Masked_Account_Number__c = payMethod.Last_4_Account_Number__c.leftPad(warpperObj.cardNumber.length(),'X'); //warpperObj.cardNumber;
                                payMethod.Expiry_Month__c = Integer.valueOf(warpperObj.expireMonth);
                                payMethod.Expiry_Year__c = Integer.valueOf(warpperObj.expireYear);
                                payMethod.Card_Type__c = ((String)payMethodMap.get('accttype')).toLowerCase();
                            }
                            else{
                                payMethod.Type__c = 'eCheck';
                                payMethod.Card_Holder_Name__c = warpperObj.accountHolderName;
                                payMethod.Last_4_Account_Number__c  = warpperObj.accountNumber.right(4);
                                payMethod.Masked_Account_Number__c = payMethod.Last_4_Account_Number__c.leftPad(warpperObj.accountNumber.length(),'X'); //warpperObj.accountNumber;
                                payMethod.Routing_Number__c = 'XXXXXXXXX';
                                
                                if(warpperObj.accountType.equalsIgnoreCase('Checking')){
                                    payMethod.Account_Type__c = 'checking';
                                }else if(warpperObj.accountType.equalsIgnoreCase('Savings')){
                                    payMethod.Account_Type__c = 'saving';
                                }
                            }

                            String paymentToken = (String)payMethodMap.get('profileid') + '/' + (String)payMethodMap.get('acctid');
                            payMethod.Payment_Method_Token__c = paymentToken;
                            payMethod.Token__c = (String)payMethodMap.get('token');
                            
                            newPaymentMethods.add(payMethod);
                            uniquePaymentMethodIds.put(key, payMethod);
                            
                            PaymentGatewayClass.createIntegrationLog(null, warpperObj.policy, warpperObj.billing, 'Processed Successfully', 0, 'Payment Method Created Successfully. Payment Method Token =>'+paymentToken, '', warpperObj.ipAddress);
                            
                        }
                    }               
                }
                
            }
            
            if(!newPayProcessorCustomers.isEmpty()){
                Insert newPayProcessorCustomers;
            }
            if(!newPaymentMethods.isEmpty()){
                Insert newPaymentMethods;
            }
            
            //Creating Payment Schedules
            for(AcctSeed__Billing__c bill : data){
                if(accWithPayProcessorMap.containsKey(bill.AcctSeed__Customer__c)){
                    String key = '';
                    if(bill.Mode_Of_Payment__c == 'Credit Card'){
                        key = '-'+bill.Billing_Card_Number__c.right(4)+'-'+String.valueOf(bill.Billing_Card_Expire_Month__c).leftPad(2, '0')+'-'+bill.Billing_Card_Expire_Year__c+'-'+ bill.Billing_Card_Type__c;
                    }
                    else{
                        key = '-'+bill.Billing_Account_Number__c.right(4)+'-'+bill.Billing_Account_Type__c;
                    }
                    key = key.toLowerCase();
                    key = bill.AcctSeed__Customer__c+key;
                    
                    if(uniquePaymentMethodIds.containsKey(key)){
                        Decimal balance = bill.AcctSeed__Balance__c;
                        Date nextPaymentDate = bill.Next_Payment_Date__c;
                        Decimal amount = bill.Next_Payment_Base_Amount__c;
                        String payMethodId = uniquePaymentMethodIds.get(key).Id;
                        
                        while(balance > 1){
                            Payment_Schedule__c pSch = new Payment_Schedule__c();
                            pSch.Due_Date__c = nextPaymentDate;
                            pSch.Billing__c = bill.id;  
                            pSch.Status__c = 'Unpaid';
                            pSch.Amount__c =  balance > amount ? amount : balance;
                            pSch.Fiserv_Payment_Method__c = payMethodId;
                            
                            if(bill.Mode_Of_Payment__c == 'Credit Card'){
                                pSch.Payment_Schedule_Type__c = 'Credit Card';
                            }
                            else{
                                pSch.Payment_Schedule_Type__c = 'eCheck';
                            }
                            //pSch.Service_Fee_Rate__c = Decimal.valueOf(label.Service_Fee_Rate);
                            pSch.Frequency__c = bill.Payment_Frequency__c;
                            
                            
                            balance = balance - pSch.Amount__c;
                            if(bill.Payment_Frequency__c == 'Monthly'){
                                nextPaymentDate = nextPaymentDate.addMonths(1);
                            }
                            else if(bill.Payment_Frequency__c == 'Quarterly'){
                                nextPaymentDate = nextPaymentDate.addMonths(3);
                            }
                            newPaymentSchedules.add(pSch);
                        }
                        
                        if(balance > 0){
                            newPaymentSchedules[newPaymentSchedules.size()-1].Amount__c += balance;
                            balance = 0;
                        }
                        
                        bill.Payment_Method__c = payMethodId;
                        //bill.Service_Fee__c = Decimal.valueOf(label.Service_Fee_Rate);
                        bill.AcctSeed__Payment_Processor__c = fiservProcessor.Id;
                        bill.Next_Payment_Date_Legacy__c = bill.Next_Payment_Date__c;
                        bill.Next_Payment_Date__c = null;
                        updatedBillings.add(bill);
                    }
                }
            }
            
            if(!newPaymentSchedules.isEmpty()){
                Insert newPaymentSchedules;
            }
            if(!updatedBillings.isEmpty()){
                Update updatedBillings;
            }
        }
        catch(Exception e){
            system.debug('Error => '+e.getMessage()+'\nAt => '+e.getLineNumber());
            if(!newPayProcessorCustomers.isEmpty() && !String.isNotBlank(newPayProcessorCustomers[0].Id)){
                Insert newPayProcessorCustomers;
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}