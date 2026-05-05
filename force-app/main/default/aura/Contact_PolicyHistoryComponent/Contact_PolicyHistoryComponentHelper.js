({
	 init: function(component, event) {
        
        var RowItemList = component.get("v.PoliciesList");
        var action = component.get("c.getData");
        
        action.setParams({
            "recId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var results = response.getReturnValue();
                console.log("results =>",results);
                var allPoliciesRows = results.lawyers;
                for (var indexVar = 0; indexVar < allPoliciesRows.length; indexVar++) {
                    RowItemList.push({
                        'sobjectType': 'Policy__c',
                        'Name': allPoliciesRows[indexVar].Policy__r.Name,
                        'Step__c': allPoliciesRows[indexVar].Step__c,
                        'Premium__c': allPoliciesRows[indexVar].Premium__c,
                        'Policy_Number__c': allPoliciesRows[indexVar].Policy__r.Policy_Number__c,
                        'Effective_Date__c':allPoliciesRows[indexVar].Policy__r.Effective_Date__c,
                        'Premium_Amount__c':allPoliciesRows[indexVar].Policy__r.Premium_Amount__c,
                        'Id':allPoliciesRows[indexVar].Policy__c,
                        'Status__c':allPoliciesRows[indexVar].Policy__r.Status__c,
                        'Limits__c':allPoliciesRows[indexVar].Policy__r.Limits__c,
                        'Total_Credit__c':allPoliciesRows[indexVar].Policy__r.Total_Credit__c,
                        'Deductible__c':allPoliciesRows[indexVar].Policy__r.Deductible__c
                    });
                    if(!component.get("v.allRecords") && indexVar == 5){
                        break;
                    }
                }
                component.set("v.policyLawyer", results.lawyerName);
                component.set("v.PoliciesList", RowItemList);
                component.set("v.totalPolicies", allPoliciesRows.length);
                
            }
        });
        
        $A.enqueueAction(action);               
            
    },
})