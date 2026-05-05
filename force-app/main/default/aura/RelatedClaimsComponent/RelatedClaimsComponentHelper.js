({
    init: function(component, event) {
        
        var action1 = component.get("c.typeOfRecord");
        action1.setParams({
            "recordId": component.get("v.recordId")
        });
        
        action1.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() == 'Policy__c'){
                    component.set("v.forApplication", true);
                }
                
                
                var RowItemList = component.get("v.ClaimsList");
                var action = component.get("c.getClaims");
                
                action.setParams({
                    "recordId": component.get("v.recordId"),
                    "allRecords" : component.get("v.allRecords")
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var allClaimsRows = response.getReturnValue();
                        for (var indexVar = 0; indexVar < allClaimsRows.length; indexVar++) {
                            RowItemList.push({
                                'sobjectType': 'Policy_Claim__c',
                                'Name': allClaimsRows[indexVar].Name,
                                'Policy_Number__c': allClaimsRows[indexVar].Policy__r.Name,
                                'File_Type__c':allClaimsRows[indexVar].File_Type__c,
                                'Report_Date__c':allClaimsRows[indexVar].Report_Date__c,
                                'Id':allClaimsRows[indexVar].Id,
                                'Occur_Date__c':allClaimsRows[indexVar].Occur_Date__c,
                                'Claim_Handler_Status__c':allClaimsRows[indexVar].Claim_Handler_Status__c,
                                'Policy__c':allClaimsRows[indexVar].Policy__c,
                                'Claim_Close_Status__c':allClaimsRows[indexVar].Claim_Close_Status__c
                            });
                            component.set("v.claimNumber", allClaimsRows[indexVar].Name);
                            if(!component.get("v.allRecords") && indexVar == 5){
                                break;
                            }
                        }
                        component.set("v.ClaimsList", RowItemList);
                        component.set("v.totalClaims", allClaimsRows.length);
                        
                    }
                });
                
                $A.enqueueAction(action);               
            }
        });
        
        $A.enqueueAction(action1);
    },
})