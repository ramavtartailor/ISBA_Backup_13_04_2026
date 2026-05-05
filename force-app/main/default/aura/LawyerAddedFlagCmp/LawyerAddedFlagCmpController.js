({
    doInit : function(component, event, helper) {
        var action = component.get("c.getDetails");
        action.setParams({
            recId : component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                
                if(result.includes('|')){
                    var lst = result.split("|"); 
                    component.set("v.removedLawyers",lst[0]);
                    component.set("v.addedLawyers",lst[1]);
                }
            } else if (state === 'INCOMPLETE') {
                // Code when Imcomplete
            } else if (state === 'ERROR') { 
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
})