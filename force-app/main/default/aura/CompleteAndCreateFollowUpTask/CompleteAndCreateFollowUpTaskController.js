({
	doInit : function(component, event, helper) {
        
        var action = component.get("c.getRecordDetails");
        action.setParams({ "recordId" : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var wrapper = response.getReturnValue();
                var createRecordEvent = $A.get("e.force:createRecord");
                var defaultValues; 
                if(wrapper.parentRecordType  == 'Policy__c'){
                    defaultValues = {'Subject__c' : wrapper.subject,'Description__c' : wrapper.description,'Type__c' : wrapper.noteType,'Task_Owner__c' : wrapper.taskOwner,'Cloned_Task_Id__c' : component.get("v.recordId"),'Status__c' : 'Pending','Create_Task__c' : true,'Policy__c' : wrapper.parentRecordId }
                }else if(wrapper.parentRecordType  == 'Policy_Claim__c'){
                    defaultValues = {'Subject__c' : wrapper.subject,'Description__c' : wrapper.description,'Type__c' : wrapper.noteType,'Task_Owner__c' : wrapper.taskOwner,'Cloned_Task_Id__c' : component.get("v.recordId"),'Status__c' : 'Pending','Create_Task__c' : true,'Claim__c' : wrapper.parentRecordId }
                }else if(wrapper.parentRecordType  == 'Account'){
                    defaultValues = {'Subject__c' : wrapper.subject,'Description__c' : wrapper.description,'Type__c' : wrapper.noteType,'Task_Owner__c' : wrapper.taskOwner,'Cloned_Task_Id__c' : component.get("v.recordId"),'Status__c' : 'Pending','Create_Task__c' : true,'Account__c' : wrapper.parentRecordId }
                }else if(wrapper.parentRecordType  == 'Opportunity'){
                    defaultValues = {'Subject__c' : wrapper.subject,'Description__c' : wrapper.description,'Type__c' : wrapper.noteType,'Task_Owner__c' : wrapper.taskOwner,'Cloned_Task_Id__c' : component.get("v.recordId"),'Status__c' : 'Pending','Create_Task__c' : true,'Opportunity__c' : wrapper.parentRecordId }
                }
                createRecordEvent.setParams({ 
                    "entityApiName": "Note__c",
                    "recordTypeId": wrapper.recordTypeId,
                    'defaultFieldValues': defaultValues
                });
                createRecordEvent.fire();
                
            }
            else if (state === "INCOMPLETE") {
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        helper.showToast('Error',errors[0].message);
                        $A.get("e.force:closeQuickAction").fire();
                    }
                } else {
                    helper.showToast('Error','Unkown Error!');
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
            helper.hideSpinner(component);
        });
        $A.enqueueAction(action);
	}
})