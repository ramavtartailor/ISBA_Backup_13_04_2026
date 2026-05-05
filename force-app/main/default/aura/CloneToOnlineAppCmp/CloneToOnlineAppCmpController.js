({
	addRenewalApp : function(component, event, helper) {
        $A.util.addClass(component.find("confirmBox"), 'hide');
        // Prepare the action to load account record
        var action = component.get("c.getPolicy");
		action.setParams(
			{"policyId" : component.get("v.recordId")}
		);
		// Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.msg", response.getReturnValue());
                var returnedValue = response.getReturnValue();
                if(returnedValue.length == 15 || returnedValue.length == 18){
                    window.location.href = '/' + returnedValue;
                }else{
                    component.set("v.msg", returnedValue);
                    $A.util.removeClass(component.find("errorMsg"), 'hide');
                }
            } else {
                component.set("v.msg", 'There is some error occurred. Please contact your System Administrator.');
                $A.util.removeClass(component.find("errorMsg"), 'hide');
                console.log('Problem getting account, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
        
	}, 
	
	hideConfirmBox : function(component, event, helper) {
		var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
		dismissActionPanel.fire();
	},
    showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();
    },
    
    hideSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        evt.fire();
    }
})