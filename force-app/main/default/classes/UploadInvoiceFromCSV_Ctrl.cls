public class UploadInvoiceFromCSV_Ctrl {
    
    public class UploadInvoiceWrapper{
        public String policyID { get; set; }
        public String invoiceID { get; set; }
        public String invoiceType { get; set; }
        public String invoiceAmount { get; set; }
        public String zipCode { get; set; }
        public String issueDate { get; set; }
        public String firmName{get;set;}
        public String firmId{get;set;}
        public UploadInvoiceWrapper(String policyID,String invoiceID,String invoiceType,String invoiceAmount,String firmName,String zipCode,String issueDate,String firmId){
            this.policyID=policyID;
            this.invoiceID=invoiceID;
            this.invoiceType=invoiceType;
            this.invoiceAmount=invoiceAmount;
            this.firmName=firmName;
            this.zipCode=zipCode;
            this.issueDate=issueDate;
            this.firmId=firmId;
        }
    }
    
    public Integer rec { get; set; }
    
    public Integer tot { get; set; }
    String successString;
    String errorString;
    integer totalRecs = 0;
    public integer count{get;set;}
    integer LimitSize= 10;
    public integer numberOfRecordsToShow{get;set;}
    public String commaString{get;set;}
    
    public List<UploadInvoiceWrapper> listUploadInvoiceWrapper=new List<UploadInvoiceWrapper>();
    public List<String> inputJson=new List<String>();
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public String[] csvFileLines{get;set;}
    public boolean previewData{get;set;}
    public UploadInvoiceFromCSV_Ctrl(){
        csvFileLines = new String[]{};
            previewData = false;
        count= 0;
        numberOfRecordsToShow = 10;
        rec=10;
        commaString = '&#44;';
    }
    public static void uploadInvoice(List<UploadInvoiceWrapper> listUploadInvoiceWrapper){
        SavePoint sp = Database.setSavepoint();
        try {
            String successString='Id,policyID,invoiceID,invoiceType,invoiceAmount,firmName,zipCode,issueDate,firmId,Message\n';
            String errorString='policyID,invoiceID,invoiceType,invoiceAmount,firmName,zipCode,issueDate,firmId,Error Message\n';
            //List<UploadInvoiceWrapper> listUploadInvoiceWrapper = new List<UploadInvoiceWrapper>();
            List<AcctSeed__Billing__c> invoiceList = new List<AcctSeed__Billing__c>();
            List<AcctSeed__Billing_Line__c> invoiceLineList = new List<AcctSeed__Billing_Line__c>();
            Account acc = [select id,name from Account where name ='Dummy Billing Account'];
            Transaction_Credit_And_Debits__c tran = Transaction_Credit_And_Debits__c.getInstance('Billing Line');
            AcctSeed__GL_Account__c glAccount = [select id,name from AcctSeed__GL_Account__c where name=:tran.Credit_GL__c];
            /*for(String str : inputJSON){
                listUploadInvoiceWrapper.add((UploadInvoiceWrapper) JSON.deserialize(str, UploadInvoiceWrapper.class));
            }*/
            for(UploadInvoiceWrapper wrapper : listUploadInvoiceWrapper){
                AcctSeed__Billing__c billing = new AcctSeed__Billing__c(Legacy_Invoice_Id__c=wrapper.invoiceID);
                AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
                bill.AcctSeed__Customer__c = acc.id;
                bill.Billing_Zip_Code__c = wrapper.zipCode;
                bill.Legacy_Policy_Id__c = wrapper.policyID;
                bill.Legacy_Invoice_Id__c= wrapper.invoiceID;
                bill.Firm_Name__c= wrapper.firmName.replaceAll('&#44;', ',');
                bill.AcctSeed__Date__c= Date.valueOf(wrapper.issueDate);
                bill.Legacy_Firm_Id__c=wrapper.firmId;
                invoiceList.add(bill);
                
                AcctSeed__Billing_Line__c billLine = new AcctSeed__Billing_Line__c();
                billLine.AcctSeed__Billing__r=billing;
                billLine.AcctSeed__Revenue_GL_Account__c =glAccount.id;
                billLine.AcctSeed__Rate__c=Decimal.valueOf(wrapper.invoiceAmount);
                invoiceLineList.add(billLine);
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
                        successString  = successString + resultInvoiceList[i].getId() + ',' + listUploadInvoiceWrapper.get(i).policyID+','+listUploadInvoiceWrapper.get(i).invoiceID+','+listUploadInvoiceWrapper.get(i).invoiceType+','+listUploadInvoiceWrapper.get(i).invoiceAmount+','+listUploadInvoiceWrapper.get(i).firmName+','+listUploadInvoiceWrapper.get(i).zipCode+','+listUploadInvoiceWrapper.get(i).issueDate+','+listUploadInvoiceWrapper.get(i).firmId+',';
                        successString=   successString +'Invoice Created Successfully\n';
                    }else{
                        errorString = errorString + listUploadInvoiceWrapper.get(i).policyID+','+listUploadInvoiceWrapper.get(i).invoiceID+','+listUploadInvoiceWrapper.get(i).invoiceType+','+listUploadInvoiceWrapper.get(i).invoiceAmount+','+listUploadInvoiceWrapper.get(i).firmName+','+listUploadInvoiceWrapper.get(i).zipCode+','+listUploadInvoiceWrapper.get(i).issueDate+','+listUploadInvoiceWrapper.get(i).firmId+',';
                        errorString = errorString + 'Error while creating billing lines for Bill Id :'+ resultInvoiceList[i].getId()+'   ---';
                        for(Database.Error err : resultInvoiceLineList[i].getErrors()) {
                            errorString = errorString +'"'+ err.getMessage()+'"';
                        }
                        errorString = errorString + '\n';
                    }
                }else{
                    errorString = errorString + listUploadInvoiceWrapper.get(i).policyID+','+listUploadInvoiceWrapper.get(i).invoiceID+','+listUploadInvoiceWrapper.get(i).invoiceType+','+listUploadInvoiceWrapper.get(i).invoiceAmount+','+listUploadInvoiceWrapper.get(i).firmName+','+listUploadInvoiceWrapper.get(i).zipCode+','+listUploadInvoiceWrapper.get(i).issueDate+','+listUploadInvoiceWrapper.get(i).firmId+',';
                    for(Database.Error err : resultInvoiceList[i].getErrors()) {
                        errorString = errorString +'"'+ err.getMessage()+'"';
                    }
                    errorString = errorString + '\n';
                }
            }
            Messaging.EmailFileAttachment csvAttachmentSuccess = new Messaging.EmailFileAttachment();
            Messaging.EmailFileAttachment csvAttachmentError = new Messaging.EmailFileAttachment();
            Blob csvBlob = blob.valueOf(successString);
            String csvName = 'Success_Invoices'+DateTime.now()+'.csv';
            csvAttachmentSuccess.setFileName(csvName);
            csvAttachmentSuccess.setBody(csvBlob);
            csvBlob = blob.valueOf(errorString);
            csvName = 'Error_Invoices'+DateTime.now()+'.csv';
            csvAttachmentError.setFileName(csvName);
            csvAttachmentError.setBody(csvBlob);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{UserInfo.getUserEmail()};
                String subject = 'Invoices Upload Result';
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setPlainTextBody('Please find attached success and error files for the recent invoice upload.');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachmentSuccess,csvAttachmentError});
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }catch(Exception e){
            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());
            Database.rollback(sp);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{UserInfo.getUserEmail()};
                String subject = 'Invoices Upload Result';
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setPlainTextBody('Unable to mass upload invoices.Please find the error occurred:<br/>'+e.getMessage());
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        }
    }
    public void createInvoices(){
        try{
            uploadInvoice(listUploadInvoiceWrapper);
            ApexPages.Message successMessage = new ApexPages.Message(ApexPages.severity.INFO,'Request for creation of Invoices has been submitted successfully. You will be notified with the status on your email.');
            ApexPages.addMessage(successMessage);
            previewData = false;
        }catch(Exception e){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while creation of Invoices.\n'+e.getMessage());
            System.debug('====='+e.getMessage());
            ApexPages.addMessage(errorMessage);
        }
    }
    public void previewData(){
        listUploadInvoiceWrapper = new List<UploadInvoiceWrapper>();
        inputJson = new List<String>();
        try{
            csvAsString = csvFileBody.toString();
            csvAsString = csvAsString.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
            csvAsString = csvAsString.replaceAll('""','DBLQT');
            csvFileLines = csvAsString.split('\n');
            for(Integer i=1;i<csvFileLines.size();i++){
                if(csvFileLines[i].replaceAll(',','').trim().length() >0){
                    string[] csvRecordData = csvFileLines[i].split(',');
                    listUploadInvoiceWrapper.add(new UploadInvoiceWrapper(csvRecordData[0].replaceAll('\\s*\\z', ''),csvRecordData[1].replaceAll('\\s*\\z', ''),csvRecordData[2].replaceAll('\\s*\\z', ''),csvRecordData[3].replaceAll('\\s*\\z', ''),csvRecordData[4].replaceAll('\\s*\\z', ''),csvRecordData[5].replaceAll('\\s*\\z', ''),csvRecordData[6].replaceAll('\\s*\\z', ''),csvRecordData[7].replaceAll('\\s*\\z', '')));
                    //inputJson.add(JSON.serialize(new UploadInvoiceWrapper(csvRecordData[0].replaceAll('\\s*\\z', ''),csvRecordData[1].replaceAll('\\s*\\z', ''),csvRecordData[2].replaceAll('\\s*\\z', ''),csvRecordData[3].replaceAll('\\s*\\z', ''),csvRecordData[4].replaceAll('\\s*\\z', ''),csvRecordData[5].replaceAll('\\s*\\z', ''),csvRecordData[6].replaceAll('\\s*\\z', ''))));
                }
            }
            tot=totalRecs = listUploadInvoiceWrapper.size();
            previewData=true;
            csvFileBody=null;
            if(listUploadInvoiceWrapper.size()<numberOfRecordsToShow){
                numberOfRecordsToShow = listUploadInvoiceWrapper.size();
            }
        }catch (Exception e){
            previewData=false;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while processing the data. Please make sure input csv file is correct.\n'+e.getMessage());
            System.debug('====='+e.getMessage());
            ApexPages.addMessage(errorMessage);
        } 
    }
    
    public List<UploadInvoiceWrapper> getlistUploadInvoiceWrapper() {
        List<UploadInvoiceWrapper> ld = new List<UploadInvoiceWrapper>();
        for(Integer i =count;i<numberOfRecordsToShow+count;i++){
            ld.add(listUploadInvoiceWrapper.get(i));
        }
        return ld;
    }
    
    public void updatePage() {
        count=0;
        if(rec>listUploadInvoiceWrapper.size()){
            numberOfRecordsToShow = limitsize=listUploadInvoiceWrapper.size();
        }else{
            numberOfRecordsToShow = limitsize=rec;
        }
        //leads=[select Name,Email,Company from Lead LIMIT:rec OFFSET:count];
    }
    public PageReference prvbtn() {
        count=count-limitsize;
        if(rec>listUploadInvoiceWrapper.size()){
            numberOfRecordsToShow =listUploadInvoiceWrapper.size();
        }else{
            numberOfRecordsToShow =rec;
        }
        return null;
    }
    
    public PageReference Nxtbtn() {
        count=count+limitsize;
        if(count+limitsize>listUploadInvoiceWrapper.size()){
            numberOfRecordsToShow =listUploadInvoiceWrapper.size()-count;
        }else{
            numberOfRecordsToShow =limitsize;
        }
        return null;
    }
    public Boolean getNxt() {
        if((count+ LimitSize) > totalRecs-1)
            return true;
        else
            return false;
    }
    public Boolean getPrv() {
        if(count== 0)
            return true;
        else
            return false;
    }
}