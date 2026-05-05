({
    initHelper : function(component, event) {
        var action = component.get("c.getData");
        action.setParams({
            recId : component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.wrapper", result);
                component.set("v.searchTerm",result.onlineNBA.Full_Legal_Name_of_the_Firm__c);
                console.log('result:', JSON.stringify(result));
            } else if (state === 'INCOMPLETE') {
                // Code when Imcomplete
            } else if (state === 'ERROR') { 
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(title, msg, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: msg,
            type: type
        });
        toastEvent.fire();
    },
    
    linkContactHelper : function(component, recId, contactId, isLawyer) {
        component.set("v.showSpinner", true);
        var action = component.get("c.linkExistingContact");
        action.setParams({
            recId  : recId,
            contactId : contactId,
            isLawyer : isLawyer
        });
        
        action.setCallback(this, function(res){
            console.log(res.getState());
            if(res.getState() === "SUCCESS") {
                component.set("v.isLinkContactModalOpen", false);
                component.set("v.showContactUnlinkModal", false);
                this.initHelper(component);
            }
            component.set("v.showSpinner", false);
        });
        
        $A.enqueueAction(action);
    },
    createContactHelper : function(component) {
        component.set("v.showSpinner", true);
        var action = component.get("c.createContactFromLawyer");
        action.setParams({
            lawyerId : component.get("v.selectedLawyerId")
        });
        
        action.setCallback(this, function(res){
            if(res.getState() === "SUCCESS") {
                component.set("v.isCreateContactModalOpen", false);
                // component.set("v.wrapper", res.getReturnValue());
                this.initHelper(component);
                this.showToast("Success!", "Contact created successfully",  "success" ); 
            }
            component.set("v.showSpinner", false);
        });
        
        $A.enqueueAction(action);
    },
    createAppContactHelper : function(component) {
        component.set("v.showSpinner", true);
        var action = component.get("c.createContactNBA");
        action.setParams({
            recId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(res){
            if(res.getState() === "SUCCESS") {
                component.set("v.isCreateContactModalOpen", false);
                // component.set("v.wrapper", res.getReturnValue());
                this.initHelper(component);
                this.showToast("Success!", "Contact created successfully",  "success" ); 
            }
            component.set("v.showSpinner", false);
        });
        
        $A.enqueueAction(action);
    },
    searchContactHelper: function(component, event){
        var action = component.get("c.searchContactForLink");
        action.setParams({
            searchKey : component.get("v.contactSearchKey")
        });
        
        action.setCallback(this, function(res){
            if(res.getState() === "SUCCESS"){
                component.set("v.contactList", res.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    }
})