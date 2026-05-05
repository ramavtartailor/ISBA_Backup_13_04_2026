public class PrintPoliciesController {
    public String searchFirmName{get;set;}
    public Date searchEffectiveStart{get;set;}
    public Date searchEffectiveEnd{get;set;}
    public Policy__c samplePolicy{get;set;}
    public Id selectedUnderWriter{get;set;}
    public Id rowIdx{get;set;}
    public String searchPolicyStatus{get;set;}
    public List<PrintPoliciesControllerWrapper> searchedResults{get;set;}
    public PrintPoliciesController(){
        samplePolicy = new Policy__c();
        fetchPolicy();
    }
    public void fetchPolicy(){
        
        searchedResults = new List<PrintPoliciesControllerWrapper>();
        searchEffectiveStart = samplePolicy.Application_Received_Date__c;
        searchEffectiveEnd = samplePolicy.Date_Signed__c;
        String query = 'Select Id,Name,Account__r.Name,Effective_Date__c,Expiration_Date__c,Renewal_Type__c,Limits__c,Premium__c,Cancel_Date__c,ClonedBy__c,Policy_Renew_Status__c,Account__c,' + 
                        'Underwriter_User__c,Underwriter_User__r.Name,Status__c from Policy__c';
        String Filter = '';
       if(String.IsNotBlank(searchFirmName)){
            searchFirmName = '%'+searchFirmName +'%';
            Filter += ' WHERE Account__r.Name LIKE : searchFirmName ';
        }
        if(searchEffectiveStart !=null){
            if(String.IsNotBlank(Filter)){
                Filter += ' AND Effective_Date__c >= : searchEffectiveStart ';
            }else{
                Filter += ' WHERE Effective_Date__c >= :  searchEffectiveStart ';
            }
        }
        if(searchEffectiveEnd !=null){
            if(String.IsNotBlank(Filter)){
                Filter += ' AND Effective_Date__c <= :  searchEffectiveEnd ';
            }else{
                Filter += ' WHERE Effective_Date__c <= :  searchEffectiveEnd ';
            }
        }
        if(selectedUnderWriter !=null){
            if(String.IsNotBlank(Filter)){
                Filter += ' AND Underwriter_User__c = :  selectedUnderWriter ';
            }else{
                Filter += ' WHERE Underwriter_User__c =:  selectedUnderWriter ';
            }
        }
        if(String.IsNotBlank(searchPolicyStatus)){
            if(String.IsNotBlank(Filter)){
                Filter += ' AND Status__c =: searchPolicyStatus ';
            }else{
                Filter += ' WHERE Status__c =: searchPolicyStatus ';
            }
        }
        if(String.isNotBlank(Filter)){
            query = query+''+Filter+' AND RecordType.Name = \'Policy\' and Status__c != \'Policy Sent\' LIMIT 1000';
        }else{
            query = query+' WHERE RecordType.Name = \'Policy\' and Status__c != \'Policy Sent\' LIMIT 1000';
        }
        System.debug(query);
        List<Policy__c> lstOfPolicies = database.query(query);
        system.debug('lstOfPolicies-----'+lstOfPolicies);
        for(Policy__c policy : lstOfPolicies){
            PrintPoliciesControllerWrapper wrapper = new PrintPoliciesControllerWrapper();
            wrapper.policy = policy;
            searchedResults.add(wrapper);
        }
    }
    public void sendPolicyStatus(){
        if(rowIdx!=null){
            Policy__c policy = new Policy__c(Id = rowIdx,Status__c = 'Policy Sent',Send_Date__c = System.now());
            update policy;
        }
        fetchPolicy();
    }
    public List<SelectOption> getUnderwriter() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        User[] threatMappings = [SELECT Id,Name FROM User where (Profile.Name = 'Sales' OR Profile.Name = 'System Administrator' OR Profile.Name = 'Underwriting') AND ISACTIVE = TRUE ORDER BY Name LIMIT 1000];
        for (User threatMapping : threatMappings) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
        }
        return options;
    }
    public List<SelectOption> getPolicyStatus(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'All'));
        options.add(new SelectOption('Printed' ,'Printed'));
        options.add(new SelectOption('Bound' ,'Bound'));
        return options;
    }
    public class PrintPoliciesControllerWrapper{
        public Policy__c policy{get;set;}
        
        public PrintPoliciesControllerWrapper(){
        }
    }
}