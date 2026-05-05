public class searchPolicyController{

public Date startExpirDate {get;set;}
public Date endExpirDate {get;set;}
public string renwalIds{get;set;}
public Policy__c policysearch{get;set;}
public Map<Id,Policy__c> newRenewalMap; 

public List<policyWrapper> searchPolicyList{get;set;}

    public searchPolicyController(){
        policysearch = new Policy__c();
        searchPolicyList = New List<policyWrapper>();
        fatchPolicy();
    }
    
    public void fatchPolicy(){
    
        searchPolicyList = New List<policyWrapper>();
        string recordtype = 'Policy';
        
        String query = 'SELECT Id,Name,Account__r.Name,Policy_Renew_Status__c,RecordType.Name,Expiration_Date__c,Application_Type__c,Limit__r.Name,Premium__c '
                       +' FROM Policy__c WHERE RecordType.Name =: recordtype ';
        String Filter = '';
        String strType = policysearch.Application_Type__c;
        
        if(startExpirDate != null){
        
            Filter += ' AND Expiration_Date__c >= :startExpirDate ';
        }
        if(endExpirDate != null){
        
            if(String.IsNotBlank(Filter)){
                
                Filter += 'AND Expiration_Date__c <= :endExpirDate';
            }else{
                
                Filter += ' AND Expiration_Date__c <= :endExpirDate ';
            }
        }
        
        if( strType != null && strType != ''){
            
            Filter += ' AND Application_Type__c = :strType';
        }
        
        if(String.IsNotBlank(Filter)){
            query = query+''+Filter+' LIMIT 1000';
            system.debug('========query========'+query);
            List<Policy__c> lstOfPolicys = database.query(query);
            system.debug('========lstOfPolicys========'+lstOfPolicys);
            set<Id> ids = new set<Id>();
            
            for(Policy__c Obj : lstOfPolicys){
                ids.add(Obj.Id);
            }
                
            newRenewalMap = new Map<Id,Policy__c>(); 
            
            for(Policy__c pol : [SELECT Id,Name,Old_Policy__c FROM Policy__c WHERE Old_Policy__c IN: ids]){
                
                newRenewalMap.put(pol.Old_Policy__c,pol);
                
            }
             
            if(!lstOfPolicys.IsEmpty()){
            
                for(Policy__c Obj : lstOfPolicys){
                    
                    if(newRenewalMap.containsKey(Obj.Id)){
                    
                        Policy__c newPolicy = newRenewalMap.get(Obj.Id);
                        
                        searchPolicyList.add(new policyWrapper(obj,newPolicy));
                    
                    } else {
                        searchPolicyList.add(new policyWrapper(obj,null));                    
                    }
                    
                }
            }
        }else{
            searchPolicyList = New List<policyWrapper>();
        }
    }
    
    public void renewal(){
        
        List<string> ids = new List<string>();
        
        if(renwalIds != null && renwalIds != ''){
            
            for(string str : renwalIds.split(',')){
                ids.add(str);
            }
            
            List<string> result = CloneAndRenewalUtilities.renewMassPolicyManually(ids);
            renwalIds = '';
            fatchPolicy();
        }
        
    }
    
    
    public class policyWrapper{
        //public Boolean isSelected{get;set;}
        public Policy__c policyobj{get;set;}
        public Policy__c newPolicy{get;set;}
        public policyWrapper(Policy__c policy,Policy__c newpolicy){
            
            this.policyobj = policy;
            this.newPolicy = newpolicy;
           // this.isSelected = sel;
        }
    }
}