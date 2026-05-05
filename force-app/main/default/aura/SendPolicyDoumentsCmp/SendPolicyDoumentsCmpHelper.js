({    
    getData: function(component,event,helper, pageNo){
        component.set("v.showSpinner",true);
        var limit = component.get("v.limit");   
        
        var action = component.get("c.getDetails");
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                component.set("v.wrapper", resp);
                var result = resp.policyList;
                console.log(result);
                for(let x of result){
                    x.isSelected = false;
                }
                var totalNumberOfRecords = result.length;
                var noOfPAges = Math.ceil(totalNumberOfRecords / limit);                
                var arry = [];
                for(let i = 1; i <= noOfPAges; i++){
                    arry.push(i);
                } 
                
                this.setdataInList(component, event, pageNo, result, totalNumberOfRecords);
                
                console.log(arry);
                component.set("v.totalPages",arry);
                component.set("v.totalNumOfRecords",totalNumberOfRecords);
                component.set("v.dataList", result);
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
        });
        $A.enqueueAction(action);        
    },  
    setdataInList: function(component, event, pageNo, dataList, numOfRecords) {
        component.set("v.showSpinner",true);        
        var limit = component.get("v.limit");   
        var offset = parseInt(limit) *(parseInt(pageNo) - 1);
        var n = parseInt(limit) *(parseInt(pageNo));
        if(n >= numOfRecords){
            component.set("v.LastPage", true);
            n = numOfRecords;
        }else{            
            component.set("v.LastPage", false);
        }
        
        var payableArray = [];
        for(let i = offset; i < n; i++){
            payableArray.push(dataList[i]);
        }
        component.set("v.data",payableArray);
        component.set("v.showSpinner",false);
    },
    showToast : function( msg , title, type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    }
})