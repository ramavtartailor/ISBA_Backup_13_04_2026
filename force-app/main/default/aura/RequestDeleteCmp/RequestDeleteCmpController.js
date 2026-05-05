({
	handleSave: function (component, event, helper) {
		component.set("v.spinner", true);
		var action = component.get("c.CreateDeleteRequest");
		action.setParams({
			recId: component.get("v.recordId"),
			reason: component.get("v.reason")
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === 'SUCCESS') {
				var result = response.getReturnValue();
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": "Success!",
					"type": "success",
					"message": "The Delete Request has been submitted successfully."
				});
				toastEvent.fire();
				$A.get("e.force:closeQuickAction").fire();
			}
			else if (state === 'ERROR') {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": "Error!",
							"type": "error",
							"message": errors[0].message
						});
						toastEvent.fire();
					}
				} else {
					console.log("Unknown error");
				}
			}
			component.set("v.spinner", false);
		});
		$A.enqueueAction(action);
	},
	handleClose: function (component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	}
})