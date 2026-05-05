public without sharing class EZQOnlineApplicationFormCtrl {
    
    public String currentStage{get;set;}
    public String policyIdString{get;set;}
    public Id policyId{get;set;}
    public Id SelectedQuoteId{get;set;}
    public policy__c policy{get;set;}
    public List<policyLawyerWrapper> policyLawyers {get;set;}
    public policyWrapper polWrapper {get;set;}
    public EZQAdditionalInfoWrapper additionInfoWrap{get;set;}
    public String combineCityStateZip{get;set;}
    public boolean booleanShowApplScreen{get;set;}
    public boolean showThankYou{get;set;}
    public boolean showAfterTaskScreen{get;set;}
    public boolean notRecordTypeApp{get;set;}
    public List<policyQuoteWrapper> policyQuoteWrapperList{get;set;}
    Map<String,String> contractRoleValues;
    public static boolean error{get;set;}
    Map<String,String> contractRolekeys;  
    public String responseMessage{get;set;}
    public String previousStage{get;set;}
    public String width{get;set;}
    public String billingLink{get;set;}
    public String stageFirmInfoChange{get;set;}
    public String stageQuoteChange{get;set;}
    public String stageLawyerChange{get;set;}
    public String stageInstructionChanged{get;set;}
    public String stepClicked{get;set;}
    public String stepBeforeClicked{get;set;}
    public String stageAdditionalInfoChanged{get;set;}
    
    
    public EZQOnlineApplicationFormCtrl(){
        contractRoleValues = new Map<String,String>();
        contractRolekeys =  new Map<String,String>();
        currentStage = 'Instructions';
        
        
        
        policyIdString = System.currentPageReference().getParameters().get('id');
        policyId  = EZQOnlineApplicationFormCtrl.processDecryption(policyIdString.trim() ,Label.Encryption_key_Policy_Id);
        polWrapper = new policyWrapper();
        additionInfoWrap = new EZQAdditionalInfoWrapper();
        List<policyLawyerWrapper> policyLawyerWrapperList = new List<policyLawyerWrapper>();
        if(String.isNotBlank(policyId))
        {
            
            
            
            
            
            policy = [SELECT Id,RecordType.name,Name,Account__r.Name,Account__r.Trade_Name_or_D_B_A__c,Account__r.BillingStreet,Underwriter_User__c, Effective_Date__c, Expiration_Date__c, 
                      Stage_Firm_Info_change__c,Stage_Lawyers_change__c,Stage_Quote_change__c,Stage_Instructions_change__c,Stage_Additional_Info_change__c,
                      Account__r.BillingCity, Account__r.BillingState,Account__r.BillingPostalCode,Application_Status_Tracking__c,App_Approval_Name__c,App_Approval_Title__c,App_Approval_Acknowledge__c,
                      County__r.Name,Firm_Contact__r.Name,Firm_Contact__r.Phone,Firm_Contact__r.Email,EZQ_Online_Additional_Info__c,Policy_Document_Version__c,Underwriter_User__r.Name,Underwriter_User__r.Phone,Underwriter_User__r.Email,
                      (SELECT Id, Coverage_Max_Per_Claim__c,Full_Coverage__c ,Deductible_Amount__c , Quote_Final_Premium__c,Policy_Effective_Date__c, Final_Quote__c  FROM Policy_Quotes__r order by Quote_Final_Premium__c ASC),
                      (SELECT Id, Prior_Act_Date__c,Average_Hours_Per_Week__c ,ARDC_Number__c,Lawyer__r.Name,Contact_Role__c,Lawyer__r.Contact__r.Email,
                       ISBA_Number__c FROM Policy_Lawyers__r)
                      FROM policy__c WHERE id=: policyId
                     ];
            if(policy.recordType.Name == 'Application'){
                booleanShowApplScreen = true;
                
                if(policy.Application_Status_Tracking__c == 'Application open'){}
                
                
                
                if(policy.EZQ_Online_Additional_Info__c != null){
                    additionInfoWrap = (EZQAdditionalInfoWrapper)JSON.deserialize(policy.EZQ_Online_Additional_Info__c, EZQAdditionalInfoWrapper.class);
                }
                polWrapper.principalAddress = policy.Account__r.billingStreet;
                polwrapper.city=  policy.Account__r.BillingCity;
                polwrapper.state = policy.Account__r.BillingState;
                polwrapper.zip = policy.Account__r.BillingPostalCode;
                polwrapper.approvalName = policy.App_Approval_Name__c;
                polwrapper.approvalTitle = policy.App_Approval_Title__c;
                polwrapper.approvalAck = policy.App_Approval_Acknowledge__c;
                polWrapper.underwriterName = policy.Underwriter_User__r.Name;
                polWrapper.underwriterEmail = policy.Underwriter_User__r.Email;
                polWrapper.underwriterPhone = policy.Underwriter_User__r.Phone;
                combineCityStateZip = policy.Account__r.BillingCity+', '+ policy.Account__r.BillingState + '&nbsp;&nbsp;'+ policy.Account__r.BillingPostalCode;
                if(!policy.Policy_Lawyers__r.isEmpty())
                {
                    getContactRolesList();
                    for(Policy_Lawyer__c policyLawyer : policy.Policy_Lawyers__r)
                    {
                        policyLawyerWrapper pLayerWrapper = new policyLawyerWrapper();
                        pLayerWrapper.policyLawyer = policyLawyer;
                        System.debug(policyLawyer.Contact_Role__c);
                        playerWrapper.desgination = contractRoleKeys.get(policyLawyer.Contact_Role__c);
                        playerWrapper.avergaeHoursPerWeek = policyLawyer.Average_Hours_Per_Week__c;
                        policyLawyerWrapperList.add(pLayerWrapper);
                    }
                }
                
                policyQuoteWrapperList = new List<policyQuoteWrapper>();
                if(!policy.Policy_Quotes__r.isEmpty()){
                    for(Policy_Quote__c inst : policy.Policy_Quotes__r){
                        policyQuoteWrapper wrap = new policyQuoteWrapper();
                        wrap.isSelected = inst.Final_Quote__c;
                        wrap.policyQuote = inst;
                        policyQuoteWrapperList.add(wrap);
                    }
                }
                
                
                
                // Return Policy Lawyers
                if(policyLawyers == null && policyLawyerWrapperList != null && !policyLawyerWrapperList.isEmpty()){
                    policyLawyers = policyLawyerWrapperList;
                }
                System.debug(policy.Policy_Quotes__r);
            }
            else{
                notRecordTypeApp = true;
            }
        }
        
    }
    
    
    
    // This is for getting contact role picklist
    public List<SelectOption> getContactRolesList(){
        
        List<SelectOption> contactRolesList = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Policy_Lawyer__c.Contact_Role__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            contactRolesList.add(new selectOption(pickListVal.getLabel(), pickListVal.getLabel()));
            contractRoleValues.put(pickListVal.getLabel(),pickListVal.getvalue());
            contractRoleKeys.put(pickListVal.getvalue(), pickListVal.getLabel());
        }  
        return  contactRolesList ;
        
    }
    
    // This is for Encyrption of URL
    public static string processEncryption(String name, String key){ 
        Blob cryptoKey = Blob.valueOf(key);
        Blob data = Blob.valueOf(name); 
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey, data); 
        String b64Data = EncodingUtil.base64Encode(encryptedData);  
        System.debug(b64Data);
        return b64Data; 
    } 
    
    // This is for decryption of URL
    public static String processDecryption(String encryptedData, String key){ 
        System.debug(encryptedData);
        String decryptedData; 
        Blob data = EncodingUtil.base64Decode(encryptedData); 
        Blob privateKey = Blob.valueOf(key);  
        String expMsg;
        try{ 
            Blob dataToDecrypt = Crypto.decryptWithManagedIV('AES128', privateKey, data); 
            decryptedData = dataToDecrypt.toString(); 
        } 
        catch(Exception e){ 
            expMsg = e.getMessage();  
        } 
        return (string.isEmpty(expMsg) ?  decryptedData :  expMsg);  
    } 
    
    
    // Set Radio Options
    public List<SelectOption> getRadOptions()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('Yes', 'YES'));
        options.add(new SelectOption('No', 'NO'));
        return options;
    }
    
    // Final submit 
    public void submit(){
        try{
            
            paramWrapper wrap = new paramWrapper();
            wrap.policyId = policy.Id;
            wrap.policyDocumentVersion = policy.Policy_Document_Version__c;
            wrap.nameSubmit =  polwrapper.approvalName;
            wrap.nameTitle =  polwrapper.approvalTitle;
            wrap.acknowledge = polwrapper.approvalAck;
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:CashReceipt_Api/services/apexrest/convertPolicy');
            request.setMethod('POST');
            request.setHeader('Content-Type','application/json'); 
            request.setBody( JSON.serialize(wrap));
            request.setTimeout(120000);
            Http http = new Http();
            HTTPResponse APIresponse = new  HTTPResponse ();
            APIresponse = http.send(request);
            system.debug('APIresponse :: ' + APIresponse.getBody());
            if(Boolean.valueOf(APIresponse.getBody()) == false){
                showThankYou = true;
                booleanShowApplScreen = false;
                responseMessage = 'success';
            }
            else{
                responseMessage = 'Some error has occurred while processing your request please contact policy underwriter to complete this application.';
            }
            
            //return responseMessage;
        }
        catch(exception e){
            system.debug('ERROR'+e.getMessage());
            responseMessage ='Some error has occurred while processing your request please contact policy underwriter to complete this application.';
        }
    }
    
    
    
    
    
    
    public void getBillingPaymentLink(){
        List<AcctSeed__Billing__c> billing = [select id,payment_Link__c
                                              from AcctSeed__Billing__c where Policy__c =: policy.Id];
        if(!billing.isEmpty()){
            billingLink = billing[0].payment_Link__c;
        }
        
        
        System.debug(billingLink);
        
    }
    
    // Update Addition firm info section
    public String updateAdditionalFirmInfo(){
        try{
            policy.EZQ_Online_Additional_Info__c = JSON.serialize(additionInfoWrap);
            update policy;
            
            if(JSON.serialize(additionInfoWrap).containsIgnoreCase('Yes')){
                
                createTask();
            }else{
                responseMessage = 'success';
            }
            
            return responseMessage;
        }
        catch(Exception e ){
            responseMessage = e.getMessage();
            return 'error';
        }
    }
    
    
    public void createTask(){
        try{
            Map<String,String> InfoHavingYes = new Map<String,String>();
            
            if(additionInfoWrap.aware_of_claim_cbx == 'Yes'){
                InfoHavingYes.put('aware_of_claim_cbx', 'Yes');
                InfoHavingYes.put('aware_of_claim_num', String.valueOf(additionInfoWrap.aware_of_claim_num));
            }
            
            if(additionInfoWrap.disciplinary_bar_denied_cbx == 'Yes'){
                InfoHavingYes.put('disciplinary_bar_denied_cbx', 'Yes');
            }
            
            if(additionInfoWrap.disciplinary_censured_cbx == 'Yes'){
                InfoHavingYes.put('disciplinary_censured_cbx', 'Yes');
            }
            
            if(additionInfoWrap.disciplinary_disbarred_cbx == 'Yes'){
                InfoHavingYes.put('disciplinary_disbarred_cbx', 'Yes');
            }
            
            if(additionInfoWrap.disciplinary_investegation_cbx == 'Yes'){
                InfoHavingYes.put('disciplinary_investegation_cbx', 'Yes');
            }
            
            if(additionInfoWrap.disciplinary_other_cbx == 'Yes'){
                InfoHavingYes.put('disciplinary_other_cbx', 'Yes');
            }
            
            if(additionInfoWrap.disciplinary_reprimanded_cbx == 'Yes'){
                InfoHavingYes.put('disciplinary_reprimanded_cbx', 'Yes');
            }
            
            if(additionInfoWrap.disciplinary_sanctioned_cbx == 'Yes'){
                InfoHavingYes.put('disciplinary_sanctioned_cbx', 'Yes');
            }
            
            if(additionInfoWrap.disciplinary_suspended_cbx == 'Yes'){
                InfoHavingYes.put('disciplinary_suspended_cbx', 'Yes');
            }
            if(additionInfoWrap.lawyer_join_past_12m_cbx == 'Yes'){
                InfoHavingYes.put('lawyer_join_past_12m_cbx', 'Yes');
            }
            if(additionInfoWrap.pl_claim_12m_not_reported_cbx == 'Yes'){
                InfoHavingYes.put('pl_claim_12m_not_reported_cbx', 'Yes');
                InfoHavingYes.put('pl_claim_12m_not_reported_cbx', String.valueOf(additionInfoWrap.pl_claim_12m_not_reported_num));
            }
            if(additionInfoWrap.disciplinary_closed_num != null || additionInfoWrap.disciplinary_closed_num != '' ){
                InfoHavingYes.put('disciplinary_closed_num', String.valueOf(additionInfoWrap.disciplinary_closed_num));
                InfoHavingYes.put('disciplinary_open_num', String.valueOf(additionInfoWrap.disciplinary_open_num));
            }
            
            
            Task taskRecord = new Task();
            taskRecord.Subject = 'Update In Firm';
            taskRecord.Status = 'Open';
            taskRecord.whatid = policy.id;
            taskRecord.Description = JSON.serialize(InfoHavingYes);
            taskRecord.OwnerId = policy.Underwriter_User__c ;
            
            
            insert taskRecord;
            
            // showAfterTaskScreen = true;
            // showThankYou = false;
            //booleanShowApplScreen = false;                
            responseMessage = 'success';
            
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    
    public String updateListOfLawyers(){
        List<Policy_Lawyer__c> policyLawyerList = new List<Policy_Lawyer__c>();
        try{
            if(policyLawyers != null && !policyLawyers.isEmpty()) {
                for(policyLawyerWrapper pLawyer : policyLawyers){
                    pLawyer.policyLawyer.Contact_Role__c = contractRoleValues.get(pLawyer.desgination);
                    pLawyer.policyLawyer.Average_Hours_Per_Week__c = pLawyer.avergaeHoursPerWeek;
                    policyLawyerList.add(pLawyer.policyLawyer);
                }
            }
            if(!policyLawyerList.isEmpty()){
                update policyLawyerList;
            }
            responseMessage = 'success';
            return 'success';
        }
        catch(Exception e){
            responseMessage = e.getMessage();
            return 'error';
        }
    }
    
    // Update firm information
    public void updateFirmInformation(){
        try{
            if(polWrapper != null && policy != null)
            {
                if(policy.Account__c != null)
                {
                    Account policyFirm = new Account();
                    policyFirm.id = policy.Account__c;
                    
                    if(String.isNotBlank(polWrapper.principalAddress)) {
                        policyFirm.BillingStreet = polWrapper.principalAddress;
                    }
                    
                    if(String.isNotBlank(polWrapper.city)) {
                        policyFirm.BillingCity = polWrapper.city;
                    }
                    if(String.isNotBlank(polWrapper.state)){
                        policyFirm.BillingState = polwrapper.state;
                    }
                    
                    if(String.isNotBlank(polWrapper.zip)){
                        policyFirm.BillingPostalCode = polwrapper.zip;
                    }
                    
                    if(policyFirm != null){
                        update policyFirm;
                    }
                }
            }
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    public string handleUpdateFirmRenewal(){
        try{
            Policy_Quote__c quote;
            /*
List<Policy_Quote__c> updatePolicyQuoteListTofalse = new List<Policy_Quote__c>();
for(policyQuoteWrapper inst : policyQuoteWrapperList){
inst.policyQuote.Final_Quote__c = false;
inst.policyQuote.Bypass_Default_Coverage_Factor__c = true;
updatePolicyQuoteListTofalse.add(inst.policyQuote);
}

update updatePolicyQuoteListTofalse;
*/
            
            for(policyQuoteWrapper inst : policyQuoteWrapperList){
                if(inst.isSelected == true){
                    quote = new Policy_Quote__c();
                    quote.Id = inst.policyQuote.Id;
                    quote.Final_Quote__c  = true;
                    //quote.Bypass_Default_Coverage_Factor__c = true;
                    break;
                }
            }
            if(quote != null){
                update quote;
            }
            responseMessage = 'success';
            return 'success';
        }
        catch(Exception e){
            responseMessage = e.getMessage();
            return 'error';
        }
    }
    
    public void updateStatusInitially(){
        updateStatus('Application open');
    }
    
   
    
    Public void updateStatus(String Status){
        try{
            policy.Application_Status_Tracking__c  = Status;
            if(String.isNotBlank(stageFirmInfoChange)){
                 policy.Stage_Firm_Info_change__c = Boolean.valueOf(stageFirmInfoChange);
            }
            
            if(String.isNotBlank(stageLawyerChange)){
                  policy.Stage_Lawyers_change__c =  Boolean.valueOf(stageLawyerChange);
            }
            System.debug('sss'+stageInstructionChanged);
            if(String.isNotBlank(stageInstructionChanged)){
                policy.Stage_Instructions_change__c = Boolean.valueOf(stageInstructionChanged);
            }
            
            if(String.isNotBlank(stageQuoteChange)){
                 policy.Stage_Quote_change__c =  Boolean.valueOf(stageQuoteChange);
            }
            
            if(String.isNotBlank(stageAdditionalInfoChanged)){
                 policy.Stage_Additional_Info_change__c =  Boolean.valueOf(stageAdditionalInfoChanged);
            }
            
            
            /*
            policy.Stage_Firm_Info_change__c = Boolean.valueOf(stageFirmInfoChange);
            policy.Stage_Lawyers_change__c =  Boolean.valueOf(stageLawyerChange);
            policy.Stage_Instructions_change__c = Boolean.valueOf(stageInstructionChanged);
            policy.Stage_Quote_change__c =  Boolean.valueOf(stageQuoteChange);*/
            update policy;
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    public void removeQuotesFinal(){
        try{
            List<Policy_Quote__c> updatePolicyQuoteListTofalse = new List<Policy_Quote__c>();
            for(policyQuoteWrapper inst : policyQuoteWrapperList){
                inst.policyQuote.Final_Quote__c = false;
                inst.policyQuote.Bypass_Default_Coverage_Factor__c = true;
                updatePolicyQuoteListTofalse.add(inst.policyQuote);
            }
            
            update updatePolicyQuoteListTofalse;
            
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    //handleStepClick
    
    public void handleStepClick(){
        stepBeforeClicked =currentStage;
        if(stepClicked == ''){
            currentStage = 'Instructions';
        }
        else{
            currentStage = stepClicked;
            handleContinue();
        }
    }
    
    
    // handle Continue
    public  void handleContinue(){
        
        
        switch on currentStage {
            when 'Instructions' {
                removeQuotesFinal();
                currentStage = 'firmRenewal';
                responseMessage = 'success';
                previousStage = 'Instructions';
                updateStatus('Firm Renewal Quotes');
                
                
            }	
            when 'firmRenewal' {
                if(handleUpdateFirmRenewal() == 'success'){
                    currentStage = 'firmInfo';
                     previousStage = 'firmRenewal';
                    updateStatus('Firm info');
                }
            }
            when 'firmInfo' {
                //updateFirmInformation();
                System.debug('Stagevalue'+stageFirmInfoChange);
                currentStage = 'listOfLawyers';
                previousStage = 'firmInfo';
                responseMessage = 'success';
	            updateStatus('Lawyer');
            }
            when 'listOfLawyers' {
                if(updateListOfLawyers() == 'success'){
                    currentStage = 'addFirmInfo';
                    previousStage = 'listOfLawyers';
                    updateStatus('Additional Firm Info');
                }
            }
            when 'addFirmInfo' {	
                if(updateAdditionalFirmInfo() == 'success'){
                    if(JSON.serialize(additionInfoWrap).containsIgnoreCase('Yes')){
                        showAfterTaskScreen = true;
                        booleanShowApplScreen = false;
                    }
                    else{
                        currentStage = 'quoteAcceptance';
                         previousStage = 'addFirmInfo';
                        updateStatus('Quote Acceptance');
                    }
                }
            }
        }
        
    }
    // handle Previous
    public void handlePrevious(){
        
        switch on currentStage {
            when 'quoteAcceptance' {
                currentStage = 'addFirmInfo';
                previousStage = 'quoteAcceptance';
            }	
            when 'addFirmInfo' {
                currentStage = 'listOfLawyers';
                 previousStage = 'addFirmInfo';
            }
            when 'listOfLawyers' {	
                currentStage = 'firmInfo';
                 previousStage = 'listOfLawyers';
            }
            when 'firmInfo' {
                currentStage = 'firmRenewal';
                previousStage = 'firmInfo';
            }
            when 'firmRenewal' {	
                currentStage = 'Instructions';
                previousStage = 'firmRenewal';
            }
        }
        
    }
    
    public class policyWrapper 
    {
        
        public string principalAddress {get;set;}
        public string city{get;set;}
        public string state{get;set;}
        public string zip{get;set;}
        public String approvalName{get;set;}
        public String approvalTitle{get;set;}
        public boolean approvalAck{get;set;}
        public String underWriterName{get;set;}
        public String underWriterEmail{get;set;}
        public String underWriterPhone{get;set;}
        
    }
    
    public class policyQuoteWrapper{
        public boolean isSelected{get;set;}
        public Policy_Quote__c policyQuote{get;set;}
    }
    
    public class policyLawyerWrapper 
    {
        public boolean ischecked {get;set;}
        public String desgination {get;set;}
        public Double avergaeHoursPerWeek{get;set;}
        public string input1    {get;set;}
        public string input3    {get;set;}
        public Policy_Lawyer__c policyLawyer {get;set;}
        
        public policyLawyerWrapper(){
            this.ischecked = false;
        }
    }
    
    public class paramWrapper{
        public String policyId;
        public String policyDocumentVersion;
        public String nameSubmit;
        public String nameTitle;
        public boolean acknowledge;
    }
    
}