({
	closeModel : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
	},
    runReport : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var accountId;
        if(component.get("v.sobjecttype") == 'Account'){
            accountId = recordId;
        }else if(component.get("v.sobjecttype") == 'Policy__c'){
            accountId = component.get("v.recordObj.Account__c");
        }else if(component.get("v.sobjecttype") == 'Policy_Claim__c'){
            accountId = component.get("v.recordObj.Account__c");
        }
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        //window.location.href = "/lightning/r/Report/" + $A.get("$Label.c.Claim_Loss_Run_report") +"/view?fv0=" + accountId + "&fv1=LAST%20" + component.get("v.numberOfYears") + "%20YEARS";
        window.location.href = "/apex/ReportPdf?fv0=" + accountId + "&fv1=LAST%20" + component.get("v.numberOfYears") + "%20YEARS";
	}
})