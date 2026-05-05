public class ApplicationPolicyTransferController {
    public String searchFirmName{get;set;}
    public Date searchExpirationStart{get;set;}
    public Date searchExpirationEnd{get;set;}
    public String searchRenewalType{get;set;}
    public String searchApplicationType{get;set;}
    public Boolean lostApp{get;set;}
    public Boolean canceledApp{get;set;}
    public Decimal premium{get;set;}
    public Policy__c samplePolicy{get;set;}
    public Id selectedUnderWriter{get;set;}
    public Id selectedTransferTo{get;set;}
    public List<BulkRenewalScreenControllerWrapper> searchedResults{get;set;}
    public List<String> limits{get;set;}
    public ApplicationPolicyTransferController(){
        searchApplicationType = '';
        lostApp = false;
        canceledApp = false;
        limits = new List<String>();
        samplePolicy = new Policy__c();
        samplePolicy.ERE_Date__c = System.today().addMonths(3).toStartofMonth();
        samplePolicy.Expiration_Date__c = System.today().addMonths(4).toStartofMonth().addDays(-1);
        selectedTransferTo = userInfo.getUserId();
    }
    public void fetchPolicy(){
        searchedResults = new List<BulkRenewalScreenControllerWrapper>();
        searchExpirationStart = samplePolicy.ERE_Date__c;
        searchExpirationEnd = samplePolicy.Expiration_Date__c;
        String query = 'Select Id,Name,Account__r.Name,Active_Laywers__c, Account__r.Open_Claims__c, Account__r.Closed_Claims_Past_5_Years__c,Expiration_Date__c,Renewal_Type__c,Limits__c,Premium__c,Cancel_Date__c,ClonedBy__c,Policy_Renew_Status__c,Account__c,' + 
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
        System.debug('searchApplicationType: ' + searchApplicationType);
        System.debug('lostApp: ' + lostApp);
        System.debug('canceledApp: ' + canceledApp);
        if(String.IsNotBlank(searchApplicationType)){
            if(String.IsNotBlank(Filter)){
                Filter += ' AND Application_Type__c =: searchApplicationType ';
            }else{
                Filter += ' WHERE Application_Type__c =: searchApplicationType ';
            }
        }
        
        if(lostApp !=null){
            if(String.IsNotBlank(Filter)){
                Filter += ' AND Is_Lost__c =: lostApp ';
            }else{  
                Filter += ' WHERE Is_Lost__c =: lostApp ';
            }
        }

        if(canceledApp !=null){
            if(String.IsNotBlank(Filter)){
                Filter += ' AND Is_Canceled__c =: canceledApp ';
            }else{
                Filter += ' WHERE Is_Canceled__c =: canceledApp ';
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
        
        System.debug(limits);

        if(limits.size()>0){
            if(String.IsNotBlank(Filter)){
                Filter += ' AND Limits__c in:  limits ';
            }else{
                Filter += ' WHERE Limits__c in:  limits ';
            }
        }

        if(String.isNotBlank(Filter)){
            query = query+''+Filter+' order by Expiration_Date__c ASC LIMIT 1000';
        }else{
            query = query+' order by Expiration_Date__c  ASC LIMIT 1000';
        }

        System.debug('query -> '+query);
        
        List<Policy__c> lstOfPolicies = database.query(query);
        system.debug('lstOfPolicies-----'+lstOfPolicies);
        for(Policy__c policy : lstOfPolicies){
            BulkRenewalScreenControllerWrapper wrapper = new BulkRenewalScreenControllerWrapper();
            wrapper.policy = policy;
            searchedResults.add(wrapper);
        }
    }
    public List<SelectOption> getLimit () {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select Limit-'));
        Set<String> limitsValues = new Set<String>();
        Map<Id,ILF_Coverage_Factor__c> threatMappingsLimits = new Map<Id,ILF_Coverage_Factor__c>([SELECT Id,Name,Is_10X10_Coverage__c,Is_5X5_Coverage__c FROM ILF_Coverage_Factor__c where OldLimit__c = false ORDER BY Coverage_Max_Per_Claim__c,Full_Coverage__c ASC LIMIT 1000]);
        for (ILF_Coverage_Factor__c threatMapping : threatMappingsLimits.values()) {
            if(!limitsValues.contains(threatMapping.Name)){
                limitsValues.add(threatMapping.Name);
                options.add(new SelectOption(threatMapping.Name,threatMapping.Name));
            }
        }
        return options;
    }
    public void renewMassPoliciesFunc(){
        Set<Id> policyIds = new Set<Id>();
        for(BulkRenewalScreenControllerWrapper wrapper : searchedResults){
            system.debug('---wrapper----'+wrapper);
            if(wrapper.isSelected){
                policyIds.add(wrapper.policy.Id);
            }
        }
        List<Policy__c> listPolicies = [SELECT id,name,ClonedBy__c,Policy_Renew_Status__c,Renew_Application__c,RecordType.Name,Underwriter_User__c FROM Policy__c WHERE Id in: policyIds];
        List<Policy__c> policiesToUpdate = new List<Policy__c>();
        for(Policy__c pol:listPolicies){
                pol.Underwriter_User__c = selectedTransferTo;
        }
        List<Database.SaveResult> resultPolicyList = Database.update(listPolicies,false);
        
        fetchPolicy();
    }
    public List<SelectOption> getUnderwriter() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        //User[] threatMappings = [SELECT Id,Name FROM User where (Profile.Name = 'Sales' OR Profile.Name = 'System Administrator' OR Profile.Name = 'Underwriting') ORDER BY Name LIMIT 1000];
        User[] threatMappings = [SELECT Id,Name FROM User where isActive = true AND (Profile.Name = 'Sales' OR Profile.Name = 'Underwriting') ORDER BY Name LIMIT 1000];
        for (User threatMapping : threatMappings) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
        }
        return options;
    }
    public List<SelectOption> getTransferTo() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        User[] threatMappings = [SELECT Id,Name FROM User where (Profile.Name = 'Sales' OR Profile.Name = 'System Administrator' OR Profile.Name = 'Underwriting') and IsActive = true ORDER BY Name LIMIT 1000];
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
    public List<SelectOption> getApplicationType(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'All'));
        options.add(new SelectOption('New Business' ,'New Business'));
        options.add(new SelectOption('Renewal' ,'Renewal'));
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