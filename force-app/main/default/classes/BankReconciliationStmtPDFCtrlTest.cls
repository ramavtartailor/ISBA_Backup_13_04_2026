@isTest
public class BankReconciliationStmtPDFCtrlTest {
    static testMethod void testMethod1() 
    {
        
         AcctSeed__GL_Account__c actGl = new AcctSeed__GL_Account__c();
            actGl.Name = 'Test';
            actGl.AcctSeed__Bank__c = true;
            actGl.AcctSeed__Type__c = 'Revenue';
            insert actGl;
            list<AcctSeed__Bank_Reconciliation2__c>listAcctSeed_BankReconciliation = new list<AcctSeed__Bank_Reconciliation2__c>();
            AcctSeed__Bank_Reconciliation2__c actSeedObj = new AcctSeed__Bank_Reconciliation2__c();
            system.debug(actGl.Id);
            actSeedObj.AcctSeed__Bank_Account__c = actGl.id;
            actSeedObj.AcctSeed__End_Date__c = System.today();
            actSeedObj.AcctSeed__Type__c = 'Bank';
            actSeedObj.AcctSeed__Cleared_Deposits__c  = 1772359.58;
            actSeedObj.AcctSeed__Cleared_Disbursements__c = 2142045.12;
            actSeedObj.AcctSeed__Beginning_Balance__c =1772359.58;
            actSeedObj.AcctSeed__Ending_Balance__c = 4929541.35;
            listAcctSeed_BankReconciliation.add(actSeedObj);
            
            insert listAcctSeed_BankReconciliation;
            system.debug(actSeedObj);
        
        
         
        
        
         PageReference pref = Page.BankReconciliationStmtPDF;       
        pref.getParameters().put('id',listAcctSeed_BankReconciliation[0].id);
        Test.setCurrentPage(pref);
        
        Test.startTest();
        BankReconciliationStmtPDFCtrl  bankReconciliationPdfCtrl = new  BankReconciliationStmtPDFCtrl();
        bankReconciliationPdfCtrl.makePDF();
        Test.stopTest();
    }
    static testMethod void testMethod2() 
    {
      
         PageReference pref = Page.BankReconciliationStmtPDF;       
        pref.getParameters().put('id','1234');
        Test.setCurrentPage(pref);
        
        Test.startTest();
        BankReconciliationStmtPDFCtrl  bankReconciliationPdfCtrl = new  BankReconciliationStmtPDFCtrl();
        bankReconciliationPdfCtrl.makePDF();
        Test.stopTest();
    }
}