@isTest
public class PolicyDocumentsUtility_Test {
    @isTest
    public static void testMethod1(){
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true; 
        insert acc;
        
          Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        insert con; 
        
        Document document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'my_document';
        document.IsPublic = true;
        document.Name = 'My Document';
        document.FolderId = [select id from folder where name = 'Pardot'].id;
        insert document;
        
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);        
        insert geo;
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        ILF_Coverage_Factor__c coverageFactorObj = TestDataFactory.createCoveragefactor(masterFactorNew.Id);
        insert coverageFactorObj;
        
        Deductible_Factor__c dedFactorObj = TestDataFactory.createDeductiblefactor(masterFactorNew.Id);
        insert dedFactorObj;
        
        Policy__c acctivePolicy = TestDataFactory.createActivePolicy(acc.id,opp.id,geo.id,'Policy');
        acctivePolicy.Limit__c = coverageFactorObj.Id;
        acctivePolicy.Deductible_ID__c = dedFactorObj.Id;
       
        insert acctivePolicy;
         
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(acctivePolicy.Account__c, con.Id);
        insert junc;
        
        
         List<Policy_Endorsement__c> lstPolicyEndorsements = new List<Policy_Endorsement__c>();
        
       /* Policy_Endorsement__c policyEnd = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.Id,'General');
        policyEnd.Event_Status__c = 'Pending';
        policyEnd.Lawyer__c = junc.id;
        policyEnd.Refund_Amount__c = 10;
        policyEnd.Additional_Premium__c = 100;
        
        lstPolicyEndorsements.add(policyEnd);
        
        insert lstPolicyEndorsements; */
        
        Policy_Quote__c quote = TestDataFactory.createPolicyQuote(acctivePolicy.Id,coverageFactorObj.Id, dedFactorObj.Id);
        insert quote;
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        insert calimset;
        
        Endorsement__c endoObj = TestDataFactory.createEndorsement('','','General');
        endoObj.Endorsement_Record_Type_ID__c = String.valueOf(Schema.getGlobalDescribe().get('Policy_Endorsement__c').getDescribe().getRecordTypeInfosByName().get('IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT').getRecordTypeId());
        insert endoObj;
        
        PolicyDocumentsUtility.createCertificationOfInsurance(acctivePolicy.Id,'docVersion',acc.Id,document.Id);
        PolicyDocumentsUtility.createNASEOC(acctivePolicy.Id,'docVersion1',acc.Id,document.Id);
        PolicyDocumentsUtility.createDeclarationPage(acctivePolicy.Id,'docVersion2',acc.Id,document.Id);
        PolicyDocumentsUtility.createPolicyLetter(acctivePolicy.Id,'docVersion3',acc.Id,document.Id);
        PolicyDocumentsUtility.createQuote(quote.Id,acctivePolicy.Id,'docVersion4',acc.Id,document.Id);
        PolicyDocumentsUtility.createEndorsement(endoObj.Id,acctivePolicy.Id,'pdfName','50','docVersion5',acc.Id,document.Id,endoObj.id,false);
        PolicyDocumentsUtility.createEndorsement(endoObj.Id,acctivePolicy.Id,'pdfName','50','docVersion5',acc.Id,document.Id,endoObj.id);
        PolicyDocumentsUtility.policyToApplicationAccountingTransactions(acctivePolicy.Id);
        PolicyDocumentsUtility.createIL102(acctivePolicy.Id,'docVersion5',acctivePolicy,document.Id);
        try{
            PolicyDocumentsUtility.createIL302(acctivePolicy.Id,'docVersion5',acctivePolicy,document.Id);
        }
        catch(Exception e){
            system.debug(e.getMessage());
        }
        try{
            PolicyDocumentsUtility.createContentVersion(Blob.valueOf('body'), 'fileName', acctivePolicy.Id, acc.Id, 'Declaration Page', document.Id, null);
        }
        catch(Exception e){
            system.debug(e.getMessage());
        }
       
        PolicyDocumentsUtility.createIL230_234_261(acctivePolicy.Id, 'docVersion6', acctivePolicy, false, false, false);
        
    }
}