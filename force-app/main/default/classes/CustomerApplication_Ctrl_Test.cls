@isTest
public class CustomerApplication_Ctrl_Test {
    
    @isTest static void testMethod1() {
        
        Account acc = TestDataFactory.createAccounts('Bucket Account');
        acc.BillingState = 'Ohio';
        acc.BillingCountry = 'US';
        insert acc;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'ISBAMIC-Claim-Supplemental';
        cv.VersionData = blob.valueOf('Test');
        cv.PathOnClient = 'test.pdf';
        insert cv;
        
        Customer_Application__c objCustomerApp = new Customer_Application__c();
        objCustomerApp.Is_the_firm_currently_insured__c = 'No';
        insert objCustomerApp; 
        
        Customer_Application_Lawyer__c objCustomerappLay = TestDataFactory.createAppLawyer(objCustomerApp.id);
        insert objCustomerappLay;
        
        Master_Factor__c objMasterFactor = TestDataFactory.createMasterfactor('Test Master Factor','AOP');
        insert objMasterFactor;
        
        Master_Factor__c objMasterFactor1 = TestDataFactory.createMasterfactor('Coverage','Coverage');
        insert objMasterFactor1;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        AOP_Factor__c ObjAOP = TestDataFactory.createAopFactor(objMasterFactor.id);
        ObjAOP.AOP_Mod__c = 100;
        insert ObjAOP;
        
        ILF_Coverage_Factor__c objILFcoverage =  TestDataFactory.createCoveragefactor(objMasterFactor1.id);
        insert objILFcoverage;
        
        Deductible_Factor__c deductibleFactor = TestDataFactory.createDeductiblefactor(objMasterFactor1.Id);
        insert deductibleFactor;
        
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
        opp.StageName   = 'Application Sent';
        insert opp;
        
         Account acc1 = TestDataFactory.createAccounts(Label.Online_NBA_Account);
        insert acc1;
        
        Policy__c pol1 = TestDataFactory.createPolicy(acc1.id,opp.id,null,'Policy');
        //pol.Status__c = 'Accepted';
        pol1.Account__c = acc1.Id;
        pol1.Limit__c = objILFcoverage.Id;
        pol1.Deductible_ID__c = deductibleFactor.Id;
        pol1.Firm_Mod__c = 1;
        pol1.Base_Amount__c = 1000000;
        pol1.Premium__c = 150;
        pol1.Total_5x5__c=1;
        pol1.Total_10x10__c=1;
        insert pol1;
        
        /*      
UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
insert r; 

User u = new User(
ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
LastName = 'Customer_Application_Creation_User_Full_Name',
Email = 'puser000@amamama.com',
Username = 'puser000@amamama.com' + System.currentTimeMillis(),
CompanyName = 'TEST',
Title = 'title',
Alias = 'alias',
TimeZoneSidKey = 'America/Los_Angeles',
EmailEncodingKey = 'UTF-8',
LanguageLocaleKey = 'en_US',
LocaleSidKey = 'en_US'
UserRoleId = r.Id
); 

EmailTemplate validEmailTemplate = new EmailTemplate();
validEmailTemplate.isActive = true;
validEmailTemplate.Name = 'Online_NBA_Creation_Notification';
validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
validEmailTemplate.TemplateType = 'text';
validEmailTemplate.FolderId = UserInfo.getUserId();

insert validEmailTemplate; 
*/     
        Test.startTest();
        
        CustomerApplication_Ctrl CustApp = new CustomerApplication_Ctrl();
        CustApp.applicationCreated = false;
        CustApp.getCounty();
        //CustApp.application = new Customer_Application__c();
        CustApp.application.Would_you_like_to_receive_a_link_to_this__c = false;
        //CustApp.nextStage();
        CustApp.currentStage ='Firm Information';
        CustApp.nextStage();
        CustApp.currentStage ='Lawyer Information'; 
        CustApp.nextStage();
        CustApp.currentStage ='Prior Claims';
        CustApp.nextStage();
        CustApp.currentStage ='Prior Insurance';
        CustApp.nextStage();
        CustApp.currentStage ='Area Of Practice';
        CustApp.nextStage();
        CustApp.currentStage ='Liability and Deductible';
        //CustApp.nextStage();
        CustApp.selectedDeductibles = deductibleFactor.Id;
        CustApp.selectedLimits = objILFcoverage.id;
        CustApp.nextStage();
        CustApp.currentStage ='Lawyer Information';
        CustApp.previousStage();
        CustApp.currentStage ='Lawyer Information';
        CustApp.previousStage();
        CustApp.currentStage ='Prior Claims';
        CustApp.previousStage();
        CustApp.currentStage ='Prior Insurance';
        CustApp.previousStage();
        CustApp.currentStage ='Area Of Practice';
        CustApp.previousStage();
        CustApp.currentStage ='Liability and Deductible';
        CustApp.previousStage(); 
        CustApp.addLawyerRows();
        CustApp.removeLawyerRow();
        CustApp.addRowQuote();
        CustApp.removeRowQuote();
        CustApp.updateRadioValues();
        CustApp.radioName = 'priorClaim';
        CustApp.updateRadioValues(); 
        CustApp.radioName = 'potentialClaim';
        CustApp.updateRadioValues(); 
        CustApp.radioName = 'pendingInvestigation';
        CustApp.updateRadioValues(); 
        CustApp.radioName = ''; 
        CustApp.updateRadioValues(); 
        CustApp.radioName = 'Reprimanded'; 
        CustApp.updateRadioValues(); 
        CustApp.radioName = 'Censured'; 
        CustApp.updateRadioValues(); 
        CustApp.radioName = 'Suspended'; 
        CustApp.updateRadioValues(); 
        CustApp.radioName = 'Disbarred';
        CustApp.updateRadioValues(); 
        CustApp.radioName = 'hasRetroactiveDate';
        CustApp.updateRadioValues(); 
        CustApp.radioName = 'anyDisciplinary';
        CustApp.updateRadioValues(); 
        CustApp.radioName = 'Q_Outside_IL';
        CustApp.updateRadioValues();
        CustApp.radioName = 'Q_Conflict_of_Interest';
        CustApp.updateRadioValues();
        CustApp.radioName = 'Q_Calendaring';
        CustApp.updateRadioValues();
        CustApp.radioName = 'Q_Engagement_Letters';
        CustApp.updateRadioValues();
        CustApp.radioName = 'Q_Non_enganement_Letters';
        CustApp.updateRadioValues();
        CustApp.radioName = 'Q_Firm_Share_Cases';
        CustApp.updateRadioValues();
        CustApp.radioName = 'Q_Firm_Share_Cases_Insured';
        CustApp.updateRadioValues();
        CustApp.radioName = 'Q_Firm_Use_Agreements_Or_Engagement_Lett';
        CustApp.updateRadioValues();
        CustApp.radioName = 'Q_Firm_Notify_Clients_Terminated';
        CustApp.updateRadioValues();
        CustApp.radioName = 'Q_Firm_Review_Conflicts';
        CustApp.updateRadioValues();
        CustApp.radioName = 'Q_Firm_Evaluate_New_Clients';
        CustApp.updateRadioValues();
        CustApp.radioName = 'Q_Docket_Calendar_System';
        CustApp.updateRadioValues();
        CustApp.radioName = 'Q_Conflict_Of_Interest_System';
        CustApp.updateRadioValues();
        CustApp.radioName = 'Does_the_Firm_have_a_backup_Lawyer';
        CustApp.updateRadioValues();
        CustApp.radioName = 'currenylyInsured';
        CustApp.radioValue ='yes';
        CustApp.radioValue = 'no';
        CustApp.updateRadioValues();
        CustApp.getDesignation();
        CustApp.getItems();
        CustApp.getLimit();
        CustApp.getDeductible();
        CustApp.getLimits();
        CustApp.getDeductibles();
        CustApp.getLimitsDeductibles();
        //  CustApp.createApplication();
        // CustApp.sendEmail(); 
        
        CustApp.radioName = '{ "route": "Main St", "street_number": "123", "locality": "Springfield", "administrative_area_level_1": "IL", "subpremise": "Suite 100", "postal_code": "62704" }';
        CustApp.handleAddressChange();
        CustApp.application.Zip_Code__c = '62704';
        CustApp.handleZipCodeChange();
        
        CustApp.sendEmail();
        
        /*Customer_Application__c updatedApp = [SELECT Application_Status__c FROM Customer_Application__c WHERE Id = :objCustomerApp.Id];
        update updatedApp;
        List<Task> tasks = [SELECT Id, Subject, Description FROM Task WHERE WhatId = :objCustomerApp.Id];
        insert tasks;*/
        
        String testFileContent = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));
        String result = CustomerApplication_Ctrl.uploadFileWithCallout('TestFile.pdf', testFileContent,'', objCustomerApp.Id);
        ContentVersion insertedCV = [SELECT Id, Title, FirstPublishLocationId FROM ContentVersion WHERE Title = 'TestFile.pdf' LIMIT 1];
        
        String errorResult = CustomerApplication_Ctrl.uploadFileWithCallout('ErrorFile.pdf', testFileContent, '', null);
        
        Test.stopTest();
        
    }
    
    @isTest static void testMethod2() {
        
        Account acc = TestDataFactory.createAccounts('Bucket Account');
        acc.BillingState = 'Ohio';
        acc.BillingCountry = 'US';
        insert acc;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'ISBAMIC-Claim-Supplemental';
        cv.VersionData = blob.valueOf('Test');
        cv.PathOnClient = 'test.pdf';
        insert cv;
        
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            Phone = '123-456-7890'
        );        
        insert testContact;
        
        Customer_Application__c objCustomerApp = new Customer_Application__c();
        objCustomerApp.Is_the_firm_currently_insured__c = 'YES';
        insert objCustomerApp; 
        
        Customer_Application_Lawyer__c objCustomerappLay = TestDataFactory.createAppLawyer(objCustomerApp.id);
        insert objCustomerappLay;
        
        Master_Factor__c objMasterFactor = TestDataFactory.createMasterfactor('Test Master Factor','AOP');
        insert objMasterFactor;
        
        Master_Factor__c objMasterFactor1 = TestDataFactory.createMasterfactor('Coverage','Coverage');
        insert objMasterFactor1;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        AOP_Factor__c ObjAOP = TestDataFactory.createAopFactor(objMasterFactor.id);
        ObjAOP.AOP_Mod__c = 100;
        insert ObjAOP;
        
        ILF_Coverage_Factor__c objILFcoverage =  TestDataFactory.createCoveragefactor(objMasterFactor1.id);
        insert objILFcoverage;
        
        Deductible_Factor__c deductibleFactor = TestDataFactory.createDeductiblefactor(objMasterFactor1.Id);
        insert deductibleFactor;

        Test.startTest();
        
        CustomerApplication_Ctrl CustApp = new CustomerApplication_Ctrl();
        CustApp.applicationCreated = false;
        
        CustApp.getCounty();

        CustApp.nextStage();
        CustApp.currentStage ='Firm Information';
        CustApp.nextStage();
        CustApp.currentStage ='Lawyer Information';         
        CustApp.nextStage();
        CustApp.currentStage ='Prior Insurance';
        
        CustApp.radioName = 'currenylyInsured';
        CustApp.radioValue ='yes';
        CustApp.updateRadioValues();
        custApp.applicationId = objCustomerApp.Id;
        custApp.file = 'test';
        custApp.fileName = 'test';
        CustApp.nextStage();        
        CustApp.currentStage ='Prior Claims';
        CustApp.nextStage();
        CustApp.currentStage ='Area Of Practice';
        CustApp.nextStage();
        CustApp.currentStage ='Liability and Deductible';
        CustApp.selectedDeductibles = deductibleFactor.Id;
        CustApp.selectedLimits = objILFcoverage.id;
        
        CustApp.currentStage ='Lawyer Information';
        CustApp.previousStage();
        CustApp.currentStage ='Lawyer Information';
        CustApp.previousStage();
        CustApp.currentStage ='Prior Claims';
        CustApp.previousStage();
        CustApp.currentStage ='Prior Insurance';
        CustApp.previousStage();
        CustApp.currentStage ='Area Of Practice';
        CustApp.previousStage();
        CustApp.currentStage ='Liability and Deductible';
        CustApp.previousStage(); 
        CustApp.addLawyerRows();
        CustApp.removeLawyerRow();
        CustApp.addRowQuote();
        CustApp.removeRowQuote();
        CustApp.updateRadioValues();
        CustApp.radioName = 'priorClaim';
        CustApp.updateRadioValues(); 
        CustApp.radioName = 'potentialClaim';
        CustApp.updateRadioValues(); 
        CustApp.radioName = 'pendingInvestigation';
        CustApp.updateRadioValues(); 
        CustApp.radioName = ''; 
        CustApp.updateRadioValues(); 
        CustApp.radioName = 'Reprimanded'; 
        CustApp.updateRadioValues(); 
        CustApp.radioName = 'Censured'; 
        CustApp.updateRadioValues(); 
        CustApp.radioName = 'Suspended'; 
        CustApp.updateRadioValues(); 
        CustApp.radioName = 'Disbarred';
        CustApp.updateRadioValues(); 
        CustApp.radioName = 'hasRetroactiveDate';
        CustApp.updateRadioValues(); 
        CustApp.radioName = 'anyDisciplinary';
        CustApp.updateRadioValues(); 
        CustApp.getNBASource();
        CustApp.getDesignation();
        CustApp.getItems();
        CustApp.getLimit();
        CustApp.getDeductible();
        CustApp.getLimits();
        CustApp.getDeductibles();
        CustApp.getLimitsDeductibles();
        CustApp.sendEmailRenewal();
        //  CustApp.createApplication();
        // CustApp.sendEmail(); 
        try{
            CustApp.showQuotesApex();
        }
        catch(Exception e){
            
        }
        Test.stopTest();
        
    }
    
    @isTEST static void testMethod3() {
        
        Account acc = TestDataFactory.createAccounts('Bucket Account');
        acc.BillingState = 'Ohio';
        acc.BillingCountry = 'US';
        insert acc;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'ISBAMIC-Claim-Supplemental';
        cv.VersionData = blob.valueOf('Test');
        cv.PathOnClient = 'test.pdf';
        insert cv;
        
        Customer_Application__c objCustomerApp = new Customer_Application__c();
        objCustomerApp.Is_the_firm_currently_insured__c = 'YES';
        objCustomerApp.Prior_Insurance_Completed__c = true;
        objCustomerApp.Prior_Claim_Completed__c = true;
        objCustomerApp.Lawyer_Information_Completed__c = true;
            
        insert objCustomerApp; 
        
        Customer_Application_Lawyer__c objCustomerappLay = TestDataFactory.createAppLawyer(objCustomerApp.id);
        insert objCustomerappLay;
        
        Master_Factor__c objMasterFactor = TestDataFactory.createMasterfactor('Test Master Factor','AOP');
        insert objMasterFactor;
        
        Master_Factor__c objMasterFactor1 = TestDataFactory.createMasterfactor('Coverage','Coverage');
        insert objMasterFactor1;
        
        County__c county = TestDataFactory.createCounty();
        insert county ;
        
        AOP_Factor__c ObjAOP = TestDataFactory.createAopFactor(objMasterFactor.id);
        ObjAOP.AOP_Mod__c = 100;
        insert ObjAOP;
        
        ILF_Coverage_Factor__c objILFcoverage =  TestDataFactory.createCoveragefactor(objMasterFactor1.id);
        insert objILFcoverage;
        
        Deductible_Factor__c deductibleFactor = TestDataFactory.createDeductiblefactor(objMasterFactor1.Id);
        insert deductibleFactor;
        
        Opportunity opp               = TestDataFactory.createOpp(acc.id);
        opp.StageName   = 'Application Sent';
        insert opp;
        
         Account acc1 = TestDataFactory.createAccounts(Label.Online_NBA_Account);
        insert acc1;
        
        Policy__c pol1 = TestDataFactory.createPolicy(acc1.id,opp.id,null,'Policy');
        //pol.Status__c = 'Accepted';
        pol1.Account__c = acc1.Id;
        pol1.Limit__c = objILFcoverage.Id;
        pol1.Deductible_ID__c = deductibleFactor.Id;
        pol1.Firm_Mod__c = 1;
        pol1.Base_Amount__c = 1000000;
        pol1.Premium__c = 150;
        pol1.Total_5x5__c=1;
        pol1.Total_10x10__c=1;
        insert pol1;

        Policy_Quote__c PQ = new Policy_Quote__c();
        PQ.Deductible__c = deductibleFactor.id;
        PQ.Coverage__c = objILFcoverage.id;
        PQ.Customer_Application__c = objCustomerApp.id;
        PQ.Policy__c = pol1.id;
        insert PQ;
        
        
        
        CustomerApplication_Ctrl.uploadFileWithCallout('Test', 'Test','', objCustomerApp.id);
        CustomerApplication_Ctrl.verifyEffectiveDate('12/27/2009','12/27/2009',objCustomerApp.id);
        CustomerApplication_Ctrl.verifyEffectiveDate('12/27/2009','12/26/2009',objCustomerApp.id);
        PageReference pageRef = Page.CustomerApplicationPage;
        Test.setCurrentPage(pageRef);
        String encrypted = PaymentGatewayClass.processEncryption(objCustomerApp.Id,Label.Encryption_Key_Payment_Id);
        pageRef.getParameters().put('id',encrypted);
        CustomerApplication_Ctrl CustApp = new CustomerApplication_Ctrl();
        CustApp.underwriterName= '';
        CustApp.underwriterEmail= '';
        CustApp.underwriterPhone= '';
        CustomerApplication_Ctrl.aopWrapper aopwrp = new CustomerApplication_Ctrl.aopWrapper();
        aopwrp.factor = ObjAOP;
        aopwrp.percentage = 50;
        
        CustomerApplication_Ctrl.aopComboWrapper aopCombo = new CustomerApplication_Ctrl.aopComboWrapper();
        aopCombo.obj1 = aopwrp;
        aopCombo.obj2 = aopwrp;
        
        CustomerApplication_Ctrl.optionWrapper ow = new CustomerApplication_Ctrl.optionWrapper();
        ow.label = '';
        ow.value = '';
        
    }
}