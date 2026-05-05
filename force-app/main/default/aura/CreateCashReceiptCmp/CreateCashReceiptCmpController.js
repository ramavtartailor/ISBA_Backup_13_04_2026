({
    doInit : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var action = component.get("c.getDetails");
        action.setParams({
            recId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state === "SUCCESS") {   
                var result = response.getReturnValue();
                console.log('result => ',result);                
                component.set("v.cr",result);
                
            } else if (state === "INCOMPLETE") {
                console.log("Error");
                helper.showToast('Unknown Error', 'Error!', 'error');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {                        
                        console.log("Error message: " + errors[0].message);
                        helper.showToast(errors[0].message, 'Error!', 'error');
                        $A.get("e.force:closeQuickAction").fire();
                    }
                } 
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },
    handleSave : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var allValid = component.find('input').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if (allValid) {
            var action = component.get("c.CreateReceipt");
            action.setParams({
                receipt: component.get("v.cr"),
                recId : component.get("v.recordId")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('state:', state);
                if (state === "SUCCESS") {   
                    var result = response.getReturnValue();
                    console.log('result => ',result);
                    helper.showToast('Cash Receipt Created Successfully.', 'Success!', 'success');
					window.open('/'+result, '_self');
                    
                } else if (state === "INCOMPLETE") {
                    console.log("Error");
                    helper.showToast('Unknown Error', 'Error!', 'error');
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {                        
                            console.log("Error message: " + errors[0].message);
                            helper.showToast(errors[0].message, 'Error!', 'error');
                        }
                    } 
                }
                component.set("v.showSpinner",false);
            });
            $A.enqueueAction(action);
        } else {
            component.set("v.showSpinner",false);
        }
    },
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})