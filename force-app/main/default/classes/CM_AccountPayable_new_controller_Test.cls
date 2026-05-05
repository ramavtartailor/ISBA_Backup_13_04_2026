@isTest
private class CM_AccountPayable_new_controller_Test {
    
    @testSetup static void setup() {
        
        Account acc = TestDataFactory.createAccounts('Bucket Account');
        acc.AccountNumber = '123456';
        acc.Vendor_Account__c = true;
        acc.BillingStreet = 'PA';
        acc.BillingCity = 'Allentown';
        acc.BillingPostalCode = '123456';
        acc.BillingState = 'IL';
        acc.BillingCountry = 'US';
        acc.ShippingStreet = 'PA';
        acc.ShippingCity = 'Allentown';
        acc.ShippingState = 'IL';
        acc.ShippingPostalCode = '123456';
        acc.ShippingCountry = 'US';
        insert acc;
        
        Contact con = TestDataFactory.createContact('Contact',acc.id);
        con.FirstName = 'Test';
        con.LastName = 'Test';
        con.AccountId = acc.Id;
        con.Type__c   = 'Lawyer';
        con.Contact_Role__c = 'P';
        con.Title = 'Test';
        con.Email = 'Test@mail.com';
        con.Phone = 'Test';
        con.ISBA__c = 'Test';
        con.Account_Number__c = 'Test';
        con.Middle_Name__c = 'Test';
        con.Primary_Contact__c = True;
        con.ARDC_Number__c = '1234';
        con.ARDC__c = 'Test';
        con.Birthdate = System.today();
        con.Phone_Ext__c = 'test';
        con.Gender__c = 'test';
        con.MailingStreet = 'test';
        con.MailingCity = 'test';
        con.MailingState = 'test';
        con.MailingPostalCode = 'test';
        con.Request_No_Contact__c = 12345566;
        con.Bar_Status__c = 'test';
        con.Bar_Membership_Geo__c = 'test';
        con.Specialty_Bar_Association__c = 'test';
        con.Full_licensed_name_ARDC__c = 'test';
        con.ARDC_Insurance_Report__c = 'test';
        con.Authorized_To_Practice__c = 'test';
        con.Do_not_mail__c = True;
        con.DoNotCall = True;
        con.AcctSeed__X1099_Vendor__c = True;
        con.AcctSeed__Default_1099_Box__c = 'Test';
        con.MailingCountry = 'Test';
        con.Bar_entry_date__c = system.today();
        con.Firm_ID__c = 'Test';
        con.Prior_Acts_Date__c = system.today();
        con.Converted_from_lead__c = system.today();
        con.Best_times_to_reach__c = 'Test';
        con.Contacted_us__c = system.today();
        con.Policy_Expiration_Date__c = System.today();
        con.Paid_Through__c = System.today();
        con.ISBA_Paid_through__c = System.today();
        con.Last_telemarketing_list_submitted__c = System.today();
        con.Last_emailed__c = System.today();
        con.Completed_form__c = System.today();
        con.Lead_returned_by_QCSS__c = System.today();
        con.QCSS_Date__c = System.today();
        con.Do_Not_Email__c = True;
        con.Category__c = 'Test';
        con.Admitted_in_Illinois__c = System.today();
        con.Joined_Firm__c = System.today();
        con.Description = 'Test';
        con.AOP_1__c = 'Test';
        con.AOP_2__c = 'Test';
        con.Court__c = 123456;
        con.Address_Purpose__c = 'Test';
        con.Act_On_Lead_Score__c = 123456;
        con.Lead_Week__c = 'Week1';
        con.Suffix__c = 'Test';
        
        insert con;
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        AccountContactJunction__c acj1 = TestDataFactory.createAccConJunc(acc.Id, con.id);
        insert acj1;
        /*    
AccountContactRelation acr = TestDataFactory.createAccContRelation(con.id, acc.id);        
insert acr;
*/   
        List<AcctSeed__GL_Account__c> glAccounts = TestDataFactory.createGLAccounts();        
        insert glAccounts;
        
        List<AcctSeed__Billing_Format__c> billingFormats = TestDataFactory.createBillingFormats();        
        insert billingFormats ;
        
        List<AcctSeed__Ledger__c> ledgers = TestDataFactory.createLedgers(glAccounts[0].id,billingFormats[0].id,billingFormats[1].id,billingFormats[2].id,billingFormats[3].id,billingFormats[4].id);
        insert ledgers;
        
        AcctSeed__Accounting_Settings__c settings = TestDataFactory.createAccountsetting(ledgers[0].id,glAccounts[0].Id,glAccounts[1].Id,glAccounts[2].Id,glAccounts[3].Id,glAccounts[4].Id,glAccounts[5].Id,glAccounts[6].Id,billingFormats[0].Id);
        insert settings;
        
        AcctSeed__Accounting_Period__c periods = TestDataFactory.createAcctPeriod();
        insert periods;
        
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
        
        Master_Factor__c masterFactor = TestDataFactory.createMasterfactor('Test Master Factor0','Step Rate');
        insert masterFactor;
        
        Step_Rate_Factor__c stepRateFactor = TestDataFactory.createStepFactor(masterFactor.Id);
        insert stepRateFactor;
        
        Master_Factor__c masterFactor1 = TestDataFactory.createMasterfactor('Test Master Factor1','Base Value');
        insert masterFactor1;
        
        Base_Factor__c baseFactor = TestDataFactory.createBaseFactor(masterFactor1.Id);
        insert baseFactor;
        
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
        
        Id devRecordTypeId = Schema.SObjectType.Policy_Endorsement__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('','','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Policy_Endorsement__c objPolEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        insert objPolEndorse;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Policy_AOP__c aop = TestDataFactory.createPolicyAop(aopFactor.Id,acctivePolicy.id);
        insert aop;
        
    }
    
    @isTest static void testMethod1() {
        
        Test.startTest();
        
        List<Account> acc = [SELECT Id FROM Account];
        List<Policy__c> policies = [SELECT Id,Account__c,Account__r.name FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id,NAME FROM AcctSeed__GL_Account__c];
        List<AcctSeed__Ledger__c> ledgers = [SELECT Id FROM AcctSeed__Ledger__c];
        List<AcctSeed__Accounting_Period__c> periods = [SELECT Id,NAME FROM AcctSeed__Accounting_Period__c];
        
        Policy__c  policy = policies[0];
        
        AccountContactJunction__c acj2 = TestDataFactory.createAccConJunc(acc[0].id, conList[0].id);
        acj2.Account__c = policies[0].Account__C;
        acj2.Contact__c = conList[0].Id;
        insert acj2;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(acc[0].id, policy.Id, acj2.Id);
        law.Policy__c = policy.Id;
        law.Active__c = true;
        law.Account__c = policy.Account__c;
        law.Prior_Act_Date__c = date.today();
        law.Lawyer__c = acj2.Id;
        insert law; 
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        calimset.Deductible_LAE_Applied_After__c =10;
        insert  calimset;
        
        Policy_Claim__c claim = TestDataFactory.createPolicyClaim(policy.Id, law.Id);
        claim.Policy__c = policy.Id;
        claim.File_Type__c = 'Claim';
        claim.Lawyer__c = law.Id;
        claim.Report_Date__c = date.today();
        claim.Occur_Date__c = date.today().adddays(-2);
        claim.Claim_Made_Date__c = date.today();
        claim.State__c = 'test';
        claim.Payable_Reference_Running_Number__c = null;
        insert claim;
        
        Policy_Claim_Detail__c claimDetail = TestDataFactory.createPolClaimDetail(acc[0].Id,'Claim Payment', claim.Id,'LAE Payment');
        claimDetail.Policy_Claim__c = claim.Id;
        claimDetail.Date__c = system.today();
        claimDetail.Vendor__c = acc[0].Id;
        insert claimDetail;
        
        AcctSeed__Account_Payable__c payable = TestDataFactory.createAccountPayable(periods[0].Id, ledgers[0].id, acc[0].Id, claim.Id);
        insert  payable;
        
        PageReference pageAcc = Page.AccountPayable_New;
        pageAcc.getParameters().put('obj', 'account');
        pageAcc.getParameters().put('accountName', 'test');
        pageAcc.getParameters().put('accountId', policy.Account__C);
        System.Test.setCurrentPage(pageAcc);    
        
        PageReference pageRef = Page.AccountPayable_New;
        pageRef.getParameters().put('obj', 'claim');
        pageRef.getParameters().put('claimName', 'test');
        pageRef.getParameters().put('accountId', policy.Account__C);
        pageRef.getParameters().put('claimId', claim.Id);
        pageRef.getParameters().put('policyId', policy.Id);
        system.Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(payable);
        CM_AccountPayable_new_controller Ctrl = new CM_AccountPayable_new_controller(sc);
        List<sObject> options = CM_AccountPayable_new_controller.getLookupRecord('Test','Account');
        Ctrl.getVendorAccountOptions();
        Ctrl.onVendorSelect();
        Ctrl.accPayableObj.AcctSeed__Vendor__c= policies[0].Account__c;
        
        Ctrl.onVendorSelect();
        Ctrl.addAccPayNewLine();
        Ctrl.indexOfLineItemToBeRemoved='1';
        Ctrl.removeLineItemRow();
        Ctrl.accPayableObj.AcctSeed__Accounting_Period__c = periods[0].Id;
        Ctrl.accPayableObj.Type__c = 'LAE Pay';
        
        for(CM_AccountPayable_new_controller.HIC_AccountPayableLineItemWrapper obj: Ctrl.accPayLineWrapList){
            obj.accPayabaleObj.AcctSeed__Expense_GL_Account__c = glAccounts[0].Id;
            obj.accPayabaleObj.AcctSeed__Amount__c = 100;
        }
        
        Ctrl.onSaveClick();
        Ctrl.accPayableObj.Type__c = 'Loss Pay';
        Ctrl.accPayableObj.Type__c = 'Claim Coverage - ARDC';
        Ctrl.accPayableObj.Type__c = 'Unallocated LAE Payment';
        Ctrl.onSaveNewClick();
        Ctrl.onUpdateClick();
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod2() {
        
        Test.startTest();
        
        List<Account> acc = [SELECT Id FROM Account];
        List<Policy__c> policies = [SELECT Id,Account__c,Account__r.name FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id,NAME FROM AcctSeed__GL_Account__c];
        List<AcctSeed__Ledger__c> ledgers = [SELECT Id FROM AcctSeed__Ledger__c];
        List<AcctSeed__Accounting_Period__c> period = [SELECT Id,NAME FROM AcctSeed__Accounting_Period__c];
        
        Policy__c  policy = policies[0];
        
        AccountContactJunction__c acj2 = TestDataFactory.createAccConJunc(acc[0].id, conList[0].id);
        acj2.Account__c = policies[0].Account__C;
        acj2.Contact__c = conList[0].Id;
        insert acj2;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(acc[0].id, policy.Id, acj2.Id);
        law.Policy__c = policy.Id;
        law.Active__c = true;
        law.Account__c = policy.Account__c;
        law.Prior_Act_Date__c = date.today();
        law.Lawyer__c = acj2.Id;
        insert law; 
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        calimset.Deductible_LAE_Applied_After__c =10;
        insert  calimset;
        
        Policy_Claim__c claim = TestDataFactory.createPolicyClaim(policy.Id, law.Id);
        claim.Policy__c = policy.Id;
        claim.File_Type__c = 'Claim';
        claim.Lawyer__c = law.Id;
        claim.Report_Date__c = date.today();
        claim.Occur_Date__c = date.today().adddays(-2);
        claim.Claim_Made_Date__c = date.today();
        claim.State__c = 'test';
        insert claim;
        
        Policy_Claim_Detail__c claimDetail = TestDataFactory.createPolClaimDetail(acc[0].Id,'Claim Payment', claim.Id,'LAE Payment');
        claimDetail.Policy_Claim__c = claim.Id;
        claimDetail.Date__c = system.today();
        claimDetail.Vendor__c = acc[0].Id;
        insert claimDetail;
        
        AcctSeed__Account_Payable__c payable = new AcctSeed__Account_Payable__c();
        
        PageReference pageRef = Page.AccountPayable_New;
        pageRef.getParameters().put('obj', 'account');
        pageRef.getParameters().put('accountName', 'test');
        pageRef.getParameters().put('from', 'claimSearch');
        pageRef.getParameters().put('accountId', policy.Account__c);
        System.Test.setCurrentPage(pageRef);    
        
        ApexPages.StandardController sc = new ApexPages.StandardController(payable);
        CM_AccountPayable_new_controller Ctrl = new CM_AccountPayable_new_controller(sc);
        Ctrl.getVendorAccountOptions();
        Ctrl.onVendorSelect();
        Ctrl.accPayableObj.AcctSeed__Vendor__c = null;
        
        Ctrl.onVendorSelect();
        Ctrl.addAccPayNewLine();
        Ctrl.indexOfLineItemToBeRemoved='1';
        Ctrl.removeLineItemRow();
        Ctrl.accPayableObj.AcctSeed__Accounting_Period__c = period[0].Id;
        Ctrl.accPayableObj.Type__c = 'LAE Pay';
        
        for(CM_AccountPayable_new_controller.HIC_AccountPayableLineItemWrapper obj: Ctrl.accPayLineWrapList){
            obj.accPayabaleObj.AcctSeed__Expense_GL_Account__c = glAccounts[0].Id;
            obj.accPayabaleObj.AcctSeed__Amount__c =-10;
        }
        
        Ctrl.onSaveClick();
        Ctrl.accPayableObj.Firm__c = claim.Policy__r.Account__c;
        
        Ctrl.accPayableObj.Type__c = 'Loss Pay';
        Ctrl.accPayableObj.Type__c = 'Claim Coverage - ARDC';
        Ctrl.accPayableObj.Type__c = 'Unallocated LAE Payment';
        Ctrl.onSaveNewClick();
        Ctrl.onUpdateClick();
        
        Test.stopTest();
        
    }
    
    
     @isTest static void testMethod_p() {
        
        Test.startTest();
        
        List<Account> acc = [SELECT Id FROM Account];
        List<Policy__c> policies = [SELECT Id,Account__c,Account__r.name FROM Policy__c];
        List<Contact> conList = [SELECT Id FROM Contact];
        List<AcctSeed__GL_Account__c> glAccounts = [SELECT Id,NAME FROM AcctSeed__GL_Account__c];
        List<AcctSeed__Ledger__c> ledgers = [SELECT Id FROM AcctSeed__Ledger__c];
        List<AcctSeed__Accounting_Period__c> periods = [SELECT Id,NAME FROM AcctSeed__Accounting_Period__c];
        
        Policy__c  policy = policies[0];
        
        AccountContactJunction__c acj2 = TestDataFactory.createAccConJunc(acc[0].id, conList[0].id);
        acj2.Account__c = policies[0].Account__C;
        acj2.Contact__c = conList[0].Id;
        insert acj2;
        
        Policy_Lawyer__c law = TestDataFactory.createPolicyLawyer(acc[0].id, policy.Id, acj2.Id);
        law.Policy__c = policy.Id;
        law.Active__c = true;
        law.Account__c = policy.Account__c;
        law.Prior_Act_Date__c = date.today();
        law.Lawyer__c = acj2.Id;
        insert law; 
        
        Claim_Setting__c calimset = TestDataFactory.createClaimSetting();
        calimset.Deductible_LAE_Applied_After__c =10;
        insert  calimset;
        
        Policy_Claim__c claim = TestDataFactory.createPolicyClaim(policy.Id, law.Id);
        claim.Policy__c = policy.Id;
        claim.File_Type__c = 'Claim';
        claim.Lawyer__c = law.Id;
        claim.Report_Date__c = date.today();
        claim.Occur_Date__c = date.today().adddays(-2);
        claim.Claim_Made_Date__c = date.today();
        claim.State__c = 'test';
        claim.Payable_Reference_Running_Number__c = null;
        insert claim;
        
        Policy_Claim_Detail__c claimDetail = TestDataFactory.createPolClaimDetail(acc[0].Id,'Claim Payment', claim.Id,'LAE Payment');
        claimDetail.Policy_Claim__c = claim.Id;
        claimDetail.Date__c = system.today();
        claimDetail.Vendor__c = acc[0].Id;
        insert claimDetail;
        
        AcctSeed__Account_Payable__c payable = TestDataFactory.createAccountPayable(periods[0].Id, ledgers[0].id, acc[0].Id, claim.Id);
        insert  payable;
        
        PageReference pageAcc = Page.AccountPayable_New;
        pageAcc.getParameters().put('obj', 'account');
        pageAcc.getParameters().put('accountName', 'test');
        pageAcc.getParameters().put('accountId', policy.Account__C);
        System.Test.setCurrentPage(pageAcc);    
        
        PageReference pageRef = Page.AccountPayable_New;
        pageRef.getParameters().put('obj', 'claim');
        pageRef.getParameters().put('claimName', 'test');
        pageRef.getParameters().put('accountId', policy.Account__C);
        pageRef.getParameters().put('claimId', claim.Id);
        pageRef.getParameters().put('policyId', policy.Id);
        system.Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(payable);
        CM_AccountPayable_new_controller Ctrl = new CM_AccountPayable_new_controller(sc);
        List<sObject> options = CM_AccountPayable_new_controller.getLookupRecord('Test','Account');
        Ctrl.getVendorAccountOptions();
        Ctrl.onVendorSelect();
        Ctrl.accPayableObj.AcctSeed__Vendor__c= policies[0].Account__c;
        Ctrl.contactObj=conList[0];
        Ctrl.selectedVendorId ='test';
        Ctrl.onVendorSelect();
        Ctrl.addAccPayNewLine();
        Ctrl.indexOfLineItemToBeRemoved='1';
        Ctrl.removeLineItemRow();
        Ctrl.accPayableObj.AcctSeed__Accounting_Period__c = periods[0].Id;
        Ctrl.accPayableObj.Type__c = 'Loss Pay';
        
        for(CM_AccountPayable_new_controller.HIC_AccountPayableLineItemWrapper obj: Ctrl.accPayLineWrapList){
            obj.accPayabaleObj.AcctSeed__Expense_GL_Account__c = glAccounts[0].Id;
            obj.accPayabaleObj.AcctSeed__Amount__c =-10;
            
        }
        
        Ctrl.onSaveClick();
        Ctrl.accPayableObj.Type__c = 'Loss Pay';
        Ctrl.accPayableObj.Type__c = 'Claim Coverage - ARDC';
        Ctrl.accPayableObj.Type__c = 'Unallocated LAE Payment';
        Ctrl.onSaveNewClick();
        Ctrl.onUpdateClick();
        
        Test.stopTest();
        
    }
    
}