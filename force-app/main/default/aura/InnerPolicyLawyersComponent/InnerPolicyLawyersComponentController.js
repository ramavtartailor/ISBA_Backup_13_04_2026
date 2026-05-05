({
	goToPolicyRecord : function(component, event, helper){
        component.getEvent("NavigateToPolicyRecord").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    },
    goToPolicyLawyerRecord : function(component, event, helper){
        component.getEvent("NavigateToPolicyLawyerRecord").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    },
})