({
    doInit : function(component, event, helper) {
        helper.initHelper(component, event);
    },
    openModel : function(component, event, helper) {
        component.set("v.showAccountModal", true);
        helper.searchAccounts(component, event);
    },
    
    handleSalesChange : function(component) {
        component.set("v.selectedUnderwriterUser", "");
    },
    
    handleUnderwriterChange : function(component) {
        component.set("v.selectedSalesUser", "");
    },
    
    openUserModel:function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },
    
    openUnlinkModel: function(component, event, helper) {
        component.set("v.showAccountUnlinkModal", true);
    },
    closeModalLinkAccount: function(component, event, helper) {
        console.log('<==Close Modal Parent==>');
        var message = event.getParam("message");
        if(message === 'callInit'){
            helper.initHelper(component, event);
        }
        component.set("v.showAccountModal", false);
    },
    closeModel : function(component, event, helper) {
        component.set("v.showAccountUnlinkModal", false);
        component.set("v.isModalOpen", false);
    },
    
    unLinkAccount : function(component, event, helper) {
        helper.updateAccount(component, event, null);
    },
    
    saveApp : function(component, event, helper) {
        let accountId = event.currentTarget.dataset.row;
        helper.updateAccount(component, event, accountId);
    },
    
    handleSearch : function(component, event, helper) {
        clearTimeout(component._debounceTimer);
        component._debounceTimer = setTimeout(function() {
            helper.searchAccounts(component, event);
        }, 100);
    },
    
    saveUser : function(component, event, helper) {
        var salesUser = component.get("v.selectedSalesUser");
        var underUser = component.get("v.selectedUnderwriterUser");
        
        if(salesUser || underUser){
            component.set("v.showSpinner", true);
            var action = component.get("c.updateApplicationUser");
            
            action.setParams({
                recordId : component.get("v.recordId"),
                salesUserId : salesUser,
                underwritingUserId : underUser});
                
            action.setCallback(this, function(a) {
                if (a.getState() === "SUCCESS") {
                    var result = a.getReturnValue();
                    helper.initHelper(component, event);
                    console.log(result);
                    component.set("v.isModalOpen", false);
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
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "message": "Please select a User."
            });
            toastEvent.fire();
            
        }
        
        
    }
})