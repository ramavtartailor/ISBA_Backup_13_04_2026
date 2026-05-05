public class RetryMatchCtrl {
    
    public class RetryMatchCtrlException extends Exception {}
    
    @AuraEnabled
    public static string reMatch(String recId){
        try {
            System.debug('recId => ' + recId);
            List<Customer_Application__c> cappList = new List<Customer_Application__c>([
                SELECT Id,
                       Full_Legal_Name_of_the_Firm__c,
                       Contact_E_mail_Address__c,
                       Account__c,
                       Contact__c,
                       (SELECT Id, Contact__c, ARDC_Number__c, ISBA_Number__c FROM Customer_Application_Lawyers__r)
                  FROM Customer_Application__c
                 WHERE Id =:recId
            ]);
            if(!cappList.isEmpty()){
                Customer_Application__c ca = cappList[0];
                Boolean flag = false;
                if(String.isNotBlank(ca.Full_Legal_Name_of_the_Firm__c)){
                    List<Account> accList = new List<Account>([SELECT Id, Name, Phone FROM Account WHERE Name =: ca.Full_Legal_Name_of_the_Firm__c LIMIT 1]);
                    if(!accList.isEmpty()){
                        ca.Account__c = accList[0].Id;
                        flag = true;
                    }
                }
                if(String.isNotBlank(ca.Contact_E_mail_Address__c)){
                    List<Contact> conList = new List<Contact>([SELECT Id, Email FROM Contact WHERE Email =: ca.Contact_E_mail_Address__c]);
                    if(!conList.isEmpty()){
                        ca.Contact__c = conList[0].Id;
                        flag = true;
                    }
                }
                
                if(flag){
                    Update ca;
                }
                
                if(ca.Customer_Application_Lawyers__r != null && !ca.Customer_Application_Lawyers__r.isEmpty()){
                    Set<String> isbaNumberSet = new Set<String>();
                    Set<String> ardcNumberSet = new Set<String>();
                    Map<String,Contact> isbaNumberContactMap = new Map<String,Contact>();
                    Map<String,Contact> ardcNumberContactMap = new Map<String,Contact>();
                    List<Customer_Application_Lawyer__c> updatedLawyers = new List<Customer_Application_Lawyer__c>();

                    for(Customer_Application_Lawyer__c lawyer : ca.Customer_Application_Lawyers__r){
                        if(lawyer.ARDC_Number__c != null){
                            ardcNumberSet.add(lawyer.ARDC_Number__c);
                        }
                        if(lawyer.ISBA_Number__c != null){
                            isbaNumberSet.add(lawyer.ISBA_Number__c);
                        }
                    }

                    if(!ardcNumberSet.isEmpty() || !isbaNumberSet.isEmpty()){
                        for(Contact cont : [select id,Name,ARDC_Number__c,ISBA__c from Contact where ISBA__c in: isbaNumberSet or ARDC_Number__c in: ardcNumberSet]){
                            if(cont.ARDC_Number__c != null){
                                ardcNumberContactMap.put(cont.ARDC_Number__c,cont);
                            }
                            if(cont.ISBA__c != null){
                                isbaNumberContactMap.put(cont.ISBA__c,cont);
                            }
                        }

                        for(Customer_Application_Lawyer__c lawyer : ca.Customer_Application_Lawyers__r){
                            if(lawyer.ARDC_Number__c != null && ardcNumberContactMap.containsKey(lawyer.ARDC_Number__c)){
                                lawyer.Contact__c = ardcNumberContactMap.get(lawyer.ARDC_Number__c).Id;
                                updatedLawyers.add(lawyer);
                            }else if(lawyer.ISBA_Number__c != null && isbaNumberContactMap.containsKey(lawyer.ISBA_Number__c)){
                                lawyer.Contact__c = isbaNumberContactMap.get(lawyer.ISBA_Number__c).Id;
                                updatedLawyers.add(lawyer);
                            }
                        }
                    }

                    if(!updatedLawyers.isEmpty()){
                        Update updatedLawyers;
                    }
                }
                
            }
            return 'success';
        } catch (DmlException e) {
            throw new RetryMatchCtrlException(e.getDmlMessage(0));
        } catch (Exception e) {
            throw new RetryMatchCtrlException(e.getMessage());
        }
    }
}