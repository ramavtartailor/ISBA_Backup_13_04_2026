global class Batch_GetAllTransactions implements Database.Batchable<Sobject>,Schedulable,Database.AllowsCallouts{
	global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([select Id from User Limit 1]);
    }
    global void execute(Database.BatchableContext BC, List<User> batch) {
        String csvString = 'Origination Date,Settle Date,Account Type,Client ID,Consumer ID,Total Amount,Transaction ID,Credit Card Processor,Cardholder Name,BillTo Company Name,Transaction Type,Entered By,Entry Description,Service Fee,Credit or Debit,Status,Created Date,Response Code,Response Description,Response Type,Batch Reference Code\n';
        csvString += ',,,,,,,,,,,,,,,,,,,,\n';        
        
        Map<String,String> csvStringMap = new Map<String,String>();
        
        csvStringMap = getAllTransactions(csvStringMap,null);
        
        Set<String> trnIdsSet = new Set<String>();
        for(String key: csvStringMap.keySet()){
            trnIdsSet.add(key);
            trnIdsSet.add(key.replace('trn_',''));
        }
        
        List<AcctSeed__Cash_Receipt__c> cashReceiptList = [SELECT Id,AcctSeed__Payment_Reference__c 
                                                           FROM AcctSeed__Cash_Receipt__c 
                                                           WHERE AcctSeed__Payment_Reference__c IN:  csvStringMap.keySet() ];
        
        List<String> refCashReceiptMatchSet = new List<String>();
        
        for(AcctSeed__Cash_Receipt__c crObj : cashReceiptList ){
            System.debug('<<<<<<<<<<the value of payment reference is>>>>>>>>>>>>>>' +crObj.AcctSeed__Payment_Reference__c);
            if(crObj.AcctSeed__Payment_Reference__c != null){
                refCashReceiptMatchSet.add(crObj.AcctSeed__Payment_Reference__c.replace('trn_',''));
            }
        }
        
        system.debug('csv => '+csvStringMap.keySet());
        
        system.debug('ref => '+refCashReceiptMatchSet);
        
        
        for(String str : csvStringMap.keySet()){
            system.debug(str);
            system.debug(refCashReceiptMatchSet.contains(str));
                     
            system.debug(refCashReceiptMatchSet.contains(str.replace('trn_','')));
            
            if(!(refCashReceiptMatchSet.contains(str) || refCashReceiptMatchSet.contains(str.replace('trn_','')))){
                system.debug('csv Data => '+csvStringMap.get(str));
                csvString += csvStringMap.get(str);
                system.debug(csvString);
            }
        }
        
        system.debug('csvString => '+csvString);
        
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        Blob csvBlob = blob.valueOf(csvString);
        String csvName = 'Transactions - '+System.today()+'.csv';
        List<ContentWorkspace> workspace = new List<ContentWorkspace>([SELECT Id FROM ContentWorkspace WHERE Name =: Label.Accounting_File_Library ]);
        List<ContentFolder> folder = new List<ContentFolder>([SELECT Id,ParentContentFolderId FROM ContentFolder WHERE Name =: Label.Accounting_Forte_File_Library]);
        ContentVersion fileToUpload = new ContentVersion();
        
        fileToUpload.pathOnClient =csvName;
        fileToUpload.title = csvName;
        fileToUpload.versionData = csvBlob;
        fileToUpload.FirstPublishLocationId = workspace[0].Id;
        
        insert fileToUpload;
		  
        
        List<ContentFolderMember> folderMembers = new List<ContentFolderMember>();
        for(ContentFolderMember cfm : [Select Id, ChildRecordId, ParentContentFolderId
                                       from ContentFolderMember
                                       where ParentContentFolderId =: folder[0].ParentContentFolderId and CreatedDate = TODAY]) {
                                           cfm.ParentContentFolderId = folder[0].Id;
                                           folderMembers.add(cfm);
                                       }
        
        update folderMembers;
        
        /*csvAttachment.setFileName(csvName);
        csvAttachment.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = Label.System_Admin_Emails.split(',');
            String subject = 'Forte Transaction File';
        email.setSubject(subject);
        email.setToAddresses(toAddresses);
        email.setPlainTextBody('Please find attached the transactions file.');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});*/
        
    }
    public Map<String,String> getAllTransactions(Map<String,String> csvStringMap,String URL){
        ForteAllTransactionsWrapper wrapper = ForteUtil.getAllTransactions(URL);
        system.debug('wrapper==='+wrapper);
        for(ForteAllTransactionsWrapper.cls_results result : wrapper.results){
            
            system.debug(result.transaction_id +' => '+((result.status.equalsIgnoreCase('Funded') ||  result.status.equalsIgnoreCase('Settled')) && (result.action == 'sale' || result.action.equalsIgnoreCase('DEBIT'))));
            
            if((result.status.equalsIgnoreCase('Funded') || //result.status.equalsIgnoreCase('Ready') || result.status.equalsIgnoreCase('Settling') ||
               result.status.equalsIgnoreCase('Settled')) && (result.action == 'sale' || result.action.equalsIgnoreCase('DEBIT')) ){
                   String tempStr = (result.origination_date != null ? result.origination_date : result.received_date) + ',,,,';
                   //system.debug('tempStr => '+tempStr);
                   tempStr += (result.customer_id != null ? result.customer_id : '') + ',' ;
                   //system.debug('tempStr => '+tempStr);
                   tempStr += result.authorization_amount + ',' + result.transaction_id + ',,,"' + result.billing_address.company_name + '",,' + result.entered_by + ',,' ;
                   //system.debug('tempStr => '+tempStr);
                   tempStr += (result.service_fee_amount != null ? result.service_fee_amount : null) + ',,'; 
                   //system.debug('tempStr => '+tempStr);
                   tempStr += result.status + ',' + result.received_date + ',' + result.response.response_code + ',,,\n';
                   
                   system.debug('tempStr => '+tempStr);                   
                   csvStringMap.put(result.transaction_id,tempStr);
            }
        }
        if(wrapper.links.next != null){
            return getAllTransactions(csvStringMap,wrapper.links.next);
        }else{
            return csvStringMap;
        }
    }
    global void finish(Database.BatchableContext BC) { 
    }
    global void execute(SchedulableContext sc){
        Database.executeBatch(new Batch_GetAllTransactions(),100);
    }
}