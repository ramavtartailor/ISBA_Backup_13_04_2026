({
     
    // function call on component Load
    doInit: function(component, event, helper) {
        helper.init(component, event);
    },
    navigateToRowClaim: function(component, event, helper) { 
        var index = event.getParam("indexVar");    
        var AllRowsList = component.get("v.ClaimList");
        if(AllRowsList[index].Id!=null && AllRowsList[index].Id!=''){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": AllRowsList[index].Id
            });
            navEvt.fire();
        }
    },
    goToAllClaims : function(component, event, helper) { 
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClaimHistoryComponent",
            componentAttributes: {
                recordId: component.get("v.recordId"),
                allRecords: true
            }
        });
        evt.fire();
    },
    navigateToPolicy: function(component, event, helper) { 
        var index = event.getParam("indexVar");    
        var AllRowsList = component.get("v.ClaimList");
        if(AllRowsList[index].Id!=null && AllRowsList[index].Id!=''){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": AllRowsList[index].Policy__c
            });
            navEvt.fire();
        }
    },
    navigateToClaims: function(component, event, helper) { 
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Policy_Claim__c"
        });
        homeEvent.fire();
    },
})