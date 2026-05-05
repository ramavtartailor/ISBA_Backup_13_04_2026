public without sharing class CustomerApplication_Ctrl {
	public String currentStage{get;set;}
    @testVisible    
    public Id applicationId {get;set;}
    public String applicationName {get;set;}
    @testVisible Customer_Application__c applicationNew;
    public Customer_Application__c application{get;set;}
    public List<Customer_Application_Lawyer__c> applicationLawyers{get;set;}
    List<Customer_Application_Lawyer__c> applicationLawyersNew;
    public ContentVersion cv{get;set;}
    public string claimsSupplementalUrl {get;set;}
    public String file {get;set;}
    public Boolean callActivateSteps{get;set;}
    public String highestStage{get;set;}
    public String fileName {get;set;}
    public String oldDate {get;set;}
    public Integer aopListSplitIndex {get;set;}
    public Set<String> quoteIds{get;set;} 
    public List<ContentVersion> cvList{get;set;}
    public Boolean hasPolicyDocument {get;set;}
    public Boolean isGuest { get; Set; }
    public Boolean setStageCalled {get;set;}
    public Boolean callSetStage{get;set;}
    public List<quoteWrapper> quoteWrapperList{get;set;}
    
    public List<Policy_Quote__c> quotes{get;set;}
    List<Policy_Quote__c> quotesNew;
    public String radioName{get;set;}
    public String radioValue{get;set;}
    public String redioValuesStr{get;set;}
    
    public List<aopWrapper> aopList{get;set;}
    public List<aopComboWrapper> aopComboList{get;set;}
    public string aopListStr{get;set;}
    public Decimal totalVal {get;set;} 
    List<AOP_Factor__c> lstOfAopFactors;
    public Integer rowIdx{get;set;}
    public String error{get;set;}
    public boolean isRegularRenewal{get;set;}
    public String f1StepWidth{get;set;}
    public boolean applicationCreated{get;set;}
    public String applicationNumber{get;set;}
    public boolean priorClaimSelected{get;set;}
    public boolean potentialClaimSelected{get;set;}
    public boolean pendingInvestigationSelected{get;set;}
    public boolean RefusedSelected{get;set;}
    public boolean SanctionedSelected{get;set;}
    public boolean ReprimandedSelected{get;set;}
    public boolean CensuredSelected{get;set;}
    public boolean SuspendedSelected{get;set;}
    public boolean DisbarredSelected{get;set;}
    public boolean hasRetroactiveDateSelected{get;set;}
    public boolean anyDisciplinarySelected{get;set;}
    public boolean Q_Outside_ILSelected{get;set;}
    //public boolean Q_Non_enganement_LettersSelected{get;set;}
    public boolean Q_Engagement_LettersSelected{get;set;}
    //public boolean Q_CalendaringSelected{get;set;}
    //public boolean Q_Conflict_of_InterestSelected{get;set;}
    public boolean Q_Firm_Share_CasesSelected{get;set;}
    public boolean Q_Firm_Share_Cases_InsuredSelected{get;set;}
    //public boolean Q_Firm_Use_Agreements_Or_Engagement_LettSelected{get;set;}
    public boolean Q_Firm_Notify_Clients_TerminatedSelected{get;set;}
    //public boolean Q_Firm_Review_ConflictsSelected{get;set;}  
    public boolean Q_Firm_Evaluate_New_ClientsSelected{get;set;} 
    //public boolean Q_Docket_Calendar_SystemSelected{get;set;}
    //public boolean Q_Conflict_Of_Interest_SystemSelected{get;set;}
    public boolean Does_the_Firm_have_a_backup_LawyerSelected{get;set;}
    public Integer numberOfLawyers{get;set;}
    public boolean showLawyers{get;set;}
    public String selectedLimits{get;set;}
    public String selectedDeductibles{get;set;}
    public String userSession {get;set;}
    public date Retroactive_Date{get;set;}
    public date signDate{get;set;}
    public set<String> removedLawyerIds{get;set;}
    public Map<String,Zip_Code_Mapping__mdt> zipCodeMap;
    public Map<String,String> countyMap;
    private final string EMAIL_TEMPLATE_NAME = 'Online_NBA_Creation_Notification';
    private final string ORG_WIDE_ADDRESS = 'insure@isbamutual.com';
    public String encryptedId{get;set;}
    public boolean isApplicationBlocked{get;set;}
    public boolean isApplicationValid{get;set;}
    public boolean isLastStage;
    public String underwriterName{get;set;}
    public String underwriterEmail{get;set;}
    public String underwriterPhone{get;set;}
    public CustomerApplication_Ctrl(){
       	hasPolicyDocument = false;
		isLastStage = false;
        isGuest = false;
        isApplicationBlocked = false;
        setStageCalled = false;
        callSetStage = false;
        callActivateSteps = false;
        highestStage = 'Firm Information';
        if(UserInfo.getUserType() == 'Guest'){
            isGuest = true;
        }

        signDate = system.today();
        error = '';
        oldDate = system.today().Month()+ '/'+ system.today().Day()+ '/' +system.today().Year();
        claimsSupplementalUrl = '';//[SELECT Id,ContentDocumentId FROM ContentVersion Where Title='ISBAMIC-Claim-Supplemental' order by CreatedDate LIMIT 1][0].ContentDocumentId;
        
        String resp = '';
        if(!Test.isRunningTest()){ 
            resp = queryAndDml_Records(applicationId,'queryRecords','SELECT Id,ContentDocumentId FROM ContentVersion Where Title=\'ISBAMIC-Claim-Supplemental\' order by CreatedDate LIMIT 1','',null,'');
        }
        else{
            resp = JSON.serialize([SELECT Id,ContentDocumentId FROM ContentVersion Where Title='ISBAMIC-Claim-Supplemental' order by CreatedDate LIMIT 1]);
        }
        if(resp != null){
            List<Sobject> ObjLis = (List<Sobject>)Json.deserialize(resp,List<Sobject>.class);
            claimsSupplementalUrl = '/apex/FilePreviewPage?id='+String.valueOf(ObjLis[0].get('Id'))+'&isdtp=vw';
        }
        
        system.debug('claimsSupplementalUrl => '+ claimsSupplementalUrl );
        
        countyMap = new Map<String,String>();
        getCounty();
        zipCodeMap = new Map<String,Zip_Code_Mapping__mdt>();
        List<Zip_Code_Mapping__mdt> zipMtdList = [SELECT Id, MasterLabel, County__c, City__c FROM Zip_Code_Mapping__mdt];
        for(Zip_Code_Mapping__mdt obj: zipMtdList){
            zipCodeMap.put(obj.MasterLabel,Obj);
        }
        quoteIds = new Set<String>();
        numberOfLawyers = 0;
        currentStage = 'Firm Information';
        application = new Customer_Application__c();
        applicationLawyers = new List<Customer_Application_Lawyer__c>();
        removedLawyerIds = new Set<String>();
        //applicationLawyers.add(new Customer_Application_Lawyer__c());
        //aops = new List<Customer_Application_AOP__c>();
        //aops.add(new Customer_Application_AOP__c());
        quotes = new List<Policy_Quote__c>();
        lstOfAopFactors=new List<AOP_Factor__c>();
        quoteWrapperList = new List<quoteWrapper>();
        isRegularRenewal = false;
        cvList = new List<ContentVersion>();        
        aopList = new List<aopWrapper>();
        aopComboList = new List<aopComboWrapper>();
        totalVal = 0;
        
        applicationLawyersNew = new List<Customer_Application_Lawyer__c>(); 
        if(Apexpages.currentpage().getparameters().get('id') != null){
            
            callActivateSteps = true;
            String strID = Apexpages.currentpage().getparameters().get('id');
            String stage = Apexpages.currentpage().getparameters().get('stage');
            encryptedId = strID;
            system.debug('currentStage ==> '+currentStage);
            Id applicationIdParam = PaymentGateway_Ctrl.processDecryption(strID.trim() ,Label.Encryption_Key_Payment_Id);
            Customer_Application__c application1 = [select Name, Address_2__c,Full_Legal_Name_of_the_Firm__c,Trade_Name_or_D_B_A__c,Street__c,City__c,State__c,Zip_Code__c,Would_you_like_to_receive_a_link_to_this__c,Application_Status__c,
                           County__c,Highest_Stage__c,Website__c,Firm_Phone_Number__c,Firm_Fax_Number__c,Contact_Name__c,Contact_Phone_Number__c,Contact_Last_Name__c,AOP_Master_Factor__c,PolicyId__c,
                           PolicyId__r.Underwriter_User__r.Name, PolicyId__r.Underwriter_User__r.Email, PolicyId__r.Underwriter_User__r.Phone, PolicyId__r.Underwriter_User__r.Title, PolicyId__r.Sales_User__r.Name, PolicyId__r.Sales_User__r.Email, PolicyId__r.Sales_User__r.Phone, PolicyId__r.Sales_User__r.Title, PolicyId__r.recordType.Name,
                           Contact_E_mail_Address__c,Date_Firm_Established__c,NBA_App_Source__c,Areas_Of_Practice__c,Professional_Liability_Claim__c,
                           Professional_Claim_Number_Against_Firm__c,Any_Potential_Claim__c,Potential_Claim_Number__c,
                           Any_Disciplinary_Action__c,Any_Other_Action__c,Is_the_firm_currently_insured__c,Prior_Insurance_Has_Retro_active_Date__c,
                           Effective_Date_Requested__c, Retroactive_Date__c,Prior_Insurance_Effective_Date__c,Prior_Insurance_Expiration_Date__c,Pending_Investigation_Proceeding__c, 
                           Insurance_Carrier__c,Limits_of_Liability__c,Deductible__c,Annual_Premium__c,of_Insured_Lawyers__c,Disbarred__c,
                           Refused_Admittance_to_Bar_or_Court__c,Sanctioned_or_Fined__c,Reprimanded__c,Censured__c,Suspended__c,Prior_Claim_Completed__c,Prior_Insurance_Completed__c,
                           Q_Outside_IL__c,Q_Engagement_Letters__c,Signed_Date__c,Signed_By__c,Title__c,Lawyer_Information_Completed__c,Form_Link__c,NBA_App_Source_Info__c,
						   Q_Firm_Gross_Revenue_Next_Year__c,Q_Firm_Gross_Revenue_Past_Year__c,Q_Firm_Share_Cases__c,Q_Firm_Conflict_Of_Interest_System__c,Q_Non_Lawyer_Personnel__c,
						   Q_Outside_IL_Description__c,Q_Firm_Share_Cases_Insured__c,Q_Firm_Notify_Clients_Terminated__c,Q_Firm_Evaluate_New_Clients__c,
                           /*Q_Docket_Calendar_System__c,Q_Docket_Calendar_System_computer__c,Q_Docket_Calendar_System_dual_calendar__c,Q_Docket_Calendar_System_Other__c,Q_Docket_Calendar_System_practice_manage__c,Q_Docket_Calendar_System_tickler__c,*/Q_Firm_Maintain_a_Docket__c,Does_the_Firm_have_a_backup_Lawyer__c,
						   /*Q_Conflict_Of_Interest_System__c,Q_Conflict_Of_Interest_System_computer__c,Q_Conflict_Of_Interest_System_conflict__c,Q_Conflict_Of_Interest_System_multiple__c,Q_Conflict_Of_Interest_System_practice_m__c,Q_Conflict_Of_Interest_System_single_ind__c,Q_Conflict_Of_Interest_System_supervisor__c,*/Inquire_About_Higher_Limits_Deductibles__c,RecordType.Name,
						   (SELECT Id, Percentage__c, AOP_Factor__c FROM Customer_Application_AOP__r)
                           from Customer_Application__c where id =: applicationIdParam];
            
            if(application1.Application_Status__c != 'Incomplete' && application1.Application_Status__c != 'Pending'){
                isApplicationBlocked = true;
                applicationName = application1.Name;
            }
            if(application1.PolicyId__c != null && application1.PolicyId__r.recordType.Name != 'Application'){
                isApplicationValid = true;
                isApplicationBlocked = true;
                applicationName = application1.Name;
            }
            
            if(String.isNotBlank(application1.PolicyId__c)){
                underwriterName = application1.PolicyId__r.Underwriter_User__r.Name;
                underwriterEmail = application1.PolicyId__r.Underwriter_User__r.Email;
                underwriterPhone = application1.PolicyId__r.Underwriter_User__r.Phone;
            }
                
                
            
            if(application1.Effective_Date_Requested__c != null){
                oldDate = application1.Effective_Date_Requested__c.Month()+ '/'+ application1.Effective_Date_Requested__c.Day()+ '/' +application1.Effective_Date_Requested__c.Year();
            }
            if(application1.RecordType.Name == 'Regular Renewal'){
                isRegularRenewal = true;
            }
            system.debug('highestStage == '+application1.Highest_Stage__c);
            if(application1.Highest_Stage__c != null){
                highestStage = application1.Highest_Stage__c;
            }
            
            if(stage != null){
                currentStage = stage;
                callSetStage = true;
                callActivateSteps = false;
            }/*else if(application1.Highest_Stage__c != null){
                currentStage = application1.Highest_Stage__c;
                callSetStage = true;
            }*/
            
            application = application1.clone(false,true);
            if(application.Lawyer_Information_Completed__c){
                Q_Outside_ILSelected = true;
                //Q_Conflict_of_InterestSelected = true;
                //Q_CalendaringSelected = true;
                Q_Engagement_LettersSelected = true;
                //Q_Non_enganement_LettersSelected = true;
                Q_Firm_Share_CasesSelected = true;  
                Q_Firm_Share_Cases_InsuredSelected = true;
                //Q_Firm_Use_Agreements_Or_Engagement_LettSelected = true;
                Q_Firm_Notify_Clients_TerminatedSelected = true;
                //Q_Firm_Review_ConflictsSelected = true;
                Q_Firm_Evaluate_New_ClientsSelected = true;
                //Q_Conflict_Of_Interest_SystemSelected = true;
                //Q_Docket_Calendar_SystemSelected = true;
                Does_the_Firm_have_a_backup_LawyerSelected = true;
            }
            if(application.Prior_Claim_Completed__c){
                priorClaimSelected = true;
                potentialClaimSelected = true;
                anyDisciplinarySelected = true;
                pendingInvestigationSelected = application.Pending_Investigation_Proceeding__c;
                RefusedSelected = application.Refused_Admittance_to_Bar_or_Court__c;
                SanctionedSelected = application.Sanctioned_or_Fined__c;
                ReprimandedSelected = application.Reprimanded__c;
                CensuredSelected = application.Censured__c;
                SuspendedSelected = application.Suspended__c;
                DisbarredSelected = application.Disbarred__c;
            }
            if(application.Prior_Insurance_Completed__c){
                hasRetroactiveDateSelected = true;
            }
            applicationId = applicationIdParam;
            getDocuments();
            createQuoteWrapperList();
            applicationLawyersNew = [select id,Name,Middle_Initial__c,Last_Name__c,Designation__c,Date_of_Hire__c,Record_Id__c,
                                     ISBA_Number__c,ARDC_Number__c,Average_Number_of_Hours_Worked__c, Birthday__c,Cell_Phone__c,Personal_Email_Address__c,Firm_Email_Address__c
                                     from Customer_Application_Lawyer__c where Customer_Application__c =: applicationIdParam AND Is_Removed__c = false];
            for(Customer_Application_Lawyer__c lawyer : applicationLawyersNew){
                applicationLawyers.add(lawyer.clone(false,true));//
                showLawyers = true;
            }
            numberOfLawyers = applicationLawyersNew.Size();
            if(application.AOP_Master_Factor__c == null){
                List<Master_Factor__c> masterFactors = new List<Master_Factor__c>([select id,From_Date__c ,To_Date__c  from Master_Factor__c where Factor_Type__c  = 'AOP']);
                for(Master_Factor__c mf : masterFactors){
                    if(application.Effective_Date_Requested__c  >= mf.From_Date__c && application.Effective_Date_Requested__c  <= mf.To_Date__c){
                        application.AOP_Master_Factor__c = mf.Id;
                    }
                }
            }
            
            lstOfAopFactors=[select id,Name,AOP_Mod__c from  AOP_Factor__c where Master_Factor__c =: application.AOP_Master_Factor__c and Application_Hidden__c = false order by name Limit 1000];
            for(AOP_Factor__c aop: lstOfAopFactors){
                aopWrapper polAop = new aopWrapper();
                polAop.factor = aop;
                polAop.aop = new Customer_Application_AOP__c(); 
                aopList.add(polAop);
            }
            
            system.debug('AOPList => '+application1.Customer_Application_AOP__r);
            if(!application1.Customer_Application_AOP__r.isEmpty()){
                Map<String, Customer_Application_AOP__c> aopMap = new Map<String, Customer_Application_AOP__c>();
                for(Customer_Application_AOP__c aop : application1.Customer_Application_AOP__r){
                    aopMap.put(aop.AOP_Factor__c, aop);
                    totalVal += aop.Percentage__c;
                }
                
                for(aopWrapper aw: aopList){
                    if(aopMap.containsKey(aw.factor.Id)){
                        aw.aop = aopMap.get(aw.factor.Id);
                        aw.percentage = integer.valueOf(aw.aop.Percentage__c);
                    }
                }
            }
            aopListStr = JSON.serialize(aopList);
            
            createAopComboList();
            
        }
        else{
            application.Would_you_like_to_receive_a_link_to_this__c = true;
        }
        
        if(test.isRunningTest()){
            application.Contact_E_mail_Address__c = 'manan@cmentor.com';
        }
        
        String IPAddress = ApexPages.currentPage().getHeaders().get('True-Client-IP');
        //Get IP address when no caching (sandbox, dev, secure urls)
        if (String.isBlank(IPAddress)) {
            IPAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        }  
        if (String.isBlank(IPAddress)) {
            IPAddress = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        }
        String browserAgent = ApexPages.currentPage().getHeaders().get('User-Agent');
        userSession = (IPAddress !=null ? ('IP Address : ' + IPAddress + '' ): '') + ('User Agent : ' + browserAgent !=null ? (browserAgent + '' ): '');
        system.debug('currentStage2 ==> '+currentStage);
    }
    
    public void createAopComboList(){
        Integer len = aopList.size();
        Integer splitIndex = len/2;
        if(Math.Mod(len,2) == 1){
            splitIndex += 1;
        }
        aopComboList = new List<aopComboWrapper>();
        
        for(integer i = 0; i < splitIndex; i++){
            aopComboWrapper acw = new aopComboWrapper();
            acw.obj1 = aopList[i];
            if(len > splitIndex+i){
                acw.obj2 = aopList[splitIndex+i];
            }
            aopComboList.add(acw);
        }
        aopListSplitIndex = splitIndex;
    }
    
    public void handleAddressChange(){
        
        system.debug('fieldName => '+radioName);
        
        Map<String,Object> addMap = (Map<String,Object>) JSON.deserializeUntyped(radioName);
        system.debug('AddressMap => '+addMap.keySet());
        system.debug(addMap.Values());
        application.Street__c = '';
        application.City__c  = '';
        application.State__c = '';
        application.Address_2__c = '';
        application.Zip_Code__c = '';        
        if(addMap.containsKey('route')){
            application.Street__c = String.valueOf(addMap.get('route'));
        }                                        
        if(addMap.containsKey('street_number')){
            if(addMap.containsKey('route')){
                application.Street__c = String.valueOf(addMap.get('street_number')) + ' ' + application.Street__c;
            }
            else{
                application.Street__c = String.valueOf(addMap.get('street_number'));
            }
        } 
        if(addMap.containsKey('locality')){//city
            application.City__c = String.valueOf(addMap.get('locality'));
        }
        if(addMap.containsKey('administrative_area_level_1')){//state
            application.State__c = String.valueOf(addMap.get('administrative_area_level_1'));
        } 
        if(addMap.containsKey('subpremise')){
            application.Address_2__c = String.valueOf(addMap.get('subpremise'));
        } 
        if(addMap.containsKey('postal_code')){
            application.Zip_Code__c = String.valueOf(addMap.get('postal_code'));
        } 
        handleZipCodeChange();
    }
    
    public void handleZipCodeChange(){
        String zip = application.Zip_Code__c;
        if(String.isNotBlank(zip) && zip.length() > 5){
            zip = zip.substring(0, 5);
        }
        system.debug(zipCodeMap.containsKey(zip));
        if(zipCodeMap.containsKey(zip)){
            system.debug(countyMap.get((zipCodeMap.get(zip).County__c).toUpperCase()));
            application.County__c = countyMap.get((zipCodeMap.get(zip).County__c).toUpperCase());
        }
        else if(String.isNotBlank(zip)){
            application.County__c = countyMap.get('OUTSIDE OF ILLINOIS');
        }
        else{   
            //application.City__c = null;
            application.County__c = null; 
        }
    } 
    
    @RemoteAction
    public static String verifyEffectiveDate(String oldDate, String effDate, String applicationId){
        String error = '';
        date oDate = Date.parse(oldDate);
        date efDate = Date.parse(effDate);
        system.debug(oDate+' => '+ efDate);
        if(oDate > efDate){
            error = 'The Effective Date cannot be earlier than today.'; 
            if(String.isNotBlank(applicationId)){
                error = 'The Effective Date for this application cannot be altered';
            }
            system.debug('Error => '+error);
        }
        return error;
    }
    
    @RemoteAction
    public static String uploadFileWithCallout(String fileName, String fileContent, String docType, String relatedRecordId) {
        try{
            contentVersion cv = new contentVersion();
            cv.Title = fileName;
            cv.VersionData = EncodingUtil.base64decode(fileContent);
            cv.FirstPublishLocationId = relatedRecordId;
            cv.Document_Type__c = docType;
            cv.PathOnClient = fileName;       
            insert cv;  
            system.debug(cv);
            system.debug('fileContent => '+fileContent);
        }
        Catch(DmlException e){
            String errorbody = 'Team,\n\nFollowing error has occurred while Creating Content Version \n\n'+e.getDMLMessage(0) + '\n\n'+e.getStackTraceString();
            if(String.isNotBlank(relatedRecordId)){
                errorbody += '\n\n On the Customer Application :'+relatedRecordId;
            }
            PaymentGatewayClass.sendEmailOnError('Error in Creating Content Version Record for Customer Application.',errorbody);
        }
        return 'Success';
    }
    
    public List<SelectOption> getCounty() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('' ,'--None--'));
        County__c[] threatMappings = [SELECT Id,Name FROM County__c where Name != 'COOK(Chicago)' and Application_Hidden__c = false ORDER BY Name LIMIT 1000];
        for (County__c threatMapping : threatMappings) {
            options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
            countyMap.put(threatMapping.Name,threatMapping.Id);
        }
        return options;
    }
    
    public void deleteContentVersion(){
       /* ContentDocument cd = new ContentDocument();
        cd.Id = file;
        delete cd;
        getDocuments();*/
        String documentId = file;
        String resp = queryAndDml_Records(applicationId,'Deletion','',documentId,null,'');
        if(resp != null){
            List<Sobject> ObjLis = (List<Sobject>)Json.deserialize(resp,List<Sobject>.class);
            cvList = (List<ContentVersion>)ObjLis;
            hasPolicyDocument = false;
            for(ContentVersion cv: cvList){
                if(cv.Document_Type__c == 'Policy Document'){
                    hasPolicyDocument = true;
                }
            }
        }
    }
    
    
    
    public void getDocuments(){
        system.debug('get Documents Called');
        /*List<ContentDocumentLink> cdlinks = new List<ContentDocumentLink>([SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: applicationId]);
		Set<String> cdIds = new Set<String>();
        for(ContentDocumentLink cdl: cdlinks){
            cdIds.add(cdl.ContentDocumentId);
        }
         cvListcar = new List<ContentVersion>([SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: cdIds]);*/
        
        String resp = queryAndDml_Records(applicationId,'Query','','',null,'');
        if(resp != null){
            List<Sobject> ObjLis = (List<Sobject>)Json.deserialize(resp,List<Sobject>.class);
            cvList = (List<ContentVersion>)ObjLis;
            hasPolicyDocument = false;
            for(ContentVersion cv: cvList){
                if(cv.Document_Type__c == 'Policy Document'){
                    hasPolicyDocument = true;
                }
            }
        }
        
        system.debug('get Documents Completed');
        //return cvList;
    }
    
    public String queryAndDml_Records(String relatedRecordId, String actionType, String queryStr, String cvId, String records, string dml){
        String msg = '';
        String jsonBody = '{"relatedRecordId" : "'+relatedRecordId+'","queryStr" : "'+queryStr+'","type": "'+actionType+'","records": '+records+',"dml": "'+dml+'","cdId": "'+cvId+'"}';
        
        system.debug(jsonBody);
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:CashReceipt_Api/services/apexrest/createContentVersion');
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        request.setBody(jsonBody);
        request.setTimeout(120000);
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        system.debug('796::');
        if (!Test.isRunningTest()){
            response = http.send(request); 
        }
        
        msg  = response.getBody(); 
        system.debug(msg); 
        if(response.getStatusCode() == 200){
            return msg; 
        } 
        return null;
    }
    
    public void showQuotesApex(){
        try{
            List<Policy__c> bucketAccountPolicies = new List<Policy__c>([select id from Policy__c where Account__r.Name=: Label.Online_NBA_Account ]);
            system.debug('selectedLimits => '+selectedLimits);
            system.debug('selectedDeductibles => '+selectedDeductibles);
            List<optionWrapper> selectedLimitsList = (List<optionWrapper>)system.JSON.deserializeStrict(selectedLimits, List<optionWrapper>.class);
            List<optionWrapper> selectedDeductiblesList = (List<optionWrapper>)system.JSON.deserializeStrict(selectedDeductibles, List<optionWrapper>.class);
            //quoteWrapperList = new List<quoteWrapper>();
            for(optionWrapper wrpLm : selectedLimitsList){
                for(optionWrapper  wrpDed: selectedDeductiblesList){
                    if(String.isNotBlank(wrpLm.value) && String.isNotBlank(wrpDed.value) && wrpLm.value != 'Unsure at this time' && wrpDed.value != 'Unsure at this time'){
                        String key = wrpLm.value+':'+wrpDed.value;
                        system.debug('quoteIds => '+quoteIds+' => '+quoteIds.contains(key));
                        if(!quoteIds.contains(key)){
                            quoteIds.add(key);
                            //quoteWrapper quoteWrap = new quoteWrapper();
                            
                            Policy_Quote__c quote = new Policy_Quote__c();
                            quote.Coverage__c = wrpLm.value;
                            quote.Deductible__c = wrpDed.value;
                            quote.Customer_Application__c = applicationId;
                            quote.Policy__c = bucketAccountPolicies[0].id;
                            quotes.add(quote);
                        
                            /*quoteWrap.quote = quote;
                            quoteWrap.limitVal = wrpLm.label;
                            quoteWrap.deductibleVal = wrpDed.label;
                            quoteWrap.idVal = key;
                            quoteWrapperList.add(quoteWrap);
                            system.debug('quoteWrap => '+quoteWrap);*/
                        }
                    }
                }
            }
            
            if(!quotes.isEmpty()){
                Policy_Quote_Handler.isUpdateQuote = false;
                TriggerFactory.isUpdatePremium = false;
                upsert quotes;
                createQuoteWrapperList();
            }
            
            system.debug('quoteWrapperList => '+quoteWrapperList);
        }
        Catch(DMLException e){
            String errorbody = 'Team,\n\nFollowing error has occurred while updating Quotes\n\n'+e.getDMLMessage(0) + '\n\n'+e.getStackTraceString();
            if(String.isNotBlank(applicationId)){
                errorbody += '\n\n On the Customer Application :'+applicationId;
                errorbody += '\n\n Selected Limits :'+selectedLimits;
                errorbody += '\n\n Selected Deductibles :'+selectedDeductibles;
            }
            PaymentGatewayClass.sendEmailOnError('Error in Quote Upsertion for Customer Application.',errorbody);
        }
    }
    
    public void createQuoteWrapperList(){
        quoteWrapperList = new List<quoteWrapper>();
        List<Policy_Quote__c> quoteList = [SELECT Id, Coverage__r.Name, Coverage__c, Deductible__r.Name, Deductible__c, Customer_Application__c, Policy__c FROM Policy_Quote__c WHERE Customer_Application__c=:applicationId  order by Coverage__r.Coverage_Max_Per_Claim__c,Coverage__r.Full_Coverage__c, Deductible__r.Name];
        for(Policy_Quote__c quote : quoteList){
            quoteWrapper quoteWrap = new quoteWrapper();                    
            quoteWrap.quote = quote;
            quoteWrap.limitVal = quote.Coverage__r.Name;
            quoteWrap.deductibleVal = quote.Deductible__r.Name;
            quoteWrap.idVal = quote.Coverage__c+':'+quote.Deductible__c;
            quoteWrapperList.add(quoteWrap);
            
            quoteIds.add(quoteWrap.idVal);
        }
    }
    
    public PageReference nextStage(){   
        system.debug('redioValuesStr = >'+redioValuesStr);
        updateRadioValuesNew();
		error = '';
        if(currentStage == 'Firm Information'){
            isLastStage = false;
            currentStage = 'Lawyer Information';
            Boolean callRedirect = false;
            if(!String.isNotBlank(applicationId)){
                callRedirect = true;
            }
            
            createApplication(); 
            system.debug('applicationId == '+applicationId);            
            if(callRedirect && applicationId != null){
                Customer_Application__c customerApp = [SELECT Id, Form_Link__c FROM Customer_Application__c WHERE Id = :applicationId];
                if(customerApp.Form_Link__c != null){
                    String applicationLink = customerApp.Form_Link__c;            
                    PageReference newPage = new PageReference(applicationLink+'&stage=LawyerInformation');  
                    newPage.setRedirect(true);
                    encryptedId = newPage.getParameters().get('id');
                    return null;
                }                
            }           
            
        }
        else if(currentStage == 'Lawyer Information'){ 
            isLastStage = false;
            currentStage = 'Area of Practice';
            //renderFileInput = true;
            application.Lawyer_Information_Completed__c = true;
            createApplication();
            
        }
        else if(currentStage == 'Area of Practice'){
            getDocuments();
            currentStage = 'Prior Insurance';
            
            if(isRegularRenewal){
                currentStage = 'Prior Claims';
            }
            isLastStage = false;
            /*Customer_Application__c custApplication = new Customer_Application__c (Id = application.Id);
            custApplication.Highest_Stage__c = currentStage;
            highestStage = currentStage;
            upsert custApplication;*/
            List<Policy__c> bucketAccountPolicies = new List<Policy__c>([select id from Policy__c where Account__r.Name=: Label.Online_NBA_Account ]);
            List<Customer_Application_AOP__c> aopToUpsert = new List<Customer_Application_AOP__c>();
            List<Customer_Application_AOP__c> aopToDelete = new List<Customer_Application_AOP__c>();
            aopList = (List<aopWrapper>) JSON.deserializeStrict(aopListStr, List<aopWrapper>.class);
            for(aopWrapper aw: aopList){
                if(aw.aop.Percentage__c != null && aw.aop.Percentage__c > 0 ){
                    Customer_Application_AOP__c aop = aw.aop;
                    aop.AOP_Factor__c = aw.factor.Id;
                    aop.Customer_Application__c = applicationId;
                    aopToUpsert.add(aop);
                }
            }
            
            
            //Update and Delete AOP Records
            if(!aopToUpsert.isEmpty()){
                system.debug('aopToUpsert =>'+aopToUpsert);
                Upsert aopToUpsert;
                Set<String> aopIds = new Set<String>();
                for(Customer_Application_AOP__c aop: aopToUpsert){
                    aopIds.add(aop.Id);
                }
                
                aopToDelete = [SELECT Id FROM Customer_Application_AOP__c WHERE Customer_Application__c =: applicationId AND Id NOT IN :aopIds];
                
            }
            
            if(!aopToDelete.isEmpty()){
                system.debug('aopToDelete =>'+aopToDelete);
                Delete aopToDelete;
                system.debug('aopList => '+aopList);  
                for(aopWrapper aw: aopList){
                    if((aw.aop.Percentage__c == null || aw.aop.Percentage__c == 0 ) && aw.aop.Id != null){
                        system.debug('deleted records => '+ aw.aop);
                        aw.aop = new Customer_Application_AOP__c();
                    }
                }
            }
            
            createAopComboList();
            
            Customer_Application__c custApplication = application.clone(false,true);
            
            if(test.isRunningTest()){
                custApplication.Contact_E_mail_Address__c = 'manan@cmentor.com';
            }
            custApplication.Id = applicationId;
            if(isHigherStage(currentStage, application.Highest_Stage__c)){
                custApplication.Highest_Stage__c = currentStage;
                highestStage = currentStage;
                upsert custApplication;
            }
            
            application = custApplication.clone(false, true);
            
        }
        else if(currentStage == 'Prior Insurance'){
            currentStage = 'Prior Claims';
            isLastStage = false;
            if(application.Is_the_firm_currently_insured__c != 'Yes'){
                application.Retroactive_Date__c = null;
                application.Prior_Insurance_Has_Retro_active_Date__c = false;                
            }
            application.Prior_Insurance_Completed__c = true;            
            system.debug('application => '+application);
            createApplication();
        }
        else if(currentStage == 'Prior Claims'){
            //currentStage = 'Area Of Practice';
			isLastStage = false;
            currentStage = 'Liability and Deductible';             
            application.Prior_Claim_Completed__c = true;            
            createApplication();
        }
        else if(currentStage == 'Area Of Practice'){
            isLastStage = false;
            currentStage = 'Liability and Deductible';
            createApplication();
        }
        else if(currentStage == 'Liability and Deductible'){
            isLastStage = true;
            quotes = new List<Policy_Quote__c>();
            application.Signed_Date__c = System.today();
            if(quoteWrapperList.isEmpty()){
                for(String str : selectedLimits.split(',')){
                    for(String str1 : selectedDeductibles.split(',')){
                        if(String.isNotBlank(str) && String.isNotBlank(str1) && str != 'Unsure at this time' && str1 != 'Unsure at this time'){
                            Policy_Quote__c quote = new Policy_Quote__c();
                            quote.Coverage__c = str;
                            quote.Deductible__c = str1;
                            quotes.add(quote);
                        }
                    }
                }
            }
            else{
                for(quoteWrapper wrp: quoteWrapperList){                    
                    quotes.add(wrp.quote);
                }
            }
            
            createApplication();
			changePolicyStatus();    
            
            try{
                if(applicationNew.RecordType.Name == 'Regular Renewal'){
                    sendEmailRenewal();
                }else{
                    sendEmail();
                }
            }
            catch(Exception e){
                system.debug('Exception == '+e.getMessage());
            }
        }
        
        return null;
    }
    
    public void changePolicyStatus(){
        
        List<Policy__c> listPolicy = [SELECT Id, Name, Status__c FROM Policy__c WHERE Id =: applicationNew.PolicyId__c LIMIT 1];
        
        if(!listPolicy.isEmpty() && applicationNew.Application_Status__c == 'Completed'){
            listPolicy[0].Status__c = 'Received';
            update listPolicy;
        }
    }
    
    public void previousStage(){
        error = '';
        if(currentStage == 'Lawyer Information'){
            currentStage = 'Firm Information';
        }else if(currentStage == 'Area of Practice'){
            currentStage = 'Lawyer Information';
        }else if(currentStage == 'Prior Insurance'){
            currentStage = 'Area of Practice';
        }else if(currentStage == 'Prior Claims'){
            currentStage = 'Prior Insurance';
            if(isRegularRenewal){
                currentStage = 'Area Of Practice';
            }
        }else if(currentStage == 'Liability and Deductible'){
            //currentStage = 'Area Of Practice';
            currentStage = 'Prior Claims';
        }
    }
    public void addLawyerRows(){
        System.debug(numberOfLawyers+'numberOfLawyers');
        for(Integer i=0;i<numberOfLawyers;i++){
            applicationLawyers.add(new Customer_Application_Lawyer__c());
            showLawyers = true;
        }
    }
    public void addLawyerRow(){
        applicationLawyers.add(new Customer_Application_Lawyer__c());
        numberOfLawyers+=1;
    }
    public void removeLawyerRow(){
        String listIndex = ApexPages.currentPage().getParameters().get('listIndex');
        if(String.isNotBlank(listIndex) &&  applicationLawyers.size() > 1){
            if(String.isNotBlank(applicationLawyers[Integer.valueOf(listIndex)].Record_Id__c)){
                removedLawyerIds.add(String.valueOf(applicationLawyers[Integer.valueOf(listIndex)].Record_Id__c));
            }
            system.debug('removedLawyerIds => '+removedLawyerIds);
            applicationLawyers.remove(Integer.valueOf(listIndex) );
            numberOfLawyers-=1;
        }
    }
    
    public void removeQuoteRow(){
        String listIndex = ApexPages.currentPage().getParameters().get('listIndex');
        system.debug('listIndex => '+listIndex);
        if(String.isNotBlank(listIndex)){
            String idVal = quoteWrapperList[Integer.valueOf(listIndex)].quote.Id;
            Policy_Quote_Handler.isUpdateQuote = false;
            TriggerFactory.isUpdatePremium = false;
			Delete quoteWrapperList[Integer.valueOf(listIndex)].quote;
            
            List<Policy_Quote__c> updatedList = new List<Policy_Quote__c>();
            for(Policy_Quote__c quote: quotes){
                if(idVal != quote.Id){
                    updatedList.add(quote);
                }
            }
            
            quotes = updatedList;
            
            quoteIds.remove(quoteWrapperList[Integer.valueOf(listIndex)].idVal);
            quoteWrapperList.remove(Integer.valueOf(listIndex));
        }
        system.debug('quoteWrapperList => '+quoteWrapperList);
    }
        
    /*public void addRowAOP(){
        aops.add(new Customer_Application_AOP__c());
    }
    public void removeRowAOP(){
        //if( rowIdx != null && aops.size() > 1 ){
        if(rowIdx != null){
            aops.remove( rowIdx );
        }
    }*/
    public void addRowQuote(){
        quotes.add(new Policy_Quote__c());
    }
    public void removeRowQuote(){
        if( rowIdx != null && quotes.size() > 1 ){
            quotes.remove( rowIdx );
        }
    }
    public void updateRadioValuesNew(){
        if(redioValuesStr != null){
            system.debug('redioValuesStr = >'+redioValuesStr);
            Map<String, Object> dataMap = (Map<String, Object>)JSON.deserializeUntyped(redioValuesStr);
            
            for(String key: dataMap.keySet()){
                radioName = key;
                radioValue = String.valueOf(dataMap.get(key));
                updateRadioValues();
            }
            redioValuesStr = null;
        }
    }
    public void updatePercentage(){
        system.debug('Index => '+radioName);
        system.debug('Value => '+radioValue);
        aopList[Integer.valueOf(radioName)].percentage = String.isNotBlank(radioValue) ? Integer.valueOf(radioValue) : null; 
        aopList[Integer.valueOf(radioName)].aop.Percentage__c = String.isNotBlank(radioValue) ? Decimal.valueOf(radioValue) : null;
    }
    public void updateRadioValues(){
        system.debug('updateRadioValues called');
        system.debug('radioName => '+radioName);
        system.debug('radioValue => '+radioValue);
        if(radioName == 'priorClaim'){
            application.Professional_Liability_Claim__c = (radioValue == 'yes'?true:false);
            priorClaimSelected = true;
        }else if(radioName == 'potentialClaim'){
            application.Any_Potential_Claim__c = (radioValue == 'yes'?true:false);
            potentialClaimSelected = true;
        }else if(radioName == 'pendingInvestigation'){
            //application.Pending_Investigation_Proceeding__c = (radioValue == 'yes'?true:false);
            application.Pending_Investigation_Proceeding__c = (radioValue == 'true'?true:false);
            pendingInvestigationSelected = true;
        }else if(radioName == 'Refused'){
            //application.Refused_Admittance_to_Bar_or_Court__c = (radioValue == 'yes'?true:false);
            application.Refused_Admittance_to_Bar_or_Court__c = (radioValue == 'true'?true:false);
            RefusedSelected = true;
        }else if(radioName == 'Sanctioned'){
            //application.Sanctioned_or_Fined__c = (radioValue == 'yes'?true:false);
            application.Sanctioned_or_Fined__c = (radioValue == 'true'?true:false);
            SanctionedSelected = true;
        }else if(radioName == 'Reprimanded'){
            //application.Reprimanded__c = (radioValue == 'yes'?true:false);
            application.Reprimanded__c = (radioValue == 'true'?true:false);
            ReprimandedSelected = true;
        }else if(radioName == 'Censured'){
            //application.Censured__c = (radioValue == 'yes'?true:false);
            application.Censured__c = (radioValue == 'true'?true:false);
            CensuredSelected = true;
        }else if(radioName == 'Suspended'){
            //application.Suspended__c = (radioValue == 'yes'?true:false);
            application.Suspended__c = (radioValue == 'true'?true:false);
            SuspendedSelected = true;
        }else if(radioName == 'Disbarred'){
            //application.Disbarred__c = (radioValue == 'yes'?true:false);
            application.Disbarred__c = (radioValue == 'true'?true:false);
            DisbarredSelected = true;
        }else if(radioName == 'hasRetroactiveDate'){
            application.Prior_Insurance_Has_Retro_active_Date__c = (radioValue == 'yes'?true:false);
            hasRetroactiveDateSelected = true;
        }else if(radioName == 'anyDisciplinary'){
            application.Any_Disciplinary_Action__c = (radioValue == 'yes'?true:false);
            anyDisciplinarySelected = true;
        }else if(radioName == 'currenylyInsured'){
            if(radioValue == 'yes'){
                application.Is_the_firm_currently_insured__c = 'Yes';
            }else if(radioValue == 'no'){
                application.Is_the_firm_currently_insured__c = 'No';
                //currentStage = 'Liability and Deductible';
            }else{
                application.Is_the_firm_currently_insured__c = 'Unsure';
                //currentStage = 'Liability and Deductible';
            }
        }
        else if(radioName == 'Q_Outside_IL'){
            application.Q_Outside_IL__c = (radioValue == 'yes'?true:false);
            Q_Outside_ILSelected = true;
        }
        /*else if(radioName == 'Q_Conflict_of_Interest'){
            application.Q_Conflict_of_Interest__c = (radioValue == 'yes'?true:false);
            Q_Conflict_of_InterestSelected = true;
        }
        else if(radioName == 'Q_Calendaring'){
            application.Q_Calendaring__c = (radioValue == 'yes'?true:false);
            Q_CalendaringSelected = true;
        }*/
        else if(radioName == 'Q_Engagement_Letters'){
            application.Q_Engagement_Letters__c = (radioValue == 'yes'?true:false);
            Q_Engagement_LettersSelected = true;
        }
        /*else if(radioName == 'Q_Non_enganement_Letters'){
            application.Q_Non_enganement_Letters__c = (radioValue == 'yes'?true:false);
            Q_Non_enganement_LettersSelected = true;
        }*/
        else if(radioName == 'Q_Firm_Share_Cases'){
            application.Q_Firm_Share_Cases__c = (radioValue == 'yes'?true:false);
            Q_Firm_Share_CasesSelected = true;
        }
        else if(radioName == 'Q_Firm_Share_Cases_Insured'){
            application.Q_Firm_Share_Cases_Insured__c = (radioValue == 'yes'?true:false);
            Q_Firm_Share_Cases_InsuredSelected = true;
        }
        /*else if(radioName == 'Q_Firm_Use_Agreements_Or_Engagement_Lett'){
            application.Q_Firm_Use_Agreements_Or_Engagement_Lett__c = (radioValue == 'yes'?true:false);
            Q_Firm_Use_Agreements_Or_Engagement_LettSelected = true;
        }*/
        else if(radioName == 'Q_Firm_Notify_Clients_Terminated'){
            application.Q_Firm_Notify_Clients_Terminated__c = (radioValue == 'yes'?true:false);
            Q_Firm_Notify_Clients_TerminatedSelected = true;
        }
        /*else if(radioName == 'Q_Firm_Review_Conflicts'){
            application.Q_Firm_Review_Conflicts__c = (radioValue == 'yes'?true:false);
            Q_Firm_Review_ConflictsSelected = true;
        }*/
        else if(radioName == 'Q_Firm_Evaluate_New_Clients'){
            application.Q_Firm_Evaluate_New_Clients__c = (radioValue == 'yes'?true:false);
            Q_Firm_Evaluate_New_ClientsSelected = true;
        }
        /*else if(radioName == 'Q_Docket_Calendar_System'){
            application.Q_Docket_Calendar_System__c = (radioValue == 'yes'?true:false);
            Q_Docket_Calendar_SystemSelected = true;
        }
        else if(radioName == 'Q_Conflict_Of_Interest_System'){
            application.Q_Conflict_Of_Interest_System__c = (radioValue == 'yes'?true:false);
            Q_Conflict_Of_Interest_SystemSelected = true;
        }*/
        else if(radioName == 'Does_the_Firm_have_a_backup_Lawyer'){
            application.Does_the_Firm_have_a_backup_Lawyer__c = (radioValue == 'yes'?true:false);
            Does_the_Firm_have_a_backup_LawyerSelected = true;
        }
    }
    
    public Boolean isHigherStage(String str1, String str2){
        Map<String, Integer> stageSequenceMap = new Map<String, Integer>{
                                        'Firm Information'  => 1,
                                        'Lawyer Information' => 2,
                                        'Area of Practice' => 3,
                                        'Prior Insurance' => 4,
                                        'Prior Claims' => 5,
                                        'Liability and Deductible' => 6
                                        };
                                            if(stageSequenceMap.get(str1) < stageSequenceMap.get(str2)){
                                                return false;
                                            }
        return true;
    }
    
    public void createApplication(){  
        
        if(currentStage == 'Area of Practice'){
            applicationLawyersNew = new List<Customer_Application_Lawyer__c>();
            system.debug('removedLawyerIds => '+removedLawyerIds);
            applicationLawyersNew = [select id from Customer_Application_Lawyer__c where Customer_Application__c =: applicationId AND Id IN: removedLawyerIds AND Is_Removed__c = false];
            
            if(isRegularRenewal){                    
                for(Customer_Application_Lawyer__c lawyer : applicationLawyersNew){
                    if(removedLawyerIds.contains(lawyer.Id)){
                        lawyer.Is_Removed__c = true;
                    }
                }
            }
            else{
                queryAndDml_Records('','dmlLawyer','','',JSON.serialize(applicationLawyersNew),'Delete');
                applicationLawyersNew = new List<Customer_Application_Lawyer__c>();
            }
            
            for(Customer_Application_Lawyer__c lawyer : applicationLawyers){
                if(!String.isNotBlank(lawyer.Record_Id__c)){
                    lawyer.Customer_Application__c = applicationId;
                    applicationLawyersNew.add(lawyer.clone(false,true));
                }       
                else{
                    applicationLawyersNew.add(lawyer.clone(false,true));
                }
            }
            system.debug('applicationLawyersNew => '+applicationLawyersNew);
            if(!applicationLawyersNew.isEmpty()){
                system.debug('dml calling');
                queryAndDml_Records('','dmlLawyer','','',JSON.serialize(applicationLawyersNew),'Upsert');
                //upsert applicationLawyersNew;
                applicationLawyers = new List<Customer_Application_Lawyer__c>();
                applicationLawyersNew = [select id,Name,Middle_Initial__c,Last_Name__c,Designation__c,Date_of_Hire__c,Record_Id__c,
                                         ISBA_Number__c,ARDC_Number__c,Average_Number_of_Hours_Worked__c, Birthday__c,Cell_Phone__c,Personal_Email_Address__c,Firm_Email_Address__c
                                         from Customer_Application_Lawyer__c where Customer_Application__c =: applicationId AND Is_Removed__c = false];
                for(Customer_Application_Lawyer__c lawyer : applicationLawyersNew){
                    applicationLawyers.add(lawyer.clone(false,true));
                }
            }
        }
        SavePoint sp = Database.setSavepoint();
        try{
            
    
            List<Policy__c> bucketAccountPolicies = new List<Policy__c>([select id from Policy__c where Account__r.Name=: Label.Online_NBA_Account ]);
            system.debug('applicationNew => '+application.Highest_Stage__c);
            applicationNew = application.clone(false,true);
            system.debug('applicationNew => '+applicationNew);
            system.debug('Is_the_firm_currently_insured__c => '+applicationNew.Is_the_firm_currently_insured__c);
            applicationNew.Id = applicationId;
            system.debug('highest stage ==> '+highestStage+' == '+currentStage);
            system.debug('isHigherStage ==> '+isHigherStage(currentStage, highestStage));
            if(highestStage != '' && isHigherStage(currentStage, highestStage)){
                if(currentStage == 'Firm Information'){
                    applicationNew.Highest_Stage__c = 'Firm Information';
                }else if(currentStage == 'Lawyer Information'){
                    system.debug('inside if ==> '); 
                    applicationNew.Highest_Stage__c = 'Lawyer Information';
                }else if(currentStage == 'Area of Practice'){
                    applicationNew.Highest_Stage__c = 'Area of Practice';                           
                }else if(currentStage == 'Prior Insurance'){
                    applicationNew.Highest_Stage__c = 'Prior Insurance';
                }else if(currentStage == 'Prior Claims'){
                    applicationNew.Highest_Stage__c = 'Prior Claims';
                }else if(currentStage == 'Liability and Deductible'){
                    applicationNew.Highest_Stage__c = 'Liability and Deductible';
                }
                highestStage = applicationNew.Highest_Stage__c;
            }            
            system.debug('highest stage 1 ==> '+applicationNew.Highest_Stage__c);              
            boolean ckeckSendLinkTrue = false; 
            
            if(applicationId == null){
                if(applicationNew.Would_you_like_to_receive_a_link_to_this__c){
                    applicationNew.Would_you_like_to_receive_a_link_to_this__c = false;
                    ckeckSendLinkTrue = true;
                } 
                
                String customerAppRecordTypeId = [SELECT Id,Name,SObjectType FROM RecordType where SObjectType='Customer_Application__c' AND Name = 'New Business' Limit 1].Id;
                applicationNew.RecordTypeId = customerAppRecordTypeId;
				application.RecordTypeId = customerAppRecordTypeId;
                
                List<Master_Factor__c> masterFactors = new List<Master_Factor__c>([select id,From_Date__c ,To_Date__c  from Master_Factor__c where Factor_Type__c  = 'AOP']);
                for(Master_Factor__c mf : masterFactors){
                    if(applicationNew.Effective_Date_Requested__c >= mf.From_Date__c && applicationNew.Effective_Date_Requested__c <= mf.To_Date__c){
                        applicationNew.AOP_Master_Factor__c = mf.Id;
                    }
                }
                
                lstOfAopFactors=[select id,Name,AOP_Mod__c from  AOP_Factor__c where Master_Factor__c =: applicationNew.AOP_Master_Factor__c and Application_Hidden__c = false order by name Limit 1000];
                aopList = new List<aopWrapper>();
                for(AOP_Factor__c aop: lstOfAopFactors){
                    aopWrapper polAop = new aopWrapper();
                    polAop.factor = aop;
                    polAop.aop = new Customer_Application_AOP__c(); 
                    aopList.add(polAop);
                }
                aopListStr = JSON.serialize(aopList);
                createAopComboList();
            }
			applicationNew.ISBAM_user_agent__c = userSession;  
            
            if(isLastStage){
                applicationNew.Application_Status__c = 'Completed';
            }
            

            upsert applicationNew;
            
            if(applicationId == null){
                /*Site mySite = [select Id from Site where Name = 'Customer_Application'];
                SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite.Id];
                applicationNew.Form_Link__c = mySiteDetail.SecureURL + '?id=' + EncodingUtil.urlEncode(PaymentGateway_Ctrl.processEncryption(applicationNew.Id,Label.Encryption_Key_Payment_Id),'UTF-8');
                application.Form_Link__c = applicationNew.Form_Link__c;*/
                if(ckeckSendLinkTrue){
                     applicationNew.Would_you_like_to_receive_a_link_to_this__c = true;
                }
                upsert applicationNew;
            }
            applicationId = applicationNew.Id;
            application = applicationNew.clone(false,true);
            applicationNumber = [select id,name from Customer_Application__c where id = : applicationId].name;
            List<Customer_Application_Lawyer__c> updatedLawyers = new List<Customer_Application_Lawyer__c>();
            
            /*for(Customer_Application_AOP__c aop : aops){
                aop.Customer_Application__c = application.Id;
                aop.Policy__c = bucketAccountPolicies[0].id;
            }*/
            quotesNew = new List<Policy_Quote__c>();
            for(Policy_Quote__c quote : quotes){
                String key = quote.Coverage__c+':'+quote.Deductible__c;//Limits__c is used before plz review.
                if(!quoteIds.contains(key)){
                    quote.Customer_Application__c = applicationNew.Id;
                    quote.Policy__c = bucketAccountPolicies[0].id;
                    quotesNew.add(quote.clone(false,true));
                }
            }
            
            /*system.debug('applicationLawyersNew isNotEmpty => '+ !applicationLawyersNew.isEmpty());
            if(!applicationLawyersNew.isEmpty()){
                system.debug('dml calling');
                queryAndDml_Records('','dmlLawyer','',JSON.serialize(applicationLawyersNew),'Upsert');
                //upsert applicationLawyersNew;
            }
            *if(aops.size()>0){
                insert aops;
            }*/
            Policy_Quote_Handler.isUpdateQuote = false;
            TriggerFactory.isUpdatePremium = false;
            if(quotesNew.size()>0){
                system.debug('quotesNew => '+quotesNew);
                upsert quotesNew;
            }
        }catch(Exception e){
            Database.rollback(sp);
            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());
            error = 'There is some error occurred. Please contact ISBA.' + e.getMessage();
            String errorbody = 'Team,\n\nFollowing error has occurred while Creation or Updation of Customer Application \n\n'+e.getMessage() + '\n\n'+e.getStackTraceString();
            if(String.isNotBlank(applicationId)){
                errorbody += '\n\n On the Customer Application :'+applicationId;
            }
            PaymentGatewayClass.sendEmailOnError('Error in Customer Application Creation or Updation.',errorbody);
        }
    }
    
    public void sendEmailRenewal(){
        
        applicationNew.Application_Status__c = 'Completed';
        update applicationNew;
        //Customer_Application__c ca = [SELECT Id, Contact__c FROM Customer_Application__c WHERE Id=: applicationId LIMIT 1];
        
        List<Policy__c> listPolicy = [SELECT Id, Name, Underwriter_User__c, Underwriter_User__r.Email FROM Policy__c WHERE Id =: applicationNew.PolicyId__c LIMIT 1];
        String userEmail = 'underwriting@isbamutual.com';
        if(!listPolicy.isEmpty() && listPolicy[0].Underwriter_User__c != null){
            //suserEmail = listPolicy[0].Underwriter_User__r.Email;
            listPolicy[0].Application_Received_Date__c = System.today();
            listPolicy[0].Date_Signed__c = applicationNew.Signed_Date__c;
            Update listPolicy[0];
        }

        
        if(test.isRunningTest() && !String.isNotBlank(userEmail)){
            userEmail = 'manan@cmentor.com';
        }
        String templateName = 'Renew_NBA_Notification';
        if(test.isRunningTest()){
            templateName = EMAIL_TEMPLATE_NAME;
        }
        EmailTemplate em = [select id,Subject from EmailTemplate where developername =:templateName]; 
        
        OrgWideEmailAddress add = [select id from OrgWideEmailAddress where address = 'underwriting@isbamutual.com'];
        User usr = [select id from User where Profile.Name = 'System Administrator' and Name =: Label.Customer_Application_Creation_User_Full_Name];
        System.debug('*****em*****'+em);
        System.debug('*****add*****'+add);
        System.debug('*****usr*****'+usr);
        Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();
        singleEmailMsg.setToAddresses(new List<String>{userEmail});
        
        singleEmailMsg.setTemplateId(em.Id);
        singleEmailMsg.setTargetObjectId(usr.Id);
        singleEmailMsg.setWhatId(applicationNew.id);
        singleEmailMsg.setSaveAsActivity(false);
        /*if(String.isNotBlank(ca.Contact__c)){
            singleEmailMsg.setTargetObjectId(ca.Contact__c);
        	singleEmailMsg.setSaveAsActivity(true);
        }*/
        singleEmailMsg.setOrgWideEmailAddressId(add.id);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {singleEmailMsg});
        
        applicationCreated = true;
        
        //if(String.isNotBlank(ca.Contact__c)){
            Task newTask = new Task();
            newTask.WhatId = applicationNew.id;
            newTask.Subject = singleEmailMsg.getSubject();
            newTask.Description = singleEmailMsg.getHtmlBody();
            Insert newTask;
        //}
    }
    
    public void sendEmail(){
        
        applicationNew.Application_Status__c = 'Completed';
        update applicationNew;
        //Customer_Application__c ca = [SELECT Id, Contact__c FROM Customer_Application__c WHERE Id=: applicationId LIMIT 1];
        
        EmailTemplate em = [select id,Subject from EmailTemplate where developername =: EMAIL_TEMPLATE_NAME]; 
        OrgWideEmailAddress add = [select id from OrgWideEmailAddress where address = : ORG_WIDE_ADDRESS];
        User usr = [select id from User where Profile.Name = 'System Administrator' and Name =: Label.Customer_Application_Creation_User_Full_Name];
        System.debug('*****em*****'+em);
        System.debug('*****add*****'+add);
        System.debug('*****usr*****'+usr);
        Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();
        singleEmailMsg.setToAddresses(new List<String>{Label.Customer_Application_Creation_Email_Address});
        //List<String> toAddress = Label.System_Admin_Emails.contains(',')? Label.System_Admin_Emails.split(',') : new List<String>{Label.System_Admin_Emails};
        //singleEmailMsg.setToAddresses(toAddress);
        singleEmailMsg.setTemplateId(em.Id);
        singleEmailMsg.setTargetObjectId(usr.Id);
        singleEmailMsg.setWhatId(applicationNew.id);
        singleEmailMsg.setSaveAsActivity(false);
        /*if(String.isNotBlank(ca.Contact__c)){
            singleEmailMsg.setTargetObjectId(ca.Contact__c);
        	singleEmailMsg.setSaveAsActivity(true);
        }*/
        singleEmailMsg.setOrgWideEmailAddressId(add.id);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {singleEmailMsg});
        
        //application.Application_Status__c = 'Completed';
        //update application;
        applicationCreated = true;
        
  //      Messaging.SingleEmailMessage EmailBody = Messaging.renderStoredEmailTemplate(EmailTemplateObj.Id, InvoiceObj.CmentorPay__Billing_Contact__c, InvoiceObj.Id);
        
        //if(!String.isNotBlank(ca.Contact__c)){
            Task newTask = new Task();
            newTask.WhatId = applicationNew.id;
            newTask.Subject = singleEmailMsg.getSubject();
            newTask.Description = singleEmailMsg.getHtmlBody();
            Insert newTask;
        //}
    }
    
    public List<SelectOption> getDesignation(){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Customer_Application_Lawyer__c.Designation__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'Select Designation'));
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
            system.debug('1253 ==>'+ f.getLabel()+' => '+ f.getValue());
        }       
        system.debug('1255 ==>'+ application);
        return options;
    }
    public List<SelectOption> getNBASource(){
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Customer_Application__c.NBA_App_Source__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', 'Select Designation'));
        for( Schema.PicklistEntry f : ple){
            if(f.getValue() != 'Unknown'){
                options.add(new SelectOption(f.getLabel(), f.getValue()));
            }
        }       
        return options;
    }
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        for(AOP_Factor__c Aop:lstOfAopFactors){
            options.add(new SelectOption(Aop.id,Aop.Name));
        }
        return options;
    }
    
    public List<LimitsDeductiblesWrapper> getLimitsDeductibles(){
        List<LimitsDeductiblesWrapper> wrapperList = new List<LimitsDeductiblesWrapper>();
        List<ILF_Coverage_Factor__c> listLimits = new List<ILF_Coverage_Factor__c>([SELECT Id,Name,Is_10X10_Coverage__c,Is_5X5_Coverage__c FROM ILF_Coverage_Factor__c WHERE From_Date__c <=: application.Effective_Date_Requested__c AND To_Date__c >=: application.Effective_Date_Requested__c AND OldLimit__c = false ORDER BY Sort_Order__c  ASC NULLS LAST,Coverage_Max_Per_Claim__c,Full_Coverage__c ASC LIMIT 1000]);
        List<Deductible_Factor__c> listDeductible =  new List<Deductible_Factor__c>([SELECT Id,Name FROM Deductible_Factor__c WHERE From_Date__c <=: application.Effective_Date_Requested__c AND To_Date__c >=: application.Effective_Date_Requested__c ORDER BY Deductible_Amount__c ASC LIMIT 1000]);
        Integer size = listLimits.size() > listDeductible.size() ? listLimits.size() : listDeductible.size();
        for(Integer i=0;i<size;i++){
            LimitsDeductiblesWrapper wrapper = new LimitsDeductiblesWrapper();
            if(listLimits.size()-1>=i){
                wrapper.limits = listLimits.get(i);
            }else{
                wrapper.limits = null;
            }
            if(listDeductible.size()-1>=i){
                wrapper.deductible = listDeductible.get(i);
            }else{
                wrapper.deductible = null;
            }
            wrapperList.add(wrapper);
        }
        return wrapperList;
    }
    
    public List<ILF_Coverage_Factor__c> getLimits () {
        List<ILF_Coverage_Factor__c> ILFList = new List<ILF_Coverage_Factor__c>([SELECT Id,Name,Is_10X10_Coverage__c,Is_5X5_Coverage__c FROM ILF_Coverage_Factor__c WHERE From_Date__c <=: application.Effective_Date_Requested__c AND To_Date__c >=: application.Effective_Date_Requested__c AND OldLimit__c = false  and Name != '3,000,000 / 7,500,000' and Full_Coverage__c <= 5000000 AND Coverage_Max_Per_Claim__c <= 5000000 ORDER BY Sort_Order__c ASC NULLS LAST,Coverage_Max_Per_Claim__c,Full_Coverage__c ASC LIMIT 1000]);
        List<ILF_Coverage_Factor__c> tempList =  new List<ILF_Coverage_Factor__c>();
        List<ILF_Coverage_Factor__c> removedILFList = new List<ILF_Coverage_Factor__c>();
        system.debug('ILFList.size() => '+ILFList.size());
        for(Integer i = 0; i<ILFList.size(); i++){ 
            /*if(i<3){
                removedILFList.add(ILFList[i]);
            }
            else{*/
                tempList.add(ILFList[i]);
            //}
        }
        //tempList.addAll(removedILFList);
        return tempList; 
    }
    public List<Deductible_Factor__c> getDeductibles () {
        return new List<Deductible_Factor__c>([SELECT Id,Name FROM Deductible_Factor__c where From_Date__c <=: application.Effective_Date_Requested__c AND To_Date__c >=: application.Effective_Date_Requested__c AND Deductible_Amount__c <= 5000 ORDER BY Deductible_Amount__c ASC LIMIT 1000]);
    }
    
    public List<SelectOption> getLimit () {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-None-'));
        for (ILF_Coverage_Factor__c threatMapping : [SELECT Id,Name,Is_10X10_Coverage__c,Is_5X5_Coverage__c FROM ILF_Coverage_Factor__c WHERE From_Date__c <=: application.Effective_Date_Requested__c AND To_Date__c >=: application.Effective_Date_Requested__c AND OldLimit__c = false  and Name != '3,000,000 / 7,500,000' ORDER BY Sort_Order__c  ASC NULLS LAST,Coverage_Max_Per_Claim__c,Full_Coverage__c ASC LIMIT 1000]) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
        }
        return options;
    }
    
    public Decimal getTotal () {
        Decimal total = 0;
        for(aopWrapper aw: aopList){
            if(aw.percentage != null){
                total += aw.percentage;
                aw.aop.Percentage__c = aw.percentage;
            }
        }
        totalVal = total;
        return total;
    }
     public List<SelectOption> getDeductible () {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-None-'));
        Deductible_Factor__c[] threatMappings = [SELECT Id,Name FROM Deductible_Factor__c where From_Date__c <=: application.Effective_Date_Requested__c AND To_Date__c >=: application.Effective_Date_Requested__c AND Deductible_Amount__c <= 25000 ORDER BY Deductible_Amount__c ASC LIMIT 1000];
        for (Deductible_Factor__c threatMapping : threatMappings) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
        }
        return options;
    }
    public class LimitsDeductiblesWrapper{
        public ILF_Coverage_Factor__c limits{get;set;}
        public Deductible_Factor__c deductible{get;set;}
    }
    
    public class aopWrapper{
        public AOP_Factor__c factor {get;set;}
        public Customer_Application_AOP__c aop{get;set;}
        public Integer percentage{get;set;}
    }
    
    public class aopComboWrapper{
        public aopWrapper obj1{get;set;}
        public aopWrapper obj2{get;set;}
    }
    
     public class quoteWrapper{
         public Policy_Quote__c quote {get;set;}
         public String limitVal{get;set;}
         public String deductibleVal{get;set;}
         public String idVal{get;set;} 
     }
    
    public class optionWrapper{
        public String label {get;set;}
        public String value{get;set;}
    }
}