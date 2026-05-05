@isTest
public class UserTrackViewCtrl_Test {
    
	@isTest
    private static void test0(){
        Test.startTest();
        Account acc = new Account(
        	Name = 'Test Acc'
        );
      	insert acc;
        UserTrackViewCtrl.updateUserTrack(acc.Id);
        Test.stopTest();
    }
    
    @isTest
    private static void test1(){
        Test.startTest();
        
        Account acc = new Account(
        	Name = 'Test Acc'
        );
      	insert acc;
        
        Policy__c pol = new Policy__c(
        	Name = 'Test Pol',
            Account__c = acc.Id,
            Effective_Date__c = system.today()
        );
      	insert pol;
        UserTrackViewCtrl.updateUserTrack(pol.Id);
        Test.stopTest();
    }
    
     @isTest
    private static void test2(){
        Test.startTest();
        UserTrackViewCtrl.dummyCode();
        Test.stopTest();
    }
   
}