({
    doInitHelper : function(component, event, helper) {
        var action = component.get('c.getOnlineApp');
        action.setParams({
            "RecordId" : component.get('v.recordId')
        });
        action.setCallback(this, function(a){
            var state = a.getState();
            if(state === 'SUCCESS') {
                component.set('v.pol', a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})