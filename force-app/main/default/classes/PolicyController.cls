public class PolicyController {
    
    @AuraEnabled
    public static polWrapper fetchLawyer(Id policyId) {
        polWrapper wrap = new polWrapper();
        wrap.lawyerList = [SELECT id,Policy__c,Step__c,Rate_At__c
                                             FROM Policy_Lawyer__c
                                             WHERE Policy__c =: policyId ];
        List<Policy__c> polList = [Select Id, Firm_Mod__c, Base_Amount__c FROM Policy__c WHERE ID =: policyId LIMIT 1];
        List<Policy_Quote__c> quoteList = [SELECT Id, Deductible_Factor__c, Coverage_Factor__c,Limits__c, Deductibles_Formula__c,ADJ_MOD__c,Mod_230__c,Mod_234__c,Mod_261__c FROM Policy_Quote__c WHERE Final_Quote__c = True AND Policy__c =: policyId LIMIT 1];
        if(!quoteList.isEmpty()){
            if(quoteList[0].Deductible_Factor__c != null){
                wrap.deductibleFactor = String.valueOf(quoteList[0].Deductible_Factor__c);
            }else{
                wrap.deductibleFactor = 'N/A';
            }
            if(quoteList[0].Coverage_Factor__c != null){
                wrap.limitFactor = String.valueOf(quoteList[0].Coverage_Factor__c);
            }else{
                wrap.limitFactor = 'N/A';
            }
            if(quoteList[0].Limits__c != null){
                wrap.quoteLimit = String.valueOf(quoteList[0].Limits__c);
            }else{
                wrap.quoteLimit = 'N/A';
            }
            if(quoteList[0].Deductibles_Formula__c != null){
                wrap.quoteDeductible = String.valueOf(quoteList[0].Deductibles_Formula__c);
            }else{
                wrap.quoteDeductible = 'N/A';
            }
            if(quoteList[0].ADJ_MOD__c !=null){
                wrap.adjMod = String.valueOf(quoteList[0].ADJ_MOD__c);
            }else{
                wrap.adjMod = 'N/A';
            }
            if(quoteList[0].Mod_230__c!=null){
                wrap.mod_230 = String.valueOf(quoteList[0].Mod_230__c);
            }else{
                wrap.mod_230 = 'N/A';
            }
            if(quoteList[0].Mod_234__c!=null){
                wrap.mod_234 = String.valueOf(quoteList[0].Mod_234__c);
            }else{
                wrap.mod_234 = 'N/A';
            }
            if(quoteList[0].Mod_261__c!=null){
                wrap.mod_261 = String.valueOf(quoteList[0].Mod_261__c);
            }else{
                wrap.mod_261 = 'N/A';
            }
        }
        if(!polList.isEmpty()){
            if(polList[0].Base_Amount__c != null){
                wrap.baseRate = String.valueOf(polList[0].Base_Amount__c);
            }else{
                wrap.baseRate = 'N/A';
            }
            if(polList[0].Firm_Mod__c != null){
                wrap.firmMod = String.valueOf(polList[0].Firm_Mod__c);
            }else{
                wrap.firmMod = 'N/A';
            }
        }
        
        return wrap;
    }
    public class polWrapper{
        @AuraEnabled
        public List<Policy_Lawyer__c> lawyerList {get;set;}
        @AuraEnabled
        public String quoteLimit {get;set;}
        @AuraEnabled
        public String quoteDeductible {get;set;}
        @AuraEnabled 
        public String baseRate {get;set;}
        @AuraEnabled 
        public String limitFactor {get;set;}
        @AuraEnabled 
        public String deductibleFactor {get;set;}
        @AuraEnabled 
        public String firmMod {get;set;}
        @AuraEnabled 
        public String adjMod {get;set;}
        @AuraEnabled 
        public String mod_230 {get;set;}
        @AuraEnabled 
        public String mod_234 {get;set;}
        @AuraEnabled 
        public String mod_261 {get;set;}
    }
}