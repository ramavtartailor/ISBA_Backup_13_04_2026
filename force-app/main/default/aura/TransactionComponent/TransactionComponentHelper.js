({
    init: function(component, event) {
        var RowItemList = component.get("v.transactionList");
        var action = component.get("c.getTransactions");
        
        action.setParams({
            "recordId": component.get("v.recordId"),
            "allRecords" : component.get("v.allRecords")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var allTransactionRows = response.getReturnValue();
                
                for (var indexVar = 0; indexVar < allTransactionRows.length; indexVar++) {
                    RowItemList.push(allTransactionRows[indexVar]);
                    component.set("v.claimName", allTransactionRows[indexVar].parentName);
                    if(!component.get("v.allRecords") && indexVar == 5){
                        break;
                    }
                }
                component.set("v.transactionList", RowItemList);
                component.set("v.totalTransaction", allTransactionRows.length);
                
            }
        });
        
        $A.enqueueAction(action);
    },
})