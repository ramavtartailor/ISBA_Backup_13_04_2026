public class ClaimHistoryComponentHandler {
	@AuraEnabled
    public static List<Policy_Claim__c> getClaims(String recordId, boolean allRecords){
        String sObjName = ((Id)recordId).getSObjectType().getDescribe().getName();
        String accId = '';
        List<Policy_Claim__c> policies = new List<Policy_Claim__c>();
        if(sObjName == 'Policy__c'){
            Policy__c policy = [select Id,Account__c from Policy__c where  id =: recordId];
            accId = policy.Account__c;
        }else if(sObjName == 'Policy_Claim__c'){
            Policy_Claim__c claim = [select Id,Policy__r.Account__c from Policy_Claim__c where id =: recordId];
            accId = claim.Policy__r.Account__c;
        }else if(sObjName == 'Account'){
            accId = recordId;
        }
        
        if(String.isNotBlank(accId)){
            policies = new List<Policy_Claim__c>([select Id,Name,Account__c,ClaimType__c,Report_Date__c,Claim_Status__c,Policy_Number__c,File_Type__c,Occur_Date__c,Policy__r.Name,Policy__c,GL_2100__c,GL_2140__c,GL_5000__c,GL_5030__c,GL_5010__c,GL_5035__c, Lawyer_Name__c,ClaimCloseDAte__c,LAE_Incurred_Total__c,Loss_Incurred_Total__c,Incurred_Total__c,LAEPay__c,Loss_Res__c   from Policy_Claim__c where Account__c =: accId order by Report_Date__c desc ]);
            return policies;
        }
        return policies;
    }
}