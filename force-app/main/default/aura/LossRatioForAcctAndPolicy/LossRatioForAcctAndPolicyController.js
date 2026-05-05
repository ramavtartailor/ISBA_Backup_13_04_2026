({
    doInit : function(component, event, helper) {
        
        var action = component.get("c.checkSobjectType");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {   
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set('v.wrapper', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})