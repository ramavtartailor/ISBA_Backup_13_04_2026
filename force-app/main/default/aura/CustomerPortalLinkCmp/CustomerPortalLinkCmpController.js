({
	doInit : function(component, event, helper) {
		var action = component.get("c.getLink");
        action.setParams({recId : component.get("v.recordId")});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log(result);
                window.open(result,"_blank");
                $A.get("e.force:closeQuickAction").fire();
                // Code when Success
            }else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                        console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	}
})