({
	doInit : function(component, event, helper) {
		component.set("v.loadingSpinner", true);
        var action = component.get('c.getGLList');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.glList", result.glList);
                component.set("v.glVar3List", result.glVar3List);
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
    handleUploadFinished : function(component, event, helper) {
        
        var file = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            component.set("v.loadingSpinner", true);
            var file = event.getSource().get("v.files")[0];
            //component.set("v.fileName", file['name']);
            if(file) {
                
                var reader = new FileReader();
                reader.readAsText(file, 'UTF-8');
                reader.onload = function(event) {
                    
                    var csv = event.target.result;
                    component.set("v.csvString", csv);
                    helper.handleGetRecords(component, event, helper, csv);
                }
            }
            component.set("v.loadingSpinner", false);
        }
    },
    handleClose: function(component, event, helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
	},
    handleSave: function(component, event, helper){
        component.set("v.loadingSpinner", true);
        var wrap = component.get("v.wrapper");
        var allValid = false;
        //if(wrap.length > 1){
        allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        /*}
        else{
            let inputCmp = component.find('field');
            inputCmp.showHelpMessageIfInvalid();
            allValid = inputCmp.get('v.validity').valid;
		}*/

        if (allValid) {
            console.log('wrap => '+JSON.stringify(wrap));
            var action = component.get('c.createPayableLines');
            action.setParams({
                recId : component.get("v.recordId"),
                wrapList : wrap
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state == "SUCCESS") {
                    helper.showSuccessToast(component, event, 'The Account Payable Lines have been imported successfully.');
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }else if(state === "ERROR"){
                    var errors = action.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            helper.showErrorToast(component, event, errors[0].message);
                        }
                    }
                }
                component.set("v.loadingSpinner", false);
            });
            $A.enqueueAction(action);
        } 
        else{
            component.set("v.loadingSpinner", false);
        }
    }
})