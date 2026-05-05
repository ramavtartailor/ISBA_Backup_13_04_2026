({
    doInit: function(component, event, helper) {
        component.set("v.showSpinner",true);
        var action = component.get("c.getInstance");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state'+state);
            if(state == "SUCCESS") {
                component.set("v.Payable",response.getReturnValue());
                component.set("v.showSpinner",false);
                helper.getPayableList(component, event, 1);
            }
            
        });
        $A.enqueueAction(action);
    },
    closeModel: function(component, event, helper) {
        window.history.back();
    },
    Save: function(component, event, helper) {
        component.set("v.showSpinner",true);
        
        var PayableObj = component.get("v.Payable");
        
        console.log('PayableObj ==> ', PayableObj);
        
        var validationFlag = false;
        var errorMsg='';
        
        if(PayableObj.Amount == 'undefined' || PayableObj.Amount == null || PayableObj.Amount == '' || PayableObj.Amount.length == 0 || parseFloat(PayableObj.Amount) == 0){
            validationFlag = true;
            errorMsg = 'Please Fill the Amount';
        }else if(PayableObj.PaymentRef == 'undefined' || PayableObj.PaymentRef == null || PayableObj.PaymentRef == '' || PayableObj.PaymentRef.length == 0){
            validationFlag = true;
            errorMsg = 'Please Fill the Payment Reference';
        }else if(PayableObj.DueDate == 'undefined' || PayableObj.DueDate == null || PayableObj.DueDate == '' || PayableObj.DueDate.length == 0 ){
            validationFlag = true;
            errorMsg = 'Please Fill due date';
        }
        
        if(!validationFlag){
            var action = component.get("c.createPayable");
            
            action.setParams({
                contentDocId : component.get("v.contentDocIds"),
                reqWrp : component.get("v.Payable")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state == "SUCCESS"){
                    component.set("v.showSpinner",false); 
                    helper.showToast("Request Payable Created.","Success!", "success");
                    helper.getPayableList(component, event, 1);
                    //window.history.back();
                }
                else{
                    component.set("v.showSpinner",false);
                    var errors = response.getError();
                    if (errors) {
                        helper.showToast(errors[0].message,"Error!", "error");
                    } else {
                        helper.showToast( "Unknown error","Error!", "error");
                    }                    
                }
            });
            $A.enqueueAction(action);
            
        }
        else{
            component.set("v.showSpinner",false);
            helper.showToast(errorMsg,"Error!", "error");
        }
    },
    openModal : function (component, event, helper) {
        var recId = event.target.closest("[data-id]").dataset.id;
        var recName = event.target.closest("[data-id]").dataset.name;
        
        component.set("v.PayableIdforDeletion",recId);
        component.set("v.PayableName",recName);
        component.set("v.showModal", true);
    },
    closeModal : function (component, event, helper) {
        component.set("v.showModal", false);
        component.set("v.PayableIdforDeletion",'');
        component.set("v.PayableName",'');
    },
    handleDelete : function (component, event, helper) {
        component.set("v.showSpinner",true);
        var recId = component.get("v.PayableIdforDeletion");
        var action = component.get("c.deletePayable");
        
        action.setParams({
            recId : recId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state'+state);
            if(state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                component.set("v.showModal", false);
                component.set("v.PayableIdforDeletion",'');
                component.set("v.PayableName",'');
                
                helper.showToast("Record Deleted Successfully.","Success!", "success");
                var pageNo = component.get("v.pageNumber");
                helper.getPayableList(component, event, pageNo);
            }
            else{
                component.set("v.showSpinner",false);
                var errors = response.getError();
                if (errors) {
                    helper.showToast(errors[0].message,"Error!", "error");
                } else {
                    helper.showToast( "Unknown error","Error!", "error");
                }                
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },
    Previous :function (component, event, helper) {
        var pageNo = component.get("v.pageNumber"); 
        component.set("v.pageNumber",parseInt(pageNo)-1);
        helper.setPayableList(component, event, parseInt(pageNo)-1, component.get("v.PayablesList"), component.get("v.totalNumOfRecords"));
    },
    onSelect :function (component, event, helper) {
        var pageNo = component.get("v.pageNumber");
        component.set("v.pageNumber",parseInt(pageNo));
        helper.setPayableList(component, event, pageNo, component.get("v.PayablesList"), component.get("v.totalNumOfRecords"));
    },
    Next :function (component, event, helper) {
        var pageNo = component.get("v.pageNumber"); 
        component.set("v.pageNumber",parseInt(pageNo)+1);
        helper.setPayableList(component, event, parseInt(pageNo)+1, component.get("v.PayablesList"), component.get("v.totalNumOfRecords"));
    },
    handleUploadFinished: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");
        console.log('uploadedFiles == > ', uploadedFiles);
		let docIds = []
        let fileNames = []
        uploadedFiles.forEach(file => 
                              { docIds.push(file.documentId);
                               fileNames.push(file.name);
                              });
        component.set("v.contentDocIds", docIds);
        component.set("v.FileNames", fileNames);                               
    },                                       
})