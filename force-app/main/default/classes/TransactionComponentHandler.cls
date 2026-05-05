public class TransactionComponentHandler {
    
    @AuraEnabled
    public static List<TransactionWrapper> getTransactions(String recordId, boolean allRecords){
        List<TransactionWrapper> Transactions = new List<TransactionWrapper>();
        String objName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        if(objName == 'Policy_Claim__c'){
            for(AcctSeed__Transaction__c objtransaction : [select id,Claim__r.Name,Name,AcctSeed__Date__c,AcctSeed__Amount__c,AcctSeed__GL_Account__r.Name,AcctSeed__Billing_Line__c,AcctSeed__Cash_Receipt__c,AcctSeed__Billing_Cash_Receipt__c,AcctSeed__Journal_Entry_Line__c,AcctSeed__Scheduled_Revenue_Expense__c,AcctSeed__Account_Payable_Line__c,AcctSeed__Cash_Disbursement__c,AcctSeed__Billing_Line__r.AcctSeed__Billing__r.Name,AcctSeed__Cash_Receipt__r.Name,AcctSeed__Billing_Cash_Receipt__r.Name,AcctSeed__Cash_Disbursement__r.Name,AcctSeed__Journal_Entry_Line__r.AcctSeed__Journal_Entry__r.Name,AcctSeed__Scheduled_Revenue_Expense__r.Name,AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.Name,AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.AcctSeed__Vendor__r.Name from AcctSeed__Transaction__c where Claim__c=:recordId order by AcctSeed__Date__c DESC,Name DESC ]){
                TransactionWrapper wrapper = new TransactionWrapper();
                wrapper.tranName = objtransaction.Name;
                wrapper.tranDate = objtransaction.AcctSeed__Date__c;
                wrapper.tranAmount = objtransaction.AcctSeed__Amount__c;
                wrapper.tranGLaccount = objtransaction.AcctSeed__GL_Account__r.Name;
                if(objtransaction.AcctSeed__Billing_Line__c != null ){
                    wrapper.relatedTo = 'Billing - '+ objtransaction.AcctSeed__Billing_Line__r.AcctSeed__Billing__r.Name;
                }else if(objtransaction.AcctSeed__Cash_Receipt__c != null ){
                    wrapper.relatedTo = 'Cash Receipt - '+ objtransaction.AcctSeed__Cash_Receipt__r.Name;
                }else if(objtransaction.AcctSeed__Billing_Cash_Receipt__c != null ){
                    wrapper.relatedTo = 'Billing Cash Receipt - '+ objtransaction.AcctSeed__Billing_Cash_Receipt__r.Name;
                }else if(objtransaction.AcctSeed__Journal_Entry_Line__c != null ){
                    wrapper.relatedTo = 'Journal Entry - '+ objtransaction.AcctSeed__Journal_Entry_Line__r.AcctSeed__Journal_Entry__r.Name;
                }else if(objtransaction.AcctSeed__Scheduled_Revenue_Expense__c != null ){
                    wrapper.relatedTo = 'Amortized - '+ objtransaction.AcctSeed__Scheduled_Revenue_Expense__r.Name;
                }else if(objtransaction.AcctSeed__Account_Payable_Line__c != null ){
                    wrapper.relatedTo = 'Payable - ' + objtransaction.AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.AcctSeed__Vendor__r.Name + ' - ' + objtransaction.AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__r.Name;
                }else if(objtransaction.AcctSeed__Cash_Disbursement__c != null ){
                    wrapper.relatedTo = 'Disbursement - '+ objtransaction.AcctSeed__Cash_Disbursement__r.Name;
                }
                wrapper.parentName = objtransaction.Claim__r.Name;
                Transactions.add(wrapper);
            }
        }
        return Transactions;
    }
    
    public class TransactionWrapper{
        @AuraEnabled 
        public String tranName{get;set;}
        @AuraEnabled 
        public Date tranDate{get;set;}
        @AuraEnabled 
        public Decimal tranAmount{get;set;}
        @AuraEnabled 
        public String tranGLaccount{get;set;}
        @AuraEnabled 
        public String relatedTo{get;set;}
        @AuraEnabled 
        public String parentName{get;set;}
    }
}