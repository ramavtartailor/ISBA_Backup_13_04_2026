({
    
    doInit: function (component, event, helper) {
        var pageReference = component.get("v.pageReference");
        var recId = pageReference.state.c__recordId;
        component.set("v.eventId", pageReference.state.c__recordId);

        var action = component.get("c.getDetails");
        action.setParams({recId : recId});
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state === 'SUCCESS') {
                // Code when Success
                var result = response.getReturnValue();
                console.log('result:', result);
                component.set("v.event", result);
            } else if (state === 'INCOMPLETE') {
                // Code when Imcomplete
                helper.showErrorToast(component, event, "Unknown error");
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showErrorToast(component, event, errors[0].message);
                    }
                } else {
                    helper.showErrorToast(component, event, "Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    handleUploadFinished : function(component, event, helper) {
        
        var file = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            component.set("v.loadingSpinner", true);
            var file = event.getSource().get("v.files")[0];
            component.set("v.fileName", file['name']);
            if(file) {
                
                var reader = new FileReader();
                reader.readAsText(file, 'UTF-8');
                reader.onload = function(event) {
                    
                    var csv = event.target.result;
                    component.set("v.csvString", csv);
                }
            }
            component.set("v.loadingSpinner", false);
        }
    },
    
    handleGetRecords : function(component, event, helper) {
        
        component.set("v.loadingSpinner", true);
        var action = component.get('c.getCSVObject');
        action.setParams({
            csv_str : component.get("v.csvString")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                
                component.set("v.wrapper", response.getReturnValue());
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
    
    handleCreateRecords : function(component, event, helper) {
        
        component.set("v.loadingSpinner", true);
        var action = component.get('c.createRecord');
        action.setParams({
            wrapper : component.get("v.wrapper"),
            eventId : component.get("v.eventId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var result = response.getReturnValue();
                if(result){
                    component.set("v.errorList",result);
                    component.set("v.showErrors",true);
                }
                else{
                    helper.showSuccessToast(component, event, 'SUCCESS!!');                    
                    $A.get('e.force:refreshView').fire();
                }
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
    
    refresh : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    
    backToEvent : function(component, event, helper) {
        var url = window.location.href; 
        var value = url.substr(0,url.lastIndexOf('/') + 1);
        window.history.back();
        return false;
    },
})