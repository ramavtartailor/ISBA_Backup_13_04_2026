public class ClonePolicyRejectedCtrl {
    public class ClonePolicyRejectedCtrlException extends Exception{}

    @AuraEnabled
    public static String clonePolicy(String policyId, Date effDate){
        try{
            Policy__c objPolicy = [SELECT Id,Account__c FROM Policy__c WHERE Id=:policyId];
            Account acc = [SELECT Id,(SELECT Id FROM Policies__r WHERE RecordType.Name ='Application') FROM Account Where Id=:objPolicy.Account__c];
            if(!acc.Policies__r.isEmpty()){
                throw new ClonePolicyRejectedCtrlException('There is already an open application with this customer. Please review it before creating a new application.');
            }
            
            objPolicy.ClonedBy__c = 'Rejected Renewal';
            objPolicy.Clone_Application_Effective_Date__c = effDate;
            update objPolicy;
            String newPolicyId = [select id from Policy__c where Old_Policy__c = : policyId limit 1].id;
            return newPolicyId;
        }
        catch(DmlException de){
            throw new ClonePolicyRejectedCtrlException(de.getDMLMessage(0));
        }
        catch(Exception e){
            throw new ClonePolicyRejectedCtrlException(e.getMessage());
        }
    }
}