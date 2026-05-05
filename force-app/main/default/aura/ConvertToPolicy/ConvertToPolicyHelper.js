({
    
    getStatusPicklist: function(component, event) {
        var action = component.get("c.getStatus");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var statusMap = [];
                for(var key in result){
                    statusMap.push({key: key, value: result[key]});
                }
                component.set("v.StatusMap", statusMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    getPaymentReceivedPicklist: function(component, event) {
        var action = component.get("c.getPaymentReceivedFieldValue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var paymentReceivedMap = [];
                for(var key in result){
                    paymentReceivedMap.push({key: key, value: result[key]});
                }
                component.set("v.paymentReceivedMap", paymentReceivedMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIBFContributionPicklist: function(component, event) {
        var action = component.get("c.getIBFPaymentFieldValue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var IBFContributionMap = [];
                for(var key in result){
                    IBFContributionMap.push({key: key, value: result[key]});
                }
                component.set("v.IBFContributionMap", IBFContributionMap);
            }
        });
        $A.enqueueAction(action);
    },
    getTargetPicklist: function(component, event) {
        var action = component.get("c.getTargetFieldValue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("State",state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var IBFTargetMap = [];
                for(var key in result){
                    IBFTargetMap.push({key: key, value: result[key]});
                }
                console.log("IBFTargetMap",IBFTargetMap);
                component.set("v.IBFTargetMap", IBFTargetMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    convertToPolicy : function(component, event, helper) {
        console.log('called convert');
       // $A.util.addClass(component.find("confirmBox"), 'hide');
        var errorMessage = '';
        var policyStatus = component.get("v.objPolicy.Status__c");
        var totalQuotes = component.get("v.objPolicy.Total_Quotes__c");
        var totalFinalQuotes = component.get("v.objPolicy.Total_Final_Quotes__c");
        var totalAOPPercentage = component.get("v.objPolicy.AOP_Percentage__c");
        var totalLawyer = component.get("v.objPolicy.Total_Lawyers__c");
        var priorActsDate = component.get("v.objPolicy.Policy_Retroactive_Date__c");
        var totalPremium = component.get("v.objPolicy.Premium__c");
        
        var policyDocVersion = component.get("v.objPolicy.Policy_Document_Version__c");
        
        var fullPriorActs = component.get("v.objPolicy.Full_Prior_Acts__c");
        
        if(policyStatus != 'Accepted')
            errorMessage += 'Status must be Accepted.\n'; 
        if (totalLawyer == '0' )
            errorMessage += 'No Lawyer(s) added!\n';
        if (totalAOPPercentage != '100' )
            errorMessage += 'Either AOP is not given or its percentage is not equal to 100.\n';
        if (totalQuotes == '0' )
            errorMessage += 'There is no Quote associated to this Application.\n' ;
        if (!priorActsDate && fullPriorActs == false)
            errorMessage += 'Please enter a valid prior date in order to proceed.\n';
        if (totalFinalQuotes != '1' && totalQuotes > 1)
            errorMessage += 'Please mark one Quote as Final.\n';
        if(totalPremium < 0 )
            errorMessage += 'Policy premium should be over $500.\n';
        if(component.get("v.objPolicy.Underwriter_User__c") == null)
            errorMessage +=  'Underwriter User is Missing.\n';
        
        if(component.get("v.objPolicy.Firm_Contact__c") == null)
            errorMessage +=  'Firm Contact is Missing.\n';
        
        if(component.get("v.objPolicy.Account__r.Phone") == null)
            errorMessage +=  'Phone Number is Missing.\n';
        
        if(component.get("v.objPolicy.Account__r.BillingStreet") == null || component.get("v.objPolicy.Account__r.BillingCity") == null || component.get("v.objPolicy.Account__r.BillingState") == null || component.get("v.objPolicy.Account__r.BillingPostalCode") == null)
            errorMessage +=  'Firm Address is Missing.\n';
        
        if(component.get("v.objPolicy.County__r.Name") == 'TO BE DETERMINED')
            errorMessage +=  'County is Missing.\n';
        
        var action1 = component.get("c.hasAllLawyersARDC");
        action1.setParams(
            {"policyId" : component.get("v.recordId")}
        );
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                if(response.getReturnValue() != 'Yes'){
                    errorMessage += 'These Lawyers does not have ARDC Numbers: ' + response.getReturnValue() +'\n' ;
                }
            } else {
                errorMessage+='Some Error has occurred. Please contact your System Administrator.';
                console.log('Problem getting account, response state: ' + state);
            }
            if(errorMessage){
                // $A.util.removeClass(component.find("errorMsg"), 'hide');
                /*
                var action = component.get('c.showError');
                action.setParams(
                    {"message" : errorMessage }
                );
                $A.enqueueAction(action);
                */
                 helper.showError(component, event, helper,errorMessage);
                component.set("v.spinner", false);
                component.set("v.msg", errorMessage);
            }else{
                var blockAction = component.get("c.hasBlocks");
                blockAction.setParams(
                    {"policyId" : component.get("v.recordId")}
                );
                blockAction.setCallback(this, function(response) {
                    var state = response.getState();
                    /*if(state === "SUCCESS") {
                        if(response.getReturnValue() == true){
                            errorMessage += 'This application has some blocks. Please resolve them in order to Bind this.' ;
                        }
                    } else {
                        errorMessage+='Some Error has occurred. Please contact your System Administrator.';
                        console.log('Problem getting account, response state: ' + state);
                    }*/
                    var aopAction = component.get("c.hasUndefinedAOP");
                    aopAction.setParams(
                        {"policyId" : component.get("v.recordId")}
                    );
                    aopAction.setCallback(this, function(response) {
                        var state = response.getState();
                        if(state === "SUCCESS") {
                            if(response.getReturnValue() == true){
                                errorMessage += 'This application has some undefined AOP\'s';
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
                                    errorMessage += '106 endorsement invalid on policies with multiple lawyers';
                                }
                            } else {
                                console.log('Problem getting account, response state: ' + state);
                            }
                            if(errorMessage){
                                //$A.util.removeClass(component.find("errorMsg"), 'hide');
                                /*
                                var action = component.get('c.showError');
                                action.setParams(
                                    {"message" : errorMessage }
                                );
                                $A.enqueueAction(action);
                                */
                                helper.showError(component, event, helper,errorMessage);
                                component.set("v.spinner", false);
                                component.set("v.msg", errorMessage);
                            }else{
                                var action = component.get("c.convertPolicy");
                                action.setParams(
                                    {"policyId" : component.get("v.recordId"), "policyDocVersion" : policyDocVersion}
                                );
                                
                                // Configure response handler
                                action.setCallback(this, function(response) {
                                    var state = response.getState();
                                    if(state === "SUCCESS") {
                                        if(response.getReturnValue() == true){
                                            helper.showSuccess(component, event, helper);
                                            var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
                                            dismissActionPanel.fire();
                                            $A.get("e.force:refreshView").fire();
                                            
                                        }else{
                                            errorMessage+='Some Error has occurred. Please contact your System Administrator.';
                                            //$A.util.removeClass(component.find("errorMsg"), 'hide');
                                            component.set("v.msg", errorMessage);
                                            helper.showError(component, event, helper,errorMessage);
                                            component.set("v.spinner", false);
                                            /*
                                            var action = component.get('c.showError');
                                            action.setParams(
                                                {"message" : errorMessage }
                                            );
                                            $A.enqueueAction(action);
                                            */
                                        }
                                        //component.set("v.objPolicy", response.getReturnValue());
                                        /*var action2 = component.get("c.createDocuments");
                                        action2.setParams(
                                            {"policyId" : component.get("v.recordId"), "policyDocVersion" : policyDocVersion}
                                        );
                                        action2.setCallback(this, function(response) {
                                            var state = response.getState();
                                            if(state === "SUCCESS") {
                                                var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
                                                dismissActionPanel.fire();
                                                $A.get("e.force:refreshView").fire();
                                                //window.location.href = "/"+component.get("v.recordId");
                                            } else {
                                                errorMessage+='Some Error has occurred. Please contact your System Administrator.';
                                                $A.util.removeClass(component.find("errorMsg"), 'hide');
                                                component.set("v.msg", errorMessage);
                                            }
                                        });
                                        $A.enqueueAction(action2);*/
                                        
                                    } else {
                                        errorMessage+='Some Error has occurred. Please contact your System Administrator.';
                                        // $A.util.removeClass(component.find("errorMsg"), 'hide');
                                        // component.set("v.msg", errorMessage);
                                        helper.showError(component, event, helper,errorMessage);
                                        component.set("v.spinner", false);
                                        /*
                                        var action = component.get('c.showError');
                                         action.setParams(
                                            {"message" : errorMessage }
                                        );
                                        $A.enqueueAction(action);
                                        */
                                        
                                    }
                                });
                                $A.enqueueAction(action);
                            }
                        });
                        $A.enqueueAction(valid106Action);
                    });
                    $A.enqueueAction(aopAction);
                });
                $A.enqueueAction(blockAction);
            }
        });
        $A.enqueueAction(action1);
        
    },
    showSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'Binding Successfull',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    showError : function(component, event, helper,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    
    
    checkRequiredFieldsHelper : function(component, event, helper){
        var receivedDate = component.find("receivedDate").get("v.value");
        var signedDate = component.find("applicationSignedDate").get("v.value");
        var status = component.find("statusPicklist").get("v.value");
        var payementReceieved = component.find("paymentReceivedPicklist").get("v.value");
      	var IBFContribution = component.find("IBFContributionPicklist").get("v.value");
        var dividendCredit = component.get("v.objPolicy.ISBAM_policy_dividend__c");
        if(receivedDate != null &&  signedDate != null && status != undefined && status != '' && payementReceieved != '' && payementReceieved != undefined && ( (IBFContribution != '' && IBFContribution != undefined && dividendCredit > 0)  || (dividendCredit == 0) )){
            if(IBFContribution == 'No IBF Contribution'){
                component.set("v.bindButtonEnable",false);
            }else if(IBFContribution == 'Yes - IBF Contribution Requested'){
                var IBFTarget = component.find("IBFTargetPicklist").get("v.value");
                if(IBFTarget != null && IBFTarget!= undefined && ((IBFTarget == 'Appellate District' && component.find("IBFAppellateDistrict").get("v.value") != null) || IBFTarget != 'Appellate District') ){
                    component.set("v.bindButtonEnable",false);
                }else{
                    component.set("v.bindButtonEnable",true);
                }
            }else{
                component.set("v.bindButtonEnable",false);
            }
        }
        else{
            component.set("v.bindButtonEnable",true);
        }
    }
})