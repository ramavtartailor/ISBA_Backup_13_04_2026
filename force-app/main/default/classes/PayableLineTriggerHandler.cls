public  class PayableLineTriggerHandler {
    
    public static void duplicateCheck(Set<String> invoiceNumbers, List<AcctSeed__Account_Payable_Line__c> newPayableLines){
        
        Set<Id> payableIds = new Set<Id>();
        
        for(AcctSeed__Account_Payable_Line__c line : newPayableLines){
            if(line.AcctSeed__Account_Payable__c != null){
                payableIds.add(line.AcctSeed__Account_Payable__c);
            }
        }
        
        List<AcctSeed__Account_Payable_Line__c> existingLines =[SELECT Id, ISBAM_Invoice_Number__c, AcctSeed__Vendor_Id__c 
                                                                FROM AcctSeed__Account_Payable_Line__c WHERE ISBAM_Invoice_Number__c IN :invoiceNumbers];
        
        Set<String> keySet = new Set<String>();
        
        for(AcctSeed__Account_Payable_Line__c line : existingLines){
            keySet.add(line.AcctSeed__Vendor_Id__c  + '|' + line.ISBAM_Invoice_Number__c);
        }
        
        for(AcctSeed__Account_Payable_Line__c line : newPayableLines){
            if(String.isNotBlank(line.ISBAM_Invoice_Number__c)){
                
                String key = line.AcctSeed__Vendor_Id__c  + '|' + line.ISBAM_Invoice_Number__c;
                
                if(keySet.contains(key)){
                    line.addError('Duplicate Invoice Number found for this Payable Line.');
                }
            }
        }
    }
    
    public static void updateInvoiceNumberOnPayable(Set<String> payableIds){
        /*if(!payableIds.isEmpty()){
            List<AcctSeed__Account_Payable__c> payableList = new List<AcctSeed__Account_Payable__c>([SELECT Id, AcctSeed__Payee_Reference__c,(SELECT Id, ISBAM_Invoice_Number__c FROM AcctSeed__Project_Account_Payable_Lines__r) FROM AcctSeed__Account_Payable__c WHERE Id IN :payableIds]);
            
            for(AcctSeed__Account_Payable__c obj: payableList ){
                
                obj.AcctSeed__Payee_Reference__c = obj.AcctSeed__Payee_Reference__c.contains('(') ? obj.AcctSeed__Payee_Reference__c.subStringBefore('(') : obj.AcctSeed__Payee_Reference__c;
                
                obj.AcctSeed__Payee_Reference__c += ' (';
                
                for(AcctSeed__Account_Payable_Line__c line : obj.AcctSeed__Project_Account_Payable_Lines__r){
                    if(String.isNotBlank(line.ISBAM_Invoice_Number__c)){
                        obj.AcctSeed__Payee_Reference__c += '#'+line.ISBAM_Invoice_Number__c+', ';
                    }
                }
                if(obj.AcctSeed__Payee_Reference__c.endsWith('(') ){
                    obj.AcctSeed__Payee_Reference__c.removeEnd('(');
                }else{
                    obj.AcctSeed__Payee_Reference__c = obj.AcctSeed__Payee_Reference__c.endsWith(', ') ? obj.AcctSeed__Payee_Reference__c.removeEnd(', ') : obj.AcctSeed__Payee_Reference__c;
                    obj.AcctSeed__Payee_Reference__c += ')';
                }
            }
            update payableList;
        }*/
    }
}