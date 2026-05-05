public class Pdf_Lib_WatermarkHelperCtrl {
    Public string watermarkText {get;set;}
    Public string url {get;set;}
    public String pdfBlob { get; set; }
    
    public Pdf_Lib_WatermarkHelperCtrl(){ 
        url = Apexpages.currentpage().getparameters().get('URL');
        String showWatermark = Apexpages.currentpage().getparameters().get('watermark');
        url = EncodingUtil.urlDecode(url, 'UTF-8');
        url = '/apex/'+url;
        System.debug(url);
        watermarkText = '';
        if(showWatermark == 'Yes'){
            watermarkText = 'Preview Copy';
        }
    }
    
    
    public void handlePrintQuotes(){
        if(url.contains('PrintQuotes')){
            string recordId = Apexpages.currentpage().getparameters().get('id');
            string qType = Apexpages.currentpage().getparameters().get('type');
            string fromPolicyBind = Apexpages.currentpage().getparameters().get('fromPolicyBind');
            string removeQuoteIds = Apexpages.currentpage().getparameters().get('removeQuoteIds');
            String contentVersionId = '';
            if(!test.isRunningTest()){
                DocumentBundleVF_Ctrl  docCtrl = new DocumentBundleVF_Ctrl();
                PageReference pr = docCtrl.printQuotes();
                
                url = String.valueOf(pr);
                contentVersionId = String.valueOf(pr).substringAfter('download/').substringBefore('?');
            }
            else{
                List<ContentVersion> cvList = new List<ContentVersion>();
                cvList = [Select Id FROM ContentVersion limit 1];
                if(cvList != null && !cvList.isEmpty()){
                    contentVersionId = cvList[0].Id;
                }
            } 
            ContentVersion cv = [SELECT VersionData, Title FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];
            
            pdfBlob = EncodingUtil.base64Encode(cv.VersionData);
        }
        System.debug(url);
        
    }
}