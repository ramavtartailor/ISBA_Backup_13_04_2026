trigger CM_contactTrigger on Contact (after insert, after update) {
    
    list<AccountContactJunction__c> lawyerListToInsert = new list<AccountContactJunction__c>();
    Map<id,String> conUpdateMap = new Map<Id,String>();
    set<Id> conids = new set<Id>();
    Map<Id,Id> conCheckLawyerMap = new Map<Id,Id>();
    
    for(contact con : trigger.new){
        
        if(con.Type__c != null && con.Type__c == 'Lawyer'){
            
            if(trigger.isUpdate && con.Type__c != null && con.Type__c == 'Lawyer' && trigger.oldmap.get(con.Id).type__c != 'Lawyer'){
            
                conids.add(con.id);
            
            }            
            
        }
    }
    
    for(AccountContactJunction__c obj : [SELECT Id,Contact__c  FROM AccountContactJunction__c WHERE Contact__c IN: conids ]){
        
        conCheckLawyerMap.put(obj.Contact__c,obj.Contact__c);
    
    }
    
    
    for(contact con : trigger.new){
        if(con.Type__c != null && con.Type__c == 'Lawyer'){
            if(trigger.isInsert){
                AccountContactJunction__c lawyer = new AccountContactJunction__c();
                lawyer.Name = con.Name;
                lawyer.Account__c = con.AccountId;
                lawyer.Contact__c = con.Id;
                lawyerListToInsert.add(lawyer);
            }else if(trigger.isUpdate && con.Type__c != null && con.Type__c == 'Lawyer' && trigger.oldmap.get(con.Id).type__c != 'Lawyer'){
                
                if(!conCheckLawyerMap.containsKey(con.Id)){
                    AccountContactJunction__c lawyer = new AccountContactJunction__c();
                    lawyer.Name = con.Name;
                    lawyer.Account__c = con.AccountId;
                    lawyer.Contact__c = con.Id;
                    lawyerListToInsert.add(lawyer);
                }
                
            }
            
            if(trigger.isUpdate && (con.FirstName != trigger.oldmap.get(con.Id).FirstName || con.LastName != trigger.oldmap.get(con.Id).LastName )){
                string name = con.FirstName != null ?con.FirstName:'';
                name = name+' '+con.LastName;
                conUpdateMap.put(con.id,name );
            }
            
        }
    }
    
    List<AccountContactJunction__c> accList = [SELECT Id,Contact__c FROM AccountContactJunction__c WHERE Contact__c IN: conUpdateMap.keyset()];
    
    for(AccountContactJunction__c obj : accList){
        
        if(conUpdateMap.containsKey(obj.Contact__c)){
            obj.Name = conUpdateMap.get(obj.Contact__c);
        }
    }
    
    if(!accList.isEmpty()){
        upsert accList;
    }
    
    if(lawyerListToInsert != null && !lawyerListToInsert.isEmpty()){
    
        insert lawyerListToInsert;
    }
}