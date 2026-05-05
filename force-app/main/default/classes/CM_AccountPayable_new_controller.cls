/*************************************************************
    @Company        : Cmentor
    @Author         : Sachin Arora
    @Created Date   : 02/07/2017
    @Desciption     :   This class acts as a controller for 
                        AccountPayable New Page.
    @TestClass Name : 
    Version          Developer                    Date                        Description
*-------------------------------------------------------------------------------------------
*     1.0            sachin                       07-Feb-2017                   Initial Creation 
***************************************************************************************************/



public class CM_AccountPayable_new_controller {
	
    public class CM_AccountPayable_new_controllerException Extends Exception{}
    
    public static ID ClaimPaymentRTID = Schema.SObjectType.Policy_Claim_Detail__C.getRecordTypeInfosByName().get('Claim Payment').getRecordTypeId(); 
    public static ID UnallocatedLAERTID = Schema.SObjectType.Policy_Claim_Detail__C.getRecordTypeInfosByName().get('Unallocated LAE').getRecordTypeId();
    
    public AcctSeed__Account_Payable__c accPayableObj{get;set;}
    public Contact contactObj{get;set;}
    public Account accountObj{get;set;}
    public Policy_Claim__c claimObj{get;set;}
    public Policy__c policyObj{get;set;}
    public String error{get;set;}
    public string indexOfLineItemToBeRemoved {get; set;}
    public String selectedAppPolicy{get;set;}
    public String selectedPolicyClaimId{get;set;}
    public String selectedVendorId{get;set;}
    public Map<String,String> typeWithGlNamesMap{get;set;}
    public Map<String,String> glNamesWithGlIdMap{get;set;}
    public list<SelectOption> ClaimOptions{get;set;}    
    public list<HIC_AccountPayableLineItemWrapper> accPayLineWrapList{get;set;}
    public boolean checksaveNew;
    Policy_Claim__c policyClaim;
    //Standard Controller Constructor
    public CM_AccountPayable_new_controller(ApexPages.StandardController stdController){
        
        List<Account_Payable_Type_Mapping__mdt> accPayExpGlList = [SELECT Id,MasterLabel,Expense_GL_Account_Name__c  FROM Account_Payable_Type_Mapping__mdt ]; 
        typeWithGlNamesMap = new Map<String,String>();
        glNamesWithGlIdMap = new Map<String,String>();
        for(Account_Payable_Type_Mapping__mdt obj: accPayExpGlList){
            typeWithGlNamesMap.put(obj.MasterLabel, obj.Expense_GL_Account_Name__c);
        }
        List<AcctSeed__GL_Account__c> glList = [SELECT Id,Name FROM AcctSeed__GL_Account__c WHERE Name IN: typeWithGlNamesMap.Values()];
        
        for(AcctSeed__GL_Account__c obj: glList){
            glNamesWithGlIdMap.put(obj.Name, obj.Id);
        }
        checksaveNew = false;
        accPayableObj = (AcctSeed__Account_Payable__c)stdController.getRecord();
        init();
        
        system.debug('------------start---------');
        
        if(ApexPages.currentPage().getParameters().get('obj') != null && ApexPages.currentPage().getParameters().get('obj') != '' && ApexPages.currentPage().getParameters().get('obj') == 'account' ){
           
           
            string vendorname = ApexPages.currentPage().getParameters().get('accountName');
            string vendorId = ApexPages.currentPage().getParameters().get('accountId');
            
            accPayableObj.AcctSeed__Vendor__c = vendorId ;
            accPayableObj.AcctSeed__Payee_Reference__c = vendorname +' - '+Date.today().format();
            onVendorSelect();
            
        }
        
        if(ApexPages.currentPage().getParameters().get('obj') != null && ApexPages.currentPage().getParameters().get('obj') != '' && ApexPages.currentPage().getParameters().get('obj') == 'claim' ){
            
            string claimName = ApexPages.currentPage().getParameters().get('claimName');
            
            string vendorId = ApexPages.currentPage().getParameters().get('accountId');
            Id claimId = ApexPages.currentPage().getParameters().get('claimId');
            Id policyId = ApexPages.currentPage().getParameters().get('policyId'); 
            
            policyClaim =[select id,name,Payable_Reference_Running_Number__c,Policy__r.Account__c from Policy_Claim__c where id = : claimId];
            if(policyClaim.Payable_Reference_Running_Number__c==null){
                policyClaim.Payable_Reference_Running_Number__c =0;
            }
            accPayableObj.AcctSeed__Payee_Reference__c = claimName;//+' - ' + (policyClaim.Payable_Reference_Running_Number__c + 1 );
            selectedAppPolicy = policyId ;
            onPolicyOptionChange();
            selectedPolicyClaimId = claimId ;
            onClaimOptionChange();
            
            
                
        }
    }
    
    
    //Update Expense Gl Accounts
    public void onTypeChange(){
         System.debug('Selected Type: nnn ' + accPayableObj.Type__c);
        system.debug(accPayableObj.Type__c);
        system.debug(typeWithGlNamesMap.KeySet());
        System.debug(glNamesWithGlIdMap.KeySet());
        if(String.isNotBlank(accPayableObj.Type__c) && typeWithGlNamesMap.containsKey(accPayableObj.Type__c) && glNamesWithGlIdMap.containsKey(typeWithGlNamesMap.get(accPayableObj.Type__c))){
            
            for(HIC_AccountPayableLineItemWrapper obj : accPayLineWrapList){
                system.debug(obj.accPayabaleObj.AcctSeed__Expense_GL_Account__c);
                if(!String.isNotBlank(obj.accPayabaleObj.AcctSeed__Expense_GL_Account__c)){
                    obj.accPayabaleObj.AcctSeed__Expense_GL_Account__c = glNamesWithGlIdMap.get(typeWithGlNamesMap.get(accPayableObj.Type__c));
                }
            }
        }
        System.debug(accPayLineWrapList);
    }
    
