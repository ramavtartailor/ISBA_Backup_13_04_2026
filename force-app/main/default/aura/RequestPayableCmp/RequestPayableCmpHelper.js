({
	getPayableList : function(component, event, pageNo) {
		component.set("v.showSpinner",true);
        var limit = component.get("v.limit");        
        
        var action = component.get("c.getPayables");
        action.setParams({
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state'+state);
            if(state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                var totalNumberOfRecords = result.totalRecords;
                var noOfPAges = Math.ceil(totalNumberOfRecords / limit);                
                var arry = [];
                for(let i = 1; i <= noOfPAges; i++){
                    arry.push(i);
                } 
                
                this.setPayableList(component, event, pageNo, result.Payables, totalNumberOfRecords);
                
                console.log(arry);
                component.set("v.totalPages",arry);
                component.set("v.totalNumOfRecords",totalNumberOfRecords);
                component.set("v.PayablesList",result.Payables);
            }
            else{
                component.set("v.showSpinner",false);
                var errors = response.getError();
                if (errors) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "error",
                        "title": "Error!",
                        "message": errors[0].message
                    });
                    toastEvent.fire();
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "error",
                        "title": "Error!",
                        "message": "Unknown error"
                    });
                    toastEvent.fire();
                    console.log("Unknown error");
                }                
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
	},
    setPayableList: function(component, event, pageNo, Payables, numOfRecords) {
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
            payableArray.push(Payables[i]);
        }
        component.set("v.Payables",payableArray);
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