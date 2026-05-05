public class LossRatioCtrl {
    
    @AuraEnabled
    public static wrapper checkSobjectType(String recordId) {
        if(String.isNotBlank(recordId)){
            if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'Policy__c'){ 
                System.debug('recordId'+recordId);
                return LossRatioCtrl.getPolicyRecord(recordId);
            }else if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'Account'){
                System.debug('recordId'+recordId);
                return LossRatioCtrl.getAccountPolicyRecord(recordId);
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static wrapper getAccountPolicyRecord(String accountId) {
        
        if(String.isNotBlank(accountId)){
            Decimal totalPremium = 0;
            for(Policy__c pol : [SELECT ID,Premium__c FROM Policy__c WHERE Account__c=: accountId AND RecordType.Name='Policy' ]){
                if(pol.Premium__c != Null){
                    totalPremium += pol.Premium__c;
                }
            }
            
            Decimal incurredExpense = 0;
            Decimal incurredIndeminty = 0;
            Decimal paymentExpense = 0;
            Decimal paymentIndeminty = 0;
            for(Policy_Claim__c claim : [SELECT ID,LossPay__c,Loss_Res__c,LAEPay__c,LAE_Res__c FROM Policy_Claim__c WHERE Account__c=: accountId ]){
                if(claim.LossPay__c != null || claim.Loss_Res__c != null){
                    incurredExpense += claim.LossPay__c + claim.Loss_Res__c;
                    paymentExpense += claim.LossPay__c;
                }
                if(claim.LAEPay__c != null || claim.LAE_Res__c != null){
                    incurredIndeminty += claim.LAEPay__c + claim.LAE_Res__c;
                    paymentIndeminty += claim.LAEPay__c; 
                }
            }
            
            Decimal incurredTotal = incurredExpense + incurredIndeminty;
            Decimal incurredPremium  = 0;
            Decimal paymentTotal = paymentExpense + paymentIndeminty;
            Decimal paymentPremium  = 0;
            
            if(totalPremium > 0 && incurredTotal > 0){
                incurredPremium = (incurredTotal / totalPremium);
            }
            
            if(totalPremium > 0 && paymentTotal > 0){ 
                paymentPremium = (paymentTotal / totalPremium);
            }
            
            wrapper obj = new wrapper(totalPremium,incurredExpense,incurredIndeminty,incurredTotal,incurredPremium,paymentExpense,paymentIndeminty,paymentTotal,paymentPremium);
            return obj;
        }
        return null;
    }
    
    
    @AuraEnabled
    public static wrapper getPolicyRecord(String policyId) {
        if(String.isNotBlank(policyId)){
            Policy__c pol = [SELECT ID,Premium__c,Account__c FROM Policy__c WHERE Id=: policyId];
            return getAccountPolicyRecord(pol.Account__c);
        }
        return null;
    }
    
    
    public class wrapper {
        
        @AuraEnabled
        Public Decimal totalPremium {get;set;}
        
        @AuraEnabled
        Public Decimal incurredExpense {get;set;}
        
        @AuraEnabled
        Public Decimal incurredIndeminty {get;set;}
        
        @AuraEnabled
        Public Decimal incurredTotal {get;set;}
        
        @AuraEnabled
        Public Decimal incurredPremium {get;set;}
        
        @AuraEnabled
        Public Decimal paymentExpense {get;set;}
        
        @AuraEnabled
        Public Decimal paymentIndeminty {get;set;}
        
        @AuraEnabled
        Public Decimal paymentTotal {get;set;}
        
        @AuraEnabled
        Public Decimal paymentPremium {get;set;}
        
        public wrapper(Decimal totalPremium,
                       Decimal incurredExpense, Decimal incurredIndeminty, Decimal incurredTotal, Decimal incurredPremium,
                       Decimal paymentExpense, Decimal paymentIndeminty, Decimal paymentTotal, Decimal paymentPremium
                      ){
                          
                          this.totalPremium = totalPremium;
                          this.incurredExpense = incurredExpense;
                          this.incurredIndeminty =  incurredIndeminty;
                          this.incurredTotal = incurredTotal;
                          this.incurredPremium = incurredPremium;
                          this.paymentExpense = paymentExpense;
                          this.paymentIndeminty =  paymentIndeminty;
                          this.paymentTotal = paymentTotal;
                          this.paymentPremium = paymentPremium;
                      }
        
    }
}