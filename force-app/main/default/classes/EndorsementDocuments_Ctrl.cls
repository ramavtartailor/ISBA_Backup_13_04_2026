public class EndorsementDocuments_Ctrl {
    public String recordId;
    public String endorsementVersion{get;set;}
    public Policy_Endorsement__c endorsement{get;set;}
    public List<JsonPolicyLawyerWrapper> policyLawyers{get;set;}
    public List<Policy_Endorsement_Term__c> termList{get;set;}
    public Policy_Quote__c quote{get;set;}
    public boolean hasOneNonFinalQuote{get;set;}
    public void setrecordId(String recordId){
        Id recId = recordId;
        if(recId.getsobjecttype()+''=='Policy_Endorsement__c'){
            if(endorsement==null){
                endorsement =[select id,Account_Name__c,Term_Start_Date__c,Term_End_Date__c,name,Attorney_Name__c,ENTITY_NAME__C,Premium__c,POLICY_FIRM__c,ENTER_MANUSCRIPT_LANGUAGE__c,AOP__c,BROKER__c,TO_DATE__c,FROM_DATE__c,PERSON_ATTORNEY__c,Name2__c,
                              TERRITORY__C,MATTER__C,FIRM_NAME__C,ENDORSEMENT_EFFECTIVE_DATE__c,REFUND_AMOUNT__C,LAWYER_NAME__C,ATTORNEY_FIRM_NAME__c,PER_LAWER__c,PER_POLICY__c,
                              ERE_MONTHS__c,Policy_Lawyer__r.Prior_Act_Date__c,PRIOR_ACT_DATE__C,ACCOUNT_BILLING_STREET__c,ACCOUNT_BILLING_City__c,ACCOUNT_BILLING_State__c,ACCOUNT_BILLING_PostalCode__c,
                              ENTITY__c,ATTORNEY__c,FIRM_ENTITY__c,TERM__c,SECOND_EFFECTIVE_DATE__c,FIRST_PER_CLAIM__C,FIRST_AGGREGATE__C,SECOND_PER_CLAIM__C,SECOND_AGGREGATE__C,THIRD_PER_CLAIM__C,
                              THIRD_AGGREGATE__C,THIRD_EFFECTIVE_DATE__c,TITLE_INSURANCE_AGENCY__C,ADDITIONAL_PREMIUM__C,Manuscript__c,Endorsement_Number__c,Policy__c,Name_Of_Insured__c,Prior_Act_Date_Text__c,Policy__r.Total_Quotes__c,
                              Old_Per_Claim__c,Old_Aggregate__c,New_Per_Claim__c,New_Aggregate__c,New_Limits__r.Coverage_Max_Per_Claim__c,New_Limits__r.Full_Coverage__c,Policy__r.Aggregate_Limit_For_All_Claims__c,Policy__r.Per_Claim_Deductible_Amount__c,Policy_Lawyer_Json__c,Policy__r.Total_Final_Quotes__c
                              from Policy_Endorsement__c where id=: recId];
                if(endorsement.Manuscript__c !=null ){
                    endorsement.Manuscript__c = endorsement.Manuscript__c.replace('<br>','%br%');
                    endorsement.Manuscript__c = endorsement.Manuscript__c.replaceAll('<[/a-zAZ0-9]*>','');
                    endorsement.Manuscript__c = endorsement.Manuscript__c.replace('%br%','<br>');
                }
                if(endorsement.Endorsement_Number__c=='IL 102' && endorsement.Policy_Lawyer_Json__c!=null){
                    if(policyLawyers==null){
                        policyLawyers = (List<JsonPolicyLawyerWrapper>)JSON.deserialize(endorsement.Policy_Lawyer_Json__c, List<JsonPolicyLawyerWrapper>.class);
                    }
                }else if((endorsement.Endorsement_Number__c=='IL 230' || endorsement.Endorsement_Number__c=='IL 232') && endorsement.Policy__r.Total_Final_Quotes__c == 0 && endorsement.Policy__r.Total_Quotes__c == 1){
                    quote = [select id,Full_Coverage__c,Deductible__r.Deductible_Amount__c from Policy_Quote__c where Policy__c =: endorsement.Policy__c];
                    hasOneNonFinalQuote = true;
                }
                termList = new List<Policy_Endorsement_Term__c>([select id,Attorney__c,Endorsement__c,Firm_Entity__c,Term_End_Date__c,Term_Start_Date__c from Policy_Endorsement_Term__c where Endorsement__c=: recId]);
            }
        }else if(recId.getsobjecttype()+''=='Policy__c'){
            if(policyLawyers==null){
                /*List<Policy_Endorsement__c> endorsements = [select id,Policy_Lawyer_Json__c from  Policy_Endorsement__c where Policy__c =:recId and Endorsement_Number__c = 'IL 102' limit 1];
                if(endorsements!=null && endorsements.size()>0 && endorsements[0].Policy_Lawyer_Json__c!=null){
                    policyLawyers = (List<JsonPolicyLawyerWrapper>)JSON.deserialize(endorsements[0].Policy_Lawyer_Json__c, List<JsonPolicyLawyerWrapper>.class);
                }*/
                Policy__c pol = [select id,Total_Final_Quotes__c,Total_Quotes__c from Policy__c where id=: recId];
                System.debug('pol'+pol);
                if((pol.Total_Final_Quotes__c == 0 || pol.Total_Final_Quotes__c == 1) && pol.Total_Quotes__c == 1){
                    quote = [select id,Full_Coverage__c,Deductible__r.Deductible_Amount__c from Policy_Quote__c where Policy__c =: recId];
                    hasOneNonFinalQuote = true;
                }else{
                    List<Policy_Quote__c> quotes = new List<Policy_Quote__c>([select id,Full_Coverage__c,Deductible__r.Deductible_Amount__c from Policy_Quote__c where Policy__c =: recId and Final_Quote__c = true]);
                    if(quotes.size() > 1){
                        quote = [select id,Full_Coverage__c,Deductible__r.Deductible_Amount__c from Policy_Quote__c where Id =: quotes[0].Id];
                        hasOneNonFinalQuote = true;
                    }
                }
                policyLawyers = new List<JsonPolicyLawyerWrapper>();
                for(Policy_Lawyer__c lawyer : [select id,Lawyer_Name__c,Prior_Act_Date__c,ARDC_Number__c  from Policy_Lawyer__c where Policy__c =: recId order by Lawyer__r.Contact__r.LastName]){
                    JsonPolicyLawyerWrapper wrapper = new JsonPolicyLawyerWrapper();
                    wrapper.lawyername = lawyer.Lawyer_Name__c;
                    wrapper.priorActsDate = lawyer.Prior_Act_Date__c ;
                    wrapper.ardcNumber = lawyer.ARDC_Number__c;
                    policyLawyers.add(wrapper);
                }
            }
        }
    }
    public String getrecordId(){
        return recordId;
    }
}