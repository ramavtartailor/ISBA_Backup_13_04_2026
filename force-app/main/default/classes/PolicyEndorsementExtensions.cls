public with sharing class PolicyEndorsementExtensions {
    
    private Policy_Endorsement__c policy;
    public string recordTypeName{get;set;}
    
    public PolicyEndorsementExtensions(ApexPages.StandardController stdController) {
        this.policy = (Policy_Endorsement__c)stdController.getRecord();
        
        if(policy.Id != null){
            recordTypeName = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosById().get(policy.RecordTypeId).getName();
        } else {
        
            if(ApexPages.currentPage().getParameters().get('Name') != null && ApexPages.currentPage().getParameters().get('Name') != ''){
                
                recordTypeName = ApexPages.currentPage().getParameters().get('Name');
                policy.Name = recordTypeName;
            }
            
            if(ApexPages.currentPage().getParameters().get('RecordType') != null && ApexPages.currentPage().getParameters().get('RecordType') != ''){
                
                policy.RecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
            }
            
            if(ApexPages.currentPage().getParameters().get('CF00NR0000001kx9I_lkid') != null && ApexPages.currentPage().getParameters().get('CF00NR0000001kx9I_lkid') != ''){
                
                policy.Account__c = ApexPages.currentPage().getParameters().get('CF00NR0000001kx9I_lkid'); 
            
            }
            
            if(ApexPages.currentPage().getParameters().get('CF00NR0000001jPr4_lkid') != null && ApexPages.currentPage().getParameters().get('CF00NR0000001jPr4_lkid') != ''){
                
                policy.Policy__c = ApexPages.currentPage().getParameters().get('CF00NR0000001jPr4_lkid'); 
            
            }
            
            if(ApexPages.currentPage().getParameters().get('00NR0000001jPrY') != null && ApexPages.currentPage().getParameters().get('00NR0000001jPrY') != ''){
                
                policy.Endorsement_Effective_Date__c = date.parse(ApexPages.currentPage().getParameters().get('00NR0000001jPrY')); 
            
            }
            
            
            
            if(recordTypeName == 'IL 152 Adding an Attorney Endorsement' || recordTypeName == 'IL 153 Deleting an Attorney Endorsement' || recordTypeName == 'CL Change Lawyer Endorsement'){
            
                if(ApexPages.currentPage().getParameters().get('00NR0000001jPtt') != null && ApexPages.currentPage().getParameters().get('00NR0000001jPtt') != ''){
                
                    policy.Prior_Act_Date__c = date.parse(ApexPages.currentPage().getParameters().get('00NR0000001jPtt')); 
            
                }
                
            }
        }
        
    }
    
    public void lawyercall(){
    
    }
    
    /* public Pagereference doSaveAndNew(){
        
        try {
        
            upsert policy;
        
            string s = '/'+policy.id;

            return new Pagereference(s);
        
        } catch(Exception e) {
             String error = e.getMessage();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,error));
        }
        
        return null;
    } */
    
    public List<SelectOption> getFirmContacts() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        AccountContactJunction__c [] threatMappings = [SELECT Id,Name,Account__c,Contact__r.Name FROM AccountContactJunction__c WHERE Account__c =: Policy.Account__c AND Contact__r.Type__c = 'Lawyer' ORDER BY Contact__r.Name LIMIT 1000];
        for (AccountContactJunction__c threatMapping : threatMappings) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Contact__r.Name));
        }
        return options;
    }
    
    public List<SelectOption> getPolicyLawyer() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        Policy_Lawyer__c [] threatMappings = [SELECT Id,Name,Account__c,Deleted_Lawyer__c,Policy__c,Lawyer__r.Contact__r.Name FROM Policy_Lawyer__c WHERE Policy__c =: policy.Policy__c AND Deleted_Lawyer__c = false ORDER BY Lawyer__r.Contact__r.Name LIMIT 1000];
        for (Policy_Lawyer__c  threatMapping : threatMappings) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Lawyer__r.Contact__r.Name));
        }
        return options;
    }
    
    

}