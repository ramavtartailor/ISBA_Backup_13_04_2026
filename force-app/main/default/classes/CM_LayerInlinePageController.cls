public with sharing class CM_LayerInlinePageController {
    
    public string AccountObj{get;set;} 
    public string queryString;
	public string lawyerToDeleteId{get; set;}
    public list<AccountContactJunction__c> layerList{get;set;}

    public CM_LayerInlinePageController(ApexPages.StandardController controller){

        Account accobj = (Account)controller.getRecord();
        AccountObj = accobj.id;
		lawyerToDeleteId = '';
        layerList = new list<AccountContactJunction__c>();

        //public string queryString;
        mycalcel();
    
    }
    
   	public void mycalcel(){
   		queryString = 'select ';
        
        for(Schema.FieldSetMember fld :SObjectType.AccountContactJunction__c.FieldSets.VfFieldSet.getFields()) {
            queryString += fld.getFieldPath() + ',' ;
        }
        if(queryString.contains('id')){
            queryString = queryString .substring(0, queryString .length()-1);
            queryString += ' from AccountContactJunction__c where Account__c =:AccountObj';
        }else{
            queryString += 'id';
            queryString += ' from AccountContactJunction__c where Account__c =:AccountObj';
        
        }
        layerList = Database.query(queryString);
   	}
    
    public void onsave(){
        update layerList;
    }
    public void deleteLawyer(){
        list<AccountContactJunction__c> tempList = new list<AccountContactJunction__c>();
        if(lawyerToDeleteId != null && lawyerToDeleteId != ''){
            tempList = [select id from AccountContactJunction__c where id=:lawyerToDeleteId];
        }
        
        if(!tempList.isEmpty()){
            delete tempList;
            lawyerToDeleteId = '';
            
        }
    }
}