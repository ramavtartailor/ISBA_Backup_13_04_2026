@isTest
private class DocumentBundleVF_Ctrl_Test {
    
    @testSetup static void setup() {
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        List<AcctSeed__GL_Account__c> glAccounts = TestDataFactory.createGLAccounts();        
        insert glAccounts;
        
        List<AcctSeed__Billing_Format__c> billingFormats = TestDataFactory.createBillingFormats();        
        insert billingFormats ;
        
        List<AcctSeed__Ledger__c> ledgers = TestDataFactory.createLedgers(glAccounts[0].id,billingFormats[0].id,billingFormats[1].id,billingFormats[2].id,billingFormats[3].id,billingFormats[4].id);
        insert ledgers;
        
        AcctSeed__Accounting_Settings__c settings = TestDataFactory.createAccountsetting(ledgers[0].id,glAccounts[0].Id,glAccounts[1].Id,glAccounts[2].Id,glAccounts[3].Id,glAccounts[4].Id,glAccounts[5].Id,glAccounts[6].Id,billingFormats[0].Id);
        insert settings;
        
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
        insert opp;
        
        Master_Factor__c mas          = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.Id,county.Id);
        
        insert geo;
        
        Master_Factor__c masterFactor = TestDataFactory.createMasterfactor('Test Master Factor','Step rate');
        insert masterFactor;
        
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(masterFactor.Id);
        insert stepRateFactor;
        
        Master_Factor__c masterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert masterFactor1;
        
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(masterFactor1.Id);
        insert baseFactor;
        
        Map<String,String> mapRecordTypes = new Map<String,String>();
        
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c']) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoveragefactor(MasterFactorCoverage.Id);
        FactorCoverage.Is_5X5_Coverage__c = true;
        //    FactorCoverage.Is_10X10_Coverage__c = false;
        FactorCoverage.Percentage_5X5_Step_0__c = 2;
        FactorCoverage.Percentage_5X5_Step_1__c = 4;
        FactorCoverage.Percentage_5X5_Step_2__c = 6;
        FactorCoverage.Percentage_5X5_Step_3__c = 10;
        FactorCoverage.Premium_Rate_5X5__c = 100;
        insert FactorCoverage;
        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor1','Deductible');
        insert mas12;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        Insert DedFac; 
        
        Policy__c pol                 = TestDataFactory.createPolicy(acc.id,opp.id,geo.id,'Policy');
        //pol.Status__c = 'Received';
        pol.Base_Amount__c = 100;
        pol.Firm_Mod__c = 2;
        pol.Limit__c = FactorCoverage.Id;
        pol.Deductible_ID__c = DedFac.id;
        pol.Application_Type__c = 'Renewal';
        pol.Policy_Document_Version__c = '1/18';
        insert pol;
        
        ContentVersion contentVersion = TestDataFactory.createContentVersoion('Penguins','Penguins.jpg');
        contentVersion.Document_Type__c = 'Policy Letter';
        contentVersion.Is_System_Generated_Document__c = true;
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<ContentDocumentLink> objLink = TestDataFactory.createContentDocumentLink(pol.id,documents[0].Id);
        insert objLink;
        
      //  List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
       /* List<ContentDocumentLink> objLink = TestDataFactory.createContentDocumentLink(objNote.id,documents[0].Id);
        objLink[0].LinkedEntityId=pol.Id;
        insert objLink;
        
        ContentVersion contentVersion = TestDataFactory.createContentVersoion('Penguins','Penguins.jpg');
        contentVersion.Document_Type__c = 'Policy Letter';
      //  contentVersion.ContentDocumentId=objLink[0].ContentDocumentId;
        insert contentVersion;*/
         
