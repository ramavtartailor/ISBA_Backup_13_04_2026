public class PolicyEndorsementController {
	
    @AuraEnabled
    public static Policy_Endorsement__c getPolicyEndorse(String policyId){
        Policy_Endorsement__c objPolicyEndorse = [SELECT Id,Name,Event_Status__c,Endorsement_Number__c,Endorsement_Version__c,Policy__c,Policy__r.Account__c,Policy__r.recordType.Name,
                                                  GL_Processing_Date__c,Endorsement_Effective_Date__c
               									FROM Policy_Endorsement__c WHERE Id =: policyId];
        return objPolicyEndorse ;
    }
    @AuraEnabled
    public static void updatePolicy(String policyId){
    	Policy_Endorsement__c objPoliceEndor = getPolicyEndorse(policyId);
        system.debug('=====objPoliceEndor====='+objPoliceEndor.Endorsement_Number__c);
        if(objPoliceEndor.Endorsement_Number__c == 'IL 102'){
            List<JsonPolicyLawyerWrapper> wrapperList = new List<JsonPolicyLawyerWrapper>();
            for(Policy_Lawyer__c lawyer :[select id,Prior_Act_Date__c,Lawyer_Name__c, ARDC_Number__c  from Policy_Lawyer__c where Policy__c =: objPoliceEndor.Policy__c] ){
                JsonPolicyLawyerWrapper wrapper = new JsonPolicyLawyerWrapper();
                wrapper.lawyername = lawyer.Lawyer_Name__c;
                wrapper.priorActsDate = lawyer.Prior_Act_Date__c;
                wrapper.ardcNumber = lawyer.ARDC_Number__c ; 
                wrapperList.add(wrapper);
            }
            String jsonString = JSON.serialize(wrapperList);
            objPoliceEndor.Policy_Lawyer_Json__c = jsonString;
        }
        objPoliceEndor.Event_Status__c= 'Complete';
        if(Label.Process_Accounting_On_Endorsements == 'Y'){
            objPoliceEndor.Accounting_Processed__c = true;
            if(objPoliceEndor.GL_Processing_Date__c == null){
                objPoliceEndor.GL_Processing_Date__c = (objPoliceEndor.Endorsement_Effective_Date__c >= System.today() ? objPoliceEndor.Endorsement_Effective_Date__c : System.today());
            }
        }        
        update objPoliceEndor;
        if(objPoliceEndor.Policy__r.recordType.Name =='Policy'){
            PolicyDocumentsUtility.createEndorsement(objPoliceEndor.id,objPoliceEndor.Policy__c,objPoliceEndor.Name,objPoliceEndor.Endorsement_Number__c,objPoliceEndor.Endorsement_Version__c,objPoliceEndor.Policy__r.Account__c,null,objPoliceEndor.Id,true);
        }
        else{
            PolicyDocumentsUtility.createEndorsement(objPoliceEndor.id,objPoliceEndor.Policy__c,objPoliceEndor.Name,objPoliceEndor.Endorsement_Number__c,objPoliceEndor.Endorsement_Version__c,objPoliceEndor.Policy__r.Account__c,null,objPoliceEndor.Id );
        } 
    }
    
    @AuraEnabled
    public static void cancelEndorsement(String policyId){
        
        List<AS_Transaction__c> asTransactionsToInsert = new List<AS_Transaction__c>();
        
        Policy_Endorsement__c objPoliceEndor = getPolicyEndorse(policyId);
        objPoliceEndor.Event_Status__c= 'Cancel';   
        objPoliceEndor.Name = objPoliceEndor.Name + '- Cancel';
        
        if(!Test.isRunningTest()){
            update objPoliceEndor;
        }
        
        for(AS_Transaction__c as_trans: [SELECT Id,Name,Amount__c,Policy_Id__c,Firm_Id__c,Transaction_Type__c,Transaction_Sub_Type__c,Policy_Endorsement_Id__c FROM AS_Transaction__c WHERE Policy_Endorsement_Id__c = : policyId]){
            
            AS_Transaction__c as_transCopy = as_trans.clone(false, true, false, false);
            as_transCopy.Amount__c = - as_trans.Amount__c;
            asTransactionsToInsert.add(as_transCopy);
            
        }
        insert asTransactionsToInsert;
    }
    
}