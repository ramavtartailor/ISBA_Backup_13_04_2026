({
    doInit : function(component, event, helper) {
        var valuesList = [];
        
        var actionMain = component.get("c.getOpenTask");
        actionMain.setParams(
            {"objRecordId" : component.get("v.recordId")}
        );
        
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.todayDate', today);
        
        actionMain.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.valuesList", response.getReturnValue());
                if(component.get("v.valuesList") == null || component.get("v.valuesList").length == 0){
                    component.set("v.ListIsEmpty", true);
                }
            } else {
                console.log('Problem getting account, response state: ' + state);
            }
            
        });
        $A.enqueueAction(actionMain);
    },
    
    Navigate : function(component,event, helper) {
        
        var taskId = event.currentTarget.getAttribute("data-recId");
        
        window.location.href= "/"+taskId;
        
    }
    
})