public class Contact_ClaimHistoryCtrl {
	@AuraEnabled
    public static Wrapper getClaims(String recordId){
        Wrapper wrap = new Wrapper();
        List<Policy_Claim__c> claims = new List<Policy_Claim__c>();
        List<AccountContactJunction__c> lawyers = new List<AccountContactJunction__c>([SELECT Id, Contact__c, Contact__r.Name, (SELECT Id,Name,Account__c,ClaimType__c,Report_Date__c,Claim_Status__c,Policy_Number__c,File_Type__c,Occur_Date__c,Policy__r.Name,Policy__c,GL_2100__c,GL_2140__c,GL_5000__c,GL_5030__c,GL_5010__c,GL_5035__c, Lawyer_Name__c,ClaimCloseDAte__c,LAE_Incurred_Total__c,Loss_Incurred_Total__c,Incurred_Total__c,LAEPay__c,Loss_Res__c   from Claims__r) FROM AccountContactJunction__c WHERE Contact__c =: recordId]);
        if(!lawyers.isEmpty()){
            for(AccountContactJunction__c lawr: lawyers){
                if(!lawr.claims__r.isEmpty()){
                    claims.addAll(lawr.claims__r);
                }
            }
            wrap.recName = lawyers[0].Contact__r.Name;
        }
        wrap.claims = claims;
        return wrap;
    }
    public Class Wrapper{
        @AuraEnabled public string recName{get;set;}
        @AuraEnabled public List<Policy_Claim__c> claims{get;set;}
        public Wrapper(){
            recName = '';
            claims = new List<Policy_Claim__c>();
        }
    }
}