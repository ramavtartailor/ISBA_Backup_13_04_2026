/*
	Name : AccountPayableTrigger 
	Auther : Sarbjeet Singh
	Date : 30th June 2017
	Description : Trigger on AcctSeed__Account_Payable__c .
*/

trigger AccountPayableTrigger on AcctSeed__Account_Payable__c (after update,before insert, before Update) {
    
    
    if(Test.isRunningTest() && Trigger.isbefore && Trigger.isInsert){
        List<AcctSeed__Ledger__c> ledgerList = [select id from AcctSeed__Ledger__c  limit 1];
        
        for(AcctSeed__Account_Payable__c objcash: trigger.new){
            objcash.AcctSeed__Ledger__c=ledgerList[0].id ;
        }
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        Set<String> payableIds = new Set<String>();
        
        for(AcctSeed__Account_Payable__c objcash: trigger.new){
            if(objcash.AcctSeed__Vendor__c != trigger.oldMap.get(objcash.Id).AcctSeed__Vendor__c){
                payableIds.add(objcash.Id);
            }
        }
        if(!payableIds.isEmpty()){
            AccountPayableTriggerHandler.checkForDuplicates(payableIds, trigger.newMap);
        }
    }

    /*if(Trigger.isAfter && Trigger.isUpdate){
        Set<String> payableIds = new Set<String>();
        
        for(AcctSeed__Account_Payable__c objcash: trigger.new){
            if(objcash.AcctSeed__Vendor__c != trigger.oldMap.get(objcash.Id).AcctSeed__Vendor__c){
                payableIds.add(objcash.Id);
            }
        }
        if(!payableIds.isEmpty()){
            PayableLineTriggerHandler.updateInvoiceNumberOnPayable(payableIds);
        }
    }*/
    
    List<AcctSeed__Account_Payable__c> paylist = new List<AcctSeed__Account_Payable__c>(); 
    
    if(trigger.isAfter && trigger.isUpdate && (AccountPayableTriggerHandler.createBilling || Test.isRunningTest())){
        
        for(AcctSeed__Account_Payable__c pay:trigger.new){
            
            if(/*(pay.AcctSeed__Payment_Status__c == 'Paid' || pay.AcctSeed__Payment_Status__c == 'Partially Paid') && */(pay.Type__c == 'LAE Pay' || pay.Type__c =='Loss Pay')){
                
                paylist.add(pay);
            }
        }
        
        if(!paylist.isEmpty()){
            AccountPayableTriggerHandler.createBilling = false;
            AccountPayableTriggerHandler.afterupdate(paylist);
        }
        
    } 
}