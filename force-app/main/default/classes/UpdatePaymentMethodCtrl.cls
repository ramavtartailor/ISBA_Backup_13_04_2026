public class UpdatePaymentMethodCtrl {
    
    public class UpdatePaymentMethodCtrlException extends Exception{}
    
    @AuraEnabled
    Public Static wrapper getDetails(String recId){
        try{   
            wrapper wrap = new wrapper();
            AcctSeed__Billing__c bill = [SELECT Id, Payment_Method__c, AcctSeed__Customer__c FROM AcctSeed__Billing__c WHERE Id =: recId];
            List<Payment_Method__c> paymentMethodList = [SELECT Id, Name, Payment_Method_Token__c, Account_Type__c, Type__c, Card_Type__c, Last_4_Account_Number__c, CreatedBy.Name, CreatedDate, Default__c FROM Payment_Method__c WHERE Account__c =: bill.AcctSeed__Customer__c AND Payment_Processor__r.Name = 'Fiserv' AND Is_Deleted__c = false];
            wrap.selectedId = bill.Payment_Method__c;
            wrap.payMethodList = paymentMethodList;
            wrap.customerId = bill.AcctSeed__Customer__c;
            return wrap;
        }catch(Exception e){
            system.debug('Error => '+ e.getMessage()+' At => '+ e.getLineNumber());
            throw new UpdatePaymentMethodCtrlException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public Static Boolean UpdatePaymentSchedule(String recId, String selectedId){
        try{
            List<Payment_Schedule__c> paymentSchedules = New List<Payment_Schedule__c>();
            AcctSeed__Billing__c bill = [SELECT Id, Payment_Method__c,Service_Fee__c,AcctSeed__Payment_Processor__r.Name, Cardknox_Service_Fee__c, (SELECT Id,Service_Fee_Rate__c FROM Payment_Schedules__r WHERE Status__c IN ('Unpaid','Rejected')) FROM AcctSeed__Billing__c WHERE Id =: recId];
            AcctSeed__Payment_Processor__c paymentProcessor = [SELECT Id, Name FROM AcctSeed__Payment_Processor__c WHERE Name='Fiserv' LIMIT 1];
            bill.Payment_Method__c = selectedId;
            if(bill.AcctSeed__Payment_Processor__r.Name == 'CardKnox'){
                bill.Service_Fee__c = bill.Cardknox_Service_Fee__c != null ? bill.Cardknox_Service_Fee__c : 0;
            }
            else if(bill.AcctSeed__Payment_Processor__r.Name == 'Forte'){
                bill.Service_Fee__c = 0;
            }
            
            if(bill.Service_Fee__c == null && bill.Cardknox_Service_Fee__c != null){
                bill.Service_Fee__c = bill.Cardknox_Service_Fee__c;
            }
            else if(bill.Service_Fee__c == null){
                bill.Service_Fee__c = Decimal.valueOf(label.Service_Fee_Rate); 
            }
            
            
            bill.AcctSeed__Payment_Processor__c = paymentProcessor.Id;
            
            Payment_Method__c pm =  [SELECT Id, Type__c FROM Payment_Method__c WHERE Id =: selectedId];
            
            for(Payment_Schedule__c ps: bill.Payment_Schedules__r){
                ps.Fiserv_Payment_Method__c = selectedId;
                if(pm.Type__c == 'eCheck'){
                    ps.Payment_Schedule_Type__c = 'eCheck';
                    ps.Service_Fee_Rate__c = 0;
                }
                else{
                    ps.Payment_Schedule_Type__c = 'Credit Card';
                    if(ps.Service_Fee_Rate__c == null){
                        ps.Service_Fee_Rate__c = Decimal.valueOf(label.Service_Fee_Rate); 
                    }
                }
                paymentSchedules.add(ps);
            }
            
            Update bill;
            
            if(!paymentSchedules.isEmpty()){
                Update paymentSchedules;
            }
            return true;
        }
        Catch(Exception e){
            system.debug('Error => '+ e.getMessage()+' At => '+ e.getLineNumber());
            throw new UpdatePaymentMethodCtrlException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string savePaymentMethod(String jsonBody,String recId){
        try{
            AcctSeed__Billing__c bill = [SELECT Id,AcctSeed__Customer__c,AcctSeed__Customer__r.Name,AcctSeed__Customer__r.AccountNumber  FROM AcctSeed__Billing__c WHERE Id=:recId LIMIT 1];
            AcctSeed__Payment_Processor__c paymentProcessor = [SELECT Id, Name FROM AcctSeed__Payment_Processor__c WHERE Name='Fiserv' LIMIT 1];
            List<AcctSeed__Payment_Processor_Customer__c> customerProcessors = [SELECT Id, AcctSeed__External_Id__c, AcctSeed__Account__c, AcctSeed__Processor__c FROM AcctSeed__Payment_Processor_Customer__c WHERE AcctSeed__Account__c =: bill.AcctSeed__Customer__c AND AcctSeed__Processor__c =: paymentProcessor.Id limit 1];
            
            Map<String,Object> jsonDataMap = new Map<String,Object>();
            jsonDataMap = (Map<String,Object>) System.JSON.deserializeUntyped(jsonBody);
            
            
            PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj = new PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper();
            
            
            warpperObj.paymentTypeVar = String.valueOf(jsonDataMap.get('paymentTypeVar')) == 'Credit Card' ? 'creditCard' : 'check';
            warpperObj.accRecord = bill.AcctSeed__Customer__r;
            if(warpperObj.paymentTypeVar == 'creditCard'){
                Map<String,Object> creditCardPayMethodMap;// = new Map<String,Object>();
                warpperObj.expireMonth = String.valueOf(jsonDataMap.get('expireMonth'));
                warpperObj.expireYear = String.valueOf(jsonDataMap.get('expireYear'));
                warpperObj.nameOnCard = String.valueOf(jsonDataMap.get('nameOnCard'));
                warpperObj.cardNumber = String.valueOf(jsonDataMap.get('cardNumber'));
                warpperObj.payMethodToken = String.valueOf(jsonDataMap.get('token'));
                
                if(customerProcessors.isEmpty() || !String.isNotBlank(customerProcessors[0].AcctSeed__External_Id__c)){
                    creditCardPayMethodMap = Fiserv_Utils.createCustomer(warpperObj);
                    warpperObj.customerToken = (String)creditCardPayMethodMap.get('profileid');
                    List<AcctSeed__Payment_Processor_Customer__c> custList = new List<AcctSeed__Payment_Processor_Customer__c>();
                    
                    AcctSeed__Payment_Processor_Customer__c customer = new AcctSeed__Payment_Processor_Customer__c();
                    customer.AcctSeed__External_Id__c = warpperObj.customerToken;
                    customer.AcctSeed__Processor__c = paymentProcessor.id;
                    customer.AcctSeed__Account__c = bill.AcctSeed__Customer__c;
                    custList.add(customer);
                    insert custList;
                }
                else{
                    warpperObj.customerToken = customerProcessors[0].AcctSeed__External_Id__c;
                    creditCardPayMethodMap = Fiserv_Utils.updateCustomer(warpperObj);
                }
                
                
                if(creditCardPayMethodMap!=null){
                    system.debug('resptext => '+creditCardPayMethodMap.get('resptext'));
                    if((string)creditCardPayMethodMap.get('resptext')=='Profile Saved'){
                        List<Payment_Method__c> payMethodList = new List<Payment_Method__c>();
                        Payment_Method__c payMethod = new Payment_Method__c();
                        payMethod.Account__c = bill.AcctSeed__Customer__c;
                        payMethod.Payment_Processor__c = paymentProcessor.Id;
                        payMethod.Type__c = 'Credit_Card';
                        payMethod.Name_On_Card__c = (String)creditCardPayMethodMap.get('name');
                        payMethod.Last_4_Account_Number__c = warpperObj.cardNumber.right(4);
                        payMethod.Masked_Account_Number__c = payMethod.Last_4_Account_Number__c.leftPad(warpperObj.cardNumber.length(),'X'); //warpperObj.cardNumber;
                        payMethod.Expiry_Month__c = Integer.valueOf(warpperObj.expireMonth);
                        payMethod.Expiry_Year__c = Integer.valueOf(warpperObj.expireYear);
                        payMethod.Card_Type__c = ((String)creditCardPayMethodMap.get('accttype')).toLowerCase();
                        
                        
                        String paymentToken =(String)creditCardPayMethodMap.get('profileid') + '/' + (String)creditCardPayMethodMap.get('acctid');
                        system.debug('paymentToken ===> '+paymentToken);
                        payMethod.Payment_Method_Token__c = paymentToken;
                        payMethod.Token__c = (String)creditCardPayMethodMap.get('token');
                        
                        for(Payment_Method__c paymentMethod : [SELECT Id,Default__c,Payment_Method_Token__c FROM Payment_Method__c WHERE Account__c =:payMethod.Account__c AND Is_Deleted__c = false AND Payment_Method_Token__c =: paymentToken]){
                            if(paymentMethod.Payment_Method_Token__c == paymentToken){
                                payMethod.Id = paymentMethod.Id;
                            }
                        }
                        payMethodList.add(payMethod);
                        Upsert payMethodList;
                        return payMethod.Id;
                    }
                    else{
                        throw new UpdatePaymentMethodCtrlException((string)creditCardPayMethodMap.get('xError'));
                    }
                    
                }
                
            }else{
                warpperObj.accountNumber = String.valueOf(jsonDataMap.get('accountNumber'));
                warpperObj.accountHolderName = String.valueOf(jsonDataMap.get('accountHolderName'));
                warpperObj.routingNumber = String.valueOf(jsonDataMap.get('routingNumber'));
                warpperObj.accountType = String.valueOf(jsonDataMap.get('accountType'));
                string token = Fiserv_Utils.createPaymentMethod(warpperObj);
                warpperObj.payMethodToken = token;
                Map<String, Object> echeckPayMethodMap;
                if(customerProcessors.isEmpty() || !String.isNotBlank(customerProcessors[0].AcctSeed__External_Id__c)){
                    echeckPayMethodMap = Fiserv_Utils.createCustomer(warpperObj);
                    warpperObj.customerToken = (String)echeckPayMethodMap.get('profileid');
                    List<AcctSeed__Payment_Processor_Customer__c> custList = new List<AcctSeed__Payment_Processor_Customer__c>();
                    
                    AcctSeed__Payment_Processor_Customer__c customer = new AcctSeed__Payment_Processor_Customer__c();
                    customer.AcctSeed__External_Id__c = warpperObj.customerToken;
                    customer.AcctSeed__Processor__c = paymentProcessor.id;
                    customer.AcctSeed__Account__c = bill.AcctSeed__Customer__c;
                    custList.add(customer);
                    insert custList;
                }
                else{
                    warpperObj.customerToken = customerProcessors[0].AcctSeed__External_Id__c;
                    echeckPayMethodMap = Fiserv_Utils.updateCustomer(warpperObj);
                }
                if(echeckPayMethodMap!=null){
                    if((string)echeckPayMethodMap.get('resptext')=='Profile Saved'){
                        List<Payment_Method__c> payMethodList = new List<Payment_Method__c>();
                        Payment_Method__c payMethod = new Payment_Method__c();
                        payMethod.Account__c = bill.AcctSeed__Customer__c;
                        payMethod.Payment_Processor__c = paymentProcessor.Id;
                        payMethod.Type__c = 'eCheck';
                        payMethod.Card_Holder_Name__c = warpperObj.accountHolderName;
                        payMethod.Last_4_Account_Number__c = warpperObj.accountNumber.right(4);
                        payMethod.Masked_Account_Number__c = payMethod.Last_4_Account_Number__c.leftPad(warpperObj.accountNumber.length(),'X'); //warpperObj.accountNumber;
                        payMethod.Routing_Number__c = 'XXXXXXXXX';
                        
                        if(warpperObj.accountType.equalsIgnoreCase('Checking')){
                            payMethod.Account_Type__c = 'checking';
                        }else if(warpperObj.accountType.equalsIgnoreCase('Savings')){
                            payMethod.Account_Type__c = 'saving';
                        }
                        String paymentToken = (String)echeckPayMethodMap.get('profileid') + '/' + (String)echeckPayMethodMap.get('acctid');
                        payMethod.Payment_Method_Token__c = paymentToken;
                        payMethod.Token__c = (String)echeckPayMethodMap.get('token');
                        
                        for(Payment_Method__c paymentMethod : [SELECT Id,Default__c,Payment_Method_Token__c FROM Payment_Method__c WHERE Account__c =:payMethod.Account__c AND Is_Deleted__c = false AND Payment_Method_Token__c =: paymentToken]){
                            if(paymentMethod.Payment_Method_Token__c == paymentToken){
                                payMethod.Id = paymentMethod.Id;
                            }
                        }
                        payMethodList.add(payMethod);
                        Upsert payMethodList;
                        
                        return payMethod.Id;
                    }
                    else{
                        throw new UpdatePaymentMethodCtrlException((string)echeckPayMethodMap.get('xError'));
                    }
                    
                }
            }
            return null;
        }
        catch(DMLException e){
            system.debug('DML Error => '+ e.getDmlMessage(0)+' At => '+ e.getLineNumber());
            throw new UpdatePaymentMethodCtrlException(e.getDmlMessage(0));
        }
        Catch(Exception e){
            system.debug('Error => '+ e.getMessage()+' At => '+ e.getLineNumber());
            throw new UpdatePaymentMethodCtrlException(e.getMessage());
        }
    }
	
    @AuraEnabled 
    public Static boolean deletePaymentMethod(String payMethodId,String recId){
        try{
            Payment_Method__c payMethd = [SELECT Id, Name,Payment_Method_Token__c FROM Payment_Method__c WHERE Payment_Method_Token__c =: payMethodId LIMIT 1];
            String paymentMethodToken = payMethd.Payment_Method_Token__c;
            
            String resp = Fiserv_Utils.DeletePaymentMethod(paymentMethodToken);
            
            if(String.isNotBlank(resp) && resp == 'Success'){
                Delete payMethd;
            } 
            else{
                throw new UpdatePaymentMethodCtrlException(resp);
            }
            return true;
        }
        catch(DMLException e){
            system.debug('DML Error => '+ e.getDmlMessage(0)+' At => '+ e.getLineNumber());
            throw new UpdatePaymentMethodCtrlException(e.getDmlMessage(0));
        }
        Catch(Exception e){
            system.debug('Error => '+ e.getMessage()+' At => '+ e.getLineNumber());
            throw new UpdatePaymentMethodCtrlException(e.getMessage());
        }
    }    
    
    public class wrapper{
        @AuraEnabled public String customerId{get;set;}
        @AuraEnabled public String selectedId{get;set;}
        @AuraEnabled public List<Payment_Method__c> payMethodList{get;set;}
    }
}