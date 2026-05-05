public class CreateApplicationEndorsementsEXT {
    public String baseUrl = String.valueOf(System.URL.getOrgDomainUrl().toExternalForm());
    public Boolean origin = Boolean.valueOf(apexpages.currentpage().getparameters().get('origin'));
    
    public String recordTypeId {get; set;}
    public String recordTypeName {get; set;}
    public String applicationRecordId {get; set;}
    public Policy__c currentApplication {get; set;}
    public List<Endorsement__c> masterEndorsements {get; set;}
    
    public CreateApplicationEndorsementsEXT (ApexPages.StandardSetController stdController) {
        applicationRecordId = ApexPages.currentPage().getParameters().get('id');
        currentApplication = [SELECT Id, Name, Cancel_Date__c, Account__c, Effective_Date__c FROM Policy__c WHERE Id =: applicationRecordId LIMIT 1];

        if (origin == true) {
            masterEndorsements = [SELECT Description__c, Endorsement_Record_Type_ID__c, Endorsement_Sub_Type__c, Id, Name, Type__c FROM Endorsement__c WHERE Active__c = true AND Endorsement_Sub_Type__c!='IL 102' AND Endorsement_Sub_Type__c!='IL 230' AND Endorsement_Sub_Type__c!='IL 234' AND Endorsement_Sub_Type__c!='IL 261'  AND Endorsement_Sub_Type__c!='IL 302' ORDER BY Type__c, Endorsement_Sub_Type__c ASC];
        } else if (origin == false) {
            masterEndorsements = [SELECT Description__c, Endorsement_Record_Type_ID__c, Endorsement_Sub_Type__c, Id, Name, Type__c FROM Endorsement__c WHERE Type__c = 'Descriptive' AND Active__c = true  AND Endorsement_Sub_Type__c!='IL 102' AND Endorsement_Sub_Type__c!='IL 230' AND Endorsement_Sub_Type__c!='IL 234' AND Endorsement_Sub_Type__c!='IL 261'  AND Endorsement_Sub_Type__c!='IL 302' ORDER BY Endorsement_Sub_Type__c ASC];
        }
    }
    
    public List<SelectOption> getRecordTypeNames() {
        List<SelectOption> recordTypeNames = new List<SelectOption>();
        for (Endorsement__c recordName : masterEndorsements) {
            recordTypeNames.add(new SelectOption(recordName.Endorsement_Record_Type_ID__c, recordName.Endorsement_Sub_Type__c + ' ' + recordName.Name));
            if(recordName.Endorsement_Sub_Type__c=='IL 191'){
                recordTypeNames.add(new SelectOption('', '-----------------------------------------------------------------------------------------------------------------------'));
            }
        }
        return recordTypeNames;
    }
    
    public PageReference CustomContinue () {
        if(recordTypeId!=null && recordTypeId!=''){
            recordTypeName = [SELECT Id, Name FROM RecordType WHERE Id =: recordTypeId LIMIT 1].Name;
            Account currentAccount = [SELECT Id, Name FROM Account WHERE Id =: currentApplication.Account__c];
            String cancelDate;
            String effectiveDate;
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
            
            PageReference continuePage;
            
            if( recordTypeName == 'IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT' || recordTypeName == 'CL Change Lawyer Endorsement'){
                
                continuePage = new PageReference('/apex/PolicyEndorsement?CF00NR0000001jPr4=' + currentApplication.Name + '&CF00NR0000001jPr4_lkid=' + applicationRecordId + '&retURL=%2F' + applicationRecordId + '&RecordType=' + recordTypeId + '&Name='+recordTypeName+'&00NR0000001jPrY=' + cancelDate + '&CF00NR0000001kx9I=' + currentAccount.Name + '&CF00NR0000001kx9I_lkid=' + currentAccount.Id + '&00NR0000001jPtt=' + effectiveDate);
                
            }else if(recordTypeName == 'IL 152 Adding an Attorney Endorsement'){
                continuePage = new PageReference('/apex/AddingAnAttorney?policyId=' + applicationRecordId +  '&Name='+recordTypeName+ '&RecordType=' + recordTypeId +'&effectiveDate=' + effectiveDate);
            }else if(recordTypeName == 'IL 153 Deleting an Attorney Endorsement'){
                continuePage = new PageReference('/apex/DeletingAnAttorney?policyId=' + applicationRecordId +  '&Name='+recordTypeName+ '&RecordType=' + recordTypeId +'&effectiveDate=' + effectiveDate);
            }else if(recordTypeName == 'IL 115 UNLIMITED PURCHASED EXTENDED'){
                Integer index = currentApplication.Name.lastIndexOf('-');
                String coverageTerm ='';
                if(index!=-1){
                    Integer value = Integer.valueOf(currentApplication.Name.substring(index+1));
                    System.debug('value'+value);
                    if(value<=4){
                        coverageTerm = '1-4 Years';
                    }else if(value==5){
                        coverageTerm = '5 Years';
                    }else if(value==6){
                        coverageTerm = '6 Years';
                    }else if(value==7){
                        coverageTerm = '7 Years';
                    }else if(value==8){
                        coverageTerm = '8 Years';
                    }else if(value==9){
                        coverageTerm = '9 Years';
                    }else if(value>=10){
                        coverageTerm = '10 or more years';
                    }
                }
                System.debug('coverageTerm'+coverageTerm);
                continuePage = new PageReference('/apex/EndorsementEditPage?policyId=' + applicationRecordId +  '&Name='+recordTypeName+ '&RecordType=' + recordTypeId +'&effectiveDate=' + effectiveDate);
                //continuePage = new PageReference(baseUrl + '/a2Z/e?CF00NR0000001jPr4=' + currentApplication.Name + '&CF00NR0000001jPr4_lkid=' + applicationRecordId + '&retURL=%2F' + applicationRecordId + '&RecordType=' + recordTypeId + '&Name='+recordTypeName+'&00NR0000001jPrY=' + cancelDate + '&CF00NR0000001kx9I=' + currentAccount.Name + '&CF00NR0000001kx9I_lkid=' + currentAccount.Id + '&00NR0000001jPtt=' + effectiveDate  +'&00NR0000001k4cF='+ coverageTerm);
            } else {
                continuePage = new PageReference('/apex/EndorsementEditPage?policyId=' + applicationRecordId +  '&Name='+recordTypeName+ '&RecordType=' + recordTypeId +'&effectiveDate=' + effectiveDate);
                //continuePage = new PageReference(baseUrl + '/a2Z/e?CF00NR0000001jPr4=' + currentApplication.Name + '&CF00NR0000001jPr4_lkid=' + applicationRecordId + '&retURL=%2F' + applicationRecordId + '&RecordType=' + recordTypeId + '&Name='+recordTypeName+'&00NR0000001jPrY=' + cancelDate + '&CF00NR0000001kx9I=' + currentAccount.Name + '&CF00NR0000001kx9I_lkid=' + currentAccount.Id + '&00NR0000001jPtt=' + effectiveDate);
            }
            
            continuePage.setRedirect(true);
            return continuePage;
        }else{
            return null;
        }
    }
    
    public PageReference Cancel () {
        PageReference cancelPage = new PageReference('/' + applicationRecordId);
        cancelPage.setRedirect(true);
        return cancelPage;
    }
}