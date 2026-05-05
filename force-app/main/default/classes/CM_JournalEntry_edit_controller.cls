/*-*********************************************************************************************
* Name         : Hic_JournalEntry_edit_controller
* @Author      : Sachin Arora(arora.s@head-in-cloud.com)
* @Date        : 09-Feb-2017
* @Description : This apex class does acts as a controller
                 for JournalEntry New Page 
* UPDATES
* Version          Developer                    Date                        Description
*------------------------------------------------------------------------------------------------
*     1.0          Sachin Arora                 09-Feb-2017                   Initial Creation 
**************************************************************************************************/

public class CM_JournalEntry_edit_controller {
    
    public AcctSeed__Journal_Entry__c accSeedJournalEntryObj{get;set;}
    public string indexOfLineItemToBeRemoved{get;set;}
    
    public list<HIC_JournalEntryLineItemWrapper> journalEntryLineWrapList{get;set;}
    
    //Standard Controller Constructor
    public CM_JournalEntry_edit_controller(ApexPages.StandardController stdController){
        accSeedJournalEntryObj = (AcctSeed__Journal_Entry__c)stdController.getRecord();
        init();
        showExistingJournalEntryLine();
    }
    //initialize function
    public void init(){ 
        journalEntryLineWrapList = new list<HIC_JournalEntryLineItemWrapper>();
        
    }   
    
    public void showExistingJournalEntryLine(){
        String journalLineId = apexpages.currentpage().getparameters().get('id');
        if(journalLineId!=null && journalLineId!=''){
            for(AcctSeed__Journal_Entry_Line__c journalLineObj :[Select Id,
                                                                         AcctSeed__GL_Account__c,
                                                                         AcctSeed__Credit__c,
                                                                         AcctSeed__Debit__c
                                                                         FROM AcctSeed__Journal_Entry_Line__c
                                                                         WHERE  AcctSeed__Journal_Entry__c=:journalLineId]){
                journalEntryLineWrapList.add(new HIC_JournalEntryLineItemWrapper(journalLineObj));
            }
        
        }               
               
    }
    
    //Method for removing line item row
     public void removeLineItemRow(){
      system.debug('---inside new row'+indexOfLineItemToBeRemoved);
     if(indexOfLineItemToBeRemoved != null  && null != journalEntryLineWrapList.get(integer.valueOf(indexOfLineItemToBeRemoved))){
        HIC_JournalEntryLineItemWrapper accWrapObj = journalEntryLineWrapList.get(integer.valueOf(indexOfLineItemToBeRemoved));
        if(accWrapObj.accSeedJournalLineObj!=null && null != accWrapObj.accSeedJournalLineObj.id){
                try{
                    delete accWrapObj.accSeedJournalLineObj;
                }   
                catch(Exception exp){
                    system.debug('**error in deleting**'+exp.getMessage());
                }
            }
        journalEntryLineWrapList.remove(integer.valueOf(indexOfLineItemToBeRemoved));
      }
    }
    
    //Method for adding new line item row
    public void addAccPayNewLine(){
        String journalLineId = apexpages.currentpage().getparameters().get('id');
        if(journalLineId!=null && journalLineId!=''){
            AcctSeed__Journal_Entry_Line__c journalLineObj = new AcctSeed__Journal_Entry_Line__c();
            journalLineObj.AcctSeed__Journal_Entry__c = journalLineId;
            journalEntryLineWrapList.add(new HIC_JournalEntryLineItemWrapper(journalLineObj));
        }
        
    }
    
    //For inserting account payable and line items
    public pagereference onSaveClick(){
      try{
        update accSeedJournalEntryObj; 
        if(!journalEntryLineWrapList.isEmpty()){
                list<AcctSeed__Journal_Entry_Line__c> payLineListToUpsert = new list<AcctSeed__Journal_Entry_Line__c>();
                for(HIC_JournalEntryLineItemWrapper wrapObj : journalEntryLineWrapList ){
                    AcctSeed__Journal_Entry_Line__c accLineObj =  wrapObj.accSeedJournalLineObj;
                    
                    payLineListToUpsert.add(accLineObj);
                }
                if(!payLineListToUpsert.isEmpty()){
                    upsert payLineListToUpsert;
                }
            }
        return new ApexPages.StandardController(accSeedJournalEntryObj).view();
      }catch(Exception e){
        return null;
      }
    }
    //For updating account payable and line items
    public pagereference onUpdateClick(){
      try{
        update accSeedJournalEntryObj; 
        return new ApexPages.StandardController(accSeedJournalEntryObj).view();
      }catch(Exception e){
        return null;
      }
    }
    
    //Wrapper Class to bind line items
    public class HIC_JournalEntryLineItemWrapper{
        public AcctSeed__Journal_Entry_Line__c  accSeedJournalLineObj{get;set;}
        public HIC_JournalEntryLineItemWrapper(AcctSeed__Journal_Entry_Line__c accSeedJournalLineObj){
            this.accSeedJournalLineObj = accSeedJournalLineObj;
            this.accSeedJournalLineObj.AcctSeed__Units__c =1;
            this.accSeedJournalLineObj.AcctSeed__Date__c = date.today();
        }
    }
}