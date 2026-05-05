({
    doInit : function(component, event, helper) {
        helper.doInitHelper(component, event, helper);
    },
    
    editable : function(component, event, helper) {
        component.set("v.editable", true);
    },
    
    keyCheck : function(component, event, helper){
        if (event.which == 13){
            var textarea = component.find("isbam_status_description");
            var a = component.get('c.doSave');
            $A.enqueueAction(a);
        }
    },
    
    handleEdit : function(component, event, helper) {
        component.set("v.editable", true);
        window.setTimeout(function(){
            var textarea = component.find("isbam_status_description");
            textarea.set("v.value", "");
            textarea.focus();
        }, 10);
    },
    
    handleCancel : function(component, event, helper) {
        var action = component.get('c.getOnlineApp');
        action.setParams({
            "RecordId" : component.get('v.recordId')
        });
        action.setCallback(this, function(a){
            var state = a.getState();
            if(state === 'SUCCESS') {
                component.set("v.pol", a.getReturnValue());
                component.set("v.editable", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    doSave : function(component, event, helper) {
        component.set('v.spinner', true);
        var action = component.get('c.saveOnlineApp');
        action.setParams({
            "app" : component.get('v.pol')
        });
        action.setCallback(this, function(a){
            var state = a.getState();
            if(state === 'SUCCESS') {
                if(a.getReturnValue() === 'Success'){
                    component.set('v.spinner', false);
                    component.set("v.editable", false);
                    helper.doInitHelper(component, event, helper);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": a.getReturnValue()
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    }
})