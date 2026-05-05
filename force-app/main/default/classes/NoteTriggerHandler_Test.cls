@istest
public class NoteTriggerHandler_Test {
    @istest static void testMethod1() {
        Test.startTest();
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Account acc1                   = TestDataFactory.createAccounts('Test Account');
        acc1.AccountNumber             = '123456';
        acc1.Vendor_Account__c         = true;
       // insert acc1;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        insert con;
        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        opp.StageName                 = 'Application Sent';
        opp.CloseDate                 = Date.today();
        insert opp;
        
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
        
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Geo');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.id,county.Id);
        //geo.County__c                 = county.Id;
        insert geo;
        
        Master_Factor__c masterFactor = TestDataFactory.createMasterfactor('Test Master Factor0','Step Rate');
        insert masterFactor;
        
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(masterFactor.Id);
        insert stepRateFactor;
        
        Master_Factor__c masterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert masterFactor1;
        
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(masterFactor1.Id);
        insert baseFactor;
        
        Policy__c pol                 = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Policy');
        pol.Status__c                 = 'Bound';
        insert pol;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(acc.id,pol.id,acj.Id);
        insert law; 
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        insert calimset;
        
        Policy_Claim__c claim = TestDataFactory.createPolicyClaim(pol.id,law.id);
        insert claim;
        
        Id ClaimRecordTypeId  = Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Claims'];
        
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo121@r1a2n3domdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo121@r1a2n3domdemodomain.com');
        insert u1;
        
        Note__c objNote = TestDataFactory.createNoteForAccount(acc.Id,'Close');
        objNote.RecordTypeId = ClaimRecordTypeId;
        objNote.Status__c = 'Pending';
        objNote.Due_Date__c = System.today();
        objNote.Create_Task__c = true;
        objNote.Task_Owner__c = u1.Id;
        objNote.Claim__c = claim.Id;
        insert objNote;
        
        objNote.Cloned_Task_Id__c = '';
        update objNote;
        
        objNote.Due_Date__c = date.today().addDays(4);
        update objNote;
        
        objNote.Due_Date__c = date.today().addDays(4);
        delete objNote;
        
        Test.stopTest();

    }
    
    @istest static void testMethod2() {
        Test.startTest();
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        insert acc;
        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        opp.StageName                 = 'Application Sent';
        opp.CloseDate                 = Date.today();
        insert opp;
        
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Geo');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.id,county.Id);
        insert geo;
        
        Policy__c pol                 = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Policy');
        pol.Status__c                 = 'Bound';
        insert pol;
        
        Id ClaimRecordTypeId  = Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Claims'];
        
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo121@r1a2n3domdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo121@r1a2n3domdemodomain.com');
        insert u1;
        
        Note__c objNote = TestDataFactory.createNoteForAccount(acc.Id,'Close');
        objNote.RecordTypeId = ClaimRecordTypeId;
        objNote.Policy__c = pol.Id;
        objNote.Status__c = 'Pending';
        objNote.Due_Date__c = System.today();
        objNote.Create_Task__c = true;
        objNote.Task_Owner__c = u1.Id;
        insert objNote;
        
        objNote.Cloned_Task_Id__c = '';
        update objNote;
        
        objNote.Due_Date__c = date.today().addDays(6);
        update objNote;
        
        objNote.Due_Date__c = date.today().addDays(6);
        delete objNote;
        
        Test.stopTest();

    }
    
     
    @istest static void testMethod3() {
        Test.startTest();
        
        Account acc                   = TestDataFactory.createAccounts('Test Account');
        insert acc;
        
        Opportunity opp = TestDataFactory.createOpp(acc.id);
        opp.StageName                 = 'Application Sent';
        opp.CloseDate                 = Date.today();
        insert opp;
        
        Master_Factor__c mas = TestDataFactory.createMasterfactor('Test Master Factor','Geo');
        insert mas;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        Geo_Factor__c geo = TestDataFactory.createGeoFactor(mas.id,county.Id);
        insert geo;
        
        Policy__c pol                 = TestDataFactory.createPolicy(acc.Id,opp.id,geo.id,'Policy');
        pol.Status__c                 = 'Bound';
        insert pol;
        
        Id ClaimRecordTypeId  = Schema.SObjectType.Note__c.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Claims'];
        
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo121@r1a2n3domdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo121@r1a2n3domdemodomain.com');
        insert u1;
        
        Note__c objNote = TestDataFactory.createNoteForAccount(acc.Id,'Close');
        objNote.RecordTypeId = ClaimRecordTypeId;
        objNote.Policy__c = pol.Id;
        objNote.Status__c = 'Pending';
        objNote.Due_Date__c = System.today();
        objNote.Create_Task__c = true;
        objNote.Task_Owner__c = u1.Id;
        insert objNote;
        
        objNote.Cloned_Task_Id__c = '';
        update objNote;
        
        objNote.Due_Date__c = date.today().addDays(6);
        update objNote;
        
        objNote.Due_Date__c = date.today().addDays(6);
        delete objNote;
        
         Note__c objNote2 = TestDataFactory.createNoteForAccount(acc.Id,'Close');
        objNote2.RecordTypeId = ClaimRecordTypeId;
       // objNote.Policy__c = pol.Id;
        objNote2.Account__c=acc.id;
        objNote2.Status__c = 'Pending';
        objNote2.Due_Date__c = System.today();
        objNote2.Create_Task__c = true;
        objNote2.Task_Owner__c = u1.Id;
        insert objNote2;
        
        List<Note__c> newList = new List<Note__c>();
        newList.add(objNote2);
        Map<id,Note__c> newMap= new Map<id,Note__c>();
        newMap.put(objNote2.id, objNote2);
        NoteTriggerHandler.onAfterInsert(newList, newMap);
        
        Test.stopTest();

    }
}