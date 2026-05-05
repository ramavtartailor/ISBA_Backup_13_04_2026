({
     
    // function call on component Load
    doInit: function(component, event, helper) {
        helper.init(component, event);
    },
    navigateToPolicyLawyer: function(component, event, helper) { 
        var index = event.getParam("indexVar");    
        var AllRowsList = component.get("v.transactionList");
        if(AllRowsList[index].Id!=null && AllRowsList[index].Id!=''){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": AllRowsList[index].ID
            });
            navEvt.fire();
        }
    },
    navigateToPolicy: function(component, event, helper) { 
        var index = event.getParam("indexVar");    
        var AllRowsList = component.get("v.transactionList");
        if(AllRowsList[index].Id!=null && AllRowsList[index].Id!=''){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": AllRowsList[index].Policy__c
            });
            navEvt.fire();
        }
    },
    goToAllTransaction : function(component, event, helper) { 
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:TransactionComponent",
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