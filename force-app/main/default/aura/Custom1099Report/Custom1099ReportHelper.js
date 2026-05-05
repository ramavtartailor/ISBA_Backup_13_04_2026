({
	showToast : function( title, message, type) {
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			title: title,
			message: message,
			type: type
		});
		toastEvent.fire();	
	},
	closeModalHelper : function (component, event) {
		component.set('v.is1099ByTypeModadOpen', false);
	},
	paginationHelper : function (component, result) {
		var pageSize = component.get("v.pageSize");
		let totalPages = Math.ceil(result.length / pageSize);
		component.set("v.totalPages", totalPages);
		let pageOptions = new Array();
		for(let i = 1; i <= totalPages; i++){
			pageOptions.push(i);
		}
		component.set("v.pageOptions", pageOptions);
		this.buildPage(component, result, 1);
	},
	buildPage : function(component, data, pageNumber) {
        var pageSize = component.get("v.pageSize");
       	component.set("v.currentPage",pageNumber);

        var start = (pageNumber - 1) * pageSize;
        var end = start + pageSize;

        component.set("v.pagedData", data.slice(start, end));
    },
	sortData : function(component, fieldName, sortDirection) {
		var data = component.get("v.wrapList");
		var reverse = sortDirection !== 'asc';
		data.sort(this.sortBy(fieldName, reverse));
		component.set("v.wrapList", data);
		//this.paginationHelper(component, data);
	},
	sortBy : function(field, reverse){
		var key = function(x) {
			if (typeof x[field] === 'string') {
				return x[field].toLowerCase();
			}
			return x[field]
		};
		reverse = !reverse ? 1 : -1;
		return function (a, b) {
			return a = key(a), b = key(b), reverse * ((a > b) - (b > a));

		}
	}
})