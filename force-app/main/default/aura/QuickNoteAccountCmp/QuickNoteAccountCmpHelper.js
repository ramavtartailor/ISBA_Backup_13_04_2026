({
    initHelper : function(component) {
        component.set("v.spinner",true);
        var action = component.get("c.getDetails");
        action.setParams({
            recId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var result = a.getReturnValue();
                console.log(result);
                component.set("v.Account", a.getReturnValue());
                component.set("v.spinner",false);
            }
        });
        
        $A.enqueueAction(action);
    }
})