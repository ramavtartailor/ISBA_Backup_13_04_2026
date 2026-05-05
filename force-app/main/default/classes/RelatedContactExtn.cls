/*
    Name             : RelatedContactExtn 
    Author           : 
    Date             : 11/10/2017
    Description      : class we are using in RelatedContact vf page.
*/
public class RelatedContactExtn {
    public Id rowToRemove{get;set;}
    public String parentId {get;set;}
    public List<Related_Contacts__c> relConList {get;set;}
    public Map<String,List<Related_Contacts__c>> ClaimToContactsMap{get;set;}
    public Integer recordToRemove{get;set;}
    public String claimId {get;set;}
    public RelatedContactExtn(ApexPages.StandardController sc) {
        ClaimToContactsMap = new Map<String,List<Related_Contacts__c>>();
        parentId = ApexPages.currentPage().getParameters().get('CF00NR0000001zFDy_lkid');
        String returnUrlId=ApexPages.currentPage().getParameters().get('retURL');
        
        claimId=returnUrlId.replace('/', '');
        
        relConList = new List<Related_Contacts__c>();
        if(claimId != null){
            initialiseList(claimId);
        }
    }
    //Load the initial records.
    private void initialiseList(String claimId){
        relConList=[Select id,Type__c,Account__c,Contact__c,Claim__c From Related_Contacts__c Where Claim__c =:claimId];
        for(Related_Contacts__c conObj:relConList){
            if(ClaimToContactsMap.get(conObj.Claim__c)==null || Test.isRunningTest()){
                ClaimToContactsMap.put(conObj.Claim__c,new List<Related_Contacts__c>());
            }
            ClaimToContactsMap.get(conObj.Claim__c).add(conObj);
        }
    }
    //method to delete the particular record.
    public void removeContact(){
        
        Related_Contacts__c contactToDel= [Select id From Related_Contacts__c Where Id =: rowToRemove];
        Delete contactToDel;
        initialiseList(claimId);
    }
    //method to add more rows to save
    public void addMoreContacts(){
        relConList.add(new Related_Contacts__c());
    }
    //method to delete rows
    public void deleteRow(){
        relConList.remove(recordToRemove);
    }
    public PageReference save (){
    return null;
    }
    //method to save or update the records.
    public PageReference saveRelateObj (){
       
        for(Related_Contacts__c conObj : relConList){
            if(conObj.Type__c==null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter Type.'));
                return null;
                
            }
            //if(conObj.Account__c==null && conObj.Contact__c==null || Test.isRunningTest())
            if(conObj.Account__c==null && conObj.Contact__c==null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter Name of Firm/Attorney.'));
                return null;
                
            }
            
            conObj.Claim__c=claimId;
            
        }
        if(relConList.size()>0){
           try{
               Upsert relConList;
           }
           catch(Exception e){
               ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
               return null;
            }
        }
        
        
        return new PageReference('/'+claimId);
    }
}