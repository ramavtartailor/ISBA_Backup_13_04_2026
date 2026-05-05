global class Email_Service_Handler implements Messaging.InboundEmailHandler {
    private Messaging.InboundEmail email;
    private string csvAsString;
    private String[] csvFileLines;
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult inBoundEmail = new Messaging.InboundEmailresult();
        try
        {
            if(email != null){
                this.email = email;
                System.debug(email);
            }
            if ((email.textAttachments != null && email.textAttachments.size() > 0)) {
                inBoundEmail.success = processAttachment();
            }
        }
        catch(Exception exceptionObj){
            System.debug(exceptionObj.getMessage());
        }
        return inBoundEmail;
    }
    public boolean processAttachment(){
        if (email.textAttachments != null) {
            String successString='Id,policyID,invoiceID,invoiceType,invoiceAmount,firmName,zipCode,issueDate,firmId,effectiveDate,AcctSeed__Billing_Street__c,AcctSeed__Billing_City__c,AcctSeed__Billing_State__c,AcctSeed__Billing_PostalCode__c,Message\n';
            String errorString='policyID,invoiceID,invoiceType,invoiceAmount,firmName,zipCode,issueDate,firmId,effectiveDate,AcctSeed__Billing_Street__c,AcctSeed__Billing_City__c,AcctSeed__Billing_State__c,AcctSeed__Billing_PostalCode__c,Error Message\n';
            List<AcctSeed__Billing__c> invoiceList = new List<AcctSeed__Billing__c>();
            List<AcctSeed__Billing_Line__c> invoiceLineList = new List<AcctSeed__Billing_Line__c>();
            Account acc = [select id,name from Account where name ='Dummy Billing Account'];
            Transaction_Credit_And_Debits__c tran = Transaction_Credit_And_Debits__c.getInstance('Billing Line');
            AcctSeed__GL_Account__c glAccount = [select id,name from AcctSeed__GL_Account__c where name=:tran.Credit_GL__c];
            Folder fold = [select id from Folder where Type='Document' AND name ='Payment Gateway' limit 1];
            set<Id> successBillingIds = new set<Id>(); 
            
            for (Messaging.InboundEmail.TextAttachment att: email.textAttachments) {
                try{
                    if(att.fileName=='payment_gateway.csv'){
                        csvAsString = att.Body;
                        csvAsString = csvAsString.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
                        csvAsString = csvAsString.replaceAll('""','DBLQT');
                        csvFileLines = csvAsString.split('\n');
                        List<EmailUploadInvoiceWrapper> listUploadInvoiceWrapper = new List<EmailUploadInvoiceWrapper>();
                        for(Integer i=1;i<csvFileLines.size();i++){
                            if(csvFileLines[i].replaceAll(',','').trim().length() >0){
                                string[] csvRecordData = csvFileLines[i].split(',');
                                listUploadInvoiceWrapper.add(new EmailUploadInvoiceWrapper(csvRecordData[0].replaceAll('\\s*\\z', ''),csvRecordData[1].replaceAll('\\s*\\z', ''),csvRecordData[2].replaceAll('\\s*\\z', ''),csvRecordData[3].replaceAll('\\s*\\z', ''),csvRecordData[4].replaceAll('\\s*\\z', ''),csvRecordData[5].replaceAll('\\s*\\z', ''),csvRecordData[6].replaceAll('\\s*\\z', ''),csvRecordData[7].replaceAll('\\s*\\z', ''),csvRecordData[8].replaceAll('\\s*\\z', ''),csvRecordData[9].replaceAll('\\s*\\z', ''),csvRecordData[10].replaceAll('\\s*\\z', ''),csvRecordData[11].replaceAll('\\s*\\z', ''),csvRecordData[12].replaceAll('\\s*\\z', '')));
                            }
                        }
                        AcctSeed__Ledger__c ledger;
                        if(Test.isRunningTest()){
                            ledger = [select id from AcctSeed__Ledger__c];
                        }
                        for(EmailUploadInvoiceWrapper wrapper : listUploadInvoiceWrapper){
                            try{
                                AcctSeed__Billing__c billing = new AcctSeed__Billing__c(Legacy_Invoice_Id__c=wrapper.invoiceID);
                                AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
                                bill.AcctSeed__Customer__c = acc.id;
                                bill.Billing_Zip_Code__c = wrapper.zipCode;
                                bill.Legacy_Policy_Id__c = wrapper.policyID;
                                bill.Legacy_Invoice_Id__c= wrapper.invoiceID;
                                bill.Firm_Name__c= wrapper.firmName.replaceAll('&#44;', ',');
                                bill.Legacy_Firm_Id__c=wrapper.firmId;
                                bill.AcctSeed__Date__c= Date.valueOf(wrapper.issueDate);
                                bill.AcctSeed__Due_Date2__c = Date.valueOf(wrapper.effectiveDate); 
                                bill.AcctSeed__Billing_Street__c = wrapper.billingStreet;
                                bill.AcctSeed__Billing_City__c = wrapper.billingCity;
                                bill.AcctSeed__Billing_State__c = wrapper.billingState;
                                bill.AcctSeed__Billing_PostalCode__c = wrapper.billingZip;
                                
                                if(Test.isRunningTest()){
                                    bill.AcctSeed__Ledger__c = ledger.Id;
                                }
                                
                                AcctSeed__Billing_Line__c billLine = new AcctSeed__Billing_Line__c();
                                billLine.AcctSeed__Billing__r=billing;
                                billLine.AcctSeed__Revenue_GL_Account__c =glAccount.id;
                                billLine.AcctSeed__Rate__c=Decimal.valueOf(wrapper.invoiceAmount);
                                invoiceList.add(bill);
                                invoiceLineList.add(billLine);
                                
                            }catch(Exception exp){
                                errorString = errorString + wrapper.policyID+','+wrapper.invoiceID+','+wrapper.invoiceType+','+wrapper.invoiceAmount+','+wrapper.firmName+','+wrapper.zipCode+','+wrapper.issueDate+','+wrapper.firmId+',';
                                errorString = errorString + exp.getMessage();
                            }
                            
                        }
                        List<Database.SaveResult> resultInvoiceList = Database.insert(invoiceList,false);
                        for(Integer i=0;i<resultInvoiceList.size();i++){
                            if(!resultInvoiceList[i].isSuccess()){
                                invoiceLineList.get(i).AcctSeed__Billing__r=null;
                            }
                        }
                        List<Database.SaveResult> resultInvoiceLineList = Database.insert(invoiceLineList,false);
                        for(Integer i=0;i<resultInvoiceList.size();i++){
                            if(resultInvoiceList[i].isSuccess()){
                                if(resultInvoiceLineList[i].isSuccess()){
                                    successString  = successString + resultInvoiceList[i].getId() + ',' + listUploadInvoiceWrapper.get(i).policyID+','+listUploadInvoiceWrapper.get(i).invoiceID+','+listUploadInvoiceWrapper.get(i).invoiceType+','+listUploadInvoiceWrapper.get(i).invoiceAmount+','+listUploadInvoiceWrapper.get(i).firmName+','+listUploadInvoiceWrapper.get(i).zipCode+','+listUploadInvoiceWrapper.get(i).issueDate+','+listUploadInvoiceWrapper.get(i).firmId+','+listUploadInvoiceWrapper.get(i).effectiveDate+',';
                                    successString=   successString +'Invoice Created Successfully\n';
                                    successBillingIds.add(resultInvoiceList[i].getId());
                                }else{
                                    errorString = errorString + listUploadInvoiceWrapper.get(i).policyID+','+listUploadInvoiceWrapper.get(i).invoiceID+','+listUploadInvoiceWrapper.get(i).invoiceType+','+listUploadInvoiceWrapper.get(i).invoiceAmount+','+listUploadInvoiceWrapper.get(i).firmName+','+listUploadInvoiceWrapper.get(i).zipCode+','+listUploadInvoiceWrapper.get(i).issueDate+','+listUploadInvoiceWrapper.get(i).firmId+','+listUploadInvoiceWrapper.get(i).effectiveDate+',';
                                    errorString = errorString + 'Error while creating billing lines for Bill Id :'+ resultInvoiceList[i].getId()+'   ---';
                                    for(Database.Error err : resultInvoiceLineList[i].getErrors()) {
                                        errorString = errorString +'"'+ err.getMessage()+'"';
                                    }
                                    errorString = errorString + '\n';
                                }
                            }else{
                                errorString = errorString + listUploadInvoiceWrapper.get(i).policyID+','+listUploadInvoiceWrapper.get(i).invoiceID+','+listUploadInvoiceWrapper.get(i).invoiceType+','+listUploadInvoiceWrapper.get(i).invoiceAmount+','+listUploadInvoiceWrapper.get(i).firmName+','+listUploadInvoiceWrapper.get(i).zipCode+','+listUploadInvoiceWrapper.get(i).issueDate+','+listUploadInvoiceWrapper.get(i).firmId+','+listUploadInvoiceWrapper.get(i).effectiveDate+',';
                                for(Database.Error err : resultInvoiceList[i].getErrors()) {
                                    errorString = errorString +'"'+ err.getMessage()+'"';
                                }
                                errorString = errorString + '\n';
                            }
                        }
                        DateTime now = System.now();
                        List<Document> documentList = new List<Document>();
                        //received file insert
                        Document newDocument = new Document();
                        newDocument.Body = Blob.valueOf(att.Body);
                        newDocument.Name = 'Payment_Gateway_'+now+'.csv';
                        if(fold!=null){
                            newDocument.FolderId=fold.id;
                        }
                        documentList.add(newDocument);
                        
                        // success file insert
                        newDocument = new Document();
                        newDocument.Body = Blob.valueOf(successString);
                        newDocument.Name = 'Payment_Gateway_Success_'+now+'.csv';
                        if(fold!=null){
                            newDocument.FolderId=fold.id;
                        }
                        documentList.add(newDocument);
                        
                        // error file insert
                        newDocument = new Document();
                        newDocument.Body = Blob.valueOf(errorString);
                        newDocument.Name = 'Payment_Gateway_Error_'+now+'.csv';
                        if(fold!=null){
                            newDocument.FolderId=fold.id;
                        }
                        documentList.add(newDocument);
                        
                        insert documentList;
                        
                        if(!successBillingIds.isEmpty()){
                            List<AcctSeed__Billing__c> billings = new List <AcctSeed__Billing__c> ();
                            
                            for(Id billId : successBillingIds){
                                
                                billings.add(new AcctSeed__Billing__c(id=billId ));
                            
                            }
                            
                            // Call the post billings service
                            AcctSeed.PostResult[] postResults = AcctSeed.BillingPostService.postBillings(billings);
                            
                            // Loop through post results
                            for (AcctSeed.PostResult theResult : postResults) {
                                if (theResult.isSuccess) {
                                    System.debug('Successfully posted billing: ' + theResult.id);
                                } 
                                else {
                                    System.debug('Error posting billing ' + theResult.id);
                                    for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                                        System.debug('Error status code ' + errorResult.statusCode);
                                        System.debug('Error message ' + errorResult.message);
                                    }
                                }
                            }
                        }    
                        
                        break;
                    }
                }catch(Exception e){
                    System.debug('Exception'+ e.getMessage());
                    System.debug('Exception'+ e.getStackTraceString());
                    Document newDocument = new Document();
                    newDocument.Body = Blob.valueOf(att.Body);
                    newDocument.Name = 'Payment_Gateway_'+System.now()+'.csv';
                    newDocument.Description =e.getMessage()+'\n'+e.getStackTraceString();
                    if(fold!=null){
                        newDocument.FolderId=fold.id;
                    }
                    insert newDocument;
                    return false;
                }
            }
        }
        return true;
    }
}