public class ReversePolicyCancellationCtrl {
    
    public class ReversePolicyCancellationCtrlException extends Exception{}
    
	@AuraEnabled
    public static String reversePolicy(String recId){
        try{
            Policy_Endorsement__c polEndsmt = [SELECT Id,Policy__c,Policy__r.Cancel_Date__c,
                                               Policy__r.Premium__c,Refund_Amount__c,
                                               Policy__r.Total_5x5__c,Premium_5_5__c,
                                               Policy__r.Total_10x10__c,Premium_10_10__c,
                                               Policy__r.Excess_Premium__c,Excess__c,
                                               Policy__r.Primary__c,Primary__c,
                                               Policy__r.Expiration_Date__c,(SELECT Id FROM Journal_Entries__r),(SELECT Id FROM Billings__r) FROM Policy_Endorsement__c WHERE Id=:recId LIMIT 1];
            
            Set<String> billIds = new Set<String>();
            for(AcctSeed__Billing__c bill : polEndsmt.Billings__r){
                billIds.add(bill.Id);
            }
            List<AS_Transaction__c> asTransactions = [SELECT Id,(SELECT Id FROM Amortization_Entries__r) FROM  AS_Transaction__c WHERE Policy_Endorsement_Id__c=: polEndsmt.Id];
            
            Map<String, AcctSeed__Scheduled_Revenue_Expense__c> amotrizationMap = new Map<String, AcctSeed__Scheduled_Revenue_Expense__c>([SELECT Id FROM AcctSeed__Scheduled_Revenue_Expense__c WHERE AcctSeed__Billing__c IN: billIds]);
            
            for(AS_Transaction__c t: asTransactions){
                for(AcctSeed__Scheduled_Revenue_Expense__c a: t.Amortization_Entries__r){
                    amotrizationMap.put(a.Id, a);
                }
            }
            
            // Call the unpost billings service
            AcctSeed.PostResult[] unpostResults = AcctSeed.BillingPostService.unpostBillings(polEndsmt.Billings__r);
            
            // Loop through unpost results
            for (AcctSeed.PostResult theResult : unpostResults) {
                if (theResult.isSuccess) {
                    System.debug('Successfully unposted billing: ' + theResult.id);
                } 
                else {                    
                    System.debug('Error unposting billing ' + theResult.id);
                    for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                        System.debug('Error status code ' + errorResult.statusCode);
                        System.debug('Error message ' + errorResult.message);
                    }
                }
            }
            
            // Call the unpost journal entry service
            AcctSeed.PostResult[] unpostJeResults = AcctSeed.JournalEntryPostService.unpostJournalEntries(polEndsmt.Journal_Entries__r);
            
            // Loop through unpost results
            for (AcctSeed.PostResult theResult : unpostJeResults) {
                if (theResult.isSuccess) {
                    System.debug('Successfully unposted journal entry: ' + theResult.id);
                } 
                else {
                    System.debug('Error unposting journal entry ' + theResult.id);
                    for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                        System.debug('Error status code ' + errorResult.statusCode);
                        System.debug('Error message ' + errorResult.message);
                    }
                }
            } 
            
            // Call the unpost Amortization service
            AcctSeed.PostResult[] unpostAmoResults = AcctSeed.AmortizationPostService.unpostAmortizationEntries(amotrizationMap.values());
            
            // Loop through unpost results
            for (AcctSeed.PostResult theResult : unpostAmoResults) {
                if (theResult.isSuccess) {
                    System.debug('Successfully unposted Amortization : ' + theResult.id);
                } 
                else {
                    System.debug('Error unposting Amortization ' + theResult.id);
                    for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                        System.debug('Error status code ' + errorResult.statusCode);
                        System.debug('Error message ' + errorResult.message);
                    }
                }
            } 
            
            Policy__c p = new Policy__c();
            p.Id = polEndsmt.Policy__c;
            p.Cancel_Date__c = null;
            System.debug('123');
            p.Premium__c = polEndsmt.Policy__r.Premium__c + polEndsmt.Refund_Amount__c;
            p.Total_5x5__c = (polEndsmt.Policy__r.Total_5x5__c == null ? 0 : polEndsmt.Policy__r.Total_5x5__c) - (polEndsmt.Premium_5_5__c == null ? 0 : polEndsmt.Premium_5_5__c);
            p.Total_10x10__c = (polEndsmt.Policy__r.Total_10x10__c == null ? 0 : polEndsmt.Policy__r.Total_10x10__c) - (polEndsmt.Premium_10_10__c == null ? 0 : polEndsmt.Premium_10_10__c);
            p.Excess_Premium__c = (polEndsmt.Policy__r.Excess_Premium__c == null ? 0 : polEndsmt.Policy__r.Excess_Premium__c) - (polEndsmt.Excess__c == null ? 0 : polEndsmt.Excess__c);
            p.Primary__c = (polEndsmt.Policy__r.Primary__c == null ? 0 : polEndsmt.Policy__r.Primary__c) - (polEndsmt.Primary__c == null ? 0 : polEndsmt.Primary__c);
            
            if(polEndsmt.Policy__r.Expiration_Date__c > System.today()){
                p.Active1__c = true;
            }
            system.debug('policy => '+p);
            Update p;
            
            Delete amotrizationMap.values();
            Delete asTransactions;
            Delete polEndsmt.Billings__r;
            Delete polEndsmt.Journal_Entries__r;            
            
            Delete polEndsmt;
            return polEndsmt.Policy__c;
        }
        catch(DmlException e){
            throw new ReversePolicyCancellationCtrlException(e.getDmlMessage(0));
        }
        catch(Exception e){
            throw new ReversePolicyCancellationCtrlException(e.getMessage());
        }
    }
}