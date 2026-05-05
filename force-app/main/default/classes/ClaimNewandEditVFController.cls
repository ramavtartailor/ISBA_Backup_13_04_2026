public class ClaimNewandEditVFController {
    
    public Policy_Claim__c claimRecord{get;set;}
    public String error{get;set;}
    public List<SelectOption> lawyerOptions{get;set;}
    public String policyId{get;set;} 
    public String accountName{get;set;}
    public String policyNumber{get;set;}
    public String deductibleAndLimit{get;set;}
    public String masterFactor{get;set;}
    public Date effectivedt{get;set;} 
    public String returnURL{get;set;}
    public Policy_Claim__c parentClaimRecord{get;set;}
    
    private String claimCloseStatus;
    public boolean isNew{get;set;}
    public ClaimNewandEditVFController(ApexPages.StandardController controller) {
        accountName='';
        policyNumber='';
        masterFactor = '';        
        this.claimRecord = (Policy_Claim__c)controller.getRecord();
        
        lawyerOptions = new List<SelectOption>();
        returnURL = ApexPages.currentPage().getParameters().get('retURL');
        
        String lkId = ApexPages.currentPage().getParameters().get('CF00NR0000001k5Pb_lkid');
        
        if(lkId != null){
            System.debug('---'+lkId);
            if((lkId.length() == 15 || lkId.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', lkId)) {
                parentClaimRecord= [SELECT Id, Name, Policy__c , Parent_Claim__c, Parent_Claim__r.Name, Is_Non_Lawyer__c FROM Policy_Claim__c WHERE Id =: lkId LIMIT 1];
            
                System.debug('---'+claimRecord.Parent_Claim__r.Name);
            }
        }
        
        //lawyerOptions.add(new SelectOption('','--None--'));
        if(claimRecord.Id==null){
            //claimRecord.Claim_Handler_Status__c='Open';
            claimRecord.Follow_up_Date__c = System.today().addDays(30);
            claimRecord.Claim_Status__c = 'Open';
            isNew = true;
        }
        
        claimCloseStatus = claimRecord.Claim_Status__c;
        
        if(claimRecord.Policy__c!=null){
            Policy__C policy = [select Policy_Number__c,AOP_Master_Factor__c,Effective_Date__c,Account__r.name,Limit__r.Name,Deductible_ID__r.Name,Account__c from Policy__C where id = :claimRecord.Policy__c limit 1 ];
            masterFactor = policy.AOP_Master_Factor__c;
            accountName = policy.Account__r.name;
            policyNumber = policy.Policy_Number__c;
            effectivedt = policy.Effective_Date__c;
            deductibleAndLimit = policy.Limit__r.Name + ' - ' + policy.Deductible_ID__r.Name;
            claimRecord.Account__c = policy.Account__c;
        }
        /*for(Policy_Lawyer__c  obj :[SELECT Id,Lawyer__r.Name FROM Policy_Lawyer__c WHERE Policy__c =: claimRecord.Policy__c ORDER BY Lawyer__r.Name]){
        
            lawyerOptions.add(new SelectOption(obj.Id,obj.Lawyer__r.Name));
        
        }*/
        lawyercall();
    }
    
    
    public pagereference saveClaim(){
    
        try{
            if(claimRecord.Id != null && claimCloseStatus == 'Closed'){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Closed claim cannot be edited.'));
            }
            else{
                String lkId = ApexPages.currentPage().getParameters().get('CF00NR0000001k5Pb_lkid');
            
                if(parentClaimRecord != null){
                    System.debug('---'+lkId);
                    if(parentClaimRecord.Id != null) {
                        claimRecord.Parent_Claim__c = parentClaimRecord.Id;
                    }
                }
                if(!claimRecord.Is_Non_Lawyer__c){
                    claimRecord.Non_Lawyer__c = '';                   
                }
                else{
                    claimRecord.Lawyer__c = null;
                }
                
                System.debug('claimRecord---'+claimRecord);
                
                boolean isNew = false;
                if(claimRecord.Id == null){
                    isNew = true;
                }
                
                upsert claimRecord;
                
                Policy_Claim__c clmObj = [SELECT Id, Name FROM Policy_Claim__c WHERE Id =: claimRecord.Id LIMIT 1];
                
                User_Tracking__c userTrack;
                if(isNew){
                    userTrack = UserTrackingHandler.createUserTrackingObject('Create', clmObj.Id, clmObj.Name);
                }else{
                    userTrack = UserTrackingHandler.createUserTrackingObject('Edit', clmObj.Id, clmObj.Name);
                }
                insert userTrack;
                
                //error = '';
                
                return new pagereference('/'+clmObj.Id );
            }
            
         } catch(DMLException e){
            ApexPages.addMessages(e);
         } catch(Exception ex){
            ApexPages.addMessages(ex);
            
         }
         
          
        
        return null;
    }
    
    
    
    public void lawyercall(){
    
        lawyerOptions = new List<SelectOption>();
        
        //lawyerOptions.add(new SelectOption('','--None--'));
        
        
        
        /*for(Policy_Lawyer__c  obj :[SELECT Id,Name,Lawyer__r.Name FROM Policy_Lawyer__c WHERE Policy__c =: policyId ORDER BY Lawyer__r.Name]){
        
            lawyerOptions.add(new SelectOption(obj.Id,obj.Lawyer__r.Name));
        
        }*/
        Id accountId;
        if(policyId == null){
            accountId = claimRecord.Account__c;
        }else{
            List<Policy__c> policies = [select id,Account__c,AOP_Master_Factor__c,Effective_Date__c from Policy__c where id =: policyId];
                      
            if(policies.size() > 0){
                accountId = policies[0].Account__c;
                claimRecord.Account__c = accountId;
                masterFactor = policies[0].AOP_Master_Factor__c;
                effectivedt = policies[0].Effective_Date__c;
            }
        }
        
        for(AccountContactJunction__c obj : [SELECT Id, Name FROM AccountContactJunction__c WHERE Contact__r.Type__c = 'Lawyer' AND 
                                             Contact__c in (SELECT ContactId FROM AccountContactRelation WHERE AccountId = : accountId) order by Name LIMIT 1000]){
            lawyerOptions.add(new SelectOption(obj.Id,obj.Name));
        }
    }
    
    
    
    public List<SelectOption> getCounty() {
        
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('','--None--'));
        
        for(GEO_Factor__c obj :[SELECT Id,Name FROM GEO_Factor__c where Master_Factor__r.Default__c=true ORDER BY Name]){
        
            options.add(new SelectOption(obj.Id,obj.Name));
        
        }
        
        return options;
    }
    
    public List<SelectOption> getAreaOfLaw() {
        system.debug('claimRecord => '+claimRecord);
    
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('','--None--'));
        if(!String.isNotBlank(masterFactor)){
            if(effectivedt != null){
                List<Master_Factor__c> mf = new List<Master_Factor__c>([SELECT Id FROM Master_Factor__c WHERE From_Date__c<= : effectivedt AND To_Date__c >=: effectivedt]);
                if(!mf.isEmpty()){
                    masterFactor = mf[0].Id;
                }
            }
        }
        
        for(AOP_Factor__c obj :[SELECT Id,Name FROM AOP_Factor__c  WHERE Master_Factor__c=: masterFactor ORDER BY Name]){
        
            options.add(new SelectOption(obj.Id,obj.Name));
        
        }
    
      return options;
    }
    public List<SelectOption> getClaimHandler() {
        if(claimRecord.Claim_Handler_Lookup__c==null){
            claimRecord.Claim_Handler_Lookup__c = UserInfo.getUserId();
        }
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        User[] threatMappings = [SELECT Id,Name FROM User where Profile.Name = 'Claims' AND ISACTIVE = TRUE ORDER BY Name LIMIT 1000];
        for (User threatMapping : threatMappings) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
        }
        return options;
    }
    @RemoteAction
    public static List<sObject> getLookupRecord(String likeString , String objectName,String compareId) {
        if(String.IsNotBlank(likeString) && String.IsNotBlank(objectName)){
            likeString = likeString+'%';
            String query = '';
            
            
            query = 'SELECT Id, Name, Effective_Date__c, Expiration_Date__c, Account__r.Name FROM '+objectName+' WHERE Name LIKE : likeString and (RecordType.Name =\'Policy\' or RecordType.Name =\'ERP Policy\') and ((Cancel_Date__c!=null and Cancel_Date__c >= LAST_90_DAYS) OR (ERE_Date__c!=null and ERE_Date__c >= LAST_90_DAYS) OR (Expiration_Date__c!=null and Expiration_Date__c >= LAST_90_DAYS)) LIMIT 50';
            
            
            return database.query(query);
        }
        return null;
    }

}