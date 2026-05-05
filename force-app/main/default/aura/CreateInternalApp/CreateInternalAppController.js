({
    handleSuccess : function(component, event, helper) {
        console.log(component.get("v.recordId"));
        var navEvt = $A.get("e.force:navigateToSObject");
        var payload = event.getParams().response;
        console.log(event.getParams());
        navEvt.setParams({
            "recordId": payload.Id,
            "slideDevName": "related"
        });
        navEvt.fire();    
    },
    handleSave : function(component, event, helper) {
        var application = component.get("v.application");
        var action = component.get("c.CreateInternalApp");
        var recId;
        console.log('inside')
        action.setParams({ 
            "application": application
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                window.location.href='/lightning/r/Customer_Application__c/'+response.getReturnValue()+'/view';
            }
        });
        $A.enqueueAction(action);
    },
    handleCancel : function(component, event, helper) {
        window.location.href='/lightning/o/Customer_Application__c/list?filterName=Recent';
        
    }
    
})