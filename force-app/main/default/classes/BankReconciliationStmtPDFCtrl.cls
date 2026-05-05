public class BankReconciliationStmtPDFCtrl {
    public String BankReconcId{get;set;}
    
    public BankReconciliationStmtPDFCtrl(){
        BankReconcId = ApexPages.currentPage().getParameters().get('id');
        SYstem.debug(BankReconcId);
    }
    
    public PageReference makePDF(){
        try{
            AcctSeed__Bank_Reconciliation2__c bankRec = [Select id,AcctSeed__Bank_Account__r.Name,AcctSeed__End_Date__c from AcctSeed__Bank_Reconciliation2__c where id = :BankReconcId limit 1];
            
            System.debug(bankRec);
            Datetime myDT = System.now();
            String myDate = myDT.format('MM/dd/YYYY h:mm a');
            
            String endDate='';
            if(bankRec.AcctSeed__End_Date__c!=Null){
                endDate = bankRec.AcctSeed__End_Date__c.month() +'/'+bankRec.AcctSeed__End_Date__c.day()+'/'+bankRec.AcctSeed__End_Date__c.year();
            }
            
            PageReference pg = Page.AcctSeed__BankReconciliationPDFReportNew;
            pg.getParameters().put('id',BankReconcId);
            //  Blob content = p.getContentAsPDF();
            blob content;
            if(!test.isRunningTest()){
                content = pg.getContentAsPdf();
            }else{
                content = Blob.valueOf('Fake PDF content');
            }
            ContentVersion fileToUpload = new ContentVersion();
            
            fileToUpload.pathOnClient ='Bank Reconciliation '+bankRec.AcctSeed__Bank_Account__r.Name+' - Statement Ending Date '+endDate+' Created - '+myDate+'.pdf';
            fileToUpload.title = 'Bank Reconciliation '+bankRec.AcctSeed__Bank_Account__r.Name+' - Statement Ending Date '+endDate+' Created - '+myDate+'.pdf';
            fileToUpload.versionData = content;
            fileToUpload.FirstPublishLocationId = bankRec.Id;
            
            insert fileToUpload;
            
            return new pageReference('/'+bankRec.Id); 
        }
        catch(Exception e){
            system.debug(e.getMessage());
            system.debug(e.getLineNumber());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            return null;
            
        }
        
    }
    
}