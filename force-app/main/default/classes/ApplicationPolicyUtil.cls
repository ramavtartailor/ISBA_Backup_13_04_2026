public without sharing class ApplicationPolicyUtil {
    
    
/*
//Created By    :   Shoukat Hussain
//Created Date  :   11/07/2016
//Purpose       :   1) Update Premium information to Policy Lawyer object by Final Quote check/uncheck (Methodname:UpdateFinalQuote_ToLawyer)
//              :   2) Update Premium information to Policy object by Final Quote check/uncheck (Methodname:UpdateFinalQuoteToPolicy)
//              :   3) Insert Accountign seeds transaction by Convert to Policy functionality. (Methodname:CreateAccuntingSeedsForPolicy)
//              :   4) Calculate Lawyer Step (Method:GetLawyerStep)
//              :   5) Public Valirables for Record Type.
//              :   6) Get and provide factors values to the referenced classes
Referenced      :   Currently at the time of creation this class is referenced by 
                    QuickQuoteGateway  
                    ApplicationPolicyCalculator
*/
   
    // Public static record type
    public static ID ApplicationRTID  = Schema.SObjectType.Policy__C.getRecordTypeInfosByName().get('Application').getRecordTypeId();
    public static ID PolicyRTID       = Schema.SObjectType.Policy__C.getRecordTypeInfosByName().get('Policy').getRecordTypeId(); 
    public static ID ApplicationRejectedRTID       = Schema.SObjectType.Policy__C.getRecordTypeInfosByName().get('Application Rejected').getRecordTypeId();
  	public static ID PolicyERPRTID       = Schema.SObjectType.Policy__C.getRecordTypeInfosByName().get('ERP Policy').getRecordTypeId(); 
    public static ID SAERPRTID       = Schema.SObjectType.Policy__C.getRecordTypeInfosByName().get('SA-ERP').getRecordTypeId(); 
    public static Master_Factor__c MasterFactorStepObj;
    public static List<Master_factor__C> MasterFactorStepObjList;
    public static Map<ID,AOP_Factor__c>  AOPFactorMap;
    public static Map<ID,Decimal> geoFactorMapStatic;
  
  // Get Lawyer Step Rate Factor
    public static  Map<Integer,Decimal> GetPolicyStepRateFactor(Map<integer,Decimal> LawyerStepRateMap2){
        
        if(MasterFactorStepObj == null){
            MasterFactorStepObj =  [Select (select id,
                                            Factor_Value_Step_Rate_0__c,Factor_Value_Step_Rate_1__c ,
                                            Factor_Value_Step_Rate_2__c,Factor_Value_Step_Rate_3__c ,
                                            Factor_Value_Step_Rate_4__c,Factor_Value_Step_Rate_5__c ,
                                            Factor_Value_Step_Rate_6__c,Factor_Value_Step_Rate_7__c 
                                            from Step_Rate_Factors__r limit 1) 
                                    from Master_Factor__c 
                                    where Default__c=true 
                                    and Factor_Type__c='Step Rate' 
                                    limit 1];
        }
        
        system.debug('MasterFactorStepObj'+MasterFactorStepObj);
        Step_Rate_Factor__c StepRateobj = MasterFactorStepObj.Step_Rate_Factors__r;
        system.debug('StepRateobj'+StepRateobj);
        LawyerStepRateMap2.put(0,StepRateobj.Factor_Value_Step_Rate_0__c);
        LawyerStepRateMap2.put(1,StepRateobj.Factor_Value_Step_Rate_1__c);
        LawyerStepRateMap2.put(2,StepRateobj.Factor_Value_Step_Rate_2__c);
        LawyerStepRateMap2.put(3,StepRateobj.Factor_Value_Step_Rate_3__c);
        LawyerStepRateMap2.put(4,StepRateobj.Factor_Value_Step_Rate_4__c);
        LawyerStepRateMap2.put(5,StepRateobj.Factor_Value_Step_Rate_5__c);
        LawyerStepRateMap2.put(6,StepRateobj.Factor_Value_Step_Rate_6__c);
        LawyerStepRateMap2.put(7,StepRateobj.Factor_Value_Step_Rate_7__c);
        //system.debug('LawyerStepRateMap2'+LawyerStepRateMap2);
        Return LawyerStepRateMap2;
    }
     
    
    // Get Lawyer Step Rate Factor
    public static  Map<Id,Map<Integer,Decimal>> GetPolicyStepRateFactor(list<Policy__c> PolicyLst, Map<Id,Map<integer,Decimal>> LawyerStepRateMap2){
        
        if(MasterFactorStepObjList == null){
            MasterFactorStepObjList =  [select From_Date__c,To_Date__c,(select id,
                                                                        Factor_Value_Step_Rate_0__c,Factor_Value_Step_Rate_1__c ,
                                                                        Factor_Value_Step_Rate_2__c,Factor_Value_Step_Rate_3__c ,
                                                                        Factor_Value_Step_Rate_4__c,Factor_Value_Step_Rate_5__c ,
                                                                        Factor_Value_Step_Rate_6__c,Factor_Value_Step_Rate_7__c 
                                                                        from Step_Rate_Factors__r limit 1) 
                                        from Master_Factor__c 
                                        where Factor_Type__c='Step Rate'];
        }
        
        
        for(Policy__c policy : PolicyLst){
            for(Master_factor__C factor : MasterFactorStepObjList){
                if(factor.From_Date__c <= policy.Effective_Date__c && factor.To_Date__c >= policy.Effective_Date__c ){
                    Step_Rate_Factor__c StepRateobj = factor.Step_Rate_Factors__r;
                    Map<integer,Decimal> lawyerStepRateMap = new Map<integer,Decimal>();
                    lawyerStepRateMap.put(0,StepRateobj.Factor_Value_Step_Rate_0__c);
                    lawyerStepRateMap.put(1,StepRateobj.Factor_Value_Step_Rate_1__c);
                    lawyerStepRateMap.put(2,StepRateobj.Factor_Value_Step_Rate_2__c);
                    lawyerStepRateMap.put(3,StepRateobj.Factor_Value_Step_Rate_3__c);
                    lawyerStepRateMap.put(4,StepRateobj.Factor_Value_Step_Rate_4__c);
                    lawyerStepRateMap.put(5,StepRateobj.Factor_Value_Step_Rate_5__c);
                    lawyerStepRateMap.put(6,StepRateobj.Factor_Value_Step_Rate_6__c);
                    lawyerStepRateMap.put(7,StepRateobj.Factor_Value_Step_Rate_7__c);
                    LawyerStepRateMap2.put(policy.Id,lawyerStepRateMap);
                }
            }
        }
        
        Return LawyerStepRateMap2;
    }
  
    // Maintain AOP Factor Map                
    public static Map<ID,Decimal> GetPolicyAOPMod(Set<ID> PolicyIDSet,Map<ID,Decimal> Policy_AOPRollupMap){
        System.debug(PolicyIDSet + 'PolicyIDSet======');
        // List for All policyAOP related to AllPolicies
        list<Policy_AOP__c> PolicyAOPLst =  [select id,Policy__c,AOP__c,
                                             Factor_Mod__c,Percentage_Value__c,Percentage__c,Policy__r.Effective_Date__c 
                                             from Policy_AOP__c 
                                             where Policy__c in :PolicyIDSet];    
        System.debug('PolicyAOPLst---'+PolicyAOPLst);
        // SEt for Unique ID For AOP Factor
        /*Set<ID> AOPFactorIDSet = new Set<ID>();
        For(Policy_AOP__C PolicyAOPFor : PolicyAOPLst){
            AOPFactorIDSet.add(PolicyAOPFor.AOP__c);
        } */
        System.debug('AOPFactorMap---'+AOPFactorMap);
        if(AOPFactorMap == null){
            AOPFactorMap  = new  Map<ID,AOP_Factor__c>([select ID,name,AOP_Mod__c 
                                                                           from AOP_Factor__C]);
            System.debug('AOPFactorMap---'+AOPFactorMap);
        }
        System.debug('AOPFactorMap---'+AOPFactorMap);
        // Update PolicyAOPLst by AOP Factor
        For(Policy_AOP__C PolicyAOPFor : PolicyAOPLst){
            //PolicyAOPFor.Factor_Mod__c = AOPFactorMap.get(PolicyAOPFor.ID).AOP_Mod__c;
            //PolicyAOPFor.Factor_Mod__c = AOPFactorMap.get(PolicyAOPFor.AOP__c).AOP_Mod__c;
            
            /*if(PolicyAOPFor.Factor_Mod__c == null){
                PolicyAOPFor.Factor_Mod__c = 0;
            }*/
            //PolicyAOPFor.Percentage_Value__c = PolicyAOPFor.Factor_Mod__c *   PolicyAOPFor.Percentage__c / 100;
            // Map for aggrigate sum policy wise
            
            if(!Policy_AOPRollupMap.containsKey(PolicyAOPFor.policy__C)) {          
                Policy_AOPRollupMap.put(PolicyAOPFor.Policy__C,0);
            }
            //integer n1 = integer.valueOf(Policy_AOPRollupMap.get(PolicyAOPFor.Policy__C).AOP_Factor__c) ; // += Integer.valueOf(PolicyAOPFor.Percentage_Value__c);
            Decimal oldval = Policy_AOPRollupMap.get(PolicyAOPFor.Policy__C) ;//+= Integer.valueOf(PolicyAOPFor.Percentage_Value__c);
            Decimal newval = PolicyAOPFor.Percentage_Value__c;
            Policy_AOPRollupMap.put(PolicyAOPFor.Policy__C,oldval+newval);            
        }
        Try{
            //Database.update(PolicyAOPLst);
        }
        catch(DmlException e) {
            System.debug('Error: ' + e.getMessage());       
        }
        Return Policy_AOPRollupMap;       
    }
    

    
    // Maintain Base Factor                
    public static Integer GetPolicyBaseAmt(){
        return TriggerFactory.GetPolicyBaseAmt();
    }
    
    // Maintain Base Factor                
    public static Map<Id,Decimal> GetPolicyBaseAmt(list<Policy__c> PolicyLst,Map<Id,Decimal> PremiumBaseVal){
        List<Master_factor__C> MasterFactorBaseObj =  TriggerFactory.getBaseValueMasterFactor();      
            
            for(Policy__c policy : PolicyLst){
                for(Master_factor__C factor : MasterFactorBaseObj){
                    if(factor.From_Date__c <= policy.Effective_Date__c && factor.To_Date__c >= policy.Effective_Date__c ){
                        Base_Factor__c BaseFactorObj = factor.Base_Factors__r;
                        Map<integer,Decimal> lawyerStepRateMap = new Map<integer,Decimal>();
                        PremiumBaseVal.put(policy.Id,BaseFactorObj.Base_Amount__c);
                    }
                }
            }
            Return PremiumBaseVal;
    }
    
  // Get GEO Factor
    public static  Map<ID,Decimal> GetPolicyGEOFactor(Set<ID> GEOFactorIDSet, Map<ID,Decimal> GEOFactorMap){
        // Captured all GEO Factor which are involved in Policies
        if(geoFactorMapStatic == null){
            geoFactorMapStatic = new Map<ID,Decimal>();
            List<GEO_Factor__c>  GEOFactorLst  = new  List<GEO_Factor__c>([select ID,Name,Region_Factor_Value__c from GEO_Factor__c where ID in :GEOFactorIDSet]);
            For(GEO_Factor__c GEOFActorFor : GEOFactorLst){
                geoFactorMapStatic.put(GEOFActorFor.id,GEOFActorFor.Region_Factor_Value__c);
            }
            
        }
        Return geoFactorMapStatic;
    }

    

    // Update Premium of Final Quote to Policy Lawyer
    Public static void UpdateFinalQuote_ToLawyer(Map<ID,Policy_Quote__c> PFinalQuoteMap,Boolean IsFinalChecked){
        
        if(PFinalQuoteMap.size()>0 ){
            // Get Policy list to get relevant Lawyers
            List<Policy_Quote__C> PQLst = PFinalQuoteMap.values();
            Set<ID> PIDSet = new Set<ID>();
            For(Policy_Quote__C PQLoop : PQLst){
                PIDSet.add(PQLoop.Policy__c);         
            }
            Map<Id,PolicyLawerCountWrapper> policyLawersCountMap = new Map<Id,PolicyLawerCountWrapper>();
            system.debug('20170102 PIDSet'+PIDSet);
            If(PIDSet.size()>0){
                /*List<Policy__c> PolicyLst = [select ID,
                                             Total_Lawyers_For_Step_0__c,Total_Lawyers_For_Step_1__c,
                                             Total_Lawyers_For_Step_2__c,Total_Lawyers_For_Step_3__c,
                                             Total_Lawyers_For_Step_4__c,Total_Lawyers_For_Step_5__c,
                                             Total_Lawyers_For_Step_6__c,Total_Lawyers_For_Step_7__c
                                             From Policy__C where ID in : PIDSet
                                             ];*/
                /*Map<Id,Policy__c> policyMap = new Map<Id,Policy__c>([select id,Total_Lawyers_Rate_For_Step_0__c,Total_Lawyers_Rate_For_Step_1__c,Total_Lawyers_Rate_For_Step_2__c,
                                                                     Total_Lawyers_Rate_For_Step_3__c,Total_Lawyers_Rate_For_Step_4__c,Total_Lawyers_Rate_For_Step_5__c,
                                                                    Total_Lawyers_Rate_For_Step_6__c,Total_Lawyers_Rate_For_Step_7__c from Policy__C where ID in : PIDSet]);*/
                List<Policy_Lawyer__C> PLawyerLst = [select id,Policy__c,Premium__c,Primary__c,X5_5__c,Step__c,Rate_At__c
                                                     from Policy_Lawyer__c where Policy__C in :PIDSet ];
                System.debug('PLawyerLst---'+PLawyerLst);
                for(Policy_Lawyer__C lawers : PLawyerLst){
                    if(lawers.Step__c==0){
                        if(policyLawersCountMap.containsKey(lawers.Policy__c)){
                            PolicyLawerCountWrapper wrapper = policyLawersCountMap.get(lawers.Policy__c);
                            wrapper.step0= wrapper.step0+1;
                            wrapper.rate0 = wrapper.rate0 + lawers.Rate_At__c;
                            policyLawersCountMap.put(lawers.Policy__c, wrapper);
                        }else{
                            PolicyLawerCountWrapper wrapper = new PolicyLawerCountWrapper();
                            wrapper.step0=1;
                            wrapper.rate0 = lawers.Rate_At__c;
                            policyLawersCountMap.put(lawers.Policy__c, wrapper);
                        }
                    }else if(lawers.Step__c==1){
                        if(policyLawersCountMap.containsKey(lawers.Policy__c)){
                            PolicyLawerCountWrapper wrapper = policyLawersCountMap.get(lawers.Policy__c);
                            wrapper.step1= wrapper.step1+1;
                            wrapper.rate1 = wrapper.rate1 + lawers.Rate_At__c;
                            policyLawersCountMap.put(lawers.Policy__c, wrapper);
                        }else{
                            PolicyLawerCountWrapper wrapper = new PolicyLawerCountWrapper();
                            wrapper.step1=1;
                            wrapper.rate1 = lawers.Rate_At__c;
                            policyLawersCountMap.put(lawers.Policy__c, wrapper);
                        }
                    }else if(lawers.Step__c==2){
                        if(policyLawersCountMap.containsKey(lawers.Policy__c)){
                            PolicyLawerCountWrapper wrapper = policyLawersCountMap.get(lawers.Policy__c);
                            wrapper.step2= wrapper.step2+1;
                            wrapper.rate2 = wrapper.rate2 + lawers.Rate_At__c;
                            policyLawersCountMap.put(lawers.Policy__c, wrapper);
                        }else{
                            PolicyLawerCountWrapper wrapper = new PolicyLawerCountWrapper();
                            wrapper.step2=1;
                            wrapper.rate2 = lawers.Rate_At__c;
                            policyLawersCountMap.put(lawers.Policy__c, wrapper);
                        }
                    }else if(lawers.Step__c==3){
                        if(policyLawersCountMap.containsKey(lawers.Policy__c)){
                            PolicyLawerCountWrapper wrapper = policyLawersCountMap.get(lawers.Policy__c);
                            wrapper.step3= wrapper.step3+1;
                            wrapper.rate3 = wrapper.rate3 + lawers.Rate_At__c;
                            policyLawersCountMap.put(lawers.Policy__c, wrapper);
                        }else{
                            PolicyLawerCountWrapper wrapper = new PolicyLawerCountWrapper();
                            wrapper.step3=1;
                            wrapper.rate3 =  lawers.Rate_At__c;
                            policyLawersCountMap.put(lawers.Policy__c, wrapper);
                        }
                    }else if(lawers.Step__c==4){
                        if(policyLawersCountMap.containsKey(lawers.Policy__c)){
                            PolicyLawerCountWrapper wrapper = policyLawersCountMap.get(lawers.Policy__c);
                            wrapper.step4= wrapper.step4+1;
                            wrapper.rate4 = wrapper.rate4 + lawers.Rate_At__c;
                            policyLawersCountMap.put(lawers.Policy__c, wrapper);
                        }else{
                            PolicyLawerCountWrapper wrapper = new PolicyLawerCountWrapper();
                            wrapper.step4=1;
                            wrapper.rate4 =  lawers.Rate_At__c;
                            policyLawersCountMap.put(lawers.Policy__c, wrapper);
                        }
                    }else if(lawers.Step__c==5){
                        if(policyLawersCountMap.containsKey(lawers.Policy__c)){
                            PolicyLawerCountWrapper wrapper = policyLawersCountMap.get(lawers.Policy__c);
                            wrapper.step5= wrapper.step5+1;
                            wrapper.rate5 = wrapper.rate5 + lawers.Rate_At__c;
                            policyLawersCountMap.put(lawers.Policy__c, wrapper);
                        }else{
                            PolicyLawerCountWrapper wrapper = new PolicyLawerCountWrapper();
                            wrapper.step5=1;
                            wrapper.rate5 = lawers.Rate_At__c;
                            policyLawersCountMap.put(lawers.Policy__c, wrapper);
                        }
                    }else if(lawers.Step__c==6){
                        if(policyLawersCountMap.containsKey(lawers.Policy__c)){
                            PolicyLawerCountWrapper wrapper = policyLawersCountMap.get(lawers.Policy__c);
                            wrapper.step6= wrapper.step6+1;
                            wrapper.rate6 = wrapper.rate6 + lawers.Rate_At__c;
                            policyLawersCountMap.put(lawers.Policy__c, wrapper);
                        }else{
                            PolicyLawerCountWrapper wrapper = new PolicyLawerCountWrapper();
                            wrapper.step6=1;
                            wrapper.rate6 = lawers.Rate_At__c;
                            policyLawersCountMap.put(lawers.Policy__c, wrapper);
                        }
                    }else if(lawers.Step__c==7){
                        if(policyLawersCountMap.containsKey(lawers.Policy__c)){
                            PolicyLawerCountWrapper wrapper = policyLawersCountMap.get(lawers.Policy__c);
                            wrapper.step7= wrapper.step7+1;
                            wrapper.rate7 = wrapper.rate7 + lawers.Rate_At__c;
                            policyLawersCountMap.put(lawers.Policy__c, wrapper);
                        }else{
                            PolicyLawerCountWrapper wrapper = new PolicyLawerCountWrapper();
                            wrapper.step7=1;
                            wrapper.rate7 = lawers.Rate_At__c;
                            policyLawersCountMap.put(lawers.Policy__c, wrapper);
                        }
                    }
                }
                
                system.debug('20170102 PLawyerLst'+PLawyerLst);
                
                If(PLawyerLst.size()>0){
                    system.debug('20170102 PLawyerLst');
                    //Map<ID,Policy__C> PolicyListMap = new Map<ID,Policy__C>(PolicyLst); // to get "Total number of Lawyer for Step 0 to 7"
                    Integer TotalLawyer =0;
                    system.debug('20170102 PLawyerLst');
                    For(Policy_Lawyer__C PLawyerLoop : PLawyerLst){
                        // IsFinalChecked Yes/No, in both cases following fields should be null
                        PLawyerLoop.Premium__c = null;
                        PLawyerLoop.Primary__c = null;
                        PLawyerLoop.X5_5__c    = null;
                        PLawyerLoop.X10_10__c    = null;
                        system.debug('20170102 PLawyerLst');
                        //If 5x5 override valud is given then don't make calculation for 5x5.
                       // If(PFinalQuoteMap.get(PLawyerLoop.Policy__C).X5X5_Override__c!=null) Continue;
                        If(IsFinalChecked){
                            TotalLawyer = 0;
                            //system.debug('TotalLawyer2 '+PolicyListMap);
                            //system.debug('TotalLawyer2 '+ PolicyListMap.get(PLawyerLoop.Policy__c).Total_Lawyers_For_Step_0__c);
                            IF(PLawyerLoop.Step__c==0){
                                //TotalLawyer = Integer.valueOf(PolicyListMap.get(PLawyerLoop.Policy__c).Total_Lawyers_For_Step_0__c);
                                TotalLawyer = Integer.valueOf(policyLawersCountMap.get(PLawyerLoop.Policy__c).step0);
                                //system.debug('check1'+PLawyerLoop.Policy__C);
                               
                            
                                System.debug('policyId'+PLawyerLoop.Policy__c);
                                system.debug('PFinalQuoteMap----'+PFinalQuoteMap);
                                system.debug('PFinalQuoteMap----'+PFinalQuoteMap.get(PLawyerLoop.Policy__c));
                                system.debug('policyLawersCountMap----'+policyLawersCountMap);
                                system.debug('============'+PFinalQuoteMap.get(PLawyerLoop.Policy__C).Primary_Step_0__c);
                                system.debug('============'+policyLawersCountMap.get(PLawyerLoop.Policy__c).rate0/100); 
                                PLawyerLoop.Primary__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).Primary_Step_0__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate0/100);
                                PLawyerLoop.Excess__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).Excess_Step_0__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate0/100);
                                
                                PLawyerLoop.Premium__c =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step_0__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate0/100);
                                if(PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step0_For_5X5__c!=null){
                                    //PLawyerLoop.X5_5__c    =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step0_For_5X5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate0/100);
                                    PLawyerLoop.X5_5__c    =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step0_For_5X5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).step0);
                                }
                            }
                            
                            Else IF(PLawyerLoop.Step__c==1){
                                //TotalLawyer = Integer.valueOf(PolicyListMap.get(PLawyerLoop.Policy__c).Total_Lawyers_For_Step_1__c);
                                TotalLawyer = Integer.valueOf(policyLawersCountMap.get(PLawyerLoop.Policy__c).step1);
                                
                                PLawyerLoop.Primary__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).Primary_Step_1__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate1/100);
                                PLawyerLoop.Excess__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).Excess_Step_1__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate1/100);
                                
                                PLawyerLoop.Premium__c =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step_1__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate1/100);
                                if(PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step1_For_5X5__c!=null){
                                    //PLawyerLoop.X5_5__c    =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step1_For_5X5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate1/100);
                                    PLawyerLoop.X5_5__c    =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step1_For_5X5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).step1);
                                }
                            }
                            Else IF(PLawyerLoop.Step__c==2){
                                //TotalLawyer = Integer.valueOf(PolicyListMap.get(PLawyerLoop.Policy__c).Total_Lawyers_For_Step_2__c);
                                TotalLawyer = Integer.valueOf(policyLawersCountMap.get(PLawyerLoop.Policy__c).step2);
                                
                                PLawyerLoop.Primary__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).Primary_Step_2__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate2/100);
                                PLawyerLoop.Excess__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).Excess_Step_2__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate2/100);
                                
                                PLawyerLoop.Premium__c =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step_2__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate2/100); 
                                if(PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step2_For_5X5__c!=null){
                                    //PLawyerLoop.X5_5__c    =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step2_For_5X5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate2/100);
                                    PLawyerLoop.X5_5__c    =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step2_For_5X5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).step2);
                                }
                            }                      
                            Else IF(PLawyerLoop.Step__c==3){
                                //TotalLawyer = Integer.valueOf(PolicyListMap.get(PLawyerLoop.Policy__c).Total_Lawyers_For_Step_3__c);
                                TotalLawyer = Integer.valueOf(policyLawersCountMap.get(PLawyerLoop.Policy__c).step3);
                                
                                PLawyerLoop.Primary__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).Primary_Step_3__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate3/100);
                                PLawyerLoop.Excess__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).Excess_Step_3__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate3/100);
                                
                                PLawyerLoop.Premium__c =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step_3__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate3/100); 
                                if(PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step3_For_5X5__c!=null){
                                    //PLawyerLoop.X5_5__c    =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step3_For_5X5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate3/100);
                                    PLawyerLoop.X5_5__c    =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step3_For_5X5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).step3);
                                }
                            }
                            Else IF(PLawyerLoop.Step__c==4){
                                //TotalLawyer = Integer.valueOf(PolicyListMap.get(PLawyerLoop.Policy__c).Total_Lawyers_For_Step_4__c);
                                TotalLawyer = Integer.valueOf(policyLawersCountMap.get(PLawyerLoop.Policy__c).step4);
                                
                                PLawyerLoop.Primary__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).Primary_Step_4__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate4/100);
                                PLawyerLoop.Excess__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).Excess_Step_4__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate4/100);
                                
                                PLawyerLoop.Premium__c =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step_4__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate4/100); 
                                if(PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step4_For_5X5__c!=null){
                                    //PLawyerLoop.X5_5__c    =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step4_For_5X5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate4/100);
                                    PLawyerLoop.X5_5__c    =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step4_For_5X5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).step4);
                                }
                            }
                            Else IF(PLawyerLoop.Step__c==5){
                                //TotalLawyer = Integer.valueOf(PolicyListMap.get(PLawyerLoop.Policy__c).Total_Lawyers_For_Step_5__c);
                                TotalLawyer = Integer.valueOf(policyLawersCountMap.get(PLawyerLoop.Policy__c).step5);
                                
                                PLawyerLoop.Primary__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).Primary_Step_5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate5/100);
                                PLawyerLoop.Excess__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).Excess_Step_5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate5/100);
                                
                                PLawyerLoop.Premium__c =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step_5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate5/100); 
                                if(PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step5_For_5X5__c!=null){
                                    //PLawyerLoop.X5_5__c    =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step5_For_5X5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate5/100);
                                    PLawyerLoop.X5_5__c    =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step5_For_5X5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).step5);
                                }
                            }
                            Else IF(PLawyerLoop.Step__c==6){
                                //TotalLawyer = Integer.valueOf(PolicyListMap.get(PLawyerLoop.Policy__c).Total_Lawyers_For_Step_6__c);
                                TotalLawyer = Integer.valueOf(policyLawersCountMap.get(PLawyerLoop.Policy__c).step6);
                                
                                PLawyerLoop.Primary__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).Primary_Step_6__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate6/100);
                                PLawyerLoop.Excess__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).Excess_Step_6__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate6/100);
                                
                                PLawyerLoop.Premium__c =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step_6__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate6/100); 
                                if(PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step6_For_5X5__c!=null){
                                    //PLawyerLoop.X5_5__c    =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step6_For_5X5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate6/100);
                                    PLawyerLoop.X5_5__c    =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step6_For_5X5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).step6);
                                }
                            }
                            Else IF(PLawyerLoop.Step__c==7){
                                //TotalLawyer = Integer.valueOf(PolicyListMap.get(PLawyerLoop.Policy__c).Total_Lawyers_For_Step_7__c);
                                TotalLawyer = Integer.valueOf(policyLawersCountMap.get(PLawyerLoop.Policy__c).step7);
                                
                                PLawyerLoop.Primary__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).Primary_Step_7__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate7/100);
                                PLawyerLoop.Excess__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).Excess_Step_7__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate7/100);
                                
                                
                                PLawyerLoop.Premium__c =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step_7__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate7/100); 
                                if(PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step7_For_5X5__c!=null){
                                    //PLawyerLoop.X5_5__c    =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step7_For_5X5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).rate7/100);
                                    PLawyerLoop.X5_5__c    =  PFinalQuoteMap.get(PLawyerLoop.Policy__C).Quote_Premium_Step7_For_5X5__c/(policyLawersCountMap.get(PLawyerLoop.Policy__c).step7);
                                }
                            }
                            //PLawyerLoop.Premium__c =  (PLawyerLoop.Premium__c / TotalLawyer ) * ((PLawyerLoop.Rate_At__c!=null?PLawyerLoop.Rate_At__c:100)/100);
                            PLawyerLoop.Premium__c =  (PLawyerLoop.Premium__c) * ((PLawyerLoop.Rate_At__c!=null?PLawyerLoop.Rate_At__c:100)/100);
                            PLawyerLoop.Primary__c = (PLawyerLoop.Primary__c) * ((PLawyerLoop.Rate_At__c!=null?PLawyerLoop.Rate_At__c:100)/100);
                            PLawyerLoop.Excess__c = (PLawyerLoop.Excess__c) * ((PLawyerLoop.Rate_At__c!=null?PLawyerLoop.Rate_At__c:100)/100);
                            
                            PLawyerLoop.Premium__c = PLawyerLoop.Primary__c + PLawyerLoop.Excess__c;
                            
                            if(PFinalQuoteMap.get(PLawyerLoop.Policy__C).ADJ_MOD__c!=null){
                                PLawyerLoop.ADJ_MOD__c = PLawyerLoop.Premium__c * (PFinalQuoteMap.get(PLawyerLoop.Policy__C).ADJ_MOD__c-1);
                                //PLawyerLoop.Premium__c = PLawyerLoop.Premium__c + PLawyerLoop.ADJ_MOD__c;
                            }else{
                                PLawyerLoop.ADJ_MOD__c = 0;
                            }
                            
                            
                            if(PFinalQuoteMap.get(PLawyerLoop.Policy__C).X10X10__c!=null){
                                //PLawyerLoop.X10_10__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).X10X10__c * ((PLawyerLoop.Rate_At__c!=null?PLawyerLoop.Rate_At__c:100)/100);
                                PLawyerLoop.X10_10__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).X10X10__c;
                                PLawyerLoop.Premium__c = PLawyerLoop.Premium__c + PLawyerLoop.X10_10__c;
                            }
                            If(PFinalQuoteMap.get(PLawyerLoop.Policy__C).X5X5_Override__c!=null){
                                //PLawyerLoop.X5_5__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).X5X5_Override__c / TotalLawyer;
                                //PLawyerLoop.X5_5__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).X5X5_Override__c * (PLawyerLoop.Premium__c) * ((PLawyerLoop.Rate_At__c!=null?PLawyerLoop.Rate_At__c:100)/100);
                                //PLawyerLoop.X5_5__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).X5X5_Override__c * ((PLawyerLoop.Rate_At__c!=null?PLawyerLoop.Rate_At__c:100)/100) ;
                                PLawyerLoop.X5_5__c = PFinalQuoteMap.get(PLawyerLoop.Policy__C).X5X5_Override__c ;
                                PLawyerLoop.Premium__c = PLawyerLoop.Premium__c + PLawyerLoop.X5_5__c;
                            } Else{
                                //system.debug('check4'+PLawyerLoop.X5_5__c+' | '+TotalLawyer);
                                If(PLawyerLoop.X5_5__c !=null){
                                    //PLawyerLoop.X5_5__c    =  PLawyerLoop.X5_5__c    / TotalLawyer;
                                    //PLawyerLoop.X5_5__c    =  PLawyerLoop.X5_5__c  *  (PLawyerLoop.Premium__c) * ((PLawyerLoop.Rate_At__c!=null?PLawyerLoop.Rate_At__c:100)/100);
                                    //PLawyerLoop.X5_5__c    =  PLawyerLoop.X5_5__c  * ((PLawyerLoop.Rate_At__c!=null?PLawyerLoop.Rate_At__c:100)/100);
                                    PLawyerLoop.X5_5__c    =  PLawyerLoop.X5_5__c ;
                                    PLawyerLoop.Premium__c = PLawyerLoop.Premium__c + PLawyerLoop.X5_5__c;
                                }
                            }
                            
                            //Decimal modPremium = 0;
                            
                            if(PFinalQuoteMap.get(PLawyerLoop.Policy__C).Mod_230__c!=null){
                                PLawyerLoop.Mod_230__c = PLawyerLoop.Premium__c * (PFinalQuoteMap.get(PLawyerLoop.Policy__C).Mod_230__c-1);
                                //modPremium +=  PLawyerLoop.Mod_230__c;
                            }else{
                                PLawyerLoop.Mod_230__c = 0;
                            }
                            
                            if(PFinalQuoteMap.get(PLawyerLoop.Policy__C).Mod_234__c!=null){
                                PLawyerLoop.Mod_234__c = PLawyerLoop.Premium__c * (PFinalQuoteMap.get(PLawyerLoop.Policy__C).Mod_234__c-1);
                                //modPremium +=  PLawyerLoop.Mod_234__c;
                            }else{
                                PLawyerLoop.Mod_234__c = 0;
                            }
                            
                            if(PFinalQuoteMap.get(PLawyerLoop.Policy__C).Mod_261__c!=null){
                                PLawyerLoop.Mod_261__c = PLawyerLoop.Premium__c * (PFinalQuoteMap.get(PLawyerLoop.Policy__C).Mod_261__c-1);
                                //modPremium +=  PLawyerLoop.Mod_261__c;
                            }else{
                                PLawyerLoop.Mod_261__c = 0;
                            }
                            
                            //PLawyerLoop.Premium__c += modPremium;
                            
                            /*PLawyerLoop.Primary__c =  PLawyerLoop.Premium__c;
                            if(PFinalQuoteMap.get(PLawyerLoop.Policy__C).X10X10__c!=null){
                                PLawyerLoop.Primary__c = PLawyerLoop.Primary__c - PLawyerLoop.X10_10__c;
                            }
                            If(PLawyerLoop.X5_5__c !=null){
                                //PLawyerLoop.Primary__c =  PLawyerLoop.Premium__c - PLawyerLoop.X5_5__c ; 
                                PLawyerLoop.Primary__c = PLawyerLoop.Primary__c - PLawyerLoop.X5_5__c;                       
                            }*/
                            
                        }

                        
                    }
                    system.debug('20170102 PLawyerLst'+PLawyerLst.size());
                    If(PLawyerLst.size()>0){
                        Database.update(PLawyerLst);
                    }
                }
               
            }            
        }
    }    
    
    // Set final Quote as checked and unchecked    
    public static void UpdateFinalQuoteToPolicy(list<Policy_Quote__c> QuoteLst,Boolean IsdeleteQuote){
        //Map<ID,Policy_Quote__c> QuoteMap = new Map<ID,Policy_Quote__c>(QuoteLst);
        Set<ID> PL_Premium_Zero_Set = new Set<ID>();
        Set<ID> PolicyID_Set = new Set<ID>();
        For (Policy_Quote__c PQLoop : QuoteLst){
            PolicyID_Set.Add(PQLoop.Policy__c);
            
        }
        
        Map<ID,Policy__C> PolicyMap = new Map<ID,Policy__C>([select 
                                                             ID,Premium_Amount__c,Original_Premium__c,
                                                             Premium__c,Limit__c,
                                                             Aggregate_Limit__c,
                                                             Deductible_Amount__c,Per_Claim_Limit__c,Deductible_ID__c,
                                                             Excess_Premium__c,ADJ_MOD__c,Total_Lawyers__c,Mod_230__c,Mod_234__c,Mod_261__c,Primary__c,Total_10x10__c,X5_5_Override__c,X10x10__c,Total_5x5__c  
                                                             from Policy__C 
                                                             where id in :PolicyID_Set ]);
        /*Map<Id,Decimal> lawyersPremium = new Map<Id,Decimal>();
        for(Policy_Lawyer__c lawyer : [select id,Premium__c,Policy__C from Policy_Lawyer__c where Policy__C in: PolicyID_Set and Premium__c!=null]){
            if(lawyersPremium.containsKey(lawyer.Policy__c)){
                lawyersPremium.put(lawyer.Policy__c,lawyersPremium.get(lawyer.Policy__c)+lawyer.Premium__c);
            }else{
                lawyersPremium.put(lawyer.Policy__c,lawyer.Premium__c);
            }
        }*/
        
        
        If(QuoteLst.size()>0){
            // Those quote which are unchecked as final quote or deleted
            For(Policy_Quote__C PQLoop :QuoteLst ){
                If(!PQLoop.Final_Quote__c || IsdeleteQuote){
                    PolicyMap.get(PQLoop.Policy__c).Premium_Amount__c   = 0;
                    PolicyMap.get(PQLoop.Policy__c).Original_Premium__c   = 0;
                    PolicyMap.get(PQLoop.Policy__c).Premium__c          = 0;
                    PolicyMap.get(PQLoop.Policy__c).Deductible_Amount__c        = 0;
                    PolicyMap.get(PQLoop.Policy__c).Limit__c            = null;                    
                    PolicyMap.get(PQLoop.Policy__c).Deductible_ID__c    = null;
                    PolicyMap.get(PQLoop.Policy__c).Deductible_Amount__c=0; 
                    PolicyMap.get(PQLoop.Policy__c).Per_Claim_Limit__c  = 0; 
                    PolicyMap.get(PQLoop.Policy__c).Aggregate_Limit__c  = 0; 
                    PolicyMap.get(PQLoop.Policy__c).Excess_Premium__c   = 0; 
                    PolicyMap.get(PQLoop.Policy__c).ADJ_MOD__c   = 1.0;
                    PolicyMap.get(PQLoop.Policy__c).Mod_230__c   = null;
                    PolicyMap.get(PQLoop.Policy__c).Mod_234__c   = null;
                    PolicyMap.get(PQLoop.Policy__c).Mod_261__c   = null;
                    PL_Premium_Zero_Set.add(PQLoop.Policy__c);
                }
            }
            // Policy Map maintain by final quote
            For(Policy_Quote__C PQLoop :QuoteLst ){
                If(PQLoop.Final_Quote__c && IsdeleteQuote==false){
                    //PolicyMap.get(PQLoop.Policy__c).Premium_Amount__c   = (lawyersPremium.containsKey(PQLoop.Policy__c)? lawyersPremium.get(PQLoop.Policy__c) : PQLoop.Quote_Final_Premium__c);
                    //PolicyMap.get(PQLoop.Policy__c).Premium__c          = (lawyersPremium.containsKey(PQLoop.Policy__c)? lawyersPremium.get(PQLoop.Policy__c) : PQLoop.Quote_Final_Premium__c);
                    PolicyMap.get(PQLoop.Policy__c).Premium_Amount__c   = PQLoop.Quote_Final_Premium__c;
                    PolicyMap.get(PQLoop.Policy__c).Original_Premium__c   = PQLoop.Quote_Final_Premium__c;
                    PolicyMap.get(PQLoop.Policy__c).Premium__c          = PQLoop.Quote_Final_Premium__c;
                    PolicyMap.get(PQLoop.Policy__c).Deductible_Amount__c        = PQLoop.Deductible_Amount__c;
                    PolicyMap.get(PQLoop.Policy__c).Deductible_ID__c    = PQLoop.Deductible__c;
                    system.debug('122220160328:'+PQLoop.Deductible__c);
                    PolicyMap.get(PQLoop.Policy__c).Limit__c            = PQLoop.Coverage__c;
                    PolicyMap.get(PQLoop.Policy__c).Per_Claim_Limit__c  = PQLoop.Coverage_Max_Per_Claim__c;
                    PolicyMap.get(PQLoop.Policy__c).Aggregate_Limit__c  = PQLoop.Full_Coverage__c;
                    PolicyMap.get(PQLoop.Policy__c).ADJ_MOD__c = PQLoop.ADJ_MOD__c;
                    PolicyMap.get(PQLoop.Policy__c).Mod_230__c = PQLoop.Mod_230__c;
                    PolicyMap.get(PQLoop.Policy__c).Mod_234__c = PQLoop.Mod_234__c;
                    PolicyMap.get(PQLoop.Policy__c).Mod_261__c = PQLoop.Mod_261__c;
                    
                    PolicyMap.get(PQLoop.Policy__c).Primary__c = PQLoop.Primary_Final__c;
                    PolicyMap.get(PQLoop.Policy__c).Excess_Premium__c = PQLoop.Excess_Final__c;
                    
                    if(PQLoop.X5X5_Override__c!=null){
                        PolicyMap.get(PQLoop.Policy__c).Total_5x5__c = PQLoop.X5X5_Override__c * PolicyMap.get(PQLoop.Policy__c).Total_Lawyers__c;
                    }else{
                        PolicyMap.get(PQLoop.Policy__c).Total_5x5__c = PQLoop.Quote_Premium_AllStep_For_5X5__c;
                    }
                    
                    if(PQLoop.X10X10__c!=null){
                        PolicyMap.get(PQLoop.Policy__c).Total_10x10__c = PQLoop.X10X10__c * PolicyMap.get(PQLoop.Policy__c).Total_Lawyers__c;
                    }
                    PolicyMap.get(PQLoop.Policy__c).X5_5_Override__c = PQLoop.X5X5_Override__c;
                    PolicyMap.get(PQLoop.Policy__c).X10x10__c = PQLoop.X10X10__c;
                    
                }
            }   
            // convert map into Policy list to update
            
            list<Policy__C> PolicyupdateLst = new list<Policy__C>([select 
                                                                   ID,Premium_Amount__c,Premium__c,Original_Premium__c,
                                                                   Deductible_Amount__c,Limit__c,Deductible_ID__c,Mod_230__c,Mod_234__c,Mod_261__c,
                                                                   Per_Claim_Limit__c,Aggregate_Limit__c , Excess_Premium__c,ADJ_MOD__c,Primary__c
                                                                   from Policy__C 
                                                                   where id in :PolicyID_Set ]);
            For(Policy__c Polloop : PolicyupdateLst){
                Polloop.Premium_Amount__c   = PolicyMap.get(Polloop.ID).Premium_Amount__c;
                Polloop.Original_Premium__c   = PolicyMap.get(Polloop.ID).Original_Premium__c;
                Polloop.Premium__c          = PolicyMap.get(Polloop.ID).Premium__c;
                Polloop.Deductible_Amount__c        =PolicyMap.get(Polloop.ID).Deductible_Amount__c;
                Polloop.Limit__c            =PolicyMap.get(Polloop.ID).Limit__C;
                Polloop.Deductible_ID__c    =PolicyMap.get(Polloop.ID).Deductible_ID__c;
                system.debug('122220160328:2:'+Polloop.Deductible_ID__c);
                // Polloop.Deductible_Amount__c =PolicyMap.get(Polloop.ID).Deductible_Amount__c;
                Polloop.Per_Claim_Limit__c  =PolicyMap.get(Polloop.ID).Per_Claim_Limit__c;
                Polloop.Aggregate_Limit__c  =PolicyMap.get(Polloop.ID).Aggregate_Limit__c;
                Polloop.ADJ_MOD__c = PolicyMap.get(Polloop.ID).ADJ_MOD__c;
                Polloop.Mod_230__c = PolicyMap.get(Polloop.ID).Mod_230__c;
                Polloop.Mod_234__c = PolicyMap.get(Polloop.ID).Mod_234__c;
                Polloop.Mod_261__c = PolicyMap.get(Polloop.ID).Mod_261__c;
                
                Polloop.Primary__c = PolicyMap.get(Polloop.ID).Primary__c;
                Polloop.Excess_Premium__c = PolicyMap.get(Polloop.ID).Excess_Premium__c;
                
                Polloop.X5_5_Override__c = PolicyMap.get(Polloop.ID).X5_5_Override__c;
                    Polloop.X10x10__c = PolicyMap.get(Polloop.ID).X10X10__c;
                    Polloop.Total_5x5__c = PolicyMap.get(Polloop.ID).Total_5x5__c;
                    Polloop.Total_10x10__c = PolicyMap.get(Polloop.ID).Total_10x10__c;
                // Polloop.Excess_Premium__c    =PolicyMap.get(Polloop.ID).Excess_Premium__c;
                system.debug('201611240741 '+Polloop.Excess_Premium__c);
                
            }
            Try{
                // update list
                Database.update(PolicyupdateLst);
                
            } catch(DmlException e) {
                System.debug('Error: ' + e.getMessage());  
            }
        }
    }
    
    public static Void CreateAccuntingSeedsForPolicy(Set<ID> PolicySetForAS){
        system.debug('CreateAccuntingSeedsForPolicy Start'+PolicySetForAS);
        List<Policy__C> PolicyDataForAS = new List<Policy__C>([select ID,Premium_Amount__c,Account__c,Total_5x5__c,Total_10x10__c,Total_CLE_Credit__c,Primary__c,Excess_Premium__c,Accounting_Processed__c,Policy_Dividend__c from Policy__C where ID in :PolicySetForAS]);
        List<AS_Transaction__c> lstASTransaction = new List<AS_Transaction__c>();
        For(Policy__C PolicyDataLoop : PolicyDataForAS){
            //PolicyDataLoop.Accounting_Processed__c = true;
             AS_Transaction__c AS_SingleEntry = new AS_Transaction__c();
             AS_SingleEntry.Firm_Id__c = PolicyDataLoop.Account__c ;
             AS_SingleEntry.Policy_Claim_Detail__c = null;
             AS_SingleEntry.Policy_Id__c = PolicyDataLoop.ID;
             AS_SingleEntry.Transaction_Type__c = 'Issue Policy';
             AS_SingleEntry.Transaction_Sub_Type__c = 'Premium';
             AS_SingleEntry.Amount__c = PolicyDataLoop.Premium_Amount__c;
            AS_SingleEntry.Credit_Amount__c = PolicyDataLoop.Total_CLE_Credit__c;
            AS_SingleEntry.Dividend_Credit__c  = PolicyDataLoop.Policy_Dividend__c;
             lstASTransaction.add(AS_SingleEntry);
            if(PolicyDataLoop.Total_5x5__c !=null && PolicyDataLoop.Total_5x5__c > 0){
                AS_SingleEntry = new AS_Transaction__c();
                AS_SingleEntry.Firm_Id__c = PolicyDataLoop.Account__c ;
                AS_SingleEntry.Policy_Claim_Detail__c = null;
                AS_SingleEntry.Policy_Id__c = PolicyDataLoop.ID;
                AS_SingleEntry.Transaction_Type__c = 'Issue Policy';
                AS_SingleEntry.Transaction_Sub_Type__c = '5x5';
                AS_SingleEntry.Amount__c = PolicyDataLoop.Total_5x5__c;
                lstASTransaction.add(AS_SingleEntry);
            }
            if(PolicyDataLoop.Total_10x10__c !=null && PolicyDataLoop.Total_10x10__c > 0){
                AS_SingleEntry = new AS_Transaction__c();
                AS_SingleEntry.Firm_Id__c = PolicyDataLoop.Account__c ;
                AS_SingleEntry.Policy_Claim_Detail__c = null;
                AS_SingleEntry.Policy_Id__c = PolicyDataLoop.ID;
                AS_SingleEntry.Transaction_Type__c = 'Issue Policy';
                AS_SingleEntry.Transaction_Sub_Type__c = '10x10';
                AS_SingleEntry.Amount__c = PolicyDataLoop.Total_10x10__c;
                lstASTransaction.add(AS_SingleEntry);
            }
            
            if(PolicyDataLoop.Primary__c != null && PolicyDataLoop.Primary__c > 0){
                AS_SingleEntry = new AS_Transaction__c();
                AS_SingleEntry.Firm_Id__c = PolicyDataLoop.Account__c ;
                AS_SingleEntry.Policy_Claim_Detail__c = null;
                AS_SingleEntry.Policy_Id__c = PolicyDataLoop.ID;
                AS_SingleEntry.Transaction_Type__c = 'Issue Policy';
                AS_SingleEntry.Transaction_Sub_Type__c = 'Primary';
                AS_SingleEntry.Amount__c = PolicyDataLoop.Primary__c;
                lstASTransaction.add(AS_SingleEntry);
            }
            
            //if(PolicyDataLoop.Excess_Premium__c != null && PolicyDataLoop.Excess_Premium__c > 0){
                AS_SingleEntry = new AS_Transaction__c();
                AS_SingleEntry.Firm_Id__c = PolicyDataLoop.Account__c ;
                AS_SingleEntry.Policy_Claim_Detail__c = null;
                AS_SingleEntry.Policy_Id__c = PolicyDataLoop.ID;
                AS_SingleEntry.Transaction_Type__c = 'Issue Policy';
                AS_SingleEntry.Transaction_Sub_Type__c = 'PrimaryAndExcess';
                AS_SingleEntry.Amount__c = (PolicyDataLoop.Excess_Premium__c !=null ? PolicyDataLoop.Excess_Premium__c : 0) + (PolicyDataLoop.Primary__c !=null ? PolicyDataLoop.Primary__c : 0);
                if(AS_SingleEntry.Amount__c > 0){
                   lstASTransaction.add(AS_SingleEntry); 
                }    
            //}
        }
        
       Try{
            if(lstASTransaction.size()>0){
                Database.insert(lstASTransaction);
                //update PolicyDataForAS;
            }
        }
        Catch(system.DmlException e){
            system.debug('Error: '+e.getMessage());
        }
        
    }
        
    // Update "Account contact junction with First policy effective date"
    public static Void UpdateAccountContactjunction(Set<ID> PolicySet){
        system.debug('Test1 '+PolicySet);
        List<Policy__C> PolicyLst = new  List<Policy__C>();            
        PolicyLst = [ select id,Account__c,Effective_Date__c,
                     (select id,Lawyer__c,policy__c
                      from Policy_Lawyers__r) 
                     from policy__c where Id in :PolicySet];
        system.debug('Test2 '+PolicyLst);
        if (PolicyLst.size()==0){
            Return;     
        }
        system.debug('Test2.1');
        Map<ID,Date> Acc_Cont_RelationUpd_Map = new Map<ID,Date>(); 
        Set<ID> Acc_Cnt_Rel_Set = new Set<ID>(); // for unique ID for get query 
        system.debug('Test2.2 '+PolicyLst);
        for (Policy__C forPolicy : PolicyLst){
            // Policy_Lawyers__r Loop to maintain Lawyer ID + Effective Date
            system.debug('Test2.2.1 '+forPolicy.Policy_Lawyers__r);
            for(Policy_Lawyer__c For_PolicyLawer : forPolicy.Policy_Lawyers__r){
                Acc_Cont_RelationUpd_Map.put(For_PolicyLawer.Lawyer__c,forPolicy.Effective_Date__c);   
                system.debug('Test2.2.2 '+Acc_Cont_RelationUpd_Map);
                Acc_Cnt_Rel_Set.add(For_PolicyLawer.Lawyer__c);
                system.debug('Test2.2.3 '+Acc_Cnt_Rel_Set);
            }
        }
        system.debug('Test2.3');
        // Get AccountContactRelation Data
        List<AccountContactjunction__C> Acc_Cont_RelationUpd_Lst = new List<AccountContactjunction__C>(
            [select ID,First_Policy_Date__c
             From AccountContactjunction__c
             where First_Policy_Date__c =null
             and ID in :Acc_Cnt_Rel_Set]);
        
        // Update AccountContactRelation with First Policy Date
        system.debug('Test2.4');
        For(AccountContactJunction__c forAccountContactjunction : Acc_Cont_RelationUpd_Lst){
            If(Acc_Cont_RelationUpd_Map.containsKey(forAccountContactjunction.Id)){
                date Policyeffectivedt = Acc_Cont_RelationUpd_Map.get(forAccountContactjunction.Id);
                forAccountContactjunction.First_Policy_Date__c = Policyeffectivedt;
            }
        }
        system.debug('Test2.5');
        If(Acc_Cont_RelationUpd_Lst.size()>0){
            system.debug('Test3 '+Acc_Cont_RelationUpd_Lst);
            Database.update(Acc_Cont_RelationUpd_Lst);           
        }
        
    }
   
    
    // Calculate Step for Lawyers on the basis of Policy Effective date and Lawyer's Prior act date 
    public static integer CalculateLawyerStep(Date EffectiveDate,Date PriorActDate){
        Decimal daysBetween = PriorActDate.daysBetween(EffectiveDate);
        decimal Diffmonth;
        integer Step;
        system.debug('EffectiveDat '+EffectiveDate);
        system.debug('PriorActDate '+PriorActDate);
        //Diffmonth = PriorActDate.monthsBetween(EffectiveDate);   
        //system.debug('Diffmonth2 '+Diffmonth);
        //Diffmonth = Diffmonth / 6;
        //Diffmonth = (Diffmonth / 12).round(System.RoundingMode.HALF_EVEN);
        Diffmonth = (daysBetween/365).round(System.RoundingMode.HALF_UP);
        system.debug('Diffmonth2 '+Diffmonth);
        // month calculation
        if(Diffmonth < 1.00)  {
            Step = 0;
        } Else if(Diffmonth >= 1.00 && Diffmonth < 2.00 ){
            Step = 1;
        } Else if(Diffmonth >= 2.00 && Diffmonth < 3.00 ){
            Step = 2;
        } Else if(Diffmonth >= 3.00 && Diffmonth < 4.00 ){
            Step = 3;
        } Else if(Diffmonth >= 4.00 && Diffmonth < 5.00 ){
            Step = 4;
        } Else if(Diffmonth >= 5.00 && Diffmonth < 6.00 ){
            Step = 5;
        } Else if(Diffmonth >= 6.00 && Diffmonth < 7.00 ){
            Step = 6;
        } Else {
            Step = 7;
        }
        Return Step;
    }  
    
    //26 April 2017, Nitin Chandwani: Insert Opportunity for every Applicatopm/Policy
    public void createOpportuniies( List<Policy__c> appPolicies ){
        
        if( appPolicies != null && appPolicies.size() > 0 ){
            List<Opportunity> opportunities = new List<Opportunity>();
            
            for( Policy__c appPolicy : appPolicies ){
                Opportunity opp = new Opportunity();
                appPolicy.Opportunity__r = opp;
                opportunities.add( opp );
            }
            
            if( opportunities.size() > 0 || Test.isRunningTest()){
                INSERT opportunities;
                for( Policy__c appPolicy : appPolicies ){
                    appPolicy.Opportunity__c = appPolicy.Opportunity__r.Id;
                }
            }
            
        }
    }
    @future(callout=true)
    public static void createLSAonRenewal(Set<Id> policyIds){
        List<ContentVersion> cvList = new List<ContentVersion>();
        Decimal currentMilliSeconds = System.now().getTime();
        for(Policy__c policy: [Select Id,Account__c,Account__r.Name,Name from Policy__c where Id in: policyIds]){
            PageReference pg = Page.LawyersSupplement;
            pg.getParameters().put('id',(String)policy.Id);
            Blob body;
            try {
                body = pg.getContent();
            } catch (VisualforceException e) {
                body = Blob.valueOf('Some Error Occurred While PDF Generation.');
            }
            String fileName = '';
            fileName = policy.Account__r.Name +' - '+policy.Name;
            fileName += ' - Lawyers Supplemental Application.pdf';
            ContentVersion content = new ContentVersion();
            content.VersionData = body;
            content.Title = fileName;
            content.PathOnClient = fileName;
            content.FirstPublishLocationId = policy.Id;
            content.Application_Policy__c = policy.Id;
            content.Account__c = policy.Account__c;
            content.Document_Type__c = 'Lawyer Supplement Application';
            content.Is_System_Generated_Document__c = true;
            content.Unique_Identifier__c = policy.Id + '_' + UserInfo.getUserId() +  '_' + currentMilliSeconds;
            cvList.add(content);
        }
        insert cvList;
    }
    @future
    public static void updatePolicyWithOpportunity(Set<Id> oppties){
        List<Policy__C> policiesToBeUpdated = new List<Policy__C>();
        for(Opportunity opp: [select id,Application_Policy__c from Opportunity where id in : oppties AND Application_Policy__c != NULL]){
            policiesToBeUpdated.add(new Policy__C(id=opp.Application_Policy__c,Opportunity__C=opp.id));
        }
        if(policiesToBeUpdated!=null && policiesToBeUpdated.size()>0){
            update policiesToBeUpdated;
            // To update policy count field on opportunity, required for One-One Validation.
            Set<String> setOpportunityIds = new Set<String>();
            Map<String,String> mapOpportunityPolicy = new Map<String,String>();
            List<Opportunity> lstOpportunities = new List<Opportunity>();
            
            for (Policy__c pol : policiesToBeUpdated) {
                setOpportunityIds.add(pol.Opportunity__c);
                mapOpportunityPolicy.put(pol.Opportunity__c,pol.Id);
            }
            
            if(setOpportunityIds.size()>0){
                for (Opportunity opp : [SELECT Id, Policy_Count__c FROM Opportunity WHERE Id IN :setOpportunityIds]) {
                    opp.Policy_Count__c = opp.Policy_Count__c + 1;
                    opp.Application_Policy__c = mapOpportunityPolicy.get(opp.Id);
                    lstOpportunities.add(opp);
                }            
                update lstOpportunities;
            }
        }
    }
    public class PolicyLawerCountWrapper{
        public Integer step0,step1,step2,step3,step4,step5,step6,step7;
        public Decimal rate0,rate1,rate2,rate3,rate4,rate5,rate6,rate7;
        public PolicyLawerCountWrapper(){
            step0=step1=step2=step3=step4=step5=step6=step7=0;
            rate0=rate1=rate2=rate3=rate4=rate5=rate6=rate7=0;
        }
    }
}