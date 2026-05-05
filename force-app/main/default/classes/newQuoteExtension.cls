public with sharing class newQuoteExtension{

    public Policy__c policy {get; set;}
    public Policy_Quote__c quote{get;set;}
    
    public newQuoteExtension(ApexPages.StandardController controller) {
          
          quote = new Policy_Quote__c();
          
          policy = (Policy__c)controller.getRecord();
          policy = [SELECT Name,Effective_Date__c,Policy_Number__c,Per_Claim_Limit__c,Aggregate_Limit_For_All_Claims__c,
                      Deductible_Amount__c,Premium__c,Expiration_Date__c,Account__c,Account__r.Name,Account__r.BillingStreet,Account__r.BillingCity, 
                       Account__r.BillingState,Account__r.BillingPostalCode,Account__r.Phone,
                   Account__r.Fax,Account__r.email__c FROM Policy__c WHERE Id =: policy.Id LIMIT 1];
                   
          List<Policy_Quote__c> quoteList = new List<Policy_Quote__c>();
          quoteList = [SELECT Id,Policy__c,Final_Quote__c FROM Policy_Quote__c WHERE Policy__c =: policy.Id AND Final_Quote__c = True];
       
          if(!quoteList.isEmpty()){
            quote = quoteList[0];
          }
          
    }

}