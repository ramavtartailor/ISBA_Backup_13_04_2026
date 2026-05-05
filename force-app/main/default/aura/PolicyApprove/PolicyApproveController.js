({
	doInit : function(component, event, helper) {
        var action = component.get("c.getPolicyEndorse");
        action.setParams(
			{policyId : component.get("v.recordId")}            
		);
        action.setCallback(this, function(response) {
            var state = response.getState();  
            if(state === "SUCCESS") {
                component.set("v.objPolicyEndorse", response.getReturnValue());
            } else {
                console.log('Problem getting account, response state: ' + state);
            }
        });
        $A.enqueueAction(action); 
        
	}, 
	
	approve : function(component, event, helper) {
		$A.util.addClass(component.find("confirmBox"), 'hide');
		var errorMessage = '';
		var eventStatus = component.get("v.objPolicyEndorse.Event_Status__c ");
		var endorspolicy = component.get("v.objPolicyEndorse.Policy__c ");
		if(eventStatus == 'Complete')
			errorMessage += 'Endorsement has already Approved!';
            
		if(errorMessage){
			$A.util.removeClass(component.find("errorMsg"), 'hide');
			component.set("v.msg", errorMessage);
		}else{
        	var action = component.get("c.updatePolicy");
			action.setParams( 
			{policyId : component.get("v.recordId")}            
		);
        
        action.setCallback(this, function(response) {
            var state = response.getState();           
            if(state === "SUCCESS") {
                component.set("v.objPolicyEndorse", response.getReturnValue());
                var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
				dismissActionPanel.fire();                
                window.location.href = "/"+endorspolicy; 
                  
            } else {
                console.log('Problem getting account, response state: ' + state);
            }
        });
        $A.enqueueAction(action);            
		}
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