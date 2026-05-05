public class ForteUtilNew {
    
    public String transaction_id;
    public String location_id;
    public String action;
    public Double authorization_amount;
    public Response response;
    public static boolean runningInASandbox;
    public class Response {
        public String environment;
        public String response_type;
        public String response_code;
        public String response_desc;
        public String authorization_code;
        public String preauth_result;
        public String preauth_desc;
        public String preauth_neg_report ;
    }
    public static ForteUtilNew createTransaction(Decimal totalAmountDue,String ipAddress, PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj){
        
        if(runningInASandbox == null){
            runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        }
        
        HttpRequest http = new HttpRequest();
        if(!runningInASandbox){
            http.setEndpoint(Label.Forte_Transaction_Sale_URL);
        }else{
            http.setEndpoint(Label.Forte_Transaction_Sale_URL_Sandbox);
        }
        http.setMethod('POST');
        http.setHeader('Content-Type', 'application/json');
        
        Blob headerValue; 
        
        if(!runningInASandbox){
            headerValue = Blob.valueOf(Label.Forte_API_Access_Id + ':' + Label.Forte_API_Secure_Key);
        }else{
            headerValue = Blob.valueOf(Label.Forte_API_Access_Id_Sandbox + ':' + Label.Forte_API_Secure_Key_Sandbox);
        }
        
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue) +'';
        
        if(!runningInASandbox){
            http.setHeader('X-Forte-Auth-Organization-Id',Label.Forte_API_Organization_Id);
        }else{
            http.setHeader('X-Forte-Auth-Organization-Id',Label.Forte_API_Organization_Id_Sandbox);
        }
        
        http.setHeader('Authorization', authorizationHeader);
        
        http.setTimeout(120000);
        
        String body = '{"action":"sale","authorization_amount":'+ totalAmountDue +',"customer_ip_address": "' + ipAddress +'",';
        body +='"billing_address":{"company_name": "' + warpperObj.firmName + '"},';//"first_name": "'+ warpperObj.firstName +'","last_name": "'+ warpperObj.lastName +'",
        
        body +='"reference_id":"'+warpperObj.invoiceId+'",';
        body +='"order_number":"'+warpperObj.invoiceId + '-' + (warpperObj.nextPaymentDate != null ? warpperObj.nextPaymentDate : '')+'",';
        body +='"xdata":{"xdata_1": "'+ warpperObj.invoiceId +'","xdata_2": "'+ warpperObj.firmId +'","xdata_3": "'+ warpperObj.firmName +'"},';
        
        if(warpperObj.paymentTypeVar=='check' || (warpperObj.paymentTypeVar == 'Existing' && warpperObj.accountNumber !=null)){
            body +='"echeck":{"sec_code": "WEB","account_type": "'+ warpperObj.accountType +'","routing_number": "'+ warpperObj.routingNumber +'","account_number": "'+ warpperObj.accountNumber +'","account_holder": "'+ warpperObj.accountHolderName +'"}}';
        }else if(warpperObj.paymentTypeVar=='creditCard' || (warpperObj.paymentTypeVar == 'Existing' && warpperObj.cardNumber !=null)){
            body +='"card":{"card_type": "'+ warpperObj.cardTypeVar +'","name_on_card": "'+ warpperObj.nameOnCard +'","account_number": "'+ warpperObj.cardNumber +'","expire_month": "'+ warpperObj.expireMonth +'","expire_year": "'+ warpperObj.expireYear +'","card_verification_value": "'+ warpperObj.verificationNumber +'"}}';
        }
        
        system.debug('Body => '+body);
        http.setBody(body);
        
        String response;
        Http con = new Http();
        HttpResponse hs = new HttpResponse();
        if(!Test.isRunningTest()){
            hs = con.send(http);
            response = hs.getBody();
            System.debug(response);
        }else{
            response='{'+
                '"transaction_id": "trn_c3cc3cb2-5b58-46fb-a530-cca9c998d5a3",'+
                '"location_id": "loc_195168",'+
                '"action": "sale",'+
                '"authorization_amount": 109.49,'+
                '"billing_address": {'+
                ' "first_name": "Emmett",'+
                '"last_name": "Brown"'+
                '},'+
                '"echeck": {'+
                '"account_holder": "Emmett Brown",'+
                '"masked_account_number": "****7852",'+
                '"routing_number": "222371863",'+
                '"account_type": "checking",'+
                '"sec_code": "WEB"'+
                '},'+
                '"response": {'+
                '"environment": "sandbox",'+
                '"response_type": "A",'+
                '"response_code": "'+ (warpperObj.firstName=='APPROVED'?'A01':'R01') + '",'+
                '"response_desc": "'+ (warpperObj.firstName=='APPROVED'?'APPROVED':'REJECTED') + '",'+
                '"authorization_code": "17058729",'+
                '"preauth_result": "POS",'+
                '"preauth_desc": "P70:VALIDATED"'+
                '}'+
                '}';
        }
        ForteUtilNew util = ForteUtilNew.parse(response);
        return util;
        
    }
    
    public static ForteUtilNew createForceTransaction(Decimal totalAmountDue,String ipAddress,PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj){
        
        if(runningInASandbox == null){
            runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        }
        
        HttpRequest http = new HttpRequest();
        if(!runningInASandbox){
            http.setEndpoint(Label.Forte_Transaction_Force_URL);
        }else{
            http.setEndpoint(Label.Forte_Transaction_Force_URL_Sandbox);
        }
        http.setMethod('POST');
        http.setHeader('Content-Type', 'application/json');
        
        Blob headerValue; 
        
        if(!runningInASandbox){
            headerValue = Blob.valueOf(Label.Forte_API_Access_Id + ':' + Label.Forte_API_Secure_Key);
        }else{
            headerValue = Blob.valueOf(Label.Forte_API_Access_Id_Sandbox + ':' + Label.Forte_API_Secure_Key_Sandbox);
        }
        
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue) +'';
        
        if(!runningInASandbox){
            http.setHeader('X-Forte-Auth-Organization-Id',Label.Forte_API_Organization_Id);
        }else{
            http.setHeader('X-Forte-Auth-Organization-Id',Label.Forte_API_Organization_Id_Sandbox);
        }
        
        http.setHeader('Authorization', authorizationHeader);
        
        http.setTimeout(120000);
        
        String body = '{"action":"force","authorization_amount":'+ totalAmountDue +',"customer_ip_address": "' + ipAddress +'",';
        body +='"billing_address":{"company_name": "' + warpperObj.firmName + '"},';//"first_name": "'+ warpperObj.firstName +'","last_name": "'+ warpperObj.lastName +'",
        
        body +='"reference_id":"'+warpperObj.invoiceId+'",';
        //body +='"order_number":"'+warpperObj.invoiceId+'",';
        body +='"order_number":"'+warpperObj.invoiceId + '-' + (warpperObj.nextPaymentDate != null ? warpperObj.nextPaymentDate : '')+'",';
        body +='"xdata":{"xdata_1": "'+ warpperObj.invoiceId +'","xdata_2": "'+ warpperObj.firmId +'","xdata_3": "'+ warpperObj.firmName +'"},';
        
        if(warpperObj.paymentTypeVar=='check' || (warpperObj.paymentTypeVar == 'Existing' && warpperObj.accountNumber !=null)){
            body +='"echeck":{"sec_code": "WEB","account_type": "'+ warpperObj.accountType +'","routing_number": "'+ warpperObj.routingNumber +'","account_number": "'+ warpperObj.accountNumber +'","account_holder": "'+ warpperObj.accountHolderName +'"}}';
        }else if(warpperObj.paymentTypeVar=='creditCard' || (warpperObj.paymentTypeVar == 'Existing' && warpperObj.cardNumber !=null)){
            body +='"card":{"card_type": "'+ warpperObj.cardTypeVar +'","name_on_card": "'+ warpperObj.nameOnCard +'","account_number": "'+ warpperObj.cardNumber +'","expire_month": "'+ warpperObj.expireMonth +'","expire_year": "'+ warpperObj.expireYear +'","card_verification_value": "'+ warpperObj.verificationNumber +'"}}';
        }
        
        http.setBody(body);
        
        String response;
        Http con = new Http();
        HttpResponse hs = new HttpResponse();
        if(!Test.isRunningTest()){
            hs = con.send(http);
            response = hs.getBody();
            System.debug(response);
        }else{
            response='{'+
                '"transaction_id": "trn_c3cc3cb2-5b58-46fb-a530-cca9c998d5a3",'+
                '"location_id": "loc_195168",'+
                '"action": "sale",'+
                '"authorization_amount": 109.49,'+
                '"billing_address": {'+
                ' "first_name": "Emmett",'+
                '"last_name": "Brown"'+
                '},'+
                '"echeck": {'+
                '"account_holder": "Emmett Brown",'+
                '"masked_account_number": "****7852",'+
                '"routing_number": "222371863",'+
                '"account_type": "checking",'+
                '"sec_code": "WEB"'+
                '},'+
                '"response": {'+
                '"environment": "sandbox",'+
                '"response_type": "A",'+
                '"response_code": "'+ (warpperObj.firstName=='APPROVED'?'A01':'R01') + '",'+
                '"response_desc": "'+ (warpperObj.firstName=='APPROVED'?'APPROVED':'REJECTED') + '",'+
                '"authorization_code": "17058729",'+
                '"preauth_result": "POS",'+
                '"preauth_desc": "P70:VALIDATED"'+
                '}'+
                '}';
        }
        ForteUtilNew util = ForteUtilNew.parse(response);
        return util;
        
    }
    
    public static ForteUtilNew authorizeTransaction(Decimal totalAmountDue,String ipAddress,PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj){
        
        if(runningInASandbox == null){
            runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        }
        
        HttpRequest http = new HttpRequest();
        if(!runningInASandbox){
            http.setEndpoint(Label.Forte_Transaction_Authorize_URL);
        }else{
            http.setEndpoint(Label.Forte_Transaction_Authorize_URL_Sandbox);
        }
        http.setMethod('POST');
        http.setHeader('Content-Type', 'application/json');
        
        Blob headerValue; 
        
        if(!runningInASandbox){
            headerValue = Blob.valueOf(Label.Forte_API_Access_Id + ':' + Label.Forte_API_Secure_Key);
        }else{
            headerValue = Blob.valueOf(Label.Forte_API_Access_Id_Sandbox + ':' + Label.Forte_API_Secure_Key_Sandbox);
        }
        
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue) +'';
        
        if(!runningInASandbox){
            http.setHeader('X-Forte-Auth-Organization-Id',Label.Forte_API_Organization_Id);
        }else{
            http.setHeader('X-Forte-Auth-Organization-Id',Label.Forte_API_Organization_Id_Sandbox);
        }
        
        http.setHeader('Authorization', authorizationHeader);
        
        http.setTimeout(120000);   
        String verifyAmount = '';
        if(warpperObj.paymentTypeVar=='check' || (warpperObj.paymentTypeVar == 'Existing' && warpperObj.accountNumber !=null)){
            verifyAmount = '0.01';
        }
        /*else if(warpperObj.paymentTypeVar=='creditCard' || (warpperObj.paymentTypeVar == 'Existing' && warpperObj.cardNumber !=null)){
            verifyAmount = '0.01';
        }*/

        String body = '{"authorization_amount":'+ '"' + verifyAmount + '"' +',"customer_ip_address": "' + ipAddress +'",'; // "action":"verify", removed because getting error in echeck Authorization
        body +='"billing_address":{"first_name": "'+ warpperObj.firstName +'","last_name": "'+ warpperObj.lastName +'"},';
        
        body +='"reference_id":"'+warpperObj.invoiceId+'",';
        //body +='"order_number":"'+warpperObj.invoiceId+'",';
        body +='"order_number":"'+warpperObj.invoiceId + '-' + (warpperObj.nextPaymentDate != null ? warpperObj.nextPaymentDate : '')+'",';
        body +='"xdata":{"xdata_1": "'+ warpperObj.invoiceId +'","xdata_2": "'+ warpperObj.firmId +'","xdata_3": "'+ warpperObj.firmName +'"},';
        
        /*if(warpperObj.paymentTypeVar=='check' || (warpperObj.paymentTypeVar == 'Existing' && warpperObj.accountNumber !=null)){
            body +='"echeck":{"sec_code": "WEB"},';
        }*/
        
        if(warpperObj.paymentTypeVar=='check' || (warpperObj.paymentTypeVar == 'Existing' && warpperObj.accountNumber !=null)){
            body +='"echeck":{"account_type": "'+ warpperObj.accountType +'","routing_number": "'+ warpperObj.routingNumber +'","account_number": "'+ warpperObj.accountNumber +'","account_holder": "'+ warpperObj.accountHolderName +'"}}';
        }else if(warpperObj.paymentTypeVar=='creditCard' || (warpperObj.paymentTypeVar == 'Existing' && warpperObj.cardNumber !=null)){
            body +='"card":{"card_type": "'+ warpperObj.cardTypeVar +'","name_on_card": "'+ warpperObj.nameOnCard +'","account_number": "'+ warpperObj.cardNumber +'","expire_month": "'+ warpperObj.expireMonth +'","expire_year": "'+ warpperObj.expireYear +'","card_verification_value": "'+ warpperObj.verificationNumber +'"}}';
        }
        
       // body += '"paymethod_token": "'+paymentMethodToken+'"}';

        System.debug('body => ' + body);
        http.setBody(body);
        
        String response;
        Http con = new Http();
        HttpResponse hs = new HttpResponse();
        if(!Test.isRunningTest()){
            hs = con.send(http);
            response = hs.getBody();
            System.debug(response);
        }else{
            response='{'+
                '"transaction_id": "trn_c3cc3cb2-5b58-46fb-a530-cca9c998d5a3",'+
                '"location_id": "loc_195168",'+
                '"action": "sale",'+
                '"authorization_amount": 109.49,'+
                '"billing_address": {'+
                ' "first_name": "Emmett",'+
                '"last_name": "Brown"'+
                '},'+
                '"echeck": {'+
                '"account_holder": "Emmett Brown",'+
                '"masked_account_number": "****7852",'+
                '"routing_number": "222371863",'+
                '"account_type": "checking",'+
                '"sec_code": "WEB"'+
                '},'+
                '"response": {'+
                '"environment": "sandbox",'+
                '"response_type": "A",'+
                '"response_code": "'+ (warpperObj.firstName=='APPROVED'?'A01':'R01') + '",'+
                '"response_desc": "'+ (warpperObj.firstName=='APPROVED'?'APPROVED':'REJECTED') + '",'+
                '"authorization_code": "17058729",'+
                '"preauth_result": "POS",'+
                '"preauth_desc": "P70:VALIDATED"'+
                '}'+
                '}';
        }
        ForteUtilNew util = ForteUtilNew.parse(response);
        return util;
        
    }
    
    public static ForteTransactionWrapper getTransaction(String transactionId){
        
        if(runningInASandbox == null){
            runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        }
        
        HttpRequest http = new HttpRequest();
        if(!runningInASandbox){
            http.setEndpoint(Label.Forte_Transaction_GET_URL+ '/' +transactionId);
        }else{
            http.setEndpoint(Label.Forte_Transaction_GET_URL_Sandbox+  '/'  +transactionId);
        }
        http.setMethod('GET');
        http.setHeader('Content-Type', 'application/json');
        
        Blob headerValue; 
        
        if(!runningInASandbox){
            headerValue = Blob.valueOf(Label.Forte_API_Access_Id + ':' + Label.Forte_API_Secure_Key);
        }else{
            headerValue = Blob.valueOf(Label.Forte_API_Access_Id_Sandbox + ':' + Label.Forte_API_Secure_Key_Sandbox);
        }
        
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue) +'';
        
        if(!runningInASandbox){
            http.setHeader('X-Forte-Auth-Organization-Id',Label.Forte_API_Organization_Id);
        }else{
            http.setHeader('X-Forte-Auth-Organization-Id',Label.Forte_API_Organization_Id_Sandbox);
        }
        
        http.setHeader('Authorization', authorizationHeader);
        
        http.setTimeout(120000);
        String response;
        Http con = new Http();
        HttpResponse hs = new HttpResponse();
        if(!Test.isRunningTest()){
            hs = con.send(http);
            response = hs.getBody();
            System.debug(response);
        }else{
            response='{'+
                '    "transaction_id": "trn_939ca9d9-deed-4cef-8902-f10f5a509e6c",'+
                '    "organization_id": "org_302974",'+
                '    "location_id": "loc_171818",'+
                '    "order_number": "114761560",'+
                '    "reference_id": "114761560",'+
                '    "funding_id": "fnd_ACH-1221-46FC9",'+
                '    "status": "funded",'+
                '    "action": "sale",'+
                '    "authorization_amount": 525.00,'+
                '    "authorization_code": "23573753",'+
                '    "entered_by": "9bfdab47c4d0ad57fa7d",'+
                '    "received_date": "2021-12-15T03:00:22.423",'+
                '    "origination_date": "2021-12-15T17:32:47.063",'+
                '    "billing_address": {'+
                '        "first_name": "Susan",'+
                '        "last_name": "Marks",'+
                '        "company_name": "SAM LAW OFFICE, LLC"'+
                '    },'+
                '    "echeck": {'+
                '        "masked_account_number": "****6271",'+
                '        "last_4_account_number": "6271",'+
                '        "routing_number": "071000013",'+
                '        "account_type": "checking",'+
                '        "sec_code": "WEB"'+
                '    },'+
                '    "settlements": ['+
                '        {'+
                '            "settle_id": "stl_d3151821-b29f-4d18-a1f1-f6d61f1d31f1",'+
                '            "organization_id": "org_302974",'+
                '            "location_id": "loc_171818",'+
                '            "transaction_id": "trn_939ca9d9-deed-4cef-8902-f10f5a509e6c",'+
                '            "order_number": "114761560",'+
                '            "reference_id": "114761560",'+
                '            "funding_id": "fnd_ACH-1221-46FC9",'+
                '            "settle_batch_id": "",'+
                '            "settle_date": "2021-12-21T00:00:00",'+
                '            "settle_type": "deposit",'+
                '            "settle_response_code": "S01",'+
                '            "settle_amount": 525.00,'+
                '            "method": "echeck",'+
                '            "links": {'+
                '                "self": "https://api.forte.net/v3/settlements/stl_d3151821-b29f-4d18-a1f1-f6d61f1d31f1"'+
                '            }'+
                '        }'+
                '    ],'+
                '    "xdata": {'+
                '        "xdata_1": "114761560",'+
                '        "xdata_2": "119903",'+
                '        "xdata_3": "SAM LAW OFFICE, LLC"'+
                '    },'+
                '    "biller_name": "Marks, Susan",'+
                '    "attempt_number": 1,'+
                '    "response": {'+
                '        "environment": "live",'+
                '        "response_type": "A",'+
                '        "response_code": "A01",'+
                '        "response_desc": "APPROVED",'+
                '        "authorization_code": "23573753",'+
                '        "preauth_result": "POS",'+
                '        "preauth_desc": "P70:VALIDATED"'+
                '    },'+
                '    "links": {'+
                '        "disputes": "https://api.forte.net/v3/transactions/trn_939ca9d9-deed-4cef-8902-f10f5a509e6c/disputes",'+
                '        "settlements": "https://api.forte.net/v3/transactions/trn_939ca9d9-deed-4cef-8902-f10f5a509e6c/settlements",'+
                '        "self": "https://api.forte.net/v3/transactions/trn_939ca9d9-deed-4cef-8902-f10f5a509e6c/"'+
                '    }'+
                '}';
        }
        return ((ForteTransactionWrapper) System.JSON.deserialize(response, ForteTransactionWrapper.class));
        
    }
    
    public static ForteAllTransactionsWrapper getAllTransactions(String URL){
        
        if(runningInASandbox == null){
            runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        }
        
        HttpRequest http = new HttpRequest();
        if(URL != null){
            http.setEndpoint(URL);
        }else{
            Date todayDate = System.today();
            Date TenDayBeforeDate = System.today().addDays(-10);
            if(!runningInASandbox){
                http.setEndpoint(Label.Forte_Transaction_GET_URL + '?filter=start_received_date+eq+\'' + TenDayBeforeDate.year() + '-' + TenDayBeforeDate.month() + '-' + TenDayBeforeDate.day() + '\'+and+end_received_date+eq+\'' + todayDate.year() + '-' + todayDate.month() + '-' + todayDate.day() + '\'' );
            }else{
                http.setEndpoint(Label.Forte_Transaction_GET_URL_Sandbox +  '?filter=start_received_date+eq+\'' + TenDayBeforeDate.year() + '-' + TenDayBeforeDate.month() + '-' + TenDayBeforeDate.day() + '\'+and+end_received_date+eq+\'' + todayDate.year() + '-' + todayDate.month() + '-' + todayDate.day() + '\'' );
            }
        }
        http.setMethod('GET');
        http.setHeader('Content-Type', 'application/json');
        
        Blob headerValue; 
        
        if(!runningInASandbox){
            headerValue = Blob.valueOf(Label.Forte_API_Access_Id + ':' + Label.Forte_API_Secure_Key);
        }else{
            headerValue = Blob.valueOf(Label.Forte_API_Access_Id_Sandbox + ':' + Label.Forte_API_Secure_Key_Sandbox);
        }
        
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue) +'';
        
        if(!runningInASandbox){
            http.setHeader('X-Forte-Auth-Organization-Id',Label.Forte_API_Organization_Id);
        }else{
            http.setHeader('X-Forte-Auth-Organization-Id',Label.Forte_API_Organization_Id_Sandbox);
        }
        
        http.setHeader('Authorization', authorizationHeader);
        
        http.setTimeout(120000);
        String response;
        Http con = new Http();
        HttpResponse hs = new HttpResponse();
        if(!Test.isRunningTest()){
            hs = con.send(http);
            response = hs.getBody();
            System.debug(response);
        }else{
            response='{'+
                '"number_results": 3,'+
                '"search_criteria": {'+
                '"page_size": 50,'+
                '"page_index": 0,'+
                '"home_organization_id": "org_300005",'+
                '"resource_specific": {'+
                '"location_id": "loc_115161",'+
                ' "start_received_date": "2018-05-05T07:52:32.9895316-07:00",'+
                '  "end_received_date": "2018-08-03T07:52:32.9895316-07:00"'+
                ' }'+
                '},'+
                '"results": ['+
                '{'+
                '"transaction_id": "trn_5acbc87c-0277-4f43-8f09-643cefdc131e",'+
                '"organization_id": "org_300005",'+
                '"location_id": "loc_115161",'+
                '"status": "ready",'+
                '"action": "sale",'+
                '"authorization_amount": 3.5,'+
                '"authorization_code": "123456",'+
                '"entered_by": "jayashri.srivelu-nam",'+
                '"received_date": "2018-05-30T13:57:32.257",'+
                '"billing_address": {'+
                '"first_name": "test",'+
                ' "last_name": "ach"'+
                '},'+
                '"card": {'+
                '"last_4_account_number": "1111",'+
                '"masked_account_number": "****1111",'+
                ' "card_type": "visa"'+
                '},'+
                '"response": {'+
                ' "response_code": "A01",'+
                ' "authorization_code": "123456"'+
                '},'+
                '"links": {'+
                '"disputes": "https://api.forte.net/v3/transactions/trn_5acbc87c-0277-4f43-8f09-643cefdc131e/disputes",'+
                ' "settlements": "https://api.forte.net/v3/transactions/trn_5acbc87c-0277-4f43-8f09-643cefdc131e/settlements",'+
                '  "self": "https://api.forte.net/v3/transactions/trn_5acbc87c-0277-4f43-8f09-643cefdc131e"'+
                ' }'+
                '}'+
                ' ],'+
                ' "response": {'+
                '    "environment": "sandbox",'+
                '    "response_desc": "Get Successful."'+
                '  },'+
                '  "links": {'+
               // '  "self": "https://api.forte.net/v3/transactions/",'+
               // '   "next": "https://api.forte.net/v3/transactions/?page_index=1"'+
                ' }'+
                '}';
        }
        system.debug('response===='+response);
        return ((ForteAllTransactionsWrapper) System.JSON.deserialize(response, ForteAllTransactionsWrapper.class));
        
    }

    public static String createCustomerInDex(PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj, String accId){
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
        req.setBody( '{"company_name": "' + warpperObj.firmName + '","customer_id": "'+ accId +'"}');//"first_name": "'+ warpperObj.firstname +'", "last_name": "'+ warpperObj.lastname +'"
        
        HTTP http = new HTTP();
        HTTPResponse Response = new HTTPResponse();
        req.setTimeout(120000);
        Response = http.send(req);
        
        system.debug(Response.getStatusCode());
        if(response.getStatusCode() == 201){
            Map<String, Object> customerMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            system.debug('customerMap -> '+customerMap);
            system.debug('customer_token -> '+customerMap.get('customer_token'));
            return (string)customerMap.get('customer_token');
        }
        return null;
    }	
    
    public static Map<String, Object> createCustomerCreditCardPaymethod(PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj){
        String customerToken = warpperObj.customerToken;
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
        // authorization is done using credentials
        String header = 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(AccessId+':'+AccessKey));
        req.setHeader('Authorization', header);
        req.setBody( '{"card": {"name_on_card":"'+warpperObj.nameOnCard+'","card_type":"'+warpperObj.cardTypeVar+'","account_number":"'+warpperObj.cardNumber+'","expire_month":'+warpperObj.expireMonth+',"expire_year":'+warpperObj.expireYear+',"card_verification_value": "'+warpperObj.verificationNumber+'"}}');

        HTTP http = new HTTP();
        HTTPResponse Response = new HTTPResponse();
        req.setTimeout(120000);
        Response = http.send(req);
        
        system.debug(Response.getStatusCode());
        system.debug(Response.getBody());
        if(response.getStatusCode() == 201){
            Map<String, Object> creditCardPayMethodMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            system.debug('creditCardPayMethodMap -> '+creditCardPayMethodMap);
            system.debug('paymethod_token -> '+creditCardPayMethodMap.get('paymethod_token'));
            /*Payment_Method__c payMethod = new Payment_Method__c();
            payMethod.Payment_Method_Token__c = (String)creditCardPayMethodMap.get('paymethod_token');
            payMethod.Account__c = warpperObj.billing.AcctSeed__Customer__c;
            payMethod.Name_On_Card__c = (String)creditCardPayMethodMap.get('name_on_card');
            payMethod.Last_4_Account_Number__c	 = (String)creditCardPayMethodMap.get('last_4_account_number');
            payMethod.Expiry_Month__c = (Decimal)creditCardPayMethodMap.get('expire_month');
            payMethod.Expiry_Year__c = (Decimal)creditCardPayMethodMap.get('expire_year');
            payMethod.Card_Type__c = (String)creditCardPayMethodMap.get('card_type');
            insert payMethod;*/
            //return (string)creditCardPayMethodMap.get('paymethod_token');
            return creditCardPayMethodMap;
        }
        return null;
    }
    
    
    public static  Map<String, Object> createCustomerECheckPaymethod(PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj){
        String customerToken = warpperObj.customerToken;
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
        // authorization is done using credentials
        String header = 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(AccessId+':'+AccessKey));
        req.setHeader('Authorization', header);
        req.setBody( '{"echeck": {"account_holder": "'+warpperObj.accountHolderName+'","account_number":"'+warpperObj.accountNumber+'","routing_number":"'+warpperObj.routingNumber+'","account_type":"'+warpperObj.accountType+'"}}');
        system.debug('Body => '+req.getBody());
        HTTP http = new HTTP();
        HTTPResponse Response = new HTTPResponse();
        req.setTimeout(120000);
        Response = http.send(req);
        
        system.debug(Response.getStatusCode());
        system.debug(Response.getBody());
        if(response.getStatusCode() == 201){
            Map<String, Object> echeckPayMethodMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            system.debug('echeckPayMethodMap -> '+echeckPayMethodMap);
            system.debug('paymethod_token -> '+echeckPayMethodMap.get('paymethod_token'));
            /*Payment_Method__c payMethod = new Payment_Method__c();
            payMethod.Payment_Method_Token__c = (String)echeckPayMethodMap.get('paymethod_token');
            payMethod.Account__c = warpperObj.billing.AcctSeed__Customer__c;
            payMethod.Name_On_Card__c = (String)echeckPayMethodMap.get('name_on_card');
            payMethod.Last_4_Account_Number__c	 = (String)echeckPayMethodMap.get('last_4_account_number');
            payMethod.Expiry_Month__c = (Decimal)echeckPayMethodMap.get('expire_month');
            payMethod.Expiry_Year__c = (Decimal)echeckPayMethodMap.get('expire_year');
            payMethod.Card_Type__c = (String)echeckPayMethodMap.get('card_type');
            insert payMethod;
            return (String)echeckPayMethodMap.get('paymethod_token');*/
            return echeckPayMethodMap;
        }
        return null;
    }
    
    public static void getCustomerPaymethods(String cstToken){
        String customerToken = cstToken;
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
        req.setMethod('GET');
        req.setHeader('X-Forte-Auth-Organization-Id', organizationID);
        req.setHeader('Accept', 'application/json');
        // authorization is done using credentials
        String header = 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(AccessId+':'+AccessKey));
        req.setHeader('Authorization', header);
        
        HTTP http = new HTTP();
        HTTPResponse Response = new HTTPResponse();
        req.setTimeout(120000);
        Response = http.send(req);
        
        system.debug(Response.getStatusCode());
        if(response.getStatusCode() == 200){
            system.debug(response.getBody());
            Map<String, Object> customerMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            system.debug('customerMap -> '+customerMap.get('results'));
        }
    }
    
    public static ForteUtilNew createTransactionInDex(Decimal totalAmountDue,String ipAddress, PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj){
        
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
        string endPoint = baseURI+'/organizations/'+organizationID+'/locations/'+locationID+'/transactions/';
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setHeader('X-Forte-Auth-Organization-Id', organizationID);
        req.setHeader('Accept', 'application/json');
        // authorization is done using credentials
        String header = 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(AccessId+':'+AccessKey));
        req.setHeader('Authorization', header);
        req.setTimeout(120000);
        
        String body = '{"action":"sale","authorization_amount":'+ totalAmountDue +',"customer_ip_address": "' + ipAddress +'",';
        body +='"billing_address":{"company_name": "' + warpperObj.firmName + '"},';//"first_name": "'+ warpperObj.firstName +'","last_name": "'+ warpperObj.lastName +'",
        
        body +='"reference_id":"'+warpperObj.invoiceId+'",';
        body +='"order_number":"'+warpperObj.invoiceId + '-' + (warpperObj.nextPaymentDate != null ? warpperObj.nextPaymentDate : '')+'",';
        body +='"xdata":{"xdata_1": "'+ warpperObj.invoiceId +'","xdata_2": "'+ warpperObj.firmId +'","xdata_3": "'+ warpperObj.firmName +'"},';
        system.debug('warpperObj.paymentTypeVar -> '+warpperObj.paymentTypeVar);
        if(warpperObj.paymentTypeVar=='check' || (warpperObj.paymentTypeVar == 'Existing' && warpperObj.accountNumber !=null)){
            body += '"echeck":{"sec_code": "PPD"},"paymethod_token":"'+warpperObj.payMethodToken+'"}';
        }else if(warpperObj.paymentTypeVar=='creditCard' || (warpperObj.paymentTypeVar == 'Existing' && warpperObj.cardNumber !=null)){
            body += '"paymethod_token":"'+warpperObj.payMethodToken+'"}';
        }
        
        system.debug('Body => '+body);
        req.setBody(body);
        
        String response;
        Http con = new Http();
        HttpResponse hs = new HttpResponse();
        if(!Test.isRunningTest()){
            hs = con.send(req);
            response = hs.getBody();
            system.debug('StatusCode -> '+hs.getStatusCode());
            system.debug('Body -> '+hs.getBody());
            if(hs.getStatusCode() == 201){
                Map<String, Object> transactionMap = (Map<String, Object>)JSON.deserializeUntyped(hs.getBody());
                system.debug('transactionMap -> '+transactionMap);
                system.debug('transaction_id -> '+transactionMap.get('transaction_id'));
        }
        }else{
            response='{'+
                '"transaction_id": "trn_c3cc3cb2-5b58-46fb-a530-cca9c998d5a3",'+
                '"location_id": "loc_195168",'+
                '"action": "sale",'+
                '"authorization_amount": 109.49,'+
                '"billing_address": {'+
                ' "first_name": "Emmett",'+
                '"last_name": "Brown"'+
                '},'+
                '"echeck": {'+
                '"account_holder": "Emmett Brown",'+
                '"masked_account_number": "****7852",'+
                '"routing_number": "222371863",'+
                '"account_type": "checking",'+
                '"sec_code": "WEB"'+
                '},'+
                '"response": {'+
                '"environment": "sandbox",'+
                '"response_type": "A",'+
                '"response_code": "'+ (warpperObj.firstName=='APPROVED'?'A01':'R01') + '",'+
                '"response_desc": "'+ (warpperObj.firstName=='APPROVED'?'APPROVED':'REJECTED') + '",'+
                '"authorization_code": "17058729",'+
                '"preauth_result": "POS",'+
                '"preauth_desc": "P70:VALIDATED"'+
                '}'+
                '}';
        }
        ForteUtilNew util = ForteUtilNew.parse(response);
        return util;
        

    }
    
    public static ForteUtilNew createForceTransactionUsingPaymentToken(Decimal totalAmountDue,String ipAddress,PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper warpperObj){
        
        if(runningInASandbox == null){
            runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        }
        
        HttpRequest http = new HttpRequest();
        if(!runningInASandbox){
            http.setEndpoint(Label.Forte_Transaction_Force_URL);
        }else{
            http.setEndpoint(Label.Forte_Transaction_Force_URL_Sandbox);
        }
        http.setMethod('POST');
        http.setHeader('Content-Type', 'application/json');
        
        Blob headerValue; 
        
        if(!runningInASandbox){
            headerValue = Blob.valueOf(Label.Forte_API_Access_Id + ':' + Label.Forte_API_Secure_Key);
        }else{
            headerValue = Blob.valueOf(Label.Forte_API_Access_Id_Sandbox + ':' + Label.Forte_API_Secure_Key_Sandbox);
        }
        
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue) +'';
        
        if(!runningInASandbox){
            http.setHeader('X-Forte-Auth-Organization-Id',Label.Forte_API_Organization_Id);
        }else{
            http.setHeader('X-Forte-Auth-Organization-Id',Label.Forte_API_Organization_Id_Sandbox);
        }
        
        http.setHeader('Authorization', authorizationHeader);
        
        http.setTimeout(120000);
        
        String body = '{"action":"force","authorization_amount":'+ totalAmountDue +',"customer_ip_address": "' + ipAddress +'",';
        body +='"billing_address":{"company_name": "' + warpperObj.firmName + '"},';//"first_name": "'+ warpperObj.firstName +'","last_name": "'+ warpperObj.lastName +'",
        
        body +='"reference_id":"'+warpperObj.invoiceId+'",';
        //body +='"order_number":"'+warpperObj.invoiceId+'",';
        body +='"order_number":"'+warpperObj.invoiceId + '-' + (warpperObj.nextPaymentDate != null ? warpperObj.nextPaymentDate : '')+'",';
        body +='"xdata":{"xdata_1": "'+ warpperObj.invoiceId +'","xdata_2": "'+ warpperObj.firmId +'","xdata_3": "'+ warpperObj.firmName +'"},';
        
        if(warpperObj.paymentTypeVar=='check' || (warpperObj.paymentTypeVar == 'Existing' && warpperObj.accountNumber !=null)){
            body +='"echeck":{"sec_code": "WEB"},"paymethod_token": "'+warpperObj.payMethodToken+'"}';
        }else if(warpperObj.paymentTypeVar=='creditCard' || (warpperObj.paymentTypeVar == 'Existing' && warpperObj.cardNumber !=null)){
            body +='"paymethod_token": "'+warpperObj.payMethodToken+'"}';
        }
        
        http.setBody(body);
        
        String response;
        Http con = new Http();
        HttpResponse hs = new HttpResponse();
        if(!Test.isRunningTest()){
            hs = con.send(http);
            response = hs.getBody();
            System.debug(response);
        }else{
            response='{'+
                '"transaction_id": "trn_c3cc3cb2-5b58-46fb-a530-cca9c998d5a3",'+
                '"location_id": "loc_195168",'+
                '"action": "sale",'+
                '"authorization_amount": 109.49,'+
                '"billing_address": {'+
                ' "first_name": "Emmett",'+
                '"last_name": "Brown"'+
                '},'+
                '"echeck": {'+
                '"account_holder": "Emmett Brown",'+
                '"masked_account_number": "****7852",'+
                '"routing_number": "222371863",'+
                '"account_type": "checking",'+
                '"sec_code": "WEB"'+
                '},'+
                '"response": {'+
                '"environment": "sandbox",'+
                '"response_type": "A",'+
                '"response_code": "'+ (warpperObj.firstName=='APPROVED'?'A01':'R01') + '",'+
                '"response_desc": "'+ (warpperObj.firstName=='APPROVED'?'APPROVED':'REJECTED') + '",'+
                '"authorization_code": "17058729",'+
                '"preauth_result": "POS",'+
                '"preauth_desc": "P70:VALIDATED"'+
                '}'+
                '}';
        }
        ForteUtilNew util = ForteUtilNew.parse(response);
        return util;
        
    }
    
    public static Map<String, Object> updateCardDetsilsOnForte(PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper wrapperObj) {
        String customerToken = wrapperObj.customerToken;
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
        string endPoint = baseURI+'/organizations/'+organizationID+'/locations/'+locationID+'/customers/'+customerToken+'/paymethods/'+wrapperObj.payMethodToken;
        req.setEndpoint(endPoint);
        req.setMethod('PUT');
        req.setHeader('Content-Type','application/json');
        req.setHeader('X-Forte-Auth-Organization-Id', organizationID);
        req.setHeader('Accept', 'application/json');
        // authorization is done using credentials
        String header = 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(AccessId+':'+AccessKey));
        req.setHeader('Authorization', header);
        req.setBody( '{"card": {"expire_month":'+wrapperObj.expireMonth+',"expire_year":'+wrapperObj.expireYear+',"card_verification_value": "'+wrapperObj.verificationNumber+'"}}');//'+wrapperObj.verificationNumber+'

        HTTP http = new HTTP();
        HTTPResponse Response = new HTTPResponse();
        req.setTimeout(120000);
        Response = http.send(req);
        
        system.debug(Response.getStatusCode());
        system.debug(Response.getBody());
        if(response.getStatusCode() == 200){
            Map<String, Object> updateCardResponseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            system.debug('updateCardResponseMap -> '+updateCardResponseMap);
            system.debug('KeySet -> '+updateCardResponseMap.keySet());
            return updateCardResponseMap;
        }
        return null;
    }
    public static String deletePaymentMethodForte(PaymentGatewayClass.PaymentGateway_Ctrl_Wrapper wrapperObj) {
        String customerToken = wrapperObj.customerToken;
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
        string endPoint = baseURI+'/organizations/'+organizationID+'/locations/'+locationID+'/customers/'+customerToken+'/paymethods/'+wrapperObj.payMethodToken;
        req.setEndpoint(endPoint);
        req.setMethod('DELETE');
        req.setHeader('Content-Type','application/json');
        req.setHeader('X-Forte-Auth-Organization-Id', organizationID);
        req.setHeader('Accept', 'application/json');
        // authorization is done using credentials
        String header = 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(AccessId+':'+AccessKey));
        req.setHeader('Authorization', header);
        //req.setBody( '{"card": {"expire_month":'+wrapperObj.expireMonth+',"expire_year":'+wrapperObj.expireYear+',"card_verification_value": "'+wrapperObj.verificationNumber+'"}}');

        HTTP http = new HTTP();
        HTTPResponse Response = new HTTPResponse();
        req.setTimeout(120000);
        Response = http.send(req);
        
        system.debug(Response.getStatusCode());
        system.debug(Response.getBody());
        if(response.getStatusCode() == 200){
            Map<String, Object> deleteCardResponseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            system.debug('deleteCardResponseMap -> '+deleteCardResponseMap);
            system.debug('KeySet -> '+deleteCardResponseMap.keySet());
            return 'success';
        }
        return null;
    }

    public static ForteUtilNew parse(String json) {
        return (ForteUtilNew) System.JSON.deserialize(json, ForteUtilNew.class);
    }
}