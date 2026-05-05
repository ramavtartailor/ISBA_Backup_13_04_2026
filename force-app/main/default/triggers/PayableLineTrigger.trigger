trigger PayableLineTrigger on AcctSeed__Account_Payable_Line__c (before insert, before update, after update, after Insert) {
    if(Trigger.isBefore && Trigger.isInsert){
        Set<String> invoiceNumbers = new Set<String>();
        Set<String> venderInvoiceKeySet = new Set<String>();
        
        for(AcctSeed__Account_Payable_Line__c line : Trigger.new){
            String key = line.AcctSeed__Vendor_Id__c+'|'+line.ISBAM_Invoice_Number__c;
            if(venderInvoiceKeySet.contains(key)){
                line.addError('Duplicate Invoice Number found for this Payable Line.');
            }
            else{
                if(String.isNotBlank(line.ISBAM_Invoice_Number__c)){
                    venderInvoiceKeySet.add(key);
                    invoiceNumbers.add(line.ISBAM_Invoice_Number__c);
                }
            }
        }
        
        PayableLineTriggerHandler.duplicateCheck(invoiceNumbers, Trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        
        Set<String> invoiceNumbers = new Set<String>();
        
        for(AcctSeed__Account_Payable_Line__c line : Trigger.new){
            
            AcctSeed__Account_Payable_Line__c oldLine =Trigger.oldMap.get(line.Id);
            
            if(String.isNotBlank(line.ISBAM_Invoice_Number__c) &&
               line.ISBAM_Invoice_Number__c != oldLine.ISBAM_Invoice_Number__c){
                   
                   invoiceNumbers.add(line.ISBAM_Invoice_Number__c);
               }
        }
        if(!invoiceNumbers.isEmpty()){
            PayableLineTriggerHandler.duplicateCheck(invoiceNumbers, Trigger.new);
        }
    }
   
    /*//AfterInsert
    if(Trigger.isAfter && Trigger.isInsert){
        Set<String> payableIds = new Set<String>();
        
        for(AcctSeed__Account_Payable_Line__c line : trigger.new){
            if(String.isNotBlank(line.ISBAM_Invoice_Number__c)){
                payableIds.add(line.AcctSeed__Account_Payable__c);
            }
        }
        if(!payableIds.isEmpty()){
            PayableLineTriggerHandler.updateInvoiceNumberOnPayable(payableIds);
        }
    }
    
    //After Update
    if(Trigger.isAfter && Trigger.isUpdate){
        Set<String> payableIds = new Set<String>();
        
        for(AcctSeed__Account_Payable_Line__c line : trigger.new){
            if(line.ISBAM_Invoice_Number__c != trigger.oldMap.get(line.Id).ISBAM_Invoice_Number__c){
                payableIds.add(line.AcctSeed__Account_Payable__c);
            }
        }
        if(!payableIds.isEmpty()){
            PayableLineTriggerHandler.updateInvoiceNumberOnPayable(payableIds);
        }
    }*/
}