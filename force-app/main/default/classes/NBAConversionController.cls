/**
* Description : NBAConversionController controller is used to Convert Online NBA to Account Contact Quote and Application .				
* Date        : 03-08-2022
* 
___________________________________________________________________________Change Log_____________________________________________________________________

Modifiedby              Case-Log        Version         Change Date         Description
__________________________________________________________________________________________________________________________________________________________

**/
public class NBAConversionController {
    /* Method Name : getAccount
    * @Description : To get all the Account.
    * return       : accountData
    */
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccount(){
        List<Account> accountData = [select Id,Name from Account];
        
        return accountData;
    }
    /* Method Name : getContact
    * @Description : To get all the Contact.
    * return       : contactData
    */
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContact(){
        List<Contact> contactData = [select Id,Name,ISBA__c,ARDC_Number__c from Contact];
        return contactData;
    }
    /* Method Name : getCustomerApplication
    * @Description : To get Customer_Application_Lawyer__c for current NBA Record.
    * return       : customerApplicationData
    */
    @AuraEnabled(cacheable=true)
    public static List<Customer_Application_Lawyer__c> getCustomerApplication(String recordId){
        system.debug('recId=='+recordId);
        List<Customer_Application_Lawyer__c> customerApplicationData = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById,
                                                                 SystemModstamp, ARDC_Number__c, Average_Number_of_Hours_Worked__c, Customer_Application__c,Contact__c,Contact__r.Contact_Full_Name__c,
                                                                 Date_of_Hire__c, Designation__c, ISBA_Number__c, Last_Name__c, Middle_Initial__c, Firm_Email_Address__c, Personal_Email_Address__c
                                                                 FROM Customer_Application_Lawyer__c where Customer_Application__c =: recordId];
        //getcurentNBA(recordId);
        return customerApplicationData;
    }
    /* Method Name : getcurentNBA
    * @Description : To get Customer_Application__c for current NBA Record.
    * return       : customerApplicationData
    */
    @AuraEnabled(cacheable=true)
    public static List<Customer_Application_AOP__c> getAOP(String recordId){
        return [SELECT Id, Percentage__c,AOP_Factor__r.Name FROM Customer_Application_AOP__c WHERE Customer_Application__c = :recordId];
    }
    
    @AuraEnabled
    public static List<Customer_Application__c> getcurentNBA(String recordId){
        system.debug('recordId=='+recordId);
        List<Customer_Application__c> accountData = [SELECT Id, Account__c, Account__r.Name, Contact__c, Application_Status__c,City__c, County__c, Trade_Name_or_D_B_A__c, Street__c, State__c, Full_Legal_Name_of_the_Firm__c, Zip_Code__c, Website__c, Firm_Phone_Number__c, Firm_Fax_Number__c FROM Customer_Application__c where Id =: recordId];
        return accountData;
    }
     /* Method Name : createObject
    * @Description : To insert Account contact quote Application And Account Relation.
    * return       : Null
    */
    @AuraEnabled
    public static Id createObject(String recordId, List<string> newcontact,string searchAccount,List<string> oldContact,Map<String, String> lawyerContactMap){
        system.debug('recordId=='+recordId);
        system.debug('newcontact=='+newcontact);
        system.debug('searchAccount=='+searchAccount);
        system.debug('oldContact=='+oldContact);
        system.debug('lawyerContactMap ==> '+lawyerContactMap);
        List<Contact> cons = [SELECT Id, AccountId FROM Contact WHERE Id IN :oldContact];
        
        for(Contact c : cons){
            if(c.AccountId == null){
                c.AccountId = searchAccount;
            }
        }
        
        update cons;
        
        
        List<Customer_Application__c> onlineNBAList = new List<Customer_Application__c>();
        onlineNBAList = [SELECT Id,Account__c,Contact__c,Date_Firm_Established__c,Contact_E_mail_Address__c, Full_Legal_Name_of_the_Firm__c, Trade_Name_or_D_B_A__c,Signed_Date__c,Effective_Date_Requested__c,
                         Street__c,City__c,State__c,Zip_Code__c,County__c,Address_2__c ,
                         Website__c,Firm_Phone_Number__c,Application_Status__c,Firm_Fax_Number__c,NBA_App_Source__c,Underwriter_User__c,Sales_User__c,
                         (SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById,
                                               SystemModstamp, ARDC_Number__c, Average_Number_of_Hours_Worked__c, Customer_Application__c, 
                                               Date_of_Hire__c, Designation__c, ISBA_Number__c, Last_Name__c, Middle_Initial__c,Cell_Phone__c,Birthday__c,Personal_Email_Address__c,Firm_Email_Address__c,Contact__c
                                               FROM Customer_Application_Lawyers__r)
                         FROM Customer_Application__c where Id =: recordId LIMIT 1];
        
        if(!String.isNotBlank(onlineNBAList[0].Contact__c)){
            List<Contact> conList = new List<Contact>([SELECT Id, Email FROM Contact WHERE Email =: onlineNBAList[0].Contact_E_mail_Address__c LIMIT 1]);
            if(!conList.isEmpty()){
                onlineNBAList[0].Contact__c = conList[0].Id;
            }
        }

        List<Customer_Application_Lawyer__c> appLawyerList = new List<Customer_Application_Lawyer__c>();
        List<Customer_Application_Lawyer__c> updatedLawyers = new List<Customer_Application_Lawyer__c>();

        if(!onlineNBAList.isEmpty() && !onlineNBAList[0].Customer_Application_Lawyers__r.isEmpty()){
            appLawyerList = onlineNBAList[0].Customer_Application_Lawyers__r;
            if(!lawyerContactMap.keySet().isEmpty()){
                for(Customer_Application_Lawyer__c appLawyer : appLawyerList){
                    if(lawyerContactMap.containsKey(appLawyer.Id)){
                        appLawyer.Contact__c = lawyerContactMap.get(appLawyer.Id);
                        updatedLawyers.add(appLawyer);
                    }
                }
            }
        }

        EmailTemplate em = [SELECT Id, Subject FROM EmailTemplate WHERE DeveloperName = 'Online_NBA_Creation_Notification'];

        List<Task> CurrentRecTaskList = new List<Task>();
        if(em != NULL){
            CurrentRecTaskList = [Select id,Subject,Description,WhatId from Task where WhatId=: recordId AND Subject=: em.Subject];
        }
        List<Account> accountList = new List<Account>();
        Account accountRecord = new Account();
        if(searchAccount != null && searchAccount != '')
        {
            accountRecord = [select Id,Name,Trade_Name_or_D_B_A__c,BillingStreet,BillingCity,BillingState,
                             BillingPostalCode,Billing_Address_County__c,Website__c,Phone,Fax,County__c
                             From Account where Id=:searchAccount Limit 1];   
        }
        List<GEO_Factor__c> geofactor = [SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Master_Factor__c, County__c, From_Date__c, GEO_External_ID__c, Region_Code__c, Region_Factor_Value__c, To_Date__c, Appellate_District__c FROM GEO_Factor__c where County__c =: accountRecord.Billing_Address_County__c AND From_Date__c <= TODAY and To_Date__c >= TODAY order by CreatedDate desc];
        system.debug('geofactor=='+geofactor);
        Savepoint sp = Database.setSavepoint();
        try{
            if(!onlineNBAList.isEmpty() && onlineNBAList[0].Application_Status__c != 'Converted')
            {
                
                //Account Upsert
                accountRecord.Name = onlineNBAList[0].Full_Legal_Name_of_the_Firm__c;
                accountRecord.Trade_Name_or_D_B_A__c  =  onlineNBAList[0].Trade_Name_or_D_B_A__c;
                accountRecord.BillingStreet =  onlineNBAList[0].Street__c;
                if(String.isNotBlank(onlineNBAList[0].Address_2__c)){
                    accountRecord.BillingStreet += ' '+onlineNBAList[0].Address_2__c;
                }
                accountRecord.BillingCity =  onlineNBAList[0].City__c;
                accountRecord.BillingState  =  onlineNBAList[0].State__c;
                accountRecord.BillingPostalCode =  onlineNBAList[0].Zip_Code__c;
                accountRecord.Billing_Address_County__c =  onlineNBAList[0].County__c;
                accountRecord.Website__c =  onlineNBAList[0].Website__c;
                accountRecord.Phone =  onlineNBAList[0].Firm_Phone_Number__c ;
                accountRecord.Fax =  onlineNBAList[0].Firm_Fax_Number__c; 
                accountList.add(accountRecord);
                system.debug('accountList=='+accountList);
                upsert accountList;
                
                onlineNBAList[0].Account__c = accountRecord.Id;
                
                //Policy Creation
                Policy__c policyRecord = new Policy__c();
                Id policyRecordTypeId = Schema.SObjectType.Policy__c.getRecordTypeInfosByDeveloperName().get('Application').getRecordTypeId();
                policyRecord.Account__c = accountList[0].Id;
                policyRecord.Effective_Date__c = onlineNBAList[0].Effective_Date_Requested__c;
                policyRecord.Expiration_Date__c = policyRecord.Effective_Date__c.addMonths(12);
                policyRecord.NBA_App_Source__c = onlineNBAList[0].NBA_App_Source__c;
                policyRecord.Customer_Application__c = onlineNBAList[0].Id;
                policyRecord.Date_Signed__c = onlineNBAList[0].Signed_Date__c;
                policyRecord.Application_Received_Date__c = onlineNBAList[0].Signed_Date__c;
                policyRecord.RecordTypeId = policyRecordTypeId;
                policyRecord.Policy_Retroactive_Date__c = onlineNBAList[0].Date_Firm_Established__c;
                policyRecord.Firm_Contact__c = onlineNBAList[0].Contact__c;
                policyRecord.Renewal_Type__c = 'Online Invoice';
                //policyRecord.Sales_User__c = Label.NBA_Sales_User_Record_Id;
                policyRecord.Status__c = 'Inquiry';
                policyRecord.Online_NBA__c = true;
                
                if(String.isNotBlank(onlineNBAList[0].Underwriter_User__c)){
                    policyRecord.Underwriter_User__c = onlineNBAList[0].Underwriter_User__c;
                }
                
                policyRecord.Sales_User__c = String.isNotBlank(onlineNBAList[0].Sales_User__c)? onlineNBAList[0].Sales_User__c : Label.NBA_Sales_User_Record_Id;
                
                if(geofactor != null && !geofactor.isEmpty()){
                    policyRecord.County__c = geofactor[0].id;
                }
                insert policyRecord;
                
                // Note Creation on 20September 2022
                if(!CurrentRecTaskList.isEmpty()){
                    
                    Note__c newNote = new Note__c ();
                    newNote.Subject__c = CurrentRecTaskList[0].Subject;
                    newNote.Description__c = CurrentRecTaskList[0].Description;
                    newNote.Policy__c = policyRecord.Id;
                    newNote.RecordTypeId = Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Application/Policy').getRecordTypeId();
                    
                    Insert newNote;
                    
                }
                
                //Quote Creation
                List<Policy_Quote__c> referenceQuoteList = [SELECT Id, Coverage__c, Deductible__c, Customer_Application__c FROM Policy_Quote__c where Customer_Application__c =: recordId];
                List<Policy_Quote__c> quoteCloneList = new  List<Policy_Quote__c>();
                
                if(referenceQuoteList != null && !referenceQuoteList.isEmpty())
                {
                    for (Policy_Quote__c referenceQuote : referenceQuoteList){
                        Policy_Quote__c quoteRecord = new Policy_Quote__c();
                        quoteRecord.Coverage__c = referenceQuote.Coverage__c;
                        quoteRecord.Deductible__c = referenceQuote.Deductible__c;
                        quoteRecord.Policy__c = policyRecord.Id;
                        quoteCloneList.add(quoteRecord);  
                    }
                }
                if(quoteCloneList!=null && !quoteCloneList.isEmpty())
                {
                    insert quoteCloneList;
                }
                
                //AOP Creation
                List<Customer_Application_AOP__c> areaOfPracticeList = [SELECT Id, Customer_Application__c, Percentage__c, AOP_Factor__c FROM Customer_Application_AOP__c WHERE Customer_Application__c =: recordId];
                
                List<Policy_AOP__c> polAopToInsert = new List<Policy_AOP__c>();
                
                if(!areaOfPracticeList.isEmpty()){
                    for(Customer_Application_AOP__c aop: areaOfPracticeList){
                        Policy_AOP__c polAop = new Policy_AOP__c();
                        polAop.Policy__c = policyRecord.Id;
                        polAop.Percentage__c = aop.Percentage__c;
                        polAop.AOP__c = aop.AOP_Factor__c;
                        polAopToInsert.add(polAop);
                    }
                    //update areaOfPracticeList;
                    Insert polAopToInsert;
                }
                
                //Contact Creation
                List<Contact> ContactList = new List<Contact>();
                Map<String,Contact> lawyerWithContactMap = new Map<String,Contact>();
                List<Customer_Application_Lawyer__c> customerApplicationData = new List<Customer_Application_Lawyer__c>();
                if(newcontact != null){
                    for(Customer_Application_Lawyer__c lawyer : appLawyerList){
                        if(newcontact.contains(lawyer.Id)){
                            customerApplicationData.add(lawyer);
                        }
                    }
                }
                Account bucketAccount = [Select Id,Name from Account where Name =: Label.Bucket_Account limit 1];
                //Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Lawyer').getRecordTypeId();
                if(customerApplicationData != null && !customerApplicationData.isempty())
                {
                    for(Customer_Application_Lawyer__c applicationLawyer :customerApplicationData ){
                        Contact contactRecord = new Contact();
                        contactRecord.FirstName = applicationLawyer.Name;
                        contactRecord.Middle_Name__c  = applicationLawyer.Middle_Initial__c ;
                        contactRecord.LastName = applicationLawyer.Last_Name__c ;
                        contactRecord.ISBA__c = applicationLawyer.ISBA_Number__c; 
                        contactRecord.ARDC_Number__c = applicationLawyer.ARDC_Number__c;
                        contactRecord.AccountId = bucketAccount.Id;
                        contactRecord.Type__c  = 'Lawyer';
                        contactRecord.MobilePhone = applicationLawyer.Cell_Phone__c;
                        contactRecord.Birthdate = applicationLawyer.Birthday__c;
                        contactRecord.Email = applicationLawyer.Firm_Email_Address__c;
                        contactRecord.Personal_Email__c = applicationLawyer.Personal_Email_Address__c;
                        ContactList.add(contactRecord);
                        lawyerWithContactMap.put(applicationLawyer.Id, contactRecord);
                    }
                }    
                
                if(ContactList!=null && !ContactList.isEmpty())
                {
                    Insert ContactList;
                    
                    for(String key: lawyerWithContactMap.keySet()){
                        Customer_Application_Lawyer__c law = new Customer_Application_Lawyer__c();
                        law.Id = key;
                        law.Contact__c = lawyerWithContactMap.get(key).Id;
                        lawyerContactMap.put(law.Id, law.Contact__c);
                        updatedLawyers.add(law);
                    }
                }
                
                List<Contact> existingContactList = [Select Id, Name from Contact where Id IN:oldContact];
                for(Contact existingContact : existingContactList){
                    ContactList.Add(existingContact);
                }
                List<AccountContactRelation> queryAccountContactRelation = [Select Id,ContactId,AccountId from AccountContactRelation where AccountId =: accountList[0].Id];
                Set<Id> contactIdSet = new Set<Id>();
                Map<String,AccountContactRelation> junctionMap = new Map<String,AccountContactRelation>();

                for(AccountContactRelation duplicateContactId : queryAccountContactRelation){
                    system.debug('duplicateContactId => '+ duplicateContactId);
                    contactIdSet.add(duplicateContactId.ContactId);
                    junctionMap.put(duplicateContactId.ContactId, duplicateContactId);
                }
                
                List<AccountContactRelation> accountContactList = new List<AccountContactRelation>();
                for(Contact nbaContacts : ContactList )
                {
                    system.debug('nbaContacts.Id => '+ nbaContacts.Id);
                    if(!contactIdSet.contains(nbaContacts.Id)){
                        AccountContactRelation accountContactRelation = new AccountContactRelation();
                        accountContactRelation.ContactId  = nbaContacts.Id;
                        accountContactRelation.AccountId   = accountList[0].Id;
                        accountContactList.Add(accountContactRelation);
                        junctionMap.put(nbaContacts.Id, accountContactRelation);
                    }
                }

                system.debug('junctionMap KeySet => ' + junctionMap.keySet());
				
                
                if(accountContactList!=null && !accountContactList.isEmpty())
                {
                    insert accountContactList;
                }
                
               	Map<String,AccountContactJunction__c> contactWithAcjMap = new Map<String,AccountContactJunction__c>();
                List<AccountContactJunction__c> acjList = new List<AccountContactJunction__c>([SELECT Id,Account__c,Contact__c,Latest_Application__c FROM AccountContactJunction__c WHERE Contact__c IN : oldContact]);
                for(AccountContactJunction__c acj: acjList){
                    acj.Latest_Application__c = policyRecord.Id;
                    contactWithAcjMap.put(acj.Contact__c, acj);
                }
                
                for(String conId : oldContact){
                    if(!contactWithAcjMap.containsKey(conId)){
                        AccountContactJunction__c acj = new AccountContactJunction__c();
                        acj.Latest_Application__c = policyRecord.Id;
                        acj.Account__c = bucketAccount.Id;
                        acj.Contact__c = conId;
                        contactWithAcjMap.put(acj.Contact__c, acj);
                        acjList.add(acj);
                    }
                }
                
                upsert acjList;
                
                List<Policy_Lawyer__c> polLawyers = new List<Policy_Lawyer__c>();
                //create policy Lawyers
                for(Customer_Application_Lawyer__c law : appLawyerList){
                    
                    Policy_Lawyer__c policyLawyerObj = new Policy_Lawyer__c();
                    policyLawyerObj.Account__c = onlineNBAList[0].Account__c;
                    policyLawyerObj.Policy__c = policyRecord.Id;
                    policyLawyerObj.Prior_Act_Date__c = law.Date_of_Hire__c;
                    policyLawyerObj.Contact_Role__c = 'o';
                    policyLawyerObj.Rate_At__c = law.Average_Number_of_Hours_Worked__c > 20 ? 100 : 75;
                    policyLawyerObj.Lawyer__c =String.isNotBlank(law.Contact__c) ? contactWithAcjMap.get(law.Contact__c).Id : contactWithAcjMap.get(lawyerContactMap.get(law.Id)).Id;
                    policyLawyerObj.Is_Application_Lawyer__c = true;
                    polLawyers.add(policyLawyerObj);
                }
                
                if(!updatedLawyers.isEmpty()){
                    update updatedLawyers;
                }
                
                if(!polLawyers.isEmpty()){
                    insert polLawyers;
                }


                onlineNBAList[0].Application_Status__c = 'Converted';
                onlineNBAList[0].PolicyId__c = policyRecord.Id;
                update onlineNBAList[0];
                
                if(!String.isNotBlank(onlineNBAList[0].Contact__c)){
                    List<Contact> conList = new List<Contact>([SELECT Id FROM Contact WHERE Email =: onlineNBAList[0].Contact_E_mail_Address__c LIMIT 1]);
                    if(!conList.isEmpty()){
                        policyRecord.Firm_Contact__c = conList[0].Id;
                        Update policyRecord;
                    }
                }
                List<Note__c> notes = new List<Note__c>([SELECT Id FROM Note__c WHERE Customer_Application__c =: onlineNBAList[0].Id]);
                
                if(!notes.isEmpty()){
                    for(Note__c n: notes){
                        n.Account__c = onlineNBAList[0].Account__c;
                        n.Policy__c = policyRecord.Id;
                    }
                    Update notes;
                }
                
                return policyRecord.Id;
            }
            return null;
        }
        catch(DMLException e){
            Database.rollback(sp);
            throw new CustomException(e.getDmlMessage(0));
        }
    } 
    
    public class CustomException extends Exception {}
    
    @AuraEnabled(cacheable=true)
    public static List<Policy_Quote__c> getPolicyQuotes(String recordId){
        return [SELECT Id, Coverage__r.Name, Deductible__r.Name FROM Policy_Quote__c WHERE Customer_Application__c = :recordId];
    }
    
    @AuraEnabled
    public static Boolean checkRecord(String recId){
        try {
            Customer_Application__c app = [SELECT Id, Name, PolicyId__c,Sales_User__c,Underwriter_User__c FROM Customer_Application__c WHERE Id =: recId LIMIT 1];
            if(String.isNotBlank(app.PolicyId__c)){
                app.Application_Status__c = 'Converted';
                update app;
                
                Policy__c pol = new Policy__c();
                pol.Id = app.PolicyId__c;
                if(String.isNotBlank(app.Underwriter_User__c)){
                    pol.Underwriter_User__c = app.Underwriter_User__c;
                }
                if(String.isNotBlank(app.Sales_User__c)){
                    pol.Sales_User__c = app.Sales_User__c;
                }
                Update pol;
                
                return false;
            }
            return true;
        } catch (Exception e) {
            throw new CustomException(e.getMessage());
        }
    }
}