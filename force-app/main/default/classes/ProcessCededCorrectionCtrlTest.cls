@isTest
public class ProcessCededCorrectionCtrlTest {

   
    @isTest
    public static void testMethod1(){
        
        Treaty_Versions__c treatyObj = new Treaty_Versions__c();
        treatyObj.Treaty_Correction_Processed__c = false;
        insert treatyObj;
        
        Account accontObj = new Account();
        accontObj.Name = 'Test test';
        insert accontObj;
        
        Policy__c PolicyObj = new Policy__c();
        PolicyObj.Accounting_Processed__c = true;
        PolicyObj.Treaty_Version__c = treatyObj.id;
        PolicyObj.Account__c = accontObj.id;
        PolicyObj.Effective_Date__c = Date.newInstance(2016, 12, 9);
        insert PolicyObj;
        
        string recordId = treatyObj.id;
        
        Test.startTest(); 
        ProcessCededCorrectionCtrl.processCededTransactions(recordId) ;
        
        Test.stopTest();
        
    }
}