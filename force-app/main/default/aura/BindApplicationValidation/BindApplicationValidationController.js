({
    Navigate : function(component,event, helper) {
        var validation = event.target.dataset.value;
        var policyId = component.get("v.recordId");
        var AccountId = component.get("v.objPolicy.Account__c");
        
        if(validation != null) {
            if(validation == 'Application Signed Date is Missing.' || validation == 'Application Received Date is Missing.' || validation == 'Underwriter User is Missing.' || validation == 'Firm Contact is Missing.' || validation == 'Status must be Accepted.' || validation == 'Please enter a valid prior date in order to proceed.' || validation == 'County is Missing.') {
                var eUrl= $A.get("e.force:navigateToURL");
                eUrl.setParams({
                    "url": '/apex/Application_Policy_DetailPageEdit_Ltng?retURL=%2F' + policyId +'&id='+ policyId 
                });
                eUrl.fire();
            }
            if(validation == 'No Lawyer(s) added!') {
                var eUrl= $A.get("e.force:navigateToURL");
                eUrl.setParams({
                    "url": '/apex/PolicyLawyers?id=' + policyId + '&showNext=false' 
                });
                eUrl.fire();
            }
            if(validation == 'Either AOP is not given or its percentage is not equal to 100.' || validation == 'This application has some undefined AOP') {
                var eUrl= $A.get("e.force:navigateToURL");
                eUrl.setParams({
                    "url": '/apex/AreaofPracticeDetailPageEdit_Ltng?id='+policyId+'&showNext=false' 
                });
                eUrl.fire();
            }
            if(validation == 'There is no Quote associated to this Application.' || validation == 'Please mark one Quote as Final.' || validation == 'Policy premium should be over $500.') {
                var eUrl= $A.get("e.force:navigateToURL");
                eUrl.setParams({
                    "url": '/apex/QuotesDetailPage?id='+policyId+'&showNext=false' 
                });
                eUrl.fire();
            }
            if(validation == 'These Lawyers does not have ARDC Numbers:' || validation == 'Phone Number is Missing.' || validation == 'Firm Address is Missing.') {
                var eUrl= $A.get("e.force:navigateToURL");
                eUrl.setParams({
                    "url": '/apex/AccountDetailPageEdit_Ltng?retURL=%2F'+policyId+'&id='+AccountId 
                });
                eUrl.fire();
            }
            if(validation == 'This application has some blocks. Please resolve them in order to Bind this.') {
            }
            
        }
    },
    
    doInit : function(component, event, helper) {
        var valuesList = [];
        var actionMain = component.get("c.getPolicy");
        actionMain.setParams(
            {"policyId" : component.get("v.recordId")}
        );   
        
        
        // Configure response handler
        actionMain.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.objPolicy", response.getReturnValue());
            } else {
                console.log('Problem getting account, response state: ' + state);
            }
            
            var policyStatus = component.get("v.objPolicy.Status__c");
            var totalQuotes = component.get("v.objPolicy.Total_Quotes__c");
            var totalFinalQuotes = component.get("v.objPolicy.Total_Final_Quotes__c");
            var totalAOPPercentage = component.get("v.objPolicy.AOP_Percentage__c");
            var totalLawyer = component.get("v.objPolicy.Total_Lawyers__c");
            var priorActsDate = component.get("v.objPolicy.Policy_Retroactive_Date__c");
            var totalPremium = component.get("v.objPolicy.Premium__c");
            
            var policyDocVersion = component.get("v.objPolicy.Policy_Document_Version__c");
            
            var signedDate = component.get("v.objPolicy.Date_Signed__c");
            var receivedDate = component.get("v.objPolicy.Application_Received_Date__c");
            
            var fullPriorActs = component.get("v.objPolicy.Full_Prior_Acts__c");
            
            if(signedDate == null)
                valuesList.push({
                    value: 'Application Signed Date is Missing.'
                });
            if(receivedDate == null)
                valuesList.push({
                    value: 'Application Received Date is Missing.'
                });
            if(policyStatus != 'Accepted')
                valuesList.push({
                    value: 'Status must be Accepted.'
                });
            if (totalLawyer == '0' )
                valuesList.push({
                    value: 'No Lawyer(s) added!'
                });
            if (totalAOPPercentage != '100' )
                valuesList.push({
                    value: 'Either AOP is not given or its percentage is not equal to 100.'
                });
            if (totalQuotes == '0' )
                valuesList.push({
                    value: 'There is no Quote associated to this Application.'
                });
            if (!priorActsDate && fullPriorActs == false)
                valuesList.push({
                    value: 'Please enter a valid prior date in order to proceed.'
                });
            if (totalFinalQuotes != '1' && totalQuotes > 1)
                valuesList.push({
                    value: 'Please mark one Quote as Final.'
                });
            if(totalPremium < 0 )
                valuesList.push({
                    value: 'Policy premium should be over $500.'
                });
            
            if(component.get("v.objPolicy.Underwriter_User__c") == null)
                valuesList.push({
                    value: 'Underwriter User is Missing.'
                });
            
            if(component.get("v.objPolicy.Firm_Contact__c") == null)
                valuesList.push({
                    value: 'Firm Contact is Missing.'
                });
            
            if(component.get("v.objPolicy.Account__r.Phone") == null)
                valuesList.push({
                    value: 'Phone Number is Missing.'
                });
            
            if(component.get("v.objPolicy.Account__r.BillingStreet") == null || component.get("v.objPolicy.Account__r.BillingCity") == null || component.get("v.objPolicy.Account__r.BillingState") == null || component.get("v.objPolicy.Account__r.BillingPostalCode") == null)
                valuesList.push({
                    value: 'Firm Address is Missing.'
                }); 
            
            if(component.get("v.objPolicy.County__r.Name") == 'TO BE DETERMINED' )
                valuesList.push({
                    value: 'County is Missing.'
                });    
            
            var action1 = component.get("c.hasAllLawyersARDC");
            action1.setParams(
                {"policyId" : component.get("v.recordId")}
            );
            action1.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    if(response.getReturnValue() != 'Yes'){
                        valuesList.push({
                            value: 'These Lawyers does not have ARDC Numbers: ' + response.getReturnValue()
                        });
                    }
                } else {
                    console.log('Problem getting account, response state: ' + state);
                }
                var blockAction = component.get("c.hasBlocks");
                blockAction.setParams(
                    {"policyId" : component.get("v.recordId")}
                );
                blockAction.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state === "SUCCESS") {
                        if(response.getReturnValue() == true){
                           /* valuesList.push({
                                value: 'This application has some blocks. Please resolve them in order to Bind this.'
                            });*/
                        }
                    } else {
                        console.log('Problem getting account, response state: ' + state);
                    }
                    var aopAction = component.get("c.hasUndefinedAOP");
                    aopAction.setParams(
                        {"policyId" : component.get("v.recordId")}
                    );
                    aopAction.setCallback(this, function(response) {
                        var state = response.getState();
                        if(state === "SUCCESS") {
                            if(response.getReturnValue() == true){
                                valuesList.push({
                                    value: 'This application has some undefined AOP\'s'
                                });
                            }
                        } else {
                            console.log('Problem getting account, response state: ' + state);
                        }
                        var valid106Action = component.get("c.hasInvalid106");
                        valid106Action.setParams(
                            {"policyId" : component.get("v.recordId")}
                        );
                        valid106Action.setCallback(this, function(response) {
                            var state = response.getState();
                            if(state === "SUCCESS") {
                                if(response.getReturnValue() == true){
                                    valuesList.push({
                                        value: '106 endorsement invalid on policies with multiple lawyers'
                                    });
                                }
                            } else {
                                console.log('Problem getting account, response state: ' + state);
                            }
                            component.set("v.valuesList", valuesList);
                        });
                        $A.enqueueAction(valid106Action);
                    });
                    $A.enqueueAction(aopAction);
                });
                $A.enqueueAction(blockAction);
            });
            $A.enqueueAction(action1);
        });
        $A.enqueueAction(actionMain);
    }
})