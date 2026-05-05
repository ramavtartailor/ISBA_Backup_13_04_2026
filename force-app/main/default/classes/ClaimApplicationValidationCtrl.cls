public class ClaimApplicationValidationCtrl {
    
    @AuraEnabled
    public static Policy_Claim__c getPolicyClaim(String policyClaimId){
        Policy_Claim__c objPolicyClaim = [SELECT Id,Claim_Status__c,ClaimCloseDAte__c,Claim_Close_Payment_Resolutions__c,State__c,GEO_Factor__c,AOP_Factor__c, Activity__c, Allegation__c, Type_of_Error__c,
                                          Claim_Close_Reasons__c,Reserve_Loss__c,Reserve_LAE__c,GL_2140__c,GL_2100__c,GL_5010__c,GL_5035__c 
                                          FROM Policy_Claim__c WHERE Id =: policyClaimId];
        system.debug('objPolicyClaim :: ' + objPolicyClaim);
        return objPolicyClaim;
        
    }

}