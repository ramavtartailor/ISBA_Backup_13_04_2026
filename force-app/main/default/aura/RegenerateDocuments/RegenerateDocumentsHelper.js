({
    showToast : function(type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if(type == 'Success'){
            toastEvent.setParams({
                "type": "success",
                "title": "Success!",
                "message": message
            });
        }else if(type=='Error'){
            toastEvent.setParams({
                "type": "error",
                "title": "Error!",
                "message": message
            });
        }
        toastEvent.fire();
    },
    showSpinner: function(cmp) {
        var cmpTarget = cmp.find('spinner');
        $A.util.removeClass(cmpTarget, 'slds-hide');
    },
    
    hideSpinner: function(cmp) {
        var cmpTarget = cmp.find('spinner');
        $A.util.addClass(cmpTarget, 'slds-hide');
    }
})