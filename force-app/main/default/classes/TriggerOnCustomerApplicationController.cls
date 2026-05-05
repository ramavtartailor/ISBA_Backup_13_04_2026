public class TriggerOnCustomerApplicationController {
    
    public static void assignContact(List<Customer_Application__c> newList, Map<Id, Customer_Application__c> oldMap ){
        Map<String, String> emailWithContactIdMap = new Map<String, String>();
        
        for(Customer_Application__c ca: newList){
            if(ca.Contact_E_mail_Address__c != null && (oldMap == null || (oldMap.containsKey(ca.Id) && ca.Contact_E_mail_Address__c != oldMap.get(ca.Id).Contact_E_mail_Address__c))){
                emailWithContactIdMap.put(ca.Contact_E_mail_Address__c, null);
            }
        }

        List<Contact> conList = [SELECT Id, Email FROM Contact WHERE Email IN :emailWithContactIdMap.keySet()];
        
        for(Contact con: conList){
            if(emailWithContactIdMap.get(con.Email) == null){
                emailWithContactIdMap.put(con.Email, con.Id);
            }
        } 

        for(Customer_Application__c ca: newList){
            if(ca.Contact_E_mail_Address__c != null && (oldMap== null || (oldMap.containsKey(ca.Id) && ca.Contact_E_mail_Address__c != oldMap.get(ca.Id).Contact_E_mail_Address__c))){
                if(String.isNotBlank(emailWithContactIdMap.get(ca.Contact_E_mail_Address__c))){
                    ca.Contact__c = emailWithContactIdMap.get(ca.Contact_E_mail_Address__c);
                }
                if(ca.Contact_E_mail_Address__c == null){
                    ca.Contact__c = null;
                }
            }
        }

    }
    
    public static void assignAccount(List<Customer_Application__c> newList, Map<Id, Customer_Application__c> oldMap ){ 
        
        Set<String> caIds = new Set<String>();
        
		Map<String,Account> accMap = new Map<String,Account>();
        
        Set<String> firmPhoneNumbers = new Set<String>();
        Set<String> firmNames = new Set<String>();
        
        for(Customer_Application__c ca: newList){
            if(ca.Full_Legal_Name_of_the_Firm__c != null && (oldMap == null || (oldMap.containsKey(ca.Id) && ca.Full_Legal_Name_of_the_Firm__c != oldMap.get(ca.Id).Full_Legal_Name_of_the_Firm__c))){
                if(String.isNotBlank(ca.Full_Legal_Name_of_the_Firm__c)){
                    firmNames.add(ca.Full_Legal_Name_of_the_Firm__c );
                }
                caIds.add(ca.Id);
            }
        }

        List<Account> accList = [SELECT Id, Name, Phone FROM Account WHERE Name IN: firmNames];

        
        for(Account acc: accList){
            String key = acc.Name;
            if(!accMap.containsKey(key)){
                accMap.put(key, acc);
            }
        } 

        for(Customer_Application__c ca: newList){
            if(caIds.contains(ca.Id)){
                String key = ca.Full_Legal_Name_of_the_Firm__c;
                if(accMap.containsKey(key)){
                    ca.Account__c = accMap.get(key).Id;
                }
            }
        }

    }
    
    public static void afterInsert(List<Customer_Application__c> newList, Map<Id, Customer_Application__c> oldMap ){
        
        Site mySite = [select Id from Site where Name = 'Customer_Application'];
        SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite.Id];
        
        List<Customer_Application__c> listApplication = new List<Customer_Application__c>();
        
        for(Customer_Application__c application : [SELECT Id, Form_Link__c FROM Customer_Application__c WHERE Id IN :newList]){
            
            if(!String.isNotBlank(application.Form_Link__c)){                
                application.Form_Link__c = mySiteDetail.SecureURL + '?id=' + EncodingUtil.urlEncode(PaymentGateway_Ctrl.processEncryption((string)application.Id,Label.Encryption_Key_Payment_Id),'UTF-8');    
                listApplication.add(application);
            }
        }
        
        if(!listApplication.isEmpty()){
            update listApplication;
        }
    }

}