public class ProcessCededCorrectionCtrl {
	@AuraEnabled
    public static void processCededTransactions(String recordId){
        Treaty_Versions__c treaty = [select id,Treaty_Correction_Processed__c from Treaty_Versions__c where id =: recordId];
        if(treaty.Treaty_Correction_Processed__c){
            throw new AuraHandledException('Ceded Transactions Already Created for this Treaty.') ;
        }else{
            List<Policy__c> policies = [select id from Policy__c where Treaty_Version__c =: recordId and Accounting_Processed__c = true and RecordType.Name = 'Policy'];
            Set<Id> policyIds = new Set<Id>();
            for(Policy__c pol : policies){
                policyIds.add(pol.Id);
            }
            Batch_CededTransactionCorrection batch = new Batch_CededTransactionCorrection(policyIds,'');
            Database.executeBatch(batch,10);
        }
    }
}