({
	doInit : function(component, event, helper) {
        // Prepare the action to load account record
        var action = component.get("c.getPolicy");
		action.setParams(
			{"policyId" : component.get("v.recordId")}
		);
		// Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.objPolicy", response.getReturnValue());
                var values = response.getReturnValue();
                console.log("values",values);
                if(values.Application_Received_Date__c && values.Date_Signed__c && values.Status__c && values.PaymentReceived__c ){
                     component.set("v.bindButtonEnable",false);
                }
            } else {
                console.log('Problem getting account, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
        
        helper.getTargetPicklist(component,event);
        helper.getStatusPicklist(component, event);
        helper.getPaymentReceivedPicklist(component,event);
       	helper.getIBFContributionPicklist(component,event);
	}, 
    
    
    
    checkRequiredField : function(component,event,helper){
        
       helper.checkRequiredFieldsHelper(component,event,helper);
        
    },
    
    
    updateToPolicy : function(component,event,helper){
       var status = component.find("statusPicklist").get("v.value");
       if(status == 'Accepted'){
       component.set("v.spinner", true); 
       var action = component.get("c.updatePolicy");
		action.setParams(
			{"policy" : component.get("v.objPolicy")}
		);
		// Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                 component.set("v.spinner", true); 
                helper.convertToPolicy(component,event,helper);
            } else {
                component.set("v.spinner", false); 
                helper.showError(component,event,helper,response.getError()[0]);
                console.log(' Update unsuccessful' + response.getError()[0]);
            }
        });
        $A.enqueueAction(action);
       }
        else{
             helper.showError(component,event,helper,'Status must be "Accepted" for binding.');
        }
    },
    
    closeModal : function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    },
	
	
	
	
	hideConfirmBox : function(component, event, helper) {
		var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
		dismissActionPanel.fire();
		/*
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
			"url": "/"+component.get("v.recordId")
		});
		urlEvent.fire();
		*/
	},
    
    showSpinner : function (component, event, helper) {
         component.set("v.spinner", true); 
        /*
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();
        */
    },
    
    hideSpinner : function (component, event, helper) {
         component.set("v.spinner", false); 
        /*
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        evt.fire();
        */
    }
    
})