public class SendPolicyDoumentsCtrl {
    
    public class SendPolicyDoumentsCtrlException extends Exception{} 
    
    @AuraEnabled
    public static Wrapper getDetails(){
        Wrapper wrap = new Wrapper();
        try{
            List<Policy__c> policyList = [SELECT Id, Billing__r.Computed_Payment_Frequency__c, Billing__r.Latest_Cash_Receipt__c, Billing__r.Computed_Payment_Type__c, Name, Account__c, Account__r.Name, Premium_FinalQuote_And_Endorsements__c, Limits__c, Expiration_Date__c, Effective_Date__c, Status__c FROM Policy__c WHERE Is_Canceled__c = false And RecordType.Name = 'Policy' AND Bound_Date__c < TODAY AND Policy_Email_Date__c = Null AND Billing__r.Computed_Payment_Frequency__c = NULL ORDER BY CreatedDate DESC];
            wrap.policyList = policyList;
            
            return wrap;
        }
        catch(Exception e){
            throw new SendPolicyDoumentsCtrlException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String runBatch(List<String> ids){
        try{
            if(ids != null){
                system.debug(ids);
                Set<String> recIds = new Set<String>();
                recIds.addAll(ids);
                SendPolicyDocumentsBatch b = new SendPolicyDocumentsBatch(recIds); 
                string batchId = Database.executeBatch(b,Integer.valueOf(label.SendPolicyDocsLimit));
                
                return batchId;
            }
            else{
                throw new SendPolicyDoumentsCtrlException('Please Select an Record.');
            }
        }
        catch(Exception e){
            throw new SendPolicyDoumentsCtrlException(e.getMessage());
        }
    }
    
    public class Wrapper{
        @AuraEnabled public List<Policy__c> policyList{get;Set;}
        @AuraEnabled public String userEmail{get;set;}
        @AuraEnabled public Boolean AddBcc{get;Set;}
        
        public Wrapper(){
            this.AddBcc = false;
            this.userEmail = UserInfo.getUserEmail();
        }
    }
}