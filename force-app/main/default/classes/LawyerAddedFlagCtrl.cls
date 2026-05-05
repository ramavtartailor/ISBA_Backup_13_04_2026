public class LawyerAddedFlagCtrl {
    
    @AuraEnabled
    public Static String getDetails(String recId){
        Integer removedLawyers = 0;
        Integer addedLawyers = 0;
        try{
            List<Customer_Application_Lawyer__c> appLawyers = new List<Customer_Application_Lawyer__c>([SELECT Id,Name,Is_Removed__c,Is_New__c,Customer_Application__r.PolicyId__c,ARDC_Number__c FROM Customer_Application_Lawyer__c WHERE Customer_Application__c =: recId]);
            if(!appLawyers.isEmpty()){
                List<Policy_Lawyer__c> policyLawyers = new List<Policy_Lawyer__c>([SELECT Id,Lawyer__r.Contact__r.ARDC_Number__c, Average_Hours_Per_Week__c, Hire_Date__c, Contact_Role__c FROM Policy_Lawyer__c WHERE Policy__c =: appLawyers[0].Customer_Application__r.PolicyId__c]);
                
                Map<String,Customer_Application_Lawyer__c> ardcNumsWithLawyer = new Map<String,Customer_Application_Lawyer__c>();
                
                Integer keyCount = 0;
                for(Customer_Application_Lawyer__c lawyer: appLawyers){
                    if(lawyer.Is_Removed__c){
                        removedLawyers += 1;                    
                    }
                    else if(lawyer.Is_New__c){
                        addedLawyers += 1;
                    }
                    /*else{
                        String key = '';
                        if(String.isNotBlank(lawyer.ARDC_Number__c)){
                            key = lawyer.ARDC_Number__c;
                        }
                        else{
                            keyCount += 1;
                            key = String.valueOf(keyCount);
                        }
                        ardcNumsWithLawyer.put(key, lawyer); 
                    }*/
                }
                
                /*for(Policy_Lawyer__c pl: policyLawyers){
                    if(!ardcNumsWithLawyer.containsKey(pl.Lawyer__r.Contact__r.ARDC_Number__c)){
                        addedLawyers += 1;
                    }
                }*/
            }
            
            return (String.valueOf(removedLawyers) +'|'+ String.valueOf(addedLawyers));
        }
        Catch(Exception e){
            system.debug(e.getMessage()+' At '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage()); 
        }
    } 
}