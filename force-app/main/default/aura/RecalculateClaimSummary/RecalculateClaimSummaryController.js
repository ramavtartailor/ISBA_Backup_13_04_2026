({
	doInit : function(component, event, helper) {
		component.set("v.spinner", true); 
        var action = component.get("c.updateClaimSummary");
        action.setParams({"claimId": component.get("v.recordId")});
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Claim Summary Updated successfully."
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                window.location.href = "/lightning/r/Policy_Claim__c/" + component.get("v.recordId") + "/view";
            } else if (state === "ERROR") {
                    var errors = response.getError();
                    var toastEvent = $A.get("e.force:showToast");
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                            toastEvent.setParams({
                                "title": "Error!",
                                "type": "error",
                                "message": errors[0].message
                            });
                        }
                    } else {
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "error",
                            "message": response.getReturnValue()
                        });
                    }
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    toastEvent.fire();
                }else {
                console.log('Problem getting account, response state: ' + state);
            }
            component.set("v.spinner", false); 
        });
        $A.enqueueAction(action);
	}
})