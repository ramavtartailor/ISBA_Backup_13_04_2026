public class FirmModDetailVFController {
    public Policy__c application_policy {get;set;}
    public String error{get;set;}
    public String success{get;set;}
    public List<modVarWrap> totalModFields {get; set;}
    public List<modVarWrap> totalModFieldsFM {get; set;}
    public List<modVarWrap> totalModFieldsBO {get; set;}
    public List<modVarWrap> totalModFieldsTraining {get; set;}
    public List<modVarWrap> totalModFieldsGM {get; set;}
    public List<modVarWrap> totalModFieldsOver {get; set;}
    public FirmModDetailVFController(ApexPages.StandardController stdController){
        Id policyId = stdController.getId();
        DescribeSObjectResult describeResult = Policy__c.getSObjectType().getDescribe();
        List<String> fieldNames = new List<String>(describeResult.fields.getMap().keySet());
        String query =	' SELECT Account__r.Name,' + String.join(fieldNames, ',') + ' FROM Policy__c where id=:  policyId'	;	
        application_policy = Database.query(query);
    }
    public pagereference savePolicy(){
        error ='';
        success = 'Record saved successfully. ';
        try{
            update application_policy;
        }catch(Exception e){
            error = e.getMessage();
            success = '';
        }
        return null;
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
    public class modVarWrap{
        public String label        {get; set;}  
        public Schema.FieldSetMember fsmModVal {get; set;}       
        public Schema.FieldSetMember fsmOverride {get; set;}  
        public Schema.FieldSetMember fsmComment {get; set;}  
    }
}