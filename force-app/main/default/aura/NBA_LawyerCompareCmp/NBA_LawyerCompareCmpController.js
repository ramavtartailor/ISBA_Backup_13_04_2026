({
    doInit: function (component, event, helper) {
        var baseURL = window.location.origin;
        component.set("v.baseURL", baseURL);
        helper.initHelper(component, event);
    },
    handleExpand: function (component, event, helper) {
        let index = event.target.dataset.index;
        let val = event.target.dataset.val;
        let wrapper = component.get("v.wrapper");
        if (val == 'false') {
            wrapper.lawyers[index].isExpended = false;
        } else {
            wrapper.lawyers[index].isExpended = true;
        }
        component.set("v.wrapper", wrapper);
    },
    handleExpandUnMatched: function (component, event, helper) {
        let index = event.target.dataset.index;
        let val = event.target.dataset.val;
        let wrapper = component.get("v.wrapper");
        if (val == 'false') {
            wrapper.unMatchedLawyers[index].isExpended = false;
        } else {
            wrapper.unMatchedLawyers[index].isExpended = true;
        }
        component.set("v.wrapper", wrapper);
    },
    handleUpdateData: function (component, event, helper) {
        let index = event.target.dataset.index;
        let lwField = event.target.dataset.lwfield;
        let conField = event.target.dataset.confield;
        let wrapper = component.get("v.wrapper");
        wrapper.lawyers[index].diffFieldsCount = parseInt(wrapper.lawyers[index].diffFieldsCount) - 1;
        wrapper.lawyers[index].con[conField] = wrapper.lawyers[index].lawyer[lwField];
        console.log('wrapper.lawyers[index].con[conField]:', wrapper.lawyers[index].con[conField]);
        console.log('wrapper.lawyers[index].lawyer[lwField]:', wrapper.lawyers[index].lawyer[lwField]);
        component.set("v.wrapper", wrapper);
        var action = component.get("c.saveData");
        action.setParams({
            conId: wrapper.lawyers[index].con.Id,
            lawyerId: wrapper.lawyers[index].lawyer.Id,
            lawyerFieldName: lwField,
            fieldName: conField,
            isContact: true
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('Success');
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
    handleUpdatePolicyLawyerData: function (component, event, helper) {
        let index = event.target.dataset.index;
        let lwField = event.target.dataset.lwfield;
        let conField = event.target.dataset.confield;
        let wrapper = component.get("v.wrapper");
        wrapper.lawyers[index].diffFieldsCount = parseInt(wrapper.lawyers[index].diffFieldsCount) - 1;
        wrapper.lawyers[index].policyLawyer[conField] = wrapper.lawyers[index].lawyer[lwField];
        console.log('wrapper.lawyers[index].policyLawyer[conField]:', wrapper.lawyers[index].policyLawyer[conField]);
        console.log('wrapper.lawyers[index].lawyer[lwField]:', wrapper.lawyers[index].lawyer[lwField]);
        component.set("v.wrapper", wrapper);
        var action = component.get("c.saveData");
        action.setParams({
            conId: wrapper.lawyers[index].policyLawyer.Id,
            lawyerId: wrapper.lawyers[index].lawyer.Id,
            lawyerFieldName: lwField,
            fieldName: conField,
            isContact: false
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('Success');
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
    
    handleUpdateAccData: function (component, event, helper) {
        let wrapper = component.get("v.wrapper");
        let accField = event.target.dataset.accfield;
        let nbaField = event.target.dataset.nbafield;
        
        wrapper.acc[accField] = wrapper.onlineNBA[nbaField];
        component.set("v.wrapper", wrapper);
        var action = component.get("c.saveAccData");
        action.setParams({
            recId: component.get("v.recordId"),
            accId: wrapper.acc.Id,
            nbaFieldName: nbaField,
            fieldName: accField
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('Success');
                var result = response.getReturnValue();
                component.set("v.wrapper", result);
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
    handleDeletePolicyLawyer: function (component, event, helper) {
        let conId = event.currentTarget.dataset.row;
        let wrapper = component.get("v.wrapper");
        var action = component.get("c.deleteLawyer");
        action.setParams({
            recId: wrapper.onlineNBA.Id,
            policyId: wrapper.onlineNBA.PolicyId__c,
            conId: conId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('Success');
                var result = response.getReturnValue();
                component.set("v.wrapper", result);
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
    openCreateModel: function (component, event, helper) {
        component.set("v.isModalOpen", true);
    },
    openLinkModel: function (component, event, helper) {
        component.set("v.isLinkModalOpen", true);
    },
    closeModalLinkAccount: function (component, event, helper) {
        console.log('<==Close Modal Parent==>');
        var message = event.getParam("message");
        if (message === 'callInit') {
            helper.initHelper(component, event);
        }
        component.set("v.isLinkModalOpen", false);
    },
    closeModal: function (component, event, helper) {
        component.set("v.isModalOpen", false);
        component.set("v.showAccountUnlinkModal", false);
        component.set("v.showContactUnlinkModal", false);
    },
    openUnLinkModel : function(component, event, helper) {
        component.set("v.showAccountUnlinkModal", true);
    },
    openUnLinkContact : function(component, event, helper) {
        component.set("v.showContactUnlinkModal", true);
        let lawyerId = event.currentTarget.dataset.row;
        component.set("v.selectedLawyerId", lawyerId);
    },
    openLinkContact : function(component, event, helper) {
        var index = event.currentTarget.dataset.index;
        var wrapper = component.get("v.wrapper");
        component.set("v.selectedLawyerId", wrapper.unMatchedLawyers[index].lawyer.Id );
        component.set("v.selectedLawyer", wrapper.unMatchedLawyers[index].lawyer );
        component.set("v.contactSearchKey", wrapper.unMatchedLawyers[index].fullName);
        component.set("v.isLinkContactModalOpen", true);
        component.set("v.isLawyer", true);
        window.setTimeout( $A.getCallback(function () { helper.searchContactHelper(component); }), 0);
    },
    searchContact : function(component, event , helper) {
        clearTimeout(component._debounceTimer);
        component._debounceTimer = setTimeout(function() {
            helper.searchContactHelper(component, event);
        }, 100);
    },
    
    handleLinkContact : function(component, event, helper) {
        var contactId = event.currentTarget.dataset.id;
        if(component.get("v.isLawyer")){
            helper.linkContactHelper(component, component.get("v.selectedLawyerId"), contactId, true);
        }
        else{
            helper.linkContactHelper(component, component.get("v.recordId"), contactId, false);
        }
    },
    
    openCreateContact : function(component, event, helper) {
        var index = event.currentTarget.dataset.index;
        var wrapper = component.get("v.wrapper");
        var lawyer = wrapper.unMatchedLawyers[index].lawyer;
        component.set("v.isLawyer", true); 
        component.set("v.selectedLawyerId", lawyer.Id);
        component.set("v.selectedLawyerName",lawyer.Name +(lawyer.Last_Name__c ? ' ' + lawyer.Last_Name__c : ''));
        component.set("v.isCreateContactModalOpen", true);
    },
    closeContactModal : function(component, event , helper) {
        component.set("v.isLinkContactModalOpen", false);
    },
    
    closeCreateContactModal : function(component) {
        component.set("v.isCreateContactModalOpen", false);
    },
    
    confirmCreateContact : function(component, event, helper) {
        if(component.get("v.isLawyer")){
            helper.createContactHelper(component);
        }
        else{
            helper.createAppContactHelper(component);
        }
    },
    
    saveAcc: function (component, event, helper) {
        component.set("v.showSpinner", true);
        
        let wrapper = component.get("v.wrapper");
        var action = component.get("c.Create_AddAccount");
        
        action.setParams({
            recId: wrapper.onlineNBA.Id
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.isModalOpen", false);
                helper.showToast(
                    "Success!",
                    "The record has been updated successfully.",
                    "success"
                );
                helper.initHelper(component, event);
                
            } else if (state === "ERROR") {
                
                var errors = response.getError();
                let message = "Something went wrong";
                
                if (errors && errors[0] && errors[0].message) {
                    message = errors[0].message;
                }
                
                helper.showToast("Error!", message, "error");
            }
            
            component.set("v.showSpinner", false);
        });
        
        $A.enqueueAction(action);
    },
    
    handleUpdateContactData: function (component, event, helper) {
        let wrapper = component.get("v.wrapper");
        let index = event.target.dataset.index;
        let conField = event.target.dataset.nbafield;
        let lwField = event.target.dataset.accfield;
        
        wrapper.unMatchedLawyers[index].lawyer.Contact__r[conField] =wrapper.unMatchedLawyers[index].lawyer[lwField];
        component.set("v.wrapper", wrapper);
        var action = component.get("c.saveConData");
        action.setParams({
            recId: wrapper.unMatchedLawyers[index].lawyer.Id,
            conId: wrapper.unMatchedLawyers[index].lawyer.Contact__c,
            lwFieldName: lwField,
            fieldName: conField
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('Success');
                var result = response.getReturnValue();
                helper.initHelper(component, event);
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
    
    unLinkAccount : function (component, event, helper) {
        component.set("v.showSpinner", true);
        var action = component.get("c.unlinkAccount");
        action.setParams({
            recId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(res){
            if(res.getState() === "SUCCESS") {
                component.set("v.showAccountUnlinkModal", false);
                helper.initHelper(component);
            }
            component.set("v.showSpinner", false);
        });
        
        $A.enqueueAction(action);
    },
    
    unLinkContact : function (component, event, helper) {
        helper.linkContactHelper(component, component.get("v.selectedLawyerId"), null, true);
    },
    
    handleUpdateContactField : function(component, event, helper) {
        
        let field = event.currentTarget.dataset.field;
        let nbaField = event.currentTarget.dataset.nbafield;
        
        let wrapper = component.get("v.wrapper");
        
        let valueToCopy = wrapper.onlineNBA[nbaField];
        
        // Update UI immediately
        wrapper.appContact[field] = valueToCopy;
        component.set("v.wrapper", wrapper);
        
        var action = component.get("c.updateContactField");
        
        action.setParams({
            conId: wrapper.appContact.Id,
            fieldName: field,
            val: valueToCopy
        });
        
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS"){
                console.log("Contact updated successfully");
            } else {
                console.log("Error updating contact");
            }
        });
        
        $A.enqueueAction(action);
    },
    openLinkContactApp: function(component, event, helper) {
        var wrapper = component.get("v.wrapper");
        let key = wrapper.onlineNBA.Contact_Name__c;
        if(wrapper.onlineNBA.Contact_Last_Name__c){
            key += ' '+ wrapper.onlineNBA.Contact_Last_Name__c;
        }
        component.set("v.contactSearchKey", key);
        component.set("v.isLinkContactModalOpen", true);
        component.set("v.isLawyer", false);        
        window.setTimeout(
            $A.getCallback(function () {helper.searchContactHelper(component); }), 0);
    },
    openCreateContactApp: function(component, event, helper) {
        var wrapper = component.get("v.wrapper");
        let key = wrapper.onlineNBA.Contact_Name__c;
        if(wrapper.onlineNBA.Contact_Last_Name__c){
            key += ' '+ wrapper.onlineNBA.Contact_Last_Name__c;
        }
        component.set("v.selectedLawyerName",key);
        component.set("v.isLawyer", false); 
        component.set("v.isCreateContactModalOpen", true);
    },
})