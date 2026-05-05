({
	checkRequiredField : function(component,event,helper){
        
       helper.checkRequiredFieldsHelper(component,event,helper);
        
    },
    closeModal : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    showSpinner : function (component, event, helper) {
         component.set("v.spinner", true); 
    },
    
    hideSpinner : function (component, event, helper) {
         component.set("v.spinner", false); 
    },
    triggerPayment : function(component,event,helper){
        component.set("v.triggerPaymentButtonEnable", true);
        component.set("v.spinner", true); 
        var action = component.get("c.triggerPaymentCtrl");
		action.setParams(
			{"recordId" : component.get("v.recordId"), "noteText" : component.get("v.noteText")}
		);
		// Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    'url': '/apex/ReprocessPayment?id=' + component.get("v.recordId")
                });
                urlEvent.fire();
            } else {
                component.set("v.spinner", false); 
                helper.showError(component,event,helper,response.getError()[0]);
                console.log(' Update unsuccessful' + response.getError()[0]);
                component.set("v.triggerPaymentButtonEnable", false);
            }
        });
        $A.enqueueAction(action);
    }
})