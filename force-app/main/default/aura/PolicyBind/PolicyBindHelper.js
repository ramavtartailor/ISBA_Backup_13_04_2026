({
    // get details from class 
    getDetails: function (component, lastTime, changeTab, to, buttype) {
        console.log('G etDetails called:');
        var toastList = [];
        var action = component.get("c.getPolicyDetails");
        this.showSpinnerHelper(component);

        // if (lastTime != '' && lastTime != undefined) {
            action.setParams({
                validationString: component.get("v.recordId"),
                lasttime: lastTime
            });
            action.setCallback(this, function (response) {
                var toastList = [];
                var state = response.getState();
                console.log('state:', state);
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result != null) {
                        result.ipAddress = component.get("v.ipAddress");
                        component.set("v.lastTime",result.paymentScheduleVar);
                        console.log('result:', result);
                        
                        var Physical_Check = component.get('v.Physical_Check');
                        
                        if(Physical_Check){
                            component.set("v.isCC",false);
                            result.paymentTypeVar = 'Physical_Check';
                            result.defaultPaymentMethodId = 'Physical_Check';
                            component.set("v.isPayButDisable", false);
                        }
                        if(result.isRedirect){
                            component.set("v.showScreenLoading", true);
                            component.set("v.isDataLoadSuccess", true);
                            if(result.policy.Customer_Application__c && result.policy.Customer_Application__r.Form_Link__c){
                               window.open(result.policy.Customer_Application__r.Form_Link__c, '_self'); 
                            }
                            else{
                                this.closeSpinnerHelper(component);
                                component.set("v.showScreenLoading", false);
                                component.set("v.isDataLoadSuccess", false);
                                component.set("v.hasError", true);
                                component.set("v.policywrap", result);
                            }
                        }
                        
                        if (result.isAlreadyBind || result.isRejected || result.isBlocked) {
                            component.set("v.showScreenLoading", false);
                            component.set("v.isDataLoadSuccess", false);
                            component.set("v.hasError", true);
                            component.set("v.policywrap", result);
                            // component.set("v.paymentMessageOnLoad", ``);
                            /*
                             * window.setTimeout(() => {
                                var link = result.siteUrl;
                                window.open(link, '_self')
                            }, 1000);
                            */
                        } 
                        else {  
                            delete result.policy.Policy_Endorsements__r;
                            delete result.policy.Policy_Lawyers__r;
                            delete result.policy.Policy_Quotes__r;

                            console.log("Custom Amount ==> " + result.policy.IBF_Custom_Amount__c);
                           
                            var updatedPremiumAmount = 0;
                            if (result.totalCLECredit > 0) {
                                updatedPremiumAmount += result.totalCLECredit;
                            }
                            if (result.policy.IBF_Contribtuion__c == 'Yes - IBF Contribution Requested') {
                                if (result.policy.IBF_Custom_Amount__c && result.policy.IBF_Custom_Amount__c > 0) {
                                    component.set("v.donationType", 'Partial');
                                } else {
                                    component.set("v.donationType", 'Full');
                                }
                                if (result.roundedDividend != null && result.roundedDividend > 0) {
                                    if(result.policy.IBF_Custom_Amount__c!= null && result.policy.IBF_Custom_Amount__c > 0){
                                        updatedPremiumAmount += result.roundedDividend - result.policy.IBF_Custom_Amount__c;
                                    }                           
                                }                                
                            }else{
                                if (result.roundedDividend != null && result.roundedDividend > 0) {
                                    updatedPremiumAmount += result.roundedDividend;
                                }
                            }
                            
                            let isAnyQuoteSelected = false;
                            if(result.policyQuotes.length && result.policyQuotes.length == 1){
                                isAnyQuoteSelected = true;
                            }
                            for(let x of result.policyQuotes){
                                if(x.Final_Quote__c){
                                    isAnyQuoteSelected = true;
                                }
                            }
                            component.set("v.isAnyQuoteSelected",isAnyQuoteSelected);
                            
                            //if(!changeTab){
                                for(let x of result.policyLawyers){
                                    console.log('phone => ',  x.Lawyer__r.Contact__r.MobilePhone);
                                    if(x.Lawyer__r.Contact__r.MobilePhone != undefined){
                                        x.formatedPhone = this.cellPhoneNumberFormatter(x.Lawyer__r.Contact__r.MobilePhone); 
                                    }
                                    else{
                                        x.formatedPhone ='';
                                    }
                                }
                            //}

                            console.log('result after phone Format:', result);
                            component.set("v.updatedPermium", updatedPremiumAmount);

                            component.set("v.isDataLoadSuccess", true);
                            component.set("v.policywrap", result);
                            
                            if(result.endorsement && result.endorsement.Endorsement_Number__c == 'IL 107'){
                                component.set("v.is_IL_107",true);
                            }
                            //component.set("coverageTerm",result.endorsement.Coverage_Term__c);
                            //component.set("endorsementEffectiveDate",result.endorsement.Endorsement_Effective_Date__c);
                            
                            component.set("v.showIbfDependentFields", false);
                            if (result.policy.IBF_Contribtuion__c == 'Yes - IBF Contribution Requested') {
                                component.set("v.showIbfDependentFields", true);
                            }
                            if (result.policy.IBF_Target__c == 'Appellate District') {
                                component.set("v.showIbfTargetDependentField", true);
                            }
                            if (changeTab && to != 'none' && buttype != 'none') {
                                if (result.policy.IBF_Contribtuion__c == 'Yes - IBF Contribution Requested') {
                                    component.set("v.showIbfDependentFields", true);
                                } else {
                                    component.set("v.showIbfDependentFields", false);
                                }
                                this.changeStepHelper(component, to, buttype);
                            }
							
                            if(to == '3'){
                                
                            }
                            //this.boxChangeHelper(component, result.policy.Terms_And_Conditions_Approval__c);
                        }

                    } else {
                        toastList.push(
                            {
                                type: 'err',
                                message: 'No record Found'
                            });
                    }
                } else if (state === "INCOMPLETE") {
                    toastList.push(
                        {
                            type: 'err',
                            message: 'Incomplete(Getting Details)'
                        });
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    var isInternalUser = component.get("v.isInternalUser");
                    var errorMsg;
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            let err = JSON.parse(errors[0].message);
                            errorMsg = err.errorMsg;
                            this.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                        }
                    }
                    
                    if (isInternalUser == 'true') {
                        if (errorMsg) {
                            console.log("Error message: " + errorMsg);
                            toastList.push(
                                {
                                    type: 'err',
                                    message: errorMsg
                                }
                            );
                    /*if (isInternalUser == 'true') {
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                toastList.push(
                                    {
                                        type: 'err',
                                        message: errors[0].message
                                    });
                            }*/
                            //console.log("getPolicyDetails Error message: " + errors[0].message);
                        } else {
                            toastList.push(
                                {
                                    type: 'err',
                                    message: 'Unknown error in getting Details.'
                                });
                        }
                    }
                    else{
                        toastList.push(
                            {
                                type: 'err',
                                message: 'An error occurred while processing your policy please contact ISBA Mutual Team.'
                            });
                        //block next button 
                        component.set("v.isNextButtonDisabled", true);
                    }
                }
                if(!result.isRedirect){
                    this.closeSpinnerHelper(component);
                    this.showToastHelper(component, toastList, 5);
                }
            });
            $A.enqueueAction(action);
        // } else {
        //     var isInternalUser = component.get("v.isInternalUser");
        //     if(isInternalUser == 'true'){
        //         toastList.push(
        //             {
        //                 type: 'err',
        //                 message: 'Payment frequency is undefined'
        //             });
        //     }
        //     else{
        //         toastList.push(
        //             {
        //                 type: 'err',
        //                 message: 'An error occurred while processing your policy please contact ISBA Mutual Team.'
        //             });
        //         //block next button 
        //         component.set("v.isNextButtonDisabled", true);
        //     }
        //     this.showToastHelper(component, toastList, 5);
        // }
    },
    getExpiryOptions: function (component) {
        console.log("g etexpiryoption");
        var action = component.get("c.getExpiryDetails");
        action.setParams({});
        action.setCallback(this, function (response) {
            var state = response.getState();
            var toastList = [];

            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                var years = result.expYears;
                var months = result.expMonths;
                component.set("v.cardExpiryYearList", years);
                component.set("v.cardExpiryMonthList", months);
                return true;
            }
            else if (state === "INCOMPLETE") {
                toastList.push(
                    {
                        type: 'err',
                        message: 'Incomplete(Getting expiry details)'
                    });
            } else if (state === "ERROR") {
                var errors = response.getError();
                var isInternalUser = component.get("v.isInternalUser");
                var errorMsg;
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            let err = JSON.parse(errors[0].message);
                            errorMsg = err.errorMsg;
                            this.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                        }
                    }
                    
                    if (isInternalUser == 'true') {
                        if (errorMsg) {
                            console.log("Error message: " + errorMsg);
                            toastList.push(
                                {
                                    type: 'err',
                                    message: errorMsg
                                }
                            );
                    /*if (isInternalUser == 'true') {
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                toastList.push(
                                    {
                                        type: 'err',
                                        message: errors[0].message
                                    });
                                console.log("getexpiryoption Error message: " + errors[0].message);
                            }*/
                        } else {
                            toastList.push(
                                {
                                    type: 'err',
                                    message: 'Unknown error in getting expiry details.'
                                });
                        }
                    }
                else {
                    toastList.push(
                        {
                            type: 'err',
                            message: 'An error occurred while processing your policy please contact ISBA Mutual Team.'
                        });
                    //block next button 
                    component.set("v.isNextButtonDisabled", true);
                }
                
            }
            this.showToastHelper(component, toastList, 6)
        });
        $A.enqueueAction(action);
    },
    getSavedPaymentMethodsList: function (component) {
        this.showSpinnerHelper(component);
        var action = component.get("c.policyExistingList");
        var wrap = component.get("v.policywrap");
        console.log('wrap:', wrap);
        action.setParams({
            customerId: wrap.policy.Account__c
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var toastList = [];
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                var savedCardList = result.cardList;
                var savedEcheckList = result.eCheckList;
                
                
                var payId = wrap.defaultPaymentMethodId;
                var flag = false;
                var flag2 = false;
                if (payId != null || payId != undefined) {
                    if (savedCardList.length) {
                        for (var i = 0; i < savedCardList.length; i++) {
                            if (savedCardList[i].paymentMethod.Id == payId) {
                                savedCardList[i].isDefault = true;
                                flag = true;
                                component.set("v.isCC",true);
                            }
                        }
                    }
                    if (savedEcheckList.length) {
                        for (var i = 0; i < savedEcheckList.length; i++) {
                            if (savedEcheckList[i].paymentMethod.Id == payId) {
                                savedEcheckList[i].isDefault = true;
                                flag = true;
                                component.set("v.isCC",false);
                            }
                        }
                    }
                }
                else{
                    for (var i = 0; i < savedCardList.length; i++) {
                        if (savedCardList[i].isDefault) {
                            flag = true;
                            flag2 = true;
                            payId = savedCardList[i].paymentMethod.Id;
                            wrap.defaultPaymentMethodId = savedCardList[i].paymentMethod.Id;
                            component.set("v.isCC",true);
                        }
                    }
                    for (var i = 0; i < savedEcheckList.length; i++) {
                        if (savedEcheckList[i].isDefault) {
                            payId = savedEcheckList[i].paymentMethod.Id;
                            wrap.defaultPaymentMethodId = savedEcheckList[i].paymentMethod.Id;
                            flag = true;
                            flag2 = true;
                            component.set("v.isCC",false);
                        }
                    }
                }


                console.log('is default payment Method flag =>', flag);
                var payBut = component.find("payBut");
                if (flag) {
                    //var paymentMethodPickList = document.getElementById('picklistPaymentMethod');
                   // paymentMethodPickList != undefined && paymentMethodPickList != null && 
                    
                    //console.log('paymentMethodPickList => ', paymentMethodPickList);
                    
                    if (flag2 || component.get("v.isDueDateValid")){                        
                        console.log('payBut:', payBut);
                        component.set("v.isPayButDisable", false);
                        //$A.util.removeClass(payBut, "disableBut");
                    }
                    else{
                        //$A.util.addClass(payBut, "disableBut");
                        component.set("v.isPayButDisable", true);
                    }
                } else {
                    //$A.util.addClass(payBut, "disableBut");
                    component.set("v.isPayButDisable", true);
                    component.set("v.policywrap.defaultPaymentMethodId", null);
                }

                if (savedCardList.length && savedCardList.length == 1 && !savedEcheckList.length) {
                    savedCardList[0].isSetToPay = true;
                    //$A.util.removeClass(payBut, "disableBut");
                    component.set("v.isPayButDisable", false);
                    component.set("v.policywrap.defaultPaymentMethodId", savedCardList[0].paymentMethod.Id);
                    component.set("v.isCC",true);
                } else if (savedEcheckList.length && savedEcheckList.length == 1 && !savedCardList.length) {
                    savedEcheckList[0].isSetToPay = true;
                    //$A.util.removeClass(payBut, "disableBut");
                    component.set("v.isPayButDisable", false);
                    component.set("v.policywrap.defaultPaymentMethodId", savedEcheckList[0].paymentMethod.Id);
                    component.set("v.isCC",false);
                }

                console.log('savedEcheckList:', savedEcheckList);
                console.log('savedCardList:', savedCardList);
                component.set('v.savedCardList', savedCardList);
                component.set('v.savedEcheckList', savedEcheckList);
                //this.picklistPaymentMethodChangeHelper(component);
            } else if (state === "INCOMPLETE") {
                toastList.push(
                    {
                        type: 'err',
                        message: 'Incomplete(Getting SavedList)'
                    });
            } else if (state === "ERROR") {
                var errors = response.getError();
                var isInternalUser = component.get("v.isInternalUser");
                var errorMsg;
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        let err = JSON.parse(errors[0].message);
                        errorMsg = err.errorMsg;
                        this.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                    }
                }
                
                if (isInternalUser == 'true') {
                    if (errorMsg) {
                        console.log("Error message: " + errorMsg);
                        toastList.push(
                            {
                                type: 'err',
                                message: errorMsg
                            }
                        );
                /*if (isInternalUser == 'true') {
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            toastList.push(
                                {
                                    type: 'err',
                                    message: errors[0].message
                                });
                            console.log("getSavedPaymentMethodsList Error message: " + errors[0].message);
                        }*/
                    } else {
                        toastList.push(
                            {
                                type: 'err',
                                message: 'Unknown error in getting savedlist.'
                            });
                    }
                }
                else{
                    toastList.push(
                        {
                            type: 'err',
                            message: 'An error occurred while processing your policy please contact ISBA Mutual Team.'
                        });
                    //block next button 
                    component.set("v.isNextButtonDisabled", true);
                }
            }
            this.closeSpinnerHelper(component);
            this.showToastHelper(component, toastList, 5)
        });
        $A.enqueueAction(action);
    },
    getStatusPicklist: function (component, event) {
        var action = component.get("c.getStatus");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var statusMap = [];
                for (var key in result) {
                    statusMap.push({ key: key, value: result[key] });
                }
                component.set("v.StatusMap", statusMap);
            }
        });
        $A.enqueueAction(action);
    },
    getPaymentReceivedPicklist: function (component, event) {
        var action = component.get("c.getPaymentReceivedFieldValue");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var paymentReceivedMap = [];
                for (var key in result) {
                    paymentReceivedMap.push({ key: key, value: result[key] });
                }
                component.set("v.paymentReceivedMap", paymentReceivedMap);
            }
        });
        $A.enqueueAction(action);
    },
    getIBFContributionPicklist: function (component, event) {
        console.log('getibf call');
        var action = component.get("c.getIBFPaymentFieldValue");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var IBFContributionMap = [];
                for (var key in result) {
                    IBFContributionMap.push({ key: key, value: result[key] });
                }
                component.set("v.ibfContributionList", IBFContributionMap);
            }
        });
        $A.enqueueAction(action);
    },
    getTargetPicklist: function (component, event) {
        var action = component.get("c.getTargetFieldValue");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('getTargetPicklist result:', result);
                var IBFTargetMap = [];
                for (var key in result) {
                    IBFTargetMap.push({ key: key, value: result[key] });
                    console.log(key);
                    console.log(result[key]);
                }
                component.set("v.ibfTargetList", IBFTargetMap);
            }
        });
        $A.enqueueAction(action);
    },

    //Payment methods
    updatePaymentMethodHelper: function (component, event, flag) {
        this.showSpinnerHelper(component);
        var wrapper = component.get("v.policywrap");
        
        var action = component.get("c.updatePaymentMethod");
        action.setParams({
            wrapperObj: wrapper
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var toastList = [];

            if (state === "SUCCESS") {
                var result = response.getReturnValue();

                if(flag){
                    if (result != 'success') {
                        wrapper.defaultPaymentMethodId = result;
                        component.set("v.policywrap", wrapper);
                    }
                    this.policyAllMethodsHelper(component);
                }
                else{
                    // if (result == 'success') {
                    toastList.push(
                        {
                            type: 'suc',
                            message: 'Payment method is successfully updated.'
                        });
                    // }
                    if (result != 'success') {
                        wrapper.defaultPaymentMethodId = result;
                        component.set("v.policywrap", wrapper);
                    }
                    this.reloadDataHelper(component);
                    component.set('v.isSavedScreen', true);
                    component.set('v.isAddScreen', false);
                }

            } else if (state === "INCOMPLETE") {
                toastList.push(
                    {
                        type: 'err',
                        message: 'Incomplete.'
                    });
            } else if (state === "ERROR") {
                var errors = response.getError();
                var isInternalUser = component.get("v.isInternalUser");
                var errorMsg;
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        let err = JSON.parse(errors[0].message);
                        errorMsg = err.errorMsg;
                        this.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                    }
                }
                
                if (isInternalUser == 'true') {
                    if (errorMsg) {
                        console.log("Error message: " + errorMsg);
                        toastList.push(
                            {
                                type: 'err',
                                message: errorMsg
                            }
                        );
                /*if (isInternalUser == 'true') {
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("updatePaymentMethodHelper-> Error message: " + errors[0].message);
                            toastList.push(
                                {
                                    type: 'err',
                                    message: errors[0].message
                                });
                        }*/
                    } else {
                        toastList.push(
                            {
                                type: 'err',
                                message: 'Unknown Error'
                            });
                    }
                }
                else{
                    toastList.push(
                        {
                            type: 'err',
                            message: 'An error occurred while processing your policy please contact ISBA Mutual Team.'
                        });
                    //block next button 
                    component.set("v.isNextButtonDisabled", true);
                }
            }
            this.showToastHelper(component, toastList, 4);
            this.closeSpinnerHelper(component);
        });
        $A.enqueueAction(action);
    },
    savePaymentMethodHelper: function (component, event) {
        try{
        this.showSpinnerHelper(component);

        var ipAdd = component.get("v.ipAddress");
        var wrapper = component.get("v.policywrap");
        var flag = true;

        var cards = component.get("v.savedCardList");
        var eCheck = component.get("v.savedEcheckList");
        var toastList = [];
        
        var key = '';
        var msg = '';
        if(wrapper.paymentTypeVar=='creditCard'){
            key = (wrapper.cardTypeVar).toLowerCase()+' '+(wrapper.cardNumber).slice(wrapper.cardNumber.length - 4);
        }
        else if(wrapper.paymentTypeVar=='check'){
            key = (wrapper.accountType).toLowerCase() +' '+(wrapper.accountNumber).slice(wrapper.accountNumber.length - 4); 
        }
        for(let x of cards){
            if(x.key == key){
                flag = false;
                msg = 'You cannot add an Existing Card.';
            }
        }
        for(let x of eCheck){
            if(x.key == key){
                flag = false;
                msg = 'You cannot add an Existing eCheck.';
            }
        }
        if(flag){
            
            var action = component.get("c.savePaymentMethod");
            console.log('saveeewrapper:', wrapper);
            action.setParams({
                wrapperObj: wrapper,
                ipAddress: ipAdd
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('state->' , state);
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result) {
                        wrapper.payMethodToken = result.token;
                        wrapper.defaultPaymentMethodId = result.methodId;
                        component.set("v.policywrap", wrapper);
                        this.closeSpinnerHelper(component);
                        toastList.push(
                            {
                                type: 'suc',
                                message: 'Payment method is successfully saved.'
                            });

                        this.closepopupHelper(component, 'nor');
                        component.set("v.disableFields", false);
                        component.set("v.dataTypeCvv", 'number');

                        this.reloadDataHelper(component);
                        component.set('v.currentActiveTab','tab-2');
                        component.set('v.isSavedScreen', true);
                        component.set('v.isAddScreen', false);
                    } else {
                        toastList.push(
                            {
                                type: 'err',
                                message: 'Oops something went wrong.'
                            });
                    }
                } else if (state === "INCOMPLETE") {
                    toastList.push(
                        {
                            type: 'err',
                            message: 'Incomplete.'
                        });
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    var isInternalUser = component.get("v.isInternalUser");
                    var errorMsg;
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            let err = JSON.parse(errors[0].message);
                            errorMsg = err.errorMsg;
                            this.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                        }
                    }
                    
                    if (isInternalUser == 'true') {
                        if (errorMsg) {
                            console.log("Error message: " + errorMsg);
                            toastList.push(
                                {
                                    type: 'err',
                                    message: errorMsg
                                }
                            );
                    /*if (isInternalUser == 'true') {
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("savePayment--> Error message: " + errors[0].message);
                                toastList.push(
                                    {
                                        type: 'err',
                                        message: errors[0].message
                                    });
                            }*/
                        } else {
                            toastList.push(
                                {
                                    type: 'err',
                                    message: 'Unknown error'
                                });
                        }
                    }
                    else{
                        toastList.push(
                            {
                                type: 'err',
                                message: 'An error occurred while adding the '+(wrapper.paymentTypeVar=='creditCard' ? 'Card' : 'eCheck/ACH')+' please contact ISBA Mutual Team.'
                            });
                        //block next button 
                    }
                }
                this.showToastHelper(component, toastList, 4);
                //component.set("v.showSpinner", false);

                //this.closeSpinnerHelper(component);
            });
            $A.enqueueAction(action);
        }
        else{
            toastList.push(
                {
                    type: 'err',
                    message: msg
                });
            this.showToastHelper(component, toastList, 4);
            
            this.closeSpinnerHelper(component);
        }}
        catch(e){
            console.error(e.getMessage());
        }
    },
    deletePaymentMethodHelper: function (component, event) {
        component.set("v.isConfirmationDelete", true);
        this.showSpinnerHelper(component);

        this.openPopupHelper(component, 'small');

        var wrap = component.get("v.policywrap");
        var action = component.get("c.deletePaymentMethod");

        console.log('delete wrap:', wrap);
        action.setParams({
            wrapperObj: wrap,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var toastList = [];

            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result) {
                    component.set("v.isConfirmationDelete", false);
                    console.log('delete Result:', result);
                    this.reloadDataHelper(component);
                    toastList.push(
                        {
                            type: 'suc',
                            message: 'Payment method is deleted.'
                        });
                    component.set('v.isSavedScreen', true);
                    component.set('v.isAddScreen', false);
                } else {
                    toastList.push(
                        {
                            type: 'err',
                            //message: 'Oops something went wrong.'
                            message:'An error occurred while removing the Payment Method please contact ISBA Mutual Team.' 
                        });
                }
            } else if (state === "INCOMPLETE") {
                toastList.push(
                    {
                        type: 'err',
                        message: 'Incomplete.'
                    });
            } else if (state === "ERROR") {
                var errors = response.getError();
                var isInternalUser = component.get("v.isInternalUser");
                var errorMsg;
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        let err = JSON.parse(errors[0].message);
                        errorMsg = err.errorMsg;
                        this.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                    }
                }
                
                if (isInternalUser == 'true') {
                    if (errorMsg) {
                        console.log("Error message: " + errorMsg);
                        toastList.push(
                            {
                                type: 'err',
                                message: errorMsg
                            }
                        );
                /*if (isInternalUser == 'true') {
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("savePayment--> Error message: " + errors[0].message);
                            toastList.push(
                                {
                                    type: 'err',
                                    message: errors[0].message
                                });
                        }*/
                    } else {
                        toastList.push(
                            {
                                type: 'err',
                                message: 'Unknown error'
                            });
                    }
                }
                else{
                    toastList.push(
                        {
                            type: 'err',
                            message: 'An error occurred while removing the Payment Method please contact ISBA Mutual Team.'
                        });
                    //block next button 
                }
            }
            this.showToastHelper(component, toastList, 4);
            this.closeSpinnerHelper(component);
            this.closepopupHelper(component, 'small');
        });
        $A.enqueueAction(action);
    },
    processPaymentHelper: function (component) {
        var wrapper = component.get("v.policywrap");
        var ipAdd = component.get("v.ipAddress");
        var usrSession = component.get("v.userSession");
		var formFactor = component.get("v.formFactor");
        
        wrapper.deviceType = formFactor;
        wrapper.screenResolution = screen.width + " x " + screen.height;
        wrapper.windowSize = window.innerWidth + " x " + window.innerHeight;
        
        for(let x of wrapper.policyLawyers){
            delete x.formatedPhone;
        }

        var action = component.get("c.processPayment");
        this.showSpinnerHelper(component);
        action.setParams({
            warpperObjStr: JSON.stringify(wrapper),
            ipAddress: ipAdd,
            userSession: usrSession
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            // component.set('v.isHeaderFooterModal', false);
            component.set('v.isAddScreen', false);
            // component.set('v.isWithoutHeaderFooterModal', true);
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('result: => ', result);
                var flag = false;
                if (!(result.includes('Error') || result.includes('error'))) {
                    wrapper.receiptNumber = result;
                    component.set('v.policywrap', wrapper);
                    flag = true
                    if(wrapper.isPolicy){
                        this.convertToPolicyHelper(component, flag);
                    } 
                    else{
                        this.approveEndorsementHelper(component);
                    }
                }
                else{
                    component.set('v.paymentErrorMessageOnScreen', result);
                    component.set("v.isPaymentAndPolicyStatus", true);
                    component.set("v.isPolicySuccess", false);
                    component.set("v.isPaymentSuccess", false);
                    var popupModalId = component.find("popupID");
                    $A.util.removeClass(popupModalId, 'openPopup');  
                    this.closeSpinnerHelper(component);
                }
                // $A.util.removeClass(spinner, 'showFullScreenSpinner');
                //component.set('v.paymentErrorMessageOnScreen', result);
                // component.set('v.isPaymentError', true);
            } else if (state === 'INCOMPLETE') {
                console.log('incomplete');
                // $A.util.removeClass(spinner, 'showFullScreenSpinner');
                component.set('v.paymentErrorMessageOnScreen', 'Incomplete');
                component.set('v.isPaymentError', true);
                this.openPopupHelper(component, 'nor');
                this.closeSpinnerHelper(component);
                //var popupModalId = component.find("popupID");
                //$A.util.removeClass(popupModalId, 'openPopup');
            } else if (state === 'ERROR') {
                var errors = response.getError();
                var errorMsg;
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        let err = JSON.parse(errors[0].message);
                        errorMsg = err.errorMsg;
                        this.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                    }
                }
                if (errorMsg) {
                    console.log("Error message: " + errorMsg);
                    component.set('v.paymentErrorMessageOnScreen', errorMsg);
                    component.set('v.isPaymentError', true);
                    this.openPopupHelper(component, 'nor');                    
                } else {
                    // $A.util.removeClass(spinner, 'showFullScreenSpinner');
                    component.set('v.paymentErrorMessageOnScreen', errors[0].message);
                    component.set('v.isPaymentError', true);
                    this.openPopupHelper(component, 'nor');
                    console.log("Unknown error");
                }
                this.closeSpinnerHelper(component);
                //var popupModalId = component.find("popupID");
                //$A.util.removeClass(popupModalId, 'openPopup');
            }
        });
        $A.enqueueAction(action);
    },

    setToPayHelper: function (component, event) {
        var wrapper = component.get('v.policywrap');

        var currentActiveTab = wrapper.paymentTypeVar;
        var currentMethodId = wrapper.paymentMethodId;
        if (currentActiveTab == 'creditCard') {
            var savedCardList = component.get("v.savedCardList");
            for (var i = 0; i < savedCardList.length; i++) {
                if (currentMethodId == savedCardList[i].paymentMethod.Id) {
                    savedCardList[i].isSetToPay = true;
                } else {
                    savedCardList[i].isSetToPay = false;
                }
            }
            component.set("v.savedCardList", savedCardList);
            return true;
        } else if (currentActiveTab == 'check') {
            var savedEcheckList = component.get("v.savedEcheckList");
            for (var i = 0; i < savedEcheckList.length; i++) {
                if (currentMethodId == savedEcheckList[i].paymentMethod.Id) {
                    savedEcheckList[i].isSetToPay = true;
                } else {
                    savedCardList[i].isSetToPay = false;
                }
            }
            component.set("v.savedEcheckList", savedEcheckList);
            return true;
        } else {
            return false;
        }
    },

    approveEndorsementHelper:function (component){
        this.showSpinnerHelper(component);
        var toastList = [];
        var wrap = component.get("v.policywrap");
        var action = component.get("c.approveEndorsement");
        action.setParams(
            { "recId": wrap.endorsement.Id}
        );
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set("v.isPaymentAndPolicyStatus", true);

            if (state === "SUCCESS") {
                if (response.getReturnValue() == true) {
                    component.set("v.isPolicySuccess", true);

                    // toastList.push({
                    //     type: 'suc',
                    //     message: 'Policy is successfully converted.'
                    // })
                } else {
                    component.set("v.isPolicySuccess", false);
                    var err = 'Some Error has occurred. Please contact your System Administrator.'
                    component.set("v.policyErrorMessageOnScreen", err);
                    console.log('approveEndorsement success-> else');
                }
            } else {
                component.set("v.isPolicySuccess", false);
                var err = 'Some Error has occurred. Please contact your System Administrator.'
                component.set("v.policyErrorMessageOnScreen", err);
                console.log('approveEndorsement else-> else');
            }
           
            component.set("v.isPaymentSuccess", true);
            
            this.closeSpinnerHelper(component);
            var popupModalId = component.find("popupID");
                                $A.util.removeClass(popupModalId, 'openPopup');
            this.showToastHelper(component, toastList, 5);
        });
        $A.enqueueAction(action);
    },
    //Policy methods 
    convertToPolicyHelper: function (component, flag) {
        this.showSpinnerHelper(component);
        var toastList = [];
        var wrap = component.get("v.policywrap");
        var policyDocVersion = wrap.policy.Policy_Document_Version__c;
        var action = component.get("c.convertPolicy");
        action.setParams(
            { "policyId": wrap.policy.Id, "policyDocVersion": policyDocVersion }
        );
        // Configure response handler
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set("v.isPaymentAndPolicyStatus", true);

            if (state === "SUCCESS") {
                if (response.getReturnValue() == true) {
                    component.set("v.isPolicySuccess", true);

                    // toastList.push({
                    //     type: 'suc',
                    //     message: 'Policy is successfully converted.'
                    // })
                } else {
                    component.set("v.isPolicySuccess", false);
                    var err = 'Some Error has occurred. Please contact your System Administrator.'
                    component.set("v.policyErrorMessageOnScreen", err);
                    console.log('convertToPolicyHelper success-> else');
                }
            } else {
                component.set("v.isPolicySuccess", false);
                var err = 'Some Error has occurred. Please contact your System Administrator.'
                component.set("v.policyErrorMessageOnScreen", err);
                console.log('convertToPolicyHelper else-> else');
            }
            if (flag) {
                component.set("v.isPaymentSuccess", true);
            } else {
                component.set("v.isPaymentSuccess", true);
            }
            this.closeSpinnerHelper(component);
            var popupModalId = component.find("popupID");
            $A.util.removeClass(popupModalId, 'openPopup');
            this.showToastHelper(component, toastList, 5);
        });
        $A.enqueueAction(action);
    },
    updatePolicyHelper: function (component, to, buttype, updateForIbfContribution) {   
        this.showSpinnerHelper(component);
        var action = component.get("c.UpdatePolicy");
        var wrapper = component.get("v.policywrap");
        console.log('policyWrapper: ', wrapper);
        var toastList = [];

        action.setParams({
            policy: wrapper.policy,
            updateForIbfContribution : updateForIbfContribution
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(updateForIbfContribution){
                    component.set("v.policywrap.policy.Status__c" ,'Accepted');
                    this.policyAllMethodsHelper(component);
                }
                console.log('Update policy result:', result);
                if(buttype && to){
                	this.getDetails(component, component.get("v.lastTime"), true, to, buttype);
                    this.changeStepHelper(component, to, buttype);
                }
            } else if (state === "INCOMPLETE") {
                toastList.push(
                    {
                        type: 'err',
                        message: 'Incomplete.'
                    });
                this.closeSpinnerHelper(component);
                this.showToastHelper(component, toastList, 3);
            } else if (state === "ERROR") {
                var errors = response.getError();
                var isInternalUser = component.get("v.isInternalUser");
                var errorMsg;
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        let err = JSON.parse(errors[0].message);
                        errorMsg = err.errorMsg;
                        this.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                    }
                }
                if(errorMsg == 'This Policy is Already Bind.'){
                    component.set("v.showScreenLoading", false);
                    component.set("v.isDataLoadSuccess", false);
                    this.closeSpinnerHelper(component);
                    component.set("v.hasError", true);
                    return false;
                }
                if (isInternalUser == 'true') {
                    if (errorMsg) {
                        console.log("Error message: " + errorMsg);
                        toastList.push(
                            {
                                type: 'err',
                                message: errorMsg
                            }
                        );
                /*if (isInternalUser == 'true') {
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            toastList.push(
                                {
                                    type: 'err',
                                    message: errors[0].message
                                });

                            console.log("Error message: " + errors[0].message);
                        }*/
                    } else {
                        toastList.push(
                            {
                                type: 'err',
                                message: 'Unknown error.'
                            });
                    }
                }
                else{
                    toastList.push(
                        {
                            type: 'err',
                            message: 'An error occurred while processing your policy please contact ISBA Mutual Team.'
                        });
                    //block next button 
                    component.set("v.isNextButtonDisabled", true);
                }
                this.closeSpinnerHelper(component);
                this.showToastHelper(component, toastList, 3);
            }
        });
        $A.enqueueAction(action);
    },
    finalizeQuoteHelper: function (component, event, quoteId, to, buttype) {
        this.showSpinnerHelper(component);
        var toastList = [];
        if (quoteId == null) {
            return false;
        }
        else {     
            var policywrap = component.get("v.policywrap");

            var action = component.get("c.finalizeQuote");
            action.setParams({
                policyId: policywrap.policy.Id,
                quoteId: quoteId,
                lawyers: policywrap.policyLawyers
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('state:', state);
                if (state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    console.log('finalize quote result => ', result);
                    component.set("v.TermsAndConditionWrapper",result);
                    var isIbf = component.get("v.hidStepTwo");
                    /*if (!isIbf) {
                        // var to = 2;
                        this.updatePolicyHelper(component, to, buttype, true);
                    }  */             
                    this.getDetails(component, component.get("v.lastTime"), true, to, buttype);
                    // Code when Success
                } else if (state === 'INCOMPLETE') {
                    toastList.push(
                        {
                            type: 'err',
                            message: "Unknown error"
                        }
                    );
                    return false;
                } else if (state === 'ERROR') {
                    var errors = response.getError();
                    var isInternalUser = component.get("v.isInternalUser");
                    var errorMsg;
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            let err = JSON.parse(errors[0].message);
                            errorMsg = err.errorMsg;
                            this.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                        }
                    }
                    if(errorMsg == 'This Policy is Already Bind.'){
                        component.set("v.showScreenLoading", false);
                        component.set("v.isDataLoadSuccess", false);
                        component.set("v.hasError", true);
                        return false;
                    }
                    if (isInternalUser == 'true') {
                        if (errorMsg) {
                            console.log("Error message: " + errorMsg);
                            toastList.push(
                                {
                                    type: 'err',
                                    message: errorMsg
                                }
                            );
                            
                        } else {
                            console.log("Unknown error");
                            toastList.push(
                                {
                                    type: 'err',
                                    message: "Unknown error"
                                }
                            );
                        }
                    }else{
                        toastList.push(
                            {
                                type: 'err',
                                message: 'An error occurred while processing your policy please contact ISBA Mutual Team.'
                            });
                        //block next button 
                        component.set("v.isNextButtonDisabled", true);
                    }
                    return false;
                }
                this.showToastHelper(component, toastList, 5);
                this.closeSpinnerHelper(component);
            });
            $A.enqueueAction(action);
        }
    },
    policyAllMethodsHelper: function (component) {
        console.log('called convert');
        this.showSpinnerHelper(component);
        var wrap = component.get("v.policywrap");

        var policyStatus = wrap.policy.Status__c;
        var totalQuotes = wrap.policy.Total_Quotes__c;
        var totalFinalQuotes = wrap.policy.Total_Final_Quotes__c;
        var totalAOPPercentage = wrap.policy.AOP_Percentage__c;
        var totalLawyer = wrap.policy.Total_Lawyers__c;
        var priorActsDate = wrap.policy.Policy_Retroactive_Date__c;
        var totalPremium = wrap.policy.Premium__c;
        var policyDocVersion = wrap.policy.Policy_Document_Version__c;
        var fullPriorActs = wrap.policy.Full_Prior_Acts__c;

        var toastList = [];
        if (!(policyStatus == 'Accepted' || policyStatus == 'Quoted')) {
            toastList.push({
                type: 'err',
                message: 'Status must be Accepted or Quoted.'
            })
        } if (totalLawyer == '0') {
            toastList.push({
                type: 'err',
                message: 'No Lawyer(s) added.'
            })
        }
        if (totalAOPPercentage != '100') {
            toastList.push({
                type: 'err',
                message: 'Either AOP is not given or its percentage is not equal to 100.'
            })
        }
        if (totalQuotes == '0') {
            toastList.push({
                type: 'err',
                message: 'There is no Quote associated to this Application.'
            })
        }
        if (!priorActsDate && fullPriorActs == false) {
            toastList.push({
                type: 'err',
                message: 'Please enter a valid prior date in order to proceed.'
            })
        }
        if (totalFinalQuotes != '1' && totalQuotes > 1) {
            toastList.push({
                type: 'err',
                message: 'Please mark one Quote as Final.'
            })
        }
        if (totalPremium < 0) {
            toastList.push({
                type: 'err',
                message: 'Policy premium should be over $500.'
            })
        }
        if (component.get("v.policywrap.policy.Underwriter_User__c") == null) {
            toastList.push({
                type: 'err',
                message: 'Underwriter User is Missing.'
            })
        }

        if (component.get("v.policywrap.policy.Firm_Contact__c") == null) {
            toastList.push({
                type: 'err',
                message: 'Firm Contact is Missing.'
            })
        }

        if (component.get("v.policywrap.policy.Account__r.Phone") == null) {
            toastList.push({
                type: 'err',
                message: 'Phone Number is Missing.'
            })
        }

        if (component.get("v.policywrap.policy.Account__r.BillingStreet") == null || component.get("v.policywrap.policy.Account__r.BillingCity") == null || component.get("v.policywrap.policy.Account__r.BillingState") == null || component.get("v.policywrap.policy.Account__r.BillingPostalCode") == null) {
            toastList.push({
                type: 'err',
                message: 'Firm Address is Missing.'
            })
        }

        if (component.get("v.policywrap.policy.County__r.Name") == 'TO BE DETERMINED') {
            toastList.push({
                type: 'err',
                message: 'County is Missing.'
            })
        }

        var actionOne = component.get("c.hasAllLawyersARDC");
        actionOne.setParams(
            { "policyId": wrap.policy.Id }
        );
        actionOne.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != 'Yes') {
                    toastList.push({
                        type: 'err',
                        message: 'These Lawyers does not have ARDC Numbers: ' + response.getReturnValue() + '.'
                    })
                }
            } else {
                if (state === 'ERROR') {
                    var errors = response.getError();
                    var isInternalUser = component.get("v.isInternalUser");
                    var errorMsg;
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            errorMsg = errors[0].message;
                        }
                    }
                    if(errorMsg == 'This Policy is Already Bind.'){
                        var popupModalId = component.find("popupID");
                        $A.util.removeClass(popupModalId, 'openPopup');
                        component.set("v.showScreenLoading", false);
                        component.set("v.isDataLoadSuccess", false);
                        component.set("v.hasError", true);
                        this.closeSpinnerHelper(component);
                        return false;
                    }
                }
                toastList.push({
                    type: 'err',
                    message: 'State: ' + state + ' || Some Error has occurred. Please contact your System Administrator.'
                })
                // errorMessage += 'Some Error has occurred. Please contact your System Administrator.';
                // console.log('Problem getting account, response state: ' + state);
            }
            if (toastList.length) {
                this.closeSpinnerHelper(component);
                var popupModalId = component.find("popupID");
                                $A.util.removeClass(popupModalId, 'openPopup');
                this.showToastHelper(component, toastList, 8);
                // helper.showError(component, event, helper, errorMessage);
                // component.set("v.spinner", false);
                // component.set("v.msg", errorMessage);
            } else {
                var blockAction = component.get("c.hasBlocks");
                blockAction.setParams(
                    { "policyId": wrap.policy.Id }
                );
                blockAction.setCallback(this, function (response) {
                    var state = response.getState();
                    /*if (state === "SUCCESS") {
                        if (response.getReturnValue() == true) {
                            toastList.push({
                                type: 'err',
                                message: 'This application has some blocks. Please resolve them in order to Bind this.'
                            })
                            // errorMessage += 'This application has some blocks. Please resolve them in order to Bind this.' ;
                        }
                    } else {
                        toastList.push({
                            type: 'err',
                            message: 'State: ' + state + ' || Some Error has occurred. Please contact your System Administrator.'
                        })
                        // errorMessage+='Some Error has occurred. Please contact your System Administrator.';
                        // console.log('Problem getting account, response state: ' + state);
                    }*/
                    var aopAction = component.get("c.hasUndefinedAOP");
                    aopAction.setParams(
                        { "policyId": wrap.policy.Id }
                    );
                    aopAction.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            if (response.getReturnValue() == true) {

                                toastList.push({
                                    type: 'err',
                                    message: 'This application has some undefined AOP\'s.'
                                })
                                // errorMessage += 'This application has some undefined AOP\'s';
                            }
                        } else {
                            // toastList.push({
                            //     type: 'err',
                            //     message: 'Problem getting account, response state: ' + state
                            // })
                            console.log('Problem getting account, response state: ' + state);
                        }
                        var valid106Action = component.get("c.hasInvalid106");
                        valid106Action.setParams(
                            { "policyId": wrap.policy.Id }
                        );
                        valid106Action.setCallback(this, function (response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                if (response.getReturnValue() == true) {
                                    toastList.push({
                                        type: 'err',
                                        message: '106 endorsement invalid on policies with multiple lawyers.'
                                    })
                                    // errorMessage += '106 endorsement invalid on policies with multiple lawyers';
                                }
                            } else {
                                console.log('Problem getting account, response state: ' + state);
                            }
                            if (toastList.length) {
                                this.closeSpinnerHelper(component);
                                var popupModalId = component.find("popupID");
                                $A.util.removeClass(popupModalId, 'openPopup');
                                this.showToastHelper(component, toastList, 8);
                                // helper.showError(component, event, helper,errorMessage);
                                // component.set("v.spinner", false);
                                // component.set("v.msg", errorMessage);
                            } else {
                                this.processPaymentHelper(component);
                                // this.convertToPolicyHelper(component)
                            }
                        });
                        $A.enqueueAction(valid106Action);
                    });
                    $A.enqueueAction(aopAction);
                });
                $A.enqueueAction(blockAction);
            }
        });
        $A.enqueueAction(actionOne);
    },

    // Card and Echeck fields: 
    isFieldEmptyHelper: function (input) {
        if (input.value == '') {
            input.className = 'errorInput';
            return input.name;
        } else {
            input.className = '';
            return '';
        }
    },
    isCardTypeHelper: function (component, cardType, cardNumber, cardCvv) {
        if (cardType.value == 'amex') {
            component.set('v.numberOfCardCvv', '4');
            var currentCvvValue = component.get('v.cardCvv');
            var temp = '';
            for (var i = currentCvvValue.length; i < 4; i++) {
                temp += 'X';
            }
            component.set('v.cardCvv', currentCvvValue + temp);
        } else {
            component.set('v.numberOfCardCvv', '3');
            var currentCvvValue = component.get('v.cardCvv');
            currentCvvValue = currentCvvValue.slice(0, 3);
            component.set('v.cardCvv', currentCvvValue);
        }
        if (cardType.value != 'none') {
            if (cardNumber.value != '') {
                var cardNumberVal = this.isCardNumberValidHelper(cardNumber);
                if (cardNumberVal == '') {
                    var comparedNumberAndTypeVal = this.compareCardNumberAndTypeHelper(cardNumber, cardType);
                    if (comparedNumberAndTypeVal != '') {
                        if (cardCvv.value != '') {
                            this.isCvvValidHelper(component, cardCvv, cardType);
                        }
                    }
                }
            } if (cardCvv.value != '') {
                this.isCvvValidHelper(component, cardCvv, cardType);
            }
        }
    },
    isCardNumberValidHelper: function (cardNumber_input) {
        if (cardNumber_input.value != '') {
            var cardNumber = cardNumber_input.value;
            cardNumber = cardNumber.split(' ').join("");
            if (parseInt(cardNumber) <= 0 || (!/\d{15,16}(~\W[a-zA-Z])*$/.test(cardNumber)) || cardNumber.length > 16) {
                cardNumber_input.className = 'errorInput';
                return 'Card Number is not valid';
            }
            var carray = new Array();
            for (var i = 0; i < cardNumber.length; i++) {
                carray[carray.length] = cardNumber.charCodeAt(i) - 48;
            }
            carray.reverse();
            var sum = 0;
            for (var i = 0; i < carray.length; i++) {
                var tmp = carray[i];
                if ((i % 2) != 0) {
                    tmp *= 2;
                    if (tmp > 9) {
                        tmp -= 9;
                    }
                }
                sum += tmp;
            }
            if ((sum % 10) == 0) {
                cardNumber_input.className = '';
                return '';
            } else {
                cardNumber_input.className = 'errorInput';
                return 'Card Number is not correct';
            }
        } else {
            cardNumber_input.className = 'errorInput';
            return cardNumber_input.name;
        }
    },
    compareCardNumberAndTypeHelper: function (cardNumber_input, cardType) {
        if (cardNumber_input.value != '' && cardType.value != 'none') {
            var cardNumber = cardNumber_input.value;
            cardNumber = cardNumber.split(' ').join("");
            var o = {
                //electron: /^(4026|417500|4405|4508|4844|4913|4917)\d+$/,
                //maestro: /^(5018|5020|5038|5612|5893|6304|6759|6761|6762|6763|0604|6390)\d+$/,
                //dankort: /^(5019)\d+$/,
                //interpayment: /^(636)\d+$/,
                //unionpay: /^(62|88)\d+$/,
                'visa': /^4[0-9]{12}(?:[0-9]{3})?$/,
                'MasterCard': /^5[1-5][0-9]{14}$/,
                'amex': /^3[47][0-9]{13}$/,
                //diners: /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/,
                'Discover': /^6(?:011|5[0-9]{2})[0-9]{12}$/
                //jcb: /^(?:2131|1800|35\d{3})\d{11}$/
            }
            var type = '';
            console.log('type-> ', type);
            for (var k in o) {
                if (o[k].test(cardNumber)) {
                    type = k;
                }
            }
            if (cardType.value == type) {
                console.log('match');
                cardType.className = '';
                return '';
            } else {
                console.log('errror 1');

                cardType.className = 'errorInput';
                return 'Card Number and Card type is not matched.';
            }
        } else {
            cardType.className = 'errorInput';
            return '';
        }
    },
    isCvvValidHelper: function (component, cardCvv, cardType) {
        var cvvNumber = cardCvv.value;
        var ccType = cardType.value;
        var isDisbled = component.get("v.fieldDisabled");
        if (isDisbled) {
            if (ccType != 'none') {
                let cvv = cvvNumber.toString();
                if (ccType === 'amex') {
                    var match = cvv.match("^\\d{4}$");
                    if (!match) {
                        cardCvv.className = 'errorInput';
                        return 'CVV must be 4 digits';
                    } else {
                        cardCvv.className = '';
                        return '';
                    }
                } else {
                    var match = cvv.match("^\\d{3}$");
                    if (!match) {
                        // obj.error = "CVV must be 3 digits"
                        cardCvv.className = 'errorInput';
                        return 'CVV must be 3 digits';
                    } else {
                        cardCvv.className = '';
                        return '';
                    }
                }
            } else if (ccType != 'none') {
                cardType.className = 'errorInput';
                return '';
            } else {
                cardCvv.className = '';
                return '';
            }
        } else {
            if (cvvNumber != '' && ccType != 'none') {
                let cvv = cvvNumber.toString();
                if (ccType === 'amex') {
                    var match = cvv.match("^\\d{4}$");
                    if (!match) {
                        cardCvv.className = 'errorInput';
                        return 'CVV must be 4 digits';
                    } else {
                        cardCvv.className = '';
                        return '';
                    }
                } else {
                    var match = cvv.match("^\\d{3}$");
                    if (!match) {
                        // obj.error = "CVV must be 3 digits"
                        cardCvv.className = 'errorInput';
                        return 'CVV must be 3 digits';
                    } else {
                        cardCvv.className = '';
                        return '';
                    }
                }
            } else if (cvvNumber == '') {
                cardCvv.className = 'errorInput';
                return cardCvv.name;
            } else if (ccType != 'none') {
                cardType.className = 'errorInput';
                return '';
            } else {
                cardCvv.className = '';
                return '';
            }
        }
    },
    getCardTypeHelper: function (cardNumber_input) {
        if (cardNumber_input.value != '') {
            var cardNumber = cardNumber_input.value;
            // returns card type; should not rely on this for checking if a card is valid
            cardNumber = cardNumber.split(' ').join("");
            var o = {
                //electron: /^(4026|417500|4405|4508|4844|4913|4917)\d+$/,
                //maestro: /^(5018|5020|5038|5612|5893|6304|6759|6761|6762|6763|0604|6390)\d+$/,
                //dankort: /^(5019)\d+$/,
                //interpayment: /^(636)\d+$/,
                //unionpay: /^(62|88)\d+$/,
                'visa': /^4[0-9]{12}(?:[0-9]{3})?$/,
                'MasterCard': /^5[1-5][0-9]{14}$/,
                'amex': /^3[47][0-9]{13}$/,
                //diners: /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/,
                'Discover': /^6(?:011|5[0-9]{2})[0-9]{12}$/
                //jcb: /^(?:2131|1800|35\d{3})\d{11}$/
            }
            for (var k in o) {
                if (o[k].test(cardNumber)) {
                    return k;
                }
            }
            return null;
        } else {
            return null;
        }

    },
    isExpiryValidHelper: function (component ,cardExpiryMonth, cardExpiryYear) {
        if (cardExpiryMonth.value != 'none' && cardExpiryYear.value != 'none') {
            var dateObj = new Date();
            let thisYear = dateObj.getFullYear();
            let thisMonth = dateObj.getMonth() + 1;

            if (cardExpiryYear.value == thisYear) {
                if (cardExpiryMonth.value < thisMonth) {
                    cardExpiryMonth.className = 'errorInput';
                    cardExpiryYear.className = 'errorInput';
                    return 'Expiry Date should not be less than today.';
                } else {
                    component.set("v.policywrap.expireMonth", cardExpiryMonth.value);
                    component.set("v.policywrap.expireYear", cardExpiryYear.value);
                    cardExpiryMonth.className = '';
                    cardExpiryYear.className = '';
                    return '';
                }
            } else {
                component.set("v.policywrap.expireMonth", cardExpiryMonth.value);
                component.set("v.policywrap.expireYear", cardExpiryYear.value);
                cardExpiryMonth.className = '';
                cardExpiryYear.className = '';
                return '';
            }
        } else {
            if (cardExpiryMonth.value == 'none' && cardExpiryYear.value == 'none') {
                cardExpiryMonth.className = 'errorInput';
                cardExpiryYear.className = 'errorInput';
                return cardExpiryYear.name;
            } if (cardExpiryMonth.value == 'none') {
                cardExpiryMonth.className = 'errorInput';
                return 'Expiry Month';
            } if (cardExpiryYear.value == 'none') {
                cardExpiryYear.className = 'errorInput';
                return 'Expiry Year';
            }
        }
    },
    securityMailHelper: function (component, securityMail) {
        if (securityMail.value != '') {
            var email = securityMail.value;
            var mailformat = new RegExp(component.get("v.emailRegex"));
            if (!(email.trim().match(mailformat))) {
                securityMail.className = 'errorInput';
                return 'Email is not Valid';
            } else {
                securityMail.className = '';
                return '';
            }
        } else {
            securityMail.className = 'errorInput';
            return securityMail.name;
        }
    },
    isRoutingNumberValidHelper: function (input) {
        if (input.value != '') {
            // pad 0's tp 9 digits
            var routing = (input.value).toString();
            while (routing.length < 9) {
                routing = '0' + routing;
            }
            // varify length of 9 didgits
            var match = routing.match("^\\d{9}$");
            if (!match) {
                input.className = 'errorInput';
                return 'Routing Number length should be 9';
            }

            // https://en.wikipedia.org/wiki/Routing_transit_number
            // first two digits must be in the ranges;
            //    00 through 12, 
            //    21 through 32,
            //    61 through 72,
            //    or 80.
            const start = parseInt(routing.substring(0, 2));
            const valid_start = (0 <= start && start <= 12) || (21 <= start && start <= 32) || (61 <= start && start <= 72) || start === 80;
            if (!valid_start) {
                input.className = 'errorInput';
                return 'Routing Number is Invalid';
            }
            // test checksum
            // http://www.siccolo.com/Articles/SQLScripts/how-to-create-sql-to-calculate-routing-check-digit.html
            const weights = [3, 7, 1];
            var sum = 0;
            for (var i = 0; i < 8; i++) {
                sum += parseInt(routing[i]) * weights[i % 3];
            }
            var result = (10 - (sum % 10)) % 10 === parseInt(routing[8]);
            if (!result) {
                input.className = 'errorInput';
                return 'Routing Number is Invalid';
            } else {
                input.className = '';
                return '';
            }
        } else {
            input.className = 'errorInput';
            return input.name;
        }
    },
    isAccountNumberValidHelper: function (input) {
        if (input.value && !isNaN(input.value) && input.value.length > 3 && input.value.length < 18) {
            input.className = '';
            return '';
        } else {
            input.className = 'errorInput';
            return input.name;
        }
    },
    showCardNumberOnDisplayCardHelper: function (number) {
        var temp = '';
        for (var i = number.length; i < 4; i++) {
            temp += '-';
        }
        return number + temp;
    },
	
    validateEmailFieldsHelper: function (component) {
        this.showSpinnerHelper(component);
        var activeTab = component.get('v.currentActiveTab');
        var emptyFieldList = [];
        var toastList = [];
        var toasttime = 4;
        var SendConfirmationEmail;   
        if (activeTab == 'tab-1') {
            SendConfirmationEmail = document.getElementById('cardSendConfirmationEmail');
        }
        else if (activeTab == 'tab-2') {
            SendConfirmationEmail = document.getElementById('checkSendConfirmationEmail');
        }
        var SendConfirmationEmailVal = this.isFieldEmptyHelper(SendConfirmationEmail);
        if (SendConfirmationEmailVal != '') {
            if (SendConfirmationEmailVal == SendConfirmationEmail.name) {
                emptyFieldList.push(
                    {
                        type: 'err',
                        field: SendConfirmationEmailVal
                    });
            } else {
                toastList.push(
                    {
                        type: 'err',
                        message: SendConfirmationEmailVal
                    });
            }
        }
        if (emptyFieldList.length) {
            var completeError = 'Please fill the ';
            for (var i = 0; i < emptyFieldList.length; i++) {
                if (i != (emptyFieldList.length - 1)) {
                    completeError += emptyFieldList[i].field + ', ';
                } else {
                    completeError += emptyFieldList[i].field;
                }
            }
            if (emptyFieldList.length == 1) {
                completeError += ' field.';
            } else {
                completeError += ' fields.';
            }
            
            toastList.push(
                {
                    type: 'error',
                    message: completeError
                }
            );
        }
        
        if (toastList.length) {
            this.closeSpinnerHelper(component);
            this.showToastHelper(component, toastList, toasttime);
        }
        if (!toastList.length) {
            component.set('v.policywrap.confirmationEmail',SendConfirmationEmail.value);
            this.closeSpinnerHelper(component);
            return true;
        }
        else {
            this.closeSpinnerHelper(component);
            return false;
        }
    },
    
    // validate all card/echeck fields 
    validateAllFieldsHelper: function (component) {
        this.showSpinnerHelper(component);
        var activeTab = component.get('v.currentActiveTab');
        // var setAutoPay = component.get("v.isAutoPay");;
        var toastList = [];
        var emptyFieldList = [];
        var toasttime = 4;
        var savedClick = component.get("v.savedItemClick");

        if (activeTab == 'tab-1') {

            //let cardFirstName = document.getElementById('cardFirstName'); // card first Name
            //let cardLastName = document.getElementById('cardLastName'); // card last name
            let cardType = document.getElementById('cardType'); // card type
            let cardNumber = document.getElementById('cardNumber'); // card number
            let cardCVV = document.getElementById('cardCVV'); // card cvv
            let cardExpiryMonth = document.getElementById('cardExpiryMonth'); // card expiry month
            let cardExpiryYear = document.getElementById('cardExpiryYear'); // card expiry year
            let cardNameOnCard = document.getElementById('cardNameOnCard'); // card holder name
            var cardSendConfirmationEmail = '';
            if(component.get("v.isAddPaymentMethod")){
                cardSendConfirmationEmail = document.getElementById('cardSendConfirmationEmail'); // card email confirmation code
            }
            // var setAutoPay = document.getElementById('creditcardAutoPay').checked;
            // console.log('setAutoPay:', setAutoPay);

            //var firstNameVal = this.isFieldEmptyHelper(cardFirstName);
            //var lastNameVal = this.isFieldEmptyHelper(cardLastName);
            var expiryReturnVal = this.isExpiryValidHelper(component ,cardExpiryMonth, cardExpiryYear);
            if(component.get("v.isAddPaymentMethod")){
                var confirmationEmailVal = this.securityMailHelper(component, cardSendConfirmationEmail);
            }
            var cvvVal = undefined;
            if(!component.get("v.disableFields")){
                cvvVal = this.isCvvValidHelper(component, cardCVV, cardType);
            }
            // if (firstNameVal != '') {
            //     emptyFieldList.push(
            //         {
            //             type: 'err',
            //             field: firstNameVal
            //         });
            // } if (lastNameVal != '') {
            //     emptyFieldList.push(
            //         {
            //             type: 'err',
            //             field: lastNameVal
            //         });
            // } 
            if (!savedClick) {
                var cardNumberVal = this.isCardNumberValidHelper(cardNumber);
                var nameOnCardVal = this.isFieldEmptyHelper(cardNameOnCard);
                console.log('nameOnCardVal:', nameOnCardVal);
                if (cardType.value == 'none') {
                    emptyFieldList.push(
                        {
                            type: 'err',
                            field: 'Card Type'
                        });
                    cardType.className = 'errorInput';
                } if (cardNumberVal != '') {
                    if (cardNumberVal == cardNumber.name) {
                        emptyFieldList.push(
                            {
                                type: 'err',
                                field: cardNumberVal
                            });
                    } else {
                        toastList.push(
                            {
                                type: 'err',
                                message: cardNumberVal
                            });
                    }
                } if (cardType.value != 'none') {
                    if (cardNumber.value != '') {
                        var cardNumberVal = this.isCardNumberValidHelper(cardNumber);
                        if (cardNumberVal == '') {
                            var comparedNumberAndTypeVal = this.compareCardNumberAndTypeHelper(cardNumber, cardType);
                            if (comparedNumberAndTypeVal != '') {
                                toastList.push(
                                    {
                                        type: 'err',
                                        message: comparedNumberAndTypeVal
                                    });
                            }
                        }
                    } if (cardCVV.value != '') {
                        this.isCvvValidHelper(component, cardCVV, cardType);
                    }
                }

                if (nameOnCardVal != '') {
                    emptyFieldList.push(
                        {
                            type: 'err',
                            field: nameOnCardVal
                        });
                }
            } if (!component.get("v.disableFields") && cvvVal != '') {
                if (cvvVal == cardCVV.name) {
                    emptyFieldList.push(
                        {
                            type: 'err',
                            field: cardCVV.name
                        });
                } else {
                    toastList.push(
                        {
                            type: 'err',
                            message: cvvVal
                        });
                }
            } if (expiryReturnVal != '') {
                if (expiryReturnVal == 'Expiry Date' || expiryReturnVal == 'Expiry Month' || expiryReturnVal == 'Expiry Year') {
                    emptyFieldList.push(
                        {
                            type: 'err',
                            field: expiryReturnVal
                        });
                } else {
                    toastList.push(
                        {
                            type: 'err',
                            message: expiryReturnVal
                        });
                }
            } 
            if(component.get("v.isAddPaymentMethod")){
                if (confirmationEmailVal != '') {
                    if (confirmationEmailVal == cardSendConfirmationEmail.name) {
                        emptyFieldList.push(
                            {
                                type: 'err',
                                field: confirmationEmailVal
                            });
                    } else {
                        toastList.push(
                            {
                                type: 'err',
                                message: confirmationEmailVal
                            });
                    }
                } 
                if (cardSendConfirmationEmail == '') {
                    emptyFieldList.push(
                        {
                            type: 'err',
                            field: 'Confirmation Email'
                        });
                } 
            }
            if (emptyFieldList.length) {
                var completeError = 'Please fill the ';
                for (var i = 0; i < emptyFieldList.length; i++) {
                    if (i != (emptyFieldList.length - 1)) {
                        completeError += emptyFieldList[i].field + ', ';
                    } else {
                        completeError += emptyFieldList[i].field;
                    }
                }
                if (emptyFieldList.length == 1) {
                    completeError += ' field.';
                } else {
                    completeError += ' fields.';
                }

                toastList.push(
                    {
                        type: 'err',
                        message: completeError
                    }
                );
            } if (toastList.length) {
                if (toastList.length > 3) {
                    toasttime = 7
                }
                this.closeSpinnerHelper(component);
                this.showToastHelper(component, toastList, toasttime);
            }
            if (!toastList.length) {
                console.log('Card Fields are valid.');
                var dataList = [
                    {
                        //'cardFirstName': cardFirstName.value,
                        //'cardLastName': cardLastName.value,
                        'cardTypeVar': cardType.value,
                        'cardNumber': cardNumber.value,
                        'verificationNumber': cardCVV.value,
                        'expireMonth': cardExpiryMonth.value,
                        'expireYear': cardExpiryYear.value,
                        'nameOnCard': cardNameOnCard.value,
                        'cardSendConfirmationEmail': cardSendConfirmationEmail!= ''? cardSendConfirmationEmail.value : '',
                        'paymentTypeVar': 'creditCard',
                        'isDefault': true,//setAutoPay,
                    }
                ]
                this.setValuesInWrapperHelper(component, 'creditCard', dataList, 0, 'validation');
                this.closeSpinnerHelper(component);
                return true;
            } else {
                this.closeSpinnerHelper(component);
                return false;
            }
        }
        else if (activeTab == 'tab-2') {
            //let checkFirstName = document.getElementById('checkFirstName'); // card first Name
            //let checkLastName = document.getElementById('checkLastName'); // card last name
            let checkAccountHolderName = document.getElementById('checkAccountHolderName'); // card number
            let checkAccountType = document.getElementById('checkAccountType'); // card expiry year
            let checkSendConfirmationEmail = document.getElementById('checkSendConfirmationEmail'); // card email confirmation code
            let checkAccountNumber = document.getElementById('checkAccountNumber'); // card expiry month
            let checkRoutingNumber = document.getElementById('checkRoutingNumber'); // card holder name

            //var checkFirstNameVal = this.isFieldEmptyHelper(checkFirstName);
            //var checkLastNameVal = this.isFieldEmptyHelper(checkLastName);
            if(component.get("v.isAddPaymentMethod")){
                var checkSendConfirmationEmailVal = this.isFieldEmptyHelper(checkSendConfirmationEmail);
                // var setAutoPay = document.getElementById('echeckAutoPay').checked;
                // console.log('setAutoPay:', setAutoPay);
                // if (checkFirstNameVal != '') {
                //     emptyFieldList.push(
                //         {
                //             type: 'err',
                //             field: checkFirstNameVal
                //         });
                // } if (checkLastNameVal != '') {
                //     emptyFieldList.push(
                //         {
                //             type: 'err',
                //             field: checkLastNameVal
                //         });
                // }
                if (checkSendConfirmationEmailVal != '') {
                    if (checkSendConfirmationEmailVal == checkSendConfirmationEmail.name) {
                        emptyFieldList.push(
                            {
                                type: 'err',
                                field: checkSendConfirmationEmailVal
                            });
                    } else {
                        toastList.push(
                            {
                                type: 'err',
                                message: confirmationEmailVal
                            });
                    }
                } 
            }
            if (!savedClick) {
                var checkAccountHolderNameVal = this.isFieldEmptyHelper(checkAccountHolderName);
                var checkAccountTypeVal = this.isFieldEmptyHelper(checkAccountType);
                var checkAccountNumberVal = this.isAccountNumberValidHelper(checkAccountNumber);
                var checkRoutingNumberVal = this.isRoutingNumberValidHelper(checkRoutingNumber);
                
                if (checkAccountType.value == 'none') {
                    emptyFieldList.push(
                        {
                            type: 'err',
                            field: 'Account Type'
                        });
                    checkAccountType.className = 'errorInput';
                }
                if (checkAccountHolderNameVal != '') {
                    emptyFieldList.push(
                        {
                            type: 'err',
                            field: checkAccountHolderNameVal
                        });
                }
                if (checkAccountTypeVal != '') {
                    emptyFieldList.push(
                        {
                            type: 'err',
                            field: checkAccountTypeVal
                        });
                }
                if (checkAccountNumberVal != '') {
                    if (checkAccountNumberVal == checkAccountNumber.name) {
                        emptyFieldList.push(
                            {
                                type: 'err',
                                field: checkAccountNumberVal
                            });
                    } else {
                        toastList.push(
                            {
                                type: 'err',
                                message: checkAccountNumberVal
                            });
                    }
                }
                if (checkRoutingNumberVal != '') {
                    if (checkRoutingNumberVal == checkRoutingNumber.name) {
                        emptyFieldList.push(
                            {
                                type: 'err',
                                field: checkRoutingNumberVal
                            });
                    } else {
                        toastList.push(
                            {
                                type: 'err',
                                message: checkRoutingNumberVal
                            });
                    }
                }
            } if (emptyFieldList.length) {
                var completeError = 'Please fill the ';
                for (var i = 0; i < emptyFieldList.length; i++) {
                    if (i != (emptyFieldList.length - 1)) {
                        completeError += emptyFieldList[i].field + ', ';
                    } else {
                        completeError += emptyFieldList[i].field;
                    }
                }
                if (emptyFieldList.length == 1) {
                    completeError += ' field.';
                } else {
                    completeError += ' fields.';
                }

                toastList.push(
                    {
                        type: 'error',
                        message: completeError
                    }
                );
            } if (toastList.length) {
                if (toastList.length > 3) {
                    toasttime = 7
                }
                this.closeSpinnerHelper(component);
                this.showToastHelper(component, toastList, toasttime);
            } if (!toastList.length) {
                console.log('Echeck Fields are valid.');
                let emval = '';
                if(component.get("v.isAddPaymentMethod")){
                    emval = checkSendConfirmationEmail.value;
                }
                var dataList = [
                    {
                        //'checkFirstName': checkFirstName.value,
                        //'checkLastName': checkLastName.value,
                        'routingNumber': checkRoutingNumber.value,
                        'accountNumber': checkAccountNumber.value,
                        'accountType': checkAccountType.value,
                        'accountHolderName': checkAccountHolderName.value,
                        'checkSendConfirmationEmail': emval,
                        'paymentTypeVar': 'check',
                        'isSetToPay': true,//setAutoPay,
                    }
                ]
                this.setValuesInWrapperHelper(component, 'check', dataList, 0, 'validation');
                this.closeSpinnerHelper(component);
                return true;
            } else {
                this.closeSpinnerHelper(component);
                return false;
            }
        } else {
            this.closeSpinnerHelper(component);
            return false;
        }
    },

    // validate Policy fields 
    validateIBFFieldsHelper: function (component) {
        var policywrap = component.get("v.policywrap");
        var showIbfDependentFields = component.get("v.showIbfDependentFields");

        var ibfConfig = document.getElementById('ibfContribution');
        policywrap.policy.IBF_Contribtuion__c = ibfConfig.value;

        var toastList = []
        var emptyFieldList = []
        if (showIbfDependentFields) {
            var donationType = component.get("v.donationType");
            if (donationType == 'Partial') {
                var ibfConfigCustAmount = document.getElementById('ibfContributionCustomAmount');
                var ibfConfigCustAmountVal = this.isFieldEmptyHelper(ibfConfigCustAmount);
                if (ibfConfigCustAmountVal != '') {
                    console.log('first if:', ibfConfigCustAmountVal);
                    emptyFieldList.push(
                        {
                            type: 'err',
                            field: ibfConfigCustAmountVal
                        });
                } 
                else if(parseFloat(ibfConfigCustAmount.value) <= 0){
                    toastList.push(
                        {
                            type: 'err',
                            message: 'The custom amount must be greater than 0'
                        }
                    );
                }
                else {
                    console.log('else:', ibfConfigCustAmountVal);
                    //debugger;
                    policywrap.policy.IBF_Custom_Amount__c = ibfConfigCustAmount.value;
                }
            }
            var showIbfTargetDependentField = component.get("v.showIbfTargetDependentField");
            var ibfTarget = document.getElementById('ibfTarget');
            var ibfTargetVal = this.isFieldEmptyHelper(ibfTarget);
            policywrap.policy.IBF_Target__c = ibfTarget.value;
            if (ibfTargetVal != '') {
                emptyFieldList.push(
                    {
                        type: 'err',
                        field: ibfTargetVal
                    });
            }
            if (showIbfTargetDependentField) {
                var ibfSpecificDistrict = document.getElementById('ibfSpecificDistrict');
                var ibfSpecificDistrictVal = this.isFieldEmptyHelper(ibfSpecificDistrict);
                policywrap.policy.IBF_Appellate_District__c = ibfSpecificDistrict.value;
                if (ibfSpecificDistrictVal != '') {
                    emptyFieldList.push(
                        {
                            type: 'err',
                            field: ibfSpecificDistrictVal
                        });
                }
            }
        }

        if (emptyFieldList.length) {
            var completeError = 'Please fill the ';
            for (var i = 0; i < emptyFieldList.length; i++) {
                if (i != (emptyFieldList.length - 1)) {
                    completeError += emptyFieldList[i].field + ', ';
                } else {
                    completeError += emptyFieldList[i].field;
                }
            }
            if (emptyFieldList.length == 1) {
                completeError += ' field.';
            } else {
                completeError += ' fields.';
            }

            toastList.push(
                {
                    type: 'err',
                    message: completeError
                }
            );
        }
        if (toastList.length) {
            this.showToastHelper(component, toastList, 5);
        }
        if (!toastList.length) {
            component.set("v.policywrap", policywrap);
            return true;
        } else {
            return false;
        }
    },

    validateCustomAmountHelper: function (component, value, percentValue) {
        var toastList = [];
        // consloe.log(value > percentValue);
        if (parseFloat(percentValue) < parseFloat(value)) {
            toastList.push(
                {
                    type: 'err',
                    message: 'The custom amount cannot be greater than 100% of the dividend credit'
                });
        } else if (value <= 0) {
            toastList.push(
                {
                    type: 'err',
                    message: 'The custom amount must be greater than 0'
                });
        }
        if (toastList.length) {
            this.showToastHelper(component, toastList, 5);
            return false;
        }
        return true;
    },

    picklistPaymentMethodChangeHelper: function (component,event) {
        var isDataLoadSuccess = component.get("v.isDataLoadSuccess");
        if (isDataLoadSuccess) {
          //  var selectMethodVal = document.getElementById('picklistPaymentMethod').value;
            var allList = component.find('picklistPaymentMethod');
            console.log('allList:',allList);
            var selectMethodVal = '';
            if(allList.length > 0){
                for(var i=0; i<allList.length; i++){
                    console.log('i-> checked ', allList[i].getElement().checked);
                    console.log('i-> dataset ', allList[i].getElement().dataset.id);
                    if(allList[i].getElement().checked){
                        selectMethodVal = allList[i].getElement().dataset.id;
                    }
                }
            }
            else if(allList){
                if(allList.getElement().checked){
                    selectMethodVal = allList.getElement().dataset.id;
                }
            }
            console.log('final:', selectMethodVal);
            let savedCardsList = component.get('v.savedCardList'); 
            console.log('savedCardsList => ',savedCardsList);
            let flag= false;
            for(let x of savedCardsList){
                console.log(x.paymentMethod.Id+'==> '+x.paymentMethod);
                if(x.paymentMethod.Id == selectMethodVal){
                    flag = true;
                }                
            }
            
            component.set("v.isCC", flag);
            
         
            if(selectMethodVal == 'Add Payment Methods'){
                $('#picklistPaymentMethod').val('none'); 
                $('#picklistPaymentMethod').change();
                component.set("v.currentActiveTab", 'tab-2');
                component.set("v.dataType", 'number');
                //component.set("v.checkValidCardNumber", false);	
                component.set("v.backToHomeScreen", true);               
                this.addPaymentMethodHelper(component);
                this.openPopupHelper(component, 'nor');
            }else{
                var payBut = component.find("payBut");
                var wrap = component.get("v.policywrap");
                
                if (selectMethodVal != 'none' && selectMethodVal != undefined && component.get("v.isDueDateValid")) {
                    component.set("v.isPayButDisable", false);
                    //$A.util.removeClass(payBut, "disableBut");
                    wrap.paymentMethodId = selectMethodVal;
                    component.set("v.policywrap", wrap);
                } else {
                    //$A.util.addClass(payBut, "disableBut");
                    component.set("v.isPayButDisable", true);
                }
            }           
        }
        this.closeSpinnerHelper(component);
        return true;
    },
    reloadDataHelper: function (component) {
        this.getSavedPaymentMethodsList(component);
    },
    isDataLoadSuccessHelper: function (component, event) {
        var flag = component.get("v.isDataLoadSuccess");
        window.setTimeout(() => {
            if (flag) {
                component.set("v.showScreenLoading", false);
                this.getSavedPaymentMethodsList(component);
                // this.picklistPaymentMethodChangeHelper(component);
            } else if(!component.get("v.hasError")){
                component.set("v.showScreenLoading", true);
            }
        }, 100);
    },
    addPaymentMethodHelper: function (component) {
        component.set('v.isAddScreen', true);
        component.set('v.isSavedScreen', false);
    },
    setValuesInWrapperHelper: function (component, type, dataList, index, from) {
        var wrap = component.get('v.policywrap');
        if (type == 'creditCard') {
            if (from == 'validation') {
                //wrap.firstName = dataList[index].cardFirstName;
                //wrap.lastName = dataList[index].cardLastName;
                wrap.confirmationEmail = dataList[index].cardSendConfirmationEmail;
            }
            wrap.cardNumber = dataList[index].cardNumber;
            wrap.cardTypeVar = dataList[index].cardTypeVar;
            wrap.expireMonth = dataList[index].expireMonth;
            wrap.expireYear = dataList[index].expireYear;
            wrap.nameOnCard = dataList[index].nameOnCard;
            wrap.verificationNumber = dataList[index].verificationNumber;
            wrap.isAutoPay = dataList[index].isDefault;
            wrap.paymentTypeVar = dataList[index].paymentTypeVar;

            if (wrap.paymentMethodId != null && (!wrap.isAutoPay) && wrap.paymentMethodId == wrap.defaultPaymentMethodId) {
                component.set("v.policywrap.defaultPaymentMethodId", null);
            }
            else if (wrap.paymentMethodId != null && wrap.isAutoPay && wrap.paymentMethodId != wrap.defaultPaymentMethodId) {
                component.set("v.policywrap.defaultPaymentMethodId", wrap.paymentMethodId);
            }

            if (from == 'saved') {
                wrap.payMethodToken = dataList[index].payMethodToken;
                wrap.paymentMethodId = dataList[index].paymentMethod.Id;
                if (wrap.isAutoPay) {
                    wrap.defaultPaymentMethodId = wrap.paymentMethodId;
                }
                var typedCardNumber = dataList[index].cardNumber;
                // component.set('v.cardCvv', dataList[index].verificationNumber);
                component.set('v.cardHolderName', dataList[index].nameOnCard);
                component.set('v.cardExpiryMonth', dataList[index].expireMonth);
                component.set('v.cardExpiryYear', dataList[index].expireYear);
                component.set('v.cardType', dataList[index].cardTypeVar);
                component.set('v.cardFirstFour', this.showCardNumberOnDisplayCardHelper(typedCardNumber.slice(0, 4)));
                component.set('v.cardSecondFour', this.showCardNumberOnDisplayCardHelper(typedCardNumber.slice(4, 8)));
                component.set('v.cardThirdFour', this.showCardNumberOnDisplayCardHelper(typedCardNumber.slice(8, 12)));
                component.set('v.cardFourthFour', this.showCardNumberOnDisplayCardHelper(typedCardNumber.slice(12, 16)));
            }
            
            wrap.paymentTypeVar = type;
            component.set('v.policywrap', wrap);
            console.log('dataList[index]tr:', dataList[index]);
            console.log('wrap:two', component.get('v.policywrap'));
            
            return true;
        } if (type == 'check') {
            if (from == 'validation') {
                //wrap.firstName = dataList[index].checkFirstName;
                //wrap.lastName = dataList[index].checkLastName;
                wrap.paymentTypeVar = dataList[index].paymentTypeVar;
                wrap.confirmationEmail = dataList[index].checkSendConfirmationEmail
            }
            wrap.routingNumber = dataList[index].routingNumber;
            wrap.accountNumber = dataList[index].accountNumber;
            wrap.accountType = dataList[index].accountType;
            wrap.accountHolderName = dataList[index].accountHolderName;
            console.log('setAutoPay => ',dataList[index].isSetToPay);
            wrap.isAutoPay = dataList[index].isSetToPay;
            
            if (from == 'saved') {
                wrap.payMethodToken = dataList[index].payMethodToken;
                wrap.paymentMethodId = dataList[index].paymentMethod.Id;
            }
            wrap.paymentTypeVar = type;
            console.log('wrap:two', component.get('v.policywrap'));
            component.set('v.policywrap', wrap);
            return true;
        } else {
            // showtoast
            return false;
        }
    },
    emptyFieldsHelper: function (component) {
        component.set('v.cardFirstFour', '----');
        component.set('v.cardSecondFour', '----');
        component.set('v.cardThirdFour', '----');
        component.set('v.cardFourthFour', '----');
        component.set('v.cardExpiryMonth', '--');
        component.set('v.cardExpiryYear', '----');
        component.set('v.cardHolderName', 'Name on Card');
        component.set('v.cardType', 'none');
        component.set('v.cardCvv', 'XXX');

        var wrapper = component.get("v.policywrap");
        wrapper.cardTypeVar = 'none';
        wrapper.cardNumber = '';
        wrapper.expireMonth = '';
        wrapper.expireYear = '';
        wrapper.nameOnCard = '';
        wrapper.verificationNumber = '';
        wrapper.payMethodToken = '';
        wrapper.paymentMethodId = '';
        wrapper.routingNumber ='';
        wrapper.accountNumber ='';
        wrapper.accountType ='';
        wrapper.accountHolderName ='';
        component.set("v.policywrap", wrapper);
    },

    // tabs,payment method type, steps change
    paymentScheduleHelper: function (component, clicked) {
        this.showSpinnerHelper(component);
        var getElement = component.find('payment-type');
        if (getElement) {
            for (var i in getElement) {
                var temp = getElement[i].getElement().getAttribute('data-type');
                if (clicked == temp) {
                    var wrapper = component.get('v.policywrap');
                    wrapper.paymentScheduleVar = clicked;
                    component.set("v.lastTime",clicked);
                    component.set("v.policywrap", wrapper);
                    $A.util.addClass(getElement[i], 'isActiveSpan');
                } else {
                    $A.util.removeClass(getElement[i], 'isActiveSpan');
                }
            }
        } else {
            var toastList = [(
                {
                    type: 'err',
                    message: 'Oops somthing went wrong'
                })]
            this.showToastHelper(component, toastList, 3);
        }
        this.closeSpinnerHelper(component);
    },
    tabSwitchHelper: function (component, clickedTab, from) {
        var savedClick = component.get("v.savedItemClick");
        var flag;
        if (from == 'onclicktab') {
            flag = savedClick;
        } if (from == 'saved') {
            flag = false;
        }
        if (!flag) {
            var numberOfTab = document.getElementsByClassName("tabHeading");
            if (numberOfTab.length) {
                var tabValue = component.find(clickedTab).getElement().getAttribute('data-tabvalue');
                this.emptyFieldsHelper(component);
                for (var i = 1; i <= (numberOfTab.length); i++) {
                    var curTab = 'tab-' + i;
                    var curTabData = 'tab-' + i + '-data';
                    if (clickedTab != curTab) {
                        var tab = component.find(curTab);
                        var tabData = component.find(curTabData);
                        $A.util.removeClass(tab, 'activeTab');
                        $A.util.removeClass(tabData, 'activeTabData');
                    } else {
                        var tab = component.find(curTab);
                        var tabData = component.find(curTabData);
                        $A.util.addClass(tab, 'activeTab');
                        $A.util.addClass(tabData, 'activeTabData');
                        component.set('v.currentActiveTab', curTab);
                    }
                }
               
            }
            var wrapper = component.get("v.policywrap");
            wrapper.paymentTypeVar = tabValue;
            component.set("v.policywrap", wrapper);
        } else {
            var toastList = [(
                {
                    type: 'err',
                    message: 'You can not switch tab'
                })]
            this.showToastHelper(component, toastList, 3);
        }
    },
    tabSwitchHelperNew: function (component, clickedTab) {               
        for (var i = 1; i <= 2; i++) {
            var curTab = 'tab-' + i;
            var curTabData = 'tab-' + i + '-data';
            if (clickedTab != curTab) {
                var tabData = component.find(curTabData);
                $A.util.removeClass(tabData, 'activeTabData');
            } else {
                var tabData = component.find(curTabData);
                $A.util.addClass(tabData, 'activeTabData');
                component.set('v.currentActiveTab', curTab);
            }
        }
    },
    changeStepHelper: function (component, to, buttype) {
        var hidStepTwo = component.get("v.hidStepTwo");
        if (!hidStepTwo && to > 1) {
            if (buttype == 'next') {
                to = Number(to) + 1;
            } else {
                to = Number(to) - 1;                               
            }
        }
        var allSteps = component.find("stepId");
        var allTabData = component.find('stepDataId')
        var allDottedLines = component.find('stepDottedLine')


        if (allSteps.length && allTabData.length && (allDottedLines.length || allDottedLines)) {
            for (var i = 0; i < allSteps.length; i++) {
                var step = allSteps[i].getElement().getAttribute('data-step');
                // var stepData = allTabData[i].getElement().getAttribute('data-step');
                if (step == to) {
                    $A.util.addClass(allSteps[i], 'activeStep');
                    $A.util.addClass(allTabData[i], 'activeStepData');

                    console.log('typeif ', typeof allDottedLines);

                    if (allDottedLines.length) {
                        $A.util.addClass(allDottedLines[i - 1], 'activeDotted');
                        $A.util.removeClass(allDottedLines[i - 1], 'completedDotted');
                    } else {
                        $A.util.addClass(allDottedLines, 'activeDotted');
                        $A.util.removeClass(allDottedLines, 'completedDotted');
                    }
                    $A.util.removeClass(allSteps[i], 'completedStep');
                } else {
                    $A.util.removeClass(allTabData[i], 'activeStepData');
                    if (i < to) {
                        $A.util.addClass(allSteps[i], 'activeStep');
                        $A.util.addClass(allSteps[i], 'completedStep');
                        if (allDottedLines.length) {
                            $A.util.addClass(allDottedLines[i - 1], 'completedDotted');
                        } else {
                            $A.util.addClass(allDottedLines, 'completedDotted');
                        }

                    } if (i > to) {
                        $A.util.removeClass(allSteps[i], 'activeStep');
                        $A.util.removeClass(allSteps[i], 'completedStep');

                        if (allDottedLines.length) {
                            $A.util.removeClass(allDottedLines[i - 1], 'completedDotted');
                            $A.util.removeClass(allDottedLines[i - 1], 'activeDotted');
                        } else {
                            $A.util.removeClass(allDottedLines, 'completedDotted');
                            $A.util.removeClass(allDottedLines, 'activeDotted');
                        }
                    }
                }
            }
            return true;
        } else {
            return false;
        }
    },

    // extra
    showToastHelper: function (component, toastList, timeout) {
        // how to use: 
        // type: err/suc,  timeout : time to hide toast

        // var toastList = []
        // toastList.push(
        //     {
        //         type: '',
        //         message: ''
        //     });
        // this.showToastHelper(component , toastList, 5)


        if (toastList.length) {
            var type = toastList[0].type;
            var toastDiv = component.find("toastId");
            console.log('toastDiv: ', toastDiv);
            console.log('toastDiv.getElement(): ', toastDiv.getElement());

            console.log('toastList: ', toastList);
            console.log('timeout: ', timeout);
            
            if(toastDiv && toastDiv.getElement() != undefined){
                console.log('classList before :', component.find("toastId").getElement().classList);
                component.find("toastId").getElement().classList.add('showToast');
                console.log('classList after :', component.find("toastId").getElement().classList);
                
                $A.util.addClass(toastDiv, 'showToast');
                if (type == 'suc') {
                    $A.util.addClass(toastDiv, 'toast_suc');
                    $A.util.removeClass(toastDiv, 'toast_err');
                    
                }
                else {
                    $A.util.removeClass(toastDiv, 'toast_suc');
                    $A.util.addClass(toastDiv, 'toast_err');
                }
                component.set("v.toastList", toastList);
                if (timeout == 0 || timeout == undefined || timeout == '0' || timeout == '') {
                    timeout = 5000;
                }
                setTimeout(() => {
                    let tempDiv = component.find("toastId");
                    console.log('tempDiv: ',tempDiv)
                    if(tempDiv.getElement() != undefined){
                    if(component.find("toastId").getElement().classList.contains('showToast')){
                    component.find("toastId").getElement().classList.remove('showToast');            
                }
                           }
                           }, (parseInt(timeout) * 1000));
            }

        }
    },
    closeToastMethodHelper: function (component, event) {
        
        var toastDiv = component.find("toastId");
        $A.util.removeClass(toastDiv, 'showToast');
    },
    showSpinnerHelper: function (component) {
        console.log('show spinner called');
        var spinner = component.find("spinnerId");
        if (spinner) {
            $A.util.addClass(spinner, 'showFullScreenSpinner');
            return true;
        } else {
            var toastList = [{
                type: 'err',
                message: 'No spinner found'
            },];
            this.showToastHelper(component, toastList, 4);
            return false;
        }
    },
    closeSpinnerHelper: function (component) {
        var spinner = component.find("spinnerId");
        $A.util.removeClass(spinner, 'showFullScreenSpinner');
        return false;
    },
    openPopupHelper: function (component, type) {
        if (type == 'nor') {
            var popupModalId = component.find("popupID");
            $A.util.addClass(popupModalId, 'openPopup');
        } if (type == 'small') {
            var smallpopup = component.find('popupSmallID');
            $A.util.addClass(smallpopup, 'openPopup');
        }
    },
    closepopupHelper: function (component, type) {
        if (type == 'nor') {
            component.set('v.backToHomeScreen', false);
            component.set('v.currentActiveTab','tab-2');
            component.set('v.isSavedScreen', false);
            component.set('v.isAddScreen', false);
            // component.set('v.isHeaderFooterModal', false);
            component.set('v.isPaymentError', false);
            component.set('v.isPaymentSuccess', false);
            component.set("v.fieldDisabled", false);
            component.set("v.savedItemClick", false);
            this.emptyFieldsHelper(component);
            // component.set("v.AddFromMainScreen", false);
            component.set("v.isAddPaymentMethod", false);
            var modal = component.find('popupID');
            $A.util.removeClass(modal, 'openPopup');
        }
        if (type == 'small') {
            component.set("v.isConfirmationDelete", false);
            var smallpopup = component.find('popupSmallID');
            $A.util.removeClass(smallpopup, 'openPopup');
        }


    },

    savedAddScreenChangeHelper: function (component) {
        var issaved = component.get("v.isSavedScreen");
        var isadd = component.get("v.isAddScreen");

        if (!issaved && !isadd) {
            component.set("v.isHeaderFooterModal", false);
        } else {
            component.set("v.isHeaderFooterModal", true);
        }
    },
    handleLawyerFieldChangeHelper: function (component, event) {
        var wrapper = component.get("v.policywrap");
        var row = event.currentTarget.dataset.row;
        var index = event.currentTarget.dataset.index;
        var value = event.currentTarget.value;
        let lawyer = wrapper.policyLawyers[index];

        if (row == 'Email') {
            lawyer.Lawyer__r.Contact__r.Email = value;
        }
        else if (row == 'Phone') {
            lawyer.formatedPhone = value;
        }

        console.log('Policy Wrapper => ', wrapper);
        component.set("v.policywrap", wrapper);
    },
    isAnyDefaultPaymentMethod: function (component, event) {
        var wrapper = component.get("v.policywrap");
        if (wrapper.defaultPaymentMethodId != null) {
            return true;
        }
        else {
            wrapper.defaultPaymentMethodId = wrapper.paymentMethodId;
            component.set("v.policywrap",wrapper);
            return true;
            // var toastList = [{
            //     type: 'err',
            //     message: 'Please set one Payment Method as Default.'
            // },];
            // this.showToastHelper(component, toastList, 4);
            // return false;
        }
    },
    boxChangeHelper : function (component, val) {
        var nextBut = component.find("nextBut");
        //component.set("v.termsAndConditionAccepted", val);
        component.set("v.policywrap.policy.Terms_And_Conditions_Approval__c", val);
        if(val && nextBut != null){
            for(let x of nextBut){ 
                $A.util.removeClass(x, "disableBut");
            }
        }
        /*                  
        else if(nextBut != null){            
            for(let x of nextBut){
                $A.util.addClass(x, "disableBut");
            }
        }
        */
    },
    cellPhoneNumberFormatter : function (number) {
        var numStr = number.toString();
        console.log('numStr:', numStr);
        
        var alreadyFormatted = /^\(\d{3}\)\s\d{3}-\d{4}$/.test(numStr);
        console.log('here1');
        if (alreadyFormatted) {
            console.log('Already formatted:', numStr);
            return numStr; // leave as it is
        }
        
        var newStr = `(${numStr.substring(0, 3)}) ${numStr.substring(3, 6)}-${numStr.substring(6)}`
        console.log('newStr:', newStr);
        return newStr;
    },
    cellPhoneNumberUnformatter: function (number) {
        var numStr = number.toString();
        console.log('numStr:', numStr);
        
        var newStr = numStr.split('(').join("");
        newStr = newStr.split(')').join("");
        newStr = newStr.split(' ').join("");
        newStr = newStr.split('-').join("");

        console.log('newStr:', newStr);
        return newStr;
    },
    removeErrorClassFromFields : function (fields, className, index, isMultiple) {
        if(isMultiple){
            for(let x in fields){
                if(x == index){
                    $A.util.removeClass(fields[x], className);                        
                }
            }
        }else{
            $A.util.removeClass(fields, className);
        }
    },
    addErrorClassInFields : function (fields, className, index, isMultiple) {
        if(isMultiple){
            for(let x in fields){
                if(x == index){                    
                    $A.util.addClass(fields[x], className); 
                    fields[x].getElement().scrollIntoView(); 
                }
            }
        }else{
            $A.util.addClass(fields, className);
        }
    },
    validateLawyerBusinessEmailFields: function (component, event){
    	var lawyers = component.get("v.policywrap.policyLawyers");
        let flag = true;
        let dtValid = false;
        var mailformat = new RegExp(component.get("v.emailRegex"));
        component.set("v.isErrorFound",false);
        for(let i in lawyers){
            let obj = lawyers[i];
            var lawyerEmail = obj.Lawyer__r.Contact__r.Email;
            var lawyerPersonalEmail = obj.Lawyer__r.Contact__r.Personal_Email__c;
            var lawyerPhoneNumber = obj.Lawyer__r.Contact__r.MobilePhone; 
            if(lawyerEmail && !(lawyerEmail.trim().match(mailformat))){
                flag = false;
                let emailfields = component.find("lawyerEmail");
                this.addErrorClassInFields(emailfields, "errorInput", i, true );
            }
            else if(!lawyerEmail){
                flag = false;
                let emailfields = component.find("lawyerEmail");
                this.addErrorClassInFields(emailfields, "errorInput", i, true );                
            }else{
                let emailfields = component.find("lawyerEmail");
                this.removeErrorClassFromFields(emailfields, "errorInput", i, true);  
            }
        }
        if(flag){            
            component.set("v.isErrorFound",true);
        }

        return flag;
    },
    validateLawyerPersonalEmailFields: function (component, event){
    	var lawyers = component.get("v.policywrap.policyLawyers");
        let flag = true;
        let dtValid = false;
        var mailformat = new RegExp(component.get("v.emailRegex"));
        component.set("v.isErrorFound",false);
        for(let i in lawyers){
            let obj = lawyers[i];
            var lawyerPersonalEmail = obj.Lawyer__r.Contact__r.Personal_Email__c;
            
            if(lawyerPersonalEmail && !(lawyerPersonalEmail.trim().match(mailformat))){
                flag = false;
                let emailfields = component.find("lawyerPersonalEmail");
                this.addErrorClassInFields(emailfields, "errorInput", i, true );
            }else{
                let emailfields = component.find("lawyerPersonalEmail");
                this.removeErrorClassFromFields(emailfields, "errorInput", i, true);  
            }
        }
        if(flag){            
            component.set("v.isErrorFound",true);
        }
        return flag;
    },
    validateLawyerPhoneFields: function (component, event){
    	var lawyers = component.get("v.policywrap.policyLawyers");
        let flag = true;
        component.set("v.isErrorFound",false);
        for(let i in lawyers){
            let obj = lawyers[i];
            var lawyerPhoneNumber = obj.Lawyer__r.Contact__r.MobilePhone; 
            console.log('lawyerPhoneNumber->' , lawyerPhoneNumber);
            if(lawyerPhoneNumber){
                console.log('lawyerPhoneNumber->' , lawyerPhoneNumber.length);
                var digitsOnly = lawyerPhoneNumber ? lawyerPhoneNumber.replace(/\D/g, '') : '';
                console.log('digitsOnly->', digitsOnly);
                if(digitsOnly && (digitsOnly.length != 10 || parseInt(digitsOnly) == NaN)){
                    flag = false;
                    let phonefields = component.find("lawyerPhoneNumber");
                    this.addErrorClassInFields(phonefields, "errorInput", i, true );
                }else{
                    let phonefields = component.find("lawyerPhoneNumber");
                    this.removeErrorClassFromFields(phonefields, "errorInput", i, true );
                }
            }
        }
        if(flag){            
            component.set("v.isErrorFound",true);
        }
        return flag;
    },
    validateLawyerBirthdateFields: function (component, event){
    	var lawyers = component.get("v.policywrap.policyLawyers");
        let dtValid = false;
        component.set("v.isErrorFound",false);
        
        dtValid = component.find('lawyerBirthdate').reduce(function (validSoFar, inputCmp) {
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        
        if(dtValid){            
            component.set("v.isErrorFound",true);
        }
        return dtValid;
    },
    dueDateChangeHelper: function (component, event, fromMethod ) {
        var policyWrap = component.get("v.policywrap");
        
        if (policyWrap.enablePaymentDate) {
            var selectedDate = this.formatDateHelperNew(policyWrap.firstInstallmentDate, 'MM/DD/YYYY');
            var payBut = component.find("payBut");
            if(selectedDate){
                policyWrap.firstInstallmentDateString = selectedDate;
                const date = new Date();
                let effectiveDate = this.formatDateHelperNew(policyWrap.effectiveDate,'MM/DD/YYYY');
                if(effectiveDate){
                    let currentDate = this.formatDateHelper(date, 'MM/DD/YYYY');
                    var d1 = currentDate.split("/");
                    var d2 = effectiveDate.split("/");
                    var c = selectedDate.split("/");
                    
                    var from = new Date(d1[2], parseInt(d1[0]) - 1, d1[1]).getTime();  // -1 because months are from 0 to 11
                    var to = new Date(d2[2], parseInt(d2[0]) - 1, d2[1]).getTime();
                    var check = new Date(c[2], parseInt(c[0]) - 1, c[1]).getTime();
                    
                    var dateField = component.find('paymentDate');
                    console.log('dateField => ',dateField);
                    
                    if(check === from){
                        policyWrap.totalAmountDue = policyWrap.scheduleAmount;
                        component.set("v.isDueDateValid", true);
                        component.set("v.paymtDateMsgStyle", '');
                        dateField.setCustomValidity('');
                    }
                    else if(from > check || check > to){
                        console.log('from > check:', from > check);
                        console.log('check > to:', check > to);
                        component.set("v.isDueDateValid", false);
                        console.log("Payment Date must be between today and "+ policyWrap.effectiveDateStr);
                        
                        dateField.setCustomValidity("Payment Date must be between today and "+ policyWrap.effectiveDateStr);
                        component.set("v.paymtDateMsgStyle", 'color: red;');
                    }
                        else{
                            component.set("v.isDueDateValid", true);
                            component.set("v.paymtDateMsgStyle", '');
                            dateField.setCustomValidity('');
                            policyWrap.totalAmountDue = 0;
                        }
                    dateField.reportValidity();
                    //$A.util.removeClass(payBut, "disableBut");
                    //component.set("v.isPayButDisable", false);
                    //this.picklistPaymentMethodChangeHelper(component, event);
                    component.set("v.policywrap",policyWrap);
                }else{
                    //$A.util.addClass(payBut, "disableBut");
                    //component.set("v.isPayButDisable", true);
                }
            }else{
                //component.set("v.isPayButDisable", true);
                //$A.util.addClass(payBut, "disableBut");
            }
        }
    },
    formatDateHelper: function (oldDate, format) {
        var tempDate = new Date(oldDate);
        //tempDate = new Date( tempDate.getTime() + Math.abs(tempDate.getTimezoneOffset()*60000) );
        let day = String(tempDate.getDate()).padStart(2, '0');
        let month = String(tempDate.getMonth() + 1).padStart(2, '0');
        let year = tempDate.getFullYear();
        var newDate;
        if(format == 'MM/DD/YYYY'){
            newDate  = `${month}/${day}/${year}`;
        }if(format == 'YYYY-MM-DD'){
            newDate = `${year}/${month}/${day}`;
        }
        if (newDate) {
            return newDate;
        } else {
            return false;
        }
    },
    formatDateHelperNew: function (oldDate, format) {
        console.log('my--> oldDate: ',oldDate);
        console.log('my--> format: ',format);
        if(oldDate != null && oldDate != undefined){
            var tempDate = oldDate.split("-");
            let day = String(tempDate[2]).padStart(2, '0');
            let month = String(tempDate[1]).padStart(2, '0');
            let year = tempDate[0];
            var newDate;
            if(format == 'MM/DD/YYYY'){
                newDate  = `${month}/${day}/${year}`;
            }if(format == 'YYYY-MM-DD'){
                newDate = `${year}/${month}/${day}`;
            }
            if (newDate) {
                return newDate;
            } else {
                return false;
            }
        }  else{
            return false;
        }
    },
    scrollTop: function (component, event) {
        // debugger
        let scrollableDiv = component.find("scrollabarDiv");
        let wholePageContainer = component.find("wholePageContainer");
        if (scrollableDiv && wholePageContainer) {
            for (let i = 0; i < scrollableDiv.length; i++) {
                scrollableDiv[i].getElement().scrollTop = 0;
            }
            wholePageContainer.getElement().scrollTop = 0;
        }
    },
    sendErrorEmail: function(component, subject, body){
        var action = component.get("c.sendEmailOnError");
        action.setParams({
            subject: subject,
            body: body
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state === "SUCCESS") {
                
            }
        });
        $A.enqueueAction(action);
    },
    UpdateSurveyFieldsNew: function(component){
        this.showSpinnerHelper(component);
        let policyWrap = component.get("v.policywrap");
        let policy = policyWrap.policy;
        let ISBAM_survey = component.get("v.ISBAM_survey");
        console.log('ISBAM_survey:', JSON.stringify(ISBAM_survey));
        var action = component.get("c.updatePolicyFields");
        action.setParams({
            policy: policy,
            survey: ISBAM_survey, 
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                document.getElementsByClassName('scrollableDiv')[0].scrollTop = 0
            } else if (state === 'INCOMPLETE') {
                // Code when Imcomplete
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                        console.log("Unknown error");
                }
            }
            this.closeSpinnerHelper(component);
        });
        $A.enqueueAction(action);
    },
    base64ToBlob: function(base64, contentType) {
            contentType = contentType || '';
        var sliceSize = 512;
        var byteCharacters = atob(base64);
        var byteArrays = [];

        for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
            var slice = byteCharacters.slice(offset, offset + sliceSize);

            var byteNumbers = new Array(slice.length);
            for (var i = 0; i < slice.length; i++) {
                byteNumbers[i] = slice.charCodeAt(i);
            }

            var byteArray = new Uint8Array(byteNumbers);
            byteArrays.push(byteArray);
        }

        return new Blob(byteArrays, {type: contentType});
    },
    saveCreditCardInFiserv: function(component,event, data){
        
        console.log(JSON.stringify(data));
        let wrapper = component.get("v.policywrap");
        wrapper.paymentTypeVar='creditCard';
        let cardData = JSON.parse(data);
        console.log('cardData' , cardData);
        wrapper.cardNumber = cardData.details.cardNumber;
        wrapper.expireMonth = cardData.details.expiryMonth;
        wrapper.expireYear = cardData.details.expiryYear;
        wrapper.nameOnCard = cardData.details.cardholderName;
        wrapper.payMethodToken = cardData.paymentReference;
        component.set("v.policywrap",wrapper);
        this.savePaymentMethodHelper(component,event);
    }
})