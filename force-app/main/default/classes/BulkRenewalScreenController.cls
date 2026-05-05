public class BulkRenewalScreenController {
    public String searchFirmName{get;set;}
    public Date searchExpirationStart{get;set;}
    public Date searchExpirationEnd{get;set;}
    public String searchRenewalType{get;set;}
    public String hasCancelled{get;set;}
    public String hasBlock{get;set;}
    public String hasOpenClaim{get;set;}
    public String hasPastClaim{get;set;}
    public String hasPendingApplication{get;set;}
    public Decimal premium{get;set;}
    public String radioName{get;set;}
    public String radioValue{get;set;}
    public Policy__c samplePolicy{get;set;}
    public Id selectedUnderWriter{get;set;}
    public List<BulkRenewalScreenControllerWrapper> searchedResults{get;set;}
    public BulkRenewalScreenController(){
        samplePolicy = new Policy__c();
        samplePolicy.ERE_Date__c = System.today().addMonths(3).toStartofMonth();
        samplePolicy.Expiration_Date__c = System.today().addMonths(4).toStartofMonth().addDays(-1);
        hasPendingApplication = 'No';
        hasCancelled = 'No';
    }
    public void fetchPolicy(){
        
        searchedResults = new List<BulkRenewalScreenControllerWrapper>();
        searchExpirationStart = samplePolicy.ERE_Date__c;
        searchExpirationEnd = samplePolicy.Expiration_Date__c;
        String query = 'Select Id,Name,Account__r.Name,Expiration_Date__c,Renewal_Type__c,Limits__c,Premium__c,Cancel_Date__c,ClonedBy__c,Policy_Renew_Status__c,Account__c,' + 
                        'Underwriter_User__c,Underwriter_User__r.Name from Policy__c';
        String Filter = ' WHERE ERE_Date__c = null';
       if(String.IsNotBlank(searchFirmName)){
            searchFirmName = '%'+searchFirmName +'%';
            Filter += ' AND (Account__r.Name LIKE : searchFirmName OR Account__r.AccountNumber LIKE : searchFirmName) ';
        }
        if(searchExpirationStart !=null){
            if(String.IsNotBlank(Filter)){
                Filter += ' AND Expiration_Date__c >= : searchExpirationStart ';
            }else{
                Filter += ' WHERE Expiration_Date__c >= :  searchExpirationStart ';
            }
        }
        if(searchExpirationEnd !=null){
            if(String.IsNotBlank(Filter)){
                Filter += ' AND Expiration_Date__c <= :  searchExpirationEnd ';
            }else{
                Filter += ' WHERE Expiration_Date__c <= :  searchExpirationEnd ';
            }
        }
        if(String.IsNotBlank(searchRenewalType)){
            if(String.IsNotBlank(Filter)){
                Filter += ' AND Renewal_Type__c =: searchRenewalType ';
            }else{
                Filter += ' WHERE Renewal_Type__c =: searchRenewalType ';
            }
        }
        if(premium !=null && premium > 0){
            if(String.IsNotBlank(Filter)){
                Filter += ' AND Premium__c <= :  premium ';
            }else{
                Filter += ' WHERE Premium__c <= :  premium ';
            }
        }
        if(selectedUnderWriter !=null){
            if(String.IsNotBlank(Filter)){
                Filter += ' AND Underwriter_User__c = :  selectedUnderWriter ';
            }else{
                Filter += ' WHERE Underwriter_User__c =:  selectedUnderWriter ';
            }
        }
        if(String.IsNotBlank(hasCancelled)){
            if(String.IsNotBlank(Filter)){
                if(hasCancelled == 'Yes'){
                    Filter += ' AND Cancel_Date__c != null ';
                }else if(hasCancelled == 'No'){
                    Filter += ' AND Cancel_Date__c = null ';
                }
            }else{
                if(hasCancelled == 'Yes'){
                    Filter += ' WHERE Cancel_Date__c != null ';
                }else if(hasCancelled == 'No'){
                    Filter += ' WHERE Cancel_Date__c = null ';
                }
            }
        }
        if(String.IsNotBlank(hasPendingApplication)){
            if(String.IsNotBlank(Filter)){
                if(hasPendingApplication == 'Yes'){
                    Filter += ' AND ClonedBy__c != null ';
                }else if(hasPendingApplication == 'No'){
                    Filter += ' AND ClonedBy__c = null ';
                }
            }else{
                if(hasPendingApplication == 'Yes'){
                    Filter += ' WHERE ClonedBy__c != null ';
                }else if(hasPendingApplication == 'No'){
                    Filter += ' WHERE ClonedBy__c = null ';
                }
            }
        }
        if(String.isNotBlank(Filter)){
            query = query+''+Filter+' AND RecordType.Name = \'Policy\' order by Expiration_Date__c ASC LIMIT 1000';
        }else{
            query = query+' WHERE RecordType.Name = \'Policy\' order by Expiration_Date__c  ASC LIMIT 1000';
        }
        
        List<Policy__c> lstOfPolicies = database.query(query);
        system.debug('lstOfPolicies-----'+lstOfPolicies);
        for(Policy__c policy : lstOfPolicies){
            BulkRenewalScreenControllerWrapper wrapper = new BulkRenewalScreenControllerWrapper();
            wrapper.policy = policy;
            searchedResults.add(wrapper);
        }
    }
    public void updateRadioValues(){
        if(radioName == 'hasCancelled'){
            hasCancelled = radioValue;
        }else if(radioName == 'hasBlock'){
            hasBlock = radioValue;
        }else if(radioName == 'hasOpenClaim'){
            hasOpenClaim = radioValue;
        }else if(radioName == 'hasPastClaim'){
            hasPastClaim = radioValue;
        }else if(radioName == 'hasPendingApplication'){
            hasPendingApplication = radioValue;
        }
    }
    public void renewMassPoliciesFunc(){
        Set<Id> policyIds = new Set<Id>();
        for(BulkRenewalScreenControllerWrapper wrapper : searchedResults){
            system.debug('---wrapper----'+wrapper);
            if(wrapper.isSelected){
                policyIds.add(wrapper.policy.Id);
            }
        }
        List<Policy__c> listPolicies = [SELECT id,name,ClonedBy__c,Policy_Renew_Status__c,Renew_Application__c,RecordType.Name  FROM Policy__c WHERE Id in: policyIds];
        List<Policy__c> policiesToUpdate = new List<Policy__c>();
        for(Policy__c pol:listPolicies){
            if(pol.Renew_Application__c){
                pol.Policy_Renew_Status__c = 'Error : Application Renewal Blocked!';
            }else if(pol.ClonedBy__c == 'Manual Renewal' || pol.ClonedBy__c == 'Renewal 3 Months Before Policy Expiration'){
                pol.Policy_Renew_Status__c = 'Error : '+'Policy Already Renewed by ' + pol.ClonedBy__c;
            }else{
                pol.ClonedBy__c = 'Manual Renewal';
                pol.Policy_Renew_Status__c = 'Renewal Created Successfully';
            }
        }
        List<Database.SaveResult> resultPolicyList = Database.update(listPolicies,false);
        for(Integer i=0;i<resultPolicyList.size();i++){
            if(!resultPolicyList[i].isSuccess()){                
                listPolicies.get(i).ClonedBy__c='';
                listPolicies.get(i).Policy_Renew_Status__c='Error : ';
                for(Database.Error err : resultPolicyList[i].getErrors()) {
                    listPolicies.get(i).Policy_Renew_Status__c = listPolicies.get(i).Policy_Renew_Status__c + err.getMessage()+'-';
                }                
                policiesToUpdate.add(listPolicies.get(i));
            }
        }
        resultPolicyList = Database.update(policiesToUpdate,false);
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
    public List<SelectOption> getRenewalType(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'All'));
        options.add(new SelectOption('Regular Renewal' ,'Regular Renewal'));
        options.add(new SelectOption('EZ Renewal' ,'EZ Renewal'));
        options.add(new SelectOption('Super EZ' ,'Super EZ'));
        options.add(new SelectOption('Online Invoice' ,'Online Invoice'));
        return options;
    }
    public class BulkRenewalScreenControllerWrapper{
        public Policy__c policy{get;set;}
        public boolean isSelected{get;set;}
        
        public BulkRenewalScreenControllerWrapper(){
            isSelected = false;
        }
    }
}