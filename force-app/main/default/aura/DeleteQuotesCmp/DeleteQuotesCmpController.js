({
    doInit : function(component, event, helper) {
        let quoteIds  = component.get("v.quoteIds");
        component.set("v.showSpinner", true);
        if(!quoteIds){
            component.set("v.message", 'Please select the quotes to delete.');
            component.set("v.showError", true);
            setTimeout(function(){
                component.set("v.showError", false);
                component.set("v.showSuccess", false);
                component.set("v.message", '');
                history.back();
            }, 4000);
        }
        else{
            component.set("v.disabled",false);
        }
        component.set("v.showSpinner", false);
    },
    handleClose : function (component, event, helper) {
        history.back();
    },
    handleSave : function (component, event, helper) {
        component.set("v.showSpinner", true);
        var action = component.get("c.deleteQuotes");
        action.setParams({
            "quoteIds" : component.get("v.quoteIds")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.showError", false);
                component.set("v.showSuccess", true);
                component.set("v.message", 'Quotes deleted successfully.');
                setTimeout(function(){
                    component.set("v.showError", false);
                    component.set("v.showSuccess", false);
                    history.back();
                }, 4000);
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.showError", true);
                        component.set("v.showSuccess", false);
                        component.set("v.message", errors[0].message);
                        setTimeout(function(){
                            component.set("v.showError", false);
                            component.set("v.showSuccess", false);
                            component.set("v.message", '');
                        }, 4000);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    closeToastHandle: function (component, event, helper) {
        component.set("v.showError", false);
        component.set("v.showSuccess", false);
        component.set("v.message", '');
    }
})