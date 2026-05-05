global class Batch_MigrateSchedules implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    global Set<String> recordIds {get;set;}
    
    global Batch_MigrateSchedules(Set<String> recIds){
        this.recordIds = recIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        return Database.getQueryLocator('SELECT Id,AcctSeed__Customer__c, Next_Payment_Date__c, Next_Payment_Base_Amount__c, AcctSeed__Balance__c, Payment_Frequency__c, Mode_Of_Payment__c, Billing_Card_Number__c, Billing_Card_Type__c, Billing_Account_Type__c, Billing_Card_Verification_Number__c, Billing_Card_Expire_Month__c, Billing_Card_Expire_Year__c, Billing_Account_Holder_Name__c, Billing_Account_Number__c, Billing_Name_On_Card__c, Billing_Routing_Number__c, Billing_Last_Name__c, Billing_First_Name__c  FROM AcctSeed__Billing__c WHERE Id IN : recordIds');
    }
    
    global void execute(Database.BatchableContext bc, List<AcctSeed__Billing__c> data){
        
        
        
        Map<String, AcctSeed__Billing__c> customerIds = new Map<String, AcctSeed__Billing__c>();//Storing  Customer Ids to get Customer's Cardknox External Ids or cerating customer in Cardknox 
        
        Map<String, AcctSeed__Payment_Method__c> uniquePaymentMethodIds = new Map<String, AcctSeed__Payment_Method__c>(); //Storing payment methods with unique Ids 
        
        List<AcctSeed__Billing__c> updatedBillings = new List<AcctSeed__Billing__c>();// storing updated Billings
        
        List<AcctSeed__Payment_Processor_Customer__c> newPayProcessorCustomers = new List<AcctSeed__Payment_Processor_Customer__c>(); // new Payment Processor Customer Records
        
        List<Payment_Schedule__c> newPaymentSchedules = new List<Payment_Schedule__c>(); // new Payment Schedule Records
        
        List<AcctSeed__Payment_Method__c> newPaymentMethods = new List<AcctSeed__Payment_Method__c>(); // new Payment Method Records
            
        try{
            for(AcctSeed__Billing__c bill : data){
                customerIds.put(bill.AcctSeed__Customer__c, bill);
            }
            
            AcctSeed__Payment_Processor__c cardknoxProcessor = [SELECT Id, Name FROM AcctSeed__Payment_Processor__c WHERE Name='Cardknox' LIMIT 1];
            
            List<Account> customers = [SELECT Id, Name, AccountNumber, AcctSeed__Billing_Contact__c, AcctSeed__Billing_Contact__r.FirstName, AcctSeed__Billing_Contact__r.LastName, AcctSeed__Billing_Contact__r.Email,(SELECT Id, Firm_Contact__r.FirstName, Firm_Contact__r.LastName FROM Policies__r WHERE (Cancel_Date__c = null OR Cancel_Date__c > TODAY ) AND RecordType.Name = 'Policy' order by Expiration_Date__c DESC LIMIT 1),
                                       (SELECT Id, AcctSeed__External_Id__c, AcctSeed__Account__c, AcctSeed__Processor__c FROM AcctSeed__Payment_Processor_Customers1__r WHERE AcctSeed__Processor__c =: cardknoxProcessor.Id), 
                                       (SELECT Id, AcctSeed__External_Id__c, AcctSeed__Payment_Method_Type__c, AcctSeed__Type__c, AcctSeed__Bank_Account_Type__c, AcctSeed__Last_Four_Digits__c, AcctSeed__Expiration_Month__c, AcctSeed__Expiration_Year__c FROM AcctSeed__Payment_Methods__r WHERE AcctSeed__Payment_Processor__c=: cardknoxProcessor.Id)
                                       FROM Account WHERE Id IN: customerIds.keySet()]; 
            
            Map<String, AcctSeed__Payment_Processor_Customer__c> accWithPayProcessorMap = new Map<String, AcctSeed__Payment_Processor_Customer__c>();
            
            
            //getting all Customer's Cardknox ExternalIds
            for(Account acc: customers){
                if(!acc.AcctSeed__Payment_Processor_Customers1__r.isEmpty()){
                    accWithPayProcessorMap.put(acc.Id, acc.AcctSeed__Payment_Processor_Customers1__r[0]);
                }
                else{
                    PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj = new PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper();
                    
                    warpperObj.firstName = customerIds.get(acc.Id).Billing_First_Name__c;
                    warpperObj.lastName = customerIds.get(acc.Id).Billing_Last_Name__c;
                    /*if(acc.AcctSeed__Billing_Contact__c != null){
                        warpperObj.firstName = acc.AcctSeed__Billing_Contact__r.FirstName;
                        warpperObj.lastName = acc.AcctSeed__Billing_Contact__r.LastName;
                    }
                    else if(!acc.Policies__r.isEmpty()){
                        warpperObj.firstName = acc.Policies__r[0].Firm_Contact__r.FirstName;
                        warpperObj.lastName = acc.Policies__r[0].Firm_Contact__r.LastName;
                    }*/
                    
                    warpperObj.accRecord = acc;
                    warpperObj.firmName = acc.Name;
                    warpperObj.emailAddress = acc.AcctSeed__Billing_Contact__r.Email;
                    String customerToken = CardknoxUtil.createCustomer(warpperObj);
                    
                    if(String.isNotBlank(customerToken)){
                        AcctSeed__Payment_Processor_Customer__c payProcessorCustomer = new AcctSeed__Payment_Processor_Customer__c(
                            AcctSeed__External_Id__c = customerToken, 
                            AcctSeed__Account__c = acc.Id, 
                            AcctSeed__Processor__c = cardknoxProcessor.Id);
                        accWithPayProcessorMap.put(acc.Id, payProcessorCustomer);
                        newPayProcessorCustomers.add(payProcessorCustomer);
                    }
                }
                
                if(!acc.AcctSeed__Payment_Methods__r.isEmpty()){
                    for(AcctSeed__Payment_Method__c obj : acc.AcctSeed__Payment_Methods__r){
                        String key = '';
                        if(obj.AcctSeed__Payment_Method_Type__c == 'Credit Card'){
                            key = '-'+obj.AcctSeed__Last_Four_Digits__c+'-'+obj.AcctSeed__Expiration_Month__c+'-'+obj.AcctSeed__Expiration_Year__c+'-'+obj.AcctSeed__Type__c;
                        }
                        else{
                            key = '-'+obj.AcctSeed__Last_Four_Digits__c+'-'+(obj.AcctSeed__Bank_Account_Type__c == 'Saving' ? obj.AcctSeed__Bank_Account_Type__c+'s' : obj.AcctSeed__Bank_Account_Type__c);
                        }
                        key = key.toLowerCase();
                        key = acc.Id+key;
                        
                        uniquePaymentMethodIds.put(key, obj);
                    }
                }
            }
            
            //Creating Payment Methods
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
                    
                    if(!uniquePaymentMethodIds.containsKey(key)){
                        
                        //Create Payment Method
                        
                        PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj = new PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper();
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
                        
                        //warpperObj.ccFeeRate = Decimal.valueOf(label.Service_Fee_Rate);
                        warpperObj.customerToken = accWithPayProcessorMap.get(bill.AcctSeed__Customer__c).AcctSeed__External_Id__c;
                        
                        Map<String, Object> payMethodMap = CardknoxUtil.AuthTransaction(warpperObj);
                        if((string)payMethodMap.get('xResult')=='A'){
                            String paymentToken = CardknoxUtil.CreatePaymentMethod((String)payMethodMap.get('xToken'),(warpperObj.paymentTypeVar == 'creditCard' ? (String)payMethodMap.get('xExp') : ''),warpperObj);
                            
                            if(String.isNotBlank(paymentToken)){
                                AcctSeed__Payment_Method__c payMethod = new AcctSeed__Payment_Method__c();
                                payMethod.AcctSeed__Customer__c = bill.AcctSeed__Customer__c;
                                payMethod.AcctSeed__Payment_Processor__c = cardknoxProcessor.Id;
                                
                                if(warpperObj.paymentTypeVar == 'creditCard'){
                                    payMethod.AcctSeed__Payment_Method_Type__c = 'Credit Card';
                                    payMethod.Name_On_Card__c = (String)payMethodMap.get('xName');
                                    payMethod.AcctSeed__Account_Number__c = (String)payMethodMap.get('xMaskedCardNumber');
                                    payMethod.AcctSeed__Last_Four_Digits__c = ((String)payMethodMap.get('xMaskedCardNumber')).right(4);
                                    payMethod.AcctSeed__Expiration_Month__c = ((string)payMethodMap.get('xExp')).substring(0,2);
                                    payMethod.AcctSeed__Expiration_Year__c = '20'+(((string)payMethodMap.get('xExp')).substring(2,4));
                                    payMethod.AcctSeed__Type__c = ((String)payMethodMap.get('xCardType')).toLowerCase();
                                }
                                else{
                                    payMethod.AcctSeed__Payment_Method_Type__c = 'Bank Account';
                                    payMethod.AcctSeed__Card_Holder_Name__c = (String)payMethodMap.get('xName');
                                    payMethod.AcctSeed__Account_Number__c = (String)payMethodMap.get('xMaskedAccountNumber');
                                    payMethod.AcctSeed__Last_Four_Digits__c = ((String)payMethodMap.get('xMaskedAccountNumber')).right(4);
                                    payMethod.AcctSeed__Routing_Number__c = 'XXXXXXXXX';
                                    
                                    if(warpperObj.accountType.equalsIgnoreCase('Checking')){
                                        payMethod.AcctSeed__Bank_Account_Type__c = 'checking';
                                    }else if(warpperObj.accountType.equalsIgnoreCase('Savings')){
                                        payMethod.AcctSeed__Bank_Account_Type__c = 'saving';
                                    }
                                }
                                payMethod.AcctSeed__External_Id__c = paymentToken;
                                
                                uniquePaymentMethodIds.put(key, payMethod);
                                newPaymentMethods.add(payMethod);
                            }
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
                            pSch.Payment_Method__c = payMethodId;
                            
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
                        
                        bill.Cardknox_Payment_Method__c = payMethodId;
                        //bill.Cardknox_Service_Fee__c = Decimal.valueOf(label.Service_Fee_Rate);
                        bill.AcctSeed__Payment_Processor__c = cardknoxProcessor.Id;
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
            system.debug('Error => '+e.getMessage());
            if(!newPayProcessorCustomers.isEmpty() && !String.isNotBlank(newPayProcessorCustomers[0].Id)){
                Insert newPayProcessorCustomers;
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}