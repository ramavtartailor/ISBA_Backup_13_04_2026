({
	doInit : function(component, event, helper) {
        // Prepare the action to load Claim record
        var action = component.get("c.getClaim");
        action.setParams({"claimId": component.get("v.recordId")});
        
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.claim", response.getReturnValue());
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": "/apex/AccountPayable_New?obj=claim&claimName="+component.get("v.claim.Name")+"&claimId="+component.get("v.claim.Id")+"&policyId="+component.get("v.claim.Policy__c")+"&accountId="+component.get("v.claim.Policy__r.Account__c")+"&retURL=%2F"+component.get("v.claim.Id")
                  
                });
                
                urlEvent.fire();
                //alert("/apex/AccountPayable_New?obj=claim&claimName="+component.get("v.claim.Name")+"&claimId="+component.get("v.claim.Id")+"&policyId="+component.get("v.claim.Policy__c")+"&accountId="+component.get("v.claim.Policy__r.Account__c")+"&retURL=%2F"+component.get("v.claim.Id"));
            } else {
                console.log('Problem getting account, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
		
	}
})