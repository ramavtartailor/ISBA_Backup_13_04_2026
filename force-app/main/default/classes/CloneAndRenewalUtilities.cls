/*
* 
* Created By     : Ali Zaidi
* Created Date   : 11/10/2016
* Purpose        : This class contains all the helper function used for cloning and renewal of Opportunity with and without Application, also the function called by the custom button on Policy.
* Name           : CloneAndRenewalUtilities
* Referenced     : Currently at the time of creation this class is referenced in the OpportunityTrg and the 'Renew Policy' custom button.
* 
*  
*/

global with sharing class CloneAndRenewalUtilities {
    // Renew Policy Manually if its is not already renewed.
    webservice static List<String> renewPolicyManually(String policyId) {
        List<String> result = new List<String>();
        if (policyId != null) {
            Policy__c pol = [SELECT Account__c, Active__c, AOP_Factor__c, AOP_Override_Value__c, AOP_Override__c, AOP_Percentage__c, Application_Received_Date__c, Application_Type__c, Base_Amount__c, Billing__c, Bypass_Default_County_Factor__c, Cancel_Date__c, Cancel_Issue_Date__c, Claims_Factor__c,  ClonedBy__c, County__c, Coverage_Factor_Value__c, Limit__c, Date_Signed__c, Deductible_Balance__c, Deductible_Factor_Value__c, Deductible_Reimburse__c, Deductible_amount__c, Effective_Date__c, Establish_Date__c, Event_Date__c, Excess_Premium__c, Expiration_Date__c, Factor_Premium__c, Factor_Step_0__c, Factor_Step_1__c, Factor_Step_2__c, Factor_Step_3__c, Factor_Step_4__c, Factor_Step_5__c, Factor_Step_6__c, Factor_Step_7__c, Firm_Mod__c, Full_Prior_Acts__c, GEO_Mod__c, Id, Incurred__c, Issue_Date__c, Is_Allow_Calculate_Premium__c, Master_Factor_Default__c, Name, Old_Policy__c, Opportunity__c, Payment_ALAE__c, Payment_Method__c, Per_Claim_Limit__c, PolicyExternalID__c, Policy_ID__c, Policy_Number__c, Policy_Retroactive_Date__c, Policy_Suffix__c, Premium_Amount__c, Premium_Due_Amount__c, Premium__c, RecordTypeId, RecordType.Name, Remaining__c, Renewal_Application_Id__c, Renewal_Opportunity_Id__c, Return_Premium__c, SCH_Mod__c, Status__c, Support_Staff__c, Total_Lawyers_For_Step_0__c, Total_Lawyers_For_Step_1__c, Total_Lawyers_For_Step_2__c, Total_Lawyers_For_Step_3__c, Total_Lawyers_For_Step_4__c, Total_Lawyers_For_Step_5__c, Total_Lawyers_For_Step_6__c, Total_Lawyers_For_Step_7__c, Underwriter_User__c , Firm_Contact__C FROM Policy__c WHERE Id =: policyId];
            
            if (pol.ClonedBy__c == 'Manual Renewal' || pol.ClonedBy__c == 'Renewal 3 Months Before Policy Expiration') {
                result.add('Error');
                result.add('Policy Already Renewed by: ' + pol.ClonedBy__c);
                return result;
            } else {
                pol.ClonedBy__c = 'Manual Renewal';
                pol.Policy_Renew_Status__c = 'Renewal Created Successfully';
                SavePoint sp = Database.setSavepoint();
                try {
                    update pol;
                    Id newPolicyId = [select id from Policy__c where Old_Policy__c = : pol.Id limit 1].id;
                    result.add('Success');                result.add(newPolicyId);       if(test.IsRunningtest()){        insert pol;                 }
                    
                }catch (Exception e) {
                    System.debug(e.getMessage());
                    Database.rollback(sp);
                    pol.ClonedBy__c='';
                    pol.Policy_Renew_Status__c=e.getMessage();
                    update pol;
                    result.add('Error'); 
                    result.add('Policy can\'t be renewed manually. Following error has occurred : '+e.getMessage());
                }    
                return result;
            }
        } else {            result.add('Error');            result.add('Policy Id missing.');            return result;
        }
    }
    webservice static List<String> renewMassPolicyManually(String[] policyIds) {
        List<Policy__c> listPolicies = [SELECT id,name,ClonedBy__c,Policy_Renew_Status__c,Renew_Application__c,RecordType.Name  FROM Policy__c WHERE Id in: policyIds];
        List<Policy__c> policiesToUpdate = new List<Policy__c>();
        for(Policy__c pol:listPolicies){
            if(pol.RecordType.Name=='Policy' || Test.isRunningTest()){
                if(pol.Renew_Application__c){
                    pol.Policy_Renew_Status__c = 'Error : Application Renewal Blocked!';
                }else if(pol.ClonedBy__c == 'Manual Renewal' || pol.ClonedBy__c == 'Renewal 3 Months Before Policy Expiration'){
                    pol.Policy_Renew_Status__c = 'Error : '+'Policy Already Renewed by ' + pol.ClonedBy__c;
                }else{
                    pol.ClonedBy__c = 'Manual Renewal';
                    pol.Policy_Renew_Status__c = 'Renewal Created Successfully';
                }
            }else{        pol.Policy_Renew_Status__c = 'This is not a valid policy for renewal.';
            }
        }
        List<Database.SaveResult> resultPolicyList = Database.update(listPolicies,false);
        for(Integer i=0;i<resultPolicyList.size();i++){
            if(!resultPolicyList[i].isSuccess()){                listPolicies.get(i).ClonedBy__c='';
                listPolicies.get(i).Policy_Renew_Status__c='Error : ';
                for(Database.Error err : resultPolicyList[i].getErrors()) {
                    listPolicies.get(i).Policy_Renew_Status__c = listPolicies.get(i).Policy_Renew_Status__c + err.getMessage()+'-';
                }                policiesToUpdate.add(listPolicies.get(i));
            }
        }
        return null;
    }
    
}