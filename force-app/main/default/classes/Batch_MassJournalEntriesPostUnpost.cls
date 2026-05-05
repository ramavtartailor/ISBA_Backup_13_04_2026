public class Batch_MassJournalEntriesPostUnpost implements Database.Batchable<Sobject>{
    String action;
    boolean deleteAfterUnPost;
    public Batch_MassJournalEntriesPostUnpost(String action,boolean deleteAfterUnPost){
        this.action = action;
        this.deleteAfterUnPost = deleteAfterUnPost;
    }
	public Database.QueryLocator start(Database.BatchableContext BC) {
        if(action == 'Post'){
            return Database.getQueryLocator([select Id, AcctSeed__Total_Credits__c, AcctSeed__Total_Debits__c, AcctSeed__Out_of_Balance__c from AcctSeed__Journal_Entry__c where AcctSeed__Total_Debits__c > 0 and (AcctSeed__Status__c = 'Approved' or AcctSeed__Status__c = 'In Process')  and AcctSeed__Out_of_Balance__c = 0]);
        }else{
            return Database.getQueryLocator([select Id, AcctSeed__Total_Credits__c, AcctSeed__Total_Debits__c, AcctSeed__Out_of_Balance__c from AcctSeed__Journal_Entry__c where ExternalId__c in ('-101093_GE000103889','101093_GE000103889','-100675_GE000102505','100675_GE000102505','-100576_GE000102009','100576_GE000102009','-100573_GE000102006','100573_GE000102006','-100589_GE000102024','100589_GE000102024','-100236_GE000100598','100236_GE000100598','-100524_GE000101828','100524_GE000101828','-100260_GE000100741','-100238_GE000100703','100238_GE000100703','100260_GE000100741','-100261_GE000100742','100261_GE000100742','-100468_GE000101617','100468_GE000101617','-100909_GE000103327','-100908_GE000103326','100908_GE000103326','100909_GE000103327','-100483_GE000101635','100483_GE000101635','-100482_GE000101634','100482_GE000101634','-100627_GE000102141','100627_GE000102141','-100674_GE000102504','100674_GE000102504','-100488_GE000101648','100488_GE000101648','-100842_GE000103045','100842_GE000103045','-100509_GE000101813','100509_GE000101813','-100604_GE000102039','100604_GE000102039','-100539_GE000101847','100539_GE000101847','-100254_GE000100722','100254_GE000100722','-100432_GE000101441','100432_GE000101441','-100518_GE000101822','100518_GE000101822','-100495_GE000101655','100495_GE000101655','-100682_GE000102514','100682_GE000102514','-100494_GE000101654','100494_GE000101654','-100264_GE000100745','-100241_GE000100706','100241_GE000100706','100264_GE000100745','-100265_GE000100753','100265_GE000100753','-101095_GE000103892','101095_GE000103892','-100831_GE000103033','100831_GE000103033')]);
        }
    }
    public void execute(Database.BatchableContext BC, List<AcctSeed__Journal_Entry__c> batch) {
        AcctSeed.PostResult[] results;
        if(action == 'Post'){
            
            for(AcctSeed__Journal_Entry__c entry : batch){
                entry.AcctSeed__Status__c = 'Approved';
            }
            update batch;
            
            results = AcctSeed.JournalEntryPostService.postJournalEntries(batch);
        }else{
            results = AcctSeed.JournalEntryPostService.unPostJournalEntries(batch);
            if(deleteAfterUnPost){
                delete batch;
            }
        }
        /*for (AcctSeed.PostResult theResult : results) {
            if (theResult.isSuccess) {
                System.debug('Successfully' + action + ' journal entry: ' + theResult.id);
            } 
            else {
                System.debug('Error ' + action + ' JE ' + theResult.id);
                for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                    System.debug('Error status code ' + errorResult.statusCode);
                    System.debug('Error message ' + errorResult.message);
                }
            }
        }*/
    }
    public void finish(Database.BatchableContext BC) { 
    }
}