global class Batch_FiservAccountUpdater implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.stateful{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id FROM Account Limit 1');
    }
    
    global void execute(Database.BatchableContext bc, List<Account> data){
        
        Map<String,Object> responseCard = Fiserv_Utils.getUpdatedMethod(true);
        //Map<String,Object> responseAch = Fiserv_Utils.getUpdatedMethod(false);
        List<Object> updatedData = new List<Object>();
        
        if(responseCard != null){
            if(responseCard.containsKey('currentPageSize') && Integer.valueOf(responseCard.get('currentPageSize')) > 0){
                List<Object> temp_updatedData = (List<Object>)responseCard.get('updates');
                if(temp_updatedData != null && !responseCard.isEmpty()){
                    updatedData.addAll(temp_updatedData);
                }
            }
        }
        /*if(responseAch != null){
            if(responseAch.containsKey('currentPageSize') && Integer.valueOf(responseAch.get('currentPageSize')) > 0){
                List<Object> temp_updatedData = (List<Object>)responseAch.get('updates');
                if(temp_updatedData != null && !responseAch.isEmpty()){
                    updatedData.addAll(temp_updatedData);
                }
            }
        }*/
        
        Map<String,Map<String,Object>> dataMap = new Map<String,Map<String,Object>>();
        
        
        for(Object obj: updatedData){
            Map<String,Object> objMap = (Map<String,Object>)obj;
            if(objMap.containsKey('oldtoken')){
                String oldToken = String.valueOf(objMap.get('oldtoken'));
                System.Debug('oldToken => '+oldToken);
                System.Debug('objMap => '+objMap);
                dataMap.put(oldToken, objMap);
            }
        }
        
        List<Payment_Method__c> paymentMethod = [SELECT Id,Token__c,Expiry_Month__c,Expiry_Year__c,Payment_Method_Token__c FROM Payment_Method__c WHERE Token__c IN : dataMap.keySet()];
        List<Payment_Method__c> updatedPaymentMethod = new List<Payment_Method__c>();	
        
        for(Payment_Method__c pm: paymentMethod){
            if(dataMap.containsKey(pm.Token__c)){
                Map<String, Object> tokenData = dataMap.get(pm.Token__c);
                pm.Token__c = String.valueOf(tokenData.get('newtoken'));
                if(tokenData.containsKey('newexpiry')){
                    String tempExp = String.valueOf(tokenData.get('newexpiry'));
                    pm.Expiry_Year__c = Double.valueOf(tempExp.substring(0, 4));
                    pm.Expiry_Month__c = Double.valueOf(tempExp.substring(4, 6));
                }
                updatedPaymentMethod.add(pm);
            }
        }
        
        if(!updatedPaymentMethod.isEmpty()){
            Update updatedPaymentMethod;
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
    global void execute(SchedulableContext sc){
        Batch_FiservAccountUpdater b = new Batch_FiservAccountUpdater();
        Database.ExecuteBatch(b);
    }
}