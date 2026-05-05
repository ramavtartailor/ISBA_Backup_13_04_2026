({
	doInit : function(component, event, helper) {
        
        $A.util.removeClass(component.find("confirmBox"), 'hide');  
	}, 
	
	convertToApplication : function(component, event, helper) {
		$A.util.addClass(component.find("confirmBox"), 'hide');
        
        // Prepare the action to load account record
        var action = component.get("c.getProfileName");

		// Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                
                var profile = response.getReturnValue();
                
                if(profile != 'System Administrator'){
              		var msg = "You are not authorized for this operation.";
                    component.set("v.msg", msg);
                    $A.util.removeClass(component.find("errorMsg"), 'hide');
                }
                else{
                    var action = component.get("c.getCongaMsg");
                    action.setParams(
                        {policyId : component.get("v.recordId")}
                    );
                    // Configure response handler
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if(state === "SUCCESS") {
                            var msg = response.getReturnValue();
                            component.set("v.msg", msg);
                            $A.util.removeClass(component.find("errorMsg"), 'hide');
                            
                            if(msg == "Policy successfully converted back to Application."){
                            	var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
								dismissActionPanel.fire();   
                            }
                                                        
                        } else {
                            console.log('Problem getting account, response state: ' + state);
                        }
                    });
                    $A.enqueueAction(action);
                }
            } else {
                console.log('Problem getting account, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
        
	},
	
	
	hideConfirmBox : function(component, event, helper) {
		var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
		dismissActionPanel.fire();
	}
})