    //initialize function
    public void init(){
        claimObj = new Policy_Claim__c();
        policyObj = new Policy__c();
       
        accPayLineWrapList = new list<HIC_AccountPayableLineItemWrapper>();
        accPayLineWrapList.add(new HIC_AccountPayableLineItemWrapper(new AcctSeed__Account_Payable_Line__c()));
        ClaimOptions = new list<SelectOption>();
    }
    
    
    
    //method to show vendor details on vendor select
    public void onVendorSelect(){
        
        system.debug('********');
        system.debug('vendor id****'+accPayableObj.AcctSeed__Vendor__c+'**********'+accPayableObj.AcctSeed__Payee_Reference__c);
       //claimObj = new Policy_Claim__c();
       
       accountObj = new Account();
       //selectedPolicyClaimId ='';
       
        if(accPayableObj.AcctSeed__Vendor__c != null){
            list<Account> accList = new list<Account>([Select Id,
                                                              Name,
                                                              AccountNumber,
                                                              AcctSeed__Accounting_Type__c,
                                                              AcctSeed__X1099_Vendor__c,
                                                              BillingCountry,
                                                              BillingStreet,
                                                              BillingCity,
                                                              type,
                                                              BillingState 
                                                              FROM Account 
                                                              WHERE Id=:accPayableObj.AcctSeed__Vendor__c]);
            
            if(!accList.isEmpty()){
                accountObj = accList.get(0);
                system.debug('accountObj ****'+accountObj.BillingStreet+'***'+accountObj.BillingState+'****'+accountObj.BillingCity);
                
                if(accPayableObj.Claim__c == null){
            
                        accPayableObj.AcctSeed__Payee_Reference__c = accountObj.Name +' - '+Date.today().format();
                
                }
                
            } 
            else {
                
                if(accPayableObj.Claim__c == null){
            
                        accPayableObj.AcctSeed__Payee_Reference__c = '';
                
                }
            }
            
            //getAppPolicyOptions();
        }
        else{
                 accountObj = new Account();
                 if(accPayableObj.Claim__c == null){
            
                        accPayableObj.AcctSeed__Payee_Reference__c = '';
                
                 }
            }
    }
    
