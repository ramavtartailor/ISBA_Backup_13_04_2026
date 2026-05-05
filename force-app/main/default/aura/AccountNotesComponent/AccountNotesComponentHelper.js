({
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
        this.init(component, event, sortFieldName);
    },
    createObjectData: function(component, event) {
        
    },
    init: function(component, event, sortField) {
        var RowItemList = [];//component.get("v.NotesList");
        var action = component.get("c.getNotes");
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.get("v.PageSize");
        var offset = (pageNumber - 1) * pageSize;
        var recordEnd = pageSize * pageNumber;
        var recordStart = offset + 1;
        var selectedFilterValue = component.get("v.selectedFilterValue");
        if(selectedFilterValue==undefined ||selectedFilterValue==null ){
            selectedFilterValue ='';
        }
        //var limit = component.get("v.initialRows");
        action.setParams({
            //"rowLimit" :  limit,
            //"rowOffset" : 0,
            'sortField': sortField,
            'isAsc': component.get("v.isAsc"),
            "recordId": component.get("v.recordId"),
            "selectedFilterValue":selectedFilterValue,
            "pageNumber": pageNumber,
            "pageSize": pageSize,
            'objectName': 'Note__c',
            'field_apiname': 'Type__c',
            'allRequired': true
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var allNotesRows = response.getReturnValue().accountNotesWrapper;
                for (var indexVar = 0; indexVar < allNotesRows.length; indexVar++) {
                    RowItemList.push({
                        'sobjectType': 'Note__c',
                        'Name': allNotesRows[indexVar].name,
                        'Type__c': allNotesRows[indexVar].noteType,
                        'Status__c': allNotesRows[indexVar].status,
                        'Subject__c':allNotesRows[indexVar].subject,
                        'Description__c':allNotesRows[indexVar].description,
                        'Id':allNotesRows[indexVar].ids,
                        'CreatedDate':allNotesRows[indexVar].createdDate,
                        'Created_By_Name__c':allNotesRows[indexVar].createdByName,
                        'of_Attachments__c':allNotesRows[indexVar].numberOfAttachments,
                        'noteURL': '/'+allNotesRows[indexVar].ids,
                        'Due_Date__c':allNotesRows[indexVar].dueDate
                    });
                }
                var sobjName = response.getReturnValue().typeOfRecord;
                if(sobjName == 'Account'){
                    var opts = [
                        { value: "View Account Notes", label: "View Account Notes" }
                    ];
                    component.set("v.filterList", opts);
                }else if(sobjName == 'Policy__c'){
                    var opts = [
                        { value: "View All Policy Notes", label: "View All Policy Notes" },
                        { value: "View This Policy Notes", label: "View This Policy Notes" }
                    ];
                    component.set("v.filterList", opts);
                }else if(sobjName == 'Policy_Claim__c'){
                    var opts = [
                        { value: "View Claim Notes", label: "View Claim Notes" }
                    ];
                    component.set("v.filterList", opts);
                }else if(sobjName == 'AcctSeed__Billing__c'){
                    var opts = [
                        { value: "View Account Notes", label: "View Account Notes" }
                    ];
                    component.set("v.filterList", opts);
                } else if(sobjName == 'Customer_Application__c'){
                    var opts = [
                        { value: "View Online NBA Notes", label: "View Online NBA Notes" }
                    ];
                    component.set("v.filterList", opts);
                }
                var totalRows = response.getReturnValue().numberOfRows;
                
                if(totalRows < recordEnd){
                    recordEnd = totalRows;
                }
                component.set("v.TotalRecords", totalRows);
                component.set("v.PageNumber", pageNumber);
                component.set("v.RecordStart", recordStart);
                component.set("v.RecordEnd", recordEnd);
                component.set("v.TotalPages", Math.ceil(totalRows / pageSize));
                component.set("v.noteTypefilterList", response.getReturnValue().pickListValues);
                component.set("v.NotesList", RowItemList);
                component.set("v.NoteRec",response.getReturnValue().newNote);
                component.set("v.newNoteRecordTypeId",response.getReturnValue().newNoteRecordTypeId);
            }
            component.set("v.spinner", false);
        });
        
        $A.enqueueAction(action);
    },
    
    newNoteFunc: function(component, event) {
   
    },
    handleFilterChangeFunc : function(component, event) {
        //component.set("v.currentCount",10);
        //component.set("v.enableInfiniteLoading",true);
        var RowItemList = [];
        var action = component.get("c.getNotes");
        var pageNumber = 1;  
        var pageSize = component.get("v.PageSize");
        var offset = (pageNumber - 1) * pageSize;
        var recordEnd = pageSize * pageNumber;
        var recordStart = offset + 1;
        //var limit = component.get("v.initialRows");
        action.setParams({
            //"rowLimit" :  limit,
            //"rowOffset" : 0,
            "recordId": component.get("v.recordId"),
            "pageNumber": pageNumber,
            "pageSize": pageSize,
            "selectedFilterValue": component.get("v.selectedFilterValue"),
            "selectedNoteTypeFilterValue": component.get("v.selectedNoteTypeFilterValue")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var allNotesRows = response.getReturnValue().accountNotesWrapper;
                for (var indexVar = 0; indexVar < allNotesRows.length; indexVar++) {
                    RowItemList.push({
                        'sobjectType': 'Note__c',
                        'Name': allNotesRows[indexVar].name,
                        'Type__c': allNotesRows[indexVar].noteType,
                        'Status__c': allNotesRows[indexVar].status,
                        'Subject__c':allNotesRows[indexVar].subject,
                        'Description__c':allNotesRows[indexVar].description,
                        'Id':allNotesRows[indexVar].ids,
                        'CreatedDate':allNotesRows[indexVar].createdDate,
                        'Created_By_Name__c':allNotesRows[indexVar].createdByName,
                        'of_Attachments__c':allNotesRows[indexVar].numberOfAttachments,
                        'noteURL': '/'+allNotesRows[indexVar].ids,
                        'Due_Date__c':allNotesRows[indexVar].dueDate
                    });
                }
                var totalRows = response.getReturnValue().numberOfRows;
                
                if(totalRows < recordEnd){
                    recordEnd = totalRows;
                }
                component.set("v.TotalRecords", totalRows);
                component.set("v.PageNumber", pageNumber);
                component.set("v.RecordStart", recordStart);
                component.set("v.RecordEnd", recordEnd);
                component.set("v.TotalPages", Math.ceil(totalRows / pageSize));
                component.set("v.NotesList", RowItemList);
            }
            component.set("v.spinner", false); 
        });
        
        $A.enqueueAction(action);
    },
    loadMore : function(component, pageNumber, pageSize) {
        var RowItemList = [];
        var action = component.get("c.getNotes");
        var offset = (pageNumber - 1) * pageSize;
        var recordEnd = pageSize * pageNumber;
        var recordStart = offset + 1;
        action.setParams({
            "recordId": component.get("v.recordId"),
            "pageNumber": pageNumber,
            "pageSize": pageSize,
            "selectedFilterValue": component.get("v.selectedFilterValue")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var allNotesRows = response.getReturnValue().accountNotesWrapper;
                for (var indexVar = 0; indexVar < allNotesRows.length; indexVar++) {
                    RowItemList.push({
                        'sobjectType': 'Note__c',
                        'Name': allNotesRows[indexVar].name,
                        'Type__c': allNotesRows[indexVar].noteType,
                        'Status__c': allNotesRows[indexVar].status,
                        'Subject__c':allNotesRows[indexVar].subject,
                        'Description__c':allNotesRows[indexVar].description,
                        'Id':allNotesRows[indexVar].ids,
                        'CreatedDate':allNotesRows[indexVar].createdDate,
                        'Created_By_Name__c':allNotesRows[indexVar].createdByName,
                        'of_Attachments__c':allNotesRows[indexVar].numberOfAttachments,
                        'noteURL': '/'+allNotesRows[indexVar].ids,
                        'Due_Date__c':allNotesRows[indexVar].dueDate
                    });
                }
                component.set("v.NotesList", RowItemList);
                
                
                var totalRows = component.get("v.TotalRecords", totalRows);
                
                if(totalRows < recordEnd){
                    recordEnd = totalRows;
                }
                
                component.set("v.PageNumber", pageNumber);
                component.set("v.RecordStart", recordStart);
                component.set("v.RecordEnd", recordEnd);
                component.set("v.TotalPages", Math.ceil(totalRows / pageSize)); 
            }
            component.set("v.spinner", false);
        });
        
        $A.enqueueAction(action);
    }
})