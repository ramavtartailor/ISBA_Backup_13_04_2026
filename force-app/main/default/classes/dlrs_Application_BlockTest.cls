/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Application_BlockTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Application_BlockTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Application_Block__c());
    }
}