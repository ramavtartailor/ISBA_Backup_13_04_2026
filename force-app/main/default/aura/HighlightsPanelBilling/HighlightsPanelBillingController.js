({
    doInit : function(component, event, helper) {
        var action = component.get("c.getBillingDetail");
        action.setParams({
            billingId : component.get("v.recordId")
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var result = a.getReturnValue();
                let isRejected = false;
                
                console.log('result => ',result);
                if(result.Payment_Schedules__r){
                    console.log(result.Payment_Schedules__r);
                    for(let x of result.Payment_Schedules__r){
                        if(x.Status__c=='Rejected'){
                            isRejected = true;
                        }
                    }
                    component.set("v.paymentSchedule",result.Payment_Schedules__r[0]);
                }
				console.log(result.AcctSeed__Balance__c,+'  '+ isRejected);                
                if(result.AcctSeed__Balance__c > 0 &&  isRejected){
                    component.set("v.isRejected",true);
                    console.log('true')
                }
                component.set("v.record", a.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    }
})