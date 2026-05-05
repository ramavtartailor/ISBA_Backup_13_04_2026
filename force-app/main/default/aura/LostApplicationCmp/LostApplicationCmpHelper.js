({
	initHelperMethod : function(component, event, helper) {
        component.set("v.spinner",true);
		var action = component.get("c.getPickListVal");
        action.setParams({
            
            strObjectName : 'Policy__c',
            recId : component.get("v.recordId"),
            strPicklistField : 'Lost_Reason__c'
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state'+state);
            if(state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                component.set("v.lostReasonList",result);
            }
            else{
                var msg = '';
                component.set("v.showSpinner",false);
                var errors = response.getError();
                if (errors) {
                    msg = errors[0].message;
                } else {
                    msg = "Unknown error";
                }  
                helper.showToast(msg, "Error!", 'error');
            }
            
            component.set("v.spinner",false);
        });
        $A.enqueueAction(action);
	},
    getDependentPicklist : function(component, event, helper) {
        component.set("v.spinner",true);
        component.set("v.lostReasonSub1List", []);
        component.set("v.lostReasonSub2List", []);
        component.set("v.lostReasonSub1",'');
        component.set("v.lostReasonSub2",'');
		var action = component.get("c.getPickListSubs");
        action.setParams({
            selectedValue : component.get("v.lostReason")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state'+state);
            if(state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                if(result.length == 1 && !(result[0].listValues)){
                    component.set("v.placeholder", result[0].placeholder);
                    component.set("v.isDescriptionReqired", result[0].isDesRequired);
                }
                else{
                    component.set("v.lostReasonSub1List",result);
                }
            }
            else{
                var msg = '';
                component.set("v.showSpinner",false);
                var errors = response.getError();
                if (errors) {
                    msg = errors[0].message;
                } else {
                    msg = "Unknown error";
                }  
                helper.showToast(msg, "Error!", 'error');
            }
            
            component.set("v.spinner",false);
        });
        $A.enqueueAction(action);
	},    
    setDependentPicklist : function(component, event, helper) {
        component.set("v.spinner",true);
        var sub1List = component.get("v.lostReasonSub1List");
        var selectVal = component.get("v.lostReasonSub1");
        var sub2List =[];
        for(let x of sub1List){
            if(x.val == selectVal){
                console.log(x);                
                if(x.listValues.length && x.listValues.length == 1){
                    component.set("v.placeholder", x.listValues[0].Placeholder__c);
                    component.set("v.isDescriptionReqired", x.listValues[0].Description_Required__c);
                    break;
                }
                   sub2List	 = x.listValues;
                break;
            }
        } 
        component.set("v.lostReasonSub2List", sub2List);
        component.set("v.spinner",false);
    },
    saveHelper : function(component, event, helper) {
        component.set("v.spinner",true);
		var action = component.get("c.save");
        action.setParams({
            recId : component.get("v.recordId"),       
            lostReason : component.get("v.lostReason"),
            lostReasonSub1 : component.get("v.lostReasonSub1"), 
            lostReasonSub2 : component.get("v.lostReasonSub2"), 
            discription : component.get("v.lostDescription")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state'+state);
            if(state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                 helper.showToast('Record Saved Successfully.', "Success!", 'success');
                
                $A.get("e.force:closeQuickAction").fire();
            }
            else{
                var msg = '';
                component.set("v.spinner",false);
                var errors = response.getError();
                if (errors) {
                    msg = errors[0].message;
                } else {
                    msg = "Unknown error";
                }  
                helper.showToast(msg, "Error!", 'error');
            }
            
            component.set("v.spinner",false);
        });
        $A.enqueueAction(action);
	},    
    showToast : function( msg , title, type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    }
})