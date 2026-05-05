/*
* Created Date    : 12/07/2022
* Description     : This Batch is Scheduled every day to collect the history data from History objects to custom history objects as
assigned in custom meta data 'History Object Settings'
eg : ContactHistory to Custom_Contact_History__c.
This batch should be scheduled through Apex scheduler.
* Test Class Name : Batch_TransferHistoryRecordsTest
*
___________________________________________________________________________Change Log_____________________________________________________________________
Modifiedby              Case-Log        Version         Change Date         Description

__________________________________________________________________________________________________________________________________________________________

*/
public class Batch_TransferHistoryRecords implements Schedulable, Database.Batchable<sObject>, Database.Stateful{
    //List to capture failed records
    List<String> failedRecords = new List<String>();
    //List to fetch the Metadata values
    List<History_Transfer_Object_Settings__mdt > getHistoryMappingList = new List<History_Transfer_Object_Settings__mdt >(); 
    //To fetch the Custom History Object name eg: Custom_Account_History__c
    String custHistoryObjName = Null;
    //To fetch the last Sync Date
    DateTime LastSyncdate = Null;
    //To fetch the lookup field created on custom history object for an object eg: Contact__c. 
    String relationshipFieldName = Null;
    //To fetch the History object parent field eg:ContactId in contactHistory object and AccountId in AccountHistory object.
    String HistObjectParentField = Null;
    //To fetch the current date
    DateTime SyncDateandTime;
    //Set to Fetch the Object Name
    Set<String>objectNameSet = new Set<String>();
    public Batch_TransferHistoryRecords(){
        SyncDateandTime = System.now();
        //this Query will fetch the metadate settings where last synced date is not equal to today.
        getHistoryMappingList = [Select Id,MasterLabel,DeveloperName,Custom_History_Object_Name__c,History_Object_Name__c,History_Object_Parent_Field__c,Last_Sync_DateTime__c,Relationship_Field__c From History_Transfer_Object_Settings__mdt ];
        for (History_Transfer_Object_Settings__mdt  sob : getHistoryMappingList) objectNameSet.add((String) sob.History_Object_Name__c);
        if(!getHistoryMappingList.isEmpty()){
            LastSyncdate = getHistoryMappingList[0].Last_Sync_DateTime__c;
            custHistoryObjName = getHistoryMappingList[0].Custom_History_Object_Name__c;
            relationshipFieldName = getHistoryMappingList[0].Relationship_Field__c;
           HistObjectParentField = getHistoryMappingList[0].History_Object_Parent_Field__c;
        }
    }
    public Batch_TransferHistoryRecords(set<String>fetchSetofObj){
        SyncDateandTime = System.now();
        getHistoryMappingList = [Select Id,MasterLabel,DeveloperName,Custom_History_Object_Name__c,History_Object_Name__c,History_Object_Parent_Field__c,Last_Sync_DateTime__c,Relationship_Field__c From History_Transfer_Object_Settings__mdt  Where History_Object_Name__c IN:fetchSetofObj];
        for (History_Transfer_Object_Settings__mdt  sob : getHistoryMappingList) objectNameSet.add((String) sob.History_Object_Name__c);
        if(!getHistoryMappingList.isEmpty()) {
            LastSyncdate = getHistoryMappingList[0].Last_Sync_DateTime__c;
            custHistoryObjName = getHistoryMappingList[0].Custom_History_Object_Name__c;
            relationshipFieldName = getHistoryMappingList[0].Relationship_Field__c;
            HistObjectParentField = getHistoryMappingList[0].History_Object_Parent_Field__c;
        }
    }
    public void execute(SchedulableContext sc){
        Batch_TransferHistoryRecords obj_EmailQueue = new Batch_TransferHistoryRecords();
        Database.executeBatch(obj_EmailQueue,200);
    } 
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = Null;
        DateTime currentDateTime = system.now();
        //To check the Metadata list is not empty
        if(!getHistoryMappingList.isEmpty()){
            //if the custom metadata has a LastSyncDate then it fetches the history records that are created from LastSyncdate to currentdate.
            if(LastSyncdate!= Null){
                query = 'SELECT Id, '+getHistoryMappingList[0].History_Object_Parent_Field__c+', CreatedById, CreatedDate, Field, DataType, OldValue, NewValue FROM '+getHistoryMappingList[0].History_Object_Name__c+' WHERE CreatedDate>=:LastSyncdate AND CreatedDate<:SyncDateandTime';
            }
            //if the custom metadata LastSyncDate is null then it fetches all the history records
            //This Run for the first time when this batch is deployed and executed.
            else{
                query = 'SELECT Id, '+getHistoryMappingList[0].History_Object_Parent_Field__c+', CreatedById, CreatedDate, Field, DataType, OldValue, NewValue FROM '+getHistoryMappingList[0].History_Object_Name__c;
            }
        }
        
