public class FirmSearchController{
public String searchName {get;set;}
public String searchPolicy {get;set;}
public String searchCity {get;set;}
public List<AccountWrapper> searchAccounts{get;set;}
    public FirmSearchController(){
        searchAccounts = New List<AccountWrapper>();
        fatchPolicy();
    }
    
    public void fatchPolicy(){
        searchAccounts = New List<AccountWrapper>();
        String query = 'SELECT Id,Name,BillingCity,BillingPostalCode ,Phone, (SELECT Id ,recordtype.Name,Effective_Date__c, Name FROM Policies__r WHERE (recordtype.Name = \'Application\' OR recordtype.Name = \'Policy\') ORDER BY Effective_Date__c  DESC LIMIT 1000) '
                       +' FROM Account ';
        String Filter = '';
        Set<Id> accIdSet = New Set<Id>();
        if(String.IsNotBlank(searchName)){
            searchName = String.escapeSingleQuotes(searchName);
            List<String> strArray = searchName.split(' ');
            searchName = '%'+searchName +'%';
            Filter += ' WHERE ((Name LIKE : searchName ) ';
            String filter2;
            if(strArray.size()>0){
                for(String str : strArray){
                    if(String.isBlank(filter2)){
                        filter2 = ' Name LIKE \'%' + str + '%\' ';
                    }else{
                        filter2 += ' AND Name LIKE \'%' + str  + '%\' ';
                    }
                    System.debug(str);
                }
            }
            
            if(String.isNotBlank(filter2)){
                Filter += ' OR ('+  filter2 +') ) ';
            }else{
                Filter += ' ) ';
            }
        }
        if(String.IsNotBlank(searchCity)){
            searchCity = String.escapeSingleQuotes(searchCity);
            if(String.IsNotBlank(Filter)){
                searchCity = '%'+searchCity +'%';
                Filter += ' AND BillingCity LIKE : searchCity ';
            }else{
                searchCity = searchCity +'%';
                Filter += ' WHERE BillingCity LIKE : searchCity ';
            }
        }
        if(String.IsNotBlank(searchPolicy)){
            searchPolicy = String.escapeSingleQuotes(searchPolicy);
            searchPolicy = '%'+searchPolicy+'%';
            String policyQuery = 'Select id , Account__c FROM Policy__c WHERE Name LIKE : searchPolicy ';
            for(Policy__c po : database.query(policyQuery )){
                accIdSet.add(po.Account__c);
            }
            if(!accIdSet.IsEmpty()){
                if(String.IsNotBlank(Filter)){
                    Filter += ' AND Id IN : accIdSet';
                }else{
                    Filter += ' WHERE Id IN : accIdSet';
                }
            }
        }
        If(String.IsNotBlank(Filter)){
            query = query+''+Filter+' LIMIT 1000';
            system.debug('!!!!!!!!!!!!!!!!! '+query );
            List<Account> lstOfAccounts = database.query(query);
            if(!lstOfAccounts.IsEmpty()){
                for(Account accObj : lstOfAccounts){
                    AccountWrapper accountObj = New AccountWrapper();
                    // parse match application or policy
                    accountObj.accountObject = accObj ;
                    for(Policy__c plc : accObj.Policies__r){
                        if(plc.recordtype.Name == 'Application' && String.IsBlank(accountObj.ltstApplicationObject.Id)){
                            accountObj.ltstApplicationObject = plc;
                        }else if(plc.recordtype.Name == 'Policy' && String.IsBlank(accountObj.ltstPolicyObject.Id)){
                            accountObj.ltstPolicyObject = plc;
                        }
                    }
                    searchAccounts.add(accountObj );
                }
            }
        }else{
            searchAccounts = New List<AccountWrapper>();
        }
    }
    
    public class AccountWrapper{
        public Account accountObject {get;set;}
        public Policy__c ltstPolicyObject {get;set;}
        public Policy__c ltstApplicationObject {get;set;}
        
        public AccountWrapper(){
            accountObject = New Account();
            ltstPolicyObject = New Policy__c ();
            ltstApplicationObject = New Policy__c ();
        }
    }
}