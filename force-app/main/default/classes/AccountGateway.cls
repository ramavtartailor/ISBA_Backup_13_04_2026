/*
 * 
 * Created By     : Ali Zaidi
 * Created Date   : 11/19/2016
 * Purpose        : This class provides finder methods for accessing data in the Account object, and also the helper functions to implement trigger processes.
 * Name           : AccountGateway
 * Referenced     : Currently at the time of creation this class is referenced by AccountHandler.
 * 
 *  
 */
public without sharing class AccountGateway {
    // Update Recent Policy Id and Name in the Account.
    public static Void updateAccountWithRecentPolicy(Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {
        set<String> setUpdatedAccountIds = new set<String>();
        Map<String,Account> mapUpdatedAccounts = new Map<String,Account>();
        Map<String,Policy__c> mapOfRecentPolicyOnAccount = new Map<String,Policy__c>();
        List<Account> lstAccountsToUpdate = new List<Account>();
        
        // Check if Active Policy Count has changed from Map and Create a list of those Accounts.
        for (Account acc : (List<Account>)newItems.values()) {
            Account oldAcc = (Account)oldItems.get(acc.Id);
            
            system.debug('----old---'+oldAcc.Count_Active_Policies__c);
            system.debug('----new -----'+acc.Count_Active_Policies__c);
            // Check if the count active policy field has changed.
            if (oldAcc.Count_Active_Policies__c != acc.Count_Active_Policies__c) {
                // Check if the count is greater than 0.
                if (acc.Count_Active_Policies__c > 0) {
                    // Fill the set with Account Ids to Soql.
                    setUpdatedAccountIds.add(acc.Id);
                }
            }
        }
        
        // SOQL Updated Accounts to update them.
        for (Account acc : [SELECT Id, Count_Active_Policies__c, Recent_Policy_ID__c, Recent_Policy__c FROM Account WHERE Id IN: setUpdatedAccountIds]) {
            mapUpdatedAccounts.put(acc.Id,acc);
        }
        
        // Soql all policies that are active on updated Accounts and get the most recent in the map against account Id.
        for (Policy__c pol : [SELECT Id, Active__c, Account__c, Expiration_Date__c, Policy_Number__c, Cancel_Date__c FROM Policy__c WHERE Active__c = true AND Expiration_Date__c != null AND Account__c IN: setUpdatedAccountIds ORDER BY Expiration_Date__c DESC]) {
            // Check to see if multiple policies are active on an Account.
            if (mapOfRecentPolicyOnAccount.containsKey(pol.Account__c)) {
                Policy__c mapPolicy = mapOfRecentPolicyOnAccount.get(pol.Account__c);
                // Check if the current looped policy has Cancel Date.
                if (pol.Cancel_Date__c != null) {
                    // Check if policy in map has cancel date.
                    if (mapPolicy.Cancel_Date__c != null) {
                        // Check if cancel date of looped policy is greater than cancel date of map policy.
                        if (pol.Cancel_Date__c > mapPolicy.Cancel_Date__c) {
                            mapOfRecentPolicyOnAccount.put(pol.Account__c,pol);
                        }
                    } else {
                        // Check if cancel date of looped policy is greater than expiration date of map policy.
                        if (pol.Cancel_Date__c > mapPolicy.Expiration_Date__c) {
                            mapOfRecentPolicyOnAccount.put(pol.Account__c,pol);
                        }
                    }
                } else {
                    // Check if policy in map has cancel date.
                    if (mapPolicy.Cancel_Date__c != null) {
                        // Check if expiration date of looped policy is greater than map policy cancel date.
                        if (pol.Expiration_Date__c > mapPolicy.Cancel_Date__c) {
                            mapOfRecentPolicyOnAccount.put(pol.Account__c,pol);
                        }
                    } else {
                        // Check if expiration date of looped policy is greater than map policy expiration date.
                        if (pol.Expiration_Date__c > mapPolicy.Expiration_Date__c) {
                            mapOfRecentPolicyOnAccount.put(pol.Account__c,pol);
                        }
                    }
                }
            } else {
                mapOfRecentPolicyOnAccount.put(pol.Account__c,pol);
            }
        }
        
        // Loop through updated accounts and make a list of account to update with the new values.
        for (Account acc : mapUpdatedAccounts.values()) {
            Policy__c pol = mapOfRecentPolicyOnAccount.get(acc.Id);
            // Check if recent policy for this account exists.
            if (pol != null) {
                acc.Recent_Policy_ID__c = pol.Id;
                acc.Recent_Policy__c = pol.Policy_Number__c;
                
                lstAccountsToUpdate.add(acc);
            }
        }
        
        // Udapte accounts with new information.
        update lstAccountsToUpdate;
    }
}