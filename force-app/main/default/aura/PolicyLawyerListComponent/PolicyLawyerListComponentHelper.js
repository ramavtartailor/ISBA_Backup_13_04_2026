({
	init: function(component, event) {
        
        var RowItemList = component.get("v.LawyersList");
        var action = component.get("c.getPolicyLawyers");
        
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var allPolicyLawyerRows = response.getReturnValue();
                var primary = component.get("v.primary");
                var excess = component.get("v.excess");
                var fiveXfive = component.get("v.fiveXfive");
                var tenXten = component.get("v.tenXten");
                var adjMod = component.get("v.adjMod");
                var premium = component.get("v.premium");
                var credit = component.get("v.credit");
                for (var indexVar = 0; indexVar < allPolicyLawyerRows.length; indexVar++) {
                    RowItemList.push({
                        'sobjectType': 'Policy_Lawyer__c',
                        'Lawyer_Name__c': allPolicyLawyerRows[indexVar].Lawyer_Name__c,
                        'Prior_Act_Date__c':allPolicyLawyerRows[indexVar].Prior_Act_Date__c,
                        'Step__c':allPolicyLawyerRows[indexVar].Step__c,
                        'Overriding_Step_Value__c':allPolicyLawyerRows[indexVar].Overriding_Step_Value__c,
                        'Rate_At__c':allPolicyLawyerRows[indexVar].Rate_At__c,
                        'Term__c':allPolicyLawyerRows[indexVar].Term__c,
                        'Primary__c':(allPolicyLawyerRows[indexVar].Primary__c ? allPolicyLawyerRows[indexVar].Primary__c : 0),
                        'Excess__c':(allPolicyLawyerRows[indexVar].Excess__c ? allPolicyLawyerRows[indexVar].Excess__c : 0),
                        'X5_5__c':(allPolicyLawyerRows[indexVar].X5_5__c ? allPolicyLawyerRows[indexVar].X5_5__c : 0),
                        'X10_10__c':(allPolicyLawyerRows[indexVar].X10_10__c ? allPolicyLawyerRows[indexVar].X10_10__c : 0),
                        'ADJ_MOD__c':(allPolicyLawyerRows[indexVar].ADJ_MOD__c ? allPolicyLawyerRows[indexVar].ADJ_MOD__c : 0),
                        'Premium__c':(allPolicyLawyerRows[indexVar].Premium_Formula__c ? allPolicyLawyerRows[indexVar].Premium_Formula__c : 0),
                        'CLE_Credit__c':(allPolicyLawyerRows[indexVar].CLE_Credit__c ? allPolicyLawyerRows[indexVar].CLE_Credit__c : 0)
                    });
                    primary += parseFloat(allPolicyLawyerRows[indexVar].Primary__c ? allPolicyLawyerRows[indexVar].Primary__c : 0);
                    excess += parseFloat(allPolicyLawyerRows[indexVar].Excess__c ? allPolicyLawyerRows[indexVar].Excess__c : 0);
                    fiveXfive += parseFloat(allPolicyLawyerRows[indexVar].X5_5__c ? allPolicyLawyerRows[indexVar].X5_5__c : 0);
                    tenXten += parseFloat(allPolicyLawyerRows[indexVar].X10_10__c ? allPolicyLawyerRows[indexVar].X10_10__c : 0);
                    adjMod += parseFloat(allPolicyLawyerRows[indexVar].ADJ_MOD__c ? allPolicyLawyerRows[indexVar].ADJ_MOD__c : 0);
                    premium += parseFloat(allPolicyLawyerRows[indexVar].Premium_Formula__c ? allPolicyLawyerRows[indexVar].Premium_Formula__c : 0);
                    credit += parseFloat(allPolicyLawyerRows[indexVar].CLE_Credit__c ? allPolicyLawyerRows[indexVar].CLE_Credit__c : 0);
                }
                component.set("v.LawyersList", RowItemList);
                component.set("v.totalLawyers", allPolicyLawyerRows.length);
                component.set("v.primary",primary);
                component.set("v.excess",excess);
                component.set("v.fiveXfive",fiveXfive);
                component.set("v.tenXten",tenXten);
                component.set("v.adjMod",adjMod);
                component.set("v.premium",premium);
                component.set("v.credit",credit);
            }
        });
        
        $A.enqueueAction(action);
    }
})