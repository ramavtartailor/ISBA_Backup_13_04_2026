public class BillingPolicyPremiumPDFExt {
	public List<AcctSeed__Billing_Cash_Receipt__c> bcrList{get;set;}
    public List<AcctSeed__Billing_Line__c > billingLines{get;set;}
    public List<AcctSeed__Billing_Credit_Memo__c> creditMemo{get;set;}
    
    public Boolean isCardKnox{get;set;}
    
	public BillingPolicyPremiumPDFExt(ApexPages.StandardController stdController) {
        String recId = stdController.getId();
        isCardKnox = false;
        AcctSeed__Billing__c bill = [SELECT Id, AcctSeed__Payment_Processor__c, AcctSeed__Payment_Processor__r.Name FROM AcctSeed__Billing__c WHERE Id =: recId];
        if(String.isNotBlank(bill.AcctSeed__Payment_Processor__c) && bill.AcctSeed__Payment_Processor__r.Name == 'Cardknox'){
            isCardKnox = true;
        }
        bcrList = new List<AcctSeed__Billing_Cash_Receipt__c>(
            [select id,Name ,AcctSeed__Applied_Amount__c,AcctSeed__Applied_Date__c,AcctSeed__Status__c,AcctSeed__Cash_Receipt__r.AcctSeed__Receipt_Date__c,
             AcctSeed__Cash_Receipt__r.AcctSeed__Purpose__c from AcctSeed__Billing_Cash_Receipt__c where AcctSeed__Billing__c =: recId ]);
        
        billingLines = new List<AcctSeed__Billing_Line__c>(
            [select id, Name, AcctSeed__Comment__c, AcctSeed__Total__c  from AcctSeed__Billing_Line__c where AcctSeed__Billing__c =: recId ]);
        
        creditMemo = new List<AcctSeed__Billing_Credit_Memo__c>(
            [select id,Name,AcctSeed__Amount__c ,AcctSeed__Applied_Date__c from AcctSeed__Billing_Credit_Memo__c where AcctSeed__Billing_Invoice__c  =: recId ]);
    }
}