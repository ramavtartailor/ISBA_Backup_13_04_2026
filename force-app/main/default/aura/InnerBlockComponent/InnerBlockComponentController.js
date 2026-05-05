({
	goToRecord : function(component, event, helper){
        component.getEvent("NavigateToBlockRecord").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    }, 
    statusChange : function(component, event, helper){
        component.getEvent("ChangeBlockStatus").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    },
})