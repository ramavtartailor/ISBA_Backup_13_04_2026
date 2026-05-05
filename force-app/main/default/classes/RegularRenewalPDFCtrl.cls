public class RegularRenewalPDFCtrl {
	public Policy__c policy {get;set;}
    public List<Policy_Lawyer__c> policyLawyers{get;set;}
    Id policyApplicationId;
    public RegularRenewalPDFCtrl(){
        policyApplicationId = apexpages.currentpage().getparameters().get('id');
        policy = [select id,name,Account__r.Name,Policy_Document_Version__c,RecordType.Name,Account__r.Account_Number_External_ID__c,
                  Effective_Date__c,County__c,Total_Lawyers__c,Policy_Number__c,Per_Claim_Limit__c,Aggregate_Limit_For_All_Claims__c,Application_Type__c,
                  Deductible_Amount__c,Premium__c,Expiration_Date__c,Account__c,Account__r.BillingStreet,Account__r.BillingCity, 
                  Account__r.BillingState,Account__r.BillingPostalCode,Account__r.Phone,Account__r.Trade_Name_or_D_B_A__c,Firm_Contact__r.Email,Firm_Contact__r.Phone,Firm_Contact__r.Name,
                  Account__r.Fax,Account__r.email__c,Remove_102_Endorsement__c,County__r.Name from Policy__C where id = :policyApplicationId];
        policyLawyers = [SELECT Lawyer__r.Name, Lawyer__r.Lawyer_Name__c, Prior_Act_Date__c, Lawyer__r.Contact__r.ARDC_Number__c, Lawyer__r.Contact__r.ISBA__c,
                         Lawyer__r.Contact__r.Contact_Role__c,Contact_Role__c,Lawyer__r.Contact__r.Email
                         FROM Policy_Lawyer__c WHERE Policy__c =: policyApplicationId order by Lawyer__r.Contact__r.LastName ASC];  
    }
}