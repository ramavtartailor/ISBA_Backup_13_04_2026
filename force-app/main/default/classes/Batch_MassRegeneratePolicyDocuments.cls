public class Batch_MassRegeneratePolicyDocuments implements Database.Batchable<Sobject>{
	public String soql;
    public String documentType;
    public Batch_MassRegeneratePolicyDocuments(String soql){
        this.documentType = 'All';
    }
    public Batch_MassRegeneratePolicyDocuments(String soql,String documentType){
        this.soql = soql;
        this.documentType = documentType;
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(soql);
    }
    public void execute(Database.BatchableContext BC, List<sObject> batch) {
        Map<Id,Id> contentDocumentIds = new Map<Id,Id>();
        Map<String,Id> documentContentIds = new Map<String,Id>();
        Set<Id> policyIds = new Set<Id>();
        for(Policy__c pol : (List<Policy__c>)batch){
            policyIds.add(pol.Id);
        }
        for(ContentDocumentLink cdl : [select id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId in: policyIds]){
            contentDocumentIds.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
        }
        for(ContentVersion cv : [select id,ContentDocumentId,Document_Type__c from ContentVersion where ContentDocumentId in: contentDocumentIds.keySet() and IsLatest = true and (Document_Type__c = 'Policy Letter' OR Document_Type__c = 'NAS EOC' OR Document_Type__c = 'Certificate Of Insurance' OR Document_Type__c = 'Declaration Page')]){
            documentContentIds.put(contentDocumentIds.get(cv.ContentDocumentId) + '-' + cv.Document_Type__c,cv.ContentDocumentId);
        }
        for(Policy__c pol : (List<Policy__c>)batch){
            if(documentType == 'NAS EOC'){
                Id documentId; 
                if(documentContentIds.containsKey('NAS EOC')){
                    documentId = documentContentIds.get('NAS EOC');
                }
                PolicyDocumentsUtility.createNASEOC(pol.Id, pol.NAS_EOC_Version_Formula__c  ,pol.Account__c,documentId);
            }
        }
    }
    public void finish(Database.BatchableContext BC) { 
    }
}