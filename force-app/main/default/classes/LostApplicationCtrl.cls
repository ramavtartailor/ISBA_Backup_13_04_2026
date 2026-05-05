public class LostApplicationCtrl {
    
    public class LostApplicationCtrlException extends Exception {}
    
    @AuraEnabled
    public static List<String> getPickListVal(String strObjectName,String recId, String strPicklistField){
        try{
            Policy__c policyRec = new Policy__c();
            if(recId != null &&  recId != ''){
                policyRec = [Select id,Application_Type__c  from Policy__c where id=:recId   limit 1];

            }
            List<String> pickListValuesList= new List<String>();
            Map<String, String> mapPickListValues = new Map<String, String>();
            Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
            Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
            Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
            List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
            for (Schema.PicklistEntry objPickList : lstPickListValues) {
                if(strPicklistField=='Lost_Reason__c' && (objPickList.getValue() =='Prospective Practice' || objPickList.getValue() == 'Online Inquiry Only' ) ){
                    if(policyRec != null && policyRec.Application_Type__c=='New Business'){
                        pickListValuesList.add(objPickList.getValue());

                    }
                }
                else{
                    pickListValuesList.add(objPickList.getValue());

                }
                    System.debug('Value = ' +objPickList.getValue() +' , Label = ' +objPickList.getLabel());
            
            }
            return pickListValuesList;
        }
        catch(exception e){
            throw new LostApplicationCtrlException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Wrapper> getPickListSubs(String selectedValue){
        try{
            List<Wrapper> WrapList = new List<Wrapper>();
            Map<String,List<Lost_Application_Config__mdt>> dataMap = new Map<String, List<Lost_Application_Config__mdt>>();
            
            for(Lost_Application_Config__mdt mtd : [SELECT Lost_Reason__c,Description_Required__c,Lost_Reason_Sub1__c, Lost_Reason_Sub2__c, Placeholder__c FROM Lost_Application_Config__mdt WHERE Lost_Reason__c =: selectedValue]){
                List<Lost_Application_Config__mdt> temp = new List<Lost_Application_Config__mdt>();
                if(dataMap.ContainsKey(mtd.Lost_Reason_Sub1__c)){
                    temp = dataMap.get(mtd.Lost_Reason_Sub1__c);
                }
                temp.add(mtd);
                dataMap.put(mtd.Lost_Reason_Sub1__c, temp);
            }
            
            for(String key : dataMap.keySet()){
                Wrapper wrap = new Wrapper();
                wrap.val = key;
                if(dataMap.get(key).size() == 1 && !String.isNotBlank(key)){
                    wrap.isDesRequired = dataMap.get(key)[0].Description_Required__c;
                    wrap.placeholder = dataMap.get(key)[0].Placeholder__c;
                }
                else{
                    wrap.listValues = dataMap.get(key);
                }
                WrapList.add(wrap);
            }
            
            return WrapList;
        }catch(exception e){
            throw new LostApplicationCtrlException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean save(String recId, String lostReason, String lostReasonSub1, String lostReasonSub2, String discription){
        try{           
            Policy__c p = new Policy__c();
            p.Id = recId;
            p.Lost_Description__c = discription;
            p.Lost_Reason__c = lostReason;
            p.Lost_Reason_Sub1__c = lostReasonSub1;
            p.Lost_Reason_Sub2__c = lostReasonSub2;
            p.Is_Rejected_Confirm__c = true;
            p.Status__c = 'Rejected';
            system.debug(p);
            Update p;
        }
        catch(DmlException e){
            throw new LostApplicationCtrlException(e.getDMLMessage(0));
        }
        catch(exception e){
            throw new LostApplicationCtrlException(e.getMessage());
        }
        return true;
    }
    
    public Class Wrapper{
        @AuraEnabled
        public String val{get;set;}
        @AuraEnabled
        public Boolean isDesRequired{get;set;}
        @AuraEnabled
        public String placeholder{get;set;}
        @AuraEnabled
        public List<Lost_Application_Config__mdt> listValues {get;set;} 
        
        public Wrapper(){
            isDesRequired = false;
            placeholder = null;
        }
    }
    
}