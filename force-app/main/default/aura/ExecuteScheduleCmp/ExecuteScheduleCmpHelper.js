({
	getPaymentHelper : function(component) {
        component.set("v.showSpinner",true);
		var action = component.get("c.getPayment");
         action.setParams({
             recId : component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if(state=='SUCCESS'){
                var result = response.getReturnValue();
                console.log('result -> ', result);
                this.showToast("Success!","Payment Schedule Paid Successfully",'success');
                $A.get("e.force:closeQuickAction").fire();
                window.location.reload();
                component.set("v.showSpinner",false);
            }else{
                this.showToast("Error!","Some Error Occured!!",'error');
            }
        });
        $A.enqueueAction(action);
	},
    
    showToast : function(title,msg,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type": type
        });
        toastEvent.fire();
    }
})