     public void onPolicyOptionChange(){
         
         accPayableObj.Policy__c = selectedAppPolicy;
         
         List<Policy__c> policyList = [SELECT Id,Name,Account__c FROM Policy__c WHERE Id =: selectedAppPolicy LIMIT 1];
         
         if(!policyList.isEmpty()){
             policyObj = policyList.get(0);
         }
         
         //allClaimOptions();
     }   
     
     public List<SelectOption> getVendorAccountOptions() {
        
        List<SelectOption> options = new List<SelectOption>();
            
            for(Account obj :[Select id,Name,Vendor_Account__c
                                             FROM Account 
                                             WHERE Vendor_Account__c =True]){
                                                
                options.add(new SelectOption(obj.Id,obj.Name));
            }
            
            return options;
        
    }
    
    //Method on change of claim select option
    public void onClaimOptionChange(){
        if(selectedPolicyClaimId!=null && selectedPolicyClaimId!=''){
            list<Policy_Claim__c> policyClaimList = new list<Policy_Claim__c>([Select Id,
                                                                                      Policy__c,
                                                                                      Policy__r.Account__c,
                                                                                      Firm_Name__c, 
                                                                                      Claim_Made_Date__c,
                                                                                      Aggregate_Limit__c,
                                                                                      Report_Date__c,
                                                                                      LAE_Pay__c,
                                                                                      Lawyer_Name__c,
                                                                                      Claim_Closed__c,
                                                                                      Unpaid_Reserves_Direct_Loss__c,
                                                                                      Unpaid_Reserves_Direct_LAE__c,
                                                                                      Payment_Direct_Loss__c,
                                                                                      Payment_Direct_LAE__c,
                                                                                      Incurred_Direct_Loss__c,
                                                                                      Incurred_Direct_LAE__c,
                                                                                      Unpaid_Reserves_Retained_LAE__c,
                                                                                      Name,GL_5010__c,GL_5035__c,GL_5000__c,GL_5030__c
                                                                                      FROM Policy_Claim__c
                                                                                      WHERE Id =: selectedPolicyClaimId]);
            if(!policyClaimList.isEmpty()){
                claimObj = policyClaimList.get(0);
            }                                                                                      
        }
        else{
             claimObj = new Policy_Claim__c();
        }
        accPayableObj.Claim__c = selectedPolicyClaimId;
    }
    
    //Method for removing line item row
     public void removeLineItemRow(){
         system.debug('---inside new row'+indexOfLineItemToBeRemoved);
         if(indexOfLineItemToBeRemoved != null){
             accPayLineWrapList.remove(integer.valueOf(indexOfLineItemToBeRemoved));
         }
     }
    
    //Method for adding new line item row
    public void addAccPayNewLine(){
        AcctSeed__Account_Payable_Line__c accPayLine = new AcctSeed__Account_Payable_Line__c();
        if(String.isNotBlank(accPayableObj.Type__c) && typeWithGlNamesMap.containsKey(accPayableObj.Type__c) && glNamesWithGlIdMap.containsKey(typeWithGlNamesMap.get(accPayableObj.Type__c))){
            accPayLine.AcctSeed__Expense_GL_Account__c = glNamesWithGlIdMap.get(typeWithGlNamesMap.get(accPayableObj.Type__c));
        }
        accPayLineWrapList.add(new HIC_AccountPayableLineItemWrapper(accPayLine));
    }
    
