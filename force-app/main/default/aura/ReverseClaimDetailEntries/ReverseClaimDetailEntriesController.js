({
	doInit : function(component, event, helper) {
		
        var action = component.get("c.checkRefundEligibility");
        action.setParams({ "recordId" : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast('Success','Entries Reversed Successfully');
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
	}
})