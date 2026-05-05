public class ClaimDeductibleBillingPDFCtrl {
    public AcctSeed__Billing__c bill {get;set;}
    public List<billingWrapper> pendingBillings {get;set;}
    public List<billingWrapper> completedBillings {get;set;}
    public Date dueDate {get;set;}
    public Decimal deductibleBalance{get;set;}
    public String deductiblePaidPercentage{get;set;}
    
    public ClaimDeductibleBillingPDFCtrl(){
        pendingBillings = new List<billingWrapper>();
        completedBillings = new List<billingWrapper>();
        deductibleBalance = 0.00;
        deductiblePaidPercentage = '0';
        
        if(Apexpages.currentpage().getparameters().get('id') != null){
            String recId = Apexpages.currentpage().getparameters().get('id');
            bill = [SELECT Id,Name,Claim__c,Claim__r.Per_Claim_Deductible__c, Claim__r.Per_Claim_Deductible_Consumed__c,AcctSeed__Date__c,AcctSeed__Due_Date2__c,AcctSeed__Billing_Contact__c,AcctSeed__Billing_Contact__r.Name,Claim__r.Policy__r.Firm_Contact__r.Name,AcctSeed__Customer__r.Name,AcctSeed__Billing_Street__c,AcctSeed__Customer__r.BillingStreet,AcctSeed__Billing_City__c,AcctSeed__Customer__r.BillingCity,
                    AcctSeed__Billing_State__c,AcctSeed__Customer__r.BillingState,AcctSeed__Billing_PostalCode__c,AcctSeed__Customer__r.BillingPostalCode,Policy_Number__c,Claim__r.Name,Policy__r.Deductible_Amount__c,AcctSeed__Balance__c,Payment_Link__c
                    FROM AcctSeed__Billing__c WHERE Id =: recId];
            
            system.debug(bill.Claim__r.Per_Claim_Deductible__c);
            
            deductibleBalance = bill.Claim__r.Per_Claim_Deductible__c - bill.Claim__r.Per_Claim_Deductible_Consumed__c;
            
            deductiblePaidPercentage = String.valueOf((bill.Claim__r.Per_Claim_Deductible_Consumed__c / bill.Claim__r.Per_Claim_Deductible__c * 100).setScale(2))+'%';
            
           
            dueDate = bill.AcctSeed__Date__c.addDays(30);
            
            List<AcctSeed__Billing__c> billings = [SELECT Id,Payment_Link__c,Name,AcctSeed__Date__c,AcctSeed__Balance__c,AcctSeed__Received_Amount__c,Billing_Description__c,(SELECT Id,AcctSeed__Revenue_GL_Account__c,AcctSeed__Revenue_GL_Account__r.Name FROM AcctSeed__Project_Billing_Lines__r) FROM AcctSeed__Billing__c WHERE Claim__c =: bill.Claim__c];
            for(AcctSeed__Billing__c bl: billings){
                Boolean flag1 = false;
                Boolean flag2 = false;
                
                for(AcctSeed__Billing_Line__c ln: bl.AcctSeed__Project_Billing_Lines__r){
                    if(ln.AcctSeed__Revenue_GL_Account__r.Name.Contains('5031')){
                        flag1 = true;
                    }
                    if(ln.AcctSeed__Revenue_GL_Account__r.Name.Contains('5001')){
                        flag2 = true;
                    }
                }
                
                String des = '';
                
                if(flag1 && flag2){
                    des = 'Defense Counsel and Settlement Payments';
                }
                else if(flag1){
                    des = 'Defense Counsel Payment';
                }
                else if(flag2){
                    des = 'Settlement Payment';
                }
                else{
                    des = bl.Billing_Description__c;
                }
                
                if(bl.AcctSeed__Balance__c > 0){
                    pendingBillings.add(new billingWrapper(bl, des));
                }
                else{
                    completedBillings.add(new billingWrapper(bl, des));
                }
            }
        }
    }
    
    public class billingWrapper{
        public AcctSeed__Billing__c bill {get;set;}
        public String description {get;set;}
        
        public billingWrapper(AcctSeed__Billing__c billObj, String des){
            this.bill = billObj;
            this.description = des;
        }
    }
    
}