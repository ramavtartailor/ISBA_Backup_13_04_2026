({
    initHelper : function(component, event) {
        component.set("v.showSpinner", true);
		var action = component.get("c.getCustomerApplication");
        action.setParams({
            appId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var data = a.getReturnValue();
                component.set("v.assignableUsers",data.usrList);
                var result = data.app;
                console.log(result);
                component.set("v.selectedSalesUser", result.Sales_User__c);
                component.set("v.selectedUnderwriterUser", result.Underwriter_User__c);
                component.set("v.nbaRecord", result);
                component.set("v.searchTerm",result.Full_Legal_Name_of_the_Firm__c);
                if(result.Customer_Application_Lawyers__r){
                    component.set("v.numberOfLawyers", result.Customer_Application_Lawyers__r.length);
                }
                else{
                    component.set("v.numberOfLawyers", 0);
                }
                // if(result.Latest_Policy__c){
                //     helper.getPolicy(component, event, result.Latest_Policy__c);
                // }
                component.set("v.showSpinner", false);
            }
        });
        
        $A.enqueueAction(action);
	},
    searchAccounts : function(component, event) {
        var action = component.get("c.searchAccount");
        action.setParams({
            companyName: component.get("v.searchTerm")
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var result = a.getReturnValue();
                console.log(result);
                component.set("v.accList",result);
            }
        });
        
        $A.enqueueAction(action);		
    },
    updateAccount: function(component, event, accountId) {
        component.set("v.showSpinner", true);
        var action = component.get("c.updateApplicationAccount");
        action.setParams({
            recordId : component.get("v.recordId"),
            accountId : accountId
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var result = a.getReturnValue();
                this.initHelper(component, event);
                console.log(result);
                component.set("v.showAccountModal", false);
                component.set("v.showAccountUnlinkModal", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire();
                
                component.set("v.showSpinner", false);
            }
        });
        
        $A.enqueueAction(action);
    }
})