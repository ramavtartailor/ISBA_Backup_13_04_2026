public class CloseApplicationCtrl{
    public class CloseApplicationCtrlException extends Exception{
    }
    
    @AuraEnabled
    public static List<String> getPickListVal(String strObjectName, String recId, String strPicklistField){
        try{
            List<String> pickListValuesList = new List<String>();
            Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
            Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
            Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
            
            List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
            
            for (Schema.PicklistEntry objPickList : lstPickListValues){
                pickListValuesList.add(objPickList.getValue());
            }
            
            return pickListValuesList;
            
        } catch (Exception e){
            throw new CloseApplicationCtrlException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean save(String recId, String closeReason, String closeDescription){
        try{
            Customer_Application__c app = [SELECT Id, Account__c, Contact__c, Account__r.Recent_Application_Lookup__c, Account__r.Recent_Policy_Lookup__r.Active__c, Account__r.Recent_Policy_Lookup__c, Effective_Date_Requested__c, 
                                           (SELECT Id, Contact__c FROM Customer_Application_Lawyers__r)
                                           FROM Customer_Application__c 
                                           WHERE Id = :recId
                                           LIMIT 1];
            
            if (app.Account__c == null){
                throw new CloseApplicationCtrlException('Account not linked.');
            }
            
            if (app.Contact__c == null){
                throw new CloseApplicationCtrlException('Contact not linked.');
            }
            Set<Id> contactIds = new Set<Id>();
            if(app.Contact__c != null){
                contactIds.add(app.Contact__c);
            }
            
            
            Boolean flag = false;
            for (Customer_Application_Lawyer__c lw : app.Customer_Application_Lawyers__r){
                
                if (!String.isNotBlank(lw.Contact__c)){
                    
                    flag = true;
                }else{
                    contactIds.add(lw.Contact__c);
                }
                
            }
            
            if (flag){
                throw new CloseApplicationCtrlException('Lawyer(s) not linked.');
            }
            
            
            /*if ((app.Account__r.Recent_Application_Lookup__c != null) || (app.Account__r.Recent_Policy_Lookup__c != null && app.Account__r.Recent_Policy_Lookup__r.Active__c == true)){
                throw new CloseApplicationCtrlException('Account has existing application or policy');
            }*/
            
            app.Id = recId;
            app.Close_Reason__c = closeReason;
            app.Close_Description__c = closeDescription;
            app.Application_Status__c = 'Closed';
            update app;
            
            List<AccountContactRelation> queryAccountContactRelation = [Select Id,ContactId,AccountId from AccountContactRelation where AccountId =: app.Account__c];
            
            Map<Id, AccountContactRelation> junctionMap = new Map<Id, AccountContactRelation>();
            
            for(AccountContactRelation acr : queryAccountContactRelation){
                junctionMap.put(acr.ContactId, acr);
            }
            List<AccountContactRelation> accountContactList = new List<AccountContactRelation>();
            
            for(Id conId : contactIds){
                if(!junctionMap.containsKey(conId)){
                    
                    AccountContactRelation acr = new AccountContactRelation();
                    acr.AccountId = app.Account__c;
                    acr.ContactId = conId;
                    
                    accountContactList.add(acr);
                }
            }
            
            if(!accountContactList.isEmpty()){
                insert accountContactList;
            }
            
            Account acc = new Account();
            acc.Id = app.Account__c;
            acc.Ex_Date__c = String.valueOf(app.Effective_Date_Requested__c);
            update acc;
            
            List<Note__c> notes = new List<Note__c>([SELECT Id
                                                     FROM Note__c
                                                     WHERE Customer_Application__c = :recId]);
            
            if (!notes.isEmpty()){
                for (Note__c n : notes){
                    n.Account__c = app.Account__c;
                }
                Update notes;
            }
            
            
        } catch (DmlException e){
            System.debug('Error => '+e.getDmlMessage(0)+'\n At => '+e.getLineNumber());
            throw new CloseApplicationCtrlException(e.getDmlMessage(0));
        } catch (Exception e){
            System.debug('Error => '+e.getMessage()+'\n At => '+e.getLineNumber());
            throw new CloseApplicationCtrlException(e.getMessage());
        }
        return true;
    }
    
}