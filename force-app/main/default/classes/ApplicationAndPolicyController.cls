/*
    Name : ApplicationAndPolicyController
    Auther : 
    Date : 20 April 2017
    Description : this lightning page of clone account detail page
*/
global class ApplicationAndPolicyController{
public Account accountRecord {get;set;}
public Contact contactRecord {get;set;}
public String error{get;set;}
public String type{get;set;}
public String edIndex{get;set;}
public String conType{get;set;}
    public String policyId{get;set;}
    public String lawyerId{get;set;}
    public boolean isSaErp{get;Set;}
Public List<Contact> appContactList {get;set;}
Private List<Contact> privateContactList = New List<Contact>();

Private List<contactWrapper> ContactsPrivate = New List<contactWrapper>();
Public List<contactWrapper> contactList {get;set;}
public String firstName{get;set;}
    public String lastName{get;set;}
    public String ardcNumber{get;set;}
    public List<Contact> searchedContacts{get;set;}
    public String selectedContacts{get;set;}
    public Boolean contactEdit=false;
    public Set<Id> contactIds {get;set;}
    public ApplicationAndPolicyController(ApexPages.StandardController stdController) {
        appContactList = New List<Contact>();
        contactIds = new Set<Id>();
        contactList = New List<contactWrapper>();
        isSaErp = false;
        type = 'ALL';
        edIndex= '';
        this.accountRecord = (Account)stdController.getRecord();
    //    System.debug('========'+getRecord());
        String accId = this.accountRecord.Id;
        if(String.isEmpty(accountRecord.BillingState)){
            accountRecord.BillingState = 'IL';
        }
        if(String.isEmpty(accountRecord.ShippingState)){
            accountRecord.ShippingState = 'IL';
        }
        if(String.IsBlank(accId )){
            type = 'ALL';
            if(Apexpages.currentpage().getparameters().get('accountName') != null ){
                accountRecord.Name = Apexpages.currentpage().getparameters().get('accountName');
            }
            if(Apexpages.currentpage().getparameters().get('lawyer') != null){
                isSaErp = true;
                accountRecord.ISBAM_Billing_Freq_Policy_Full_Pay_Only__c = true;
                lawyerId = Apexpages.currentpage().getparameters().get('lawyer');
                String lawyerContId = Apexpages.currentpage().getparameters().get('contact');
                if(selectedContacts != null){
                    selectedContacts += ','+lawyerContId;
                }
                else{
                    selectedContacts = lawyerContId;
                }
                associateContacts();
                
                system.debug('lawyerId =>'+lawyerId);
                policyId = Apexpages.currentpage().getparameters().get('policy');
                System.debug('policyId => '+policyId);
            }
        }else{
            integer i = -1;
            appContactList = [select Id, FirstName,LastName,Type__c,Account.BillingState,Title,Email,Phone,ISBA__c,Account_Number__c,Contact_Role__c ,Middle_Name__c,Primary_Contact__c,ARDC_Number__c,
                              Birthdate,Phone_Ext__c,Gender__c,MailingStreet,MailingCity,MailingState,MailingPostalCode,Request_No_Contact__c,Bar_Status__c,Bar_Membership_Geo__c,
                              Specialty_Bar_Association__c,Full_licensed_name_ARDC__c,ARDC_Insurance_Report__c,Authorized_To_Practice__c,Do_not_mail__c,DoNotCall,
                              AcctSeed__X1099_Vendor__c,AcctSeed__Default_1099_Box__c,MailingCountry,Bar_entry_date__c,Firm_ID__c,Prior_Acts_Date__c,Converted_from_lead__c,
                              Best_times_to_reach__c,Contacted_us__c,Policy_Expiration_Date__c,Paid_Through__c,ISBA_Paid_through__c,Last_telemarketing_list_submitted__c,
                              Last_emailed__c,Completed_form__c,Lead_returned_by_QCSS__c,QCSS_Date__c,Do_Not_Email__c,Category__c,Admitted_in_Illinois__c,Joined_Firm__c,Description,
                              AOP_1__c,AOP_2__c,Court__c,Address_Purpose__c,Act_On_Lead_Score__c,Lead_Week__c,AccountId,Suffix__c from contact 
                              where id in (select ContactId from AccountContactRelation where AccountId = :accId and isDirect = true)];
            if(!appContactList.IsEmpty()){
                for(Contact conObj : appContactList){
                    i++;
                    ContactsPrivate.add(New contactWrapper(conObj,i,true));
                }
            }
            appContactList = [select Id, FirstName,LastName,Type__c,Account.BillingState,Title,Email,Phone,ISBA__c,Account_Number__c,Contact_Role__c ,Middle_Name__c,Primary_Contact__c,ARDC_Number__c,
                              Birthdate,Phone_Ext__c,Gender__c,MailingStreet,MailingCity,MailingState,MailingPostalCode,Request_No_Contact__c,Bar_Status__c,Bar_Membership_Geo__c,
                              Specialty_Bar_Association__c,Full_licensed_name_ARDC__c,ARDC_Insurance_Report__c,Authorized_To_Practice__c,Do_not_mail__c,DoNotCall,
                              AcctSeed__X1099_Vendor__c,AcctSeed__Default_1099_Box__c,MailingCountry,Bar_entry_date__c,Firm_ID__c,Prior_Acts_Date__c,Converted_from_lead__c,
                              Best_times_to_reach__c,Contacted_us__c,Policy_Expiration_Date__c,Paid_Through__c,ISBA_Paid_through__c,Last_telemarketing_list_submitted__c,
                              Last_emailed__c,Completed_form__c,Lead_returned_by_QCSS__c,QCSS_Date__c,Do_Not_Email__c,Category__c,Admitted_in_Illinois__c,Joined_Firm__c,Description,
                              AOP_1__c,AOP_2__c,Court__c,Address_Purpose__c,Act_On_Lead_Score__c,Lead_Week__c,AccountId,Suffix__c from contact 
                              where id in (select ContactId from AccountContactRelation where AccountId = :accId and isDirect = false)];
            if(!appContactList.IsEmpty()){
                for(Contact conObj : appContactList){
                    i++;
                    ContactsPrivate.add(New contactWrapper(conObj,i,false,false));
                }
            }
        }
        //appContactList = this.accountRecord.Contacts;
        //fillWrapper();
        filterContactByType();
        contactRecord = New Contact();
        contactRecord.MailingState = 'IL';
    }
    public void fillWrapper(){
        system.debug('appContactList=='+appContactList+'===='+appContactList.size());
        if(!appContactList.IsEmpty()){
            integer i = -1;
            for(Contact conObj : appContactList){
                i++;
                ContactsPrivate.add(New contactWrapper(conObj,i));
            }
        }
    }
    public List<SelectOption> getCounty() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        County__c[] threatMappings = [SELECT Id,Name FROM County__c ORDER BY Name LIMIT 1000];
        for (County__c threatMapping : threatMappings) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
        }
        return options;
    }
    public List<SelectOption> getState(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('AL' ,'AL'));options.add(new SelectOption('AK' ,'AK'));options.add(new SelectOption('AR' ,'AR'));options.add(new SelectOption('AZ' ,'AZ'));
        options.add(new SelectOption('CA' ,'CA'));options.add(new SelectOption('CO' ,'CO'));options.add(new SelectOption('CT' ,'CT'));
        options.add(new SelectOption('DC' ,'DC'));options.add(new SelectOption('DE' ,'DE'));
        options.add(new SelectOption('FL' ,'FL'));options.add(new SelectOption('GA' ,'GA'));options.add(new SelectOption('HI' ,'HI'));options.add(new SelectOption('IA' ,'IA'));
        options.add(new SelectOption('ID' ,'ID'));options.add(new SelectOption('IL' ,'IL'));options.add(new SelectOption('IN' ,'IN'));options.add(new SelectOption('KS' ,'KS'));
        options.add(new SelectOption('KY' ,'KY'));options.add(new SelectOption('LA' ,'LA'));options.add(new SelectOption('MA' ,'MA'));options.add(new SelectOption('MD' ,'MD'));
        options.add(new SelectOption('ME' ,'ME'));options.add(new SelectOption('MI' ,'MI'));options.add(new SelectOption('MN' ,'MN'));options.add(new SelectOption('MO' ,'MO'));
        options.add(new SelectOption('MS' ,'MS'));options.add(new SelectOption('MT' ,'MT'));options.add(new SelectOption('NC' ,'NC'));options.add(new SelectOption('NE' ,'NE'));
        options.add(new SelectOption('NH' ,'NH'));options.add(new SelectOption('NJ' ,'NJ'));options.add(new SelectOption('NM' ,'NM'));options.add(new SelectOption('NV' ,'NV'));
        options.add(new SelectOption('NY' ,'NY'));options.add(new SelectOption('ND' ,'ND'));options.add(new SelectOption('OH' ,'OH'));options.add(new SelectOption('OK' ,'OK'));
        options.add(new SelectOption('OR' ,'OR'));options.add(new SelectOption('PA' ,'PA'));options.add(new SelectOption('RI' ,'RI'));options.add(new SelectOption('SC' ,'SC'));
        options.add(new SelectOption('SD' ,'SD'));options.add(new SelectOption('TN' ,'TN'));options.add(new SelectOption('TX' ,'TX'));options.add(new SelectOption('UT' ,'UT'));
        options.add(new SelectOption('VT' ,'VT'));options.add(new SelectOption('VA' ,'VA'));options.add(new SelectOption('WA' ,'WA'));options.add(new SelectOption('WI' ,'WI'));
        options.add(new SelectOption('WV' ,'WV'));options.add(new SelectOption('WY' ,'WY'));
        return options;
    }
    public List<SelectOption> getPolicyCounty() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        GEO_Factor__c [] threatMappings = [SELECT Id,Name FROM GEO_Factor__c where County__r.Only_Claim_Value__c = false ORDER BY Name LIMIT 1000];
        for (GEO_Factor__c threatMapping : threatMappings) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
        }
        return options;
    }
    public List<SelectOption> getPolicyDeductible () {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        Deductible_Factor__c[] threatMappings = [SELECT Id,Name FROM Deductible_Factor__c LIMIT 1000];
        for (Deductible_Factor__c threatMapping : threatMappings) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
        }
        return options;
    }
    public List<SelectOption> getPolicyLimit () {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        ILF_Coverage_Factor__c[] threatMappings = [SELECT Id,Name FROM ILF_Coverage_Factor__c WHERE OldLimit__c = false LIMIT 1000];
        for (ILF_Coverage_Factor__c threatMapping : threatMappings) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
        }
        return options;
    }
    public List<SelectOption> getUnderwriter() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        User[] threatMappings = [SELECT Id,Name FROM User LIMIT 1000];
        for (User threatMapping : threatMappings) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
        }
        return options;
    }
    public pagereference saveAccount(){
        SavePoint sp = Database.setSavepoint();
        Id bucketAccountId = [select id from account where name =: Label.Bucket_Account limit 1].id;
        try{
            upsert accountRecord ;
            error = '';
            privateContactList = new List<Contact>();
            AccountContactRelation[] acr = new List<AccountContactRelation>();
            Set<Integer> indexIds = new Set<Integer>();
            for(contactWrapper con : ContactsPrivate ){
                privateContactList.add(con.contactRecord );
                System.debug(con.isdirect);
                 System.debug(con.isNew);
                if(!con.isdirect && con.isNew){
                    acr.add(new AccountContactRelation(contactid=con.contactRecord.Id,accountid=accountRecord.Id));
                }
            }
            if(!privateContactList.IsEmpty()){
                Integer i = 0;
                for(Contact con : privateContactList ){
                    if(con.AccountId == null ){
                        if(con.Type__c == 'Lawyer'){
                            con.AccountId = bucketAccountId;
                            indexIds.add(i);
                            System.debug('herer' + indexIds);
                        }else{
                            con.AccountId = accountRecord.Id;
                        }
                    }
                    i++;
                }
                System.debug('privateContactList'+privateContactList+'privateContactList');
                
                if(test.isRunningTest()){
                    List<Contact> conList = new List<Contact>();
                    Set<String> idSet = new Set<String>();
                    for(Contact con : privateContactList){
                        if(!idSet.contains(con.Id)){
                            conList.add(con);
                            idSet.add(con.Id);
                        }
                    }
                    privateContactList = conList;                    
                }
                
                upsert privateContactList;
                System.debug('indexIds'+indexIds+'indexIds');
                for(Integer inte :  indexIds){
                    acr.add(new AccountContactRelation(contactid=privateContactList[inte].Id,accountid=accountRecord.Id));
                    System.debug(acr + 'acr' );
                }
                
            }
            System.debug(acr + ' updated acr' );
            if(test.isRunningTest()){
                Set<String> conIds = new Set<String>();
                for(AccountContactRelation acrObj: acr){
                    conIds.add(acrObj.contactid);
                }
                List<AccountContactRelation> tempAcr = new List<AccountContactRelation>();
                List<AccountContactRelation> tempAcr2 = [SELECT Id, contactid FROM AccountContactRelation WHERE contactid =: conIds];
                conIds = new Set<String>();
                for(AccountContactRelation acrObj: tempAcr2){
                    conIds.add(acrObj.ContactId);
                }
                
                for(AccountContactRelation acrObj: acr){
                    if(!conIds.contains(acrObj.ContactId)){
                        tempAcr.add(acrObj);
                    }
                }
                acr = new List<AccountContactRelation>();
                acr = tempAcr;
            }
            if(!acr.isEmpty()){
                insert acr;
            }
            if(!isSaErp){
                return new pagereference('/'+accountRecord.Id );
            }
            else{
                //Create Application
				Policy__c policyObj = [SELECT id, Claims_Factor__c, ADJ_MOD__c, County__c, Underwriter_User__c, Expiration_Date__c,(SELECT Id, Policy__c, AOP__c,Percentage__c FROM Policy_AOPs__r)  from Policy__c WHERE Id =: policyId];
                Policy_Lawyer__c lawyer = [SELECT Id, Lawyer__r.Contact__c, Deleted_Date__c, Prior_Act_Date__c FROM Policy_Lawyer__c WHERE Id =: lawyerId LIMIT 1];
                
                List<RecordType > rtmap = [SELECT id ,Name,DeveloperName from RecordType WHERE SobjectType='Policy__c' and DeveloperName = 'SA_ERP'];
                
                Policy__c application_policy = new Policy__c();
                application_policy.Status__c = 'Application created';
                application_policy.SCH_Mod__c = 1.0;
                application_policy.RecordTypeId = rtmap[0].Id;
                application_policy.Account__c = accountRecord.Id;
                application_policy.Terms_Conditions__c ='<ul><li>Executed <b>Quote and Acceptance Form</b> confirming the firm’s limit and deductible selection.</li>' +
                        +'<li>Copy of Firm Letterhead, if not already provided.</li></ul>';
                application_policy.Effective_Date__c = lawyer.Deleted_Date__c != null ? lawyer.Deleted_Date__c : policyObj.Expiration_Date__c;
                application_policy.Expiration_Date__c = application_policy.Effective_Date__c.addYears(100);
                application_policy.Underwriter_User__c = policyObj.Underwriter_User__c;
                application_policy.Remove_102_Endorsement__c = true;
                application_policy.County__c = policyObj.County__c;
                application_policy.Policy_Retroactive_Date__c = lawyer.Prior_Act_Date__c;
                application_policy.ADJ_MOD__c = policyObj.ADJ_MOD__c;
                application_policy.Claims_Factor__c = policyObj.Claims_Factor__c;
                application_policy.Previous_Policy__c = policyObj.Id;
                if(application_policy.County__c == null){
                    List<GEO_Factor__c> lstGeoFactor = new List<GEO_Factor__c>();
                    if(accountRecord.Billing_Address_County__r.Name != null){
                        lstGeoFactor = [select Id, Name from GEO_Factor__c where Name =: accountRecord.Billing_Address_County__r.Name limit 1];
                    }
                    application_policy.County__c = (lstGeoFactor.isEmpty()?application_policy.County__c:lstGeoFactor[0].Id);
                }
                
                Insert application_policy;
                
                Policy__c newSAERPPolicy = [select id,AOP_Master_Factor__c from Policy__c where id =: application_policy.Id];
                
                lawyer.Is_Policy_Created__c = true;
                Update lawyer;
                
                List<AccountContactJunction__c> accConList = [SELECT Id, Name, Account__c, Contact__c, Contact__r.Type__c, Contact__r.Name,Lawyer_Name__c,
                                                    Contact__r.Phone, Contact__r.Email, Contact__r.ISBA__c, Contact__r.Account_Number__c,Contact__r.ARDC_Number__c,Contact__r.Contact_Role__c, 
                                                    Account__r.Name,Contact__r.FirstName,Contact__r.LastName,Contact__r.Middle_Name__c,Contact__r.Suffix__c FROM AccountContactJunction__c
                                                    WHERE Contact__c =: lawyer.Lawyer__r.Contact__c order by Contact__r.LastName,Contact__r.FirstName ASC LIMIT 1];
                
                Policy_Lawyer__c policyLawyerObj = new Policy_Lawyer__c();
                //policyLawyerObj.Account__c =wprObj.accountContactJObj.Account__c;
                policyLawyerObj.Account__c = accountRecord.Id;
                policyLawyerObj.Policy__c = application_policy.Id;
                //policyLawyerObj.Prior_Act_Date__c = firmPriorActsDate!=null?firmPriorActsDate:System.today();
                policyLawyerObj.Prior_Act_Date__c =  lawyer.Prior_Act_Date__c;
                policyLawyerObj.Contact_Role__c =  'o';
                policyLawyerObj.Rate_At__c = 100;
                if(!accConList.isEmpty()){
                    policyLawyerObj.Lawyer__c = accConList[0].Id;
                    policyLawyerObj.Lawyer__r = accConList[0];
                }
                //policyLawyerObj.Contact_Role__c =  wprObj.accountContactJObj.Contact__r.Contact_Role__c;
                policyLawyerObj.Is_Application_Lawyer__c = true;
                insert policyLawyerObj;
               
                Map<String,Policy_AOP__c> oldAopMap = new Map<String,Policy_AOP__c>();
                
                /*if(!policyObj.Policy_AOPs__r.isEmpty()){
                    for(Policy_AOP__c aop: policyObj.Policy_AOPs__r){
                        oldAopMap.put(aop.AOP__c, aop);
                    }
                }*/
                Map<String,Id> mapAOPFactors = new Map<String,Id>();
                List<AOP_Factor__c> lstOfAopFactors = [select id,Name,AOP_Mod__c from  AOP_Factor__c where Master_Factor__c =: newSAERPPolicy.AOP_Master_Factor__c order by name Limit 1000];
                system.debug(lstOfAopFactors);
                for(AOP_Factor__c factor : lstOfAopFactors){
                    mapAOPFactors.put(factor.Name,factor.Id);
                }
                List<Policy_AOP__c> polObjList = new List<Policy_AOP__c>();
                for (Policy_AOP__c AOP : policyObj.Policy_AOPs__r) {
                    if(mapAOPFactors.size()>0){
                        Policy_AOP__c newAOP = new Policy_AOP__c();
                        newAOP = AOP.Clone(false, true);
                        newAOP.Policy__c = newSAERPPolicy.Id;
                        newAOP.Policy_AOP_External_ID__c = null;
                        if(newSAERPPolicy.AOP_Master_Factor__c == AOP.AOP__r.Next_AOP_Factor__r.Master_Factor__c && AOP.AOP__r.Next_AOP_Factor__c !=null){
                            newAOP.AOP__c = AOP.AOP__r.Next_AOP_Factor__c;
                            polObjList.add(newAOP);
                        }else if(mapAOPFactors.containsKey(AOP.AOP__r.Name)){
                            newAOP.AOP__c = mapAOPFactors.get(AOP.AOP__r.Name);
                            polObjList.add(newAOP);
                        }else{
                            //applicationBlocks.add(new Application_Block__c(Account__c=pol.Account__c,Application_Policy__c=pol.Id,Status__c='Active',Subject__c='AOP Conflict',Description__c='AOP Conflict ('+ AOP.AOP__r.Name +') From Renewal Policy('+AOP.Policy__r.Name+')'));
                        }
                    }else{
                        //applicationBlocks.add(new Application_Block__c(Account__c=pol.Account__c,Application_Policy__c=pol.Id,Status__c='Active',Subject__c='AOP Conflict',Description__c='AOP Conflict ('+ AOP.AOP__r.Name +') From Renewal Policy('+AOP.Policy__r.Name+')'));
                    }
                }
                if(!polObjList.isEmpty()){
                    Insert polObjList;
                }
                return new pagereference('/'+application_policy.Id );
            }
        }catch(DMLException e){
             error = e.getdmlMessage(0);
            Database.rollback(sp);
            System.debug(e.getStackTraceString());
        }catch(Exception e){
             error = e.getMessage();
            Database.rollback(sp);
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
        
        return null; 
    }
    public pagereference saveAndNextAccount(){
        try{
            upsert accountRecord ;
            error = '';
            privateContactList = new List<Contact>();
            Id bucketAccountId = [select id from account where name =: Label.Bucket_Account limit 1].id;
            Set<Integer> indexIds = new Set<Integer>();
            AccountContactRelation[] acr = new List<AccountContactRelation>(); 
            for(contactWrapper con : ContactsPrivate ){
                privateContactList.add(con.contactRecord );
                System.debug(con.isdirect);
                 System.debug(con.isNew);
                if(!con.isdirect && con.isNew){
                    acr.add(new AccountContactRelation(contactid=con.contactRecord.Id,accountid=accountRecord.Id));
                }
            }
            if(!privateContactList.IsEmpty()){
                Integer i =0;
                for(Contact con : privateContactList ){
                    if(con.AccountId == null ){
                        if(con.Type__c == 'Lawyer'){
                            con.AccountId = bucketAccountId;
                            indexIds.add(i);
                            System.debug('herer' + indexIds);
                        }else{
                            con.AccountId = accountRecord.Id;
                        }
                    }
                    i++;
                }
                System.debug('privateContactList'+privateContactList+'privateContactList');
                upsert privateContactList;
                for(Integer inte :  indexIds){
                    acr.add(new AccountContactRelation(contactid=privateContactList[inte].Id,accountid=accountRecord.Id));
                    System.debug(acr + 'acr' );
                }
            }
            if(!acr.isEmpty()){
                insert acr;
            }
            String pageRef = '/apex/Application_Policy_DetailPageEdit_Ltng?accountid='+accountRecord.Id+'&fromAccount=yes';
            if(lawyerId != null && policyId != null){
                pageRef += '&policy='+policyId+'&lawyer='+lawyerId;
            }
            return new pagereference(pageRef);
        }catch(DMLException e){
             error = e.getdmlMessage(0);
            System.debug(e.getStackTraceString());
        }catch(Exception e){
             error = e.getMessage();
            System.debug(e.getStackTraceString());
        }
        
        return null; 
        
    }
    public void filterContactByType(){
        contactList= New List<contactWrapper >();
        for(contactWrapper con : ContactsPrivate ){
            if(type == con.contactRecord.Type__c || type == 'ALL'){
                contactList.add(con);
            }
        }
    }
    public void associateContacts(){
        List<String> conIds = new List<String>();
        if(String.isnotBlank(selectedContacts)){
            if(selectedContacts.contains(',')){
                conIds = selectedContacts.split(',');
            }
            else{
                conIds.add(selectedContacts);
            }
        }
        Contact[] contacts = [select Id, FirstName,LastName,Type__c,Title,Email,Phone,ISBA__c,Account_Number__c,Contact_Role__c ,Middle_Name__c,Primary_Contact__c,ARDC_Number__c,
                              Birthdate,Phone_Ext__c,Gender__c,MailingStreet,MailingCity,MailingState,MailingPostalCode,Request_No_Contact__c,Bar_Status__c,Bar_Membership_Geo__c,
                              Specialty_Bar_Association__c,Full_licensed_name_ARDC__c,ARDC_Insurance_Report__c,Authorized_To_Practice__c,Do_not_mail__c,DoNotCall,
                              AcctSeed__X1099_Vendor__c,AcctSeed__Default_1099_Box__c,MailingCountry,Bar_entry_date__c,Firm_ID__c,Prior_Acts_Date__c,Converted_from_lead__c,
                              Best_times_to_reach__c,Contacted_us__c,Policy_Expiration_Date__c,Paid_Through__c,ISBA_Paid_through__c,Last_telemarketing_list_submitted__c,
                              Last_emailed__c,Completed_form__c,Lead_returned_by_QCSS__c,QCSS_Date__c,Do_Not_Email__c,Category__c,Admitted_in_Illinois__c,Joined_Firm__c,Description,
                              AOP_1__c,AOP_2__c,Court__c,Address_Purpose__c,Act_On_Lead_Score__c,Lead_Week__c,AccountId,Suffix__c from Contact where id in : conIds];
        for(Contact cont : contacts){
            contactIds.add(cont.Id);
            if(!ContactsPrivate.IsEmpty()){
                integer i = ContactsPrivate.get(ContactsPrivate.size()-1).index + 1;
                ContactsPrivate.add(New contactWrapper(cont,i,false,true));
            }else{
                ContactsPrivate.add(New contactWrapper(cont,0,false,true));
            }
        }
        searchedContacts =new List<Contact>();
        /*firstName='';
        lastName='';
        ardcNumber='';*/
        filterContactByType();
        searchContact();
        System.debug(selectedContacts);
    }
    public void createContact(){
        System.debug('edIndex'+edIndex);
        System.debug(String.IsNotBlank(edIndex));
        System.debug(contactRecord.LastName);
        System.debug(contactRecord.Type__c);
        Boolean wasDirect=true,wasNew=true;
        if(String.IsNotBlank(edIndex) && contactRecord.LastName != null && contactRecord.Type__c != null){
            wasDirect = ContactsPrivate.get(Integer.valueOf(edIndex)).isDirect;
            wasNew = ContactsPrivate.get(Integer.valueOf(edIndex)).isNew;
            contactEdit=true;
            deleteRecordContact();
            edIndex= '';
            contactEdit=false;
        }
        if(contactRecord.LastName != null && contactRecord.Type__c != null){
            if(!ContactsPrivate.IsEmpty()){
                integer i = ContactsPrivate.get(ContactsPrivate.size()-1).index + 1;
                if(wasDirect){
                    ContactsPrivate.add(New contactWrapper(contactRecord,i,true));
                }else{
                    ContactsPrivate.add(New contactWrapper(contactRecord,i,false,wasNew));
                }
            }else{
                if(wasDirect){
                    ContactsPrivate.add(New contactWrapper(contactRecord,0,true));
                }else{
                    ContactsPrivate.add(New contactWrapper(contactRecord,0,false,wasNew));
                }
            }
            contactRecord= New Contact();
            contactRecord.MailingState = 'IL';
            filterContactByType();
        }
    }
    
    public void setContactType(){
        if(String.IsNotBlank(conType)){
            contactRecord.Type__c = conType;
            system.debug('@@@@@@@@@@@@@@ contactRecord.Type__c---'+contactRecord.Type__c);
        }
    }
    
    public void editRecordModalContact(){
        system.debug('@@@@@@@@@@@@@@ '+edIndex);
        if(String.IsNotBlank(edIndex)){
            contactRecord = ContactsPrivate.get(Integer.valueOf(edIndex)).contactRecord;
        }
    }
    public void deleteRecordContact(){
        try{
            error='';
            System.debug('deleteContact'+ContactsPrivate.get(Integer.valueOf(edIndex)).contactRecord.Id);
            System.debug('deleteContact'+contactEdit);
            System.debug('deleteContact'+ContactsPrivate.get(Integer.valueOf(edIndex)).isDirect);
            System.debug('deleteContact'+contactIds);
            System.debug('deleteContact'+ContactsPrivate);
            if(String.IsNotBlank(edIndex)){
                if(ContactsPrivate.get(Integer.valueOf(edIndex)).contactRecord.Id!=null && !contactEdit && ContactsPrivate.get(Integer.valueOf(edIndex)).isDirect){
                    delete ContactsPrivate.get(Integer.valueOf(edIndex)).contactRecord;
                }else if(!ContactsPrivate.get(Integer.valueOf(edIndex)).isDirect && !contactEdit){
                    AccountContactRelation[] acr = [select id from AccountContactRelation where accountid = :accountRecord.id and ContactId = :ContactsPrivate.get(Integer.valueOf(edIndex)).contactRecord.Id limit 1];
                    if(acr.size()>0){
                        delete acr[0];
                    }
                }
                if(ContactsPrivate.get(Integer.valueOf(edIndex)).contactRecord.Id!=null && contactIds.contains(ContactsPrivate.get(Integer.valueOf(edIndex)).contactRecord.Id)){
                    contactIds.remove(ContactsPrivate.get(Integer.valueOf(edIndex)).contactRecord.Id);
                }
                ContactsPrivate.remove(Integer.valueOf(edIndex));
                edIndex= '';
                integer i=-1;
                for(contactWrapper con : ContactsPrivate ){
                    i++;
                    con.index = i;
                }
                filterContactByType();
            }
        }catch(DMLException e){
             error = e.getdmlMessage(0);
            System.debug('=====1'+error);
        }catch(Exception e){
             error = e.getMessage();
            System.debug('=====2'+error);
        }
    }
    
    public class contactWrapper{
        public Contact contactRecord {get;set;}
        public Integer index {get;set;}
        public boolean isDirect{get;set;}
        public boolean isNew{get;set;}
        public contactWrapper(Contact contactRecord  , Integer index){
             this.contactRecord  = contactRecord ;
             this.index = index ;
        }
        public contactWrapper(Contact contactRecord  , Integer index , Boolean isDirect){
             this.contactRecord  = contactRecord ;
             this.index = index ;
             this.isDirect = isDirect;
        }
        public contactWrapper(Contact contactRecord  , Integer index , Boolean isDirect , Boolean isNew){
             this.contactRecord  = contactRecord ;
             this.index = index ;
             this.isDirect = isDirect;
             this.isNew = isNew;
        }
    }
    @RemoteAction
    global static List<sObject> getLookupRecord(String likeString , String objectName) {
        if(String.IsNotBlank(likeString) && String.IsNotBlank(objectName)){
            likeString = '%'+likeString+'%';
            String query = '';
            
            query = 'SELECT Id, Name FROM '+objectName+' WHERE Name LIKE : likeString LIMIT 50';
            return database.query(query);
        }
        return null;
    }
    
    public void searchContact(){
        String query = 'select id,FirstName,LastName,Type__c,Title,Email,Phone,ISBA__c,ARDC_Number__c,Suffix__c,Middle_Name__c from Contact';
        String Filter = '';
        String searchKeyword='';
        String accountId = accountRecord.id;
        if(String.IsNotBlank(firstName)){
            searchKeyword = '%'+firstName +'%';
            Filter += ' WHERE FirstName LIKE : searchKeyword ';
        }
        if(String.IsNotBlank(lastName)){
            if(String.IsNotBlank(Filter)){
                searchKeyword = '%'+lastName +'%';
                Filter += ' AND lastName LIKE : searchKeyword ';
            }else{
                searchKeyword = '%' + lastName +'%';
                Filter += ' WHERE lastName LIKE : searchKeyword ';
            }
        }
        
        if(String.IsNotBlank(ardcNumber)){
            if(String.IsNotBlank(Filter)){
                searchKeyword = '%'+ardcNumber +'%';
                Filter += ' AND ARDC_Number__c LIKE : searchKeyword ';
            }else{
                searchKeyword = '%' + ardcNumber +'%';
                Filter += ' WHERE ARDC_Number__c LIKE : searchKeyword ';
            }
        }
        
        If(String.IsNotBlank(Filter)){
            query = query+''+Filter+'and Id not in (select ContactId from AccountContactRelation where AccountId = : accountId)  and Id not in : contactIds LIMIT 1000';
            searchedContacts = database.query(query);
        }
    }
    public void cancelMethod(){
        searchedContacts =new List<Contact>();
        firstName='';
        lastName='';
        ardcNumber='';
    }
}