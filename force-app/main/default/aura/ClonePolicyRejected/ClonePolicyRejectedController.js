({
	handleSave : function(component, event, helper) {
        component.set("v.spinner",true);
		var action = component.get("c.clonePolicy");
        action.setParams({
            policyId : component.get("v.recordId"),
            effDate : component.get("v.effectiveDate")
        });
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                helper.showToast("Success!", "success", "Application Cloned Successfully.");
                window.location.href = '/' + a.getReturnValue();                
            }else if (state === "INCOMPLETE") {
                helper.showToast("Error!", "error", "An unknown error has occurred.");
            } else if (state === "ERROR") {
                var errors = a.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast("Error!", "error", errors[0].message);
                    }
                }else{
                    helper.showToast("Error!", "error", "An unknown error has occurred.");
                }                
            }
            component.set("v.spinner",false);
        });
        
        $A.enqueueAction(action);
	},
    handleClose : function(component, event, helper) {
		 $A.get("e.force:closeQuickAction").fire();
	}
})