public without sharing class RequestPayableCtrl {
    
    public class RequestPayableException extends Exception {}
    
	@AuraEnabled
    public static requestWrapper getInstance(){
        return new requestWrapper();
    }
    
    @AuraEnabled
    public static void createPayable(list<String> contentDocId, requestWrapper reqWrp){
        try{
            Account VendorAcc = [Select Id from Account Where Name =: label.RequestPayableVendor limit 1];
            
            AcctSeed__Account_Payable__c  payable = new AcctSeed__Account_Payable__c();
            payable.AcctSeed__Status__c = 'Waiting for Approval';
            payable.AcctSeed__Vendor__c = VendorAcc.Id;
            payable.AcctSeed__Payee_Reference__c = reqWrp.PaymentRef + ' ' +system.now();
            payable.AcctSeed__Due_Date__c = reqWrp.DueDate;
            payable.Pre_Payable_Amount__c = reqWrp.Amount;
            insert payable;
            
            list<ContentDocumentLink> listContentDocLink = new list<ContentDocumentLink>();
            for(String docIds : contentDocId){
                ContentDocumentLink CDLink = new ContentDocumentLink();
                CDLink.ContentDocumentId = docIds;
                CDLink.LinkedEntityId = payable.Id;
                CDLink.ShareType = 'V';
                listContentDocLink.add(CDLink);
            }
            
            if(!listContentDocLink.isEmpty()){
                Insert listContentDocLink;
            }
            
        }catch(exception e){
            throw new RequestPayableException(e.getLineNumber()+' '+e.getMessage());
        }
    }
    
    @AuraEnabled
    public static payableWrap getPayables(){
        try{        
            payableWrap wrap = new payableWrap();
            String  currentUserId = UserInfo.getUserId();
            AggregateResult ar = [SELECT Count(Id)c FROM AcctSeed__Account_Payable__c WHERE OwnerId =: currentUserId];
            List<AcctSeed__Account_Payable__c> Payables = [SELECT Id,Name,Pre_Payable_Amount__c,AcctSeed__Status__c,AcctSeed__Balance__c,AcctSeed__Total__c,AcctSeed__Due_Date__c,AcctSeed__Date__c FROM AcctSeed__Account_Payable__c WHERE OwnerId =: currentUserId ORDER BY CreatedDate DESC LIMIT 50000];
            wrap.Payables = Payables;
            wrap.totalRecords = Integer.valueOf(ar.get('c'));
            return wrap;
        }catch(exception e){
            throw new RequestPayableException(e.getLineNumber()+' '+e.getMessage());
        }
    }

     @AuraEnabled
    public static Boolean deletePayable(String recId){
        try{       
            Delete new AcctSeed__Account_Payable__c(Id=recId);
            return true;
        }catch(exception e){
            throw new RequestPayableException(e.getLineNumber()+' '+e.getMessage());
        }
    }
    public class payableWrap{
        @AuraEnabled public List<AcctSeed__Account_Payable__c> Payables  {get; set;}
        @AuraEnabled public Integer totalRecords {get; set;}
    }
    public class requestWrapper{
        @AuraEnabled public String PaymentRef {get; set;}
        @AuraEnabled public Date DueDate {get; set;}
        @AuraEnabled public Decimal Amount {get; set;}
        
        public requestWrapper(){
            DueDate = date.today();
        }
    }   
}