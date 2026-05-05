global class Batch_UpdateCardknoxPaymentMethod implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{
    
    global Set<String> recordIds {get;set;}
    
    global Batch_UpdateCardknoxPaymentMethod(){
        this.recordIds = new Set<String>();
        List<Payment_Schedule__c> paySchedules = [SELECT Id,Payment_Method__c,Payment_Method__r.AcctSeed__External_Id__c FROM Payment_Schedule__c WHERE ((Billing__r.AcctSeed__Balance__c > 0  AND Status__c IN ('Pending' ,'Rejected' ,'Unpaid')) OR (Status__c = 'Paid'  AND Due_Date__c >= 2025-01-01 AND Frequency__c = 'Full')) AND Billing__r.AcctSeed__Payment_Processor__r.Name = 'Cardknox' and Payment_Schedule_Type__c != 'Physical Check' AND ((Payment_Schedule_Type__c ='Credit Card' and Payment_Method__r.AcctSeed__Expiration_Year__c > '2025' )OR Payment_Schedule_Type__c ='eCheck' )];
        for(Payment_Schedule__c ps: paySchedules){
            recordIds.add(ps.Payment_Method__c);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id,AcctSeed__External_Id__c,Token__c,Method_JSON__c FROM AcctSeed__Payment_Method__c WHERE Id IN : recordIds');
    }
    
    global void execute(Database.BatchableContext bc, List<AcctSeed__Payment_Method__c> data){
        
        List<AcctSeed__Payment_Method__c> updatedPaymentMethodList = new List<AcctSeed__Payment_Method__c>();
        Cardknox_Creds__c creds = Cardknox_Creds__c.getOrgDefaults();
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String baseURL = '';
        String xKey = '';
                    
        if(runningInASandbox){
            baseURL = creds.SB_Base_URL__c;
            xKey = creds.SB_xKey__c;
        }
        else{
            baseURL = creds.Base_URL__c;
            xKey = creds.xKey__c;
        }
        
        HttpRequest http = new HttpRequest();
        http.setEndpoint(baseURL+'/GetPaymentMethod');
        http.setMethod('POST');
        http.setHeader('Content-Type', 'application/json');
        http.setHeader('X-Recurring-Api-Version', '2.1');
        http.setHeader('Authorization', xKey);
        
        for(AcctSeed__Payment_Method__c pm: data){
            String body = '{'+
                '   "SoftwareName" : "'+creds.Software_Name__c+'",'+
                '   "SoftwareVersion" : "'+creds.Software_Version__c+'",'+
                '	"ShowDeleted" : false,'+
                '   "PaymentMethodId" : "'+pm.AcctSeed__External_Id__c+'"}';
            
            http.setTimeout(120000);
            http.setBody(body);
            
            Http ht = new Http();
            HttpResponse hResp = new HttpResponse();
            if(test.isRunningTest()){
                hResp.setStatusCode(200);
                hResp.setBody('{'+
                              '    "Token": "r1234567890",'+
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
                pm.Token__c = String.valueOf(respMap.get('Token'));
                pm.Method_JSON__c = hResp.getBody();
                updatedPaymentMethodList.add(pm);
            }
        }
        
        
        if(!updatedPaymentMethodList.isEmpty()){
            update updatedPaymentMethodList;
        }        
        
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}