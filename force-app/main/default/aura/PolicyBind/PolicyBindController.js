({
    init: function (component, event, helper) {
        
        console.log('isInternalUser =>', component.get("v.isInternalUser"));
        var lastTime = component.get("v.lastTime");

        var flag = helper.showSpinnerHelper(component);
        if (flag) {
            helper.getDetails(component, lastTime, false, "none", "none");
        }
        helper.getExpiryOptions(component);
        helper.getIBFContributionPicklist(component, event);
        helper.getTargetPicklist(component, event)


        window.addEventListener('message', (message) => {
            if (message.data.name == "FiservToken") {
                console.log("message -> ", JSON.stringify(message.data.payload));
                if (message.data.payload) {
                    //component.set("v.showSpinner",true);
                    var eventData = JSON.parse(JSON.stringify(message.data.payload));
                    // console.log('single_use_token -> ' + eventData.paymentReference);
                    //component.set('v.tokenVal', eventData.paymentReference);
                    component.set('v.paymentMethodData', JSON.stringify(eventData));
                    let toastList = [];
                    if (!eventData.details) {
                        toastList.push(
                            {
                                type: 'err',
                                message: 'Missing credit card details'
                            });
                        helper.closeSpinnerHelper(component);
                        helper.showToastHelper(component, toastList, 5);
                        return;
                    }

                    console.log('creditcard expiry yr -> ', eventData.details.expiryYear);
                    console.log('creditcard expiry yr -> ', eventData.details.expiryYear);
                    var creditCardExpiryYear = eventData.details.expiryYear;
                    console.log('creditCardExpiryYear -> ', creditCardExpiryYear);
                    var currentYr = new Date().getFullYear();
                    console.log('creditcard expiry month -> ', eventData.details.expiryMonth);
                    var creditCardExpiryMonth = eventData.details.expiryMonth;
                    console.log('creditCardExpiryMonth -> ', creditCardExpiryMonth);
                    var currentMonth = new Date().getMonth() + 1;
                    console.log('currentMonth -> ', currentMonth);
                    console.log('eventData full -> ', JSON.stringify(eventData));
                    if (!eventData.details.cardholderName) {
                        toastList.push(
                            {
                                type: 'err',
                                message: 'Please enter Card Holder Name'
                            });
                        helper.closeSpinnerHelper(component);
                    } else if (!eventData.details.cardNumber) {
                        toastList.push(
                            {
                                type: 'err',
                                message: 'Please enter Your Credit Card Number'
                            });
                        helper.closeSpinnerHelper(component);
                    } else if (creditCardExpiryYear == undefined || creditCardExpiryMonth == undefined) {
                        toastList.push(
                            {
                                type: 'err',
                                message: 'Please enter valid Expiration Date'
                            });
                    } else if ((parseInt(creditCardExpiryYear) < currentYr) || (parseInt(creditCardExpiryYear) == currentYr && parseInt(creditCardExpiryMonth) < currentMonth)) {
                        toastList.push(
                            {
                                type: 'err',
                                message: 'Please enter valid Expiration Date'
                            });
                        helper.closeSpinnerHelper(component);
                    } else {
                        //create Payment method in Salesforce
                        console.log('Payment Method Details:', eventData);
                        var cmpEvent = component.getEvent("submitEvent");
                        cmpEvent.fire();
                        //helper.saveCreditCardInFiserv(component, event, eventData);
                    }
                    if (toastList.length > 0) {
                        helper.showToastHelper(component, toastList, 5);
                    }
                    //helper.closeSpinnerHelper(component);
                }
            }

            if (message.data.name == "TokenizeError") {
                console.log("message -> ", JSON.stringify(message.data.payload));
                if (message.data.payload) {
                    console.log('Error -> ', JSON.parse(JSON.stringify(message.data.payload)));
                    var toastList = [];
                    toastList.push(
                        {
                            type: 'err',
                            message: JSON.parse(JSON.stringify(message.data.payload))
                        });
                    helper.showToastHelper(component, toastList, 5);
                    helper.closeSpinnerHelper(component);
                }
            }
            if (message.data.name == "OpenSpinner") {
                console.log('Start spinner');
                //component.set("v.showSpinner", true);
                //helper.showSpinnerHelper(component);
                $A.getCallback(function () {
                    helper.showSpinnerHelper(component);
                })();
            }

            if (message.data.name == "CloseSpinner") {
                console.log('Close spinner');
                //component.set("v.showSpinner", false);
                //helper.closeSpinnerHelper(component);
                $A.getCallback(function () {
                    helper.closeSpinnerHelper(component);
                })();
            }
            if (message.data.name == "back"){
                var cmpEvent = component.getEvent("backEvent");
                cmpEvent.fire();
            }
        });
    },
    handleSubmitEvent: function (component, event, helper) {
        console.log('handleSubmitEvent called');
         var eventData = component.get('v.paymentMethodData');
        console.log(JSON.stringify(eventData));
        helper.saveCreditCardInFiserv(component, event, eventData);
    },
        // cards fields:
        fieldEmptyHandle: function (component, event, helper) {
            var id = event.target.id;
            document.getElementById(id).className = '';
            var input = document.getElementById(id);
            helper.isFieldEmptyHelper(input);
        },
    cardTypeHandle: function (component, event, helper) {
        var id = event.target.id;
        document.getElementById(id).className = '';
        var cardType = document.getElementById(id);
        var cardNumber = document.getElementById('cardNumber');
        var cardCvv = document.getElementById('cardCVV');

        helper.isCardTypeHelper(component, cardType, cardNumber, cardCvv);
    },
    cardNumberHandle: function (component, event, helper) {
        document.getElementById('cardNumber').className = '';
        var cardNumber = document.getElementById('cardNumber');
        var cardType = document.getElementById('cardType');
        var cardCvv = document.getElementById('cardCVV');
        var cardNumberVal = helper.isCardNumberValidHelper(cardNumber);
        if (cardNumberVal == '') {
            var cardTypeHelper = helper.getCardTypeHelper(cardNumber);
            component.set('v.cardType', cardTypeHelper);
            var comparedNumberAndTypeVal = helper.compareCardNumberAndTypeHelper(cardNumber, cardType);
            if (comparedNumberAndTypeVal == '') {
                if (cardCvv.value != '') {
                    helper.isCvvValidHelper(component, cardCvv, cardType);
                }
            }
        }
    },
    cvvValidHandle: function (component, event, helper) {
        document.getElementById('cardCVV').className = '';
        var cardCvv = document.getElementById('cardCVV');
        var cardType = document.getElementById('cardType');
        helper.isCvvValidHelper(component, cardCvv, cardType);
    },
    expiryChangeHandle: function (component, event, helper) {
        document.getElementById('cardExpiryMonth').className = '';
        document.getElementById('cardExpiryYear').className = '';
        var cardExpiryMonth = document.getElementById('cardExpiryMonth');
        var cardExpiryYear = document.getElementById('cardExpiryYear');
        if (cardExpiryMonth.value != 'none') {
            component.set('v.cardExpiryMonth', cardExpiryMonth.value);
        } else {
            component.set('v.cardExpiryMonth', '--');
        }
        if (cardExpiryYear.value != 'none') {
            component.set('v.cardExpiryYear', cardExpiryYear.value);
        } else {
            component.set('v.cardExpiryYear', '----');
        }
        helper.isExpiryValidHelper(component ,cardExpiryMonth, cardExpiryYear);
    },
    securityMailHandle: function (component, event, helper) {
        var id = event.target.id;
        document.getElementById(id).className = '';
        var securityMail = document.getElementById(id);
        let result = helper.securityMailHelper(component,securityMail);
        if(result == ''){            
            component.set("v.isConfirmDisabled",false);
        }
        else{
            component.set("v.isConfirmDisabled",true);
        }
    },
    // cards fields changing methods:
    keyUpCardNumberHandle: function (component, event, helper) {
        var typedCardNumber = event.currentTarget.value;
        component.set('v.cardFirstFour', helper.showCardNumberOnDisplayCardHelper(typedCardNumber.slice(0, 4)));
        component.set('v.cardSecondFour', helper.showCardNumberOnDisplayCardHelper(typedCardNumber.slice(4, 8)));
        component.set('v.cardThirdFour', helper.showCardNumberOnDisplayCardHelper(typedCardNumber.slice(8, 12)));
        component.set('v.cardFourthFour', helper.showCardNumberOnDisplayCardHelper(typedCardNumber.slice(12, 16)));
    },
    keyUpCvvHandle: function (component, event, helper) {
        var enteredCvv = event.currentTarget.value;
        var numberOfDigit = component.get('v.numberOfCardCvv');
        var temp = '';
        for (var i = enteredCvv.length; i < numberOfDigit; i++) {
            temp += 'X';
        }
        component.set('v.cardCvv', enteredCvv + temp);
    },
    keyUpCardHolderNameHandle: function (component, event, helper) {
        var name = event.currentTarget.value;
        if (name.length != 0) {
            component.set("v.cardHolderName", name);
        } else {
            component.set("v.cardHolderName", 'CARD HOLDER NAME');
        }
    },
    cvvFocusInHandle: function (component, event, helper) {
        var cardSideFront = component.find("card-front");
        var cardSideBack = component.find("card-back");
        $A.util.addClass(cardSideFront, 'onFocusFlipFront');
        $A.util.addClass(cardSideBack, 'onFocusFlipBack');
    },
    cvvFocusOutHandle: function (component, event, helper) {
        var cardSideFront = component.find("card-front");
        var cardSideBack = component.find("card-back");
        $A.util.removeClass(cardSideFront, 'onFocusFlipFront');
        $A.util.removeClass(cardSideBack, 'onFocusFlipBack');
    },
    // echeck field validation
    routingNumberHandle: function (component, event, helper) {
        var id = event.target.id;
        document.getElementById(id).className = '';
        var checkRoutingNumber = document.getElementById(id);
        helper.isRoutingNumberValidHelper(checkRoutingNumber);
    },
    accountNumberHandle: function (component, event, helper) {
        var id = event.target.id;
        document.getElementById(id).className = '';
        var checkAccountNumber = document.getElementById(id);
        helper.isAccountNumberValidHelper(checkAccountNumber);
    },
    accountTypeHandle: function (component, event, helper) {
        var id = event.target.id;
        document.getElementById(id).className = '';
        var checkAccountType = document.getElementById(id);
        helper.isFieldEmptyHelper(checkAccountType);
    },

    // Payment methods 
    savedItemClickHandle: function (component, event, helper) {
		/* 
        component.set("v.isPaymentAndPolicyStatus", true);
		component.set("v.isPolicySuccess", true);  
		component.set("v.isPaymentSuccess", true);   
        var popupModalId = component.find("popupID");
        $A.util.removeClass(popupModalId, 'openPopup');

        /**/
        var lastTime = component.get("v.lastTime");
        if(lastTime){
            helper.showSpinnerHelper(component);
            var from = event.currentTarget.dataset.from;
            var proceedToSetValues = false;
            var itemIndex = '';
            var itemType = '';
            var dataList;
            var Physical_Check = component.get('v.Physical_Check');
            
            if (from == 'homeScreen') {
                component.set("v.disableFields", true);
                component.set("v.dataTypeCvv", 'text');

                var isPayButDisable = component.get("v.isPayButDisable");
                var isDueDateValid = component.get("v.isDueDateValid");
                var policyWrap = component.get("v.policywrap");
                var dueDateEnabled = policyWrap.enablePaymentDate;
                if(dueDateEnabled && !isDueDateValid){
                    var toastList = [];
                    toastList.push(
                        {
                            type: 'err',
                            message: "Payment Date must be between today and "+ policyWrap.effectiveDateStr
                        }
                    );
                    helper.showToastHelper(component, toastList, 5);
                }
                else if (!isPayButDisable) {
                    component.set('v.backToHomeScreen', true);
                    component.set("v.savedItemClick", true);
                    component.set("v.dataType", 'text');
                    component.set("v.isAddPaymentMethod", true);
                	// var currid = document.getElementById('picklistPaymentMethod').value;
                    var allList = component.find('picklistPaymentMethod');
                    console.log('allList:',allList);
                
                    if(!Physical_Check){
                        var currid = '';
                        if(allList.length > 0){
                            for(var i=0; i<allList.length; i++){
                                console.log('i-> checked ', allList[i].getElement().checked);
                                console.log('i-> dataset ', allList[i].getElement().dataset.id);
                                if(allList[i].getElement().checked){
                                    currid = allList[i].getElement().dataset.id;
                                }
                            }
                        }
                        else if(allList){
                            if(allList.getElement().checked){
                                currid = allList.getElement().dataset.id;
                            }
                        }
                        
                        var savedcardList = component.get("v.savedCardList");
                        if (savedcardList.length) {
                            for (var i = 0; i < savedcardList.length; i++) {
                                if (currid == savedcardList[i].paymentMethod.Id) {
                                    itemType = 'creditCard';
                                    itemIndex = i;
                                    dataList = component.get("v.savedCardList");
                                }
                            }
                        }
                        var savedecheckList = component.get("v.savedEcheckList");
                        if (savedecheckList.length) {
                            for (var i = 0; i < savedecheckList.length; i++) {
                                if (currid == savedecheckList[i].paymentMethod.Id) {
                                    itemType = 'check';
                                    itemIndex = i;
                                    dataList = component.get("v.savedEcheckList");
                                }
                            }
                        }
                    }
                    
                    proceedToSetValues = true;
                }             
                else {
                    component.set("v.showPayMethodError",true);
                    helper.openPopupHelper(component, 'nor');
                }
            } if (from == 'savedList') {
                component.set("v.disableFields", false);
                component.set("v.dataTypeCvv", 'number');           

                component.set("v.savedItemClick", true);
                component.set("v.dataType", 'text');
                itemIndex = event.currentTarget.dataset.recordid;
                itemType = event.currentTarget.dataset.recordtype;
                    if(itemType == 'check'){
                        dataList = component.get("v.savedEcheckList");
                    }
                    else{
                        dataList = component.get("v.savedCardList");
                    }
                proceedToSetValues = true;
            } if (proceedToSetValues) {
                console.log('datalist => ', dataList);
                var flag = false;
                if(!Physical_Check){
                    flag = helper.setValuesInWrapperHelper(component, itemType, dataList, itemIndex, 'saved');
                }else{
                    flag= true;
                }
                if (flag) {
                    var tabVal = 'tab-1';
                    if (itemType == 'check') {
                        tabVal = 'tab-2';
                    }
                    if (from == 'homeScreen') {
                        helper.openPopupHelper(component, 'nor');
                        // component.set("v.isHeaderFooterModal", true);
                    }
                    component.set('v.isAddScreen', true);
                    component.set('v.isSavedScreen', false);
                    helper.tabSwitchHelperNew(component, tabVal);
                }
            }
            helper.closeSpinnerHelper(component);
        }
        else{
            var toastList = [];
            toastList.push(
                {
                    type: 'err',
                    message: "No Payment Frequency Option Selected"
                }
            );
            helper.showToastHelper(component, toastList, 5);
        }
        /**/
    },
    updateSavePayHandle: function (component, event, helper) {
        helper.showSpinnerHelper(component);
        var toastList = [];

        var buttonType = event.currentTarget.dataset.type;
        var flag = helper.validateAllFieldsHelper(component);
        if (flag) {
            if (buttonType == 'update') {
                helper.updatePaymentMethodHelper(component, event, false);
            } if (buttonType == 'save') {
                helper.savePaymentMethodHelper(component, event);
            } if (buttonType == 'setToPay') {
                var res = helper.setToPayHelper(component, event);
                if (res) {
                    var resTwo = helper.picklistPaymentMethodChangeHelper(component, event);
                    if (resTwo) {
                        helper.closepopupHelper(component, 'nor');
                    } else {
                        toastList.push(
                            {
                                type: 'err',
                                message: 'Something went wrong.'
                            });
                    }
                } else {
                    toastList.push(
                        {
                            type: 'err',
                            message: 'Something went wrong during set to pay.'
                        });
                }
                if (toastList.length) {
                    helper.showToastHelper(component, toastList, 5);
                }
            }
        }
        // helper.closeSpinnerHelper(component);
    },
    deleteSavedItemHandle: function (component, event, helper) {
        event.stopPropagation();
        var itemIndex = event.currentTarget.dataset.recordid;
        var itemType = event.currentTarget.dataset.recordtype;

        if (itemType == 'creditCard') {
            var list = component.get("v.savedCardList");
            var itemValues = list[itemIndex];
        } else if (itemType == 'eCheck') {
            var list = component.get("v.savedEcheckList");
            var itemValues = list[itemIndex];
        }
        var itemId = itemValues.paymentMethod.Id;
        var itemPayMethodToken = itemValues.payMethodToken;

        var wrap = component.get("v.policywrap");
        wrap.paymentMethodId = itemId;
        wrap.payMethodToken = itemPayMethodToken;
        component.set("v.paywrap", wrap);
        component.set("v.isConfirmationDelete", true);

        helper.openPopupHelper(component, 'small');
    },
    proceedToPaymentHandle: function (component, event, helper) {
        helper.showSpinnerHelper(component);
        var res = helper.validateEmailFieldsHelper(component);
        if (res) {
            var newResponse = helper.isAnyDefaultPaymentMethod(component,event);
            if(!component.get("v.disableFields") && newResponse){
                helper.updatePaymentMethodHelper(component, event, true);
            }
            else if(newResponse){
				var wrapper = component.get("v.policywrap");
                if(wrapper.isPolicy){
                    helper.updatePolicyHelper(component, '', '',true);
                    //helper.policyAllMethodsHelper(component);
                }
                else{
                    helper.processPaymentHelper(component);
                }
            }
        }
    },
    addPaymentMethodHandle: function (component, event, helper) {
        helper.showSpinnerHelper(component);
        var from = event.currentTarget.dataset.from;
        component.set("v.dataType", 'number');
        //component.set("v.checkValidCardNumber", false);

        if (from == 'modal') {
            var button = 'addButton';
            helper.emptyFieldsHelper(component);
            helper.addPaymentMethodHelper(component);
        } if (from == 'homeScreen') {            
            helper.openPopupHelper(component, 'nor');
            // component.set("v.isHeaderFooterModal", true);
            // component.set('v.isSavedScreen', true);
            var savedCardList = component.get("v.savedCardList");
            var savedEcheckList = component.get("v.savedEcheckList");

            if (savedCardList.length == 0 && savedEcheckList.length == 0) {
                component.set("v.backToHomeScreen", true);
                helper.addPaymentMethodHelper(component);
            } else {
                component.set('v.isSavedScreen', true);
            }
        }
        helper.closeSpinnerHelper(component);
    },
    closePayMethodErrorModal: function (component, event, helper) {
        component.set("v.disableFields", false);
        component.set("v.showPayMethodError", false);
        helper.closepopupHelper(component, 'nor');
    },
    confirmationModalButton: function (component, event, helper) {
        var buttonType = event.currentTarget.dataset.buttype;
        if (buttonType == 'no') {
            component.set("v.isConfirmationDelete", false);
            var smallpopup = component.find('popupSmallID');      
            $A.util.removeClass(smallpopup, 'openPopup');
        } else if (buttonType == 'yes') {
            helper.deletePaymentMethodHelper(component);
        }
    },
    picklistPaymentMethodChange: function (component, event, helper) {
        var dataId = event.currentTarget.dataset.id;
        if(dataId != null && dataId != undefined){
            if(dataId == 'Physical_Check'){
                var payBut = component.find("payBut");
                component.set('v.Physical_Check', true);
                var Physical_Check = component.get('v.Physical_Check');
                var wrapper = component.get('v.policywrap');
                
                if(Physical_Check){
                    component.set("v.isCC",false);
                    wrapper.paymentTypeVar = 'Physical_Check';
                    wrapper.defaultPaymentMethodId = 'Physical_Check';
                    component.set("v.isPayButDisable", false);
                    //$A.util.removeClass(payBut, "disableBut");
                }else{
                    component.set("v.isCC",true);
                    wrapper.defaultPaymentMethodId = '';
                    wrapper.paymentTypeVar = '';
                }
                component.set('v.policywrap',wrapper);
            }
            else{
                component.set('v.Physical_Check', false);
                helper.picklistPaymentMethodChangeHelper(component,event);                
            }
        }
    },
    
    // tabs,payment method type, steps change
    paymentScheduleHandle: function (component, event, helper) {
        var clicked = event.currentTarget.dataset.type;
        helper.paymentScheduleHelper(component, clicked);
        helper.getDetails(component, clicked, false, "none", "none")
    },
    handlePaymentOptionChange: function (component, event, helper) {
        var clicked = event.getParam("value");
        helper.paymentScheduleHelper(component, clicked);
        helper.getDetails(component, clicked, false, "none", "none")
    },
    handlePaymentTypeChange: function (component, event, helper) {
        var clicked = event.getSource().get("v.text");
        helper.paymentScheduleHelper(component, clicked);
        helper.getDetails(component, clicked, false, "none", "none")
    },
    tabSwitchHandle: function (component, event, helper) {
        var clickedTab = event.target.id;
        var from = 'onclicktab'
        helper.tabSwitchHelper(component, clickedTab, from);
    },
    changeStepHandle: function (component, event, helper) {
        var flag = false;
        var to = event.currentTarget.dataset.to;
        var buttype = event.currentTarget.dataset.buttype;
        var toastList = [];
        var wrap = component.get("v.policywrap");

        // if (flag) {
        var from = event.currentTarget.dataset.from;
        if (from == 'policyInformation') {
            var list = wrap.policyQuotes;
            var proceed = false;
            var finlQuoteId = null;
            if (list.length) {
                for (var i of list) {
                    if (i.Final_Quote__c == true) {
                        proceed = true;
                        finlQuoteId = i.Id;
                    }
                }
            }
            
            //check lawyer fields
            var flag = helper.validateLawyerBirthdateFields(component, event);
            var flag1 = helper.validateLawyerBusinessEmailFields(component, event);
            var flag2 = helper.validateLawyerPersonalEmailFields(component, event);
            var flag3 = helper.validateLawyerPhoneFields(component, event);
            
            if (proceed && flag && flag1 && flag2 && flag3) {
                helper.finalizeQuoteHelper(component, event, finlQuoteId, to, buttype);
            } else {
                if(!proceed){
                    toastList.push(
                        {
                            type: 'err',   
                            message: 'Please select a Quote.'
                        }
                    )
                }
                if(!flag3){
                    toastList.push(
                        {
                            type: 'err',   
                            message: "Please confirm the lawyer’s phone number."
                        }
                    )
                }
                if(!flag2){
                    toastList.push(
                        {
                            type: 'err',   
                            message: 'Please confirm the lawyer’s personal email address.'
                        }
                    )
                }
                if(!flag1){
                    toastList.push(
                        {
                            type: 'err',   
                            message: 'Lawyer missing business email address.'
                        }
                    )
                }
                if(!flag){
                    toastList.push(
                        {
                            type: 'err',   
                            message: 'Please confirm the lawyer’s Birthday.'
                        }
                    )
                }
                helper.showToastHelper(component, toastList, 5);
            }   
        } else if (from == 'ibfContribution') {
            var isValid = helper.validateIBFFieldsHelper(component);
            console.log('isValid: ibfContribution', isValid);
            if (isValid) {
                helper.showSpinnerHelper(component);
                //helper.updatePolicyHelper(component, to, buttype,true);
            }
        } else if(from == 'TermsAndConditions'){
            //Updated the check box on policy.
            helper.showSpinnerHelper(component);
            helper.changeStepHelper(component, to, buttype);
            helper.closeSpinnerHelper(component);
            //helper.updatePolicyHelper(component, to, buttype,false);
        } else {
            flag = helper.changeStepHelper(component, to, buttype);
            //debugger;
            component.set("v.termsAndConditionAccepted",false); 
            helper.boxChangeHelper(component,false);
        }
        if(component.get("v.isErrorFound")){
            helper.scrollTop(component, event);
        }
    },
    isDataLoadSuccessHandle: function (component, event, helper) {
        helper.isDataLoadSuccessHelper(component, event);
    },

    // close, back, refresh buttons
    pageReloadHandle: function (component, event, helper) {
        //location.reload();
        helper.closepopupHelper(component, 'nor');
        component.set("v.isPaymentAndPolicyStatus", false);
        component.set("v.isPaymentSuccess", false);
        component.set("v.disableFields", false);
        component.set("v.dataTypeCvv", 'number');
    },
    pageCyberPop: function(component, event, helper) {
        //window.location.href= "https://isbamutual.com/cyber";
        window.open("https://www.sidebarinsurance.com/cyberquickquote/","_blank");
    },
    closemodalHandle: function (component, event, helper) {
        helper.closepopupHelper(component, 'nor');
        component.set("v.disableFields", false);
        component.set("v.dataTypeCvv", 'number');
    },
    closeToastHandle: function (component, event, helper) {
        helper.closeToastMethodHelper(component, event);
    },
    backToSavedScreenHandle: function (component, event, helper) {
        var backToHomeScreen = component.get("v.backToHomeScreen");
        component.set("v.disableFields", false);
        component.set("v.dataTypeCvv", 'number');
        if (backToHomeScreen) {
            helper.closepopupHelper(component, 'nor');
        } else {
            component.set('v.currentActiveTab','tab-2');
            component.set('v.isSavedScreen', true);
            component.set('v.isAddScreen', false);
            component.set("v.savedItemClick", false);
            helper.emptyFieldsHelper(component);
        }
    },

    // policy methods
    changeIBFValues: function (component, event, helper) {
        var from = event.target.id;
        var field = document.getElementById(from);        
        var wrap = component.get("v.policywrap");

        if (from == 'ibfContribution') {
            console.log('1', field.value);
            var updatedPermium = wrap.totalCLECredit;
            if (field.value == 'Yes - IBF Contribution Requested') {
                component.set("v.showIbfDependentFields", true);               
                component.set("v.donationType", 'Full');
            } else {
                component.set("v.showIbfDependentFields", false);
                updatedPermium = updatedPermium + parseFloat(wrap.roundedDividend);
                component.set("v.policywrap.policy.IBF_Custom_Amount__c", 0);
            }
            component.set("v.updatedPermium",updatedPermium);
        } else if (from == 'ibfContributionPercent') {
            console.log('2', field.value);
        } else if (from == 'ibfContributionCustomAmount') {
            console.log('3', field.value);
            // var percent = document.getElementById('ibfContributionPercent');
            var success = helper.validateCustomAmountHelper(component, field.value, wrap.roundedDividend);
            if(success){
                var updatedPermium = parseFloat(wrap.totalCLECredit) + parseFloat(wrap.roundedDividend) - parseFloat(field.value);
                component.set("v.updatedPermium", updatedPermium);
                component.set("v.policywrap.policy.IBF_Custom_Amount__c",parseFloat(field.value));
                console.log(component.get("v.updatedPermium"));
            }

        } else if (from == 'ibfTarget') {
            if (field.value == 'Appellate District') {
                component.set("v.showIbfTargetDependentField", true);
            } else {
                component.set("v.policywrap.policy.IBF_Appellate_District__c", null);
                component.set("v.showIbfTargetDependentField", false);
            }
        } else if (from == 'ibfSpecificDistrict') {
            console.log('5', field.value);
        } else if (from == 'ibfContributionDonationAmount') {
            var val = event.currentTarget.value;
            component.set("v.donationType", val);
            if(val == 'Full'){
                component.set("v.policywrap.policy.IBF_Custom_Amount__c", 0);
            }
            var updatedPremium = parseFloat(wrap.totalCLECredit);
            component.set("v.updatedPermium", updatedPremium);
            
        } else {
            console.log('6', field.value);
        }
    },
    selectQuote: function (component, event, helper) {
        var field = document.getElementById('selectedListViewRow');
        var isCheck = event.currentTarget.checked;
        var index = event.currentTarget.dataset.index;
        var wrap = component.get("v.policywrap");
        console.log('isCheck:', isCheck);

        var policyQuotes = wrap.policyQuotes;


        for (var i = 0; i < policyQuotes.length; i++) {
            if (isCheck && i == index) {
                policyQuotes[i].Final_Quote__c = true;
                wrap.premium = policyQuotes[i].Quote_Final_Premium__c;
                wrap.limits = policyQuotes[i].Limits__c;
                wrap.deductible = policyQuotes[i].Deductibles_Formula__c;
                wrap.perClaimLimit = policyQuotes[i].Coverage_Max_Per_Claim__c;
                wrap.aggregateLimit = policyQuotes[i].Full_Coverage__c;
            } else {
                policyQuotes[i].Final_Quote__c = false;
            }
        }
        component.set("v.isAnyQuoteSelected",isCheck);
        wrap.policyQuotes = policyQuotes;

        component.set("v.policywrap", wrap);
        console.log('second wrap:', component.get("v.policywrap"));
    },

    emailAndPhoneValidation: function (component, event, helper) {
        var id = event.target.id;
        var toastList = [];
        var field = document.getElementById(id);
        document.getElementById(id).className = '';

        if (id == 'lawyerEmail') {
            var confirmationEmailVal = helper.securityMailHelper(component, field);
            if (confirmationEmailVal != '') {
                if (confirmationEmailVal == field.name) {
                    toastList.push(
                        {
                            type: 'err',
                            message: 'Please enter email.'
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
        if (id == 'lawyerPhone') {

        }

        helper.showToastHelper(component, toastList, 5);

    },

    savedAddScreenChangeHandle: function (component, event, helper) {
        helper.savedAddScreenChangeHelper(component);
    },
    handleLawyerFieldChange: function (component, event, helper) {
        helper.handleLawyerFieldChangeHelper(component, event);
    },
    handelDonation : function (component, event, helper) {
        var val = event.currentTarget.value;
        component.set("v.donationType", val);
    },
    boxChangeHandler : function (component, event, helper) {
        var val = component.get("v.termsAndConditionAccepted"); 
        helper.boxChangeHelper(component, val);        
    },
    handleFocusPhone : function (component, event, helper) {
        var number = event.currentTarget.value;
        var index = parseInt(event.currentTarget.dataset.index);
        number = helper.cellPhoneNumberUnformatter(number);
        console.log('number:', number);
        var policyLawyers = component.get("v.policywrap.policyLawyers");

        var phonefields = component.find("lawyerPhoneNumber");

        if(policyLawyers){  
            helper.removeErrorClassFromFields(phonefields, "errorInput", index, (policyLawyers.length>1) );
            var button = component.find("infoNextBut");
            //$A.util.addClass(button,"disableBut");  
            component.set("v.isNextButtonDisabled", true);
            //helper.removeErrorClassFromFields(button, "disableBut", null, false );
        }
        policyLawyers[index].formatedPhone = number;
        component.set("v.policywrap.policyLawyers", policyLawyers);
    },
    handleBlurPhone: function (component, event, helper) {
        var number = event.currentTarget.value;
        var phonefields = component.find("lawyerPhoneNumber");
        var index = parseInt(event.currentTarget.dataset.index);
        var policyLawyers = component.get("v.policywrap.policyLawyers");
        let flag = false;
        var button = component.find("infoNextBut");
        if(number.length>0){
            if(parseInt(number) == NaN || number.length != 10){
                flag = true;
            }
            if(policyLawyers && flag){
                helper.addErrorClassInFields(phonefields, "errorInput", index, (policyLawyers.length>1) );
                //$A.util.addClass(button,"disableBut"); 
                component.set("v.isNextButtonDisabled", true);
            }
        }else{
            helper.removeErrorClassFromFields(button, "disableBut", null, false );
            component.set("v.isNextButtonDisabled", false);
        }

        policyLawyers[index].formatedPhone = number;
        policyLawyers[index].Lawyer__r.Contact__r.MobilePhone = number;        
        if(number.length == 10 && parseInt(number) != NaN){
            var formatedNumber = helper.cellPhoneNumberFormatter(number);
            policyLawyers[index].formatedPhone = formatedNumber;
            helper.removeErrorClassFromFields(button, "disableBut", null, false )
            component.set("v.isNextButtonDisabled", false);;
        }       
        component.set("v.policywrap.policyLawyers", policyLawyers);
    },
    handleFocusEmail : function (component, event, helper) {
        var index = parseInt(event.currentTarget.dataset.index);
        var auraId = event.currentTarget.dataset.id;
        var emailFields = component.find(auraId);
        var policyLawyers = component.get("v.policywrap.policyLawyers");
        if(policyLawyers){  
            helper.removeErrorClassFromFields(emailFields, "errorInput", index, (policyLawyers.length>1) );
            var button = component.find("infoNextBut");
            //$A.util.addClass(button,"disableBut");  
            component.set("v.isNextButtonDisabled", true);
            //helper.removeErrorClassFromFields(button, "disableBut", null, false );
        }
    },
    handleBlurEmail : function (component, event, helper) {
        var email = event.currentTarget.value;
        var index = parseInt(event.currentTarget.dataset.index);
        var auraId = event.currentTarget.dataset.id;
        var field = event.currentTarget.dataset.row;
        var required = event.currentTarget.dataset.req;
        var emailFields = component.find(auraId);
        var policyLawyers = component.get("v.policywrap.policyLawyers");
        var flag = false;
        var mailformat = new RegExp(component.get("v.emailRegex")); // /^[a-zA-Z0-9][a-zA-Z0-9._%+-]*[a-zA-Z0-9]@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[a-zA-Z]{2,}$/
        		        
        if(required == 'true'  || email){
            if (!(email.trim().match(mailformat))) {
                flag = true;
            }
        }
        var button = component.find("infoNextBut");
        if(policyLawyers && flag){  
            //$A.util.addClass(button,"disableBut");  
            component.set("v.isNextButtonDisabled", true);
            helper.addErrorClassInFields(emailFields, "errorInput", index, true);
        }
        else{
            //helper.removeErrorClassFromFields(button, "disableBut", null, false );
            component.set("v.isNextButtonDisabled", false);
            helper.removeErrorClassFromFields(emailFields, "errorInput", index, true);
        }
        policyLawyers[index].Lawyer__r.Contact__r[field] = email; 
        component.set("v.policywrap.policyLawyers", policyLawyers);
    },
    handleEditOnPay : function (component, event, helper) {
        component.set("v.disableFields", false);
        component.set("v.dataTypeCvv", 'number');
    },
    handleCancelOnPay : function (component, event, helper) {
        component.set("v.disableFields", true);
        component.set("v.dataTypeCvv", 'text');
        var wrap = component.get("v.policywrap");
        var currid =  wrap.paymentMethodId;

        var savedcardList = component.get("v.savedCardList");
        if (savedcardList.length) {
            for (var i = 0; i < savedcardList.length; i++) {
                if (currid == savedcardList[i].paymentMethod.Id) {
                    wrap.verificationNumber = savedcardList[i].verificationNumber;
                    wrap.expireMonth = savedcardList[i].expireMonth;
                    wrap.expireYear = savedcardList[i].expireYear;
                }
            }
            dataList = component.get("v.savedCardList");
        }
        var savedecheckList = component.get("v.savedEcheckList");
        if (savedecheckList.length) {
            for (var i = 0; i < savedecheckList.length; i++) {
                if (currid == savedecheckList[i].paymentMethod.Id) {

                } 
            }
            dataList = component.get("v.savedEcheckList");
        }
    },
    onCheck : function (component, event, helper) {
        var checkCmp = component.find("deliveryCheckbox");
        console.log('checkCmp =>', checkCmp.get("v.value"));
		component.set("v.policywrap.policy.Account__r.Physical_document_delivery__c", checkCmp.get("v.value"));
        helper.showSpinnerHelper(component);
        helper.updatePolicyHelper(component, '', '',false);
    },
    handleChangeDueDate: function (component, event, helper) {        
        helper.dueDateChangeHelper(component, event, 'onchange');
    },
    handleBlurDate: function(component, event, helper){
        var dtValid = false;
        let lawyers = component.get("v.policywrap.policyLawyers");
        //if(lawyers.length > 1){
            dtValid = component.find('lawyerBirthdate').reduce(function (validSoFar, inputCmp) {
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
        //}
        /*else{
            dtValid = component.find('lawyerBirthdate');
            dtValid = dtValid.get('v.validity').valid;
        }*/
        
        
        if(!dtValid){
            component.set("v.isNextButtonDisabled", true);
        }
        else{
            component.set("v.isNextButtonDisabled", false);
        }
    },
    openConfirmScreen : function (component, event, helper) {
        //helper.openPopupHelper(component, 'nor');
        component.set("v.isPaymentAndPolicyStatus", true);
        component.set("v.isPaymentSuccess", true);
        var page = component.find("wholePageContainer");
        $A.util.addClass(page, "bgWhite");
    },
    
    changePhysicalCheckHandle: function (component, event, helper) {
        var Physical_Check= component.get('v.Physical_Check');
        var wrapper = component.get('v.policywrap');
        console.log('Physical_Check',Physical_Check);
        console.log('wrapper',wrapper);
        if(Physical_Check){
            wrapper.paymentTypeVar = 'Physical_Check';
            wrapper.defaultPaymentMethodId = 'Physical_Check';
            
        }else{
            wrapper.defaultPaymentMethodId = '';
            wrapper.paymentTypeVar = '';
        }
        component.set('v.policywrap',wrapper);
         console.log('wrapper after',component.get('v.policywrap'));
     
    },
    downloadDocs: function (component, event, helper) {
        var wrapper = component.get('v.policywrap');
        //let link = wrapper.baseUrl+'/apex/PrintQuotes?id=' + wrapper.policy.Id + '&type=quoteBundle&fromPolicyBind=yes&removeQuoteIds=';
        let url = 'PrintQuotes&id=' + wrapper.policy.Id + '&type=quoteBundle&fromPolicyBind=yes&removeQuoteIds=';
        let link = wrapper.baseUrl+'/apex/Pdf_Lib_WatermarkHelper?watermark=Yes&URL='+encodeURI(url);
        window.open(link,'_Blank');
    },
    downloadEndorsementPdf: function (component, event, helper) {
        let watermark = event.currentTarget.dataset.watermark;
        var wrapper = component.get('v.policywrap');
        let url = 'Endorsement_Pdf?id=' + wrapper.endorsement.Id + '%26number='+encodeURI(wrapper.endorsement.Endorsement_Number__c)+'%26version='+encodeURI(wrapper.endorsement.Endorsement_Version__c);
        let link = wrapper.baseUrl+'/apex/Pdf_Lib_WatermarkHelper?watermark='+watermark+'&URL='+encodeURI(url);
        window.open(link,'_Blank');
    },
    downloadPolicy : function (component, event, helper) {
        var wrapper = component.get('v.policywrap');
        let versionData = wrapper.versionData;
        var contentType = 'application/pdf';
        var fileName = wrapper.fileName;
        
        var blob = helper.base64ToBlob(versionData, contentType);
        var url = window.URL.createObjectURL(blob);
        
        var a = document.createElement('a');
        a.style.display = 'none';
        a.href = url;
        a.download = fileName;
        
        document.body.appendChild(a);
        a.click();
        
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);
    },
    
    handleScaleInputNew: function (component, event, helper) {
        var scale = event.currentTarget.dataset.val;
        var allelements = event.currentTarget.parentNode.children;
        var field = '';
        var queNo = event.currentTarget.dataset.que;
        var questions = component.find(queNo);

        let isNextActive = false;
        let flag = false;

        for(let x of allelements){
           if(x.dataset.val == scale && x.style.background == ''){
                x.style.background = x.style.color;
                x.style.color = 'white';
           }
           else if(x.style.background != ''){
                x.style.color = x.style.background;
                x.style.background = '';
           }
        }
        
        if(questions.length > 0){
            for(let q of questions){
                if(q.getElement().classList.contains('activeQue')){
                    field = q.getElement().dataset.row;
                    $A.util.removeClass(q, 'activeQue');
                    $A.util.addClass(q, 'inActiveQue');
                    q.getElement().childNodes[1].innerHTML = scale;
                    isNextActive = true;
                    flag = false;
                }
                else if(isNextActive){
                    $A.util.addClass(q, 'activeQue');
                    $A.util.removeClass(q, 'inActiveQue');
                    isNextActive = false;
                    flag = true;
                }
                else{
                    flag = true;
                }
            }
        }
        else{
            field = questions.getElement().dataset.row;
            flag = false;
        }
        let ISBAM_survey = component.get("v.ISBAM_survey");
        if(!ISBAM_survey){
            ISBAM_survey = {};
        }
        ISBAM_survey[field] = scale;
        console.log('ISBAM_survey:', ISBAM_survey);
        component.set("v.ISBAM_survey", ISBAM_survey);
    },
    submitSurveyNew: function (component, event, helper) {
        var queNo = event.currentTarget.dataset.que;
        var field = '';
        var val = '';
        var questions = component.find(queNo);
        
        field = questions[0].getElement().dataset.row;
        val = questions[1].get("v.value");
        let ISBAM_survey = component.get("v.ISBAM_survey");
        ISBAM_survey[field] = val;
        console.log('ISBAM_survey:', ISBAM_survey);
        component.set("v.ISBAM_survey", ISBAM_survey);
        
        $A.util.addClass(component.find('surveyPage'), 'inActiveSection');
        $A.util.removeClass(component.find('surveyThanksPage'), 'inActiveSection');
        helper.UpdateSurveyFieldsNew(component);
    }
})