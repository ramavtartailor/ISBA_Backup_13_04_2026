({
     
    // function call on component Load
    doInit: function(component, event, helper) {
        helper.init(component, event);
    },
    navigateToRowPolicy: function(component, event, helper) { 
        var index = event.getParam("indexVar");    
        var AllRowsList = component.get("v.PoliciesList");
        if(AllRowsList[index].Id!=null && AllRowsList[index].Id!=''){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": AllRowsList[index].Id
            });
            navEvt.fire();
        }
    },
    goToAllPolicies : function(component, event, helper) { 
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:PolicyHistoryComponent",
            componentAttributes: {
                recordId: component.get("v.recordId"),
                allRecords: true
            }
        });
        evt.fire();
    },
    navigateToPolicy: function(component, event, helper) { 
        var index = event.getParam("indexVar");    
        var AllRowsList = component.get("v.PoliciesList");
        if(AllRowsList[index].Id!=null && AllRowsList[index].Id!=''){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": AllRowsList[index].Id
            });
            navEvt.fire();
        }
    },
    navigateToPolicies: function(component, event, helper) { 
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Policy__c"
        });
        homeEvent.fire();
    },
})