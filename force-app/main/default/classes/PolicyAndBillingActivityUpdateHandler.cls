public class PolicyAndBillingActivityUpdateHandler {
    
    public static void onAfterInsertTask(List<Task> newList){
        try{
        Set<Id> PolicyIds = new Set<id>();
        Set<Id> BillingIds = new Set<id>();
        List<Task> BillingTasks = new List<Task>();
        List<Task> PolicyTasks = new List<Task>();
        for(Task Obj : newList){
            Id RecordId = Obj.WhatId;
            String sObjName = RecordId.getSObjectType().getDescribe().getName();
            
            if(sObjName == 'AcctSeed__Billing__c'){
                BillingIds.add(RecordId);
                BillingTasks.add(Obj);
            }
            else if(sObjName == 'Policy__c'){
                PolicyIds.add(RecordId);
                PolicyTasks.add(Obj);
            }
        }
        
        if(!BillingIds.isEmpty()){
            
            Map<ID,AcctSeed__Billing__c> BillingList = new Map<ID,AcctSeed__Billing__c>([Select id from AcctSeed__Billing__c where id in:BillingIds]);
            List<AcctSeed__Billing__c> UpdateBillingList = new List<AcctSeed__Billing__c>();
            for(Task Obj : BillingTasks){
                
                AcctSeed__Billing__c CurrBillingRecord = BillingList.get(Obj.WhatId);
                CurrBillingRecord.Latest_Activity_Date__c = Obj.ActivityDate;
                CurrBillingRecord.Latest_Activity_Subject__c= Obj.Subject;
                CurrBillingRecord.Latest_Activity_Type__c='Task';
                CurrBillingRecord.Latest_Activity_Id__c = Obj.Id;
                
                UpdateBillingList.add(CurrBillingRecord);
            }
            
            update UpdateBillingList;
        }
        
        
        if(!PolicyIds.isEmpty()){
            
            Map<ID,Policy__c> PolicyList = new Map<ID,Policy__c>([Select id from Policy__c where id in:PolicyIds]);
            List<Policy__c> UpdatePolicyList = new List<Policy__c>();
            for(Task Obj : PolicyTasks){
                
                Policy__c CurrPolicyRecord = PolicyList.get(Obj.WhatId);
                CurrPolicyRecord.Latest_Activity_Date__c = Obj.ActivityDate;
                CurrPolicyRecord.Latest_Activity_Subject__c= Obj.Subject;
                CurrPolicyRecord.Latest_Activity_Type__c= 'Task';
                CurrPolicyRecord.Latest_Activity_Id__c = Obj.Id;
                
                UpdatePolicyList.add(CurrPolicyRecord);
            }
            
            update UpdatePolicyList;
            
        }
        }
        catch(Exception e){
            System.debug(e.getMessage()+ e.getLineNumber());
        }
    }
    
    
    public static void onAfterInsertEvent(List<Event> newList){
        try{
        Set<Id> PolicyIds = new Set<id>();
        Set<Id> BillingIds = new Set<id>();
        List<Event> BillingEvents = new List<Event>();
        List<Event> PolicyEvents = new List<Event>();
        for(Event Obj : newList){
            Id RecordId = Obj.WhatId;
            String sObjName = RecordId.getSObjectType().getDescribe().getName();
            
            if(sObjName == 'AcctSeed__Billing__c'){
                BillingIds.add(RecordId);
                BillingEvents.add(Obj);
            }
            else if(sObjName == 'Policy__c'){
                PolicyIds.add(RecordId);
                PolicyEvents.add(Obj);
            }
        }
        
        if(!BillingIds.isEmpty()){
            
            Map<ID,AcctSeed__Billing__c> BillingList = new Map<ID,AcctSeed__Billing__c>([Select id from AcctSeed__Billing__c where id in:BillingIds]);
            List<AcctSeed__Billing__c> UpdateBillingList = new List<AcctSeed__Billing__c>();
            for(Event Obj : BillingEvents){
                
                AcctSeed__Billing__c CurrBillingRecord = BillingList.get(Obj.WhatId);
                CurrBillingRecord.Latest_Activity_Date__c = Obj.ActivityDate;
                CurrBillingRecord.Latest_Activity_Subject__c= Obj.Subject;
                CurrBillingRecord.Latest_Activity_Type__c='Event';
                currBillingRecord.Latest_Activity_Id__c = Obj.Id;
                
                UpdateBillingList.add(CurrBillingRecord);
            }
            
            update UpdateBillingList;
        }
        
        
        if(!PolicyIds.isEmpty()){
            
            Map<ID,Policy__c> PolicyList = new Map<ID,Policy__c>([Select id from Policy__c where id in:PolicyIds]);
            List<Policy__c> UpdatePolicyList = new List<Policy__c>();
            for(Event Obj : PolicyEvents){
                
                Policy__c CurrPolicyRecord = PolicyList.get(Obj.WhatId);
                CurrPolicyRecord.Latest_Activity_Date__c = Obj.ActivityDate;
                CurrPolicyRecord.Latest_Activity_Subject__c= Obj.Subject;
                CurrPolicyRecord.Latest_Activity_Type__c= 'Event';
                CurrPolicyRecord.Latest_Activity_Id__c = Obj.Id;
                
                UpdatePolicyList.add(CurrPolicyRecord);
            }
            
            update UpdatePolicyList;
            
        }
        
        }
        catch(Exception e){
            System.debug(e.getMessage() + e.getLineNumber());
        }
        
    }
    
    
    
    public static void onAfterInsertEmailMessage(List<EmailMessage> newList){
        try{
        Set<Id> PolicyIds = new Set<id>();
        Set<Id> BillingIds = new Set<id>();
        List<EmailMessage> BillingEmailMessage = new List<EmailMessage>();
        List<EmailMessage> PolicyEmailMessage = new List<EmailMessage>();
        for(EmailMessage Obj : newList){
            Id RecordId = Obj.RelatedToId;
            if(RecordId != null){
                String sObjName = RecordId.getSObjectType().getDescribe().getName();
                
                if(sObjName == 'AcctSeed__Billing__c'){
                    BillingIds.add(RecordId);
                    BillingEmailMessage.add(Obj);
                }
                else if(sObjName == 'Policy__c'){
                    PolicyIds.add(RecordId);
                    PolicyEmailMessage.add(Obj);
                }
            }
        }
        
        if(!BillingIds.isEmpty()){
            
            Map<ID,AcctSeed__Billing__c> BillingList = new Map<ID,AcctSeed__Billing__c>([Select id from AcctSeed__Billing__c where id in:BillingIds]);
            List<AcctSeed__Billing__c> UpdateBillingList = new List<AcctSeed__Billing__c>();
            for(EmailMessage Obj : BillingEmailMessage){
                
                AcctSeed__Billing__c CurrBillingRecord = BillingList.get(Obj.RelatedToId);
                CurrBillingRecord.Latest_Activity_Date__c = Obj.MessageDate.Date();
                CurrBillingRecord.Latest_Activity_Subject__c= Obj.Subject;
                CurrBillingRecord.Latest_Activity_Type__c ='Email Message';
                CurrBillingRecord.Latest_Activity_Id__c = Obj.Id;
                
                UpdateBillingList.add(CurrBillingRecord);
            }
            System.debug(UpdateBillingList);
            update UpdateBillingList;
            
        }
        
        
        if(!PolicyIds.isEmpty()){
            
            Map<ID,Policy__c> PolicyList = new Map<ID,Policy__c>([Select id from Policy__c where id in:PolicyIds]);
            List<Policy__c> UpdatePolicyList = new List<Policy__c>();
            for(EmailMessage Obj : PolicyEmailMessage){
                
                Policy__c CurrPolicyRecord = PolicyList.get(Obj.RelatedToId);
                CurrPolicyRecord.Latest_Activity_Date__c = Obj.MessageDate.date();
                CurrPolicyRecord.Latest_Activity_Subject__c= Obj.Subject;
                CurrPolicyRecord.Latest_Activity_Type__c = 'Email Message';
                CurrPolicyRecord.Latest_Activity_Id__c = obj.Id;
                
                UpdatePolicyList.add(CurrPolicyRecord);
            }
            
            update UpdatePolicyList;
            
        }
       }  
        catch(Exception e){
            System.debug(e.getMessage());
        }
        
    }
    
}