({
    handleSave : function(component, event, helper) {
        var action = component.get("c.reMatch");
        action.setParams({recId : component.get("v.recordId")});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                helper.showToast('Success!', 'success', 'The record matching process has been completed.');
                $A.get("e.force:closeQuickAction").fire();
                const timeOut = window.setTimeout(function() {
                    window.location.reload(true);
                }, 3000);
            } else if (state === 'INCOMPLETE') {
                helper.showToast('Error!', 'error', "Unknown error");
                // Code when Imcomplete
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        helper.showToast('Error!', 'error', errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    helper.showToast('Error!', 'error', "Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    closeModal: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})