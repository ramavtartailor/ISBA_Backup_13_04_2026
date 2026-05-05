public class PrintFilesController {
    public String searchDocumentType{get;set;}
    public List<SearchFilesControllerWrapper> searchedResults{get;set;}
    public string selectedFileIds{get;set;}
    
    public PrintFilesController(){
        fetchFiles();
    }
    
    public void fetchFiles(){
        searchedResults = new List<SearchFilesControllerWrapper>();
        
        String query = 'Select Id, Title,Policy_Number__c,Document_Type__c,Printed__c FROM ContentVersion';
        if(String.IsNotBlank(searchDocumentType)){
            query += ' WHERE Document_Type__c =: searchDocumentType AND Printed__c != true LIMIT 1000';
            System.debug(query);
            List<ContentVersion> lstOffiles = database.query(query);
            system.debug('lstOffiles-----'+lstOffiles);
            for(ContentVersion file : lstOffiles){
                SearchFilesControllerWrapper wrapper = new SearchFilesControllerWrapper();
                wrapper.document = file;
                wrapper.isSelected = false;
                searchedResults.add(wrapper);
            }
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
                    if(String.isBlank(searchDocumentType)){
                        title = 'Close Out Letter.pdf';
                    }else {
                        title = searchDocumentType+'.pdf';
                    }
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
    
    public List<SelectOption> getDocumentTypes(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        options.add(new SelectOption('Close Out Letter' ,'Close Out Letter'));
        options.add(new SelectOption('NOC' ,'NOC'));
        options.add(new SelectOption('Close Out Letter - NOC' ,'Close Out Letter - NOC'));
        return options;
    }
    
     public class SearchFilesControllerWrapper{
        public ContentVersion document{get;set;}
        public boolean isSelected{get;set;}
         
        public SearchFilesControllerWrapper(){
        }
    }
}