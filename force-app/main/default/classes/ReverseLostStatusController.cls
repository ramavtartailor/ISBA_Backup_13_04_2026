public class ReverseLostStatusController {
    @AuraEnabled
    public static String convertToApplication(Id policyId){
        try{
            Policy__c objPolicy = [select id,Policy_Number_Before_Rejection__c,Name,Is_Rejected_Confirm__c,RecordTypeId,Status__c from Policy__c where id=: policyId];
            objPolicy.Is_Rejected_Confirm__c = false;
            objPolicy.RecordTypeId = ApplicationPolicyUtil.ApplicationRTID;
            objPolicy.Status__c = 'Application created';
            objPolicy.Name = objPolicy.Policy_Number_Before_Rejection__c;
            update objPolicy;
			return 'Success';            
        }catch(Exception e){
            return 'There is some error occurred : ' + e.getMessage();
        }
    }
	
}