@isTest
private class MultiselectController_Test {
    
    @isTest static void testMethod1() {
        
        Test.startTest();
        
        MultiselectController Ctrl = new MultiselectController();
        Ctrl.leftOptions = new List<SelectOption>();
        Ctrl.leftOptions.add(new SelectOption('a','b'));
        Ctrl.leftOptionsHidden ='a&b&c';
        Ctrl.rightOptions = new List<SelectOption>();
        Ctrl.rightOptions.add(new SelectOption('a', 'b'));
        Ctrl.rightOptionsHidden ='a&b';
        
        Test.stopTest();
        
    }
   
}