public class ContactClaimsComponentHandler {
	@AuraEnabled
    public static List<Policy_Claim__c> getClaims(String recordId, boolean allRecords){
        String sObjName = ((Id)recordId).getSObjectType().getDescribe().getName();
        if(sObjName == 'Contact'){
            List<Policy_Claim__c> policyClaims = new List<Policy_Claim__c>();
            for(Policy_Claim__c claim : [select id,Name,Policy_Number__c,Claimant__c,File_Type__c,Report_Date__c,Claim_Status__c,Policy__r.Name,GL_2100__c,GL_2140__c,GL_5000__c,GL_5030__c,GL_5010__c,GL_5035__c from Policy_Claim__c where LawyerNew__r.Contact__c =: recordId order by Name desc ]){
                policyClaims.add(claim);
            }
            return policyClaims;
        }else{
            List<Policy_Claim__c> policyClaims = new List<Policy_Claim__c>();
            return policyClaims;
        }
    }
}