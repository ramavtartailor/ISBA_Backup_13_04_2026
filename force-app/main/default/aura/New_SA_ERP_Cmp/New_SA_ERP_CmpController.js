({
    doInit : function(component, event, helper) {
        var policyId = component.get("v.recordId");
        console.log("policyId => ",policyId);
        
        var action = component.get("c.getLawyerList");
        action.setParams({
            policyId: policyId
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.policyLawyers", result);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error => ',errors[0].message);
                        component.set("v.ErrorMessage",errors[0].message);
                        component.set("v.showError",true);
                        const myTimeout = setTimeout(function() { 
                            helper.returnToPolicy(component.get("v.recordId"));
                        }, 3000);
                    }
                } 
            }	
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },
    handleChange: function(component, event, helper) {
        console.log('handleChange');
        var val = event.getSource().get("v.checked");
        component.set("v.disable",true);
        if(val){
            component.set("v.disable",false);
            var index = event.getSource().get("v.label");
            var lawyerList = component.get("v.policyLawyers");
            console.log('lawyerList => ',lawyerList);
            for(let x in lawyerList){
                console.log(x);
                if(x == index){
                    lawyerList[x].isChecked = true;
                }
                else{
                    lawyerList[x].isChecked = false;
                }
            }
            console.log('Updated lawyerList => ',lawyerList);
            
            component.set("v.policyLawyers",lawyerList);
        }
    }
    ,
    handleClose: function(component, event, helper) {
        helper.returnToPolicy(component.get("v.recordId"));
    }
    ,
    handleNext: function(component, event, helper) {
        component.set("v.showSpinner",true);
        var lawyerName = '';
        var lawyerId = '';
        var lawyerContId = '';
        var policyId = '';
        var lawyerList = component.get("v.policyLawyers");
        console.log('lawyerList => ',lawyerList);
        for(let x of lawyerList){
            console.log(x);
            if(x.isChecked){
                lawyerName = x.Lawyer__r.Name + ' (ERP)';
                lawyerId = x.Id;
                lawyerContId = x.Lawyer__r.Contact__c;
                policyId = x.Policy__c;
            }
        }
       window.open("/apex/ApplicationAndPolicy?returnURL=/apex/firmSearch&accountName=" + lawyerName +"&lawyer="+lawyerId+"&contact="+lawyerContId+"&policy="+policyId,"_self");
    }
})