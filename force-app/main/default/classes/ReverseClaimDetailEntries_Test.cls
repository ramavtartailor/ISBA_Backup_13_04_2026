@isTest
public class ReverseClaimDetailEntries_Test {
    
    
    @testSetup 
    static void testData(){
        Test.startTest();
        Account acc                   = TestDataFactory.createAccounts('Bucket Account');
        acc.AccountNumber             = '123456';
        acc.Vendor_Account__c         = true;
        insert acc;
        
        Contact con                   = TestDataFactory.createContact('Test Contact',acc.id);
        con.FirstName                 = 'Test';
        con.Type__c                   = 'Lawyer';
        con.Contact_Role__c           = 'P';
        con.AccountId                 = acc.Id;
        insert con;
        
        AccountContactJunction__c acj = TestDataFactory.createAccConJunc(acc.id, con.id);
        acj.Name                      = 'Test Name';
        insert acj;
        
        AcctSeed__Accounting_Period__c accPeriod = TestDataFactory.createAcctPeriod();
        accPeriod.AcctSeed__Status__c = 'Open';
        accPeriod.AcctSeed__Start_Date__c = System.Date.today().toStartOfMonth();
        accPeriod.AcctSeed__End_Date__c = accPeriod.AcctSeed__Start_Date__c.addMonths(1).addDays(-1);
        Insert accPeriod;
        
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
        
        for (RecordType rt : [SELECT DeveloperName,Id FROM RecordType WHERE SobjectType = 'Master_Factor__c' limit 100]) {
            mapRecordTypes.put(rt.DeveloperName,rt.Id);
        }
        
        Master_Factor__c MasterFactorCoverage = TestDataFactory.createMasterfactor('Coverage','Coverage');
        MasterFactorCoverage.RecordTypeId = mapRecordTypes.get('Limit_Coverage');
        insert MasterFactorCoverage;
        
        ILF_Coverage_Factor__c FactorCoverage = TestDataFactory.createCoverageFactor(MasterFactorCoverage.Id);
        FactorCoverage.Percentage_5X5_Step_0__c =3;
        FactorCoverage.Percentage_5X5_Step_1__c=4;
        FactorCoverage.Percentage_5X5_Step_2__c=5;
        FactorCoverage.Percentage_5X5_Step_3__c=6;
        FactorCoverage.Percentage_5X5_Step_4__c=8;
        FactorCoverage.Premium_Rate_5X5__c = 33;
        FactorCoverage.Is_5X5_Coverage__c = true;
        insert FactorCoverage;
        
        Master_Factor__c mas12       = TestDataFactory.createMasterfactor('Test Master Factor','Deductible');
        insert mas12;
        
        Deductible_Factor__c DedFac = TestDataFactory.createDeductiblefactor(mas12.Id);
        Insert DedFac; 
        
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
        
        Endorsement__c endorse = TestDataFactory.createEndorsement('IL 152','Functional','General');
        insert endorse;
        
        Endorsement_Version__c endorseVersion = TestDataFactory.createEndorsementVersion(endorse.Id);
        insert endorseVersion;
        
        Endorsement_Version__c endorseVersion2 = TestDataFactory.createEndorsementVersion(endorse.Id);
        endorseVersion2.Endorsement_Version_Number__c='2';
        insert endorseVersion2;
        
        Policy_Endorsement__c poicyEndorse = TestDataFactory.createPolicyEndorsement(acc.id,acctivePolicy.id,'General');
        insert poicyEndorse;
        
        AOP_Factor__c aopFactor = TestDataFactory.createAopFactor(masterFactorNew.Id);
        insert aopFactor;
        
        Claim_Setting__c claimSet = TestDataFactory.createClaimSetting();
        insert claimSet;
        
        Policy_Lawyer__c polLawyerObj = TestDataFactory.createPolicyLawyer(acc.Id,acctivePolicy.Id,acj.Id);
        insert polLawyerObj;
        
        Policy_Claim__c  polClaimObj = TestDataFactory.createPolicyClaim(acctivePolicy.Id,polLawyerObj.Id);
        insert polClaimObj;
        polClaimObj.Reserve_LAE__c = null;
      //  update polClaimObj;
        
        List<Policy_Claim_Detail__c> PCDList =  new List<Policy_Claim_Detail__c>();
        
        Policy_Claim_Detail__c polClaimDetailObj = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Claim Payment', polClaimObj.Id,'Loss Payment'); 
        polClaimDetailObj.Loss_Amount__c = 200;
        polClaimDetailObj.LAE_Amount__c = null;
        PCDList.add(polClaimDetailObj);
        
        Policy_Claim_Detail__c polClaimDetailObj1 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Claim Payment', polClaimObj.Id,'LAE Payment');
        //polClaimDetailObj1.LAE_Amount__c = 1;
        PCDList.add(polClaimDetailObj1);
      /*          
        Policy_Claim_Detail__c polClaimDetailObj2 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'', polClaimObj.Id,'Claim Coverage - ARDC'); 
        //polClaimDetailObj2.Loss_Amount__c = null;
       // polClaimDetailObj2.ISBA_First_Payment__c = 200;
        PCDList.add(polClaimDetailObj2);
        */  
       
        Policy_Claim_Detail__c polClaimDetailObj3 = TestDataFactory.createPolClaimDetail(acctivePolicy.Account__c,'Unallocated LAE', polClaimObj.Id,'Unallocated LAE Payment'); 
        polClaimDetailObj3.Loss_Amount__c = null;
        polClaimDetailObj3.LAE_Amount__c = 200;
        PCDList.add(polClaimDetailObj3);
        
        insert PCDList;
        
        
        // Create account payable records to post and unpost
        AcctSeed__Account_Payable__c[] payables = new List <AcctSeed__Account_Payable__c> ();
        payables.add(
            new AcctSeed__Account_Payable__c(
                AcctSeed__Vendor__c = [Select Id From Account limit 1].Id,
                AcctSeed__Payee_Reference__c = 'ThisIsATestPayeeReference123',
                Policy_Claim_Detail__c = PCDList[0].id,
                AcctSeed__Credit_Memo_Applied_Amount__c = 50,
                Type__c = 'Loss Pay' ,
                AcctSeed__Discount_Amount__c=0
                
            )
        );
        
        insert payables;
        
        
        // Create account payable line records to post and unpost
        AcctSeed__Account_Payable_Line__c[] apLines = new List <AcctSeed__Account_Payable_Line__c> ();
        AcctSeed__GL_Account__c glAccount = [Select Id From AcctSeed__GL_Account__c Where AcctSeed__Type__c = 'Expense' limit 1];
        
        for (AcctSeed__Account_Payable__c ap : payables) {
            AcctSeed__Account_Payable_Line__c apLine = new AcctSeed__Account_Payable_Line__c();
            apLine.AcctSeed__Account_Payable__c = ap.Id;
            apLine.AcctSeed__Amount__c = 100;
            apLine.AcctSeed__Expense_GL_Account__c = glAccount.Id;
            apLines.add(apLine);
            
            apLine = new AcctSeed__Account_Payable_Line__c();
            apLine.AcctSeed__Account_Payable__c = ap.Id;
            apLine.AcctSeed__Amount__c = 100;
            apLine.AcctSeed__Expense_GL_Account__c = glAccount.Id;
            apLines.add(apLine);
            
        }
        
        insert apLines;
        
        AcctSeed__Cash_Disbursement_Batch__c cashBatch = new AcctSeed__Cash_Disbursement_Batch__c(
            Name = 'Test Batch');
        insert cashBatch;
        
        AcctSeed__Cash_Disbursement__c cashD = new AcctSeed__Cash_Disbursement__c(
            AcctSeed__Cash_Disbursement_Batch__c = cashBatch.id,
            AcctSeed__Amount__c = 100,
            AcctSeed__Type__c = 'Check',
            AcctSeed__Vendor__c = acc.id,
            AcctSeed__Bank_Account__c = glAccounts[0].Id,
            AcctSeed__Accounting_Period__c = accPeriod.Id,
            AcctSeed__Ledger__c = ledgers[0].id
        );
        
        insert CashD;
        
        
        
        
        
        
        
        Test.stopTest();
        // Call the post service
        AcctSeed.PostResult[] postResults = AcctSeed.AccountPayablePostService.postAccountPayables(payables);
    }
  
