({
    doInit : function(component, event, helper) {
        var action = component.get("c.getClaimDetails");
        action.setParams({
            claimId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var result = a.getReturnValue();
                if(a.getReturnValue().Claim_Status__c == 'Closed'){
                    component.set("v.isActiveClaim", false);
                }else{
                    component.set("v.isActiveClaim", true);
                }
                component.set("v.record", a.getReturnValue());
                
                var balance = 0;
                var total = 0;
                if(result.Billings__r){
                    for(let x of result.Billings__r){
                        balance = parseFloat(balance) + parseFloat(x.AcctSeed__Balance__c);
                        total = parseFloat(total) + parseFloat(x.AcctSeed__Total__c);
                    }
                }
                component.set("v.balance",balance);
                component.set("v.total",total);
            }
        });
        
        $A.enqueueAction(action);
        
        var action1 = component.get("c.hasBlocks");
        action1.setParams({
            relatedId : component.get("v.recordId")
        });
        
        action1.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.hasAnyBlock", a.getReturnValue());
            }
        });
        
        $A.enqueueAction(action1);
    }
})