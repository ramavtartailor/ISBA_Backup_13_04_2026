/*
    Name : App_Policy_DetailPageEdit_LtngCtrl
    Auther : 
    Date : 27 April 2017
    Description : 
*/
global class App_Policy_DetailPageEdit_LtngCtrl{
public Policy__c application_policy {get;set;}
    public Policy__c policyObj {get;set;}
    public Policy_Lawyer__c lawyer {get;set;}
    public boolean isSaErp{get;Set;}
    public String returnURL{get;set;}
    public boolean hasAccount {get;set;}    
    public String error{get;set;}
    public string recordTypeName{get;set;}
    public Date oldEffectiveDate{get;set;}
    public Account acc{get;set;}
    public List<modVarWrap> totalModFields {get; set;}
    public List<modVarWrap> totalModFieldsFM {get; set;}
    public List<modVarWrap> totalModFieldsBO {get; set;}
    public List<modVarWrap> totalModFieldsTraining {get; set;}
    public List<modVarWrap> totalModFieldsGM {get; set;}
    public List<modVarWrap> totalModFieldsOver {get; set;}
    public String recordTypeToUpdate{get;set;}
   
    public Boolean showAdvancedFields{get; set;}
    public App_Policy_DetailPageEdit_LtngCtrl(ApexPages.StandardController stdController) {
          isSaErp = false;
          this.application_policy = (Policy__c)stdController.getRecord();
          
        if(ApexPages.currentPage().getParameters().get('policy')!=null){
            isSaErp = true;
            String policyId = ApexPages.currentPage().getParameters().get('policy');
            String lawyerId = ApexPages.currentPage().getParameters().get('lawyer');
            lawyer = [SELECT Id, Deleted_Date__c, Prior_Act_Date__c FROM Policy_Lawyer__c WHERE Id =: lawyerId LIMIT 1];
            policyObj = [SELECT Id ,Underwriter_User__c,Effective_Date__c, Expiration_Date__c, County__c, Claims_Factor__c, ADJ_MOD__c FROM Policy__c WHERE Id=:policyId LIMIT 1];
        }
          
          acc = new Account();
          if(application_policy.Id == null){
             application_policy.Status__c = 'Application created';
              application_policy.SCH_Mod__c = 1.0;
              String devName = 'Application';
              if(policyObj != null){
                  devName = 'SA_ERP';
                  //application_policy.SA_ERP_Mod__c = 2.5;
              }
              List<RecordType > rtmap = [SELECT id ,Name,DeveloperName from RecordType WHERE SobjectType='Policy__c' and DeveloperName =: devName];
              if(rtmap.size() > 0)
                  recordTypeName = rtmap.get(0).Name;
              if(policyObj != null){
                  application_policy.RecordTypeId = rtmap[0].Id;
              }
          } else {
              /*List<Policy__c> policyList = [SELECT Id,Underwriter_User__c,Effective_Date__c,Sales_User__c FROM Policy__c WHERE Id =:application_policy.Id]; 
              
              if(!policyList.IsEmpty()){
                  
                  application_policy.Underwriter_User__c = policyList[0].Underwriter_User__c;
                  application_policy.Sales_User__c = policyList[0].Sales_User__c;
                    oldEffectiveDate = policyList[0].Effective_Date__c;
              }*/
              
              if(application_policy.Id != null){
                  this.application_policy = getDynamicQuery('Policy__c','Account__r.Name, RecordType.Name,Underwriter_User__r.Name,Sales_User__r.Name,County__r.Name,Limit__r.Name,Deductible_ID__r.Name,Firm_Contact__r.Name', application_policy.Id);
                  oldEffectiveDate = application_policy.Effective_Date__c;
              }
              
              recordTypeToUpdate = application_policy.RecordTypeId;
          }
         if(application_policy.Terms_Conditions__c==null || application_policy.Terms_Conditions__c==''){
            /*application_policy.Terms_Conditions__c ='<ul><li>Executed <b>Quote and Acceptance Form</b> confirming the firm’s limit and deductible selection.</li>' +
                        +'<li>Copy of Firm Letterhead, if not already provided.</li></ul>'; */
        } 
         if(ApexPages.currentPage().getParameters().get('accountid')!=null){
             application_policy.Account__c =ApexPages.currentPage().getParameters().get('accountid');
             returnURL = '/'+application_policy.Account__c;
         }else if(application_policy.Id!=null){
             returnURL = '/'+application_policy.Id;
         }else if(application_policy.Account__c!=null){
             returnURL = '/'+application_policy.Account__c;
         }else{
             returnURL = '/lightning/o/Policy__c/list?filterName=Recent';
         }
         if(String.isEmpty(application_policy.Account__c)){
             hasAccount =false;
         }else{
             hasAccount =true;
         }
         
         /*if(application_policy.Id != null){
             this.application_policy = getDynamicQuery('Policy__c','Account__r.Name, RecordType.Name,Underwriter_User__r.Name,Sales_User__r.Name,County__r.Name,Limit__r.Name,Deductible_ID__r.Name,Firm_Contact__r.Name', application_policy.Id);
         }*/
         
         if(application_policy.SCH_Mod__c == null){
             application_policy.SCH_Mod__c = 0;
         }
        
        if(policyObj != null && lawyer != null){
            application_policy.Effective_Date__c = lawyer.Deleted_Date__c != null ? lawyer.Deleted_Date__c : policyObj.Expiration_Date__c;
            application_policy.Expiration_Date__c = application_policy.Effective_Date__c.addYears(100);
            application_policy.Underwriter_User__c = policyObj.Underwriter_User__c;
            application_policy.Remove_102_Endorsement__c = true;
            application_policy.County__c = policyObj.County__c;
            application_policy.Policy_Retroactive_Date__c = lawyer.Prior_Act_Date__c;
            application_policy.ADJ_MOD__c = policyObj.ADJ_MOD__c;
            application_policy.Claims_Factor__c = policyObj.Claims_Factor__c;
            application_policy.Previous_Policy__c = policyObj.Id;
        }
        
         if(application_policy.Account__c!=null){
             acc =[select name,Billing_Address_County__r.Name,Billing_Address_County__c from Account where id=:application_policy.Account__c limit 1];
         }
         
         List<GEO_Factor__c> lstGeoFactor = new List<GEO_Factor__c>();
         if(acc.Billing_Address_County__r.Name != null){
             lstGeoFactor = [select Id, Name from GEO_Factor__c where Name =: acc.Billing_Address_County__r.Name limit 1];
         }
         
         //application_policy.County__c = (acc.Billing_Address_County__r.Name != null?acc.Billing_Address_County__r.Name:application_policy.County__c); 
        if(application_policy.County__c == null){
            application_policy.County__c = (lstGeoFactor.isEmpty()?application_policy.County__c:lstGeoFactor[0].Id);
        }
    
        showAdvancedFields = false;
        Set<Id> setAdvanceUserId = new Set<Id>();
        for(GroupMember objGroupMember : [SELECT Id, UserOrGroupId FROM GroupMember where Group.Name = 'Advance Users']){
            setAdvanceUserId.add(objGroupMember.UserOrGroupId);
        }
        
        showAdvancedFields = (setAdvanceUserId.contains(UserInfo.getUserId())?true:false);
    }
    
    public void updateExpirationDate(){
        if(application_policy.Effective_Date__c!=null){
            application_policy.Expiration_Date__c = application_policy.Effective_Date__c.addYears(1);
        }
    }
    
    public List<SelectOption> getRenewalType(){
        List<SelectOption> lstRenewalType = new List<SelectOption>();
        lstRenewalType.add(new SelectOption('', '--None--'));
        String applicationRecordTypeId = [SELECT id FROM RecordType WHERE name = 'Application' and sobjecttype ='Policy__c'].Id;
        for( Schema.PicklistEntry f : Policy__c.Renewal_Type__c.getDescribe().getPicklistValues())
        {
            if(!(application_policy.RecordTypeId == applicationRecordTypeId && (f.getValue() == 'EZ Renewal' || f.getValue() == 'Super EZ'))){
                lstRenewalType.add(new SelectOption(f.getLabel(), f.getValue()));
            }
        }       
        return lstRenewalType;
    }
     
    public List<SelectOption> getRecordTypeList(){
        List<SelectOption> lstRecordType = new List<SelectOption>();
        for(RecordType rt :  [Select id,Name from RecordType where sObjectType = 'Policy__c']){
            lstRecordType.add(new SelectOption(rt.Id,rt.Name));
        }       
        return lstRecordType;
    }
    
    //This method creates a dynamic query of the API passed.
    public Policy__c getDynamicQuery(String objectAPI, String relationfields, Id policyId){
        String query = 'select ';
        for(String fieldAPI : Schema.getGlobalDescribe().get(objectAPI).getDescribe().fields.getMap().keyset()){
            query += fieldAPI + ', ';
        }
        query = query.subString(0, query.length() - 1);
        
        if(String.isNotBlank(relationFields)){
            query += relationFields;
        }
        query += ' from '+objectAPI +' WHERE Id=: policyId';  
        System.debug('query----'+query);
        return Database.query(query);
    }
    
    public pagereference saveApplication_Policy(){
         try{
             if(application_policy != null){
                 if(!canEffectiveDateChange()){
                     return null;
                 }
                 if(validateLastApplicationIn90Days()){
                    return null; 
                 }
                 if(applicationEffectiveDateValidation()){
                     return null;
                 }
                 boolean isNew = false;
                 if(application_policy.Id == null){
                     isNew = true;
                 }
                 if(recordTypeToUpdate != null){
                     application_policy.RecordTypeId = recordTypeToUpdate;
                 }
                 
                 if(isSaErp && !String.isNotBlank(application_policy.Id)){
                     application_policy.RecordTypeId = [SELECT id ,Name,DeveloperName from RecordType WHERE SobjectType='Policy__c' and DeveloperName = 'SA_ERP' LIMIT 1].Id;
                 }
                 
                 upsert application_policy;
                 
                 User_Tracking__c userTrack;
                 if(isNew){
                     userTrack = UserTrackingHandler.createUserTrackingObject('Create', application_policy.Id, application_policy.Name);
                 }else{
                     userTrack = UserTrackingHandler.createUserTrackingObject('Edit', application_policy.Id, application_policy.Name);
                 }
                 insert userTrack;
                 
                 error = '';
                 
                 return new pagereference('/'+application_policy.Id);
             }
         }catch(DMLException e){
             error = e.getdmlMessage(0);
         }catch(Exception e){
             error = e.getMessage();
         }
         return null;
    }
    
    public pagereference saveAndNextApplication_Policy(){
         try{
             if(application_policy != null){
                 if(!canEffectiveDateChange()){
                     return null;
                 }
                 if(validateLastApplicationIn90Days()){
                    return null; 
                 }
                 if(applicationEffectiveDateValidation()){
                     return null;
                 }
                 
                 if(isSaErp && !String.isNotBlank(application_policy.Id)){
                     application_policy.RecordTypeId = [SELECT id ,Name,DeveloperName from RecordType WHERE SobjectType='Policy__c' and DeveloperName = 'SA_ERP' LIMIT 1].Id;
                 }
                 
                 
                 upsert application_policy;
                 if(isSaErp){                     
                     lawyer.Is_Policy_Created__c = true;
                     Update lawyer;
                 }
                 error = '';
                 
                 string pageRef = '/apex/PolicyLawyers?id='+application_policy.Id+'&showNext=true';
                 if(policyObj != null){
                     pageRef += '&policy='+policyObj.Id;
                 }
                 return new pagereference(pageRef);
             }
         }catch(DMLException e){
             error = e.getdmlMessage(0);
         }catch(Exception e){
             error = e.getMessage();
         }
         return null;
     }
    public boolean canEffectiveDateChange(){
        if(oldEffectiveDate!=null && oldEffectiveDate!=application_policy.Effective_Date__c){
            /*list<Policy_AOP__c> PolicyAOPLst =  [select id,Policy__c,AOP__c,AOP__r.Name
                                                 from Policy_AOP__c 
                                                 where Policy__c = :application_policy.Id];
            if(PolicyAOPLst.size()>0){
                Map<String,Id> aops = new Map<String,Id>();
                for(AOP_Factor__c aop : [select id,Name,AOP_Mod__c from  AOP_Factor__c where From_Date__c <=: application_policy.Effective_Date__c and  To_Date__c >=: application_policy.Effective_Date__c]){
                    aops.put(aop.Name,aop.Id);
                }
                for(Policy_AOP__c aop : PolicyAOPLst){
                    if(aops.containsKey(aop.AOP__r.Name)){
                        aop.AOP__c = aops.get(aop.AOP__r.Name);
                    }else{
                        error = 'Changing the Effective Date causes the AOP conflicts, please resolve them first.';
                        return false;
                    }
                }
                update PolicyAOPLst;
            }*/
            List<Policy_Quote__c> policyQuoteList = [SELECT Id,name,Coverage__c,Coverage__r.name,Deductible__c,Deductible__r.name FROM Policy_Quote__c WHERE Policy__c = :application_policy.Id];
            if(policyQuoteList.size()>0){
                Map<String,Id> deductible = new Map<String,Id>();
                Map<String,Id> limits = new Map<String,Id>();
                Map<String,Id> aops = new Map<String,Id>();
                for(Deductible_Factor__c df :[SELECT Id,Name FROM Deductible_Factor__c where From_Date__c <=: application_policy.Effective_Date__c and  To_Date__c >=: application_policy.Effective_Date__c]){
                    deductible.put(df.Name,df.Id);
                }
                for(ILF_Coverage_Factor__c ilf : [SELECT Id,Name,Is_10X10_Coverage__c,Is_5X5_Coverage__c FROM ILF_Coverage_Factor__c WHERE From_Date__c <=: application_policy.Effective_Date__c and  To_Date__c >=: application_policy.Effective_Date__c and OldLimit__c = false]){
                    limits.put(ilf.Name,ilf.Id);
                }
                for(Policy_Quote__c quote : policyQuoteList){
                    if(deductible.containsKey(quote.Deductible__r.name) && limits.containsKey(quote.Coverage__r.name)){
                        quote.Coverage__c =   limits.get(quote.Coverage__r.name);
                        quote.Deductible__c = deductible.get(quote.Deductible__r.name);
                    }else{
                        error = 'Changing the Effective Date causes the Limits and Deductibles conflicts, please resolve them first.';
                        return false;
                    }
                }
                update policyQuoteList;
            }
            
        }
        return true;
    }
    public boolean validateLastApplicationIn90Days(){
        if(application_policy.Id==null){
            List<Policy__c> policiesList = new List<Policy__c>([select id from Policy__c where RecordType.Name='Application' and CreatedDate = LAST_N_DAYS:90 and Account__c =: application_policy.Account__c]);
            if(policiesList.size()>0){
                error = 'There is already an open Application created in last 90 days. Please use that application or contact your system administrator in case of any discrepancy.';
                return true;
            }else{
                return false;
            }
        }else{
            return false;
        }
    } 
    public boolean applicationEffectiveDateValidation(){
        if(recordTypeName== 'Application' && application_policy.Effective_Date__c > System.today().addMonths(6)){
            error = 'You can not create policy in future more than 6 months from now';
            return true;
        }else if(application_policy.Policy_Retroactive_Date__c  > application_policy.Effective_Date__c){
            error = 'Prior Acts Date can not be greater than effective date of the policy';
            return true;
        }else{
            return false;
        }
    }
     public void fillRecordType(){
         List<RecordType > rtmap = [SELECT id ,Name from RecordType WHERE SobjectType='Policy__c' AND id =: recordTypeName];
          if(rtmap.size() > 0)
              recordTypeName = rtmap.get(0).Name;
     }
     
    public List<SelectOption> getPolicyCounty() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        if(application_policy.Effective_Date__c!=null){
            GEO_Factor__c [] threatMappings = [SELECT Id,Name,Master_Factor__r.Default__c,County__c FROM GEO_Factor__c WHERE From_Date__c <=: application_policy.Effective_Date__c and  To_Date__c >=: application_policy.Effective_Date__c and County__r.Only_Claim_Value__c = false and  Name != 'COOK(Chicago)'ORDER BY Name LIMIT 1000];
            for (GEO_Factor__c threatMapping : threatMappings) {
                if(application_policy.County__c == null && threatMapping.County__c == acc.Billing_Address_County__c){
                    application_policy.County__c = threatMapping.Id;
                }
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
            }
        }
        return options;
    }
    /*public List<SelectOption> getPolicyVersions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        for(Policy_Pricing_Version__mdt version : [select id,MasterLabel from Policy_Pricing_Version__mdt]){
            options.add(new SelectOption(version.MasterLabel,version.MasterLabel));
        }
        return options;
    }*/
    public List<SelectOption> getFirmContacts() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        /*AccountContactJunction__c [] threatMappings = [SELECT Id,Name,Account__c,Contact__r.Name FROM AccountContactJunction__c WHERE Account__c =: application_policy.Account__c ORDER BY Contact__r.Name LIMIT 1000];
        for (AccountContactJunction__c threatMapping : threatMappings) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Contact__r.Name));
        }*/
        List<AccountContactRelation> accountContactRelationList = [select id,contactid,Contact.Name from AccountContactRelation where AccountId =: application_policy.Account__c ORDER BY Contact.Name limit 1000];
        for(AccountContactRelation acr : accountContactRelationList){
            if(application_policy.Firm_Contact__c == null && accountContactRelationList.size() == 1){
                application_policy.Firm_Contact__c = acr.contactid;
            }
            options.add(new SelectOption(acr.contactid,acr.Contact.Name));
        }
        return options;
    }
    
    
    public List<SelectOption> getPolicyLimit () {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        ILF_Coverage_Factor__c[] threatMappings = [SELECT Id,Name FROM ILF_Coverage_Factor__c WHERE OldLimit__c = false ORDER BY Coverage_Max_Per_Claim__c,Full_Coverage__c ASC LIMIT 1000];
        for (ILF_Coverage_Factor__c threatMapping : threatMappings) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
        }
        return options;
    }
    
    public List<SelectOption> getUnderwriter() {
        if(application_policy.Underwriter_User__c==null){
            application_policy.Underwriter_User__c = UserInfo.getUserId();
        }
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        User[] threatMappings = [SELECT Id,Name FROM User where Profile.Name = 'Underwriting' AND ISACTIVE = TRUE ORDER BY Name LIMIT 1000];
        for (User threatMapping : threatMappings) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
        }
        return options;
    }
    public List<SelectOption> getSalesUser() {
        if(application_policy.Sales_User__c==null){
            application_policy.Sales_User__c = UserInfo.getUserId();
        }
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        User[] threatMappings = [SELECT Id,Name FROM User where Profile.Name = 'Sales' AND ISACTIVE = TRUE ORDER BY Name LIMIT 1000];
        for (User threatMapping : threatMappings) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
        }
        return options;
    }
    public List<SelectOption> getPolicyDeductible () {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        Deductible_Factor__c[] threatMappings = [SELECT Id,Name FROM Deductible_Factor__c ORDER BY Deductible_Amount__c ASC LIMIT 1000];
        for (Deductible_Factor__c threatMapping : threatMappings) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
        }
        return options;
    }
    
    public List<modVarWrap> getAllModFields() {
        totalModFields = new List<modVarWrap>();
        
        getFieldSetFields('SCH_Mod', 'SCH_Mod_Override', 'SCH_Override_Comment', totalModFields);
        
        return totalModFields;
    }
    
    public List<modVarWrap> getAllModFieldsFM() {
        totalModFieldsFM = new List<modVarWrap>();
        
        getFieldSetFields('SCH_Mod_FM', 'SCH_Mod_Override_FM', 'SCH_Override_Comment_FM', totalModFieldsFM);
        
        return totalModFieldsFM;
    }
    
    public List<modVarWrap> getAllModFieldsBO() {
        totalModFieldsBO = new List<modVarWrap>();
        
        getFieldSetFields('SCH_Mod_BO', 'SCH_Mod_Override_BO', 'SCH_Override_Comment_BO', totalModFieldsBO);
        
        return totalModFieldsBO;
    }
    
    public List<modVarWrap> getAllModFieldsTraining() {
        totalModFieldsTraining = new List<modVarWrap>();
        
        getFieldSetFields('SCH_Mod_Training', 'SCH_Mod_Override_Training', 'SCH_Override_Comment_Training', totalModFieldsTraining);
        
        return totalModFieldsTraining;
    }
    
    public List<modVarWrap> getAllModFieldsGM() {
        totalModFieldsGM = new List<modVarWrap>();
        
        getFieldSetFields('SCH_Mod_GM', 'SCH_Mod_Override_GM', 'SCH_Override_Comment_GM', totalModFieldsGM);
        
        return totalModFieldsGM;
    }
    
    public List<modVarWrap> getAllModFieldsOver() {
        totalModFieldsOver = new List<modVarWrap>();
        
        getFieldSetFields('SCH_Mod_Over', 'SCH_Mod_Override_Over', 'SCH_Override_Comment_Over', totalModFieldsOver);
        
        return totalModFieldsOver;
    }
    
    public void getFieldSetFields(String fieldSetName1, String fieldSetName2, String fieldSetName3, List<modVarWrap> actualModWrapList){
        Map<Integer, Schema.FieldSetMember> modValMap = new Map<Integer, Schema.FieldSetMember>();
        
        Integer i = 0;
        for(Schema.FieldSetMember fsm: SObjectType.Policy__c.FieldSets.getMap().get(fieldSetName1).getFields()){
            modValMap.put(i, fsm);
            i++;
        }
        
        Map<Integer, Schema.FieldSetMember> modOverrideMap = new Map<Integer, Schema.FieldSetMember>();
        
        i = 0;
        for(Schema.FieldSetMember fsm: SObjectType.Policy__c.FieldSets.getMap().get(fieldSetName2).getFields()){
            modOverrideMap.put(i, fsm);
            i++;
        }
        
        Map<Integer, Schema.FieldSetMember> modCommentMap = new Map<Integer, Schema.FieldSetMember>();
        
        i = 0;
        for(Schema.FieldSetMember fsm: SObjectType.Policy__c.FieldSets.getMap().get(fieldSetName3).getFields()){
            modCommentMap.put(i, fsm);
            i++;
        }
        
        for(Integer j : modValMap.keySet()){
            modVarWrap mVarWrap = new modVarWrap();
            String label = modValMap.get(j).getLabel();
            if(label == 'Client Intake/New Matter Acceptance Proc'){
                mVarWrap.label = 'Client Intake/New Matter Acceptance Procedures';
            }
            
            if(label == 'Use of Client Engagement/Contingency Fe'){
                mVarWrap.label = 'Use of  Client Engagement/Contingency Fee Agreement Letters';
            }
            
            if(label == 'Use of Declination/Non-Engagement Lette'){
                mVarWrap.label = 'Use of  Declination/Non-Engagement Letters';
            }
            if(label == 'Docket/Conflict Coordination with Main'){
                mVarWrap.label = 'Docket/Conflict Coordination with Main Office';
            }
            if(label == 'Size of Firm'){
                mVarWrap.label = 'Size of Firm (1% credit/attorney after 1st attorney – up to 10% credit allowed)';
            }
            if(label != 'Client Intake/New Matter Acceptance Proc' && label != 'Use of Client Engagement/Contingency Fe' && label != 'Use of Declination/Non-Engagement Lette' 
                && label != 'Docket/Conflict Coordination with Main' && label != 'Size of Firm'){
                mVarWrap.label = label;
            }
            mVarWrap.fsmModVal = modValMap.get(j);
            mVarWrap.fsmOverride = modOverrideMap.get(j);
            mVarWrap.fsmComment = modCommentMap.get(j);
            
            actualModWrapList.add(mVarWrap);
        }
    }
    
    @RemoteAction
    global static List<sObject> getLookupRecord(String likeString , String objectName) {
        if(String.IsNotBlank(likeString) && String.IsNotBlank(objectName)){
            likeString = likeString+'%';
            String query = '';
            
            query = 'SELECT Id, Name FROM '+objectName+' WHERE Name LIKE : likeString LIMIT 50';
            List<sObject> sObjectsList = database.query(query);
            if(sObjectsList.size()<50){
                likeString = '%'+likeString+'%';
                query = 'SELECT Id, Name FROM '+objectName+' WHERE Name LIKE : likeString LIMIT '+ (50-sObjectsList.size());
                sObjectsList.addAll(database.query(query));
            }
            return sObjectsList;
        }
        return null;
    }
    
    public class modVarWrap{
        public String label        {get; set;}  
        public Schema.FieldSetMember fsmModVal {get; set;}       
        public Schema.FieldSetMember fsmOverride {get; set;}  
        public Schema.FieldSetMember fsmComment {get; set;}  
    }
}