public class DeletingAnAttorney_Ctrl {
    public String error{get;set;}
    public Policy_Endorsement__c policyEndorsement{get;set;}
    public String returnURL{get;set;}
    public List<Policy_Lawyer__c> polLawyersList{get;set;}
    public Id selectedLawyer{get;set;}
    public String fromPage{get;set;}
    
    public boolean canRemoved{get;set;}
    public Integer manageIndex{get;set;}
    Id policyId;
    public DeletingAnAttorney_Ctrl(ApexPages.StandardController stdController) {
        error ='';
        this.policyEndorsement = (Policy_Endorsement__c)stdController.getRecord();
        polLawyersList = new List<Policy_Lawyer__c>();
        Policy__c pol;
        
        if(ApexPages.currentPage().getParameters().get('policyId')!=null){
            policyEndorsement.Policy__c = ApexPages.currentPage().getParameters().get('policyId');
            policyId = ApexPages.currentPage().getParameters().get('policyId');
            returnURL = '/'+policyEndorsement.Policy__c;
            pol = [select id,Account__c,Name,Expiration_Date__c,Effective_Date__c from Policy__C where id = : policyEndorsement.Policy__c];
            policyEndorsement.Account__r = [select id,name from Account where id = : pol.Account__c];
            policyEndorsement.Policy__r = pol;
            policyEndorsement.Account__c = pol.Account__c;
        }
        fromPage = ApexPages.currentPage().getParameters().get('fromPage');
        if(ApexPages.currentPage().getParameters().get('manageIndex') != null){
            manageIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('manageIndex'));
        }
        if(fromPage == 'ManageEndorsements'){
            canRemoved = true;
        }
        if(ApexPages.currentPage().getParameters().get('name')!=null){
            policyEndorsement.name =ApexPages.currentPage().getParameters().get('name');
        }
        if(ApexPages.currentPage().getParameters().get('effectiveDate')!=null){
            policyEndorsement.Prior_Act_Date__c =date.parse(ApexPages.currentPage().getParameters().get('effectiveDate'));
        }
        if(ApexPages.currentPage().getParameters().get('id')!=null){
            returnURL = '/'+ApexPages.currentPage().getParameters().get('id');
            Policy_Endorsement__C policyEnd = [select Policy_Lawyer__c,Event_Status__c,Policy__c from Policy_Endorsement__C where id=:ApexPages.currentPage().getParameters().get('id')];
            system.debug('policyEnd :: ' + policyEnd);
            selectedLawyer = policyEnd.Policy_Lawyer__c;
            policyId = policyEnd.Policy__c;
            system.debug('policyEnd.Policy_Lawyer__c :: ' + policyEnd.Policy_Lawyer__c);
            if(policyEnd.Event_Status__c == 'Complete'){
                canRemoved = false;
            }
        }
        if(ApexPages.currentPage().getParameters().get('RecordType')!=null){
            policyEndorsement.RecordTypeId =  ApexPages.currentPage().getParameters().get('RecordType');
        }
        if(policyId!=null){
            System.debug(selectedLawyer);
            if(selectedLawyer != null){
                polLawyersList.addAll([select Id,Lawyer_Name__c,Lawyer__r.Contact__r.ARDC_Number__c,Prior_Act_Date__c,Premium__c,Primary__c,Step__c,Rate_At__c from Policy_Lawyer__c where Id =: selectedLawyer]);
            }
            
            polLawyersList.addAll([select Id,Lawyer_Name__c,Lawyer__r.Contact__r.ARDC_Number__c,Prior_Act_Date__c,Premium__c,Primary__c,Step__c,Rate_At__c from Policy_Lawyer__c where Active__c = true and Deleted_Lawyer__c = false and Policy__c =:policyId and Id !=: selectedLawyer order by Lawyer__r.Contact__r.LastName ASC]);
        }
        if(ApexPages.currentPage().getParameters().get('fromPolicyLawyerRelatedList')!=null){
            Endorsement__c endorsement = [SELECT Description__c, Endorsement_Record_Type_ID__c, Endorsement_Sub_Type__c, Id, Name, Type__c FROM Endorsement__c WHERE Active__c = true AND Endorsement_Sub_Type__c='IL 153' limit 1];
            policyEndorsement.RecordTypeId = endorsement.Endorsement_Record_Type_ID__c;
            policyEndorsement.name = [SELECT Id, Name FROM RecordType WHERE Id =: endorsement.Endorsement_Record_Type_ID__c LIMIT 1].Name;
            if (pol.Effective_Date__c != null) {
                policyEndorsement.Prior_Act_Date__c  = pol.Effective_Date__c;
            } else {
                policyEndorsement.Prior_Act_Date__c = System.today();
            }
        }
        system.debug('policyEndorsement 1: ' + policyEndorsement);
    }
    public void premiumCalculator(){
        try{
            system.debug('policyEndorsement 2: ' + policyEndorsement);
            error='';
            //String masterStepFactorId;
            //String masterLimitFactorId;
            //Step_Rate_Factor__c stepFactors = new Step_Rate_Factor__c();
            //ILF_Coverage_Factor__c lowestLimitFactor = new ILF_Coverage_Factor__c();
            /*Map<Id,Step_Rate_Factor__c> stepFactors = new Map<Id,Step_Rate_Factor__c>();
            Map<Id,ILF_Coverage_Factor__c> lowestLimitFactor = new Map<Id,ILF_Coverage_Factor__c>();
            set<String> setLimitFactorIds = new Set<String>();
            set<String> setDeductibleFactorIds = new Set<String>();
            Map<String,Policy__c> mapOfPolicies = new Map<String,Policy__c>();
            Map<String,ILF_Coverage_Factor__c> mapOfLimits = new Map<String,ILF_Coverage_Factor__c>();
            Map<String,Deductible_Factor__c> mapOfDeductibles = new Map<String,Deductible_Factor__c>();
            Map<String,Policy_Lawyer__c> mapOfPolicyLawyers = new Map<String,Policy_Lawyer__c>();
            List<Policy_Endorsement__c> lstPolicyEndorsements = new List<Policy_Endorsement__c>();
            List<Policy_Endorsement__c> lstPolicyEndorsementsToUpdate = new List<Policy_Endorsement__c>();
            
            // Get the Master Factor Record Id For Step Rate and Limits where default is true.
            //masterStepFactorId = String.valueOf([SELECT Id, Name, Default__c, Factor_Type__c FROM Master_Factor__c WHERE Default__c = true AND Factor_type__c = 'Step Rate' LIMIT 1].Id);
            //masterLimitFactorId = String.valueOf([SELECT Id, Name, Default__c, Factor_Type__c FROM Master_Factor__c WHERE Default__c = true AND Factor_type__c = 'Coverage' LIMIT 1].Id);
            
            // Get the Step Factor To fetch all the Step Rate Factor Values.
            //stepFactors = [SELECT Id, Factor_Value_Step_Rate_0__c, Factor_Value_Step_Rate_1__c, Factor_Value_Step_Rate_2__c, Factor_Value_Step_Rate_3__c, Factor_Value_Step_Rate_4__c, Factor_Value_Step_Rate_5__c, Factor_Value_Step_Rate_6__c, Factor_Value_Step_Rate_7__c, Master_Factor__c FROM Step_Rate_Factor__c WHERE Master_Factor__c =: masterStepFactorId];
            List<Step_Rate_Factor__c> stepRateFactorsList = new List<Step_Rate_Factor__c>([SELECT Id,From_Date__c,To_Date__c, Factor_Value_Step_Rate_0__c, Factor_Value_Step_Rate_1__c, Factor_Value_Step_Rate_2__c, Factor_Value_Step_Rate_3__c, Factor_Value_Step_Rate_4__c, Factor_Value_Step_Rate_5__c, Factor_Value_Step_Rate_6__c, Factor_Value_Step_Rate_7__c, Master_Factor__c FROM Step_Rate_Factor__c WHERE Master_Factor__r.Factor_type__c = 'Step Rate']);
            // Get the lowest coverage factor and its value for primary calculations.
            //lowestLimitFactor = [SELECT Id, Factor_Value__c, Lowest_Coverage__c, Master_Factor__c FROM ILF_Coverage_Factor__c WHERE Master_Factor__c =: masterLimitFactorId AND Lowest_Coverage__c = true];
            List<ILF_Coverage_Factor__c> lowestLimitFactorList = new List<ILF_Coverage_Factor__c>([SELECT Id,From_Date__c,To_Date__c, Factor_Value__c, Lowest_Coverage__c, Master_Factor__c FROM ILF_Coverage_Factor__c WHERE Master_Factor__r.Factor_type__c = 'Coverage' AND Lowest_Coverage__c = true]);
            
            // Get all the Policies related to the endorsements and fill the map.
            for (Policy__c pol : [SELECT Id, Name, Effective_Date__c, Expiration_Date__c, Limit__c, Firm_Mod__c, Deductible_ID__c, Base_Amount__c, Final_Quote_10x10_Value__c,ADJ_MOD__c FROM Policy__c WHERE Id = : policyId]) {
                System.debug('pol---'+pol);
                for(Step_Rate_Factor__c factor : stepRateFactorsList){
                    if(factor.From_Date__c <= pol.Effective_Date__c &&  factor.To_Date__c >= pol.Effective_Date__c){
                        stepFactors.put(pol.Id,factor);
                    }
                }
                for(ILF_Coverage_Factor__c factor : lowestLimitFactorList){
                    if(factor.From_Date__c <= pol.Effective_Date__c &&  factor.To_Date__c >= pol.Effective_Date__c){
                        lowestLimitFactor.put(pol.Id,factor);
                    }
                }
                mapOfPolicies.put(pol.Id,pol);
                setLimitFactorIds.add(pol.Limit__c);
                setDeductibleFactorIds.add(pol.Deductible_ID__c);
            }
            
            // Get all the limits applied to policy endorsements and fill the map.
            for (ILF_Coverage_Factor__c lim : [SELECT Id, Name, Is_5X5_Coverage__c, Is_10X10_Coverage__c, Percnt_amt_5X5_Step_0__c, Percnt_amt_5X5_Step_1__c, Percnt_amt_5X5_Step_2__c, Percnt_amt_5X5_Step_3__c, Premium_Rate_5X5__c, Factor_Value__c FROM ILF_Coverage_Factor__c WHERE Id IN: setLimitFactorIds]) {
                mapOfLimits.put(lim.Id,lim);
            }
            
            // Get all the deductibles applied to policy endorsements and fill the map.
            for (Deductible_Factor__c ded : [SELECT Id, Name, Deductible_Amount__c, Factor_Value__c, Master_Factor__c FROM Deductible_Factor__c WHERE Id IN: setDeductibleFactorIds]) {
                mapOfDeductibles.put(ded.Id,ded);
            }
            system.debug('selectedLawyer :: ' + selectedLawyer);
            // Get all the policy lawyer infor to be updated in policy.
            for (Policy_Lawyer__c polLaw : [SELECT Id, Rate_At__c,Prior_Act_Date__c FROM Policy_Lawyer__c WHERE Id =:  selectedLawyer]) {
                mapOfPolicyLawyers.put(polLaw.Id,polLaw);
            }
            
            // SOQL the Policy Endorsemnts for calculations.
            Decimal stepFactorValue;
            Decimal rate = (mapOfPolicyLawyers.get(selectedLawyer).Rate_At__c == 0 ? 0 : mapOfPolicyLawyers.get(selectedLawyer).Rate_At__c) / 100;
            Decimal amountBeforeDeductible;
            Decimal deductibleFactorAmount;
            
            policyEndorsement.Prior_Act_Date__c = mapOfPolicyLawyers.get(selectedLawyer).Prior_Act_Date__c;
            
            ILF_Coverage_Factor__c limitFactor = mapOfLimits.get(mapOfPolicies.get(policyId).Limit__c);
            Deductible_Factor__c deductibleFactor = mapOfDeductibles.get(mapOfPolicies.get(policyId).Deductible_ID__c);
            
            policyEndorsement.Step__c = ApplicationPolicyUtil.CalculateLawyerStep(mapOfPolicies.get(policyId).Effective_Date__c,policyEndorsement.Prior_Act_Date__c);
            
            
            Date endorsementEffectiveDate = policyEndorsement.Endorsement_Effective_Date__c;
            System.debug('endorsementEffectiveDate---'+endorsementEffectiveDate);
            System.debug('map----'+mapOfPolicies.get(policyId).Expiration_Date__c);
            Decimal daysProRated = endorsementEffectiveDate.daysBetween(mapOfPolicies.get(policyId).Expiration_Date__c);
            policyEndorsement.Term__c = daysProRated / (Date.isLeapYear(Date.today().year()) ?  366 : 365);
            //policyEndorsement.Rate_At__c = mapOfPolicyLawyers.get(policyEndorsement.Policy_Lawyer__c).Rate_At__c;
            
            
            if (policyEndorsement.Step_Override__c == true) {
                if (policyEndorsement.Step_Override_Value__c == 0) {
                    stepFactorValue = stepFactors.containsKey(policyId)?stepFactors.get(policyId).Factor_Value_Step_Rate_0__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 1) {
                    stepFactorValue = stepFactors.containsKey(policyId)?stepFactors.get(policyId).Factor_Value_Step_Rate_1__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 2) {
                    stepFactorValue = stepFactors.containsKey(policyId)?stepFactors.get(policyId).Factor_Value_Step_Rate_2__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 3) {
                    stepFactorValue = stepFactors.containsKey(policyId)?stepFactors.get(policyId).Factor_Value_Step_Rate_3__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 4) {
                    stepFactorValue = stepFactors.containsKey(policyId)?stepFactors.get(policyId).Factor_Value_Step_Rate_4__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 5) {
                    stepFactorValue = stepFactors.containsKey(policyId)?stepFactors.get(policyId).Factor_Value_Step_Rate_5__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 6) {
                    stepFactorValue = stepFactors.containsKey(policyId)?stepFactors.get(policyId).Factor_Value_Step_Rate_6__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 7) {
                    stepFactorValue = stepFactors.containsKey(policyId)?stepFactors.get(policyId).Factor_Value_Step_Rate_7__c:0;
                }
            } else {
                if (policyEndorsement.Step__c == 0) {
                    stepFactorValue = stepFactors.containsKey(policyId)?stepFactors.get(policyId).Factor_Value_Step_Rate_0__c:0;
                } else if (policyEndorsement.Step__c == 1) {
                    stepFactorValue = stepFactors.containsKey(policyId)?stepFactors.get(policyId).Factor_Value_Step_Rate_1__c:0;
                } else if (policyEndorsement.Step__c == 2) {
                    stepFactorValue = stepFactors.containsKey(policyId)?stepFactors.get(policyId).Factor_Value_Step_Rate_2__c:0;
                } else if (policyEndorsement.Step__c == 3) {
                    stepFactorValue = stepFactors.containsKey(policyId)?stepFactors.get(policyId).Factor_Value_Step_Rate_3__c:0;
                } else if (policyEndorsement.Step__c == 4) {
                    stepFactorValue = stepFactors.containsKey(policyId)?stepFactors.get(policyId).Factor_Value_Step_Rate_4__c:0;
                } else if (policyEndorsement.Step__c == 5) {
                    stepFactorValue = stepFactors.containsKey(policyId)?stepFactors.get(policyId).Factor_Value_Step_Rate_5__c:0;
                } else if (policyEndorsement.Step__c == 6) {
                    stepFactorValue = stepFactors.containsKey(policyId)?stepFactors.get(policyId).Factor_Value_Step_Rate_6__c:0;
                } else if (policyEndorsement.Step__c == 7) {
                    stepFactorValue = stepFactors.containsKey(policyId)?stepFactors.get(policyId).Factor_Value_Step_Rate_7__c:0;
                }
            }
            
            amountBeforeDeductible = (100 * stepFactorValue * mapOfPolicies.get(policyId).Base_Amount__c * limitFactor.Factor_Value__c * mapOfPolicies.get(policyId).Firm_Mod__c) / 100;
            amountBeforeDeductible = amountBeforeDeductible.round(System.RoundingMode.HALF_UP);
            
            deductibleFactorAmount = ((stepFactorValue * mapOfPolicies.get(policyId).Base_Amount__c * (lowestLimitFactor.containsKey(policyId)?lowestLimitFactor.get(policyId).Factor_Value__c:0) * mapOfPolicies.get(policyId).Firm_Mod__c) - (stepFactorValue * mapOfPolicies.get(policyId).Base_Amount__c * (lowestLimitFactor.containsKey(policyId)?lowestLimitFactor.get(policyId).Factor_Value__c:0) * mapOfPolicies.get(policyId).Firm_Mod__c * deductibleFactor.Factor_Value__c));
            deductibleFactorAmount = (100 * deductibleFactorAmount) / 100;
            deductibleFactorAmount = deductibleFactorAmount.round(System.RoundingMode.HALF_UP);
            deductibleFactorAmount = deductibleFactorAmount * (-1);
            
            //policyEndorsement.Primary__c = (100 * stepFactorValue * rate * policyEndorsement.Term__c * mapOfPolicies.get(policyId).Base_Amount__c * limitFactor.Factor_Value__c * deductibleFactor.Factor_Value__c * mapOfPolicies.get(policyId).Firm_Mod__c) / 100;
            //policyEndorsement.Primary__c = (amountBeforeDeductible + deductibleFactorAmount) * rate * policyEndorsement.Term__c;
            policyEndorsement.Primary__c = (amountBeforeDeductible + deductibleFactorAmount)  * policyEndorsement.Term__c;
            policyEndorsement.Primary__c = (100 * policyEndorsement.Primary__c) / 100;
            policyEndorsement.Primary__c = policyEndorsement.Primary__c.round(System.RoundingMode.HALF_UP);
            
            if (limitFactor.Is_5X5_Coverage__c == true) {
                if (policyEndorsement.Step_Override__c == true) {
                    if (policyEndorsement.Step_Override_Value__c == 0) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_0__c;
                    } else if (policyEndorsement.Step_Override_Value__c == 1) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_1__c;
                    } else if (policyEndorsement.Step_Override_Value__c == 2) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_2__c;
                    } else if (policyEndorsement.Step_Override_Value__c == 3) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_3__c;
                    } else if (policyEndorsement.Step_Override_Value__c > 3) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Premium_Rate_5X5__c;
                    }
                } else {
                    if (policyEndorsement.Step__c == 0) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_0__c;
                    } else if (policyEndorsement.Step__c == 1) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_1__c;
                    } else if (policyEndorsement.Step__c == 2) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_2__c;
                    } else if (policyEndorsement.Step__c == 3) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_3__c;
                    } else if (policyEndorsement.Step__c > 3) {
                        policyEndorsement.Premium_5_5__c = limitFactor.Premium_Rate_5X5__c;
                    }
                    policyEndorsement.Premium_5_5__c = policyEndorsement.Premium_5_5__c * policyEndorsement.Term__c;
                }
            } else {
                policyEndorsement.Premium_5_5__c = 0.00;
            }
            
            policyEndorsement.Premium_10_10__c = 0.0;
            
            // Removing the 10 X 10 from per lawyer calculations, because 10 X 10 is applicable per policy as per discussion with Gibran 03/01/2017.
            //if (limitFactor.Is_10X10_Coverage__c == true) {
            //    policyEndorsement.Premium_10_10__c = mapOfPolicies.get(policyId).Final_Quote_10x10_Value__c;
            //} else {
            //    policyEndorsement.Premium_10_10__c = 0.0;
            //}
            
            if (policyEndorsement.Override_Rating__c == true) {
                policyEndorsement.Premium__c = policyEndorsement.Primary__c + (policyEndorsement.Override_5_5__c == null ? 0 : policyEndorsement.Override_5_5__c) + (policyEndorsement.Override_10_10__c == null ? 0 : policyEndorsement.Override_10_10__c);
                if(mapOfPolicies.get(policyId).ADJ_MOD__c!=null){
                    policyEndorsement.Premium__c = ( policyEndorsement.Premium__c +  (policyEndorsement.Premium__c * (mapOfPolicies.get(policyId).ADJ_MOD__c - 1)));
                }
                policyEndorsement.Refund_Amount__c = policyEndorsement.Premium__c;
                policyEndorsement.Premium__c = policyEndorsement.Premium__c * (-1);
                policyEndorsement.Premium__c = (100 * policyEndorsement.Premium__c) / 100;
                policyEndorsement.Premium__c = policyEndorsement.Premium__c.round(System.RoundingMode.HALF_UP);
            } else {
                policyEndorsement.Premium__c = policyEndorsement.Primary__c + (policyEndorsement.Premium_5_5__c == null ? 0 : policyEndorsement.Premium_5_5__c) + (policyEndorsement.Premium_10_10__c == null ? 0 : policyEndorsement.Premium_10_10__c);
                if(mapOfPolicies.get(policyId).ADJ_MOD__c!=null){
                    policyEndorsement.Premium__c = ( policyEndorsement.Premium__c +  (policyEndorsement.Premium__c * (mapOfPolicies.get(policyId).ADJ_MOD__c - 1)));
                }
                policyEndorsement.Refund_Amount__c = policyEndorsement.Premium__c;
                policyEndorsement.Premium__c = policyEndorsement.Premium__c * (-1);
                policyEndorsement.Premium__c = (100 * policyEndorsement.Premium__c) / 100;
                policyEndorsement.Premium__c = policyEndorsement.Premium__c.round(System.RoundingMode.HALF_UP);
            }           
            policyEndorsement.Primary__c = policyEndorsement.Primary__c * (-1);*/
            Map<String,Policy_Lawyer__c> mapOfPolicyLawyers = new Map<String,Policy_Lawyer__c>();
            Map<String,Policy__c> mapOfPolicies = new Map<String,Policy__c>();
            for (Policy__c pol : [SELECT Id, Name, Effective_Date__c, Expiration_Date__c, Limit__c, Firm_Mod__c, Deductible_ID__c, Base_Amount__c, Final_Quote_10x10_Value__c,ADJ_MOD__c FROM Policy__c WHERE Id = : policyId]) {
                mapOfPolicies.put(pol.Id,pol);
            }
            
            for (Policy_Lawyer__c polLaw : [SELECT Id, Rate_At__c,Prior_Act_Date__c,Premium__c,Primary__c,X5_5__c,X10_10__c,Excess__c,Added_Date__c FROM Policy_Lawyer__c WHERE Id =:  selectedLawyer]) {
                mapOfPolicyLawyers.put(polLaw.Id,polLaw);
            }
            
            Decimal rate = (mapOfPolicyLawyers.get(selectedLawyer).Rate_At__c == 0 ? 0 : mapOfPolicyLawyers.get(selectedLawyer).Rate_At__c) / 100;
            
            policyEndorsement.Prior_Act_Date__c = mapOfPolicyLawyers.get(selectedLawyer).Prior_Act_Date__c;
            
            policyEndorsement.Step__c = ApplicationPolicyUtil.CalculateLawyerStep(mapOfPolicies.get(policyId).Effective_Date__c,policyEndorsement.Prior_Act_Date__c);
            
            Date endorsementEffectiveDate = policyEndorsement.Endorsement_Effective_Date__c;
            System.debug('endorsementEffectiveDate---'+endorsementEffectiveDate);
            System.debug('map----'+mapOfPolicies.get(policyId).Expiration_Date__c);
            Decimal daysProRated = endorsementEffectiveDate.daysBetween(mapOfPolicies.get(policyId).Expiration_Date__c) + 1;
            policyEndorsement.Term__c = daysProRated / (Date.isLeapYear(Date.today().year()) ?  366 : 365);
            if(mapOfPolicyLawyers.get(selectedLawyer).Added_Date__c != null){
                policyEndorsement.Term__c = daysProRated /  (mapOfPolicyLawyers.get(selectedLawyer).Added_Date__c.daysBetween(mapOfPolicies.get(policyId).Expiration_Date__c) + 1);
            }
            if(policyEndorsement.Term__c > 1){
                policyEndorsement.Term__c = 1;
            }
            policyEndorsement.Primary__c = mapOfPolicyLawyers.get(selectedLawyer).Primary__c == null ? 0 :(mapOfPolicyLawyers.get(selectedLawyer).Primary__c*policyEndorsement.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            policyEndorsement.Excess__c = mapOfPolicyLawyers.get(selectedLawyer).Excess__c == null ? 0 :(mapOfPolicyLawyers.get(selectedLawyer).Excess__c*policyEndorsement.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            policyEndorsement.Premium_5_5__c = mapOfPolicyLawyers.get(selectedLawyer).X5_5__c == null ? 0 :(mapOfPolicyLawyers.get(selectedLawyer).X5_5__c*policyEndorsement.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            policyEndorsement.Premium_10_10__c = mapOfPolicyLawyers.get(selectedLawyer).X10_10__c == null ? 0 :(mapOfPolicyLawyers.get(selectedLawyer).X10_10__c*policyEndorsement.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            policyEndorsement.Premium__c = mapOfPolicyLawyers.get(selectedLawyer).Premium__c == null ? 0 :(mapOfPolicyLawyers.get(selectedLawyer).Premium__c*policyEndorsement.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            policyEndorsement.Refund_Amount__c = mapOfPolicyLawyers.get(selectedLawyer).Premium__c == null ? 0 :(mapOfPolicyLawyers.get(selectedLawyer).Premium__c*policyEndorsement.Term__c).round(System.RoundingMode.HALF_UP);
            
            system.debug('deletingAnAttorney called 1');
        }catch(DMLException e){
            error = e.getdmlMessage(0) + e.getStackTraceString();
        }catch(Exception e){
            error = e.getMessage() +e.getStackTraceString();
            System.debug('Error----'+e.getMessage());
        }
    }
    public PageReference saveEndorsement(){
        try{
            error='';
            if(!policyEndorsement.Override_Rating__c){
                policyEndorsement.Override_10_10__c = null;
                policyEndorsement.Override_5_5__c = null;
            }
            if(!policyEndorsement.Step_Override__c){
                policyEndorsement.Step_Override_Value__c =null;
            }
            policyEndorsement.Policy_Lawyer__c = selectedLawyer;
            
            boolean isNew = false;
            if(policyEndorsement.Id == null){
                isNew = true;
            }
            system.debug('deletingAnAttorney called 2');
            upsert policyEndorsement;
            
            User_Tracking__c userTrack;
            if(isNew){
                userTrack = UserTrackingHandler.createUserTrackingObject('Create', policyEndorsement.Id, policyEndorsement.Name);
            }else{
                userTrack = UserTrackingHandler.createUserTrackingObject('Edit', policyEndorsement.Id, policyEndorsement.Name);
            }
            insert userTrack;
            
            if(fromPage == 'ManageEndorsements'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Sucessfully Saved.'));
                String baseUrl = String.valueOf(System.URL.getOrgDomainUrl().toExternalForm());
                return new PageReference(baseUrl + '/apex/DeletingAnAttorney?fromPage=ManageEndorsements&manageIndex='+manageIndex+'&id='+policyEndorsement.Id);
            }else{
                return new PageReference('/'+policyEndorsement.Id);
            }
        }catch(DMLException e){
            error = e.getdmlMessage(0);
            return null;
        }catch(Exception e){
            error = e.getMessage();
            return null;
        }
    }
}