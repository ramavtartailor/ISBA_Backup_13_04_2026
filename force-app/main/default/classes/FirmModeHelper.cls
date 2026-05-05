public class FirmModeHelper {
	@AuraEnabled
    public static policyWrap getRecord(String recId){
        policyWrap wrapper = new policyWrap();
        wrapper.previousPolicy = false;
        if(recId != null){
            List<Policy__c> polList = [SELECT Id, RecordType.DeveloperName, Name,Treaty_Version__r.Ceded_Primary_Rate__c,Treaty_Version__r.Ceded_4x1_Rate__c, Previous_Policy__c,
                                       Previous_Policy__r.RecordType.DeveloperName, Previous_Policy__r.Name,Previous_Policy__r.Treaty_Version__r.Ceded_Primary_Rate__c,Previous_Policy__r.Treaty_Version__r.Ceded_4x1_Rate__c,
                                       Previous_Policy__r.SCH_Mod__c, Previous_Policy__r.GEO_Mod__c, Previous_Policy__r.Claims_Factor__c, Previous_Policy__r.AOP_Factor__c, Previous_Policy__r.ADJ_MOD__c, Previous_Policy__r.Firm_Mod__c, 
                                       Previous_Policy__r.Base_Amount__c, Previous_Policy__r.Mod_230__c, Previous_Policy__r.Mod_234__c, Previous_Policy__r.Mod_261__c
                                       FROM  Policy__c 
                                       WHERE Id =: recId LIMIT 1];
            if(!polList.isEmpty()){
                if(String.isNotBlank(polList[0].Previous_Policy__c)){
                    wrapper.oldPolicyObj = (Policy__c) polList[0].getSobject('Previous_Policy__r');
                    wrapper.previousPolicy = true;
                    
                    wrapper.isSaErpPrev = false;
                    if(wrapper.oldPolicyObj.RecordType.DeveloperName == 'SA_ERP'){
                        wrapper.isSaErpPrev = true;
                    }
                    if(wrapper.oldPolicyObj.Treaty_Version__c != null){
                        if(wrapper.oldPolicyObj.Treaty_Version__r.Ceded_Primary_Rate__c != null){
                            wrapper.cpRatePrev = String.valueOf(wrapper.oldPolicyObj.Treaty_Version__r.Ceded_Primary_Rate__c);
                        }else{
                            wrapper.cpRatePrev = 'N/A';
                        }
                        if(wrapper.oldPolicyObj.Treaty_Version__r.Ceded_4x1_Rate__c != null){
                            wrapper.c41RatePrev = String.valueOf(wrapper.oldPolicyObj.Treaty_Version__r.Ceded_4x1_Rate__c);
                        }else{
                            wrapper.c41RatePrev = 'N/A';
                        }
                    }
                }
                
                wrapper.isSaErp = false;
                if(polList[0].RecordType.DeveloperName == 'SA_ERP'){
                    wrapper.isSaErp = true;
                }
                if(polList[0].Treaty_Version__c != null){
                    if(polList[0].Treaty_Version__r.Ceded_Primary_Rate__c != null){
                        wrapper.cpRate = String.valueOf(polList[0].Treaty_Version__r.Ceded_Primary_Rate__c);
                    }else{
                        wrapper.cpRate = 'N/A';
                    }
                    if(polList[0].Treaty_Version__r.Ceded_4x1_Rate__c != null){
                        wrapper.c41Rate = String.valueOf(polList[0].Treaty_Version__r.Ceded_4x1_Rate__c);
                    }else{
                        wrapper.c41Rate = 'N/A';
                    }
                }
            }
            List<Policy_Quote__c> qList = new List<Policy_Quote__c>();
            if(wrapper.previousPolicy){
                qList = [SELECT Id, Final_Quote__c, Deductible_Factor__c, Coverage_Factor__c,Policy__c FROM Policy_Quote__c 
                         WHERE (Policy__c =: recId OR Policy__c =: wrapper.oldPolicyObj.Id) AND Final_Quote__c =: True];
            }
            else{
                qList = [SELECT Id, Final_Quote__c, Deductible_Factor__c, Coverage_Factor__c,Policy__c FROM Policy_Quote__c 
                         WHERE Policy__c =: recId AND Final_Quote__c =: True LIMIT 1];
            }
            if(!qList.isEmpty()){
                for(Policy_Quote__c q: qList){
                    if(q.Policy__c == recId){
                        if(q.Coverage_Factor__c != null){
                            wrapper.lFactor = String.valueOf(q.Coverage_Factor__c);
                        }else{
                            wrapper.lFactor = 'N/A';
                        }
                        if(q.Deductible_Factor__c != null){ 
                            wrapper.dFactor = String.valueOf(q.Deductible_Factor__c);
                        }else{
                            wrapper.dFactor = 'N/A';
                        }
                    }
                    else{
                        if(q.Coverage_Factor__c != null){
                            wrapper.lFactorPrev = String.valueOf(q.Coverage_Factor__c);
                        }else{
                            wrapper.lFactorPrev = 'N/A';
                        }
                        if(q.Deductible_Factor__c != null){ 
                            wrapper.dFactorPrev = String.valueOf(q.Deductible_Factor__c);
                        }else{
                            wrapper.dFactorPrev = 'N/A';
                        }
                    }
                }
            }
            
        }
        system.debug('wrapper------------->'+wrapper);
        return wrapper;
    }
    //Wrapper class for retrieving relational data
    Public class policyWrap{
        @AuraEnabled
        public Boolean isSaErp {get;set;}
        @AuraEnabled
        public String lFactor {get;set;}
        @AuraEnabled
        public String dFactor {get;set;}
        @AuraEnabled
        public String cpRate {get;set;}
        @AuraEnabled
        public String c41Rate {get;set;}
        @AuraEnabled
        public Boolean previousPolicy {get;set;}
        @AuraEnabled
        public Policy__c oldPolicyObj {get;set;}
        @AuraEnabled
        public Boolean isSaErpPrev {get;set;}
        @AuraEnabled
        public String lFactorPrev {get;set;}
        @AuraEnabled
        public String dFactorPrev {get;set;}
        @AuraEnabled
        public String cpRatePrev {get;set;}
        @AuraEnabled
        public String c41RatePrev {get;set;}
        public policyWrap(){
            this.lFactor = 'N/A';
            this.dFactor = 'N/A';
            this.cpRate = 'N/A';
            this.c41Rate = 'N/A';
            this.lFactorPrev = 'N/A';
            this.dFactorPrev = 'N/A';
            this.cpRatePrev = 'N/A';
            this.c41RatePrev = 'N/A';
        }
    }
}