public class MassRenewalPolicyCtrl {
    public String error{get;set;}
    public String success{get;set;}
    List<Policy__c> selectedPolicies;
    public MassRenewalPolicyCtrl(ApexPages.StandardSetController controller){
        selectedPolicies = (List<Policy__c>)controller.getSelected();
    }
    public void massRenewPolicies(){
        if(selectedPolicies.size()>0){
            List<Policy__c> listPolicies = [SELECT id,name,ClonedBy__c,Policy_Renew_Status__c,Renew_Application__c,RecordType.Name  FROM Policy__c WHERE Id in: selectedPolicies];
            System.debug('listPolicies---'+listPolicies);
            List<Policy__c> policiesToUpdate = new List<Policy__c>();
            for(Policy__c pol:listPolicies){
                if(pol.RecordType.Name=='Policy'){
                    if(pol.Renew_Application__c){
                        pol.Policy_Renew_Status__c = 'Error : Application Renewal Blocked!';
                    }else if(pol.ClonedBy__c == 'Manual Renewal' || pol.ClonedBy__c == 'Renewal 3 Months Before Policy Expiration'){
                        pol.Policy_Renew_Status__c = 'Error : '+'Policy Already Renewed by ' + pol.ClonedBy__c;
                    }else{
                        pol.ClonedBy__c = 'Manual Renewal';
                        pol.Policy_Renew_Status__c = 'Renewal Created Successfully';
                    }
                }else{        
                    pol.Policy_Renew_Status__c = 'This is not a valid policy for renewal.';
                }
            }
            List<Database.SaveResult> resultPolicyList = Database.update(listPolicies,false);
            System.debug('====resultPolicyList==='+resultPolicyList);
            for(Integer i=0;i<resultPolicyList.size();i++){
                if(!resultPolicyList[i].isSuccess()){
                    listPolicies.get(i).ClonedBy__c='';
                    listPolicies.get(i).Policy_Renew_Status__c='Error : ';
                    for(Database.Error err : resultPolicyList[i].getErrors()) {
                        listPolicies.get(i).Policy_Renew_Status__c = listPolicies.get(i).Policy_Renew_Status__c + err.getMessage()+'-';
                    }                policiesToUpdate.add(listPolicies.get(i));
                }
            }
            success = 'Mass Operation Successful. Please see the status field for further information.';
            
        }else{
            error = 'Please select atleast one Policy.';
        }
    }
}