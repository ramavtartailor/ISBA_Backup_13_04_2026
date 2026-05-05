({
    doInit : function(component, event, helper) {
      
        var action = component.get("c.getClaimDetails");
        action.setParams({
            claimId : component.get("v.recordId")
            
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.record", a.getReturnValue());
                
                var a = component.get("v.record.Per_Claim_Limit__c");
                console.log(a);
                var b = component.get("v.record.Claim_Incurred__c");
                console.log(b);
                var total = parseInt(a) - parseInt(b);
                component.set("v.total", total);
            }
        });
        
        $A.enqueueAction(action);
        
    }
})