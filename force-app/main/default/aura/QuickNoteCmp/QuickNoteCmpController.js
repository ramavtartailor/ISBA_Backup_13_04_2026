({
    doInit : function(component, event, helper) {
        helper.initHelper(component);
    },
    updateContact: function(component, event, helper) {
        var inputCmp = component.find("field");
        inputCmp.showHelpMessageIfInvalid();
        var isValid = inputCmp.get('v.validity').valid;        
        if(isValid){
            component.set("v.spinner",true);
            var action = component.get("c.updateData");
            action.setParams({
                recId : component.get("v.recordId"),
                note: component.get("v.note")
            });
            
            action.setCallback(this, function(a) {
                if (a.getState() === "SUCCESS") {
                    var result = a.getReturnValue();
                    helper.initHelper(component);
                    component.set("v.showEdit",false);
                }
                else{
                    component.set("v.spinner",false);
                }
            });
            
            $A.enqueueAction(action);
        }
    },
    handleCancel: function(component, event, helper) {
        helper.initHelper(component);
        component.set("v.showEdit",false);
    },
    handleEdit: function(component, event, helper) {
        component.set("v.note",'');
        component.set("v.showEdit",true);
    }
})