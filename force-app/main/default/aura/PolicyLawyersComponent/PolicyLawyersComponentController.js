({
     
    // function call on component Load
    doInit: function(component, event, helper) {
        helper.init(component, event);
    },
    navigateToPolicyLawyer: function(component, event, helper) { 
        var index = event.getParam("indexVar");    
        var AllRowsList = component.get("v.PolicyLawyersList");
        if(AllRowsList[index].Id!=null && AllRowsList[index].Id!=''){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": AllRowsList[index].Lawyer_Contact_Id__c
            });
            navEvt.fire();
        }
    },
    navigateToPolicy: function(component, event, helper) { 
        var index = event.getParam("indexVar");    
        var AllRowsList = component.get("v.PolicyLawyersList");
        if(AllRowsList[index].Id!=null && AllRowsList[index].Id!=''){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": AllRowsList[index].Policy__c
            });
            navEvt.fire();
        }
    },
    goToAllLawyers : function(component, event, helper) { 
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:PolicyLawyersComponent",
            componentAttributes: {
                recordId: component.get("v.recordId"),
                allRecords: true
            }
        });
        evt.fire();
    },
    navigateToAccount: function(component, event, helper) { 
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();
    },
    navigateToAccounts: function(component, event, helper) { 
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Account"
        });
        homeEvent.fire();
    },
})