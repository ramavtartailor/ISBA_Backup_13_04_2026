public class RegularRenewalPDFExtn
{
    public Policy__c policy {get; set;}
    public AccountContactRelation primaryConRole {get; set;}
    
    public RegularRenewalPDFExtn(ApexPages.StandardController controller) {
        
        policy = (Policy__c)controller.getRecord();
        
        Boolean isRegularRenwalPol = false;
        
        for(Policy__c pol: [SELECT Account__c, Account__r.Account_Number_External_ID__c, Renewal_Type__c FROM Policy__c WHERE Id =: policy.Id])
        {
            policy = pol;
            if(pol.Renewal_Type__c == 'Regular Renewal')
            {
            policy = pol;
            isRegularRenwalPol = true;
            }
        }
        
        if(isRegularRenwalPol)
        {          
            for(AccountContactRelation accConRole: [SELECT AccountId, Account.Name, Account.BillingCity, Account.BillingStreet, Account.BillingState,
                                                        Contact.Email, Contact.Website__c,
                                                        Account.BillingCountry, Account.BillingPostalCode, ContactId, Contact.Name  
                                                        FROM AccountContactRelation 
                                                        WHERE AccountId =: policy.Account__c AND Contact.Primary_Contact__c = true LIMIT 1])
            {
               
                primaryConRole = accConRole;
            }
        }
    }


}