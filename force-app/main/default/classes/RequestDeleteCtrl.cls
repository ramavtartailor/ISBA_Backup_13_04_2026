public with sharing class RequestDeleteCtrl {
    @AuraEnabled
    public static Boolean CreateDeleteRequest(Id recId, String reason){
        try {
            String objName = recId.getSObjectType().getDescribe().getName();
            Sobject obj = Database.Query('SELECT Id, Name FROM '+objName+' WHERE Id =: recId LIMIT 1'); 
            
            //User u = [SELECT Id FROM User WHERE Name = 'Omar Uddin' LIMIT 1];
            
            Account acc = [SELECT Id,(SELECT Id, Name FROM Contacts WHERE Name =: UserInfo.getName()) FROM Account WHERE Name='ISBA Mutual Insurance Company' LIMIT 1];
                        
            
            Case c = new Case();
            c.Type = 'Delete Request';
            c.Origin = 'Web';
            //c.OwnerId = u.Id;
            c.Delete_Reason__c = reason;
            c.Record_Id__c = String.valueOf(obj.get('Id'));
            c.Record_Name__c = String.valueOf(obj.get('Name'));
            c.Object_Name__c = objName;
            c.Subject = 'Request Delete '+ objName +': '+ c.Record_Name__c;
            if(!acc.Contacts.isEmpty()){
                c.ContactId = acc.Contacts[0].Id;
            }
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            dmo.EmailHeader.triggerUserEmail = true;
            Database.insert(c, dmo);
            
            if(objName == 'Customer_Application__c'){
                obj.put('Status_Description__c', 'Request Delete: '+reason);
            }
            
            obj.put('Delete_Requested_Date__c',system.today());
            obj.put('Delete_Requested_By__c',UserInfo.GetUserId());
            obj.put('Delete_Reason__c',reason);
            obj.put('Case_Record__c',c.Id);
            Update obj;
            
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}