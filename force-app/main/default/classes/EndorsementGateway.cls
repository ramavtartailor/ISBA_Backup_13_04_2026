/*
 * 
 * Created By     : Ali Zaidi
 * Created Date   : 11/19/2016
 * Purpose        : This class provides finder methods for accessing data in the Endorsement object, and also the helper functions to implement trigger processes.
 * Name           : EndorsementGateway
 * Referenced     : Currently at the time of creation this class is referenced by EndorsementHandler.
 * 
 *  
 */
public without sharing class EndorsementGateway {
    // Auto Populate Name by concatinating the Sub Type and Version.
    public static Void checkEndorsementRecordTypeId (List<SObject> newItems) {
        // Type cast from list of SObject to list of Endorsements.
        Set<Id> setEndorsementIds = (new Map<Id,SObject>(newItems)).keySet();
        // Map to hold record types of policy endorsements.
        Map<String,RecordType> mapOfPolicyEndorsementRecordTypes = new Map<String,RecordType>();
        
        // Fetch all the Policy Endorsement record types to fill the map.
        for (RecordType rt : [SELECT DeveloperName, Id, IsActive, Name, SobjectType FROM RecordType WHERE SobjectType = 'Policy_Endorsement__c' AND IsActive = true ORDER BY Name ASC NULLS FIRST]) {
            mapOfPolicyEndorsementRecordTypes.put(rt.Id, rt);
        }
        
        // Check if the Record Type Id is valid or not.
        for (Endorsement__c newEnd : [SELECT Id, Name, Endorsement_Record_Type_ID__c FROM Endorsement__c WHERE Id IN: setEndorsementIds]) {
            if (!(mapOfPolicyEndorsementRecordTypes.containsKey(newEnd.Endorsement_Record_Type_ID__c))) {
            	newEnd.addError('Invalid Record Type Id.');
            }
        }
    }
    
    public static Void checkEndorsementRecordTypeId (Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {
        // Type case list of new endorsements. 
        List<Endorsement__c> lstEndorsements = (List<Endorsement__c>) newItems.values();
        // Map to hold record types of policy endorsements.
        Map<String,RecordType> mapOfPolicyEndorsementRecordTypes = new Map<String,RecordType>();
        
        // Fetch all the Policy Endorsement record types to fill the map.
        for (RecordType rt : [SELECT DeveloperName, Id, IsActive, Name, SobjectType FROM RecordType WHERE SobjectType = 'Policy_Endorsement__c' AND IsActive = true ORDER BY Name ASC NULLS FIRST]) {
            mapOfPolicyEndorsementRecordTypes.put(rt.Id, rt);
        }
        
        // Check if the Record Type Id has changed.
        for (Endorsement__c masEnd : lstEndorsements) {
            // Type cast old endorsement object to compare values.
            Endorsement__c oldEnd = (Endorsement__c) oldItems.get(masEnd.Id);
            // Compare record type id.
            if (oldEnd.Endorsement_Record_Type_ID__c != masEnd.Endorsement_Record_Type_ID__c) {
                if (!(mapOfPolicyEndorsementRecordTypes.containsKey(masEnd.Endorsement_Record_Type_ID__c))) {
                    masEnd.addError('Invalid Record Type Id.');
                }
            }
        }
    }
}