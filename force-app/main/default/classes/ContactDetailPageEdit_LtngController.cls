/*
Name : ContactDetailPageEdit_LtngController
Auther : 
Date : 20 April 2017
Description : this lightning page of clone account detail page
*/
public class ContactDetailPageEdit_LtngController{
    public Contact contactRecord {get;set;}
    public String returnURL{get;set;}
    public String error{get;set;}
    
    public ContactDetailPageEdit_LtngController(ApexPages.StandardController stdController) {
        System.debug('Parameters'+ApexPages.currentPage().getParameters());
        for(String str : ApexPages.currentPage().getParameters().keySet()){
            System.debug('1=='+str);
        }
        for(String str : ApexPages.currentPage().getParameters().values()){
            System.debug('2=='+str);
        }
        this.contactRecord = (Contact)stdController.getRecord();
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        if(retURL == null && contactRecord.Id!=null){
            returnURL = '/'+contactRecord.Id;
        }else if(retURL != null){
            returnURL = retURL;
        }else{
            returnURL = ApexPages.currentPage().getHeaders().get('Referer');
        }
    }
    
    public pagereference saveContactRecord(){
        try{
            Id accountId;
            Boolean boo = false;
            if(contactRecord.Id == null){
                contactRecord.AccountId = [select id from account where name =: Label.Bucket_Account limit 1].id;
                boo = true;
            }
            upsert contactRecord ;
            if(boo){
                AccountContactRelation acr = new AccountContactRelation(ContactId=contactRecord.Id,AccountId=accountId );
                insert acr;
            }
            
            error = '';
            return new pagereference(returnURL );
            
        } catch(Exception ex){
            ApexPages.addMessages(ex);
            
        }
        
        return null;
        
    }
    
    @RemoteAction
    public static List<sObject> getLookupRecord(String likeString , String objectName) {
        if(String.IsNotBlank(likeString) && String.IsNotBlank(objectName)){
            likeString = '%'+likeString+'%';
            String query = '';
            
            query = 'SELECT Id, Name FROM '+objectName+' WHERE Name LIKE : likeString LIMIT 50';
            return database.query(query);
        }
        return null;
    }
}