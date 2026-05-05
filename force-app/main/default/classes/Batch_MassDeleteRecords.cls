public class Batch_MassDeleteRecords implements Database.Batchable<Sobject>{
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(Label.Batch_Mass_Delete_Query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> batch) {
        delete batch;
    }
    public void finish(Database.BatchableContext BC) { 
    }
}