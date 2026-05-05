public class CustomerApplicationLawyerTriggerHandler {
    Public static boolean stopMatchingLawyer = false;
    public static void onBeforeInsert(List<Customer_Application_Lawyer__c> newList){
        linkContactLookup(newList);
    }
	public static void onBeforeUpdate(List<Customer_Application_Lawyer__c> oldList,Map<Id,Customer_Application_Lawyer__c> oldMap,List<Customer_Application_Lawyer__c> newList,Map<Id,Customer_Application_Lawyer__c> newMap){
        if(!stopMatchingLawyer){
            linkContactLookup(newList);
        }
    }
    public static void linkContactLookup(List<Customer_Application_Lawyer__c> newList){
        Set<String> isbaNumberSet = new Set<String>();
        Set<String> ardcNumberSet = new Set<String>();
        Map<String,Contact> isbaNumberContactMap = new Map<String,Contact>();
        Map<String,Contact> ardcNumberContactMap = new Map<String,Contact>();
        for(Customer_Application_Lawyer__c lawyer : newList){
            if(lawyer.Contact__c == null){
                if(lawyer.ARDC_Number__c != null){
                    ardcNumberSet.add(lawyer.ARDC_Number__c);
                }
                if(lawyer.ISBA_Number__c != null){
                    isbaNumberSet.add(lawyer.ISBA_Number__c);
                }
            }
        }
        if(ardcNumberSet != null || isbaNumberSet != null){
            for(Contact cont : [select id,Name,ARDC_Number__c,ISBA__c from Contact where ISBA__c in: isbaNumberSet or ARDC_Number__c in: ardcNumberSet]){
                if(cont.ARDC_Number__c != null){
                    ardcNumberContactMap.put(cont.ARDC_Number__c,cont);
                }
                if(cont.ISBA__c != null){
                    isbaNumberContactMap.put(cont.ISBA__c,cont);
                }
            }
            for(Customer_Application_Lawyer__c lawyer : newList){
                if(lawyer.Contact__c == null){
                    if(lawyer.ARDC_Number__c != null && ardcNumberContactMap.containsKey(lawyer.ARDC_Number__c)){
                        lawyer.Contact__c = ardcNumberContactMap.get(lawyer.ARDC_Number__c).Id;
                    }else if(lawyer.ISBA_Number__c != null && ardcNumberContactMap.containsKey(lawyer.ISBA_Number__c)){
                        lawyer.Contact__c = isbaNumberContactMap.get(lawyer.ISBA_Number__c).Id;
                    }
                }
            }
        }
    }
}