({
	doInit : function(component, event, helper) {
        console.log('recID -> ',component.get('v.recordId'));
		var action = component.get("c.getDetails");
         action.setParams({
             recId : component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if(state=='SUCCESS'){
                var result = response.getReturnValue();
                console.log('result -> ', result);
                if(!result){
                    helper.showToast("Error!","Schedule Payments are already calculated",'error');
                    $A.get("e.force:closeQuickAction").fire();
                }
            }else{
                helper.showToast("Error!","Some Error occured!!",'error');
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
	},
    
    handleYes: function(component, event, helper) {
		console.log('Yes clicked');
        helper.RecalculatePaymentsHelper(component);
	},
    
    handleNo: function(component, event, helper) {
		console.log('No clicked');
        $A.get("e.force:closeQuickAction").fire();
	},
})