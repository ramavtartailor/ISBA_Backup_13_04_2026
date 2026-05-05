public class QuotesDetailController{
    public String appId{get;set;}
    public List<Policy_Quote__c> policyQuoteList{get;set;}
    public List<WrapperClass> modalList{get;set;}
    public String error{get;set;}
    public Integer rowIdx{get;set;}
    private List<Policy_Quote__c> policyQuoteListRemove = New List<Policy_Quote__c> ();
    Map<Id,ILF_Coverage_Factor__c> threatMappingsLimits;
    public Policy__c policy{get;set;}
    public String limits{get;set;}
    public String deductibles{get;set;}
    public Boolean showAdvancedFields{get; set;}
    public List<Policy_Lawyer__c> policyLawyers{get;set;}
    public List<modVarWrap> totalModFields {get; set;}
    public List<modVarWrap> totalModFieldsFM {get; set;}
    public List<modVarWrap> totalModFieldsBO {get; set;}
    public List<modVarWrap> totalModFieldsTraining {get; set;}
    public List<modVarWrap> totalModFieldsGM {get; set;}
    public List<modVarWrap> totalModFieldsOver {get; set;}
    public Decimal claimsFactor{get;set;}
    public String termsConditions{get;set;}
    public String printQuoteURL{get;set;}
        
    public Decimal squenceNum{get;set;}
    public String policyId{get;set;}
    public Decimal totalLawyerRate{get;set;}
    public Decimal totalPrimary{get;set;}
    public Decimal total5x5{get;set;}
    public Decimal total10x10{get;set;}
    public Decimal totalExcess{get;set;}
    public Decimal totalAdjMod{get;set;}
    public Decimal totalLawyerPremium{get;set;}
    public Decimal totalCLECredit{get;set;}
    
    public Decimal deductibleFactor{get;set;}
    public Decimal limitFactor{get;set;}
    public Decimal firmMod{get;set;}
    public Decimal baseRate{get;set;}
    public String quoteLimit{get;set;}
    public String quoteDeductible{get;set;}
    public Decimal adjMod{get;set;}
    public Decimal mod_230{get;set;}
    public Decimal mod_234{get;set;}
    public Decimal mod_261{get;set;}
    
    public QuotesDetailController(){
        totalLawyerRate = totalPrimary = total5x5 = total10x10 = totalAdjMod = totalLawyerPremium = totalCLECredit = totalExcess = 0;
        deductibleFactor = limitFactor = firmMod = baseRate = 0;
        quoteLimit = quoteDeductible = '';
        policyQuoteListRemove = New List<Policy_Quote__c> ();
        appId =  ApexPages.currentPage().getParameters().get('Id');
        policyQuoteList = new List<Policy_Quote__c>();
        
        policyQuoteList = [SELECT Id,name,Coverage__c,Coverage__r.name,Deductible__c,Deductible__r.name,Quote_Expire_Date__c,X10X10__c,ADJ_R_O__c,Additional_Premium__c,Title_Premium__c,Sequence__c,Policy__c,Coverage_Factor__c,Deductible_Factor__c,
                        Terms_Conditions__c, Final_Quote__c ,X5X5_Override__c,Coverage__r.Is_5X5_Coverage__c,Coverage__r.Is_10X10_Coverage__c,ADJ_MOD__c,Quote_Final_Premium__c,Mod_230__c,Mod_234__c,Mod_261__c,Limits__c,Deductibles_Formula__c FROM Policy_Quote__c WHERE Policy__c = :appId order by Sequence__c ASC];
        
        DescribeSObjectResult describeResult = Policy__c.getSObjectType().getDescribe();
        List<String> fieldNames = new List<String>(describeResult.fields.getMap().keySet());
        String query =	' SELECT Account__r.Name,Limit__r.Name,Deductible_ID__r.Name,' + String.join(fieldNames, ',') + ' FROM Policy__c where id=:  appId'	;	
        policy = Database.query(query);
        claimsFactor = policy.Claims_Factor__c;
        termsConditions = policy.Terms_Conditions__c;
        //policy = [select id, Terms_Conditions__C,Account__r.Name,Name,Effective_Date__c,X10x10__c,X5_5_Override__c from Policy__C where id = :appId ];
        modalList = new List<WrapperClass>();
        System.debug('==modalList=='+modalList);
        if(policyQuoteList.size() > 0){
            Decimal indx = 1;
            for(Policy_Quote__c quote : policyQuoteList){
                WrapperClass modObj = new WrapperClass();
                /*quote.Quote_Expire_Date__c = Date.Today().adddays(30);
                if(quote.Quote_Expire_Date__c > policy.Effective_Date__c){
                    quote.Quote_Expire_Date__c = policy.Effective_Date__c;
                }*/
                modObj.policyQuoteObj = quote;
                modObj.isFinal = quote.Final_Quote__c;
                modObj.isAdjRO = quote.ADJ_R_O__c;
                modObj.is5X5 = quote.Coverage__r.Is_5X5_Coverage__c;
                modObj.is10X10 = quote.Coverage__r.Is_10X10_Coverage__c;
                modObj.finalPremium = quote.Quote_Final_Premium__c;
                modObj.quoteLimit = quote.Limits__c;
                modObj.quoteDeductible = quote.Deductibles_Formula__c;
                indx = quote.Sequence__c != null ? quote.Sequence__c : indx;
                modObj.policyQuoteObj.Sequence__c = indx;
                if((quote.ADJ_MOD__c != null && quote.ADJ_MOD__c != 1) || quote.Mod_230__c  != null || quote.Mod_234__c  != null || quote.Mod_261__c  != null){
                    modObj.isExpandable = true;
                }
                modalList.add(modObj);
                indx++;
            }
        }else{
            /*WrapperClass modObj = new WrapperClass();
            modObj.isFinal = false;
            modObj.is10X10=false;
            modObj.is5X5=false;
            modalList.add(modObj);*/
        }   
        
        showAdvancedFields = false;
        Set<Id> setAdvanceUserId = new Set<Id>();
        for(GroupMember objGroupMember : [SELECT Id, UserOrGroupId FROM GroupMember where Group.Name = 'Advance Users']){
            setAdvanceUserId.add(objGroupMember.UserOrGroupId);
        }
        
        showAdvancedFields = (setAdvanceUserId.contains(UserInfo.getUserId())?true:false);             
    }
    
    //WrapperClass
    public class WrapperClass{
        public Boolean isFinal{get;set;}
        public Policy_Quote__c policyQuoteObj{get;set;}
        public Boolean is5X5{get;set;}
        public Boolean is10X10{get;set;}
        public Decimal finalPremium{get;set;}
        public boolean isAdjRO{get;set;}
        public boolean printQuote{get;set;}
        public String quoteLimit{get;set;}
        public String quoteDeductible{get;set;}
        public boolean isExpandable{get;set;}
        public WrapperClass(){
            //isFinal = false;
            policyQuoteObj = new Policy_Quote__c();
            //policyQuoteObj.Quote_Expire_Date__c = Date.Today().adddays(30);
            policyQuoteObj.ADJ_MOD__c = 1.0;
            finalPremium = 0;
            printQuote =true;
            
        }
    }
    
      
    public PageReference saveQuote(){
        try{
            error = '';
            
            if(policyQuoteListRemove.size() > 0){
                
                Integer j = 0;
                
                for(Policy_Quote__c obj : policyQuoteListRemove){
                    
                    j = 0;
                    while (j < policyQuoteList.size())
                    {
                        if(obj.Id == policyQuoteList.get(j).Id)
                        {
                            policyQuoteList.remove(j);
                        }else {
                            j++;
                        }
                    }
                    
                }
                
                delete policyQuoteListRemove;
                
                policyQuoteListRemove = New List<Policy_Quote__c>();
            }
            /*Map<String, ILF_Coverage_Factor__c> coverageMap = new Map<String, ILF_Coverage_Factor__c>();
            Deductible_Factor__c dedfactor = new Deductible_Factor__c();
            if(policy.Type__c == 'SA-ERP'){
                coverageMap = new Map<String, ILF_Coverage_Factor__c>([SELECT Id,Name,Is_10X10_Coverage__c,Is_5X5_Coverage__c FROM ILF_Coverage_Factor__c WHERE From_Date__c <=: policy.Effective_Date__c and  To_Date__c >=: policy.Effective_Date__c and OldLimit__c = false AND Full_Coverage__c <= 1000000 ORDER BY Coverage_Max_Per_Claim__c,Full_Coverage__c ASC LIMIT 1000]);
                dedfactor = [SELECT Id,Name FROM Deductible_Factor__c where From_Date__c <=: policy.Effective_Date__c and  To_Date__c >=: policy.Effective_Date__c AND Deductible_Amount__c = 0 ORDER BY Deductible_Amount__c ASC LIMIT 1];
            }   */         
            List<Policy_Quote__c> policy_quote_upsertLst = New List<Policy_Quote__c>();
            Policy_Quote__c finalQuote;
            System.debug('modalList====='+modalList);
            for(WrapperClass mod : modalList){
                System.debug('mod====='+mod);
                if(mod.isAdjRO!=null && mod.isAdjRO){
                    mod.policyQuoteObj.Adj_R_O__c = true;
                }else{
                    mod.policyQuoteObj.Adj_R_O__c = false;
                }
                /*if(policy.Type__c == 'SA-ERP'){
                    system.debug('coverageMap Keys=> '+coverageMap.keySet());
                    system.debug(' => '+coverageMap.containsKey(mod.policyQuoteObj.Coverage__c));
                    if(!coverageMap.containsKey(mod.policyQuoteObj.Coverage__c)){
                        error = 'Quote\'s Limit Should be less then or Equal to 1000000.';
                    }
                    system.debug('Deductible => '+mod.policyQuoteObj.Deductible__c +' => '+dedfactor.Id);
                    if(mod.policyQuoteObj.Deductible__c != dedfactor.Id){
                        error = String.isNotBlank(error) ?  error + ' And Deductible should be Equal to 0.' : 'Deductible should be Equal to 0.';
                    }
                    system.debug('String.isNotBlank(error) => '+error);
                    if(String.isNotBlank(error)){
                        system.debug('1 => '+coverageMap.containsKey(mod.policyQuoteObj.Coverage__c));
                        return null;                        
                    }
                    system.debug('2 => '+coverageMap.containsKey(mod.policyQuoteObj.Coverage__c));   
                }*/              
                if(mod.isFinal){
                    if(mod.policyQuoteObj.Quote_Expire_Date__c <= system.today()){
                        error = 'Selected quote is expired .';
                        return null;
                    }else{
                        mod.policyQuoteObj.Final_Quote__c = true;
                        finalQuote = mod.policyQuoteObj;
                    }
                }else{
                    mod.policyQuoteObj.Final_Quote__c = false;
                    policy_quote_upsertLst.add(mod.policyQuoteObj);
                }
                // getting records
                if(String.IsBlank(mod.policyQuoteObj.Id)){
                    mod.policyQuoteObj.Policy__c = appId ;
                }
            }
            
            //update policy;
            if(policy_quote_upsertLst.size() > 0){
                upsert policy_quote_upsertLst;
            }
            if(finalQuote!=null){
                TriggerFactory.isUpdatePremium = true;
                upsert finalQuote;
            }
            
            
            /*try{
                
                error = '';
                Id excludeQuote;
                List<Policy_Quote__c> quoteList = new List<Policy_Quote__c>();
                List<Policy_Quote__c> quoteList2 = new List<Policy_Quote__c>();
                
                for(WrapperClass mod : modalList){
                    
                    if(mod.isFinal == true ){
                        
                        if(mod.policyQuoteObj.Quote_Expire_Date__c <= system.today()){
                            error = 'Selected quote is expired .';
                            return null;
                        }else{
                            mod.policyQuoteObj.Final_Quote__c = mod.isFinal;
                            excludeQuote = mod.policyQuoteObj.Id;
                            quoteList.add(mod.policyQuoteObj);
                        }
                    }
                }
                
                if(quoteList.size() > 0){
                    if(policyQuoteList.size() > 0){
                        for(Policy_Quote__c quote : policyQuoteList){
                            if( excludeQuote != quote.Id ){
                                quote.Final_Quote__c = false;
                                quoteList2.add( quote );
                            }
                        }
                        if( quoteList2.size() > 0 ){
                            update quoteList2;
                        }
                    }
                
                    update quoteList;
                    
                    
                }
                
            }catch(DMLException e){
    
                 error = e.getdmlMessage(0);
                 System.debug('error---'+e.getdmlMessage(0));
                 
                
            }catch(Exception e){
            
                 error = e.getMessage();
                 System.debug('error---'+e.getMessage());     
            }
            
            
            //Testing Issue for Final Premium
            update policy; */
 
       } catch(DMLException e){            error = e.getdmlMessage(0);            System.debug('error---'+e.getdmlMessage(0));
                 
       } catch(Exception e){         error = e.getMessage();
           System.debug('error---'+e.getMessage());
                 
       }
       
       return null;
    }
    
    public void printSelectedQuotes(){
        String ids = '';
        for(WrapperClass mod : modalList){
            if(!mod.printQuote){
                ids += (mod.policyQuoteObj.Id + ';');
            }
        }
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename="'+'Test.pdf'+'"');
        printQuoteURL = '/apex/PrintQuotes?id=' + appId + '&type=quoteBundle&removeQuoteIds='+ids;
    }
    public void recalculateQuotesPremium(){
        saveQuote();
    }
    public void updatePolicy(){
        policy.Terms_Conditions__c = termsConditions;
        update policy;
        
        DescribeSObjectResult describeResult = Policy__c.getSObjectType().getDescribe();
        List<String> fieldNames = new List<String>(describeResult.fields.getMap().keySet());
        String query =	' SELECT Account__r.Name,' + String.join(fieldNames, ',') + ' FROM Policy__c where id=:  appId'	;	
        policy = Database.query(query);
        
        Map<Id,Policy_Quote__c> updatedQuotes = new Map<Id,Policy_Quote__c>([select id,Quote_Final_Premium__c,Coverage_Factor__c,Deductible_Factor__c,Limits__c,Deductibles_Formula__c from Policy_Quote__c where Policy__c =: appId]);
        for(WrapperClass modObj : modalList){
            if(modObj.policyQuoteObj.Id!=null &&  updatedQuotes.containsKey(modObj.policyQuoteObj.Id)){
                modObj.finalPremium = updatedQuotes.get(modObj.policyQuoteObj.Id).Quote_Final_Premium__c;
            }
        }
    }
    public void addLimit(){
        List<Policy_Quote__c> quotes = new List<Policy_Quote__c>();
        limits = limits.remove('[');        limits = limits.remove(']');        deductibles = deductibles.remove('[');        deductibles = deductibles.remove(']');
        if(limits.split(',').size()>0 && deductibles.split(',').size()>0){
            for(String str : limits.split(',')){
                for(String str1 : deductibles.split(',')){
                    if(String.isNotBlank(str.trim()) && String.isNotBlank(str1.trim())){
                        WrapperClass modObj = new WrapperClass();
                        modObj.isFinal = false;
                        modObj.is10X10=false;
                        modObj.is5X5=false;
                        modObj.printQuote= true;
                        modObj.policyQuoteObj.Coverage__c = str.trim();
                        modObj.policyQuoteObj.Deductible__c = str1.trim();
                       /* modObj.policyQuoteObj.Quote_Expire_Date__c = Date.Today().adddays(30);
                        if(modObj.policyQuoteObj.Quote_Expire_Date__c > policy.Effective_Date__c){
                            modObj.policyQuoteObj.Quote_Expire_Date__c = policy.Effective_Date__c;
                        }*/
                        modObj.policyQuoteObj.Quote_Expire_Date__c = policy.Effective_Date__c;
                        if(threatMappingsLimits.containsKey(modObj.policyQuoteObj.Coverage__c)){
                            if(threatMappingsLimits.get(modObj.policyQuoteObj.Coverage__c).Is_10X10_Coverage__c){
                                modObj.is10X10=true;
                                if(modObj.policyQuoteObj.X10X10__c == null){
                                    modObj.policyQuoteObj.X10X10__c = policy.X10x10__c;
                                }
                            }
                            if(threatMappingsLimits.get(modObj.policyQuoteObj.Coverage__c).Is_5X5_Coverage__c){
                                modObj.is5X5=true;
                                if(modObj.policyQuoteObj.X5X5_Override__c == null){
                                    modObj.policyQuoteObj.X5X5_Override__c = policy.X5_5_Override__c;
                                }
                            }
                        }
                        modObj.policyQuoteObj.Policy__c = appId;
                        modalList.add(modObj);
                        quotes.add(modObj.policyQuoteObj);
                    }
                }
            }
            if(quotes.size()>0){
                upsert quotes;
                Map<Id,Policy_Quote__c> updatedQuotes = new Map<Id,Policy_Quote__c>([select id,Quote_Final_Premium__c,Deductible_Factor__c,Coverage_Factor__c,Limits__c,Deductibles_Formula__c from Policy_Quote__c where id in: quotes]);
                for(WrapperClass modObj : modalList){
                    if(modObj.policyQuoteObj.Id!=null &&  updatedQuotes.containsKey(modObj.policyQuoteObj.Id)){
                        modObj.finalPremium = updatedQuotes.get(modObj.policyQuoteObj.Id).Quote_Final_Premium__c;
                        modObj.policyQuoteObj.Deductible_Factor__c = updatedQuotes.get(modObj.policyQuoteObj.Id).Deductible_Factor__c;
                        modObj.policyQuoteObj.Coverage_Factor__c = updatedQuotes.get(modObj.policyQuoteObj.Id).Coverage_Factor__c;
                        modObj.quoteLimit = updatedQuotes.get(modObj.policyQuoteObj.Id).Limits__c;
                        modObj.quoteDeductible = updatedQuotes.get(modObj.policyQuoteObj.Id).Deductibles_Formula__c;
                    }
                }
            }
        }
    }
    public void addRow(){
        WrapperClass modObj = new WrapperClass();
        modObj.isFinal = false;
        modObj.isAdjRO = false;
        modObj.is10X10=false;
        modObj.is5X5=false;
        modObj.printQuote = true;
        /*modObj.policyQuoteObj.Quote_Expire_Date__c = Date.Today().adddays(30);
        if(modObj.policyQuoteObj.Quote_Expire_Date__c > policy.Effective_Date__c){
            modObj.policyQuoteObj.Quote_Expire_Date__c = policy.Effective_Date__c;
        }*/
        modObj.policyQuoteObj.Quote_Expire_Date__c = policy.Effective_Date__c;
        modalList.add(modObj);
    }
    //Remove Row
    public void removeRow(){
        error = '';
        if( rowIdx > -1 && modalList.size() > 0 ){
                if(String.IsNotBlank(modalList[rowIdx].policyQuoteObj.Id)){
                    policyQuoteListRemove.add(modalList[rowIdx].policyQuoteObj );
                } 
                
            modalList.remove( rowIdx );
        }
    }
    public void updateFinalPremium(){
        if( rowIdx > -1 && modalList.size() > 0 ){
            if(String.IsNotBlank(modalList[rowIdx].policyQuoteObj.Coverage__c) && String.IsNotBlank(modalList[rowIdx].policyQuoteObj.Deductible__c)){
                try{
                    if(String.IsBlank(modalList[rowIdx].policyQuoteObj.Id)){
                        modalList[rowIdx].policyQuoteObj.Policy__c = appId;
                    }
                    upsert  modalList[rowIdx].policyQuoteObj;
                    Policy_Quote__c quote = [select id,Quote_Final_Premium__c,Coverage_Factor__c,Deductible_Factor__c,Limits__c,Deductibles_Formula__c from Policy_Quote__c where id=:modalList[rowIdx].policyQuoteObj.Id];
                    modalList[rowIdx].finalPremium = quote.Quote_Final_Premium__c;
                    modalList[rowIdx].policyQuoteObj.Deductible_Factor__c = quote.Deductible_Factor__c;
                    modalList[rowIdx].policyQuoteObj.Coverage_Factor__c = quote.Coverage_Factor__c;
                    modalList[rowIdx].quoteLimit = quote.Limits__c;
                    modalList[rowIdx].quoteDeductible = quote.Deductibles_Formula__c;
                }catch(Exception e){
                    modalList[rowIdx].finalPremium = 0;
                    error = e.getMessage();
                    System.debug(e.getMessage());
                }
            }else{
                modalList[rowIdx].finalPremium = 0;
            }
        }
    }
    public void updateQuotePremiumByPolicyLawyer(){
        if( rowIdx > -1 && modalList.size() > 0 && String.IsNotBlank(modalList[rowIdx].policyQuoteObj.Coverage__c) && String.IsNotBlank(modalList[rowIdx].policyQuoteObj.Deductible__c)){
            SavePoint sp = Database.setSavepoint();
            try{
                deductibleFactor = limitFactor = firmMod = baseRate = 0;
                quoteLimit = quoteDeductible = '';
                List<Policy_Quote__c> quotes = new List<Policy_Quote__c>();
                Policy_Quote__c finalQuote;
                WrapperClass wrap;
                for(Integer i=0;i<modalList.size();i++){
                    if(String.IsNotBlank(modalList[i].policyQuoteObj.Coverage__c) && String.IsNotBlank(modalList[i].policyQuoteObj.Deductible__c)){
                        if(String.IsBlank(modalList[i].policyQuoteObj.Id)){
                            modalList[i].policyQuoteObj.Policy__c = appId;
                        }
                        if(rowIdx == i){
                            modalList[i].policyQuoteObj.Final_Quote__c = true;
                            finalQuote = modalList[i].policyQuoteObj;
                            wrap = modalList[i];
                        }else{
                            modalList[i].policyQuoteObj.Final_Quote__c = false;
                            quotes.add(modalList[i].policyQuoteObj);
                        }
                    }
                }
                upsert quotes;
                TriggerFactory.isUpdatePremium = true;
                upsert finalQuote;
                policyLawyers = new List<Policy_Lawyer__c>();
                totalLawyerRate = totalPrimary = total5x5 = total10x10 = totalAdjMod = totalLawyerPremium = totalCLECredit = totalExcess = 0;
                for(Policy_Lawyer__c lawyer : [select id,Lawyer_Name__c,Prior_Act_Date__c,Step__c,Overriding_Step_Value__c,Rate_At__c,Primary__c,X5_5__c,X10_10__c,ADJ_MOD__c,Premium__c,Mod_230__c,Mod_234__c,Mod_261__c,CLE_Credit__c,Excess__c from Policy_Lawyer__c where Policy__c =: appId order by Lawyer__r.Contact__r.LastName ]){
                    totalLawyerRate += lawyer.Rate_At__c !=null ? lawyer.Rate_At__c : 0;
                    totalPrimary += lawyer.Primary__c !=null ? lawyer.Primary__c : 0;
                    totalExcess += lawyer.Excess__c !=null ? lawyer.Excess__c : 0;
                    total5x5 += lawyer.X5_5__c !=null ? lawyer.X5_5__c : 0;
                    total10x10 += lawyer.X10_10__c !=null ? lawyer.X10_10__c : 0;
                    totalAdjMod += lawyer.ADJ_MOD__c !=null ? lawyer.ADJ_MOD__c : 0;
                    totalLawyerPremium += lawyer.Premium__c !=null ? lawyer.Premium__c : 0;
                    totalCLECredit += lawyer.CLE_Credit__c !=null ? lawyer.CLE_Credit__c : 0;
                    policyLawyers.add(lawyer);
                }
                for(Integer i=0;i<modalList.size();i++){
                    modalList[i].policyQuoteObj.Final_Quote__c = modalList[i].isFinal;
                }
                deductibleFactor = finalQuote.Deductible_Factor__c;
                limitFactor = finalQuote.Coverage_Factor__c;
                baseRate = policy.Base_Amount__c;
                firmMod = policy.Firm_Mod__c;
                quoteLimit = wrap.quoteLimit;
                quoteDeductible = wrap.quoteDeductible;
                adjMod = finalQuote.ADJ_MOD__c!=null ? finalQuote.ADJ_MOD__c : 0;
                mod_230 = finalQuote.Mod_230__c!=null ? finalQuote.Mod_230__c : 0;
                mod_234 = finalQuote.Mod_234__c!=null ? finalQuote.Mod_234__c : 0;
                mod_261 = finalQuote.Mod_261__c!=null ? finalQuote.Mod_261__c : 0;
                Database.rollback(sp);
            }catch(Exception e){
                policyLawyers = new List<Policy_Lawyer__c>();
                error = e.getMessage();
                Database.rollback(sp);
            }
        }
    }
    public void update10X10And5X5(){
        error = '';
        if( rowIdx > -1 && modalList.size() > 0 ){
            if(String.IsNotBlank(modalList[rowIdx].policyQuoteObj.Coverage__c) && threatMappingsLimits.containsKey(modalList[rowIdx].policyQuoteObj.Coverage__c)){
                if(threatMappingsLimits.get(modalList[rowIdx].policyQuoteObj.Coverage__c).Is_10X10_Coverage__c){
                    modalList[rowIdx].is10X10=true;
                    if(modalList[rowIdx].policyQuoteObj.X10X10__c == null){
                        modalList[rowIdx].policyQuoteObj.X10X10__c = policy.X10x10__c;
                    }
                }else{
                    modalList[rowIdx].is10X10=false;
                    modalList[rowIdx].policyQuoteObj.X10X10__c=null;
                }
                if(threatMappingsLimits.get(modalList[rowIdx].policyQuoteObj.Coverage__c).Is_5X5_Coverage__c){
                    modalList[rowIdx].is5X5=true;
                    if(modalList[rowIdx].policyQuoteObj.X5X5_Override__c == null){
                        modalList[rowIdx].policyQuoteObj.X5X5_Override__c = policy.X5_5_Override__c;
                    }
                }else{
                    modalList[rowIdx].is5X5=false;
                    modalList[rowIdx].policyQuoteObj.X5X5_Override__c=null;
                }
            }else{
                modalList[rowIdx].is5X5=false;
                modalList[rowIdx].is10X10=false;
                modalList[rowIdx].policyQuoteObj.X10X10__c=null;
                modalList[rowIdx].policyQuoteObj.X5X5_Override__c=null;
            }
        }
    }
    public List<SelectOption> getLimit () {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select Limit-'));
        if(policy.Type__c == 'SA-ERP'){
            threatMappingsLimits = new Map<Id,ILF_Coverage_Factor__c>();
                
            List<ILF_Coverage_Factor__c> coverageFactors = [SELECT Id,Name,Is_10X10_Coverage__c,Is_5X5_Coverage__c,Full_Coverage__c,Coverage_Max_Per_Claim__c FROM ILF_Coverage_Factor__c WHERE From_Date__c <=: policy.Effective_Date__c and  To_Date__c >=: policy.Effective_Date__c and OldLimit__c = false AND Full_Coverage__c <= 1000000 ORDER BY Coverage_Max_Per_Claim__c,Full_Coverage__c ASC LIMIT 1000];
            
            for(ILF_Coverage_Factor__c cf: coverageFactors){
                if(!(cf.Coverage_Max_Per_Claim__c == 500000 && cf.Full_Coverage__c == 1000000)){
                    threatMappingsLimits.put(cf.Id, cf);
                }
            }
        }
        else{
            threatMappingsLimits = new Map<Id,ILF_Coverage_Factor__c>([SELECT Id,Name,Is_10X10_Coverage__c,Is_5X5_Coverage__c FROM ILF_Coverage_Factor__c WHERE From_Date__c <=: policy.Effective_Date__c and  To_Date__c >=: policy.Effective_Date__c and OldLimit__c = false ORDER BY Coverage_Max_Per_Claim__c,Full_Coverage__c ASC LIMIT 1000]);
        }
        for (ILF_Coverage_Factor__c threatMapping : threatMappingsLimits.values()) {
                options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
        }
        return options;
    }
     public List<SelectOption> getDeductible () {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select Deductible-'));
         Deductible_Factor__c[] threatMappings = new List<Deductible_Factor__c>();
         if(policy.Type__c == 'SA-ERP'){
             threatMappings = [SELECT Id,Name FROM Deductible_Factor__c where From_Date__c <=: policy.Effective_Date__c and  To_Date__c >=: policy.Effective_Date__c AND Deductible_Amount__c = 0 ORDER BY Deductible_Amount__c ASC LIMIT 1000];
         }
         else{
             threatMappings = [SELECT Id,Name FROM Deductible_Factor__c where From_Date__c <=: policy.Effective_Date__c and  To_Date__c >=: policy.Effective_Date__c ORDER BY Deductible_Amount__c ASC LIMIT 1000];
         }      
         
         System.debug('policy.Effective_Date__c'+policy.Effective_Date__c);
         for (Deductible_Factor__c threatMapping : threatMappings) {
             options.add(new SelectOption(threatMapping.Id,threatMapping.Name));
         }
         return options;
    }
    public List<modVarWrap> getAllModFields() {
        totalModFields = new List<modVarWrap>();
        
        getFieldSetFields('SCH_Mod', 'SCH_Mod_Override', 'SCH_Override_Comment', totalModFields);
        
        return totalModFields;
    }
    
    public List<modVarWrap> getAllModFieldsFM() {
        totalModFieldsFM = new List<modVarWrap>();
        
        getFieldSetFields('SCH_Mod_FM', 'SCH_Mod_Override_FM', 'SCH_Override_Comment_FM', totalModFieldsFM);
        
        return totalModFieldsFM;
    }
    
    public List<modVarWrap> getAllModFieldsBO() {
        totalModFieldsBO = new List<modVarWrap>();
        
        getFieldSetFields('SCH_Mod_BO', 'SCH_Mod_Override_BO', 'SCH_Override_Comment_BO', totalModFieldsBO);
        
        return totalModFieldsBO;
    }
    
    public List<modVarWrap> getAllModFieldsTraining() {
        totalModFieldsTraining = new List<modVarWrap>();
        
        getFieldSetFields('SCH_Mod_Training', 'SCH_Mod_Override_Training', 'SCH_Override_Comment_Training', totalModFieldsTraining);
        
        return totalModFieldsTraining;
    }
    
    public List<modVarWrap> getAllModFieldsGM() {
        totalModFieldsGM = new List<modVarWrap>();
        
        getFieldSetFields('SCH_Mod_GM', 'SCH_Mod_Override_GM', 'SCH_Override_Comment_GM', totalModFieldsGM);
        
        return totalModFieldsGM;
    }
    
    public List<modVarWrap> getAllModFieldsOver() {
        totalModFieldsOver = new List<modVarWrap>();
        
        getFieldSetFields('SCH_Mod_Over', 'SCH_Mod_Override_Over', 'SCH_Override_Comment_Over', totalModFieldsOver);
        
        return totalModFieldsOver;
    }
    
    public void getFieldSetFields(String fieldSetName1, String fieldSetName2, String fieldSetName3, List<modVarWrap> actualModWrapList){
        Map<Integer, Schema.FieldSetMember> modValMap = new Map<Integer, Schema.FieldSetMember>();
        
        Integer i = 0;
        for(Schema.FieldSetMember fsm: SObjectType.Policy__c.FieldSets.getMap().get(fieldSetName1).getFields()){
            modValMap.put(i, fsm);
            i++;
        }
        
        Map<Integer, Schema.FieldSetMember> modOverrideMap = new Map<Integer, Schema.FieldSetMember>();
        
        i = 0;
        for(Schema.FieldSetMember fsm: SObjectType.Policy__c.FieldSets.getMap().get(fieldSetName2).getFields()){
            modOverrideMap.put(i, fsm);
            i++;
        }
        
        Map<Integer, Schema.FieldSetMember> modCommentMap = new Map<Integer, Schema.FieldSetMember>();
        
        i = 0;
        for(Schema.FieldSetMember fsm: SObjectType.Policy__c.FieldSets.getMap().get(fieldSetName3).getFields()){
            modCommentMap.put(i, fsm);
            i++;
        }
        
        for(Integer j : modValMap.keySet()){
            modVarWrap mVarWrap = new modVarWrap();
            String label = modValMap.get(j).getLabel();
            if(label == 'Client Intake/New Matter Acceptance Proc'){
                mVarWrap.label = 'Client Intake/New Matter Acceptance Procedures';
            }
            
            if(label == 'Use of Client Engagement/Contingency Fe'){
                mVarWrap.label = 'Use of  Client Engagement/Contingency Fee Agreement Letters';
            }
            
            if(label == 'Use of Declination/Non-Engagement Lette'){
                mVarWrap.label = 'Use of  Declination/Non-Engagement Letters';
            }
            if(label == 'Docket/Conflict Coordination with Main'){
                mVarWrap.label = 'Docket/Conflict Coordination with Main Office';
            }
            if(label == 'Size of Firm'){
                mVarWrap.label = 'Size of Firm (1% credit/attorney after 1st attorney – up to 10% credit allowed)';
            }
            if(label != 'Client Intake/New Matter Acceptance Proc' && label != 'Use of Client Engagement/Contingency Fe' && label != 'Use of Declination/Non-Engagement Lette' 
                && label != 'Docket/Conflict Coordination with Main' && label != 'Size of Firm'){
                mVarWrap.label = label;
            }
            mVarWrap.fsmModVal = modValMap.get(j);
            mVarWrap.fsmOverride = modOverrideMap.get(j);
            mVarWrap.fsmComment = modCommentMap.get(j);
            
            actualModWrapList.add(mVarWrap);
        }
    }
    public class modVarWrap{
        public String label        {get; set;}  
        public Schema.FieldSetMember fsmModVal {get; set;}       
        public Schema.FieldSetMember fsmOverride {get; set;}  
        public Schema.FieldSetMember fsmComment {get; set;}  
    }
    
    public void ClonePolicy(){
        
        List<WrapperClass> finalList = new List<WrapperClass>();
        finalList.addAll(modalList);
        modalList.clear();
        WrapperClass modObjClone = new WrapperClass();
        List<WrapperClass> beforeList = new List<WrapperClass>();
        List<WrapperClass> afterList = new List<WrapperClass>();
        
        for(WrapperClass modObj : finalList){
            if(modObj.policyQuoteObj.Sequence__c <= squenceNum){
                beforeList.add(modObj);
                if(modObj.policyQuoteObj.id == policyId){
                    //modObjClone = modObj;
                    modObjClone.isFinal = false;
                    modObjClone.isAdjRO = modObj.isAdjRO;
                    modObjClone.is10X10= modObj.is10X10;
                    modObjClone.is5X5= modObj.is5X5;
                    modObjClone.printQuote = true;
                    modObjClone.finalPremium = modObj.finalPremium;
                    modObjClone.policyQuoteObj = modObj.policyQuoteObj.clone(false,false);
                }
            }else{
                afterList.add(modObj);
            }
        }
        
        Policy_Quote__c quote = modObjClone.policyQuoteObj;
        quote.Sequence__c = squenceNum+1;
        quote.Final_Quote__c = false;
        /*quote.Quote_Expire_Date__c = Date.Today().adddays(30);
        if(quote.Quote_Expire_Date__c > policy.Effective_Date__c){
            quote.Quote_Expire_Date__c = policy.Effective_Date__c;
        }*/
        quote.Quote_Expire_Date__c = policy.Effective_Date__c;
        insert quote;
        
        modalList.addAll(beforeList);
        modalList.add(modObjClone);
        modalList.addAll(afterList);

    }
    
    public void updatePolicyQuote(){
        List<Policy_Quote__c> updateList = new List<Policy_Quote__c>();
        for(WrapperClass modObj : modalList){
            updateList.add(modObj.policyQuoteObj);
        }
        update updateList;
    }
}