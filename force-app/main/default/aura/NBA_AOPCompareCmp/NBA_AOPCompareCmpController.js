({
	doInit : function(component, event, helper) {
		component.set("v.spinner", true);
		var action = component.get("c.getAopData");
		action.setParams({
			recId : component.get("v.recordId")
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === 'SUCCESS') {
				var result = response.getReturnValue();
				let hasAop = false;
                var totalPercentage = 0;
                var hasPolicy = false;
                
                var customerAopMap = new Map();
                var policyAopList = [];
                
                for(let x of result) {
                    if(x.aop.AOP_Factor__c) {
                        hasAop = true;
                    }
                    
                    if (x.aop.Percentage__c) {
                       totalPercentage += x.aop.Percentage__c;
                       
                    }
                    
                    if (x.policyAop) {
                        hasPolicy = true;
                    }
                    if ( x.aop && x.aop.AOP_Factor__r && x.aop.AOP_Factor__r.Name ) {
                        customerAopMap.set( x.aop.AOP_Factor__r.Name, x.aop.Percentage__c);
                    }
                    
                    if (x.policyAop) {
                        policyAopList.push(x.policyAop);
                    }
                    
                }
                if (policyAopList.length === 0) {
                    component.set("v.showSyncBtn", false);
                    component.set("v.wrapper", result);
                    component.set("v.spinner", false);
                    return;
                }
				var hasDifference = false;
                if(policyAopList.length > 0){
                    for (let pol of policyAopList) {
                        if(pol.AOP__c){
                            let policyFactor = pol.AOP__r.Name;
                            let policyPct = pol.Percentage__c;
                            
                            // Case 1: Factor missing in Customer AOP
                            if (!customerAopMap.has(policyFactor)) {
                                hasDifference = true;
                                break;
                            }
                            let customerPct = customerAopMap.get(policyFactor);
                            if (customerPct - policyPct !=0) {
                                hasDifference = true;
                                break;
                            }
                        }
                    }
                }
                
                
                var isHundred=false;
                if(totalPercentage === 100)
                {
                    isHundred=true;
                }
                
                component.set("v.isHundredPercent", isHundred);
                console.log('Total AOP %:', totalPercentage);
                component.set("v.hasPolicyAop", hasPolicy);
                component.set("v.wrapper", result);
                
                component.set("v.showSyncBtn", hasDifference);
                
				component.set("v.hasAop", hasAop);
				component.set("v.wrapper", result);
				console.log('result:', JSON.stringify(result));
			} else if (state === 'INCOMPLETE') {
				// Code when Imcomplete
			} else if (state === 'ERROR') {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
                        helper.showToast('error', 'Error!', errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
			component.set("v.spinner", false);
		});
		$A.enqueueAction(action);
	},
	handleClick: function(component, event, helper) {
		component.set("v.spinner", true);
		var action = component.get("c.syncAopRecords");
		action.setParams({
			recId : component.get("v.recordId")
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === 'SUCCESS') {
				var result = response.getReturnValue();
				component.set("v.wrapper", result);
                component.set("v.showSyncBtn", false);
				console.log('result:', JSON.stringify(result));
			} else if (state === 'INCOMPLETE') {
				// Code when Imcomplete
			} else if (state === 'ERROR') {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
                        helper.showToast('error', 'Error!', errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
			component.set("v.spinner", false);
		});
		$A.enqueueAction(action);
	}
})