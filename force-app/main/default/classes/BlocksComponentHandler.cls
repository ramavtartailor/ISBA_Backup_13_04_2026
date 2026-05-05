public class BlocksComponentHandler {
    @AuraEnabled
    public static BlockDataTableWrapper getBlocks(String recordId, Decimal pageNumber, Decimal pageSize, String sortField, boolean isAsc){
        Integer pSize = (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;
         system.debug('isAsc'+isAsc);
        //Offset for SOQL
        Integer offset = (pNumber - 1) * pSize;
         
        //Total Records
        Integer totalRecords = 0;
        Integer recordEnd = pSize * pNumber;
        
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
 		system.debug('sortType'+sortType);
        //Instance of Contact DataTable Wrapper Class
        BlockDataTableWrapper objDT =  new BlockDataTableWrapper();  
        objDT.pageSize = pSize;
        objDT.pageNumber = pNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        
        
        String objName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        
        String ssOQL;
        String ssOQL1;
        if(objName == 'Account'){
            List<Policy__C> lstPolicies = [select id,Account__c from Policy__c where Account__C=:recordId ];
            ssOQL = 'select id,Name,Status__C,Subject__c,Description__C,CreatedDate,Created_By_Name__c from Application_Block__c where Account__c=:recordId OR Application_Policy__c in : lstPolicies ORDER BY ' + orderByField + ' ' + sortType + ' LIMIT :pSize OFFSET :offset';
            objDT.blockList = Database.query(ssOQL);
            system.debug('objDT.BlockList'+objDT.BlockList);
            totalRecords = [select Count() from Application_Block__c where Account__c=:recordId OR Application_Policy__c in : lstPolicies];
            objDT.totalRecords = totalRecords;
            objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
            return objDT;
        }else if(objName == 'Policy__c'){
            List<Policy__C> lstPolicies = [select id,Account__c from Policy__c where Id=:recordId ];
            Id accountId = lstPolicies[0].Account__C;
            if(lstPolicies.size()>0 && lstPolicies[0].Account__C!=null){
                lstPolicies = [select id,Account__c from Policy__c where Account__C=:lstPolicies[0].Account__C ];
                ssOQL1 = 'select id,Name,Status__C,Subject__c,Description__C,CreatedDate,Created_By_Name__c from Application_Block__c where Account__c=: accountId OR Application_Policy__c in : lstPolicies ORDER BY ' + orderByField + ' ' + sortType + ' LIMIT :pSize OFFSET :offset';
                objDT.blockList = Database.query(ssOQL1);
                totalRecords = [select Count() from Application_Block__c where Account__c=:lstPolicies[0].Account__C OR Application_Policy__c in : lstPolicies];
                objDT.totalRecords = totalRecords;
                objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
                return objDT;
            }else{
                objDT.blockList = new List<Application_Block__c>();
                return objDT;
            }
        }else{
            objDT.blockList = new List<Application_Block__c>();
            return objDT;
        }
    }
    @AuraEnabled
    public static Id getRecordTypeId(String recordId){
        String objName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        if(objName == 'Account'){
            return Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        }else if(objName == 'Policy__c'){
            return Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Application/Policy').getRecordTypeId();
        }else{
            return Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        }
    }
    @AuraEnabled
    public static String changeStatusMethod(String recordId){
        system.debug('recordId'+recordId);
        if(String.isNotBlank(recordId) && recordId != null){
            Application_Block__c blockRecord = [SELECT Id, Name, Status__c FROM Application_Block__c WHERE Id =: recordId];
            if(blockRecord != NULL){
                if(blockRecord.Status__c == 'Active'){
                    blockRecord.Status__c = 'Disabled';
                        }else{
                            blockRecord.Status__c = 'Active';
                        }
                update blockRecord;
            }
        }
        return null;
    }
    @AuraEnabled
    public static Application_Block__c getRecord(){
        Application_Block__c objBlocks = new Application_Block__c();
        objBlocks.Status__c = 'Active';
        return objBlocks;
    } 
    
    @AuraEnabled
    Public Static String saveBlocks(String recordId, Application_Block__c objBlocks){
        String objName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        system.debug('recordId'+recordId);
        system.debug('objBlocks'+objBlocks);
        
        if(objName == 'Account'){
            objBlocks.Account__c = recordId;
        }
        else if(objName == 'Policy__c'){
            objBlocks.Application_Policy__c = recordId;  
            objBlocks.Account__c = [select id,Account__c from Policy__c where Id=:recordId ][0].Account__c;
        }
        try{
            insert objBlocks;
        }
        catch(exception ex){
            return ex.getMessage();
        }
        
        return 'Success';
    }
    //Wrapper Class For Block DataTable  
    public class BlockDataTableWrapper {
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public List<Application_Block__c> blockList {get;set;}
    }
}