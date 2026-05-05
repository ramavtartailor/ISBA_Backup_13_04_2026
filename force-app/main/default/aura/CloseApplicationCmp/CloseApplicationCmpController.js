({
    doInit : function(component, event, helper) {
        helper.initHelperMethod(component);
    },

    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    handleSave : function(component, event, helper) {
        var allValid = component.find('field').reduce(function(valid, input) {
            input.showHelpMessageIfInvalid();
            return valid && input.get('v.validity').valid;
        }, true);
        if(allValid){
            helper.saveHelper(component);
        }
    }
})