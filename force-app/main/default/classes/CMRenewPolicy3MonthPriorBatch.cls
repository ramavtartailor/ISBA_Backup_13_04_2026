global class CMRenewPolicy3MonthPriorBatch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date startTimeFrame = system.today();
        Date timeFrame = system.today().addDays(90);
        //timeFrame = Date.newInstance(2026, 03, 31);
        Id RecordTypeId = Schema.SObjectType.Policy__c.getRecordTypeInfosByName().get('Policy').getRecordTypeId();
        String query = 'select id,ClonedBy__c from Policy__c where RecordTypeId=:RecordTypeId AND Renew_Application__c = false AND Account__r.Count_of_Application__c<1 and Expiration_Date__c <=:timeFrame and ClonedBy__c = null and Expiration_Date__c >:startTimeFrame and Cancel_Date__c = null';
        system.debug('query-->'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Policy__c> records) {
        try{
            for(Policy__c obj : records){
                if(test.isRunningTest()){
                    obj.NBA_App_Source__c = 'test';
                }
                obj.ClonedBy__c = 'Renewal 3 Months Before Policy Expiration';
                obj.Policy_Renew_Status__c = 'Renewal Created Successfully';
            }
            List<Database.SaveResult> results = Database.Update(records,false);
            
            
            List<Policy__c> updatedPolicyRecords = new List<Policy__c>();
            for(Database.SaveResult sr: results){
                if (!sr.isSuccess()) { 
                    Policy__c pol = new Policy__c();
                    pol.Id = sr.getId();
                    pol.ClonedBy__c = '';
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        pol.Policy_Renew_Status__c = err.getMessage();
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                    System.debug(pol);
                    updatedPolicyRecords.add(pol);
                }
            }
            
            if(!updatedPolicyRecords.isEmpty()){
                Database.Update(updatedPolicyRecords,false);
            }
        }catch(exception ex){
			system.debug('ex-->'+ex.getMessage());
        }
    }   
    
    global void finish(Database.BatchableContext BC){           
        
    }
    
    global void execute(SchedulableContext sc){
        Database.executeBatch(new CMRenewPolicy3MonthPriorBatch(),10);
    }
}