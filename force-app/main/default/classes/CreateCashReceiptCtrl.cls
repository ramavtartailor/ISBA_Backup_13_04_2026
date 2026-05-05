public class CreateCashReceiptCtrl {
    
    public class CreateCashReceiptCtrlException extends Exception{}
    
    @AuraEnabled
    public Static AcctSeed__Cash_Receipt__c getDetails(String recId){
        try{
            List<Payment_Schedule__c> paymentSchList= [SELECT Id, Payment_Schedule_Type__c, Due_Amount__c, Billing__c, Billing__r.AcctSeed__Customer__c  FROM Payment_Schedule__c WHERE Id=: recId]; 

            if(!paymentSchList.isEmpty()){
                if(paymentSchList[0].Payment_Schedule_Type__c != 'Physical Check'){
                    throw New CreateCashReceiptCtrlException('You can\'t Create Cash Receipt for this Record.');
                }
                AcctSeed__Billing__c bill = [SELECT Id, Policy__c, AcctSeed__Customer__c, AcctSeed__Accounting_Period__c, AcctSeed__Due_Date2__c, AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c, (select id,AcctSeed__GL_Account_Variable_1__c from AcctSeed__Project_Billing_Lines__r )
                                             From AcctSeed__Billing__c WHERE Id =: paymentSchList[0].Billing__c LIMIT 1];
                
                
                AcctSeed__Cash_Receipt__c cashReceipt = new AcctSeed__Cash_Receipt__c();
                cashReceipt.AcctSeed__Receipt_Date__c=System.today();
                cashReceipt.AcctSeed__GL_Account_Variable_1__c = bill.AcctSeed__Project_Billing_Lines__r[0].AcctSeed__GL_Account_Variable_1__c;
                cashReceipt.AcctSeed__Account__c = paymentSchList[0].Billing__r.AcctSeed__Customer__c;
                cashReceipt.AcctSeed__Payment_Type__c = 'Check';
                return cashReceipt;
            }
            else{
                throw New CreateCashReceiptCtrlException('Record Not Found.');
            }
        }
        Catch(Exception e){
             throw New CreateCashReceiptCtrlException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public Static String CreateReceipt(AcctSeed__Cash_Receipt__c receipt, String recId){
        try{
            
            Payment_Schedule__c paymentSch= [SELECT Id, Due_Amount__c, Billing__c, Billing__r.AcctSeed__Customer__c, Billing__r.AcctSeed__Accounting_Period__c, Billing__r.AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c, Billing__r.AcctSeed__Due_Date2__c  FROM Payment_Schedule__c WHERE Id=: recId LIMIT 1];
            
            receipt.AcctSeed__Payment_Reference__c = String.valueOf(receipt.AcctSeed__Check_Number__c);
            receipt.AcctSeed__Check_Number__c = null;
            Insert receipt;
            
            AcctSeed.PostResult[] postResults = AcctSeed.CashReceiptPostService.postCashReceipts(new List<AcctSeed__Cash_Receipt__c>{receipt});
            
            Id accountPeriodId = [SELECT id,name,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM  AcctSeed__Accounting_Period__c  WHERE AcctSeed__Status__c = 'Open' and AcctSeed__Start_Date__c<=TODAY and AcctSeed__End_Date__c>=TODAY limit 1][0].id;
            
            //Createing Billing Cash Receipt
            AcctSeed__Billing_Cash_Receipt__c billingCashReceipt = new AcctSeed__Billing_Cash_Receipt__c();
            billingCashReceipt.AcctSeed__Applied_Amount__c = receipt.AcctSeed__Amount__c;
            billingCashReceipt.AcctSeed__Billing__c = paymentSch.Billing__c;
            billingCashReceipt.AcctSeed__Cash_Receipt__c = receipt.Id;
            billingCashReceipt.AcctSeed__Applied_Date__c = System.today();
            if(paymentSch.Billing__r.AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c > System.today() ){
                billingCashReceipt.AcctSeed__Accounting_Period__c = paymentSch.Billing__r.AcctSeed__Accounting_Period__c;
                billingCashReceipt.AcctSeed__Applied_Date__c = paymentSch.Billing__r.AcctSeed__Due_Date2__c;
            }else{
                billingCashReceipt.AcctSeed__Accounting_Period__c = accountPeriodId;   
            }
            system.debug(billingCashReceipt);
            Insert billingCashReceipt;
            
            AcctSeed.PostResult[] bcrPostResults = AcctSeed.BillingCashReceiptPostService.postBillingCashReceipts(new List<AcctSeed__Billing_Cash_Receipt__c>{billingCashReceipt});
            
            paymentSch.Status__c = 'Paid';
            paymentSch.Paid_Amount__c = receipt.AcctSeed__Amount__c;
            paymentSch.Payment_Reference__c = receipt.AcctSeed__Payment_Reference__c;
            paymentSch.Cash_Receipt__c = receipt.Id;
            Update paymentSch;
            
            return receipt.Id;
        }
        Catch(DmlException e){
            throw New CreateCashReceiptCtrlException(e.getDmlMessage(0));
        }        
    }
    
}