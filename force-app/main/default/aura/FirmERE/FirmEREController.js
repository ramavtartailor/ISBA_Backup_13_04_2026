({
	doInit : function(component, event, helper) {
        var action = component.get("c.get107Endorsements");
        action.setParams({
            policyId : component.get("v.recordId")
        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var RowItemList = [];
                var allRows = a.getReturnValue();
                for (var indexVar = 0; indexVar < allRows.length; indexVar++) {
                    RowItemList.push({
                        'sobjectType': 'Policy_Endorsement__c',
                        'Name': allRows[indexVar].Name,
                        'Endorsement_Number__c':allRows[indexVar].Endorsement_Number__c,
                        'Name_Of_Insured__c':allRows[indexVar].Name_Of_Insured__c,
                        'Coverage_Term__c':allRows[indexVar].Coverage_Term__c
                    });
                    component.set("v.has107Endorsements", true);
                }
                component.set("v.EndorsementList", RowItemList);
            }
        });
        $A.enqueueAction(action);
	}
})