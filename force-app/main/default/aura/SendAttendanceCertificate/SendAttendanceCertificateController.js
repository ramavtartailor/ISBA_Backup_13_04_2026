({
    doInit : function(component, event, helper) {
        var action = component.get("c.callBatch");
        action.setParams({
            recId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state === "SUCCESS") {
                helper.showToast("Info!","info","The process of sending the certification is currently underway.");
            }else if(state === "INCOMPLETE"){
                helper.showToast("Error!","error","An unexpected error has occurred.");
            }else if(state === "ERROR"){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast("Error!","error",errors[0].message);
                    }
                }
            }
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });
        $A.enqueueAction(action);
    }
})