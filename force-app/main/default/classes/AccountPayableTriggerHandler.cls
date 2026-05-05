/*    
Name : AccountPayableTriggerHandler
Auther : Sarbjeet Singh
Date : 30th June 2017
Description : Handler class for AccountPayableTrigger .

update Rollup for LAE AND LOSS in Claim and also create bill if the Loss rollup is greater then 5000 and dedcutable amount 

*/


public class AccountPayableTriggerHandler{
    public static boolean createBilling = false;
    
    
    public static void checkForDuplicates(Set<String> payableIds, Map<Id,AcctSeed__Account_Payable__c> newMap){
        Set<String> invoiceNumbers = new Set<String>();
		List<AcctSeed__Account_Payable_Line__c> payableLineList = [SELECT Id, AcctSeed__Account_Payable__c, AcctSeed__Vendor_Id__c, ISBAM_Invoice_Number__c FROM AcctSeed__Account_Payable_Line__c WHERE AcctSeed__Account_Payable__c IN : payableIds];       
        
        for(AcctSeed__Account_Payable_Line__c objLine: payableLineList){
            invoiceNumbers.add(objLine.ISBAM_Invoice_Number__c);
        }
        
       	List<AcctSeed__Account_Payable_Line__c> existingLines =[SELECT Id, ISBAM_Invoice_Number__c, AcctSeed__Vendor_Id__c 
                                                                FROM AcctSeed__Account_Payable_Line__c WHERE ISBAM_Invoice_Number__c IN :invoiceNumbers];
        
        Set<String> keySet = new Set<String>();
        
        for(AcctSeed__Account_Payable_Line__c line : existingLines){
            keySet.add(line.AcctSeed__Vendor_Id__c  + '|' + line.ISBAM_Invoice_Number__c);
        }
        
        for(AcctSeed__Account_Payable_Line__c line : payableLineList){
            if(String.isNotBlank(line.ISBAM_Invoice_Number__c)){
                String vendor = newMap.get(line.AcctSeed__Account_Payable__c).AcctSeed__Vendor__c;
                
                String key = vendor + '|' + line.ISBAM_Invoice_Number__c;
                
                if(keySet.contains(key)){
                    newMap.get(line.AcctSeed__Account_Payable__c).addError('Duplicate Invoice Number found for this Payable.');
                }
            }
        }
    }
    
