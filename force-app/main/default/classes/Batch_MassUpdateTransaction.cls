public class Batch_MassUpdateTransaction implements Database.Batchable<Sobject>{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([select id,Claim__c,AcctSeed__Journal_Entry_Line__r.Claim__c from AcctSeed__Transaction__c where Claim__c = null and AcctSeed__Journal_Entry_Line__c != null]);
    }
    public void execute(Database.BatchableContext BC, List<AcctSeed__Transaction__c> batch) {
        for(AcctSeed__Transaction__c tran : batch){
            tran.Claim__c = tran.AcctSeed__Journal_Entry_Line__r.Claim__c;
        }
        update batch;
    }
    public void finish(Database.BatchableContext BC) {
        
    }
}