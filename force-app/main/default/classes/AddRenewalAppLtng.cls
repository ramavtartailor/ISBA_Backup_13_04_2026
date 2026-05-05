public class AddRenewalAppLtng {
    @AuraEnabled
    public static String getPolicy(String policyId){
        String message = '';
        Map<Id,Profile> profilesMap = new Map<Id,Profile>([select id from Profile where Name = 'System Administrator']);
        Policy__c objPolicy = [select Id,Account__c,Renew_Application__c,Expiration_Date__c,Cancel_Date__c from Policy__c where Id =: policyId];
        Account acc = [SELECT Id,(SELECT Id FROM Policies__r WHERE RecordType.Name ='Application') FROM Account Where Id=:objPolicy.Account__c];
        if(!acc.Policies__r.isEmpty()){
             message = 'There is already an open application with this customer. Please review it before creating a new application.';
        }
        else if(objPolicy.Renew_Application__c != false){
            message = 'Application Renewal Blocked!';
        }else if((System.today() > objPolicy.Expiration_Date__c.addDays(90) || (objPolicy.Cancel_Date__c!=null && System.today() > objPolicy.Cancel_Date__c.addDays(90))) && !profilesMap.containsKey(UserInfo.getProfileId())){
            message = 'Cannot renew policy due to expiration or cancel date greater than 90 days.';
        }else{
            List<String> lstResult = CloneAndRenewalUtilities.renewPolicyManually(policyId);
            if(!lstResult.isEmpty()){
                message += lstResult[1];
            }      
        }
        return message;
    }
}