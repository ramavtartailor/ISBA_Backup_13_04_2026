trigger CashDisburesementBatchTrigger_CM on AcctSeed__Cash_Disbursement_Batch__c (After Update) {

    if(trigger.isAfter && trigger.isUpdate){
        List<String> recIds = new List<String>();
        for(AcctSeed__Cash_Disbursement_Batch__c b :trigger.New){
            system.debug(' b.AcctSeed__Posted_Cash_Disbursements__c => '+ b.AcctSeed__Posted_Cash_Disbursements__c);
            system.debug('trigger.oldMap.get(b.Id).AcctSeed__Posted_Cash_Disbursements__c => '+ trigger.oldMap.get(b.Id).AcctSeed__Posted_Cash_Disbursements__c);

            if(trigger.oldMap.containsKey(b.Id) && b.AcctSeed__Posted_Cash_Disbursements__c != null && (trigger.oldMap.get(b.Id).AcctSeed__Posted_Cash_Disbursements__c == null ||  b.AcctSeed__Posted_Cash_Disbursements__c > trigger.oldMap.get(b.Id).AcctSeed__Posted_Cash_Disbursements__c)){
                recIds.add(b.Id);
            }
        }
        
        if(!recIds.isEmpty()){
            GeneratePositivePayController.generateCsv(recIds);
        }
    }
}