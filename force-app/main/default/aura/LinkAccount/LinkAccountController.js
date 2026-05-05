({
    doInit: function (component, event, helper){
        helper.getCurrentApplication(component, event);
        helper.searchAccounts(component, event);
    },
	closeModal: function (component, event, helper) {
		helper.closeModalHelper(component, null);
	},
	saveApp : function(component, event, helper) {
        let accountId = event.currentTarget.dataset.row;
        helper.updateAccount(component, event, accountId);
    },
    
    handleSearch : function(component, event, helper) {
        clearTimeout(component._debounceTimer);
        component._debounceTimer = setTimeout(function() {
            helper.searchAccounts(component, event);
        }, 100);
    },
})