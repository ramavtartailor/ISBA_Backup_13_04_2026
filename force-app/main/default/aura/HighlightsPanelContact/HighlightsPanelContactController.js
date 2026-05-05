({
	doInit : function(component, event, helper) {
		var action = component.get("c.getContactDetail");
        action.setParams({
            conId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var result = a.getReturnValue();
                console.log(result);
                component.set("v.contactRecord", result);
                if(result.Latest_Policy__c){
                    helper.getPolicy(component, event, result.Latest_Policy__c);
                }
            }
        });
        
        $A.enqueueAction(action);
	}
})