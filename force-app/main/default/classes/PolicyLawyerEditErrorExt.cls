public with sharing class PolicyLawyerEditErrorExt {
    
    public Policy_Lawyer__c polLawyer;
    
    public PolicyLawyerEditErrorExt(ApexPages.StandardController controller) {
        this.polLawyer = (Policy_Lawyer__c)controller.getRecord();
    }
    
    public PageReference getRedir() {

        Policy_Lawyer__c pollawyer1 = [Select id,Policy__c,Policy__r.RecordType.Name From Policy_Lawyer__c Where Id =: polLawyer.Id];
        
        PageReference continuePage;
        String baseUrl = String.valueOf(System.URL.getOrgDomainUrl().toExternalForm());
        String retURL = apexpages.currentpage().getparameters().get('retURL');
        String recordType = apexpages.currentpage().getparameters().get('recordType');
        String token = apexpages.currentpage().getparameters().get('_CONFIRMATIONTOKEN');
        String action = apexpages.currentpage().getparameters().get('common.udd.actions.ActionsUtilORIG_URI');
        
        
        System.debug('pollawyer1.Policy__r.RecordType.Name :: ' + pollawyer1.Policy__r.RecordType.Name);
        if(pollawyer1.Policy__r.RecordType.Name == 'Policy'){
            
            return null;
            
        } else {
            
            if(recordType != null && recordType != ''){
                
                continuePage = new PageReference(baseUrl+ '/'+polLawyer.Id+'/e?retURL='+retURL+'&RecordType=' + recordType +'&_CONFIRMATIONTOKEN='+token +'&common.udd.actions.ActionsUtilORIG_URI='+action+'&nooverride=1');
                
            } else {
                continuePage = new PageReference(baseUrl+ '/'+polLawyer.Id+'/e?retURL='+retURL+'&_CONFIRMATIONTOKEN='+token +'&common.udd.actions.ActionsUtilORIG_URI='+action+'&nooverride=1');
            }
            
        }
        
        continuePage.setRedirect(true);
        return continuePage;
        
    }

}