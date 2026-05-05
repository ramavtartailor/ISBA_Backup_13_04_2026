/*    
Name : PolicyTriggerHandler
Auther : Shweta Fulara
Date : 22nd September 2017
Description : Handler class for Policy_Trg.

Decide policies Renewal type
*/

public class PolicyTriggerHandler{
    
    public static void CreatePolicyQuote(List<Policy__c> newList){
        List<Policy_Quote__c> lstQuotesToClone = new List<Policy_Quote__c>();
        List<Deductible_Factor__c> deductibleFactor = [select id,From_Date__c,To_Date__c,Deductible_Amount__c  from Deductible_Factor__c where Deductible_Amount__c = 0];
        List<ILF_Coverage_Factor__c> coverageFactor = [select id, From_Date__c, To_Date__c, Coverage_Max_Per_Claim__c, Full_Coverage__c from ILF_Coverage_Factor__c  where Coverage_Max_Per_Claim__c <= 1000000 and Full_Coverage__c <= 1000000];
        Map<String, Policy_Quote__c> previousPolicyWithQuoteMap = new Map<String,Policy_Quote__c>();
        Set<String> setPolicyIds = new Set<String>();// Previous Policy List
        
        String coverageFactor5_1m = '';
        String coverageFactor5_5 = '';
        List<ILF_Coverage_Factor__c> coverageFactor1m = new List<ILF_Coverage_Factor__c>();
        
        for(ILF_Coverage_Factor__c cf: coverageFactor){
            if(cf.Coverage_Max_Per_Claim__c == 500000 && cf.Full_Coverage__c == 1000000){
                coverageFactor5_1m = cf.Id;
            }
            else if(cf.Coverage_Max_Per_Claim__c == 500000 && cf.Full_Coverage__c == 500000){
                coverageFactor5_5 = cf.Id;
            }
            else if(cf.Coverage_Max_Per_Claim__c == 1000000 && cf.Full_Coverage__c == 1000000){
                coverageFactor1m.add(cf);
            }
        }
        
        for(Policy__c pol: newList){
            setPolicyIds.add(pol.Previous_Policy__c);
        }
        List<Policy_Quote__c> pulicyQuotes = [SELECT Id, Policy__c, ADJ_MOD__c, X5X5_Override__c, X10X10__c, Additional_Premium__c, Quote_Premium_Amount__c, Coverage__c, Coverage__r.Name,Deductible__r.Name,Coverage__r.Full_Coverage__c ,Policy__r.Name FROM Policy_Quote__c WHERE Policy__c IN: setPolicyIds AND Final_Quote__c = true];
        
        for(Policy_Quote__c obj: pulicyQuotes){
            previousPolicyWithQuoteMap.put(obj.Policy__c, obj);
        }
        
        for(Policy__c pol: newList){
            Policy_Quote__c newQuote = new Policy_Quote__c();
            newQuote.Policy__c = pol.Id;
            newQuote.Quote_Premium_Amount__c = previousPolicyWithQuoteMap.containsKey(pol.Previous_Policy__c) && previousPolicyWithQuoteMap.get(pol.Previous_Policy__c).Quote_Premium_Amount__c != null ? previousPolicyWithQuoteMap.get(pol.Previous_Policy__c).Quote_Premium_Amount__c : null;
            newQuote.Additional_Premium__c = previousPolicyWithQuoteMap.containsKey(pol.Previous_Policy__c) && previousPolicyWithQuoteMap.get(pol.Previous_Policy__c).Additional_Premium__c != null ? previousPolicyWithQuoteMap.get(pol.Previous_Policy__c).Additional_Premium__c : null;
            newQuote.Quote_Expire_Date__c = pol.Effective_Date__c;
            newQuote.Final_Quote__c = false; 
            newQuote.ADJ_MOD__c = previousPolicyWithQuoteMap.containsKey(pol.Previous_Policy__c) && previousPolicyWithQuoteMap.get(pol.Previous_Policy__c).ADJ_MOD__c != null ? previousPolicyWithQuoteMap.get(pol.Previous_Policy__c).ADJ_MOD__c : 0;
            newQuote.X5X5_Override__c = 0;
            newQuote.X10X10__c   = 0;
            
            if(previousPolicyWithQuoteMap.containsKey(pol.Previous_Policy__c) && previousPolicyWithQuoteMap.get(pol.Previous_Policy__c).Coverage__c != null && previousPolicyWithQuoteMap.get(pol.Previous_Policy__c).Coverage__r.Full_Coverage__c <= 1000000){
                newQuote.Coverage__c = previousPolicyWithQuoteMap.get(pol.Previous_Policy__c).Coverage__c;
            }
            else{
                for(ILF_Coverage_Factor__c   factor : coverageFactor1m){
                    if(factor.From_Date__c <= pol.Effective_Date__c &&  factor.To_Date__c >= pol.Effective_Date__c){
                        newQuote.Coverage__c =factor.Id;
                    }
                }
            }
            system.debug('newQuote.Coverage__c => '+newQuote.Coverage__c);
            system.debug('coverageFactor5_1m => '+coverageFactor5_1m);
            if(String.isNotBlank(coverageFactor5_1m) && newQuote.Coverage__c == coverageFactor5_1m){
                newQuote.Coverage__c = coverageFactor5_5;
            }
            
            for(Deductible_Factor__c  factor : deductibleFactor){
                if(factor.From_Date__c <= pol.Effective_Date__c &&  factor.To_Date__c >= pol.Effective_Date__c){
                    newQuote.Deductible__c =factor.Id;
                }
            }            
            lstQuotesToClone.add(newQuote);
        }
        if(!lstQuotesToClone.isEmpty())
            Insert lstQuotesToClone;
    }
    //public static void setRenewalType(List<Policy__c> policyList, Map<Id, Policy__c> oldMap)
    public static void setRenewalType(List<Policy__c> policyList)
    {
        Map<Id, String> renewalMap = new Map<Id, String>();
        
        //Policy__c oldP = new Policy__c();
        
        //oldP = null;
        
        /*
Set<Date> effectiveDates = new Set<Date>();

List<Policy_Claim__c> openClaims = [SELECT Id FROM Policy_Claim__c WHERE Policy__c IN: policyList AND Claim_Close_Status__c = 'Open'];
List<Policy_Claim__c> closeClaims = [SELECT Id FROM Policy_Claim__c WHERE Policy__c IN: policyList AND Claim_Close_Status__c = 'Close'];
*/
        
        for(Policy__c policy: [SELECT Id, Name, Account__r.First_Policy_Date__c, Account__r.First_Claim_Date__c, 
                               Account__r.Last_Policy_Aggregate_Limit__c, Account__r.Last_Policy_Claim_Limit__c, Limit__c, Effective_Date__c,
                               Limit__r.Full_Coverage__c, Limit__r.Coverage_Max_Per_Claim__c, Renewal_Type__c 
                               FROM Policy__c WHERE Id IN: policyList])
        {
            /*
if(oldMap != null){
if(oldMap.containsKey(policy.Id)){
oldP = oldMap.get(policy.Id);
}
}
*/
            
            
            //String versionNum = policy.Name.substringAfter('-');
            String versionNum = policy.Name.substringBetween('-','-') == null ? policy.Name.substringAfter('-') : policy.Name.substringBetween('-','-');
            
            Date fiveYrBack = policy.Effective_Date__c.addYears(-5);
            
            Integer version = Integer.valueOf(versionNum);
            
            System.debug('policy---'+policy);
            System.debug('version---'+version);
            System.debug('policy.Account__r.First_Claim_Date__c---'+policy.Account__r.First_Claim_Date__c);
            System.debug('fiveYrBack---'+fiveYrBack);
            System.debug('policy.Effective_Date__c---'+policy.Effective_Date__c);
            System.debug('policy.Limit__r.Full_Coverage__c---'+policy.Limit__r.Full_Coverage__c);
            System.debug('policy.Limit__r.Coverage_Max_Per_Claim__c---'+policy.Limit__r.Coverage_Max_Per_Claim__c);
            System.debug('Integer.valueOf(Label.AggregateLimit)---'+Integer.valueOf(Label.AggregateLimit));
            System.debug('Integer.valueOf(Label.CoverageMaxPerClaim)---'+Integer.valueOf(Label.CoverageMaxPerClaim));
            
            if(version < 4)
            {
                renewalMap.put(policy.Id, 'Regular Renewal');
            }
            else{
                if(policy.Limit__c != null && version > 4 && (policy.Account__r.First_Claim_Date__c == null || (policy.Account__r.First_Claim_Date__c < fiveYrBack || policy.Account__r.First_Claim_Date__c > policy.Effective_Date__c)) && policy.Account__r.Last_Policy_Aggregate_Limit__c < Integer.valueOf(Label.AggregateLimit) && policy.Account__r.Last_Policy_Claim_Limit__c < Integer.valueOf(Label.CoverageMaxPerClaim)){
                    
                    renewalMap.put(policy.Id, 'EZ Renewal');
                    
                } else {
                    renewalMap.put(policy.Id, 'Regular Renewal');
                }
            }
            
            System.debug('renewalMap---'+renewalMap);
            
            
            /*
if(oldP == null){


}
else{

if(policy.Limit__c != null && policy.Limit__c != oldP.Limit__c)
{
System.debug('renewalMap---'+renewalMap);

if(policy.Renewal_Type__c != 'EZ Renewal' && version > 4 && (policy.Account__r.First_Claim_Date__c == null || 
(policy.Account__r.First_Claim_Date__c != null && policy.Account__r.First_Claim_Date__c < fiveYrBack)
|| (policy.Account__r.First_Claim_Date__c != null && policy.Account__r.First_Claim_Date__c > policy.Effective_Date__c)
) 
&& policy.Limit__r.Full_Coverage__c == Integer.valueOf(Label.AggregateLimit)
&& policy.Limit__r.Coverage_Max_Per_Claim__c == Integer.valueOf(Label.CoverageMaxPerClaim))
{
renewalMap.put(policy.Id, 'EZ Renewal');
}
else
{
renewalMap.put(policy.Id, 'Regular Renewal');
}

}

System.debug('renewalMap---'+renewalMap);
}
*/
        }
        
        List<Policy__c> policiesToUpdate = new List<Policy__c>();
        
        for(Id policyId: renewalMap.keySet())
        {
            policiesToUpdate.add(new Policy__c(Id = policyId, Renewal_Type__c = renewalMap.get(policyId)));
        }
        
        if(!policiesToUpdate.isEmpty())
        {
            update policiesToUpdate;
        }
    }
    public static void updateEndorsementAndPolicyLawyerEffectiveDate(List<Policy__c> policyList, Map<Id, Policy__c> oldMap){
        Map<Id,Policy__c> policyMap = new Map<Id,Policy__c>();
        for(Policy__c policy : policyList){
            if(policy.Effective_Date__c != oldMap.get(policy.Id).Effective_Date__c){
                policyMap.put(policy.Id,policy);
            }
        }
        if(policyMap.size()>0){
            List<Policy_Endorsement__c> listEndorsement = new List<Policy_Endorsement__c>([select Id,Policy__c,Endorsement_Effective_Date__c from Policy_Endorsement__c where Policy__c in: policyMap.keySet()]);
            for(Policy_Endorsement__c endorsement : listEndorsement){
                endorsement.Endorsement_Effective_Date__c = policyMap.get(endorsement.Policy__c).Effective_Date__c;
            }
            update listEndorsement;
            
            List<Policy_Lawyer__c> listLawyers = new List<Policy_Lawyer__c>();
            for(Policy_Lawyer__c lawyer : [select id,Policy__c,Prior_Act_Date__c from Policy_Lawyer__c where Policy__c  in: policyMap.keySet()]){
                if(lawyer.Prior_Act_Date__c == oldMap.get(lawyer.Policy__c).Effective_Date__c){
                    lawyer.Prior_Act_Date__c = policyMap.get(lawyer.Policy__c).Effective_Date__c;
                    listLawyers.add(lawyer);
                }
            }
            if(listLawyers.size()>0){
                update listLawyers;
            }
        }
    }
    
