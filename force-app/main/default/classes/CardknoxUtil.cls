public without sharing class CardknoxUtil {
    
    public Static Cardknox_Creds__c creds;
    public Static Boolean runningInASandbox;
    public Static String baseURL;
    public Static String xKey;
    public Static String transactionUrl;
    

    public static void setCreds(){
        creds = Cardknox_Creds__c.getOrgDefaults();
        if(runningInASandbox == null){
            runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        }
        
        if(runningInASandbox){
            baseURL = creds.SB_Base_URL__c;
            xKey = creds.SB_xKey__c;
            transactionUrl = creds.SB_Transaction_URL__c;
        }
        else{
            baseURL = creds.Base_URL__c;
            xKey = creds.xKey__c;
            transactionUrl = creds.Transaction_URL__c;
        }
    }   
    public static String createCustomer(PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj){   
        if(creds == null)
            setCreds();
        
        system.debug('creds -> '+creds);
        HttpRequest http = new HttpRequest();
        http.setEndpoint(baseURL+'/CreateCustomer');
        http.setMethod('POST');
        http.setHeader('Content-Type', 'application/json');
        http.setHeader('X-Recurring-Api-Version', '2.1');
        http.setHeader('Authorization', xKey);
        string customerId = '';
        String accountNumber = '';
        if(warpperObj.accRecord != null){
            customerId = warpperObj.accRecord.Id;
            accountNumber = warpperObj.accRecord.AccountNumber;
        }else{
            customerId = warpperObj.billing.AcctSeed__Customer__c;
            accountNumber = warpperObj.billing.AcctSeed__Customer__r.AccountNumber;
        }
        String body = '{'+
            '"SoftwareName" : "'+creds.Software_Name__c+'",'+
            '"SoftwareVersion" : "'+creds.Software_Version__c+'",'+
            '"BillFirstName" : "'+warpperObj.firstName+'",'+
            '"BillLastName" : "'+warpperObj.lastName+'",'+
            '"Email" : "'+warpperObj.emailAddress+'",'+
            '"CustomerCustom02" : "'+customerId+'",'+
            '"CustomerNumber" : "'+accountNumber+'",'+
            '"BillCompany" : "'+warpperObj.firmName+'"'+
            '}';
        system.debug('createCustomer body -> '+body);
        
        http.setBody(body);
        http.setTimeout(120000);
        
        Http ht = new Http();
        HttpResponse hResp = new HttpResponse();
        
        if(test.isRunningTest()){
            hResp.setStatusCode(200);
            hResp.setBody('{ '+
                          '"RefNum": "r1234567890",'+
                          '"Result": "S",'+
                          '"Error": "",'+
                          '"CustomerId": "c1234567890"'+
                          '}');
        }else{
            hResp = ht.send(http);
        }
        String response;
        
        if(hResp.getStatusCode() == 200){
            response = hResp.getBody();
            Map<String,Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            if(respMap.get('Result') == 's'){
                system.debug(String.valueOf(respMap.get('CustomerId')));
                return String.valueOf(respMap.get('CustomerId'));
            }
        }
        
        return null;
    }
    
    public static Map<String, Object> AuthTransaction(PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj){
         if(creds == null)
            setCreds();
        
        HttpRequest http = new HttpRequest();
        http.setEndpoint(transactionUrl);
        http.setMethod('POST');
        http.setHeader('Content-Type', 'application/json');
        http.setHeader('X-Recurring-Api-Version', '2.1');
        http.setHeader('Authorization', xKey);
        
        String body = '{'+            
            '    "xKey": "'+xKey+'",'+
            '    "xVersion": "5.0.0",'+
            '    "xSoftwareName": "'+creds.Software_Name__c+'",'+
            '    "xSoftwareVersion": "'+creds.Software_Version__c+'",';
            
            if(warpperObj.payMethodToken != null && warpperObj.payMethodToken!=''){
                body += '    "xToken": "'+warpperObj.payMethodToken+'"';
            }    
            else if(warpperObj.paymentTypeVar=='creditCard'){
                body +='    "xCardNum": "'+warpperObj.cardNumber+'",'+
                '    "xName": "'+warpperObj.nameOnCard+'",'+
                '    "xExp": "'+String.valueOf(warpperObj.expireMonth)+String.valueOf(warpperObj.expireYear).substring(2,4)+'",'+
                '    "xCVV": "'+warpperObj.verificationNumber+'",'+
                '    "xCommand": "cc:save"';
            }
            else{
                body +='    "xAccount": "'+warpperObj.accountNumber+'",'+
                // '    "xAccountType": "'+warpperObj.accountType+'",'+
                '    "xName": "'+warpperObj.accountHolderName+'",'+
                '    "xRouting": "'+warpperObj.routingNumber+'",'+
                '    "xCommand": "check:save"';
        }
        
        body += '}';
        
        System.debug('AuthTransaction body -> '+body);
        http.setBody(body);
        http.setTimeout(120000);
        
        Http ht = new Http();
        HttpResponse hResp = new HttpResponse();
        if(test.isRunningTest()){
            hResp.setStatusCode(200);
            hResp.setBody('{'+
                          '"xResult":"A",'+
                          '"xStatus":"Approved",'+
                          '"xName":"test test",'+
                          '"xError":"",'+
                          '"xErrorCode":"00000",'+
                          '"xRefNum":"601518451",'+
                          '"xInvoice":"123456",'+
                          '"xExp":"1030",'+
                          '"xAuthCode":"11295A",'+
                          '"xBatch":"11948741",'+
                          '"xAvsResultCode":"NNN",'+
                          '"xAvsResult":"Address: No Match & 5 Digit Zip: No Match",'+
                          '"xCvvResultCode":"M",'+
                          '"xCvvResult":"Match",'+
                          '"xAuthAmount":"35.00",'+
                          '"xMaskedCardNumber":"4xxxxxxxxxxx1111",'+
                          '"xMaskedAccountNumber":"xxxxx1111",'+
                          '"xCardType":"Visa",'+
                          '"xToken":"8n21126mq0hn253p9m7964p5qn60000g",'+
                          '"xMID":"xxxxxxxxxx9999",'+
                          '"xTID":"xxxxx6789",'+
                          '"xCurrency":"USD",'+
                          '"xDate":"3/3/2022 7:36:34 AM",'+
                          '"xEntryMethod":"Keyed",'+
                          '"xReviewed":"N"'+
                          '}');
        }else{
            hResp = ht.send(http);
        }
        String response;
        
        if(hResp.getStatusCode() == 200){
            response = hResp.getBody();
            Map<String,Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            if(respMap.get('xResult') == 'A'){
                system.debug('xToken -> '+String.valueOf(respMap.get('xToken')));
            }
            return respMap;
        }
        return null;
    }
    
    public static Map<String,Object> getPaymentMethod(String payMethodId){
        if(creds == null)
            setCreds();
        HttpRequest http = new HttpRequest();
        http.setEndpoint(baseURL+'/GetPaymentMethod');
        http.setMethod('POST');
        http.setHeader('Content-Type', 'application/json');
        http.setHeader('X-Recurring-Api-Version', '2.1');
        http.setHeader('Authorization', xKey);
        
        String body = '{'+
            '   "SoftwareName" : "'+creds.Software_Name__c+'",'+
            '   "SoftwareVersion" : "'+creds.Software_Version__c+'",'+
            '	"ShowDeleted" : false,'+
            '   "PaymentMethodId" : "'+payMethodId+'"}';
        
        http.setTimeout(120000);
        http.setBody(body);
        
        Http ht = new Http();
        HttpResponse hResp = new HttpResponse();
        if(test.isRunningTest()){
            hResp.setStatusCode(200);
            hResp.setBody('{'+
                          '    "RefNum": "r1234567890",'+
                          '    "Result": "S",'+
                          '    "Revision": 1,'+
                          '    "Error": ""'+
                          '}');
        }else{
            hResp = ht.send(http);
        }
        String response;
        
        if(hResp.getStatusCode() == 200){
            response = hResp.getBody();
            Map<String,Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(response);            
            return respMap;            
        }
        return null;
    }
    
    public static String markDefault(String payMethodId){
        if(creds == null)
            setCreds();
        Integer revisionNumber;
        Map<String,Object> resultMap = getPaymentMethod(payMethodId);
        if(resultMap.get('Result') == 'S'){
            revisionNumber = Integer.valueOf(String.valueOf(resultMap.get('Revision')));
        }
        else if(resultMap.get('Result') == 'E'){
            return '"'+string.valueOf(resultMap.get('Error'))+'"';
        }
        
        HttpRequest http = new HttpRequest();
        http.setEndpoint(baseURL+'/UpdatePaymentMethod');
        http.setMethod('POST');
        http.setHeader('Content-Type', 'application/json');
        http.setHeader('X-Recurring-Api-Version', '2.1');
        http.setHeader('Authorization', xKey);
        
        String body = '{'+
            '   "SoftwareName" : "'+creds.Software_Name__c+'",'+
            '   "SoftwareVersion" : "'+creds.Software_Version__c+'",'+
            '   "Revision" : "'+revisionNumber+'",'+
            '	"SetAsDefault" : true,'+
            '   "PaymentMethodId" : "'+payMethodId+'"}';
        
        http.setTimeout(120000);
        http.setBody(body);
        
        Http ht = new Http();
        HttpResponse hResp = new HttpResponse();
        if(test.isRunningTest()){
            hResp.setStatusCode(200);
            hResp.setBody('{'+
                          '    "RefNum": "r1234567890",'+
                          '    "Result": "S",'+
                          '    "Error": ""'+
                          '}');
        }else{
            hResp = ht.send(http);
        }
        String response;
        
        if(hResp.getStatusCode() == 200){
            response = hResp.getBody();
            Map<String,Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            if(respMap.get('Result') == 'S'){
                return 'Success';
            }
            else if(respMap.get('Result') == 'E'){
                return '"'+string.valueOf(respMap.get('Error'))+'"';
            }
        }
        return '';
    } 
    
    public static String CreatePaymentMethod(String  xToken, String exp, PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj){
         if(creds == null)
            setCreds();
        
        HttpRequest http = new HttpRequest();
        http.setEndpoint(baseURL+'/CreatePaymentMethod');
        http.setMethod('POST');
        http.setHeader('Content-Type', 'application/json');
        http.setHeader('X-Recurring-Api-Version', '2.1');
        http.setHeader('Authorization', xKey);
        
        String body = '{'+
            '   "SoftwareName" : "'+creds.Software_Name__c+'",'+
            '   "SoftwareVersion" : "'+creds.Software_Version__c+'",'+
            '   "CustomerId" : "'+warpperObj.customerToken+'",'+
            '	"Token" : "'+xToken+'",'+
            '	"SetAsDefault" : false,';

        if(warpperObj.paymentTypeVar=='creditCard'){
            body += '	"TokenType" : "cc",'+
                    '   "Exp": "'+exp+'"';
        }else{
            body += '	"TokenType" : "Check",'+
                    '   "Name": "'+warpperObj.accountHolderName+'"';
        }
        
        body += '}';

        System.debug('CreatePaymentMethod body -> '+body);

        http.setTimeout(120000);
        http.setBody(body);
        
        Http ht = new Http();
        HttpResponse hResp = new HttpResponse();
        if(test.isRunningTest()){
            hResp.setStatusCode(200);
            hResp.setBody('{'+
                          '    "RefNum": "r1234567890",'+
                          '    "Result": "S",'+
                          '    "Error": "",'+
                          '    "PaymentMethodId": "c123456_pm123456"'+
                          '}');
        }else{
            hResp = ht.send(http);
        }
        String response;
        
        if(hResp.getStatusCode() == 200){
            response = hResp.getBody();
            Map<String,Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            if(respMap.get('Result') == 'S'){
                system.debug('response ===> '+String.valueOf(respMap));
                system.debug('PaymentMethodId -> '+String.valueOf(respMap.get('PaymentMethodId')));
                return String.valueOf(respMap.get('PaymentMethodId'));
            }
        }
        return '';
    }

    public static String DeletePaymentMethod(String payMethodId,String customerId){
        if(creds == null)
            setCreds();
        
        String defaultPaymentMethodId = '';
        
        List<AcctSeed__Payment_Processor_Customer__c> customer = [SELECT Id, AcctSeed__Account__c, AcctSeed__External_Id__c FROM AcctSeed__Payment_Processor_Customer__c WHERE AcctSeed__Account__c =: customerId];
        List<AcctSeed__Payment_Method__c> paymentMethodList = new List<AcctSeed__Payment_Method__c>();
        
        if(!customer.isEmpty()){            
            
            String customerToken = customer[0].AcctSeed__External_Id__c;
            
            Map<String,Object> resultMap = getCustomer(customerToken);
            if(resultMap.get('Result') == 'S'){
                defaultPaymentMethodId = String.valueOf(resultMap.get('DefaultPaymentMethodId'));
            }
            else if(resultMap.get('Result') == 'E'){
                return '"'+string.valueOf(resultMap.get('Error'))+'"';
            }
            system.debug('defaultPaymentMethodId => '+defaultPaymentMethodId);
            
            if(defaultPaymentMethodId == payMethodId){            
                paymentMethodList = [SELECT Id, Name, AcctSeed__External_Id__c, AcctSeed__Bank_Account_Type__c, AcctSeed__Type__c, AcctSeed__Payment_Method_Type__c, AcctSeed__Last_Four_Digits__c, CreatedBy.Name, CreatedDate, AcctSeed__Status__c, AcctSeed__Default__c FROM AcctSeed__Payment_Method__c WHERE AcctSeed__External_Id__c !=: payMethodId AND AcctSeed__Customer__c =: customerId AND AcctSeed__Payment_Processor__r.Name = 'Cardknox' AND AcctSeed__Status__c = 'Active' limit 1];
                if(!paymentMethodList.isEmpty()){
                    markDefault(paymentMethodList[0].AcctSeed__External_Id__c);
                    paymentMethodList[0].AcctSeed__Default__c = true;
                }            
            }
            
            HttpRequest http = new HttpRequest();
            http.setEndpoint(baseURL+'/DeletePaymentMethod');
            http.setMethod('POST');
            http.setHeader('Content-Type', 'application/json');
            http.setHeader('X-Recurring-Api-Version', '2.1');
            http.setHeader('Authorization', xKey);
            
            String body = '{'+
                '   "SoftwareName" : "'+creds.Software_Name__c+'",'+
                '   "SoftwareVersion" : "'+creds.Software_Version__c+'",'+
                '   "PaymentMethodId" : "'+payMethodId+'"}';
            
            http.setTimeout(120000);
            http.setBody(body);
            
            Http ht = new Http();
            HttpResponse hResp = new HttpResponse();
            if(test.isRunningTest()){
                hResp.setStatusCode(200);
                hResp.setBody('{'+
                              '    "RefNum": "r1234567890",'+
                              '    "Result": "S",'+
                              '    "Error": ""'+
                              '}');
            }else{
                hResp = ht.send(http);
            }
            String response;
            
            if(hResp.getStatusCode() == 200){
                response = hResp.getBody();
                Map<String,Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(response);
                if(respMap.get('Result') == 'S'){
                    return 'Success';
                }
                else if(respMap.get('Result') == 'E'){
                    return '"'+string.valueOf(respMap.get('Error'))+'"';
                }
            }
            
            if(!paymentMethodList.isEmpty()){
                paymentGatewayClass.updatePSchRecords(paymentMethodList, 'upsert');
            }
        }
        return '';

    }   
    
    public static Map<String,Object> getCustomer(String customerId){   
        if(creds == null)
            setCreds();
        
        system.debug('creds -> '+creds);
        HttpRequest http = new HttpRequest();
        http.setEndpoint(baseURL+'/GetCustomer');
        http.setMethod('POST');
        http.setHeader('Content-Type', 'application/json');
        http.setHeader('X-Recurring-Api-Version', '2.1');
        http.setHeader('Authorization', xKey);

        String body = '{'+
            '"SoftwareName" : "'+creds.Software_Name__c+'",'+
            '"SoftwareVersion" : "'+creds.Software_Version__c+'",'+
            '"CustomerId" : "'+customerId+'",'+
            '"ShowDeleted" : false'+
            '}';
        system.debug('createCustomer body -> '+body);
        
        http.setBody(body);
        http.setTimeout(120000);
        
        Http ht = new Http();
        HttpResponse hResp = new HttpResponse();
        
        if(test.isRunningTest()){
            hResp.setStatusCode(200);
            hResp.setBody('{ '+
                          '"RefNum": "r1234567890",'+
                          '"Result": "S",'+
                          '"Error": "",'+
                          '"CustomerId": "c1234567890"'+
                          '}');
        }else{
            hResp = ht.send(http);
        }
        String response;
        
        if(hResp.getStatusCode() == 200){
            response = hResp.getBody();
            Map<String,Object> respMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            return respMap;
        }        
        return null;
    }
    
    public static Map<String,Object> ProcessTransaction(Decimal amount, PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj, String transactionType){
         if(creds == null)
            setCreds();
        
        HttpRequest http = new HttpRequest();
        http.setEndpoint(baseURL+'/ProcessTransaction');
        http.setMethod('POST');
        http.setHeader('Content-Type', 'application/json');
        http.setHeader('X-Recurring-Api-Version', '2.1');
        http.setHeader('Authorization', xKey);
        Decimal totalAmount = Decimal.valueOf(String.valueOf(amount));
        Decimal serviceFee= 0.00;
        if(warpperObj.paymentTypeVar == 'creditCard'){
            serviceFee = ((amount/100) * warpperObj.ccFeeRate);
            totalAmount += serviceFee;
            system.debug('Amount to Pay => '+totalAmount.setScale(2));
        }
        
        String body = '{'+
            '   "SoftwareName" : "'+creds.Software_Name__c+'",'+
            '   "SoftwareVersion" : "'+creds.Software_Version__c+'",'+
            '   "PaymentMethodId" : "'+warpperObj.payMethodToken+'",'+
            '   "Amount" : '+totalAmount.setScale(2)+',';
        
        if(warpperObj.paymentTypeVar == 'creditCard'){
            body +='	"Custom09" : '+serviceFee.setScale(2)+','+
            '	"Custom10" : '+amount.setScale(2)+',';
        }    
        
        if(warpperObj.billing != null){
            body += '	"Custom19" : "'+warpperObj.billing.id+'",';
        }
        
        if(transactionType=='Auth'){
            body += '	"TransactionType" : "AuthOnly",'+
            		'   "AllowDuplicates" : true,';
        }else{
            body += '   "AllowDuplicates" : false,';
        }
        
        body += '	"UseBackupPaymentMethods" : false'+
            	'}';
        
        http.setBody(body);
        http.setTimeout(120000);

        system.debug('ProcessTransaction body -> '+body);
        
        Http ht = new Http();
        HttpResponse hResp = new HttpResponse();
        
        if(test.isRunningTest()){
            hResp.setStatusCode(200);
            hResp.setBody('{'+
                          '    "RefNum": "r1234567890",'+
                          '    "Result": "S",'+
                          '    "Error": "",'+
                          '    "DefaultPaymentMethodId": "c123456_pm123456",'+
                          '    "GatewayRefnum" : "1234567890",'+
                          '    "GatewayStatus" : "Approved",'+
                          '    "GatewayErrorMessage" : ""'+
                          '}');
        }else{
            hResp = ht.send(http);
        }
        String response;
        Map<String,Object> respMap = new map<string,object>();
        
        if(hResp.getStatusCode() == 200){
            response = hResp.getBody();
            respMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            if(respMap.get('Result') == 'S'){
                system.debug('GatewayRefNum -> '+String.valueOf(respMap.get('GatewayRefNum')));
            }
        }
        return respMap;
    }
    
    /*@future(callout=true)
    public static void captureTransaction(String refNum, String billId){
        creds = Cardknox_Creds__c.getOrgDefaults();
        HttpRequest http = new HttpRequest();
        http.setEndpoint(transactionUrl);
        http.setMethod('POST');
        http.setHeader('Content-Type', 'application/json');
        http.setHeader('X-Recurring-Api-Version', '2.1');
        http.setHeader('Authorization', xKey);
        
       String body = '{'+            
            '    "xKey": "'+xKey+'",'+
            '    "xVersion": "5.0.0",'+
            '    "xSoftwareName": "'+creds.Software_Name__c+'",'+
            '    "xSoftwareVersion": "'+creds.Software_Version__c+'",'+
            '	"xCommand": "cc:Capture",'+
			'	"xCustom19" : "'+billId+'",'+
			'	"xRefNum" : "'+refNum+'"'+
            	'}';
        
        http.setBody(body);
        http.setTimeout(120000);

        system.debug('captureTransaction body -> '+body);
        
        Http ht = new Http();
        HttpResponse hResp = new HttpResponse();
        hResp = ht.send(http);
        String response;
        Map<String,Object> respMap = new map<string,object>();
        
        if(hResp.getStatusCode() == 200){
            response = hResp.getBody();
            system.debug('response -> '+response);
            /*respMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            if(respMap.get('Result') == 'S'){
                system.debug('GatewayRefNum -> '+String.valueOf(respMap.get('GatewayRefNum')));
            }*
        }
        //return response;
    }

    public static string transactionReport(String beginDate, String endDate){
        creds = Cardknox_Creds__c.getOrgDefaults();
        HttpRequest http = new HttpRequest();
        http.setEndpoint(transactionUrl+'/reportjson');
        http.setMethod('POST');
        http.setHeader('Content-Type', 'application/json');
        http.setHeader('X-Recurring-Api-Version', '2.1');
        http.setHeader('Authorization', xKey);
        
       String body = '{'+            
            '    "xKey": "'+xKey+'",'+
            '    "xVersion": "5.0.0",'+
            '    "xSoftwareName": "'+creds.Software_Name__c+'",'+
            '    "xSoftwareVersion": "'+creds.Software_Version__c+'",'+
            '      "xCommand": "report:batch",'+
            '      "xBeginDate": "'+beginDate+'",'+
            '      "xEndDate": "'+endDate+'",'+
            '      "xFields": "xCustom19,xrefnum, xcommand, xname, xmaskedcardnumber, xtoken, xamount, xentereddate",'+
            	'}';
        
        http.setBody(body);
        http.setTimeout(120000);

        system.debug('transactionReport body -> '+body);
        
        Http ht = new Http();
        HttpResponse hResp = new HttpResponse();
        hResp = ht.send(http);
        String response;
        Map<String,Object> respMap = new map<string,object>();
        
        if(hResp.getStatusCode() == 200){
            response = hResp.getBody();
            /*respMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            if(respMap.get('Result') == 'S'){
                system.debug('GatewayRefNum -> '+String.valueOf(respMap.get('GatewayRefNum')));
            }*
        }
        return response;
    }
    */
}