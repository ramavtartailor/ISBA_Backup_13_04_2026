@RestResource(urlMapping='/createContentVersion/*')
global class CreateAndRetriveContentVersion {
    @HttpPost
    global static void postRecords(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String RequestedBody = req.requestBody.toString();
        try{
            system.debug('RequestedBody -- > ' + RequestedBody);
            object bodyRequest = JSON.deserializeUntyped(RequestedBody);
            
            Map<String,Object> Requestedmap = (Map<String,Object>) bodyRequest;
            
            Object recordList = (object) Requestedmap.get('records');
            List<Sobject> ObjLis;
            if(String.isNotBlank(String.valueOf(recordList))){
                ObjLis = (List<Sobject>)Json.deserialize(JSON.serialize(recordList),List<Sobject>.class);
            }
            String actionType = (String) Requestedmap.get('type');
            String dmlType = (String) Requestedmap.get('dml');
            String fileName = (String) Requestedmap.get('fileName');
            String queryStr = (String) Requestedmap.get('queryStr');
            String documentId = (String) Requestedmap.get('cdId');
            String versionData = (String) Requestedmap.get('vaesionData');
            String relatedRecordId = (String) Requestedmap.get('relatedRecordId');
            String result ;
            if(actionType == 'Query' || actionType == 'Deletion'){
                if(String.isNotBlank(documentId) && actionType == 'Deletion'){
                    ContentDocument cd = new ContentDocument();
                    cd.Id = documentId;
                    delete cd;
                }
                List<ContentDocumentLink> cdlinks = new List<ContentDocumentLink>([SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: relatedRecordId]);
                Set<String> cdIds = new Set<String>();
                for(ContentDocumentLink cdl: cdlinks){
                    cdIds.add(cdl.ContentDocumentId);
                }
                List<ContentVersion> cvList = new List<ContentVersion>([SELECT Id, Title, ContentDocumentId, Document_Type__c, CreatedDate, ContentSize  FROM ContentVersion WHERE ContentDocumentId IN: cdIds AND (Document_Type__c = 'Policy Document' OR Document_Type__c = 'Claims Supplemental' OR Document_Type__c = 'Potential Claims Supplemental' OR Document_Type__c = 'AOP Documents') order by CreatedDate]);
                result = JSON.serialize(cvList);
            }
            else if(actionType =='queryRecords'){
                List<Sobject> sobjList = Database.Query(queryStr);
                result = JSON.serialize(sobjList);
            }
            else if(actionType == 'dmlLawyer'){
                if(dmlType.equalsIgnoreCase('Upsert')){
                    for(Sobject obj: ObjLis){
                        if(obj.get('Record_Id__c') != null){
                            obj.put('Id',obj.get('Record_Id__c'));
                        }
                    }
                    database.upsert(ObjLis);
                }
                else if(dmlType.equalsIgnoreCase('Delete')){
					database.delete(ObjLis);                    
                }
                result = 'success';
            }
            else{
                contentVersion cv = new contentVersion();
                cv.Title = fileName.substringBeforeLast('.');
                cv.VersionData = EncodingUtil.base64decode(versionData);
                cv.PathOnClient = fileName; 
                
                insert cv;
                List<Sobject> records = new List<Sobject>();
                records.add(cv);
                result = JSON.serialize(records);
            }
             
            res.responseBody = Blob.valueOf(result);
            res.statusCode = 200;
        }
        catch(Exception e){
            res.statusCode = 500;
            system.debug('Error : '+e.getMessage()+'at => '+e.getLineNumber());
            res.responseBody = Blob.valueOf('Error : '+e.getMessage());
        }
        
    }
}