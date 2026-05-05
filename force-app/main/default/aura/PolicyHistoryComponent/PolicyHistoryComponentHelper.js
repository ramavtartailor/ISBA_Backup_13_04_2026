({
    init: function(component, event) {
        
        var RowItemList = component.get("v.PoliciesList");
        var action = component.get("c.getPolicies");
        
        action.setParams({
            "recordId": component.get("v.recordId"),
            "allRecords" : component.get("v.allRecords")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var allPoliciesRows = response.getReturnValue();
                for (var indexVar = 0; indexVar < allPoliciesRows.length; indexVar++) {
                    RowItemList.push({
                        'sobjectType': 'Policy__c',
                        'Name': allPoliciesRows[indexVar].Name,
                        'Policy_Number__c': allPoliciesRows[indexVar].Policy_Number__c,
                        'Effective_Date__c':allPoliciesRows[indexVar].Effective_Date__c,
                        'Premium_Amount__c':allPoliciesRows[indexVar].Premium_Amount__c,
                        'Id':allPoliciesRows[indexVar].Id,
                        'Expiration_Date__c':allPoliciesRows[indexVar].Expiration_Date__c,
                        'Status__c':allPoliciesRows[indexVar].Status__c,
                        'Limits__c':allPoliciesRows[indexVar].Limits__c,
                        'Deductible__c':allPoliciesRows[indexVar].Deductible__c
                    });
                    if(!component.get("v.allRecords") && indexVar == 5){
                        break;
                    }
                }
                component.set("v.PoliciesList", RowItemList);
                component.set("v.totalPolicies", allPoliciesRows.length);
                
            }
        });
        
        $A.enqueueAction(action);               
            
    },
})