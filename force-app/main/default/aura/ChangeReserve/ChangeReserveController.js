({
	doInit : function(component, event, helper) {
        component.set("v.spinner", true); 
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.transactionDate', today);
        console.log(new Date());
        var action = component.get("c.getClaim");
        action.setParams({"claimId": component.get("v.recordId")});
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.claim", response.getReturnValue());
            component.set("v.lossReserve", response.getReturnValue().GL_5010__c + response.getReturnValue().GL_5000__c);
            component.set("v.laeReserve", response.getReturnValue().GL_5035__c + response.getReturnValue().GL_5030__c);
            if(state === "SUCCESS") {
                if(component.get("v.claim.Claim_Status__c")=="Closed"){
                    component.set("v.msg","Claim has already been Closed.To make any changes please reopen the claim or file a new one.");
                    component.set("v.isClosed", true); 
                }else {
                    component.set("v.isClosed", false); 
                }
            } else {
                console.log('Problem getting account, response state: ' + state);
            }
            component.set("v.spinner", false); 
        });
        $A.enqueueAction(action);
	},
    saveRecord : function(component, event, helper) {
        component.set("v.spinner", true); 
        var transactionDate = new Date(component.get("v.transactionDate"));
        var today = new Date();
        var claim = component.get("v.claim");
        var changeLossReserve =  (component.get("v.lossReserve") - (component.get("v.claim.GL_5010__c") + component.get("v.claim.GL_5000__c")));
        var changeLAEReserve = (component.get("v.laeReserve") - (component.get("v.claim.GL_5035__c") + component.get("v.claim.GL_5030__c")));
        if(transactionDate > today || transactionDate < today.setDate(today.getDate() -14 )){
            component.set("v.msg","Transaction date can not be in future and not less than 14 days.");
            component.set("v.spinner", false); 
        }else if(changeLossReserve + changeLAEReserve > component.get("v.claim.Policy_Remaining_By_All_Claims__c")){
            component.set("v.msg","Loss Incurred and LAE Incurred cannot exceed policy limit.");
            component.set("v.spinner", false); 
        }else{
            var action = component.get("c.updateReserve");
            action.setParams({"lossReserve":component.get("v.lossReserve"),"laeReserve":component.get("v.laeReserve"),"claim": claim,"transactionDate" : component.get("v.transactionDate")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    if(response.getReturnValue() == 'Success'){
                        setTimeout(function() {
                            component.set("v.spinner", true); 
                        }, 100);
                        setTimeout(function() {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "type": "success",
                                "message": "Reserved changed successfully."
                            });
                            toastEvent.fire();
                            var dismissActionPanel = $A.get("e.force:closeQuickAction");
                            dismissActionPanel.fire();
                            window.location.href = "/lightning/r/Policy_Claim__c/" + component.get("v.recordId") + "/view";
                        }, 5000);
                        
                        //var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        //dismissActionPanel.fire();
                        //$A.get('e.force:refreshView').fire();
                        //
                        
                    }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "error",
                            "message": response.getError()[0].message 
                        });
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                        toastEvent.fire();
                    }
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    var toastEvent = $A.get("e.force:showToast");
                    if (errors) {
                        console.log(errors);
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                            toastEvent.setParams({
                                "title": "Error!",
                                "type": "error",
                                "message": errors[0].message
                            });
                        }
                    } else {
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "error",
                            "message": response.getReturnValue()
                        });
                    }
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    toastEvent.fire();
                }
                component.set("v.spinner", false); 
            });
            $A.enqueueAction(action);
        }
    },
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },
})