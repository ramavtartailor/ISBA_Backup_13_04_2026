/*************************************************************
    @Company        : HIC Global Solutions
    @Author         : Sachin Arora(arora.s@head-in-cloud.com)
    @Created Date   : 02/22/2017
    @Desciption     :   This class acts as a controller for 
                        AccountPayable Edit Page.
    @TestClass Name : 
    Version          Developer                    Date                        Description
*-------------------------------------------------------------------------------------------
*     1.0            sachin                       21-Feb-2017                   Initial Creation 
***************************************************************************************************/

public class CM_AccountPayable_edit_controller {

    public AcctSeed__Account_Payable__c accPayableObj{get;set;}
    public Account accountObj{get;set;}
    public Policy_Claim__c claimObj{get;set;}
    public Policy__c policyObj{get;set;}
    public string indexOfLineItemToBeRemoved {get; set;}
    public String selectedAppPolicy{get;set;}
    public String selectedPolicyClaimId{get;set;}
    public String selectedVendorId{get;set;}
    public list<HIC_AccountPayableLineItemWrapper> accPayLineWrapList{get;set;}
    
    public list<SelectOption> ClaimOptions{get;set;}    
    
    
    //Standard Controller Constructor
    public CM_AccountPayable_edit_controller(ApexPages.StandardController stdController){
    
        claimObj = new Policy_Claim__c();
        policyObj = new Policy__c();
        accPayableObj = (AcctSeed__Account_Payable__c)stdController.getRecord();
        onVendorSelect();
        selectedAppPolicy = accPayableObj.Policy__c;
        onPolicyOptionChange();
        selectedPolicyClaimId = accPayableObj.Claim__c;
        onClaimOptionChange();
        system.debug('***selectedPolicyClaimId---'+selectedPolicyClaimId);
        init();
    }
    
    //initialize function
    public void init(){
        accPayLineWrapList = new list<HIC_AccountPayableLineItemWrapper>();
        showExistingAccPaayableLine();
    }
    
    public void showExistingAccPaayableLine(){
        String accPyableId = apexpages.currentpage().getparameters().get('id');
        if(accPyableId!=null && accPyableId!=''){
            for(AcctSeed__Account_Payable_Line__c accPayLineObj :[Select Id,
                                                                         AcctSeed__Expense_GL_Account__c,
                                                                         AcctSeed__Amount__c                                                                         
                                                                         FROM AcctSeed__Account_Payable_Line__c
                                                                         WHERE AcctSeed__Account_Payable__c=:accPyableId]){
                accPayLineWrapList.add(new HIC_AccountPayableLineItemWrapper(accPayLineObj));
            }
        
        }               
               
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
            } else {
                
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
         
         List<Policy__c> policyList = [SELECT Id,Name FROM Policy__c WHERE Id =: selectedAppPolicy LIMIT 1];
         
         if(!policyList.isEmpty()){
             policyObj = policyList.get(0);
         }
          
         
     }   
     
     //system.debug('***selectedPolicyClaimId---'+selectedPolicyClaimId);
     
    //Method on change of claim select option
    public void onClaimOptionChange(){
    system.debug('***selectedPolicyClaimId---'+selectedPolicyClaimId);
        if(selectedPolicyClaimId!=null && selectedPolicyClaimId!=''){
            list<Policy_Claim__c> policyClaimList = new list<Policy_Claim__c>([Select Id,
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
                                                                                      Name
                                                                                      FROM Policy_Claim__c
                                                                                      WHERE Id =: selectedPolicyClaimId]);
            if(!policyClaimList.isEmpty()){
                claimObj = policyClaimList.get(0);
            }                                                                                      
        }
        else{
             claimObj = new Policy_Claim__c();
        }
    
    }
    
    
    // For Updating account Payable
    public pagereference onUpdateClick(){
       //Savepoint sp = Database.setSavepoint();
      try{
         accPayableObj.Policy__c = selectedAppPolicy;
         accPayableObj.Claim__c = selectedPolicyClaimId;
        update accPayableObj; 
            if(!accPayLineWrapList.isEmpty()){
                list<AcctSeed__Account_Payable_Line__c> payLineListToUpsert = new list<AcctSeed__Account_Payable_Line__c>();
                for(HIC_AccountPayableLineItemWrapper wrapObj : accPayLineWrapList ){
                    AcctSeed__Account_Payable_Line__c accLineObj =  wrapObj.accPayabaleObj;
                    
                    payLineListToUpsert.add(accLineObj);
                }
                if(!payLineListToUpsert.isEmpty()){
                    upsert payLineListToUpsert;
                }
            }
        return new ApexPages.StandardController(accPayableObj).view();
      }catch(Exception e){
          system.Debug('***excep**'+e);
          //Database.rollback(sp);
          system.Debug('**accPayableObj***'+accPayableObj);
        return null;
      }
    }
    
    //Method for removing line item row
     public void removeLineItemRow(){
      system.debug('---inside new row'+indexOfLineItemToBeRemoved);
     if(indexOfLineItemToBeRemoved != null && null != accPayLineWrapList.get(integer.valueOf(indexOfLineItemToBeRemoved))){
        HIC_AccountPayableLineItemWrapper accWrapObj = accPayLineWrapList.get(integer.valueOf(indexOfLineItemToBeRemoved));
            if(accWrapObj.accPayabaleObj!=null && null != accWrapObj.accPayabaleObj.id){
                try{
                    delete accWrapObj.accPayabaleObj;
                }   
                catch(Exception exp){
                    system.debug('**error in deleting**'+exp.getMessage());
                }
            }
        accPayLineWrapList.remove(integer.valueOf(indexOfLineItemToBeRemoved));
      }
    }
    
    //Method for adding new line item row
    public void addAccPayNewLine(){
        String accPyableId = apexpages.currentpage().getparameters().get('id');
        if(accPyableId!=null && accPyableId!=''){
            AcctSeed__Account_Payable_Line__c accLineObj = new AcctSeed__Account_Payable_Line__c();
            accLineObj.AcctSeed__Quantity__c =1;
            accLineObj.AcctSeed__Amount__c =0.0;
            accLineObj.AcctSeed__Account_Payable__c = accPyableId;
            accLineObj.AcctSeed__Date__c = date.today();
            accPayLineWrapList.add(new HIC_AccountPayableLineItemWrapper(accLineObj));
        }
    }
    
    
     
    //Wrapper Class to bind line items
    public class HIC_AccountPayableLineItemWrapper{
        public AcctSeed__Account_Payable_Line__c accPayabaleObj{get;set;}
        public HIC_AccountPayableLineItemWrapper(AcctSeed__Account_Payable_Line__c accPayabaleObj){
            this.accPayabaleObj = accPayabaleObj;
        }
    }
}