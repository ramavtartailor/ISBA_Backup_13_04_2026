public with sharing class ProcessRegularRenewalCmpCtrl {
    public String recordId {get;set;}
    public list<Wrapper> wrapperList {get; set;}
    public Wrapper wrapper { get { return wrapperList.isEmpty() ? null : wrapperList[0]; } }

    
    public ProcessRegularRenewalCmpCtrl(ApexPages.StandardController stdController) {
        wrapperList = new List<Wrapper>();
        recordId = '';
        String recId = ApexPages.currentPage().getParameters().get('id');
        if (String.isNotBlank(recId)) {
            recordId = recId;
            wrapperList.add(getDetails(recId));
        }
        
        ApexPages.currentPage().getHeaders().put('Content-Type', 'application/pdf');
        ApexPages.currentPage().getHeaders().put('Content-Disposition', 'inline; filename="ISBA_MUTUAL_' + wrapperList[0].onlineNBA.Name + '.pdf"');
    }
    
    @AuraEnabled
    public static Wrapper getDetails(String recId){
        
        Id recordId = recId;
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        if(sObjName == 'Policy__c'){
            Policy__c pol = [SELECT Id,Customer_Application__c FROM Policy__c WHERE Id =: recordId];
            if(String.isNotBlank(pol.Customer_Application__c)){
                recId = pol.Customer_Application__c;
            }
        }
        
        Wrapper wrap = new Wrapper();
        Customer_Application__c nba = [SELECT Id,Name, Address_2__c,Prior_Insurance_Expiration_Date__c,Insurance_Carrier__c,NBA_App_Source__c,Limits_of_Liability__c, Deductible__c, Annual_Premium__c, of_Insured_Lawyers__c,Retroactive_Date__c, Is_the_firm_currently_insured__c,RecordType.Name, Effective_Date_Requested__c, Prior_Insurance_Effective_Date__c, Full_Legal_Name_of_the_Firm__c, Trade_Name_or_D_B_A__c, Street__c, City__c, State__c, Zip_Code__c, County__r.Name, Firm_Phone_Number__c, Website__c, Date_Firm_Established__c, Contact_Name__c, Contact_Last_Name__c, Contact_Phone_Number__c, Contact_E_mail_Address__c, PolicyId__c,  
                                       Q_Outside_IL__c,Q_Conflict_of_Interest__c,Q_Calendaring__c,Q_Engagement_Letters__c,Q_Non_enganement_Letters__c,Q_AOP_1__c,Q_AOP_2__c,Q_AOP_3__c,Signed_Date__c,Signed_By__c,Title__c,Lawyer_Information_Completed__c,Form_Link__c,NBA_App_Source_Info__c,
                                       Q_Firm_Gross_Revenue_Next_Year__c,Q_Firm_Gross_Revenue_Past_Year__c,Q_Firm_Share_Cases__c,Q_Firm_Conflict_Of_Interest_System__c,Q_Lawyer_Backup_Name__c,Q_Lawyer_Backup_Firm__c,Q_Lawyer_Backup_Phone__c,Q_Lawyer_Backup_Carrier__c,Q_Non_Lawyer_Personnel__c,
                                       Q_Outside_IL_Description__c,Q_Firm_Share_Cases_Insured__c,Q_Firm_Notify_Clients_Terminated__c,Q_Firm_Use_Agreements_Or_Engagement_Lett__c,Q_Firm_Review_Conflicts__c,Q_Firm_Evaluate_New_Clients__c,
                                       Q_Docket_Calendar_System__c,Q_Docket_Calendar_System_computer__c,Q_Docket_Calendar_System_dual_calendar__c,Q_Docket_Calendar_System_Other__c,Q_Docket_Calendar_System_practice_manage__c,Q_Docket_Calendar_System_tickler__c,Q_Firm_Maintain_a_Docket__c,Does_the_Firm_have_a_backup_Lawyer__c,
                                       Q_Conflict_Of_Interest_System__c,Q_Conflict_Of_Interest_System_computer__c,Q_Conflict_Of_Interest_System_conflict__c,Q_Conflict_Of_Interest_System_multiple__c,Q_Conflict_Of_Interest_System_practice_m__c,Q_Conflict_Of_Interest_System_single_ind__c,Q_Conflict_Of_Interest_System_supervisor__c
                                       ,Professional_Claim_Number_Against_Firm__c,Professional_Liability_Claim__c,Any_Disciplinary_Action__c,Any_Other_Action__c,Pending_Investigation_Proceeding__c,Inquire_About_Higher_Limits_Deductibles__c,
                                       Refused_Admittance_to_Bar_or_Court__c,Disbarred__c,Suspended__c,Censured__c, Reprimanded__c, Sanctioned_or_Fined__c,Potential_Claim_Number__c,Any_Potential_Claim__c
                                       ,(SELECT Id, Name, Middle_Initial__c, Last_Name__c, ISBA_Number__c, ARDC_Number__c, Cell_Phone__c, Birthday__c, Firm_Email_Address__c, Personal_Email_Address__c, Customer_Application__c FROM Customer_Application_Lawyers__r WHERE Is_Removed__c = false ORDER By Last_Name__c ASC) 
                                       ,(SELECT Id, Quote_Expire_Date__c, Deductible__r.Name, Coverage__r.Name, Final_Quote__c FROM Quotes__r)
                                       ,(SELECT Id,Percentage__c,AOP_Factor__r.Name FROM Customer_Application_AOP__r)
                                       FROM Customer_Application__c WHERE Id =: recId];
        
        
        if(String.isNotBlank(nba.Address_2__c)){
            nba.Street__c += ' '+ nba.Address_2__c;
        }

        List<Policy__c> pol = new List<Policy__c>([SELECT Id, Customer_Application__c, Effective_Date__c, Account__r.Name, Account__r.Trade_Name_or_D_B_A__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.Billing_Address_County__r.Name, Account__r.Phone, Account__r.Website__c, Account__r.Establish_Date__c, Firm_Contact__r.FirstName, Firm_Contact__r.LastName, Firm_Contact__r.Phone, Firm_Contact__r.Email,
                         (SELECT First_Name_Contact__c, Middle_Name_Contact__c, Last_Name_Contact__c, ISBA_Number__c , ARDC_Number__c, Lawyer__r.Contact__r.MobilePhone, Lawyer__r.Contact__r.Birthdate, Contact_Email__c, Lawyer__r.Contact__r.Personal_Email__c FROM Policy_Lawyers__r ORDER By Last_Name_Contact__c ASC),//lawyer
                         (SELECT Id, Quote_Expire_Date__c, Deductible__r.Name, Coverage__r.Name, Final_Quote__c FROM Policy_Quotes__r)//quotes
                         FROM Policy__c WHERE Id =: nba.PolicyId__c]);
        
        if(pol.isEmpty()){
            wrap.policy = null;
        }
        else{
            String street = '';
            if(String.isNotBlank(pol[0].Account__r.BillingStreet)){
                street = pol[0].Account__r.BillingStreet;
                street = street.replaceAll('\n', ' ');
                street = street.replaceAll('\r', ' ');
                pol[0].Account__r.BillingStreet = street;
            }
            wrap.policy = pol[0];
        }
        Map<String, Customer_Application_Lawyer__c> ardcNumWithNBALawyerMap = new Map<String,Customer_Application_Lawyer__c>();
        
        for(Customer_Application_Lawyer__c law : nba.Customer_Application_Lawyers__r){
            if(String.isNotBlank(law.ARDC_Number__c)){
                ardcNumWithNBALawyerMap.put(law.ARDC_Number__c, law);
            }
        }
        List<aopWrapper> aopList = new List<aopWrapper>();
        Integer i = 0;
        Decimal total = 0;
        While(i<= nba.Customer_Application_AOP__r.Size()){
            aopWrapper aop = new aopWrapper();
            if(i == nba.Customer_Application_AOP__r.Size()){
                aop.aop1 = 'Total';
                aop.aop1Per = total;
                aopList.add(aop);
                i++;
            }
            else{
                aop.aop1 = nba.Customer_Application_AOP__r[i].AOP_Factor__r.Name;
                aop.aop1Per = nba.Customer_Application_AOP__r[i].Percentage__c;
                total += nba.Customer_Application_AOP__r[i].Percentage__c;
                i++;
                aopList.add(aop);
            }
        }
        
        List<List<columnWrap>> rowList = new List<List<columnWrap>>();
        if(!pol.isEmpty()){
            for(Policy_Lawyer__c law: pol[0].Policy_Lawyers__r){
                List<columnWrap> row = new List<columnWrap>();
                
                if(ardcNumWithNBALawyerMap.containsKey(law.ARDC_Number__c)){ 
                    Customer_Application_Lawyer__c cappLaw = ardcNumWithNBALawyerMap.get(law.ARDC_Number__c);
                    row.add(new columnWrap(law.First_Name_Contact__c, (cappLaw.Name != law.First_Name_Contact__c), false)); 
                    row.add(new columnWrap(law.Middle_Name_Contact__c, (cappLaw.Middle_Initial__c != law.Middle_Name_Contact__c), false));
                    row.add(new columnWrap(law.Last_Name_Contact__c, (cappLaw.Last_Name__c != law.Last_Name_Contact__c), false));
                    row.add(new columnWrap(law.ISBA_Number__c, (cappLaw.ISBA_Number__c != law.ISBA_Number__c), false));
                    row.add(new columnWrap(law.ARDC_Number__c, (cappLaw.ARDC_Number__c != law.ARDC_Number__c), false));
                    row.add(new columnWrap(law.Lawyer__r.Contact__r.MobilePhone, (cappLaw.Cell_Phone__c != law.Lawyer__r.Contact__r.MobilePhone), false));
                    if(law.Lawyer__r.Contact__r.Birthdate != null){
                        row.add(new columnWrap((String.valueOf(law.Lawyer__r.Contact__r.Birthdate.month()).leftPad(2, '0') +'/'+ String.valueOf(law.Lawyer__r.Contact__r.Birthdate.day()).leftPad(2, '0')+'/'+law.Lawyer__r.Contact__r.Birthdate.year()), (cappLaw.Birthday__c != law.Lawyer__r.Contact__r.Birthdate), false));
                    }
                    else{
                        row.add(new columnWrap(law.Lawyer__r.Contact__r.Birthdate, (cappLaw.Birthday__c != law.Lawyer__r.Contact__r.Birthdate), false));
                    }
                    row.add(new columnWrap(law.Contact_Email__c, (cappLaw.Firm_Email_Address__c != law.Contact_Email__c), false));
                    row.add(new columnWrap(law.Lawyer__r.Contact__r.Personal_Email__c, (cappLaw.Personal_Email_Address__c != law.Lawyer__r.Contact__r.Personal_Email__c), false));
                }
                else{
                    row.add(new columnWrap(law.First_Name_Contact__c, false, true)); 
                    row.add(new columnWrap(law.Middle_Name_Contact__c, false, true));
                    row.add(new columnWrap(law.Last_Name_Contact__c, false, true));
                    row.add(new columnWrap(law.ISBA_Number__c, false, true));
                    row.add(new columnWrap(law.ARDC_Number__c, false, true));
                    row.add(new columnWrap(law.Lawyer__r.Contact__r.MobilePhone, false, true));
                    if(law.Lawyer__r.Contact__r.Birthdate != null){
                        row.add(new columnWrap((String.valueOf(law.Lawyer__r.Contact__r.Birthdate.month()).leftPad(2, '0') +'/'+ String.valueOf(law.Lawyer__r.Contact__r.Birthdate.day()).leftPad(2, '0')+'/'+law.Lawyer__r.Contact__r.Birthdate.year()), false, true));
                    }
                    else{
                        row.add(new columnWrap(law.Lawyer__r.Contact__r.Birthdate, false, true));
                    }
                    row.add(new columnWrap(law.Contact_Email__c, false, true));
                    row.add(new columnWrap(law.Lawyer__r.Contact__r.Personal_Email__c, false, true));
                }
                rowList.add(row);
            }
        }
        wrap.onlineNBA = nba;
        wrap.policyLawyers = rowList;
        wrap.aopList = aopList;
        return wrap;
    }
    
    public Class Wrapper{
        @AuraEnabled public Policy__c policy{get;set;}
        @AuraEnabled public Customer_Application__c onlineNBA {get;set;}
        //@AuraEnabled public List<List<columnWrap>> onlineNBALawyers {get;set;}
        @AuraEnabled public List<List<columnWrap>> policyLawyers {get;set;}
        @AuraEnabled public List<aopWrapper> aopList{get;set;}
    }
    public Class aopWrapper{
        @AuraEnabled public String aop1{get;set;}
        @AuraEnabled public Decimal aop1Per {get;set;}
    }
    public Class columnWrap{
        @AuraEnabled public object val{get;set;}
        @AuraEnabled public Boolean isChanged {get;set;}
        @AuraEnabled public Boolean isRemoved {get;set;} 
        public columnWrap(Object val, Boolean isChanged, Boolean isRemoved){
            this.val = null;
            if(String.isNotBlank(String.valueOf(val))){
                this.val = val;
            }            
            this.isChanged = isChanged;
            this.isRemoved = isRemoved;
        }
    }

}