({
	RecalculatePaymentsHelper : function(component) {
		var action = component.get("c.RecalculatePayments");
         action.setParams({
             recId : component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if(state=='SUCCESS'){
                var result = response.getReturnValue();
                console.log('result -> ', result);
                $A.get("e.force:closeQuickAction").fire();
            }else{
                this.showToast("Success!","Scheduled Payments Recalculated Successfully",'success')
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