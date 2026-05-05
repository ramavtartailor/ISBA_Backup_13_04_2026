({
    init: function(component, event) {
        
        var RowItemList = component.get("v.ClaimList");
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
                        'Policy__c':allClaimsRows[indexVar].Policy__c,
                        'Claim_Status__c':allClaimsRows[indexVar].Claim_Status__c,
                        'GL_5010__c':Math.abs(allClaimsRows[indexVar].GL_5010__c),
                        'GL_5035__c':Math.abs(allClaimsRows[indexVar].GL_5035__c),
                        'GL_5000__c':Math.abs(allClaimsRows[indexVar].GL_5000__c),
                        'GL_5030__c':Math.abs(allClaimsRows[indexVar].GL_5030__c),
                        'ClaimCloseDAte__c':allClaimsRows[indexVar].ClaimCloseDAte__c,
                        'Lawyer_Name__c':allClaimsRows[indexVar].Lawyer_Name__c,
                        'LAE_Incurred_Total__c':allClaimsRows[indexVar].LAE_Incurred_Total__c,
                        'Loss_Incurred_Total__c':allClaimsRows[indexVar].Loss_Incurred_Total__c,
                        'Incurred_Total__c':allClaimsRows[indexVar].Incurred_Total__c,
                        'LAEPay__c':allClaimsRows[indexVar].LAEPay__c,
                        'Loss_Res__c':allClaimsRows[indexVar].Loss_Res__c
                    });
                    if(!component.get("v.allRecords") && indexVar == 5){
                        break;
                    }
                }
                component.set("v.ClaimList", RowItemList);
                component.set("v.totalClaims", allClaimsRows.length);
                
            }
        });
        
        $A.enqueueAction(action);               
            
    },
})