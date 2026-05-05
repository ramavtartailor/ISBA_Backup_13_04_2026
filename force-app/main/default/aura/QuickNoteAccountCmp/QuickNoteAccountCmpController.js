({
	doInit : function(component, event, helper) {
        helper.initHelper(component);
    },
    handleSave: function(component, event, helper) {
        var inputCmp = component.find("field");
        inputCmp.showHelpMessageIfInvalid();
        var isValid = inputCmp.get('v.validity').valid;        
        if(isValid){
            let acc = component.get("v.Account");
            acc.ISBAM_Quick_Note__c = component.get("v.note");
            console.log('acc =>'+ acc);
            component.set("v.spinner",true);
            var action = component.get("c.updateAccount");
            action.setParams({
                acc : acc,
                createTask: false,
                t: null
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