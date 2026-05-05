public class New_SA_ERP_Ctrl {
    
    public class New_SA_ERP_CtrlException extends Exception{}
    
    @AuraEnabled
    public static List<Policy_Lawyer__c> getLawyerList(String policyId){
        List<Policy_Lawyer__c> lawyers = [SELECT Id, Lawyer__c, Is_Policy_Created__c, Lawyer__r.Contact__c, Lawyer__r.Name, Prior_Act_Date__c, Step__c, Rate_At__c, Policy__c, Policy__r.Active__c, Policy__r.Account__r.Name  FROM Policy_Lawyer__c WHERE Policy__c=: policyId ORDER by Lawyer__r.Contact__r.LastName ASC, Lawyer__r.Contact__r.FirstName];
        List<Policy_Lawyer__c> remaininglawyers = new List<Policy_Lawyer__c>();
        
        if(!lawyers.isEmpty() && !lawyers[0].Policy__r.Active__c){ 
            throw new New_SA_ERP_CtrlException('This policy is Inactive.');//policy is not active 
        }
        for(Policy_Lawyer__c pl: lawyers){
            if(!pl.Is_Policy_Created__c){
                remaininglawyers.add(pl);
            }
        }
        if(!lawyers.isEmpty() && lawyers.size() == 1){ 
            throw new New_SA_ERP_CtrlException('Lawyers should be more then one.');//Lawyer should be more then one
        }
        if(remaininglawyers.isEmpty()){
            throw new New_SA_ERP_CtrlException('The policy has been created for all lawyers.');
        }
        return remaininglawyers;
    }
}