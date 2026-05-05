public with sharing class Policy_Lawyer_Trg_Handler {

    public static Boolean InsertCustomerApplicationLawyer = true;

    public static void onAfterInsert(List<Policy_Lawyer__c> newList) {
        if(InsertCustomerApplicationLawyer){
            Set<String> policyIds = new Set<String>();
            Set<String> lawyerIds = new Set<String>();
            List<Customer_Application_Lawyer__c> cAppLawyers = new List<Customer_Application_Lawyer__c>();
            List<Policy_Lawyer__c> polLawyers = new List<Policy_Lawyer__c>();
            for(Policy_Lawyer__c pl : newList){
                if(String.isNotBlank(pl.Policy__c)){
                    policyIds.add(pl.Policy__c);
                }
            }
            
            Map<String, Policy__c> policyMap = new Map<String, Policy__c>([SELECT Id, RecordType.Name, Account__c, Customer_Application__c FROM Policy__c WHERE Id IN: policyIds]);
            

            for(Policy_Lawyer__c pl : newList){
                if(String.isNotBlank(pl.Policy__c) && policyMap.containsKey(pl.Policy__c) && policyMap.get(pl.Policy__c).RecordType.Name == 'Application' && String.isNotBlank(pl.Lawyer__c)){
                    lawyerIds.add(pl.Lawyer__c);
                }
            }
            
            Map<String, AccountContactJunction__c> lawyerMap = new Map<String, AccountContactJunction__c>([SELECT Id,Contact__c, Contact__r.Name, Contact__r.ARDC_Number__c, Contact__r.Suffix__c, Contact__r.Middle_Name__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.ISBA__c, Contact__r.Phone, Contact__r.MobilePhone, Contact__r.Email, Contact__r.Personal_Email__c, Contact__r.Birthdate, Contact__r.Bar_entry_date__c, Contact__r.Contact_Role__c, Contact__r.Prior_Acts_Date__c, Contact__r.Type__c  FROM AccountContactJunction__c WHERE Id IN: lawyerIds]);
            Set<String> accIds = new Set<String>();
            for(Policy_Lawyer__c pl : newList){
                if(String.isNotBlank(pl.Policy__c) && policyMap.containsKey(pl.Policy__c) && policyMap.get(pl.Policy__c).RecordType.Name == 'Application' && policyMap.get(pl.Policy__c).Customer_Application__c != null && String.isNotBlank(pl.Lawyer__c) && lawyerMap.containsKey(pl.Lawyer__c)){
                    Contact con = (Contact)lawyerMap.get(pl.Lawyer__c).getsObject('Contact__r');
                    Customer_Application_Lawyer__c cAppLawyer = new Customer_Application_Lawyer__c();
                    cAppLawyer.Customer_Application__c = policyMap.get(pl.Policy__c).Customer_Application__c;
                    cAppLawyer.Name = con.FirstName;
                    cAppLawyer.Middle_Initial__c = con.Middle_Name__c;
                    cAppLawyer.Last_Name__c = con.LastName;
                    cAppLawyer.ISBA_Number__c = con.ISBA__c;
                    cAppLawyer.ARDC_Number__c = con.ARDC_Number__c;
                    cAppLawyer.Cell_Phone__c = con.MobilePhone;
                    cAppLawyer.Birthday__c = con.Birthdate;
                    cAppLawyer.Firm_Email_Address__c = con.Email;
                    cAppLawyer.Personal_Email_Address__c = con.Personal_Email__c;
                    //cAppLawyer.Designation__c = pl.Contact_Role__c;
                    cAppLawyer.Date_of_Hire__c = pl.Hire_Date__c;
                    cAppLawyer.Average_Number_of_Hours_Worked__c = pl.Average_Hours_Per_Week__c;
                    cAppLawyers.add(cAppLawyer);
                }
                else if(String.isNotBlank(pl.Policy__c) && policyMap.containsKey(pl.Policy__c) && policyMap.get(pl.Policy__c).RecordType.Name == 'Policy'){
                    accIds.add(policyMap.get(pl.Policy__c).Account__c);
                }
            }

            if(!accIds.isEmpty()){
                Map<String, Policy__c> applicationMap = new Map<String, Policy__c>();
                system.debug([SELECT Id, Account__c,RecordType.Name FROM Policy__c WHERE Account__c IN: accIds ORDER BY Effective_Date__c DESC,CreatedDate DESC]);
                for(Policy__c pol: [SELECT Id, Account__c FROM Policy__c WHERE Account__c IN: accIds AND RecordType.Name = 'Application' ORDER BY Effective_Date__c DESC,CreatedDate DESC]){
                    applicationMap.put(pol.Account__c, pol);
                }
                for(Policy_Lawyer__c pl : newList){
                    if(String.isNotBlank(pl.Policy__c) && policyMap.containsKey(pl.Policy__c) && policyMap.get(pl.Policy__c).RecordType.Name == 'Policy' && applicationMap.containsKey(policyMap.get(pl.Policy__c).Account__c)){
                        Policy_Lawyer__c polLaw = new Policy_Lawyer__c();
                        polLaw = pl.Clone(false, true);
                        polLaw.Policy__c = applicationMap.get(policyMap.get(pl.Policy__c).Account__c).Id;
                        pollaw.Is_Application_Lawyer__c = true;
                        polLaw.Added_Date__c = null;
                        polLaw.Term__c = null;
                        polLaw.Policy_Lawyer_External_ID__c =  null;
                        System.debug('old polLaw => '+pl);
                        System.debug('polLaw => '+polLaw);
                        polLawyers.add(polLaw);
                    }
                }

            }

            if(!cAppLawyers.isEmpty()){
                Insert cAppLawyers;
            }
            if(!polLawyers.isEmpty()){
                Insert polLawyers;
            }
        }
    }
    public static void onAfterUpdate(List<Policy_Lawyer__c> newList, Map<Id,Policy_Lawyer__c> oldMap) {
        Set<String> pLawyerIds = new Set<String>();
        List<Customer_Application_Lawyer__c> cAppLawyers = new List<Customer_Application_Lawyer__c>();
        for(Policy_Lawyer__c pl : newList){
            if(String.isNotBlank(pl.Policy__c) && String.isNotBlank(pl.Lawyer__c) && pl.Deleted_Date__c != null && oldMap.get(pl.Id).Deleted_Date__c == null){
                pLawyerIds.add(pl.Id);
            }
        }
        if(!pLawyerIds.isEmpty()){
            List<Policy_Lawyer__c> polLawyers =  [SELECT Id, Lawyer__r.Contact__c, Policy__c, Policy__r.Account__c FROM Policy_Lawyer__c WHERE Id IN :pLawyerIds];
            
            if(!polLawyers.isEmpty() && polLawyers[0].Policy__r.Account__c != null){
                Set<String> conIds = new Set<String>();
                Set<String> accIds = new Set<String>();
                for(Policy_Lawyer__c pl : polLawyers){
                    accIds.add(pl.Policy__r.Account__c);
                    conIds.add(pl.Lawyer__r.Contact__c);
                }
                List<Policy__c> application = new List<Policy__c>([SELECT Id,(SELECT Id FROM Policy_Lawyers__r WHERE Lawyer__r.Contact__c IN : conIds) FROM Policy__c WHERE Account__c IN: accIds AND RecordType.Name = 'Application' ORDER BY Effective_Date__c DESC,CreatedDate DESC]);

                if(!application.isEmpty()){
                    List<Policy_Lawyer__c> polLawyersToDelete = new List<Policy_Lawyer__c>();
                    for(Policy__c a:application){
                        if(!a.Policy_Lawyers__r.isEmpty()){
                            for(Policy_Lawyer__c pl: a.Policy_Lawyers__r){
                                polLawyersToDelete.add(pl);
                            }
                        }
                    }
                    if(!polLawyersToDelete.isEmpty()){
                        Delete polLawyersToDelete;
                    }
                }
                
            }
        }
    }
    public static void onBeforeDelete(Map<Id,Policy_Lawyer__c> oldMap) {
        Set<Id> pLawyerIds = oldMap.keySet();
        List<Customer_Application_Lawyer__c> cAppLawyers = new List<Customer_Application_Lawyer__c>();
        if(!pLawyerIds.isEmpty()){
            List<Policy_Lawyer__c> polLawyers = new List<Policy_Lawyer__c>([SELECT Id, Lawyer__r.Contact__r.ISBA__c, Lawyer__r.Contact__r.ARDC_Number__c, Policy__c, Policy__r.Customer_Application__c FROM Policy_Lawyer__c WHERE  Policy__r.Customer_Application__c != null AND Id IN : pLawyerIds]);
            if(!polLawyers.isEmpty()){
                Set<String> cAppIds = new Set<String>();
                Set<String> ardcNums = new Set<String>();
                Set<String> isbaNums = new Set<String>();
                for(Policy_Lawyer__c pl: polLawyers){
                    cAppIds.add(pl.Policy__r.Customer_Application__c);
                    if(String.isNotBlank(pl.Lawyer__r.Contact__r.ARDC_Number__c)){
                        ardcNums.add(pl.Lawyer__r.Contact__r.ARDC_Number__c);
                    }
                    if(String.isNotBlank(pl.Lawyer__r.Contact__r.ISBA__c)){
                        isbaNums.add(pl.Lawyer__r.Contact__r.ISBA__c);
                    }
                }
                Map<String, Customer_Application__c> cAppMap = new Map<String, Customer_Application__c>([SELECT Id,(SELECT Id, ARDC_Number__c, ISBA_Number__c FROM Customer_Application_Lawyers__r WHERE ISBA_Number__c IN : isbaNums OR ARDC_Number__c IN : ardcNums) FROM Customer_Application__c WHERE Id IN : cAppIds]);

                for(Policy_Lawyer__c pl: polLawyers){
                    if(cAppMap.containsKey(pl.Policy__r.Customer_Application__c) && !cAppMap.get(pl.Policy__r.Customer_Application__c).Customer_Application_Lawyers__r.isEmpty() ){
                        for(Customer_Application_Lawyer__c cl: cAppMap.get(pl.Policy__r.Customer_Application__c).Customer_Application_Lawyers__r){
                            if(cl.ISBA_Number__c == pl.Lawyer__r.Contact__r.ISBA__c && cl.ARDC_Number__c == pl.Lawyer__r.Contact__r.ARDC_Number__c){
                                cAppLawyers.add(cl);
                            }
                        }
                    }
                }
                if(!cAppLawyers.isEmpty()){
                    Delete cAppLawyers;
                }
            }
        }
    }
}