public class Declaration_Page_Template_Ctrl {
	public String recordId;
    public policyWrapper policy{get;set;}
    public List<Policy_Endorsement__c> endorsements{get;set;}
    public void setrecordId(String recordId){
        Policy__c policyObj = [select id,name,FIRM_NAME_History__C, FIRM_BILLING_ADDRESS_History__C , POLICY_NUMBER_History__C,EFFECTIVE_DATE_History__C,EXPIRATION_DATE_History__C, PER_CLAIM_LIMIT_History__C,Full_Prior_Acts__c,
                  AGGREGATE_LIMIT_History__C ,PER_CLAIM_DEDUCTIBLE_AMOUNT_History__C,POLICY_RETROACTIVE_DATE_History__c,PREMIUM_History__c,ISSUE_DATE_History__c,Remove_102_Endorsement__c,Date_Signed__c,
                  Firm_Billing_Address__c,Firm_Name__c,EFFECTIVE_DATE__c,EXPIRATION_DATE__c,PER_CLAIM_LIMIT__c,AGGREGATE_LIMIT__c,PER_CLAIM_DEDUCTIBLE_AMOUNT__c,
                  POLICY_RETROACTIVE_DATE__c,PREMIUM__c,ISSUE_DATE__c,recordType.Name from Policy__C where id=: recordId];
        
        policy = new policyWrapper();
        policy.recId = policyObj.recordType.Name != 'Application' ? policyObj.Id : policyObj.Id;
        policy.name = policyObj.recordType.Name != 'Application' ? policyObj.Name : policyObj.Name;
        policy.FIRM_NAME_History = policyObj.recordType.Name != 'Application' ? policyObj.FIRM_NAME_History__c : policyObj.Firm_Name__c;
        policy.FIRM_BILLING_ADDRESS_History = policyObj.recordType.Name != 'Application' ? policyObj.FIRM_BILLING_ADDRESS_History__c : policyObj.Firm_Billing_Address__c;
        policy.POLICY_NUMBER_History = policyObj.recordType.Name != 'Application' ? policyObj.POLICY_NUMBER_History__c : policyObj.Name;
        policy.EFFECTIVE_DATE_History = policyObj.recordType.Name != 'Application' ? policyObj.EFFECTIVE_DATE_History__c : policyObj.EFFECTIVE_DATE__c;
        policy.EXPIRATION_DATE_History = policyObj.recordType.Name != 'Application' ? policyObj.EXPIRATION_DATE_History__c : policyObj.EXPIRATION_DATE__c;
        policy.PER_CLAIM_LIMIT_History = policyObj.recordType.Name != 'Application' ? policyObj.PER_CLAIM_LIMIT_History__c : policyObj.PER_CLAIM_LIMIT__c;
        policy.Full_Prior_Acts = policyObj.recordType.Name != 'Application' ? policyObj.Full_Prior_Acts__c : policyObj.Full_Prior_Acts__c;
        policy.AGGREGATE_LIMIT_History = policyObj.recordType.Name != 'Application' ? policyObj.AGGREGATE_LIMIT_History__c : policyObj.AGGREGATE_LIMIT__c;
        policy.PER_CLAIM_DEDUCTIBLE_AMOUNT_History = policyObj.recordType.Name != 'Application' ? policyObj.PER_CLAIM_DEDUCTIBLE_AMOUNT_History__c : policyObj.PER_CLAIM_DEDUCTIBLE_AMOUNT__c;
        policy.POLICY_RETROACTIVE_DATE_History = policyObj.recordType.Name != 'Application' ? policyObj.POLICY_RETROACTIVE_DATE_History__c : policyObj.POLICY_RETROACTIVE_DATE__c;
        policy.PREMIUM_History = policyObj.recordType.Name != 'Application' ? policyObj.PREMIUM_History__c : policyObj.PREMIUM__c;
        policy.ISSUE_DATE_History = policyObj.recordType.Name != 'Application' ? policyObj.ISSUE_DATE_History__c : policyObj.ISSUE_DATE__c;
        policy.Remove_102_Endorsement = policyObj.recordType.Name != 'Application' ? policyObj.Remove_102_Endorsement__c : policyObj.Remove_102_Endorsement__c;
        policy.Date_Signed = policyObj.recordType.Name != 'Application' ? policyObj.Date_Signed__c : policyObj.Date_Signed__c;
        
        String showIL102 = '';
        if(!policyObj.Remove_102_Endorsement__c){
            showIL102 = 'IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT';
        }
    	endorsements = [select id, ENDORSEMENT_NUMBER__C , ENDORSEMENT_VERSION__c,ENDORSEMENT_NAME__C,Name 
                        	from Policy_Endorsement__C 
                        	where Policy__C =: recordId and 
                        		(Is_Application_Endorsement__c = true 
                                 	OR RecordType.Name =: showIL102 
                                 	OR RecordType.Name='IL 302 AMENDMENT OF EXTENDED REPORTING PERIOD OPTIONS ENDORSEMENT'
                                 	OR RecordType.Name='IL 230 ANNUAL AGGREGATE DEDUCTIBLE ENDORSEMENT'
                                 	OR RecordType.Name='IL 234 LOSS ONLY DEDUCTIBLE ENDORSEMENT'
                                 	OR RecordType.Name='IL 261 Claim Expenses Outside the Policy Limits Endorsement') 
                        	order by ENDORSEMENT_NUMBER__C];
    }
    public String getrecordId(){
        return recordId;
    }
    
    public class policyWrapper{
        public String recId {get;set;}
        public String Name {get;set;}
        public String FIRM_NAME_History {get;set;}
        public String FIRM_BILLING_ADDRESS_History  {get;set;}
        public String POLICY_NUMBER_History {get;set;}
        public Date EFFECTIVE_DATE_History {get;set;}
        public Date EXPIRATION_DATE_History {get;set;}
        public Double PER_CLAIM_LIMIT_History {get;set;}
        public Boolean Full_Prior_Acts {get;set;}
        public Double AGGREGATE_LIMIT_History  {get;set;}
        public Double PER_CLAIM_DEDUCTIBLE_AMOUNT_History {get;set;}
        public Date POLICY_RETROACTIVE_DATE_History {get;set;}
        public Double PREMIUM_History {get;set;}
        public Date ISSUE_DATE_History {get;set;}
        public Boolean Remove_102_Endorsement {get;set;}
        public Date Date_Signed {get;set;}
    }
}