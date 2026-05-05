public class EndorsementEditVFCtrl {
    public Policy_Endorsement__c policyEndorsement{get;set;}
    public String returnURL{get;set;}
    public String endorsementName{get;set;}
    public boolean singleColumnLayout{get;set;}
    public boolean termEndorsement{get;set;}
    public boolean effectiveDateDisabled{get;set;}
    public Integer rowIdx{get;set;}
    public List<Policy_Endorsement_Term__c> termList{get;set;}
    public String fromPage{get;set;}
    public boolean additionalPremiumSection{get;set;}
    public boolean additionalERPPolicySection{get;set;}
    public boolean isIL107{get;set;}
    public boolean isIL190{get;set;}
    public String IL106Value{get;set;}
    public Long policyYears{get;set;}
    public boolean has106{get;set;}
    public Decimal premium{get;set;}
    public Decimal primary{get;set;}
    public Decimal excess{get;set;}
    public Decimal x5x5{get;set;}
    public Decimal x10x10{get;set;}
    public Decimal term{get;set;}
    Map<Id,String> lawyersMap = new Map<Id,String>();
    Apexpages.StandardController controller;
    
    public boolean canRemoved{get;set;}
    public Integer manageIndex{get;set;}
    
    
    public EndorsementEditVFCtrl(ApexPages.StandardController stdController) {
        controller = stdController;
        this.policyEndorsement = (Policy_Endorsement__c)stdController.getRecord();
        fromPage = ApexPages.currentPage().getParameters().get('fromPage');
        if(ApexPages.currentPage().getParameters().get('manageIndex') != null){
            manageIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('manageIndex'));
        }
        if(fromPage == 'ManageEndorsements'){
            canRemoved = true;
        }
        if(policyEndorsement.Id != null){
            DescribeSObjectResult describeResult = policyEndorsement.Id.getSObjectType().getDescribe();	
            List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            String query =	  ' SELECT ' +	      String.join( fieldNames, ',' ) +	  ',Policy__r.Policy_Series_Effective_Date__c ,Policy__r.Policy_Suffix_Formula__c,Policy__r.Original_Premium__c,Policy__r.Total_10x10__c,Policy__r.Total_5x5__c,Policy__r.Expiration_Date__c,Policy__r.Effective_Date__c,Policy__r.Premium__c,Policy__r.Original_Primary__c,Policy__r.Original_Excess__c,Policy__r.Original_5x5__c,Policy__r.Original_10x10__c FROM ' +	      describeResult.getName() +	  ' WHERE ' +	      ' id = \''+ policyEndorsement.Id  +	  '\' LIMIT 1 '	;
            policyEndorsement = Database.query( query );
            if(policyEndorsement.Event_Status__c == 'Complete'){
                canRemoved = false;
            }
        }
        Schema.DescribeSObjectResult d = Schema.SObjectType.Policy_Endorsement__c; 
        Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
        Policy__c pol = new Policy__c ();
        
        if(ApexPages.currentPage().getParameters().get('policyId')!=null){
            policyEndorsement.Policy__c = ApexPages.currentPage().getParameters().get('policyId');
            returnURL = '/'+policyEndorsement.Policy__c;
            pol = [select id,Account__c,Name,Expiration_Date__c,RecordType.Name,Effective_Date__c,Cancel_Date__c,Policy_Suffix_Formula__c,Original_Premium__c,Total_10x10__c,Total_5x5__c,Premium__c,Original_Primary__c,Original_Excess__c,Original_5x5__c,Original_10x10__c,Policy_Series_Effective_Date__c  from Policy__C where id = : policyEndorsement.Policy__c];
            policyEndorsement.Account__r = [select id,name from Account where id = : pol.Account__c];
            policyEndorsement.Policy__r = pol;
            policyEndorsement.Account__c = pol.Account__c;
            if(pol.RecordType.Name == 'Application'){
                policyEndorsement.Endorsement_Effective_Date__c = pol.Effective_Date__c;
            }
        }
        if(ApexPages.currentPage().getParameters().get('name')!=null){
            policyEndorsement.name =ApexPages.currentPage().getParameters().get('name');
        }
        if(ApexPages.currentPage().getParameters().get('effectiveDate')!=null){
            policyEndorsement.Prior_Act_Date__c =date.parse(ApexPages.currentPage().getParameters().get('effectiveDate'));
        }
        if(ApexPages.currentPage().getParameters().get('id')!=null){
            returnURL = '/'+ApexPages.currentPage().getParameters().get('id');
            endorsementName = rtMapById.get(policyEndorsement.RecordTypeId).getName();
        }
        
        System.debug('endorsement:: Name---:'+policyEndorsement.Name);
        if(ApexPages.currentPage().getParameters().get('RecordType')!=null){
            policyEndorsement.RecordTypeId =  ApexPages.currentPage().getParameters().get('RecordType');
            endorsementName = rtMapById.get(policyEndorsement.RecordTypeId).getName();
        }
        
        System.debug('endorsementName---:'+endorsementName);
        if(endorsementName!=null && endorsementName.equalsIgnoreCase('IL 150 POLICY ENDORSEMENT')){
            singleColumnLayout = true;
        }
        
        if(endorsementName!=null 
           && (endorsementName.equalsIgnoreCase('IL 107 PURCHASE EXTENDED REPORTING ENDORSEMENT') || 
               endorsementName.equalsIgnoreCase('IL 107B U.S. Active Duty Military Service Extended Reporting Period Election') ||
               endorsementName.equalsIgnoreCase('IL 107C Unlimited Death or Disability Extended Reporting Period Election') ||
               endorsementName.equalsIgnoreCase('IL 107D Unlimited Retirement Extended Reporting Period Election Endorsement'))){
            if(pol.Cancel_Date__c!=null){
                //effectiveDateDisabled = true;
                policyEndorsement.Endorsement_Effective_Date__c = pol.Cancel_Date__c;
            }else if(pol.Expiration_Date__c!=null){
                //effectiveDateDisabled = true;
                policyEndorsement.Endorsement_Effective_Date__c = pol.Expiration_Date__c;
            } 
        }
        if(policyEndorsement.Policy__r.Policy_Series_Effective_Date__c != null){
            policyYears = (Decimal.valueOf(policyEndorsement.Policy__r.Policy_Series_Effective_Date__c.monthsBetween(policyEndorsement.Policy__r.Effective_Date__c) / 12)).round(System.RoundingMode.DOWN);
            if(policyEndorsement.Policy__r.Expiration_Date__c == policyEndorsement.Endorsement_Effective_Date__c){
                policyYears += 1;
            }
        }else{
            policyYears = 0;
        }
        if(endorsementName!=null && endorsementName.equalsIgnoreCase('IL 191 Reinstatement Notice')){
            if(pol.Cancel_Date__c!=null){
                effectiveDateDisabled = true;
                policyEndorsement.Endorsement_Effective_Date__c = pol.Cancel_Date__c;
            }
        }
        if(endorsementName!=null && (endorsementName.equalsIgnoreCase('IL 200 PAST ACTS COVERAGE BUYBACK ENDORSEMENT') ||
                                     endorsementName.equalsIgnoreCase('IL 260 Past Acts Coverage Endorsement'))){
            termEndorsement = true;
            if(policyEndorsement.Id == null){
                termList = new List<Policy_Endorsement_Term__c>();
                termList.add(new Policy_Endorsement_Term__c());
            }else{
                termList = new List<Policy_Endorsement_Term__c>([select id,Attorney__c,Endorsement__c,Firm_Entity__c,Term_End_Date__c,Term_Start_Date__c from Policy_Endorsement_Term__c where Endorsement__c=: policyEndorsement.Id]);
            }
        }
        system.debug('policyEndorsementPolicy__c'+policyEndorsement.Policy__c); 
        if(endorsementName!=null && (endorsementName.equalsIgnoreCase('IL 107 PURCHASE EXTENDED REPORTING ENDORSEMENT') )){
            additionalPremiumSection = true;
            isIL107 = true;
            List<Policy_Endorsement__c> IL106Endorsement = [select id from Policy_Endorsement__c where Policy__c =: policyEndorsement.Policy__c and Endorsement_Number__c = 'IL 106'];
            IL106Value = 'N/A';
            has106 = false;
            premium = policyEndorsement.Premium__c;
            primary = policyEndorsement.Primary__c;
            excess = policyEndorsement.Excess__c;
            x5x5 = policyEndorsement.Premium_5_5__c;
            x10x10 = policyEndorsement.Premium_10_10__c;
            system.debug('IL106EndorsementIL106Endorsement'+IL106Endorsement);
            if(IL106Endorsement.size()>0){
                has106 = true;     
                if(policyEndorsement.Policy__r.Policy_Suffix_Formula__c <= 4){ 
                    IL106Value = '250%';
                }else if(policyEndorsement.Policy__r.Policy_Suffix_Formula__c == 5){
                    IL106Value = '225%';
                }else if(policyEndorsement.Policy__r.Policy_Suffix_Formula__c == 6){
                    IL106Value = '200%';
                }else if(policyEndorsement.Policy__r.Policy_Suffix_Formula__c == 7){
                    IL106Value = '175%';
                }else if(policyEndorsement.Policy__r.Policy_Suffix_Formula__c == 8){
                    IL106Value = '150%';
                }else if(policyEndorsement.Policy__r.Policy_Suffix_Formula__c == 9){
                    IL106Value = '125%';
                }else{
                    IL106Value = '100%';
                }
            }
        }
        if(endorsementName!=null && (endorsementName.equalsIgnoreCase('IL 107B U.S. Active Duty Military Service Extended Reporting Period Election') ||
                                     endorsementName.equalsIgnoreCase('IL 107C Unlimited Death or Disability Extended Reporting Period Election') ||
                                     endorsementName.equalsIgnoreCase('IL 107D Unlimited Retirement Extended Reporting Period Election Endorsement') )){
            additionalERPPolicySection = true;
        }
        if(endorsementName!=null && (endorsementName.equalsIgnoreCase('IL 190 Cancellation of Coverage') )){
            additionalPremiumSection = true;
            isIL190 = true;
            premium = policyEndorsement.Refund_Amount__c;
            term = policyEndorsement.Term__c;
        }
    }
    public List<SelectOption> getLawyersList(){
        List<SelectOption> lstLawyers = new List<SelectOption>();
        lstLawyers.add(new SelectOption('','-Select-'));
        for(Policy_Lawyer__c lawyer :  [Select id,Lawyer_Name__c from Policy_Lawyer__c where Policy__c =: policyEndorsement.Policy__c]){
            lstLawyers.add(new SelectOption(lawyer.Id,lawyer.Lawyer_Name__c));
            lawyersMap.put(lawyer.Id,lawyer.Lawyer_Name__c);
        }       
        return lstLawyers;
    }
    public PageReference save(){
        SavePoint sp = Database.setSavepoint();
        try{
            System.debug('Line 180 -' + policyEndorsement.Endorsement_Effective_Date__c);
            
            boolean isNew = false;
            if(policyEndorsement.Id == null){
                isNew = true;
            }
            System.debug('Line 186 -' + lawyersMap.get(policyEndorsement.Policy_Lawyer__c));
            
            if(policyEndorsement.Policy_Lawyer__c != null){
                policyEndorsement.Name_Of_Insured__c = lawyersMap.get(policyEndorsement.Policy_Lawyer__c);
            }
            upsert policyEndorsement;
            
            User_Tracking__c userTrack;
            if(isNew){
                userTrack = UserTrackingHandler.createUserTrackingObject('Create', policyEndorsement.Id, policyEndorsement.Name);
            }else{
                userTrack = UserTrackingHandler.createUserTrackingObject('Edit', policyEndorsement.Id, policyEndorsement.Name);
            }
            insert userTrack;
            
            system.debug('termList :: ' + termList);
            if(termList!=null && termList.size()>0){
                for(Policy_Endorsement_Term__c term : termList){
                    if(term.Endorsement__c == null){
                        term.Endorsement__c = policyEndorsement.Id;
                    }
                }
                upsert termList;
            }
            if(fromPage == 'ManageEndorsements'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Sucessfully Saved.'));
                String baseUrl = String.valueOf(System.URL.getOrgDomainUrl().toExternalForm());
                return new PageReference(baseUrl + '/apex/EndorsementEditPage?fromPage=ManageEndorsements&manageIndex='+manageIndex+'&id='+policyEndorsement.Id);
            }else{
                return new PageReference('/'+policyEndorsement.Id);
            }
        }catch(Exception e){
            System.debug('Line 215: ' + e.getStackTraceString());
            System.debug('Line 216: ' +e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
            Database.rollback(sp);   
            return null;
        }
    }
    
    public PageReference saveAndNew(){
        SavePoint sp = Database.setSavepoint();
        try{
            
            boolean isNew = false;
            if(policyEndorsement.Id == null){
                isNew = true;
            }
            if(policyEndorsement.Policy_Lawyer__c != null){
                policyEndorsement.Name_Of_Insured__c = lawyersMap.get(policyEndorsement.Policy_Lawyer__c);
            }
            upsert policyEndorsement;
            
            User_Tracking__c userTrack;
            if(isNew){
                userTrack = UserTrackingHandler.createUserTrackingObject('Create', policyEndorsement.Id, policyEndorsement.Name);
            }else{
                userTrack = UserTrackingHandler.createUserTrackingObject('Edit', policyEndorsement.Id, policyEndorsement.Name);
            }
            insert userTrack;
            
            if(termList!=null && termList.size()>0){
                for(Policy_Endorsement_Term__c term : termList){
                    if(term.Endorsement__c == null){
                        term.Endorsement__c = policyEndorsement.Id;
                    }
                }
                upsert termList;
            }
            if(policyEndorsement.Policy__r.RecordType.Name == 'Application'){
                return new PageReference('/apex/CreateApplicationEndorsementsVFP?id='+policyEndorsement.Policy__c+'&origin=false');
            }else{
                return new PageReference('/apex/CreatePolicyEndorsementsVFP?id='+policyEndorsement.Policy__c+'&origin=true');
            }
            
            
        }catch(Exception e){
             System.debug('Line 262: ' + e.getStackTraceString());
            System.debug('Line 263: ' +e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
            Database.rollback(sp);   
            return null;
        }
    }
    
    
    public PageReference premiumCalculator(){
        SavePoint sp = Database.setSavepoint();
        system.debug('(policyEndorsement.Coverage_Term__c'+policyEndorsement.Coverage_Term__c);
        system.debug('Policy_Series_Effective_Date__c'+policyEndorsement.Policy__r.Policy_Series_Effective_Date__c);
        system.debug('Effective_Date__c'+policyEndorsement.Policy__r.Effective_Date__c);
        
        try{
            if(policyEndorsement.Policy__r.Policy_Series_Effective_Date__c != null){
                policyYears = (Decimal.valueOf(policyEndorsement.Policy__r.Policy_Series_Effective_Date__c.monthsBetween(policyEndorsement.Policy__r.Effective_Date__c) / 12)).round(System.RoundingMode.DOWN);
               system.debug('policyYears277 ' + policyYears);
                system.debug('policyYears278 ' + policyEndorsement.Policy__r.Expiration_Date__c);
                system.debug('policyYears279 ' + policyEndorsement.Endorsement_Effective_Date__c);
                if(policyEndorsement.Policy__r.Expiration_Date__c == policyEndorsement.Endorsement_Effective_Date__c){
                    policyYears += 1;
                }
            }else{
                policyYears = 0;
            }
            system.debug('policyYears286 ' + policyYears);
            system.debug('policyYears287 ' + policyEndorsement.Coverage_Term__c);
            if(endorsementName!=null && (endorsementName.equalsIgnoreCase('IL 107 PURCHASE EXTENDED REPORTING ENDORSEMENT') )){
                //IL106Value = 'N/A';
                Decimal percentageFormula = 1;
                if (policyEndorsement.Coverage_Term__c == '1 Year') {
                    if(policyYears <= 4){  
                        percentageFormula = 1;
                    }else if(policyYears == 5){
                        percentageFormula = 0.95;
                    }else if(policyYears == 6){
                        percentageFormula = 0.9;
                    }else if(policyYears == 7){
                        percentageFormula = 0.85;
                    }else if(policyYears == 8){
                        percentageFormula = 0.80;
                    }else if(policyYears == 9){ 
                        percentageFormula = 0.70;
                    }else{
                        percentageFormula = 0.60;
                    }
                } else if (policyEndorsement.Coverage_Term__c == '3 Years') {
                    if(policyYears <= 4){  
                        percentageFormula = 1.75;
                    }else if(policyYears == 5){
                        percentageFormula = 1.60;
                    }else if(policyYears == 6){
                        percentageFormula = 1.45;
                    }else if(policyYears == 7){
                        percentageFormula = 1.25;
                    }else if(policyYears == 8){
                        percentageFormula = 1.10;
                    }else if(policyYears == 9){ 
                        percentageFormula = 0.9;
                    }else{
                        percentageFormula = 0.7;
                    }
                } else if (policyEndorsement.Coverage_Term__c == '6 Years') {
                    if(policyYears <= 4){  
                        percentageFormula = 2;
                    }else if(policyYears == 5){
                        percentageFormula = 1.85;
                    }else if(policyYears == 6){
                        percentageFormula = 1.65;
                    }else if(policyYears == 7){
                        percentageFormula = 1.45;
                    }else if(policyYears == 8){
                        percentageFormula = 1.25;
                    }else if(policyYears == 9){ 
                        percentageFormula = 1.05;
                    }else{
                        percentageFormula = 0.85;
                    }
                } else if (policyEndorsement.Coverage_Term__c == 'Unlimited') {
                    //percentageFormula = 2.5;
                    //if(has106){
                        if(policyYears <= 4){  // policyEndorsement.Policy__r.Policy_Suffix_Formula__c
                            percentageFormula = 2.5;
                            //IL106Value = '250%';
                        }else if(policyYears == 5){
                            percentageFormula = 2.25;
                            //IL106Value = '225%';
                        }else if(policyYears == 6){
                            percentageFormula = 2;
                            //IL106Value = '200%';
                        }else if(policyYears == 7){
                            percentageFormula = 1.75;
                            //IL106Value = '175%';
                        }else if(policyYears == 8){
                            percentageFormula = 1.5;
                            //IL106Value = '150%';
                        }else if(policyYears == 9){ 
                            percentageFormula = 1.25;
                            //IL106Value = '125%';
                        }else{
                            percentageFormula = 1;
                            //IL106Value = '100%';
                        }
                    /*}else{
                        System.debug(IL106Value);
                        //percentageFormula = policyEndorsement.IL_107_Multiplier__c!=null ? policyEndorsement.IL_107_Multiplier__c/100 : percentageFormula;
                        System.debug(percentageFormula);
                    }*/
                }
                Decimal Original_Premium = (policyEndorsement.Policy__r.Original_Premium__c == null ? 0 : policyEndorsement.Policy__r.Original_Premium__c).round(System.RoundingMode.HALF_UP);
                system.debug(policyEndorsement.Policy__r.Original_Premium__c +'=>'+policyEndorsement.Policy__r.Original_Primary__c);
                system.debug(percentageFormula);
                premium = (Original_Premium * percentageFormula).round(System.RoundingMode.HALF_UP);
                primary = ((policyEndorsement.Policy__r.Original_Primary__c == null ? 0 : policyEndorsement.Policy__r.Original_Primary__c) * percentageFormula).round(System.RoundingMode.HALF_UP);
                excess = ((policyEndorsement.Policy__r.Original_Excess__c == null ? 0 : policyEndorsement.Policy__r.Original_Excess__c) * percentageFormula).round(System.RoundingMode.HALF_UP);
                x5x5 = ((policyEndorsement.Policy__r.Original_5x5__c == null ? 0 : policyEndorsement.Policy__r.Original_5x5__c) * percentageFormula).round(System.RoundingMode.HALF_UP);
                x10x10 = ((policyEndorsement.Policy__r.Original_10x10__c == null ? 0 : policyEndorsement.Policy__r.Original_10x10__c) * percentageFormula).round(System.RoundingMode.HALF_UP);
            }else if(endorsementName!=null && (endorsementName.equalsIgnoreCase('IL 190 Cancellation of Coverage') )){
                System.debug(policyEndorsement.Endorsement_Effective_Date__c);
                Decimal daysProRated = policyEndorsement.Endorsement_Effective_Date__c.daysBetween(policyEndorsement.Policy__r.Expiration_Date__c) + 1;
                System.debug(daysProRated);
                term = daysProRated / (policyEndorsement.Policy__r.Effective_Date__c.daysBetween(policyEndorsement.Policy__r.Expiration_Date__c));
                if(term > 1){
                    term = 1;
                }
                if (policyEndorsement.Override_Rating__c == true) {
                    premium = ((policyEndorsement.Policy__r.Premium__c + policyEndorsement.Override_5_5__c + policyEndorsement.Override_10_10__c)* term).round(System.RoundingMode.HALF_UP);
                } else {
                    premium = (policyEndorsement.Policy__r.Premium__c * term).round(System.RoundingMode.HALF_UP);
                }
            }
            return null;
        }catch(Exception e){
            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
            Database.rollback(sp);   
            return null;
        }
    }
    
    public List<Schema.FieldSetMember> getFields() {
        if(endorsementName.equalsIgnoreCase('IL 107 Purchase Extended Reporting Endorsement')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_107.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 107B U.S. Active Duty Military Service Extended Reporting Period Election')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_107B.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 107C Unlimited Death or Disability Extended Reporting Period Election')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_107C.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 107D Unlimited Retirement Extended Reporting Period Election Endorsement')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_107D.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 120 Limit of Liability Endorsement')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_120.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 151 Name Change Endorsement')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_151.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 151A Address Change Endorsement')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_151A.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 190 Cancellation of Coverage')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_190.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 191 Reinstatement Notice')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_191.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 101A SPECIFIC ATTORNEY(S) EXCLUSION ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_101A.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 101B SPECIFIC ATTORNEY(S) EXCLUSION ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_101B.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 104 SPECIFIC ENTITY EXCLUSIONS ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_104.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 106 AMENDMENT OF EXTENDED REPORTING PERIOD')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_106.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 110 SECURITIES, BOND AND LIMITED PARTNERSHIP EXCLUSION')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_110.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 130 LIMIT OF LIABILITY ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_130.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 150 POLICY ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_150.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 160 CONTRACTUAL LIABILITY EXCLUSION ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_160.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 162 FDCPA ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_162.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 169 SECURITIES EXCLUSION ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_169.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 174A CLAIM AND DISCIPLINARY PROCEEDINGS EXCLUSION ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_174A.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 175 PREDECESSOR FIRM ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_175.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 176A ENTITY ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_176A.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 177 DISCIPLINARY PROCEEDINGS COVERAGE ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_177.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 200 PAST ACTS COVERAGE BUYBACK ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_200.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 210 SEPARATELY OWNED TITLE AGENCY')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_210.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 230 ANNUAL AGGREGATE DEDUCTIBLE ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_230.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 232 ANNUAL AGGREGATE DEDUCTIBLE')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_232.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 234 LOSS ONLY DEDUCTIBLE ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_234.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 260 Past Acts Coverage Endorsement')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_260.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 301 Amendment of EXTENDED REPORTING PERIOD Options Endorsement')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_301.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 261 Claim Expenses Outside the Policy Limits Endorsement')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_261.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 302 AMENDMENT OF EXTENDED REPORTING PERIOD OPTIONS ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_302.getFields();
        }
        return new List<Schema.FieldSetMember>();
    }
    
    public void addRow(){
        termList.add(new Policy_Endorsement_Term__c());
    }
    
    public void removeRow(){
        if( rowIdx > -1 && termList.size() > 0 ){
            if(String.IsNotBlank(termList[rowIdx].Id)){
                delete new Policy_Endorsement_Term__c(Id=termList[rowIdx].Id);
            } 
            
            termList.remove( rowIdx );
        }
    }
}