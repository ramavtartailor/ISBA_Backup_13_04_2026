public class PolicyDeductibleInvoiceHandler {
    public  AcctSeed__Billing__c acc {get;set;}
    public Policy__c pcc {get;set;}
    public Decimal totalBilled{get;set;}
    public Decimal totalPaid{get;set;}
    public Decimal totalBalance{get;set;}
    public Decimal totalPayments{get;set;}
    public PolicyDeductibleInvoiceHandler(ApexPages.StandardController stdController){
        totalBilled = totalPaid = totalBalance = totalPayments = 0 ;
        acc = [Select id,AcctSeed__Date__c,AcctSeed__Billing_Contact__c,AcctSeed__Billing_Street__c,AcctSeed__Billing_City__c,AcctSeed__Billing_State__c,Claim__c,
               AcctSeed__Billing_PostalCode__c,Claim__r.Name,Claim__r.Policy_Deductible__r.Deductible_Amount__c,Claim__r.Aggregate_Limit__c,
               Claim__r.Per_Claim_Limit__c,Claim__r.Claimant__c,Claim__r.File_Type__c,Claim__r.Policy__r.Policy_Number__c,Claim__r.Payment_Direct_Loss__c,Claim__r.Payment_Direct_LAE__c from AcctSeed__Billing__c where id=: stdController.getId()];
        totalPayments += acc.Claim__r.Payment_Direct_Loss__c;
        totalPayments += acc.Claim__r.Payment_Direct_LAE__c;
        for(AcctSeed__Billing__c billing : [select id,AcctSeed__Total__c,AcctSeed__Balance__c,AcctSeed__Received_Amount__c from AcctSeed__Billing__c where Claim__c =: acc.Claim__c]){
            totalBilled += billing.AcctSeed__Total__c;
            totalBalance += billing.AcctSeed__Balance__c;
            totalPaid += billing.AcctSeed__Received_Amount__c;
        }
    }
    
    
}