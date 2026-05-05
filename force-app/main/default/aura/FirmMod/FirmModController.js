({
	doInit : function(component, event, helper) {
		var action = component.get("c.getRecord");
        action.setParams({
            "recId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                console.log('returnVal => '+JSON.stringify(returnVal));
                component.set("v.wrapObj",returnVal);
            } 
        });
        $A.enqueueAction(action);
	}
})