    //For inserting account payable and line items
    public pagereference onSaveClick(){
        Savepoint sp = Database.setSavepoint();
        error = '';
        try{
          boolean isRefund = false;
          
          Decimal totalAmount = 0;
          
          for(HIC_AccountPayableLineItemWrapper wrapObj : accPayLineWrapList){
              if(wrapObj.accPayabaleObj != null ){
                  totalAmount += wrapObj.accPayabaleObj.AcctSeed__Amount__c;
                  if(wrapObj.accPayabaleObj.AcctSeed__Amount__c < 0){
                      isRefund = true;
                  }
              }
          }
          if(accPayableObj.Type__c=='Loss Pay' && totalAmount > claimObj.GL_5010__c){
              //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Payment Amount Can not be greater than Unpaid Loss Reserve'));
              throw new CM_AccountPayable_new_controllerException('Payment Amount Can not be greater than Unpaid Loss Reserve');
              //Database.rollback(sp);
              //return null;
          }else if(accPayableObj.Type__c=='LAE Pay' && totalAmount > claimObj.GL_5035__c){
              throw new CM_AccountPayable_new_controllerException('Payment Amount Can not be greater than Unpaid LAE Reserve');
              //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Payment Amount Can not be greater than Unpaid LAE Reserve'));
              //Database.rollback(sp);
              //return null;
          }
          
          AccountPayableTriggerHandler.createBilling = true;
          
          policyClaim.Payable_Reference_Running_Number__c = policyClaim.Payable_Reference_Running_Number__c +1;
          
          update policyClaim;
          system.debug('policyClaim.Payable_Reference_Running_Number__c :2: ' + policyClaim.Payable_Reference_Running_Number__c);
          System.debug('--claimObj.Policy__r.Account__c-- :: '+claimObj.Policy__r.Account__c);
          
          
          if(isRefund){
              List<Policy_Claim_Detail__c> claimDetailList = new List<Policy_Claim_Detail__c>();
              for(HIC_AccountPayableLineItemWrapper wrapObj : accPayLineWrapList){
                  if(wrapObj.accPayabaleObj != null ){
                      if(accPayableObj.Type__c=='LAE Pay'){
                          claimDetailList.add(new Policy_Claim_Detail__c(GL_Account_Name__c=wrapObj.accPayabaleObj.AcctSeed__Expense_GL_Account__c,Policy_Claim__c=accPayableObj.Claim__c,Type__c='LAE Payment',Date__c=accPayableObj.AcctSeed__Date__c,Vendor__c=accPayableObj.AcctSeed__Vendor__c,LAE_Amount__c=wrapObj.accPayabaleObj.AcctSeed__Amount__c,RecordTypeId=ClaimPaymentRTID));
                      }else if(accPayableObj.Type__c=='Loss Pay'){
                          claimDetailList.add(new Policy_Claim_Detail__c(GL_Account_Name__c=wrapObj.accPayabaleObj.AcctSeed__Expense_GL_Account__c,Policy_Claim__c=accPayableObj.Claim__c,Type__c='Loss Payment',Date__c=accPayableObj.AcctSeed__Date__c,Vendor__c=accPayableObj.AcctSeed__Vendor__c,Loss_Amount__c=wrapObj.accPayabaleObj.AcctSeed__Amount__c,RecordTypeId=ClaimPaymentRTID));
                      }else if(accPayableObj.Type__c=='Claim Coverage - ARDC'){
                          claimDetailList.add(new Policy_Claim_Detail__c(GL_Account_Name__c=wrapObj.accPayabaleObj.AcctSeed__Expense_GL_Account__c,Policy_Claim__c=accPayableObj.Claim__c,Type__c=accPayableObj.Type__c,Date__c=accPayableObj.AcctSeed__Date__c,Vendor__c=accPayableObj.AcctSeed__Vendor__c,ISBA_First_Payment__c=wrapObj.accPayabaleObj.AcctSeed__Amount__c,RecordTypeId=UnallocatedLAERTID));
                      }else if(accPayableObj.Type__c=='Unallocated LAE Payment'){
                          claimDetailList.add(new Policy_Claim_Detail__c(GL_Account_Name__c=wrapObj.accPayabaleObj.AcctSeed__Expense_GL_Account__c,Policy_Claim__c=accPayableObj.Claim__c,Type__c=accPayableObj.Type__c,Date__c=accPayableObj.AcctSeed__Date__c,Vendor__c=accPayableObj.AcctSeed__Vendor__c,LAE_Amount__c=wrapObj.accPayabaleObj.AcctSeed__Amount__c,RecordTypeId=UnallocatedLAERTID));
                      }
                  }
              }
              
              if(claimDetailList.size()>0){
                  insert claimDetailList;
              }
          } else{
              //add Firm to AP
              if(accPayableObj.AcctSeed__Payee_Reference__c.contains('(')){
                  accPayableObj.AcctSeed__Payee_Reference__c = accPayableObj.AcctSeed__Payee_Reference__c.subStringBefore('(');
              }
              //accPayableObj.AcctSeed__Payee_Reference__c += ' #'+accPayableObj.ISBAM_Invoice_Number__c;
              accPayableObj.Firm__c = claimObj.Policy__r.Account__c;
              
              accPayableObj.AcctSeed__Payee_Reference__c += ' (';
              for(HIC_AccountPayableLineItemWrapper wrapObj : accPayLineWrapList){
                  accPayableObj.AcctSeed__Payee_Reference__c += '#'+wrapObj.accPayabaleObj.ISBAM_Invoice_Number__c+', ';
              }
              accPayableObj.AcctSeed__Payee_Reference__c = accPayableObj.AcctSeed__Payee_Reference__c.endsWith(', ') ? accPayableObj.AcctSeed__Payee_Reference__c.removeEnd(', ') : accPayableObj.AcctSeed__Payee_Reference__c;
              accPayableObj.AcctSeed__Payee_Reference__c += ')';
              System.debug('accPayableObj => '+accPayableObj);
              
              if(accPayableObj.Id != null){
                  List<AcctSeed__Account_Payable__c> payableList = new List<AcctSeed__Account_Payable__c>([SELECT Id FROM AcctSeed__Account_Payable__c WHERE Id=: accPayableObj.Id]);
                  if(payableList.isEmpty()){
                     accPayableObj.Id = null; 
                  }
              }              
              upsert accPayableObj; 
              
              list<AcctSeed__Account_Payable_Line__c> lineItemListToInsert = new list<AcctSeed__Account_Payable_Line__c>();
              List<Policy_Claim_Detail__c> claimDetailList = new List<Policy_Claim_Detail__c>();
              for(HIC_AccountPayableLineItemWrapper wrapObj : accPayLineWrapList){
                  AcctSeed__Account_Payable_Line__c liTempObj = new AcctSeed__Account_Payable_Line__c();
                  if(wrapObj.accPayabaleObj != null ){
                      liTempObj = wrapObj.accPayabaleObj;
                      liTempObj.AcctSeed__Account_Payable__c = accPayableObj.Id;
                      
                      lineItemListToInsert.add(liTempObj);
                      if(accPayableObj.Type__c=='LAE Pay'){
                          claimDetailList.add(new Policy_Claim_Detail__c(Policy_Claim__c=accPayableObj.Claim__c,Type__c='LAE Payment',Date__c=accPayableObj.AcctSeed__Date__c,Vendor__c=accPayableObj.AcctSeed__Vendor__c,LAE_Amount__c=liTempObj.AcctSeed__Amount__c,RecordTypeId=ClaimPaymentRTID));
                      }else if(accPayableObj.Type__c=='Loss Pay'){
                          claimDetailList.add(new Policy_Claim_Detail__c(Policy_Claim__c=accPayableObj.Claim__c,Type__c='Loss Payment',Date__c=accPayableObj.AcctSeed__Date__c,Vendor__c=accPayableObj.AcctSeed__Vendor__c,Loss_Amount__c=liTempObj.AcctSeed__Amount__c,RecordTypeId=ClaimPaymentRTID));
                      }else if(accPayableObj.Type__c=='Claim Coverage - ARDC'){
                          claimDetailList.add(new Policy_Claim_Detail__c(Policy_Claim__c=accPayableObj.Claim__c,Type__c=accPayableObj.Type__c,Date__c=accPayableObj.AcctSeed__Date__c,Vendor__c=accPayableObj.AcctSeed__Vendor__c,ISBA_First_Payment__c=liTempObj.AcctSeed__Amount__c,RecordTypeId=UnallocatedLAERTID));
                      }else if(accPayableObj.Type__c=='Unallocated LAE Payment'){
                          claimDetailList.add(new Policy_Claim_Detail__c(Policy_Claim__c=accPayableObj.Claim__c,Type__c=accPayableObj.Type__c,Date__c=accPayableObj.AcctSeed__Date__c,Vendor__c=accPayableObj.AcctSeed__Vendor__c,LAE_Amount__c=liTempObj.AcctSeed__Amount__c,RecordTypeId=UnallocatedLAERTID));
                      }
                  }
              }
              
              insert lineItemListToInsert;
              
              if(claimDetailList.size()>0){
                  insert claimDetailList;
                  accPayableObj.Policy_Claim_Detail__c = claimDetailList[0].Id;
                  update accPayableObj;
              }
              AcctSeed.AccountPayablePostService.postAccountPayables(new AcctSeed__Account_Payable__c[]{accPayableObj}); 
          }
        //return new ApexPages.StandardController(accPayableObj).view();
          if(ApexPages.currentPage().getParameters().get('from')=='claimSearch'){
              return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));  
          }else{
              return new PageReference('/'+accPayableObj.Claim__c);              
          }
      }
        catch(DmlException e){
            system.Debug('***excep**'+e);
            error = e.getDmlMessage(0).replaceAll('\'','');
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,e.getDmlMessage(0)));
            Database.rollback(sp);
            system.Debug('**accPayableObj***'+accPayableObj);
            return null;
        }
        catch(Exception e){
            system.Debug('***excep**'+e);
            error = e.getMessage().replaceAll('\'','');
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,e.getMessage()));
            Database.rollback(sp);
            system.Debug('**accPayableObj***'+accPayableObj);
            return null;
        }
    }
    
    public pagereference onSaveNewClick(){
        checksaveNew = true;
        return onSaveClick();
    }
    
    public pagereference onUpdateClick(){
       //Savepoint sp = Database.setSavepoint();
      try{
         
        update accPayableObj; 
        return new ApexPages.StandardController(accPayableObj).view();
      }catch(Exception e){
          system.Debug('***excep**'+e);
          //Database.rollback(sp);
          system.Debug('**accPayableObj***'+accPayableObj);
        return null;
      }
    }
    
    //Wrapper Class to bind line items
    public class HIC_AccountPayableLineItemWrapper{
        public AcctSeed__Account_Payable_Line__c accPayabaleObj{get;set;}
        public HIC_AccountPayableLineItemWrapper(AcctSeed__Account_Payable_Line__c accPayabaleObj){
            this.accPayabaleObj = accPayabaleObj;
            this.accPayabaleObj.AcctSeed__Quantity__c =1;
            this.accPayabaleObj.AcctSeed__Amount__c =0.0;
            this.accPayabaleObj.AcctSeed__Date__c = date.today();
        }
    }
    
    @RemoteAction
    public static List<sObject> getLookupRecord(String likeString , String objectName) {
        if(String.IsNotBlank(likeString) && String.IsNotBlank(objectName)){
            likeString = likeString+'%';
            String query = '';
            // Query Update on 20 sept 2022
            List<String> AccountingTypeStatusList = new List<String>{'Vendor','Customer and Vendor'};
            query = 'SELECT Id, Name FROM '+objectName+' WHERE AcctSeed__Accounting_Type__c IN:AccountingTypeStatusList AND Name LIKE : likeString LIMIT 50';
            return database.query(query);
        }
        return null;
    }
}