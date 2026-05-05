public class BankReconciliationGenerateStatementBatch implements Database.Batchable<sObject>,Schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select id,AcctSeed__Bank_Account__r.Name,AcctSeed__End_Date__c from AcctSeed__Bank_Reconciliation2__c where AcctSeed__End_Date__c = TODAY';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<AcctSeed__Bank_Reconciliation2__c> scope){
        
        Datetime myDT = System.today();
		String myDate = myDT.format('MM/dd/YYYY h:mm a');
        List<ContentVersion> conVer = new List<ContentVersion>();
        for(AcctSeed__Bank_Reconciliation2__c bankRec : scope){
            String endDate='';
            if(bankRec.AcctSeed__End_Date__c!=Null){
		endDate = bankRec.AcctSeed__End_Date__c.month() +'/'+bankRec.AcctSeed__End_Date__c.day()+'/'+bankRec.AcctSeed__End_Date__c.year();
            }
            
            pageReference p = Page.AcctSeed__BankReconciliationPDFReportNew;
            p.getParameters().put('id',bankRec.Id);
          //  Blob content = p.getContentAsPDF();
            blob content;
            if(!test.isRunningTest()){
     			content = p.getContentAsPdf();
    		}else{
      			content = Blob.valueOf('Fake PDF content');
    		}
            ContentVersion fileToUpload = new ContentVersion();
            
            fileToUpload.pathOnClient ='Bank Reconciliation '+bankRec.AcctSeed__Bank_Account__r.Name+' - Statement Ending Date '+endDate+' Created - '+myDate+'.pdf';
            fileToUpload.title = 'Bank Reconciliation '+bankRec.AcctSeed__Bank_Account__r.Name+' - Statement Ending Date '+endDate+' Created - '+myDate+'.pdf';
            fileToUpload.versionData = content;
            fileToUpload.FirstPublishLocationId = bankRec.Id;
            conVer.add(fileToUpload);
            
        }
        insert conVer;
        
        
        
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    public void execute(SchedulableContext SC) {
      BankReconciliationGenerateStatementBatch obj = new BankReconciliationGenerateStatementBatch(); 
      Database.executeBatch(obj,50);
   }
    
    
}