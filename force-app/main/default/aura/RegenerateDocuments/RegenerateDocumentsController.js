({
	regenerateDocuments : function(component, event, helper) {
		helper.showSpinner(component);
        var action = component.get("c.regenerateDocs");
        action.setParams({ "recordId" : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast('Success','Documents Generated Successfully.');
                $A.get("e.force:closeQuickAction").fire();
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        helper.showToast('Error',errors[0].message);
                        $A.get("e.force:closeQuickAction").fire();
                    }
                } else {
                    helper.showToast('Error','Unkown Error!');
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
            helper.hideSpinner(component);
        });
        $A.enqueueAction(action);
	},
    hideConfirmBox : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})