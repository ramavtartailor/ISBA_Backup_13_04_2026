({
	// function call on component Load
    doInit: function(component, event, helper) {
        helper.init(component, event);
    },
    goToAllAttendees : function(component, event, helper) { 
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:Account_CLE_AttendancesComponent",
            componentAttributes: {
                recordId: component.get("v.recordId"),
                allRecords: true
            }
        });
        evt.fire();
    },
    navigateToAccount : function(component, event, helper) { 
        window.open("/"+component.get("v.recordId"), "_self");
    },
    navigateToAttendees: function(component, event, helper) { 
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "CLE_Attendance__c"
        });
        homeEvent.fire();
    },
})