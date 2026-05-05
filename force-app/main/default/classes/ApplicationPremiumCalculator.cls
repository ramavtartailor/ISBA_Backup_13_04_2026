public without sharing class ApplicationPremiumCalculator {
/*
//Created By    :   Shoukat Hussain
//Created Date  :   11/07/2016
//Purpose       :   Calculate Premium by provided factors values or by pre defined factors values.
*/

      
    public static Map<ID,Deductible_Factor__c>  DeductibleFactorMap;
    public static Map<ID,ILF_Coverage_Factor__c>  Coverage5X5_Map;
    
    // Maintain list only those Policy  which new.IsAllowCalculatePremium =True and Old.IsAllowCalculatePremium= False    
    public static void UpdateQuotePremium(list<Policy__c> PolicyLst, Set<ID> PolicyIDSet){
        system.debug('Start UpdateQuotePremium process: ');
        System.debug(PolicyIDSet + 'PolicyIDSet======');
        Map<Id,Decimal> lawyersByPolicyMap = new Map<Id,Decimal>();
        
        // Reintial all Policy Values and Select IDs
        Set<ID> GEOFactorIDSet = new Set<ID>();
        For(Policy__c PolicyFor :PolicyLst ){
            PolicyFor.AOP_Factor__c = 0;
            GEOFactorIDSet.add(PolicyFor.County__c);
        }
        
        // Get AOP Factor in Rollup shape
        Map<ID,Decimal> PolicyAOPModMap = new Map<ID,Decimal>();
        PolicyAOPModMap = ApplicationPolicyUtil.GetPolicyAOPMod(PolicyIDSet,PolicyAOPModMap);
        system.debug('GetPolicyAOPMod-->' +PolicyAOPModMap);
        
        // Get Step Rate Factor
        Map<Id,Map<integer,Decimal>> LawyerStepRateMap = new Map<Id,Map<integer,Decimal>>();
        LawyerStepRateMap = ApplicationPolicyUtil.GetPolicyStepRateFactor(PolicyLst,LawyerStepRateMap);
        system.debug('GetPolicyStepRateFactor'+LawyerStepRateMap);
        
        // Get Base Value Factor 
        //Integer PremiumBaseVal = 0; 
        Map<Id,Decimal> PremiumBaseVal = new Map<Id,Decimal>();
        PremiumBaseVal = ApplicationPolicyUtil.GetPolicyBaseAmt(PolicyLst,PremiumBaseVal);
        system.debug('GetPolicyBaseAmt-->'+PremiumBaseVal);
        
        // Get Policy with County / Geo Factor
        Map<ID,Decimal> PolicyGEOFactorMap = new Map<ID,Decimal>();
        
        PolicyGEOFactorMap = ApplicationPolicyUtil.GetPolicyGEOFactor(GEOFactorIDSet,PolicyGEOFactorMap);
        system.debug('GetPolicyGEOFactor-->'+PolicyGEOFactorMap);       
        // Get Policy Quote Data
        list<Policy_Quote__c> PolicyQuoteLst;
        
        PolicyQuoteLst = GetQuoteData(PolicyIDSet,PolicyQuoteLst);
        system.debug('GetQuoteData-->'+PolicyQuoteLst);
        
        // Update Quote data by Coverage and Deductible factor values
        if(PolicyQuoteLst.size()>0){
            PolicyQuoteLst = UpdateQuoteDataByCoverage(PolicyQuoteLst);            
            PolicyQuoteLst = UpdateQuoteDataByDeductible(PolicyQuoteLst);
        }

        // Update Policy list        
        Try{
            if(PolicyLst.size()>0){
                For (Policy__c PolicyFor : PolicyLst){
                    // Generate Errors
                    PolicyFor.Premium_Calculation_Errors__c = '';
                    if (PolicyFor.Status__c  != 'Accepted'){
                        //PolicyFor.Premium_Calculation_Errors__c = 'Policy Status is not Accepted.';   
                    }
                    if (PolicyFor.Total_Lawyers__c == 0){
                        PolicyFor.Premium_Calculation_Errors__c += 'There is no Lawyer.';   
                    }
                    if (PolicyFor.AOP_Percentage__c != 100){
                        PolicyFor.Premium_Calculation_Errors__c += 'AOP percentage is not 100.';   
                    }
                    if (PolicyFor.Total_Quotes__c == 0){
                        PolicyFor.Premium_Calculation_Errors__c += 'There is no Quote.';   
                    }
                    if (PolicyFor.Total_Final_Quotes__c == 0){
                        PolicyFor.Premium_Calculation_Errors__c += 'There is no Quote as Final.';   
                    }
                    If (PolicyFor.Premium_Calculation_Errors__c!=''){
                        //PolicyFor.adderror('Please Resolve all Errors before converting Application or to calculate Premium: '+PolicyFor.Premium_Calculation_Errors__c); 
                        //above line commented becuase it stop commit of policy and policy_Quote object.
                    }
                    
                    // PolicyFor.AOP_Factor__c = Integer.valueOf(PolicyAOPModMap.containsKey(PolicyFor.Id)); // AOP
                    If(PolicyFor.AOP_Override__c==True){
                        PolicyFor.AOP_Factor__c     =  PolicyFor.AOP_Override_Value__c; // pick AOP override value 
                    }
                    Else{
                        PolicyFor.AOP_Factor__c     = PolicyAOPModMap.get(PolicyFor.ID); // AOP               
                    }
                    
                    system.debug('PolicyAOPModMap:'+PolicyFor.AOP_Factor__c);
                    // Set Step Rate
                    
                    PolicyFor.Factor_Step_0__c  = PolicyFor.Total_Lawyers_For_Step_0__c==0?0:(LawyerStepRateMap.containsKey(PolicyFor.Id)?LawyerStepRateMap.get(PolicyFor.Id).get(0):0); // Step Rate
                    PolicyFor.Factor_Step_1__c  = PolicyFor.Total_Lawyers_For_Step_1__c==0?0:(LawyerStepRateMap.containsKey(PolicyFor.Id)?LawyerStepRateMap.get(PolicyFor.Id).get(1):0); // Step Rate
                    PolicyFor.Factor_Step_2__c  = PolicyFor.Total_Lawyers_For_Step_2__c==0?0:(LawyerStepRateMap.containsKey(PolicyFor.Id)?LawyerStepRateMap.get(PolicyFor.Id).get(2):0); // Step Rate
                    PolicyFor.Factor_Step_3__c  = PolicyFor.Total_Lawyers_For_Step_3__c==0?0:(LawyerStepRateMap.containsKey(PolicyFor.Id)?LawyerStepRateMap.get(PolicyFor.Id).get(3):0); // Step Rate
                    PolicyFor.Factor_Step_4__c  = PolicyFor.Total_Lawyers_For_Step_4__c==0?0:(LawyerStepRateMap.containsKey(PolicyFor.Id)?LawyerStepRateMap.get(PolicyFor.Id).get(4):0); // Step Rate
                    PolicyFor.Factor_Step_5__c  = PolicyFor.Total_Lawyers_For_Step_5__c==0?0:(LawyerStepRateMap.containsKey(PolicyFor.Id)?LawyerStepRateMap.get(PolicyFor.Id).get(5):0); // Step Rate
                    PolicyFor.Factor_Step_6__c  = PolicyFor.Total_Lawyers_For_Step_6__c==0?0:(LawyerStepRateMap.containsKey(PolicyFor.Id)?LawyerStepRateMap.get(PolicyFor.Id).get(6):0); // Step Rate
                    PolicyFor.Factor_Step_7__c  = PolicyFor.Total_Lawyers_For_Step_7__c==0?0:(LawyerStepRateMap.containsKey(PolicyFor.Id)?LawyerStepRateMap.get(PolicyFor.Id).get(7):0); // Step Rate         
                    system.debug('Policy:Factor_Step:'+
                                 '0:'+PolicyFor.Factor_Step_0__c +
                                 '1:'+PolicyFor.Factor_Step_1__c +  
                                 '2:'+PolicyFor.Factor_Step_2__c +
                                 '3:'+PolicyFor.Factor_Step_3__c +
                                 '4:'+PolicyFor.Factor_Step_4__c +
                                 '5:'+PolicyFor.Factor_Step_5__c +
                                 '6:'+PolicyFor.Factor_Step_6__c +
                                 '7:'+PolicyFor.Factor_Step_7__c 
                                );
                    
                    lawyersByPolicyMap.put(PolicyFor.Id,PolicyFor.Total_Lawyers__c);
                    PolicyFor.is_allow_calculate_premium__C = false; // false becuase use can calculate again & again
                    PolicyFor.Base_Amount__c    = PremiumBaseVal.containsKey(PolicyFor.Id)?PremiumBaseVal.get(PolicyFor.Id):0;
                    // system.debug('Base_Amount__c '+PolicyFor.Base_Amount__c);
                    
                    PolicyFor.GEO_Mod__c        = PolicyGEOFactorMap.get(PolicyFor.County__c); // GEO
                    system.debug('GEO_Mod__c'+PolicyFor.GEO_Mod__c);
                    
                    PolicyFor.GEO_Mod__c = (PolicyFor.GEO_Mod__c==null)?0:PolicyFor.GEO_Mod__c;
                    PolicyFor.AOP_Factor__c = (PolicyFor.AOP_Factor__c==null)?0:PolicyFor.AOP_Factor__c;
                    system.debug('201701040642: '+PolicyFor.GEO_Mod__c+' | '+PolicyFor.SCH_Mod__c+' | '+PolicyFor.Claims_Factor__c+' | '+PolicyFor.AOP_Factor__c);    
                    
                    // Start Form Mod calculation
                    //PolicyFor.Firm_Mod__c     = PolicyFor.GEO_Mod__c * PolicyFor.SCH_Mod__c * PolicyFor.Claims_Factor__c * PolicyFor.AOP_Factor__c; // Firm Mod
                    Decimal AOPFactor;
                    
                    If(PolicyFor.AOP_Override__c){                        
                        AOPFactor = PolicyFor.AOP_Override_Value__c ;                                                
                    }Else{
                        AOPFactor = PolicyFor.AOP_Factor__c ;
                    }
                    If(
                        (PolicyFor.GEO_Mod__c == null || PolicyFor.GEO_Mod__c == 0) &&
                        (PolicyFor.SCH_Mod__c == null || PolicyFor.SCH_Mod__c == 0) &&
                        (PolicyFor.Claims_Factor__c == null || PolicyFor.Claims_Factor__c == 0) &&
                        (AOPFactor==null || AOPFactor==0) && (PolicyFor.Mod_230__c == null || PolicyFor.Mod_230__c == 0)
                    && (PolicyFor.Mod_234__c == null || PolicyFor.Mod_234__c == 0) && (PolicyFor.Mod_261__c == null || PolicyFor.Mod_261__c == 0)) {
                        PolicyFor.Firm_Mod__c = 0;
                        
                    }
                    Else{
                        PolicyFor.Firm_Mod__c = 1;  // 1 value input so that firm mod can be multiply with other factor
                        If (PolicyFor.GEO_Mod__c != null && PolicyFor.GEO_Mod__c != 0){
                            PolicyFor.Firm_Mod__c  = PolicyFor.Firm_Mod__c * PolicyFor.GEO_Mod__c;
                        }
                        If (PolicyFor.SCH_Mod__c != null && PolicyFor.SCH_Mod__c != 0){
                            PolicyFor.Firm_Mod__c  = PolicyFor.Firm_Mod__c  * PolicyFor.SCH_Mod__c;
                        }
                        If (PolicyFor.Claims_Factor__c != null && PolicyFor.Claims_Factor__c != 0){
                            PolicyFor.Firm_Mod__c  = PolicyFor.Firm_Mod__c  * PolicyFor.Claims_Factor__c;
                        }
                        If (AOPFactor != null && AOPFactor != 0){
                            PolicyFor.Firm_Mod__c  = PolicyFor.Firm_Mod__c  * AOPFactor;
                        }
                        if(PolicyFor.Mod_230__c != null && PolicyFor.Mod_230__c != 0){
                            PolicyFor.Firm_Mod__c  = PolicyFor.Firm_Mod__c  * PolicyFor.Mod_230__c;
                        }
                        if(PolicyFor.Mod_234__c != null && PolicyFor.Mod_234__c != 0){
                            PolicyFor.Firm_Mod__c  = PolicyFor.Firm_Mod__c  * PolicyFor.Mod_234__c;
                        }
                        if(PolicyFor.Mod_261__c != null && PolicyFor.Mod_261__c != 0){
                            PolicyFor.Firm_Mod__c  = PolicyFor.Firm_Mod__c  * PolicyFor.Mod_261__c;
                        }
                    }
                    system.debug('201701090755: '+PolicyFor.Firm_Mod__c);
                    PolicyFor.Firm_Mod__c   = Math.round(PolicyFor.Firm_Mod__c * 100) / 100.0; //due to an error controll
                    system.debug('201701090755: '+PolicyFor.Firm_Mod__c);
                    // End Form Mod calculation

                }
            }
        } catch(DmlException e) {
            System.debug('Error: ' + e.getMessage());  
        }
        
        // Update Quote
        Try{
            system.debug('Start UpdatePolicyQuote function-->'+PolicyQuoteLst);
            PolicyQuoteLst = UpdatePolicyQuote(PolicyLst,PolicyQuoteLst);       
            system.debug('End UpdatePolicyQuote function-->'+PolicyQuoteLst);
        } catch(DmlException e) {
            System.debug('Error: ' + e.getMessage());  
        }
        // Final Quote Update on Policy & Update Per Lawyer Premium Info
        Map<ID,Policy_Quote__c> PFinalQuoteMap = new Map<ID,Policy_Quote__c>();
        Map<ID,Policy__C> PolicyMap = new Map<ID,Policy__C>();
        For(Policy_Quote__c PQLoop : PolicyQuoteLst){
            If(PQloop.Final_Quote__c){
                system.debug('122220160328:1:'+PQLoop.Deductible__c);
                Policy__C pobj = new Policy__C(Premium_Amount__c =PQLoop.Quote_Premium_Amount__c,
                                               Premium__c = PQLoop.Quote_Premium_Amount__c,
                                               Original_Premium__c = PQLoop.Quote_Premium_Amount__c,
                                               Deductible_amount__c = PQLoop.Deductible_Amount__c,
                                               Limit__c = PQLoop.Coverage__c,                               
                                               Per_Claim_Limit__c = PQLoop.Coverage_Max_Per_Claim__c,
                                               Aggregate_Limit__c = PQLoop.Full_Coverage__c,
                                               Deductible_ID__c =   PQLoop.Deductible__c,
                                               X5_5_Override__c = PQLoop.X5X5_Override__c,
                                               X10x10__c = PQLoop.X10X10__c,
                                               ADJ_MOD__c = PQLoop.ADJ_MOD__c,
                                               Mod_230__c = PQLoop.Mod_230__c,
                                               Mod_234__c = PQLoop.Mod_234__c,
                                               Mod_261__c = PQLoop.Mod_261__c,
                                               Primary__c = PQLoop.Primary_Final__c,
                                               Excess_Premium__c = PQLoop.Excess_Final__c
                                                );
                
                if(PQLoop.X5X5_Override__c!=null){
                    pobj.Total_5x5__c = PQLoop.X5X5_Override__c * (lawyersByPolicyMap.containsKey(PQloop.Policy__c) ? lawyersByPolicyMap.get(PQloop.Policy__c) : 0 );
                }else{
                    pobj.Total_5x5__c = PQLoop.Quote_Premium_AllStep_For_5X5__c;
                }
                
                if(PQLoop.X10X10__c!=null){
                    pobj.Total_10x10__c = PQLoop.X10X10__c * (lawyersByPolicyMap.containsKey(PQloop.Policy__c) ? lawyersByPolicyMap.get(PQloop.Policy__c) : 0 );
                }
                
                PolicyMap.put(PQloop.Policy__c,pobj);
                PFinalQuoteMap.put(PQloop.Policy__c,PQLoop);
                system.debug('201611250311 '+PolicyMap); 
                
            }
        }
        
        
        // Update info on Policy for final quote
        if(PolicyLst.size()>0 && PolicyMap.size()>0){
            
            // Update Final  Quote (only checked) info to  Policy Lawyer
            If(PFinalQuoteMap.size()>0){
               //ApplicationPolicyUtil.UpdateFinalQuote_ToLawyer(PFinalQuoteMap,PolicyLst,True);      
               ApplicationPolicyUtil.UpdateFinalQuote_ToLawyer(PFinalQuoteMap,True);     
               //ApplicationPolicyUtil.UpdateFinalQuoteToPolicy(QuoteFinalCheckedLst,False); 
            }
            Map<Id,Decimal> lawyersPremium = new Map<Id,Decimal>();
            for(Policy_Lawyer__c lawyer : [select id,Premium__c,Policy__C from Policy_Lawyer__c where Policy__C in: PolicyLst and Premium__c!=null]){
                if(lawyersPremium.containsKey(lawyer.Policy__c)){
                    lawyersPremium.put(lawyer.Policy__c,lawyersPremium.get(lawyer.Policy__c)+lawyer.Premium__c);
                }else{
                    lawyersPremium.put(lawyer.Policy__c,lawyer.Premium__c);
                }
            }
            For(Policy__c Polloop :PolicyLst ){
                If(PolicyMap.containsKey(Polloop.id)){
                    //Polloop.Premium_Amount__c   = (lawyersPremium.containsKey(Polloop.ID)? lawyersPremium.get(Polloop.ID) : PolicyMap.get(Polloop.ID).Premium_Amount__c) + Polloop.Title_Premium__c + Polloop.Additional_Premium__c;
                    //Polloop.Premium__c          = (lawyersPremium.containsKey(Polloop.ID)? lawyersPremium.get(Polloop.ID) : PolicyMap.get(Polloop.ID).Premium__c) + Polloop.Title_Premium__c + Polloop.Additional_Premium__c; 
                    //Polloop.Original_Premium__c          = (lawyersPremium.containsKey(Polloop.ID)? lawyersPremium.get(Polloop.ID) : PolicyMap.get(Polloop.ID).Original_Premium__c) + Polloop.Title_Premium__c + Polloop.Additional_Premium__c;
                    Polloop.Premium_Amount__c   = (lawyersPremium.containsKey(Polloop.ID)? lawyersPremium.get(Polloop.ID) : PolicyMap.get(Polloop.ID).Premium_Amount__c)  + Polloop.Additional_Premium__c;
                    Polloop.Premium__c          = (lawyersPremium.containsKey(Polloop.ID)? lawyersPremium.get(Polloop.ID) : PolicyMap.get(Polloop.ID).Premium__c) +  Polloop.Additional_Premium__c; 
                    Polloop.Original_Premium__c          = (lawyersPremium.containsKey(Polloop.ID)? lawyersPremium.get(Polloop.ID) : PolicyMap.get(Polloop.ID).Original_Premium__c) + Polloop.Additional_Premium__c;
                    Polloop.Deductible_Amount__c        =PolicyMap.get(Polloop.ID).Deductible_Amount__c;
                    Polloop.Limit__c            =PolicyMap.get(Polloop.ID).Limit__c;
                    //   Polloop.Per_Claim_Deductible__c    =PolicyMap.get(Polloop.ID).Per_Claim_Deductible__c;
                    Polloop.Per_Claim_Limit__c  =PolicyMap.get(Polloop.ID).Per_Claim_Limit__c;  
                    Polloop.Aggregate_Limit__c  =PolicyMap.get(Polloop.ID).Aggregate_Limit__c;  
                    //  Polloop.Excess_Premium__c   =PolicyMap.get(Polloop.ID).Excess_Premium__c;   
                    Polloop.X5_5_Override__c = PolicyMap.get(Polloop.ID).X5_5_Override__c;
                    Polloop.X10x10__c = PolicyMap.get(Polloop.ID).X10X10__c;
                    Polloop.ADJ_MOD__c = PolicyMap.get(Polloop.ID).ADJ_MOD__c;
                    Polloop.Mod_230__c = PolicyMap.get(Polloop.ID).Mod_230__c;
                    Polloop.Mod_234__c = PolicyMap.get(Polloop.ID).Mod_234__c;
                    Polloop.Mod_261__c = PolicyMap.get(Polloop.ID).Mod_261__c;
                    Polloop.Total_5x5__c = PolicyMap.get(Polloop.ID).Total_5x5__c;
                    Polloop.Total_10x10__c = PolicyMap.get(Polloop.ID).Total_10x10__c;
                    Polloop.Primary__c = PolicyMap.get(Polloop.ID).Primary__c;
                    Polloop.Excess_Premium__c = PolicyMap.get(Polloop.ID).Excess_Premium__c;
                    Polloop.Deductible_ID__c = PolicyMap.get(Polloop.ID).Deductible_ID__c;
                }
            }
            
            
        }
        System.debug(PolicyQuoteLst);
        //commit to Database
        try{
            Database.update(PolicyQuoteLst);            
        } 
        catch(DmlException e) {
            System.debug('Error: ' + e.getMessage());  
        }
        
    }

    // Update Quote with policy information / policy factor
    Public static List<Policy_Quote__C> UpdatePolicyQuote(List<Policy__C> PolicyLst2,List<Policy_Quote__c> PolicyQuoteLst2){
        system.debug('Start UpdatePolicyQuote '+PolicyQuoteLst2);
        
        // Set step 0-3 Value if coverage are 5X5
        Set<ID> Coverage5X5_IDSet = new Set<ID>(); // for 5X5 Coverage        
        For(Policy_Quote__c PolicyQuoteFor : PolicyQuoteLst2){            
            If(PolicyQuoteFor.Is_5X5_Coverage__c==true){
                Coverage5X5_IDSet.add(PolicyQuoteFor.Coverage__c);
            }
        }
        
        /*List<ILF_Coverage_Factor__c> Coverage5X5_Lst = [
            select ID,
            Percentage_5X5_Step_0__c,Percentage_5X5_Step_1__c,
            Percentage_5X5_Step_2__c,Percentage_5X5_Step_3__c,
            Percentage_5X5_Step_4__c,Percentage_5X5_Step_5__c,
            Percentage_5X5_Step_6__c,Percentage_5X5_Step_7__c,            
            Percnt_amt_5X5_Step_0__c,Percnt_amt_5X5_Step_1__c,
            Percnt_amt_5X5_Step_2__c,Percnt_amt_5X5_Step_3__c,
            Percnt_amt_5X5_Step_4__c,Percnt_amt_5X5_Step_5__c,
            Percnt_amt_5X5_Step_6__c,Percnt_amt_5X5_Step_7__c,
            Premium_Rate_5X5__c
            from ILF_Coverage_Factor__c
            where ID in :Coverage5X5_IDSet  ];*/
        //Map<ID,ILF_Coverage_Factor__c>  Coverage5X5_Map  = new  Map<ID,ILF_Coverage_Factor__c>(Coverage5X5_Lst);
        if(Coverage5X5_Map == null){
            Coverage5X5_Map  = new  Map<ID,ILF_Coverage_Factor__c>([select ID,
                                                                                                    Percentage_5X5_Step_0__c,Percentage_5X5_Step_1__c,
                                                                                                    Percentage_5X5_Step_2__c,Percentage_5X5_Step_3__c,
                                                                                                    Percentage_5X5_Step_4__c,Percentage_5X5_Step_5__c,
                                                                                                    Percentage_5X5_Step_6__c,Percentage_5X5_Step_7__c,            
                                                                                                    Percnt_amt_5X5_Step_0__c,Percnt_amt_5X5_Step_1__c,
                                                                                                    Percnt_amt_5X5_Step_2__c,Percnt_amt_5X5_Step_3__c,
                                                                                                    Percnt_amt_5X5_Step_4__c,Percnt_amt_5X5_Step_5__c,
                                                                                                    Percnt_amt_5X5_Step_6__c,Percnt_amt_5X5_Step_7__c,
                                                                                                    Premium_Rate_5X5__c
                                                                                                    from ILF_Coverage_Factor__c]);
        }
        // For Normal Coverage 
        Map<ID,Policy__c> PolicyMap = new Map<ID,Policy__C>(PolicyLst2);   
        Map<Id,ApplicationPolicyUtil.PolicyLawerCountWrapper> policyLawersCountMap = new Map<Id,ApplicationPolicyUtil.PolicyLawerCountWrapper>();
        List<Policy_Lawyer__C> PLawyerLst = [select id,Policy__c,Premium__c,Primary__c,X5_5__c,Step__c,Rate_At__c
                                             from Policy_Lawyer__c where Policy__C in :PolicyLst2 ];
        System.debug('PLawyerLst---'+PLawyerLst);
        for(Policy_Lawyer__C lawers : PLawyerLst){
            if(lawers.Step__c==0){
                if(policyLawersCountMap.containsKey(lawers.Policy__c)){
                    ApplicationPolicyUtil.PolicyLawerCountWrapper wrapper = policyLawersCountMap.get(lawers.Policy__c);
                    wrapper.step0= wrapper.step0+1;
                    wrapper.rate0 = wrapper.rate0 + lawers.Rate_At__c;
                    policyLawersCountMap.put(lawers.Policy__c, wrapper);
                }else{
                    ApplicationPolicyUtil.PolicyLawerCountWrapper wrapper = new ApplicationPolicyUtil.PolicyLawerCountWrapper();
                    wrapper.step0=1;
                    wrapper.rate0 = lawers.Rate_At__c;
                    policyLawersCountMap.put(lawers.Policy__c, wrapper);
                }
            }else if(lawers.Step__c==1){
                if(policyLawersCountMap.containsKey(lawers.Policy__c)){
                    ApplicationPolicyUtil.PolicyLawerCountWrapper wrapper = policyLawersCountMap.get(lawers.Policy__c);
                    wrapper.step1= wrapper.step1+1;
                    wrapper.rate1 = wrapper.rate1 + lawers.Rate_At__c;
                    policyLawersCountMap.put(lawers.Policy__c, wrapper);
                }else{
                    ApplicationPolicyUtil.PolicyLawerCountWrapper wrapper = new ApplicationPolicyUtil.PolicyLawerCountWrapper();
                    wrapper.step1=1;
                    wrapper.rate1 = lawers.Rate_At__c;
                    policyLawersCountMap.put(lawers.Policy__c, wrapper);
                }
            }else if(lawers.Step__c==2){
                if(policyLawersCountMap.containsKey(lawers.Policy__c)){
                    ApplicationPolicyUtil.PolicyLawerCountWrapper wrapper = policyLawersCountMap.get(lawers.Policy__c);
                    wrapper.step2= wrapper.step2+1;
                    wrapper.rate2 = wrapper.rate2 + lawers.Rate_At__c;
                    policyLawersCountMap.put(lawers.Policy__c, wrapper);
                }else{
                    ApplicationPolicyUtil.PolicyLawerCountWrapper wrapper = new ApplicationPolicyUtil.PolicyLawerCountWrapper();
                    wrapper.step2=1;
                    wrapper.rate2 = lawers.Rate_At__c;
                    policyLawersCountMap.put(lawers.Policy__c, wrapper);
                }
            }else if(lawers.Step__c==3){
                if(policyLawersCountMap.containsKey(lawers.Policy__c)){
                    ApplicationPolicyUtil.PolicyLawerCountWrapper wrapper = policyLawersCountMap.get(lawers.Policy__c);
                    wrapper.step3= wrapper.step3+1;
                    wrapper.rate3 = wrapper.rate3 + lawers.Rate_At__c;
                    policyLawersCountMap.put(lawers.Policy__c, wrapper);
                }else{
                    ApplicationPolicyUtil.PolicyLawerCountWrapper wrapper = new ApplicationPolicyUtil.PolicyLawerCountWrapper();
                    wrapper.step3=1;
                    wrapper.rate3 =  lawers.Rate_At__c;
                    policyLawersCountMap.put(lawers.Policy__c, wrapper);
                }
            }else if(lawers.Step__c==4){
                if(policyLawersCountMap.containsKey(lawers.Policy__c)){
                    ApplicationPolicyUtil.PolicyLawerCountWrapper wrapper = policyLawersCountMap.get(lawers.Policy__c);
                    wrapper.step4= wrapper.step4+1;
                    wrapper.rate4 = wrapper.rate4 + lawers.Rate_At__c;
                    policyLawersCountMap.put(lawers.Policy__c, wrapper);
                }else{
                    ApplicationPolicyUtil.PolicyLawerCountWrapper wrapper = new ApplicationPolicyUtil.PolicyLawerCountWrapper();
                    wrapper.step4=1;
                    wrapper.rate4 =  lawers.Rate_At__c;
                    policyLawersCountMap.put(lawers.Policy__c, wrapper);
                }
            }else if(lawers.Step__c==5){
                if(policyLawersCountMap.containsKey(lawers.Policy__c)){
                    ApplicationPolicyUtil.PolicyLawerCountWrapper wrapper = policyLawersCountMap.get(lawers.Policy__c);
                    wrapper.step5= wrapper.step5+1;
                    wrapper.rate5 = wrapper.rate5 + lawers.Rate_At__c;
                    policyLawersCountMap.put(lawers.Policy__c, wrapper);
                }else{
                    ApplicationPolicyUtil.PolicyLawerCountWrapper wrapper = new ApplicationPolicyUtil.PolicyLawerCountWrapper();
                    wrapper.step5=1;
                    wrapper.rate5 = lawers.Rate_At__c;
                    policyLawersCountMap.put(lawers.Policy__c, wrapper);
                }
            }else if(lawers.Step__c==6){
                if(policyLawersCountMap.containsKey(lawers.Policy__c)){
                    ApplicationPolicyUtil.PolicyLawerCountWrapper wrapper = policyLawersCountMap.get(lawers.Policy__c);
                    wrapper.step6= wrapper.step6+1;
                    wrapper.rate6 = wrapper.rate6 + lawers.Rate_At__c;
                    policyLawersCountMap.put(lawers.Policy__c, wrapper);
                }else{
                    ApplicationPolicyUtil.PolicyLawerCountWrapper wrapper = new ApplicationPolicyUtil.PolicyLawerCountWrapper();
                    wrapper.step6=1;
                    wrapper.rate6 = lawers.Rate_At__c;
                    policyLawersCountMap.put(lawers.Policy__c, wrapper);
                }
            }else if(lawers.Step__c==7){
                if(policyLawersCountMap.containsKey(lawers.Policy__c)){
                    ApplicationPolicyUtil.PolicyLawerCountWrapper wrapper = policyLawersCountMap.get(lawers.Policy__c);
                    wrapper.step7= wrapper.step7+1;
                    wrapper.rate7 = wrapper.rate7 + lawers.Rate_At__c;
                    policyLawersCountMap.put(lawers.Policy__c, wrapper);
                }else{
                    ApplicationPolicyUtil.PolicyLawerCountWrapper wrapper = new ApplicationPolicyUtil.PolicyLawerCountWrapper();
                    wrapper.step7=1;
                    wrapper.rate7 = lawers.Rate_At__c;
                    policyLawersCountMap.put(lawers.Policy__c, wrapper);
                }
            }
        }
        
        For(Policy_Quote__c PolicyQuoteFor : PolicyQuoteLst2){
            system.debug('Start to Calculate Base Amount ');
            system.debug('Start For Quote ID:'+PolicyQuoteFor.ID); //+ '\r\n';  
            // Start - Reinitial fields values
            PolicyQuoteFor.Quote_Premium_Amount__c = 0;
            PolicyQuoteFor.Quote_Premium_Step0_For_5X5__c = null;
            PolicyQuoteFor.Quote_Premium_Step1_For_5X5__c = null;
            PolicyQuoteFor.Quote_Premium_Step2_For_5X5__c = null;  
            PolicyQuoteFor.Quote_Premium_Step3_For_5X5__c = null;
            PolicyQuoteFor.Quote_Premium_Step4_For_5X5__c = null;
            PolicyQuoteFor.Quote_Premium_Step5_For_5X5__c = null;
            PolicyQuoteFor.Quote_Premium_Step6_For_5X5__c = null;
            PolicyQuoteFor.Quote_Premium_Step7_For_5X5__c = null;
            
            
            PolicyQuoteFor.Percnt_amt_5X5_Step_0__c = null;
            PolicyQuoteFor.Percnt_amt_5X5_Step_1__c = null;
            PolicyQuoteFor.Percnt_amt_5X5_Step_2__c = null;
            PolicyQuoteFor.Percnt_amt_5X5_Step_3__c = null;
            PolicyQuoteFor.Percnt_amt_5X5_Step_4__c = null;
            PolicyQuoteFor.Percnt_amt_5X5_Step_5__c = null;
            PolicyQuoteFor.Percnt_amt_5X5_Step_6__c = null;
            PolicyQuoteFor.Percnt_amt_5X5_Step_7__c = null;
            
            Decimal firmMod = PolicyMap.get(PolicyQuoteFor.Policy__c).Firm_Mod__c;
            
            System.debug('firmMod'+firmMod);
            
            if((PolicyMap.get(PolicyQuoteFor.Policy__c).Mod_230__c != null && PolicyMap.get(PolicyQuoteFor.Policy__c).Mod_230__c != 0)){
                firmMod = firmMod / PolicyMap.get(PolicyQuoteFor.Policy__c).Mod_230__c;
            }
            if((PolicyMap.get(PolicyQuoteFor.Policy__c).Mod_234__c != null && PolicyMap.get(PolicyQuoteFor.Policy__c).Mod_234__c != 0)){
                firmMod = firmMod / PolicyMap.get(PolicyQuoteFor.Policy__c).Mod_234__c;
            }
            if((PolicyMap.get(PolicyQuoteFor.Policy__c).Mod_261__c != null && PolicyMap.get(PolicyQuoteFor.Policy__c).Mod_261__c != 0)){
                firmMod = firmMod / PolicyMap.get(PolicyQuoteFor.Policy__c).Mod_261__c;
            }
            
            firmMod = Math.round(firmMod * 100) / 100.0;
            
            System.debug('firmMod'+firmMod);
            
            if((PolicyQuoteFor.Mod_230__c !=null && PolicyQuoteFor.Mod_230__c != 0)){
                firmMod *= PolicyQuoteFor.Mod_230__c;
                /*if(PolicyMap.get(PolicyQuoteFor.Policy__c).Mod_230__c == null || PolicyMap.get(PolicyQuoteFor.Policy__c).Mod_230__c == 0){
                    PolicyMap.get(PolicyQuoteFor.Policy__c).Mod_230__c = PolicyQuoteFor.Mod_230__c;
                }*/
            }
            if((PolicyQuoteFor.Mod_234__c !=null && PolicyQuoteFor.Mod_234__c != 0)){
                firmMod *= PolicyQuoteFor.Mod_234__c;
                /*if(PolicyMap.get(PolicyQuoteFor.Policy__c).Mod_234__c == null || PolicyMap.get(PolicyQuoteFor.Policy__c).Mod_234__c == 0){
                    PolicyMap.get(PolicyQuoteFor.Policy__c).Mod_234__c = PolicyQuoteFor.Mod_234__c;
                }*/
            }
            if((PolicyQuoteFor.Mod_261__c !=null && PolicyQuoteFor.Mod_261__c != 0)){
                firmMod *= PolicyQuoteFor.Mod_261__c;
                /*if(PolicyMap.get(PolicyQuoteFor.Policy__c).Mod_261__c == null || PolicyMap.get(PolicyQuoteFor.Policy__c).Mod_261__c == 0){
                    PolicyMap.get(PolicyQuoteFor.Policy__c).Mod_261__c = PolicyQuoteFor.Mod_261__c;
                }*/
            }
            
            firmMod = Math.round(firmMod * 100) / 100.0;
            
            System.debug('firmMod'+firmMod);
            
            if(PolicyQuoteFor.ADJ_MOD__c!=null){
                firmMod *=  (PolicyQuoteFor.ADJ_MOD__c);
            }
            
            // End   - Reinitial Fields values
            // Base Amount
            Decimal BaseCoverage = 0; 
            BaseCoverage = PolicyMap.get(PolicyQuoteFor.Policy__c).Base_Amount__c *
                PolicyQuoteFor.Coverage_Factor__c;
           // BaseCoverage = BaseCoverage.round();
            system.debug('Base Amount:'+BaseCoverage); 
            // Base * ILF * SRF
            /*PolicyQuoteFor.Base_ILF_SRF_Step_0__c = (BaseCoverage *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_0__c *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_For_Step_0__c).round(System.RoundingMode.HALF_UP);            
            
            PolicyQuoteFor.Base_ILF_SRF_Step_1__c = (BaseCoverage *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_1__c *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_For_Step_1__c).round(System.RoundingMode.HALF_UP);
            
            PolicyQuoteFor.Base_ILF_SRF_Step_2__c = (BaseCoverage *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_2__c *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_For_Step_2__c).round(System.RoundingMode.HALF_UP);
            PolicyQuoteFor.Base_ILF_SRF_Step_3__c = (BaseCoverage *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_3__c *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_For_Step_3__c ).round(System.RoundingMode.HALF_UP);
            PolicyQuoteFor.Base_ILF_SRF_Step_4__c = (BaseCoverage *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_4__c *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_For_Step_4__c ).round(System.RoundingMode.HALF_UP);
            PolicyQuoteFor.Base_ILF_SRF_Step_5__c = (BaseCoverage *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_5__c *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_For_Step_5__c).round(System.RoundingMode.HALF_UP);
            PolicyQuoteFor.Base_ILF_SRF_Step_6__c = (BaseCoverage *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_6__c *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_For_Step_6__c).round(System.RoundingMode.HALF_UP);
            PolicyQuoteFor.Base_ILF_SRF_Step_7__c = (BaseCoverage *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_7__c *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_For_Step_7__c).round(System.RoundingMode.HALF_UP);*/            
            
            Decimal lawyerStep0Rate = policyLawersCountMap.containsKey(PolicyQuoteFor.Policy__c) ? policyLawersCountMap.get(PolicyQuoteFor.Policy__c).rate0 : 0;
            Decimal lawyerStep1Rate = policyLawersCountMap.containsKey(PolicyQuoteFor.Policy__c) ? policyLawersCountMap.get(PolicyQuoteFor.Policy__c).rate1 : 0;
            Decimal lawyerStep2Rate = policyLawersCountMap.containsKey(PolicyQuoteFor.Policy__c) ? policyLawersCountMap.get(PolicyQuoteFor.Policy__c).rate2 : 0;
            Decimal lawyerStep3Rate = policyLawersCountMap.containsKey(PolicyQuoteFor.Policy__c) ? policyLawersCountMap.get(PolicyQuoteFor.Policy__c).rate3 : 0;
            Decimal lawyerStep4Rate = policyLawersCountMap.containsKey(PolicyQuoteFor.Policy__c) ? policyLawersCountMap.get(PolicyQuoteFor.Policy__c).rate4 : 0;
            Decimal lawyerStep5Rate = policyLawersCountMap.containsKey(PolicyQuoteFor.Policy__c) ? policyLawersCountMap.get(PolicyQuoteFor.Policy__c).rate5 : 0;
            Decimal lawyerStep6Rate = policyLawersCountMap.containsKey(PolicyQuoteFor.Policy__c) ? policyLawersCountMap.get(PolicyQuoteFor.Policy__c).rate6 : 0;
            Decimal lawyerStep7Rate = policyLawersCountMap.containsKey(PolicyQuoteFor.Policy__c) ? policyLawersCountMap.get(PolicyQuoteFor.Policy__c).rate7 : 0;
            
            Decimal lawyerStep0Count = policyLawersCountMap.containsKey(PolicyQuoteFor.Policy__c) ? policyLawersCountMap.get(PolicyQuoteFor.Policy__c).step0 : 0;
            Decimal lawyerStep1Count = policyLawersCountMap.containsKey(PolicyQuoteFor.Policy__c) ? policyLawersCountMap.get(PolicyQuoteFor.Policy__c).step1 : 0;
            Decimal lawyerStep2Count = policyLawersCountMap.containsKey(PolicyQuoteFor.Policy__c) ? policyLawersCountMap.get(PolicyQuoteFor.Policy__c).step2 : 0;
            Decimal lawyerStep3Count = policyLawersCountMap.containsKey(PolicyQuoteFor.Policy__c) ? policyLawersCountMap.get(PolicyQuoteFor.Policy__c).step3 : 0;
            Decimal lawyerStep4Count = policyLawersCountMap.containsKey(PolicyQuoteFor.Policy__c) ? policyLawersCountMap.get(PolicyQuoteFor.Policy__c).step4 : 0;
            Decimal lawyerStep5Count = policyLawersCountMap.containsKey(PolicyQuoteFor.Policy__c) ? policyLawersCountMap.get(PolicyQuoteFor.Policy__c).step5 : 0;
            Decimal lawyerStep6Count = policyLawersCountMap.containsKey(PolicyQuoteFor.Policy__c) ? policyLawersCountMap.get(PolicyQuoteFor.Policy__c).step6 : 0;
            Decimal lawyerStep7Count = policyLawersCountMap.containsKey(PolicyQuoteFor.Policy__c) ? policyLawersCountMap.get(PolicyQuoteFor.Policy__c).step7 : 0;
            
            PolicyQuoteFor.Base_ILF_SRF_Step_0__c = (BaseCoverage *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_0__c *
                                                     lawyerStep0Rate / 100).round(System.RoundingMode.HALF_UP);            
            
            PolicyQuoteFor.Base_ILF_SRF_Step_1__c = (BaseCoverage *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_1__c *
                                                     lawyerStep1Rate / 100).round(System.RoundingMode.HALF_UP);
            
            PolicyQuoteFor.Base_ILF_SRF_Step_2__c = (BaseCoverage *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_2__c *
                                                     lawyerStep2Rate / 100).round(System.RoundingMode.HALF_UP);
            PolicyQuoteFor.Base_ILF_SRF_Step_3__c = (BaseCoverage *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_3__c *
                                                     lawyerStep3Rate / 100 ).round(System.RoundingMode.HALF_UP);
            PolicyQuoteFor.Base_ILF_SRF_Step_4__c = (BaseCoverage *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_4__c *
                                                     lawyerStep4Rate / 100 ).round(System.RoundingMode.HALF_UP);
            PolicyQuoteFor.Base_ILF_SRF_Step_5__c = (BaseCoverage *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_5__c *
                                                     lawyerStep5Rate / 100).round(System.RoundingMode.HALF_UP);
            PolicyQuoteFor.Base_ILF_SRF_Step_6__c = (BaseCoverage *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_6__c *
                                                     lawyerStep6Rate / 100).round(System.RoundingMode.HALF_UP);
            PolicyQuoteFor.Base_ILF_SRF_Step_7__c = (BaseCoverage *
                                                     PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_7__c *
                                                     lawyerStep7Rate / 100).round(System.RoundingMode.HALF_UP);
            
            
            // Rate before deductible
            PolicyQuoteFor.Rate_Before_Deductible_Step_0__c = (PolicyQuoteFor.Base_ILF_SRF_Step_0__c *  
                                                               firmMod).round(System.RoundingMode.HALF_UP);
            PolicyQuoteFor.Rate_Before_Deductible_Step_1__c = (PolicyQuoteFor.Base_ILF_SRF_Step_1__c *  
                                                               firmMod).round(System.RoundingMode.HALF_UP);
            PolicyQuoteFor.Rate_Before_Deductible_Step_2__c = (PolicyQuoteFor.Base_ILF_SRF_Step_2__c *  
                                                               firmMod).round(System.RoundingMode.HALF_UP);
            PolicyQuoteFor.Rate_Before_Deductible_Step_3__c = (PolicyQuoteFor.Base_ILF_SRF_Step_3__c *  
                                                               firmMod).round(System.RoundingMode.HALF_UP);
            PolicyQuoteFor.Rate_Before_Deductible_Step_4__c = (PolicyQuoteFor.Base_ILF_SRF_Step_4__c *  
                                                               firmMod).round(System.RoundingMode.HALF_UP);
            PolicyQuoteFor.Rate_Before_Deductible_Step_5__c = (PolicyQuoteFor.Base_ILF_SRF_Step_5__c *  
                                                               firmMod).round(System.RoundingMode.HALF_UP);
            PolicyQuoteFor.Rate_Before_Deductible_Step_6__c = (PolicyQuoteFor.Base_ILF_SRF_Step_6__c *  
                                                               firmMod).round(System.RoundingMode.HALF_UP);
            PolicyQuoteFor.Rate_Before_Deductible_Step_7__c = (PolicyQuoteFor.Base_ILF_SRF_Step_7__c *  
                                                               firmMod).round(System.RoundingMode.HALF_UP);
            
            // Set Deductible_Amount_Step_ 0 to 7 (DAS)
            Decimal DAS0_Amt1,DAS0_Amt2, DAS1_Amt1,DAS1_Amt2, DAS2_Amt1,DAS2_Amt2, DAS3_Amt1,DAS3_Amt2,
                DAS4_Amt1,DAS4_Amt2, DAS5_Amt1,DAS5_Amt2, DAS6_Amt1,DAS6_Amt2, DAS7_Amt1,DAS7_Amt2,
                DASForAllStep;
                
           system.debug('----1----'+PolicyQuoteFor.Lowest_Coverage_Factor__c);
           system.debug('----2----'+Integer.valueOf(PolicyMap.get(PolicyQuoteFor.Policy__c).Base_Amount__c));
           system.debug('----3----'+PolicyMap.get(PolicyQuoteFor.Policy__c).Firm_Mod__c);
                
                
            DASForAllStep = PolicyQuoteFor.Lowest_Coverage_Factor__c 
                * Integer.valueOf(PolicyMap.get(PolicyQuoteFor.Policy__c).Base_Amount__c) 
                * firmMod ;            
            
            //Deductible_Amount_Step_0__c
            /*DAS0_Amt1 = DASForAllStep 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_For_Step_0__c 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_0__c ;*/
            DAS0_Amt1 = DASForAllStep 
                * (lawyerStep0Rate / 100) 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_0__c ;
            DAS0_Amt2 = DAS0_Amt1 * PolicyQuoteFor.Deductible_Factor__c;
            PolicyQuoteFor.Deductible_Amount_Step_0__c = (DAS0_Amt1 - DAS0_Amt2).round(System.RoundingMode.HALF_UP);
            //PolicyQuoteFor.Deductible_Amount_Step_0__c = -1 * (DAS0_Amt1 - DAS0_Amt2).round();
            
            //Deductible_Amount_Step_1__c
            /*DAS1_Amt1 = DASForAllStep 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_For_Step_1__c 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_1__c ;*/
            DAS1_Amt1 = DASForAllStep 
                * (lawyerStep1Rate / 100 ) 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_1__c ;
            DAS1_Amt2 = DAS1_Amt1 * PolicyQuoteFor.Deductible_Factor__c;
            PolicyQuoteFor.Deductible_Amount_Step_1__c =  (DAS1_Amt1 - DAS1_Amt2).round(System.RoundingMode.HALF_UP);
            
            //Deductible_Amount_Step_2__c
            /*DAS2_Amt1 = DASForAllStep 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_For_Step_2__c 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_2__c ;*/
            DAS2_Amt1 = DASForAllStep 
                * (lawyerStep2Rate / 100 ) 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_2__c ;
            DAS2_Amt2 = DAS2_Amt1 * PolicyQuoteFor.Deductible_Factor__c;
            PolicyQuoteFor.Deductible_Amount_Step_2__c =  (DAS2_Amt1 - DAS2_Amt2).round(System.RoundingMode.HALF_UP);
            
            //Deductible_Amount_Step_3__c
            /*DAS3_Amt1 = DASForAllStep 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_For_Step_3__c 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_3__c ;*/
            DAS3_Amt1 = DASForAllStep 
                * (lawyerStep3Rate / 100 )
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_3__c ;
            DAS3_Amt2 = DAS3_Amt1 * PolicyQuoteFor.Deductible_Factor__c;
            PolicyQuoteFor.Deductible_Amount_Step_3__c =  (DAS3_Amt1 - DAS3_Amt2).round(System.RoundingMode.HALF_UP);
            
            //Deductible_Amount_Step_4__c
            DAS4_Amt1 = DASForAllStep 
                * (lawyerStep4Rate / 100 ) 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_4__c ;
            /*DAS4_Amt1 = DASForAllStep 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_For_Step_4__c 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_4__c ;*/
            DAS4_Amt2 = DAS4_Amt1 * PolicyQuoteFor.Deductible_Factor__c;
            PolicyQuoteFor.Deductible_Amount_Step_4__c =  (DAS4_Amt1 - DAS4_Amt2).round(System.RoundingMode.HALF_UP);
            
            //Deductible_Amount_Step_5__c
            /*DAS5_Amt1 = DASForAllStep 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_For_Step_5__c 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_5__c ;*/
            DAS5_Amt1 = DASForAllStep 
                * (lawyerStep5Rate / 100 ) 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_5__c ;
            DAS5_Amt2 = DAS5_Amt1 * PolicyQuoteFor.Deductible_Factor__c;
            PolicyQuoteFor.Deductible_Amount_Step_5__c =  (DAS5_Amt1 - DAS5_Amt2).round(System.RoundingMode.HALF_UP);
            
            //Deductible_Amount_Step_6__c
            /*DAS6_Amt1 = DASForAllStep 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_For_Step_6__c 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_6__c ;*/
            DAS6_Amt1 = DASForAllStep 
                * (lawyerStep6Rate / 100 ) 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_6__c ;
            DAS6_Amt2 = DAS6_Amt1 * PolicyQuoteFor.Deductible_Factor__c;
            PolicyQuoteFor.Deductible_Amount_Step_6__c =  (DAS6_Amt1 - DAS6_Amt2).round(System.RoundingMode.HALF_UP);
            
            //Deductible_Amount_Step_7__c
            /*DAS7_Amt1 = DASForAllStep 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_For_Step_7__c 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_7__c ;*/
            DAS7_Amt1 = DASForAllStep 
                * (lawyerStep7Rate / 100 ) 
                * PolicyMap.get(PolicyQuoteFor.Policy__c).Factor_Step_7__c ;
            DAS7_Amt2 = DAS7_Amt1 * PolicyQuoteFor.Deductible_Factor__c;
            PolicyQuoteFor.Deductible_Amount_Step_7__c =  (DAS7_Amt1 - DAS7_Amt2).round(System.RoundingMode.HALF_UP);
            
            System.debug(PolicyMap.get(PolicyQuoteFor.Policy__c).Expiration_Date__c);
            System.debug(PolicyMap.get(PolicyQuoteFor.Policy__c).Effective_Date__c);
            Decimal termOfPolicy;
            if(PolicyMap.get(PolicyQuoteFor.Policy__c).Expiration_Date__c !=null && PolicyMap.get(PolicyQuoteFor.Policy__c).Effective_Date__c!=null){
                Decimal daysBetween1 = PolicyMap.get(PolicyQuoteFor.Policy__c).Expiration_Date__c.daysBetween(PolicyMap.get(PolicyQuoteFor.Policy__c).Effective_Date__c);
                Decimal daysBetween2 =PolicyMap.get(PolicyQuoteFor.Policy__c).Effective_Date__c.addMonths(12).daysBetween(PolicyMap.get(PolicyQuoteFor.Policy__c).Effective_Date__c);
                termOfPolicy = daysBetween1 / daysBetween2; 
            }else{
                termOfPolicy = 1;
            }
            
                
            //Decimal termOfPolicy = PolicyMap.get(PolicyQuoteFor.Policy__c).Term__c;
            
            PolicyQuoteFor.Excess_Step_0__c =  PolicyQuoteFor.Excess_Factor__c != null ? (PolicyQuoteFor.Rate_Before_Deductible_Step_0__c/PolicyQuoteFor.Coverage_Factor__c)*PolicyQuoteFor.Excess_Factor__c : 0;
            PolicyQuoteFor.Excess_Step_1__c =  PolicyQuoteFor.Excess_Factor__c != null ? (PolicyQuoteFor.Rate_Before_Deductible_Step_1__c/PolicyQuoteFor.Coverage_Factor__c)*PolicyQuoteFor.Excess_Factor__c : 0;
            PolicyQuoteFor.Excess_Step_2__c =  PolicyQuoteFor.Excess_Factor__c != null ? (PolicyQuoteFor.Rate_Before_Deductible_Step_2__c/PolicyQuoteFor.Coverage_Factor__c)*PolicyQuoteFor.Excess_Factor__c : 0;
            PolicyQuoteFor.Excess_Step_3__c =  PolicyQuoteFor.Excess_Factor__c != null ? (PolicyQuoteFor.Rate_Before_Deductible_Step_3__c/PolicyQuoteFor.Coverage_Factor__c)*PolicyQuoteFor.Excess_Factor__c : 0;
            PolicyQuoteFor.Excess_Step_4__c =  PolicyQuoteFor.Excess_Factor__c != null ? (PolicyQuoteFor.Rate_Before_Deductible_Step_4__c/PolicyQuoteFor.Coverage_Factor__c)*PolicyQuoteFor.Excess_Factor__c : 0;
            PolicyQuoteFor.Excess_Step_5__c =  PolicyQuoteFor.Excess_Factor__c != null ? (PolicyQuoteFor.Rate_Before_Deductible_Step_5__c/PolicyQuoteFor.Coverage_Factor__c)*PolicyQuoteFor.Excess_Factor__c : 0;
            PolicyQuoteFor.Excess_Step_6__c =  PolicyQuoteFor.Excess_Factor__c != null ? (PolicyQuoteFor.Rate_Before_Deductible_Step_6__c/PolicyQuoteFor.Coverage_Factor__c)*PolicyQuoteFor.Excess_Factor__c : 0;
            PolicyQuoteFor.Excess_Step_7__c =  PolicyQuoteFor.Excess_Factor__c != null ? (PolicyQuoteFor.Rate_Before_Deductible_Step_7__c/PolicyQuoteFor.Coverage_Factor__c)*PolicyQuoteFor.Excess_Factor__c : 0;    
            
            
            
            // update premium
            PolicyQuoteFor.Quote_Premium_Step_0__c =   (PolicyQuoteFor.Rate_Before_Deductible_Step_0__c - PolicyQuoteFor.Deductible_Amount_Step_0__c)*termOfPolicy;
            PolicyQuoteFor.Quote_Premium_Step_1__c =   (PolicyQuoteFor.Rate_Before_Deductible_Step_1__c - PolicyQuoteFor.Deductible_Amount_Step_1__c)*termOfPolicy;
            PolicyQuoteFor.Quote_Premium_Step_2__c =   (PolicyQuoteFor.Rate_Before_Deductible_Step_2__c - PolicyQuoteFor.Deductible_Amount_Step_2__c)*termOfPolicy;
            PolicyQuoteFor.Quote_Premium_Step_3__c =   (PolicyQuoteFor.Rate_Before_Deductible_Step_3__c - PolicyQuoteFor.Deductible_Amount_Step_3__c)*termOfPolicy;
            PolicyQuoteFor.Quote_Premium_Step_4__c =   (PolicyQuoteFor.Rate_Before_Deductible_Step_4__c - PolicyQuoteFor.Deductible_Amount_Step_4__c)*termOfPolicy;
            PolicyQuoteFor.Quote_Premium_Step_5__c =   (PolicyQuoteFor.Rate_Before_Deductible_Step_5__c - PolicyQuoteFor.Deductible_Amount_Step_5__c)*termOfPolicy;
            PolicyQuoteFor.Quote_Premium_Step_6__c =   (PolicyQuoteFor.Rate_Before_Deductible_Step_6__c - PolicyQuoteFor.Deductible_Amount_Step_6__c)*termOfPolicy;
            PolicyQuoteFor.Quote_Premium_Step_7__c =   (PolicyQuoteFor.Rate_Before_Deductible_Step_7__c - PolicyQuoteFor.Deductible_Amount_Step_7__c)*termOfPolicy; 
            
            
            PolicyQuoteFor.Primary_Step_0__c = PolicyQuoteFor.Quote_Premium_Step_0__c - PolicyQuoteFor.Excess_Step_0__c;
            PolicyQuoteFor.Primary_Step_1__c = PolicyQuoteFor.Quote_Premium_Step_1__c - PolicyQuoteFor.Excess_Step_1__c;
            PolicyQuoteFor.Primary_Step_2__c = PolicyQuoteFor.Quote_Premium_Step_2__c - PolicyQuoteFor.Excess_Step_2__c;
            PolicyQuoteFor.Primary_Step_3__c = PolicyQuoteFor.Quote_Premium_Step_3__c - PolicyQuoteFor.Excess_Step_3__c;
            PolicyQuoteFor.Primary_Step_4__c = PolicyQuoteFor.Quote_Premium_Step_4__c - PolicyQuoteFor.Excess_Step_4__c;
            PolicyQuoteFor.Primary_Step_5__c = PolicyQuoteFor.Quote_Premium_Step_5__c - PolicyQuoteFor.Excess_Step_5__c;
            PolicyQuoteFor.Primary_Step_6__c = PolicyQuoteFor.Quote_Premium_Step_6__c - PolicyQuoteFor.Excess_Step_6__c;
            PolicyQuoteFor.Primary_Step_7__c = PolicyQuoteFor.Quote_Premium_Step_7__c - PolicyQuoteFor.Excess_Step_7__c;
            
            // start Update 5X5
            system.debug('20161220042700'+PolicyQuoteFor.X5X5_Override__c);
            
            Decimal totalLawyerRate = ((lawyerStep0Rate + lawyerStep1Rate + lawyerStep2Rate + lawyerStep3Rate + lawyerStep4Rate +
                                                                                         + lawyerStep5Rate + lawyerStep6Rate + lawyerStep7Rate) / 100 );
            
            Decimal totalLawyers = ((lawyerStep0Count + lawyerStep1Count + lawyerStep2Count + lawyerStep3Count + lawyerStep4Count +
                                                                                        + lawyerStep5Count + lawyerStep6Count + lawyerStep7Count) );
            
            If(PolicyQuoteFor.X5X5_Override__c!=null){
                system.debug('201612200427001'+PolicyQuoteFor.X5X5_Override__c);
                //PolicyQuoteFor.Quote_Premium_Amount__c = PolicyQuoteFor.Quote_Premium_Amount__c +  (PolicyQuoteFor.X5X5_Override__c * totalLawyerRate);
                PolicyQuoteFor.Quote_Premium_Amount__c = PolicyQuoteFor.Quote_Premium_Amount__c +  (PolicyQuoteFor.X5X5_Override__c * totalLawyers);
            }
            Else{
                If(PolicyQuoteFor.Is_5X5_Coverage__c==true){
                    system.debug('20161220042700Is_5X5_Coverage__c'+PolicyQuoteFor.Is_5X5_Coverage__c);
                    PolicyQuoteFor.Premium_Rate_5X5__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Premium_Rate_5X5__c;
                    If(lawyerStep0Count > 0){   
                        PolicyQuoteFor.Percnt_amt_5X5_Step_0__c       = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_0__c;
                        PolicyQuoteFor.Quote_Premium_Step0_For_5X5__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_0__c * 
                            lawyerStep0Count;
                        /*PolicyQuoteFor.Quote_Premium_Step0_For_5X5__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_0__c * 
                            (PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_Rate_For_Step_0__c / 100 );*/
                        PolicyQuoteFor.Quote_Premium_Step_0__c = PolicyQuoteFor.Quote_Premium_Step_0__c + PolicyQuoteFor.Quote_Premium_Step0_For_5X5__c; 
                    }
                    If(lawyerStep1Count > 0){                
                        PolicyQuoteFor.Percnt_amt_5X5_Step_1__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_1__c;
                        PolicyQuoteFor.Quote_Premium_Step1_For_5X5__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_1__c *
                            lawyerStep1Count;
                        /*PolicyQuoteFor.Quote_Premium_Step1_For_5X5__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_1__c *
                            (PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_Rate_For_Step_1__c / 100 );*/
                        PolicyQuoteFor.Quote_Premium_Step_1__c = PolicyQuoteFor.Quote_Premium_Step_1__c + PolicyQuoteFor.Quote_Premium_Step1_For_5X5__c; 
                    }
                    If(lawyerStep2Count > 0){                
                        PolicyQuoteFor.Quote_Premium_Step2_For_5X5__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_2__c * 
                            lawyerStep2Count;
                        /*PolicyQuoteFor.Quote_Premium_Step2_For_5X5__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_2__c * 
                            (PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_Rate_For_Step_2__c / 100 );*/
                        PolicyQuoteFor.Percnt_amt_5X5_Step_2__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_2__c;
                        PolicyQuoteFor.Quote_Premium_Step_2__c = PolicyQuoteFor.Quote_Premium_Step_2__c + PolicyQuoteFor.Quote_Premium_Step2_For_5X5__c; 
                    }
                    If(lawyerStep3Count > 0){                
                        PolicyQuoteFor.Quote_Premium_Step3_For_5X5__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_3__c * 
                            lawyerStep3Count;
                        /*PolicyQuoteFor.Quote_Premium_Step3_For_5X5__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_3__c * 
                            (PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_Rate_For_Step_3__c / 100 );*/
                        PolicyQuoteFor.Percnt_amt_5X5_Step_3__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_3__c;
                        PolicyQuoteFor.Quote_Premium_Step_3__c = PolicyQuoteFor.Quote_Premium_Step_3__c + PolicyQuoteFor.Quote_Premium_Step3_For_5X5__c; 
                    }
                    If(lawyerStep4Count > 0){                
                        PolicyQuoteFor.Quote_Premium_Step4_For_5X5__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_4__c * 
                            lawyerStep4Count;
                        /*PolicyQuoteFor.Quote_Premium_Step4_For_5X5__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_4__c * 
                            (PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_Rate_For_Step_4__c / 100 );*/
                        PolicyQuoteFor.Percnt_amt_5X5_Step_4__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_4__c;
                        PolicyQuoteFor.Quote_Premium_Step_4__c = PolicyQuoteFor.Quote_Premium_Step_4__c + PolicyQuoteFor.Quote_Premium_Step4_For_5X5__c; 
                    }                
                    If(lawyerStep5Count > 0){                
                        PolicyQuoteFor.Quote_Premium_Step5_For_5X5__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_5__c * 
                            lawyerStep5Count;
                        /*PolicyQuoteFor.Quote_Premium_Step5_For_5X5__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_5__c * 
                            (PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_Rate_For_Step_5__c / 100 );*/
                        PolicyQuoteFor.Percnt_amt_5X5_Step_5__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_5__c;
                        PolicyQuoteFor.Quote_Premium_Step_5__c = PolicyQuoteFor.Quote_Premium_Step_5__c + PolicyQuoteFor.Quote_Premium_Step5_For_5X5__c; 
                    }
                    If(lawyerStep6Count > 0){                
                        PolicyQuoteFor.Quote_Premium_Step6_For_5X5__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_6__c * 
                            lawyerStep6Count;
                        /*PolicyQuoteFor.Quote_Premium_Step6_For_5X5__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_6__c * 
                            (PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_Rate_For_Step_6__c / 100 );*/
                        PolicyQuoteFor.Percnt_amt_5X5_Step_6__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_6__c;
                        PolicyQuoteFor.Quote_Premium_Step_6__c = PolicyQuoteFor.Quote_Premium_Step_6__c + PolicyQuoteFor.Quote_Premium_Step6_For_5X5__c; 
                    }
                    If(lawyerStep7Count > 0){                
                        PolicyQuoteFor.Quote_Premium_Step7_For_5X5__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_7__c * 
                            lawyerStep7Count;
                        /*PolicyQuoteFor.Quote_Premium_Step7_For_5X5__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_7__c * 
                            (PolicyMap.get(PolicyQuoteFor.Policy__c).Total_Lawyers_Rate_For_Step_7__c / 100 );*/
                        PolicyQuoteFor.Percnt_amt_5X5_Step_7__c = Coverage5X5_Map.get(PolicyQuoteFor.Coverage__c).Percnt_amt_5X5_Step_7__c;
                        PolicyQuoteFor.Quote_Premium_Step_7__c = PolicyQuoteFor.Quote_Premium_Step_7__c + PolicyQuoteFor.Quote_Premium_Step7_For_5X5__c; 
                    }                                                     
                }   
            }   
            
            //  Premium add from All Steps
                        
            PolicyQuoteFor.Quote_Premium_Amount__c = PolicyQuoteFor.Quote_Premium_Amount__c +   
                PolicyQuoteFor.Quote_Premium_Step_0__c +
                PolicyQuoteFor.Quote_Premium_Step_1__c +    
                PolicyQuoteFor.Quote_Premium_Step_2__c +
                PolicyQuoteFor.Quote_Premium_Step_3__c +
                PolicyQuoteFor.Quote_Premium_Step_4__c +
                PolicyQuoteFor.Quote_Premium_Step_5__c +
                PolicyQuoteFor.Quote_Premium_Step_6__c +
                PolicyQuoteFor.Quote_Premium_Step_7__c ;
                

            // End update 5x5
            // start 10X10
            If(PolicyQuoteFor.X10X10__c!=null){
                //PolicyQuoteFor.Quote_Premium_Amount__c = PolicyQuoteFor.Quote_Premium_Amount__c +  (PolicyQuoteFor.X10X10__c * totalLawyerRate );
                PolicyQuoteFor.Quote_Premium_Amount__c = PolicyQuoteFor.Quote_Premium_Amount__c +  (PolicyQuoteFor.X10X10__c * totalLawyers );
            }
            // End 10x10        
            // Req. 1/6/2017 Premium should be rounded to nearest upper dollars(50 down, 51 goes up)
            
            
            
            /*Decimal endorsementMod = 1;
            
            if(PolicyQuoteFor.Mod_230__c!=null){
                endorsementMod *= PolicyQuoteFor.Mod_230__c;
            }
            
            if(PolicyQuoteFor.Mod_234__c!=null){
                endorsementMod *= PolicyQuoteFor.Mod_234__c;
            }
            
            if(PolicyQuoteFor.Mod_261__c!=null){
                endorsementMod *= PolicyQuoteFor.Mod_261__c;
            }
            
            PolicyQuoteFor.Quote_Premium_Amount__c = PolicyQuoteFor.Quote_Premium_Amount__c + (PolicyQuoteFor.Quote_Premium_Amount__c * (endorsementMod - 1));*/
            
            System.debug('Quote_Premium_Amount_Imported__c'+PolicyQuoteFor.Quote_Premium_Amount_Imported__c);
            if(PolicyQuoteFor.Quote_Premium_Amount_Imported__c!=null && PolicyQuoteFor.Quote_Premium_Amount__c > 0 ){
                Decimal adj = PolicyQuoteFor.Quote_Premium_Amount_Imported__c / PolicyQuoteFor.Quote_Premium_Amount__c;
                PolicyQuoteFor.Quote_Premium_Amount__c = PolicyQuoteFor.Quote_Premium_Amount__c + (PolicyQuoteFor.Quote_Premium_Amount__c * (adj - 1));
                PolicyQuoteFor.Quote_Premium_Amount_Imported__c = null;
            }
            
            PolicyQuoteFor.Quote_Premium_Amount__c =  PolicyQuoteFor.Quote_Premium_Amount__c.round(System.RoundingMode.HALF_Down);
            PolicyQuoteFor.Additional_Premium__c = PolicyMap.get(PolicyQuoteFor.Policy__c).Additional_Premium__c;
            PolicyQuoteFor.Title_Premium__c = PolicyMap.get(PolicyQuoteFor.Policy__c).Title_Premium__c;
            
            
            if(PolicyQuoteFor.Policy__r.RecordType.Name == 'SA-ERP'){
                if(PolicyQuoteFor.Coverage__r.Coverage_Max_Per_Claim__c == 250000 && PolicyQuoteFor.Coverage__r.Full_Coverage__c == 500000){
                    PolicyQuoteFor.Quote_Premium_Amount__c = 2600;
                }else if(PolicyQuoteFor.Coverage__r.Coverage_Max_Per_Claim__c == 500000 && PolicyQuoteFor.Coverage__r.Full_Coverage__c == 500000){
                    PolicyQuoteFor.Quote_Premium_Amount__c = 2900;
                }else if(PolicyQuoteFor.Coverage__r.Coverage_Max_Per_Claim__c == 1000000 && PolicyQuoteFor.Coverage__r.Full_Coverage__c == 1000000){
                    PolicyQuoteFor.Quote_Premium_Amount__c = 3200;
                }
                //PolicyQuoteFor.Quote_Premium_Amount__c =  (PolicyQuoteFor.Quote_Premium_Amount__c * (PolicyQuoteFor.Policy__r.SA_ERP_Mod__c != null ? PolicyQuoteFor.Policy__r.SA_ERP_Mod__c : 2.5))/100 ;
                //PolicyQuoteFor.Quote_Premium_Amount__c =  PolicyQuoteFor.Quote_Premium_Amount__c.round(System.RoundingMode.HALF_Down);
            } 
            
            system.debug('Return from method:'+PolicyQuoteFor);  
            // Update Quote Premium
            
            
            
        }
        
        Return PolicyQuoteLst2;                                                      
    }

    
    // Set Deductible in Quote
    Public static List<Policy_Quote__c> UpdateQuoteDataByDeductible(List<Policy_Quote__C> PolicyQuoteLst2){
        // SEt for Unique ID For Deductible Factor
        Set<ID> DeductibleFactorIDSet = new Set<ID>();
        For(Policy_Quote__C PolicyQuoteFor : PolicyQuoteLst2){
            DeductibleFactorIDSet.add(PolicyQuoteFor.Deductible__c);
        } 
        
        if(DeductibleFactorMap == null){
            DeductibleFactorMap  = new  Map<ID,Deductible_Factor__c>([
                select ID,name,Factor_Value__c,Deductible_Amount__c
                from Deductible_Factor__c ]);
        }
        // Captured all Deductible Factor which are involved in Policies
        /*Map<ID,Deductible_Factor__c>  DeductibleFactorMap  = new  Map<ID,Deductible_Factor__c>([
                                                    select ID,name,Factor_Value__c,Deductible_Amount__c
                                                    from Deductible_Factor__c 
                                                    where ID in :DeductibleFactorIDSet]);*/
        
        For(Policy_Quote__C PolicyQuoteFor :PolicyQuoteLst2){
            PolicyQuoteFor.Deductible_Factor__c = DeductibleFactorMap.get(PolicyQuoteFor.Deductible__c).Factor_Value__c;
            PolicyQuoteFor.Deductible_Amount__c = DeductibleFactorMap.get(PolicyQuoteFor.Deductible__c).Deductible_Amount__c;            
        }
            
        Return PolicyQuoteLst2;
        
    }
    
    
    // Set ILF / Coverage in Quote (including Lowest Factor & Hightest Factor)
    Public static List<Policy_Quote__c> UpdateQuoteDataByCoverage(List<Policy_Quote__C> PolicyQuoteLst2){
        // SEt for Unique ID For Coverage Factor
        Set<ID> CoverageFactorIDSet = new Set<ID>();
        Set<ID> CoverageFactor_ParentIDSet = new Set<ID>(); // for Lowest and Highest Factor and Mid
        
        For(Policy_Quote__C PolicyQuoteFor : PolicyQuoteLst2){
            CoverageFactorIDSet.add(PolicyQuoteFor.Coverage__c);
        } 
        // Captured all Coverage Factor which are involved in Policies
        List<ILF_Coverage_Factor__c> ilfList = TriggerFactory.getCoverageFactors(CoverageFactorIDSet);
        Map<ID,ILF_Coverage_Factor__c>  CoverageFactorMap  = new  Map<ID,ILF_Coverage_Factor__c>(ilfList);
        
        // coverage Factor infromation set in policy quote
        For(Policy_Quote__C PolicyQuoteFor :PolicyQuoteLst2){
            PolicyQuoteFor.Excess_Factor__c = CoverageFactorMap.get(PolicyQuoteFor.Coverage__c).X4x1_Rate__c;
            PolicyQuoteFor.Coverage_Factor__c           = CoverageFactorMap.get(PolicyQuoteFor.Coverage__c).Factor_Value__c;
            PolicyQuoteFor.Coverage_Max_Per_Claim__c    = CoverageFactorMap.get(PolicyQuoteFor.Coverage__c).Coverage_Max_Per_Claim__c;
            PolicyQuoteFor.Full_Coverage__c             = CoverageFactorMap.get(PolicyQuoteFor.Coverage__c).Full_Coverage__c;
            PolicyQuoteFor.Lowest_Coverage_MasterID__c  = CoverageFactorMap.get(PolicyQuoteFor.Coverage__c).Master_Factor__c;
            // PolicyQuoteFor.Highest_Coverage_MasterID__c  = CoverageFactorMap.get(PolicyQuoteFor.Coverage__c).Master_Factor__c;
            PolicyQuoteFor.Mid_Coverage_MasterID__c     = CoverageFactorMap.get(PolicyQuoteFor.Coverage__c).Master_Factor__c;
            // PolicyQuoteFor.Is_Excess_Value_Zero__c       = CoverageFactorMap.get(PolicyQuoteFor.Coverage__c).Is_Excess_Value_Zero__c;
            PolicyQuoteFor.Is_5X5_Coverage__c           = CoverageFactorMap.get(PolicyQuoteFor.Coverage__c).Is_5X5_Coverage__c;
            //          PolicyQuoteFor.First_Coverage_MasterID_For_5X5__c= CoverageFactorMap.get(PolicyQuoteFor.Coverage__c).Master_Factor__c;            
            
            // Master factor added
            CoverageFactor_ParentIDSet.add(CoverageFactorMap.get(PolicyQuoteFor.Coverage__c).Master_Factor__c);
            
        }
        
        // Map for Lowest coverage 
        /*List<ILF_Coverage_Factor__c> LowestCoverageFactor_Lst = [
            select Master_Factor__c,Factor_Value__c
            from ILF_Coverage_Factor__c 
            where Master_Factor__c in :CoverageFactor_ParentIDSet
            and Lowest_Coverage__c = true  ];*/
        List<ILF_Coverage_Factor__c> LowestCoverageFactor_Lst = TriggerFactory.getLowerCoverageFactors(CoverageFactor_ParentIDSet);
        Map<ID,Integer>  LowestCoverageFactor_Map  = new  Map<ID,Integer>();
        For(ILF_Coverage_Factor__c ILFCOvFactorFor :LowestCoverageFactor_Lst){
            //LowestCoverageFactor_Map.put(ILFCOvFactorFor.Master_Factor__c,Integer.valueOf(ILFCOvFactorFor.Lowest_Coverage__c));            
            LowestCoverageFactor_Map.put(ILFCOvFactorFor.Master_Factor__c,Integer.valueOf(ILFCOvFactorFor.Factor_Value__c));            
            
        }
        
        // List for Mid Coverage Factor value
        /*List<ILF_Coverage_Factor__c> MidCoverageFactor_Lst = new List<ILF_Coverage_Factor__c>([
            select Master_Factor__c,Factor_Value__c  
            from ILF_Coverage_Factor__c 
            where Master_Factor__c in :CoverageFactor_ParentIDSet
            and Mid_Coverage__c = true  ]);*/
        List<ILF_Coverage_Factor__c> MidCoverageFactor_Lst = TriggerFactory.getMidCoverageFactors(CoverageFactor_ParentIDSet);
        Map<ID,Decimal>  MidCoverageFactor_Map  = new  Map<ID,Decimal>();
        For(ILF_Coverage_Factor__c ILFCOvFactorFor :MidCoverageFactor_Lst){
            MidCoverageFactor_Map.put(ILFCOvFactorFor.Master_Factor__c,ILFCOvFactorFor.Factor_Value__c);            
        }
        
        // update quote list with lowest / highest / Mid factor value 
        For(Policy_Quote__C PolicyQuoteFor :PolicyQuoteLst2){
            PolicyQuoteFor.Lowest_Coverage_Factor__c    = LowestCoverageFactor_Map.get(PolicyQuoteFor.Lowest_Coverage_MasterID__c);
            // PolicyQuoteFor.Highest_Coverage_Factor__c    = HighestCoverageFactor_Map.get(PolicyQuoteFor.Highest_Coverage_MasterID__c); 
            PolicyQuoteFor.Mid_Coverage_Factor__c       = MidCoverageFactor_Map.get(PolicyQuoteFor.Mid_Coverage_MasterID__c); 
            CoverageFactor_ParentIDSet.add(CoverageFactorMap.get(PolicyQuoteFor.Coverage__c).Master_Factor__c);            
        }
        
        Return PolicyQuoteLst2;
        
    }
    

    // Get Policy Quote Data
    Public static List<Policy_Quote__C> GetQuoteData(Set<ID> PolicyIDSet2, List<Policy_Quote__C> PolicyQuoteLst2){
        PolicyQuoteLst2 = [select id,Policy__c,Coverage__c,Coverage_Factor__c,
                           Full_Coverage__c,Coverage_Max_Per_Claim__c,
                           Deductible__c,final_Quote__c,Quote_Final_Premium__c,Quote_Premium_AllStep_For_5X5__c,Mod_230__c,Mod_234__c,Mod_261__c,Excess_Final__c,Primary_Final__c,
                           Deductible_Amount__c,X5X5_Override__c,X10X10__c,ADJ_MOD__c,Quote_Premium_Amount_Imported__c,Additional_Premium__c,Title_Premium__c,Excess_Factor__c,Base_ILF_SRF_Step_0__c,Policy__r.RecordType.Name,/*Policy__r.SA_ERP_Mod__c,*/Coverage__r.Coverage_Max_Per_Claim__c , Coverage__r.Full_Coverage__c                            
                           from Policy_Quote__c 
                           where Policy__c in :PolicyIDSet2];
        Return   PolicyQuoteLst2;      
    }
    
    
}