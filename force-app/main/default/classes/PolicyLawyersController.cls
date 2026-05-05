public class PolicyLawyersController{
    //public 
    public List<WrapperClass> modalList{get;set;}
    public List<Policy_Lawyer__c> policyLawyerList{get;set;}
    public Boolean isSaErp {get;set;}
    public Boolean isPolicySaErp {get;set;}
    public String appId{get;set;}
    public String errorMessage{get;set;}
    public Boolean status{get;set;}
    public String policyLawyerId{get;set;}
    public Integer indexPolicyLawyer{get;set;}
    public Boolean ContactPartRender{get;set;}
    public Contact contactRec{get;set;}
    public String firstName{get;set;}
    public String lastName{get;set;}
    public String ardcNumber{get;set;}
    public List<Contact> searchedContacts{get;set;}
    public String selectedContacts{get;set;}
    private Date firmPriorActsDate;
    //private
    private Map<Id,Contact> contactMap{get;set;}
    public List<Policy__c> applicationPolicyList{get;set;}
    String firmId;
    
    public Boolean showAdvancedFields{get; set;}
    //constructor
    public PolicyLawyersController(){
        isSaErp = false;
        isPolicySaErp = false;
        system.debug('in constructor');
        
        
        
        contactMap = new Map<Id,Contact>();
        modalList = new List<WrapperClass>();
        if(ApexPages.currentPage().getParameters().get('policy')!=null){
            isSaErp = true;
            isPolicySaErp = true;
        }
        appId =  ApexPages.currentPage().getParameters().get('Id');
        policyLawyerId = '';
        errorMessage = '';
        ContactPartRender = false;
        utilizeFuntion();
        
        showAdvancedFields = false;
        Set<Id> setAdvanceUserId = new Set<Id>();
        for(GroupMember objGroupMember : [SELECT Id, UserOrGroupId FROM GroupMember where Group.Name = 'Advance Users']){
            setAdvanceUserId.add(objGroupMember.UserOrGroupId);
        }
        
        showAdvancedFields = (setAdvanceUserId.contains(UserInfo.getUserId())?true:false);
    }
    
    public void utilizeFuntion(){
        modalList = new List<WrapperClass>();
        contactMap = new Map<Id,Contact>();
        ContactPartRender = false;
        Set<String> setOfPolicyLawyer = new Set<String>();
        
        applicationPolicyList = [SELECT Name, Id, Previous_Policy__c,RecordType.DeveloperName, Account__c,Account__r.Name,Account__r.Firm_Prior_Acts_Date__c,Policy_Retroactive_Date__c FROM Policy__c WHERE Id =: appId AND Account__c != null];
        firmPriorActsDate = applicationPolicyList[0].Policy_Retroactive_Date__c;
        isPolicySaErp = applicationPolicyList[0].RecordType.DeveloperName == 'SA_ERP' ? true : false;
        /*if(policyLawyerList!=null && policyLawyerList.size()>0){
            policyLawyerList.addAll([SELECT Name, Id, Lawyer__r.Name, Prior_Act_Date__c, Step__c, Policy_Effective_Date__c, Lawyer__r.Id,Rate_At__c, 
                                     Hire_Date__c, X10_10__c,Overriding_Step_Value__c,Lawyer__r.Contact__r.ISBA__c,Lawyer__r.Contact__r.ARDC_Number__c,Lawyer_Name__c,Contact_Role__c  FROM Policy_Lawyer__c WHERE Policy__c =: appId and Id not in: policyLawyerList order by Lawyer__r.Contact__r.lastname asc,Lawyer__r.Contact__r.firstname LIMIT 1000]);
        }else{*/
            policyLawyerList = [SELECT Name, Id, Lawyer__r.Name, Prior_Act_Date__c, Step__c, Policy_Effective_Date__c, Lawyer__r.Id,Rate_At__c, Lawyer__r.Lawyer_Name__c,Policy__c,
                            Hire_Date__c, X10_10__c,Overriding_Step_Value__c,Lawyer__r.Contact__c,Lawyer__r.Contact__r.ISBA__c,Lawyer__r.Contact__r.ARDC_Number__c,Lawyer_Name__c,Contact_Role__c,Lawyer__r.Contact__r.Email,Lawyer__r.Contact__r.MobilePhone,Lawyer__r.Contact__r.Phone, Lawyer__r.Contact__r.Personal_Email__c  FROM Policy_Lawyer__c WHERE Policy__c =: appId order by Lawyer__r.Contact__r.lastname asc,Lawyer__r.Contact__r.firstname LIMIT 1000];
        //}
        
        
        if( policyLawyerList.size() > 0 ){
            for( Policy_Lawyer__c policyObj : policyLawyerList ){
                setOfPolicyLawyer.add(policyObj.Lawyer__r.Id);
            }
        }
        
        if(applicationPolicyList.size() > 0 ){
            
            Map<String , Date> priorActDateMap = new Map<String, Date>();
            if(applicationPolicyList[0].Previous_Policy__c != null){
                for(Policy_Lawyer__c lawrObj : [SELECT Id, Lawyer__r.Contact__c, Deleted_Date__c, Prior_Act_Date__c FROM Policy_Lawyer__c WHERE Policy__c =: applicationPolicyList[0].Previous_Policy__c]){
                    priorActDateMap.put(lawrObj.Lawyer__r.Contact__c, lawrObj.Prior_Act_Date__c);
                }
            }
            
            system.debug('----applicationPolicyList[0].Account__c--'+applicationPolicyList[0].Account__c);
            for(AccountContactJunction__c accConObj : [SELECT Id, Name, Account__c, Contact__c, Contact__r.Type__c, Contact__r.Name,Lawyer_Name__c,
                                                    Contact__r.Phone, Contact__r.Email, Contact__r.Personal_Email__c, Contact__r.MobilePhone, Contact__r.ISBA__c, Contact__r.Account_Number__c,Contact__r.ARDC_Number__c,Contact__r.Contact_Role__c, 
                                                    Account__r.Name,Contact__r.FirstName,Contact__r.LastName,Contact__r.Middle_Name__c,Contact__r.Suffix__c FROM AccountContactJunction__c
                                                    WHERE Contact__c in (SELECT ContactId FROM AccountContactRelation WHERE AccountId = : applicationPolicyList[0].Account__c) order by Contact__r.LastName,Contact__r.FirstName ASC LIMIT 1000]){
                                                       //Account__c =: applicationPolicyList[0].Account__c LIMIT 1000]){
                                                       
                                                       system.debug('--accConObj--'+accConObj.Id);
                if(!setOfPolicyLawyer.contains(accConObj.Id)){                                                
                    if(accConObj.Contact__r.Type__c == 'Lawyer'){
                        WrapperClass wrap = new WrapperClass(false, accConObj, accConObj.Id);
                        if(priorActDateMap.containsKey(accConObj.Contact__c)){
                            wrap.policyLawyerObj.Prior_Act_Date__c = priorActDateMap.get(accConObj.Contact__c);
                            wrap.policyLawyerObj.Rate_At__c = 100;
                            wrap.policyLawyerObj.Contact_Role__c = 'o';                            
                        }
                        
                        modalList.add(wrap);
                        Contact cont = new Contact();
                        cont.Email = accConObj.Contact__r.Email;
                        cont.Phone = accConObj.Contact__r.Phone;
                        cont.MobilePhone = accConObj.Contact__r.MobilePhone;
                        cont.Personal_Email__c = accConObj.Contact__r.Personal_Email__c;
                        cont.Id = accConObj.Contact__c;
                        contactMap.put(accConObj.Contact__c,cont);
                    }
                }
            }
            firmId = applicationPolicyList[0].Account__c;
        }
    }
    
    
    
    //Add Lawyer
    public void AddLawyer(){
        errorMessage = '';
        List<Policy_Lawyer__c> applicationPolicyList = new List<Policy_Lawyer__c>();
        List<Contact> contactsToUpdate = new List<Contact>();
        System.debug('here1');
        system.debug('modalList => '+modalList);
        for( WrapperClass wprObj : modalList){
            system.debug('wprObj.isStatus => '+wprObj.isStatus);
            if(wprObj.isStatus){                
                if(wprObj.policyLawyerObj.Prior_Act_Date__c == null || wprObj.policyLawyerObj.Rate_At__c == null){
                    errorMessage = 'Please enter Prior Act Date and Rate for the selected Lawyers';
                    System.debug('here');
                    break;
                }
                if(isPolicySaErp && wprObj.policyLawyerObj.Rate_At__c != null && wprObj.policyLawyerObj.Rate_At__c != 100){
                    errorMessage = 'SA-ERP all lawyers must be 100% rate at';
                    System.debug('here');
                    break;
                }
                Policy_Lawyer__c policyLawyerObj = new Policy_Lawyer__c();
                //policyLawyerObj.Account__c =wprObj.accountContactJObj.Account__c;
                policyLawyerObj.Account__c = this.applicationPolicyList[0].Account__c;
                policyLawyerObj.Policy__c = appId;
                //policyLawyerObj.Prior_Act_Date__c = firmPriorActsDate!=null?firmPriorActsDate:System.today();
                policyLawyerObj.Prior_Act_Date__c =  wprObj.policyLawyerObj.Prior_Act_Date__c;
                policyLawyerObj.Contact_Role__c =  wprObj.policyLawyerObj.Contact_Role__c;
                policyLawyerObj.Rate_At__c = wprObj.policyLawyerObj.Rate_At__c;
                policyLawyerObj.Lawyer__c = wprObj.junctionId;
                policyLawyerObj.Lawyer__r = wprObj.accountContactJObj;
                //policyLawyerObj.Contact_Role__c =  wprObj.accountContactJObj.Contact__r.Contact_Role__c;
                policyLawyerObj.Is_Application_Lawyer__c = true;
                //policyLawyerObj.Rate_At__c = 100;
                
                applicationPolicyList.add(policyLawyerObj);
                if(wprObj.accountContactJObj.Contact__r.Email != contactMap.get(wprObj.accountContactJObj.Contact__c).Email || wprObj.accountContactJObj.Contact__r.Phone != contactMap.get(wprObj.accountContactJObj.Contact__c).Phone){
                    contactsToUpdate.add(wprObj.accountContactJObj.Contact__r);
                }
                
            }
        }
        if(!String.isNotBlank(errorMessage)){
            if(applicationPolicyList.size() > 0 ){
                try{    
                    insert applicationPolicyList;
                    if(contactsToUpdate.size() > 0){
                        update contactsToUpdate;
                    }
                    utilizeFuntion();
                    //return new PageReference('/' + appId );
                }catch(DMLException e){
                    errorMessage = e.getdmlMessage(0);
                }catch(Exception e){
                    errorMessage = e.getMessage();
                }
            }else{
                errorMessage = 'Please select atleast one lawyer to add to the application.';
            }
        }
    }
    
    //save button
    public void savePolicyLawyer(){
        /*if(!status){
            error = 'Select Atleast one checkbox';
            return;
        }*/
        boolean isError = false;
        errorMessage = ''; 
        for(Policy_Lawyer__c  pl : policyLawyerList){
            if(isPolicySaErp && pl.Rate_At__c < 100){
                errorMessage = 'SA-ERP all lawyers must be 100% rate at';
                isError = true;
                break;
            }
        }
        if(!isError){
            upsert policyLawyerList;
            List<Contact> updatedContactRecords = new List<Contact>();
            for(Policy_Lawyer__c  pl : policyLawyerList){
                if(pl.Lawyer__r.Contact__r != null){
                    updatedContactRecords.add(pl.Lawyer__r.Contact__r);
                }
            }
            if(updatedContactRecords.size() > 0){
                Update updatedContactRecords;
            }
        }
    }
    
    //delete Policy Lawyer
    public void removePolicyLawyer(){
        
        if(indexPolicyLawyer != null && policyLawyerList.size() > indexPolicyLawyer){
            if(policyLawyerList.get(indexPolicyLawyer).Id != null){
                delete new Policy_Lawyer__c ( Id = policyLawyerList.get(indexPolicyLawyer).Id );
            }
            policyLawyerList.remove(indexPolicyLawyer);
        }
        
        /*if( policyLawyerId != '' || policyLawyerId != null ){
           delete new Policy_Lawyer__c ( Id = policyLawyerId );
        }*/
        utilizeFuntion();
    }
    
    //create contact 
    public void insertContact(){
        ContactPartRender = true;
        contactRec = new Contact();
        contactRec.Type__c = 'Lawyer';
        contactRec.AccountId = [select id from account where name =: Label.Bucket_Account limit 1].id;
    }
    
    public void saveContact(){
        try{
            insert contactRec;
            
            AccountContactRelation acr = new AccountContactRelation(ContactId=contactRec.Id,AccountId=firmId );
            insert acr;
            
            /*AccountContactJunction__c lawyerRec = [SELECT ID, Account__c, Contact__c,Contact__r.Contact_Role__c FROM AccountContactJunction__c WHERE Contact__c =: contactRec.Id AND Account__c =: contactRec.AccountId LIMIT 1];
            Policy_Lawyer__c policyLawyerObj = new Policy_Lawyer__c();
            //policyLawyerObj.Account__c = lawyerRec.Account__c;
            policyLawyerObj.Account__c = applicationPolicyList[0].Account__c;
            policyLawyerObj.Policy__c = appId;
            policyLawyerObj.Prior_Act_Date__c = firmPriorActsDate!=null?firmPriorActsDate:System.today();
            policyLawyerObj.Lawyer__c = lawyerRec.Id;
            policyLawyerObj.Rate_At__c = 100;
            policyLawyerObj.Contact_Role__c =  lawyerRec.Contact__r.Contact_Role__c;
            insert policyLawyerObj;*/
            
            utilizeFuntion();
        } catch(DMLException e){
            System.debug('Error---'+e.getMessage());
            if(e.getDmlType(0) +'' == 'DUPLICATE_VALUE'){
                Id duplicateContactId = String.valueOf(e.getdmlMessage(0)).subStringAfter('id: ') ;
                Contact cont = [select id,name from Contact where id =: duplicateContactId];
                errorMessage = 'Duplicate ARDC Number found on Contact : ' + cont.Name  ;
            }else{
              errorMessage = e.getdmlMessage(0)  ;  
            }
        } catch(Exception e){
             errorMessage = e.getMessage();
        }
    }
    
    public void redirectToFirstPage(){
        ContactPartRender = false;
    }
    
    public void cancelMethod(){
        searchedContacts =new List<Contact>();
        firstName='';
        lastName='';
        ardcNumber='';
    }
    public void searchContact(){
        String query = 'select id,FirstName,LastName,Type__c,Title,Email,Phone,ISBA__c,ARDC_Number__c,Suffix__c,Middle_Name__c from Contact';
        String Filter = '';
        String searchKeywordFirstName,searchKeywordLastName,searchKeywordARDCNumber='';
        String accountId = applicationPolicyList[0].Account__c;
        if(String.IsNotBlank(firstName)){
            searchKeywordFirstName = '%'+firstName +'%';
            Filter += ' WHERE FirstName LIKE : searchKeywordFirstName ';
                        System.assert(true);
        }
        
        if(String.IsNotBlank(lastName)){
            if(String.IsNotBlank(Filter)){
                searchKeywordLastName = '%'+lastName +'%';
                Filter += ' AND lastName LIKE : searchKeywordLastName ';
            }else{
                searchKeywordLastName = '%' + lastName +'%';
                Filter += ' WHERE lastName LIKE : searchKeywordLastName ';
            }
        }
        
        if(String.IsNotBlank(ardcNumber)){
            if(String.IsNotBlank(Filter)){
                searchKeywordARDCNumber = '%'+ardcNumber +'%';
                Filter += ' AND ARDC_Number__c LIKE : searchKeywordARDCNumber ';
            }else{
                searchKeywordARDCNumber = '%' + ardcNumber +'%';
                Filter += ' WHERE ARDC_Number__c LIKE : searchKeywordARDCNumber ';
            }
        }
        
        If(String.IsNotBlank(Filter)){
            query = query+''+Filter+'and Id not in (select ContactId from AccountContactRelation where AccountId = : accountId) and Type__c = \'Lawyer\' order by lastname asc,firstname asc LIMIT 1000';
            searchedContacts = database.query(query);
        }
        System.debug('query'+query);
    }
    public void associateContacts(){ 
        System.debug(selectedContacts);
        AccountContactRelation acr = new AccountContactRelation(ContactId=selectedContacts,AccountId=applicationPolicyList[0].Account__c );
        insert acr;
        
        /*AccountContactJunction__c lawyerRec = [SELECT ID, Account__c, Contact__c,Contact__r.Contact_Role__c FROM AccountContactJunction__c WHERE Contact__c =: selectedContacts LIMIT 1];
        Policy_Lawyer__c policyLawyerObj = new Policy_Lawyer__c();
        //policyLawyerObj.Account__c = lawyerRec.Account__c;
        policyLawyerObj.Account__c = applicationPolicyList[0].Account__c;
        policyLawyerObj.Policy__c = appId;
        policyLawyerObj.Prior_Act_Date__c = firmPriorActsDate!=null?firmPriorActsDate:System.today();
        policyLawyerObj.Lawyer__c = lawyerRec.Id;
        policyLawyerObj.Rate_At__c = 100;
        policyLawyerObj.Contact_Role__c =  lawyerRec.Contact__r.Contact_Role__c;
        insert policyLawyerObj;*/
        
        utilizeFuntion();
        
        searchedContacts =new List<Contact>();
        /*firstName='';
        lastName='';
        ardcNumber='';*/
        searchContact();
        System.debug(selectedContacts);
    }
    //WrapperClass
    public class WrapperClass{
        public Boolean isStatus{get;set;}
        public AccountContactJunction__c accountContactJObj{get;set;}
        public String junctionId{get;set;} 
        public Policy_Lawyer__c policyLawyerObj{get;set;}
        public WrapperClass(Boolean status, AccountContactJunction__c accConJObj, String jId ){
            isStatus = status;
            accountContactJObj = accConJObj;
            junctionId = jId;
            policyLawyerObj = new Policy_Lawyer__c();
        }
    }
}