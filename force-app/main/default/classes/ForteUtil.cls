public class ForteUtil {
    
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
    public static ForteUtil createTransaction(Decimal totalAmountDue,String ipAddress,PaymentGateway_Ctrl.PaymentGateway_Ctrl_Wrapper warpperObj){
        
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
        //body +='"billing_address":{"first_name": "'+ warpperObj.firstName +'","last_name": "'+ warpperObj.lastName +'","company_name": "' + warpperObj.firmName + '"},';
        body +='"billing_address":{"first_name": "'+ warpperObj.firstName +'","last_name": "'+ warpperObj.lastName + '"},';
        
        body +='"reference_id":"'+warpperObj.invoiceId+'",';
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
        ForteUtil util = ForteUtil.parse(response);
        return util;
        
    }
    
    public static ForteUtil createForceTransaction(Decimal totalAmountDue,String ipAddress,PaymentGateway_Ctrl.PaymentGateway_Ctrl_Wrapper warpperObj){
        
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
        //body +='"billing_address":{"first_name": "'+ warpperObj.firstName +'","last_name": "'+ warpperObj.lastName +'","company_name": "' + warpperObj.firmName + '"},';
        body +='"billing_address":{"first_name": "'+ warpperObj.firstName +'","last_name": "'+ warpperObj.lastName + '"},';
        
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
        ForteUtil util = ForteUtil.parse(response);
        return util;
        
    }
    
    public static ForteUtil authorizeTransaction(Decimal totalAmountDue,String ipAddress,PaymentGateway_Ctrl.PaymentGateway_Ctrl_Wrapper warpperObj){
        
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
        
        String body = '{"action":"verify","authorization_amount":'+ '"' + verifyAmount + '"' +',"customer_ip_address": "' + ipAddress +'",';
        body +='"billing_address":{"first_name": "'+ warpperObj.firstName +'","last_name": "'+ warpperObj.lastName +'"},';
        
        body +='"reference_id":"'+warpperObj.invoiceId+'",';
        //body +='"order_number":"'+warpperObj.invoiceId+'",';
        body +='"order_number":"'+warpperObj.invoiceId + '-' + (warpperObj.nextPaymentDate != null ? warpperObj.nextPaymentDate : '')+'",';
        body +='"xdata":{"xdata_1": "'+ warpperObj.invoiceId +'","xdata_2": "'+ warpperObj.firmId +'","xdata_3": "'+ warpperObj.firmName +'"},';
        
        if(warpperObj.paymentTypeVar=='check' || (warpperObj.paymentTypeVar == 'Existing' && warpperObj.accountNumber !=null)){
            body +='"echeck":{"account_type": "'+ warpperObj.accountType +'","routing_number": "'+ warpperObj.routingNumber +'","account_number": "'+ warpperObj.accountNumber +'","account_holder": "'+ warpperObj.accountHolderName +'"}}';
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
        ForteUtil util = ForteUtil.parse(response);
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
                '    "status": "rejected",'+
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
                http.setEndpoint(Label.Forte_Transaction_GET_URL + '?filter=start_received_date+eq+\''+ TenDayBeforeDate.year() + '-' + TenDayBeforeDate.month() + '-' + TenDayBeforeDate.day() +'\'+and+end_received_date+eq+\'' + todayDate.year() + '-' + todayDate.month() + '-' + todayDate.day() + '\'' );
            }else{
                http.setEndpoint(Label.Forte_Transaction_GET_URL_Sandbox +  '?filter=start_received_date+eq+\''+ TenDayBeforeDate.year() + '-' + TenDayBeforeDate.month() + '-' + TenDayBeforeDate.day() +'\'+and+end_received_date+eq+\'' + todayDate.year() + '-' + todayDate.month() + '-' + todayDate.day() + '\'' );
            }
        }
        
        system.debug(URL);
        
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
        system.debug(authorizationHeader);
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
                '"status": "Funded",'+
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
    
    public static ForteUtil parse(String json) {
        return (ForteUtil) System.JSON.deserialize(json, ForteUtil.class);
    }
}