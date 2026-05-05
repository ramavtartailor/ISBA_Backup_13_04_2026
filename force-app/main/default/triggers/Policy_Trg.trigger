/*
Created By      :   Shoukat Hussainhttps://isbamutual--sandbox1.cs2.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
Created Date    :   11/03/2016
Purpose         :   1) Premium Calculate for those Policies which are Is_Allow_Calculate_Premium =true.    
                    2) Generate Policy number at the time of policy conversion 

*/
trigger Policy_Trg on Policy__c (Before Insert, Before Update, After Insert, After update, Before Delete, After Delete) { //
    Set<Id> accountIds = new Set<Id>();
    if(Trigger.isAfter && Trigger.isUpdate){
        Set<String> policyIdsOfRegularRenewal = new Set<String>(); 
        for(Policy__c policy : Trigger.new){
            if(policy.Account__c!=null && (policy.Effective_Date__c != Trigger.oldMap.get(policy.Id).Effective_Date__c || policy.RecordTypeId != Trigger.oldMap.get(policy.Id).RecordTypeId) ){
                accountIds.add(policy.Account__c);
            }
            
            //changed in to Regular Renewal Policy
            if(policy.Renewal_Type__c == 'Regular Renewal' && Trigger.oldMap.get(policy.Id).Renewal_Type__c != 'Regular Renewal'){
                policyIdsOfRegularRenewal.add(policy.Id);
            }
        }
        PolicyTriggerHandler.updateEndorsementAndPolicyLawyerEffectiveDate(Trigger.new,Trigger.oldMap);
        if(!policyIdsOfRegularRenewal.isEmpty()){
            PolicyTriggerHandler.changeToRegularRenewal(policyIdsOfRegularRenewal);
        }
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
		//added for SA-Erp Record Type;
        List<Policy__c>  saErpPolicyRecords = [SELECT Id,Effective_Date__c,Previous_Policy__c FROM Policy__c WHERE Id IN: trigger.newMap.keySet() AND RecordType.Name='SA-ERP'];
        if(!saErpPolicyRecords.isEmpty()){
            PolicyTriggerHandler.CreatePolicyQuote(saErpPolicyRecords);
        }
        List<policy__c> policyList = new List<policy__c>();
        for(Policy__c policy : Trigger.new){
            if(policy.Account__c!=null){
                accountIds.add(policy.Account__c);
            }
            policy__c updatePolicy = new policy__c();
            updatePolicy.Id = policy.Id;
            updatePolicy.Application_Form_Link__c  = getUrl() + '?id=' + EncodingUtil.urlEncode(EZQOnlineApplicationFormCtrl.processEncryption(policy.Id,Label.Encryption_key_Policy_Id),'UTF-8');
            policyList.add(updatePolicy); 
        }
        update policyList;
        
    }
    
    
    if(Trigger.isBefore && Trigger.isUpdate){
        
         for(Policy__c policy : Trigger.new){
             if(policy.Application_Form_Link__c == null){
            	policy.Application_Form_Link__c  = getUrl() + '?id=' + EncodingUtil.urlEncode(EZQOnlineApplicationFormCtrl.processEncryption(policy.Id,Label.Encryption_key_Policy_Id),'UTF-8');
             }
        }
    }
    
    
    if(accountIds.size()>0){
        Map<String,Policy__c> mapOfRecentPolicyOnAccount = new Map<String,Policy__c>();
        Map<String,Policy__c> mapOfRecentApplicationOnAccount = new Map<String,Policy__c>();
        Set<Id> accountIdsNew = new Set<Id>();
        Map<Id,Account> accountsToUpdate = new Map<Id,Account>();
        for(Policy__c pol : [select id,Name,RecordType.Name,Account__c from Policy__c where Account__c IN: accountIds ORDER BY Effective_Date__c DESC,CreatedDate DESC]){
            if(pol.RecordType.Name == 'Policy' && !mapOfRecentPolicyOnAccount.containsKey(pol.Account__c)){
                mapOfRecentPolicyOnAccount.put(pol.Account__c,pol);
                accountIdsNew.add(pol.Account__c);
                if(!mapOfRecentApplicationOnAccount.containsKey(pol.Account__c)){
                    mapOfRecentApplicationOnAccount.put(pol.Account__c,null);
                }
            }
            
            if(pol.RecordType.Name == 'Application' && !mapOfRecentApplicationOnAccount.containsKey(pol.Account__c)){
                mapOfRecentApplicationOnAccount.put(pol.Account__c,pol);
                accountIdsNew.add(pol.Account__c);
            }
            
            if(pol.RecordType.Name == 'Application Rejected' && !mapOfRecentApplicationOnAccount.containsKey(pol.Account__c)){
                mapOfRecentApplicationOnAccount.put(pol.Account__c,pol);
                accountIdsNew.add(pol.Account__c);
            }
        }
        System.debug('accountIdsNew'+accountIdsNew);
        System.debug('mapOfRecentPolicyOnAccount'+mapOfRecentPolicyOnAccount);
        System.debug('mapOfRecentApplicationOnAccount'+mapOfRecentApplicationOnAccount);
        for(Id ids : accountIdsNew){
            if(mapOfRecentPolicyOnAccount.containsKey(ids) && mapOfRecentPolicyOnAccount.get(ids) != null){
                Policy__c pol = mapOfRecentPolicyOnAccount.get(ids);
                Account acc = new Account();
                acc.Recent_Policy_ID__c = pol.Id;
                acc.Recent_Policy__c = pol.Name;
                acc.Recent_Policy_Lookup__c = pol.Id;
                acc.Id = ids;
                accountsToUpdate.put(acc.Id,acc);
            }
            if(mapOfRecentApplicationOnAccount.containsKey(ids) && mapOfRecentApplicationOnAccount.get(ids) != null){
                Policy__c pol = mapOfRecentApplicationOnAccount.get(ids);
                if(accountsToUpdate.containsKey(ids)){
                    Account acc = accountsToUpdate.get(ids);
                    acc.Recent_Application_Id__c = pol.Id;
                    acc.Recent_Application__c = pol.Name;
                    acc.Recent_Application_Lookup__c = pol.Id;
                    acc.Id = ids;
                    accountsToUpdate.put(acc.Id,acc);
                }else{
                    Account acc = new Account();
                    acc.Recent_Application_Id__c = pol.Id;
                    acc.Recent_Application__c = pol.Name;
                    acc.Recent_Application_Lookup__c = pol.Id;
                    acc.Id = ids;
                    accountsToUpdate.put(acc.Id,acc);
                }
            }else{
                if(accountsToUpdate.containsKey(ids)){
                    Account acc = accountsToUpdate.get(ids);
                    acc.Recent_Application_Id__c = null;
                    acc.Recent_Application__c = null;
                    acc.Recent_Application_Lookup__c = null;
                    acc.Id = ids;
                    accountsToUpdate.put(acc.Id,acc);
                }else{
                    Account acc = new Account();
                    acc.Recent_Application_Id__c = null;
                    acc.Recent_Application__c = null;
                    acc.Recent_Application_Lookup__c = null;
                    acc.Id = ids;
                    accountsToUpdate.put(acc.Id,acc);
                }
            }
        }
        
        /*for(Id ids : mapOfRecentPolicyOnAccount.keySet()){
            Policy__c pol = mapOfRecentPolicyOnAccount.get(ids);
            if (pol != null) {
                Account acc = new Account();
                acc.Recent_Policy_ID__c = pol.Id;
                acc.Recent_Policy__c = pol.Name;
                acc.Id = ids;
                accountsToUpdate.put(acc.Id,acc);
                System.debug('==accountsToUpdate=='+accountsToUpdate);
            }
        }
        for(Id ids : mapOfRecentApplicationOnAccount.keySet()){
            Policy__c pol = mapOfRecentApplicationOnAccount.get(ids);
            if (pol != null) {
                System.debug('==accountsToUpdate=='+accountsToUpdate);
                if(accountsToUpdate.containsKey(ids)){
                   // System.debug('==accountsToUpdate=='+accountsToUpdate);
                    Account acc = accountsToUpdate.get(ids);
                    acc.Recent_Application_Id__c = pol.Id;
                    acc.Recent_Application__c = pol.Name;
                    acc.Id = ids;
                    accountsToUpdate.put(acc.Id,acc);
                }else{
                    Account acc = new Account();
                    acc.Recent_Application_Id__c = pol.Id;
                    acc.Recent_Application__c = pol.Name;
                    acc.Id = ids;
                    accountsToUpdate.put(acc.Id,acc);
                }
            }
        }*/
        if(accountsToUpdate.size()>0){
            System.debug('accountsToUpdate => '+accountsToUpdate);
            update accountsToUpdate.values();
        }
    }
    
    if(trigger.isAfter && trigger.isInsert)
    {
        // Commented on 17 September 2024  // Rolling over to Online Invoice
        //PolicyTriggerHandler.setRenewalType(trigger.new);
    }
    /*
    if(trigger.isAfter && trigger.isUpdate)
    {
        if(checkRecursive.run)
        {
            checkRecursive.run = false;
            PolicyTriggerHandler.setRenewalType(trigger.new, trigger.oldMap);
        }
    }
    */

    // Get the Custom Setting to see if the trigger is enabled on not.
    Boolean isEnabled;
    if (Test.isRunningTest()) {
        isEnabled = true;
    } else {
        isEnabled = !(Trigger_Setup__c.getInstance().Policy_Trigger_Disabled__c);
    }
    
    //List<Policy_Pricing_Version__mdt> policyVersions = new List<Policy_Pricing_Version__mdt>([select id,Effective_Date__c,Expiration_Date__c,MasterLabel from Policy_Pricing_Version__mdt]);
    
    if (isEnabled == true) {   
        // public ID ApplicationRTID = Schema.SObjectType.Policy__C.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        // public ID PolicyRTID       = Schema.SObjectType.Policy__C.getRecordTypeInfosByName().get('Policy').getRecordTypeId();    
        // Added by Ali Zaidi 11/12/2016
        if (Trigger.IsBefore) {
            if (Trigger.IsInsert) {
                // To check if Application/Policy already exist.
                Set<String> setOpportunitiesOfPol = new Set<String>();
                Map<String,Opportunity> mapOpportunities = new Map<String,Opportunity>();
                List<Treaty_Versions__c> treatyVersions = new List<Treaty_Versions__c>([select id,Start_Date__c,End_Date__c from Treaty_Versions__c]);
                List<Master_Factor__c> masterFactors = new List<Master_Factor__c>([select id,From_Date__c ,To_Date__c  from Master_Factor__c where Factor_Type__c  = 'AOP']);
                for (Policy__c pol : Trigger.New) {
                    setOpportunitiesofPol.add(pol.Opportunity__c);
                }
                System.debug(setOpportunitiesOfPol);
                for (Opportunity opp : [SELECT Id, Policy_Count__c FROM Opportunity WHERE Id IN: setOpportunitiesOfPol]) {
                    mapOpportunities.put(opp.Id, opp);
                }
                
                for (Policy__c pol : Trigger.New) {
                    if(mapOpportunities.containsKey(pol.Opportunity__c) && mapOpportunities.get(pol.Opportunity__c).Policy_Count__c!=null){
                        Integer count = Integer.valueOf(mapOpportunities.get(pol.Opportunity__c).Policy_Count__c);
                        
                        if (count > 0) {
                            pol.addError('Policy already exist for the selected Opportunity.');
                        }
                    }
                }
                /*
                // To set Opportunity Account in the Application or Policy Account.
                Set<String> setOpportunityIds = new Set<String>();
                Map<String,String> mapOpportunityAccounts = new Map<String,String>();
                
                for (Policy__c pol : Trigger.New) {
                    setOpportunityIds.add(pol.Opportunity__c);
                }
                
                for (Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE Id IN :setOpportunityIds]) {
                    mapOpportunityAccounts.put(opp.Id, opp.AccountId);
                }
                
                for (Policy__c pol : Trigger.New) {
                    pol.Account__c = mapOpportunityAccounts.get(pol.Opportunity__c);
                }
                */
                // To set Application and Policy name automatically.
                
               
                Set<String> setAccountIds = new Set<String>();
                Map<String,Account> mapAccountData = new Map<String,Account>();
                for (Policy__c pol : Trigger.New) {
                    if(!pol.DataLoader__c){
                        setAccountIds.add(pol.Account__c);
                    }
                }
                System.debug(setAccountIds);
                for (Account acc : [SELECT Id, Name, AccountNumber, Count_of_Applications__c, Count_of_Policies__c, Count_of_All_Records__c FROM Account WHERE Id IN :setAccountIds]) {
                    mapAccountData.put(acc.Id, acc);
                }
                Date dtEffectivePolicyVersion = Date.newInstance(2026, 4, 1);
                for (Policy__c pol : Trigger.New) {
                    for(Treaty_Versions__c version : treatyVersions){
                        if(pol.Effective_Date__c >= version.Start_Date__c && pol.Effective_Date__c <= version.End_Date__c){
                            pol.Treaty_Version__c = version.Id;
                        }
                    }
                    for(Master_Factor__c mf : masterFactors){
                        if(pol.Effective_Date__c >= mf.From_Date__c && pol.Effective_Date__c <= mf.To_Date__c){
                            pol.AOP_Master_Factor__c = mf.Id;
                        }
                    }
                    if(pol.Effective_Date__c >= dtEffectivePolicyVersion){
                        pol.Policy_Document_Version__c = '4/26';
                    }
                    if(!pol.DataLoader__c){
                        if (mapAccountData.containsKey(pol.Account__c)) {
                            //pol.Name = mapAccountData.get(pol.Account__c).AccountNumber + '-' + Integer.valueOf(mapAccountData.get(pol.Account__c).Count_of_Applications__c + 1);
                            if(pol.Application_Type__c != 'Renewal' && (pol.Application_Type__c == 'New Business' && pol.Old_Policy__c == null)){
                                pol.Name = mapAccountData.get(pol.Account__c).AccountNumber + '-1-' + String.valueOf(pol.Effective_Date__c.year()).right(2) + (String.valueOf(pol.Effective_Date__c.month()).length()>1 ? String.valueOf(pol.Effective_Date__c.month()): '0' + pol.Effective_Date__c.month());
                            }
                        } else {
                            pol.addError('Invalid Account Data.');
                        }
                    }
                    System.debug(pol.Name+'pol.Name');
                    /*for(Policy_Pricing_Version__mdt version : policyVersions){
                        if(pol.Effective_Date__c >= version.Effective_Date__c && pol.Effective_Date__c <= version.Expiration_Date__c){
                            pol.Pricing_Version__c = version.MasterLabel;
                        }
                    }*/ 
                }
            } 
            else  if (Trigger.IsUpdate) {
                // To set  Policy number automatically.
                // To set  Rejct number automatically.
                Set<String> setAccountIds = new Set<String>();
                Map<String,Account> mapAccountData = new Map<String,Account>();
                Map<String,Integer> mapAc_Policycount = new Map<String,Integer>();

                Set<String> setAccount_Rej_Ids = new Set<String>();
                Map<String,Account> mapAccount_Rej_Data = new Map<String,Account>(); 
                Map<String,Integer> mapAc_Policy_Rej_count = new Map<String,Integer>();
                List<Policy__c> treatyUpdate = new List<Policy__c>();
                List<Treaty_Versions__c> treatyVersions = new List<Treaty_Versions__c>();
                for (Policy__c pol : Trigger.New) { 
                    // for policy number
                    if(pol.RecordTypeId == ApplicationPolicyUtil.ApplicationRTID && 
                       pol.status__c == 'Accepted'  && pol.Is_Accepted_Confirm__c == true && Trigger.oldMap.get(pol.Id).Is_Accepted_Confirm__c == false  ) {
                           setAccountIds.add(pol.Account__c);  
                       }  
                    // for  Application Reject number
                    if(pol.RecordTypeId == ApplicationPolicyUtil.ApplicationRTID && 
                       pol.status__c == 'Rejected'  && pol.Is_Rejected_Confirm__c == true && Trigger.oldMap.get(pol.Id).Is_Rejected_Confirm__c == false  ) {
                           pol.RecordTypeId = ApplicationPolicyUtil.ApplicationRejectedRTID;
                           pol.Policy_Number_Before_Rejection__c = pol.Name;
                           setAccount_Rej_Ids.add(pol.Account__c);  
                       }
                    
                    if(pol.Effective_Date__c!=Trigger.oldMap.get(pol.Id).Effective_Date__c || pol.Treaty_Version__c == null){
                        treatyUpdate.add(pol);
                    }
                    /*if(pol.Effective_Date__c!=Trigger.oldMap.get(pol.Id).Effective_Date__c){
                        for(Policy_Pricing_Version__mdt version : policyVersions){
                            if(pol.Effective_Date__c >= version.Effective_Date__c && pol.Effective_Date__c <= version.Expiration_Date__c){
                                pol.Pricing_Version__c = version.MasterLabel;
                            }
                        }
                    }*/
                }
                // for policy number
                if(setAccountIds.size() > 0){
                    for (Account acc : [SELECT Id,AccountNumber,Count_of_Policies__c FROM Account WHERE Id IN :setAccountIds]) {                              
                        mapAccountData.put(acc.Id, acc);
                        mapAc_Policycount.put(acc.Id,Integer.valueOf(acc.Count_of_Policies__c))  ;                  
                    }
                }
                // for Reject Application number
                if(setAccount_Rej_Ids.size() > 0){
                    for (Account acc : [SELECT Id,AccountNumber,Count_of_Reject_Application__c FROM Account WHERE Id IN :setAccount_Rej_Ids]) {                             
                        mapAccount_Rej_Data.put(acc.Id, acc);
                        mapAc_Policy_Rej_count.put(acc.Id,Integer.valueOf(acc.Count_of_Reject_Application__c))  ;                  
                    }
                }
                
                if(treatyUpdate.size() > 0){
                    if(!Test.isRunningTest())
                        treatyVersions = new List<Treaty_Versions__c>([select id,Start_Date__c,End_Date__c from Treaty_Versions__c]);
                }
                
                for (Policy__c pol : Trigger.New) {
                    // For Policy Number update
                    if(pol.RecordTypeId == ApplicationPolicyUtil.ApplicationRTID && 
                       pol.status__c == 'Accepted'  && pol.Is_Accepted_Confirm__c == true && Trigger.oldMap.get(pol.Id).Is_Accepted_Confirm__c == false && pol.Policy_Number__c == null) {
                           mapAc_Policycount.put(pol.Account__c,Integer.valueOf(mapAccountData.get(pol.Account__c).Count_of_Policies__c) + 1)  ; 
                           /*pol.Policy_Number__c = mapAccountData.get(pol.Account__c).AccountNumber + '-' + 
                               Integer.valueOf(mapAc_Policycount.get(pol.Account__c));  */   
                           pol.Policy_Number__c = pol.Name;
                       }
                    
                    // For Application Reject number update
                    if(pol.RecordTypeId == ApplicationPolicyUtil.ApplicationRejectedRTID && 
                       pol.status__c == 'Rejected'  &&
                       pol.Is_Rejected_Confirm__c == true &&
                       Trigger.oldMap.get(pol.Id).Is_Rejected_Confirm__c == false &&
                       pol.Name != null) {
                           try{
                              mapAc_Policy_Rej_count.put(pol.Account__c,Integer.valueOf(mapAccount_Rej_Data.get(pol.Account__c).Count_of_Reject_Application__c) + 1)  ; 
                           }
                           catch(NullPointerException e) {
                               mapAc_Policy_Rej_count.put(pol.Account__c,1)  ; 
                           }
                           if(Trigger.oldMap.get(pol.Id).Status__c == 'Inquiry'){
                               pol.Name = mapAccount_Rej_Data.get(pol.Account__c).AccountNumber + '-I' + 
                                   Integer.valueOf(mapAc_Policy_Rej_count.get(pol.Account__c));
                           }else{
                               pol.Name = mapAccount_Rej_Data.get(pol.Account__c).AccountNumber + '-R' + 
                                   Integer.valueOf(mapAc_Policy_Rej_count.get(pol.Account__c));
                           }
                                              
                       }
                    
                    if(pol.Effective_Date__c!=Trigger.oldMap.get(pol.Id).Effective_Date__c || pol.Treaty_Version__c == null){
                        for(Treaty_Versions__c version : treatyVersions){
                            if(pol.Effective_Date__c >= version.Start_Date__c && pol.Effective_Date__c <= version.End_Date__c){
                                pol.Treaty_Version__c = version.Id;
                            }
                        }
                    }
                    
                }     
                    
                    
            }
        } else if (Trigger.IsAfter) {
            if (Trigger.IsInsert) {
                List<Opportunity> opptiesToInsert = new List<Opportunity>();
                Set<Id> oldPolicyIds = new Set<Id>();
                Set<Id> renewalPolicies = new Set<Id>();
                Map<Id,Policy__C> mapOldPolicies = new Map<Id,Policy__C>();
                List<Policy_Quote__c> lstQuotesToClone = new List<Policy_Quote__c>();
                List<Policy_Lawyer__c> lstLawyersToClone = new List<Policy_Lawyer__c>();
                List<Policy_AOP__c> lstAOPsToClone = new List<Policy_AOP__c>();
                List<Policy_Endorsement__c> lstEndsToClone = new List<Policy_Endorsement__c>();
                List<AOP_Factor__c> lstOfAopFactors;
                List<Deductible_Factor__c> lstDeductible;
                List<ILF_Coverage_Factor__c> lstCoverage;
                Map<Id,Map<String,Id>> mapAOPFactors = new Map<Id,Map<String,Id>>();
                Map<Id,Map<String,Id>> mapCoverage = new Map<Id,Map<String,Id>>();
                Map<Id,Map<String,Id>> mapDeductible = new Map<Id,Map<String,Id>>();
                Set<Id> aopMasterFactors = new Set<Id>();
                Map<String,String> policyIdWithOnlineNba = new Map<String,String>();
                for(Policy__c pol : Trigger.New){
                    if(pol.Application_Type__c == 'Renewal' && pol.Old_Policy__c!=null){
                        oldPolicyIds.add(pol.Old_Policy__c);
                        renewalPolicies.add(pol.Id);
                        
                        if(String.isNotBlank(pol.Customer_Application__c)){
                            policyIdWithOnlineNba.put(pol.Id,pol.Customer_Application__c);
                        }
                        aopMasterFactors.add(pol.AOP_Master_Factor__c);
                    }
                }
                if(oldPolicyIds.size()>0){
                    mapOldPolicies = new Map<Id,Policy__C>([select id,Opportunity__r.Name,Opportunity__r.id,ClonedBy__c,PolicyExternalID__c from Policy__C where id in : oldPolicyIds]);
                    lstOfAopFactors = new List<AOP_Factor__c>([select id,Name,AOP_Mod__c,From_Date__c,To_Date__c,Master_Factor__c from  AOP_Factor__c where Master_Factor__c in: aopMasterFactors]);
                    lstDeductible = new List<Deductible_Factor__c>([SELECT Id,Name,From_Date__c,To_Date__c FROM Deductible_Factor__c]);
                    lstCoverage = new List<ILF_Coverage_Factor__c>([SELECT Id,Name,From_Date__c,To_Date__c FROM ILF_Coverage_Factor__c where OldLimit__c = false]);
                }
                
                
                
                for(Policy__c pol : Trigger.New){
                    Opportunity opp = new Opportunity();
                    if(pol.Application_Type__c == 'Renewal' && pol.Old_Policy__c!=null && mapOldPolicies.containsKey(pol.Old_Policy__c)){
                        opp.CloseDate =pol.Effective_Date__c;
                        opp.Name=mapOldPolicies.get(pol.Old_Policy__c).Opportunity__r.Name;
                        opp.StageName='Application Received';
                        opp.AccountId=pol.Account__c;
                        opp.ClonedBy__c=mapOldPolicies.get(pol.Old_Policy__c).ClonedBy__c;
                        opp.Old_Opprortunity__c=mapOldPolicies.get(pol.Old_Policy__c).Opportunity__r.id;
                        opp.Type='Existing Business';
                        opp.Application_Policy__c=pol.Id;
                        for(AOP_Factor__c factor : lstOfAopFactors){
                            if(pol.AOP_Master_Factor__c == factor.Master_Factor__c){
                                if(mapAOPFactors.containsKey(pol.Id)){
                                    Map<String,Id> tempMap = mapAOPFactors.get(pol.Id);
                                    tempMap.put(factor.Name,factor.Id);
                                    mapAOPFactors.put(pol.Id,tempMap);
                                }else{
                                    Map<String,Id> tempMap = new Map<String,Id>();
                                    tempMap.put(factor.Name,factor.Id);
                                    mapAOPFactors.put(pol.Id,tempMap);
                                }
                            }
                        }
                        for(Deductible_Factor__c factor : lstDeductible){
                            if(factor.From_Date__c <= pol.Effective_Date__c &&  factor.To_Date__c >= pol.Effective_Date__c){
                                if(mapDeductible.containsKey(pol.Id)){
                                    Map<String,Id> tempMap = mapDeductible.get(pol.Id);
                                    tempMap.put(factor.Name,factor.Id);
                                    mapDeductible.put(pol.Id,tempMap);
                                }else{
                                    Map<String,Id> tempMap = new Map<String,Id>();
                                    tempMap.put(factor.Name,factor.Id);
                                    mapDeductible.put(pol.Id,tempMap);
                                }
                            }
                        }
                        for(ILF_Coverage_Factor__c factor : lstCoverage){
                            if(factor.From_Date__c <= pol.Effective_Date__c &&  factor.To_Date__c >= pol.Effective_Date__c){
                                if(mapCoverage.containsKey(pol.Id)){
                                    Map<String,Id> tempMap = mapCoverage.get(pol.Id);
                                    tempMap.put(factor.Name,factor.Id);
                                    mapCoverage.put(pol.Id,tempMap);
                                }else{
                                    Map<String,Id> tempMap = new Map<String,Id>();
                                    tempMap.put(factor.Name,factor.Id);
                                    mapCoverage.put(pol.Id,tempMap);
                                }
                            }
                        }
                    }else{
                        opp.CloseDate=pol.Effective_Date__c;
                        opp.Name=pol.Name;
                        System.debug(pol.Name+'pol.Name');
                        opp.StageName='Application Received';
                        opp.AccountId=pol.Account__c;
                        opp.Type='New Business';
                        opp.Application_Policy__c=pol.Id;
                    }
                    opptiesToInsert.add(opp);
                }
                if(opptiesToInsert!=null && opptiesToInsert.size()>0){
                    insert opptiesToInsert;
                }
                
               // ApplicationPolicyUtil.updatePolicyWithOpportunity(new Map<Id,Opportunity>(opptiesToInsert).keyset());
              // System.enqueueJob(new UpdatePolicyWithOpportunityQueueable(new Map<Id,Opportunity>(opptiesToInsert).keyset()));
                
                List<Application_Block__c> applicationBlocks = new List<Application_Block__c>();
                if(oldPolicyIds.size()>0){
                    
                    List<String> fieldNames = new List<String>( Schema.getGlobalDescribe().get('Policy_Quote__c').getDescribe().fields.getMap().keySet() );
                    String query =' SELECT ' +String.join( fieldNames, ',' ) +',Coverage__r.Name,Deductible__r.Name,Policy__r.Name FROM Policy_Quote__c'  +' WHERE ' +' Policy__c in: oldPolicyIds ' +' AND Final_Quote__c = true ';
                    List<Policy__c> bucketAccountPolicies = new List<Policy__c>([select id from Policy__c where Account__r.Name=: Label.Online_NBA_Account ]);
                    for (Policy_Quote__c quo : Database.query(query)) {
                        for (Policy__c pol : Trigger.new) {
                            if (quo.Policy__c == pol.Old_Policy__c) {
                                if(mapCoverage.containsKey(pol.Id) && mapDeductible.containsKey(pol.Id)){
                                    if(mapCoverage.get(pol.Id).containsKey(quo.Coverage__r.Name) && mapDeductible.get(pol.Id).containsKey(quo.Deductible__r.Name)){
                                        Policy_Quote__c newQuote = new Policy_Quote__c();
                                        newQuote = quo.Clone(false, true);
                                        
                                        newQuote.Final_Quote__c = false; 
                                        newQuote.Coverage__c = mapCoverage.get(pol.Id).get(quo.Coverage__r.Name);
                                        newQuote.Deductible__c =mapDeductible.get(pol.Id).get(quo.Deductible__r.Name);
                                        newQuote.Policy__c = pol.Id;
                                        newQuote.Quote_Expire_Date__c = pol.Effective_Date__c;
                                        newQuote.Policy_Quote_External_ID__c =  null;
                                        if(String.isNotBlank(mapOldPolicies.get(pol.Old_Policy__c).PolicyExternalID__c) && pol.Legacy_Endorsement_List__c != null){
                                            if(pol.Legacy_Endorsement_List__c.contains('IL 230')){
                                                newQuote.Mod_230__c = 1;
                                            }
                                            if(pol.Legacy_Endorsement_List__c.contains('IL 234')){
                                                newQuote.Mod_234__c = 1;
                                            }
                                            if(pol.Legacy_Endorsement_List__c.contains('IL 261')){
                                                newQuote.Mod_261__c = 1;
                                            }
                                        }
                                        if(quo.Mod_230__c !=null && quo.Mod_230__c < 1.03){
                                            newQuote.Mod_230__c = 1.03;
                                        }
                                        if(quo.Mod_234__c !=null && quo.Mod_234__c < 1.03){
                                            newQuote.Mod_234__c = 1.03;
                                        }
                                        if(quo.Mod_261__c !=null && quo.Mod_261__c < 1.03){
                                            newQuote.Mod_261__c = 1.03;
                                        }
                                        if(!newQuote.ADJ_R_O__c){
                                            newQuote.ADJ_MOD__c = 1;
                                        } 
                                        
                                        if(String.isNotBlank(pol.Customer_Application__c)){
                                            Policy_Quote__c newQuote1 = new Policy_Quote__c();
                                            newQuote1 = newQuote.Clone(false, true);
                                            newQuote1.Customer_Application__c = pol.Customer_Application__c;
                                            newQuote1.Policy__c = bucketAccountPolicies[0].Id;
                                            lstQuotesToClone.add(newQuote1);
                                        }
                                        lstQuotesToClone.add(newQuote);
                                    }else{
                                        applicationBlocks.add(new Application_Block__c(Account__c=pol.Account__c,Application_Policy__c=pol.Id,Status__c='Active',Subject__c='Quote Conflict',Description__c='Quote Conflict ('+ quo.Name +') From Renewal Policy('+quo.Policy__r.Name+')'));
                                    }
                                }else{
                                    applicationBlocks.add(new Application_Block__c(Account__c=pol.Account__c,Application_Policy__c=pol.Id,Status__c='Active',Subject__c='Quote Conflict',Description__c='Quote Conflict ('+ quo.Name +') From Renewal Policy('+quo.Policy__r.Name+')'));
                                }
                            }
                        }
                    }
                    
                    if(lstQuotesToClone!=null && lstQuotesToClone.size()>0){
                        insert lstQuotesToClone;
                    }
                    
                    fieldNames = new List<String>( Schema.getGlobalDescribe().get('Policy_Lawyer__c').getDescribe().fields.getMap().keySet() );
                    query =' SELECT Lawyer__r.Contact__c, Lawyer__r.Contact__r.MobilePhone, Lawyer__r.Contact__r.Personal_Email__c, Lawyer__r.Contact__r.Birthdate,' +String.join( fieldNames, ',' ) +' FROM Policy_Lawyer__c'  +' WHERE ' +' Policy__c in: oldPolicyIds ' +'  AND  Deleted_Date__c = null';
                    List<Customer_Application_Lawyer__c> applicationLawyerList = new List<Customer_Application_Lawyer__c>();
                    Map<Id,Integer> countOfLawyers = new Map<Id,Integer>();
                    // Fetch Policy Lawyers to Attach with Newly created applications.
                    for (Policy_Lawyer__c law : Database.query(query)) {
                        for (Policy__c pol : Trigger.new) {
                            if (law.Policy__c == pol.Old_Policy__c) {
                                if(!countOfLawyers.containsKey(law.Policy__c)){
                                    countOfLawyers.put(law.Policy__c,0);
                                }
                                countOfLawyers.put(law.Policy__c,countOfLawyers.get(law.Policy__c) + 1);
                                Policy_Lawyer__c newLawyer = new Policy_Lawyer__c();
                                newLawyer = law.Clone(false, true);
                                newLawyer.Is_Application_Lawyer__c = true;
                                newLawyer.Policy__c = pol.Id;
                                newLawyer.Policy_Lawyer_External_ID__c =  null;
                                newLawyer.Added_Date__c = null;
                                newLawyer.Term__c = null;
                                newLawyer.CLE_Credit__c = null;
                                lstLawyersToClone.add(newLawyer);
                                
                                if(policyIdWithOnlineNba.containsKey(pol.Id)){
                                    Customer_Application_Lawyer__c applicationLawyer = new Customer_Application_Lawyer__c();
                                    applicationLawyer.Name = law.First_Name_Contact__c;
                                    applicationLawyer.Contact__c = law.Lawyer__r.Contact__c;
                                    applicationLawyer.Middle_Initial__c  = law.Middle_Name_Contact__c ;
                                    applicationLawyer.Last_Name__c  = law.Last_Name_Contact__c;
                                    applicationLawyer.ISBA_Number__c = law.ISBA_Number__c; 
                                    applicationLawyer.ARDC_Number__c = law.ARDC_Number__c;
                                    applicationLawyer.Cell_Phone__c = law.Lawyer__r.Contact__r.MobilePhone;
                                    applicationLawyer.Birthday__c = law.Lawyer__r.Contact__r.Birthdate;
                                    applicationLawyer.Firm_Email_Address__c = law.Contact_Email__c;
                                    applicationLawyer.Personal_Email_Address__c = law.Lawyer__r.Contact__r.Personal_Email__c;
                                    applicationLawyer.Customer_Application__c = policyIdWithOnlineNba.get(pol.Id);
                                    applicationLawyerList.add(applicationLawyer);
                                }
                                
                            }
                        }
                    }
                    if(lstLawyersToClone!=null && lstLawyersToClone.size()>0){
                        Policy_Lawyer_Trg_Handler.InsertCustomerApplicationLawyer = false;
                        insert lstLawyersToClone;
                    }
                    
                    if(!applicationLawyerList.isEmpty()){
                        Insert applicationLawyerList;
                    }
                    
                    fieldNames = new List<String>( Schema.getGlobalDescribe().get('Policy_AOP__c').getDescribe().fields.getMap().keySet() );
                    query =' SELECT ' +String.join( fieldNames, ',' ) +',AOP__r.Name,AOP__r.Next_AOP_Factor__c,AOP__r.Next_AOP_Factor__c  FROM Policy_AOP__c'  +' WHERE ' +' Policy__c in: oldPolicyIds ';
                    
                    Map<String,Map<String,Policy_AOP__c>> policyWithAopMap = new Map<String,Map<String,Policy_AOP__c>>();
                    
                    // Fetch Policy AOP to Attach with Newly created applications.
                    for (Policy_AOP__c AOP : [SELECT AOP__c, Bypass_Default_Factor__c, Factor_Mod__c, Id, Name, Percentage_Value__c, Percentage__c, Policy_Number__c, Policy__c,AOP__r.Name,Policy__r.Name,AOP__r.Next_AOP_Factor__c,AOP__r.Next_AOP_Factor__r.Master_Factor__c FROM Policy_AOP__c WHERE Policy__c IN :oldPolicyIds]) {
                        system.debug('AOP  => '+ AOP);
                        for (Policy__c pol : Trigger.new) {
                           
                            Map<String,Policy_AOP__c> tempAopMap = new Map<String,Policy_AOP__c>();
                            if(policyWithAopMap.containsKey(pol.Id)){
                                tempAopMap = policyWithAopMap.get(pol.Id);
                            }
                            
                            if (AOP.Policy__c == pol.Old_Policy__c) {
                                if(mapAOPFactors.containsKey(pol.Id)){
                                    Policy_AOP__c newAOP = new Policy_AOP__c();
                                    newAOP = AOP.Clone(false, true);
                                    newAOP.Policy__c = pol.Id;
                                    newAOP.Policy_AOP_External_ID__c = null;
                                    if(pol.AOP_Master_Factor__c == AOP.AOP__r.Next_AOP_Factor__r.Master_Factor__c && AOP.AOP__r.Next_AOP_Factor__c !=null){
                                        newAOP.AOP__c = AOP.AOP__r.Next_AOP_Factor__c;
                                        system.debug('NextAopFactors => '+newAOP.AOP__c);
                                        if(tempAopMap.containsKey(newAOP.AOP__c)){
                                            tempAopMap.get(newAOP.AOP__c).Percentage__c += newAOP.Percentage__c;
                                            tempAopMap.get(newAOP.AOP__c).Percentage_Value__c += newAOP.Percentage_Value__c;
                                            tempAopMap.get(newAOP.AOP__c).Factor_Mod__c += newAOP.Factor_Mod__c;
                                        }
                                        else{
                                            tempAopMap.put(newAOP.AOP__c, newAOP);
                                            lstAOPsToClone.add(newAOP);
                                        }
                                        
                                    }else if(mapAOPFactors.get(pol.Id).containsKey(AOP.AOP__r.Name)){
                                        newAOP.AOP__c = mapAOPFactors.get(pol.Id).get(AOP.AOP__r.Name);
                                        system.debug('NextAopFactors => mapAOPFactors => '+newAOP.AOP__c);
                                        if(tempAopMap.containsKey(newAOP.AOP__c)){
                                            tempAopMap.get(newAOP.AOP__c).Percentage__c += newAOP.Percentage__c;
                                            tempAopMap.get(newAOP.AOP__c).Percentage_Value__c += newAOP.Percentage_Value__c;
                                            tempAopMap.get(newAOP.AOP__c).Factor_Mod__c += newAOP.Factor_Mod__c;
                                        }
                                        else{
                                            tempAopMap.put(newAOP.AOP__c, newAOP);
                                            lstAOPsToClone.add(newAOP);
                                        }
                                    }else{
                                        applicationBlocks.add(new Application_Block__c(Account__c=pol.Account__c,Application_Policy__c=pol.Id,Status__c='Active',Subject__c='AOP Conflict',Description__c='AOP Conflict ('+ AOP.AOP__r.Name +') From Renewal Policy('+AOP.Policy__r.Name+')'));
                                    }
                                }else{
                                    applicationBlocks.add(new Application_Block__c(Account__c=pol.Account__c,Application_Policy__c=pol.Id,Status__c='Active',Subject__c='AOP Conflict',Description__c='AOP Conflict ('+ AOP.AOP__r.Name +') From Renewal Policy('+AOP.Policy__r.Name+')'));
                                }
                            }
                            policyWithAopMap.put(pol.Id,tempAopMap); 
                        }
                    }
                    if(lstAOPsToClone!=null && lstAOPsToClone.size()>0){
                        for(Policy_AOP__c newAOP: lstAOPsToClone){
                            system.debug('newAOP => '+ newAOP); 
                        }
                        
                        insert lstAOPsToClone;
                    }
                    // Fetch all the Descriptive Endorsement record type ids.
                    Set<String> setRecordTypeIds = new Set<String>();
                    
                    for (Endorsement__c endRT : [SELECT Id, Endorsement_Record_Type_ID__c FROM Endorsement__c WHERE Type__c = 'Descriptive'and Endorsement_Sub_Type__c != 'IL 230' and  Endorsement_Sub_Type__c != 'IL 234' and  Endorsement_Sub_Type__c != 'IL 261'  and  Endorsement_Sub_Type__c != 'IL 302'  and  Endorsement_Sub_Type__c != 'IL 106' and  Endorsement_Sub_Type__c != 'IL 303']) {
                        setRecordTypeIds.add(endRT.Endorsement_Record_Type_ID__c);
                    }
                    Set<Id> oldEndorsementIds = new Set<Id>();
                    
                    fieldNames = new List<String>( Schema.getGlobalDescribe().get('Policy_Endorsement__c').getDescribe().fields.getMap().keySet() );
                    query =' SELECT ' +String.join( fieldNames, ',' ) +' FROM Policy_Endorsement__c'  +' WHERE ' +' Policy__c in: oldPolicyIds and  RecordTypeId IN :setRecordTypeIds';
                    
                    // Fetch Policy Endorsements to Attach with Newly created applications.
                    for (Policy_Endorsement__c ends : Database.query(query)) {
                        for (Policy__c pol : Trigger.new) {
                            if (ends.Policy__c == pol.Old_Policy__c) {
                                if(ends.Endorsement_Number__c == 'IL 106' && countOfLawyers.get(ends.Policy__c)>1){
                                    applicationBlocks.add(new Application_Block__c(Account__c=pol.Account__c,Application_Policy__c=pol.Id,Status__c='Active',Subject__c='IL 106 Removed',Description__c='106 endorsement was removed as there are more than 1 lawyers.'));
                                }else{
                                    Policy_Endorsement__c newEnd = new Policy_Endorsement__c();
                                    newEnd = ends.Clone(false, true);
                                    newEnd.Event_Status__c = 'Pending';
                                    newEnd.Endorsement_Effective_Date__c = pol.Effective_Date__c;
                                    newEnd.Policy__c = pol.Id;
                                    newEnd.Policy_Endorsement_External_Id__c = ends.Id;
                                    oldEndorsementIds.add(ends.Id);
                                    lstEndsToClone.add(newEnd);
                                }
                            }
                        }
                    }
                    
                    if(lstEndsToClone!=null && lstEndsToClone.size()>0){
                        insert lstEndsToClone;
                        /*Database.SaveResult [] insertResult = Database.insert(lstEndsToClone,false);
                        for(integer idx = 0; idx < insertResult.size(); idx++) {
                            if(!insertResult[idx].isSuccess()) {
                                Trigger.new[idx].addError(insertResult[idx].getErrors()[0].getMessage());
                            }
                        }*/
                    }
                    List<Policy_Endorsement_Term__c> termsToClone = new List<Policy_Endorsement_Term__c>();
                    for(Policy_Endorsement_Term__c term : [select id,Attorney__c,Endorsement__c,Firm_Entity__c,Term_End_Date__c,Term_Start_Date__c from Policy_Endorsement_Term__c where Endorsement__c in: oldEndorsementIds]){
                        Policy_Endorsement_Term__c newTerm = new Policy_Endorsement_Term__c();
                        Policy_Endorsement__c newEnd = new Policy_Endorsement__c();
                        newEnd.Policy_Endorsement_External_Id__c = term.Endorsement__c;
                        newTerm.Attorney__c = term.Attorney__c;
                        newTerm.Firm_Entity__c = term.Firm_Entity__c;
                        newTerm.Term_End_Date__c = term.Term_End_Date__c;
                        newTerm.Term_Start_Date__c = term.Term_Start_Date__c;
                        newTerm.Endorsement__r = newEnd;
                        System.debug('======newTerm' + newTerm);
                        termsToClone.add(newTerm);
                    }
                    if(termsToClone.size()>0){
                        insert termsToClone;
                    }
                    if(applicationBlocks.size()>0){
                        insert applicationBlocks;
                    }
                }
                if(renewalPolicies.size() > 0){
                    //System.enqueueJob(new UpdatePolicyWithOpportunityQueueable(new Map<Id,Opportunity>(opptiesToInsert).keyset()));
                    System.enqueueJob(new CreateLSAonRenewalQueueable(renewalPolicies,new Map<Id,Opportunity>(opptiesToInsert).keyset()));
                    //ApplicationPolicyUtil.createLSAonRenewal(renewalPolicies);
                }
            } else if (Trigger.IsDelete) {
                // To update policy count on opportunity, if the application or policy is deleted.
                Set<String> setOpportunityIds = new Set<String>();
                List<Opportunity> lstOpportunities = new List<Opportunity>();
                
                for (Policy__c pol : Trigger.Old) {
                    setOpportunityIds.add(pol.Opportunity__c);
                }
                
                for (Opportunity opp : [SELECT Id, Policy_Count__c FROM Opportunity WHERE Id IN :setOpportunityIds]) {
                    opp.Policy_Count__c = opp.Policy_Count__c - 1;
                    opp.Application_Policy__c = null;
                    lstOpportunities.add(opp);
                }
                update lstOpportunities;
            }
        }
        // End
        
        If(Trigger.Isbefore && Trigger.IsUpdate){
            
            list<Policy__c> PolicyCalculatePremiumLst = new list<Policy__c>();    // for filtered policies     
            Set<ID>  PolicyIDCalculatePremiumSet = new   Set<ID>(); // for unique IDs
            //Map<String,List<Policy__c>> policyCalculatePremiumMap = new Map<String,List<Policy__c>>();
            //Map<String,Set<Id>> PolicyIDCalculatePremiumMap = new Map<String,Set<Id>>();
            for(Policy__C PolicyForloop : Trigger.New){
                // set Mini_Tail_Override_Date__c
                System.debug('PolicyForloop.RecordTypeId----'+PolicyForloop.RecordTypeId);
                System.debug('ApplicationPolicyUtil.PolicyRTID----'+ApplicationPolicyUtil.PolicyRTID);
                System.debug('Trigger.oldMap.get(PolicyForloop.Id).RecordTypeId----'+Trigger.oldMap.get(PolicyForloop.Id).RecordTypeId);
                System.debug('ApplicationPolicyUtil.ApplicationRTID----'+ApplicationPolicyUtil.ApplicationRTID);
                System.debug('PolicyForloop.Mini_Tail_Override_Date__c---'+PolicyForloop.Mini_Tail_Override_Date__c);
                if(PolicyForloop.RecordTypeId == ApplicationPolicyUtil.PolicyRTID && 
                   Trigger.oldMap.get(PolicyForloop.Id).RecordTypeId == ApplicationPolicyUtil.ApplicationRTID &&
                   PolicyForloop.Mini_Tail_Override_Date__c == null
                  ) {
                      if(PolicyForloop.Expiration_Date__c!=null){
                          PolicyForloop.Mini_Tail_Override_Date__c = PolicyForloop.Expiration_Date__c.addDays(60);
                      }
                  }
                // Calculate Premium 
                /* old code of calculate policy premium by clicking on details page button 
                    Modified Date 19 April 2017
                    ---------------------------------------------------
                    if (PolicyForLoop.is_allow_calculate_premium__c ==true 
                    && Trigger.oldMap.get(PolicyForloop.Id).is_allow_calculate_premium__C==false 
                    && PolicyForLoop.RecordTypeId==ApplicationPolicyUtil.ApplicationRTID){
                        PolicyIDCalculatePremiumSet.add(PolicyForloop.id);
                        PolicyCalculatePremiumLst.add(PolicyForloop);
                    } 
                    ---------------------------------------------------
                */
                if (PolicyForLoop.RecordTypeId==ApplicationPolicyUtil.ApplicationRTID || PolicyForLoop.RecordTypeId==ApplicationPolicyUtil.SAERPRTID){
                    System.debug('Premium Recalculate On Policy');
                    System.debug('TriggerFactory.isUpdatePremium'+TriggerFactory.isUpdatePremium);
                        PolicyIDCalculatePremiumSet.add(PolicyForloop.id);
                        PolicyCalculatePremiumLst.add(PolicyForloop);
                    /*if(PolicyForLoop.Pricing_Version__c!=null && policyCalculatePremiumMap.containsKey(PolicyForLoop.Pricing_Version__c)){
                        PolicyCalculatePremiumLst = policyCalculatePremiumMap.get(PolicyForLoop.Pricing_Version__c);
                        PolicyIDCalculatePremiumSet = PolicyIDCalculatePremiumMap.get(PolicyForLoop.Pricing_Version__c);
                        PolicyIDCalculatePremiumSet.add(PolicyForloop.id);
                        PolicyCalculatePremiumLst.add(PolicyForloop);
                        policyCalculatePremiumMap.put(PolicyForLoop.Pricing_Version__c,PolicyCalculatePremiumLst);
                        PolicyIDCalculatePremiumMap.put(PolicyForLoop.Pricing_Version__c,PolicyIDCalculatePremiumSet);
                    }else if(PolicyForLoop.Pricing_Version__c!=null){
                        PolicyCalculatePremiumLst = new list<Policy__c>();   
                        PolicyIDCalculatePremiumSet = new   Set<ID>();
                        PolicyIDCalculatePremiumSet.add(PolicyForloop.id);
                        PolicyCalculatePremiumLst.add(PolicyForloop);
                        policyCalculatePremiumMap.put(PolicyForLoop.Pricing_Version__c,PolicyCalculatePremiumLst);
                        PolicyIDCalculatePremiumMap.put(PolicyForLoop.Pricing_Version__c,PolicyIDCalculatePremiumSet);
                    }*/
                }            
            }
            /*if(policyCalculatePremiumMap.size()>0){
                for(String str : policyCalculatePremiumMap.keySet()){
                    TriggerFactory.isUpdatePremium = false;
                    ApplicationPremiumCalculator.UpdateQuotePremium(policyCalculatePremiumMap.get(str),PolicyIDCalculatePremiumMap.get(str));
                }
            }*/
            // For Calculate Premium 
            if(PolicyCalculatePremiumLst.size()>0 && TriggerFactory.isUpdatePremium){  
                system.debug('210701110634');
                // variable that stop recursive call of trigger
                //if (!Test.isRunningTest()) {
                    TriggerFactory.isUpdatePremium = false;
                //}
                ApplicationPremiumCalculator.UpdateQuotePremium(PolicyCalculatePremiumLst,PolicyIDCalculatePremiumSet);
            }
        } 
        // For "account contact relation" update [first policy date]
        If(Trigger.Isafter && Trigger.IsUpdate){
            
            Set<ID>  PolicyIDApp2PolicySet = new   Set<ID>(); // for unique IDs
            Set<ID>  Policy_For_AS_Set = new   Set<ID>();   // for unique IDs + For Accounting Seeds
            List<Policy__C> newAutoRenewalApplications = new List<Policy__C>();
            List<GEO_Factor__c> threatMappings = new List<GEO_Factor__c>();
            Map<Id,Policy__c> policiesMap = new Map<Id,Policy__c>();
            List<Application_Block__c> applicationBlocks = new List<Application_Block__c>();
            Set<Id> policyIds = new Set<Id>();
            Set<Id> accountIds = new Set<Id>();
            Map<String,Decimal> effectiveYearDividendPolicies = new Map<String,Decimal>();
            Map<String,Decimal> expirationYearDividendPolicies = new Map<String,Decimal>();
            Set<String> accountDividendYearPolicies = new Set<String>();
            Map<Id,Policy_Quote__c> quotesMap = new Map<Id,Policy_Quote__c>();
            List<Task> tasksList = new List<Task>();
            for(Policy__C PolicyForloop : Trigger.New){
                if((PolicyForloop.ClonedBy__c=='Renewal 3 Months Before Policy Expiration' && Trigger.oldMap.get(PolicyForloop.Id).ClonedBy__c!='Renewal 3 Months Before Policy Expiration') || (PolicyForloop.ClonedBy__c=='Manual Renewal' && Trigger.oldMap.get(PolicyForloop.Id).ClonedBy__c!='Manual Renewal')  || (PolicyForloop.ClonedBy__c=='Rejected Renewal' && Trigger.oldMap.get(PolicyForloop.Id).ClonedBy__c!='Rejected Renewal')){
                    //policiesMap = new Map<Id,Policy__c>([select id,County__r.Name from Policy__c where Id in: Trigger.new]);
                    //threatMappings = [SELECT Id,Name,From_Date__c,To_Date__c FROM GEO_Factor__c];
                    policyIds.add(PolicyForloop.Id);
                    accountIds.add(PolicyForloop.Account__c);
                }
                if(PolicyForloop.Create_Follow_Up_Task__c && !Trigger.oldMap.get(PolicyForloop.Id).Create_Follow_Up_Task__c){
                    Task tsk = new Task(OwnerId=(PolicyForloop.Follow_Up_Task_Owner__c ==null?PolicyForloop.LastModifiedById:PolicyForloop.Follow_Up_Task_Owner__c),Subject='Follow Up',ActivityDate=PolicyForloop.Follow_Up_Task_Date__c,WhatId=PolicyForloop.Id,Status='In Progress');
                    tasksList.add(tsk);
                }
            }
            
            if(policyIds.size() > 0){
                policiesMap = new Map<Id,Policy__c>([select id,County__r.Name from Policy__c where Id in: policyIds]);
                threatMappings = [SELECT Id,Name,From_Date__c,To_Date__c FROM GEO_Factor__c];
                for(Policy_Quote__c quote : [select id,ADJ_R_O__c,Policy__c from Policy_Quote__c where Policy__c in: policyIds AND Final_Quote__c = true ]){
                    quotesMap.put(quote.Policy__c,quote);
                    System.debug(quote + '==========');
                }
                for(Policy__c pol : [select id,Account__c,Policy_Effective_Year__c,Policy_Expiration_Year__c,Effective_Year_Dividend__c,Dividend_Expiration_Year_Earned__c,Dividend__c,Dividend__r.Effective_Year__c  from Policy__c where Account__c in: accountIds and RecordType.Name = 'Policy']){
                    if(!effectiveYearDividendPolicies.containsKey(pol.Policy_Effective_Year__c + '-' + pol.Account__c)){
                        effectiveYearDividendPolicies.put(pol.Policy_Effective_Year__c + '-' + pol.Account__c,0);
                    }
                    if(pol.Effective_Year_Dividend__c != null){
                        effectiveYearDividendPolicies.put(pol.Policy_Effective_Year__c + '-' + pol.Account__c,effectiveYearDividendPolicies.get(pol.Policy_Effective_Year__c + '-' + pol.Account__c) + pol.Effective_Year_Dividend__c);
                    }
                    
                    if(!expirationYearDividendPolicies.containsKey(pol.Policy_Expiration_Year__c + '-' + pol.Account__c)){
                        expirationYearDividendPolicies.put(pol.Policy_Expiration_Year__c + '-' + pol.Account__c,0);
                    }
                    if(pol.Dividend_Expiration_Year_Earned__c  != null){
                        expirationYearDividendPolicies.put(pol.Policy_Expiration_Year__c + '-' + pol.Account__c,expirationYearDividendPolicies.get(pol.Policy_Expiration_Year__c + '-' + pol.Account__c) + pol.Dividend_Expiration_Year_Earned__c );
                    }
                    if(pol.Dividend__r.Effective_Year__c != null){
                        accountDividendYearPolicies.add(pol.Account__c + '-' + pol.Dividend__r.Effective_Year__c);
                    }
                }
            }
            
            //new policy List  
            Map<String,Policy__c> policyMap = new Map<String,Policy__c> ([SELECT Id, Name, Account__r.Open_Claims__c, Account__r.Name, Account__r.Trade_Name_or_D_B_A__c, Firm_Contact__r.Email, Firm_Contact__r.Phone, Firm_Contact__r.LastName, Firm_Contact__r.FirstName, Account__r.Website__c, Account__r.Establish_Date__c, Account__r.Phone, Account__r.Billing_Address_County__c, Account__r.BillingPostalCode, Account__r.BillingState, Account__r.BillingCity, Account__r.BillingStreet FROM Policy__c WHERE  Id IN: trigger.newMap.keySet()]);
            Map<String,Customer_Application__c> customerAppMap = new Map<String,Customer_Application__c>();
            Map<double, Dividend__c> dividendMap = new Map<double, Dividend__c>();
            List<Dividend__c> dividendList = new List<Dividend__c>([SELECT Id, Effective_Year__c, Start_Date__c, End_Date__c, Percent__c FROM Dividend__c]);
            
            for(Dividend__c div: dividendList){
                dividendMap.put(div.Effective_Year__c, div);
            }
            
            String customerAppRecordTypeId = [SELECT Id,Name,SObjectType FROM RecordType where SObjectType='Customer_Application__c' AND Name = 'Regular Renewal' Limit 1].Id;
            
            for(Policy__C PolicyForloop : Trigger.New){
                if (PolicyForLoop.Status__C =='Accepted'
                    && PolicyForLoop.Is_Accepted_Confirm__c
                    && PolicyForLoop.RecordTypeId==ApplicationPolicyUtil.ApplicationRTID
                    && Trigger.oldMap.get(PolicyForloop.Id).RecordTypeId == ApplicationPolicyUtil.ApplicationRTID){
                        PolicyIDApp2PolicySet.add(PolicyForloop.id);
                        // for Accounting Seeds set
                        If(PolicyForLoop.Is_Allow_to_Generate_AS__c && Label.Process_Accounting_On_Bound == 'Y'){
                            Policy_For_AS_Set.add(PolicyForloop.id);
                        }
                        
                    }
                if((PolicyForloop.ClonedBy__c=='Renewal 3 Months Before Policy Expiration' && Trigger.oldMap.get(PolicyForloop.Id).ClonedBy__c!='Renewal 3 Months Before Policy Expiration') || (PolicyForloop.ClonedBy__c=='Manual Renewal' && Trigger.oldMap.get(PolicyForloop.Id).ClonedBy__c!='Manual Renewal') || (PolicyForloop.ClonedBy__c=='Rejected Renewal' && Trigger.oldMap.get(PolicyForloop.Id).ClonedBy__c!='Rejected Renewal') ){
                    Policy__c newPolicy = new Policy__c();
                    newPolicy = PolicyForloop.clone(false, true);
                    
                    newPolicy.Old_Policy__c = PolicyForloop.Id;
                    newPolicy.Previous_Policy__c = PolicyForloop.Id;
                    newPolicy.PolicyExternalID__c = '';
                    newPolicy.RecordTypeId = ApplicationPolicyUtil.ApplicationRTID;// mapPolicyRecordType.get('Application').Id;

                    system.debug('PolicyForloop.Active_Laywers__c => '+ PolicyForloop.Active_Laywers__c);
                    system.debug('PolicyForloop.Account__r.Open_Claims__c => '+ policyMap.get(PolicyForloop.Id).Account__r.Open_Claims__c);
                    system.debug('PolicyForloop.Policy_Series_Count__c => '+ PolicyForloop.Policy_Series_Count__c);
                    system.debug('PolicyForloop.Renewal_Type__c => '+ PolicyForloop.Renewal_Type__c);
                    if(PolicyForloop.Renewal_Type__c != 'Regular Renewal'){
                        newPolicy.Renewal_Type__c = 'Online Invoice';
                    }
                    newPolicy.Renewal_Type__c = 'Online Invoice';
                    if(policyMap.get(PolicyForloop.Id).Account__r.Open_Claims__c == 0 && newPolicy.Renewal_Type__c == 'Online Invoice'){ // ISBAM_Automatic_Renewal_Eligible__c
                        newPolicy.Status__c = 'Approved';
                    }else{
                        newPolicy.Status__c = 'Application created';
                    }
                    //newPolicy.Active__c = false;
                    newPolicy.Effective_Date__c = PolicyForloop.ClonedBy__c=='Rejected Renewal' ? PolicyForloop.Clone_Application_Effective_Date__c  : PolicyForloop.Expiration_Date__c;//PolicyForloop.Expiration_Date__c.addDays(1);
                    if(PolicyForloop.Cancel_Date__c != null){
                        newPolicy.Effective_Date__c = PolicyForloop.Cancel_Date__c;
                    }
                    if(PolicyForloop.Application_Type__c != 'New Business'){
                        newPolicy.Application_Type__c = 'Renewal';  
                    }
                    
                    newPolicy.Account__c = PolicyForloop.Account__c;
                    newPolicy.Application_Received_Date__c = null;
                    newPolicy.Cancel_Date__c = null;
                    newPolicy.Date_Signed__c = null;
                    newPolicy.Establish_Date__c = null;
                    newPolicy.Expiration_Date__c = newPolicy.Effective_Date__c.addMonths(12);
                    //newPolicy.Account_Contact__c = PolicyForloop.Account_Contact__c;
                    newPolicy.Firm_Contact__C = PolicyForloop.Firm_Contact__C;
                    newPolicy.Policy_Retroactive_Date__c = PolicyForloop.Policy_Retroactive_Date__c;
                    newPolicy.Premium__c = null;
                    newPolicy.Policy_Number__c = null;
                    newPolicy.Premium_Amount__c = null;
                    newPolicy.Original_Premium__c = null;
                    newPolicy.Underwriter_User__c = PolicyForloop.Underwriter_User__c;
                    newPolicy.Support_Staff__c = PolicyForloop.Support_Staff__c;
                    newPolicy.Opportunity__c=null;
                    newPolicy.ClonedBy__c = '';
                    newPolicy.PaymentReceived__c = '';
                    newPolicy.X10x10__c = PolicyForloop.X10x10__c;
                    newPolicy.X5_5_Override__c = PolicyForloop.X5_5_Override__c;
                    newPolicy.Claims_Factor__c = PolicyForloop.Claims_Factor__c;
                    newPolicy.Is_Accepted_Confirm__c = false;
                    newPolicy.Is_Allow_to_Generate_AS__c =false;
                    newPolicy.Is_Allow_Calculate_Premium__c = false;
                    newPolicy.ISBAM_Processed__c = false;
                    newPolicy.Accounting_Processed__c = false;
                    newPolicy.GL_Processing_Date__c = null;
                    newPolicy.Policy_Renew_Status__c = '';
                    newPolicy.Name = PolicyForloop.Name.substringBefore('-') + '-';
                    newPolicy.Treaty_Version__c = null;
                    if(PolicyForloop.ClonedBy__c=='Rejected Renewal'){
                        newPolicy.Name += (Integer.valueOf((PolicyForloop.Name.substringBetween('-','-') == null ? PolicyForloop.Name.substringAfter('-') : PolicyForloop.Name.substringBetween('-','-')).substring(1)) + 1);
                    }else{
                        newPolicy.Name += (Integer.valueOf(PolicyForloop.Name.substringBetween('-','-') == null ? PolicyForloop.Name.substringAfter('-') : PolicyForloop.Name.substringBetween('-','-')) + 1);
                    }
                    system.debug('Name => '+ newPolicy.Name);
                    newPolicy.Name += '-' + String.valueOf(newPolicy.Effective_Date__c.year()).right(2) + (String.valueOf(newPolicy.Effective_Date__c.month()).length()>1 ? String.valueOf(newPolicy.Effective_Date__c.month()): '0' + newPolicy.Effective_Date__c.month());
                    
                    newPolicy.County__c = null;
                    newPolicy.Bound_Date__c = null;
                    newPolicy.Mini_Tail_Override_Date__c = null;
                    newPolicy.Treaty_Correction_Processed__c = false;
                    newPolicy.Create_Follow_Up_Task__c = false;
                    newPolicy.Follow_Up_Task_Date__c = null;
                    newPolicy.Follow_Up_Task_Owner__c = null;
                    newPolicy.sharepoint_folder_id__c = null;
                    newPolicy.Bind_Policy_JSON__c = null;
                    newPolicy.Is_First_Billing_Created__c = false;
                    newPolicy.IBF_Contribtuion__c = 'No IBF Contribution';
                    newPolicy.IBF_Target__c  = null;
                    newPolicy.IBF_Appellate_District__c  = null;
                    newPolicy.IBF_Custom_Amount__c = null;
                    newPolicy.Lost_Description__c = null;
                    newPolicy.Lost_Reason__c = null;
                    newPolicy.Lost_Reason_Sub1__c = null;
                    newPolicy.Lost_Reason_Sub2__c = null;
                    newPolicy.Billing__c = null;
                    newPolicy.Override_Application_Expire_Date__c = null;
                    newPolicy.Quote_Link_Sent_Date__c = null;
                    newPolicy.Quote_Link_Sent_By__c = null;
                    newPolicy.Customer_Application__c = null;
                    
                    //System.debug('======='+PolicyForloop.Policy_Series_Effective_Date__c.year());
                    //System.debug('============='+newPolicy.Effective_Date__c.year());
                    //System.debug('============='+effectiveYearDividendPolicies);
                    //System.debug('============='+expirationYearDividendPolicies);

                    if(PolicyForloop.Policy_Series_Count__c >= 2){
                        Integer year = PolicyForloop.Expiration_Date__c.Year();
                        Decimal percent = 0;
                        if(dividendMap.containsKey(year) && !accountDividendYearPolicies.contains(PolicyForloop.Account__c + '-' + year)){
                            percent = dividendMap.get(year).percent__c;   
                        }
                        Decimal Original_First_5M_Premium  = PolicyForloop.Original_First_5M_Premium__c;
                        newPolicy.ISBAM_policy_dividend__c = (Original_First_5M_Premium  * percent/100).round();
                    }else{
                    	newPolicy.ISBAM_policy_dividend__c = 0;
                    } 
                    
                    /*if(PolicyForloop.Policy_Series_Effective_Date__c != null && PolicyForloop.Policy_Series_Effective_Date__c.year() <= (newPolicy.Effective_Date__c.year()-2)){
                        newPolicy.ISBAM_policy_dividend__c = ((effectiveYearDividendPolicies.containsKey((newPolicy.Effective_Date__c.year() - 1) + '-' + newPolicy.Account__c) ? (effectiveYearDividendPolicies.get((newPolicy.Effective_Date__c.year() - 1) + '-' + newPolicy.Account__c)) : 0) + 
                            + (expirationYearDividendPolicies.containsKey((newPolicy.Effective_Date__c.year() - 1) + '-' + newPolicy.Account__c) ? (expirationYearDividendPolicies.get((newPolicy.Effective_Date__c.year() - 1) + '-' + newPolicy.Account__c)) : 0)).round(System.RoundingMode.HALF_UP);
                    }else{
                        newPolicy.ISBAM_policy_dividend__c = 0;
                    }*/
                    System.debug(PolicyForloop.Id);
                    System.debug(quotesMap);
                    
                    if( quotesMap.containskey(PolicyForloop.Id) && !quotesMap.get(PolicyForloop.Id).ADJ_R_O__c){
                        newPolicy.ADJ_MOD__c = 1;
                    } 
                    
                    /*if(newPolicy.Renewal_Type__c != 'Online Invoice'){
                        newPolicy.Terms_Conditions__c = '<ul><li>Executed <b>Quote and Acceptance Form</b> confirming the firm's limit and deductible selection.</li>' +
                            +'<li>Copy of Firm Letterhead, if not already provided.</li>' +
                            +'<li>ISBA Mutual Premium Payment Invoice confirming the Firm's payment selection.</li></ul>';
                    }else{
                        newPolicy.Terms_Conditions__c = '';
                    }*/
                    newPolicy.Terms_Conditions__c = '';
                    
                    for(GEO_Factor__c factor : threatMappings){
                        if(factor.From_Date__c <= newPolicy.Effective_Date__c &&  factor.To_Date__c >= newPolicy.Effective_Date__c && factor.name == policiesMap.get(PolicyForloop.Id).County__r.Name){
                            newPolicy.County__c = factor.Id;
                        }
                    }
                    if(newPolicy.County__c == null){
                        system.debug(policiesMap.get(PolicyForloop.Id));
                        system.debug(PolicyForloop.Name);
                        applicationBlocks.add(new Application_Block__c(Application_Policy__r=new Policy__c(Old_Policy__c=PolicyForloop.Id),Status__c='Active',Subject__c='County Conflict',Description__c='County Conflict ('+ policiesMap.get(PolicyForloop.Id).County__r.Name +') From Renewal Policy('+PolicyForloop.Name+')'));
                    }
                    newAutoRenewalApplications.add(newPolicy);
                    
                    //Create Customer_Application__c record if renewal application == regular
                    if(newPolicy.Renewal_Type__c == 'Regular Renewal'){
                        Policy__c pol = policyMap.get(PolicyForloop.Id);
                        Account acc = policyMap.get(PolicyForloop.Id).Account__r;
                        
                        Customer_Application__c capp = new Customer_Application__c();
                        capp.RecordTypeId = customerAppRecordTypeId;
                        capp.Effective_Date_Requested__c = newPolicy.Effective_Date__c;
                        capp.Full_Legal_Name_of_the_Firm__c = acc.Name;
                        capp.Account__c = acc.Id;
                        capp.Trade_Name_or_D_B_A__c = acc.Trade_Name_or_D_B_A__c;
                        capp.Street__c = acc.BillingStreet;
                        capp.City__c = acc.BillingCity;
                        capp.State__c = acc.BillingState;
                        capp.Zip_Code__c = acc.BillingPostalCode;
                        capp.County__c = acc.Billing_Address_County__c;
                        capp.Firm_Phone_Number__c = acc.Phone;
                        capp.Website__c = acc.Website__c;
                        capp.Date_Firm_Established__c = acc.Establish_Date__c;
                        capp.Contact__c =  pol.Firm_Contact__c;
                        capp.Contact_Name__c = pol.Firm_Contact__r.FirstName;
                        capp.Contact_Last_Name__c = pol.Firm_Contact__r.LastName;
                        capp.Contact_Phone_Number__c = pol.Firm_Contact__r.Phone;
                        capp.Contact_E_mail_Address__c = pol.Firm_Contact__r.Email;
                        customerAppMap.put(PolicyForloop.Id,capp);
                    }
                    
                }
            }
            
            if(newAutoRenewalApplications.size()>0){
                if(!customerAppMap.keySet().isEmpty()){ 
                    Site mySite = [select Id from Site where Name = 'Customer_Application'];
                    SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite.Id];
                    Insert customerAppMap.values();
                    for(Policy__c pol:newAutoRenewalApplications){
                        if(customerAppMap.containsKey(pol.Old_Policy__c)){
                            pol.Customer_Application__c = customerAppMap.get(pol.Old_Policy__c).Id;
                            customerAppMap.get(pol.Old_Policy__c).Form_Link__c = mySiteDetail.SecureURL + '?id=' + EncodingUtil.urlEncode(PaymentGateway_Ctrl.processEncryption(pol.Customer_Application__c,Label.Encryption_Key_Payment_Id),'UTF-8'); 
                        }
                    }
                }
                Database.SaveResult [] insertResult = Database.insert(newAutoRenewalApplications,false);
                for(integer idx = 0; idx < insertResult.size(); idx++) {
                    if(!insertResult[idx].isSuccess()) {
                        Trigger.new[idx].addError(insertResult[idx].getErrors()[0].getMessage());
                    }
                }
                
                if(!customerAppMap.keySet().isEmpty()){
                    
                    for(Policy__c pol:newAutoRenewalApplications){
                        if(customerAppMap.containsKey(pol.Old_Policy__c)){
                            customerAppMap.get(pol.Old_Policy__c).PolicyId__c = pol.Id;
                        }
                    }
                    
                    Update customerAppMap.values();
                }
            }
            if(applicationBlocks.size()>0){
                insert applicationBlocks;
            }
            if(tasksList.size()>0){
                insert tasksList;
            }
            // For Update "Account contact relation" 
            If(!PolicyIDApp2PolicySet.isEmpty()){               
                ApplicationPolicyUtil.UpdateAccountContactjunction(PolicyIDApp2PolicySet);
            }
            // To Create Accounting Seeds Transaction 
            If(!Policy_For_AS_Set.isEmpty()){               
                ApplicationPolicyUtil.CreateAccuntingSeedsForPolicy(Policy_For_AS_Set);
            }
            
            /*Set<Id> oneQuoteApplications = new Set<Id>();
            for(Policy__C policy : Trigger.New){
                if (policy.Status__C =='Accepted' && policy.Total_Quotes__c == 1){
                    oneQuoteApplications.add(policy.Id);
                }
            }
            if(oneQuoteApplications.size()>0){
                List<Policy_Quote__c> quotes = [select id,Final_Quote__c from Policy_Quote__c where Policy__C in : oneQuoteApplications and Final_Quote__c = false];
                
                for(Policy_Quote__c pq : quotes){
                    pq.Final_Quote__c = true;
                }
                if(quotes.size()>0){
                    update quotes;
                }
            }*/
        }
    }
    
    
    public static string getUrl(){
        boolean isSb = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        if(isSb){
            return 'https://sb-portal.isbamutual.com/';
        }else{
            return 'https://portal.isbamutual.com/';
        }
	}
}