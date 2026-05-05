global class AddingAnAttorney_Ctrl {
    public Policy__c application_policy {get;set;}
    public String firstName{get;set;}
    public String lastName{get;set;}
    public String ardcNumber{get;set;}
    public String fieldLabel{get;set;}
    public String fieldValue{get;set;}
    public String valueType{get;set;}
    public List<Contact> searchedContacts{get;set;}
    public String selectedContacts{get;set;}
    public Contact cont{get;set;}
    public Contact contactRecord {get;set;}
    public Contact lawyerRecord {get;set;}
    public String error{get;set;}
    public Policy_Endorsement__c policyEndorsement{get;set;}
    public String returnURL{get;set;}
    public String fromPage{get;set;}
    
    public boolean enableEditLawyer{get;set;}
    public boolean canRemoved{get;set;}
    public Integer manageIndex{get;set;}
    
    public List<SelectOption> getStepOverrideValues(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1', '1'));
        options.add(new SelectOption('2', '2'));
        options.add(new SelectOption('3', '3'));
        options.add(new SelectOption('4', '4'));
        options.add(new SelectOption('5', '5'));
        options.add(new SelectOption('6', '6'));
        options.add(new SelectOption('7', '7'));
        return options;
    }
    
    public void updateContValue(){
        system.debug('Cont => '+fieldValue);
        if(String.isNotBlank(fieldValue)){
            cont = [select Id, Name,ARDC_Number__c,Suffix__c,Middle_Name__c,FirstName,LastName, ISBA__c, Phone, MobilePhone, Email, Personal_Email__c, Birthdate, Bar_entry_date__c, Contact_Role__c, Prior_Acts_Date__c, Type__c from Contact where id =: cont.Id limit 1];
            contactRecord = new Contact();
            contactRecord.Id = cont.Id;
            contactRecord.Type__c ='Lawyer';
            contactRecord.FirstName = cont.FirstName;
            contactRecord.Middle_Name__c = cont.Middle_Name__c;
            contactRecord.LastName = cont.LastName;
            contactRecord.ISBA__c = cont.ISBA__c;
            contactRecord.ARDC_Number__c = cont.ARDC_Number__c;
            contactRecord.Phone = cont.Phone;
            contactRecord.MobilePhone = cont.MobilePhone;
            contactRecord.Email = cont.Email;
            contactRecord.Personal_Email__c = cont.Personal_Email__c;
            contactRecord.Birthdate = cont.Birthdate;
            contactRecord.Bar_entry_date__c = cont.Bar_entry_date__c;
            contactRecord.Contact_Role__c = cont.Contact_Role__c;
            contactRecord.Prior_Acts_Date__c = cont.Prior_Acts_Date__c;
            enableEditLawyer = true;
        }
        else{
            cont.Id = null;
            enableEditLawyer = false;
            if(policyEndorsement.Event_Status__c == 'Submitted'){
                contactRecord.Type__c ='Lawyer';
                contactRecord.FirstName = policyEndorsement.IL_152_First_Name__c;
                contactRecord.Middle_Name__c = policyEndorsement.IL_152_Middle_Name__c;
                contactRecord.LastName = policyEndorsement.IL_152_Last_Name__c;
                contactRecord.ISBA__c = policyEndorsement.IL_152_ISBA__c;
                contactRecord.ARDC_Number__c = policyEndorsement.IL_152_ARDC__c;
                contactRecord.Phone = policyEndorsement.IL_152_Phone__c;
                contactRecord.MobilePhone = policyEndorsement.IL_152_Cell_Phone__c;
                contactRecord.Email = policyEndorsement.IL_152_Business_Email__c;
                contactRecord.Personal_Email__c = policyEndorsement.IL_152_Personal_Email__c;
                contactRecord.Birthdate = policyEndorsement.IL_152_Birthdate__c;
                contactRecord.Bar_entry_date__c = policyEndorsement.IL_152_Bar_Entry_Date__c;
                contactRecord.Contact_Role__c = policyEndorsement.IL_152_Contact_Role__c;
                contactRecord.Prior_Acts_Date__c = policyEndorsement.IL_152_Prior_Act_Date__c;
            }
            else{
                contactRecord = new Contact();
                contactRecord.Type__c ='Lawyer';
            }
        }
        system.debug('enableEditLawyer => '+enableEditLawyer );
    }
    
    public AddingAnAttorney_Ctrl(ApexPages.StandardController stdController) {
        enableEditLawyer = false;
        contactRecord = new Contact();
        contactRecord.Type__c ='Lawyer';
        system.debug('contactRecord => '+contactRecord);
        cont = new Contact();
        error ='';
        
        this.policyEndorsement = (Policy_Endorsement__c)stdController.getRecord();
        Policy_Endorsement__c tempEndorsement = new Policy_Endorsement__c();
        if(policyEndorsement.Id != null){
            tempEndorsement = [SELECT id,Lawyer__c, Lawyer__r.Contact__c,Lawyer__r.Contact__r.FirstName, Lawyer__r.Contact__r.Middle_Name__c, Lawyer__r.Contact__r.LastName, Lawyer__r.Contact__r.ISBA__c, Lawyer__r.Contact__r.ARDC_Number__c, Lawyer__r.Contact__r.Phone, Lawyer__r.Contact__r.MobilePhone, Lawyer__r.Contact__r.Email, Lawyer__r.Contact__r.Personal_Email__c, Lawyer__r.Contact__r.Birthdate, Lawyer__r.Contact__r.Bar_entry_date__c, Lawyer__r.Contact__r.Contact_Role__c, Lawyer__r.Contact__r.Prior_Acts_Date__c FROM  Policy_Endorsement__c WHERE Id=:policyEndorsement.Id LIMIT 1];
            policyEndorsement.Lawyer__c = tempEndorsement.Lawyer__c;
        }
        system.debug('policyEndorsement => '+policyEndorsement);
        if(policyEndorsement.Event_Status__c == 'Submitted' && policyEndorsement.Lawyer__c == null){
            contactRecord.Type__c ='Lawyer';
            contactRecord.FirstName = policyEndorsement.IL_152_First_Name__c;
            contactRecord.Middle_Name__c = policyEndorsement.IL_152_Middle_Name__c;
            contactRecord.LastName = policyEndorsement.IL_152_Last_Name__c;
            contactRecord.ISBA__c = policyEndorsement.IL_152_ISBA__c;
            contactRecord.ARDC_Number__c = policyEndorsement.IL_152_ARDC__c;
            contactRecord.Phone = policyEndorsement.IL_152_Phone__c;
            contactRecord.MobilePhone = policyEndorsement.IL_152_Cell_Phone__c;
            contactRecord.Email = policyEndorsement.IL_152_Business_Email__c;
            contactRecord.Personal_Email__c = policyEndorsement.IL_152_Personal_Email__c;
            contactRecord.Birthdate = policyEndorsement.IL_152_Birthdate__c;
            contactRecord.Bar_entry_date__c = policyEndorsement.IL_152_Bar_Entry_Date__c;
            contactRecord.Contact_Role__c = policyEndorsement.IL_152_Contact_Role__c;
            contactRecord.Prior_Acts_Date__c = policyEndorsement.IL_152_Prior_Act_Date__c;
            system.debug('contactRecord => '+contactRecord);
        }else if(policyEndorsement.Lawyer__c != null){
            enableEditLawyer = true;
            contactRecord.Type__c ='Lawyer';
            contactRecord.Id = tempEndorsement.Lawyer__r.Contact__c;
            contactRecord.FirstName = tempEndorsement.Lawyer__r.Contact__r.FirstName;
            contactRecord.Middle_Name__c = tempEndorsement.Lawyer__r.Contact__r.Middle_Name__c;
            contactRecord.LastName = tempEndorsement.Lawyer__r.Contact__r.LastName;
            contactRecord.ISBA__c = tempEndorsement.Lawyer__r.Contact__r.ISBA__c;
            contactRecord.ARDC_Number__c = tempEndorsement.Lawyer__r.Contact__r.ARDC_Number__c;
            contactRecord.Phone = tempEndorsement.Lawyer__r.Contact__r.Phone;
            contactRecord.MobilePhone = tempEndorsement.Lawyer__r.Contact__r.MobilePhone;
            contactRecord.Email = tempEndorsement.Lawyer__r.Contact__r.Email;
            contactRecord.Personal_Email__c = tempEndorsement.Lawyer__r.Contact__r.Personal_Email__c;
            contactRecord.Birthdate = tempEndorsement.Lawyer__r.Contact__r.Birthdate;
            contactRecord.Bar_entry_date__c = tempEndorsement.Lawyer__r.Contact__r.Bar_entry_date__c;
            contactRecord.Contact_Role__c = tempEndorsement.Lawyer__r.Contact__r.Contact_Role__c;
            contactRecord.Prior_Acts_Date__c = tempEndorsement.Lawyer__r.Contact__r.Prior_Acts_Date__c;
        }
        /*else if(policyEndorsement.Event_Status__c == 'Submitted' && policyEndorsement.Lawyer__c != null){
            AccountContactJunction__c lawyer = [SELECT Id, Contact__r.FirstName, Contact__r.Middle_Name__c, Contact__r.LastName, Contact__r.ISBA__c, Contact__r.ARDC_Number__c, Contact__r.Phone, Contact__r.Cell_Phone__c, Contact__r.Email, Contact__r.Personal_Email__c, Contact__r.Birthdate, Contact__r.Bar_entry_date__c, Contact__r.Contact_Role__c, Contact__r.Prior_Acts_Date__c, Contact__r.Type__c FROM AccountContactJunction__c WHERE Id=:policyEndorsement.Lawyer__c limit 1];
			lawyerRecord = (contact)lawyer.getsobject('Contact__r');
        }*/

        Policy__c pol;
        
        fromPage = ApexPages.currentPage().getParameters().get('fromPage');
        if(ApexPages.currentPage().getParameters().get('manageIndex') != null){
            manageIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('manageIndex'));
        }
        if(fromPage == 'ManageEndorsements'){
            canRemoved = true;
        }
        if(ApexPages.currentPage().getParameters().get('policyId')!=null){
            policyEndorsement.Policy__c = ApexPages.currentPage().getParameters().get('policyId');
            returnURL = '/'+policyEndorsement.Policy__c;
            pol = [select id,Account__c,Name,Expiration_Date__c,Effective_Date__c from Policy__C where id = : policyEndorsement.Policy__c];
            policyEndorsement.Account__r = [select id,name from Account where id = : pol.Account__c];
            policyEndorsement.Policy__r = pol;
            policyEndorsement.Account__c = pol.Account__c;
        }
        if(ApexPages.currentPage().getParameters().get('name')!=null){
            policyEndorsement.name =ApexPages.currentPage().getParameters().get('name');
        }
        if(ApexPages.currentPage().getParameters().get('effectiveDate')!=null){
            policyEndorsement.Prior_Act_Date__c =date.parse(ApexPages.currentPage().getParameters().get('effectiveDate'));
        }
        System.debug('iddd-==>'+ ApexPages.currentPage().getParameters().get('id'));
        if(ApexPages.currentPage().getParameters().get('id')!=null){
            returnURL = '/'+ApexPages.currentPage().getParameters().get('id');
            Policy_Endorsement__C polEnd = [select Lawyer__c,Event_Status__c from Policy_Endorsement__C where id=:ApexPages.currentPage().getParameters().get('id')];
            if(polEnd.Event_Status__c == 'Complete'){
                canRemoved = false;
            }
            System.debug('polEnd'+ polEnd.Lawyer__C);
            //List<AccountContactJunction__c> jun = [select contact__C from AccountContactJunction__c where id=:polEnd.Lawyer__c]; 
            
            List<Contact> conList = New List<Contact>([select id,name,ARDC_Number__c,ISBA__c,FirstName,Middle_Name__c,LastName,Email,Suffix__c,Birthdate,Phone,MobilePhone,Personal_Email__c,Bar_entry_date__c,Prior_Acts_Date__c,Contact_Role__c,Type__c  from Contact where id in (select contact__C from AccountContactJunction__c where id=:polEnd.Lawyer__c)]);
            
            if(!conList.isEmpty()){
                cont =conList[0];
            } 
            
        }
        if(ApexPages.currentPage().getParameters().get('RecordType')!=null){
            policyEndorsement.RecordTypeId =  ApexPages.currentPage().getParameters().get('RecordType');
        }
        if(ApexPages.currentPage().getParameters().get('fromPolicyLawyerRelatedList')!=null){
            Endorsement__c endorsement = [SELECT Description__c, Endorsement_Record_Type_ID__c, Endorsement_Sub_Type__c, Id, Name, Type__c FROM Endorsement__c WHERE Active__c = true AND Endorsement_Sub_Type__c='IL 152' limit 1];
            policyEndorsement.RecordTypeId = endorsement.Endorsement_Record_Type_ID__c;
            policyEndorsement.name = [SELECT Id, Name FROM RecordType WHERE Id =: endorsement.Endorsement_Record_Type_ID__c LIMIT 1].Name;
            
            if (pol.Effective_Date__c != null) {
                policyEndorsement.Prior_Act_Date__c  = pol.Effective_Date__c;
            } else {
                policyEndorsement.Prior_Act_Date__c = System.today();
            }
        }
        if(policyEndorsement.Rate_At__c == null){
            policyEndorsement.Rate_At__c = 100;
        }
    }
    
    Public void updateLawyerValue(){
        Object val = fieldValue;
        if(valueType =='Integer'){
            val = Integer.valueOf(fieldValue);
        } 
        else if(valueType=='Date'){ 
            val = Date.valueOf(fieldValue);
        } 

        cont.put(fieldLabel,val);
    } 
    public void createContact(){
        try{
            error ='';
            contactRecord.AccountId = [select id from account where name =: Label.Bucket_Account limit 1].id;
            system.debug(' query :: ' + [select id from account where name =: Label.Bucket_Account limit 1]);
            Upsert contactRecord;
            system.debug('contactRecord:: ' + contactRecord);
            cont = [select id,name,ARDC_Number__c,ISBA__c,FirstName,Middle_Name__c,LastName,Email,Suffix__c,Birthdate,Phone,MobilePhone,Personal_Email__c,Bar_entry_date__c,Prior_Acts_Date__c,Contact_Role__c,Type__c from Contact where id = : contactRecord.id];
            enableEditLawyer = true;
            //contactRecord = new Contact();
            //contactRecord.Type__c ='Lawyer';
        }catch(DMLException e){
            System.debug('error---90'+e.getMessage() );
            System.debug('error---91'+e.getLineNumber());
            error = e.getdmlMessage(0);
            
        }catch(Exception e){
            System.debug('error---'+e.getMessage());
            System.debug('error---'+e.getLineNumber());
            error = e.getMessage();
            
        }
    }
    public void premiumCalculator(){
        try{
            policyEndorsement.Endorsement_Effective_Date__c = policyEndorsement.Effective_Date__c;
            error='';
            //String masterStepFactorId;
            //String masterLimitFactorId;
            //Step_Rate_Factor__c stepFactors = new Step_Rate_Factor__c();
            //ILF_Coverage_Factor__c lowestLimitFactor = new ILF_Coverage_Factor__c();
            Map<Id,Step_Rate_Factor__c> stepFactors = new Map<Id,Step_Rate_Factor__c>();
            Map<Id,ILF_Coverage_Factor__c> lowestLimitFactor = new Map<Id,ILF_Coverage_Factor__c>();
            //Set<String> setPolicyEndorsementIds = new Set<String>();
            //Set<String> setPolicyIds = new Set<String>();
            set<String> setLimitFactorIds = new Set<String>();
            set<String> setDeductibleFactorIds = new Set<String>();
            Map<String,Policy__c> mapOfPolicies = new Map<String,Policy__c>();
            Map<String,ILF_Coverage_Factor__c> mapOfLimits = new Map<String,ILF_Coverage_Factor__c>();
            Map<String,Deductible_Factor__c> mapOfDeductibles = new Map<String,Deductible_Factor__c>();
            List<Policy_Endorsement__c> lstPolicyEndorsements = new List<Policy_Endorsement__c>();
            List<Policy_Endorsement__c> lstPolicyEndorsementsToUpdate = new List<Policy_Endorsement__c>();
            
            // Get the Master Factor Record Id For Step Rate and Limits where default is true.
            //masterStepFactorId = String.valueOf([SELECT Id, Name, Default__c, Factor_Type__c FROM Master_Factor__c WHERE Default__c = true AND Factor_type__c = 'Step Rate' LIMIT 1].Id);
            //masterLimitFactorId = String.valueOf([SELECT Id, Name, Default__c, Factor_Type__c FROM Master_Factor__c WHERE Default__c = true AND Factor_type__c = 'Coverage' LIMIT 1].Id);
            List<Step_Rate_Factor__c> stepRateFactorsList = new List<Step_Rate_Factor__c>([SELECT Id,From_Date__c,To_Date__c, Factor_Value_Step_Rate_0__c, Factor_Value_Step_Rate_1__c, Factor_Value_Step_Rate_2__c, Factor_Value_Step_Rate_3__c, Factor_Value_Step_Rate_4__c, Factor_Value_Step_Rate_5__c, Factor_Value_Step_Rate_6__c, Factor_Value_Step_Rate_7__c, Master_Factor__c FROM Step_Rate_Factor__c WHERE Master_Factor__r.Factor_type__c = 'Step Rate']);
            // Get the Step Factor To fetch all the Step Rate Factor Values.
            //stepFactors = [SELECT Id, Factor_Value_Step_Rate_0__c, Factor_Value_Step_Rate_1__c, Factor_Value_Step_Rate_2__c, Factor_Value_Step_Rate_3__c, Factor_Value_Step_Rate_4__c, Factor_Value_Step_Rate_5__c, Factor_Value_Step_Rate_6__c, Factor_Value_Step_Rate_7__c, Master_Factor__c FROM Step_Rate_Factor__c WHERE Master_Factor__c =: masterStepFactorId];
            
            // Get the lowest coverage factor and its value for primary calculations.
            //lowestLimitFactor = [SELECT Id, Factor_Value__c, Lowest_Coverage__c, Master_Factor__c FROM ILF_Coverage_Factor__c WHERE Master_Factor__c =: masterLimitFactorId AND Lowest_Coverage__c = true];
            List<ILF_Coverage_Factor__c> lowestLimitFactorList = new List<ILF_Coverage_Factor__c>([SELECT Id,From_Date__c,To_Date__c, Factor_Value__c, Lowest_Coverage__c, Master_Factor__c FROM ILF_Coverage_Factor__c WHERE Master_Factor__r.Factor_type__c = 'Coverage' AND Lowest_Coverage__c = true]);            
            // Get all the Policy Endorsement Ids to SOQL.
            //for (Policy_Endorsement__c policyEndorsement : lstPendingAddLawyer) {
            //setPolicyEndorsementIds.add(policyEndorsement.Id);
            //setPolicyIds.add(policyEndorsement.Policy__c);
            //}
            
            // Get all the Policies related to the endorsements and fill the map.
            for (Policy__c pol : [SELECT Id, Name, Effective_Date__c, Expiration_Date__c, Limit__c, Firm_Mod__c, Deductible_ID__c, Base_Amount__c, Final_Quote_10x10_Value__c,ADJ_MOD__c,X5_5_Override__c,X10x10__c FROM Policy__c WHERE Id = :policyEndorsement.Policy__c]) {
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
            for (ILF_Coverage_Factor__c lim : [SELECT Id, Name, Is_5X5_Coverage__c, Is_10X10_Coverage__c, Percnt_amt_5X5_Step_0__c, Percnt_amt_5X5_Step_1__c, Percnt_amt_5X5_Step_2__c, Percnt_amt_5X5_Step_3__c, Premium_Rate_5X5__c, Factor_Value__c,X4x1_Rate__c FROM ILF_Coverage_Factor__c WHERE Id IN: setLimitFactorIds]) {
                mapOfLimits.put(lim.Id,lim);
            }
            
            // Get all the deductibles applied to policy endorsements and fill the map.
            for (Deductible_Factor__c ded : [SELECT Id, Name, Deductible_Amount__c, Factor_Value__c, Master_Factor__c FROM Deductible_Factor__c WHERE Id IN: setDeductibleFactorIds]) {
                mapOfDeductibles.put(ded.Id,ded);
            }
            
            Decimal stepFactorValue;
            Decimal rate = (policyEndorsement.Rate_At__c == 0 ? 0 : policyEndorsement.Rate_At__c) / 100;
            Decimal amountBeforeDeductible;
            Decimal deductibleFactorAmount;
            
            system.debug('policyEndorsement >> ' + policyEndorsement);
            
            ILF_Coverage_Factor__c limitFactor = mapOfLimits.get(mapOfPolicies.get(policyEndorsement.Policy__c).Limit__c);
            
            Deductible_Factor__c deductibleFactor = mapOfDeductibles.get(mapOfPolicies.get(policyEndorsement.Policy__c).Deductible_ID__c);
            
            policyEndorsement.Step__c = ApplicationPolicyUtil.CalculateLawyerStep(mapOfPolicies.get(policyEndorsement.Policy__c).Effective_Date__c,policyEndorsement.Prior_Act_Date__c);
            
            Date endorsementEffectiveDate = policyEndorsement.Endorsement_Effective_Date__c;
            
            System.debug('mapOfPolicies.get(policyEndorsement.Policy__c).Expiration_Date__c: : ' + mapOfPolicies.get(policyEndorsement.Policy__c).Expiration_Date__c);
            System.debug('endorsementEffectiveDate: : ' + endorsementEffectiveDate);
            
            Decimal daysProRated = policyEndorsement.Endorsement_Effective_Date__c.daysBetween(mapOfPolicies.get(policyEndorsement.Policy__c).Expiration_Date__c) + 1;
            policyEndorsement.Term__c = daysProRated / (Date.isLeapYear(Date.today().year()) ?  366 : 365);
            
            if(policyEndorsement.Term__c > 1){
                policyEndorsement.Term__c = 1;
            }
            
            if (policyEndorsement.Step_Override__c == true) {
                if (policyEndorsement.Step_Override_Value__c == 0) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_0__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 1) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_1__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 2) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_2__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 3) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_3__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 4) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_4__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 5) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_5__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 6) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_6__c:0;
                } else if (policyEndorsement.Step_Override_Value__c == 7) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_7__c:0;
                }
            } else {
                if (policyEndorsement.Step__c == 0) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_0__c:0;
                } else if (policyEndorsement.Step__c == 1) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_1__c:0;
                } else if (policyEndorsement.Step__c == 2) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_2__c:0;
                } else if (policyEndorsement.Step__c == 3) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_3__c:0;
                } else if (policyEndorsement.Step__c == 4) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_4__c:0;
                } else if (policyEndorsement.Step__c == 5) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_5__c:0;
                } else if (policyEndorsement.Step__c == 6) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_6__c:0;
                } else if (policyEndorsement.Step__c == 7) {
                    stepFactorValue = stepFactors.containsKey(policyEndorsement.Policy__c)?stepFactors.get(policyEndorsement.Policy__c).Factor_Value_Step_Rate_7__c:0;
                }
            }
            
            amountBeforeDeductible = (100 * stepFactorValue * mapOfPolicies.get(policyEndorsement.Policy__c).Base_Amount__c * limitFactor.Factor_Value__c * mapOfPolicies.get(policyEndorsement.Policy__c).Firm_Mod__c) / 100;
            amountBeforeDeductible = amountBeforeDeductible.round(System.RoundingMode.HALF_UP);
            
            deductibleFactorAmount = ((stepFactorValue * mapOfPolicies.get(policyEndorsement.Policy__c).Base_Amount__c * (lowestLimitFactor.containsKey(policyEndorsement.Policy__c)?lowestLimitFactor.get(policyEndorsement.Policy__c).Factor_Value__c:0) * mapOfPolicies.get(policyEndorsement.Policy__c).Firm_Mod__c) - (stepFactorValue * mapOfPolicies.get(policyEndorsement.Policy__c).Base_Amount__c * (lowestLimitFactor.containsKey(policyEndorsement.Policy__c)?lowestLimitFactor.get(policyEndorsement.Policy__c).Factor_Value__c:0) * mapOfPolicies.get(policyEndorsement.Policy__c).Firm_Mod__c * deductibleFactor.Factor_Value__c));
            deductibleFactorAmount = (100 * deductibleFactorAmount) / 100;
            deductibleFactorAmount = deductibleFactorAmount.round(System.RoundingMode.HALF_UP);
            deductibleFactorAmount = deductibleFactorAmount * (-1);
            
            
            policyEndorsement.Excess__c =  limitFactor.X4x1_Rate__c != null ? (amountBeforeDeductible/limitFactor.Factor_Value__c)*limitFactor.X4x1_Rate__c : 0;
            
            
            //policyEndorsement.Primary__c = (100 * stepFactorValue * rate * policyEndorsement.Term__c * mapOfPolicies.get(policyEndorsement.Policy__c).Base_Amount__c * limitFactor.Factor_Value__c * deductibleFactor.Factor_Value__c * mapOfPolicies.get(policyEndorsement.Policy__c).Firm_Mod__c) / 100;
            policyEndorsement.Primary__c = (amountBeforeDeductible + deductibleFactorAmount) - policyEndorsement.Excess__c;
            
            policyEndorsement.Excess__c = policyEndorsement.Excess__c * rate * policyEndorsement.Term__c;
            policyEndorsement.Excess__c = policyEndorsement.Excess__c.round(System.RoundingMode.HALF_UP);
                
            policyEndorsement.Primary__c = policyEndorsement.Primary__c * rate * policyEndorsement.Term__c;
            
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
                }else if(mapOfPolicies.get(policyEndorsement.Policy__c).X5_5_Override__c != null && mapOfPolicies.get(policyEndorsement.Policy__c).X5_5_Override__c>0){
                    policyEndorsement.Premium_5_5__c = mapOfPolicies.get(policyEndorsement.Policy__c).X5_5_Override__c * policyEndorsement.Term__c;
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
            
            if(mapOfPolicies.get(policyEndorsement.Policy__c).X10x10__c != null && mapOfPolicies.get(policyEndorsement.Policy__c).X10x10__c>0){
                policyEndorsement.Premium_10_10__c = mapOfPolicies.get(policyEndorsement.Policy__c).X10x10__c * policyEndorsement.Term__c;
            }else{
                policyEndorsement.Premium_10_10__c = 0.0;
            }
            
            // Removing the 10 X 10 from per lawyer calculations, because 10 X 10 is applicable per policy as per discussion with Gibran 03/01/2017.
            //if (limitFactor.Is_10X10_Coverage__c == true) {
            //    policyEndorsement.Premium_10_10__c = mapOfPolicies.get(policyEndorsement.Policy__c).Final_Quote_10x10_Value__c;
            //} else {
            //    policyEndorsement.Premium_10_10__c = 0.0;
            //}
            
            if (policyEndorsement.Override_Rating__c == true) {
                policyEndorsement.Premium__c = policyEndorsement.Primary__c + policyEndorsement.Excess__c + (policyEndorsement.Override_5_5__c == null ? 0 : policyEndorsement.Override_5_5__c) + (policyEndorsement.Override_10_10__c == null ? 0 : policyEndorsement.Override_10_10__c);
            } else {
                policyEndorsement.Premium__c = policyEndorsement.Primary__c + policyEndorsement.Excess__c + (policyEndorsement.Premium_5_5__c == null ? 0 : policyEndorsement.Premium_5_5__c) + (policyEndorsement.Premium_10_10__c == null ? 0 : policyEndorsement.Premium_10_10__c);
            }
            if(mapOfPolicies.get(policyEndorsement.Policy__c).ADJ_MOD__c!=null){
                policyEndorsement.Premium__c = ( policyEndorsement.Premium__c +  (policyEndorsement.Premium__c * (mapOfPolicies.get(policyEndorsement.Policy__c).ADJ_MOD__c-1)));
            }
            policyEndorsement.Premium__c = (100 * policyEndorsement.Premium__c) / 100;
            policyEndorsement.Premium__c = policyEndorsement.Premium__c.round(System.RoundingMode.HALF_UP);
            system.debug('AddingAnAttorney class');
        }catch(DMLException e){
            
            error = e.getdmlMessage(0);
        }catch(Exception e){
            
            System.debug('error--- :: '+e.getMessage());
            System.debug('error--- "" '+e.getLineNumber());
            
            error = e.getMessage();
            System.debug('error---'+error);
            
        }
        
    }
    public void searchContact(){
        policyEndorsement.Lawyer__c = null;
        String query = 'select id,FirstName,LastName,Type__c,Title,Email,Phone,ISBA__c,ARDC_Number__c,Suffix__c,Middle_Name__c from Contact';
        String Filter = '';
        String searchKeywordFirstName,searchKeywordLastName,searchKeywordARDCNumber='';
        if(String.IsNotBlank(firstName)){
            searchKeywordFirstName = '%'+firstName +'%';
            Filter += ' WHERE FirstName LIKE : searchKeywordFirstName ';
        }
        if(String.IsNotBlank(lastName)){
            if(String.IsNotBlank(Filter)){
                searchKeywordLastName = '%'+lastName +'%';
                Filter += ' AND lastName LIKE : searchKeywordLastName ';
            }else{
                searchKeywordLastName = '%' + lastName +'%';
                Filter += ' WHERE lastName LIKE : searchKeywordLastName ';
            }
        }
        
        if(String.IsNotBlank(ardcNumber)){
            if(String.IsNotBlank(Filter)){
                searchKeywordARDCNumber = '%'+ardcNumber +'%';
                Filter += ' AND ARDC_Number__c LIKE : searchKeywordARDCNumber ';
            }else{
                searchKeywordARDCNumber = '%' + ardcNumber +'%';
                Filter += ' WHERE ARDC_Number__c LIKE : searchKeywordARDCNumber ';
            }
        }
        Set<Id> lawyersId  = new Set<Id>();
        
        for(AccountContactJunction__c lawyer : [Select Contact__c from AccountContactJunction__c where id in (select Lawyer__C from Policy_Lawyer__C where Policy__c = :policyEndorsement.Policy__c)]){
            lawyersId.add(lawyer.Contact__c);
        }
        If(String.IsNotBlank(Filter)){
            query = query+''+Filter+'and Id not in :  lawyersId  order by lastname asc,firstname asc LIMIT 1000';
            System.debug(query);
            searchedContacts = database.query(query);
        }
    }
    public PageReference saveEndorsement(){
        Savepoint s = Database.setSavepoint();
        try{
            policyEndorsement.Endorsement_Effective_Date__c = policyEndorsement.Effective_Date__c;
            error='';
            if(!policyEndorsement.Override_Rating__c){
                policyEndorsement.Override_10_10__c = null;
                policyEndorsement.Override_5_5__c = null;
            }
            if(!policyEndorsement.Step_Override__c){
                policyEndorsement.Step_Override_Value__c =null;
            }
            policyEndorsement.Lawyer__c = [select id from AccountContactJunction__c where Contact__c = :cont.Id  limit 1][0].id;
            
            boolean isNew = false;
            if(policyEndorsement.Id == null){
                isNew = true;
            }
            system.debug('AddingAnAttorney called 2');
            upsert policyEndorsement;
            
            User_Tracking__c userTrack;
            if(isNew){
                userTrack = UserTrackingHandler.createUserTrackingObject('Create', policyEndorsement.Id, policyEndorsement.Name);
            }else{
                userTrack = UserTrackingHandler.createUserTrackingObject('Edit', policyEndorsement.Id, policyEndorsement.Name);
            }
            insert userTrack;
            
            List<AccountContactRelation> acr = [select id,contactid,accountid from AccountContactRelation where contactid=:cont.Id and accountid=:policyEndorsement.Account__c];
            if(acr.size()==0){
                acr.add(new AccountContactRelation(contactid=cont.Id,accountid=policyEndorsement.Account__c));
                insert acr;
            }
            
            if(String.isNotBlank(cont.Id)){
                Update cont;
            }
            
            if(fromPage == 'ManageEndorsements'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Confirm,'Sucessfully Saved.'));
                String baseUrl = String.valueOf(System.URL.getOrgDomainUrl().toExternalForm());
                return new PageReference(baseUrl + '/apex/AddingAnAttorney?fromPage=ManageEndorsements&manageIndex='+manageIndex+'&id='+policyEndorsement.Id);
            }else{
                return new PageReference('/'+policyEndorsement.Id);
            }
        }catch(DMLException e){
            Database.rollback(s);
            error = e.getdmlMessage(0);
            return null;
        }catch(Exception e){
            Database.rollback(s);
            error = e.getMessage();
            System.debug('error---'+error);
            System.debug('error---'+e.getLineNumber());
            return null;
        }
    }
    public void associateContacts(){
        cont = [select Id, Name,ARDC_Number__c,Suffix__c,Middle_Name__c,FirstName,LastName, ISBA__c, Phone, MobilePhone, Email, Personal_Email__c, Birthdate, Bar_entry_date__c, Contact_Role__c, Prior_Acts_Date__c, Type__c from Contact where id in : selectedContacts.split(',') limit 1];
        //lawyerRecord = cont;
        System.debug(cont);
        enableEditLawyer = true;
        contactRecord = new Contact();
        contactRecord.Id = cont.Id;
        contactRecord.Type__c ='Lawyer';
        contactRecord.FirstName = cont.FirstName;
        contactRecord.Middle_Name__c = cont.Middle_Name__c;
        contactRecord.LastName = cont.LastName;
        contactRecord.ISBA__c = cont.ISBA__c;
        contactRecord.ARDC_Number__c = cont.ARDC_Number__c;
        contactRecord.Phone = cont.Phone;
        contactRecord.MobilePhone = cont.MobilePhone;
        contactRecord.Email = cont.Email;
        contactRecord.Personal_Email__c = cont.Personal_Email__c;
        contactRecord.Birthdate = cont.Birthdate;
        contactRecord.Bar_entry_date__c = cont.Bar_entry_date__c;
        contactRecord.Contact_Role__c = cont.Contact_Role__c;
        contactRecord.Prior_Acts_Date__c = cont.Prior_Acts_Date__c;
        searchedContacts =new List<Contact>();
        firstName='';
        lastName='';
        ardcNumber='';
    }
    public void cancelMethod(){
        searchedContacts =new List<Contact>();
        //lawyerRecord = null;
        //policyEndorsement.Lawyer__c = null;
        firstName='';
        lastName='';
        ardcNumber='';
    }
    @RemoteAction
    global static List<sObject> getLookupRecord(String likeString , String objectName,String policyId) {
        if(String.IsNotBlank(likeString) && String.IsNotBlank(objectName)){
            likeString = likeString+'%';
            String query = '';
            
            Set<Id> lawyersId  = new Set<Id>();
            
            for(AccountContactJunction__c lawyer : [Select Contact__c from AccountContactJunction__c where id in (select Lawyer__C from Policy_Lawyer__C where Policy__c = : policyId AND Deleted_Date__c = null)]){
                lawyersId.add(lawyer.Contact__c);
            }
            
            query = 'SELECT Id, Name , ARDC_Number__c,Suffix__c,Middle_Name__c,FirstName,LastName FROM '+'Contact'+' WHERE (LastName LIKE : likeString or ARDC_Number__c LIKE : likeString)and Type__c=\'Lawyer\' and Id not in :  lawyersId LIMIT 50';
            return database.query(query);
        }
        return null;
    }
}