    public static void changeToRegularRenewal(Set<String> policyIds){
        List<Policy__c> policies = [SELECT Id, Customer_Application__c, Effective_Date__c, Account__r.Name, Account__r.Trade_Name_or_D_B_A__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.Billing_Address_County__c, Account__r.Phone, Account__r.Website__c, Account__r.Establish_Date__c, Firm_Contact__r.FirstName, Firm_Contact__r.LastName, Firm_Contact__r.Phone, Firm_Contact__r.Email,
                         (SELECT First_Name_Contact__c, Middle_Name_Contact__c, Last_Name_Contact__c, ISBA_Number__c , ARDC_Number__c, Lawyer__r.Contact__c, Lawyer__r.Contact__r.MobilePhone, Lawyer__r.Contact__r.Birthdate, Contact_Email__c, Lawyer__r.Contact__r.Personal_Email__c FROM Policy_Lawyers__r),//lawyer
                         (SELECT Id FROM Policy_Quotes__r WHERE Customer_Application__c = null)//quotes
                         FROM Policy__c WHERE Id IN: policyIds];
        
        List<Policy__c> bucketAccountPolicies = new List<Policy__c>([select id from Policy__c where Account__r.Name=: Label.Online_NBA_Account ]);
        List<String> fieldNames = new List<String>( Schema.getGlobalDescribe().get('Policy_Quote__c').getDescribe().fields.getMap().keySet() );
        String query =' SELECT ' +String.join( fieldNames, ',' ) +' FROM Policy_Quote__c'  +' WHERE ' +' Policy__c IN: policyIds ';
        
        Map<String, List<Policy_Quote__c>> polQuoteMap = new Map<String, List<Policy_Quote__c>>();
        List<Policy_Quote__c> policyQuotes = new List<Policy_Quote__c>();
        policyQuotes = (List<Policy_Quote__c>) Database.query(query);
        
        for(Policy_Quote__c quo: policyQuotes){
            List<Policy_Quote__c> temp = new List<Policy_Quote__c>();
            if(polQuoteMap.containsKey(quo.Policy__c)){
                temp = polQuoteMap.get(quo.Policy__c);
            }
            temp.add(quo);
            polQuoteMap.put(quo.Policy__c, temp);
        }
            
       
        String customerAppRecordTypeId = [SELECT Id,Name,SObjectType FROM RecordType where SObjectType='Customer_Application__c' AND Name = 'Regular Renewal' Limit 1].Id;
        
        Map<String, Customer_Application__c> cappMap = new Map<String, Customer_Application__c>();
        Map<String, List<Customer_Application_Lawyer__c>> cappLawyerMap = new Map<String, List<Customer_Application_Lawyer__c>>();
        Map<String, List<Policy_Quote__c>> cappQuoteMap = new Map<String, List<Policy_Quote__c>>();
        
        List<Customer_Application_Lawyer__c> lawyersToInsert = new List<Customer_Application_Lawyer__c>();
        
        List<Policy_Quote__c> quotesToInsert = new List<Policy_Quote__c>();
        
        Set<String> cappIds = new Set<String>();
        
        for(Policy__c pol : policies){
            Customer_Application__c  capp = new Customer_Application__c();
            if(String.isNotBlank(pol.Customer_Application__c)){
                capp.Id = pol.Customer_Application__c;
                cappIds.add(pol.Customer_Application__c);
            }
            else{
                capp.RecordTypeId = customerAppRecordTypeId;
            }
            capp.Effective_Date_Requested__c  = pol.Effective_Date__c;
            capp.Full_Legal_Name_of_the_Firm__c = pol.Account__r.Name;
            capp.Account__c = pol.Account__c;
            capp.Trade_Name_or_D_B_A__c = pol.Account__r.Trade_Name_or_D_B_A__c;
            capp.Street__c = pol.Account__r.BillingStreet;
            capp.City__c = pol.Account__r.BillingCity;
            capp.State__c = pol.Account__r.BillingState;
            capp.Zip_Code__c = pol.Account__r.BillingPostalCode;
            capp.County__c = pol.Account__r.Billing_Address_County__c;
            capp.Firm_Phone_Number__c = pol.Account__r.Phone;
            capp.Website__c = pol.Account__r.Website__c;
            capp.Date_Firm_Established__c = pol.Account__r.Establish_Date__c;
            capp.Contact_Name__c = pol.Firm_Contact__r.FirstName;
            capp.Contact_Last_Name__c = pol.Firm_Contact__r.LastName;
            capp.Contact_Phone_Number__c = pol.Firm_Contact__r.Phone;
            capp.Contact_E_mail_Address__c = pol.Firm_Contact__r.Email;
            capp.PolicyId__c = pol.Id;
            
            cappMap.put(pol.Id, capp);
            List<Customer_Application_Lawyer__c> temp_lawyersToInsert = new List<Customer_Application_Lawyer__c>();
            for(Policy_Lawyer__c law : pol.Policy_Lawyers__r){
                
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
                
                lawyersToInsert.add(applicationLawyer);
                temp_lawyersToInsert.add(applicationLawyer);
            }
            
            if(!temp_lawyersToInsert.isEmpty()){
                cappLawyerMap.put(pol.Id, temp_lawyersToInsert);
            }
            
            if(polQuoteMap.ContainsKey(pol.Id)){
                List<Policy_Quote__c> temp_quotesToInsert = new List<Policy_Quote__c>();
                
                for (Policy_Quote__c quo : polQuoteMap.get(pol.Id)) {
                    Policy_Quote__c newQuote = new Policy_Quote__c();
                    newQuote = quo.Clone(false, true);
                    newQuote.Policy__c = bucketAccountPolicies[0].Id;
                    newQuote.Customer_Application__c = pol.Customer_Application__c;
                    
                    quotesToInsert.add(newQuote);
                    temp_quotesToInsert.add(newQuote);
                }
                
				cappQuoteMap.put(pol.Id, temp_quotesToInsert);                
            }
            
        }
        
        if(!cappIds.isEmpty()){
            List<Customer_Application__c> cappList = [SELECT Id, 
                        (SELECT Id FROM Customer_Application_Lawyers__r), 
                        (SELECT Id,Policy__c FROM Quotes__r WHERE Policy__c NOT IN: policyIds) 
                        FROM Customer_Application__c WHERE Id IN: cappIds];
            
            
            List<Customer_Application_Lawyer__c> lawyersToDelete = new List<Customer_Application_Lawyer__c>();
            List<Policy_Quote__c> quotesToDelete = new List<Policy_Quote__c>();
            
            system.debug('deleting lawyer and qoutes');
            
            for(Customer_Application__c capp: cappList){
                system.debug('Lawyers =>'+ capp.Customer_Application_Lawyers__r);
                
                if(!capp.Customer_Application_Lawyers__r.isEmpty()){                    
                    lawyersToDelete.addAll(capp.Customer_Application_Lawyers__r);
                    system.debug('deleting lawyers =>'+lawyersToDelete);
                }
                
                system.debug('Quotes => '+capp.Quotes__r);
                
                if(!capp.Quotes__r.isEmpty()){
                    quotesToDelete.addAll(capp.Quotes__r);
                    system.debug('deleting Quotes => '+quotesToDelete);
                }
            }
            
            if(!lawyersToDelete.isEmpty()){
                Delete lawyersToDelete;
            }
            
            if(!quotesToDelete.isEmpty()){
                Delete quotesToDelete;
            }
        }
        
        if(!cappMap.keySet().isEmpty()){
            upsert cappMap.values();
            
            Site mySite = [select Id from Site where Name = 'Customer_Application'];
            SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite.Id];
            List<Policy__c> updatedPolicies = new List<Policy__c>();
            List<Customer_Application__c> updatedApps = new List<Customer_Application__c>();
            for(String polId : cappMap.keySet()){
                
                Customer_Application__c capp = cappMap.get(polId);
                capp.Form_Link__c = mySiteDetail.SecureURL + '?id=' + EncodingUtil.urlEncode(PaymentGateway_Ctrl.processEncryption(capp.Id,Label.Encryption_Key_Payment_Id),'UTF-8'); 
                updatedApps.add(capp);
                
                Policy__c pol = new Policy__c();
                pol.Id = polId;
                pol.Customer_Application__c = capp.Id;
                updatedPolicies.add(pol);
                
                if(cappLawyerMap.containsKey(polId)){
                    for(Customer_Application_Lawyer__c applicationLawyer: cappLawyerMap.get(polId)){
                        applicationLawyer.Customer_Application__c = capp.Id;
                    }
                }
                
                if(cappQuoteMap.containsKey(polId)){
                    for (Policy_Quote__c newQuote : cappQuoteMap.get(polId)) {
                        newQuote.Customer_Application__c = pol.Customer_Application__c;
                    }
                }
                
            }
            
            if(!updatedApps.isEmpty()){
                Update updatedApps;
            }
            
            if(!updatedPolicies.isEmpty()){
                Update updatedPolicies;
            }

            if(!lawyersToInsert.isEmpty()){
                Insert lawyersToInsert;
            }
            
            if(!quotesToInsert.isEmpty()){
                Insert quotesToInsert;
            }
        }
    }
    
    /*public static void onAfterUpdate(List<Policy__c> newList ,Map<Id,Policy__c> oldMap){
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
        Map<Id,Policy_Quote__c> quotesMap = new Map<Id,Policy_Quote__c>();
        List<Task> tasksList = new List<Task>();
        for(Policy__C PolicyForloop : newList){
            if((PolicyForloop.ClonedBy__c=='Renewal 3 Months Before Policy Expiration' && oldMap.get(PolicyForloop.Id).ClonedBy__c!='Renewal 3 Months Before Policy Expiration') || (PolicyForloop.ClonedBy__c=='Manual Renewal' && oldMap.get(PolicyForloop.Id).ClonedBy__c!='Manual Renewal')){
                //policiesMap = new Map<Id,Policy__c>([select id,County__r.Name from Policy__c where Id in: newList]);
                //threatMappings = [SELECT Id,Name,From_Date__c,To_Date__c FROM GEO_Factor__c];
                policyIds.add(PolicyForloop.Id);
                accountIds.add(PolicyForloop.Account__c);
            }
            if(PolicyForloop.Create_Follow_Up_Task__c && !oldMap.get(PolicyForloop.Id).Create_Follow_Up_Task__c){
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
            for(Policy__c pol : [select id,Account__c,Policy_Effective_Year__c,Policy_Expiration_Year__c,Effective_Year_Dividend__c,Dividend_Expiration_Year_Earned__c  from Policy__c where Account__c in: accountIds and RecordType.Name = 'Policy']){
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
            }
        }
        for(Policy__C PolicyForloop : newList){
            if (PolicyForLoop.Status__C =='Accepted'
                && PolicyForLoop.Is_Accepted_Confirm__c
                && PolicyForLoop.RecordTypeId==ApplicationPolicyUtil.ApplicationRTID){
                    PolicyIDApp2PolicySet.add(PolicyForloop.id);
                    // for Accounting Seeds set
                    If(PolicyForLoop.Is_Allow_to_Generate_AS__c && Label.Process_Accounting_On_Bound == 'Y'){
                        Policy_For_AS_Set.add(PolicyForloop.id);
                    }
                    
                }
            if((PolicyForloop.ClonedBy__c=='Renewal 3 Months Before Policy Expiration' && oldMap.get(PolicyForloop.Id).ClonedBy__c!='Renewal 3 Months Before Policy Expiration') || (PolicyForloop.ClonedBy__c=='Manual Renewal' && oldMap.get(PolicyForloop.Id).ClonedBy__c!='Manual Renewal') || (PolicyForloop.ClonedBy__c=='Rejected Renewal' && oldMap.get(PolicyForloop.Id).ClonedBy__c!='Rejected Renewal') ){
                Policy__c newPolicy = new Policy__c();
                newPolicy = PolicyForloop.clone(false, true);
                
                newPolicy.Old_Policy__c = PolicyForloop.Id;
                newPolicy.Previous_Policy__c = PolicyForloop.Id;
                newPolicy.PolicyExternalID__c = '';
                newPolicy.RecordTypeId = ApplicationPolicyUtil.ApplicationRTID;// mapPolicyRecordType.get('Application').Id;
                newPolicy.Status__c = 'Application created';
                //newPolicy.Active__c = false;
                newPolicy.Effective_Date__c = PolicyForloop.ClonedBy__c=='Rejected Renewal' ? PolicyForloop.Renewal_Effective_Date__c  : PolicyForloop.Expiration_Date__c;//PolicyForloop.Expiration_Date__c.addDays(1);
                newPolicy.Application_Type__c = 'Renewal';
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
                
                if(PolicyForloop.ClonedBy__c=='Rejected Renewal'){
                    newPolicy.Name += (Integer.valueOf((PolicyForloop.Name.substringBetween('-','-') == null ? PolicyForloop.Name.substringAfter('-') : PolicyForloop.Name.substringBetween('-','-')).substring(1)) + 1);
                }else{
                    newPolicy.Name += (Integer.valueOf(PolicyForloop.Name.substringBetween('-','-') == null ? PolicyForloop.Name.substringAfter('-') : PolicyForloop.Name.substringBetween('-','-')) + 1);
                }
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
                //System.debug('======='+PolicyForloop.Policy_Series_Effective_Date__c.year());
                //System.debug('============='+newPolicy.Effective_Date__c.year());
                //System.debug('============='+effectiveYearDividendPolicies);
                //System.debug('============='+expirationYearDividendPolicies);
                if(PolicyForloop.Policy_Series_Effective_Date__c != null && PolicyForloop.Policy_Series_Effective_Date__c.year() <= (newPolicy.Effective_Date__c.year()-2)){
                    newPolicy.ISBAM_policy_dividend__c = (effectiveYearDividendPolicies.containsKey((newPolicy.Effective_Date__c.year() - 1) + '-' + newPolicy.Account__c) ? (effectiveYearDividendPolicies.get((newPolicy.Effective_Date__c.year() - 1) + '-' + newPolicy.Account__c)) : 0) + 
                        + (expirationYearDividendPolicies.containsKey((newPolicy.Effective_Date__c.year() - 1) + '-' + newPolicy.Account__c) ? (expirationYearDividendPolicies.get((newPolicy.Effective_Date__c.year() - 1) + '-' + newPolicy.Account__c)) : 0);
                }else{
                    newPolicy.ISBAM_policy_dividend__c = 0;
                }
                System.debug(PolicyForloop.Id);
                System.debug(quotesMap);
                if(!quotesMap.containsKey(PolicyForloop.Id) || !quotesMap.get(PolicyForloop.Id).ADJ_R_O__c){
                    newPolicy.ADJ_MOD__c = 1;
                } 
                
                newPolicy.Terms_Conditions__c = '<ul><li>Executed <b>Quote and Acceptance Form</b> confirming the firm’s limit and deductible selection.</li>' +
                    +'<li>Copy of Firm Letterhead, if not already provided.</li>' +
                    +'<li>ISBA Mutual Premium Payment Invoice confirming the Firm’s payment selection.</li></ul>';
                for(GEO_Factor__c factor : threatMappings){
                    if(factor.From_Date__c <= newPolicy.Effective_Date__c &&  factor.To_Date__c >= newPolicy.Effective_Date__c && factor.name == policiesMap.get(PolicyForloop.Id).County__r.Name){
                        newPolicy.County__c = factor.Id;
                    }
                }
                if(newPolicy.County__c == null){
                    applicationBlocks.add(new Application_Block__c(Application_Policy__r=new Policy__c(Old_Policy__c=PolicyForloop.Id),Status__c='Active',Subject__c='County Conflict',Description__c='County Conflict ('+ policiesMap.get(PolicyForloop.Id).County__r.Name +') From Renewal Policy('+PolicyForloop.Name+')'));
                }
                newAutoRenewalApplications.add(newPolicy);
            }
        }
        
        if(newAutoRenewalApplications.size()>0){
            Database.SaveResult [] insertResult = Database.insert(newAutoRenewalApplications,false);
            for(integer idx = 0; idx < insertResult.size(); idx++) {
                if(!insertResult[idx].isSuccess()) {
                    newList[idx].addError(insertResult[idx].getErrors()[0].getMessage());
                }
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

    }*/
}