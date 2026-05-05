@isTest
public class SCHCalcultorCtrl_Test {
    
    @isTest 
    static void TestMethod1() {
        Test.StartTest();
        SCHCalcultorCtrl SCH = new SCHCalcultorCtrl();
        SCH.calculateMod();
        SCH.isDocketSystems = false;
        SCH.isConflictSystems = false;
        SCH.isClientInatke = false;
        SCH.isBillProcedure = false;
        SCH.isFeeSuits = false;
        SCH.isOutsideInterests = false;
        SCH.isMgmtCommittee = false;
        SCH.isUseOfClientEnagagement = false;
        SCH.isUseOfClientFeeAgreement = false;
        SCH.isUseOfDeclination = false;
        SCH.isUseOfTermination = false;
        SCH.isUseOfReferral = false;
        SCH.isUseOfSettlement = false;
        SCH.isUseOfClientCommunication = false;
        SCH.isGeneralOverride = false;
        
        Test.stopTest();
    }
    
    
}