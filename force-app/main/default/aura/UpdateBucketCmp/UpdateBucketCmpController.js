({
    doInit: function(component, event, helper){
        var action = component.get("c.getContact");
        action.setParams({
            recId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var result = a.getReturnValue();
                console.log(result);
                component.set("v.record", a.getReturnValue());
                component.set("v.selectedVal",result.Account.Name);
            }
        });
        
        $A.enqueueAction(action);
    },
	handleSave : function(component, event, helper) {
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        if (!allValid) {
            return null;
        } 
		component.set("v.spinner",true);
        var action = component.get("c.updateRecord");
        action.setParams({
            "rec": component.get("v.record"),
            "accName" : component.get("v.selectedVal")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                //show toast
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"success",
                    "title": "Success!",
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
            else if(state === "ERROR"){
                var errors = response.getError();
                var msg = '';
                if (errors) {
                    if (errors[0] && errors[0].message) {                       
                        msg = errors[0].message;
                    }
                }
                else {                    
                    msg =  'Unknown error in getting Details.';                    
                }
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"error",
                    "title": "Error!",
                    "message": msg
                });
                toastEvent.fire();
            } 
            component.set("v.spinner",false);
        });
        $A.enqueueAction(action);
	},
    handleCancel : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
	}
})