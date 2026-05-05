public class SendEmailExt {

    public class SendEmailExtException extends Exception {}
    
    public Static Set<String> otherCvIds = new Set<String>();
    public static Boolean sendToUnderwriter = false;
    
    @auraEnabled public static EmailWrapper getDetails(Id RecordId,String buttonType){
        try{
            String sObjName = RecordId.getSObjectType().getDescribe().getName();
            EmailWrapper wrp = new EmailWrapper();
            wrp.recordId = RecordId;
            if(String.isNotBlank(sObjName)){
                List<Send_Email__mdt> mdtList = new List<Send_Email__mdt>([select id,Object_API_Name__c,Email_Template_Name__c,Send_To_Contact_Field_API_Name__c,Attachment_Library_Name__c, Fields_To_Query__c  from Send_Email__mdt where Object_API_Name__c =: sObjName limit 1]);
                if(!mdtList.isEmpty()){
                    string qry = 'select ';
                    if(sObjName == 'Policy__c' && (!mdtList[0].Fields_To_Query__c.containsIgnoreCase('Application_Type__c')) && (!mdtList[0].Send_To_Contact_Field_API_Name__c.containsIgnoreCase('Application_Type__c'))){
                        qry += 'Application_Type__c, ';
                        qry += mdtList[0].Fields_To_Query__c  + ',' +mdtList[0].Send_To_Contact_Field_API_Name__c +' from '+mdtList[0].Object_API_Name__c+' where id = \''+RecordId+'\'';
                    }
                    else if(sObjName == 'Policy_Endorsement__c'){
                        qry += 'Id, Name, Policy__c, Endorsement_Number__c, Account__c ';
                        
                        if(String.isNotBlank(mdtList[0].Fields_To_Query__c) && (!qry.contains(mdtList[0].Fields_To_Query__c ))){
                            qry += ',' + mdtList[0].Send_To_Contact_Field_API_Name__c;
                        }
                        
                        if(String.isNotBlank(mdtList[0].Send_To_Contact_Field_API_Name__c) && (!qry.contains(mdtList[0].Send_To_Contact_Field_API_Name__c))){
                            qry += ',' + mdtList[0].Send_To_Contact_Field_API_Name__c;
                        }
                        
                            qry +=  ' from '+mdtList[0].Object_API_Name__c+' where id = \''+RecordId+'\'';
                    }
                    else{
                        qry += mdtList[0].Fields_To_Query__c  + ',' +mdtList[0].Send_To_Contact_Field_API_Name__c +' from '+mdtList[0].Object_API_Name__c+' where id = \''+RecordId+'\'';
                    }
                    system.debug(qry);
                    sObject obj = Database.query(qry);
                    
                    //wrp.toAddressList = new List<Contact>();
                    List<ContactWrap> AddressList = new List<ContactWrap>();
                    List<ContactWrap> AddressList1 = new List<ContactWrap>();
                    ContactWrap conWrap = new ContactWrap();
                    String contId = '';
                    
                    string contactId = '';
                    if(mdtList[0].Send_To_Contact_Field_API_Name__c.contains('__r')){
                        sObject parentObj = obj.getSobject(mdtList[0].Send_To_Contact_Field_API_Name__c.substringBefore('.'));
                        contactId = String.valueOf(parentObj.get(mdtList[0].Send_To_Contact_Field_API_Name__c.substringAfter('.')));
                    }
                    else{
                        contactId = String.valueOf(obj.get(mdtList[0].Send_To_Contact_Field_API_Name__c));
                    }
                    
                    system.debug(contactId);
                    
                    if(String.isNotBlank(contactId)){
                        List<Contact> sendToContact = [select Id,Name,Email,Contact_Full_Name__c from contact where id =: contactId];
                        if(sendToContact.size() > 0){
                            wrp.sendToContactEmailSelected = sendToContact[0].Email;
                            wrp.sendToContactSelected = sendToContact[0];
                            contId = sendToContact[0].Id;
                            conWrap.SelectedContact = sendToContact[0];
                            conWrap.Selected= true;
                            AddressList.add(conWrap);
                            
                            String accountId;
                            if(sObjName == 'AcctSeed__Billing__c'){
                                accountId = String.valueOf(obj.get('AcctSeed__Customer__c'));
                            }else{
                                accountId = String.valueOf(obj.get('Account__c'));
                            }
                            
                            Set<id> contactIds = new Set<id>();
                            for(AccountContactRelation acr : [select id,AccountId,ContactId from AccountContactRelation where AccountId =: accountId]){
                                contactIds.add(acr.ContactId);
                            }
                            for(Contact con : [select Id,Name,Email,Primary_Contact__c from contact where id =: contactIds and id !=: contId order by Name ASC]){
                                
                                ContactWrap conWrap2 = new ContactWrap();
                                conWrap2.SelectedContact = con;
                                // wrp.toAddressList.add(con);
                                if(con.Primary_Contact__c){
                                    conWrap2.Selected= true;
                                    if(String.isNotBlank(wrp.CCAddress)){
                                        wrp.CCAddress += ';'+con.Email;
                                        wrp.CCAddressDisplay += ';'+ con.Name + ' (' + con.Email + ')'; 
                                    }else{
                                        wrp.CCAddress = con.Email;
                                        wrp.CCAddressDisplay = con.Name + ' (' + con.Email + ')'; 
                                    }
                                }
                                AddressList.add(conWrap2);
                                AddressList1.add(conWrap2);
                            }
                        }else{
                            wrp.noContactReference = true;
                            wrp.sendToContactEmailSelected = contactId;
                            Contact cont = new Contact();
                            cont.Email = wrp.sendToContactEmailSelected;
                            wrp.sendToContactSelected = cont;
                            //contId = sendToContact[0].Id;
                            conWrap.SelectedContact = cont;
                            conWrap.Selected= true;
                            AddressList.add(conWrap);
                        }
                        
                        
                        if(sObjName == 'Customer_Application__c' && obj.get('Contact__c') != null){
                            wrp.sendToContactSelected.Id = String.valueOf(obj.get('Contact__c'));
                        }
                    }
                    wrp.isBCCchecked = false;
                    wrp.bccAddress = UserInfo.getUserEmail();
                    wrp.toAddressList = AddressList; 
                    wrp.ccAddressList = AddressList1;
                    wrp.fromAddressList = new List<String>();
                    for(OrgWideEmailAddress em : [select Id,Address from OrgWideEmailAddress]){
                        //wrp.fromAddressSelected = em.Address;
                        wrp.fromAddressList.add(em.Address);
                    }
                    wrp.fromAddressList.add(UserInfo.getUserEmail());
                    wrp.templateList = new List<String>();
                    wrp.attachments = new List<attchWrapper>();                
                    Set<id> cdIdSet = new Set<id>();
                    String contentVersionId;
                    if(buttonType.equalsIgnoreCase('quoteBundle')){
                        DocumentBundleVF_Ctrl doc = new DocumentBundleVF_Ctrl(RecordId,buttonType,String.valueOf(obj.get('Renewal_Type__c')));
                        contentVersionId = doc.autoRenewal();
                        wrp.folderName = 'Underwriting Email Templates';
                        wrp.fromAddressSelected = 'underwriting@isbamutual.com';
                        wrp.templateName = 'Quote Email';
                        if(sObjName == 'Policy__c' && obj.get('Application_Type__c') != null && obj.get('Application_Type__c') == 'New Business'){
                            wrp.templateName = 'Quote Email (NBA)'; 
                            wrp.folderName = 'Sales';
                        } 
                        wrp = changeFolder(wrp);
                        wrp = changeTemplate(wrp,RecordId);
                        System.debug('contentVersionId' + contentVersionId);
                    }
                    else if(buttonType.equalsIgnoreCase('renewalBundle')){
                        //DocumentBundleVF_Ctrl doc = new DocumentBundleVF_Ctrl(RecordId,'quoteBundle',String.valueOf(obj.get('Renewal_Type__c')));
                        //contentVersionId = doc.autoRenewal();
                        system.debug('contentVersionId => '+contentVersionId);
                        
                        wrp.folderName = 'Underwriting Email Templates';
                        wrp.fromAddressSelected = 'underwriting@isbamutual.com';
                        wrp.templateName = 'Regular Renewal Template';
                        
                        wrp = changeFolder(wrp);
                        wrp = changeTemplate(wrp,RecordId);
                        System.debug('contentVersionId' + contentVersionId);
                    }
                    else if(buttonType == 'renewalBatch'){
                        
                        if(String.valueOf(obj.get('Renewal_Type__c')) == 'Regular Renewal'){
                            wrp.templateName = 'Regular Renewal Online Application (from Policy App)';
                        }
                        else if(String.valueOf(obj.get('Renewal_Type__c')) == 'Online Invoice'){
                            wrp.templateName = 'Online Policy Invoice (Renewal)';
                            
                            if(sObjName == 'Policy__c' && obj.get('Application_Type__c') != null && obj.get('Application_Type__c') == 'New Business'){
                                wrp.templateName = 'Online Policy Invoice (NBA)'; 
                            }   
                        }
                        
                        wrp.folderName = 'Underwriting Email Templates';
                        wrp.fromAddressSelected = 'underwriting@isbamutual.com';
                        wrp = changeFolder(wrp);
                        wrp = changeTemplate(wrp,RecordId);                    
                    }
                    else if(buttonType == 'renewal'){
                        
                        if(String.valueOf(obj.get('Renewal_Type__c')) == 'Regular Renewal'){
                            wrp.templateName = 'Online Policy Invoice (Regular Renewal)';
                            if(obj.get('Customer_Application__c') != null && String.valueOf(obj.getSobject('Customer_Application__r').get('Application_Status__c')) != 'Reviewed'){
                                throw new SendEmailExtException('Invoices should be sent only after the Online Application status is "Reviewed".');
                            }
                        }else if(String.valueOf(obj.get('Renewal_Type__c')) == 'EZ Renewal'){
                            wrp.templateName = 'EZ Renewal Email';
                        }else if(String.valueOf(obj.get('Renewal_Type__c')) == 'Online Invoice'){
                            wrp.templateName = 'Online Policy Invoice (Renewal)';
                            
                            if(sObjName == 'Policy__c' && obj.get('Application_Type__c') != null && obj.get('Application_Type__c') == 'New Business'){
                                wrp.templateName = 'Online Policy Invoice (NBA)'; 
                            }   
                        }else{
                            wrp.templateName = 'Super EZ Renewal Template';
                        }
                        
                        if(String.valueOf(obj.get('Renewal_Type__c')) != 'Online Invoice' &&  String.valueOf(obj.get('Renewal_Type__c')) != 'Regular Renewal'){
                            DocumentBundleVF_Ctrl doc = new DocumentBundleVF_Ctrl(RecordId,buttonType,String.valueOf(obj.get('Renewal_Type__c')));
                            contentVersionId = doc.autoRenewal();
                        }
                        
                        wrp.folderName = 'Underwriting Email Templates';
                        wrp.fromAddressSelected = 'underwriting@isbamutual.com';
                        wrp = changeFolder(wrp);
                        wrp = changeTemplate(wrp,RecordId);                    
                    }
                    else if(buttonType.equalsIgnoreCase('printPolicyDocs')){
                        DocumentBundleVF_Ctrl doc = new DocumentBundleVF_Ctrl(RecordId,buttonType,String.valueOf(obj.get('Renewal_Type__c')));
                        contentVersionId = doc.autoRenewal();
                        wrp.folderName = 'Underwriting Email Templates';
                        wrp.fromAddressSelected = 'underwriting@isbamutual.com';
                        
                        wrp.templateName = 'Policy Documents Email';
                        if(sObjName == 'Policy__c'){
                            if(obj.get('Application_Type__c') != null && obj.get('Application_Type__c') == 'New Business'){
                                wrp.templateName = 'Policy Documents Email - NBA'; 
                            }
                        }
                        wrp = changeFolder(wrp);
                        wrp = changeTemplate(wrp,RecordId);
                    }
                    else if(buttonType.equalsIgnoreCase('sendEmail')){
                        wrp.folderName = 'Underwriting Email Templates';
                        wrp.fromAddressSelected = 'underwriting@isbamutual.com';
                        if(sObjName == 'Policy__c'){
                            if(obj.get('Application_Type__c') != null && obj.get('Application_Type__c') == 'New Business'){
                                wrp.folderName = 'Sales';
                                wrp.templateName = 'Online Policy Invoice (NBA)'; 
                            }
                            /* List<Policy__c> pol = [SELECT Id,Application_Type__c FROM Policy__c WHERE Id=:RecordId AND Application_Type__c = '' LIMIT 1];
                            if(!pol.isEmpty()){
                            wrp.templateName = 'Online Policy Invoice (NBA)';
                            }*/
                        }
                        wrp = changeTemplate(wrp,RecordId);
                        wrp = changeFolder(wrp);                    
                    }
                    else if(buttonType.equalsIgnoreCase('sendContactEmail')){
                        wrp.folderName = 'Sales';
                        wrp.fromAddressSelected = UserInfo.getUserEmail();//'insure@isbamutual.com';
                        wrp = changeTemplate(wrp,RecordId);
                        wrp = changeFolder(wrp);                    
                    }
                    else if(buttonType.equalsIgnoreCase('onlineNBALinkEmail')){
                        if(sObjName == 'Customer_Application__c' && Obj.getSobject('RecordType').get('Name') == 'Regular Renewal'){
                            wrp.templateName = 'Regular Renwal Online Application (from Online App)';
                            wrp.folderName = 'Underwriting Email Templates';
                            wrp.fromAddressSelected = 'underwriting@isbamutual.com';
                            wrp = changeTemplate(wrp,RecordId);
                            wrp = changeFolder(wrp);             
                        }   
                    }
                    else if(buttonType.equalsIgnoreCase('sendNBA_Invoice')){
                        if(sObjName == 'Policy__c' && obj.get('Application_Type__c') != null && obj.get('Application_Type__c') == 'New Business'){
                            wrp.templateName = 'NBA - Quote for ISBA Active Firms';
                            wrp.folderName = 'Sales';
                            wrp.fromAddressSelected = 'underwriting@isbamutual.com';
                            wrp = changeTemplate(wrp,RecordId);
                            wrp = changeFolder(wrp); 
                        }
                    }
                    else if(buttonType.equalsIgnoreCase('closeoutletter')){
                        PageReference pg = Page.Closeout_Letter;
                        pg.getParameters().put('id',(String)recordId);
                        
                        String fileName = obj.get('Firm_Name__c') +' - '+obj.get('Name') + ' - Close Out Letter.pdf';
                        
                        Timezone tz = Timezone.getTimeZone('America/Chicago');
                        Decimal currentMilliSeconds = System.now().getTime();
                        
                        ContentVersion content = new ContentVersion();
                        if(Test.isRunningTest()) { 
                            content.VersionData = blob.valueOf('Unit.Test');
                        } else {
                            content.VersionData = pg.getContent();
                        }
                        
                        content.Title = fileName;
                        content.PathOnClient = fileName;
                        content.FirstPublishLocationId = recordId;
                        content.Application_Policy__c = recordId;
                        content.Account__c = (Id)obj.get('Account__c');
                        content.Document_Type__c = 'Close Out Letter';
                        content.Is_System_Generated_Document__c = true;
                        content.Unique_Identifier__c = recordId + '_' + UserInfo.getUserId() +  '_' + currentMilliSeconds;
                        insert content;
                        
                        contentVersionId = content.Id;
                        
                        wrp.folderName = 'Underwriting Email Templates';
                        wrp.fromAddressSelected = 'underwriting@isbamutual.com';
                        // wrp.templateName = 'Close Out Letter Template';
                        wrp.templateName = 'Close Out Letter';
                        wrp = changeFolder(wrp);
                        wrp = changeTemplate(wrp,RecordId);
                        wrp = changeFolder(wrp);                   
                    }
                    else if(buttonType.equalsIgnoreCase('billingNOC')){
                        PageReference pg = Page.NOC_PDF;
                        pg.getParameters().put('id',(String)recordId);
                        
                        String fileName = obj.get('Policy_Number__c') +' - '+obj.get('Name') + ' - NOC.pdf';
                        
                        Timezone tz = Timezone.getTimeZone('America/Chicago');
                        Decimal currentMilliSeconds = System.now().getTime();
                        
                        ContentVersion content = new ContentVersion();
                        if(Test.isRunningTest()) { 
                            content.VersionData = blob.valueOf('Unit.Test');
                        } else {
                            content.VersionData = pg.getContent();
                        }
                        
                        content.Title = fileName;
                        content.PathOnClient = fileName;
                        content.FirstPublishLocationId = recordId;
                        content.Account__c = (Id)obj.get('AcctSeed__Customer__c');
                        content.Document_Type__c = 'NOC';
                        content.Is_System_Generated_Document__c = true;
                        content.Unique_Identifier__c = recordId + '_' + UserInfo.getUserId() +  '_' + currentMilliSeconds;
                        insert content;
                        
                        contentVersionId = content.Id;
                        
                        wrp.fromAddressSelected = 'accounting@isbamutual.com';
                        wrp.folderName = 'Accounting Email Templates';
                        //wrp.templateName = 'NOC Email Template';
                        wrp.templateName = 'Billing NOC';
                        wrp = changeFolder(wrp);
                        wrp = changeTemplate(wrp,RecordId);
                        system.debug('wrp -- > ' + wrp);
                    }
                    else if(buttonType.equalsIgnoreCase('billingCOLNOC')){
                        PageReference pg = Page.COLNOC_PDF;
                        pg.getParameters().put('id',(String)recordId);
                        
                        String fileName = obj.get('Policy_Number__c') +' - '+obj.get('Name') + ' - COLNP.pdf';
                        wrp.folderName = 'Accounting Email Templates';
                        wrp.templateName = 'Billing Close Out Letter - NP(New Business)';
                        if(sObjName == 'AcctSeed__Billing__c'){
                            Schema.DescribeFieldResult fieldResult = AcctSeed__Billing__c.Policy__c.getDescribe();
                            Schema.SObjectField field = fieldResult.getSObjectField();
                            
                            Sobject policyObj =  obj.getSobject(field);
                            if(String.valueOf(policyObj.get('Application_Type__c')) == 'Renewal'){
                                wrp.templateName = 'Billing Close Out Letter - NP(Renewal)';
                                fileName = obj.get('Policy_Number__c') +' - '+obj.get('Name') + ' - COLNP-Renewal.pdf';
                            }
                        }
                        
                        
                        Timezone tz = Timezone.getTimeZone('America/Chicago');
                        Decimal currentMilliSeconds = System.now().getTime();
                        
                        ContentVersion content = new ContentVersion();
                        if(Test.isRunningTest()) { 
                            content.VersionData = blob.valueOf('Unit.Test');
                        } else {
                            content.VersionData = pg.getContent();
                        }
                        
                        content.Title = fileName;
                        content.PathOnClient = fileName;
                        content.FirstPublishLocationId = recordId;
                        content.Account__c = (Id)obj.get('AcctSeed__Customer__c');
                        content.Document_Type__c = 'Close Out Letter - NOC';
                        content.Is_System_Generated_Document__c = true;
                        content.Unique_Identifier__c = recordId + '_' + UserInfo.getUserId() +  '_' + currentMilliSeconds;
                        insert content;
                        
                        contentVersionId = content.Id;
                        
                        wrp.fromAddressSelected = 'accounting@isbamutual.com';
                        wrp.folderName = 'Accounting Email Templates';
                        // wrp.templateName = 'COLNOC Email Template';
                        
                        wrp = changeFolder(wrp);
                        wrp = changeTemplate(wrp,RecordId);
                    }
                    else if(buttonType.equalsIgnoreCase('sendInvoice')){
                        if(String.valueOf(obj.get('Endorsement_Number__c')) == 'IL 152'){
                            wrp.templateName = 'INVOICE - IL152 Add Lawyer';
                        }
                        else{
                            wrp.templateName = 'INVOICE - IL107 ERE';
                        }
                        wrp.folderName = 'Underwriting Email Templates';
                        wrp.fromAddressSelected = 'underwriting@isbamutual.com';
                        wrp = changeFolder(wrp);
                        List<EmailTemplate> templateList = new List<EmailTemplate>([Select id,Subject,Body,HtmlValue from EmailTemplate where name =: wrp.templateName]);
                        if(!templateList.isEmpty()){
                            wrp.templateId = templateList[0].Id;
                            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(wrp.templateId,contId,RecordId);
                            wrp.emailSubject = String.valueOf(email.getSubject());
                            if(email.getHtmlBody() != null){
                                wrp.emailBody = String.valueOf(email.getHtmlBody());
                            }else{
                                wrp.emailBody = email.getPlainTextBody().replaceAll('\n','<br/>');
                                wrp.emailBody = wrp.emailBody.replaceAll('<p>','');
                                wrp.emailBody = wrp.emailBody.replaceAll('</p>','');
                            }
                            //wrp.emailBody = email.getPlainTextBody();
                        }
                    }
                    else if(buttonType.equalsIgnoreCase('finalEmail')){
                        wrp.templateName = 'Incomplete Online Application - Final Close Notice';
                        wrp.folderName = 'Sales';
                        wrp.fromAddressSelected = 'sales@isbamutual.com';
                        wrp = changeFolder(wrp);
                        wrp = changeTemplate(wrp,RecordId);
                    }

                    system.debug('otherCvIds => '+otherCvIds);                

                    for(ContentDocumentLink cdl : [select id,ContentDocumentId from ContentDocumentLink where LinkedEntityId =:RecordId]){
                        cdIdSet.add(cdl.ContentDocumentId);
                    }
                    System.debug('contentVersionId' + contentVersionId);
                    if(!cdIdSet.isEmpty()){
                        for(contentVersion cv : [select Id, ContentSize ,Title,CreatedById,CreatedBy.Name,CreatedDate,LastModifiedById,LastModifiedBy.Name,LastModifiedDate,ContentDocumentId,Document_Type__c from contentVersion where ContentDocumentId =: cdIdSet order by CreatedDate DESC]){//,VersionData
                            attchWrapper attch = new attchWrapper();
                            if(contentVersionId == cv.Id){
                                attch.attached = true;
                            }
                            else if(otherCvIds.contains(cv.Id)){
                                attch.attached = true;
                            }
                            else{
                                attch.attached = false;
                            }
                            attch.attachment = cv;
                            wrp.attachments.add(attch);
                        }
                    }
                    
                    wrp.folderList = new List<string>();
                    for(Folder fl : [select id,name from folder where Type = 'Email' limit 1000]){
                        wrp.folderList.add(fl.name);
                    }
                    
                    wrp.LibraryAttachments = new List<attchWrapper>();
                    if(String.isNotBlank(mdtList[0].Attachment_Library_Name__c)){
                        List<ContentWorkspace> workspace = new List<ContentWorkspace>([SELECT Id FROM ContentWorkspace WHERE Name =: mdtList[0].Attachment_Library_Name__c]);
                        if(!workspace.isEmpty()){
                            for(ContentVersion cv : [SELECT Id,ContentSize, Title,CreatedById,CreatedBy.Name,CreatedDate,LastModifiedById,LastModifiedBy.Name,LastModifiedDate,ContentDocumentId,Resource_Document_Type__c,FileExtension, Policy_Version__c,Document_Type__c  FROM ContentVersion WHERE ContentDocument.ParentId = :workspace[0].Id and IsLatest = true order by Title]){
                                attchWrapper attch = new attchWrapper();
                                Set<String> resourceDocumentTypes = cv.Resource_Document_Type__c!=null ? new Set<String>(cv.Resource_Document_Type__c.split(';')) : new Set<String>();
                                Set<String> resourceDocumentPolicyVersion = cv.Policy_Version__c!=null ? new Set<String>(cv.Policy_Version__c.split(';')) : new Set<String>();
                                attch.attached = false;
                                if(buttonType == 'renewal'){
                                    if(resourceDocumentTypes.contains(String.valueOf(obj.get('Renewal_Type__c')))){
                                        if(cv.Title == 'ISBAM - Step Rating'){
                                            if(Integer.valueOf(obj.get('Total_Lawyers__c')) > Integer.valueOf(obj.get('Total_Lawyers_For_Step_7__c')) ){
                                                attch.attached = true;
                                            }
                                        }else{
                                            attch.attached = true;
                                        }
                                    }
                                }
                                else if(buttonType == 'sendNBA_Invoice'){
                                    if(cv.Title == 'ISBAM - Step Rating'){
                                        attch.attached = true;
                                    }
                                }
                                else{
                                    if(buttonType == 'printPolicyDocs'){
                                        if(resourceDocumentTypes.contains(buttonType) && resourceDocumentPolicyVersion.contains(String.valueOf(obj.get('Policy_Document_Version__c')))){
                                            attch.attached = true;
                                        }
                                    }else{
                                        if(resourceDocumentTypes.contains(buttonType)){
                                            attch.attached = true;
                                        }
                                    }
                                }
                                attch.attachment = cv;
                                wrp.LibraryAttachments.add(attch);
                            }
                        }
                    }
                }
            }
            return wrp;
        }
        Catch(Exception e){
            System.debug('Error => '+e.getMessage()+' line no =>'+e.getLineNumber());
            throw new SendEmailExtException(e.getMessage());
        }
    }
    
    
    @auraEnabled public static EmailWrapper UpdateEmailTemp(EmailWrapper wrp,Id RecordId, Id ConId){
        wrp.sendToContactSelected = new contact(id= ConId);
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(wrp.templateId,ConId,RecordId);
        wrp.emailBody = String.valueOf(email.getHtmlBody());
        wrp.emailSubject = String.valueOf(email.getSubject());
        return wrp;
    }
    
    @auraEnabled public static EmailWrapper changeFolder(EmailWrapper wrp){
        if(String.isNotBlank(wrp.folderName)){
            String folderId = [select id from folder where Type = 'Email' AND name =:wrp.folderName].id;
            system.debug(folderId);
            wrp.templateList = new List<string>();
            for(EmailTemplate et : [SELECT Id,Name,FolderName FROM EmailTemplate WHERE FolderId =: folderId]){
                wrp.templateList.add(et.Name);
            }
        }
        return wrp;
    }
    
    @auraEnabled public static EmailWrapper changeTemplate(EmailWrapper wrp,Id RecordId){
        system.debug(wrp.templateName);
        if(String.isNotBlank(wrp.templateName)){
            List<EmailTemplate> templateList = new List<EmailTemplate>([Select id,Subject,Body,HtmlValue from EmailTemplate where name =: wrp.templateName]);
            if(!templateList.isEmpty()){
                wrp.templateId = templateList[0].Id;
                system.debug(wrp.sendToContactSelected);
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(wrp.templateId,wrp.sendToContactSelected.id,RecordId);
                wrp.emailSubject = String.valueOf(email.getSubject());
                if(email.getHtmlBody() != null){
                    wrp.emailBody = String.valueOf(email.getHtmlBody());
                }else{
                    wrp.emailBody = email.getPlainTextBody().replaceAll('\n','<br/>');
                    wrp.emailBody = wrp.emailBody.replaceAll('<p>','');
                    wrp.emailBody = wrp.emailBody.replaceAll('</p>','');
                }
              //  wrp.emailBody = email.getPlainTextBody();
            }
        }
        return wrp;
    }

    @auraEnabled public static EmailWrapper getDetailsHelper(Id RecordId,String buttonType, String contentVersionId){
        system.debug('contentVersionIdNew => '+ contentVersionId);
        if(String.isNotBlank(contentVersionId)){
            otherCvIds.add(contentVersionId);
        }
		system.debug('otherCvIds => '+otherCvIds);
        return getDetails(RecordId, buttonType);
    }
    
    @auraEnabled
    public static String getDocId(Id RecordId){
        String sObjName = RecordId.getSObjectType().getDescribe().getName();
        if(String.isNotBlank(sObjName)){
            List<Send_Email__mdt> mdtList = new List<Send_Email__mdt>([select id,Object_API_Name__c,Email_Template_Name__c,Send_To_Contact_Field_API_Name__c,Attachment_Library_Name__c, Fields_To_Query__c  from Send_Email__mdt where Object_API_Name__c =: sObjName limit 1]);
            if(!mdtList.isEmpty()){
                string qry = 'select ';
                if(sObjName == 'Policy__c' && (!mdtList[0].Fields_To_Query__c.containsIgnoreCase('Application_Type__c')) && (!mdtList[0].Send_To_Contact_Field_API_Name__c.containsIgnoreCase('Application_Type__c'))){
                    qry += 'Application_Type__c, ';
                    qry += mdtList[0].Fields_To_Query__c  + ',' +mdtList[0].Send_To_Contact_Field_API_Name__c +' from '+mdtList[0].Object_API_Name__c+' where id = \''+RecordId+'\'';
                    
                    system.debug(qry);
                    sObject obj = Database.query(qry);
                    
                    DocumentBundleVF_Ctrl doc = new DocumentBundleVF_Ctrl(RecordId,'renewal',String.valueOf(obj.get('Renewal_Type__c')));
                    String contentVersionId = doc.autoRenewal();
                    return contentVersionId;
                } 
            }
        }
        return null;
    }
    
    @auraEnabled public static string SendEmail(EmailWrapper wrp,String buttonType){
        
        try{
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            list<Id> cvList = new list<Id>();
            List<Messaging.EmailFileAttachment> emailFileAttachments = new List<Messaging.EmailFileAttachment>();
            for(attchWrapper attch : wrp.attachments){
                if(attch.attached){
                    cvList.add(attch.attachment.Id);
                }
            }
            for(attchWrapper attch : wrp.libraryAttachments){
                if(attch.attached){
                    cvList.add(attch.attachment.Id);
                }
            }
            
            for(ContentVersion cv : [select id,VersionData,Title,FileExtension from ContentVersion where id in: cvList]){
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.body = cv.versiondata;
                efa.fileName = cv.Title;
                if(!efa.fileName.endsWith('.'+cv.FileExtension)){
                    efa.fileName = cv.Title + '.' + cv.FileExtension;
                }
                emailFileAttachments.add(efa);
            }
            
            email.setSubject(wrp.emailSubject);
            email.setToAddresses(new String[] {wrp.sendToContactEmailSelected});
            if(wrp.fromAddressSelected != UserInfo.getUserEmail()){
                email.setOrgWideEmailAddressId([select Id,Address from OrgWideEmailAddress where Address =: wrp.fromAddressSelected].Id);
            }
            if(String.isNotBlank(wrp.CCAddress)){
                if(wrp.CCAddress.contains(';')){
                    email.setCCAddresses(wrp.CCAddress.split(';'));
                }else{
                    email.setCCAddresses(new String[] {wrp.CCAddress});
                }
            }
            if(wrp.isBCCchecked){
                email.setBccAddresses(new String[]{wrp.bccAddress});
            }
           
            wrp.emailBody = wrp.emailBody.replaceAll('<p><br></p>','<br><br>');
            wrp.emailBody = wrp.emailBody.replaceAll('</p><p>','<br/>');
            wrp.emailBody = wrp.emailBody.replaceAll('</p>','');
            wrp.emailBody = wrp.emailBody.replaceAll('<p>','');
           	email.setHtmlBody(wrp.emailBody);
           // email.setPlainTextBody(wrp.emailBody);
            /*if(!cvList.isEmpty()){
email.setEntityAttachments(cvList);
}*/
            if(!emailFileAttachments.isEmpty()){
                //email.setFileAttachments(emailFileAttachments);
            }
            if(!cvList.isEmpty()){
                email.setEntityAttachments(cvList);
            }
            //email.setTreatTargetObjectAsRecipient(true);
            if(wrp.sendToContactSelected != null){
                email.setTargetObjectId(wrp.sendToContactSelected.Id);
            }
            system.debug('wrp.recordId => '+wrp.recordId);
            if(wrp.recordId.startsWith('003')){
                email.setTargetObjectId(wrp.recordId);
            }else{
                email.setWhatId(wrp.recordId);
            }
            
            email.setSaveAsActivity(true);
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
            system.debug('Send Email Result => '+r);
            System.debug(buttonType);

            Boolean flag = true;
            
            if(buttonType == 'renewal'){
                flag = false;
                Policy__c pol = new Policy__c(Id = wrp.recordId,Status__c ='Sent');
                if(wrp.templateName == 'Online Policy Invoice (Renewal)' || wrp.templateName == 'Online Policy Invoice (NBA)' || wrp.templateName == 'Online Policy Invoice (Regular Renewal)'){
                    pol.Status__c ='Quoted';  
                    pol.Quote_Link_Sent_Date__c = system.now();
                    pol.Quote_Link_Sent_By__c  = UserInfo.getUserId();
                }
                System.debug(pol.Id);
                System.debug(pol.Status__c);
                update pol;
            }else if(buttonType == 'renewalBatch'){
                flag = false;
                Policy__c pol = new Policy__c(Id = wrp.recordId,Status__c ='Sent');
                if(wrp.templateName == 'Online Policy Invoice (Renewal)' || wrp.templateName == 'Online Policy Invoice (NBA)' || wrp.templateName == 'Online Policy Invoice (Regular Renewal)'){
                    pol.Status__c ='Quoted';  
                    pol.Quote_Link_Sent_Date__c = system.now();
                    pol.Quote_Link_Sent_By__c  = UserInfo.getUserId();
                }
                System.debug(pol.Id);
                System.debug(pol.Status__c);
                update pol;
            }else if(buttonType.equalsIgnoreCase('printPolicyDocs')){
                flag = false;
                Policy__c pol = new Policy__c(Id = wrp.recordId,Status__c ='Emailed',Policy_Email_Date__c = system.today(), Policy_Emailed__c = true);
                if(wrp.templateName == 'Online Policy Invoice (Renewal)' || wrp.templateName == 'Online Policy Invoice (NBA)'){
                    pol.Status__c ='Quoted';  
                    pol.Quote_Link_Sent_Date__c = system.now();
                    pol.Quote_Link_Sent_By__c  = UserInfo.getUserId();
                }
                update pol;
            }else if(buttonType.equalsIgnoreCase('closeoutletter')){
                flag = false;
                Policy__c pol = new Policy__c(Id = wrp.recordId,COL_Sent_Date__c =System.today());
                if(wrp.templateName == 'Online Policy Invoice (Renewal)' || wrp.templateName == 'Online Policy Invoice (NBA)'){
                    pol.Status__c ='Quoted'; 
                    pol.Quote_Link_Sent_Date__c = system.now();
                    pol.Quote_Link_Sent_By__c  = UserInfo.getUserId();
                }
                update pol;
            }
            else if(buttonType.equalsIgnoreCase('billingNOC')){
                flag = false;
                AcctSeed__Billing__c  pol = new AcctSeed__Billing__c (Id = wrp.recordId,NOC_Sent_Date__c  = System.today());
                update pol;
            }else if(buttonType.equalsIgnoreCase('billingCOLNOC')){
                flag = false;
                AcctSeed__Billing__c  pol = new AcctSeed__Billing__c (Id = wrp.recordId,COLNOC_Sent_Date__c   = System.today());
                update pol;
            }
            
            Id recId = wrp.recordId;
            if(flag && recId.getSObjectType().getDescribe().getName() == 'Policy__c' && (wrp.templateName == 'Online Policy Invoice (Renewal)' || wrp.templateName == 'Online Policy Invoice (NBA)')){
                Policy__c pol = new Policy__c(Id = wrp.recordId,Status__c ='Quoted', Quote_Link_Sent_Date__c = system.now(), Quote_Link_Sent_By__c  = UserInfo.getUserId());
                System.debug(pol.Status__c);
                update pol;
            }
            
            return 'success';
        }catch(exception ex){
            system.debug('ex-->'+ex.getMessage()+' => '+ex.getLineNumber());
            System.debug(Ex.getStackTraceString());
            return 'failed-'+ex.getMessage();
        }
        
    }
    
    public class EmailWrapper{
        @auraEnabled public List<ContactWrap> toAddressList{get;set;}
        @auraEnabled public List<ContactWrap> ccAddressList{get;set;}
        @auraEnabled public string sendToContactEmailSelected{get;set;}
        @auraEnabled public string CCAddress{get;set;}
        @auraEnabled public string CCAddressDisplay{get;set;}
        @auraEnabled public List<string> fromAddressList{get;set;}
        @auraEnabled public List<string> folderList{get;set;}
        @auraEnabled public List<string> templateList{get;set;}
        @auraEnabled public string emailSubject{get;set;}
        @auraEnabled public string emailBody{get;set;}
        @auraEnabled public List<attchWrapper> attachments{get;set;}
        @auraEnabled public List<attchWrapper> LibraryAttachments{get;set;}
        @auraEnabled public string fromAddressSelected{get;set;}
        @auraEnabled public string templateId{get;set;}
        @auraEnabled public string templateName{get;set;}
        @auraEnabled public string folderName{get;set;}
        @auraEnabled public Contact sendToContactSelected{get;set;}
        @auraEnabled public String recordId{get;set;}
        @auraEnabled public String bccAddress{get;set;}
        @auraEnabled public boolean isBCCchecked{get;set;}
        @auraEnabled public boolean noContactReference{get;set;}
        public EmailWrapper(){
            isBCCchecked = false;
            noContactReference = false;
        }
    }
    
    public class ContactWrap{
        @auraEnabled public Contact SelectedContact{get;set;}
        @auraEnabled public boolean Selected{get;set;}
        public ContactWrap(){
            Selected = false;
        }
    }
    
    public class attchWrapper{
        @auraEnabled public boolean attached{get;set;}
        @auraEnabled public ContentVersion attachment{get;set;}
        public attchWrapper(){
            attached = false;
        }
    }
}