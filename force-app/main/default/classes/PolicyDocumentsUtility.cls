global without sharing class PolicyDocumentsUtility {
    webservice static void createCertificationOfInsurance(String policyId,String docVersion,String accountId,Id documentId) {
        try{
            PageReference pageRef = Page.CERTIFICATION_OF_INSURANCE_Pdf;
            pageRef.getParameters().put('id',(String)policyId);
            pageRef.getParameters().put('version',(String)docVersion);
            Blob body ;
            if (Test.IsRunningTest()){
                body = Blob.valueOf('UNIT.TEST');
            } else {
                body = pageRef.getContentAsPDF();
            }
            createContentVersion(body,'Certification Of Insurance - '+ policyId+'.pdf',policyId,accountId,'Certificate Of Insurance',documentId,null,false);
        }catch(Exception e){
            System.debug('Error Message:'+e.getMessage());
        }
    }
    webservice static void createNASEOC(String policyId,String docVersion,String accountId,Id documentId) {
        try{
            PageReference pageRef = Page.NAS_EOC_Pdf;
            pageRef.getParameters().put('id',(String)policyId);
            pageRef.getParameters().put('version',(String)docVersion);
            Blob body ;
            if (Test.IsRunningTest()){
                body = Blob.valueOf('UNIT.TEST');
            } else {
                body = pageRef.getContentAsPDF();
            }
            createContentVersion(body,'NAS EOC - '+ policyId+'.pdf',policyId,accountId,'NAS EOC',documentId,null,false);
        }catch(Exception e){
            System.debug('Error Message:'+e.getMessage());
        }
    }
    webservice static void createDeclarationPage(String policyId,String docVersion,String accountId,Id documentId) {
        try{
            PageReference pageRef = Page.Declaration_Page_Pdf;
            pageRef.getParameters().put('id',(String)policyId);
            pageRef.getParameters().put('version',(String)docVersion);
            Blob body ;
            if (Test.IsRunningTest()){
                body = Blob.valueOf('UNIT.TEST');
            } else {
                body = pageRef.getContentAsPDF();
            }
            createContentVersion(body,'Declaration Page - '+ policyId+'.pdf',policyId,accountId,'Declaration Page',documentId,null,false);
        }catch(Exception e){
            System.debug('Error Message:'+e.getMessage());
        }
    }
    webservice static void createPolicyLetter(String policyId,String docVersion,String accountId,Id documentId) {
        try{
            PageReference pageRef = Page.Policy_Letter_Pdf;
            pageRef.getParameters().put('id',(String)policyId);
            pageRef.getParameters().put('version',(String)docVersion);
            Blob body;
            if (Test.IsRunningTest()){
                body = Blob.valueOf('UNIT.TEST');
            } else {
                body = pageRef.getContentAsPDF();
            }
            createContentVersion(body,'Policy Letter - '+ policyId+'.pdf',policyId,accountId,'Policy Letter',documentId,null,false);
        }catch(Exception e){
            System.debug('Error Message:'+e.getMessage());
        }
    }
    webservice static void createQuote(String quoteId,String policyId,String pdfname,String accountId,Id documentId) {
        try{
            PageReference pageRef = Page.Quote_Pdf;
            pageRef.getParameters().put('id',(String)quoteId);
            Blob body;
            if (Test.IsRunningTest()){
                body = Blob.valueOf('UNIT.TEST');
            } else {
                body = pageRef.getContentAsPDF();
            }
            createContentVersion(body,pdfname+'.pdf',policyId,accountId,'Quote',documentId);
        }catch(Exception e){
            System.debug('Error Message:'+e.getMessage());
        }
    }
    webservice static void createIL230_234_261(String policyId,String docVersion,Policy__c policy,boolean IL_230,boolean IL_234,boolean IL_261){
        /*Policy__c policy = [select id,Account__c,Effective_Date__c from Policy__c where id =: policyId];
        system.debug('policy :: ' + policy);*/
        List<Policy_Endorsement__c> endorsementList = new List<Policy_Endorsement__c>();
        Policy_Endorsement__c endorsementIL230 = new Policy_Endorsement__c();
        Policy_Endorsement__c endorsementIL234 = new Policy_Endorsement__c();
        Policy_Endorsement__c endorsementIL261 = new Policy_Endorsement__c();
        if(IL_230){
            endorsementIL230.Account__c = policy.Account__c;
            endorsementIL230.RecordTypeId = Schema.getGlobalDescribe().get('Policy_Endorsement__c').getDescribe().getRecordTypeInfosByName().get('IL 230 ANNUAL AGGREGATE DEDUCTIBLE ENDORSEMENT').getRecordTypeId();
            endorsementIL230.Effective_Date__c = System.today();
            endorsementIL230.Endorsement_Effective_Date__c = policy.Effective_Date__c;
            endorsementIL230.Event_Status__c = 'Pending';
            endorsementIL230.Policy__c = policyId;
            endorsementList.add(endorsementIL230);
        }    
        if(IL_234){
            endorsementIL234.Account__c = policy.Account__c;
            endorsementIL234.RecordTypeId = Schema.getGlobalDescribe().get('Policy_Endorsement__c').getDescribe().getRecordTypeInfosByName().get('IL 234 LOSS ONLY DEDUCTIBLE ENDORSEMENT').getRecordTypeId();
            endorsementIL234.Effective_Date__c = System.today();
            endorsementIL234.Endorsement_Effective_Date__c = policy.Effective_Date__c;
            endorsementIL234.Event_Status__c = 'Pending';
            endorsementIL234.Policy__c = policyId;
            endorsementList.add(endorsementIL234);
        }
        if(IL_261){
            endorsementIL261.Account__c = policy.Account__c;
            endorsementIL261.RecordTypeId = Schema.getGlobalDescribe().get('Policy_Endorsement__c').getDescribe().getRecordTypeInfosByName().get('IL 261 Claim Expenses Outside the Policy Limits Endorsement').getRecordTypeId();
            endorsementIL261.Effective_Date__c = System.today();
            endorsementIL261.Endorsement_Effective_Date__c = policy.Effective_Date__c;
            endorsementIL261.Event_Status__c = 'Pending';
            endorsementIL261.Policy__c = policyId;
            endorsementList.add(endorsementIL261);
        }
        
        insert endorsementList;
        
        if(IL_261){
            endorsementIL261 = [select id,Endorsement_Version__c from Policy_Endorsement__c where id=: endorsementIL261.Id];
        }
        
        
        for(Policy_Endorsement__c endorsement : endorsementList){
            endorsement.Event_Status__c = 'Complete';
        }
        
        update endorsementList;
        if(IL_230){
            createEndorsement(policyId,policyId,'IL 230 Annual Aggregate Deductible Endorsement - '+policyId,'IL 230',docVersion,policy.Account__c,null,endorsementIL230.Id);
        }
        if(IL_234){
            createEndorsement(policyId,policyId,'IL 234 Loss Only Deductible Endorsement - '+policyId,'IL 234',docVersion,policy.Account__c,null,endorsementIL234.Id);
        }
        if(IL_261){
            createEndorsement(policyId,policyId,'IL 261 Claim Expenses Outside the Policy Limits Endorsement - '+policyId,'IL 261',endorsementIL261.Endorsement_Version__c,policy.Account__c,null,endorsementIL261.Id);
        }
    }
    webservice static void createIL102(String policyId,String docVersion,Policy__c policy,Id documentId){
        /*Policy__c policy = [select id,Account__c,Effective_Date__c from Policy__c where id =: policyId];
        system.debug('policy :: ' + policy);*/
            
        Policy_Endorsement__c endorsement = new Policy_Endorsement__c();
        endorsement.Account__c = policy.Account__c;
        endorsement.RecordTypeId = Schema.getGlobalDescribe().get('Policy_Endorsement__c').getDescribe().getRecordTypeInfosByName().get('IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT').getRecordTypeId();
        system.debug('endorsement.RecordTypeId == >>'+endorsement.RecordTypeId);
        endorsement.Effective_Date__c = System.today();
        endorsement.Endorsement_Effective_Date__c = policy.Effective_Date__c;
        endorsement.Event_Status__c = 'Pending';
        endorsement.Policy__c = policyId;
        insert endorsement;
        List<JsonPolicyLawyerWrapper> wrapperList = new List<JsonPolicyLawyerWrapper>();
        for(Policy_Lawyer__c lawyer :[select id,Prior_Act_Date__c,Lawyer_Name__c,ARDC_Number__c  from Policy_Lawyer__c where Policy__C = :policyId] ){
            JsonPolicyLawyerWrapper wrapper = new JsonPolicyLawyerWrapper();
            wrapper.lawyername = lawyer.Lawyer_Name__c;
            wrapper.priorActsDate = lawyer.Prior_Act_Date__c;
            wrapper.ardcNumber = lawyer.ARDC_Number__c ;
            wrapperList.add(wrapper);
        }
        String jsonString = JSON.serialize(wrapperList);
        endorsement.Event_Status__c = 'Complete';
        endorsement.Policy_Lawyer_Json__c = jsonString;
        update endorsement;
        createEndorsement(policyId,policyId,'IL 102 Prior Acts Exclusion Endorsement - '+policyId,'IL 102',docVersion,policy.Account__c,documentId,endorsement.Id);
    }
    webservice static void createIL302(String policyId,String docVersion,Policy__c policy,Id documentId){
        Policy_Endorsement__c endorsement = new Policy_Endorsement__c();
        endorsement.Account__c = policy.Account__c;
        endorsement.RecordTypeId = Schema.getGlobalDescribe().get('Policy_Endorsement__c').getDescribe().getRecordTypeInfosByName().get('IL 302 AMENDMENT OF EXTENDED REPORTING PERIOD OPTIONS ENDORSEMENT').getRecordTypeId();
        system.debug('endorsement.RecordTypeId == >>'+endorsement.RecordTypeId);
        endorsement.Effective_Date__c = System.today();
        endorsement.Endorsement_Effective_Date__c = policy.Effective_Date__c;
        endorsement.Event_Status__c = 'Pending';
        endorsement.Policy__c = policyId;
        insert endorsement;
        
        endorsement.Event_Status__c = 'Complete';
        update endorsement;
        
        createEndorsement(policyId,policyId,'IL 302 Amendment of Unlimited Retirement Extended Reporting Period Endorsement - '+policyId,'IL 302',Label.IL_302_Version,policy.Account__c,documentId,endorsement.Id);
    }
    webservice static void createEndorsement(String endorsementId,String policyId,String pdfname,String endorsementNumber,String version,String accountId,Id documentId,Id mappedEndorsementId, boolean physicalDocumentDelivery) {
        try{
            PageReference pageRef = Page.Endorsement_Pdf;
            pageRef.getParameters().put('id',(String)endorsementId);
            pageRef.getParameters().put('number',(String)endorsementNumber);
            pageRef.getParameters().put('version',(String)version);
            Blob body;
            
            if (Test.IsRunningTest()){
                body = Blob.valueOf('UNIT.TEST');
            } else {
                body = pageRef.getContentAsPDF();
            }
            ContentVersion content = createContentVersion(body,pdfname+'.pdf',policyId,accountId,'Endorsement',documentId,mappedEndorsementId,physicalDocumentDelivery);
            
        }catch(Exception e){
            System.debug('Error Message:'+e.getMessage());
        }
    }
    webservice static String policyToApplicationAccountingTransactions(String policyId) {
        SavePoint sp = Database.setSavepoint();
        try{
            Policy__c pol = [select id,Premium__c,Is_Accepted_Confirm__c,Is_Allow_to_Generate_AS__c,RecordTypeId,Account__c from Policy__c where id=:policyId];
            
            /*AS_Transaction__c asTransaction = new AS_Transaction__c();
            asTransaction.Amount__c = pol.Premium__c;
            asTransaction.Firm_Id__c = pol.Account__c;
            asTransaction.Policy_Id__c = policyId;
            asTransaction.Transaction_Type__c = 'Cancel Policy';
            asTransaction.Transaction_Sub_Type__c = 'Cancel Policy';
            
            insert asTransaction;*/
            
            List<Policy_Lawyer__c> lawyers = new List<Policy_Lawyer__c>([select id,Is_Application_Lawyer__c from Policy_Lawyer__c where Policy__c =: policyId]);
            for(Policy_Lawyer__c lawyer : lawyers){
                lawyer.Is_Application_Lawyer__c = true;
            }
            
            update lawyers;
            
            pol.Premium__c = null;
            pol.Is_Accepted_Confirm__c= false; 
            pol.Is_Allow_to_Generate_AS__c= true;
            pol.Is_Allow_Calculate_Premium__c=false;
            pol.RecordTypeId=ApplicationPolicyUtil.ApplicationRTID;
            pol.Accounting_Processed__c = false;
            
            update pol;
            
            
            return 'Policy successfully converted back to Application.';
        }catch(Exception e){
            Database.rollback(sp);
            return 'There is some error occurred while conversion : '+e.getMessage();
        }
        
    }
    
    public static ContentVersion createContentVersion(Blob body,String fileName,Id policyId,Id accountId,String documentType,Id contentDocumentId,Id mappedEndorsementId,boolean physicalDocumentDelivery){
        Decimal currentMilliSeconds = System.now().getTime();
        ContentVersion content = new ContentVersion();
        content.VersionData = body;
        content.Title = fileName;
        content.PathOnClient = fileName;
        content.Application_Policy__c = policyId;
        content.Endorsement_Id__c = mappedEndorsementId;
        content.Account__c = accountId;
        content.Document_Type__c = documentType;
        content.Is_System_Generated_Document__c = true;
        content.Unique_Identifier__c = policyId + '_' + UserInfo.getUserId() +  '_' + currentMilliSeconds;
        content.IsMajorVersion = true;
        content.Physical_document_delivery__c = physicalDocumentDelivery;
        if(contentDocumentId != null){
            content.ContentDocumentId = contentDocumentId;
        }else{
            content.FirstPublishLocationId = policyId;
        }
        insert content;
        return content;
    }
    
    public static ContentVersion createContentVersion(Blob body,String fileName,Id policyId,Id accountId,String documentType,Id contentDocumentId){
        return createContentVersion(body,fileName,policyId,accountId,documentType,contentDocumentId,null,false);
    }
    public static ContentVersion createContentVersion(Blob body,String fileName,Id policyId,Id accountId,String documentType,Id contentDocumentId,Id mappedEndorsementId){
        return createContentVersion(body,fileName,policyId,accountId,documentType,contentDocumentId,null,false);
    }
    
    public static void createEndorsement(String endorsementId,String policyId,String pdfname,String endorsementNumber,String version,String accountId,Id documentId,Id mappedEndorsementId){
        createEndorsement(endorsementId,policyId,pdfname,endorsementNumber,version,accountId,documentId,mappedEndorsementId,false);
    }
    
}