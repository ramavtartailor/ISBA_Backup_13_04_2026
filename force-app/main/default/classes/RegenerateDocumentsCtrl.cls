public class RegenerateDocumentsCtrl {
	@AuraEnabled
    public static void regenerateDocs(String recordId){
        SavePoint sp = Database.setSavepoint();
        try{
            String objName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            if(objName == 'Policy__c'){
                Policy__c policy = [select id,Account__c,Policy_Document_Version__c,Effective_Date__c, NAS_EOC_Version_Formula__c   from Policy__c where id =: recordId];
                Set<Id> contentDocumentIds = new Set<Id>();
                Map<String,Id> documentContentIds = new Map<String,Id>();
                Set<Id> contentDocumentIdsTEMP = new Set<Id>();
                Map<String,Id> documentContentIdsTEMP = new Map<String,Id>();
                for(ContentDocumentLink cdl : [select id,ContentDocumentId from ContentDocumentLink where LinkedEntityId =: recordId]){
                    contentDocumentIds.add(cdl.ContentDocumentId);
                }
                for(ContentVersion cv : [select id,ContentDocumentId,Document_Type__c from ContentVersion where ContentDocumentId in: contentDocumentIds and IsLatest = true and (Document_Type__c = 'Policy Letter' OR Document_Type__c = 'NAS EOC' OR Document_Type__c = 'Certificate Of Insurance' OR Document_Type__c = 'Declaration Page')]){
                    documentContentIds.put(cv.Document_Type__c,cv.ContentDocumentId);
                }
                Id documentId;
                /*if(documentContentIds.containsKey('Policy Letter')){
                    documentId = documentContentIds.get('Policy Letter');
                }
                PolicyDocumentsUtility.createPolicyLetter(recordId, policy.Policy_Document_Version__c,policy.Account__c,documentId);
                
                documentId = null;*/
                if(documentContentIds.containsKey('Declaration Page')){
                    documentId = documentContentIds.get('Declaration Page');
                }
                System.debug(documentId);
                PolicyDocumentsUtility.createDeclarationPage(recordId, policy.Policy_Document_Version__c,policy.Account__c,documentId);
                
                documentId = null;
                if(documentContentIds.containsKey('NAS EOC')){
                    documentId = documentContentIds.get('NAS EOC');
                }
                PolicyDocumentsUtility.createNASEOC(recordId, policy.NAS_EOC_Version_Formula__c  ,policy.Account__c,documentId);
                
                documentId = null;
                if(documentContentIds.containsKey('Certificate Of Insurance')){
                    documentId = documentContentIds.get('Certificate Of Insurance');
                }
                PolicyDocumentsUtility.createCertificationOfInsurance(recordId, policy.Policy_Document_Version__c,policy.Account__c,documentId);
            }else if(objName == 'Policy_Endorsement__c'){
                Policy_Endorsement__c endorsement = [select id,Attachment_Record_Id__c,Policy__c,Name,Endorsement_Number__c,Endorsement_Version__c,Policy__r.Account__c from Policy_Endorsement__c where id =: recordId];
                Id documentId;
                List<ContentVersion> cvList = [select id,ContentDocumentId from ContentVersion where Endorsement_Id__c=: recordId and IsLatest = true];
                if(cvList.size()>0){ 
                    documentId = cvList[0].ContentDocumentId;
                }
                PolicyDocumentsUtility.createEndorsement(endorsement.id,endorsement.Policy__c,endorsement.Name,endorsement.Endorsement_Number__c,endorsement.Endorsement_Version__c,endorsement.Policy__r.Account__c,documentId, recordId);
            }
        }catch(DmlException e){
            System.debug('Error----'+e.getMessage());
            System.debug('LIne-----'+e.getLineNumber());
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString()) ;
        }catch(LimitException e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString()) ;
        }catch(ListException e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString()) ;
        }catch(NullPointerException e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString()) ;
        }catch(QueryException e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString()) ;
        }
    }
}