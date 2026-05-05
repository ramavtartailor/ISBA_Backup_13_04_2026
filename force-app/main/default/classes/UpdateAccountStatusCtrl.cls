public class UpdateAccountStatusCtrl {
    
    public Class UpdateAccountStatusCtrlException extends Exception{}
    
    @AuraEnabled
    public static Account getDetails(String recId){
        try{
            Account acc= [SELECT Id,Name,ISBAM_Quick_Note__c,ISBAM_Rating_Last_Update_Date__c,ISBAM_Rating_Last_Update_By__c,ISBAM_Rating_Last_Update_By__r.Name,ISBAM_Rating__c,OwnerId FROM Account WHERE Id =: recId LIMIT 1];
            return acc;
        }
        catch(Exception e){
            System.debug('Error => '+ e.getMessage()+' At => '+e.getLineNumber());
            throw new UpdateAccountStatusCtrlException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean updateAccount(Account acc, boolean createTask, Task t){
        try{
            acc.ISBAM_Rating_Last_Update_Date__c = system.now();
            acc.ISBAM_Rating_Last_Update_By__c = UserInfo.getUserId();
            
            Update acc;
            
            if(createTask){
                t.OwnerId = UserInfo.getUserId();
                t.WhatId = acc.Id;
                t.ActivityDate = t.ActivityDate != null ? t.ActivityDate : System.today().addMonths(6);
                Insert t;
            }
            
            return true;
        }
        catch(DmlException e){
            System.debug('Error => '+ e.getDmlMessage(0)+' At => '+e.getLineNumber());
            throw new UpdateAccountStatusCtrlException(e.getDmlMessage(0));
        }
        catch(Exception e){
            System.debug('Error => '+ e.getMessage()+' At => '+e.getLineNumber());
            throw new UpdateAccountStatusCtrlException(e.getMessage());
        }
    }

}