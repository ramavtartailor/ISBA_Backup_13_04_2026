({
    doInit : function(component, event, helper) {
        var action = component.get("c.getPolicyDetails");
        action.setParams({
            policyId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.record", a.getReturnValue());
                component.set("v.selectedContact", a.getReturnValue().Firm_Contact__c);
                component.set("v.selectedPolicyContact", a.getReturnValue().Firm_Contact__c);
                component.set("v.selectedBillingContact", a.getReturnValue().Account__r.AcctSeed__Billing_Contact__c);
            }
        });
        
        $A.enqueueAction(action);
        
        var action1 = component.get("c.hasBlocks");
        action1.setParams({
            relatedId : component.get("v.recordId")
        });
        
        action1.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.hasAnyBlock", a.getReturnValue());
            }
        });
        
        $A.enqueueAction(action1);
        
        var action2 = component.get("c.typeOfPolicy");
        action2.setParams({
            policyId : component.get("v.recordId")
        });
        
        action2.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                if(a.getReturnValue() == 'latestApplication'){
                   component.set("v.latestApplication", true); 
                }else if(a.getReturnValue() == 'latestPolicy'){
                   component.set("v.latestPolicy", true); 
                }else if(a.getReturnValue() == 'isApplication'){
                   component.set("v.isApplication", true); 
                }else if(a.getReturnValue() == 'futurePolicy'){
                    component.set("v.futurePolicy", true); 
                }
            }
            helper.hideSpinner(component);
        });
        
        $A.enqueueAction(action2);
        
        var action3 = component.get("c.has107");
        action3.setParams({
            policyId : component.get("v.recordId")
        });
        
        action3.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                if(a.getReturnValue() == 'False'){
                    component.set("v.has107", false);
                }else{
                    component.set("v.has107", true);
                    component.set("v.value107", a.getReturnValue());
                }
                
            }
        });
        
        $A.enqueueAction(action3);
        
    },
    openModel: function(component, event, helper) {
        helper.showSpinner(component);
        var contactOption = [];
        contactOption.push({value :"",label:'---Select Contact---'});
        component.set("v.contacts",contactOption);
        
        var action1 = component.get("c.getContacts");
        action1.setParams({"accountId": component.get("v.record.Account__c")
                          });
        
        action1.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                let contacts = response.getReturnValue();
                for(var i in contacts){
                    contactOption.push({value : contacts[i].ContactId,label:contacts[i].Contact.Name});
                }
                component.set("v.contacts",contactOption);
            }
            helper.hideSpinner(component);
        });
        $A.enqueueAction(action1);
        var whichContact = event.target.dataset.rId;
        if(whichContact == 'policyContact'){
            component.set("v.selectedContact", component.get("v.selectedPolicyContact"));
            component.set("v.isPolicyContactUpdate", true);
            component.set("v.isBillingContactUpdate", false);
        }else{
            component.set("v.selectedContact", component.get("v.selectedBillingContact"));
            component.set("v.isPolicyContactUpdate", false);
            component.set("v.isBillingContactUpdate", true);
        }
        component.set("v.isModalOpen", true);
    },
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    
    saveContact: function(component, event, helper) {
        helper.showSpinner(component);
        
        var action1 = component.get("c.updateContact");
        var whichContact = event.getSource().getLocalId();
        if(whichContact == 'policyContact'){
            action1.setParams({
                "contactId": component.get("v.selectedContact"),
                "policyId" : component.get("v.recordId")
            });
        }else{
            action1 = component.get("c.updateBillingContact");
            action1.setParams({
                "contactId": component.get("v.selectedContact"),
                "accountId" : component.get("v.record.Account__c")
            });
        }
        
        action1.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() == 'Success'){
                    helper.showToast('Success','Contact Updated Successfully');
                    window.location.href = "/"+component.get("v.recordId");
                }else{
                    helper.showToast('Error',response.getReturnValue());
                }
                helper.hideSpinner(component);
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                        helper.showToast('Error',errors[0].message);
                        $A.get("e.force:closeQuickAction").fire();
                    }
                } else {
                    helper.showToast('Error','Unkown Error!');
                }
                helper.hideSpinner(component);
            }
        });
        component.set("v.isModalOpen", false);
        $A.enqueueAction(action1);
    },
})