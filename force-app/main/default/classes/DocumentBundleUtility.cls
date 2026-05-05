public without sharing class DocumentBundleUtility {
	public static DocumentBundleUtilityWrapper mergePDF(List<Blob> documentsToBeMerged){
        DocumentBundleUtilityWrapper wrapper = new DocumentBundleUtilityWrapper();
        try{
            HttpRequest req = new HttpRequest();
            String boundary = String.valueOf(DateTime.now().getTime());
            req.setEndpoint(Label.Document_Merge_End_Point);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'multipart/form-data; boundary=----------' + boundary);
            req.setTimeout(30000);
            
            String bodyHeader = '------------' + boundary + '\r\n';
            
            String bodyFooter = '\r\n------------' + boundary + '--';
            
            String newRowString = '\r\n------------' + boundary + '\r\n';
            
            String finalBody = '';
            
            String i = '0';
            
            for(Blob doc : documentsToBeMerged){
                String body;
                if(i=='0'){
                    body = bodyHeader;
                }else{
                    body = newRowString;
                }
                if(i.length() == 1){
                    i = '0'+ i;
                }
                System.debug(i);
                body+='Content-Disposition: form-data; name="'+ i + '.pdf"; filename="' + i + '.pdf"\r\n';
                body+='Content-Type: application/pdf\r\n\r\n';
                
                finalBody+= (EncodingUtil.convertToHex(Blob.valueOf(body)) +
                             EncodingUtil.convertToHex(doc));
                i = String.valueOf(Integer.valueOf(i) + 1);
            }
            
            finalBody += EncodingUtil.convertToHex(Blob.valueOf(bodyFooter));
            
            System.debug(finalBody);
            
            req.setBodyAsBlob(EncodingUtil.convertFromHex(finalBody));
            
            Http http = new Http();
            HTTPResponse res = new HTTPResponse();
            if(test.isRunningTest()){
                res.setStatusCode(200);
                res.setBody('{}');
            }
            else{
                res = http.send(req);
            }
            
           // HTTPResponse 
            System.debug(res);
            if (res.getStatusCode() == 200) {
                wrapper.isSuccess = true;
                wrapper.mergedDocument = res.getBodyAsBlob();
            }else{
                wrapper.isSuccess = false;
                wrapper.message = res.getStatus();
                system.debug(res.getBody());
            }
            return wrapper;
        }catch(Exception e){
            wrapper.isSuccess = false;
            wrapper.message = e.getMessage() + '\n' + e.getStackTraceString();
            return wrapper;
        }
    }
    public class DocumentBundleUtilityWrapper{
        public Blob mergedDocument;
        public boolean isSuccess;
        public String message;
    }
}