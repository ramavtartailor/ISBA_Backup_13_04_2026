public class Batch_CededTransactionCorrection  implements Database.Batchable<Sobject>, Database.Stateful{
    public Set<Id> recordIds;
    public String objectName;
    Map<Id,Treaty_Versions__c> treatyVersionsToUpdate;
    Set<Id> errorTreatyVersions;
    public Batch_CededTransactionCorrection(Set<Id> policyIds,String objectName){
        this.objectName = objectName;
        this.recordIds = policyIds;
        treatyVersionsToUpdate = new Map<Id,Treaty_Versions__c>();
        errorTreatyVersions = new Set<Id>();
    }
	public Database.QueryLocator start(Database.BatchableContext BC) {
        Date boundDate = Date.valueOf(System.Label.CededTransactionBoundEndDate);
        if(objectName == 'Policy'){
            return Database.getQueryLocator([select id,GL_Processing_Date__c,Effective_Date__c,Account__c,Original_Primary__c ,Original_Excess__c,Treaty_Version__r.Ceded_Primary_Rate_Delta__c,Treaty_Version__r.Ceded_4x1_Rate_Delta__c,Treaty_Version__c,Account__r.Name,Expiration_Date__c,(select id,Primary__c,Excess__c,Endorsement_Effective_Date__c,GL_Processing_Date__c from Policy_Endorsements__r where Endorsement_Number__c = 'IL 107'),(select id, AcctSeed__Date__c  from Billings__r where AcctSeed__Type__c = 'Invoice' and Claim__c = null and Policy_Endorsement__c = null and AS_Transaction_Description__c = 'Issue Policy-Premium' ) from Policy__c where id in: recordIds and Treaty_Version__r.Treaty_Correction_Processed__c = false and Accounting_Processed__c = true and RecordType.Name = 'Policy' and Cancel_Date__c = null and Treaty_Correction_Processed__c = false ]);
        }else{
            return Database.getQueryLocator([select id,GL_Processing_Date__c,Effective_Date__c,Account__c,Original_Primary__c ,Original_Excess__c,Treaty_Version__r.Ceded_Primary_Rate_Delta__c,Treaty_Version__r.Ceded_4x1_Rate_Delta__c,Treaty_Version__c,Account__r.Name,Expiration_Date__c,(select id,Primary__c,Excess__c,Endorsement_Effective_Date__c,GL_Processing_Date__c from Policy_Endorsements__r where Endorsement_Number__c = 'IL 107'),(select id, AcctSeed__Date__c  from Billings__r where AcctSeed__Type__c = 'Invoice' and Claim__c = null and Policy_Endorsement__c = null and  AS_Transaction_Description__c = 'Issue Policy-Premium') from Policy__c where id in: recordIds and Treaty_Version__r.Treaty_Correction_Processed__c = false and Accounting_Processed__c = true and RecordType.Name = 'Policy' and Cancel_Date__c = null and Treaty_Correction_Processed__c = false ]);
        }
    }
    public void execute(Database.BatchableContext BC, List<Policy__c> batch) {
        SavePoint sp = Database.setSavepoint();
        Map<Id,Treaty_Versions__c > tempTreatyVersion = new Map<Id,Treaty_Versions__c >();
        try{
            list<AcctSeed__Scheduled_Revenue_Expense__c> Schedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
            Map<Id,list<AcctSeed__Journal_Entry_Line__c>> jeLinesMap = new Map<Id,list<AcctSeed__Journal_Entry_Line__c>>();
            Map<Id,AcctSeed__Journal_Entry__c> jeMap = new Map<Id,AcctSeed__Journal_Entry__c>();
            
            Map<string,Transaction_Credit_And_Debits__c> transactionCustomSettingMap = Transaction_Credit_And_Debits__c.getAll();
            set<string> setofAllGlNames = new set<string>();
            
            for(Transaction_Credit_And_Debits__c t : transactionCustomSettingMap.values()){
                setofAllGlNames.add(t.Credit_GL__c);
                setofAllGlNames.add(t.Debit_GL__c);
            }
            
            map<string, AcctSeed__GL_Account__c> mapOfGlAccounts = new map<string, AcctSeed__GL_Account__c>();
            
            for(AcctSeed__GL_Account__c a : [select id, name from AcctSeed__GL_Account__c where name IN:setofAllGlNames]){
                mapOfGlAccounts.put(a.name, a);
            }
            
            map<string,AcctSeed__Accounting_Period__c> mapAccountingPeriod = new map<string,AcctSeed__Accounting_Period__c>();
            
            list<AcctSeed__Accounting_Period__c> lstAccPeriod = new list<AcctSeed__Accounting_Period__c>([SELECT id,Name,
                                                                                                          AcctSeed__Start_Date__c,AcctSeed__End_Date__c,
                                                                                                          AcctSeed__Status__c
                                                                                                          FROM 
                                                                                                          AcctSeed__Accounting_Period__c
                                                                                                          WHERE 
                                                                                                          AcctSeed__Status__c = 'Open']);
            
            for(AcctSeed__Accounting_Period__c acPeriod : lstAccPeriod)
            {
                string key = 'key'+acPeriod.AcctSeed__Start_Date__c.month()+'year'+acPeriod.AcctSeed__Start_Date__c.year();
                mapAccountingPeriod.put(key, acPeriod);
            }
            
            for(Policy__c pol : batch){
                pol.Treaty_Correction_Processed__c = true;
                if(!treatyVersionsToUpdate.containsKey(pol.Treaty_Version__c)){
                    treatyVersionsToUpdate.put(pol.Treaty_Version__c,new Treaty_Versions__c(Id = pol.Treaty_Version__c,Treaty_Correction_Processed__c = true));
                }
                Date transactionDate = pol.GL_Processing_Date__c != null ? pol.GL_Processing_Date__c :  (pol.Billings__r != null ? pol.Billings__r[0].AcctSeed__Date__c  : pol.Effective_Date__c);
                    
                AcctSeed__Journal_Entry__c je = new AcctSeed__Journal_Entry__c();
                je.AcctSeed__Journal_Date__c = transactionDate;
                string acKey1 = 'key'+transactionDate.month()+'year'+transactionDate.year();
                if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey1)){
                    je.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey1).Id;
                }    
                je.Firm__c = pol.Account__c;
                je.Policy__c = pol.Id;
                je.Name = 'Ceded Correction';
                
                jeMap.put(pol.Id,je);
                
                list<AcctSeed__Journal_Entry_Line__c> journalLineItemList = new list<AcctSeed__Journal_Entry_Line__c>();
                
                if(pol.Treaty_Version__r.Ceded_Primary_Rate_Delta__c != 0){
                    journalLineItemList.add(Batch_CededTransactionCorrection.journalLineItem(transactionDate, pol.Account__c , 'Debit' , mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Primary').debit_GL__c).Id,(pol.Original_Primary__c *pol.Treaty_Version__r.Ceded_Primary_Rate_Delta__c )/100,'Treaty Delta Correction - Policy'));
                    journalLineItemList.add(Batch_CededTransactionCorrection.journalLineItem(transactionDate, pol.Account__c , 'Credit' , mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Primary').credit_GL__c).Id,(pol.Original_Primary__c *pol.Treaty_Version__r.Ceded_Primary_Rate_Delta__c )/100,'Treaty Delta Correction - Policy'));
                    
                    Schedules.add(scheduleForFullAmount(transactionDate, pol.Account__c, pol.Id, pol.Account__r.Name , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Primary Amortize').credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Primary Amortize').debit_GL__c).Id,(pol.Original_Primary__c*pol.Treaty_Version__r.Ceded_Primary_Rate_Delta__c )/100,'Treaty Delta Correction - Policy'));
                    
                    Schedules.addAll(createRevenueSchedules(pol , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Primary Amortize').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Primary Amortize').credit_GL__c).Id,(pol.Original_Primary__c*pol.Treaty_Version__r.Ceded_Primary_Rate_Delta__c )/100,'Treaty Delta Correction - Policy'));
                }
                
                if(pol.Treaty_Version__r.Ceded_4x1_Rate_Delta__c != 0){
                    journalLineItemList.add(Batch_CededTransactionCorrection.journalLineItem(transactionDate, pol.Account__c , 'Debit' , mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded 4x1').debit_GL__c).Id,(pol.Original_Primary__c +(pol.Original_Excess__c !=null ? pol.Original_Excess__c : 0)*pol.Treaty_Version__r.Ceded_4x1_Rate_Delta__c )/100,'Treaty Delta Correction - Policy'));
                    journalLineItemList.add(Batch_CededTransactionCorrection.journalLineItem(transactionDate, pol.Account__c , 'Credit' , mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded 4x1').credit_GL__c).Id,(pol.Original_Primary__c +(pol.Original_Excess__c !=null ? pol.Original_Excess__c : 0 )*pol.Treaty_Version__r.Ceded_4x1_Rate_Delta__c )/100,'Treaty Delta Correction - Policy'));
                    
                    Schedules.add(scheduleForFullAmount(transactionDate, pol.Account__c, pol.Id, pol.Account__r.Name , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded 4x1 Amortize').Credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded 4x1 Amortize').debit_GL__c).Id,(pol.Original_Primary__c +(pol.Original_Excess__c !=null ? pol.Original_Excess__c : 0)*pol.Treaty_Version__r.Ceded_4x1_Rate_Delta__c )/100,'Treaty Delta Correction - Policy'));
                    
                    Schedules.addAll(createRevenueSchedules(pol , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded 4x1 Amortize').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded 4x1 Amortize').Credit_GL__c).Id,(pol.Original_Primary__c +(pol.Original_Excess__c !=null ? pol.Original_Excess__c : 0)*pol.Treaty_Version__r.Ceded_4x1_Rate_Delta__c )/100,'Treaty Delta Correction - Policy'));
                }
                
                jeLinesMap.put(pol.Id,journalLineItemList);
                
                if(pol.Policy_Endorsements__r !=null && pol.Policy_Endorsements__r.size()>0){
                    Map<Id,AcctSeed__Billing__c> billingMap = new Map<Id,AcctSeed__Billing__c>();
                    for(AcctSeed__Billing__c bill : [select id,AcctSeed__Date__c,Policy_Endorsement__c from AcctSeed__Billing__c where Policy_Endorsement__c in: pol.Policy_Endorsements__r]){
                        billingMap.put(bill.Policy_Endorsement__c,bill);
                    }
                    for(Policy_Endorsement__c polEnd : pol.Policy_Endorsements__r){
                        transactionDate = polEnd.GL_Processing_Date__c != null ? polEnd.GL_Processing_Date__c :  (billingMap.containsKey(polEnd.Id) ? billingMap.get(polEnd.Id).AcctSeed__Date__c : polEnd.Endorsement_Effective_Date__c); 
                        je = new AcctSeed__Journal_Entry__c();
                        je.AcctSeed__Journal_Date__c = transactionDate;
                        acKey1 = 'key'+transactionDate.month()+'year'+transactionDate.year();
                        if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey1)){
                            je.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey1).Id;
                        }    
                        je.Firm__c = pol.Account__c;
                        je.Policy__c = pol.Id;
                        je.Policy_Endorsement__c = polEnd.Id;
                        je.Name = 'Ceded Correction';
                        
                        jeMap.put(polEnd.Id,je);
                        
                        journalLineItemList = new list<AcctSeed__Journal_Entry_Line__c>();
                        
                        if(pol.Treaty_Version__r.Ceded_Primary_Rate_Delta__c != 0){
                            journalLineItemList.add(Batch_CededTransactionCorrection.journalLineItem(transactionDate, pol.Account__c , 'Debit' , mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Primary').debit_GL__c).Id,(polEnd.Primary__c *pol.Treaty_Version__r.Ceded_Primary_Rate_Delta__c )/100,'Treaty Delta Correction - Endorsement'));
                            journalLineItemList.add(Batch_CededTransactionCorrection.journalLineItem(transactionDate, pol.Account__c , 'Credit' , mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Primary').credit_GL__c).Id,(polEnd.Primary__c *pol.Treaty_Version__r.Ceded_Primary_Rate_Delta__c )/100,'Treaty Delta Correction - Endorsement'));
                        }
                        
                        if(pol.Treaty_Version__r.Ceded_4x1_Rate_Delta__c != 0){
                            journalLineItemList.add(Batch_CededTransactionCorrection.journalLineItem(transactionDate, pol.Account__c , 'Debit' , mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded 4x1').debit_GL__c).Id,(polEnd.Primary__c +   (polEnd.Excess__c !=null ? polEnd.Excess__c : 0)*pol.Treaty_Version__r.Ceded_4x1_Rate_Delta__c )/100,'Treaty Delta Correction - Endorsement'));
                            journalLineItemList.add(Batch_CededTransactionCorrection.journalLineItem(transactionDate, pol.Account__c , 'Credit' , mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded 4x1').credit_GL__c).Id,(polEnd.Primary__c +(polEnd.Excess__c !=null ? polEnd.Excess__c : 0)*pol.Treaty_Version__r.Ceded_4x1_Rate_Delta__c )/100,'Treaty Delta Correction - Endorsement'));
                        }
                        
                        jeLinesMap.put(polEnd.Id,journalLineItemList);
                        
                    }
                }
            }
            
            insert jeMap.values();
            
            list<AcctSeed__Journal_Entry_Line__c> journalLineItemListToInsert = new list<AcctSeed__Journal_Entry_Line__c>();
            
            for(Policy__c pol : batch){
                if(jeLinesMap.containsKey(pol.Id)){
                    for(AcctSeed__Journal_Entry_Line__c li : jeLinesMap.get(pol.Id)){
                        if(jeMap != null && jeMap.containsKey(pol.Id)){
                            li.AcctSeed__Journal_Entry__c = jeMap.get(pol.Id).Id;
                            journalLineItemListToInsert.add(li);
                        }
                        
                    }
                }
            }
            
            insert journalLineItemListToInsert;
            
            AcctSeed.PostResult[] postResults = AcctSeed.JournalEntryPostService.postJournalEntries(jeMap.values());
            
            insert Schedules;
            
            update batch;
            
        }catch(Exception e){
            System.debug(e.getMessage() + e.getLineNumber() + e.getStackTraceString());
            System.debug(e.getStackTraceString());
            Database.rollback(sp);
            errorTreatyVersions.addAll(tempTreatyVersion.keySet());
        }
        
    }
    public void finish(Database.BatchableContext BC) { 
        for(Id ids : errorTreatyVersions){
            if(treatyVersionsToUpdate.containsKey(ids)){
                treatyVersionsToUpdate.remove(ids);
            }
        }
        if(treatyVersionsToUpdate.size() > 0){
            update treatyVersionsToUpdate.values();
        }
    }
    
    public static AcctSeed__Journal_Entry_Line__c journalLineItem(Date transactionDate, Id accountId , String operationType, String glAccount,Decimal amount,String description){
        
        //-----creating debit journal line item
        AcctSeed__Journal_Entry_Line__c line = new AcctSeed__Journal_Entry_Line__c();
        line.AcctSeed__Account__c = accountId;
        line.AcctSeed__Units__c = 1;
        line.AcctSeed__Date__c = transactionDate;
        if((operationType == 'Debit' && amount >0) || (operationType == 'Credit' && amount < 0)){
            line.AcctSeed__GL_Account__c = glAccount;
            line.AcctSeed__Debit__c = Math.abs(amount);
        }else if((operationType == 'Credit' && amount >0) || (operationType == 'Debit' && amount < 0)){
            line.AcctSeed__GL_Account__c = glAccount;
            line.AcctSeed__Credit__c = Math.abs(amount);
        }
        line.AcctSeed__Description__c = description;
        return line;
    }
    
    public static AcctSeed__Scheduled_Revenue_Expense__c scheduleForFullAmount(Date transactionDate, Id accountId, Id policyId, String firmName, map<string,AcctSeed__Accounting_Period__c> mapAccountingPeriod, string GLCredit, string GLDebit,Decimal amount,String description){
        
        
        AcctSeed__Scheduled_Revenue_Expense__c RevenueSchedule = new AcctSeed__Scheduled_Revenue_Expense__c();
        string acKey1 = 'key'+transactionDate.month()+'year'+transactionDate.year();
        if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey1)){
            RevenueSchedule.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey1).Id;
        }
        RevenueSchedule.AcctSeed__Account2__c = accountId;
        
        if(amount < 0){
            RevenueSchedule.AcctSeed__Amount__c = -(amount);
            RevenueSchedule.AcctSeed__Credit_GL_Account__c = GLDebit;
            RevenueSchedule.AcctSeed__Debit_GL_Account__c = GLCredit;
        }else{
            RevenueSchedule.AcctSeed__Amount__c = amount;
            RevenueSchedule.AcctSeed__Credit_GL_Account__c = GLCredit;
            RevenueSchedule.AcctSeed__Debit_GL_Account__c = GLDebit;
        }
        
        RevenueSchedule.AcctSeed__Quantity__c = 1;
        
        RevenueSchedule.Policy__c = policyId;
        RevenueSchedule.Name = firmName.subString(0,(firmName.length() > 70 ? 70 : firmName.length() )) + '-' + date.valueof(System.now()).year() + '/' + date.valueOf(System.now()).month();
        RevenueSchedule.Date__c = transactionDate;
        RevenueSchedule.AcctSeed__Description__c = description;
        return RevenueSchedule;
    }
    
    public static list<AcctSeed__Scheduled_Revenue_Expense__c> createRevenueSchedules(Policy__c pol, map<string,AcctSeed__Accounting_Period__c> mapAccountingPeriod, string GLCredit, string GLDebit,Decimal amount,String description){
        try{
            
            list<AcctSeed__Scheduled_Revenue_Expense__c> listOfAllSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
	
            if(amount < 0){
                amount *= -1;
                String temp = GLDebit;
                GLDebit = GLCredit;
                GLCredit = temp;
            }
            Integer totalDays = pol.Effective_Date__c.daysBetween(pol.Expiration_Date__c);
            Date scheduleDate = pol.Effective_Date__c;
            Date transactionStartDate = pol.GL_Processing_Date__c != null ? pol.GL_Processing_Date__c :  (pol.Billings__r != null ? pol.Billings__r[0].AcctSeed__Date__c  : pol.Effective_Date__c);

            transactionStartDate = transactionStartDate.toStartOfMonth().addMonths(1).addDays(-1);
            Date transactionEndDate = pol.Expiration_Date__c.addDays(-1).toStartOfMonth().addDays(-1);
            
            
            
            
            Decimal oneDayAmount = amount/totalDays;
            oneDayAmount = oneDayAmount.setscale(2,RoundingMode.FLOOR);
            Decimal temp = amount;
            while(transactionStartDate <= transactionEndDate){
                AcctSeed__Scheduled_Revenue_Expense__c RevenueSchedule = new AcctSeed__Scheduled_Revenue_Expense__c();
                RevenueSchedule.AcctSeed__Amount__c = oneDayAmount * (scheduleDate.daysBetween(transactionStartDate) + 1);
                
                temp -= RevenueSchedule.AcctSeed__Amount__c;
                
                RevenueSchedule.AcctSeed__Quantity__c = 1;
                
                RevenueSchedule.AcctSeed__Credit_GL_Account__c = GLCredit;
                RevenueSchedule.AcctSeed__Debit_GL_Account__c = GLDebit;
                RevenueSchedule.Name = pol.Account__r.Name.subString(0,(pol.Account__r.Name.length() > 70 ? 70 : pol.Account__r.Name.length() )) + '-' + transactionStartDate.year() + '/' + transactionStartDate.month();
                
                string acKey1 = 'key'+transactionStartDate.month()+'year'+transactionStartDate.year();
                if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey1)){
                    RevenueSchedule.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey1).Id;
                }
                RevenueSchedule.AcctSeed__Account2__c = pol.Account__c;
                RevenueSchedule.Policy__c = pol.Id;
                RevenueSchedule.Date__c = transactionStartDate;
                RevenueSchedule.AcctSeed__Description__c = description;
                listOfAllSchedules.add(RevenueSchedule);
                scheduleDate = transactionStartDate.addDays(1);
                transactionStartDate = transactionStartDate.toStartOfMonth().addMonths(2).addDays(-1);
            }
            
            if(pol.Expiration_Date__c.addDays(-1) >= scheduleDate){
                AcctSeed__Scheduled_Revenue_Expense__c RevenueSchedule = new AcctSeed__Scheduled_Revenue_Expense__c();
                RevenueSchedule.AcctSeed__Amount__c = temp;
                
                RevenueSchedule.AcctSeed__Quantity__c = 1;
                
                RevenueSchedule.AcctSeed__Credit_GL_Account__c = GLCredit;
                RevenueSchedule.AcctSeed__Debit_GL_Account__c = GLDebit;
                RevenueSchedule.Name = pol.Account__r.Name.subString(0,(pol.Account__r.Name.length() > 70 ? 70 : pol.Account__r.Name.length() )) + '-' + pol.Expiration_Date__c.addDays(-1).year() + '/' + pol.Expiration_Date__c.addDays(-1).month();
                
                string acKey1 = 'key'+pol.Expiration_Date__c.addDays(-1).month()+'year'+pol.Expiration_Date__c.addDays(-1).year();
                if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey1)){
                    RevenueSchedule.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey1).Id;
                }
                RevenueSchedule.AcctSeed__Account2__c = pol.Account__c;
                RevenueSchedule.Policy__c = pol.Id;
                RevenueSchedule.Date__c = pol.Expiration_Date__c.addDays(-1);
                RevenueSchedule.AcctSeed__Description__c = description;
                listOfAllSchedules.add(RevenueSchedule);
            }
            
            return listOfAllSchedules;
            
        }   
        catch(exception e){
            system.debug('--exception is a'+e.getMessage()+e.getlinenumber());
            return null;
        }
        
    }
}