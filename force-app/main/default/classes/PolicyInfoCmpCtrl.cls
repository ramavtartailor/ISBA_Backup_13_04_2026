public with sharing class PolicyInfoCmpCtrl {
    
    public class PolicyInfoCmpCtrlException extends Exception {}
    
    @AuraEnabled
    public static wrapper getData(String recId){
        try{
            wrapper wrap = new wrapper(); 
            
            Policy__c pol =[SELECT Id, Mod_261__c, Mod_230__c, Mod_234__c, Treaty_Version__r.Ceded_4x1_Rate__c, Treaty_Version__r.Ceded_Primary_Rate__c, Base_Amount__c, Previous_Policy__c, SCH_Mod__c, GEO_Mod__c, AOP_Factor__c, Claims_Factor__c, ADJ_MOD__c, Firm_Mod__c, Effective_Date__c, Account__r.Name, Account__r.Trade_Name_or_D_B_A__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.Billing_Address_County__r.Name, Account__r.Phone, Account__r.Website__c, Account__r.Establish_Date__c, Firm_Contact__r.FirstName, Firm_Contact__r.LastName, Firm_Contact__r.Phone, Firm_Contact__r.Email,
                            (SELECT Step__c, First_Name_Contact__c, Middle_Name_Contact__c, Last_Name_Contact__c, ISBA_Number__c , ARDC_Number__c, Lawyer__r.Contact__r.MobilePhone, Lawyer__r.Contact__r.Birthdate, Contact_Email__c, Lawyer__r.Contact__r.Personal_Email__c, Prior_Act_Date__c FROM Policy_Lawyers__r ORDER BY Last_Name_Contact__c,First_Name_Contact__c),//lawyer
                            (SELECT Id, Deductible_Factor__c, Coverage_Factor__c, Quote_Expire_Date__c, Deductible__r.Name, Coverage__r.Name, Limits__c, Quote_Final_Premium__c, Final_Quote__c FROM Policy_Quotes__r ORDER BY Coverage__r.Coverage_Max_Per_Claim__c,Coverage__r.Full_Coverage__c ASC),//quotes
                            (SELECT Id, Factor_Mod__c, AOP__c, AOP__r.Name, Percentage__c from Policy_AOPs__r)
                            FROM Policy__c WHERE Id =: recId];
            
            if(pol==null){
                wrap.currPolicy = null;
            }
            else{
                String street = '';
                if(String.isNotBlank(pol.Account__r.BillingStreet)){
                    street = pol.Account__r.BillingStreet;
                    street = street.replaceAll('\n', ' ');
                    street = street.replaceAll('\r', ' ');
                    pol.Account__r.BillingStreet = street;
                }
                wrap.currPolicy = pol;
            }
            
            //AopWrapper aopWrap = new AopWrapper(); 
            //wrap.currPolicyAop = pol.Policy_AOPs__r;
            
            Id previousPolicyId = pol.Previous_Policy__c;
            
            Policy__c prevPol =[SELECT Id, Mod_261__c, Mod_230__c, Mod_234__c, Treaty_Version__r.Ceded_4x1_Rate__c, Treaty_Version__r.Ceded_Primary_Rate__c, Base_Amount__c, SCH_Mod__c, GEO_Mod__c, AOP_Factor__c, Claims_Factor__c, ADJ_MOD__c, Firm_Mod__c, Effective_Date__c, Account__r.Name, Account__r.Trade_Name_or_D_B_A__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.Billing_Address_County__r.Name, Account__r.Phone, Account__r.Website__c, Account__r.Establish_Date__c, Firm_Contact__r.FirstName, Firm_Contact__r.LastName, Firm_Contact__r.Phone, Firm_Contact__r.Email,
                                (SELECT Step__c, First_Name_Contact__c, Middle_Name_Contact__c, Last_Name_Contact__c, ISBA_Number__c , ARDC_Number__c, Lawyer__r.Contact__r.MobilePhone, Lawyer__r.Contact__r.Birthdate, Contact_Email__c, Lawyer__r.Contact__r.Personal_Email__c, Prior_Act_Date__c FROM Policy_Lawyers__r ORDER BY Last_Name_Contact__c,First_Name_Contact__c),//lawyer
                                (SELECT Id, Deductible_Factor__c, Coverage_Factor__c, Quote_Expire_Date__c, Deductible__r.Name, Coverage__r.Name, Limits__c, Quote_Final_Premium__c, Final_Quote__c FROM Policy_Quotes__r ORDER BY Coverage__r.Coverage_Max_Per_Claim__c,Coverage__r.Full_Coverage__c ASC),//quotes
                                (SELECT Id, Factor_Mod__c, AOP__c, AOP__r.Name, Percentage__c from Policy_AOPs__r)
                                FROM Policy__c WHERE Id =: previousPolicyId];
            
            if(prevPol==null){
                wrap.oldPolicy = null;
            }
            else{
                String street = '';
                if(String.isNotBlank(prevPol.Account__r.BillingStreet)){
                    street = prevPol.Account__r.BillingStreet;
                    street = street.replaceAll('\n', ' ');
                    street = street.replaceAll('\r', ' ');
                    prevPol.Account__r.BillingStreet = street;
                }
                wrap.oldPolicy = prevPol;
            }
            
            List<lawyer> currLawyerList = new List<lawyer>();
            
            Map<String, Policy_Lawyer__c> currentLawyersMap = new Map<String, Policy_Lawyer__c>();
            for (Policy_Lawyer__c law : pol.Policy_Lawyers__r) {
                if (String.isNotBlank(law.ARDC_Number__c)) {
                    currentLawyersMap.put(law.ARDC_Number__c, law);
                }
            }
            
            // Build lawyer comparisons
            Set<String> oldArdcs = new Set<String>();
            List<LawyerComparison> lawyerComparisons = new List<LawyerComparison>();
            for (Policy_Lawyer__c prevLaw : prevPol.Policy_Lawyers__r) {
                LawyerComparison lc = new LawyerComparison();
                
                if (currentLawyersMap.containsKey(prevLaw.ARDC_Number__c)) {
                    oldArdcs.add(prevLaw.ARDC_Number__c);
                    Policy_Lawyer__c currLaw = currentLawyersMap.get(prevLaw.ARDC_Number__c);
                    String prevFullName = prevLaw.First_Name_Contact__c+(String.isNotBlank(prevLaw.Middle_Name_Contact__c)?(' '+prevLaw.Middle_Name_Contact__c):'')+' '+prevLaw.Last_Name_Contact__c;
                    String currFullName = currLaw.First_Name_Contact__c+(String.isNotBlank(currLaw.Middle_Name_Contact__c)?(' '+currLaw.Middle_Name_Contact__c):'')+' '+currLaw.Last_Name_Contact__c;
                    lc.firstName = new columnWrap(prevFullName, currFullName != prevFullName, false);
                    lc.step = new columnWrap(prevLaw.Step__c, currLaw.Step__c != prevLaw.Step__c, false);
                    lc.priorActDate = new columnWrap(prevLaw.Prior_Act_Date__c, currLaw.Prior_Act_Date__c != prevLaw.Prior_Act_Date__c, false);
                } else {
                    lc.firstName = new columnWrap(prevLaw.First_Name_Contact__c+(String.isNotBlank(prevLaw.Middle_Name_Contact__c)?(' '+prevLaw.Middle_Name_Contact__c):'')+' '+prevLaw.Last_Name_Contact__c, false, true);
                    lc.step = new columnWrap(prevLaw.Step__c, false, true);
                    lc.priorActDate = new columnWrap(prevLaw.Prior_Act_Date__c, false, true);
                }
                
                lawyerComparisons.add(lc);
            }
            
            wrap.prevPolicyLawyers = lawyerComparisons;
            
            for (Policy_Lawyer__c law : pol.Policy_Lawyers__r) {
                if (!oldArdcs.contains(law.ARDC_Number__c) ) {
                    currLawyerList.add(new lawyer(law, true));
                } else if(String.isNotBlank(law.ARDC_Number__c)){
                    currLawyerList.add(new lawyer(law, false));
                }
            }
            
            List<AopComparison> aopComparisons = new List<AopComparison>();
            
            // Keep original order by using lists instead of maps
            List<Policy_AOP__c> currentAops = pol.Policy_AOPs__r;
            List<Policy_AOP__c> previousAops = prevPol.Policy_AOPs__r;
            
            // First pair matching AOPs by order
            Integer maxLength = Math.max(currentAops.size(), previousAops.size());
            
            for(Integer i = 0; i < maxLength; i++) {
                AopComparison comp = new AopComparison();
                
                // Get current and previous AOPs at this position if they exist
                comp.current = (i < currentAops.size()) ? currentAops[i] : null;
                comp.previous = (i < previousAops.size()) ? previousAops[i] : null;
                
                aopComparisons.add(comp);
            }
            
            wrap.aopComparisons = aopComparisons;
            
            // Get final quote for current policy
            List<Policy_Quote__c> currQuotes = pol.Policy_Quotes__r;
            
            if(!currQuotes.isEmpty() && currQuotes.size()==1){
                wrap.currCoverageFactor = !currQuotes.isEmpty() ? currQuotes[0].Coverage_Factor__c : null;
                wrap.currDeductibleFactor = !currQuotes.isEmpty() ? currQuotes[0].Deductible_Factor__c : null;
            }
            else{
                for(Policy_Quote__c q: currQuotes){
                    if(q.Final_Quote__c){
                        wrap.currCoverageFactor = q.Coverage_Factor__c;
                        wrap.currDeductibleFactor = q.Deductible_Factor__c;
                    }
                }
            }
            
            // Get final quote for previous policy
            List<Policy_Quote__c> prevQuotes = new List<Policy_Quote__c>();
            if (prevPol != null) {
                prevQuotes = prevPol.Policy_Quotes__r;
            }
            
            wrap.currPolicyLawyers = currLawyerList;
            for(Policy_Quote__c q: prevQuotes){
                if(q.Final_Quote__c){
                    wrap.oldCoverageFactor = q.Coverage_Factor__c;
                    wrap.oldDeductibleFactor = q.Deductible_Factor__c;
                }
            }
            
            return wrap;
        }
        catch (Exception e) {
            throw new PolicyInfoCmpCtrlException(e.getMessage());
        }
    }
    
    
    public class wrapper{
        @AuraEnabled
        public Policy__c currPolicy{get; set;}
        @AuraEnabled
        public Policy__c oldPolicy{get; set;}
        //@AuraEnabled public List<List<columnWrap>> prevPolicyLawyers {get;set;}
        @AuraEnabled 
        public List<AopComparison> aopComparisons {get;set;}
        @AuraEnabled
        public list<Policy_AOP__c> currPolicyAop {get;set;}
        @AuraEnabled
        public list<Policy_AOP__c> oldPolicyAop{get;set;}
        @AuraEnabled 
        public List<LawyerComparison> prevPolicyLawyers {get; set;}
        @AuraEnabled 
        public List<lawyer> currPolicyLawyers {get; set;}
        
        @AuraEnabled public Decimal currCoverageFactor {get; set;}
        @AuraEnabled public Decimal currDeductibleFactor {get; set;}
        @AuraEnabled public Decimal oldCoverageFactor {get; set;}
        @AuraEnabled public Decimal oldDeductibleFactor {get; set;}
    }
    
    public class AopComparison{
        @AuraEnabled public Policy_AOP__c current {get; set;}
        @AuraEnabled public Policy_AOP__c previous {get; set;}
    }
    
    public class lawyer {
        @AuraEnabled public Policy_Lawyer__c lawObj {get; set;}
        @AuraEnabled public Boolean isNew {get; set;}
        @AuraEnabled public String priorActDate {get; set;}
        public lawyer(Policy_Lawyer__c lawObj, Boolean isNew) {
            this.lawObj = lawObj;
            this.isNew = isNew;
            this.priorActDate = formatValue(lawObj.get('Prior_Act_Date__c'));
        }
    }
    
    public class LawyerComparison {
        @AuraEnabled public columnWrap firstName {get; set;}
        @AuraEnabled public columnWrap middleName {get; set;}
        @AuraEnabled public columnWrap lastName {get; set;}
        @AuraEnabled public columnWrap step {get; set;}
        @AuraEnabled public columnWrap priorActDate {get; set;}
        public LawyerComparison(){
            this.firstName = null;
            this.middleName = null;
            this.lastName = null;
            this.step = null;
            this.priorActDate = null;
        }
    }
    
    public Class columnWrap{
        @AuraEnabled public object val{get;set;}
        @AuraEnabled public Boolean isChanged {get;set;}
        @AuraEnabled public Boolean isRemoved {get;set;} 
        @AuraEnabled public String formattedVal {get; set;}
        
        public columnWrap(Object val, Boolean isChanged, Boolean isRemoved){
            this.val = null;
            if(String.isNotBlank(String.valueOf(val))){
                this.val = val;
            }            
            this.isChanged = isChanged;
            this.isRemoved = isRemoved;
            this.formattedVal = formatValue(val);
            
        }
    }
    
    Public static String formatValue(Object val) {
        if (val instanceof Date) {
            Date d = (Date)val;
            // Format with leading zeros: MM/dd/yyyy
            return DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0)).format('MM/dd/yyyy');
            
        }
        
        return String.valueOf(val);
    }
}