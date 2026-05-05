@RestResource(urlMapping='/InsertDeletePaymentScheduleRecords/*')
global with sharing class InsertPaymentScheduleRecords {
        @HttpPost
        global static void DMLRecords(){
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            String RequestedBody = req.requestBody.toString();
            try{
                system.debug('RequestedBody -- > ' + RequestedBody);
                object bodyRequest = JSON.deserializeUntyped(RequestedBody);
                
                Map<String,Object> Requestedmap = (Map<String,Object>) bodyRequest;
                
                Object recordList = (object) Requestedmap.get('Records');
                List<Sobject> ObjLis = (List<Sobject>)Json.deserialize(JSON.serialize(recordList),List<Sobject>.class);
                String opr = (String) Requestedmap.get('Opr');
                system.debug('Opr:'+opr) ;
                if(Opr=='insert'){
                    insert ObjLis;
                }
                else if(Opr=='update'){
                    update ObjLis;
                }
                else if(Opr=='upsert'){
                    upsert ObjLis;
                }
                else if(Opr=='delete'){
                    delete ObjLis;
                }
                
                res.responseBody = Blob.valueOf(JSON.serialize(ObjLis));
                res.statusCode = 200;
            }
            catch(DMLException e){
                res.statusCode = 500;
                system.debug(e+'=>'+e.getMessage()+' => '+e.getDmlMessage(0));
                res.responseBody = Blob.valueOf('Error : '+e.getDmlMessage(0));
            }
        }
    }