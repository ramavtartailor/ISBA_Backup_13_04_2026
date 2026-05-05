({
    doInit : function(component, event, helper) {
        helper.initHelperMethod(component, event, helper);
    },
    onChange : function(component, event, helper) {
        component.set("v.placeholder", '');
        component.set("v.isDescriptionReqired", false);
        helper.getDependentPicklist(component, event, helper);
    },
    onSub1Change : function(component, event, helper) {
        component.set("v.placeholder", '');
        component.set("v.isDescriptionReqired", false);
        helper.setDependentPicklist(component, event, helper);
    },   
    onSub2Change : function(component, event, helper) {
        component.set("v.placeholder", '');
        component.set("v.isDescriptionReqired", false);
        var sub2List = component.get("v.lostReasonSub2List");
        var selectedValue = component.get("v.lostReasonSub2");
        
        for(let x of sub2List){
            console.log(x);
            if(selectedValue == x.Lost_Reason_Sub2__c){
                component.set("v.placeholder", x.Placeholder__c);
                component.set("v.isDescriptionReqired", x.Description_Required__c);
            }
        }
    },   
    handleClose: function(component, event, helper) {
         $A.get("e.force:closeQuickAction").fire();
    },
    handleSave : function(component, event, helper) {
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        if (allValid) {
            helper.saveHelper(component, event, helper);
        } else {
            console.log("input Errors");
        }
    }
})