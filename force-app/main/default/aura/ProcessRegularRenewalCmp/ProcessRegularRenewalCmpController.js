({
	doInit : function(component, event, helper) {
        var action = component.get('c.getDetails'); 
        action.setParams({
            recId : component.get("v.recordId")
        });
        action.setCallback(this, function(a){
            var state = a.getState();
            if(state == 'SUCCESS') {
                var result = a.getReturnValue();
                console.log('result => ',result);
                component.set("v.wrapper",result);
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
            
                component.set("v.spinner",false);
        });
        $A.enqueueAction(action);
	},
    handleClose: function(component, event, helper){        
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})