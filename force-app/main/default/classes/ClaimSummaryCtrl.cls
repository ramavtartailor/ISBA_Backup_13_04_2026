public class ClaimSummaryCtrl {
    @AuraEnabled
    public static ClaimSummaryWrapper getClaimDetails(string claimId){
        Map<String,Decimal> claimGLMap = new Map<String,Decimal>();
        Policy_Claim__c objPolicy = [select Id,Name,Claim_Id__c,Unpaid_Reserves_Direct_Loss__c,Unpaid_Reserves_Direct_LAE__c,Payment_Direct_Loss__c,Payment_Direct_LAE__c,Incurred_Direct_Loss__c,Incurred_Direct_LAE__c,
                                     Unpaid_Reserve_Ceded_Loss__c,Unpaid_Reserve_Ceded_LAE__c,Payment_Ceded_Loss__c,Payment_Ceded_LAE__c,Incurred_Ceded_Loss__c,Incurred_Ceded_LAE__c,
                                     Unpaid_Reserves_Retained_Loss__c,Unpaid_Reserves_Retained_LAE__c,Payment_Retained_Loss__c,Payment_Retained_LAE__c,Incurred_Retained_Loss__c,Incurred_Retained_LAE__c,
                                     Per_Claim_Deductible_formula__c,Per_Claim_Deductible_Consumed__c,Per_Claim_Deductible_Balance__c,
                                     Aggregate_Limit_For_All_Claims__c,Policy_Incurred__c,Policy_Remaining_By_All_Claims__c,ULAE__c,
                                     Per_Claim_Limit__c,Claim_Incurred__c,Remaining_Deductible__c,
                                     GL_5010__c,GL_5035__c,GL_2120__c,GL_2160__c,GL_5000__c,GL_5030__c,GL_5020__c,GL_5045__c,GL_5050__c,GL_5031__c,GL_5015__c,GL_5040__c,GL_5051__c
                                     from Policy_Claim__c WHERE Id=: claimId];

        Decimal unpaidReserveDirectLoss = objPolicy.GL_5010__c;
        Decimal unpaidReserveDirectLAE = objPolicy.GL_5035__c; 
        Decimal unpaidReserveCededLoss = objPolicy.GL_5015__c;  
        Decimal unpaidReserveCededLAE = objPolicy.GL_5040__c;   
        Decimal paymentsDirectLoss = objPolicy.GL_5000__c; 
        Decimal paymentsDirectLAE = objPolicy.GL_5030__c; 
        Decimal paymentsCededLoss = objPolicy.GL_5020__c; 
        Decimal paymentsCededLAE = objPolicy.GL_5045__c; 
        
        ClaimSummaryWrapper wrapperObj = new ClaimSummaryWrapper(unpaidReserveDirectLoss,unpaidReserveDirectLAE,unpaidReserveCededLoss,unpaidReserveCededLAE,paymentsDirectLoss,paymentsDirectLAE,paymentsCededLoss,paymentsCededLAE,objPolicy);
        return wrapperObj;
    }
    
    public class ClaimSummaryWrapper {
        @AuraEnabled
        public Decimal unpaidReserveDirectLoss{get;set;}
        @AuraEnabled
        public Decimal paymentsDirectLoss{get;set;}
        @AuraEnabled
        public Decimal incurredDirectLoss{get;set;}
        @AuraEnabled
        public Decimal unpaidReserveDirectLAE{get;set;}
        @AuraEnabled
        public Decimal paymentsDirectLAE{get;set;}
        @AuraEnabled
        public Decimal incurredDirectLAE{get;set;}
        
        @AuraEnabled
        public Decimal unpaidReserveCededLoss{get;set;}
        @AuraEnabled
        public Decimal paymentsCededLoss{get;set;}
        @AuraEnabled
        public Decimal incurredCededLoss{get;set;}
        @AuraEnabled
        public Decimal unpaidReserveCededLAE{get;set;}
        @AuraEnabled
        public Decimal paymentsCededLAE{get;set;}
        @AuraEnabled
        public Decimal incurredCededLAE{get;set;}
        
        @AuraEnabled
        public Decimal unpaidReserveRetainedLoss{get;set;}
        @AuraEnabled
        public Decimal paymentsRetainedLoss{get;set;}
        @AuraEnabled
        public Decimal incurredRetainedLoss{get;set;}
        @AuraEnabled
        public Decimal unpaidReserveRetainedLAE{get;set;}
        @AuraEnabled
        public Decimal paymentsRetainedLAE{get;set;}
        @AuraEnabled
        public Decimal incurredRetainedLAE{get;set;}
        
        @AuraEnabled
        public Policy_Claim__c claimObj{get;set;}
        
        public ClaimSummaryWrapper(Decimal unpaidReserveDirectLoss,Decimal unpaidReserveDirectLAE,Decimal unpaidReserveCededLoss,Decimal unpaidReserveCededLAE,Decimal paymentsDirectLoss,Decimal paymentsDirectLAE,Decimal paymentsCededLoss,Decimal paymentsCededLAE,Policy_Claim__c claimObj){
            this.unpaidReserveDirectLoss = unpaidReserveDirectLoss;
            this.unpaidReserveDirectLAE = unpaidReserveDirectLAE;
            this.unpaidReserveCededLoss = unpaidReserveCededLoss;
            this.unpaidReserveCededLAE = unpaidReserveCededLAE;
            this.paymentsDirectLoss = paymentsDirectLoss;
            this.paymentsDirectLAE = paymentsDirectLAE;
            this.paymentsCededLoss = paymentsCededLoss;
            this.paymentsCededLAE = paymentsCededLAE;
            this.unpaidReserveRetainedLoss  = unpaidReserveDirectLoss + unpaidReserveCededLoss;
            this.paymentsRetainedLoss = paymentsDirectLoss + paymentsCededLoss;
            this.unpaidReserveRetainedLAE = unpaidReserveDirectLAE + unpaidReserveCededLAE;
            this.paymentsRetainedLAE = paymentsDirectLAE + paymentsCededLAE;
            this.incurredDirectLoss = unpaidReserveDirectLoss + paymentsDirectLoss;
            this.incurredDirectLAE = unpaidReserveDirectLAE + paymentsDirectLAE;
            this.incurredCededLoss = unpaidReserveCededLoss + paymentsCededLoss;
            this.incurredCededLAE = unpaidReserveCededLAE + paymentsCededLAE;
            this.incurredRetainedLoss = this.unpaidReserveRetainedLoss + this.paymentsRetainedLoss;
            this.incurredRetainedLAE = this.unpaidReserveRetainedLAE + this.paymentsRetainedLAE;
            
            this.claimObj = claimObj;
        }
    }
}