        return Database.getQueryLocator(query);
        
    }
    public void execute(Database.BatchableContext BC, List<sObject> histObjList){
        try{
            //List to insert History records to custom history record object
            List<sObject> insertCustomHistList = new List<sobject>();
            
            for(sObject obj: histObjList){
                //Type casting string to objectName where eg: 'custHistoryObjName' - Custom_Account_History__c.
                sObject genericObject = Schema.getGlobalDescribe().get(custHistoryObjName).newSObject();
                genericObject.put('Data_Type__c',obj.get('DataType'));
                genericObject.put('Field__c',obj.get('Field'));
                genericObject.put('New_Value__c',obj.get('NewValue'));
                genericObject.put('Old_Value__c',obj.get('OldValue'));
                // To Map the Parent record to lookup field created on custom object
                // eg Account__c - AccountId in (Account history object)
                genericObject.put(relationshipFieldName,obj.get(HistObjectParentField));
                genericObject.put('Created_By__c',obj.get('CreatedById'));
                genericObject.put('Created_Date__c',obj.get('CreatedDate'));
                insertCustomHistList.add(genericObject);
            }
            if(!insertCustomHistList.isEmpty()){
                Database.SaveResult[] custHistList= Database.insert(insertCustomHistList, false);
                for(Integer i=0; i < insertCustomHistList.size(); i++){
                    // Iterate through each returned result
                    Database.SaveResult result = custHistList[i];
                    if (!result.isSuccess()) {
                        for(Database.Error err : result.getErrors()){
                            //failedRecords.add(String.valueOf(insertCustomHistList[i]));
                            
                        }
                    }
                }
            }
        }
        catch(Exception e){
            System.debug('Error occured on CustomHistoryObjectBatch '+e.getMessage());
        }
    }
    public void finish(Database.BatchableContext BC){
        if(!getHistoryMappingList.isEmpty()){
            //To update the metadate records 'last sync date' field to current date after batch is processed.
            Metadata.CustomMetadata metadaterec = new Metadata.CustomMetadata();
            metadaterec.fullname = 'Custom_meta_data__mdt.'+getHistoryMappingList[0].DeveloperName;
            metadaterec.label = getHistoryMappingList[0].MasterLabel;
            Metadata.CustomMetadataValue metadaterecvalue = new Metadata.CustomMetadataValue();
            metadaterecvalue.field = 'Last_Sync_DateTime__c';
            metadaterecvalue.value = SyncDateandTime;
            metadaterec.values.add(metadaterecvalue);
            Metadata.DeployContainer mdcontainer = new Metadata.DeployContainer();
            mdcontainer.addMetadata(metadaterec);
            if(!Test.isRunningTest()){
                Metadata.Operations.enqueueDeployment(mdcontainer, Null);
            }
            //To query the next set of records on metadate after updating the date.
            //List<Custom_meta_data__mdt> fetchObjList = [Select Id From Custom_meta_data__mdt Where Last_Sync_Date__c !=:todayDate ];
            //Cron scheduled to run the batch in recursive for next metadate record
            //eg: after processing the contact object next it schedules that batch to process Account object
            //This batches are scheduled in an interval of 15 Sec.
            objectNameSet.remove(getHistoryMappingList[0].History_Object_Name__c);
            if(!objectNameSet.isEmpty()){
                Batch_TransferHistoryRecords obj = new Batch_TransferHistoryRecords(objectNameSet);
                Database.executeBatch(obj);  
            }
        }  
    }
}