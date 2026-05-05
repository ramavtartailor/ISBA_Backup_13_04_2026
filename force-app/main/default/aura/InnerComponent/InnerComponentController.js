({
	goToRecord : function(component, event, helper){
        component.getEvent("NavigateToNoteRecord").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    }, 
})