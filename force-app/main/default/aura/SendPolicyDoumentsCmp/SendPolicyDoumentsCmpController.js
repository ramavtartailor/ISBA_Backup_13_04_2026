({
    doInit : function(component, event, helper) {
        helper.getData(component,event,helper, 1);        
    },
    Previous :function (component, event, helper) {
        component.set("v.showSpinner",true);
        var pageNo = component.get("v.pageNumber"); 
        component.set("v.allSelected",false);
        component.set("v.pageNumber",parseInt(pageNo)-1);
        helper.setdataInList(component, event, parseInt(pageNo)-1, component.get("v.dataList"), component.get("v.totalNumOfRecords"));
        component.set("v.showSpinner",false);
    },
    onSelect :function (component, event, helper) {
        component.set("v.showSpinner",true);
        component.set("v.allSelected",false);
        var pageNo = component.get("v.pageNumber");
        component.set("v.pageNumber",parseInt(pageNo));
        helper.setdataInList(component, event, pageNo, component.get("v.dataList"), component.get("v.totalNumOfRecords"));
        component.set("v.showSpinner",false);
    },
    Next :function (component, event, helper) {
        component.set("v.showSpinner",true);
        component.set("v.allSelected",false);
        var pageNo = component.get("v.pageNumber"); 
        component.set("v.pageNumber",parseInt(pageNo)+1);
        helper.setdataInList(component, event, parseInt(pageNo)+1, component.get("v.dataList"), component.get("v.totalNumOfRecords"));
        component.set("v.showSpinner",false);
    },
    handleSelect:function (component, event, helper) {
        component.set("v.showSpinner",true);
        var val = event.getSource().get("v.checked");
        var data = component.get("v.data");
        for(let x of data){
            x.isSelected = val;
        }
        component.set("v.data",data);
        component.set("v.showSpinner",false);
    },
    sendDocs : function (component, event, helper) {
        component.set("v.showSpinner",true);
        var dataList = component.get("v.dataList");
        var selectedIds = [];
        for(let x of dataList){
            if(x.isSelected){
                selectedIds.push(x.Id);
            }
        }
        console.log('selectedIds => ',selectedIds);
        if(selectedIds && selectedIds.length > 0){
            console.log('selectedIds ====> ',selectedIds);
            
            var action = component.get("c.runBatch");
            action.setParams({
                ids : selectedIds
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('state:', state);
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    helper.showToast('The Send Policy process is running in the background for further information, please refer to Job ID: '+result+'.', "Info!", "info");
                    var pageNo = component.get("v.pageNumber");
                    helper.getData(component,event,helper, pageNo);
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log('Error => ',errors[0].message);
                            helper.showToast(errors[0].message, "Error!", "error");
                        }
                    } 
                }	            
                component.set("v.showSpinner",false);
            });
            $A.enqueueAction(action); 
        }
        else{
            helper.showToast("Please select the Policy you would like to send documents for.", "Error!", "error");
            component.set("v.showSpinner",false);
        }
        
    }
})