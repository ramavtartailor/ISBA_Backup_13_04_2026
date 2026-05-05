({
    createObjectData: function(component, event) {
        
    },
    init: function(component, event, pageNumber, sortField) {
        var pageSize = 20;
        var RowItemList = [];
        var action = component.get("c.getBlocks");
        
        action.setParams({
            "recordId": component.get("v.recordId"),
            "pageNumber": pageNumber,
            "pageSize": pageSize,
            'sortField': sortField,
            'isAsc': component.get("v.isAsc"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var allNotesRows = response.getReturnValue().blockList;
                for (var indexVar = 0; indexVar < allNotesRows.length; indexVar++) {
                    RowItemList.push({
                        'sobjectType': 'Application_Block__c',
                        'Name': allNotesRows[indexVar].Name,
                        'Status__c': allNotesRows[indexVar].Status__c,
                        'Subject__c':allNotesRows[indexVar].Subject__c,
                        'Description__c':allNotesRows[indexVar].Description__c,
                        'Id':allNotesRows[indexVar].Id,
                        'CreatedDate':allNotesRows[indexVar].CreatedDate,
                        'Created_By_Name__c':allNotesRows[indexVar].Created_By_Name__c
                    });
                }
                component.set("v.BlocksList", RowItemList);
                var resultData = response.getReturnValue();
                component.set("v.PageNumber", resultData.pageNumber);
                component.set("v.TotalRecords", resultData.totalRecords);
                component.set("v.RecordStart", resultData.recordStart);
                component.set("v.RecordEnd", resultData.recordEnd);
                component.set("v.TotalPages", Math.ceil(resultData.totalRecords / pageSize));
            }
            component.set("v.spinner", false); 
        });
        
        $A.enqueueAction(action);
    },
    sortHelper: function(component, event, sortFieldName) {  
        
        var currentDir = component.get("v.arrowDirection");
        if (currentDir == 'arrowdown') {
            // set the arrowDirection attribute for conditionally rendred arrow sign  
            component.set("v.arrowDirection", 'arrowup');
            // set the isAsc flag to true for sort in Assending order.  
            component.set("v.isAsc", true);
        } else {
            component.set("v.arrowDirection", 'arrowdown');
            component.set("v.isAsc", false);
        }
        // call the onLoad function for call server side method with pass sortFieldName 
        component.set("v.PageNumber",1);  
        var pageNumber = component.get("v.PageNumber");
        this.init(component, event,pageNumber, sortFieldName);
    },
    statusChangeHelper : function(component, event, recId) {
        var action = component.get("c.changeStatusMethod");
        action.setParams({
            "recordId": recId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var pageNumber = component.get("v.PageNumber");  
                this.init(component,event, pageNumber);
            } 
        });
        $A.enqueueAction(action);
    },
   
})