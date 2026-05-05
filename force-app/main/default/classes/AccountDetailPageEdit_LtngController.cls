/*
    Name : AccountDetailPageEdit_LtngController
    Author : 
    Date : 20 April 2017
    Description : this lightning page of clone account detail page
*/
public class AccountDetailPageEdit_LtngController{
public Account accountRecord {get;set;}
public Contact contactRecord {get;set;}
public String error{get;set;}
public String type{get;set;}
public String edIndex{get;set;}
Public List<Contact> appContactList {get;set;}
Private List<Contact> privateContactList = New List<Contact>();
public String returnURL{get;set;}
Private List<contactWrapper> ContactsPrivate = New List<contactWrapper>();
Public List<contactWrapper> contactList {get;set;}
    public Set<Id> contactIds {get;set;}
    public String firstName{get;set;}
    public String lastName{get;set;}
    public String ardcNumber{get;set;}
    public List<Contact> searchedContacts{get;set;}
    public String selectedContacts{get;set;}
    public Boolean contactEdit=false;
    public AccountDetailPageEdit_LtngController(ApexPages.StandardController stdController) {
        appContactList = New List<Contact>();
        contactList = New List<contactWrapper>();
        type = 'ALL';
        edIndex= '';
        this.accountRecord = (Account)stdController.getRecord();
        String accId = this.accountRecord.Id;
        contactIds = new Set<Id>();
        if(String.isEmpty(accountRecord.BillingState)){
            accountRecord.BillingState = 'IL';
        }
        if(String.isEmpty(accountRecord.ShippingState)){
            accountRecord.ShippingState = 'IL';
        }
        if(String.IsBlank(accId)){
            type = 'ALL';
        }else{
            integer i = -1;
            appContactList = [select Id, FirstName,LastName,Type__c,Title,Email,Phone,MobilePhone,Personal_Email__c,ISBA__c,Account_Number__c,Contact_Role__c ,Middle_Name__c,Primary_Contact__c,ARDC_Number__c,
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
            appContactList = [select Id, FirstName,LastName,Type__c,Title,Email,Phone,MobilePhone,Personal_Email__c,ISBA__c,Account_Number__c,Contact_Role__c ,Middle_Name__c,Primary_Contact__c,ARDC_Number__c,
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
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        if(retURL == null && accId!=null){
            returnURL = '/'+accId;
        }else if(retURL != null){
            returnURL = retURL;
        }else{
            returnURL = ApexPages.currentPage().getHeaders().get('Referer');
        }
    }
    public void fillWrapper(){
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
        County__c[] threatMappings = [SELECT Id,Name FROM County__c where Name != 'COOK(Chicago)' ORDER BY Name LIMIT 1000 ];
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
        options.add(new SelectOption('OR' ,'OR'));options.add(new SelectOption('PA' ,'PA'));options.add(new SelectOption('PR' ,'PR'));options.add(new SelectOption('RI' ,'RI'));options.add(new SelectOption('SC' ,'SC'));
        options.add(new SelectOption('SD' ,'SD'));options.add(new SelectOption('TN' ,'TN'));options.add(new SelectOption('TX' ,'TX'));options.add(new SelectOption('UT' ,'UT'));
        options.add(new SelectOption('VT' ,'VT'));options.add(new SelectOption('VA' ,'VA'));options.add(new SelectOption('WA' ,'WA'));options.add(new SelectOption('WI' ,'WI'));
        options.add(new SelectOption('WV' ,'WV'));options.add(new SelectOption('WY' ,'WY'));
        return options;
    }
    public pagereference saveAccount(){
        try{
            boolean isNew = false;
            if(accountRecord.Id == null){
                isNew = true;
            }
            upsert accountRecord ;
            User_Tracking__c userTrack;
            if(isNew){
                userTrack = UserTrackingHandler.createUserTrackingObject('Create', accountRecord.Id, accountRecord.Name);
            }else{
                userTrack = UserTrackingHandler.createUserTrackingObject('Edit', accountRecord.Id, accountRecord.Name);
            }
            insert userTrack;
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
                upsert privateContactList;
                for(Integer inte :  indexIds){
                    acr.add(new AccountContactRelation(contactid=privateContactList[inte].Id,accountid=accountRecord.Id));
                    System.debug(acr + 'acr' );
                }
            }
            if(!acr.isEmpty()){
                insert acr;
            }
            return new pagereference(returnURL );
        }catch(DMLException e){
             error = e.getdmlMessage(0).replaceAll('\'','');
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }catch(Exception e){
             error = e.getMessage().replaceAll('\'','');
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
        Contact[] contacts = [select Id, FirstName,LastName,Type__c,Title,Email,Phone,MobilePhone,Personal_Email__c,ISBA__c,Account_Number__c,Contact_Role__c ,Middle_Name__c,Primary_Contact__c,ARDC_Number__c,
                              Birthdate,Phone_Ext__c,Gender__c,MailingStreet,MailingCity,MailingState,MailingPostalCode,Request_No_Contact__c,Bar_Status__c,Bar_Membership_Geo__c,
                              Specialty_Bar_Association__c,Full_licensed_name_ARDC__c,ARDC_Insurance_Report__c,Authorized_To_Practice__c,Do_not_mail__c,DoNotCall,
                              AcctSeed__X1099_Vendor__c,AcctSeed__Default_1099_Box__c,MailingCountry,Bar_entry_date__c,Firm_ID__c,Prior_Acts_Date__c,Converted_from_lead__c,
                              Best_times_to_reach__c,Contacted_us__c,Policy_Expiration_Date__c,Paid_Through__c,ISBA_Paid_through__c,Last_telemarketing_list_submitted__c,
                              Last_emailed__c,Completed_form__c,Lead_returned_by_QCSS__c,QCSS_Date__c,Do_Not_Email__c,Category__c,Admitted_in_Illinois__c,Joined_Firm__c,Description,
                              AOP_1__c,AOP_2__c,Court__c,Address_Purpose__c,Act_On_Lead_Score__c,Lead_Week__c,AccountId,Suffix__c from Contact where id in : selectedContacts.split(',')];
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
    
    public void editRecordModalContact(){
        system.debug('@@@@@@@@@@@@@@ '+edIndex);
        if(String.IsNotBlank(edIndex)){
            contactRecord = ContactsPrivate.get(Integer.valueOf(edIndex)).contactRecord;
        }
    }
    public void deleteRecordContact(){
        try{
            error='';
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
    public static List<sObject> getLookupRecord(String likeString , String objectName) {
        if(String.IsNotBlank(likeString) && String.IsNotBlank(objectName)){
            likeString = '%'+likeString+'%';
            String query = '';
            
            query = 'SELECT Id, Name FROM '+objectName+' WHERE Name LIKE : likeString LIMIT 50';
            return database.query(query);
        }
        return null;
    }
    
    public void searchContact(){
        String query = 'select id,FirstName,LastName,Type__c,Title,Email,Phone,MobilePhone,Personal_Email__c,ISBA__c,ARDC_Number__c,Suffix__c,Middle_Name__c from Contact';
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
            System.debug(accountRecord.id+'herere');
            query = query+''+Filter+'and Id not in (select ContactId from AccountContactRelation where AccountId = : accountId) and Id not in : contactIds LIMIT 1000';
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