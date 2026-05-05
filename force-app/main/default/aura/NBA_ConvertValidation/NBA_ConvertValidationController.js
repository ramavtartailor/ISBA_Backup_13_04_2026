({
	doInit : function(component, event, helper) {
		var action = component.get("c.getDetails");
        action.setParams({
            recId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(res){
            if(res.getState() === "SUCCESS"){
                component.set("v.valuesList", res.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
	}
})