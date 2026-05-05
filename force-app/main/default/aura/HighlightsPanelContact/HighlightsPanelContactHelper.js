({
	showToast : function(type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if(type == 'Success'){
            toastEvent.setParams({
                "type": "success",
                "title": "Success!",
                "message": message
            });
        }else if(type=='Error'){
            toastEvent.setParams({
                "type": "error",
                "title": "Error!",
                "message": message
            });
        }
        toastEvent.fire();
    },
    getPolicy : function(component, event, policyId){
        var action2 = component.get("c.getPolicyDetails");
        action2.setParams({
            policyId : policyId
        });
        
        action2.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var result = a.getReturnValue();
                
                this.hasBlocksHelper(component, event, result.Account__c);
                
                const date = new Date().getTime();
                if(result != null){
                    console.log(date);
                    var eff = new Date(result.Effective_Date__c).getTime();
                    var exp = new Date(result.Expiration_Date__c).getTime();
                   
                    if(eff <= date && exp >= date){
                        component.set("v.hasActivePolicy", true);                    
                    }
                    component.set("v.record", a.getReturnValue());
                }
            }
        });
        
        $A.enqueueAction(action2);
    },
    hasBlocksHelper : function(component, event, accId){
        var action1 = component.get("c.hasBlocks");
        action1.setParams({
            relatedId : accId //component.get("v.recordId")
        });
        
        action1.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.hasAnyBlock", a.getReturnValue());
            }
        });
        
        $A.enqueueAction(action1);
        
        var action3 = component.get("c.has107");
        action3.setParams({
            policyId : accId//component.get("v.recordId")
        });
        
        action3.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                if(a.getReturnValue() == 'False'){
                    component.set("v.has107", false);
                }else{
                    component.set("v.has107", true);
                    component.set("v.value107", a.getReturnValue());
                }
                
            }
        });
        
        $A.enqueueAction(action3);
    },
    showSpinner: function(cmp) {
        var cmpTarget = cmp.find('spinner');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    
    hideSpinner: function(cmp) {
        var cmpTarget = cmp.find('spinner');
        $A.util.addClass(cmpTarget, 'slds-hide');
    }
})