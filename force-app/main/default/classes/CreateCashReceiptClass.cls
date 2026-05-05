public with sharing class CreateCashReceiptClass{

    public class CreateCashReceiptClassException extends Exception{}
    
    @future(Callout = true)
    public static void createReceiptAndAppliedReceipt(String billId, String transactionId, String paymentScheduleId){
        String resp = '';
        List<String> successStatusList = new List<String>();
        List<String> errorStatusList = new List<String>();
        Fiserv_Creds__c crds = Fiserv_Creds__c.getOrgDefaults();
        
        String Bank_Deposit_GL = crds.Fiserv_Funding_GL_Account__c;
        for(String str : crds.Fiserv_Funding_Error_Status__c.split(',')){
            if(String.isNotBlank(str)){
                errorStatusList.add(str.trim());
            }
        }
        for(String str : crds.Fiserv_Funding_Success_Status__c.split(',')){
            if(String.isNotBlank(str)){
                successStatusList.add(str.trim());
            }
        }

        try{
            List<AcctSeed__Billing__c> billings = new List<AcctSeed__Billing__c>([select id,name,AcctSeed__Due_Date2__c ,AcctSeed__Balance__c,AcctSeed__Customer__r.Name,AcctSeed__Payment_Processor__c,Service_Fee__c,
                                   AcctSeed__Customer__c,First_Payment_Date__c,IsPaymentProcessed__c,Mode_Of_Payment__c,
                                   Next_Payment_Base_Amount__c,Next_Payment_Date__c,Next_Payment_Service_Fee__c,AcctSeed__Billing_Street__c,
                                   Payment_Frequency__c,Firm_Name__c,Legacy_Invoice_Id__c,Legacy_Firm_Id__c,AcctSeed__Billing_City__c,
                                   AcctSeed__Customer__r.AccountNumber,AcctSeed__Billing_State__c,AcctSeed__Billing_PostalCode__c,AcctSeed__Accounting_Period__c,AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c,Policy__c,Policy__r.Effective_Date__c,
                                   (select id,AcctSeed__GL_Account_Variable_1__c from AcctSeed__Project_Billing_Lines__r )      
                                   from AcctSeed__Billing__c 
                                   where Id =: billId  AND AcctSeed__Payment_Processor__r.Name = 'Fiserv' Limit 1]);
            
            List<Payment_Schedule__c> paySchedules = new List<Payment_Schedule__c>([SELECT Id, Name, Amount__c, Status__c,Fiserv_Payment_Method__r.Type__c FROM Payment_Schedule__c WHERE Id = :paymentScheduleId AND Status__c != 'Paid' LIMIT 1]); 
            
            if(!billings.isEmpty() && !paySchedules.isEmpty()){
                AcctSeed__Billing__c billing = billings[0];
                Payment_Schedule__c paySchedule = paySchedules[0];
                Decimal baseAmountToPay = paySchedule.Amount__c;
                System.debug('billing.Service_Fee__c => '+billing.Service_Fee__c);
                Decimal ServiceFeeAmount = ((baseAmountToPay/100) * billing.Service_Fee__c).setScale(2);
                Boolean isCC = paySchedule.Fiserv_Payment_Method__r.Type__c == 'Credit_Card' ? true : false;

                String fundingIdPreFix = 'Fiserv CC - '; 
                if(isCC){
                    fundingIdPreFix = 'Fiserv CC - ';
                }else{
                    fundingIdPreFix = 'Fiserv ACH - ';
                }
                //getTransactionDetails
                resp = Fiserv_Utils.getTransaction(transactionId, isCC);
                Map<String,Object> responseMap = (Map<String,Object>) System.JSON.deserializeUntyped(resp);

                if(responseMap.containsKey('respstat') && responseMap.get('respstat').equals('A')){ 
                    String dt = responseMap.containsKey('settledate') ? String.valueOf(responseMap.get('settledate')) : null;
                    String crDate = responseMap.containsKey('capturedate') ? String.valueOf(responseMap.get('capturedate')) : null;
                    crDate = crDate.substring(0, 8);
                    Date captureDate = date.newinstance(Integer.valueOf(crDate.substring(0, 4)), Integer.valueOf(crDate.substring(4, 6)), Integer.valueOf(crDate.substring(6, 8)));
                    Object fundingResp = null;
                    Date dtObj = null;

                    if(dt != null){
                        dt = dt.substring(0, 8);
                        dtObj = date.newinstance(Integer.valueOf(dt.substring(0, 4)), Integer.valueOf(dt.substring(4, 6)), Integer.valueOf(dt.substring(6, 8)));
                        fundingResp = GetFundingBatchId(transactionId, '100', '1', dt, isCC);
                    }
                    
                    Decimal totalAmount = baseAmountToPay + ServiceFeeAmount;
                    Decimal amount = Decimal.valueOf(String.valueOf(responseMap.get('amount')));
                    if(amount != totalAmount){
                        throw new CreateCashReceiptClassException('Amount does not match Please Check the Service Fee Rate');
                    } 
                    AcctSeed__Cash_Receipt__c cashReceipt = new AcctSeed__Cash_Receipt__c();
                    cashReceipt.AcctSeed__Account__c = billing.AcctSeed__Customer__c;
                    cashReceipt.AcctSeed__Payment_Reference__c = transactionId;
                    cashReceipt.AcctSeed__Amount__c = Decimal.valueOf(String.valueOf(responseMap.get('amount')));
                    cashReceipt.AcctSeed__Receipt_Date__c = captureDate;
                    cashReceipt.AcctSeed__Payment_Processor__c = billing.AcctSeed__Payment_Processor__c;
                    cashReceipt.AcctSeed__GL_Account_Variable_1__c = billing.AcctSeed__Project_Billing_Lines__r[0].AcctSeed__GL_Account_Variable_1__c;
                    insert cashReceipt;
                    
                    List<AcctSeed__GL_Account__c> glList = [SELECT Id, Name FROM AcctSeed__GL_Account__c WHERE Name =: label.Adjustment_GL_Account LIMIT 1]; 
                
                    paySchedule.Cash_Receipt__c = cashReceipt.Id;
                    paySchedule.Status__c = 'Paid';
                    paySchedule.Paid_Amount__c = baseAmountToPay;
                    paySchedule.Payment_Reference__c = transactionId;

                    Id accountPeriodId = [SELECT id,name,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM  AcctSeed__Accounting_Period__c  WHERE AcctSeed__Status__c = 'Open' and AcctSeed__Start_Date__c<=:captureDate and AcctSeed__End_Date__c>=:captureDate limit 1][0].id;
                    system.debug('accountPeriodId+'+accountPeriodId);
                    AcctSeed__Billing_Cash_Receipt__c billingCashReceipt = new AcctSeed__Billing_Cash_Receipt__c();
                    billingCashReceipt.AcctSeed__Applied_Amount__c = cashReceipt.AcctSeed__Amount__c;
                    billingCashReceipt.AcctSeed__Billing__c= billing.id;
                    billingCashReceipt.AcctSeed__Cash_Receipt__c=cashReceipt.Id;
                    billingCashReceipt.AcctSeed__Accounting_Period__c=accountPeriodId;
                    billingCashReceipt.AcctSeed__Applied_Date__c = captureDate;
                    billingCashReceipt.AcctSeed__Adjustment_GL_Account__c = glList[0].Id;
                    billingCashReceipt.AcctSeed__Adjustment_Amount__c = -ServiceFeeAmount;
                    
                    if(billing.AcctSeed__Accounting_Period__r.AcctSeed__Start_Date__c > captureDate ){
                        billingCashReceipt.AcctSeed__Accounting_Period__c = billing.AcctSeed__Accounting_Period__c;
                        billingCashReceipt.AcctSeed__Applied_Date__c = billing.AcctSeed__Due_Date2__c;
                    }else{
                        billingCashReceipt.AcctSeed__Accounting_Period__c = accountPeriodId;   
                    }
                    
                    system.debug('billingCashReceipt+'+billingCashReceipt);
                    insert billingCashReceipt;
                    Update paySchedule;

                    if(fundingResp != null){
                        Map<String,Object> transObj = (Map<String, Object>) fundingResp;
                        String fundingId =  fundingIdPreFix + String.valueOf(transObj.get('fundingtxnid'));
                        Set<String> transIds = new Set<String>();
                        
                        if( successStatusList.contains(String.valueOf(transObj.get('status'))) || errorStatusList.contains(String.valueOf(transObj.get('status'))) ){
                            if(transObj.containsKey('retref') && transObj.get('retref') != null ){
                                if(errorStatusList.contains(String.valueOf(transObj.get('status')))){
                                    //create Negetive Cr and Brc and Update Payment Schedule;
                                    transIds.add(('rejected_'+String.valueOf(transObj.get('retref'))));
                                    
                                    
                                    Batch_FiservFundingBankDeposit b = new Batch_FiservFundingBankDeposit();

                                    Batch_FiservFundingBankDeposit.paymentFailed(String.valueOf(transObj.get('retref')), dtObj, JSON.serialize(transObj));
                                }
                                
                                transIds.add(String.valueOf(transObj.get('retref')));
                            }
                        }

                        List<AcctSeed__Bank_Deposit__c> bankDepositList = new List<AcctSeed__Bank_Deposit__c>([SELECT Id,AcctSeed__Deposit_Reference__c FROM AcctSeed__Bank_Deposit__c WHERE AcctSeed__Deposit_Reference__c =: fundingId LIMIT 1]);

                        if(bankDepositList.isEmpty()){
                            AcctSeed__Bank_Deposit__c bankDeposit = new AcctSeed__Bank_Deposit__c(
                                AcctSeed__Cleared_Date__c = dtObj,
                                AcctSeed__Deposit_Date__c = dtObj,
                                AcctSeed__Bank_Account__c = Bank_Deposit_GL,
                                AcctSeed__Deposit_Reference__c  = fundingId
                            );
                            insert bankDeposit;
                            bankDepositList.add(bankDeposit);
                        }

                        List<AcctSeed__Cash_Receipt__c> crList = new List<AcctSeed__Cash_Receipt__c>([SELECT Id, AcctSeed__Payment_Reference__c FROM AcctSeed__Cash_Receipt__c WHERE AcctSeed__Payment_Reference__c IN : transIds]);

                        List<Id> crIds = new List<Id>();
                        for(AcctSeed__Cash_Receipt__c cr: crList){
                            if(transIds.contains(cr.AcctSeed__Payment_Reference__c)){
                                crIds.add(cr.Id);
                            }
                        }
                        if(!crIds.isEmpty()){
                            AcctSeed__Bank_Deposit__c bankDeposit = bankDepositList[0];
                            AcctSeed.ServiceResult sr = AcctSeed.BankDeposit.associate(bankDeposit.Id, crIds);
                            System.debug('sr => '+sr);
                        }

                    }
                }
            }   

        }
        catch(DmlException e){
            System.debug('Error => '+e.getDmlMessage(0)+'\nAt => '+e.getLineNumber());
            Integration_Log__c log = new Integration_Log__c();
            log.Billing__c = billId;
            log.Status__c = 'Processed With Errors';
            log.JSON_Body__c = resp;
            log.Description__c = 'Error => '+ e.getDmlMessage(0) +''+ e.getStackTraceString();
            Insert log;
        }
        catch(Exception e){
            System.debug('Error => '+e.getMessage()+'\nAt => '+e.getLineNumber());
            Integration_Log__c log = new Integration_Log__c();
            log.Billing__c = billId;
            log.JSON_Body__c = resp;
            log.Status__c = 'Processed With Errors';
            log.Description__c = 'Error => '+ e.getMessage() +''+ e.getStackTraceString();
            Insert log;
        }
    }

    public static Object GetFundingBatchId(String transactionId, String lmt, String pageNo, String dt, Boolean isCC) {
        String resp = '';
        
        if(isCC){
            resp = Fiserv_Utils.getCCFunding(dt, lmt, pageNo);   
        }else{
            resp = Fiserv_Utils.getACHFunding(dt, lmt, pageNo);
        }

        if(String.isNotBlank(resp) && resp.contains(transactionId)){
            Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(resp);
            if(result.containsKey('errormsg')){
                return null;
            }
            if(result.containsKey('txns')){
                List<Object> transactions = (List<Object>)result.get('txns');
                if(!transactions.isEmpty()){
                    for(Object obj : transactions){
                        Map<String, Object> transObj = (Map<String, Object>) obj;
                        if(transObj.containsKey('retref') && transObj.get('retref') == transactionId){
                            return obj;
                        }
                    }
                }
            }
        }
        else if(String.isNotBlank(resp) && !resp.contains('errormsg')){
            Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(resp);
            if(result.containsKey('perPageSize')){
                System.debug('result.get(perPageSize) => '+ result.get('perPageSize'));
                
                if(result.containsKey('currentPageSize') && result.get('perPageSize') == result.get('currentPageSize')){
                    System.debug('result.get(currentPageSize) => '+ result.get('currentPageSize'));
                    return GetFundingBatchId(transactionId, lmt, pageNo+1 , dt, isCC);
                }
                else{
                    return null;
                }
            }
        }
        return null;
    }
}