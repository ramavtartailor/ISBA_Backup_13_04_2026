({
	handleSave : function(component, event, helper) {
		component.set("v.spinner", true);
        var action = component.get("c.reversePolicy");
        action.setParams({
            recId: component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state'+state);
            if(state == "SUCCESS") {
                var result = response.getReturnValue();
                helper.showToast('Policy cancellation reversed successfully.',"Success!","success");
                window.open("/"+result, "_self");
            }
            else{                
                var errors = response.getError();
                if (errors) {
                    helper.showToast(errors[0].message,"Error!","error");
                } else {
                    helper.showToast("Unknown error","Error!","error");
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