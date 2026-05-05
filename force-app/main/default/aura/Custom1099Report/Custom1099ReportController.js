({
	handle1099ByType : function(component, event, helper) {
		let row = event.currentTarget.dataset.row;
		component.set('v.reportType', row);
		component.set('v.is1099ByTypeModadOpen', row === '1099 by Type');
	},
	closeModal : function(component, event, helper) {
		helper.closeModalHelper(component, event);
	},
	handleRun1099Report : function (component, event, helper) {
		
		let reportType = component.get('v.reportType');
		let startDate = component.get('v.startDate');
		let endDate = component.get('v.endDate');
		if(startDate && endDate){
			component.set('v.isLoading', true);
			var action = component.get("c.RunReport");
			action.setParams({
				reportType: reportType,
				startDate: startDate,
				endDate: endDate
			});
			action.setCallback(this, function (response) {
				var state = response.getState();
				if (state === 'SUCCESS') {
					var result = response.getReturnValue();
					//helper.paginationHelper(component, result);
					component.set("v.wrapList", result);
					component.set("v.is1099ByType", true);
					helper.closeModalHelper(component, event);
				} else if (state === 'INCOMPLETE') {
					// Code when Imcomplete
				} else if (state === 'ERROR') {
					var errors = response.getError();
					if (errors) {
						if (errors[0] && errors[0].message) {
							console.log("Error message: " + errors[0].message);
							helper.showToast('Error!', errors[0].message, 'error');
						}
					} else {
						console.log("Unknown error");
					}
				}
				component.set('v.isLoading', false);
			});
			$A.enqueueAction(action);
		}
		else{
			helper.showToast('Error!', 'Please select start and end date', 'error');
		}
	},

	nextPage : function(component, event, helper) {
        helper.buildPage(component, component.get("v.wrapList"), (component.get("v.currentPage") + 1));
    },

    previousPage : function(component, event, helper) {
        helper.buildPage(component, component.get("v.wrapList"), component.get("v.currentPage") - 1);
    },
	onPageChange : function(component, event, helper) {
		helper.buildPage(component, component.get("v.wrapList"), component.get("v.currentPage"));
	},
	handleSort : function(component, event, helper) {
		let field = event.currentTarget.dataset.field;
		let isSort = component.get("v.isSort");
		let lastSort = component.get("v.LastSort");
		let sortDirection = '';
		if(lastSort === field){
			isSort = !isSort;
		}
		else{
			isSort = false;
			lastSort = field;
		}
		if (isSort == false) {
			sortDirection = 'asc';
		}else{
			sortDirection = 'desc';
		}
		component.set("v.isSort", isSort);
		component.set("v.LastSort", lastSort);
		helper.sortData(component, field, sortDirection);
	}
})