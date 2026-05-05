({
    init: function(component, event) {
        var RowItemList = component.get("v.PolicyLawyersList");
        var action = component.get("c.getPolicyLawyers");
        
        action.setParams({
            "recordId": component.get("v.recordId"),
            "allRecords" : component.get("v.allRecords")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var allPolicyLawyerRows = response.getReturnValue();
                for (var indexVar = 0; indexVar < allPolicyLawyerRows.length; indexVar++) {
                    RowItemList.push({
                        'sobjectType': 'Policy_Lawyer__c',
                        'Lawyer_Name__c': allPolicyLawyerRows[indexVar].Lawyer_Name__c,
                        'Lawyer_Contact_Id__c': allPolicyLawyerRows[indexVar].Lawyer_Contact_Id__c,
                        'Prior_Act_Date__c':allPolicyLawyerRows[indexVar].Prior_Act_Date__c,
                        'ARDC_Number__c':allPolicyLawyerRows[indexVar].ARDC_Number__c,
                        'Id':allPolicyLawyerRows[indexVar].Id,
                        'ISBA_Number__c':allPolicyLawyerRows[indexVar].ISBA_Number__c,
                        'Rate_At__c':allPolicyLawyerRows[indexVar].Rate_At__c,
                        'Policy__c':allPolicyLawyerRows[indexVar].Policy__c,
                        'Policy_Number__c':allPolicyLawyerRows[indexVar].Policy__r.Name
                    });
                    component.set("v.accountName", allPolicyLawyerRows[indexVar].Account__r.Name);
                    if(!component.get("v.allRecords") && indexVar == 5){
                        break;
                    }
                }
                component.set("v.PolicyLawyersList", RowItemList);
                component.set("v.totalLawyers", allPolicyLawyerRows.length);
                
            }
        });
        
        $A.enqueueAction(action);
    },
})