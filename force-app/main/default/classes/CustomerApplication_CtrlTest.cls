@isTest
private class CustomerApplication_CtrlTest {
    @isTest static void TestMethod2() {
        Test.startTest();
        Account acc = new Account();
        acc.Name = 'Bucket Account';
        acc.BillingState = 'Ohio';
        acc.BillingCountry = 'US';
        insert acc;
        
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'ISBAMIC-Claim-Supplemental',
            PathOnClient = 'ISBAMIC-Claim-Supplemental.txt',
            VersionData = Blob.valueOf('Test'),
            IsMajorVersion = true
        );
        insert testContentVersion;
        
        Customer_Application__c objCustomerApp = new Customer_Application__c();
        objCustomerApp.Is_the_firm_currently_insured__c = 'No';
        insert objCustomerApp; 
        
        Customer_Application_Lawyer__c objCustomerappLay = new Customer_Application_Lawyer__c();
        objCustomerappLay.Customer_Application__c = objCustomerApp.id;
        objCustomerappLay.ARDC_Number__c = 'test22';
        objCustomerappLay.Average_Number_of_Hours_Worked__c = 10;
        objCustomerappLay.Name = 'testing';
        objCustomerappLay.Date_of_Hire__c = system.today();
        objCustomerappLay.Designation__c = 'Associate or Employed Lawyer';
        objCustomerappLay.ISBA_Number__c = 'tstt1';   
        insert objCustomerappLay;
        
        Master_Factor__c objMasterFactor = new Master_Factor__c();
        objMasterFactor.Default__c = true;
        objMasterFactor.Factor_Type__c ='AOP';
        objMasterFactor.From_Date__c = system.today();
        objMasterFactor.To_Date__c =	system.today()+1;
        insert objMasterFactor;
        
        Master_Factor__c objMasterFactor1 = new Master_Factor__c();
        objMasterFactor1.Default__c = true;
        objMasterFactor1.Factor_Type__c ='Coverage';
        objMasterFactor1.From_Date__c = system.today();
        objMasterFactor1.To_Date__c =	system.today()+1;
        insert objMasterFactor1;
        
        County__c county              = new County__c();
        county.Name                   = 'Test County';
        county.Region__c              = '5';
        insert county;
        
        AOP_Factor__c ObjAOP = new AOP_Factor__c();
        ObjAOP.Master_Factor__c = objMasterFactor.id;
        insert ObjAOP;
        
        ILF_Coverage_Factor__c objILFcoverage = new ILF_Coverage_Factor__c();
        objILFcoverage.OldLimit__c = false;
        objILFcoverage.Master_Factor__c = objMasterFactor1.Id;
        objILFcoverage.Full_Coverage__c = 1000;
        objILFcoverage.Lowest_Coverage__c = true;
        objILFcoverage.Coverage_Max_Per_Claim__c = 100;
        objILFcoverage.Factor_Value__c = 10;
        insert objILFcoverage;
        
        Deductible_Factor__c deductibleFactor = new Deductible_Factor__c();
        deductibleFactor.Name = '1000/10000';
        deductibleFactor.Master_Factor__c  =  objMasterFactor1.Id;
        deductibleFactor.Deductible_Amount__c = 1000 ;
        deductibleFactor.Factor_Value__c = 1 ;
        insert deductibleFactor;
        
        CustomerApplication_Ctrl CustApp = new CustomerApplication_Ctrl();
        CustApp.applicationCreated = false;
        CustApp.getCounty();
        CustApp.nextStage();
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
        Test.stopTest();
        
    }
    
}