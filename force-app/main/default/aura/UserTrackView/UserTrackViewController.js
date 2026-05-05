({
	doInit : function(component, event, helper) {
        var action = component.get("c.updateUserTrack");
        action.setParams({"recordId": component.get("v.recordId")});
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log('User Track Success');
            } else {
                console.log('Problem getting account, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
	}
})