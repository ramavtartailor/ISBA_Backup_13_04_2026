({
	checkRequiredFieldsHelper : function(component, event, helper){
        var noteText = component.find("noteText").get("v.value");
        if(noteText != null ){
            component.set("v.triggerPaymentButtonEnable",false);
        }else{
            component.set("v.triggerPaymentButtonEnable",false);
        }
    },
    showSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'Binding Successfull',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    showError : function(component, event, helper,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
    }
})