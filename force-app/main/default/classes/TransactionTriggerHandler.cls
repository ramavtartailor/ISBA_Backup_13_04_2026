public class TransactionTriggerHandler{    
    public static void  onBeforeInsert(List<AcctSeed__Transaction__c> newList){
        populateClaimAndPolicyOnTransaction(newList);
    }
    public static void  onAfterInsert(List<AcctSeed__Transaction__c> newList,Map<Id,AcctSeed__Transaction__c> newMap){
        updateClaimPolicySummaryFields(newList);
    }
    public static void  onBeforeDelete(List<AcctSeed__Transaction__c> oldList){
        updateClaimPolicySummaryFields(oldList);
    }
    public static void populateClaimAndPolicyOnTransaction(List<AcctSeed__Transaction__c> newList){
        Set<Id> jeLinesIds = new Set<Id>();
        Set<Id> billLinesIds = new Set<Id>();
        Set<Id> cashReceiptIds = new Set<Id>();
        Set<Id> billcashReceiptIds = new Set<Id>();
        Set<Id> payableLineIds = new Set<Id>();
        Set<Id> cashDisbursementIds = new Set<Id>();
        Set<Id> amortizationIds = new Set<Id>();
        for(AcctSeed__Transaction__c tran : newList){
            if(tran.AcctSeed__Journal_Entry_Line__c!=null){
                jeLinesIds.add(tran.AcctSeed__Journal_Entry_Line__c);
            }else if(tran.AcctSeed__Billing_Line__c!=null){
                billLinesIds.add(tran.AcctSeed__Billing_Line__c);
            }else if(tran.AcctSeed__Cash_Receipt__c!=null){
                cashReceiptIds.add(tran.AcctSeed__Cash_Receipt__c);
            }else if(tran.AcctSeed__Billing_Cash_Receipt__c!=null){
                billcashReceiptIds.add(tran.AcctSeed__Billing_Cash_Receipt__c);
            }else if(tran.AcctSeed__Account_Payable_Line__c!=null){
                payableLineIds.add(tran.AcctSeed__Account_Payable_Line__c);
            }else if(tran.AcctSeed__Cash_Disbursement__c!=null){
                cashDisbursementIds.add(tran.AcctSeed__Cash_Disbursement__c);
            }else if(tran.AcctSeed__Scheduled_Revenue_Expense__c!=null){
                amortizationIds.add(tran.AcctSeed__Scheduled_Revenue_Expense__c);
            }
        }
        
        Map<Id,AcctSeed__Journal_Entry_Line__c> jeLinesMap = new Map<Id,AcctSeed__Journal_Entry_Line__c>([select id,AcctSeed__Journal_Entry__r.AS_Transaction__c,AcctSeed__Journal_Entry__r.Claim__c,AcctSeed__Journal_Entry__r.Policy__c,AcctSeed__Journal_Entry__r.Claim__r.Policy__c from AcctSeed__Journal_Entry_Line__c where Id=:jeLinesIds and (AcctSeed__Journal_Entry__r.Claim__c!=null or AcctSeed__Journal_Entry__r.Policy__c!=null)]);
        Map<Id,AcctSeed__Billing_Line__c> billLinesMap = new Map<Id,AcctSeed__Billing_Line__c>([select id,AcctSeed__Billing__r.AS_Transaction__c,AcctSeed__Billing__r.Claim__c,AcctSeed__Billing__r.Policy__c,AcctSeed__Billing__r.Claim__r.Policy__c from AcctSeed__Billing_Line__c where Id=:billLinesIds and (AcctSeed__Billing__r.Claim__c!=null or AcctSeed__Billing__r.Policy__c!=null)]);
        Map<Id,AcctSeed__Cash_Receipt__c> cashReceiptMap = new Map<Id,AcctSeed__Cash_Receipt__c>([select id,Claim__c,Claim__r.Policy__c from AcctSeed__Cash_Receipt__c where Id=:cashReceiptIds and (Claim__c!=null)]);
        Map<Id,AcctSeed__Billing_Cash_Receipt__c> billingCashReceiptMap = new Map<Id,AcctSeed__Billing_Cash_Receipt__c>([select id,AcctSeed__Billing__r.Claim__c,AcctSeed__Billing__r.Policy__c,AcctSeed__Billing__r.Claim__r.Policy__c from AcctSeed__Billing_Cash_Receipt__c where Id=:billcashReceiptIds and (AcctSeed__Billing__r.Claim__c!=null or AcctSeed__Billing__r.Policy__c!=null)]);
        Map<Id,AcctSeed__Account_Payable_Line__c> payableLineMap = new Map<Id,AcctSeed__Account_Payable_Line__c>([select id,AcctSeed__Account_Payable__r.AS_Transaction__c,AcctSeed__Account_Payable__r.Claim__c,AcctSeed__Account_Payable__r.Policy__c,AcctSeed__Account_Payable__r.Claim__r.Policy__c from AcctSeed__Account_Payable_Line__c where Id=:payableLineIds and (AcctSeed__Account_Payable__r.Claim__c!=null or AcctSeed__Account_Payable__r.Policy__c!=null)]);
        Map<Id,AcctSeed__Cash_Disbursement__c> cashDisbursementMap = new Map<Id,AcctSeed__Cash_Disbursement__c>([select id,Claim__c,Policy__c,Claim__r.Policy__c from AcctSeed__Cash_Disbursement__c where Id=:cashDisbursementIds and (Claim__c!=null or Policy__c!=null)]);
        Map<Id,AcctSeed__Scheduled_Revenue_Expense__c> amortizationMap = new Map<Id,AcctSeed__Scheduled_Revenue_Expense__c>([select id,Policy__c,Date__c,AS_Transaction__c from AcctSeed__Scheduled_Revenue_Expense__c where Id=:amortizationIds and ( Policy__c!=null)]);
    	
        for(AcctSeed__Transaction__c tran : newList){
            if(tran.AcctSeed__Journal_Entry_Line__c!=null && jeLinesMap.containsKey(tran.AcctSeed__Journal_Entry_Line__c)){
                tran.Policy__c = jeLinesMap.get(tran.AcctSeed__Journal_Entry_Line__c).AcctSeed__Journal_Entry__r.Policy__c;
                if(tran.Policy__c == null){
                    tran.Policy__c = jeLinesMap.get(tran.AcctSeed__Journal_Entry_Line__c).AcctSeed__Journal_Entry__r.Claim__r.Policy__c;
                }
                tran.Claim__c = jeLinesMap.get(tran.AcctSeed__Journal_Entry_Line__c).AcctSeed__Journal_Entry__r.Claim__c;
                tran.AS_Transaction__c = jeLinesMap.get(tran.AcctSeed__Journal_Entry_Line__c).AcctSeed__Journal_Entry__r.AS_Transaction__c;
            }else if(tran.AcctSeed__Billing_Line__c!=null && billLinesMap.containsKey(tran.AcctSeed__Billing_Line__c)){
                tran.Policy__c = billLinesMap.get(tran.AcctSeed__Billing_Line__c).AcctSeed__Billing__r.Policy__c;
                if(tran.Policy__c == null){
                    tran.Policy__c = billLinesMap.get(tran.AcctSeed__Billing_Line__c).AcctSeed__Billing__r.Claim__r.Policy__c;
                }
                tran.Claim__c = billLinesMap.get(tran.AcctSeed__Billing_Line__c).AcctSeed__Billing__r.Claim__c;
                tran.AS_Transaction__c = billLinesMap.get(tran.AcctSeed__Billing_Line__c).AcctSeed__Billing__r.AS_Transaction__c;
            }else if(tran.AcctSeed__Cash_Receipt__c!=null && cashReceiptMap.containsKey(tran.AcctSeed__Cash_Receipt__c)){
                tran.Claim__c = cashReceiptMap.get(tran.AcctSeed__Cash_Receipt__c).Claim__c;
                tran.Policy__c = cashReceiptMap.get(tran.AcctSeed__Cash_Receipt__c).Claim__r.Policy__c;
            }else if(tran.AcctSeed__Billing_Cash_Receipt__c!=null && billingCashReceiptMap.containsKey(tran.AcctSeed__Billing_Cash_Receipt__c)){
                tran.Policy__c = billingCashReceiptMap.get(tran.AcctSeed__Billing_Cash_Receipt__c).AcctSeed__Billing__r.Policy__c;
                if(tran.Policy__c == null){
                    tran.Policy__c = billingCashReceiptMap.get(tran.AcctSeed__Billing_Cash_Receipt__c).AcctSeed__Billing__r.Claim__r.Policy__c;
                }
                tran.Claim__c = billingCashReceiptMap.get(tran.AcctSeed__Billing_Cash_Receipt__c).AcctSeed__Billing__r.Claim__c;
            }else if(tran.AcctSeed__Account_Payable_Line__c!=null && payableLineMap.containsKey(tran.AcctSeed__Account_Payable_Line__c)){
                tran.Policy__c = payableLineMap.get(tran.AcctSeed__Account_Payable_Line__c).AcctSeed__Account_Payable__r.Policy__c;
                if(tran.Policy__c == null){
                    tran.Policy__c = payableLineMap.get(tran.AcctSeed__Account_Payable_Line__c).AcctSeed__Account_Payable__r.Claim__r.Policy__c;
                }
                tran.Claim__c = payableLineMap.get(tran.AcctSeed__Account_Payable_Line__c).AcctSeed__Account_Payable__r.Claim__c;
                tran.AS_Transaction__c = payableLineMap.get(tran.AcctSeed__Account_Payable_Line__c).AcctSeed__Account_Payable__r.AS_Transaction__c;
            }else if(tran.AcctSeed__Cash_Disbursement__c!=null && cashDisbursementMap.containsKey(tran.AcctSeed__Cash_Disbursement__c)){
                tran.Policy__c = cashDisbursementMap.get(tran.AcctSeed__Cash_Disbursement__c).Policy__c;
                if(tran.Policy__c == null){
                    tran.Policy__c = cashDisbursementMap.get(tran.AcctSeed__Cash_Disbursement__c).Claim__r.Policy__c;
                }
                tran.Claim__c = cashDisbursementMap.get(tran.AcctSeed__Cash_Disbursement__c).Claim__c;
            }else if(tran.AcctSeed__Scheduled_Revenue_Expense__c!=null && amortizationMap.containsKey(tran.AcctSeed__Scheduled_Revenue_Expense__c)){
                tran.Policy__c = amortizationMap.get(tran.AcctSeed__Scheduled_Revenue_Expense__c).Policy__c;
                tran.AS_Transaction__c = amortizationMap.get(tran.AcctSeed__Scheduled_Revenue_Expense__c).AS_Transaction__c;
                if(amortizationMap.get(tran.AcctSeed__Scheduled_Revenue_Expense__c).Date__c != null){
                    tran.AcctSeed__Date__c = amortizationMap.get(tran.AcctSeed__Scheduled_Revenue_Expense__c).Date__c;
                }
            }
        }
    }
    
    public static void updateClaimPolicySummaryFields(List<AcctSeed__Transaction__c> newList){
        Set<Id> claimIds = new Set<Id>();
        Set<Id> policyIds = new Set<Id>();
        List<String> glNames = new List<String>();
        Map<String,Decimal> claimGLMap = new Map<String,Decimal>();
        Map<String,Decimal> policyGLMap = new Map<String,Decimal>();
        Map<Id,sObject> claimsToUpdate = new Map<Id,sObject>();
        Map<Id,sObject> policiesToUpdate = new Map<Id,sObject>();
        Map<String,Date> claimLastTransactionDateMap = new Map<String,Date>();
        for(AcctSeed__Transaction__c tran : newList){
            if(tran.Claim__c != null){
                claimIds.add(tran.Claim__c);
            }
            if(tran.Policy__c != null){
                policyIds.add(tran.Policy__c);
            }
        }
        List<Claim_Loss_Summary_GL__mdt> glSummaryList =  [select MasterLabel,GL_Account__c,Claim_Field__c,Policy_Field__c,Claim_Last_Transaction_Date_Field__c  from Claim_Loss_Summary_GL__mdt];
        for(Claim_Loss_Summary_GL__mdt summary : glSummaryList){
            glNames.add(summary.GL_Account__c);
        }
        
        for(AcctSeed__Transaction__c tran : [select id,AcctSeed__Amount__c,AcctSeed__GL_Account__r.Name,Claim__c, Policy__c,AcctSeed__Date__c   from AcctSeed__Transaction__c where (Claim__c in: claimIds OR Policy__c in: policyIds) and AcctSeed__GL_Account__r.Name in: glNames]){
            if(!claimGLMap.containsKey(tran.Claim__c + '-' + tran.AcctSeed__GL_Account__r.Name)){
                claimGLMap.put(tran.Claim__c + '-' + tran.AcctSeed__GL_Account__r.Name,0);
                claimLastTransactionDateMap.put(tran.Claim__c + '-' + tran.AcctSeed__GL_Account__r.Name,tran.AcctSeed__Date__c );
            }
            claimGLMap.put(tran.Claim__c + '-' + tran.AcctSeed__GL_Account__r.Name,claimGLMap.get(tran.Claim__c + '-' + tran.AcctSeed__GL_Account__r.Name) + tran.AcctSeed__Amount__c);
            claimLastTransactionDateMap.put(tran.Claim__c + '-' + tran.AcctSeed__GL_Account__r.Name,(claimLastTransactionDateMap.get(tran.Claim__c + '-' + tran.AcctSeed__GL_Account__r.Name) > tran.AcctSeed__Date__c ? claimLastTransactionDateMap.get(tran.Claim__c + '-' + tran.AcctSeed__GL_Account__r.Name) : tran.AcctSeed__Date__c));
            if(!policyGLMap.containsKey(tran.Policy__c + '-' + tran.AcctSeed__GL_Account__r.Name)){
                policyGLMap.put(tran.Policy__c + '-' + tran.AcctSeed__GL_Account__r.Name,0);
            }
            policyGLMap.put(tran.Policy__c + '-' + tran.AcctSeed__GL_Account__r.Name,policyGLMap.get(tran.Policy__c + '-' + tran.AcctSeed__GL_Account__r.Name) + tran.AcctSeed__Amount__c);
        }
        
        for(Claim_Loss_Summary_GL__mdt summary : glSummaryList){
            if(summary.Claim_Field__c != null || summary.Claim_Last_Transaction_Date_Field__c != null){
                for(Id ids: claimIds){
                    sObject claim = new Policy_Claim__c(Id = ids);
                    if(claimsToUpdate.containsKey(ids)){
                        claim = claimsToUpdate.get(ids);
                    }
                    if(summary.Claim_Field__c != null){
                        claim.put(summary.Claim_Field__c,(claimGLMap.containsKey(claim.Id + '-' + summary.GL_Account__c) ? claimGLMap.get(claim.Id + '-' + summary.GL_Account__c) : 0));
                    }
                    if(summary.Claim_Last_Transaction_Date_Field__c != null){
                        claim.put(summary.Claim_Last_Transaction_Date_Field__c,(claimLastTransactionDateMap.containsKey(claim.Id + '-' + summary.GL_Account__c) ? claimLastTransactionDateMap.get(claim.Id + '-' + summary.GL_Account__c) : null));
                    }
                    claimsToUpdate.put(claim.Id,claim);
                }
            }
            if(summary.Policy_Field__c != null){
                for(Id ids: policyIds){
                    sObject policy = new Policy__c(Id = ids);
                    if(policiesToUpdate.containsKey(ids)){
                        policy = policiesToUpdate.get(ids);
                    }
                    policy.put(summary.Policy_Field__c,(policyGLMap.containsKey(policy.Id + '-' + summary.GL_Account__c) ? policyGLMap.get(policy.Id + '-' + summary.GL_Account__c) : 0));
                    policiesToUpdate.put(policy.Id,policy);
                }
            }
        }
        if(claimsToUpdate.size() > 0){
            update claimsToUpdate.values();
        }
        if(policiesToUpdate.size() > 0){
            update policiesToUpdate.values();
        }
    }
    

}