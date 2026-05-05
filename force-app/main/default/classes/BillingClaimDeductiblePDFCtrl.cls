public class BillingClaimDeductiblePDFCtrl {
    //public String validationString{get;set;}
	/*public BillingClaimDeductiblePDFCtrl(ApexPages.StandardController stdController) {
        String sitename = 'Payment';
        
        Site site = [SELECT GuestUserId FROM Site WHERE Name = :sitename ];
        
        String sitepath = '/sites/servlet.SiteDebugMode';
        PageReference prRef = new PageReference(sitepath );
        prRef .getParameters().put('guid', site.GuestUserId);
        prRef .getParameters().put('sitedebugmode', 'x');
        String siteurl = prRef .getContent().toString().substringAfter('URL=').substringBefore(sitepath );
        validationString = siteurl + '?id=' + PaymentGateway_Ctrl.processEncryption(Apexpages.currentpage().getparameters().get('id'),Label.Encryption_Key_Payment_Id);
    }*/
    
    public List<AcctSeed__Billing__c> relatedBillings { get; private set; }

    public BillingClaimDeductiblePDFCtrl(ApexPages.StandardController std) {
		relatedBillings = new List<AcctSeed__Billing__c>();
        
        Id currentId = std.getId();

        AcctSeed__Billing__c currentBill = [
            SELECT Id, AcctSeed__Customer__c, Claim__c , Policy_Deductible_Amount__c  FROM   AcctSeed__Billing__c WHERE  Id = :currentId LIMIT  1 ];

        relatedBillings = [
            SELECT Id, Name, AcctSeed__Date__c, AcctSeed__Total__c, AcctSeed__Received_Amount__c, AcctSeed__Balance__c FROM   AcctSeed__Billing__c
            WHERE Claim__c =: currentBill.Claim__c AND Id != :currentId ORDER  BY AcctSeed__Date__c ASC ];
    }
}