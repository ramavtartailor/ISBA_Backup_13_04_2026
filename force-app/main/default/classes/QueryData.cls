@RestResource(urlMapping='/QueryRecords/*')
global without sharing class QueryData {
    @HttpPost
    global static void QueryRecords(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String RequestedBody = req.requestBody.toString();
        system.debug('RequestedBody -- > ' + RequestedBody);
        object bodyRequest = JSON.deserializeUntyped(RequestedBody);
        Map<String,Object> Requestedmap = (Map<String,Object>) bodyRequest;
		
        String Query = String.valueOf(Requestedmap.get('Query'));
        try{
            
            List<sObject> records = new List<Sobject>();
            
            if(Query.contains('VersionData')){
                
                List<ContentVersion> cvList = (List<ContentVersion>)Database.query(Query);
                Map<String,String> cvMap = new Map<String,String>();
                if(!cvList.isEmpty()){
                    cvMap.put('Title',cvList[0].Title);
                    cvMap.put('VersionData', EncodingUtil.base64Encode(cvList[0].VersionData));
                }
                res.responseBody = Blob.valueOf(JSON.serialize(cvMap));
                res.statusCode = 200;
                
            }
            else{
                
                if(String.isNotBlank(Query))
                    records = Database.query(Query);
                
                system.debug('QueryData >==>  records => '+records);
                res.responseBody = Blob.valueOf(JSON.serialize(records));
                res.statusCode = 200;
            }
        }
        catch(Exception e){ 
            res.responseBody = Blob.valueOf('Error');
            res.statusCode = 500;
        }
    }
}