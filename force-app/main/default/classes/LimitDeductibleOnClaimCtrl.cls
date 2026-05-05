public class LimitDeductibleOnClaimCtrl {
	@AuraEnabled
    public static Policy_Claim__c getClaimRecord(String recordId) {
        Policy_Claim__c claim =  [select id,Policy__r.Name,Policy__c,Policy__r.Limits__c,Policy_Incurred__c,Policy_Remaining_By_All_Claims__c,Policy__r.Deductible__c,Per_Claim_Deductible_Balance__c from Policy_Claim__c where id =: recordId];
        return claim;
    }
}