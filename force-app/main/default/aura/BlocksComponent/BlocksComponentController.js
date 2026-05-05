({
     
    // function call on component Load
    doInit: function(component, event, helper) {
        component.set("v.spinner", true); 
        var pageNumber = component.get("v.PageNumber");  
        helper.init(component, event, pageNumber);
    },
    Cancel: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();
    },
    refresh : function(component, event, helper) {
         component.set("v.spinner", true); 
        var pageNumber = component.get("v.PageNumber");  
        helper.init(component, event, pageNumber);
    },
    navigateToBlock: function(component, event, helper) { 
        var index = event.getParam("indexVar");    
        var AllRowsList = component.get("v.BlocksList");
        if(AllRowsList[index].Id!=null && AllRowsList[index].Id!=''){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": AllRowsList[index].Id
            });
            navEvt.fire();
        }
    },
    newBlock: function(component, event, helper) {
         component.set("v.spinner", true); 
        component.set("v.BlockRec",null);
         var action = component.get("c.getRecord");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.BlockRec",response.getReturnValue());
            } 
        });
         component.set("v.spinner", false); 
        $A.enqueueAction(action);
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
    },
    sortByDate: function(component, event, helper) {
        component.set("v.spinner", true); 
       // set current selected header field on selectedTabsoft attribute.        
       component.set("v.selectedTabsoft", 'CreatedDate');
       // call the helper function with pass sortField Name      
       helper.sortHelper(component, event, 'CreatedDate');
    },
    changeStatus : function(component, event, helper) { 
        component.set("v.spinner", true); 
        var index = event.getParam("indexVar");
        var AllRowsList = component.get("v.BlocksList");
        if(AllRowsList[index].Id!=null && AllRowsList[index].Id!=''){
            helper.statusChangeHelper(component, event , AllRowsList[index].Id);
        }
    },
    handleNext: function(component, event, helper) {
        component.set("v.spinner", true); 
        var pageNumber = component.get("v.PageNumber");  
        pageNumber++;
        helper.init(component, event, pageNumber);
    },
     
    handlePrev: function(component, event, helper) {
        component.set("v.spinner", true); 
        var pageNumber = component.get("v.PageNumber");  
        pageNumber--;
        helper.init(component, event, pageNumber);
    },
    onSelectChange: function(component, event, helper) {
        component.set("v.spinner", true); 
        var page = 1
        helper.init(component, event, page);
    },
    handleSuccess : function(component, event, helper) {
       
        component.set("v.spinner",true);
        
        var action = component.get("c.saveBlocks");
        action.setParams({"recordId": component.get("v.recordId"),"objBlocks" : component.get("v.BlockRec")});
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
        component.set("v.spinner", true); 
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
        component.set("v.spinner", false); 
    },
})