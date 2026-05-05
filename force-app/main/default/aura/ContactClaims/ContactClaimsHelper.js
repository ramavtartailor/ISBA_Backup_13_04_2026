({
    init: function(component, event) {
        
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
                    RowItemList.push(allClaimsRows[indexVar]);
                    if(!component.get("v.allRecords") && indexVar == 5){
                        break;
                    }
                }
                component.set("v.ClaimsList", RowItemList);
                component.set("v.totalClaims", allClaimsRows.length);
                
            }
        });
        
        $A.enqueueAction(action);               
            
    },
})