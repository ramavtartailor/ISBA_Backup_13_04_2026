@isTest
public class Batch_FiservAccountUpdaterTest {
    @testSetup
    static void setupData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Payment_Method__c pm = new Payment_Method__c(
            Account__c = acc.Id,   
            Token__c = '9559111741684444',
            Expiry_Year__c = 2024,
            Expiry_Month__c = 12
        );
        insert pm;
    }
    
    @isTest
    static void testShedulable(){
        Test.startTest();
        Batch_FiservAccountUpdater sched = new Batch_FiservAccountUpdater();
        String jobId = System.schedule('Fiserv Batch Job','0 0 0 1 1 ? 2099',sched);
        
        Test.stopTest();
        
        System.assertNotEquals(null, jobId, 'Scheduled job should be created');
        
    }
    
    
}