    public static void afterupdate(List<AcctSeed__Account_Payable__c> payableList){
        set<Id> claimId = new set<Id>();
        Map<Id,AcctSeed__Account_Payable__c> claimPayableMap = new Map<Id,AcctSeed__Account_Payable__c>();
        Map<Id,Decimal> LAEPayMap = new Map<Id,Decimal>(); 
        Map<Id,Decimal> LossPayMap = new Map<Id,Decimal>();
        List<Policy_Claim__c> updateLAEPolicyClaimList = new List<Policy_Claim__c>(); 
        List<Policy_Claim__c> updateLossPolicyClaimList = new List<Policy_Claim__c>(); 
        Map<Id,AcctSeed__Billing__c> billingMap = new Map<Id,AcctSeed__Billing__c>();
        Map<Id,AcctSeed__Billing_Line__c> billLineMap = new Map<Id,AcctSeed__Billing_Line__c>(); 
        
        for(AcctSeed__Account_Payable__c pay : payableList){
            System.debug('pay'+pay);
            if(pay.Claim__c != null){
                claimId.add(pay.Claim__c);
                claimPayableMap.put(pay.Claim__c,pay);
                //LAEPayMap.put(pay.Claim__c,0);
                //LossPayMap.put(pay.Claim__c,0);
                if(pay.Type__c == 'LAE Pay'){
                    
                    if(LAEPayMap.containskey(pay.Claim__c)){
                        
                        Decimal val = LAEPayMap.get(pay.Claim__c);
                        val += pay.AcctSeed__Total__c; //- pay.AcctSeed__Balance__c;
                        LAEPayMap.put(pay.Claim__c,val); 
                        SYstem.debug('LAE Pay 1');
                        
                    } else {
                        
                        Decimal val;
                        val = pay.AcctSeed__Total__c; //- pay.AcctSeed__Balance__c;
                        System.debug('val--='+val);
                        LAEPayMap.put(pay.Claim__c,val);
                        SYstem.debug('LAE Pay 2');
                    }   
                    
                    
                } else if(pay.Type__c == 'Loss Pay'){
                    
                    if(LossPayMap.containskey(pay.Claim__c)){
                        
                        Decimal val = LossPayMap.get(pay.Claim__c);
                        val += pay.AcctSeed__Total__c;// - pay.AcctSeed__Balance__c;
                        LossPayMap.put(pay.Claim__c,val);    
                        
                    } else {
                        Decimal val;
                        val = pay.AcctSeed__Total__c;// - pay.AcctSeed__Balance__c;
                        System.debug('val--='+val);
                        LossPayMap.put(pay.Claim__c,val);
                        
                    }
                    
                }
                
            }
            
        } 
        Map<Id,Policy_Claim__c> PolicyClaimMap = new Map<Id,Policy_Claim__c>();
        Set<Id> policyIds = new Set<Id>();
        for(Policy_Claim__c claim: [SELECT Id,Policy__c,Remaining_Deductible__c,Name,LAE_Pay__c,Loss_Pay__c,Policy__r.Account__c,
                                    Per_Claim_Deductible__c , Per_Claim_Deductible_Balance__c,Deductible_LAE_Applied_Balance__c,
                                    Policy__r.Per_Claim_Deductible_Amount__c,Policy__r.Deductible_Consumed_All_Claims__c,Policy__r.Firm_Contact__c,Account__r.AcctSeed__Billing_Contact__c,Account__r.Recent_Policy_Lookup__r.Firm_Contact__c 
                                    FROM Policy_Claim__c WHERE Id IN: claimId]){
                                        PolicyClaimMap.put(claim.Id,claim);
                                        policyIds.add(claim.Policy__c);
                                        
                                    }
        
        
        Map<Id,Policy_Endorsement__c> endorsementMap = new Map<Id,Policy_Endorsement__c>();       
        for(Policy_Endorsement__c endorsement : [SELECT Id,Policy__c FROM Policy_Endorsement__c 
                                                 WHERE Policy__c in : policyIds 
                                                 AND RecordType.Name = 'IL 230 ANNUAL AGGREGATE DEDUCTIBLE ENDORSEMENT']){
            endorsementMap.put(endorsement.Policy__c,endorsement);
        }
        
        Map<string,Transaction_Credit_And_Debits__c> transactionCustomSettingMap = Transaction_Credit_And_Debits__c.getAll();
        system.debug('transactionCustomSettingMap :: ' + transactionCustomSettingMap);
        set<string> setofAllGlNames = new set<string>();
        set<string> setofAllGlVariables = new set<string>();
        for(Transaction_Credit_And_Debits__c t : transactionCustomSettingMap.values()){
            setofAllGlNames.add(t.Credit_GL__c);
            setofAllGlNames.add(t.Debit_GL__c);
            if(t.GL_Variable__c != null){
                setofAllGlVariables.add(t.GL_Variable__c);
            }
        }
        
        system.debug('======setofAllGlNames===='+setofAllGlNames);
        
        map<string, AcctSeed__GL_Account__c> mapOfGlAccounts = new map<string, AcctSeed__GL_Account__c>();
        for(AcctSeed__GL_Account__c a : [select id, name from AcctSeed__GL_Account__c where name IN:setofAllGlNames]){
            System.debug('gl--'+a);
            mapOfGlAccounts.put(a.name, a);
        }
        
        Map<String,AcctSeed__Accounting_Variable__c> mapOfGlVariables = new Map<String,AcctSeed__Accounting_Variable__c>();
        for(AcctSeed__Accounting_Variable__c a : [select id, name from AcctSeed__Accounting_Variable__c where name IN:setofAllGlVariables]){
            System.debug('gl--'+a);
            mapOfGlVariables.put(a.name, a);
        }
        
        
        List<AcctSeed__Billing_Format__c> deductibleBillingFormat = new List<AcctSeed__Billing_Format__c>([Select id from AcctSeed__Billing_Format__c where Name =: Label.Deductible_Billing_Format   limit 1]);
        
        //List<AcctSeed__Account_Payable__c> PayableClaimList = [SELECT Id,Type__c,Claim__c,Policy__r.Account__c,AcctSeed__Total__c,AcctSeed__Balance__c,AcctSeed__Net_Amount__c FROM AcctSeed__Account_Payable__c WHERE Claim__c IN: claimId /*AND (AcctSeed__Payment_Status__c = 'Paid' OR AcctSeed__Payment_Status__c = 'Partially Paid')*/];

        for(Policy_Claim__c polclaim : PolicyClaimMap.values()){
            Decimal amount=0,amount1=0;
            Decimal claimDeductibleBalance;
            if(endorsementMap.containsKey(polClaim.Policy__c)){
                claimDeductibleBalance = polclaim.Policy__r.Per_Claim_Deductible_Amount__c - polclaim.Policy__r.Deductible_Consumed_All_Claims__c;
            }else{
                claimDeductibleBalance = polclaim.Per_Claim_Deductible_Balance__c;
            }
            Decimal remainingBalance = claimDeductibleBalance;
            if(LAEPayMap.containskey(polclaim.Id)){
                if(polclaim.Deductible_LAE_Applied_Balance__c <= 0){
                    system.debug('LAEPayMap.get(polclaim.Id) => '+LAEPayMap.get(polclaim.Id));
                    amount = - LAEPayMap.get(polclaim.Id);
                }else{
                    system.debug('polclaim.Deductible_LAE_Applied_Balance__c => '+polclaim.Deductible_LAE_Applied_Balance__c);
                    system.debug('LAEPayMap.get(polclaim.Id) => '+LAEPayMap.get(polclaim.Id));
                    amount = polclaim.Deductible_LAE_Applied_Balance__c - LAEPayMap.get(polclaim.Id);
                }
                if(amount<0 && claimDeductibleBalance>0){
                    if(claimDeductibleBalance+amount>0){
                        amount = - amount;
                        remainingBalance = claimDeductibleBalance+amount;
                    }else{
                        amount = claimDeductibleBalance;
                        remainingBalance = 0;
                    }
                }else{
                    amount=0;
                }
            }  
            if(LossPayMap.containskey(polclaim.Id)){
                if(remainingBalance>0){
                    system.debug('remainingBalance => '+remainingBalance);
                    system.debug('LossPayMap.get(polclaim.Id) => '+LossPayMap.get(polclaim.Id));
                    if(remainingBalance-LossPayMap.get(polclaim.Id)>0){
                        amount1 = LossPayMap.get(polclaim.Id);
                    }else{
                        amount1 = remainingBalance;
                    }
                }
                amount += amount1;
                
            }
            if(amount!=null && amount>0){
                AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
                bill.AcctSeed__Customer__c = polclaim.Policy__r.Account__c;
                bill.AcctSeed__Date__c = claimPayableMap.get(polclaim.Id).AcctSeed__Date__c;  
                bill.Claim__c = polclaim.Id;
                bill.Policy__c = polclaim.Policy__c;
                if(deductibleBillingFormat.size() > 0){
                    bill.AcctSeed__Billing_Format__c = deductibleBillingFormat[0].Id;
                }
                bill.Billing_Description__c = 'Deductible Invoice for Claim ' + polclaim.Name;
                bill.AcctSeed__Billing_Contact__c = (polclaim.Account__r.AcctSeed__Billing_Contact__c != null ? polclaim.Account__r.AcctSeed__Billing_Contact__c : polclaim.Account__r.Recent_Policy_Lookup__r.Firm_Contact__c);
                billingMap.put(polclaim.Id,bill);
                
                AcctSeed__Billing_Line__c billLine = new AcctSeed__Billing_Line__c();
                
                billLine.AcctSeed__Hours_Units__c = 1;
                billLine.AcctSeed__Rate__c = amount;
                billLine.AcctSeed__Date__c = claimPayableMap.get(polclaim.Id).AcctSeed__Date__c;
                if(LAEPayMap.containskey(polclaim.Id)){
                    billLine.AcctSeed__Revenue_GL_Account__c = mapOfGlAccounts.get(transactionCustomSettingMap.get('LAE Pay Bill Line').Credit_GL__c).Id;
                    if(transactionCustomSettingMap.get('LAE Pay Bill Line').GL_Variable__c != null){
                        billLine.AcctSeed__GL_Account_Variable_1__c = mapOfGlVariables.get(transactionCustomSettingMap.get('LAE Pay Bill Line').GL_Variable__c).Id;
                    }
                }else if(LossPayMap.containskey(polclaim.Id)){
                    billLine.AcctSeed__Revenue_GL_Account__c = mapOfGlAccounts.get(transactionCustomSettingMap.get('Loss Pay Bill Line').Credit_GL__c).Id;
                    if(transactionCustomSettingMap.get('Loss Pay Bill Line').GL_Variable__c != null){
                        billLine.AcctSeed__GL_Account_Variable_1__c = mapOfGlVariables.get(transactionCustomSettingMap.get('Loss Pay Bill Line').GL_Variable__c).Id;
                    }
                }
                
                
                billLineMap.put(polclaim.Id,billLine);
            }            
        }
        if(!billingMap.isEmpty()){
            
            insert billingMap.values();
            
            for(id claim : billingMap.keyset()){
                
                AcctSeed__Billing_Line__c billLine = billLineMap.get(claim);
                billLine.AcctSeed__Billing__c = billingMap.get(claim).Id;
                
                billLineMap.put(claim,billLine);
            }
            
            insert billLineMap.values();
            AcctSeed.PostResult[] postResults = AcctSeed.BillingPostService.postBillings(billingMap.values());
        }
    }
    
    
}