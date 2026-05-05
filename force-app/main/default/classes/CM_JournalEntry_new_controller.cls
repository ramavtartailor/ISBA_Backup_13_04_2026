/*-*********************************************************************************************
* Name         : Hic_JournalEntry_new_controller
* @Author      : Sachin Arora(arora.s@head-in-cloud.com)
* @Date        : 09-Feb-2017
* @Description : This apex class does acts as a controller
                 for JournalEntry New Page 
* UPDATES
* Version          Developer                    Date                        Description
*------------------------------------------------------------------------------------------------
*     1.0          Sachin Arora                 09-Feb-2017                   Initial Creation 
**************************************************************************************************/

public class CM_JournalEntry_new_controller {
    
    public AcctSeed__Journal_Entry__c accSeedJournalEntryObj{get;set;}
    public string indexOfLineItemToBeRemoved{get;set;}
    
    public list<HIC_JournalEntryLineItemWrapper> journalEntryLineWrapList{get;set;}
    
    //Standard Controller Constructor
    public CM_JournalEntry_new_controller(ApexPages.StandardController stdController){
        accSeedJournalEntryObj = (AcctSeed__Journal_Entry__c)stdController.getRecord();
        init();
    }
    //initialize function
    public void init(){
        journalEntryLineWrapList = new list<HIC_JournalEntryLineItemWrapper>();
        journalEntryLineWrapList.add(new HIC_JournalEntryLineItemWrapper(new AcctSeed__Journal_Entry_Line__c()));
        
    }   
    
    //Method for removing line item row
     public void removeLineItemRow(){
      system.debug('---inside new row'+indexOfLineItemToBeRemoved);
     if(indexOfLineItemToBeRemoved != null){
        journalEntryLineWrapList.remove(integer.valueOf(indexOfLineItemToBeRemoved));
      }
    }
    
    //Method for adding new line item row
    public void addAccPayNewLine(){
        journalEntryLineWrapList.add(new HIC_JournalEntryLineItemWrapper(new AcctSeed__Journal_Entry_Line__c()));
    }
    
    //For inserting account payable and line items
    public pagereference onSaveClick(){
      try{
        insert accSeedJournalEntryObj; 
        list<AcctSeed__Journal_Entry_Line__c  > lineItemListToInsert = new list<AcctSeed__Journal_Entry_Line__c  >();
        for(HIC_JournalEntryLineItemWrapper wrapObj : journalEntryLineWrapList){
          AcctSeed__Journal_Entry_Line__c  liTempObj = new AcctSeed__Journal_Entry_Line__c  ();
            if(wrapObj.accSeedJournalLineObj!= null){
                liTempObj = wrapObj.accSeedJournalLineObj;
                liTempObj.AcctSeed__Journal_Entry__c= accSeedJournalEntryObj.Id;
            lineItemListToInsert.add(liTempObj);
            }
        }
        insert lineItemListToInsert;
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