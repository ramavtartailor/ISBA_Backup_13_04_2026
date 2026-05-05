({
     
    // function call on component Load
    doInit: function(component, event, helper) {
        component.set("v.spinner", true); 
         helper.init(component, event);
    },
   sortByDate: function(component, event, helper) {
       // set current selected header field on selectedTabsoft attribute.        
       component.set("v.selectedTabsoft", 'CreatedDate');
       // call the helper function with pass sortField Name      
       helper.sortHelper(component, event, 'CreatedDate');
    },
    sortByName: function(component, event, helper) {
       // set current selected header field on selectedTabsoft attribute.        
       component.set("v.selectedTabsoft", 'Name');
       // call the helper function with pass sortField Name      
       helper.sortHelper(component, event, 'Name');
    },
    sortByCreatedName: function(component, event, helper) {
       // set current selected header field on selectedTabsoft attribute.        
       component.set("v.selectedTabsoft", 'Created_By_Name__c');
       // call the helper function with pass sortField Name      
       helper.sortHelper(component, event, 'Created_By_Name__c');
    },
    sortByType: function(component, event, helper) {
       // set current selected header field on selectedTabsoft attribute.        
       component.set("v.selectedTabsoft", 'Type__C');
       // call the helper function with pass sortField Name      
       helper.sortHelper(component, event, 'Type__C');
    },
    sortByStatus: function(component, event, helper) {
       // set current selected header field on selectedTabsoft attribute.        
       component.set("v.selectedTabsoft", 'Status__C');
       // call the helper function with pass sortField Name      
       helper.sortHelper(component, event, 'Status__C');
    },
    sortBySubject: function(component, event, helper) {
       // set current selected header field on selectedTabsoft attribute.        
       component.set("v.selectedTabsoft", 'Subject__c');
       // call the helper function with pass sortField Name      
       helper.sortHelper(component, event, 'Subject__c');
    },
    
    Cancel: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();
    },
    ExportNotes: function(component, event, helper) {
        window.open("/apex/ExportNotes?recordId=" + component.get("v.recordId") + "&selectedFilterValue=" + component.get("v.selectedFilterValue") + "&selectedNoteTypeFilterValue=" + component.get("v.selectedNoteTypeFilterValue"),'_blank');
    },
    navigateToNote: function(component, event, helper) { 
        var index = event.getParam("indexVar");    
        var AllRowsList = component.get("v.NotesList");
        if(AllRowsList[index].Id!=null && AllRowsList[index].Id!=''){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": AllRowsList[index].Id
            });
            navEvt.fire();
        }
    },
    newNote: function(component, event, helper) {
        // helper.newNoteFunc(component, event);
        
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
    },
    handleCheck : function(component, event, helper) {
        var isChecked = component.find("CreateTask").get("v.checked");
        var isReminderChecked = component.find("ReminderSet").get("v.checked");
        component.set("v.NoteRec.Create_Task__c", isChecked);
        component.set("v.NoteRec.Reminder_Set__c", isReminderChecked);
    },
    handleSuccess : function(component, event, helper) {
       
        component.set("v.spinner",true);
        
        if(component.get("v.NoteRec").Task_Owner__c ==null || component.get("v.NoteRec").Task_Owner__c == ''){
            component.get("v.NoteRec").Task_Owner__c = null;
        }
        var action = component.get("c.saveNotes");
        action.setParams({"recordId": component.get("v.recordId"),"objNotes" : component.get("v.NoteRec")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                if(returnVal == 'Success'){
                    component.set("v.reloadForm", false);
                    component.set("v.reloadForm", true);
                    var action1 = component.get("c.doInit");
                    $A.enqueueAction(action1);
                    var cmpTarget = component.find('Modalbox');
                    var cmpBack = component.find('Modalbackdrop');
                    $A.util.removeClass(cmpBack,'slds-backdrop--open');
                    $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
                  
                }
                else{
                   
                     var tOut = setTimeout(function(){
                        clearTimeout(tOut);
                        component.set("v.showError", false);
                    }, 5000);
                    
                    component.set("v.spinner",false);
                    component.set("v.showError", true);
                    component.set("v.status",response.getReturnValue());
                }
            }
             else{
                 component.set("v.spinner",false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMessage = errors[0].message;
                        component.set("v.status",errorMessage);
                    }
                } 
            }
            
        });
        $A.enqueueAction(action);
        
       window.scroll(0, 0);
    },
  
    onCancel: function(component, event, helper) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
},
    
    handleFilterChange: function(component, event, helper) {
        component.set("v.spinner", true); 
        helper.handleFilterChangeFunc(component, event);
        window.scroll(0, 0);
    },
     
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },
    handleNext: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.get("v.PageSize");  
        pageNumber++;
        component.set("v.spinner", true);
        helper.loadMore(component, pageNumber, pageSize);
        window.scroll(0, 0);
    },
     
    handlePrev: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.get("v.PageSize");
        pageNumber--;
        component.set("v.spinner", true);
        helper.loadMore(component, pageNumber, pageSize);
        window.scroll(0, 0);
    },
    
})