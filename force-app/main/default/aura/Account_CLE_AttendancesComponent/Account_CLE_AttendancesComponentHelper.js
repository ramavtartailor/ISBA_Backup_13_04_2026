({
	init: function(component, event) {
        var action = component.get("c.getCLE_Attendances");
        
        action.setParams({
            "recId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var results = response.getReturnValue();
                console.log("results =>",results);
                var cleAttendees = results.cleAttendees;         
                component.set("v.AttendeeList", cleAttendees);
                component.set("v.account", results.recName);
                component.set("v.totalAttendees", cleAttendees.length);                
            }
        });
        
        $A.enqueueAction(action);               
            
    },
})