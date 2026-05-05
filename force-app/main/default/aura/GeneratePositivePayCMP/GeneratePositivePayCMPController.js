({
	doInit : function(component, event, helper) {
		var action = component.get("c.generateFile");
        action.setParams({recId : component.get("v.recordId")});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": '!Success',
					"type": "success",
					"message": 'Positive Pay file generated successfully.'
				});
				toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
                // Code when Success
            }else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": '!Error',
							"type": "error",
							"message": errors[0].message
						});
						toastEvent.fire();
                    }
                } else {
					console.log("Unknown error");
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						"title": '!Error',
						"type": "error",
						"message": "Unknown error"
					});
					toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
	}
})