public class PrintBillingsPDFExt {
    public List<AcctSeed__Billing__c> billings{get;private set;}
    public String pdf{get;set;}
    public PrintBillingsPDFExt(ApexPages.StandardSetController stdSetController){
        // Returns all selected records
        billings = (List<AcctSeed__Billing__c>) stdSetController.getSelected();
    }
    
    public void printBillings(){
        List<Blob> documentsToMerge = new List<Blob>();
        Blob body;
        for(AcctSeed__Billing__c bill : [select id,AcctSeed__Billing_Format__r.AcctSeed__Visualforce_PDF_Page__c  from AcctSeed__Billing__c where id in: billings]){
            ContentVersion content = new ContentVersion();
            PageReference pg = new PageReference('/apex/'+bill.AcctSeed__Billing_Format__r.AcctSeed__Visualforce_PDF_Page__c+'?id='+bill.Id+'&IsPrint=true');
            try {
                body = pg.getContent();
            } catch (VisualforceException e) {
                body = Blob.valueOf('Some Error Occurred While PDF Generation.');
            }
            if(body!=null){
                documentsToMerge.add(body);
                body = null;
            }
        }
        if(documentsToMerge.size()>0){
            DocumentBundleUtility.DocumentBundleUtilityWrapper wrapper = DocumentBundleUtility.mergePDF(documentsToMerge);
            if(wrapper.isSuccess){
                pdf = EncodingUtil.Base64Encode(wrapper.mergedDocument);
            }
        }
                
    }
}