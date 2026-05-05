({
	doInit : function(component, event, helper) {
        var action = component.get('c.updateDetails'); 
        action.setParams({
            recId : component.get("v.recordId")
        });
        action.setCallback(this, function(a){
            var state = a.getState();
            if(state == 'SUCCESS') {
                var result = a.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "The Customer Application has been Regenerated successfully."
                });
                toastEvent.fire();
            }
            else if (state === "INCOMPLETE") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "An unknown error occurred."
                });
                toastEvent.fire();
            } else if (state === "ERROR") {
                var errors = a.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "error",
                            "message": errors[0].message
                        });
                        toastEvent.fire();
                    }
                }
            }
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });
        $A.enqueueAction(action);
	}
})