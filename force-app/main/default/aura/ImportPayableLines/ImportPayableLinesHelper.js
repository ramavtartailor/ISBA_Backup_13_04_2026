({
	handleGetRecords : function(component, event, helper, csv) {
        
        component.set("v.loadingSpinner", true);
        var action = component.get('c.getCSVObject');
        action.setParams({
            csv_str : csv
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.wrapper", result);
                console.log('result =>>'+ JSON.stringify(result));
                component.set("v.loadingSpinner", false);
            }else if(state === "ERROR"){
                var errors = action.getError();
                component.set("v.loadingSpinner", false);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showErrorToast(component, event, errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    showSuccessToast : function(cmp,event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
    showErrorToast : function(cmp,event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
})