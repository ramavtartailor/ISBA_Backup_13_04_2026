/*
 * 
 * Created By     : Ali Zaidi
 * Created Date   : 11/20/2016
 * Purpose        : This class provides finder methods for accessing data in the AccountContactJunction object, and also the helper functions to implement trigger processes.
 * Name           : AccountContactJunctionGateway
 * Referenced     : Currently at the time of creation this class is referenced by AccountContactJunctionHandler.
 * 
 *  
 */
public without sharing class AccountContactJunctionGateway {
	// Function will auto-populate the name of AccountContactJunction record with Account Name - Contact Name.
    public static void populateACJName (Map<Id,SObject> newItems) {
        // Cast the map to list of policy endorsements.
        List<AccountContactJunction__c> lstACJ = (List<AccountContactJunction__c>) newItems.values();
        List<AccountContactJunction__c> lstACJToUpdate = new List<AccountContactJunction__c>();
        // Used variables.
        Set<String> setAccountIds = new Set<String>();
		Set<String> setContactIds = new Set<String>();
        Set<Id> setACJIds = (new Map<Id,SObject>(lstACJ)).keySet();
		Map<String,String> mapAccountNames = new Map<String,String>();
		Map<String,String> mapContactNames = new Map<String,String>();
        
        // Get the Account and Contact Ids from Records.
        for (AccountContactJunction__c junc : lstACJ) {
			setAccountIds.add(junc.Account__c);
			setContactIds.add(junc.Contact__c);
		}
		
        // SOQL Account names and fill the map.
		for (Account acc : [SELECT Id, Name FROM Account WHERE Id IN :setAccountIds]) {
			mapAccountNames.put(acc.Id, acc.Name);
		}
		
        // SOQL Contact names and fill the map.
		for (Contact con : [SELECT Id, Name FROM Contact WHERE Id IN :setContactIds]) {
			mapContactNames.put(con.Id, con.Name);
		}
		
        // Update the record name.
		for (AccountContactJunction__c junc : [SELECT Id, Name, Account__c, Contact__c FROM AccountContactJunction__c WHERE Id IN: setACJIds]) {
			junc.Name = mapContactNames.get(junc.Contact__c);
            lstACJToUpdate.add(junc);
		}
        update lstACJToUpdate;
    }
}