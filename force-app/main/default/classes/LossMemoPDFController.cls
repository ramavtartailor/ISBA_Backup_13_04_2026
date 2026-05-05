public class LossMemoPDFController {
    
    public Policy_Claim__c objPolicy {get;set;}
    public ClaimSummaryWrapper wrapperObj {get;set;}
    
    public LossMemoPDFController(ApexPages.StandardController con){
        
        objPolicy = [SELECT Id,Name,Occur_Date__c,Claim_Made_Date__c,GL_5010__c,GL_5035__c,GL_5000__c,GL_5030__c,Report_Date__c,Claimant__c,
                     Policy__r.County__r.Name,Policy__r.Name,Policy__r.Effective_Date__c,Policy__r.Expiration_Date__c,Policy__r.Limits__c,
                     Policy__r.Deductible__c,Policy__r.Firm_Name_History__c,GL_5020__c,GL_5045__c,Policy__r.Treaty_Version__r.Reinsurance_Limit__c,Policy__r.Deductible_ID__r.Deductible_Amount__c
                     FROM Policy_Claim__c WHERE Id=:con.getId()];
        
        Decimal unpaidReserveDirectLoss = objPolicy.GL_5010__c;
        Decimal unpaidReserveDirectLAE = objPolicy.GL_5035__c; 
        Decimal paymentsDirectLoss = objPolicy.GL_5000__c; 
        Decimal paymentsDirectLAE = objPolicy.GL_5030__c; 
        Decimal totalPaid = paymentsDirectLoss + paymentsDirectLAE;
        Decimal totalReserves = unpaidReserveDirectLoss + unpaidReserveDirectLAE;
        Decimal retension = (objPolicy.Policy__r.Treaty_Version__r.Reinsurance_Limit__c != null ? objPolicy.Policy__r.Treaty_Version__r.Reinsurance_Limit__c : 0) + (objPolicy.Policy__r.Deductible_ID__r.Deductible_Amount__c != null ? objPolicy.Policy__r.Deductible_ID__r.Deductible_Amount__c : 0) ;
        Decimal amountPreviouslyRequested = Math.abs(objPolicy.GL_5020__c) + Math.abs(objPolicy.GL_5045__c);
        wrapperObj = new ClaimSummaryWrapper(unpaidReserveDirectLoss,unpaidReserveDirectLAE,paymentsDirectLoss,paymentsDirectLAE,totalPaid,totalReserves,retension,amountPreviouslyRequested);
    }
    
    
    public class ClaimSummaryWrapper {
        public Decimal unpaidReserveDirectLoss{get;set;}
        public Decimal paymentsDirectLoss{get;set;}
        public Decimal unpaidReserveDirectLAE{get;set;}
        public Decimal paymentsDirectLAE{get;set;}
        public Decimal totalPaid {get;set;}
        public Decimal totalReserves {get;set;}
        public Decimal retension{get;set;}
        public Decimal cededPaid{get;set;}
        public Decimal amountPreviouslyRequested{get;set;}
        public Decimal amountDueNow{get;set;}
        
        public ClaimSummaryWrapper(Decimal unpaidReserveDirectLoss,Decimal unpaidReserveDirectLAE,Decimal paymentsDirectLoss,Decimal paymentsDirectLAE,Decimal totalPaid,Decimal totalReserves,Decimal retension,Decimal amountPreviouslyRequested){
            this.unpaidReserveDirectLoss = unpaidReserveDirectLoss;
            this.unpaidReserveDirectLAE = unpaidReserveDirectLAE;
            this.paymentsDirectLoss = paymentsDirectLoss;
            this.paymentsDirectLAE = paymentsDirectLAE;
            this.totalPaid = totalPaid;
            this.totalReserves = totalReserves;
            this.retension = retension;
            this.cededPaid = ((paymentsDirectLoss + paymentsDirectLAE - retension) > 0) ? (paymentsDirectLoss + paymentsDirectLAE - retension) : 0;
            this.amountPreviouslyRequested = amountPreviouslyRequested;
            this.amountDueNow = this.cededPaid - this.amountPreviouslyRequested;
        }
    }
}