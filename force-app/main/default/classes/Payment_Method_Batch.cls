global with sharing class Payment_Method_Batch Implements Database.Batchable<SObject> , Database.Stateful, Database.AllowsCallouts{
    global List<Database.SaveResult> Results = new List<Database.SaveResult>();
    public static Map<String,String> PayMethError = new Map<String,String>();
    global Map<String,String> PayMethErrorResult = new Map<String,String>();
    public static boolean runningInASandbox;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        //String month = String.valueOf(Date.Today().Month());
        //String yr = String.valueOf(Date.Today().Year());
        //list<AcctSeed__Payment_Method__c> pmList = [select id,AcctSeed__Payment_Method_Type__c from AcctSeed__Payment_Method__c where AcctSeed__Payment_Method_Type__c='Bank Account' or (AcctSeed__Expiration_Year__c = :yr and AcctSeed__Expiration_Month__c >= :month) or  AcctSeed__Expiration_Year__c > :yr]; 
        //system.debug('pmList -> '+pmList);
        //String query = 'SELECT Id, Name, Forte_ID__c, (SELECT Id, AcctSeed__Payment_Method_Type__c, Name_on_Card__c, AcctSeed__Type__c, Credit_Card_Number__c, AcctSeed__Expiration_Month__c, AcctSeed__Expiration_Year__c, Card_Verification_Number__c, AcctSeed__Card_Holder_Name__c, Account_Number__c, AcctSeed__Routing_Number__c, AcctSeed__Bank_Account_Type__c FROM AcctSeed__Payment_Methods__r where AcctSeed__Payment_Method_Type__c=\'Bank Account\' or (AcctSeed__Expiration_Year__c = :yr and AcctSeed__Expiration_Month__c >= :month) or  AcctSeed__Expiration_Year__c > :yr order by AcctSeed__Expiration_Year__c) FROM Account where (Forte_ID__c=\'\' or Forte_ID__c=null)';
        String query = 'SELECT Id, Name, Forte_ID__c FROM Account where (Forte_ID__c=\'\' or Forte_ID__c=null )';
        //and Billing_Card_Expire_Year__c>='+year+' and Billing_Card_Expire_Month__c >'+month+'
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> accList) {
        try{
            Set<ID> accIds = new Set<Id>();
            for(Account acc : accList){
                accIds.add(acc.Id);
            }
            //Integer year = Date.Today().Year();
            //Integer month = Date.Today().Month();
            accList = [SELECT Id,  Name, Forte_ID__c, (Select AcctSeed__Customer__c,Billing_Card_Number__c,Billing_Card_Type__c,Billing_Routing_Number__c,Mode_Of_Payment__c,Billing_Account_Number__c,Billing_Card_Expire_Year__c,Billing_Card_Expire_Month__c, Billing_Name_On_Card__c, Billing_Account_Holder_Name__c,Billing_Card_Verification_Number__c,Billing_Account_Type__c from AcctSeed__Billings__r where Mode_Of_Payment__c!='' and Mode_Of_Payment__c!=null and IsPaymentProcessed__c = true )  from Account where Id In :accIds ];
            //and Billing_Card_Expire_Year__c>=:year and Billing_Card_Expire_Month__c >:month 
            List<Account> accToUpdate = new List<Account>();
            List<Payment_Method__c> payMethodList = new List<Payment_Method__c>();
            for(Account acc : accList){
                system.debug('acc -> '+acc);
                if(acc.AcctSeed__Billings__r.size()>0){
                    String customerToken ='';
                    Map<String,AcctSeed__Billing__c> cardNumberWithBillingMap = new Map<String,AcctSeed__Billing__c>();
                    Map<String,AcctSeed__Billing__c> AccountNumberWithBillingMap = new Map<String,AcctSeed__Billing__c>();
                    
                    if(acc.AcctSeed__Billings__r.size()>0){
                        customerToken = createCustomerInDex(acc);
                        acc.Forte_ID__c = customerToken;
                        accToUpdate.add(acc);
                    }
                    for(AcctSeed__Billing__c acctBill : acc.AcctSeed__Billings__r){
                        if(acctBill.Mode_Of_Payment__c == 'Credit Card' && !String.isEmpty(acctBill.Billing_Card_Number__c) && !String.isEmpty(String.valueOf(acctBill.Billing_Card_Expire_Year__c)) && !String.isEmpty(String.valueOf(acctBill.Billing_Card_Expire_Month__c)) && !cardNumberWithBillingMap.containsKey(acctBill.Billing_Card_Number__c)){
                            cardNumberWithBillingMap.put(acctBill.Billing_Card_Number__c,acctBill);
                        }
                        if(acctBill.Mode_Of_Payment__c == 'eCheck/ACH' && !String.isEmpty(acctBill.Billing_Account_Number__c) && !String.isEmpty(acctBill.Billing_Routing_Number__c) && !AccountNumberWithBillingMap.containsKey(acctBill.Billing_Account_Number__c)){
                            AccountNumberWithBillingMap.put(acctBill.Billing_Account_Number__c,acctBill);
                        }
                        
                    }
                    for(AcctSeed__Billing__c acctPayMeth : cardNumberWithBillingMap.values()){
                        Integer month = Date.Today().Month();
                        Integer yr = Date.Today().Year();
                        Integer pmExpiryMonth = Integer.valueOf(acctPayMeth.Billing_Card_Expire_Month__c);
                        Integer pmExpiryYr = integer.valueOf(acctPayMeth.Billing_Card_Expire_Year__c);
                        If((pmExpiryYr == yr && pmExpiryMonth >= month) || pmExpiryYr > yr){
                            Map<String, Object> creditCardPayMethodMap = createCustomerCreditCardPaymethod(acctPayMeth, customerToken);
                            if(creditCardPayMethodMap != null){
                                Payment_Method__c payMethod = new Payment_Method__c();
                                payMethod.Payment_Method_Token__c = (String)creditCardPayMethodMap.get('paymethod_token');
                                payMethod.Account__c = acc.id;
                                payMethod.Type__c = 'Credit_Card';
                                Map<string,object> cardMap = (Map<string,object>)creditCardPayMethodMap.get('card');
                                payMethod.Name_On_Card__c = (String)cardMap.get('name_on_card');
                                payMethod.Masked_Account_Number__c = (String)cardMap.get('masked_account_number');
                                payMethod.Expiry_Month__c = (Decimal)cardMap.get('expire_month');
                                payMethod.Expiry_Year__c = (Decimal)cardMap.get('expire_year');
                                payMethod.Card_Type__c = (String)cardMap.get('card_type');
                                payMethodList.add(payMethod);  
                            }
                        }
                    }
                    for(AcctSeed__Billing__c acctPayMeth : AccountNumberWithBillingMap.values()){
                        Map<String, Object> echeckPayMethodMap = createCustomerECheckPaymethod(acctPayMeth, customerToken);
                        if(echeckPayMethodMap != null){
                            Payment_Method__c payMethod = new Payment_Method__c();   
                            payMethod.Payment_Method_Token__c = (String)echeckPayMethodMap.get('paymethod_token');
                            payMethod.Account__c = acc.id;
                            payMethod.Type__c = 'eCheck';
                            Map<string,object> cardMap = (Map<string,object>)echeckPayMethodMap.get('echeck');
                            payMethod.Card_Holder_Name__c = (String)cardMap.get('account_holder');
                            payMethod.Masked_Account_Number__c = (String)cardMap.get('masked_account_number');
                            payMethod.Routing_Number__c = (string)cardMap.get('routing_number');
                            if(((string)cardMap.get('account_type')).equalsIgnoreCase('Checking')){
                                payMethod.Account_Type__c = 'checking';
                            }else if(((string)cardMap.get('account_type')).equalsIgnoreCase('Savings')){
                                payMethod.Account_Type__c = 'savings';
                            }
                            payMethodList.add(payMethod);
                        }
                    }
                }
                
                
            }
            system.debug('accToUpdate '+accToUpdate);
            if(!accToUpdate.isEmpty()){
                List<Database.SaveResult> result = Database.update(accToUpdate, false);
                system.debug('accToUpdate result '+result);
            }
            system.debug('payMethodList '+payMethodList);
            if(!accToUpdate.isEmpty()){
                List<Database.SaveResult> result = Database.insert(payMethodList, false);
                system.debug('payMethodList result '+result);
            }
            PayMethErrorResult = PayMethError;
        }catch(Exception e){
            system.debug('Error -> '+e.getMessage()+' Line No. -> '+e.getLineNumber());
        }
    }
    
    public static String createCustomerInDex(Account acc){
        String baseURI = Label.Forte_API_Base_URL_Sandbox;
        String organizationID = Label.Forte_API_Organization_Id_Sandbox;
        String locationID = Label.Forte_API_Location_Id_Sandbox;
        String AccessId = Label.Forte_API_Access_Id_Sandbox;
        String AccessKey = Label.Forte_API_Secure_Key_Sandbox;
        if(runningInASandbox == null){
            runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        }
        HttpRequest req = new HttpRequest();
        if(runningInASandbox){
            baseURI = Label.Forte_API_Base_URL_Sandbox;
            organizationID = Label.Forte_API_Organization_Id_Sandbox;
            locationID = Label.Forte_API_Location_Id_Sandbox;
            AccessId = Label.Forte_API_Access_Id_Sandbox;
            AccessKey = Label.Forte_API_Secure_Key_Sandbox;            
        }else{
            baseURI = Label.Forte_API_Base_URL;
            organizationID = Label.Forte_API_Organization_Id;
            locationID = Label.Forte_API_Location_Id;
            AccessId = Label.Forte_API_Access_Id;
            AccessKey = Label.Forte_API_Secure_Key;
        }
        string endPoint = baseURI+'/organizations/'+organizationID+'/locations/'+locationID+'/customers/';
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('X-Forte-Auth-Organization-Id', organizationID);
        req.setHeader('Accept', 'application/json');
        String header = 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(AccessId+':'+AccessKey));
        req.setHeader('Authorization', header);
        req.setBody( '{"first_name": "'+ acc.Name +'", "customer_id": "'+ acc.Id +'"}');
        
        HTTP http = new HTTP();
        HTTPResponse Response = new HTTPResponse();
        req.setTimeout(120000);
        if(!Test.isRunningTest()){
            Response = http.send(req);
        }else{
            Response.setBody('{"customer_token": "cst_test"}');
            Response.setStatusCode(201);
        }
        
        system.debug(Response.getStatusCode());
        if(response.getStatusCode() == 201){
            Map<String, Object> customerMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            system.debug('customerMap -> '+customerMap);
            system.debug('customer_token -> '+customerMap.get('customer_token'));
            return (string)customerMap.get('customer_token');
        }
        return null;
    }	
    
    public static Map<String, Object> createCustomerCreditCardPaymethod(AcctSeed__Billing__c payMeth, String customerToken){
        String baseURI = Label.Forte_API_Base_URL_Sandbox;
        String organizationID = Label.Forte_API_Organization_Id_Sandbox;
        String locationID = Label.Forte_API_Location_Id_Sandbox;
        String AccessId = Label.Forte_API_Access_Id_Sandbox;
        String AccessKey = Label.Forte_API_Secure_Key_Sandbox;
        if(runningInASandbox == null){
            runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        }
        
        HttpRequest req = new HttpRequest();
        if(runningInASandbox){
            baseURI = Label.Forte_API_Base_URL_Sandbox;
            organizationID = Label.Forte_API_Organization_Id_Sandbox;
            locationID = Label.Forte_API_Location_Id_Sandbox;
            AccessId = Label.Forte_API_Access_Id_Sandbox;
            AccessKey = Label.Forte_API_Secure_Key_Sandbox;            
        }else{
            baseURI = Label.Forte_API_Base_URL;
            organizationID = Label.Forte_API_Organization_Id;
            locationID = Label.Forte_API_Location_Id;
            AccessId = Label.Forte_API_Access_Id;
            AccessKey = Label.Forte_API_Secure_Key;
        }
        string endPoint = baseURI+'/organizations/'+organizationID+'/locations/'+locationID+'/customers/'+customerToken+'/paymethods';
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('X-Forte-Auth-Organization-Id', organizationID);
        req.setHeader('Accept', 'application/json');
        String header = 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(AccessId+':'+AccessKey));
        req.setHeader('Authorization', header);
        req.setBody( '{"card": {"name_on_card":"'+payMeth.Billing_Name_On_Card__c+'","card_type":"'+payMeth.Billing_Card_Type__c+'","account_number":"'+payMeth.Billing_Card_Number__c+'","expire_month":'+payMeth.Billing_Card_Expire_Month__c+',"expire_year":'+payMeth.Billing_Card_Expire_Year__c+',"card_verification_value": "'+payMeth.Billing_Card_Verification_Number__c+'"}}');
        //system.debug('body -> '+req.getBody());
        HTTP http = new HTTP();
        HTTPResponse Response = new HTTPResponse();
        req.setTimeout(120000);
        
        if(!Test.isRunningTest()){
            Response = http.send(req);
        }else{
            Response.setBody('{"paymethod_token": "mth_-test","card": {"name_on_card": "test","last_4_account_number": "1111","masked_account_number": "****1111","expire_month": 9,"expire_year": 2023,"card_type": "visa"}}');
            Response.setStatusCode(201);
        }
        
        system.debug(Response.getStatusCode());
        Map<String, Object> creditCardPayMethodMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        if(response.getStatusCode() == 201){
            system.debug('creditCardPayMethodMap -> '+creditCardPayMethodMap);
            return creditCardPayMethodMap;
        }
        
        Map<string,object> resMap = (Map<string,object>)creditCardPayMethodMap.get('response');
        PayMethError.put(payMeth.id, (String) resMap.get('response_desc'));
        return null;
    }
    
    
    public static Map<String, Object> createCustomerECheckPaymethod(AcctSeed__Billing__c payMeth, String customerToken){
        String baseURI = Label.Forte_API_Base_URL_Sandbox;
        String organizationID = Label.Forte_API_Organization_Id_Sandbox;
        String locationID = Label.Forte_API_Location_Id_Sandbox;
        String AccessId = Label.Forte_API_Access_Id_Sandbox;
        String AccessKey = Label.Forte_API_Secure_Key_Sandbox;
        if(runningInASandbox == null){
            runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        }
        HttpRequest req = new HttpRequest();
        if(runningInASandbox){
            baseURI = Label.Forte_API_Base_URL_Sandbox;
            organizationID = Label.Forte_API_Organization_Id_Sandbox;
            locationID = Label.Forte_API_Location_Id_Sandbox;
            AccessId = Label.Forte_API_Access_Id_Sandbox;
            AccessKey = Label.Forte_API_Secure_Key_Sandbox;            
        }else{
            baseURI = Label.Forte_API_Base_URL;
            organizationID = Label.Forte_API_Organization_Id;
            locationID = Label.Forte_API_Location_Id;
            AccessId = Label.Forte_API_Access_Id;
            AccessKey = Label.Forte_API_Secure_Key;
        }
        string endPoint = baseURI+'/organizations/'+organizationID+'/locations/'+locationID+'/customers/'+customerToken+'/paymethods';
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('X-Forte-Auth-Organization-Id', organizationID);
        req.setHeader('Accept', 'application/json');
        String header = 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(AccessId+':'+AccessKey));
        req.setHeader('Authorization', header);
        req.setBody( '{"echeck": {"account_holder": "'+payMeth.Billing_Account_Holder_Name__c+'","account_number":"'+payMeth.Billing_Account_Number__c+'","routing_number":"'+payMeth.Billing_Routing_Number__c+'","account_type":"'+payMeth.Billing_Account_Type__c+'"}}');
        //system.debug('body -> '+req.getBody());
        HTTP http = new HTTP();
        HTTPResponse Response = new HTTPResponse();
        req.setTimeout(120000);
        
        if(!Test.isRunningTest()){
            Response = http.send(req);
        }else{
            Response.setBody('{"paymethod_token": "mth_-test","echeck":{"account_holder": "Emmett Brown","masked_account_number": "****1111","last_4_account_number": "1111","routing_number": "021000021","account_type": "checking"}}');
            Response.setStatusCode(201);
        }
        
        system.debug(Response.getStatusCode());
        Map<String, Object> echeckPayMethodMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        if(response.getStatusCode() == 201){     
            system.debug('echeckPayMethodMap -> '+echeckPayMethodMap);
            return echeckPayMethodMap;
        }
        
        Map<string,object> resMap = (Map<string,object>)echeckPayMethodMap.get('response');
        PayMethError.put(payMeth.id, (String) resMap.get('response_desc'));
        return null;
    }
    
    global void finish(Database.BatchableContext bc){
        AsyncApexJob a = [Select Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String orgWideEmailAddressId = [select Id,Address from OrgWideEmailAddress where Address = 'underwriting@isbamutual.com'].Id;
		mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        String[] toAddresses = new String[] {'palak@cmentor.com'};
            mail.setToAddresses(toAddresses);
        mail.setSubject('ISBA Payment Method Batch Results ' + a.Status);
        mail.setPlainTextBody('PM failed => '+PayMethErrorResult);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}