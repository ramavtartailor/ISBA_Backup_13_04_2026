public class ClaimSearchScreenController {
    public String searchClaimNumber{get;set;}
    public String searchLawyerName{get;set;}
    public String searchClaimantName{get;set;}
    public String hasOpen{get;set;}
    public String radioName{get;set;}
    public String radioValue{get;set;}
    public String searchFirmName{get;set;}
    public Policy_Claim__c sampleClaim{get;set;}
    public List<ClaimSearchScreenControllerWrapper> searchedResults{get;set;}
    public ClaimSearchScreenController(){
        sampleClaim = new Policy_Claim__c();     
        hasOpen = 'Either';
    }
    public void clearDataFunc(){
        sampleClaim = new Policy_Claim__c();  
        searchClaimNumber = searchLawyerName = searchClaimantName = searchFirmName ='';
        hasOpen = 'Either';
        searchedResults = new List<ClaimSearchScreenControllerWrapper>();
    }
    public void fetchClaim(){
        searchedResults = new List<ClaimSearchScreenControllerWrapper>();
        String query = 'Select Id, Name, Policy__c,Policy__r.Account__c,Policy__r.Account__r.Name,Lawyer_Name__c,Claimant__c, Policy__r.Name, Report_Date__c, File_Type__c, Occur_Date__c,Claim_Status__c from Policy_Claim__c';
        String Filter = '';
       if(String.IsNotBlank(searchClaimNumber)){
           if(searchClaimNumber.length() == 5){
               searchClaimNumber = searchClaimNumber.substring(0, 2) + '-' + searchClaimNumber.substring(2, searchClaimNumber.length());
           }
            searchClaimNumber = '%'+searchClaimNumber +'%';
            Filter += ' WHERE (Name LIKE : searchClaimNumber) ';
        } 
        if(String.IsNotBlank(searchFirmName)){
            if(String.IsNotBlank(Filter)){
                Filter += ' AND (Policy__r.Account__r.Name LIKE \'%'+ searchFirmName +'%\' OR Policy__r.Account__r.AccountNumber LIKE \'%'+ searchFirmName +'%\') ';
            }else{
                Filter += ' WHERE (Policy__r.Account__r.Name LIKE \'%'+ searchFirmName +'%\' OR Policy__r.Account__r.AccountNumber LIKE \'%'+ searchFirmName +'%\') ';
            }
        } 
        if(String.IsNotBlank(searchLawyerName)){
            if(String.IsNotBlank(Filter)){
                Filter += ' AND (Lawyer_Name__c LIKE \'%'+ searchLawyerName +'%\') ';
            }else{
                Filter += ' WHERE (Lawyer_Name__c LIKE \'%'+ searchLawyerName +'%\') ';
            }
        }        

        if(String.IsNotBlank(searchClaimantName)){
            if(String.IsNotBlank(Filter)){
                Filter += ' AND (Claimant__c LIKE \'%'+searchClaimantName +'%\')  ';
            }else{
                Filter += ' WHERE (Claimant__c LIKE \'%'+searchClaimantName +'%\')  ';
            }
        } 
        if(String.IsNotBlank(hasOpen)){
            if(String.IsNotBlank(Filter)){
                if(hasOpen == 'Yes'){
                    Filter += ' AND Claim_Status__c= \'Open\' ';
                }else if(hasOpen == 'No'){
                    Filter += ' AND Claim_Status__c= \'Closed\' ';
                }
            }else{
                if(hasOpen == 'Yes'){
                    Filter += ' WHERE Claim_Status__c = \'Open\' ';
                }else if(hasOpen == 'No'){
                    Filter += ' WHERE Claim_Status__c= \'Closed\' ';
                }
            }
        }
        if(String.isNotBlank(Filter)){
            query = query+''+Filter;
        }else{
            query = query;
        }
        
        System.debug('query------'+query);
        System.debug('searchClaimNumber------'+searchClaimNumber);
        System.debug('searchLawyerName  ------'+searchLawyerName);
        System.debug('searchClaimantName------'+searchClaimantName);
        
        List<Policy_Claim__c> lstOfClaims = (List<Policy_Claim__c>)database.query(query);
        system.debug('lstOfClaims-----'+lstOfClaims);
        for(Policy_Claim__c claim : lstOfClaims){
            ClaimSearchScreenControllerWrapper wrapper = new ClaimSearchScreenControllerWrapper();
            wrapper.claim = claim;
            searchedResults.add(wrapper);
        }
    }
    public void updateRadioValues(){
        if(radioName == 'hasOpen'){
            hasOpen = radioValue;
        }
    }
    public void renewMassClaimsFunc(){
        Set<Id> claimIds = new Set<Id>();
        for(ClaimSearchScreenControllerWrapper wrapper : searchedResults){
            system.debug('---wrapper----'+wrapper);
            if(wrapper.isSelected){
                claimIds.add(wrapper.claim.Id);
            }
        }
        List<Policy_Claim__c> listClaims = [SELECT id  FROM Policy_Claim__c WHERE Id in: claimIds];
        List<Policy_Claim__c> claimsToUpdate = new List<Policy_Claim__c>();
        for(Policy_Claim__c cla:listClaims){
            cla.Claim_Status__c = 'Open';
        }
        List<Database.SaveResult> resultClaimList = Database.update(listClaims,false);
        fetchClaim();
    }


    public class ClaimSearchScreenControllerWrapper{
        public Policy_Claim__c claim{get;set;}
        public boolean isSelected{get;set;}
        
        public ClaimSearchScreenControllerWrapper(){
            isSelected = false;
        }
    }
}