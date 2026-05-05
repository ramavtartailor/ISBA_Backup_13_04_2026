({
    showToast : function(msg, title ,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,//"Success!",
            "type": type,//"success",
            "message": msg//"The record has been updated successfully."
        });
        toastEvent.fire();
    }
})