({
	init: function(component, event) {
		var action = component.get("c.isOperationAllowed");
        action.setParams({
            "recordId": component.get("v.recordId"),
            "operation": "Edit"
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue().isOperationAllowed){
                    if(response.getReturnValue().isOperationAllowed == 'No'){
                        this.showToast('Error','You are not allowed to edit this after the application is bound.');
                        this.moveToObject(component,response.getReturnValue().returnURL);
                    }else if(response.getReturnValue().isOperationAllowed == 'Yes'){
                        window.location.href = response.getReturnValue().returnURL;
                    }
                }else{
                    this.showToast('Error','There is some error occurred. Please contact your System Administrator.');
                    this.moveToObject(component,component.get("v.recordId"));
                }
            }
        });
        $A.enqueueAction(action);
	},
    showToast : function(type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if(type == 'Success'){
            toastEvent.setParams({
                "type": "success",
                "title": "Success!",
                "message": message
            });
        }else if(type=='Error'){
            toastEvent.setParams({
                "type": "error",
                "title": "Error!",
                "message": message
            });
        }
        toastEvent.fire();
    },
    moveToObject : function(component,recordId){
        setTimeout(function(){ 
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": recordId
            });
            navEvt.fire();
        }, 2000);
    }
})