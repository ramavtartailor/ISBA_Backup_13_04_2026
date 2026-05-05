public class Billing_Policy_Ctrl {
    
    // variables
    public String billId {get; set;}
    public String recordId{get;set;}
    public AcctSeed__Billing__c billing {get; set;}
    public Policy__c policy {get; set;}
    public Policy_Quote__c quote{get;set;}
    public EmailMessage latest_invoice_activity{get;set;}
    public List<Policy_Quote__c> quoteList{get;set;}    
    
    // constructor
    public Billing_Policy_Ctrl(){
        if (apexpages.currentpage().getparameters().get('id') != null){
            recordId = apexpages.currentpage().getparameters().get('id');
        }else{
            recordId = billId;
        }
        if(String.isNotBlank(recordId)){
            setrecordId(recordId);
            getPolicyRec();
            getInvoiceActivity();
        }
    }
    //System.debug('recordId-----'+recordId);
    
    
    public static string insertBreak(String hyperLink) { // hyperLink is the URL
        final Integer linkLength = hyperLink.length();
        final Integer maxLength = Math.min(100,linkLength);
        Integer varCount = (linkLength/maxLength);
        
        if (math.mod(linkLength, maxLength) > 0)
            varCount++;
        
        String fullLink = '';
        integer startValue = 0;
        integer endValue = maxLength;
        for (Integer i = varCount; i >= 0; i--) { 
            fullLink += hyperLink.substring(startValue, endValue) + ' ';
            startValue = endValue;
            endValue = (endValue + maxLength) > linkLength ? linkLength : (endValue + maxLength);
        }
        return fullLink;
    }
    
    // instantiate record id
    public void setrecordId(String recordId){
        
        // get billing
        // https://isbamutual--beta--c.sandbox.vf.force.com/apex/NOC_PDF?id=a1f050000016RiFAAU
        billing = [
            SELECT 
            Name
            , Payment_Link__c
            , Policy__c
            , AcctSeed__Billing_Contact__r.Name
            , AcctSeed__Billing_Contact__r.email
            , AcctSeed__Billing_Contact__r.FirstName
            , AcctSeed__Billing_Contact__r.LastName
            , ISBAM_Overdue_Date__c 
            , Past_Due_Amount__c,Policy_Number__c,Latest_Activity_Date__c
            FROM AcctSeed__Billing__c 
            WHERE Id =: recordId
        ];
        System.debug('billing: '+billing);    
        
        
        
        // get latest invoice activity
       
                
        // get policy
        policy = [
            SELECT 
            Name
            , Account__c
            , Effective_Date__c
            , County__r.Name
            , Account__r.Account_Number_External_ID__c, Account__r.Name
            , Account__r.Phone
            , Account__r.Fax
            , Expiration_Date__c
            , Per_Claim_Limit__c
            , Deductible_ID__r.Name, Premium__c
            , Aggregate_Limit__c
            , Account__r.BillingStreet
            , Account__r.BillingCity
            , Account__r.BillingState
            , Account__r.BillingPostalCode
            , Latest_Activity_Date__c
            , Application_Type__c
            , Firm_Contact__r.Email
            , Firm_Contact__r.Name
            , Firm_Contact__r.FirstName
            , Firm_Contact__r.LastName
            , Firm_Contact__r.Website__c
            , Firm_Contact__r.Title
            , Account__r.Website__c
            , Firm_Contact__r.Contact_Role__c
            , Total_CLE_Credit__c
            , DataLoader__c
            , Underwriter_User__r.FirstName
            , Underwriter_User__r.LastName
            , Dividend_Credit__c
            , Total_Credit__c
            , Underwriter_User__r.Title,Underwriter_User__r.Phone,Underwriter_User__r.Email
            , ISBAM_policy_dividend__c
            , Previous_Policy__r.Name
            FROM Policy__c 
            WHERE Id =: billing.Policy__c
        ];
        
        
        // get quote
        quoteList = [
            SELECT id,
            name
            , POLICY_EFFECTIVE_DATE__C
            , POLICY_FIRM__C
            , FIRM_BILLINGSTREET__C
            , FIRM_BILLINGCITY__C
            , FIRM_BILLINGSTATE__C
            , FIRM_BILLINGZIP__C
            , CREATEDDATE,QUOTE_EXPIRE_DATE__C
            , Policy__C
            , FIRM_PRIOR_ACTS_DATE__c
            , COVERAGE_MAX_PER_CLAIM__c
            , FULL_COVERAGE__C
            , DEDUCTIBLE_AMOUNT__C
            , QUOTE_FINAL_PREMIUM__c
            , QUOTE_FINAL_PREMIUM_QRTLY__c
            , QUOTE_FINAL_PREMIUM_MONTHLY__c 
            FROM Policy_Quote__c 
            WHERE Policy__c=: billing.Policy__c
            ORDER BY QUOTE_FINAL_PREMIUM__c ASC
        ];
        System.debug('quoteList-----'+quoteList);  
        if(!quoteList.isEmpty()){
            quote = quoteList[0];
        }
        
        
        
    }
    
    public EmailMessage getInvoiceActivity() {
        system.debug('recordId  - > ' + recordId);
        List<EmailMessage> emailMessages = [SELECT
                Name
                , Status
                , Subject
                , MessageDate 
                FROM EmailMessage 
                WHERE RelatedToId =: recordId AND Subject Like '%Invoice%'
                ORDER BY MessageDate DESC
                LIMIT 1
               ];
        if(!emailMessages.isEmpty()){
            return emailMessages[0];
        }else{
            return null;
        }
        
    }
        
    public AcctSeed__Billing__c getbillingRec(){
        AcctSeed__Billing__c bill = [
            SELECT id,
            Name
            , Payment_Link__c
            , Policy__c
            , AcctSeed__Billing_Contact__r.Name
            , AcctSeed__Billing_Contact__r.email
            , AcctSeed__Billing_Contact__r.FirstName
            , AcctSeed__Billing_Contact__r.LastName
            , ISBAM_Overdue_Date__c 
            , Past_Due_Amount__c,Policy_Number__c,Latest_Activity_Date__c
            FROM AcctSeed__Billing__c 
            WHERE Id =: recordId
            LIMIT 1
        ];
        bill.Payment_Link__c = insertBreak(bill.Payment_Link__c);
        return bill;
    }  
    
    public Policy__c getPolicyRec(){
        system.debug('recordId -- > ' + recordId);
        
        List<AcctSeed__Billing__c> billingRecList = new List<AcctSeed__Billing__c>();
        billingRecList = [
            SELECT 
            id
            , Policy__c,Policy_Number__c 
            FROM AcctSeed__Billing__c 
            WHERE Id =: recordId
            LIMIT 1
        ];
        
        if(!billingRecList.isEmpty()){ 
            return  [
                SELECT 
                Name
                , Account__c
                , Effective_Date__c
                , County__r.Name
                , Account__r.Account_Number_External_ID__c, Account__r.Name
                , Account__r.Phone
                , Account__r.Fax
                , Expiration_Date__c
                , Per_Claim_Limit__c
                , Deductible_ID__r.Name, Premium__c
                , Aggregate_Limit__c
                , Account__r.BillingStreet
                , Account__r.BillingCity
                , Account__r.BillingState
                , Account__r.BillingPostalCode
                , Account__r.ShippingStreet
                , Account__r.ShippingCity
                , Account__r.ShippingState
                , Account__r.ShippingPostalCode
                , Latest_Activity_Date__c
                , Application_Type__c
                , Firm_Contact__r.Email
                , Firm_Contact__r.Name
                , Firm_Contact__r.FirstName
                , Firm_Contact__r.LastName
                , Firm_Contact__r.Website__c
                , Firm_Contact__r.Title
                , Account__r.Website__c
                , Firm_Contact__r.Contact_Role__c
                , Total_CLE_Credit__c
                , DataLoader__c
                , Underwriter_User__r.FirstName
                , Underwriter_User__r.LastName
                , Dividend_Credit__c
                , Total_Credit__c
                , Underwriter_User__r.Title,Underwriter_User__r.Phone,Underwriter_User__r.Email
                , ISBAM_policy_dividend__c
                , Previous_Policy__r.Name
                FROM Policy__c 
                WHERE Id =: billingRecList[0].Policy__c
            ];
        }
        else{
            return new Policy__c();
        }
    }
}