    @isTest 
    static void testError1(){
        try{
            Test.startTest();
            List<Policy_Claim__c> listPC=[Select id, Per_Claim_Deductible__c from Policy_Claim__c];   
            for(Policy_Claim__c pc:listPC){
                pc.Per_Claim_Deductible__c=500;
            }
            Update listPC; 
            callClass();
            Date startDate = System.Date.today().toStartOfMonth();
            Date endDate = startDate.addMonths(1).addDays(-1);
            
            AcctSeed__Accounting_Period__c ap=new AcctSeed__Accounting_Period__c();
            ap.AcctSeed__Start_Date__c=startDate;
            ap.AcctSeed__End_Date__C=endDate;
            ap.AcctSeed__Status__c = 'Open';
            insert ap;
           
            Test.stopTest();    
        }catch(Exception e){
            
        }
        
    }
      @isTest 
    static void testError2(){
        try{
            Test.startTest();            
         
            List<AcctSeed__Accounting_Period__c> listAP=[Select id,AcctSeed__Start_Date__c,AcctSeed__End_Date__C from AcctSeed__Accounting_Period__c ];
            for(AcctSeed__Accounting_Period__c ap:listAP)  {
                ap.AcctSeed__End_Date__C=Date.today().addMonths(10);
               // ap.AcctSeed__Status__c='Closed';
            }
            Update listAP;           
            callClass();
            Test.stopTest();    
        }catch(Exception e){ }
        
        
        
    }
      @isTest 
    static void testError3(){
        try{
                      
       /*  
             List<AcctSeed__Account_Payable__c> payableList = [select id,AcctSeed__Net_Amount__c,AcctSeed__Paid_Amount__c,
                                                              AcctSeed__Credit_Memo_Applied_Amount__c,
                                                              Policy_Claim_Detail__c,AcctSeed__Balance__c,Type__c 
                                                              from AcctSeed__Account_Payable__c Limit 200];
           AcctSeed__Account_Payable__c newPayable = payableList[0].clone(false, true, false, false);
           
            insert newPayable;
           */ 
            List<Policy_Claim__c>  polClaimObj=[Select id from Policy_Claim__c];
            List<Policy__c> listP=[Select id,Account__c from Policy__c];
            List<Policy_Claim_Detail__c> PCDList=new List<Policy_Claim_Detail__c>();
            Policy_Claim_Detail__c polClaimDetailObj3 = TestDataFactory.createPolClaimDetail(listP[0].Account__c,'Unallocated LAE', polClaimObj[0].id,'Unallocated LAE Payment'); 
            polClaimDetailObj3.Loss_Amount__c = null;
            polClaimDetailObj3.LAE_Amount__c = 200;
            PCDList.add(polClaimDetailObj3);
            insert PCDList;
          /*  List<Policy_Claim_Detail__c> polClaimDetailList = [SELECT Id, Name,Date__c,Type__c,RecordType.Name,Policy_Claim__c,Loss_Amount__c,LAE_Amount__c
                                                               FROM Policy_Claim_Detail__c Where Type__c=:'Loss Payment' Limit 200];
            for(Policy_Claim_Detail__c pc :polClaimDetailList){
                pc.Type__c=null;
            }
                
             System.debug('##polClaimDetailList[0]===>'+polClaimDetailList[0]);
           */  
            ReverseClaimDetailEntries.checkRefundEligibility(String.valueOf(PCDList[0].id));
           
        }catch(Exception e){
        System.debug(e.getLineNumber()+'---error----'+e.getMessage());
        }
        
        
        
    }
    
     
    @isTest 
    static void checkRefundEligibility_Test(){
        Test.startTest();
        try{
             
            List<Policy_Claim__c> listPC=[Select id, Per_Claim_Deductible__c from Policy_Claim__c limit 100];   
            for(Policy_Claim__c pc:listPC){
                pc.Per_Claim_Deductible__c=-500;
            }
            Update listPC;
            //System.debug('listPC======>'+listPC);
            
            List<AcctSeed__Account_Payable__c> payableList = [select id,AcctSeed__Net_Amount__c,AcctSeed__Paid_Amount__c,
                                                              AcctSeed__Credit_Memo_Applied_Amount__c,
                                                              Policy_Claim_Detail__c,AcctSeed__Balance__c,Type__c 
                                                              from AcctSeed__Account_Payable__c Limit 100];
            for(AcctSeed__Account_Payable__c pay : payableList ){
                pay.AcctSeed__Credit_Memo_Applied_Amount__c = 69;
            }
            update payableList; 
            
            //System.debug('payableList----'+payableList); 
            
            
            List<Policy_Claim_Detail__c> polClaimDetailList = [SELECT Id, Name,Date__c,Type__c,RecordType.Name,Policy_Claim__c,Loss_Amount__c,LAE_Amount__c
                                                               FROM Policy_Claim_Detail__c Where Type__c='Loss Payment' Limit 100];
            
            
            //System.debug('polClaimDetailList[0]===>'+polClaimDetailList[0]);
            ReverseClaimDetailEntries.checkRefundEligibility(String.valueOf(polClaimDetailList[0].id));
            
        }
        catch(Exception e){
            //System.debug('e===>'+e.getMessage()+'---------'+e.getLineNumber());
        }
        Test.stopTest();
    }
   
    
      @isTest 
    static void testError4(){
        try{ 
             List<Policy_Claim_Detail__c> polClaimDetailList = [SELECT Id, Name,Date__c,Type__c,RecordType.Name,Policy_Claim__c,Loss_Amount__c,LAE_Amount__c
                                                               FROM Policy_Claim_Detail__c Where Type__c='Unallocated LAE Payment' Limit 200];
            
            
       
            List<AcctSeed__Account_Payable__c> payableList =new  List<AcctSeed__Account_Payable__c>();
             payableList.add(new AcctSeed__Account_Payable__c(
                AcctSeed__Vendor__c = [Select Id From Account limit 1].Id,
                AcctSeed__Payee_Reference__c = 'ThisIsATestPayeeReference321',
                Policy_Claim_Detail__c = polClaimDetailList[0].id,
                AcctSeed__Credit_Memo_Applied_Amount__c = 50,
                Type__c = 'Loss Pay' ,
                AcctSeed__Discount_Amount__c=0
             ));           
            insert payableList;
           // System.debug('Size Payble==>'+[select id from AcctSeed__Account_Payable__c ]);
           
            
           //  System.debug('##polClaimDetailList[0]===>'+polClaimDetailList[0]);
            ReverseClaimDetailEntries.checkRefundEligibility(String.valueOf(polClaimDetailList[0].id));
           
        }catch(Exception e){
       // System.debug(e.getLineNumber()+'---error----'+e.getMessage());
        }
        
        
        
    }
      @isTest 
    static void testError5(){
        try{
           ReverseClaimDetailEntries.checkRefundEligibility(String.valueOf(12345));   
        }
        catch(Exception e){
            
        }
    }
      @isTest 
    static void testError6(){
    
        try{
            Test.startTest(); 
            List<Policy_Claim__c> listPC=[Select id, Per_Claim_Deductible__c from Policy_Claim__c];   
            for(Policy_Claim__c pc:listPC){
                pc.Per_Claim_Deductible__c=-500;
            }
            Update listPC;
            System.debug('listPC======>'+listPC);
            
             List<Policy_Claim_Detail__c> polClaimDetailList = [SELECT Id, Name,Date__c,Type__c,RecordType.Name,Vendor__c,
                                                               Policy_Claim__c,Loss_Amount__c,LAE_Amount__c
                                                               FROM Policy_Claim_Detail__c Where Type__c='Loss Payment' Limit 200];
            Id repID=Schema.SObjectType.Policy_Claim_Detail__c.getRecordTypeInfosByName().get('Unallocated LAE').getRecordTypeId();
            System.debug('repID====>'+repID);
            Policy_Claim_Detail__c objDetail = new Policy_Claim_Detail__c();
            objDetail.Vendor__c= polClaimDetailList[0].Vendor__c;
            objDetail.RecordTypeId =repID; 
            objDetail.Date__c=date.today();
            objDetail.Policy_Claim__c=polClaimDetailList[0].Policy_Claim__c;
            objDetail.Type__c='Unallocated LAE Payment';
            objDetail.LAE_Amount__c=200;
            insert objDetail;         
            
            
            System.debug('objDetail[0]===>'+objDetail);
            
            List<AcctSeed__Account_Payable__c> payableList = [select id,AcctSeed__Net_Amount__c,AcctSeed__Paid_Amount__c,
                                                              AcctSeed__Credit_Memo_Applied_Amount__c,
                                                              Policy_Claim_Detail__c,AcctSeed__Balance__c,Type__c 
                                                              from AcctSeed__Account_Payable__c Limit 200];
            for(AcctSeed__Account_Payable__c pay : payableList ){
                pay.AcctSeed__Credit_Memo_Applied_Amount__c = 69;
                pay.Type__c='Unallocated LAE Payment';
                pay.Policy_Claim_Detail__c=objDetail.Id;
            }
            update payableList; 
            System.debug('payableList====>'+payableList);
           
            ReverseClaimDetailEntries.checkRefundEligibility(String.valueOf(objDetail.id));
            Test.stopTest();
        }catch(Exception e){
         System.debug(e.getLineNumber()+'-----error---'+e.getMessage());   
        }

        
       
        
        
        
        
        
        
    }
      @isTest 
    static void testError7(){
         try{
            List<Policy_Claim_Detail__c> polClaimDetailList = [SELECT Id, Name,Date__c,Type__c,RecordType.Name,Vendor__c,
                                                               Policy_Claim__c,Loss_Amount__c,LAE_Amount__c
                                                               FROM Policy_Claim_Detail__c Where Type__c='Loss Payment' Limit 200];
            Id repID=Schema.SObjectType.Policy_Claim_Detail__c.getRecordTypeInfosByName().get('Unallocated LAE').getRecordTypeId();
            System.debug('repID====>'+repID);
            Policy_Claim_Detail__c objDetail = new Policy_Claim_Detail__c();
            objDetail.Vendor__c= polClaimDetailList[0].Vendor__c;
            objDetail.RecordTypeId =repID; 
            objDetail.Date__c=date.today();
            objDetail.Policy_Claim__c=polClaimDetailList[0].Policy_Claim__c;
            objDetail.Type__c='Unallocated LAE Payment';
            objDetail.LAE_Amount__c=null;
            insert objDetail;
            
            
            System.debug('objDetail[0]===>'+objDetail);
            ReverseClaimDetailEntries.checkRefundEligibility(String.valueOf(objDetail.id));
            
        }catch(Exception e){
         System.debug(e.getLineNumber()+'-----error---'+e.getMessage());   
        }
        
    }
    
