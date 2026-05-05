public class ContentDocumentLinkTriggerHandler {
    public static void onAfterInsert(List<ContentDocumentLink> newList, Map<Id,ContentDocumentLink> newMap){
        countNumberOfFilesForNotes(newList);
        //autoAddAdminUserAccessForDocuments(newList);
    }
    public static void countNumberOfFilesForNotes(List<ContentDocumentLink> newList){
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = m.get('Note__c') ;
        Schema.DescribeSObjectResult r = s.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        System.debug('keyPrefix:'+keyPrefix);
        System.debug('newList:'+newList);
         Map<Id,Note__c> countFilesMap = new Map<Id,Note__c>();
        for(ContentDocumentLink cdl : newList){
            if(String.valueOf(cdl.LinkedEntityId).startsWith(keyPrefix)){
                System.debug('cdl.LinkedEntityId:'+cdl.LinkedEntityId);
                if(countFilesMap.containsKey(cdl.LinkedEntityId)){
                    Note__c note = countFilesMap.get(cdl.LinkedEntityId);
                    note.of_Attachments__c+=1;
                    countFilesMap.put(cdl.LinkedEntityId,note);
                }else{
                    countFilesMap.put(cdl.LinkedEntityId,new Note__c(Id=cdl.LinkedEntityId , of_Attachments__c = 1));
                }
            }
        }
        update countFilesMap.values();
    }
    /*public static void autoAddAdminUserAccessForDocuments(List<ContentDocumentLink> newList){
        List<ContentDocumentLink> newContentDocumentLinks = new List<ContentDocumentLink>();
        Set<Id> addedContentDocumentLinks = new Set<Id>();
        for(ContentDocumentLink link : newList){
            if(!addedContentDocumentLinks.contains(link.ContentDocumentId) && !String.valueOf(link.LinkedEntityId).startsWith('005')){
                addedContentDocumentLinks.add(link.ContentDocumentId);
                for(String str : Label.All_Documents_Access_Users.split(';')){
                    ContentDocumentLink newLink = new ContentDocumentLink();
                    newLink.ContentDocumentId = link.ContentDocumentId;
                    newLink.LinkedEntityId = str;
                    newLink.ShareType = 'C';
                    newContentDocumentLinks.add(newLink);
                }
            }
        }
        System.debug(newContentDocumentLinks);
        if(newContentDocumentLinks.size() > 0){
            Database.insert(newContentDocumentLinks,false);
        }
    }*/
}