        Policy_Quote__c objQuote = new Policy_Quote__c();
        objQuote.Policy__c =pol.id ;
        objQuote.Coverage__c = FactorCoverage.id;
        objQuote.Deductible__c = DedFac.id;
        objQuote.Lowest_Coverage_Factor__c = 12;
        objQuote.Quote_Premium_Step_0__c =1000;
        objQuote.Quote_Premium_Step_1__c = 1000;
        objQuote.Quote_Premium_Step_2__c = 1000;
        objQuote.Quote_Premium_Step_3__c = 1000;
        objQuote.Quote_Premium_Step_4__c = 1000;
        objQuote.Quote_Premium_Step_5__c = 1000;
        objQuote.Quote_Premium_Step_6__c = 1000;
        objQuote.Quote_Premium_Step_7__c = 1000;
        objQuote.Primary_Step_0__c = 1000;
        objQuote.Primary_Step_1__c = 1000;
        objQuote.Primary_Step_2__c = 1000;
        objQuote.Primary_Step_3__c = 1000;
        objQuote.Primary_Step_4__c = 1000;
        objQuote.Primary_Step_5__c = 1000;
        objQuote.Primary_Step_6__c = 1000;
        objQuote.Primary_Step_7__c = 1000;
        objQuote.Excess_Step_0__c = 1000;
        objQuote.Excess_Step_1__c = 1000;
        objQuote.Excess_Step_2__c = 1000;
        objQuote.Excess_Step_3__c = 1000;
        objQuote.Excess_Step_4__c = 1000;
        objQuote.Excess_Step_5__c = 1000;
        objQuote.Excess_Step_6__c = 1000;
        objQuote.Excess_Step_7__c = 1000;
        objQuote.Mod_230__c = 12;
        objQuote.Mod_234__c = 22;
        objQuote.Mod_261__c = 23;
        insert objQuote;
        
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,pol.id,'General');
        poicyEndorse.Endorsement_Number__c = '123456';
        poicyEndorse.Endorsement_Version__c = '12';
         poicyEndorse.Endorsement_Effective_Date__c = system.today()-1;
        poicyEndorse.Policy__c = pol.Id;
        
        poicyEndorse.Event_Status__c = 'Complete';    
        poicyEndorse.Event_Status__c = 'Pending';
        //     poicyEndorse.Override_Rating__c = true;
        //     poicyEndorse.Override_5_5__c = 10; 
        //     poicyEndorse.Override_10_10__c = 20;
        //    poicyEndorse.RecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        insert poicyEndorse;
        
        Master_Factor__c masterFactorNew = TestDataFactory.createMasterfactor('Test Master Factor4','AOP');
        insert masterFactorNew;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,pol.id);
        insert aop;
        
        ContentVersion cv = TestDataFactory.createContentVersoion('title', 'poc');
        insert cv;
        
        Attachment attach=new Attachment();
        attach.Name='Unit Test Attachment'; 
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
        attach.body=bodyBlob; 
        attach.ParentId = acc.Id;
        attach.ContentType = 'Quote'; 
        attach.IsPrivate = false; 
        attach.Description = 'Test'; 
        
        //  attach.DeveloperName = ‘my_document’;
        //  attach.FolderId = [select id from folder where Name = ‘Unit Test Attachment’].id;
        
        insert attach; 
        
        Set<String> setAttachId  = new Set<String>();
        //for(Attachment objAttch : [SELECT Id FROM Attachment ]){
        setAttachId.add(attach.id);
        //}
        
    }
    
    @isTest static void testMethod1() {
        
        List<Account> acc = [SELECT Id FROM Account];
        List<Policy__c> policies = [SELECT Id,Account__c,Account__r.name FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<ContentVersion> lc = [Select id from ContentVersion ];
        
        
        Policy__c  policy = policies[0];
        
        
        Set<String> setAttachId  = new Set<String>();
        for(Attachment objAttch : [SELECT Id FROM Attachment ]){
            setAttachId.add(objAttch.id);
        }
        
        Test.startTest();
        
        
        PageReference pageRef = Page.DocumentBundleVF;
        pageRef.getParameters().put('id', policy.id);
        pageRef.getParameters().put('type', 'printPolicyDocs');
        //   pageRef.getParameters().put('type', 'quoteBundle');
        //   pageRef.getParameters().put('type', 'Quote');
        //  ApexPages.currentPage().getParameters().put('type', 'printPolicyDocs');
        
        system.Test.setCurrentPage(pageRef);
        
        DocumentBundleVF_Ctrl  Ctrl = new DocumentBundleVF_Ctrl();  
        Ctrl.generateBundle();
        Ctrl.printPolicy();
        Ctrl.close();
        
        Test.stopTest();
        
    }
    @isTest static void testMethod2() {
        
        List<Account> acc = [SELECT Id FROM Account];
        List<Policy__c> policies = [SELECT Id,Account__c,Account__r.name FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<Policy_Quote__c> q = [select id,name,Limits__c,Deductibles_Formula__c,Mod_230__c,Mod_234__c,Mod_261__c from Policy_Quote__c];
        List<ContentVersion> lc = [Select id from ContentVersion ];
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 261','Descriptive','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
                
        Policy__c  policy = policies[0];
        
        Set<String> setAttachId  = new Set<String>();
        for(Attachment objAttch : [SELECT Id FROM Attachment ]){
            setAttachId.add(objAttch.id);
        }
         
        
        Test.startTest();
        
        
        PageReference pageRef = Page.DocumentBundleVF;
        pageRef.getParameters().put('id', policy.id);
        
        pageRef.getParameters().put('type', 'quoteBundle');
        //   pageRef.getParameters().put('type', 'Quote');
        //  ApexPages.currentPage().getParameters().put('type', 'printPolicyDocs');
        
        system.Test.setCurrentPage(pageRef);
        
        DocumentBundleVF_Ctrl  Ctrl = new DocumentBundleVF_Ctrl();  
        Ctrl.generateBundle();
        Ctrl.printPolicy();
        Ctrl.close();
        DocumentBundleVF_Ctrl.deleteDownloadedContent(lc[0].id);
        Ctrl.printQuotes();
        Test.stopTest();
        
    }
    @isTest static void testMethod3() {
        
        List<Account> acc = [SELECT Id FROM Account];
        List<Policy__c> policies = [SELECT Id,Account__c,Account__r.name FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        
        
        Policy__c  policy = policies[0];
        
        Set<String> setAttachId  = new Set<String>();
        for(Attachment objAttch : [SELECT Id FROM Attachment ]){
            setAttachId.add(objAttch.id);
        }
        
        Test.startTest();
        
        
        PageReference pageRef = Page.DocumentBundleVF;
        pageRef.getParameters().put('id', policy.id);
        
        
        pageRef.getParameters().put('type', 'Quote');
        //  ApexPages.currentPage().getParameters().put('type', 'printPolicyDocs');
        
        system.Test.setCurrentPage(pageRef);
        
        DocumentBundleVF_Ctrl  Ctrl = new DocumentBundleVF_Ctrl();  
        Ctrl.generateBundle();
        Ctrl.printPolicy();
        Ctrl.close();
        
        Test.stopTest();
        
    }
    @isTest static void testMethod4() {
        
        List<Account> acc = [SELECT Id FROM Account];
        List<Policy__c> policies = [SELECT Id,Account__c,Account__r.name FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        
        
        Policy__c  policy = policies[0];
        policy.Application_Type__c ='New Business';
     //  policy.Application_Type__c ='renewal';
        update policy;
        
        Set<String> setAttachId  = new Set<String>();
        for(Attachment objAttch : [SELECT Id FROM Attachment ]){
            setAttachId.add(objAttch.id);
        }
        
        Test.startTest();
        
        
        PageReference pageRef = Page.DocumentBundleVF;
        pageRef.getParameters().put('id', policy.id);
        
        
        pageRef.getParameters().put('type', 'renewal');
        //  ApexPages.currentPage().getParameters().put('type', 'printPolicyDocs');
        
        system.Test.setCurrentPage(pageRef);
        
        DocumentBundleVF_Ctrl  Ctrl = new DocumentBundleVF_Ctrl();  
        Ctrl.generateBundle();
        Ctrl.printPolicy();
        Ctrl.close();
        
        Test.stopTest();
        
    }
    @isTest static void testMethod5() {
        
        List<Account> acc = [SELECT Id FROM Account];
        List<Policy__c> policies = [SELECT Id,Account__c,Account__r.name FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        
        
        Policy__c  policy = policies[0];
        
        Set<String> setAttachId  = new Set<String>();
        for(Attachment objAttch : [SELECT Id FROM Attachment ]){
            setAttachId.add(objAttch.id);
        }
        
        Test.startTest();
        
        
        PageReference pageRef = Page.DocumentBundleVF;
        pageRef.getParameters().put('id', policy.id);
        
        
        pageRef.getParameters().put('renewalType', 'Regular Renewal');
        //  ApexPages.currentPage().getParameters().put('type', 'printPolicyDocs');
        
        system.Test.setCurrentPage(pageRef);
        
        DocumentBundleVF_Ctrl  Ctrl = new DocumentBundleVF_Ctrl();  
        Ctrl.generateBundle();
        Ctrl.printPolicy();
        Ctrl.close();
        
        Test.stopTest();
        
    }
     @isTest static void testMethod6() {
        
        List<Account> acc = [SELECT Id FROM Account];
        List<Policy__c> policies = [SELECT Id,Account__c,Account__r.name FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<Policy_Quote__c> q = [select id,name,Limits__c,Deductibles_Formula__c,Mod_230__c,Mod_234__c,Mod_261__c from Policy_Quote__c];
        
        
        Policy__c  policy = policies[0];
        
        Set<String> setAttachId  = new Set<String>();
        for(Attachment objAttch : [SELECT Id FROM Attachment ]){
            setAttachId.add(objAttch.id);
        }
         
        
        Test.startTest();
        
        
        PageReference pageRef = Page.DocumentBundleVF;
        pageRef.getParameters().put('id', policy.id);
        pageRef.getParameters().put('type', 'Renewal');
        //pageRef.getParameters().put('removeQuoteIds', q[0].id);
        //  ApexPages.currentPage().getParameters().put('type', 'printPolicyDocs');
        
        system.Test.setCurrentPage(pageRef);
        
        DocumentBundleVF_Ctrl  Ctrl = new DocumentBundleVF_Ctrl();  
        Ctrl.generateBundle();
        Ctrl.printPolicy();
        Ctrl.close();
        
        Test.stopTest();
        
    }
     @isTest static void testMethod7() {
        
         Test.startTest();
        List<Account> acc = [SELECT Id FROM Account];
        List<Policy__c> policies = [SELECT Id,Account__c,Account__r.name FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<Policy_Quote__c> q = [select id,name,Limits__c,Deductibles_Formula__c,Mod_230__c,Mod_234__c,Mod_261__c from Policy_Quote__c];
        
         System.debug('policy id --> ' + policies[0]);
        
        Policy__c  policy = policies[0];
        policy.Application_Type__c='New Business';
         update policy;
        Set<String> setAttachId  = new Set<String>();
        for(Attachment objAttch : [SELECT Id FROM Attachment ]){
            setAttachId.add(objAttch.id);
        }
         
          List<Deductible_Factor__c> DedFac = [Select id from Deductible_Factor__c ];
        
         
         
         
          List<ILF_Coverage_Factor__c> FactorCoverage = [select id from ILF_Coverage_Factor__c];
       
            
        Policy_Quote__c objQuote = new Policy_Quote__c();
        objQuote.Policy__c =policies[0].id ;
        objQuote.Coverage__c = FactorCoverage[0].id;
        objQuote.Deductible__c = DedFac[0].id;
        objQuote.Lowest_Coverage_Factor__c = 1;
        objQuote.Quote_Premium_Step_0__c =10;
        objQuote.Quote_Premium_Step_1__c = 10;
        objQuote.Quote_Premium_Step_2__c = 10;
        objQuote.Quote_Premium_Step_3__c = 10;
        objQuote.Quote_Premium_Step_4__c = 10;
        objQuote.Quote_Premium_Step_5__c = 10;
        objQuote.Quote_Premium_Step_6__c = 10;
        objQuote.Quote_Premium_Step_7__c = 10;
        objQuote.Primary_Step_0__c = 10;
        objQuote.Primary_Step_1__c = 10;
        objQuote.Primary_Step_2__c = 10;
        objQuote.Primary_Step_3__c = 10;
        objQuote.Primary_Step_4__c = 10;
        objQuote.Primary_Step_5__c = 10;
        objQuote.Primary_Step_6__c = 10;
        objQuote.Primary_Step_7__c = 10;
        objQuote.Excess_Step_0__c = 10;
        objQuote.Excess_Step_1__c = 10;
        objQuote.Excess_Step_2__c = 10;
        objQuote.Excess_Step_3__c = 10;
        objQuote.Excess_Step_4__c = 10;
        objQuote.Excess_Step_5__c = 10;
        objQuote.Excess_Step_6__c = 10;
        objQuote.Excess_Step_7__c = 10;
        objQuote.Mod_230__c = 11;
        objQuote.Mod_234__c = 222;
        objQuote.Mod_261__c = 232;
        insert objQuote;
         
        
        
        
        
        PageReference pageRef = Page.DocumentBundleVF;
        pageRef.getParameters().put('id', policy.id);
        //pageRef.getParameters().put('type', 'Renewal');
        pageRef.getParameters().put('removeQuoteIds', objQuote.id);
        //  ApexPages.currentPage().getParameters().put('type', 'printPolicyDocs');
        
         system.Test.setCurrentPage(pageRef);
         
         DocumentBundleVF_Ctrl  Ctrl = new DocumentBundleVF_Ctrl();  
         Ctrl.generateBundle();
         Ctrl.printPolicy();
         Ctrl.close();
         Ctrl.autoRenewal();
         Ctrl.autoGenerate();
         
         DocumentBundleVF_Ctrl  Ctrl1 = new DocumentBundleVF_Ctrl(policy.Id,'lawyerSupplement','Regular Renewal');  
         Test.stopTest();
        
    }
    @isTest static void testMethod8(){
        List<Account> acc = [SELECT Id FROM Account];
        List<Policy__c> policies = [SELECT Id,Account__c,Account__r.name FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<Policy_Quote__c> q = [select id,name,Limits__c,Deductibles_Formula__c,Mod_230__c,Mod_234__c,Mod_261__c from Policy_Quote__c];
        List<ContentVersion> lc = [Select id from ContentVersion ];
        
        Policy__c  policy = policies[0];
        
        Set<String> setAttachId  = new Set<String>();
        for(Attachment objAttch : [SELECT Id FROM Attachment ]){
            setAttachId.add(objAttch.id);
        }
         
        
        Test.startTest();
        
        
        PageReference pageRef = Page.DocumentBundleVF;
        pageRef.getParameters().put('id', policy.id);
        
        pageRef.getParameters().put('type', 'lawyerSupplement');
        //   pageRef.getParameters().put('type', 'Quote');
        //  ApexPages.currentPage().getParameters().put('type', 'printPolicyDocs');
        
        system.Test.setCurrentPage(pageRef);
        
        DocumentBundleVF_Ctrl  Ctrl = new DocumentBundleVF_Ctrl();  
        Ctrl.generateBundle();
        Ctrl.printPolicy();
        Ctrl.close();
        DocumentBundleVF_Ctrl.deleteDownloadedContent(lc[0].id);
        Ctrl.printQuotes();
        Test.stopTest();
        
    }
    
    @isTest static void testMethod9(){
        List<Account> acc = [SELECT Id FROM Account];
        List<Policy__c> policies = [SELECT Id,Account__c,Account__r.name FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 261','Descriptive','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy__c  policy = policies[0];
        policy.Application_Type__c ='New Business';
        update policy;
        
        Test.startTest();
        Set<String> setAttachId  = new Set<String>();
        for(Attachment objAttch : [SELECT Id FROM Attachment ]){
            setAttachId.add(objAttch.id);
        }
        
        
        
        PageReference pageRef = Page.DocumentBundleVF;
        pageRef.getParameters().put('id', policy.id);
        
        
        pageRef.getParameters().put('type', 'quoteBundle');
        //  ApexPages.currentPage().getParameters().put('type', 'printPolicyDocs');
        
        system.Test.setCurrentPage(pageRef);
        
        DocumentBundleVF_Ctrl  Ctrl = new DocumentBundleVF_Ctrl();  
        Ctrl.generateBundle();
        Ctrl.printPolicy();
        Ctrl.close();
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod10(){
        Test.startTest();
        List<Account> acc = [SELECT Id FROM Account];
        List<Policy__c> policies = [SELECT Id,Account__c,Account__r.name FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<Policy_Quote__c> q = [select id,name,Limits__c,Deductibles_Formula__c,Mod_230__c,Mod_234__c,Mod_261__c from Policy_Quote__c];
        
         System.debug('policy id --> ' + policies[0]);
        
        Policy__c  policy = policies[0];
        policy.Application_Type__c='New Business';
         update policy;
        Set<String> setAttachId  = new Set<String>();
        for(Attachment objAttch : [SELECT Id FROM Attachment ]){
            setAttachId.add(objAttch.id);
        }
         
          List<Deductible_Factor__c> DedFac = [Select id from Deductible_Factor__c ];
        
         
         
         
          List<ILF_Coverage_Factor__c> FactorCoverage = [select id from ILF_Coverage_Factor__c];
       
            
        Policy_Quote__c objQuote = new Policy_Quote__c();
        objQuote.Policy__c =policies[0].id ;
        objQuote.Coverage__c = FactorCoverage[0].id;
        objQuote.Deductible__c = DedFac[0].id;
        objQuote.Lowest_Coverage_Factor__c = 1;
        objQuote.Quote_Premium_Step_0__c =10;
        objQuote.Quote_Premium_Step_1__c = 10;
        objQuote.Quote_Premium_Step_2__c = 10;
        objQuote.Quote_Premium_Step_3__c = 10;
        objQuote.Quote_Premium_Step_4__c = 10;
        objQuote.Quote_Premium_Step_5__c = 10;
        objQuote.Quote_Premium_Step_6__c = 10;
        objQuote.Quote_Premium_Step_7__c = 10;
        objQuote.Primary_Step_0__c = 10;
        objQuote.Primary_Step_1__c = 10;
        objQuote.Primary_Step_2__c = 10;
        objQuote.Primary_Step_3__c = 10;
        objQuote.Primary_Step_4__c = 10;
        objQuote.Primary_Step_5__c = 10;
        objQuote.Primary_Step_6__c = 10;
        objQuote.Primary_Step_7__c = 10;
        objQuote.Excess_Step_0__c = 10;
        objQuote.Excess_Step_1__c = 10;
        objQuote.Excess_Step_2__c = 10;
        objQuote.Excess_Step_3__c = 10;
        objQuote.Excess_Step_4__c = 10;
        objQuote.Excess_Step_5__c = 10;
        objQuote.Excess_Step_6__c = 10;
        objQuote.Excess_Step_7__c = 10;
        objQuote.Mod_230__c = 11;
        objQuote.Mod_234__c = 222;
        objQuote.Mod_261__c = 232;
        insert objQuote;
         
        
        
        
        
        PageReference pageRef = Page.DocumentBundleVF;
        pageRef.getParameters().put('id', policy.id);
        pageRef.getParameters().put('type', 'printPolicyDocs');
        pageRef.getParameters().put('removeQuoteIds', objQuote.id);
       // ApexPages.currentPage().getParameters().put('type', 'printPolicyDocs');
        
         system.Test.setCurrentPage(pageRef);
         
         DocumentBundleVF_Ctrl  Ctrl = new DocumentBundleVF_Ctrl();  
         Ctrl.generateBundle();
         Ctrl.printPolicy();
         Ctrl.close();
         Ctrl.autoRenewal();
         Ctrl.autoGenerate();
         
         DocumentBundleVF_Ctrl  Ctrl1 = new DocumentBundleVF_Ctrl(policy.Id,'lawyerSupplement','Regular Renewal'); 
        Ctrl1.generateBundle();
         Ctrl1.printPolicy();
         Ctrl1.close();
         Ctrl1.autoRenewal();
         Ctrl1.autoGenerate();
        
        DocumentBundleVF_Ctrl  Ctrl2 = new DocumentBundleVF_Ctrl(policy.Id,'renewal','Regular Renewal'); 
        Ctrl2.generateBundle();
         Ctrl2.printPolicy();
         Ctrl2.close();
         Ctrl2.autoRenewal();
         Ctrl2.autoGenerate();
        
       
        policy.Application_Type__c = 'Renewal';
        update policy;
        
        DocumentBundleVF_Ctrl  Ctrl4 = new DocumentBundleVF_Ctrl(policy.Id,'renewal','Regular Renewal'); 
        Ctrl4.generateBundle();
         Ctrl4.printPolicy();
         Ctrl4.close();
         Ctrl4.autoRenewal();
         Ctrl4.autoGenerate();
        
        DocumentBundleVF_Ctrl  Ctrl3 = new DocumentBundleVF_Ctrl(policy.Id,'renewal','EZ Renewal'); 
        Ctrl3.generateBundle();
         Ctrl3.printPolicy();
         Ctrl3.close();
         Ctrl3.autoRenewal();
         Ctrl3.autoGenerate();
         Test.stopTest();
    }
        
}