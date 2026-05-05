({
	doInit : function(component, event, helper) {
        var action = component.get("c.getClaim");
        action.setParams({"claimId": component.get("v.recordId")});
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.claim", response.getReturnValue());
            } else {
                console.log('Problem getting account, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
	}
})