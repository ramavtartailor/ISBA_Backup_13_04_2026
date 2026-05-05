public class UserTrackingHandler {
    public static User_Tracking__c createUserTrackingObject(String eventType,Id recordId,String recordName){
        User_Tracking__c userTrack = new User_Tracking__c();
        userTrack.Activity_Time__c = System.now();
        userTrack.Event_Type__c = eventType;
        userTrack.Object_Type__c = recordId.getSObjectType().getDescribe().getName();
        userTrack.Record_Id__c = recordId;
        userTrack.Record_Name__c = recordName;
        userTrack.User__c = UserInfo.getUserId();
        return userTrack;
    }
}