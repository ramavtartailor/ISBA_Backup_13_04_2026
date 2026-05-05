public class Contact_PolicyHistoryCtrl {
    
    @AuraEnabled
    public Static Wrapper getData(String recId){
        Wrapper wrp = new Wrapper();
        List<AccountContactJunction__c> lawyerList = [SELECT Id,Name FROM AccountContactJunction__c WHERE Contact__c =: recId];
        if(!lawyerList.isEmpty()){
            wrp.lawyerName = lawyerList[0].Name;
            wrp.lawyers = [SELECT Id,Policy__c,Step__c, Premium__c, Policy__r.Name,Policy__r.Policy_Number__c,Policy__r.Effective_Date__c,Policy__r.Premium_Amount__c,Policy__r.Expiration_Date__c,Policy__r.Status__c,Policy__r.Limits__c,Policy__r.Deductible__c, Policy__r.Total_Credit__c FROM Policy_Lawyer__c WHERE Lawyer__c =: lawyerList[0].Id ORDER BY Policy__r.Effective_Date__c DESC];
            return wrp;
        }            
        return wrp;
    }
    
    public Class Wrapper{
        @AuraEnabled public string lawyerName{get;set;}
        @AuraEnabled public List<Policy_Lawyer__c> lawyers{get;set;}
        public Wrapper(){
            lawyerName = '';
            lawyers = new List<Policy_Lawyer__c>();
        }
        
    }

}