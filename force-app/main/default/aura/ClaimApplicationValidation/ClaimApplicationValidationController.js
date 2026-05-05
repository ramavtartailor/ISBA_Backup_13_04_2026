({
    doInit : function(component, event, helper) {
        var valuesList = [];
		
        var actionMain = component.get("c.getPolicyClaim");
        actionMain.setParams(
            {"policyClaimId" : component.get("v.recordId")}
        );   
        
        
        actionMain.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                
                component.set("v.objPolicyClaim", response.getReturnValue());
            } else {
                console.log('Problem getting account, response state: ' + state);
            }
            
            var policyClaimStatus = component.get("v.objPolicyClaim.Claim_Status__c");
            var claimCloseDate = component.get("v.objPolicyClaim.ClaimCloseDAte__c");
            var claimClosePayRsltn = component.get("v.objPolicyClaim.Claim_Close_Payment_Resolutions__c");
            var claimCloseReason = component.get("v.objPolicyClaim.Claim_Close_Reasons__c");
            var reverseLAE = component.get("v.objPolicyClaim.GL_5010__c");
            var reverseLoss = component.get("v.objPolicyClaim.GL_5035__c");
            var State = component.get("v.objPolicyClaim.State__c");
            var GEO_Factor = component.get("v.objPolicyClaim.GEO_Factor__c");
            var AOP_Factor = component.get("v.objPolicyClaim.AOP_Factor__c");
            var Activity = component.get("v.objPolicyClaim.Activity__c");
            var Allegation = component.get("v.objPolicyClaim.Allegation__c");
            var Type_of_Error = component.get("v.objPolicyClaim.Type_of_Error__c");
            if(policyClaimStatus != 'Closed'){
                if(claimCloseDate == null || claimCloseDate == '' || claimCloseDate === 'undefined')
                    valuesList.push({
                        value: 'Enter close date'
                    });
                if(State == null || State == '' || State === 'undefined')
                    valuesList.push({
                        value: 'Enter State'
                    });
                if(GEO_Factor == null || GEO_Factor == '' || GEO_Factor === 'undefined')
                    valuesList.push({
                        value: 'Enter Venue'
                    });
                if(AOP_Factor == null || AOP_Factor == '' || AOP_Factor === 'undefined')
                    valuesList.push({
                        value: 'Enter Area of Law'
                    });
                if(Activity == null || Activity == '' || Activity === 'undefined')
                    valuesList.push({
                        value: 'Enter Activity'
                    });
                if(Allegation == null || Allegation == '' || Allegation === 'undefined')
                    valuesList.push({
                        value: 'Enter Allegation'
                    });
                if(Type_of_Error == null || Type_of_Error == '' || Type_of_Error === 'undefined')
                    valuesList.push({
                        value: 'Enter Type of Error'
                    });
                
                if(claimClosePayRsltn == null || claimClosePayRsltn == '' || claimClosePayRsltn === 'undefined')
                    valuesList.push({
                        value: 'Enter close payment resolution'
                    });
                
                if(claimCloseReason == null || claimCloseReason == '' || claimCloseReason === 'undefined')
                    valuesList.push({
                        value: 'Enter close reason'
                    });
                
                if (reverseLAE != 0 ){
                    valuesList.push({
                        value: 'LAE reserve must be 0.'
                    });
                }
                
                if (reverseLoss != 0 ){
                    valuesList.push({
                        value: 'Loss reserve must be 0.'
                    });
                }
            }
            console.log(valuesList);
            component.set("v.valuesList", valuesList);
        });
        $A.enqueueAction(actionMain);
    },
    
    closeModel : function(component,event, helper){
        component.set("v.isModel",false);
    },
    
    Navigate : function(component,event, helper) {
        var validation = event.target.dataset.value;
        var policyClaimId = component.get("v.recordId");
        
        if(validation != null) {
            
            if(validation == 'LAE Reserve must be 0.') {
                component.set("v.isModel",true);
             /*   var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef : "c:ChangeReserve",
                    componentAttributes: {
                        "recordId" : policyClaimId
                    }
                });
                evt.fire();*/
            }
            if(validation == 'Loss Reserve must be 0.') {
                component.set("v.isModel",true);
                /*var evt = $A.get("e.force:navigateToComponent");
                evt.setParams({
                    componentDef : "c:ChangeReserve",
                    componentAttributes: {
                        "recordId" : policyClaimId
                    }
                });
                evt.fire();*/
            }
            
            if(validation == 'Claim close date not empty.') {
                var eUrl= $A.get("e.force:navigateToURL");
                eUrl.setParams({
                    "url": '/apex/ClaimNewandEditVF?retURL=%2F' + policyClaimId +'&id='+ policyClaimId 
                });
                eUrl.fire();
            }
            if(validation == 'Claim Close Reasons not empty.') {
                var eUrl= $A.get("e.force:navigateToURL");
                eUrl.setParams({
                    "url": '/apex/ClaimNewandEditVF?retURL=%2F' + policyClaimId +'&id='+ policyClaimId
                });
                eUrl.fire();
            }
            if(validation == 'Claim Close Payment Resolutions not empty.') {
                var eUrl= $A.get("e.force:navigateToURL");
                eUrl.setParams({
                    "url": '/apex/ClaimNewandEditVF?retURL=%2F' + policyClaimId +'&id='+ policyClaimId
                });
                eUrl.fire();
            }
        }
    }
})