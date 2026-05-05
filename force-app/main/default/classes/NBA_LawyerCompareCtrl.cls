public with sharing class NBA_LawyerCompareCtrl {

    public class NBA_LawyerCompareCtrlException extends Exception {}
    
    @AuraEnabled
    public static wrapper getData(String recId){
        try {
            wrapper wrap = new wrapper(); 
            Map<String, Policy_Lawyer__c> contactIds = new Map<String, Policy_Lawyer__c>(); 
            List<Contact> unMatchedContacts = new List<Contact>();
            List<lawyerWrapper> unMatchedlawyers = new List<lawyerWrapper>();
            List<lawyerWrapper> wrapperList = new List<lawyerWrapper>();
            Customer_Application__c onlineNba = [SELECT Id, PolicyId__c, Contact__c, Contact__r.CreatedDate, Account__r.CreatedDate, Contact_Name__c, Contact_Last_Name__c, Contact_E_mail_Address__c, Contact_Phone_Number__c, Full_Legal_Name_of_the_Firm__c, Trade_Name_or_D_B_A__c, Street__c, Address_2__c, City__c, State__c, Zip_Code__c, County__c, County__r.Name, Firm_Phone_Number__c, Date_Firm_Established__c, Website__c,RecordType.Name,
                                                 Account__c, Account__r.Name, Account__r.Trade_Name_or_D_B_A__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.Billing_Address_County__r.Name, Account__r.Billing_Address_County__c, Account__r.Phone, Account__r.Establish_Date__c, Account__r.Website__c,CreatedDate FROM Customer_Application__c WHERE Id = :recId LIMIT 1];
            
            
            //showLinkContact

            List<Policy__c> policyList = new List<Policy__c>();
            if(String.isNotBlank(onlineNba.PolicyId__c)){
                policyList = [SELECT Id, Name, Account__c, Account__r.Name, Account__r.Trade_Name_or_D_B_A__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.Billing_Address_County__r.Name, Account__r.Billing_Address_County__c, Account__r.Phone, Account__r.Establish_Date__c, Account__r.Website__c, (SELECT Id,Lawyer__r.Contact__c, Average_Hours_Per_Week__c, Hire_Date__c, Contact_Role__c FROM Policy_Lawyers__r) FROM Policy__c WHERE Id =:onlineNba.PolicyId__c];
                if(!policyList.isEmpty()){
                    for(Policy_Lawyer__c lawObj: policyList[0].Policy_Lawyers__r){
                        contactIds.put(lawObj.Lawyer__r.Contact__c, lawObj);
                    }
                }
            }

            List<Customer_Application_Lawyer__c> lawyers = new List<Customer_Application_Lawyer__c>([SELECT Id, Lawyer_Name__c, Name, Middle_Initial__c, Last_Name__c, ISBA_Number__c, ARDC_Number__c, Cell_Phone__c, Birthday__c, Firm_Email_Address__c, Personal_Email_Address__c, Customer_Application__c, Designation__c, Date_of_Hire__c, Average_Number_of_Hours_Worked__c
                                                                                                     ,Contact__c, Contact__r.CreatedDate, Contact__r.Name, Contact__r.ARDC_Number__c,Contact__r.Suffix__c,Contact__r.Middle_Name__c,Contact__r.FirstName,Contact__r.LastName, Contact__r.ISBA__c, Contact__r.Phone, Contact__r.MobilePhone,Contact__r.Email, Contact__r.Personal_Email__c, Contact__r.Birthdate, Contact__r.Bar_entry_date__c, Contact__r.Contact_Role__c, 
                                                                                                     Contact__r.Prior_Acts_Date__c, Contact__r.Type__c,CreatedDate
                                                                                                     FROM Customer_Application_Lawyer__c WHERE Customer_Application__c =:recId AND Is_Removed__c = false ORDER By Last_Name__c ASC]);
            Boolean flag = true;            
            if(!lawyers.isEmpty()){
                Map<String,Customer_Application_Lawyer__c> ardcNumsWithLawyer = new Map<String,Customer_Application_Lawyer__c>();

               
                for(Customer_Application_Lawyer__c lawyer : lawyers){
                    
                    if(lawyer.Firm_Email_Address__c == onlineNba.Contact_E_mail_Address__c){
                        flag = false;
                    }
                    
                    ardcNumsWithLawyer.put(lawyer.ARDC_Number__c, lawyer);
                }
                

                List<Contact> allPolicyContacts = new List<Contact>([SELECT Id, Name, ARDC_Number__c,Suffix__c,Middle_Name__c,FirstName,LastName, ISBA__c, Phone, MobilePhone, Email, Personal_Email__c, Birthdate, Bar_entry_date__c, Contact_Role__c, Prior_Acts_Date__c, Type__c,CreatedDate FROM Contact WHERE  Id IN: contactIds.keySet() ORDER By LastName ASC]);
                List<Contact> matchingContacts = new List<Contact>();
                
                for(Contact con :allPolicyContacts){
                    if(ardcNumsWithLawyer.containsKey(con.ARDC_Number__c)){
                        matchingContacts.add(con);
                    }
                    else {
                        unMatchedContacts.add(con);
                    }
                }


                Set<string> machingArdc = new Set<String>();

                if(!matchingContacts.isEmpty()){
                    for(Contact con: matchingContacts){
                        Integer count = 0;
                        String fullName = '';
                        machingArdc.add(con.ARDC_Number__c);
                        Customer_Application_Lawyer__c l = ardcNumsWithLawyer.get(con.ARDC_Number__c);
                        Policy_Lawyer__c pl =  contactIds.get(con.Id);
                        count += (l.Name != con.FirstName ? 1 : 0);
                        count += (l.Middle_Initial__c != con.Middle_Name__c ? 1 : 0);
                        count += (l.Last_Name__c != con.LastName ? 1 : 0);
                        count += (l.ISBA_Number__c != con.ISBA__c ? 1 : 0);
                        count += (l.ARDC_Number__c != con.ARDC_Number__c ? 1 : 0);
                        count += (l.Cell_Phone__c != con.MobilePhone ? 1 : 0);
                        count += (l.Birthday__c != con.Birthdate ? 1 : 0);
                        count += (l.Firm_Email_Address__c != con.Email ? 1 : 0);
                        count += (l.Personal_Email_Address__c != con.Personal_Email__c ? 1 : 0);

                        count += (l.Designation__c != pl.Contact_Role__c ? 1 : 0);
                        count += (l.Date_of_Hire__c != pl.Hire_Date__c ? 1 : 0);
                        count += (l.Average_Number_of_Hours_Worked__c != pl.Average_Hours_Per_Week__c ? 1 : 0);
                        fullName = l.Name;
                        fullName += l.Middle_Initial__c != null ? ' '+l.Middle_Initial__c : '';
                        fullName += l.Last_Name__c != null ? ' '+l.Last_Name__c : '';
                        fullName  = fullName.trim();
                        
                        lawyerWrapper lw = new lawyerWrapper(con, l, pl , count, fullName);
                        if(count > 0){
                            lw.isExpended = true;
                        }
                        wrapperList.add(lw);
                    }
                }
                
                for(String key: ardcNumsWithLawyer.keySet()){
                    if(!machingArdc.contains(key)){
						Integer count = 0;
                        Customer_Application_Lawyer__c l = ardcNumsWithLawyer.get(key);
                        
                        if(String.isNotBlank(l.Contact__c)){
                            Contact con = (Contact)l.getSobject('Contact__r');
                            count += (l.Name != con.FirstName ? 1 : 0);
                            count += (l.Middle_Initial__c != con.Middle_Name__c ? 1 : 0);
                            count += (l.Last_Name__c != con.LastName ? 1 : 0);
                            count += (l.ISBA_Number__c != con.ISBA__c ? 1 : 0);
                            count += (l.ARDC_Number__c != con.ARDC_Number__c ? 1 : 0);
                            count += (l.Cell_Phone__c != con.MobilePhone ? 1 : 0);
                            count += (l.Birthday__c != con.Birthdate ? 1 : 0);
                            count += (l.Firm_Email_Address__c != con.Email ? 1 : 0);
                            count += (l.Personal_Email_Address__c != con.Personal_Email__c ? 1 : 0);
                        }
                        String fullName = l.Name;
                        fullName += l.Middle_Initial__c != null ? ' '+l.Middle_Initial__c : '';
                        fullName += l.Last_Name__c != null ? ' '+l.Last_Name__c : '';
                        fullName  = fullName.trim();
                        lawyerWrapper lw = new lawyerWrapper(null, l, null, count, fullName);
        				lw.isUnMatched = true;
                        if(count > 0 || !String.isNotBlank(l.Contact__c)){
                            lw.isExpended = true;
                        }
        				unMatchedlawyers.add(lw);
                    }
                    /*if(matchingContacts.isEmpty() && !unMatchedlawyers.isEmpty()){
                        unMatchedlawyers[0].isExpended = true;
                    }*/
                }


            }
            
            if(flag && !String.isNotBlank(onlineNba.Contact__c)){
                wrap.showLinkContact = true;
            }
            else if(String.isNotBlank(onlineNba.Contact__c)){
				wrap.showLinkContact = false;                
            }
            else{
                wrap.showLinkContact = flag;
            }

            wrap.unMatchedContact = unMatchedContacts;
            wrap.unMatchedLawyers = unMatchedlawyers;
            wrap.lawyers = wrapperList;
            
            if(String.isNotBlank(onlineNba.Address_2__c)){
                onlineNba.Street__c += ' '+onlineNba.Address_2__c;
            }
             
            wrap.onlineNBA = onlineNba;
            if(String.isNotBlank(onlineNba.Account__c)){
                String street = '';
                if(String.isNotBlank(onlineNba.Account__r.BillingStreet)){
                    street = onlineNba.Account__r.BillingStreet;
                    street = street.replaceAll('\n', ' ');
                    street = street.replaceAll('\r', ' ');
                    onlineNba.Account__r.BillingStreet = street;
                }
                wrap.acc = onlineNba.Account__r; 
            } 
            else if(!policyList.isEmpty()) {
                String street = '';
                if(String.isNotBlank(policyList[0].Account__r.BillingStreet)){
                    street = policyList[0].Account__r.BillingStreet;
                    street = street.replaceAll('\n', ' ');
                    street = street.replaceAll('\r', ' ');
                    policyList[0].Account__r.BillingStreet = street;
                }
                wrap.acc = policyList[0].Account__r;
            }
            else{
                wrap.acc = new Account();
            }
            
            //contact part----23/2/26
            if(onlineNba.Contact__c != null){
                wrap.appContact = [ SELECT Id, FirstName, LastName, Email, Phone,CreatedDate FROM Contact WHERE Id = :onlineNba.Contact__c LIMIT 1];
            }
            
            return wrap;
        } catch (Exception e) {
            throw new NBA_LawyerCompareCtrlException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Contact> searchContactForLink(String searchKey) {
        
        String key = '%' + String.escapeSingleQuotes(searchKey) + '%'; 
        
        return [SELECT Id, Contact_Full_Name__c, ARDC_Number__c, ISBA__c, Email, Birthdate FROM Contact
            WHERE ( Contact_Full_Name__c LIKE :key OR ARDC_Number__c LIKE :key OR ISBA__c LIKE :key OR Email LIKE :key)
            ORDER BY Contact_Full_Name__c LIMIT 50];
    }

    @AuraEnabled
    public static List<AopWrapper> getAopData(String recId){
        try {
            List<AopWrapper> wrapList = new List<AopWrapper>(); 
            Customer_Application__c onlineNba = [SELECT Id, PolicyId__c,(SELECT Id, AOP_Factor__c, AOP_Factor__r.AOP_Mod__c, AOP_Factor__r.Name, Percentage__c FROM Customer_Application_AOP__r) FROM Customer_Application__c WHERE Id = :recId LIMIT 1];
            
            List<Customer_Application_AOP__c> aopList = new List<Customer_Application_AOP__c>();
            if(!onlineNba.Customer_Application_AOP__r.isEmpty()){
                aopList = onlineNba.Customer_Application_AOP__r;
            }

            List<Policy_AOP__c> policyAopList = new List<Policy_AOP__c>([SELECT Id, AOP__c, AOP__r.Name, Percentage__c, Policy__c FROM Policy_AOP__c WHERE Policy__c = :onlineNba.PolicyId__c]);
            
            Integer len = policyAopList.size() > aopList.size() ? policyAopList.size() : aopList.size();
            

            for(Integer i= 0; i < len; i++){
                AopWrapper wrap = new AopWrapper();
                wrap.aop = aopList.size() > i ? aopList[i] : new Customer_Application_AOP__c();
                wrap.policyAop = policyAopList.size() > i ? policyAopList[i] : new Policy_AOP__c();
                wrapList.add(wrap);
            }
            return wrapList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<AopWrapper> syncAopRecords(String recId){
        try {
            Customer_Application__c onlineNba = [SELECT Id, PolicyId__c,(SELECT Id, AOP_Factor__c, AOP_Factor__r.AOP_Mod__c, AOP_Factor__r.Name, Percentage__c FROM Customer_Application_AOP__r) FROM Customer_Application__c WHERE Id = :recId LIMIT 1];
            Policy__c appPolicy = [SELECT Id, Name,Account__r.Name,Effective_Date__c,Legacy_AOP_List__c,AOP_Master_Factor__c  FROM Policy__c WHERE Id =: onlineNba.PolicyId__c LIMIT 1];
            List<Policy_AOP__c> policyAopList = new List<Policy_AOP__c>();
            Delete [SELECT Id FROM Policy_AOP__c WHERE Policy__c =: onlineNba.PolicyId__c ];

            for(Customer_Application_AOP__c aop: onlineNba.Customer_Application_AOP__r){
                Policy_AOP__c polObj = new Policy_AOP__c();
                polObj.Policy__c = onlineNba.PolicyId__c;
                polObj.AOP__c = aop.AOP_Factor__c;
                polObj.Factor_Mod__c = aop.AOP_Factor__r.AOP_Mod__c;
                polObj.Percentage__c = aop.Percentage__c;
                policyAopList.add(polObj);
            }
            
            TriggerFactory.isUpdatePremium = false;             
            if(!policyAopList.isEmpty()){
                insert policyAopList;
            }
            TriggerFactory.isUpdatePremium = true;
            update appPolicy;
            return getAopData(recId);
        }catch (DmlException e) {
            throw new NBA_LawyerCompareCtrlException(e.getDmlMessage(0));
        }
        catch (Exception e) {
            throw new NBA_LawyerCompareCtrlException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean saveData(String conId, String lawyerId, String lawyerFieldName, String fieldName, Boolean isContact){
        try{
            List<Customer_Application_Lawyer__c> lawyer = (List<Customer_Application_Lawyer__c>) database.query('SELECT '+lawyerFieldName+' FROM Customer_Application_Lawyer__c WHERE Id =: lawyerId');
            if(isContact){
                Contact con = new Contact();
                con.Id = conId;
                con.put(fieldName, lawyer[0].get(lawyerFieldName));
                Update con;
            }
            else{
                Policy_Lawyer__c law = new Policy_Lawyer__c();
                law.Id = conId;
                law.put(fieldName, lawyer[0].get(lawyerFieldName));
                Update law;
            }
            return true;
        }
        catch(DmlException e){
            throw new NBA_LawyerCompareCtrlException(e.getDmlMessage(0));
        }
    }

    @AuraEnabled
    public static string Create_AddAccount(String recId){
        try {
            Customer_Application__c ca = [SELECT Id, Full_Legal_Name_of_the_Firm__c, Trade_Name_or_D_B_A__c,Signed_Date__c,Effective_Date_Requested__c,Date_Firm_Established__c,
                                          Street__c,City__c,State__c,Zip_Code__c,County__c,Address_2__c ,
                                          Website__c,Firm_Phone_Number__c,Application_Status__c,Firm_Fax_Number__c,NBA_App_Source__c,Underwriter_User__c,Sales_User__c
                                          FROM Customer_Application__c where Id =: recId LIMIT 1];
            
            Account accountRecord = new Account();
            accountRecord.Name = ca.Full_Legal_Name_of_the_Firm__c;
            accountRecord.Trade_Name_or_D_B_A__c  =  ca.Trade_Name_or_D_B_A__c;
            accountRecord.BillingStreet =  ca.Street__c;
            if(String.isNotBlank(ca.Address_2__c)){
                accountRecord.BillingStreet += ' '+ca.Address_2__c;
            }
            accountRecord.BillingCity =  ca.City__c;
            accountRecord.BillingState  =  ca.State__c;
            accountRecord.BillingPostalCode =  ca.Zip_Code__c;
            accountRecord.Billing_Address_County__c =  ca.County__c;
            accountRecord.Website__c =  ca.Website__c;
            accountRecord.Phone =  ca.Firm_Phone_Number__c ;
            accountRecord.Fax =  ca.Firm_Fax_Number__c; 
            accountRecord.Establish_Date__c = ca.Date_Firm_Established__c;
            
            Insert accountRecord;
            
            ca.Account__c = accountRecord.Id;
            Update ca;
            return 'success';
        }catch (DmlException e) {
            System.debug('Error => '+e.getDmlMessage(0)+'\n At => '+e.getLineNumber());
            throw new NBA_LawyerCompareCtrlException(e.getDmlMessage(0));
        }
        catch (Exception e) {
            System.debug('Error => '+e.getMessage()+'\n At => '+e.getLineNumber());
            throw new NBA_LawyerCompareCtrlException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void linkExistingContact(Id recId, Id contactId,Boolean isLawyer) {
        if(isLawyer){
            CustomerApplicationLawyerTriggerHandler.stopMatchingLawyer = true;
            Customer_Application_Lawyer__c l = [
                SELECT Id, Name, Customer_Application__c, Customer_Application__r.Contact__c, Customer_Application__r.Contact_E_mail_Address__c, Firm_Email_Address__c FROM Customer_Application_Lawyer__c
                WHERE Id = :recId
                LIMIT 1
            ];
            
            if(!String.isNotBlank(l.Customer_Application__r.Contact__c) && l.Customer_Application__r.Contact_E_mail_Address__c == l.Firm_Email_Address__c){
                update new Customer_Application__c(
                    Id = l.Customer_Application__c,
                    Contact__c = contactId
                );
            } 
            
            update new Customer_Application_Lawyer__c(
                Id = recId,
                Contact__c = contactId
            );
        }
        else{
			update new Customer_Application__c(
                Id = recId,
                Contact__c = contactId
            );            
        }
    } 
    
    @AuraEnabled
    public static void unlinkAccount(Id recId) {
        update new Customer_Application__c(
            Id = recId,
            Account__c = null
        );
    } 
    
    @AuraEnabled
    public static String createContactFromLawyer(Id lawyerId) {
        Account bucketAccount = [Select Id,Name from Account where Name =: Label.Bucket_Account limit 1];
        Customer_Application_Lawyer__c l = [ SELECT Name, Last_Name__c, Firm_Email_Address__c,Middle_Initial__c,ISBA_Number__c,Birthday__c,Personal_Email_Address__c,
            Cell_Phone__c, ARDC_Number__c, Customer_Application__c, Customer_Application__r.Contact__c, Customer_Application__r.Contact_E_mail_Address__c
            FROM Customer_Application_Lawyer__c
            WHERE Id = :lawyerId
            LIMIT 1
        ];
        
        Contact con = new Contact(
            FirstName = l.Name,
            LastName = l.Last_Name__c,
            AccountId = bucketAccount.Id,
            Type__c  = 'Lawyer',
            Middle_Name__c = l.Middle_Initial__c,
            ISBA__c = l.ISBA_Number__c,
   			ARDC_Number__c = l.ARDC_Number__c,
    		Birthdate = l.Birthday__c, 
            Email = l.Firm_Email_Address__c,
            MobilePhone = l.Cell_Phone__c,
            Personal_Email__c = l.Personal_Email_Address__c
        );
        insert con;
        
        l.Contact__c = con.Id;
        update l;
        
        if(!String.isNotBlank(l.Customer_Application__r.Contact__c) && l.Customer_Application__r.Contact_E_mail_Address__c == l.Firm_Email_Address__c){
            update new Customer_Application__c(
                Id = l.Customer_Application__c,
                Contact__c = con.Id
            );
        }
        
        return con.Id;
    }
    
    @AuraEnabled
    public static String createContactNBA(String recId) {
        Account bucketAccount = [Select Id,Name from Account where Name =: Label.Bucket_Account limit 1];
        
        Customer_Application__c app = [ SELECT Id, Contact_Name__c, Contact_Last_Name__c,Contact_Phone_Number__c, Account__c,Contact_E_mail_Address__c FROM Customer_Application__c WHERE Id = :recId LIMIT 1 ];
        
        Contact con = new Contact();
        con.FirstName = app.Contact_Name__c;
        con.Type__c  = 'Non-Lawyer';

        if(String.isNotBlank(app.Contact_Last_Name__c) ){
             con.LastName  = app.Contact_Last_Name__c;
        }
        else{
            con.LastName = app.Contact_Name__c;
            con.FirstName = null;
        }
       
        con.Email = app.Contact_E_mail_Address__c;
        con.Phone = app.Contact_Phone_Number__c;
        con.AccountId = app.Account__c;
        
        insert con;
        
        app.Contact__c = con.Id;
        Update app;
        
        return con.Id;
    }


    @AuraEnabled
    public static wrapper saveAccData(String recId, String accId, String nbaFieldName, String fieldName){
        try{
            List<Customer_Application__c> onlineNba = (List<Customer_Application__c>) database.query('SELECT '+nbaFieldName+' FROM Customer_Application__c WHERE Id =: recId');
            Account acc = new Account();
            acc.Id = accId;
            acc.put(fieldName, onlineNba[0].get(nbaFieldName));
            Update acc;
            return getData(recId);
        }
        catch(DmlException e){
            throw new NBA_LawyerCompareCtrlException(e.getDmlMessage(0));
        }
    }
    
    @AuraEnabled 
    public static String updateContactField(String conId, String fieldName, String val){
        Contact con = new Contact();
        con.Id = conId;
        con.put(fieldName, val);
        Update con;
        return 'Success';
    }
    
    @AuraEnabled
    public static String saveConData(String recId, String conId, String lwFieldName, String fieldName){
        try{
            List<Customer_Application_Lawyer__c> onlineNbaLawyer = (List<Customer_Application_Lawyer__c>) database.query('SELECT '+lwFieldName+' FROM Customer_Application_Lawyer__c WHERE Id =: recId');
            Contact con = new Contact();
            con.Id = conId;
            con.put(fieldName, onlineNbaLawyer[0].get(lwFieldName));
            Update con;
            return 'Success';
        }
        catch(DmlException e){
            throw new NBA_LawyerCompareCtrlException(e.getDmlMessage(0));
        }
    }

    @AuraEnabled
    public static wrapper deleteLawyer(String recId, String policyId, String conId){
        try {
            List<Policy_Lawyer__c> lawyer = [SELECT Id FROM Policy_Lawyer__c WHERE Lawyer__r.Contact__c = :conId AND Policy__c = :policyId]; 
            System.debug('lawyer: '+lawyer);
            Delete lawyer;
            return getData(recId);
        } catch (Exception e) {
            throw new NBA_LawyerCompareCtrlException(e.getMessage());
        }
    }

    public class AopWrapper{
        @AuraEnabled
        public Customer_Application_AOP__c aop {get;set;}
        @AuraEnabled
        public Policy_AOP__c policyAop{get;set;}
    }
    
    public class wrapper{
        @AuraEnabled
        public Account acc{get;set;}
        @AuraEnabled
        public Customer_Application__c onlineNBA {get;set;}
        @AuraEnabled
        public List<lawyerWrapper> lawyers{get;set;}
        @AuraEnabled
        public List<lawyerWrapper> unMatchedLawyers{get;set;}
        @AuraEnabled
        public List<Contact> unMatchedContact{get;set;}
        @AuraEnabled
        public Contact appContact {get;set;}
        @AuraEnabled
        public Boolean showLinkContact {get;set;}
    }
    
    public class lawyerWrapper {
        @AuraEnabled
        public String fullName{get;set;} 
        @AuraEnabled
        public Integer diffFieldsCount{get;set;} 
        @AuraEnabled
        public Boolean isExpended{get;set;} 
        @AuraEnabled
        public Contact con{get;set;} 
        @AuraEnabled
        public Policy_Lawyer__c policyLawyer{get;set;} 
        @AuraEnabled
        public Customer_Application_Lawyer__c lawyer{get;set;}
        @AuraEnabled
    	public Boolean isUnMatched { get; set; }


        public lawyerWrapper(Contact c, Customer_Application_Lawyer__c l, Policy_Lawyer__c pl,Integer count, String fullName){
            this.con = c;
            this.lawyer = l;
            this.isExpended = false;
            this.diffFieldsCount = count;
            this.fullName = fullName;
            this.policyLawyer = pl;
        }
    }
}