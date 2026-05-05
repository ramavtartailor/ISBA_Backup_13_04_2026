public with sharing class EZRenewalExtension {

    public Policy__c policy {get; set;}
    public Date expirationDate{get;set;}
    public EZRenewalExtension(ApexPages.StandardController controller) {
         policy = (Policy__c)controller.getRecord();
          policy = [SELECT Name,Effective_Date__c,Policy_Number__c,Per_Claim_Limit__c,Aggregate_Limit_For_All_Claims__c,
                      Deductible_Amount__c,Premium__c,Expiration_Date__c,Account__c,Account__r.Name,Account__r.BillingStreet,Account__r.BillingCity, 
                       Account__r.BillingState,Account__r.BillingPostalCode,Account__r.Phone,
                       Account__r.Fax,Account__r.email__c FROM Policy__c WHERE Id =: policy.Id];
        expirationDate = policy.Effective_Date__c.addYears(1);
    }

}