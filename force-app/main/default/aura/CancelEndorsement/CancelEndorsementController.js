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
	
	cancel : function(component, event, helper) {
		$A.util.addClass(component.find("confirmBox"), 'hide');
		var errorMessage = '';
		var eventStatus = component.get("v.objPolicyEndorse.Event_Status__c ");
		var endorspolicy = component.get("v.objPolicyEndorse.Policy__c ");
        var endorsementNumber = component.get("v.objPolicyEndorse.Endorsement_Number__c ");
        if(endorsementNumber != 'IL 107'){
            errorMessage += 'This endorsement type can not be cancelled.';
        }
        if(eventStatus == 'Cancel' || eventStatus == 'Pending')
			errorMessage += 'Endorsement has already been Cancelled or no transactions yet generated!';
            
		if(errorMessage){
			$A.util.removeClass(component.find("errorMsg"), 'hide');
			component.set("v.msg", errorMessage);
		}else{
        	var action = component.get("c.cancelEndorsement");
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