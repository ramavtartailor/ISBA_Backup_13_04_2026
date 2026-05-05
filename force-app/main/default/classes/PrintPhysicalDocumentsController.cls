public class PrintPhysicalDocumentsController {
    public Boolean isPrinted{get;set;}
    public string selectedFileIds{get;set;}
    public List<SearchFilesControllerWrapper> searchedResults{get;set;}
    
    public PrintPhysicalDocumentsController(){
        isPrinted = false;
        fetchFiles();
    }
        
    public void fetchFiles(){
        searchedResults = new List<SearchFilesControllerWrapper>();
        
        String query = 'Select Id,CreatedDate, Title,Policy_Number__c,Document_Type__c,Printed__c,Account__r.Name, Account__c,'+
            'Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingCountry, Account__r.BillingPostalCode,'+
            ' Account__r.ShippingStreet, Account__r.ShippingCity, Account__r.ShippingState, Account__r.ShippingCountry, Account__r.ShippingPostalCode'+
            ' FROM ContentVersion WHERE Physical_document_delivery__c = true  AND Printed__c = '+isPrinted+' LIMIT 1000';
        System.debug(query);
        List<ContentVersion> lstOffiles = database.query(query);
        system.debug('lstOffiles-----'+lstOffiles);
        for(ContentVersion file : lstOffiles){
            SearchFilesControllerWrapper wrapper = new SearchFilesControllerWrapper();
            wrapper.document = file;            
            wrapper.billingAddress = file.Account__r.BillingStreet == null ? '' :file.Account__r.BillingStreet+'\n'+file.Account__r.BillingCity+', '+file.Account__r.BillingState+' '+file.Account__r.BillingPostalCode;
            wrapper.mailingAddress = file.Account__r.ShippingStreet == null ? '' :file.Account__r.ShippingStreet+'\n'+file.Account__r.ShippingCity+', '+file.Account__r.ShippingState+' '+file.Account__r.ShippingPostalCode;
            wrapper.isSelected = false;
            searchedResults.add(wrapper);
        }
         
    }
    
    public PageReference printSelectedFiles(){
        try{
            List<String> cvIdSet = new List<String>();
            List<ContentVersion> cvList = new List<ContentVersion>();
            List<Blob> documentsToBeMerged = new List<Blob>();
            if(String.isNotBlank(selectedFileIds)){
                cvIdSet.addAll(selectedFileIds.split(','));
                system.debug('selectedFiles Size--'+cvIdSet.size());
            }
            if(!cvIdSet.isEmpty()){
                for(ContentVersion cv : [Select Id,Printed__c,VersionData FROM ContentVersion WHERE ID IN: cvIdSet]){
                    ContentVersion cvRec = new ContentVersion(Id = cv.id);
                    cvRec.Printed__c = true;
                    cvList.add(cvRec);
                    documentsToBeMerged.add(cv.VersionData);
                }
            }
            if(!documentsToBeMerged.isEmpty()){
                
                DocumentBundleUtility.DocumentBundleUtilityWrapper wrapper = DocumentBundleUtility.mergePDF(documentsToBeMerged);
                if(wrapper.isSuccess){
                    if(!cvList.isEmpty()){
                        update cvList;
                    }
                    ContentVersion content = new ContentVersion();
                    content.VersionData = wrapper.mergedDocument;
                    string title = '';
                    /*if(String.isBlank(searchDocumentType)){
                        title = 'Close Out Letter.pdf';
                    }else {*/
                        title = 'Physical Documents'+'.pdf';
                    //}
                    content.Title = title;
                    content.PathOnClient = title;
                    insert content;
                    System.debug(content.Id);
                    ContentDistribution cd = new ContentDistribution();
                    cd.Name = title;
                    cd.ContentVersionId = content.Id;
                    cd.PreferencesAllowViewInBrowser= true;
                    cd.PreferencesLinkLatestVersion=true;
                    cd.PreferencesNotifyOnVisit=false;
                    cd.PreferencesPasswordRequired=false;
                    cd.PreferencesAllowOriginalDownload= false;
                    cd.PreferencesAllowPDFDownload = true;
                    cd.PreferencesExpires = true;
                    cd.ExpiryDate = System.now().addSeconds(90);
                    insert cd;
                    
                    string previewLink = [select id,DistributionPublicUrl from ContentDistribution where id =: cd.id].DistributionPublicUrl;
                    PageReference pr = new PageReference(previewLink);
                    return pr;
                    
                }else{
                    return null;
                }
            }else {
                return null;
            }
        }catch(Exception ex){
            system.debug('error---'+ex.getMessage()+'---line--'+ex.getLineNumber());
            return null;
        }
    }
    
    public class SearchFilesControllerWrapper{
        public ContentVersion document{get;set;}
        public String billingAddress{get;set;}
        public String mailingAddress{get;set;}
        public boolean isSelected{get;set;}
         
        public SearchFilesControllerWrapper(){
        }
    }

}