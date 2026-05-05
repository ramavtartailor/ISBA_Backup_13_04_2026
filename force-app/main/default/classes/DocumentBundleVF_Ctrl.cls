global class DocumentBundleVF_Ctrl {
    public Id policyApplicationId{get;set;}
    String typeOfButton;
    String renewalType;
    Id policyApplicationId1;
    String typeOfButton1;
    String renewalType1;
    public Policy__c policy {get;set;}
    public SelectOption[] selectedDocuments { get; set; }
    public SelectOption[] allDocuments { get; set; }
    public List<PolicyDocument> documentsList{get;set;}
    Map<Id,Policy_Endorsement__c> mapEndorsement;
    public Date expirationDate{get;set;}
    public Map<Id,String> quotesMap = new Map<Id,String>();
        public List<Policy_Quote__c> quoteList{get;set;}
    public List<Policy_Lawyer__c> policyLawyers{get;set;}
    public String errorMessage{get;set;}
    public String street{get;set;}
    public boolean fromDirectDownloadPage = false;
    public String contentType{get;set;}
    public String base64Value{get;set;}
    public String mergedContentVersionId{get;set;}
    public String fromPolicyBind{get;set;}
    public DocumentBundleVF_Ctrl(Id policyApplicationId,String typeOfButton,String renewalType){
        this.policyApplicationId1 = policyApplicationId;
        this.typeOfButton1 = typeOfButton;
        this.renewalType1 = renewalType;
        documentBundleCtrlHelper();
    }
    public DocumentBundleVF_Ctrl(){
        documentBundleCtrlHelper();
    }
    
    public void documentBundleCtrlHelper(){
        fromPolicyBind = '';
        System.debug(policyApplicationId1);
        System.debug(String.isBlank(policyApplicationId));
        if(String.isBlank(policyApplicationId)){
            Organization myOrg = [Select Street From Organization];
            if(myOrg.Street!=null){
                street = myOrg.Street.replaceAll('\n','<br/>');
            }
            mapEndorsement = new Map<Id,Policy_Endorsement__c>();
            selectedDocuments = new List<SelectOption>();
            allDocuments = new List<SelectOption>();
            List<Id> quoteIds = new List<Id>();
            if(policyApplicationId1 != null){
                policyApplicationId = policyApplicationId1;
                typeOfButton = typeOfButton1;
                renewalType = renewalType1;
            }else{
                policyApplicationId = apexpages.currentpage().getparameters().get('id');
                typeOfButton=apexpages.currentpage().getparameters().get('type');
                renewalType = apexpages.currentpage().getparameters().get('renewalType');
                if(apexpages.currentpage().getparameters().get('removeQuoteIds')!=null){
                    quoteIds = apexpages.currentpage().getparameters().get('removeQuoteIds').split(';');
                }
                if(apexpages.currentpage().getparameters().get('fromPolicyBind')!=null){
                    fromPolicyBind = apexpages.currentpage().getparameters().get('fromPolicyBind');
                }
            }
            policy = [select id,name,Account__r.Name,Policy_Document_Version__c,RecordType.Name,Account__r.Account_Number_External_ID__c,
                      Effective_Date__c,County__c,Total_Lawyers__c,Policy_Number__c,Per_Claim_Limit__c,Aggregate_Limit_For_All_Claims__c,Renewal_Type__c,Application_Type__c,
                      Deductible_Amount__c,Premium__c,Expiration_Date__c,Account__c,Account__r.BillingStreet,Account__r.BillingCity, 
                       Account__r.BillingState,Account__r.BillingPostalCode,Account__r.Phone,Account__r.Trade_Name_or_D_B_A__c,Firm_Contact__r.Email,Firm_Contact__r.Phone,Firm_Contact__r.Name,
                       Account__r.Fax,Account__r.email__c,Remove_102_Endorsement__c,County__r.Name, ISBAM_policy_dividend__c from Policy__C where id = :policyApplicationId];
            expirationDate = policy.Effective_Date__c.addYears(1);
            System.debug('==typeOfButton=='+typeOfButton);
            System.debug('quoteIds => '+quoteIds+' Size ==>'+quoteIds.size());
            
            
            
           /* POLICY DOCUMENTS
			*	use existing generated file
            */
            if(typeOfButton=='printPolicyDocs'){
                
                Set<Id> contentDocumentIds = new Set<Id>();
                for(ContentDocumentLink cdl : [select ContentDocumentId from ContentDocumentLink where LinkedEntityId =: policyApplicationId]){
                    contentDocumentIds.add(cdl.ContentDocumentId);
                }
                for(ContentVersion cv : [select id,Title,FirstPublishLocationId from ContentVersion where ContentDocumentId =: contentDocumentIds and (Document_Type__c = 'Policy Letter' OR Document_Type__c = 'Declaration Page'  OR Document_Type__c = 'NAS EOC'  OR Document_Type__c = 'Certificate Of Insurance' OR Document_Type__c='Endorsement') and Is_System_Generated_Document__c = true and IsLatest=true order by Priority_Order__c,Title]){
                    selectedDocuments.add(new SelectOption(cv.Id,cv.Title));
                }

                
		   /*  QUOTE BUTTON
			*          removeQuoteIds !== null if coming from quote screen
			*/
            }else if(typeOfButton=='quoteBundle' && quoteIds.size() == 0){
                boolean Mod_230 = false, Mod_234 = false , mod_261 = false;
                for(Policy_Quote__c q : [select id,name,Limits__c,Deductibles_Formula__c,Mod_230__c,Mod_234__c,Mod_261__c from Policy_Quote__c where Policy__c =:policyApplicationId Order By QUOTE_FINAL_PREMIUM__c ASC]){
                    selectedDocuments.add(new SelectOption(q.Id, q.Name+' - '+q.Limits__c+' - '+q.Deductibles_Formula__c));
                    if(q.Mod_230__c != null && q.Mod_230__c !=0){
                        Mod_230 = true;
                    }
                    if(q.Mod_234__c != null && q.Mod_234__c !=0){
                        Mod_234 = true;
                    }
                    if(q.Mod_261__c != null && q.Mod_261__c !=0){
                        Mod_261 = true;
                    }
                }
                system.debug('fromPolicyBind => '+fromPolicyBind);
                if(fromPolicyBind == 'yes'){
                    selectedDocuments.add(new SelectOption('Declaration Page', 'Declaration Page'));
                }
                
                selectedDocuments.add(new SelectOption('Terms Of Service', 'Terms Of Service'));
                
                //DISABLE PAYMENT OPTIONS - kyle.hoker 2023-03-21
                //selectedDocuments.add(new SelectOption('Payment Options', 'Payment Options'));
                
                // IBF Dividend Options
                system.debug('policy.ISBAM_policy_dividend__c => '+policy.ISBAM_policy_dividend__c);
                if (policy.ISBAM_policy_dividend__c > 0){
                	selectedDocuments.add(new SelectOption('IBF Contribution', 'IBF Contribution'));
                }
                
                //DISABLE PAYMENT AUTHORIZATION - kyle.hoker 2022-10-28
                //selectedDocuments.add(new SelectOption('Authorization Form', 'Authorization Form'));
                
                if(!policy.Remove_102_Endorsement__c){
                    if(policy.RecordType.Name!='Policy'){
                        selectedDocuments.add(new SelectOption('IL 102 Prior Acts Exclusion Endorsement', 'IL 102 Prior Acts Exclusion Endorsement'));
                    }
                }
                if(Mod_230){
                    selectedDocuments.add(new SelectOption('IL 230 Annual Aggregate Deductible Endorsement', 'IL 230 Annual Aggregate Deductible Endorsement'));
                }
                if(Mod_234){
                    selectedDocuments.add(new SelectOption('IL 234 Loss Only Deductible Endorsement', 'IL 234 Loss Only Deductible Endorsement'));
                }
                if(Mod_261){
                    selectedDocuments.add(new SelectOption('IL 261 Claim Expenses Outside the Policy Limits Endorsement', 'IL 261 Claim Expenses Outside the Policy Limits Endorsement'));
                }
                for(Policy_Endorsement__c q : [select id,name,Event_Status__c,Endorsement_Number__c,Endorsement_Version__c from Policy_Endorsement__c where Policy__c =:policyApplicationId  Order By CreatedDate DESC]){
                    selectedDocuments.add(new SelectOption(q.Id, q.Name));
                    mapEndorsement.put(q.id,q);
                }
                if(policy.Policy_Document_Version__c == '1/18'){
                    selectedDocuments.add(new SelectOption('IL 302 Amendment of Unlimited Retirement Extended Reporting Period Endorsement', 'IL 302 Amendment of Unlimited Retirement Extended Reporting Period Endorsement'));
                }
            	//selectedDocuments.add(new SelectOption('Comprehensive Cyber Liability Insurance Program', 'Comprehensive Cyber Liability Insurance Program'));
                
                system.debug('selectedDocuments => '+selectedDocuments);
           /*  
			*   APPLICATION BUTTON / RENEWAL
			*/
            }else if(typeOfButton == 'renewal' && policy.Application_Type__c == 'Renewal'){
                selectedDocuments.add(new SelectOption('Cover Letter', 'Cover Letter'));
                selectedDocuments.add(new SelectOption('Renewal Application', 'Renewal Application'));
                selectedDocuments.add(new SelectOption('Comprehensive Cyber Liability Insurance Program', 'Comprehensive Cyber Liability Insurance Program'));
                allDocuments.add(new SelectOption('Lawyer Supplement Application', 'Lawyer Supplement Application'));
                
            
           /*  
			*   APPLICATION BUTTON / NEW BUSINESS
			*/
            }else if(typeOfButton == 'renewal' && policy.Application_Type__c == 'New Business'){
                //selectedDocuments.add(new SelectOption('Cover Letter', 'Cover Letter'));
                //selectedDocuments.add(new SelectOption('Application', 'Application'));
                errorMessage = 'This operation is not allowed as this is a New Business Application.'; 
            
                
            /*  QUOTE BUTTON / FROM EDIT QUOTE PAGE
			*          removeQuoteIds !== null if coming from quote screen
			*/
            }else if(quoteIds.size()>0){
                //List<Id> quoteIds = apexpages.currentpage().getparameters().get('removeQuoteIds').split(';');
                boolean Mod_230 = false, Mod_234 = false , mod_261 = false;
                for(Policy_Quote__c q : [select id,name,Limits__c,Deductibles_Formula__c,Mod_230__c,Mod_234__c,Mod_261__c from Policy_Quote__c where Policy__c =:policyApplicationId and Id not in: quoteIds Order By CreatedDate DESC]){
                    selectedDocuments.add(new SelectOption(q.Id, q.Name+' - '+q.Limits__c+' - '+q.Deductibles_Formula__c));
                	if(q.Mod_230__c != null && q.Mod_230__c !=0){
                        Mod_230 = true;
                    }
                    if(q.Mod_234__c != null && q.Mod_234__c !=0){
                        Mod_234 = true;
                    }
                    if(q.Mod_261__c != null && q.Mod_261__c !=0){
                        Mod_261 = true;
                    }
                }
                system.debug('fromPolicyBind => '+fromPolicyBind);
                if(fromPolicyBind == 'yes'){
                    selectedDocuments.add(new SelectOption('Declaration Page', 'Declaration Page'));
                }
                selectedDocuments.add(new SelectOption('Terms Of Service', 'Terms Of Service'));
                
                //DISABLE PAYMENT OPTIONS - kyle.hoker 2023-03-21
                //selectedDocuments.add(new SelectOption('Payment Options', 'Payment Options'));

                // DISABLE PAYMENT AUTHORIZATION - kyle.hoker 2022-10-28
                //selectedDocuments.add(new SelectOption('Authorization Form', 'Authorization Form'));

                if(!policy.Remove_102_Endorsement__c){
                    if(policy.RecordType.Name!='Policy'){
                        selectedDocuments.add(new SelectOption('IL 102 Prior Acts Exclusion Endorsement', 'IL 102 Prior Acts Exclusion Endorsement'));
                    }
                }
                if(Mod_230){
                    selectedDocuments.add(new SelectOption('IL 230 Annual Aggregate Deductible Endorsement', 'IL 230 Annual Aggregate Deductible Endorsement'));
                }
                if(Mod_234){
                    selectedDocuments.add(new SelectOption('IL 234 Loss Only Deductible Endorsement', 'IL 234 Loss Only Deductible Endorsement'));
                }
                if(Mod_261){
                    selectedDocuments.add(new SelectOption('IL 261 Claim Expenses Outside the Policy Limits Endorsement', 'IL 261 Claim Expenses Outside the Policy Limits Endorsement'));
                }
                for(Policy_Endorsement__c q : [select id,name,Event_Status__c,Endorsement_Number__c,Endorsement_Version__c from Policy_Endorsement__c where Policy__c =:policyApplicationId  Order By CreatedDate DESC]){
                    selectedDocuments.add(new SelectOption(q.Id, q.Name));
                    mapEndorsement.put(q.id,q);
                }
                if(policy.Policy_Document_Version__c == '1/18'){
                    selectedDocuments.add(new SelectOption('IL 302 Amendment of Unlimited Retirement Extended Reporting Period Endorsement', 'IL 302 Amendment of Unlimited Retirement Extended Reporting Period Endorsement'));
                }
                //selectedDocuments.add(new SelectOption('Comprehensive Cyber Liability Insurance Program', 'Comprehensive Cyber Liability Insurance Program'));
            }else if(typeOfButton == 'lawyerSupplement'){
                selectedDocuments.add(new SelectOption('Lawyer Supplement Application', 'Lawyer Supplement Application'));
            }
        }
    }
    
    /*  CREATE DOCUMENTS
     * 
     */
    public PageReference generateBundle() {
        documentsList = new List<PolicyDocument>();
        Set<Id> contentVersionIds = new Set<Id>();
        for ( SelectOption so : selectedDocuments ) {
            if(so.getLabel() == 'Policy Letter'){
                documentsList.add(new PolicyDocument(so.getValue(),null,null));
            }else if(so.getLabel() == 'Declaration Page'){
                documentsList.add(new PolicyDocument(so.getValue(),null,null));
            }else if(so.getLabel() == 'Certification Of Insurance'){
                documentsList.add(new PolicyDocument(so.getValue(),null,null));
            }else if(so.getLabel() == 'NAS EOC'){
                documentsList.add(new PolicyDocument(so.getValue(),null,null));
            }else if(so.getLabel() == 'Terms Of Service'){
                documentsList.add(new PolicyDocument(so.getValue(),null,null));
            }else if(so.getLabel() == 'Payment Options'){
                documentsList.add(new PolicyDocument(so.getValue(),null,null));
            }else if(so.getLabel() == 'Authorization Form'){
                documentsList.add(new PolicyDocument(so.getValue(),null,null));
            }else if(so.getLabel().containsIgnoreCase('Quote')){
                quotesMap.put(so.getValue(), so.getLabel());
                documentsList.add(new PolicyDocument('Quote',so.getValue(),null));
            }else if(so.getLabel()=='IL 102 Prior Acts Exclusion Endorsement'){
                documentsList.add(new PolicyDocument(so.getValue(),null,null));
            }else if(so.getLabel()=='IL 230 Annual Aggregate Deductible Endorsement'){
                documentsList.add(new PolicyDocument(so.getValue(),null,null));
            }else if(so.getLabel()=='IL 234 Loss Only Deductible Endorsement'){
                documentsList.add(new PolicyDocument(so.getValue(),null,null));
            }else if(so.getLabel()=='IL 261 Claim Expenses Outside the Policy Limits Endorsement'){
                documentsList.add(new PolicyDocument(so.getValue(),null,null));
            }else if(so.getLabel()=='IL 302 Amendment of Unlimited Retirement Extended Reporting Period Endorsement'){
                documentsList.add(new PolicyDocument(so.getValue(),null,null));
            }else if(so.getLabel()=='Cover Letter'){
                documentsList.add(new PolicyDocument(so.getValue(),null,null));
            }else if(so.getLabel()=='Renewal Application'){
                documentsList.add(new PolicyDocument(so.getValue(),null,null));
            }else if(so.getLabel()=='Application'){
                documentsList.add(new PolicyDocument(so.getValue(),null,null));
            }else if(so.getLabel()=='Lawyer Supplement Application'){
                documentsList.add(new PolicyDocument(so.getValue(),null,null));
            }else if(so.getLabel()=='IBF Contribution'){
                documentsList.add(new PolicyDocument(so.getValue(),null,null));    
            }else if(so.getLabel()=='Comprehensive Cyber Liability Insurance Program'){
                documentsList.add(new PolicyDocument(so.getValue(),null,null));    
            }else{
                if(Id.valueOf(so.getValue()).getSObjectType().getDescribe().getName() == 'Policy_Endorsement__c'){
                    documentsList.add(new PolicyDocument('Endorsement',so.getValue(),mapEndorsement.get(Id.valueOf(so.getValue()))));
                }else{
                    documentsList.add(new PolicyDocument('Content Version',so.getValue(),null));
                    contentVersionIds.add(so.getValue());
                }
            }
        }
        
        /*
         * Name file bundle
         */
        String fileName = '';
        // fileName = policy.Account__r.Name +' - '+policy.Name+ ' - ' + renewalType +'.pdf' ;
        fileName = policy.Account__r.Name +' - '+policy.Name;
        if(typeOfButton=='printPolicyDocs'){
            fileName += ' - Documents';
        }else if(typeOfButton=='quoteBundle'){
            fileName += ' - Quote Bundle' ;
        }else if(typeOfButton == 'renewal'){
        	if(policy.Renewal_Type__c == 'Regular Renewal'){
                fileName += ' - REN';
            }else if(policy.Renewal_Type__c == 'EZ Renewal'){                        
                fileName += ' - RQA';
            }else{
                fileName += ' - EZQ';
            }
        }else if(typeOfButton == 'lawyerSupplement'){
            fileName += ' - Lawyers Supplemental Application';
        }
        fileName += '.pdf';
        
        /*
         * CREATE NON-RENEWAL DOCUMENTS
         */
        if(typeOfButton != 'renewal'){
            if(!fromDirectDownloadPage){
                //Apexpages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename="'+fileName+'"');
            }
            PageReference np = new PageReference('/apex/PolicyDocumentsPdf');
            np.setRedirect(false);
            Set<String> valuesSet = new Set<String>();
            List<ContentVersion> contentVersionList = new List<ContentVersion>();
            Blob body;
            Timezone tz = Timezone.getTimeZone('America/Chicago');
            Decimal currentMilliSeconds = System.now().getTime();
            DateTime currentDateTime = System.now();
            currentDateTime = currentDateTime.addMinutes(tz.getOffset(currentDateTime)/ (1000 * 60));
            List<Blob> documentsToMerge = new List<Blob>();
            
            /*
             *   CREATE QUOTE BUNDLE DOCUMENTS  -- REGULAR RENEWAL
             */
            if(typeOfButton=='quoteBundle'){
                List<ContentWorkspace> workspace = new List<ContentWorkspace>([SELECT Id FROM ContentWorkspace WHERE Name = 'Send Email Resource Documents']);
                //List<ContentVersion> cvListComprehensive = new List<ContentVersion>([select Id, VersionData  from ContentVersion where Title = 'Comprehensive Cyber Liability Insurance Program' and ContentDocument.ParentId = :workspace[0].Id]);
                List<Endorsement_Version__c> masterEndorsementVersions = [select id,Effective_From__c,Endorsement_Version_Number__c,Policy_Version__c from Endorsement_Version__c where Master_Endorsement__r.Endorsement_Sub_Type__c = 'IL 261' order by Effective_From__c];
                for(PolicyDocument doc : documentsList){
                    ContentVersion content = new ContentVersion();
                    if(doc.typeOfDocument == 'Quote'){
                        if(!(String.isNotBlank(fromPolicyBind) && fromPolicyBind == 'yes')){
                            PageReference pg = Page.Quote_Pdf;
                            pg.getParameters().put('id',doc.recordId);
                            try {
                                body = pg.getContent();
                            } catch (VisualforceException e) {
                                body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                            }
                        }
                    }else if(doc.typeOfDocument == 'IL 102 Prior Acts Exclusion Endorsement'){
                        PageReference pg = Page.Endorsement_Pdf;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        pg.getParameters().put('number','IL 102');
                        pg.getParameters().put('version','9/24');
                        //pg.getParameters().put('id',doc.recordId);
                        System.debug('---doc.recordId---'+doc.recordId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                    }else if(doc.typeOfDocument == 'IL 230 Annual Aggregate Deductible Endorsement'){
                        PageReference pg = Page.Endorsement_Pdf;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        pg.getParameters().put('number','IL 230');
                        pg.getParameters().put('version',(String)policy.Policy_Document_Version__c);
                        //pg.getParameters().put('id',doc.recordId);
                        System.debug('---doc.recordId---'+doc.recordId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                    }else if(doc.typeOfDocument == 'IL 234 Loss Only Deductible Endorsement'){
                        PageReference pg = Page.Endorsement_Pdf;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        pg.getParameters().put('number','IL 234');
                        pg.getParameters().put('version',(String)policy.Policy_Document_Version__c);
                        //pg.getParameters().put('id',doc.recordId);
                        System.debug('---doc.recordId---'+doc.recordId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                    }else if(doc.typeOfDocument == 'IL 261 Claim Expenses Outside the Policy Limits Endorsement'){
                        PageReference pg = Page.Endorsement_Pdf;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        pg.getParameters().put('number','IL 261');
                        Endorsement_Version__c versionToUse;
                        for (Endorsement_Version__c endVer : masterEndorsementVersions) {
                            if (versionToUse == null) {
                                versionToUse = endVer;
                            } else {
                                if (endVer.Effective_From__c <= policy.Effective_Date__c && endVer.Effective_From__c > versionToUse.Effective_From__c && endVer.Policy_Version__c == policy.Policy_Document_Version__c) {
                                    versionToUse = endVer;
                                }
                            }
                        }
                        pg.getParameters().put('version',versionToUse.Endorsement_Version_Number__c);
                        //pg.getParameters().put('id',doc.recordId);
                        System.debug('---doc.recordId---'+doc.recordId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                    }else if(doc.typeOfDocument == 'IL 302 Amendment of Unlimited Retirement Extended Reporting Period Endorsement'){
                        PageReference pg = Page.Endorsement_Pdf;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        pg.getParameters().put('number','IL 302');
                        pg.getParameters().put('version',Label.IL_302_Version);
                        //pg.getParameters().put('id',doc.recordId);
                        System.debug('---doc.recordId---'+doc.recordId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                    }else if(doc.typeOfDocument == 'Terms Of Service'){
                        PageReference pg;
                        pg = Page.Terms_Of_Service_Pdf;
                        /*
                         // disable per-type T&C for now
                        if(policy.Application_Type__c == 'New Business'){
                        	pg = Page.RegularRenewalTerms;
                        }else if(policy.Renewal_Type__c == 'Regular Renewal'){
                        	pg = Page.RegularRenewalTerms;
                        }else if(policy.Renewal_Type__c == 'EZ Renewal'){                        
                            pg = Page.EZRenewalTerms;
                        }else{
                            pg = Page.EZQRenewalTerms;
                        }
                        */
                        pg.getParameters().put('id',(String)policyApplicationId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                    
                    //DISABLE PAYMENT OPTIONS - kyle.hoker 2023-03-21
                    /*
                    }else if(doc.typeOfDocument == 'Payment Options'){
                        PageReference pg = Page.Payment_Options_Pdf;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            System.debug('Test');
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                    */
                    }else if(doc.typeOfDocument == 'Authorization Form'){
                        PageReference pg = Page.Authorization_Form_Pdf;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                    }else if(doc.typeOfDocument == 'Endorsement'){
                        PageReference pg = Page.Endorsement_Pdf;
                        pg.getParameters().put('number',doc.endorsement.Endorsement_Number__c);
                        pg.getParameters().put('version',(String)doc.endorsement.Endorsement_Version__c);
                        pg.getParameters().put('id',doc.recordId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                    }else if(doc.typeOfDocument == 'IBF Contribution'){
                    	PageReference pg = Page.IBF_Dividend_PDF;
                    	pg.getParameters().put('id',(String)policyApplicationId);
                    	try {
                        	body = pg.getContent();
                    	} catch (VisualforceException e) {
                        	body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                    	}
                    }else if(doc.typeOfDocument == 'Comprehensive Cyber Liability Insurance Program'){
                        PageReference pg = Page.Comprehensive_Cyber_Liability_Pdf;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        try {
                        	body = pg.getContent();
                    	} catch (VisualforceException e) {
                        	body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                    	}
                    }else if(doc.typeOfDocument == 'Declaration Page'){
                        PageReference pg = Page.Declaration_Page_Pdf;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        pg.getParameters().put('version', policy.Policy_Document_Version__c);
                        try {
                        	body = pg.getContent();
                    	} catch (VisualforceException e) {
                        	body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                    	}
                    }
                    
                    
                     
                    if(body!=null){
                        documentsToMerge.add(body);
                        body = null;
                    }
                }
                
                if(documentsToMerge.size()>0){
                    DocumentBundleUtility.DocumentBundleUtilityWrapper wrapper = DocumentBundleUtility.mergePDF(documentsToMerge);
                    if(wrapper.isSuccess){
                        ContentVersion content = new ContentVersion();
                        content.VersionData = wrapper.mergedDocument;
                        content.Title = fileName;
                        content.PathOnClient = fileName;
                        content.FirstPublishLocationId = policyApplicationId;
                        content.Application_Policy__c = policyApplicationId;
                        content.Account__c = policy.Account__c;
                        content.Document_Type__c = 'Quote Bundle';
                        content.Is_System_Generated_Document__c = true;
                        content.Unique_Identifier__c = policyApplicationId + '_' + UserInfo.getUserId() +  '_' + currentMilliSeconds;
                        insert content;
                        mergedContentVersionId = content.Id;
                        base64Value = EncodingUtil.base64Encode(wrapper.mergedDocument);
                        System.debug(content.Id);
                        return new PageReference(System.URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/'+content.Id+'?asPdf=false&operationContext=CHATTER');
                    }else{
                        return null;
                    }
                }
                
            /*
             * CREATE POLICY DOCUMENTS
             */
            }else if(typeOfButton=='printPolicyDocs'){
                Map<Id,ContentVersion> contentVersionMap = new Map<Id,ContentVersion>([select id,VersionData from ContentVersion where id in: contentVersionIds]);
                for(PolicyDocument doc : documentsList){
                    if(doc.typeOfDocument == 'Content Version'){
                        body = contentVersionMap.get(doc.recordId).VersionData;
                    }
                    if(body!=null){
                        documentsToMerge.add(body);
                        body = null;
                    }
                }
                if(documentsToMerge.size()>0){
                    DocumentBundleUtility.DocumentBundleUtilityWrapper wrapper = DocumentBundleUtility.mergePDF(documentsToMerge);
                    if(wrapper.isSuccess){
                        ContentVersion content = new ContentVersion();
                        content.VersionData = wrapper.mergedDocument;
                        content.Title = fileName;
                        content.PathOnClient = fileName;
                        content.FirstPublishLocationId = policyApplicationId;
                        content.Application_Policy__c = policyApplicationId;
                        content.Account__c = policy.Account__c;
                        content.Document_Type__c = 'Policy Bundle';
                        content.Is_System_Generated_Document__c = true;
                        content.Unique_Identifier__c = policyApplicationId + '_' + UserInfo.getUserId() +  '_' + currentMilliSeconds;
                        insert content;
                        mergedContentVersionId = content.Id;
                        System.debug(content.Id);
                        base64Value = EncodingUtil.base64Encode(wrapper.mergedDocument);
                        if(!fromDirectDownloadPage){
                            deleteDownloadedContent(content.Id);
                        }
                        return new PageReference(System.URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/'+content.Id+'?asPdf=false&operationContext=CHATTER');
                    }else{
                        return null;
                    }
                }
            }else if(typeOfButton=='lawyerSupplement'){
                for(PolicyDocument doc : documentsList){
                    if(doc.typeOfDocument == 'Lawyer Supplement Application'){
                        PageReference pg = Page.LawyersSupplement;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                    }
                    if(body!=null){
                        documentsToMerge.add(body);
                        body = null;
                    }
                }
                if(documentsToMerge.size()>0){
                    DocumentBundleUtility.DocumentBundleUtilityWrapper wrapper = DocumentBundleUtility.mergePDF(documentsToMerge);
                    if(wrapper.isSuccess){
                        ContentVersion content = new ContentVersion();
                        content.VersionData = wrapper.mergedDocument;
                        content.Title = fileName;
                        content.PathOnClient = fileName;
                        content.FirstPublishLocationId = policyApplicationId;
                        content.Application_Policy__c = policyApplicationId;
                        content.Account__c = policy.Account__c;
                        content.Document_Type__c = 'Lawyer Supplement Application';
                        content.Is_System_Generated_Document__c = true;
                        content.Unique_Identifier__c = policyApplicationId + '_' + UserInfo.getUserId() +  '_' + currentMilliSeconds;
                        insert content;
                        mergedContentVersionId = content.Id;
                        base64Value = EncodingUtil.base64Encode(wrapper.mergedDocument);
                        System.debug(content.Id);
                        return new PageReference(System.URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/'+content.Id+'?asPdf=false&operationContext=CHATTER');
                    }else{
                        return null;
                    }
                }
            }
            return np;
            
            
        /*	
         * 	CREATE RENEWAL DOCUMENTS
         */
        }else{
            
            /*
             * 	CREATE NBA DOCUMENTS
             */
            if(policy.Application_Type__c == 'New Business'){
                List<Blob> documentsToMerge = new List<Blob>();
                Blob body;
                Decimal currentMilliSeconds = System.now().getTime();
                for(PolicyDocument doc : documentsList){
                    ContentVersion content = new ContentVersion();
                    if(doc.typeOfDocument == 'Cover Letter'){
                        PageReference pg = Page.NBACoverLetter;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        pg.getParameters().put('version',(String)policy.Policy_Document_Version__c);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                        if(body!=null){
                            documentsToMerge.add(body);
                            body = null;
                        }
                    }else if(doc.typeOfDocument == 'Application'){
                        PageReference pg = Page.NBAApplication;
                        pg.getParameters().put('id',(String)policyApplicationId);
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
                }
                if(documentsToMerge.size()>0){
                    DocumentBundleUtility.DocumentBundleUtilityWrapper wrapper = DocumentBundleUtility.mergePDF(documentsToMerge);
                    if(wrapper.isSuccess){
                        ContentVersion content = new ContentVersion();
                        content.VersionData = wrapper.mergedDocument;
                        content.Title = fileName;
                        content.PathOnClient = fileName;
                        content.FirstPublishLocationId = policyApplicationId;
                        content.Application_Policy__c = policyApplicationId;
                        content.Account__c = policy.Account__c;
                        content.Document_Type__c = 'Renewal Bundle';
                        content.Is_System_Generated_Document__c = true;
                        content.Unique_Identifier__c = policyApplicationId + '_' + UserInfo.getUserId() +  '_' + currentMilliSeconds;
                        insert content;
                        mergedContentVersionId = content.Id;
                        base64Value = EncodingUtil.base64Encode(wrapper.mergedDocument);
                        System.debug(content.Id);
                        return new PageReference(System.URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/'+content.Id+'?asPdf=false&operationContext=CHATTER');
                    }else{
                        return null;
                    }
                }else{
                    return null;
                }
                
            /*
             * CREATE REN DOCUMENTS (REGULAR RENEWAL)
             */
            }else if(renewalType == 'Regular Renewal'){
                List<Blob> documentsToMerge = new List<Blob>();
                Blob body;
                Decimal currentMilliSeconds = System.now().getTime();
                for(PolicyDocument doc : documentsList){
                    ContentVersion content = new ContentVersion();
                    if(doc.typeOfDocument == 'Cover Letter'){
                        PageReference pg = Page.RegularRenewalCoverLetter;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        pg.getParameters().put('version',(String)policy.Policy_Document_Version__c);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                        if(body!=null){
                            documentsToMerge.add(body);
                            body = null;
                        }
                    }else if(doc.typeOfDocument == 'Lawyer Supplement Application'){
                        PageReference pg = Page.LawyersSupplement;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                        if(body!=null){
                            documentsToMerge.add(body);
                            body = null;
                        }
                    }else if(doc.typeOfDocument == 'Renewal Application'){
                        PageReference pg = Page.RegularRenewalPDF;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                        if(body!=null){
                            documentsToMerge.add(body);
                            body = null;
                        }
                        
                        
                        /*
                         Disable T&C for regular renewal

                        pg = Page.RegularRenewalTerms;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                        if(body!=null){
                            documentsToMerge.add(body);
                            body = null;
                        }
						*/
                    }
                }
                if(documentsToMerge.size()>0){
                    DocumentBundleUtility.DocumentBundleUtilityWrapper wrapper = DocumentBundleUtility.mergePDF(documentsToMerge);
                    if(wrapper.isSuccess){
                        ContentVersion content = new ContentVersion();
                        content.VersionData = wrapper.mergedDocument;
                        content.Title = fileName;
                        content.PathOnClient = fileName;
                        content.FirstPublishLocationId = policyApplicationId;
                        content.Application_Policy__c = policyApplicationId;
                        content.Account__c = policy.Account__c;
                        content.Document_Type__c = 'Renewal Bundle';
                        content.Is_System_Generated_Document__c = true;
                        content.Unique_Identifier__c = policyApplicationId + '_' + UserInfo.getUserId() +  '_' + currentMilliSeconds;
                        insert content;
                        mergedContentVersionId = content.Id;
                        base64Value = EncodingUtil.base64Encode(wrapper.mergedDocument);
                        System.debug(content.Id);
                        return new PageReference(System.URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/'+content.Id+'?asPdf=false&operationContext=CHATTER');
                    }else{
                        return null;
                    }
                }else{
                    return null;
                }
                /*Apexpages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename="'+fileName+'"');
                PageReference np = new PageReference('/apex/RegularRenewalPDF');
                np.setRedirect(false);
                return np;*/
                
            /*
             * CREATE RQA DOCUMENTS (EZ RENEWAL)
             */
            }else if(renewalType == 'EZ Renewal'){
                List<Blob> documentsToMerge = new List<Blob>();
                Blob body;
                Decimal currentMilliSeconds = System.now().getTime();
                for(PolicyDocument doc : documentsList){
                    ContentVersion content = new ContentVersion();
                    if(doc.typeOfDocument == 'Cover Letter'){
                        PageReference pg = Page.EZRenewalCoverLetter;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        pg.getParameters().put('version',(String)policy.Policy_Document_Version__c);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                        if(body!=null){
                            documentsToMerge.add(body);
                            body = null;
                        }
                    }else if(doc.typeOfDocument == 'Lawyer Supplement Application'){
                        PageReference pg = Page.LawyersSupplement;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                        if(body!=null){
                            documentsToMerge.add(body);
                            body = null;
                        }
                    }else if(doc.typeOfDocument == 'Renewal Application'){
                        PageReference pg = Page.EZRenewal;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                        if(body!=null){
                            documentsToMerge.add(body);
                            body = null;
                        }
                        pg = Page.EZRenewalTerms;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                        if(body!=null){
                            documentsToMerge.add(body);
                            body = null;
                        }
                        
                        //DISABLE PAYMENT OPTIONS - kyle.hoker 2023-03-21
                        // Payment Options
                        /*
                        pg = Page.Payment_Options_Pdf;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                        if(body!=null){
                            documentsToMerge.add(body);
                            body = null;
                        }
                        */
                        
                        // IBF Dividend Options
                        if (policy.ISBAM_policy_dividend__c > 0){
                            pg = Page.IBF_Dividend_PDF;
                            pg.getParameters().put('id',(String)policyApplicationId);
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
                        
                        /*
                        // DISABLE PAYMENT AUTHORIZATION - kyle.hoker 2022-10-28
                        pg = Page.Authorization_Form_Pdf;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                        if(body!=null){
                            documentsToMerge.add(body);
                            body = null;
                        }
						*/
                    }else if(doc.typeOfDocument == 'Comprehensive Cyber Liability Insurance Program'){
                        PageReference pg = Page.Comprehensive_Cyber_Liability_Pdf;
                        pg.getParameters().put('id',(String)policyApplicationId);
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
                }
                if(documentsToMerge.size()>0){
                    DocumentBundleUtility.DocumentBundleUtilityWrapper wrapper = DocumentBundleUtility.mergePDF(documentsToMerge);
                    if(wrapper.isSuccess){
                        ContentVersion content = new ContentVersion();
                        content.VersionData = wrapper.mergedDocument;
                        content.Title = fileName;
                        content.PathOnClient = fileName;
                        content.FirstPublishLocationId = policyApplicationId;
                        content.Application_Policy__c = policyApplicationId;
                        content.Account__c = policy.Account__c;
                        content.Document_Type__c = 'Renewal Bundle';
                        content.Is_System_Generated_Document__c = true;
                        content.Unique_Identifier__c = policyApplicationId + '_' + UserInfo.getUserId() +  '_' + currentMilliSeconds;
                        insert content;
                        mergedContentVersionId = content.Id;
                        base64Value = EncodingUtil.base64Encode(wrapper.mergedDocument);
                        System.debug(content.Id);
                        return new PageReference(System.URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/'+content.Id+'?asPdf=false&operationContext=CHATTER');
                    }else{
                        return null;
                    }
                }else{
                    return null;
                }
                /*quoteList = [select id,name,POLICY_EFFECTIVE_DATE__C,POLICY_FIRM__C,FIRM_BILLINGSTREET__C,FIRM_BILLINGCITY__C,FIRM_BILLINGSTATE__C,FIRM_BILLINGZIP__C,CREATEDDATE,QUOTE_EXPIRE_DATE__C,Policy__C,
                             FIRM_PRIOR_ACTS_DATE__c,COVERAGE_MAX_PER_CLAIM__c,FULL_COVERAGE__C,DEDUCTIBLE_AMOUNT__C,QUOTE_FINAL_PREMIUM__c,QUOTE_FINAL_PREMIUM_QRTLY__c,QUOTE_FINAL_PREMIUM_MONTHLY__c from Policy_Quote__c where Policy__c=: policyApplicationId ];
                policyLawyers = [SELECT Lawyer__r.Name, Prior_Act_Date__c, Lawyer__r.Contact__r.ARDC_Number__c, Lawyer__r.Contact__r.ISBA__c,
                                 Lawyer__r.Contact__r.Contact_Role__c,Contact_Role__c,Lawyer__r.Contact__r.Email
                                 FROM Policy_Lawyer__c WHERE Policy__c =: policyApplicationId order by Lawyer__r.Contact__r.LastName ASC];  
                Apexpages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename="'+fileName+'"');
                PageReference np = new PageReference('/apex/EZRenewal');
                np.setRedirect(false);
                return np;*/
                
            /*
             * CREATE EZQ DOCUMENTS (SUPER EZ)
             */
            }else{
                List<Blob> documentsToMerge = new List<Blob>();
                Blob body;
                Decimal currentMilliSeconds = System.now().getTime();
                for(PolicyDocument doc : documentsList){
                    ContentVersion content = new ContentVersion();
                    if(doc.typeOfDocument == 'Cover Letter'){
                        PageReference pg = Page.EZQCoverLetter;
                        pg.getParameters().put('id',(String)policyApplicationId);
						pg.getParameters().put('version',(String)policy.Policy_Document_Version__c);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                        if(body!=null){
                            documentsToMerge.add(body);
                            body = null;
                        }
                    }else if(doc.typeOfDocument == 'Renewal Application'){
                        PageReference pg = Page.EZQApplication;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                        if(body!=null){
                            documentsToMerge.add(body);
                            body = null;
                        }
                        
                        // T&C
                        pg = Page.EZQRenewalTerms;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                        if(body!=null){
                            documentsToMerge.add(body);
                            body = null;
                        }
                        
                        //DISABLE PAYMENT OPTIONS - kyle.hoker 2023-03-21
                        // Payment Options
                        /*
                        pg = Page.Payment_Options_Pdf;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                        if(body!=null){
                            documentsToMerge.add(body);
                            body = null;
                        }
                        */
                        
                        // IBF Dividend Options
                        if (policy.ISBAM_policy_dividend__c > 0){
                            pg = Page.IBF_Dividend_PDF;
                            pg.getParameters().put('id',(String)policyApplicationId);
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

                        
                        // DISABLE PAYMENT AUTHORIZATION - kyle.hoker 2022-10-28
                        // Payment Authorization
                        /*
                        pg = Page.Authorization_Form_Pdf;
                        pg.getParameters().put('id',(String)policyApplicationId);
                        try {
                            body = pg.getContent();
                        } catch (VisualforceException e) {
                            body = Blob.valueOf('Some Error Occurred While PDF Generation.');
                        }
                        if(body!=null){
                            documentsToMerge.add(body);
                            body = null;
                        }
                        */
						
                    }else if(doc.typeOfDocument == 'Comprehensive Cyber Liability Insurance Program'){
                        PageReference pg = Page.Comprehensive_Cyber_Liability_Pdf;
                        pg.getParameters().put('id',(String)policyApplicationId);
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
                }
                if(documentsToMerge.size()>0){
                    DocumentBundleUtility.DocumentBundleUtilityWrapper wrapper = DocumentBundleUtility.mergePDF(documentsToMerge);
                    if(wrapper.isSuccess){
                        ContentVersion content = new ContentVersion();
                        content.VersionData = wrapper.mergedDocument;
                        content.Title = fileName;
                        content.PathOnClient = fileName;
                        content.FirstPublishLocationId = policyApplicationId;
                        content.Application_Policy__c = policyApplicationId;
                        content.Account__c = policy.Account__c;
                        content.Document_Type__c = 'Renewal Bundle';
                        content.Is_System_Generated_Document__c = true;
                        content.Unique_Identifier__c = policyApplicationId + '_' + UserInfo.getUserId() +  '_' + currentMilliSeconds;
                        insert content;
                        mergedContentVersionId = content.Id;
                        base64Value = EncodingUtil.base64Encode(wrapper.mergedDocument);
                        System.debug(content.Id);
                        return new PageReference(System.URL.getOrgDomainUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/'+content.Id+'?asPdf=false&operationContext=CHATTER');
                    }else{
                        return null;
                    }
                }else{
                    return null;
                }
            }
        }
    }
    @future
    public static void deleteDownloadedContent(Id contentId){
        DocumentBundleVF_Ctrl.sleep(10000);
        ContentVersion cv = [select id,ContentDocumentId from ContentVersion where id =: contentId];
        delete new ContentDocument(Id = cv.ContentDocumentId);
    }
    public static void sleep(Long milliSeconds){
        Long timeDiff = 0;
        DateTime firstTime = System.now();
        do
        {
            timeDiff = System.now().getTime() - firstTime.getTime();
        }
        while(timeDiff <= milliSeconds);
    }
    public PageReference close(){
        return new PageReference('/'+policyApplicationId);
    }
   public class PolicyDocument{
        public String typeOfDocument{get;set;}
        public Id recordId{get;set;}
        public Policy_Endorsement__C endorsement{get;set;}
        public  PolicyDocument(String typeOfDocument,Id recordId,Policy_Endorsement__C endorsement){
            this.typeOfDocument=typeOfDocument;
            this.recordId=recordId;
            this.endorsement =endorsement;
        }
    }
    
    public PageReference printPolicy(){
        fromDirectDownloadPage = true;
        //selectedDocuments = allDocuments;
        Policy__c policy1 = new Policy__c(Id = policyApplicationId,Status__c = 'Printed',Print_Date__c = System.now());
        update policy1;
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename="'+policy.Account__r.Name +' - '+policy.Name+' Documents.pdf' +'"');
        return generateBundle();
    }
    public PageReference printQuotes(){
        fromDirectDownloadPage = true;
        //Apexpages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename="'+policy.Account__r.Name +' - '+policy.Name+' Quote Bundle.pdf' +'"');
        return generateBundle();
    }  
    public String autoRenewal(){
        fromDirectDownloadPage = true;
        generateBundle();
        return mergedContentVersionId;
    }
    public PageReference autoGenerate(){
        if(typeOfButton=='lawyerSupplement'){
            fromDirectDownloadPage = true;
            generateBundle();
            return new PageReference('/'+policyApplicationId);
        }
        return null;
    }
}