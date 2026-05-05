/*
* 
* Created By     : Ali Zaidi
* Created Date   : 11/08/2016
* Purpose        : This trigger at the time of creation was made to clone opportunities with or without application for cloning and renewal process.
* Name           : OpportunityTrg
* Referenced     : Currently at the time of creation this trigger is referenced on the clone with and without application button on opportunity and the renewal workflow on policy.
* 
*  
*/
trigger OpportunityTrg on Opportunity (before insert, before update, after insert, after update) {
    // Get the Custom Setting to see if the trigger is enabled on not.
    Boolean isEnabled;
    if (Test.isRunningTest()) {
        isEnabled = true;
    } else {
        isEnabled = !(Trigger_Setup__c.getInstance().Opportunity_Trigger_Disabled__c);
    }
    
    if (isEnabled == true) {
        Set<String> setoppToCloneIds = new Set<String>();
        Set<String> setOldOpportunities = new Set<String>();
        Set<String> setOldApplications = new Set<String>();
        Set<String> setOldPolicies = new Set<String>();
        Set<String> setOldAppsAndPols =new Set<String>();
        List<Opportunity> lstClonedOpportunities = new List<Opportunity>();
        List<Policy__c> lstPoliciesToClone = new List<Policy__c>();
        List<Policy_Quote__c> lstQuotesToClone = new List<Policy_Quote__c>();
        List<Policy_Lawyer__c> lstLawyersToClone = new List<Policy_Lawyer__c>();
        List<Policy_AOP__c> lstAOPsToClone = new List<Policy_AOP__c>();
        List<Policy_Endorsement__c> lstEndsToClone = new List<Policy_Endorsement__c>();
        //Map<String,RecordType> mapPolicyRecordType = new Map<String,RecordType>();
        Map<String,Policy__c> maplatestPolicies = new Map<String,Policy__c>();
        
        // To set the name of Opportunity at the time of creation.
        if (Trigger.IsBefore) {
            if (Trigger.IsInsert) {
                for (Opportunity opp : Trigger.New) {
                    if(opp.Name !=null){
                        if (opp.Name.contains('_')) {
                            String[] arrNames = opp.Name.split('_');
                            if (opp.ClonedBy__c != null) {
                                opp.Name = arrNames[0] + '_' + String.valueOf(Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day()) + '_Renewal';
                            } else {
                                opp.Name = arrNames[0] + '_' + String.valueOf(Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day());
                            }
                        } else {
                            if (opp.ClonedBy__c != null) {
                                opp.Name = opp.Name = opp.Name + '_' + String.valueOf(Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day()) + '_Renewal';
                            } else {
                                opp.Name = opp.Name + '_' + String.valueOf(Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day());
                            }
                        }
                    }else{
                        if (opp.ClonedBy__c != null) {
                            opp.Name = String.valueOf(Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day()) + '_Renewal';
                        } else {
                            opp.Name = String.valueOf(Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day());
                        }
                    }
                }
            }
        }
        
        // For Cloning the Opportunity.
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                // Get Opportunities Ids in a Set that are to be cloned.
                for (Opportunity opp : Trigger.New) {
                    if (opp.ClonedBy__c == 'Clone Opportunity With Application' || opp.ClonedBy__c == 'Manual Renewal' || opp.ClonedBy__c == 'Renewal 3 Months Before Policy Expiration') {
                        if(opp.Old_Opprortunity__c != null){
                            setoppToCloneIds.add(opp.Old_Opprortunity__c);
                        }
                    }
                }
                system.debug('Old Opps: ' + setoppToCloneIds);
                // Get All Policies for those Opportunities that are to be cloned.
                for (Policy__c pol : [SELECT Id, Limit__c, Deductible_amount__c, Opportunity__c, Premium__c, Underwriter_User__c, Expiration_Date__c, Policy_Number__c FROM Policy__c WHERE Opportunity__c IN :setoppToCloneIds AND RecordType.DeveloperName = 'Policy']) {
                    maplatestPolicies.put(String.valueOf(pol.Opportunity__c).substring(0, 15), pol);
                    maplatestPolicies.put(String.valueOf(pol.Opportunity__c), pol);
                }
                system.debug('Map of policies: ' + maplatestPolicies);
                // Update the Values from latest Policies to their subsequent Cloned Opportunities
                for (Opportunity opp : Trigger.New) {
                    if (opp.ClonedBy__c == 'Clone Opportunity With Application') {
                        if (maplatestPolicies.containsKey(String.valueOf(opp.Old_Opprortunity__c))) {
                            Policy__c pol = new Policy__c();
                            pol = maplatestPolicies.get(opp.Old_Opprortunity__c);
                            system.debug('Policy: ' + pol);
                            //opp.Limits__c = pol.Coverage__c;
                            //opp.Firm_Size__c = pol.Support_Staff__c;
                            //opp.Underwriter__c = pol.Underwriter_User__c;
                            //opp.Deductible__c = pol.Deductible__c;
                            //opp.Amount = pol.Premium__c;
                            opp.StageName = 'Application Received';
                            opp.Type = 'Existing Business';
                            opp.CloseDate = pol.Expiration_Date__c;
                        } else {
                            opp.addError('No Policy found for the Opportunity!');
                        }
                    } else if (opp.ClonedBy__c == 'Clone Opportunity Without Application') {
                        opp.Policy_Premium__c = null;
                        opp.StageName = 'Application Received';
                        opp.Type = 'Existing Business';
                        opp.CloseDate = Date.today();
                    } else if (opp.ClonedBy__c == 'Manual Renewal' || opp.ClonedBy__c == 'Renewal 3 Months Before Policy Expiration') {
                        opp.Policy_Premium__c = null;
                        opp.StageName = 'Application Received';
                        opp.Type = 'Renewal';
                        opp.CloseDate = Date.today();
                    }
                }
            }
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                // Get the Record Types of Policy__c object to se in the cloned application.
                /*for (RecordType rec : [SELECT DeveloperName, Id, IsActive, Name, SobjectType FROM RecordType WHERE SobjectType = 'Policy__c']) {
                    mapPolicyRecordType.put(rec.Name, rec);
                }*/
                
                // Get the Opportunities that will have Application Clones attached with them.
                for (Opportunity opp : Trigger.New) {
                    if (opp.ClonedBy__c == 'Clone Opportunity With Application' /*|| opp.ClonedBy__c == 'Manual Renewal' || opp.ClonedBy__c == 'Renewal 3 Months Before Policy Expiration'*/) {
                        setOldOpportunities.add(opp.Old_Opprortunity__c);
                        lstClonedOpportunities.add(opp);
                    }
                }
                
                // Get the Applications from Old Opportunities and Clone them to set with the New Opportunities.
                for (Policy__c pol : [SELECT Account__c, Active__c, AOP_Factor__c, AOP_Override_Value__c, AOP_Override__c, AOP_Percentage__c, Application_Received_Date__c, Application_Type__c, Base_Amount__c, Billing__c, Bypass_Default_County_Factor__c, Cancel_Date__c, Cancel_Issue_Date__c, Claims_Factor__c,  ClonedBy__c, County__c, Coverage_Factor_Value__c, Limit__c, Date_Signed__c, Deductible_Balance__c, Deductible_Factor_Value__c, Deductible_Reimburse__c, Deductible_amount__c, Effective_Date__c, Establish_Date__c, Event_Date__c, Excess_Premium__c, Expiration_Date__c, Factor_Premium__c, Factor_Step_0__c, Factor_Step_1__c, Factor_Step_2__c, Factor_Step_3__c, Factor_Step_4__c, Factor_Step_5__c, Factor_Step_6__c, Factor_Step_7__c, Firm_Mod__c, Full_Prior_Acts__c, GEO_Mod__c, Id, Incurred__c, Issue_Date__c, Is_Allow_Calculate_Premium__c, Master_Factor_Default__c, Name, Old_Policy__c, Opportunity__c, Payment_ALAE__c, Payment_Method__c, Per_Claim_Limit__c, PolicyExternalID__c, Policy_ID__c, Policy_Number__c, Policy_Retroactive_Date__c, Policy_Suffix__c, Premium_Amount__c,Original_Premium__c, Premium_Due_Amount__c, Premium__c, RecordTypeId, RecordType.Name, Remaining__c, Renewal_Application_Id__c, Renewal_Opportunity_Id__c, Return_Premium__c, SCH_Mod__c, Status__c, Support_Staff__c, Total_Lawyers_For_Step_0__c, Total_Lawyers_For_Step_1__c, Total_Lawyers_For_Step_2__c, Total_Lawyers_For_Step_3__c, Total_Lawyers_For_Step_4__c, Total_Lawyers_For_Step_5__c, Total_Lawyers_For_Step_6__c, Total_Lawyers_For_Step_7__c, Underwriter_User__c ,Firm_Contact__c FROM Policy__c WHERE Opportunity__c IN :setOldOpportunities]) {
                    for (Opportunity opp : lstClonedOpportunities) {
                        if (pol.Opportunity__c == opp.Old_Opprortunity__c) {
                            Policy__c newPolicy = new Policy__c();
                            newPolicy = pol.clone(false, true);
                            
                            newPolicy.Opportunity__c = opp.Id;
                            newPolicy.Old_Policy__c = pol.Id;
                            newPolicy.PolicyExternalID__c = '';
                            newPolicy.RecordTypeId = ApplicationPolicyUtil.ApplicationRTID;// mapPolicyRecordType.get('Application').Id;
                            newPolicy.Status__c = 'Application Received';
                            //newPolicy.Active__c = false;
                            
                            if (pol.RecordType.Name == 'Application' || pol.RecordType.Name == 'Application Rejected') {
                                newPolicy.Effective_Date__c = Date.today();
                            } else if (pol.RecordType.Name == 'Policy') {
                                newPolicy.Effective_Date__c = pol.Expiration_Date__c.addDays(1);
                            }
                            
                            if (pol.ClonedBy__c == 'Manual Renewal' || pol.ClonedBy__c == 'Renewal 3 Months Before Policy Expiration') {
                                newPolicy.Application_Type__c = 'Renewal';
                            } else {
                                newPolicy.Application_Type__c = pol.Application_Type__c;
                            }
                            
                            newPolicy.Account__c = opp.AccountId;
                            newPolicy.Application_Received_Date__c = null;
                            newPolicy.Cancel_Date__c = null;
                            newPolicy.Date_Signed__c = null;
                            newPolicy.Establish_Date__c = null;
                            newPolicy.Expiration_Date__c = null;
                            //newPolicy.Account_Contact__c = pol.Account_Contact__c;
                            newPolicy.Firm_Contact__c = pol.Firm_Contact__c;
                            newPolicy.Policy_Retroactive_Date__c = null;
                            newPolicy.Premium__c = null;
                            newPolicy.Policy_Number__c = null;
                            newPolicy.Premium_Amount__c = null;
                            newPolicy.Original_Premium__c = null;
                            newPolicy.Underwriter_User__c = pol.Underwriter_User__c;
                            newPolicy.Support_Staff__c = pol.Support_Staff__c;
                            newPolicy.ClonedBy__c = '';
                            newPolicy.Policy_Renew_Status__c='';
                            
                            lstPoliciesToClone.add(newPolicy);
                            setOldAppsAndPols.add(pol.Id);
                        }
                    }
                }
                system.debug('List of Application to clone: ' + lstPoliciesToClone);
                insert lstPoliciesToClone;
                
                // Create a set of policy id's to fetch policy childs and clone them under the new policy.
                for (Policy__c oldPolicy : [SELECT Id, RecordTypeId FROM Policy__c WHERE RecordTypeId != NULL AND Id IN :setOldAppsAndPols]) {
                    for (Policy__c pol : lstPoliciesToClone) {
                        if (oldPolicy.Id == pol.Old_Policy__c && (oldPolicy.RecordTypeId == ApplicationPolicyUtil.ApplicationRTID || oldPolicy.RecordTypeId == ApplicationPolicyUtil.ApplicationRejectedRTID)) {
                            setOldApplications.add(pol.Old_Policy__c);
                        } else if (oldPolicy.Id == pol.Old_Policy__c && (oldPolicy.RecordTypeId == ApplicationPolicyUtil.PolicyRTID)) {
                            setOldPolicies.add(pol.Old_Policy__c);  
                        }
                    }
                }
                
                // Fetch Policy Quotes to Attach with Newly created applications.
                if (setOldPolicies.size() > 0) {
                    for (Policy_Quote__c quo : [SELECT Bypass_Default_Coverage_Factor__c, Bypass_Default_Deductible_Factor__c, Coverage_Factor__c, Coverage_Max_Per_Claim__c, Coverage__c, Deductible_Amount_Step_0__c, Deductible_Amount_Step_1__c, Deductible_Amount_Step_2__c, Deductible_Amount_Step_3__c, Deductible_Amount_Step_4__c, Deductible_Amount_Step_5__c, Deductible_Amount_Step_6__c, Deductible_Amount_Step_7__c, Deductible_Factor__c, Deductible__c, Final_Quote__c, Full_Coverage__c, Id, Name, Percnt_amt_5X5_Step_0__c, Percnt_amt_5X5_Step_1__c, Percnt_amt_5X5_Step_2__c, Percnt_amt_5X5_Step_3__c, Percnt_amt_5X5_Step_4__c, Percnt_amt_5X5_Step_5__c, Percnt_amt_5X5_Step_6__c, Percnt_amt_5X5_Step_7__c, Premium_Rate_5X5__c, Policy__c, Quote_Final_Premium__c, Quote_Premium_Step_0__c, Quote_Premium_Step_1__c, Quote_Premium_Step_2__c, Quote_Premium_Step_3__c, Quote_Premium_Step_4__c, Quote_Premium_Step_5__c, Quote_Premium_Step_6__c, Quote_Premium_Step_7__c, Rate_Before_Deductible_Step_0__c, Rate_Before_Deductible_Step_1__c, Rate_Before_Deductible_Step_2__c, Rate_Before_Deductible_Step_3__c, Rate_Before_Deductible_Step_4__c, Rate_Before_Deductible_Step_5__c FROM Policy_Quote__c WHERE Policy__c IN :setOldPolicies AND Final_Quote__c = true]) {
                        for (Policy__c pol : lstPoliciesToClone) {
                            if (quo.Policy__c == pol.Old_Policy__c) {
                                Policy_Quote__c newQuote = new Policy_Quote__c();
                                newQuote = quo.Clone(false, true);
                                newQuote.Final_Quote__c = false;            
                                newQuote.Policy__c = pol.Id;
                                
                                lstQuotesToClone.add(newQuote);
                            }
                        }
                    }
                }
                
                if (setOldApplications.size() > 0) {
                    for (Policy_Quote__c quo : [SELECT Bypass_Default_Coverage_Factor__c, Bypass_Default_Deductible_Factor__c, Coverage_Factor__c, Coverage_Max_Per_Claim__c, Coverage__c, Deductible_Amount_Step_0__c, Deductible_Amount_Step_1__c, Deductible_Amount_Step_2__c, Deductible_Amount_Step_3__c, Deductible_Amount_Step_4__c, Deductible_Amount_Step_5__c, Deductible_Amount_Step_6__c, Deductible_Amount_Step_7__c, Deductible_Factor__c, Deductible__c, Excess_Final__c, Excess_Step_0__c, Excess_Step_1__c, Excess_Step_2__c, Excess_Step_3__c, Excess_Step_4__c, Excess_Step_5__c, Excess_Step_6__c, Excess_Step_7__c, Final_Quote__c, Full_Coverage__c, Id, Name, Policy__c, Quote_Final_Premium__c, Quote_Premium_Step_0__c, Quote_Premium_Step_1__c, Quote_Premium_Step_2__c, Quote_Premium_Step_3__c, Quote_Premium_Step_4__c, Quote_Premium_Step_5__c, Quote_Premium_Step_6__c, Quote_Premium_Step_7__c, Rate_Before_Deductible_Step_0__c, Rate_Before_Deductible_Step_1__c, Rate_Before_Deductible_Step_2__c, Rate_Before_Deductible_Step_3__c, Rate_Before_Deductible_Step_4__c, Rate_Before_Deductible_Step_5__c FROM Policy_Quote__c WHERE Policy__c IN :setOldApplications]) {
                        for (Policy__c pol : lstPoliciesToClone) {
                            if (quo.Policy__c == pol.Old_Policy__c) {
                                Policy_Quote__c newQuote = new Policy_Quote__c();
                                newQuote = quo.Clone(false, true);
                                newQuote.Final_Quote__c = false;
                                newQuote.Policy__c = pol.Id;
                                
                                lstQuotesToClone.add(newQuote);
                            }
                        }
                    }
                }
                
                insert lstQuotesToClone;
                
                // Fetch Policy Lawyers to Attach with Newly created applications.
                for (Policy_Lawyer__c law : [SELECT Id, Policy__c, Prior_Act_Date__c, Lawyer__c, Hire_Date__c, Account__c, Deleted_Lawyer__c FROM Policy_Lawyer__c WHERE Policy__c IN :setOldAppsAndPols AND Deleted_Lawyer__c = false]) {
                    for (Policy__c pol : lstPoliciesToClone) {
                        if (law.Policy__c == pol.Old_Policy__c) {
                            Policy_Lawyer__c newLawyer = new Policy_Lawyer__c();
                            newLawyer = law.Clone(false, true);
                            newLawyer.Is_Application_Lawyer__c = true;
                            newLawyer.Policy__c = pol.Id;
                            
                            lstLawyersToClone.add(newLawyer);
                        }
                    }
                }
                insert lstLawyersToClone;
                
                // Fetch Policy AOP to Attach with Newly created applications.
                for (Policy_AOP__c AOP : [SELECT AOP__c, Bypass_Default_Factor__c, Factor_Mod__c, Id, Name, Percentage_Value__c, Percentage__c, Policy_Number__c, Policy__c FROM Policy_AOP__c WHERE Policy__c IN :setOldAppsAndPols]) {
                    for (Policy__c pol : lstPoliciesToClone) {
                        if (AOP.Policy__c == pol.Old_Policy__c) {
                            Policy_AOP__c newAOP = new Policy_AOP__c();
                            newAOP = AOP.Clone(false, true);
                            
                            newAOP.Policy__c = pol.Id;
                            
                            lstAOPsToClone.add(newAOP);
                        }
                    }
                }
                insert lstAOPsToClone;
                
                // Fetch all the Descriptive Endorsement record type ids.
                Set<String> setRecordTypeIds = new Set<String>();
                
                for (Endorsement__c endRT : [SELECT Id, Endorsement_Record_Type_ID__c FROM Endorsement__c WHERE Type__c = 'Descriptive']) {
                    setRecordTypeIds.add(endRT.Endorsement_Record_Type_ID__c);
                }
                                
                // Fetch Policy Endorsements to Attach with Newly created applications.
                for (Policy_Endorsement__c ends : [SELECT Additional_Premium__c, AOP__c, Attorney_Firm_Name__c, Attorney_Name__c, Attorney__c, Broker__c, Coverage_Term__c, Date_Deleted__c, Days_Pro_Rated__c, Effective_Date__c, Endorsement_Effective_Date__c, Endorsement_Term__c, Endorsement_Type_For_Lawyer__c, Enter_Manuscript_Language__c, Entity_Name__c, Entity__c, Event_Status__c, Firm_Entity__c, Firm_Name__c, From_Date__c, Hire_Date__c, Id, Matter__c, Name, New_Aggregate__c, New_Per_Claim__c, Old_Aggregate__c, Old_Per_Claim__c, Override_Rating__c, Person_Attorney__c, Policy_Number__c, Policy__c, Premium_5_5__c, Premium_10_10__c, Premium__c, Primary__c, Prior_Act_Date__c, Rate_At__c, RecordType.Description, Step_Override_Value__c, Step_Override__c, Step__c, Term__c, Territory__c, Title_Insurance_Agency__c FROM Policy_Endorsement__c WHERE Policy__c IN :setOldAppsAndPols AND RecordTypeId IN :setRecordTypeIds]) {
                    for (Policy__c pol : lstPoliciesToClone) {
                        if (ends.Policy__c == pol.Old_Policy__c) {
                            Policy_Endorsement__c newEnd = new Policy_Endorsement__c();
                            newEnd = ends.Clone(false, true);
                            newEnd.Event_Status__c = 'Pending';
                            newEnd.Endorsement_Effective_Date__c = pol.Effective_Date__c;
                            newEnd.Policy__c = pol.Id;
                            
                            lstEndsToClone.add(newEnd);
                        }
                    }
                }
                insert lstEndsToClone;
            }
        }
        // End For Cloning Opportunity.
    }
}