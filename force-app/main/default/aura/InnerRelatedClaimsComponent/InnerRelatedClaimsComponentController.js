({
	goToPolicyRecord : function(component, event, helper){
        component.getEvent("NavigateToPolicyRecord").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    },
    goToClaimRecord : function(component, event, helper){
        component.getEvent("NavigateToRowClaimRecord").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    },
})