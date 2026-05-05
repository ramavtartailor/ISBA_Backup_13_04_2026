public class AccountNotesComponentHandler {
    
    public static boolean boo = true;
    
    @AuraEnabled
    //public static List<Note__c> getNotes(Integer rowLimit,Integer rowOffset,String recordId,String selectedFilterValue){
    public static NotesComponentWrapper getNotes(String sortField,boolean isAsc,String recordId,String selectedFilterValue,Decimal pageNumber, Decimal pageSize,String selectedNoteTypeFilterValue,String objectName, String field_apiname,boolean allRequired){
        System.debug(boo);
        if(boo) boo = false;
        System.debug(boo);
        Integer rowLimit = (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;
        
        Integer rowOffset = (pNumber - 1) * rowLimit;
        
        //
        String userId = userInfo.getUserId();
        
        String orderByField;
        if(sortField == null) {
            orderByField = 'CreatedDate';
        } else {
            orderByField = sortField;
        }       
        
        String sortType = 'DESC' ;
        // if isAsc is equal tp ture then set 'asc' order otherwise set 'desc' order.
        if(isAsc != null) {
            if (isAsc) {
                sortType = 'ASC';
            }else {
                sortType = 'DESC';
            }
        }
        
        System.debug('orderByField-----'+orderByField);
        System.debug('sortType-----'+sortType);
        
        String sSoql = 'Select Id,Name,Type__C,Status__C,Subject__c,Description__C,CreatedDate,Created_By_Name__c,of_Attachments__c,Due_Date__c from Note__C ';
        
        //String sSoqlTask = 'Select Id,Type__c,Subject,Description,WhatId,CreatedDate,CreatedBy.Name from Task '; //Commented on 10/27/20 
        
        String sSoqlBlock = 'Select Id,Created_By_Name__c,CreatedDate,Name,Description__c,Status__c,Subject__c from Application_Block__c ';
        
        String objName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        String noteRecordType = '';
        if(objName == 'Account'){
            List<Policy__C> lstPolicies1 = [select id,Account__c from Policy__c where Account__c =: recordId ];
            sSoql += 'where (Account__c = \''+recordId+ '\' OR Policy__C in: lstPolicies1' + + ') ' ;
            //sSoqlTask += 'where (WhatId = \''+recordId+ '\' OR WhatId in: lstPolicies1' + + ') ' ; //Commented on 10/27/20 
            sSoqlBlock += 'where (Account__c = \''+recordId+ '\' OR Application_Policy__c in: lstPolicies1' + + ') ' ;
            noteRecordType = 'Account';
        }else if(objName == 'Policy__c'){            
            if(selectedFilterValue == 'View This Policy Notes'){
                List<Policy__C> lstPolicies = [select id,Underwriter_User__c, Account__c from Policy__c where Id=:recordId ];//added by Ramavter 20 june 2024
                if(lstPolicies[0].Underwriter_User__c != null){
                    userId = lstPolicies[0].Underwriter_User__c;
                }
                
                sSoql += 'where Policy__c = \''+recordId+ '\'' ;
                //sSoqlTask += 'where WhatId = \''+recordId+ '\'' ; //Commented on 10/27/20 
                sSoqlBlock += 'where Application_Policy__c = \''+recordId+ '\'' ;
                noteRecordType = 'Application_Policy';
            }else{
                List<Policy__C> lstPolicies = [select id,Underwriter_User__c, Account__c from Policy__c where Id=:recordId ];
                if(lstPolicies[0].Underwriter_User__c != null){
                    userId = lstPolicies[0].Underwriter_User__c;
                }
                lstPolicies = [select id,Account__c from Policy__c where Account__C=:lstPolicies[0].Account__C ];
                sSoql += 'where (Account__c = \''+lstPolicies[0].Account__C+ '\' OR Policy__C in: lstPolicies' + + ') ' ;
                //sSoqlTask += 'where (WhatId = \''+lstPolicies[0].Account__C+ '\' OR WhatId in: lstPolicies' + + ') ' ; //Commented on 10/27/20 
                sSoqlBlock += 'where (Account__c = \''+lstPolicies[0].Account__C+ '\' OR Application_Policy__c in: lstPolicies' + + ') ' ;
                noteRecordType = 'Claim';
            }
        }else if(objName == 'Policy_Claim__c'){
            sSoql += 'where Claim__c = \''+recordId+ '\'' ;
            //sSoqlTask += 'where WhatId = \''+recordId+ '\'' ; //Commented on 10/27/20 
        }else if(objName == 'AcctSeed__Billing__c'){
            System.debug(objName);
            List<AcctSeed__Billing__c> bill = [select id,AcctSeed__Customer__c  from AcctSeed__Billing__c where Id =: recordId ];
            sSoql += 'where Account__c = \''+bill[0].AcctSeed__Customer__c+ '\'' ;
            //sSoqlTask += 'where WhatId = \''+recordId+ '\'' ; //Commented on 10/27/20 
        }
        else if(objName == 'Customer_Application__c'){
            sSoql += 'where Customer_Application__c = \''+recordId+ '\'' ;
        }
        
        if(selectedNoteTypeFilterValue == 'ALL' || String.isBlank(selectedNoteTypeFilterValue)){
            //sSoql += ' ' + 'order by ' + orderByField + ' ' + sortType + ' ' + 'LIMIT  ' + rowLimit + ' ' + 'OFFSET '+ rowOffset ;
            //List<Note__c> notesList = 	Database.query(sSoql);
            //return notesList;
        }else{
            sSoql += ' AND Type__c = \''+selectedNoteTypeFilterValue+'\'';
            //sSoqlTask += ' AND Type__c = \''+selectedNoteTypeFilterValue+'\''; //Commented on 10/27/20
            //sSoql += ' ' + 'order by ' + orderByField + ' ' + sortType + ' ' + 'LIMIT  ' + rowLimit + ' ' + 'OFFSET '+ rowOffset ;
            //List<Note__c> notesList = 	Database.query(sSoql);
            //return notesList;
        }
        sSoql += ' ' + 'order by ' + orderByField + ' ' + sortType;
        //sSoqlTask += ' ' + 'order by ' + orderByField + ' ' + sortType; //Commented on 10/27/20
        sSoqlBlock += ' ' + 'order by ' + orderByField + ' ' + sortType;
        System.debug(sSoql);
        System.debug(sSoqlBlock);
        List<AccountNotesWrapper> notesWrapper = new List<AccountNotesWrapper>();
        List<Note__c> notesList = new List<Note__c>();
        List<Application_Block__c> blocks = new List<Application_Block__c>();
        notesList = Database.query(sSoql);
        for(Note__c note : notesList){
            notesWrapper.add(new AccountNotesWrapper(note.Name,note.Type__c,note.Subject__c,note.Description__c,note.Id,Date.valueOf(note.CreatedDate),note.Created_By_Name__c,note.of_Attachments__c));
        }
        /*for(Task tsk : Database.query(sSoqlTask)){
            notesWrapper.add(new AccountNotesWrapper(tsk.Subject ,tsk.Type__c,tsk.Subject,tsk.Description,tsk.Id,Date.valueOf(tsk.CreatedDate),tsk.CreatedBy.Name,0));
        }*/ //Commented on 10/27/20
        if(objName == 'Account' || objName == 'Policy__c'){
            for(Application_Block__c block : Database.query(sSoqlBlock)){
                notesWrapper.add(new AccountNotesWrapper(block.Name ,block.Status__c,block.Subject__c,block.Description__c,block.Id,Date.valueOf(block.CreatedDate),block.Created_By_Name__c,0));
            }
        }
        AccountNotesWrapper.sortBy = orderByField;
        AccountNotesWrapper.sortType = sortType;
        notesWrapper.sort();
        List<AccountNotesWrapper> finalNotesWrapper = new List<AccountNotesWrapper>();
        Integer limitTo = notesWrapper.size() < (rowOffset+rowLimit) ? notesWrapper.size() : rowOffset+rowLimit ;
        for(Integer i= rowOffset ; i < limitTo; i++ ){
            finalNotesWrapper.add(notesWrapper[i]);
        }
        NotesComponentWrapper wrapper = new NotesComponentWrapper();
        wrapper.accountNotesWrapper = finalNotesWrapper;
        wrapper.typeOfRecord = getTypeOfRecord(recordId);
        wrapper.numberOfRows = getNotesRowCount(recordId,selectedFilterValue,selectedNoteTypeFilterValue);
        
        if(objectName != null && field_apiname != null){
            wrapper.pickListValues = getPicklistvalues(objectName,field_apiname,allRequired,noteRecordType);
        }
        wrapper.newNote = getRecord();
        if(objName == 'Policy__c'){ 
            wrapper.newNote.Task_Owner__c = userId;
        }
        wrapper.newNoteRecordTypeId = getRecordTypeId(recordId);
        return wrapper;
    }
    @AuraEnabled
    public static Integer getNotesRowCount(String recordId,String selectedFilterValue,String selectedNoteTypeFilterValue){
        String objName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        if(objName == 'Account'){
            List<Policy__C> lstPolicies = [select id,Account__c from Policy__c where Account__C=:recordId ];
            if(selectedNoteTypeFilterValue == 'ALL' || String.isBlank(selectedNoteTypeFilterValue)){
                //return [select count() from Note__C where Account__c=:recordId OR Policy__C in : lstPolicies] + [select count() from Task where WhatId=:recordId OR WhatId in : lstPolicies] + [select count() from Application_Block__c where Account__c=:recordId OR Application_Policy__c in : lstPolicies];
                return [select count() from Note__C where Account__c=:recordId OR Policy__C in : lstPolicies]  + [select count() from Application_Block__c where Account__c=:recordId OR Application_Policy__c in : lstPolicies];
            }else{
                //return [select count() from Note__C where (Account__c=:recordId OR Policy__C in : lstPolicies) AND Type__c =:selectedNoteTypeFilterValue] + [select count() from Task where (WhatId=:recordId OR WhatId in : lstPolicies) AND Type__c =:selectedNoteTypeFilterValue] + [select count() from Application_Block__c where Account__c=:recordId OR Application_Policy__c in : lstPolicies];
                return [select count() from Note__C where (Account__c=:recordId OR Policy__C in : lstPolicies) AND Type__c =:selectedNoteTypeFilterValue] +  [select count() from Application_Block__c where Account__c=:recordId OR Application_Policy__c in : lstPolicies];
            }
            
        }else if(objName == 'Policy__c'){
            if(selectedFilterValue == 'View This Policy Notes'){
                if(selectedNoteTypeFilterValue == 'ALL' || String.isBlank(selectedNoteTypeFilterValue)){
                    //return [select count() from Note__C where Policy__C = : recordId ] + [select count() from Task where WhatId = : recordId ]  + [select count() from Application_Block__c where Application_Policy__c=:recordId];
                    return [select count() from Note__C where Policy__C = : recordId ]  + [select count() from Application_Block__c where Application_Policy__c=:recordId];
                }else{
                    //return [select count() from Note__C where Policy__C = : recordId AND Type__c =:selectedNoteTypeFilterValue] + [select count() from Task where WhatId = : recordId AND Type__c =:selectedNoteTypeFilterValue]   + [select count() from Application_Block__c where Application_Policy__c=:recordId];
                    return [select count() from Note__C where Policy__C = : recordId AND Type__c =:selectedNoteTypeFilterValue]  + [select count() from Application_Block__c where Application_Policy__c=:recordId];
                }
            }else{
                List<Policy__C> lstPolicies = [select id,Account__c from Policy__c where Id=:recordId ];
                lstPolicies = [select id,Account__c from Policy__c where Account__C=:lstPolicies[0].Account__C ];
                if(selectedNoteTypeFilterValue == 'ALL' || String.isBlank(selectedNoteTypeFilterValue)){
                    //return [select count() from Note__C where  Policy__C in : lstPolicies or Account__c=:lstPolicies[0].Account__c] + [select count() from Task where  WhatId in : lstPolicies or WhatId=:lstPolicies[0].Account__c] + [select count() from Application_Block__c where Account__c=:lstPolicies[0].Account__c OR Application_Policy__c in : lstPolicies];
                    return [select count() from Note__C where  Policy__C in : lstPolicies or Account__c=:lstPolicies[0].Account__c]  + [select count() from Application_Block__c where Account__c=:lstPolicies[0].Account__c OR Application_Policy__c in : lstPolicies];
                }else{
                    //return [select count() from Note__C where  (Policy__C in : lstPolicies or Account__c=:lstPolicies[0].Account__c) AND Type__c =:selectedNoteTypeFilterValue] + [select count() from Task where  (WhatId in : lstPolicies or WhatId=:lstPolicies[0].Account__c) AND Type__c =:selectedNoteTypeFilterValue] + [select count() from Application_Block__c where Account__c=:lstPolicies[0].Account__c OR Application_Policy__c in : lstPolicies];
                    return [select count() from Note__C where  (Policy__C in : lstPolicies or Account__c=:lstPolicies[0].Account__c) AND Type__c =:selectedNoteTypeFilterValue]  + [select count() from Application_Block__c where Account__c=:lstPolicies[0].Account__c OR Application_Policy__c in : lstPolicies];
                }
            }
        }else if(objName == 'Policy_Claim__c'){
            if(selectedNoteTypeFilterValue == 'ALL' || String.isBlank(selectedNoteTypeFilterValue)){
                //return [select count() from Note__C where Claim__c=:recordId] + [select count() from Task where WhatId=:recordId];
                return [select count() from Note__C where Claim__c=:recordId];
            }else{
                //return [select count() from Note__C where Claim__c=:recordId AND Type__c =:selectedNoteTypeFilterValue] + [select count() from Task where WhatId=:recordId AND Type__c =:selectedNoteTypeFilterValue];
                return [select count() from Note__C where Claim__c=:recordId AND Type__c =:selectedNoteTypeFilterValue] ;
            }
        }else if(objName == 'AcctSeed__Billing__c'){
            List<AcctSeed__Billing__c> bill = [select id,AcctSeed__Customer__c  from AcctSeed__Billing__c where Id =: recordId ];
            return [select count() from Note__C where Account__c =: bill[0].AcctSeed__Customer__c];
        }
        else if(objName == 'Customer_Application__c'){
            if(selectedNoteTypeFilterValue == 'ALL' || String.isBlank(selectedNoteTypeFilterValue)){
                //return [select count() from Note__C where Claim__c=:recordId] + [select count() from Task where WhatId=:recordId];
                return [select count() from Note__C where Customer_Application__c=:recordId];
            }else{
                //return [select count() from Note__C where Claim__c=:recordId AND Type__c =:selectedNoteTypeFilterValue] + [select count() from Task where WhatId=:recordId AND Type__c =:selectedNoteTypeFilterValue];
                return [select count() from Note__C where Customer_Application__c=:recordId AND Type__c =:selectedNoteTypeFilterValue] ;
            }
        }
        else{
            return 0;
        }
    }
    @AuraEnabled
    public static Id getRecordTypeId(String recordId){
        String objName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        system.debug('objName'+objName);
        if(objName == 'Account'){
            return Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        }else if(objName == 'Policy__c'){
            return Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Application/Policy').getRecordTypeId();
        }else if(objName == 'Policy_Claim__c'){
            return Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
        }else{
            return Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        }
    }
    @AuraEnabled
    public static String getTypeOfRecord(String recordId){
        String objName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        return objName;
    }
    
    @AuraEnabled
    public static Note__c getRecord(){
        Note__c objNotes = new Note__c();
        objnotes.Task_Owner__c = userinfo.getUserId();
        objnotes.Status__c = 'Pending';
        return objNotes;
    } 
    
    @AuraEnabled
    public static String saveNotes(String recordId,Note__c objNotes){
        String objName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        system.debug('objNotes'+objNotes);
      
       if(objName == 'Account'){
            objNotes.Account__c = recordId;
            objNotes.RecordTypeId =  Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        }
        else if(objName == 'Policy__c'){
            objNotes.Policy__c = recordId;  
            objNotes.RecordTypeId =  Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Application/Policy').getRecordTypeId();
        }
        else if(objName == 'Policy_Claim__c'){
            objNotes.Claim__c = recordId;   
            objNotes.RecordTypeId = Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
        }else if(objName == 'AcctSeed__Billing__c'){
            List<AcctSeed__Billing__c> bill = [select id,AcctSeed__Customer__c  from AcctSeed__Billing__c where Id =: recordId ];
            objNotes.Account__c = bill[0].AcctSeed__Customer__c;
            objNotes.RecordTypeId =  Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        }
        else if(objName == 'Customer_Application__c'){
            objNotes.Customer_Application__c = recordId;
            objNotes.RecordTypeId =  Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        }
        
        try{
        insert objNotes;
        }
        catch(exception ex){
            return ex.getMessage();
        }
      
        return 'Success';
    }
    @AuraEnabled
    public static List<String> getPicklistvalues(String objectName, String field_apiname,boolean allRequired,String recordType){
        List<String> optionlist = new List<String>();
        
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap(); 
        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();
        
        if(allRequired == true){
            optionlist.add('ALL');
        }
        
        for (Schema.PicklistEntry pv : picklistValues) {
            optionlist.add(pv.getValue());
        }
        return optionlist;
    }
    
    public class NotesComponentWrapper{
        @AuraEnabled
        public List<AccountNotesWrapper> accountNotesWrapper{get;set;}
        @AuraEnabled
        public String typeOfRecord{get;set;}
        @AuraEnabled
        public Integer numberOfRows{get;set;}
        @AuraEnabled
        public List<String> pickListValues{get;set;}
        @AuraEnabled
        public Note__c newNote{get;set;}
        @AuraEnabled
        public Id newNoteRecordTypeId{get;set;}
    }
}