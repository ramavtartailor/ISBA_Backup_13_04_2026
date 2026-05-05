public class ManageEndorsementsExt {
    public String baseUrl = String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm());
    public Boolean origin = Boolean.valueOf(apexpages.currentpage().getparameters().get('origin'));
    
    public String recordTypeId {get; set;}
    public String recordTypeName {get; set;}
    public String applicationRecordId {get; set;}
    public Policy__c currentApplication {get; set;}
    public List<Endorsement__c> masterEndorsements {get; set;}
    public List<ManageEndorsementsWrapper> endorsementWrapper{get;set;}
    public String returnURL{get;set;}
    public String error{get;set;}
    public String newName{get;set;}
    public String newURL{get;set;}
    public Integer currentNumber{get;set;}
    public Integer index{get;set;}
    public String endorsementId{get;set;} 
	public ManageEndorsementsExt(ApexPages.StandardController stdController) {
        error = newName = newURL = '';
        applicationRecordId = ApexPages.currentPage().getParameters().get('relatedId');
        currentApplication = [SELECT Id, Name, Cancel_Date__c, Account__c, Effective_Date__c,Account__r.Name,Expiration_Date__c,Policy_Document_Version__c FROM Policy__c WHERE Id =: applicationRecordId LIMIT 1];
        returnURL = '/'+applicationRecordId;
        if (origin == true) {
            Profile prof = [select Id,Name from Profile where id =: UserInfo.getProfileId()];
            if(prof.Name == 'System Administrator'){
                masterEndorsements = [SELECT Description__c, Endorsement_Record_Type_ID__c, Endorsement_Sub_Type__c, Id, Name, Type__c FROM Endorsement__c WHERE Active__c = true  ORDER BY Type__c, Endorsement_Sub_Type__c ASC];
            }else{
                masterEndorsements = [SELECT Description__c, Endorsement_Record_Type_ID__c, Endorsement_Sub_Type__c, Id, Name, Type__c FROM Endorsement__c WHERE Active__c = true AND Endorsement_Sub_Type__c!='IL 102' AND Endorsement_Sub_Type__c!='IL 230' AND Endorsement_Sub_Type__c!='IL 234' AND Endorsement_Sub_Type__c!='IL 261'  AND Endorsement_Sub_Type__c!='IL 302' ORDER BY Type__c, Endorsement_Sub_Type__c ASC];
            }
        } else if (origin == false) {
            masterEndorsements = [SELECT Description__c, Endorsement_Record_Type_ID__c, Endorsement_Sub_Type__c, Id, Name, Type__c FROM Endorsement__c WHERE Type__c = 'Descriptive' AND Active__c = true  AND Endorsement_Sub_Type__c!='IL 102' AND Endorsement_Sub_Type__c!='IL 230' AND Endorsement_Sub_Type__c!='IL 234' AND Endorsement_Sub_Type__c!='IL 261'  AND Endorsement_Sub_Type__c!='IL 302' ORDER BY Endorsement_Sub_Type__c ASC];
        }
        endorsementWrapper = new List<ManageEndorsementsWrapper>();
        currentNumber = -1;
        for(Policy_Endorsement__c endorsement : [select id,Name,Endorsement_Number__c from Policy_Endorsement__c where Policy__c =: applicationRecordId order by Name ASC]){
            currentNumber++;
            ManageEndorsementsWrapper wrapper = new ManageEndorsementsWrapper();
            wrapper.endorsementNumber = endorsement.Endorsement_Number__c;
            if(endorsement.Endorsement_Number__c == 'IL 102' || endorsement.Endorsement_Number__c == 'IL 260'){
                wrapper.url =  baseUrl + '/apex/EndorsementEditPage?fromPage=ManageEndorsements&manageIndex='+currentNumber+'&id='+endorsement.Id;
            }else if(endorsement.Endorsement_Number__c == 'IL 152'){
                wrapper.url =  baseUrl + '/apex/AddingAnAttorney?fromPage=ManageEndorsements&manageIndex='+currentNumber+'&id='+endorsement.Id;
            }else if(endorsement.Endorsement_Number__c == 'IL 153'){
                wrapper.url =  baseUrl + '/apex/DeletingAnAttorney?fromPage=ManageEndorsements&manageIndex='+currentNumber+'&id='+endorsement.Id;
            }else{
                wrapper.url =  baseUrl + '/apex/EndorsementEditPage?fromPage=ManageEndorsements&manageIndex='+currentNumber+'&id='+endorsement.Id+'&name='+endorsement.name;
            }
            endorsementWrapper.add(wrapper);
        }
    }
    public List<SelectOption> getRecordTypeNames() {
        List<SelectOption> recordTypeNames = new List<SelectOption>();
        for (Endorsement__c recordName : masterEndorsements) {
            if(recordName.Endorsement_Sub_Type__c=='IL 106' && currentApplication.Policy_Document_Version__c != '1/18'){
                continue;
            }
            recordTypeNames.add(new SelectOption(recordName.Endorsement_Record_Type_ID__c, recordName.Endorsement_Sub_Type__c + ' ' + recordName.Name));
            if(recordName.Endorsement_Sub_Type__c=='IL 191'){
                recordTypeNames.add(new SelectOption('', '-----------------------------------------------------------------------------------------------------------------------'));
            }
        }
        return recordTypeNames;
    }
    public void addEndorsementFunc(){
        error = newName = newURL = '';
        if(recordTypeId!=null && recordTypeId!=''){
            String cancelDate;
            String effectiveDate;
            recordTypeName = [SELECT Id, Name FROM RecordType WHERE Id =: recordTypeId LIMIT 1].Name;
            if (currentApplication.Cancel_Date__c != null) {
                cancelDate = String.valueOf(currentApplication.Cancel_Date__c.Month() + '/' + currentApplication.Cancel_Date__c.Day() + '/' + currentApplication.Cancel_Date__c.Year());
            } else {
                cancelDate = String.valueOf(Date.today().Month() + '/' + Date.today().Day() + '/' + Date.today().Year());
            }
            
            if (currentApplication.Effective_Date__c != null) {
                effectiveDate = String.valueOf(currentApplication.Effective_Date__c.Month() + '/' + currentApplication.Effective_Date__c.Day() + '/' + currentApplication.Effective_Date__c.Year());
            } else {
                effectiveDate = String.valueOf(Date.today().Month() + '/' + Date.today().Day() + '/' + Date.today().Year());
            }
            currentNumber++;
            Endorsement__c endor = [select id,Endorsement_Sub_Type__c from Endorsement__c where Endorsement_Record_Type_ID__c=: recordTypeId];
            if(endor.Endorsement_Sub_Type__c == 'IL 102' || endor.Endorsement_Sub_Type__c == 'IL 260'){
                newURL =  baseUrl + '/apex/EndorsementEditPage?fromPage=ManageEndorsements&manageIndex='+currentNumber+'&policyId=' + applicationRecordId +  '&Name='+recordTypeName+ '&RecordType=' + recordTypeId +'&effectiveDate=' + effectiveDate;
            }else if(endor.Endorsement_Sub_Type__c == 'IL 152'){
                newURL =  baseUrl + '/apex/AddingAnAttorney?fromPage=ManageEndorsements&manageIndex='+currentNumber+'&policyId=' + applicationRecordId +  '&Name='+recordTypeName+ '&RecordType=' + recordTypeId +'&effectiveDate=' + effectiveDate;
            }else if(endor.Endorsement_Sub_Type__c == 'IL 153'){
                newURL =  baseUrl + '/apex/DeletingAnAttorney?fromPage=ManageEndorsements&manageIndex='+currentNumber+'&policyId=' + applicationRecordId +  '&Name='+recordTypeName+ '&RecordType=' + recordTypeId +'&effectiveDate=' + effectiveDate;
            }else if(endor.Endorsement_Sub_Type__c == 'IL 107'){
                List<Policy__c> polList = new List<Policy__c>([select id,Account__c FROM Policy__c where RecordType.Name ='Application' and Account__c =:currentApplication.Account__c]);
                if(!polList.isEmpty()){
                    error = 'There is a pending application. for this account.';
                }
                else{
                    newURL =  baseUrl + '/apex/EndorsementEditPage?fromPage=ManageEndorsements&manageIndex='+currentNumber+'&policyId=' + applicationRecordId +  '&Name='+recordTypeName+ '&RecordType=' + recordTypeId +'&effectiveDate=' + effectiveDate;
                }
            }else{
                newURL =  baseUrl + '/apex/EndorsementEditPage?fromPage=ManageEndorsements&manageIndex='+currentNumber+'&policyId=' + applicationRecordId +  '&Name='+recordTypeName+ '&RecordType=' + recordTypeId +'&effectiveDate=' + effectiveDate;
            }
            newName = endor.Endorsement_Sub_Type__c;
        }else{
            error = 'Please select the Endorsement Type.';
        }
    }
    public void removeEndorsementFunc(){
        error = newName = newURL = '';
        if(String.isNotBlank(endorsementId)){
            try{
                Policy_Endorsement__c endorsement = [select id,Event_Status__c from Policy_Endorsement__c where id=: endorsementId];
                if(endorsement.Event_Status__c == 'Completed'){
                    error = 'You can not delete Approved Endorsement.';
                }else{
                    delete endorsement;
                    currentNumber--;
                }
            }catch(Exception e){
                error = e.getMessage();
            }
        }else{
            currentNumber--;
        }
    }
    public class ManageEndorsementsWrapper{
        public String url{get;set;}
        public String endorsementNumber{get;set;}
    }
}