global class SendPolicyDocumentsBatch implements Database.Batchable<SObject> ,Schedulable , Database.AllowsCallouts{
    
    global String query{get;set;}
    global Set<String> recIds{get;set;}
    
    global SendPolicyDocumentsBatch(String query){
        this.query = query;
    }
    global SendPolicyDocumentsBatch(){
        this.query = null;
    }
    
    global SendPolicyDocumentsBatch(Set<String> recIds){
        this.query = null;
        this.recIds = recIds;
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        Date dt = system.today().addDays(-10);
        if(query == null){
            query = 'SELECT Id FROM Policy__c WHERE Is_Canceled__c = false And RecordType.Name = \'Policy\' AND Bound_Date__c < TODAY AND Policy_Email_Date__c = Null AND Billing__r.Computed_Payment_Frequency__c = NULL';
        }
        if(recIds != null && !recIds.isEmpty()){
            query += ' AND Id IN : recIds';             
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Policy__c> objList){
        for(policy__c obj : objList){
            SendEmailExt.EmailWrapper  emWrp= SendEmailExt.getDetails(obj.Id, 'printPolicyDocs');
            SendEmailExt.SendEmail(emWrp, 'printPolicyDocs');
        }        
    }
    
    global void finish(Database.BatchableContext bc){}
    
    global void execute(SchedulableContext SC) {
        SendPolicyDocumentsBatch b = new SendPolicyDocumentsBatch(); 
        Database.executeBatch(b,Integer.valueOf(label.SendPolicyDocsLimit));
    }    
}