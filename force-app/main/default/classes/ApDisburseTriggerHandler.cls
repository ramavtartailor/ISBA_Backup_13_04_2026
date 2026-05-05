/*    
    Name : ApDisburseTriggerHandler
    Author : Shweta Fulara
    Date : 28th June 2017
    Description : Handler class for AP_DisbursementTrigger .
*/
public class ApDisburseTriggerHandler{
    /*
    public static void reverseJournalEntries(List<AcctSeed__AP_Disbursement__c> apDisburseList){
        
        Set<Id> claimIds = new Set<Id>();
        
        Map<Id, Integer> claimAmountMap = new Map<Id, Integer>();
        
        Map<Id, AcctSeed__AP_Disbursement__c> apDisbursementMap = new Map<Id, AcctSeed__AP_Disbursement__c>([SELECT Id, AcctSeed__Cash_Disbursement__r.AcctSeed__Amount__c, AcctSeed__Account_Payable__r.Claim__c,
                                                                AcctSeed__Cash_Disbursement__r.AcctSeed__Payment_Status__c
                                                                FROM AcctSeed__AP_Disbursement__c WHERE Id IN: apDisburseList
                                                                AND AcctSeed__Cash_Disbursement__r.AcctSeed__Payment_Status__c = 'Paid']);
                                                                
        System.debug('apDisbursementMap----'+apDisbursementMap);
        
        for(AcctSeed__AP_Disbursement__c apDisburse: apDisbursementMap.values()){
            
            claimIds.add(apDisburse.AcctSeed__Account_Payable__r.Claim__c);

        }
        
        
        System.debug('claimIds----'+claimIds);
        
        Map<Id, AcctSeed__Journal_Entry__c> journalEntriesMap = new Map<Id, AcctSeed__Journal_Entry__c>([SELECT Id, Name, Firm__c, 
                                                Claim__c, Policy__c, Policy_Claim_Detail__c
                                                FROM AcctSeed__Journal_Entry__c 
                                                WHERE Claim__c IN: claimIds AND AS_Transaction__r.Transaction_Sub_Type__c = 'Open Reserve Loss']);
    
        
        System.debug('journalEntriesMap ----'+journalEntriesMap);
        
        Map<Id, List<AcctSeed__Journal_Entry_Line__c>> journalEntryLinesMap = new Map<Id, List<AcctSeed__Journal_Entry_Line__c>>();
        List<AcctSeed__Journal_Entry_Line__c> jeLineList = [SELECT Id, Name, AcctSeed__Debit__c, AcctSeed__Credit__c, AcctSeed__Date__c, AcctSeed__Units__c,
                                                        AcctSeed__Journal_Entry__c, AcctSeed__Journal_Entry__r.Claim__c, AcctSeed__GL_Account__c 
                                                        FROM AcctSeed__Journal_Entry_Line__c
                                                        WHERE AcctSeed__Journal_Entry__c IN: journalEntriesMap.keySet()];
        
        System.debug('jeLineList----'+jeLineList);
        
        for(AcctSeed__Journal_Entry_Line__c jeLine: jeLineList){
            for(Id apDisburse: apDisbursementMap.keySet()){
                System.debug('jeLine.AcctSeed__Journal_Entry__r.Claim__c----'+jeLine.AcctSeed__Journal_Entry__r.Claim__c);
                if(jeLine.AcctSeed__Journal_Entry__r.Claim__c == apDisbursementMap.get(apDisburse).AcctSeed__Account_Payable__r.Claim__c){
                    System.debug('jeLine----'+jeLine);
                    AcctSeed__Journal_Entry_Line__c jeLineNew = jeLine.clone(false,true,false,false);
                    jeLineNew.AcctSeed__Debit__c = null;
                    jeLineNew.AcctSeed__Credit__c = null;
                    
                    if(jeLine.AcctSeed__Credit__c != null){
                        jeLineNew.AcctSeed__Debit__c = apDisbursementMap.get(apDisburse).AcctSeed__Cash_Disbursement__r.AcctSeed__Amount__c;
                    }
                    if(jeLine.AcctSeed__Debit__c != null){                    
                        jeLineNew.AcctSeed__Credit__c = apDisbursementMap.get(apDisburse).AcctSeed__Cash_Disbursement__r.AcctSeed__Amount__c;
                    }    
                                                            
                    if(journalEntryLinesMap.containsKey(jeLine.AcctSeed__Journal_Entry__c)){
                    
                        journalEntryLinesMap.get(jeLine.AcctSeed__Journal_Entry__c).add(jeLineNew);
                    }
                    else{
                        journalEntryLinesMap.put(jeLine.AcctSeed__Journal_Entry__c, new List<AcctSeed__Journal_Entry_Line__c>{jeLineNew});
                    } 
                }
            }
                                                
        }
        System.debug('journalEntryLinesMap----'+journalEntryLinesMap);
        
        Map<Integer, AcctSeed__Journal_Entry__c> jeMap = new Map<Integer, AcctSeed__Journal_Entry__c>();
        
        Map<Integer, List<AcctSeed__Journal_Entry_Line__c>> jeLineMap = new Map<Integer, List<AcctSeed__Journal_Entry_Line__c>>();
        
        Integer i = 0;
        for(Id jeId : journalEntriesMap.keySet()){
        
            jeMap.put(i, journalEntriesMap.get(jeId).clone(false,true,false,false));
            
            jeLineMap.put(i, journalEntryLinesMap.get(jeId));
            
            i++;
        }
        
        System.debug('jeLineMap----'+jeLineMap);
        
        
        if(!jeMap.isEmpty()){
            Savepoint sp = Database.setSavepoint();
            try {
                
                    insert jeMap.values();
                    System.debug('jeMap----'+jeMap);
        
        
                    List<AcctSeed__Journal_Entry_Line__c> jEntryLines = new List<AcctSeed__Journal_Entry_Line__c>();
                    
                    for (Integer jeId: jeLineMap.keySet()) {
                        for (AcctSeed__Journal_Entry_Line__c jeLine: jeLineMap.get(jeId)) {
                            
                            jeLine.AcctSeed__Journal_Entry__c = jeMap.get(jeId).Id;
                            
                            jEntryLines.add(jeLine);
                        }
                    }
                    System.debug('jEntryLines----'+jEntryLines);
        
                    if (jEntryLines.size() > 0) {
                        insert jEntryLines;
                        System.debug('jEntryLines----'+jEntryLines);
        
                    }
                
            } catch (Exception e) {
                Database.rollBack(sp);                
                System.debug(e.getMessage());
                throw(e);
            }
        }
        
    }
    */
    public static void beforeinsertUpdateClaim(List<AcctSeed__AP_Disbursement__c> apDisburseList){
            
        Set<Id> payableId = new Set<Id>();
        
        for(AcctSeed__AP_Disbursement__c ap: apDisburseList){
        
            payableId.add(ap.AcctSeed__Account_Payable__c);    
        
        }
        
        Map<Id,AcctSeed__Account_Payable__c> payableMap = new Map<Id,AcctSeed__Account_Payable__c>([SELECT Id,Name,Claim__c,Policy__c,Firm__c
                                                                FROM AcctSeed__Account_Payable__c WHERE Id IN: payableId 
                                                                AND (Claim__c != null OR Policy__c != null OR Firm__c != null)]);
        
        List<AcctSeed__Cash_Disbursement__c> cdToUpdate = new List<AcctSeed__Cash_Disbursement__c>();
        
        for(AcctSeed__AP_Disbursement__c ap: apDisburseList){
            if(payableMap != null){
                if(payableMap.containsKey(ap.AcctSeed__Account_Payable__c)){
                    //if(payableMap.get(ap.AcctSeed__Account_Payable__c).Claim__c != null){
                        ap.Claim__c = payableMap.get(ap.AcctSeed__Account_Payable__c).Claim__c; 
                       
                        //AcctSeed__Cash_Disbursement__c cashDisburse = new AcctSeed__Cash_Disbursement__c();
                        //cashDisburse.Id = ap.AcctSeed__Cash_Disbursement__c;
                        //cashDisburse.Claim__c = payableMap.get(ap.AcctSeed__Account_Payable__c).Claim__c;  
                        //cashDisburse.Policy__c = payableMap.get(ap.AcctSeed__Account_Payable__c).Policy__c;     
                        //cashDisburse.Firm__c = payableMap.get(ap.AcctSeed__Account_Payable__c).Firm__c;   
                        
                        //cdToUpdate.add(cashDisburse);               
                    //} 
                }  
            }        
        } 
        
        /*if(!cdToUpdate.isEmpty()){
            update cdToUpdate;
        }*/         
    }
    
    
    
}