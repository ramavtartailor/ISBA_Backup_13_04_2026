public class QuickQuoteCtrl {
    public String existingPolicyName{get;set;}
    public String existingPolicyId{get;set;}
    public Policy__c application_policy{get;set;}
    public Policy__c existing_policy{get;set;}
    public Decimal step0{get;set;}
    public Decimal step1{get;set;}
    public Decimal step2{get;set;}
    public Decimal step3{get;set;}
    public Decimal step4{get;set;}
    public Decimal step5{get;set;}
    public Decimal step6{get;set;}
    public Decimal step7{get;set;}
    public Decimal geoMod{get;set;}
    public Decimal aopMod{get;set;}
    public Decimal claimsMod{get;set;}
    public Decimal schMod{get;set;}
    public Decimal firmMod{get;set;}
    public Decimal x5x5{get;set;}
    public Decimal x10x10{get;set;}
    public String selectedLimit{get;set;}
    public String selectedDeductible{get;set;}
    public List<QuickQuoteWrapper> quoteWrapper{get;set;}
    public String errorString{get;set;}
    public boolean isError{get;set;}
    public Integer rowIdx{get;set;}
    public QuickQuoteCtrl(){
        aopMod = claimsMod = schMod = 1;
        step0 = step1 = step2 = step3 = step4 = step5 = step6 = step7 = 0;
        application_policy = new Policy__c();
        application_policy.Effective_Date__c = System.today();
        existing_policy = new Policy__c();
        existing_policy.Effective_Date__c = null;
        quoteWrapper = new List<QuickQuoteWrapper>();
        isError = false;
        errorString = '';
    }
    public List<SelectOption> getPolicyCounty() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        if(application_policy.Effective_Date__c!=null){
            GEO_Factor__c [] threatMappings = [SELECT Id,Name,Master_Factor__r.Default__c,County__c FROM GEO_Factor__c WHERE From_Date__c <=: application_policy.Effective_Date__c and  To_Date__c >=: application_policy.Effective_Date__c and County__r.Only_Claim_Value__c = false ORDER BY Name LIMIT 1000];
            for (GEO_Factor__c threatMapping : threatMappings) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
            }
        }
        return options;
    }
    public List<SelectOption> getLimit () {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select Limit-'));
        Map<Id,ILF_Coverage_Factor__c> threatMappingsLimits = new Map<Id,ILF_Coverage_Factor__c>([SELECT Id,Name,Is_10X10_Coverage__c,Is_5X5_Coverage__c FROM ILF_Coverage_Factor__c WHERE From_Date__c <=: application_policy.Effective_Date__c and  To_Date__c >=: application_policy.Effective_Date__c and OldLimit__c = false ORDER BY Coverage_Max_Per_Claim__c,Full_Coverage__c ASC LIMIT 1000]);
        for (ILF_Coverage_Factor__c threatMapping : threatMappingsLimits.values()) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
        }
        return options;
    }
     public List<SelectOption> getDeductible () {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select Deductible-'));
        Deductible_Factor__c[] threatMappings = [SELECT Id,Name FROM Deductible_Factor__c where From_Date__c <=: application_policy.Effective_Date__c and  To_Date__c >=: application_policy.Effective_Date__c ORDER BY Deductible_Amount__c ASC LIMIT 1000];
        for (Deductible_Factor__c threatMapping : threatMappings) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
        }
        return options;
    }
    public void addQuickQuote(){
        isError = false;
        errorString = '';
        if(application_policy.Effective_Date__c == null){
            isError = true;
            errorString = 'Please select the Effective Date.';
        }else if(String.isBlank(selectedLimit)){
            isError = true;
            errorString = 'Please select the limit.';
        }else if(String.isBlank(selectedDeductible)){
            isError = true;
            errorString = 'Please select the Deductible.';
        }else if( (step0 == null || step0 == 0 ) && (step1 == null || step1 == 0 ) && (step2 == null || step2 == 0 ) && (step3 == null || step3 == 0 ) && (step4 == null || step4 == 0 ) && (step5 == null || step5 == 0 ) && (step6 == null || step6 == 0 ) && (step7 == null || step7 == 0 )){
            isError = true;
            errorString = 'Please add atleast one lawyer';
        }else if(String.isBlank(application_policy.County__c)){
            isError = true;
            errorString = 'Please select the county.';
        }else{
            QuickQuoteWrapper wrapper = new QuickQuoteWrapper();
            
            GEO_Factor__c geoFactor = [SELECT Id,Name,County__c,Region_Factor_Value__c FROM GEO_Factor__c where id =: application_policy.County__c];
            geoMod = geoFactor.Region_Factor_Value__c;
            
            firmMod = 1;
            if(geoMod != null && geoMod >0 ){
                firmMod *= geoMod;
            }
            if(aopMod != null && aopMod >0 ){
                firmMod *= aopMod;
            }
            if(claimsMod != null && claimsMod >0 ){
                firmMod *= claimsMod;
            }
            if(schMod != null && schMod >0 ){
                firmMod *= schMod;
            }
            
            firmMod = firmMod.setScale(2);
            
            ILF_Coverage_Factor__c lowestFactor = [select id,Factor_Value__c
                                                   from ILF_Coverage_Factor__c where Lowest_Coverage__c = true and From_Date__c <=: application_policy.Effective_Date__c and  To_Date__c >=: application_policy.Effective_Date__c];
            
            Master_Factor__c MasterFactorStepObj =  [Select (select id,
                                                             Factor_Value_Step_Rate_0__c,Factor_Value_Step_Rate_1__c ,
                                                             Factor_Value_Step_Rate_2__c,Factor_Value_Step_Rate_3__c ,
                                                             Factor_Value_Step_Rate_4__c,Factor_Value_Step_Rate_5__c ,
                                                             Factor_Value_Step_Rate_6__c,Factor_Value_Step_Rate_7__c 
                                                             from Step_Rate_Factors__r limit 1) 
                                                     from Master_Factor__c 
                                                     where From_Date__c <=: application_policy.Effective_Date__c and  To_Date__c >=: application_policy.Effective_Date__c
                                                     and Factor_Type__c='Step Rate' 
                                                     limit 1];
            
            Master_Factor__c MasterFactorStepObj1 =  [Select (select id,
                                                              Base_Amount__c
                                                              from Base_Factors__r limit 1) 
                                                      from Master_Factor__c 
                                                      where From_Date__c <=: application_policy.Effective_Date__c and  To_Date__c >=: application_policy.Effective_Date__c
                                                      and Factor_Type__c='Base Value' 
                                                      limit 1];
            
            Base_Factor__c baseFactor = MasterFactorStepObj1.Base_Factors__r;
            Step_Rate_Factor__c StepRateobj = MasterFactorStepObj.Step_Rate_Factors__r;
            
            Decimal BaseCoverage = 0,baseILFstep0 = 0;
            Decimal baseILFstep1 = 0,baseILFstep2 = 0;
            Decimal baseILFstep3 = 0,baseILFstep4 = 0;
            Decimal baseILFstep5 = 0,baseILFstep6 = 0,baseILFstep7 = 0; 
            
            ILF_Coverage_Factor__c ilfFactor = [select id,Name,Factor_Value__c,X4x1_Rate__c,Is_5X5_Coverage__c,Coverage_Max_Per_Claim__c,Full_Coverage__c,Is_10X10_Coverage__c,
                                                Percnt_amt_5X5_Step_0__c,Percnt_amt_5X5_Step_1__c,Percnt_amt_5X5_Step_2__c,Percnt_amt_5X5_Step_3__c,Percnt_amt_5X5_Step_4__c,
                                                Percnt_amt_5X5_Step_5__c,Percnt_amt_5X5_Step_6__c,Percnt_amt_5X5_Step_7__c from ILF_Coverage_Factor__c where id=: selectedLimit];
            Deductible_Factor__c deductibleFactor = [select ID,name,Factor_Value__c,Deductible_Amount__c
                                                     from Deductible_Factor__c 
                                                     where ID =: selectedDeductible];
            
            
            wrapper.limits = ilfFactor.Name;
            wrapper.deductible = deductibleFactor.Name;
            
            BaseCoverage = baseFactor.Base_Amount__c * ilfFactor.Factor_Value__c;
            
            Decimal DAS_Amt1 = 0,DAS_Amt2 = 0,DeductibleAmount = 0;
            
            Decimal DASForAllStep = lowestFactor.Factor_Value__c
                * baseFactor.Base_Amount__c 
                * firmMod;
            
            if(step0 != null && step0 >0 ){
                baseILFstep0 = (BaseCoverage *
                                StepRateobj.Factor_Value_Step_Rate_0__c *
                                step0).round(System.RoundingMode.HALF_UP);
                
                DAS_Amt1 = DASForAllStep 
                    * step0 
                    * StepRateobj.Factor_Value_Step_Rate_0__c ;
                DAS_Amt2 = DAS_Amt1 * deductibleFactor.Factor_Value__c;
                DeductibleAmount = (DAS_Amt1 - DAS_Amt2).round(System.RoundingMode.HALF_UP);
            }
            
            if(step1 != null && step1 >0 ){            
                
                baseILFstep1  = (BaseCoverage *
                                 StepRateobj.Factor_Value_Step_Rate_1__c *
                                 step1).round(System.RoundingMode.HALF_UP);
                
                DAS_Amt1 = DASForAllStep 
                    * step1 
                    * StepRateobj.Factor_Value_Step_Rate_1__c ;
                DAS_Amt2 = DAS_Amt1 * deductibleFactor.Factor_Value__c;
                DeductibleAmount = (DAS_Amt1 - DAS_Amt2).round(System.RoundingMode.HALF_UP);
            }
            
            if(step2 != null && step2 >0 ){
                baseILFstep2  = (BaseCoverage *
                                 StepRateobj.Factor_Value_Step_Rate_2__c *
                                 step2 ).round(System.RoundingMode.HALF_UP);
                
                DAS_Amt1 = DASForAllStep 
                    * step2 
                    * StepRateobj.Factor_Value_Step_Rate_2__c ;
                DAS_Amt2 = DAS_Amt1 * deductibleFactor.Factor_Value__c;
                DeductibleAmount = (DAS_Amt1 - DAS_Amt2).round(System.RoundingMode.HALF_UP);
                
            }
            
            if(step3 != null && step3 >0 ){
                baseILFstep3  = (BaseCoverage *
                                 StepRateobj.Factor_Value_Step_Rate_3__c *
                                 step3  ).round(System.RoundingMode.HALF_UP);
                
                DAS_Amt1 = DASForAllStep 
                    * step3 
                    * StepRateobj.Factor_Value_Step_Rate_3__c ;
                DAS_Amt2 = DAS_Amt1 * deductibleFactor.Factor_Value__c;
                DeductibleAmount = (DAS_Amt1 - DAS_Amt2).round(System.RoundingMode.HALF_UP);
            }
            
            if(step4 != null && step4 >0 ){
                baseILFstep4 = (BaseCoverage *
                                StepRateobj.Factor_Value_Step_Rate_4__c *
                                step4  ).round(System.RoundingMode.HALF_UP);
                
                DAS_Amt1 = DASForAllStep 
                    * step4 
                    * StepRateobj.Factor_Value_Step_Rate_4__c ;
                DAS_Amt2 = DAS_Amt1 * deductibleFactor.Factor_Value__c;
                DeductibleAmount = (DAS_Amt1 - DAS_Amt2).round(System.RoundingMode.HALF_UP);
            }
            
            if(step5 != null && step5 >0 ){
                baseILFstep5 = (BaseCoverage *
                                StepRateobj.Factor_Value_Step_Rate_5__c *
                                step5 ).round(System.RoundingMode.HALF_UP);
                
                DAS_Amt1 = DASForAllStep 
                    * step5 
                    * StepRateobj.Factor_Value_Step_Rate_5__c ;
                DAS_Amt2 = DAS_Amt1 * deductibleFactor.Factor_Value__c;
                DeductibleAmount = (DAS_Amt1 - DAS_Amt2).round(System.RoundingMode.HALF_UP);
            }
            
            if(step6 != null && step6 >0 ){
                baseILFstep6 = (BaseCoverage *
                                StepRateobj.Factor_Value_Step_Rate_6__c *
                                step6 ).round(System.RoundingMode.HALF_UP);
                
                DAS_Amt1 = DASForAllStep 
                    * step6 
                    * StepRateobj.Factor_Value_Step_Rate_6__c ;
                DAS_Amt2 = DAS_Amt1 * deductibleFactor.Factor_Value__c;
                DeductibleAmount = (DAS_Amt1 - DAS_Amt2).round(System.RoundingMode.HALF_UP);
            }
            
            if(step7 != null && step7 >0 ){
                baseILFstep7 = (BaseCoverage *
                                StepRateobj.Factor_Value_Step_Rate_7__c *
                                step7 ).round(System.RoundingMode.HALF_UP);
                
                DAS_Amt1 = DASForAllStep 
                    * step7 
                    * StepRateobj.Factor_Value_Step_Rate_7__c ;
                DAS_Amt2 = DAS_Amt1 * deductibleFactor.Factor_Value__c;
                DeductibleAmount = (DAS_Amt1 - DAS_Amt2).round(System.RoundingMode.HALF_UP);
            }
            
            Decimal rateBeforeDeductible = ((baseILFstep0 + baseILFstep1 + baseILFstep2 + baseILFstep3 + baseILFstep4 + baseILFstep5 + baseILFstep6 + baseILFstep7) *  
                                            firmMod).round(System.RoundingMode.HALF_UP);
            
            if(ilfFactor.X4x1_Rate__c != null){
                wrapper.excess = (rateBeforeDeductible/ilfFactor.Factor_Value__c)*ilfFactor.X4x1_Rate__c;
            }
            
            Decimal quotePremium = rateBeforeDeductible - DeductibleAmount;
            
            wrapper.primary = quotePremium - wrapper.excess;
            
            if(ilfFactor.Is_5X5_Coverage__c){
                if(x5x5 != null && x5x5 > 0){
                    wrapper.x5x5 = (x5x5 * (step0 + step1 + step2 + step3 + step4 + step5 + step6 + step7 ));
                }else{
                    wrapper.x5x5 = ( ilfFactor.Percnt_amt_5X5_Step_0__c*step0 + ilfFactor.Percnt_amt_5X5_Step_1__c*step1 +
                                    ilfFactor.Percnt_amt_5X5_Step_2__c*step2 + ilfFactor.Percnt_amt_5X5_Step_3__c*step3 +
                                    ilfFactor.Percnt_amt_5X5_Step_4__c*step4 + ilfFactor.Percnt_amt_5X5_Step_5__c*step5 +
                                    ilfFactor.Percnt_amt_5X5_Step_6__c*step6 + ilfFactor.Percnt_amt_5X5_Step_7__c*step7 );
                }
                quotePremium += wrapper.x5x5;
            }
            
            if(ilfFactor.Is_10X10_Coverage__c){
                if(x10x10 != null && x10x10 > 0){
                    wrapper.x10x10 = (x10x10 * (step0 + step1 + step2 + step3 + step4 + step5 + step6 + step7 ));
                    quotePremium += wrapper.x10x10;
                }
            }
            
            wrapper.premium = quotePremium;
            
            quoteWrapper.add(wrapper);
        }
        
        
    }
    public void removeRow(){
        errorString = '';
        if( rowIdx > -1 && quoteWrapper.size() > 0 ){
            quoteWrapper.remove( rowIdx );
        }
    }
    public void updateCountyFunc(){
        if(application_policy.County__c != null){
            GEO_Factor__c geoFactor = [SELECT Id,Name,County__c,Region_Factor_Value__c FROM GEO_Factor__c where id =: application_policy.County__c];
            geoMod = geoFactor.Region_Factor_Value__c;
        }
    }
    @RemoteAction
    public static List<sObject> getLookupRecord(String likeString , String objectName,String compareId) {
        if(String.IsNotBlank(likeString) && String.IsNotBlank(objectName)){
            likeString = likeString+'%';
            String query = '';
            
            
            query = 'SELECT Id, Name,Account__r.Name,Account__r.Recent_Policy_ID__c FROM '+objectName+' WHERE Name LIKE : likeString and RecordType.Name =\'Policy\'  LIMIT 50';
            List<sObject> lookupRecords = new List<sObject>();
            for(POlicy__c obj : database.query(query)){
                if(obj.Id == obj.Account__r.Recent_Policy_ID__c){
                    lookupRecords.add(obj);
                }
            }
            
            return lookupRecords;
        }
        return null;
    }
    public void updateEffectiveDateFunc(){
        quoteWrapper = new List<QuickQuoteWrapper>();
    }
    public void preSetPolicyDataFunc(){
        if(existingPolicyId != null){
            application_policy.County__c = existing_policy.County__c;
            application_policy.Effective_Date__c = existing_policy.Effective_Date__c;
            selectedLimit = existing_policy.Limit__c;
            selectedDeductible = existing_policy.Deductible_ID__c;
            firmMod = existing_policy.Firm_Mod__c;
            aopMod = existing_policy.AOP_Factor__c;
            geoMod = existing_policy.GEO_Mod__c;
            schMod = existing_policy.SCH_Mod__c;
            
            for(Policy_Lawyer__c lawyer : [select id,Rate_At__c,Step__c from Policy_Lawyer__c where Policy__c =: existingPolicyId]){
                if(lawyer.Step__c == 0){
                    step0 += (lawyer.Rate_At__c/100);
                }else if(lawyer.Step__c == 1){
                    step1 += (lawyer.Rate_At__c/100);
                }else if(lawyer.Step__c == 2){
                    step2 += (lawyer.Rate_At__c/100);
                }else if(lawyer.Step__c == 3){
                    step3 += (lawyer.Rate_At__c/100);
                }else if(lawyer.Step__c == 4){
                    step4 += (lawyer.Rate_At__c/100);
                }else if(lawyer.Step__c == 5){
                    step5 += (lawyer.Rate_At__c/100);
                }else if(lawyer.Step__c == 6){
                    step6 += (lawyer.Rate_At__c/100);
                }else if(lawyer.Step__c == 7){
                    step7 += (lawyer.Rate_At__c/100);
                }
            }
        }
    }
    public void renderPolicyDataFunc(){
        if(existingPolicyId != null){
            existing_policy = [select id,Name,Limit__r.Name,Deductible_ID__r.Name,Effective_Date__c,County__r.Name,Premium__c,County__c,Limit__c,Deductible_ID__c,Firm_Mod__c,AOP_Factor__c,GEO_Mod__c,SCH_Mod__c from Policy__c where id=: existingPolicyId];
        	preSetPolicyDataFunc();
        }
    }
    public class QuickQuoteWrapper{
        public String selectedLimit{get;set;}
        public String selectedDeductible{get;set;}
        public String limits{get;set;}
        public String deductible{get;set;}
        public Decimal primary{get;set;}
        public Decimal excess{get;set;}
        public Decimal x5x5{get;set;}
        public Decimal x10x10{get;set;}
        public Decimal premium{get;set;}
        
        public QuickQuoteWrapper(){
            limits = deductible = '';
            primary = excess = x5x5 = x10x10 = premium = 0;
        }
    }
}