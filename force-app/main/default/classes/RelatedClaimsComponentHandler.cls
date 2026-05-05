public class RelatedClaimsComponentHandler {
    @AuraEnabled
    public static List<Policy_Claim__c> getClaims(String recordId, boolean allRecords){
        String sObjName = ((Id)recordId).getSObjectType().getDescribe().getName();
        if(sObjName == 'Policy_Claim__c'){
            Set<Id> directRelatedClaimIds = new Set<Id>();
            Set<Id> allRelatedClaimIds = new Set<Id>();
            for(Related_Claim__c claim : [select Claim1__c,Claim2__c from Related_Claim__c where Claim1__c =: recordId or Claim2__c =: recordId ]){
                directRelatedClaimIds.add(claim.Claim1__c);
                directRelatedClaimIds.add(claim.Claim2__c);
            }
            for(Related_Claim__c claim : [select Claim1__c,Claim2__c from Related_Claim__c where Claim1__c in: directRelatedClaimIds or Claim2__c in: directRelatedClaimIds ]){
                if(claim.Claim1__c != recordId){
                    allRelatedClaimIds.add(claim.Claim1__c);
                }
                if(claim.Claim2__c != recordId){
                    allRelatedClaimIds.add(claim.Claim2__c);
                }
            }
            List<Policy_Claim__c> claims = new List<Policy_Claim__c>([select id,Name,File_Type__c,Policy__c,Report_Date__c,Occur_Date__c,Policy__r.Name from Policy_Claim__c where id in: allRelatedClaimIds]);
            return claims;
        }else if(sObjName == 'Policy__c'){
            Policy__c app = [select id,Account__c from Policy__c where id=:recordId ];
            List<Policy_Claim__c> claims = new List<Policy_Claim__c>([select id,Name,File_Type__c,Policy__c,Report_Date__c,Occur_Date__c,Policy__r.Name,Account__c from Policy_Claim__c where Account__c =: app.Account__c]);
            return claims;
        }else{
            List<Policy_Claim__c> claims = new List<Policy_Claim__c>();
            return claims;
        }
    }
    @AuraEnabled
    public static String typeOfRecord(String recordId){
        String sObjName = ((Id)recordId).getSObjectType().getDescribe().getName();
        return sObjName;
    }
}