global class Batch_PaymentSettlements implements Database.Batchable<Sobject>,Schedulable,Database.AllowsCallouts{
    public String query;
    public Batch_PaymentSettlements(){
        
    }
    public Batch_PaymentSettlements(String query){
        this.query = query;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(query != null){
            return Database.getQueryLocator(query);
        }else{
            return Database.getQueryLocator([select Id,ISBAM_Settlement_Date__c,ISBAM_Settlement_Result__c,AcctSeed__Description__c,AcctSeed__Payment_Reference__c,AcctSeed__Account__c,AcctSeed__Amount__c,AcctSeed__GL_Account_Variable_1__c,Name    
                                             from AcctSeed__Cash_Receipt__c 
                                             where CreatedDate = LAST_N_DAYS:30 
                                             and (ISBAM_Settlement_Result__c in ('Ready','Settling') OR ISBAM_Settlement_Result__c =null) and AcctSeed__Payment_Processor__r.Name != 'Cardknox' ]);
        }
    }
    global void execute(Database.BatchableContext BC, List<AcctSeed__Cash_Receipt__c> batch) {
        System.debug(batch.size());
        try{
            List<AcctSeed__Cash_Receipt__c> negativeCashReceipts = new List<AcctSeed__Cash_Receipt__c>();
            List<AcctSeed__Billing_Cash_Receipt__c> billingCashReceipts = new List<AcctSeed__Billing_Cash_Receipt__c>();
            Map<String,List<AcctSeed__Billing_Cash_Receipt__c>> billingCashReceiptsMap = new Map<String,List<AcctSeed__Billing_Cash_Receipt__c>>();
            List<AcctSeed__Billing__c> billingsToUpdate = new List<AcctSeed__Billing__c>();
            Map<Id,Map<Id,Double>> cashReceiptBillingMap = new Map<Id,Map<Id,Double>>();
            Set<Id> allBillingsId = new Set<Id>();
            Map<Id,List<AcctSeed__Billing_Cash_Receipt__c>> bcrMap = new Map<Id,List<AcctSeed__Billing_Cash_Receipt__c>>();
            List<AcctSeed__Billing_Cash_Receipt__c> bcrListToUpdate = new List<AcctSeed__Billing_Cash_Receipt__c>();
            for(AcctSeed__Billing_Cash_Receipt__c  bcr : [select id,AcctSeed__Billing__c ,AcctSeed__Cash_Receipt__c,AcctSeed__Applied_Amount__c  from AcctSeed__Billing_Cash_Receipt__c where AcctSeed__Cash_Receipt__c in: batch]){
                Map<Id,Double> billingIdsMap = new Map<Id,Double>();
                List<AcctSeed__Billing_Cash_Receipt__c> bcrList = new List<AcctSeed__Billing_Cash_Receipt__c>();
                if(bcrMap.containsKey(bcr.AcctSeed__Cash_Receipt__c)){
                    bcrList = bcrMap.get(bcr.AcctSeed__Cash_Receipt__c);
                }
                bcrList.add(bcr);
                bcrMap.put(bcr.AcctSeed__Cash_Receipt__c,bcrList);
                if(cashReceiptBillingMap.containsKey(bcr.AcctSeed__Cash_Receipt__c)){
                    billingIdsMap = cashReceiptBillingMap.get(bcr.AcctSeed__Cash_Receipt__c);
                }
                Double appliedAmount = bcr.AcctSeed__Applied_Amount__c;
                if(billingIdsMap.containsKey(bcr.AcctSeed__Billing__c)){
                    appliedAmount += billingIdsMap.get(bcr.AcctSeed__Billing__c);
                }
                billingIdsMap.put(bcr.AcctSeed__Billing__c,appliedAmount);
                cashReceiptBillingMap.put(bcr.AcctSeed__Cash_Receipt__c,billingIdsMap);
                allBillingsId.add(bcr.AcctSeed__Billing__c);
            }
            Map<Id,AcctSeed__Billing__c> billings = new Map<Id,AcctSeed__Billing__c>([select id,ISBAM_Error__c,ISBAM_Error_Description__c  from AcctSeed__Billing__c where id in: allBillingsId]);
            for(AcctSeed__Cash_Receipt__c receipt : batch){
                try{
                    String paymentReference = receipt.AcctSeed__Payment_Reference__c;
                    if(!paymentReference.startsWith('trn_')){
                        paymentReference = 'trn_' + paymentReference;
                    }
                    ForteTransactionWrapper wrapper = ForteUtil.getTransaction(paymentReference);
                    if(wrapper.status !=null){
                        if(wrapper.status.equalsIgnoreCase('Funded') || wrapper.status.equalsIgnoreCase('Settled')){
                            receipt.ISBAM_Settlement_Result__c = wrapper.status;
                            if(wrapper.settlements.size() > 0){
                                receipt.ISBAM_Settlement_Date__c = Date.valueOf(wrapper.settlements[0].settle_date);
                                receipt.AcctSeed__Description__c = receipt.AcctSeed__Description__c == null ? ('[Settle: ' + wrapper.settlements[0].settle_date + ']') : (receipt.AcctSeed__Description__c + '\n' + ('[Settle: ' + wrapper.settlements[0].settle_date + ']'));
                                    }
                        }else{
                            receipt.ISBAM_Settlement_Result__c = wrapper.status;
                        }
                    }else{
                        receipt.ISBAM_Settlement_Result__c = 'No Information In Forte';
                    }
                    if(wrapper.status !=null && wrapper.status.equalsIgnoreCase('rejected')){
                        AcctSeed__Cash_Receipt__c negativeReceipt = new AcctSeed__Cash_Receipt__c();
                        negativeReceipt.AcctSeed__Account__c=receipt.AcctSeed__Account__c;
                        negativeReceipt.AcctSeed__Payment_Reference__c = 'rejected_'+receipt.AcctSeed__Payment_Reference__c;
                        negativeReceipt.AcctSeed__Amount__c = receipt.AcctSeed__Amount__c*-1;
                        negativeReceipt.AcctSeed__Receipt_Date__c=System.today();
                        
                        negativeReceipt.AcctSeed__GL_Account_Variable_1__c = receipt.AcctSeed__GL_Account_Variable_1__c;
                        negativeCashReceipts.add(negativeReceipt);
                        if(cashReceiptBillingMap.containsKey(receipt.Id)){
                            Map<Id,Double> billingIdsMap = cashReceiptBillingMap.get(receipt.Id);
                            for(Id ids : billingIdsMap.keySet()){
                                AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
                                bill.Id = ids;
                                bill.ISBAM_Error__c = 'Rejected Cash Receipt';
                                bill.ISBAM_Error_Description__c = (bill.ISBAM_Error_Description__c != null ? bill.ISBAM_Error_Description__c + '\nRejected Cash Receipt ' + receipt.Name :  'Rejected Cash Receipt ' + receipt.Name);
                                billingsToUpdate.add(bill);
                                
                                AcctSeed__Billing_Cash_Receipt__c billingCashReciept = new AcctSeed__Billing_Cash_Receipt__c(); 
                                billingCashReciept.AcctSeed__Billing__c = ids;                  
                                billingCashReciept.AcctSeed__Applied_Amount__c = billingIdsMap.get(ids) * -1;
                                List<AcctSeed__Billing_Cash_Receipt__c> billingCashReceiptsTemp = new List<AcctSeed__Billing_Cash_Receipt__c>();
                                if(billingCashReceiptsMap.containsKey(receipt.AcctSeed__Payment_Reference__c)){
                                    billingCashReceiptsTemp = billingCashReceiptsMap.get(receipt.AcctSeed__Payment_Reference__c);
                                }
                                billingCashReceiptsTemp.add(billingCashReciept);
                                billingCashReceiptsMap.put(receipt.AcctSeed__Payment_Reference__c,billingCashReceiptsTemp);
                            }
                        }
                    }
                    if(bcrMap.containsKey(receipt.Id)){
                        for(AcctSeed__Billing_Cash_Receipt__c bcr :  bcrMap.get(receipt.Id)){
                            if(wrapper.status !=null){
                                bcr.ISBAM_Settlement_Result__c = wrapper.status;
                            }else{
                                bcr.ISBAM_Settlement_Result__c = 'No Information In Forte';
                            }
                            bcrListToUpdate.add(bcr);
                        }
                    }
                    
                }catch(Exception e){
                    System.debug('Payment Settlement \n Error :'+e.getMessage() + '\n' + e.getStackTraceString());
                }
            }
            update batch;
            if(bcrListToUpdate.size() > 0){
                update bcrListToUpdate;
            }
            if(negativeCashReceipts.size() > 0){
                insert negativeCashReceipts;
                Map<Id,AcctSeed__Cash_Receipt__c> negativeCRMap = new Map<Id,AcctSeed__Cash_Receipt__c>([select id,AcctSeed__Accounting_Period__c from AcctSeed__Cash_Receipt__c where id in: negativeCashReceipts]);
                for(AcctSeed__Cash_Receipt__c receipt : negativeCashReceipts){
                    String reference = receipt.AcctSeed__Payment_Reference__c;
                    if(billingCashReceiptsMap.containsKey(reference.remove('rejected_'))){
                        for(AcctSeed__Billing_Cash_Receipt__c bcr : billingCashReceiptsMap.get(reference.remove('rejected_'))){
                            bcr.AcctSeed__Cash_Receipt__c = receipt.Id;
                            bcr.AcctSeed__Accounting_Period__c = negativeCRMap.get(receipt.Id).AcctSeed__Accounting_Period__c;
                            billingCashReceipts.add(bcr);
                        }
                    }
                }
                insert billingCashReceipts;
                update billingsToUpdate;
            }
        }catch(Exception e){
            Integration_Log__c log = new Integration_Log__c();
            log.Status__c='Processed With Errors';
            log.Description__c='Payment Settlement \n Error :'+e.getMessage() + '\n' + e.getStackTraceString();
            insert log;
        }
    }
    global void finish(Database.BatchableContext BC) { 
    }
    global void execute(SchedulableContext sc){
        Database.executeBatch(new Batch_PaymentSettlements(),100);
    }
}