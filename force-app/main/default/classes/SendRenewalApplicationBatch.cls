global class SendRenewalApplicationBatch implements Database.Batchable<SObject> ,Schedulable , Database.AllowsCallouts{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        //date dt = system.today().addDays(40);
        String query = 'SELECT Id, Renewal_Type__c,Account__r.AcctSeed__Billing_Contact__c,Account__r.AcctSeed__Billing_Contact__r.Email FROM Policy__c WHERE ISBAM_Automatic_Renewal_Send__c = true';// AND RecordType.Name =\'Application\' AND Status__c=\'Approved\' AND Effective_Date__c<=:dt';
        //if(!Test.isRunningTest())
          //  query += ' AND Effective_Date__c >= 2025-01-01';
        
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Policy__c> objList){        
        for(Policy__c obj : objList){
            SendEmailExt.EmailWrapper  emWrp= SendEmailExt.getDetails(obj.Id, 'renewalBatch');
            //emWrp.sendToContactEmailSelected = 'kyle.hoker@isbamutual.com';
            //emWrp.sendToContactSelected = null;
            if(obj.Account__r.AcctSeed__Billing_Contact__c != null){
                emWrp.CCAddress = obj.Account__r.AcctSeed__Billing_Contact__r.Email;
            }
            SendEmailExt.SendEmail(emWrp, 'renewalBatch');            
        }
    }
    
    global void finish(Database.BatchableContext bc){}
    
    global void execute(SchedulableContext SC) {
        SendRenewalApplicationBatch b = new SendRenewalApplicationBatch(); 
        Database.executeBatch(b,1);
    }    
}