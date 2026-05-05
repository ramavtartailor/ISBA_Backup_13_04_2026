public class UpdateBucketCtrl {
    public class UpdateBucketCtrlException extends Exception{}
    
    @AuraEnabled
    public static Contact getContact(String recId){        
        Contact con= [SELECT Id,Account.Name,ISBAM_Quick_Note__c,ISBAM_Rating_Last_Update__c,ISBAM_Rating__c FROM Contact WHERE Id =: recId LIMIT 1];
        return con;
    }
    
    @AuraEnabled
    public static Boolean updateRecord(Contact rec, String accName){
        try{
            List<Account> accLis = [SELECT Id FROM Account WHERE Name=: accName LIMIT 1];
            Contact con = [SELECT Id,ISBAM_Rating__c, ISBAM_Quick_Note__c, AccountId,(Select Id from AccountContactRelations where Account.Name LIKE 'ISBAM BUCKET%') FROM Contact WHERE Id =: rec.Id LIMIT 1];

            if(accLis.isEmpty()){
                throw new UpdateBucketCtrlException('The Account named "'+accName+'" was not found.');
            }            
            
            if(con.ISBAM_Rating__c != rec.ISBAM_Rating__c || con.ISBAM_Quick_Note__c != rec.ISBAM_Quick_Note__c || con.AccountId != accLis[0].Id){
                rec.ISBAM_Rating_Last_Update__c = system.today();//.addDays(-1);
                
                if(con.AccountId != accLis[0].Id){
                    rec.AccountId = accLis[0].Id;                    
                }
                Update rec; 
                
                if(con.AccountId != accLis[0].Id && !con.AccountContactRelations.isEmpty()){
                    Delete con.AccountContactRelations;
                }
                
            }
            
            
        }
        catch(Exception e){
            throw new UpdateBucketCtrlException(e.getMessage());
        }
        return true;
    }
    
}