     @isTest 
    static void testError8(){
 
         try{
            List<Policy_Claim_Detail__c> polClaimDetailList = [SELECT Id, Name,Date__c,Type__c,RecordType.Name,Vendor__c,
                                                               Policy_Claim__c,Loss_Amount__c,LAE_Amount__c
                                                               FROM Policy_Claim_Detail__c Where Type__c='Loss Payment' Limit 200];
            Id repID=Schema.SObjectType.Policy_Claim_Detail__c.getRecordTypeInfosByName().get('Unallocated LAE').getRecordTypeId();
            System.debug('repID====>'+repID);
            Policy_Claim_Detail__c objDetail = new Policy_Claim_Detail__c();
            objDetail.Vendor__c= polClaimDetailList[0].Vendor__c;
            objDetail.RecordTypeId =repID; 
            objDetail.Date__c=date.today();
            objDetail.Policy_Claim__c=polClaimDetailList[0].Policy_Claim__c;
            objDetail.Type__c='Unallocated LAE Payment';
           // objDetail.LAE_Amount__c=50;
            insert objDetail;
            
            
            System.debug('objDetail[0]===>'+objDetail);
            ReverseClaimDetailEntries.checkRefundEligibility(String.valueOf(objDetail.id));
            
        }catch(Exception e){
         System.debug(e.getLineNumber()+'-----error---'+e.getMessage());   
        }
        
        
    }
    
    public static void callClass(){
        
        List<Policy_Claim_Detail__c> polClaimDetailList = [SELECT Id, Name,Date__c,Type__c,RecordType.Name,Policy_Claim__c,Loss_Amount__c,LAE_Amount__c
                                                               FROM Policy_Claim_Detail__c Where Type__c='Loss Payment' Limit 200];
            
            
             System.debug('polClaimDetailList[0]===>'+polClaimDetailList[0]);
            ReverseClaimDetailEntries.checkRefundEligibility(String.valueOf(polClaimDetailList[0].id));
            
    }
    
    
}