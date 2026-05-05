@RestResource(urlMapping='/posting/*')
global class PostingHelper {
    @HttpPost
    global static void postRecords(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String RequestedBody = req.requestBody.toString();
        try{
            system.debug('RequestedBody -- > ' + RequestedBody);
            object bodyRequest = JSON.deserializeUntyped(RequestedBody);
            
            Map<String,Object> Requestedmap = (Map<String,Object>) bodyRequest;
            
            Object recordList = (object) Requestedmap.get('Records');
            List<Sobject> ObjLis = (List<Sobject>)Json.deserialize(JSON.serialize(recordList),List<Sobject>.class);
            String objectName = (String) Requestedmap.get('obj');
             AcctSeed.PostResult[] postResults;
            if(objectName == 'AcctSeed__Cash_Receipt__c'){
                // Post the cash receipts
                Insert ObjLis;
                postResults = AcctSeed.CashReceiptPostService.postCashReceipts(ObjLis);
            }
            else if(objectName == 'AcctSeed__Billing_Cash_Receipt__c'){
                Insert ObjLis; 
                postResults = AcctSeed.BillingCashReceiptPostService.postBillingCashReceipts(ObjLis);
            }
            system.debug('postResults => '+postResults);
            res.responseBody = Blob.valueOf(JSON.serialize(ObjLis));
            res.statusCode = 200;
        }
        catch(Exception e){
            res.statusCode = 500;
            system.debug('Error : '+e.getMessage());
            res.responseBody = Blob.valueOf('Error : '+e.getMessage());
        }
        
    }
}