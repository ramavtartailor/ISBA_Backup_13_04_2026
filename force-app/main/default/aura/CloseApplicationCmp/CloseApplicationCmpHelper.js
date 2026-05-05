({
    initHelperMethod : function(component){
        component.set("v.spinner",true);
        var action = component.get("c.getPickListVal");
        action.setParams({
            strObjectName : 'Customer_Application__c', recId : component.get("v.recordId"),strPicklistField : 'Close_Reason__c'
        });
        
        action.setCallback(this,function(res){
            if(res.getState() === "SUCCESS"){
                component.set("v.closeReasonList",res.getReturnValue());
            }
            component.set("v.spinner",false);
        });
        
        $A.enqueueAction(action);
    },
    
    saveHelper : function(component){
        
        component.set("v.spinner",true);
        var action = component.get("c.save");
        action.setParams({recId : component.get("v.recordId"), closeReason : component.get("v.closeReason"), closeDescription : component.get("v.closeDescription")});
        action.setCallback(this,function(res){
            
            if(res.getState() === "SUCCESS"){
                $A.get("e.force:closeQuickAction").fire();
                location.reload();
            }
            else if(res.getState() === "ERROR"){
                var errors = res.getError();
                if(errors && errors[0] && errors[0].message){
                    console.log('Error',errors[0]);
                    console.log('Error message',errors[0].message);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error",
                        message: errors[0].message,
                        type: "error"                        
                    });
                    toastEvent.fire();
                }
            }
            
            component.set("v.spinner",false);
        });
        
        $A.enqueueAction(action);
    }
})