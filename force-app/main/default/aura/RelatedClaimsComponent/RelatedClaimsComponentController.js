({
     
    // function call on component Load
    doInit: function(component, event, helper) {
        helper.init(component, event);
    },
    newRelatedClaim: function(component, event, helper) { 
        var actionAPI = component.find("quickActionAPI");
        var args = { actionName : "Policy_Claim__c.New_Related_Claim"};
        actionAPI.selectAction(args).then(function(result){
        }).catch(function(e) {
            console.error(e.errors);
        });
    },
    navigateToRowClaim: function(component, event, helper) { 
        var index = event.getParam("indexVar");    
        var AllRowsList = component.get("v.ClaimsList");
        if(AllRowsList[index].Id!=null && AllRowsList[index].Id!=''){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": AllRowsList[index].Id
            });
            navEvt.fire();
        }
    },
    navigateToPolicy: function(component, event, helper) { 
        var index = event.getParam("indexVar");    
        var AllRowsList = component.get("v.ClaimsList");
        if(AllRowsList[index].Id!=null && AllRowsList[index].Id!=''){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": AllRowsList[index].Policy__c
            });
            navEvt.fire();
        }
    },
    goToAllClaims : function(component, event, helper) { 
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:RelatedClaimsComponent",
            componentAttributes: {
                recordId: component.get("v.recordId"),
                allRecords: true
            }
        });
        evt.fire();
    },
    navigateToClaim: function(component, event, helper) { 
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();
    },
    navigateToClaims: function(component, event, helper) { 
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Policy_Claim__c"
        });
        homeEvent.fire();
    },
})