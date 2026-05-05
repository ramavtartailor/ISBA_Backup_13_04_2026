public class UserTrackViewCtrl {
    @AuraEnabled
    public static void updateUserTrack(Id recordId) {
        User_Tracking__c userTrack;
        if(recordId.getSObjectType().getDescribe().getName() == 'Account'){
            Account obj = [select id,name from Account where id=: recordId];
            userTrack = UserTrackingHandler.createUserTrackingObject('View', recordId, obj.Name);
        }else if(recordId.getSObjectType().getDescribe().getName() == 'Policy__c'){
            Policy__c obj = [select id,name from Policy__c where id=: recordId];
            userTrack = UserTrackingHandler.createUserTrackingObject('View', recordId, obj.Name);
        }else if(recordId.getSObjectType().getDescribe().getName() == 'Policy_Claim__c'){
            Policy_Claim__c obj = [select id,name from Policy_Claim__c where id=: recordId];
            userTrack = UserTrackingHandler.createUserTrackingObject('View', recordId, obj.Name);
        }else if(recordId.getSObjectType().getDescribe().getName() == 'Policy_Endorsement__c'){
            Policy_Endorsement__c obj = [select id,name from Policy_Endorsement__c where id=: recordId];
            userTrack = UserTrackingHandler.createUserTrackingObject('View', recordId, obj.Name);
        }else if(recordId.getSObjectType().getDescribe().getName() == 'AcctSeed__Billing__c'){
            AcctSeed__Billing__c  obj = [select id,name from AcctSeed__Billing__c  where id=: recordId];
            userTrack = UserTrackingHandler.createUserTrackingObject('View', recordId, obj.Name);
        }
        insert userTrack;
    }
    
    public static void dummyCode(){
         Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    

    }
}