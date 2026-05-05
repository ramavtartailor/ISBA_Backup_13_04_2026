@isTest
public class Batch_MassRegeneratePolicyDocumentsTest {
    
     @testSetup static void setup(){
        Test.startTest();
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        opp.StageName                 = 'Application Sent';
        opp.CloseDate                 = Date.today();
        insert opp;
        
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Step Rate');
        insert mas;
        
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(mas.Id);
        insert stepRateFactor;
        
        ILF_Coverage_Factor__c ilfCoverageLowest = TestDataFactory.createCoveragefactor(mas.id);
        insert ilfCoverageLowest;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas.Id);
        Insert DedFac;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.id,county.Id);
        insert geo;

         Policy__c pol                 = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Application');
        pol.Status__c                 = 'Accepted';
        pol.SCH_Mod__c                = 1.00;
        pol.Policy_Document_Version__c    = '1/18';
        pol.Premium__c                 = 100;
        pol.Base_Amount__c = 123;
        pol.Firm_Mod__c = 112;
        pol.Limit__c = ilfCoverageLowest.id;
        pol.Deductible_ID__c = DedFac.id;
        pol.Premium_Amount__c = 120;
        insert pol;

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
         
          
       // Policy_Quote__c objPolQuote = TestDataFactory.createPolicyQuote(acctivePolicy.Id,coverageFactorObj.Id,DedFac.id);
       // insert objPolQuote;
        
        
       
        Contact con  = TestDataFactory.createContact('Test Contact',acc.id);
        con.ARDC_Number__c=null;
        insert con;
        
       
        
        AccountContactJunction__c junc = TestDataFactory.createAccConJunc(acctivePolicy.Account__C, con.Id);
        insert junc;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(acctivePolicy.Account__c,acctivePolicy.Id,junc.Id);
        insert law;
        
        Endorsement__c endorse191= TestDataFactory.createEndorsement('','descriptive','IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT');
        insert endorse191;
        
        Endorsement_Version__c endorseVersion1 = TestDataFactory.createEndorsementVersion(endorse191.Id);
        endorseVersion1.Endorsement_Version_Number__c='1';
        insert endorseVersion1;
        
        
        Endorsement_Version__c endorseVersion2 = TestDataFactory.createEndorsementVersion(endorse191.Id);
        endorseVersion1.Endorsement_Version_Number__c='2';
        insert endorseVersion2;
        
        Endorsement__c endorse302= TestDataFactory.createEndorsement('','descriptive','IL 302 AMENDMENT OF EXTENDED REPORTING PERIOD OPTIONS ENDORSEMENT');
        insert endorse302;
        
        Endorsement_Version__c endorseVersion3 = TestDataFactory.createEndorsementVersion(endorse302.Id);
        endorseVersion3.Endorsement_Version_Number__c='1';
        insert endorseVersion3;
        Test.stopTest();
        
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT');
        
        insert objPolEndorse;
        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'IL 102 PRIOR ACTS EXCLUSION ENDORSEMENT');
        poicyEndorse.Lawyer__c=junc.id;
        poicyEndorse.New_Limits__c=ilfCoverageLowest.Id;
        insert poicyEndorse;
        
        poicyEndorse.Effective_Date__c = date.today().addDays(4);
        poicyEndorse.Endorsement_Effective_Date__c =date.today().addDays(1);
        update poicyEndorse;
        
         
    }
    
    @isTest
    public static void TestMethod1(){
         Policy__c acctivePolicy =[Select id from Policy__c LIMIT 1];
        
        List<ContentVersion> CVList = new List<ContentVersion>();
        ContentVersion contentVersion1 = TestDataFactory.createContentVersoion('Penguins','Penguins.jpg');
        contentVersion1.Document_Type__c =  'Certificate Of Insurance';
        CVList.add(contentVersion1);
        ContentVersion contentVersion2 = TestDataFactory.createContentVersoion('Penguins2','Penguins.jpg');
        contentVersion2.Document_Type__c =  'Declaration Page';
        CVList.add(contentVersion2);
        ContentVersion contentVersion3 = TestDataFactory.createContentVersoion('Penguins3','Penguins.jpg');
        contentVersion3.Document_Type__c =  'NAS EOC';
        CVList.add(contentVersion3);
        ContentVersion contentVersion4 = TestDataFactory.createContentVersoion('Penguins4','Penguins.jpg');
        contentVersion4.Document_Type__c =  'Policy Letter';
        CVList.add(contentVersion4);
        
        insert CVList;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentDocumentLink> AllobjLink = new List<ContentDocumentLink>();
        
        for(ContentDocument Obj : documents){
            List<ContentDocumentLink> objLink = TestDataFactory.createContentDocumentLink(acctivePolicy.id,Obj.Id);
            AllobjLink.addAll(objLink);
        }
        
        insert AllobjLink;
        
        
        Batch_MassRegeneratePolicyDocuments batch = new Batch_MassRegeneratePolicyDocuments('select id,Account__c,Account__r.Physical_document_delivery__c,Policy_Document_Version__c,Effective_Date__c, NAS_EOC_Version_Formula__c   from Policy__c ','NAS EOC');
        DataBase.executeBatch(batch); 
    }

}