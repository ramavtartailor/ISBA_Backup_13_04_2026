({
    searchAccounts : function(component, event) {
        component.set("v.showSpinner", true);
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
            component.set("v.showSpinner", false);
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
                this.closeModalHelper(component, 'callInit');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire();
                
            }
            component.set("v.showSpinner", true);
        });
        
        $A.enqueueAction(action);
    },
    getCurrentApplication : function(component){
        var action = component.get("c.getApplication");
        
        action.setParams({
            recordId : component.get("v.recordId")
        });
        
        action.setCallback(this,function(res){
            if(res.getState() === "SUCCESS"){
                let app = res.getReturnValue();
                component.set("v.currentName", app.Full_Legal_Name_of_the_Firm__c);
                component.set("v.currentPhone", app.Firm_Phone_Number__c);
                let fullAddress = (app.Street__c || '') + ' ' + (app.Address_2__c || '') + ', ' + (app.City__c || '') + ' ' + (app.State__c || '') + ' ' + (app.Zip_Code__c || '');
                component.set("v.currentFullAddress", fullAddress.trim());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    closeModalHelper : function (component, msg) {
        console.log('<==Close Modal Child==>');
        var closeEvent = $A.get("e.c:closeLinkAccountModalEvt");
        closeEvent.setParams({"message": msg});
        closeEvent.fire();
    },
})