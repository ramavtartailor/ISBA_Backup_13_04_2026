({
    showToast : function(msg, title, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    }
})