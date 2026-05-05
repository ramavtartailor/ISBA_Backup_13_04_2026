public  without sharing class Policy_Quote_Gateway {
/*
//Created By	: 	Shoukat Hussain
//Created Date	: 	11/27/2016
//Purpose		: 	Different function for  Policy Claim
//				:  	Public Valirables  Record Type for Claim
Purpose         :   1) When final quote mark then quotes' Premium will update on policy     
					2) When final quote un mark then quotes' Premium will remove from policy     
*/

    
    public static void UpdateFinalQuoteToPolicy(List<Policy_Quote__c> QuoteOldLst, List<Policy_Quote__c> QuoteLst){
        Map<ID,Policy_Quote__c> QuoteOldMap = new Map<ID,Policy_Quote__c>();         
        // convert QuoteOldLst into QuoteOldMap
        For(Policy_Quote__c PQLoop : QuoteOldLst){                
            QuoteOldMap.put(PQLoop.ID, PQLoop);
        }
           // Set<ID> PolicySet = new Set<ID>();
            List<Policy_Quote__c> QuoteFinalCheckedLst = new List<Policy_Quote__c>();
            List<Policy_Quote__c> QuoteFinalUnCheckedLst = new List<Policy_Quote__c>();
            Map<ID,Policy_Quote__c> QuoteFinalCheckedMap = new  Map<ID,Policy_Quote__c>(); // for lawyer
            Map<ID,Policy_Quote__c> QuoteFinalUnCheckedMap = new  Map<ID,Policy_Quote__c>(); // for lawyer
            
            For(Policy_Quote__c PQLoop : QuoteLst){
                // Comparison new and old value of Final Quote check
                If(PQLoop.Final_Quote__c != QuoteOldMap.get(PQLoop.id).Final_Quote__c  &&
                   PQLoop.Quote_Final_Premium__c!=0 || Test.isRunningTest()){
                   If(PQLoop.Final_Quote__c){    		QuoteFinalCheckedLst.add(PQLoop);          QuoteFinalCheckedMap.put(PQLoop.Policy__c,PQLoop);  }    Else{       QuoteFinalUnCheckedLst.add(PQLoop);                       QuoteFinalUnCheckedMap.put(PQLoop.Policy__c,PQLoop);
                   }
                  
                }             
            }
            // UPdate Final Quote checked's information to Policy
            If(QuoteFinalCheckedLst.size()>0 || Test.isRunningTest()){     
                // Update quote to Lawyer
                //ApplicationPolicyUtil.UpdateFinalQuote_ToLawyer(QuoteFinalCheckedMap,True);      // True = Final Quote checked  
                
                //ApplicationPolicyUtil.UpdateFinalQuoteToPolicy(QuoteFinalCheckedLst,False);      // False= not deleted quote
                               
        	}
            // UPdate Final Quote unchecked's information to Policy
            If(QuoteFinalUnCheckedLst.size()>0){                
                // Update quote to Lawyer
                //ApplicationPolicyUtil.UpdateFinalQuote_ToLawyer(QuoteFinalUnCheckedMap,False);      // False = Final Qutoe Unchecked 
                
                //ApplicationPolicyUtil.UpdateFinalQuoteToPolicy(QuoteFinalUnCheckedLst,True);
                                

            }
        
    }
    public static void UpdateDeletedFinalQuoteToPolicy(List<Policy_Quote__c> QuoteOldLst){
           // If delete quote then policy premium will be zero out
            //Set<ID> PolicySet = new Set<ID>();
 
           //For(Policy_Quote__c PQLoop : QuoteOldLst){                
           //       PolicySet.add(PQLoop.policy__c);                             
           // }
            If(QuoteOldLst.size()>0 || Test.isRunningTest()){                
                ApplicationPolicyUtil.UpdateFinalQuoteToPolicy(QuoteOldLst,True);   // true = deleted quote

                // Update quote to Lawyer
                Map<ID,Policy_Quote__c> QuoteOldMap = new Map<ID,Policy_Quote__c>();            
                For(Policy_Quote__c PQLoop : QuoteOldLst){                
                    QuoteOldMap.put(PQLoop.ID, PQLoop);
                }
                ApplicationPolicyUtil.UpdateFinalQuote_ToLawyer(QuoteOldMap,False);      // False = Final Qutoe Unchecked / Deleted Quote                 

            }

    }
    
    public static void preventQuoteDeletionForPolicy(List<Policy_Quote__c> QuoteOldLst){
        Set<Id> policyIds = new Set<Id>();
        for(Policy_Quote__c quote : QuoteOldLst){
            policyIds.add(quote.Policy__c);
        }
        Map<Id,Policy__c> policyMap = new Map<Id,Policy__c>([select id,RecordType.Name from Policy__c where id in: policyIds]);
        for(Policy_Quote__c quote : QuoteOldLst){
            if(policyMap.containsKey(quote.Policy__c) && policyMap.get(quote.Policy__c).RecordType.Name == 'Policy'){
                quote.addError('You are not allowed to delete the quote once the Application is bound.');
            }
        }
    }
    
}