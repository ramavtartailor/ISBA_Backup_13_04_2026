({
    init: function (component, event, helper) {
        var spinner = component.find("fullScreenSpinnerId");
        $A.util.addClass(spinner, 'showFullScreenSpinner');
        var lastTime = component.get("v.lastTime");
        var urlQueryString = window.location.search;
        var urlParams = new URLSearchParams(urlQueryString);
        var isPay = urlParams.get('isPay');
        var isModifySchedules = urlParams.get('isModifySchedules');
        var isModifyPaymentMethod = urlParams.get('isModifyPaymentMethod');
        // this.getSavedPaymentMethodsList(component, event);

        if (isPay == 'true') {
            component.set("v.isPay", 'true');
        } else {
            isPay = 'false';
            component.set("v.isPay", 'false');
        }
        if (isModifySchedules == 'true') {
            component.set("v.isModifySchedules", 'true');
        } else {
            isModifySchedules = 'false';
            component.set("v.isModifySchedules", 'false');
        }
        if (isModifyPaymentMethod == 'true') {
            component.set("v.isModifyPaymentMethod", 'true');
        } else {
            isModifyPaymentMethod = 'false';
            component.set("v.isModifyPaymentMethod", 'false');
        }

        var validationString = component.get("v.recordId");
        if (validationString != '') {
            helper.getDetails(component, event, lastTime, false);
        } else {
            // var popupModalId = component.find("popupID");
            // $A.util.addClass(popupModalId, 'openPopup');
            // $A.util.addClass(popupModalId, 'smallPopupModalTwo');
            $A.util.removeClass(spinner, 'showFullScreenSpinner');
            component.set("v.isEnterEmail", true);
        }
        
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
            		let emptyFieldErrorList = [];
                    if (!eventData.details) {
                        helper.closeSpinnerHelper(component);
                        //helper.showToastHelper(component, toastList, 5);
                        toastList.push('Missing credit card details');
                        toastType = 'error';
                        helper.showToast(component, emptyFieldErrorList, toastList, toastType);
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
                        toastList.push('Please enter Card Holder Name');
                        helper.closeSpinnerHelper(component);
                    } else if (!eventData.details.cardNumber) {
                        toastList.push('Please enter Your Credit Card Number');
                        helper.closeSpinnerHelper(component);
                    } else if (creditCardExpiryYear == undefined || creditCardExpiryMonth == undefined) {
                        toastList.push('Please enter valid Expiration Date');
                    } else if ((parseInt(creditCardExpiryYear) < currentYr) || (parseInt(creditCardExpiryYear) == currentYr && parseInt(creditCardExpiryMonth) < currentMonth)) {
                        toastList.push('Please enter valid Expiration Date');
                        helper.closeSpinnerHelper(component);
                    } else {
                        //create Payment method in Salesforce
                        console.log('Payment Method Details:', eventData);
                        var cmpEvent = component.getEvent("submitEvent");
                        cmpEvent.fire();
                        //helper.saveCreditCardInFiserv(component, event, eventData);
                    }
                    if (toastList.length > 0) {
                        //helper.showToastHelper(component, toastList, 5);
                        toastType = 'error';
                        helper.showToast(component, emptyFieldErrorList, toastList, toastType);
                    }
                    //helper.closeSpinnerHelper(component);
                }
            }

            if (message.data.name == "TokenizeError") {
                console.log("message -> ", JSON.stringify(message.data.payload));
                if (message.data.payload) {
                    console.log('Error -> ', JSON.parse(JSON.stringify(message.data.payload)));
                    var toastList = [];
                    let emptyFieldErrorList = [];
                    toastList.push(JSON.parse(JSON.stringify(message.data.payload)));
                    toastType = 'error';
                    helper.showToast(component, emptyFieldErrorList, toastList, toastType);
                    //helper.showToastHelper(component, toastList, 5);
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
    billingPayOrAdd: function (component, event, helper) {
        var butType = event.currentTarget.dataset.type;
        var isEditable = component.get("v.isEditable");
        var isPayButDisable = component.get("v.isPayButDisable");
        if (!isEditable) {
            var spinner = component.find("fullScreenSpinnerId");
            var popup = component.find('popupID');
            if (butType == 'payBut') {
                if (!isPayButDisable) {
                    $A.util.addClass(popup, 'openPopup');
                    $A.util.addClass(spinner, 'showFullScreenSpinner');
                    component.set('v.isHeaderFooterModal', true);
                    component.set("v.isAddPaymentMethod", true);
                    component.set("v.fieldDisabled", true);
                    component.set("v.disableFields", true);
                    component.set("v.dataTypeCvv", 'text');
                    component.set("v.savedClick", true);
                    component.set("v.backToHomeScreen", true);
                    var from = 'savedItem'
                    helper.addScreenHelper(component, event, from);
                    //var currid = document.getElementById('picklistPaymentMethod').value;

                    var currid = '';
                    var allList = component.find('picklistPaymentMethod');
                    console.log('allList:', allList);
                    if (allList) {
                        if (allList.length > 0) {
                            for (var i = 0; i < allList.length; i++) {
                                console.log('i-> checked ', allList[i].getElement().checked);
                                console.log('i-> dataset ', allList[i].getElement().dataset.id);
                                if (allList[i].getElement().checked) {
                                    currid = allList[i].getElement().dataset.id;
                                }
                            }
                        }
                        else if (allList) {
                            if (allList.getElement().checked) {
                                currid = allList.getElement().dataset.id;
                            }
                        }

                        var savedcardList = component.get("v.savedCardList");
                        var itemIndex = '';
                        var itemType = '';

                        if (savedcardList.length) {
                            for (var i = 0; i < savedcardList.length; i++) {
                                if (currid == savedcardList[i].paymentMethod.Id) {
                                    console.log('yes Exists');
                                    itemType = 'creditCard';
                                    itemIndex = i;
                                }
                            }
                        }
                        var savedecheckList = component.get("v.savedEcheckList");
                        if (savedecheckList.length) {
                            for (var i = 0; i < savedecheckList.length; i++) {
                                if (currid == savedecheckList[i].paymentMethod.Id) {
                                    console.log('yes Exists');
                                    itemType = 'eCheck';
                                    itemIndex = i;

                                }
                            }
                        }
                        helper.setValuesInAddModal(component, event, itemIndex, itemType);
                    } else {
                        console.error('All list not found!')
                    }
                }
                else {
                    $A.util.addClass(popup, 'openPopup');
                    var smallpopup = component.find('popupSmallID');
                    $A.util.addClass(smallpopup, 'openPopup');
                    component.set("v.showPayMethodError", true);
                }
            } else {
                var savedCardList = component.get("v.savedCardList");
                var savedEcheckList = component.get("v.savedEcheckList");

                $A.util.addClass(popup, 'openPopup');
                $A.util.addClass(spinner, 'showFullScreenSpinner');
                component.set('v.isHeaderFooterModal', true);
                component.set("v.showInvoiceDetails", false);
                $A.util.removeClass(spinner, 'showFullScreenSpinner');

                if (savedCardList.length == 0 && savedEcheckList.length == 0) {
                    component.set('v.isAddScreen', true);
                    var addButton = 'addButton';
                    component.set("v.backToHomeScreen", true);
                    component.set("v.savedClick", false);
                    helper.addScreenHelper(component, event, addButton);
                } else {
                    component.set('v.isSavedScreen', true);
                }
                // helper.getSavedPaymentMethodsList(component, event);
            }
        }
    },
    closeToastBut: function (component, event, helper) {
        helper.closeToastButHelper(component, event);
    },

    closePopUpBut: function (component, event, helper) {
        component.set("v.disableFields", false);
        component.set("v.dataTypeCvv", 'number');

        helper.closeModalHelper(component, event);
    },
    okayButt: function (component, event, helper) {
        component.set('v.isWithoutHeaderFooterModal', false);
        var popupModalId = component.find("popupID");
        component.set('v.isPaymentSuccess', false);
        component.set("v.fieldDisabled", false);
        component.set('v.isPaymentError', false);
        $A.util.removeClass(popupModalId, 'openPopup');
        $A.util.removeClass(popupModalId, 'smallPopupModal');

        var wrapper = component.get("v.payWrapper");
        // var siteUrl = wrapper.siteUrl;
        // window.open(siteUrl, "_self");
        var buttonClick = '';
        var billid = wrapper.billing.Id;
        console.log('Okay butbillid:', billid);
        var tab = '_self'
        helper.isModifyOrPayHelper(component, event, billid, buttonClick, tab)


        // var isPay = component.get("v.isPay");
        // var isModifySchedules = component.get("v.isModifySchedules");
        // var isModifyPaymentMethod = component.get("v.isModifyPaymentMethod");
        // var url = new URL(location);
        // if (isPay) {
        //     url.searchParams.set("isPay", false);
        // } else if (isModifySchedules) {
        //     url.searchParams.set("isModifySchedules", false);

        // } else if (isModifyPaymentMethod) {
        //     url.searchParams.set("isModifyPaymentMethod", false);
        // }
        // history.pushState({}, "", url);
        // location.reload();
    },
    tabClick: function (component, event, helper) {
        var fieldDisabled = component.get("v.fieldDisabled");
        if (!fieldDisabled) {
            var currentTab = event.target.id;
            var numberOfTab = document.getElementsByClassName("tabHeading");
            var tabValue = component.find(currentTab).getElement().getAttribute('data-tabvalue');
            helper.emptyTheFields(component, event);
            for (var i = 1; i <= (numberOfTab.length); i++) {
                var curTab = 'tab-' + i;
                var curTabData = 'tab-' + i + '-data';
                if (currentTab != curTab) {
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
            var payWrap = component.get("v.payWrapper");
            payWrap.paymentTypeVar = tabValue;
            console.log('payWrap -> ' + JSON.stringify(payWrap));
            component.set("v.payWrapper", payWrap);
        }
    },
    backToSavedBut: function (component, event, helper) {
        var backToHomeScreen = component.get("v.backToHomeScreen");
        component.set("v.dataTypeCvv", 'number');
        component.set("v.disableFields", false);
        if (backToHomeScreen) {
            helper.closeModalHelper(component, event);
            component.set("v.backToHomeScreen", false);
        } else {
            component.set('v.currentActiveTab', 'tab-2');
            component.set("v.savedClick", false);
            component.set('v.isSavedScreen', true);
            component.set('v.isAddScreen', false);
            helper.emptyTheFields(component, event);
            component.set("v.fieldDisabled", false);
        }
    },
    savedItemClick: function (component, event, helper) {
        console.log('savedItemClick:');
        component.set("v.savedClick", true);
        var spinner = component.find("popupSmallID");
        $A.util.addClass(spinner, 'showFullScreenSpinner');

        // setPaymentMethod

        component.set("v.fieldDisabled", true);
        var itemIndex = event.currentTarget.dataset.recordid;
        var itemType = event.currentTarget.dataset.recordtype;
        helper.setValuesInAddModal(component, event, itemIndex, itemType);
    },

    deleteSavedItem: function (component, event, helper) {
        console.log('deletebutt:');
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
        console.log('deleteSavedItem-> itemId:', itemId);

        var wrapper = component.get("v.payWrapper");
        wrapper.paymentMethodId = itemId;
        wrapper.payMethodToken = itemPayMethodToken;
        component.set("v.payWrapper", wrapper);

        component.set("v.isConfirmationDelete", true);
        var smallpopup = component.find('popupSmallID');
        $A.util.addClass(smallpopup, 'openPopup');
    },

    addCardCheckBut: function (component, event, helper) {
        console.log('addCardCheckBut Wrapper:-> ', component.get('v.payWrapper'));
        var addButton = 'addButton';

        console.log(component.get('v.isAddScreen'));

        console.log(component.get('v.isSavedScreen'));
        console.log(component.get('v.savedClick'));
        console.log(component.get('v.backToHomeScreen'));
        console.log(component.get('v.AddFromMainScreen'));
        console.log(component.get('v.isAddPaymentMethod'));



        helper.addScreenHelper(component, event, addButton);

    },
    PayNowBut: function (component, event, helper) {
        var currentTab = component.get('v.currentActiveTab');
        var proceedToPay = false;
        var buttonType = event.currentTarget.dataset.type;
        console.log('buttonType', buttonType);
        var isAddPaymentMethod = component.get("v.isAddPaymentMethod");
        var payWrap = component.get('v.payWrapper');
        var emptyFieldErrorList = [];


        if (buttonType == 'setPaymentMethod') {
            var currentActiveTab = payWrap.paymentTypeVar;
            var currentMethodId = payWrap.paymentMethodId;
            if (currentActiveTab == 'creditCard') {
                var savedCardList = component.get("v.savedCardList");
                if (savedCardList != undefined) {
                    for (var i = 0; i < savedCardList.length; i++) {
                        if (currentMethodId == savedCardList[i].paymentMethod.Id) {
                            savedCardList[i].isSetToPay = true;
                        } else {
                            savedCardList[i].isSetToPay = false;
                        }
                    }
                    component.set("v.savedCardList", savedCardList);
                } else {
                    console.log("SavedCardList empty");
                }
            } else {
                var savedEcheckList = component.get("v.savedEcheckList");
                if (savedCardList != undefined) {
                    for (var i = 0; i < savedEcheckList.length; i++) {
                        if (currentMethodId == savedEcheckList[i].paymentMethod.Id) {
                            savedEcheckList[i].isSetToPay = true;
                        } else {
                            savedCardList[i].isSetToPay = false;
                        }
                    }
                    component.set("v.savedEcheckList", savedEcheckList);
                } else {
                    console.log("SavedCardList empty");
                }
            }
            helper.closeModalHelper(component, event);
            console.log('settopayment :', payWrap);

            window.setTimeout(() => {
                helper.picklistPaymentMethodChangeHelper(component, event, '');
            }, 1000);
            $A.util.removeClass(spinner, 'showFullScreenSpinner');
        } else {
            if (currentTab == 'tab-1') {
                var error = false;
                if (isAddPaymentMethod) {
                    let cardSendConfirmationEmail = '';
                    var confirmationEmailVal = '';
                    cardSendConfirmationEmail = document.getElementById('cardSendConfirmationEmail'); // card email confirmation code
                    confirmationEmailVal = helper.isConfirmationEmailValid(cardSendConfirmationEmail);
                    if (confirmationEmailVal != '') {
                        if (confirmationEmailVal == cardSendConfirmationEmail.name) {
                            emptyFieldErrorList.push(confirmationEmailVal);
                        } else {
                            otherErrorList.push(confirmationEmailVal);
                        }
                        error = true;
                    } if (cardSendConfirmationEmail == '') {
                        emptyFieldErrorList.push('Confirmation Email');
                        error = true;
                    }
                    if (!error) {
                        var spinner = component.find("fullScreenSpinnerId");
                        $A.util.addClass(spinner, 'showFullScreenSpinner');
                        console.log('Verified!');
                        payWrap.confirmationEmail = document.getElementById('cardSendConfirmationEmail').value;

                        component.set('v.payWrapper', payWrap);

                        proceedToPay = true;
                    }
                }
                else {
                    // creditCard
                    var savedClick = component.get("v.savedClick");


                    let cardNameOnCard = document.getElementById('cardNameOnCard'); // card holder name
                    let cardExpiryMonth = document.getElementById('cardExpiryMonth'); // card expiry month
                    let cardExpiryYear = document.getElementById('cardExpiryYear'); // card expiry year
                    let cardNumber = document.getElementById('cardNumber'); // card number
                    let cardCVV = document.getElementById('cardCVV'); // card cvv
                    let cardType = document.getElementById('cardType'); // card type
                    var otherErrorList = [];
                    var expiryReturnVal = helper.isExpiryValid(cardExpiryMonth, cardExpiryYear)
                    // var setAutoPay = component.get("v.isAutoPay");;
                    // var setAutoPay = document.getElementById('creditcardAutoPay').checked;

                    if (expiryReturnVal != '') {
                        if (expiryReturnVal == 'Expiry Date' || expiryReturnVal == 'Expiry Month' || expiryReturnVal == 'Expiry Year') {
                            emptyFieldErrorList.push(expiryReturnVal);
                        } else {
                            otherErrorList.push(expiryReturnVal);
                        }
                        error = true;
                    }

                    var cvvVal = helper.isCVVValid(component, cardCVV, cardType);
                    if (cvvVal != '') {
                        if (cvvVal == cardCVV.name) {
                            emptyFieldErrorList.push(cardCVV.name);
                        } else {
                            otherErrorList.push(cvvVal);
                        }
                        error = true;
                    }
                    if (!savedClick) {
                        var cardNumberVal = helper.isCardNumberValid(cardNumber);
                        var nameOnCardVal = helper.isFieldEmpty(cardNameOnCard);

                        if (cardNumberVal != '') {
                            if (cardNumberVal == cardNumber.name) {
                                emptyFieldErrorList.push(cardNumberVal);
                            } else {
                                otherErrorList.push(cardNumberVal);
                            }
                            error = true;
                        }

                        if (nameOnCardVal != '') {
                            emptyFieldErrorList.push(nameOnCardVal);
                            error = true;
                        }

                        if (cardType.value == 'none') {
                            emptyFieldErrorList.push('Card Type');
                            cardType.className = 'errorInput';
                            error = true;
                        }
                        if (cardType.value != 'none') {
                            if (cardNumber.value != '') {
                                var cardNumberVal = helper.isCardNumberValid(cardNumber);
                                if (cardNumberVal == '') {
                                    var comparedNumberAndTypeVal = helper.compareCardNumberAndType(cardNumber, cardType);
                                    if (comparedNumberAndTypeVal != '') {
                                        otherErrorList.push(comparedNumberAndTypeVal);
                                        error = true;
                                    }
                                }
                            } if (cardCVV.value != '') {
                                helper.isCVVValid(component, cardCVV, cardType);
                            }
                        }
                    }
                    if (!error) {
                        var spinner = component.find("fullScreenSpinnerId");
                        $A.util.addClass(spinner, 'showFullScreenSpinner');
                        console.log('Verified!');

                        payWrap.cardTypeVar = document.getElementById('cardType').value;
                        payWrap.cardNumber = document.getElementById('cardNumber').value;
                        payWrap.verificationNumber = document.getElementById('cardCVV').value;
                        payWrap.expireMonth = document.getElementById('cardExpiryMonth').value;
                        payWrap.expireYear = document.getElementById('cardExpiryYear').value;
                        payWrap.nameOnCard = document.getElementById('cardNameOnCard').value;
                        payWrap.paymentTypeVar = 'creditCard';
                        // payWrap.isAutoPay = setAutoPay;

                        component.set('v.payWrapper', payWrap);

                        proceedToPay = true;
                    }
                }

                if (error) {
                    var toastType = 'error';
                    helper.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
                }
            } else if (currentTab == 'tab-2') {
                var error = false;

                if (isAddPaymentMethod) {
                    let checkSendConfirmationEmail = '';
                    var checkSendConfirmationEmailVal = '';
                    checkSendConfirmationEmail = document.getElementById('checkSendConfirmationEmail'); // card email confirmation code
                    checkSendConfirmationEmailVal = helper.isConfirmationEmailValid(checkSendConfirmationEmail);
                    if (checkSendConfirmationEmailVal != '') {
                        if (checkSendConfirmationEmailVal == checkSendConfirmationEmail.name) {
                            emptyFieldErrorList.push(checkSendConfirmationEmailVal);
                        } else {
                            otherErrorList.push(checkSendConfirmationEmailVal);
                        }
                        error = true;
                    }
                    if (!error) {
                        var spinner = component.find("fullScreenSpinnerId");
                        $A.util.addClass(spinner, 'showFullScreenSpinner');
                        console.log('Verified!');
                        payWrap.confirmationEmail = document.getElementById('checkSendConfirmationEmail').value;

                        component.set('v.payWrapper', payWrap);

                        proceedToPay = true;

                    }
                }
                else {
                    var savedClick = component.get("v.savedClick");

                    // echeck
                    let checkAccountHolderName = document.getElementById('checkAccountHolderName'); // card number
                    let checkAccountType = document.getElementById('checkAccountType'); // card expiry year
                    let checkAccountNumber = document.getElementById('checkAccountNumber'); // card expiry month
                    let checkRoutingNumber = document.getElementById('checkRoutingNumber'); // card holder name

                    var emptyFieldErrorList = [];
                    var otherErrorList = [];
                    // var setAutoPay = component.get("v.isAutoPay");
                    // var setAutoPay = document.getElementById('echeckAutoPay').checked;

                    if (!savedClick) {
                        var checkAccountHolderNameVal = helper.isFieldEmpty(checkAccountHolderName);
                        var checkAccountTypeVal = helper.isFieldEmpty(checkAccountType);
                        var checkAccountNumberVal = helper.isFieldEmpty(checkAccountNumber);
                        var checkRoutingNumberVal = helper.isCheckRoutingNumberValid(checkRoutingNumber);

                        if (checkAccountHolderNameVal != '') {
                            emptyFieldErrorList.push(checkAccountHolderNameVal);
                            error = true;
                        }
                        if (checkAccountTypeVal != '') {
                            emptyFieldErrorList.push(checkAccountTypeVal);
                            error = true;
                        }
                        if (checkAccountNumberVal != '') {
                            emptyFieldErrorList.push(checkAccountNumberVal);
                            error = true;
                        }
                        if (checkRoutingNumberVal != '') {
                            if (checkRoutingNumberVal == checkRoutingNumber.name) {
                                emptyFieldErrorList.push(checkRoutingNumberVal);
                            } else {
                                otherErrorList.push(checkRoutingNumberVal);
                            }
                            error = true;
                        }
                    }
                    if (!error) {
                        var spinner = component.find("fullScreenSpinnerId");
                        $A.util.addClass(spinner, 'showFullScreenSpinner');
                        console.log('Verified!');

                        payWrap.routingNumber = document.getElementById('checkRoutingNumber').value;
                        payWrap.accountNumber = document.getElementById('checkAccountNumber').value;
                        payWrap.accountType = document.getElementById('checkAccountType').value;
                        payWrap.accountHolderName = document.getElementById('checkAccountHolderName').value;
                        payWrap.paymentTypeVar = 'check';
                        // payWrap.isAutoPay = setAutoPay;

                        component.set('v.payWrapper', payWrap);

                        proceedToPay = true;

                    }
                }

                if (error) {
                    var toastType = 'error';
                    helper.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
                }

            }
            if (proceedToPay) {
                if (buttonType == 'savePaymentMethod') {
                    helper.savePaymentMethodHelper(component, event);
                } else if (buttonType == 'updatePaymentMethod') {
                    console.log('buttonType:', buttonType);
                    helper.updatePaymentMethodHelper(component, event);
                } else {
                    var isPaymentFirstTime = component.get("v.isPaymentFirstTime");
                    var oldPaymentFrequency = component.get("v.tempLastTime");
                    var newPaymentFrequency = component.get("v.tempLastTime");

                    var oldPaymentSchedule = component.get("v.oldPaymentSchedule");
                    var newPaymentSchedule = component.get("v.payWrapper.paymentScheduleListToInsert");
                    let flag = false;
                    if (oldPaymentSchedule && newPaymentSchedule && newPaymentSchedule.length == oldPaymentSchedule.length) {
                        for (let i = 0; i < newPaymentSchedule.length; i++) {
                            if (newPaymentSchedule[i].Due_Date__c != oldPaymentSchedule[i].Due_Date__c || newPaymentSchedule[i].Due_Amount__c != oldPaymentSchedule[i].Due_Amount__c) {
                                flag = true;
                            }
                        }
                    }
                    else {
                        flag = true;
                    }
                    if (isPaymentFirstTime || oldPaymentFrequency != newPaymentFrequency || flag) {
                        helper.saveNewPaymentSchedules(component, event, false);
                        //window.setTimeout(() => {
                            //helper.processPaymentHelper(component, event);
                        //}, 100);
                    } else {
                        helper.processPaymentHelper(component, event);
                    }
                }
            }
        }
    },

    isFirstNameValid: function (component, event, helper) {
        document.getElementById('cardFirstName').className = '';
        var firstName = document.getElementById('cardFirstName');
        helper.isFieldEmpty(firstName);
    },
    isLastNameValid: function (component, event, helper) {
        document.getElementById('cardLastName').className = '';
        var lastName = document.getElementById('cardLastName');
        helper.isFieldEmpty(lastName);
    },
    isNameOnCardValid: function (component, event, helper) {
        document.getElementById('cardNameOnCard').className = '';
        var nameOnCard = document.getElementById('cardNameOnCard');
        console.log('Name On card: ', nameOnCard.value);
        helper.isFieldEmpty(nameOnCard);
    },
    isCardTypeValid: function (component, event, helper) {
        document.getElementById('cardType').className = '';
        var cardType = document.getElementById('cardType');
        var cardNumber = document.getElementById('cardNumber');
        var cardCvv = document.getElementById('cardCVV');
        if (cardType.value == 'americanExpress') {
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
                var cardNumberVal = helper.isCardNumberValid(cardNumber);
                if (cardNumberVal == '') {
                    var comparedNumberAndTypeVal = helper.compareCardNumberAndType(cardNumber, cardType);
                    if (comparedNumberAndTypeVal != '') {
                        if (cardCvv.value != '') {
                            helper.isCVVValid(component, cardCvv, cardType);
                        }
                    }
                }
            } if (cardCvv.value != '') {
                helper.isCVVValid(component, cardCvv, cardType);
            }
        }
    },
    isCardNumberValid: function (cmp, eve, hel) {
        document.getElementById('cardNumber').className = '';
        var cardNumber = document.getElementById('cardNumber');
        var cardType = document.getElementById('cardType');
        var cardCvv = document.getElementById('cardCVV');
        var cardNumberVal = hel.isCardNumberValid(cardNumber);
        if (cardNumberVal == '') {
            var getCreditCardTypeVal = hel.getCreditCardType(cardNumber);
            cmp.set('v.cardType', getCreditCardTypeVal);
            var comparedNumberAndTypeVal = hel.compareCardNumberAndType(cardNumber, cardType);
            if (comparedNumberAndTypeVal == '') {
                if (cardCvv.value != '') {
                    hel.isCVVValid(cmp, cardCvv, cardType);
                }
            }
        }
    },
    isCvvValid: function (cmp, eve, hel) {
        document.getElementById('cardCVV').className = '';
        var cardCvv = document.getElementById('cardCVV');
        var cardType = document.getElementById('cardType');
        hel.isCVVValid(cmp, cardCvv, cardType);
    },
    isExpiryValid: function (cmp, eve, hel) {
        document.getElementById('cardExpiryMonth').className = '';
        document.getElementById('cardExpiryYear').className = '';
        var cardExpiryMonth = document.getElementById('cardExpiryMonth');
        var cardExpiryYear = document.getElementById('cardExpiryYear');
        if (cardExpiryMonth.value != 'none') {
            cmp.set('v.cardExpiryMonth', cardExpiryMonth.value);
        } else {
            cmp.set('v.cardExpiryMonth', '--');
        }
        if (cardExpiryYear.value != 'none') {
            cmp.set('v.cardExpiryYear', cardExpiryYear.value);
        } else {
            cmp.set('v.cardExpiryYear', '----');
        }
        hel.isExpiryValid(cardExpiryMonth, cardExpiryYear);
    },
    isSecurityMailValid: function (cmp, eve, hel) {
        document.getElementById('cardSendConfirmationEmail').className = '';
        var securityMail = document.getElementById('cardSendConfirmationEmail');
        hel.isConfirmationEmailValid(securityMail);
    },
    keyUpCardNumber: function (cmp, eve, hel) {
        var typedCardNumber = eve.currentTarget.value;
        cmp.set('v.cardFirstFour', hel.showCardNumberOnDisplayCard(typedCardNumber.slice(0, 4)));
        cmp.set('v.cardSecondFour', hel.showCardNumberOnDisplayCard(typedCardNumber.slice(4, 8)));
        cmp.set('v.cardThirdFour', hel.showCardNumberOnDisplayCard(typedCardNumber.slice(8, 12)));
        cmp.set('v.cardFourthFour', hel.showCardNumberOnDisplayCard(typedCardNumber.slice(12, 16)));
    },
    keyUpCardHolderName: function (cmp, eve, hel) {
        var enteredCardHolderName = eve.currentTarget.value;
        if (enteredCardHolderName.length != 0) {
            cmp.set("v.cardHolderName", enteredCardHolderName);
        } else {
            cmp.set("v.cardHolderName", 'CARD HOLDER NAME');
        }
    },
    keyUpCvv: function (cmp, eve, hel) {
        var enteredCvv = eve.currentTarget.value;
        var numberOfDigit = cmp.get('v.numberOfCardCvv');
        var temp = '';
        for (var i = enteredCvv.length; i < numberOfDigit; i++) {
            temp += 'X';
        }
        cmp.set('v.cardCvv', enteredCvv + temp);
    },
    cvvFocusIn: function (cmp, eve, hel) {
        var cardSideFront = cmp.find("card-front");
        var cardSideBack = cmp.find("card-back");
        $A.util.addClass(cardSideFront, 'onFocusFlipFront');
        $A.util.addClass(cardSideBack, 'onFocusFlipBack');
    },
    cvvFocusOut: function (cmp, eve, hel) {
        var cardSideFront = cmp.find("card-front");
        var cardSideBack = cmp.find("card-back");
        $A.util.removeClass(cardSideFront, 'onFocusFlipFront');
        $A.util.removeClass(cardSideBack, 'onFocusFlipBack');
    },
    // CHECK VALIDATIONS
    isCheckFirstNameValid: function (cmp, eve, hel) {
        document.getElementById('checkFirstName').className = '';
        var checkFistName = document.getElementById('checkFirstName');
        hel.isFieldEmpty(checkFistName);
    },
    isCheckLastNameValid: function (cmp, eve, hel) {
        document.getElementById('checkLastName').className = '';
        var checkLastName = document.getElementById('checkLastName');
        hel.isFieldEmpty(checkLastName)
    },
    isCheckAccountHolderNameValid: function (cmp, eve, hel) {
        document.getElementById('checkAccountHolderName').className = '';
        var accountHolderName = document.getElementById('checkAccountHolderName');
        hel.isFieldEmpty(accountHolderName)
    },
    isCheckAccountType: function (cmp, eve, hel) {
        document.getElementById('checkAccountType').className = '';
        var checkAccountType = document.getElementById('checkAccountType');
        hel.isCheckAccountTypeValid(checkAccountType);
    },
    isCheckSecurityMailValid: function (cmp, eve, hel) {
        document.getElementById('checkSendConfirmationEmail').className = '';
        var checkSendConfirmEmail = document.getElementById('checkSendConfirmationEmail');
        hel.isConfirmationEmailValid(checkSendConfirmEmail);
    },
    isCheckAccountNumberValid: function (cmp, eve, hel) {
        document.getElementById('checkAccountNumber').className = '';
        var checkAccountNumber = document.getElementById('checkAccountNumber');
        hel.isCheckAccountNumberValid(checkAccountNumber);
    },
    isCheckRoutingNumberValid: function (cmp, eve, hel) {
        document.getElementById('checkRoutingNumber').className = '';
        var checkRoutingNumber = document.getElementById('checkRoutingNumber');
        hel.isCheckRoutingNumberValid(checkRoutingNumber);
    },
    // for full time / quaterly / monthly
    paymentTypeHandle: function (component, eve, hel) {
        var clicked = eve.getSource().get("v.text");
        // hel.changePaymentType(component, clicked);
        let tempLastTime = component.get("v.tempLastTime");
        console.log('tempLastTime:', tempLastTime);
        var payWrap = component.get('v.payWrapper');
        payWrap.paymentScheduleVar = clicked;
        component.set("v.payWrapper", payWrap);

        component.set("v.lastTime", clicked);
        hel.getDetails(component, eve, clicked, false);
        // var isPaymentFirstTime = component.get("v.isPaymentFirstTime");
        // var isEditable = component.get("v.isEditable");
        // if (isPaymentFirstTime) {
        // } else {
        //     if (isEditable) {
        //         hel.changePaymentType(component, clicked);
        //         component.set("v.lastTime", clicked);
        //         hel.getDetails(component, eve, clicked, false);
        //     }
        // }
    },
    listTypeHandle: function (component, eve, hel) {
        var clicked = eve.currentTarget.dataset.id;
        if (clicked == 'Billing') {
            component.set("v.billingTabActive", true);
            component.set("v.policyTabActive", false);
            component.set("v.endorsementTabActive", false);
        }
        else if (clicked == 'Applications') {
            component.set("v.billingTabActive", false);
            component.set("v.policyTabActive", false);
            component.set("v.endorsementTabActive", true);
        }
        else {
            component.set("v.billingTabActive", false);
            component.set("v.policyTabActive", true);
            component.set("v.endorsementTabActive", false);
        }
        hel.changeListType(component, clicked);
    },
    editPayMethod: function (component, eve, hel) {
        var payBut = component.find("payBut");
        $A.util.addClass(payBut, "disableBut");
        var lastTime = component.get("v.lastTime");
        component.set("v.tempLastTime", lastTime);
        var tempLastTime = component.get("v.tempLastTime");
        component.set("v.isEditable", true);
        hel.changePaymentType(component, tempLastTime);
    },
    closeEdit: function (component, event, helper) {

        // var isModifySchedules = component.get("v.isModifySchedules");
        // if(isModifySchedules){
        //     history.back();
        // }else{
        var payBut = component.find("payBut");
        $A.util.removeClass(payBut, "disableBut");

        component.set("v.isEditable", false);
        var tempLastTime = component.get("v.tempLastTime");
        console.log('my test: ', tempLastTime)
        component.set("v.lastTime", tempLastTime);

        helper.getDetails(component, event, tempLastTime, true);
        // helper.disablePayMethod(component, event, tempLastTime);

    },
    closePayMethodErrorModal: function (component, event, helper) {
        var popup = component.find('popupID');
        $A.util.removeClass(popup, 'openPopup');
        var smallpopup = component.find('popupSmallID');
        $A.util.removeClass(smallpopup, 'openPopup');
        component.set("v.showPayMethodError", false);
    },
    saveEdit: function (component, event, helper) {
        var spinner = component.find("fullScreenSpinnerId");
        $A.util.addClass(spinner, 'showFullScreenSpinner');
        var isModifySchedules = component.get("v.isModifySchedules");
        if (isModifySchedules) {
            var url = new URL(location);
            url.searchParams.set("isModifySchedules", false);
            history.pushState({}, "", url);
        }
        var payBut = component.find("payBut");
        $A.util.removeClass(payBut, "disableBut");

        component.set("v.isEditable", false);
        var lastTime = component.get("v.lastTime");
        var tempLastTime = component.get("v.tempLastTime");
        if (tempLastTime != lastTime) {
            component.set("v.tempLastTime", lastTime);
            var newTemp = component.get("v.tempLastTime");
            helper.saveNewPaymentSchedules(component, event, true);


            // helper.disablePayMethod(component, event, newTemp);
        }
    },
    handleChangeDueDate: function (component, event, helper) {
        var isLoad = component.get("v.isPaymentLoad");
        if (isLoad) {
            helper.dueDateChangeHelper(component, event, 'onchange');
        }
    },
    checkEmailValid: function (component, event, helper) {
        document.getElementById('emailAddress').className = '';
        var enteredEmail = document.getElementById('emailAddress');
        var returnVal = helper.isConfirmationEmailValid(enteredEmail);
        var temp = '';
        var getLinkBut = component.find("getLinkBut");
        if (returnVal == enteredEmail.name) {
            temp = 'Please Enter the email';
            $A.util.addClass(getLinkBut, "disableBut");
            component.set("v.isDisabledSendEmailbut", true);
        } else if (returnVal == '') {
            enteredEmail.className = 'successInput';
            component.set("v.isDisabledSendEmailbut", false);
            $A.util.removeClass(getLinkBut, "disableBut");
        } else {
            temp = returnVal;
            $A.util.addClass(getLinkBut, "disableBut");
            component.set("v.isDisabledSendEmailbut", true);
        }
        component.set("v.emailmessage", temp);
    },

    getLink: function (component, event, helper) {
        var isDisabled = component.get("v.isDisabledSendEmailbut");
        if (!isDisabled) {
            var spinner = component.find("fullScreenSpinnerId");
            $A.util.addClass(spinner, 'showFullScreenSpinner');
            var emailId = document.getElementById('emailAddress').value;
            console.log('emailId:', emailId);
            helper.getLinkHelper(component, emailId);
        }
    },
    proceedToBilling: function (component, event, helper) {
        var spinner = component.find("fullScreenSpinnerId");
        $A.util.addClass(spinner, 'showFullScreenSpinner');
        var billid = event.currentTarget.dataset.billid;
        var butType = event.currentTarget.dataset.buttype;

        var buttonClick = '';
        if (butType == 'isPay') {
            buttonClick = '&isPay=true';
        }
        // else if (butType == 'isModifyPaymentMethod') {
        //     buttonClick = '';
        // } 
        else if (butType == 'isPayMobile') {
            buttonClick = '&isPay=true';
            billid = component.get("v.rs_selectedBillId");
        } else if (butType == 'isModifyPaymentMobile') {
            //     buttonClick = '&isModifyPaymentMethod=true';
            billid = component.get("v.rs_selectedBillId");
        }
        //  else {
        //     buttonClick = '';
        // }
        var tab = '_blank'
        if (component.get("v.isPayButDisable") && (butType == 'isPay' || butType == 'isPayMobile')) {
            component.set("v.showPayMethodError", true);
            var smallpopup = component.find('popupSmallID');
            $A.util.addClass(smallpopup, 'openPopup');
        }
        else {
            helper.isModifyOrPayHelper(component, event, billid, buttonClick, tab)
        }
    },
    confirmationModalButton: function (component, event, helper) {
        var buttonType = event.currentTarget.dataset.buttype;
        if (buttonType == 'no') {
            component.set("v.isConfirmationDelete", false);
            var smallpopup = component.find('popupSmallID');
            $A.util.removeClass(smallpopup, 'openPopup');
        } else if (buttonType == 'yes') {

            helper.deleteSavedItemHelper(component, event);
        }
    },
    picklistPaymentMethodChange: function (component, event, helper) {

        helper.picklistPaymentMethodChangeHelper(component, event);
    },

    StartTimmer: function (component, event, helper) {
        // console.log('starttime:');
        // var minnn = component.get("v.minutes");
        // var secc = component.get("v.seconds");
        // console.log('minnn:', minnn);
        // console.log('secc:', secc);
        var flag = false;
        let min = component.get("v.minutes");
        let sec = component.get("v.seconds");
        if (parseInt(sec) == 0) {
            min = parseInt(min) - 1;
            sec = 59;
        }
        else {
            sec = parseInt(sec) - 1;
        }
        min = '' + min + '';
        sec = '' + sec + '';
        // component.set("v.minutes",min);
        // component.set("v.seconds",sec);
        component.set("v.minutes", min.padStart(2, "0"));
        component.set("v.seconds", sec.padStart(2, "0"));
        // console.log('min.padStart(2,0):', min.padStart(2,"0"));
        // console.log('sec.padStart(2,0):', sec.padStart(2,"0"));
        if (parseInt(min) == 0 && parseInt(sec) == 0) {
            console.log('isTimeOut => ');
            flag = true;
        }
        else {
            window.setTimeout(() => {
                helper.changeTime(component, event);
            }, 1000);
        }
        if (flag) {
            helper.timeOutHelper(component, event);
        }
    },

    redirectToGetVerificationPage: function (component, event, helper) {
        helper.redirectToGetVerificationPageHelper(component, event);
    },

    rs_expandRow: function (component, event, helper) {
        var index = event.currentTarget.dataset.index;
        console.log('index:', index);
        helper.rs_expandRowHelper(component, event, index);
    },
    rs_expandApplicationRow: function (component, event, helper) {
        var index = event.currentTarget.dataset.index;
        console.log('index:', index);
        helper.rs_expandApplicationRowHelper(component, event, index);
    },

    selectBillingMethod: function (component, event, helper) {
        var index = event.currentTarget.dataset.index;
        var billId = event.currentTarget.dataset.billid;
        var checked = event.currentTarget.checked;
        helper.selectBillingMethodHelper(component, event, index, checked);
    },

    redirectToLoginScreen: function (component, event, helper) {
        helper.redirectToLoginScreenHelper(component, event);
    },
    printBillingHandle: function (component, event, helper) {
        var from = event.currentTarget.dataset.from;
        var link = '';
        if (from == 'mebview') {
            link = component.get("v.rs_selectedBillpdfLink");

        } else {
            link = event.currentTarget.dataset.pdflink;
        }
        helper.printBillingHelper(component, link);

    },
    getSavedPaymentMethodsListHandle: function (component, event, helper) {
        helper.getSavedPaymentMethodsList(component, event);
    },
    pageCyberPop: function (component, event, helper) {
        window.location.href = "https://isbamutual.com/cyber";
    },
    backToHomeScreenHandle: function (component, event, helper) {
        helper.closeModalHelper(component, event);
    },
    handleSort: function (component, event, helper) {
        var id = event.currentTarget.dataset.id;
        var type = event.currentTarget.dataset.type;
        var field = event.currentTarget.dataset.field;
        var wrapper = component.get("v.payWrapper");
        var sortingType = component.get("v.lastItemClicked") == type + field ? 'DESC' : 'ASC';

        if (sortingType == 'DESC') {
            component.set("v.lastItemClicked", '');
        } else {
            component.set("v.lastItemClicked", type + field);
        }
        let items = [];
        if (id == 'Billing') {
            items = wrapper.billings;
        }
        else if (id == 'Applications') {
            items = wrapper.applications;
        }
        else if(id == 'Endorsement'){
            items = wrapper.policyEndorsements;
        }
        else {
            items = wrapper.policies;
        }


        if (items.length > 1) {
            items.sort((a, b) => {
                let nameA;
                let nameB;
                if (id == 'Billing') {
                    nameA = a.bill[field];
                    nameB = b.bill[field];
                }
                else if (id == 'Applications') {
                    nameA = a[field];
                    nameB = b[field];
                }
            	else if(id == 'Endorsement'){
                    nameA = a[field];
                    nameB = b[field];
                }
                else {
                    nameA = a.policy[field];
                    nameB = b.policy[field];
                }


                if (type == 'String') {
                    nameA = nameA ? nameA.toUpperCase(): ''; // ignore upper and lowercase
                    nameB = nameB ? nameB.toUpperCase(): ''; // ignore upper and lowercase
                }
                else if (type == 'Date') {
                    nameA = Date.parse(nameA);
                    nameB = Date.parse(nameB);
                }
                else {
                    nameA = parseFloat(nameA);
                    nameB = parseFloat(nameB);
                }

                if (nameA < nameB) {
                    return sortingType == 'DESC' ? 1 : -1;
                }
                if (nameA > nameB) {
                    return sortingType == 'DESC' ? -1 : 1;
                }
                // names must be equal
                return 0;
            });
            console.log('Billings => ' + items);
            component.set("v.payWrapper", wrapper);
        }
    },
	handleShrink : function(component, event, helper){
		var index = event.currentTarget.dataset.index;
        var row = event.currentTarget.dataset.row;
		var policies = component.get("v.payWrapper.policies");
        if(row === 'Policy'){
            policies[index].isExpended = false;
        }else if(row === 'cvList'){
            policies[index].isCVListExpended = false;
        }
		component.set("v.payWrapper.policies",policies);     
    },
    handleShrinkBilling: function(component, event, helper){
        component.set("v.isBillingExpended",false);
    },
    handleExpandBilling: function(component, event, helper){
        component.set("v.isBillingExpended",true);
    },
	handleExpand : function(component, event, helper){
        var index = event.currentTarget.dataset.index;
		var row = event.currentTarget.dataset.row;
		var policies = component.get("v.payWrapper.policies");
        if(row === 'Policy'){
            policies[index].isExpended = true;
        }else if(row === 'cvList'){
            policies[index].isCVListExpended = true;
        }
		component.set("v.payWrapper.policies",policies);  
    },
   	showPaymentSchedules : function(component, event, helper){
    	var index = event.currentTarget.dataset.index;
        var payWrap = component.get("v.payWrapper");
        component.set("v.BillingPaymentSchedules",payWrap.billings[index].paymentSchedules);
        var popup = component.find('popupID');
        $A.util.addClass(popup, 'openPopup');
        component.set("v.isHeaderFooterModal",true);
        component.set("v.ShowBillingPs",true);
    },
    previewFile : function(component, event, helper){
        var index = event.currentTarget.dataset.index;
        var rowIndx = event.currentTarget.dataset.row;
		var policies = component.get("v.payWrapper.policies");
		let cv = policies[index].cvList[rowIndx];
        let url = policies[index].pdfUrl+cv.cvObj.Id+'&isdtp=vw';
        
        console.log("url => ",url);  
        window.open(url, '_blank');        
    },
    /*downloadFile : function(component, event, helper){
        var spinner = component.find("fullScreenSpinnerId");
        $A.util.addClass(spinner, 'showFullScreenSpinner');
        var id = event.currentTarget.dataset.id;
        var action = component.get("c.downloadContent");
            action.setParams({
                recId: id
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('getDetails State--> ', state);
                if (state === 'SUCCESS') { 
                    console.log('success');
                    var contentVersion = response.getReturnValue();
                    var fileName = contentVersion.Title + '.pdf';
                    var base64Data = contentVersion.VersionData;                
                    var element = document.createElement('a');
                    element.setAttribute('href', 'data:application/pdf;base64,' + base64Data);
                    element.setAttribute('download', fileName);
                    
                    element.style.display = 'none';
                    document.body.appendChild(element);
                    
                    element.click();
                    
                    document.body.removeChild(element);
                }
                else if (state === 'INCOMPLETE') {
                    console.log('incomplete');
                } 
                else if (state === 'ERROR') {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
                $A.util.removeClass(spinner, 'showFullScreenSpinner');
            });
        $A.enqueueAction(action);
    },*/
    logout: function(component, event, helper){
        var wrap = component.get("v.payWrapper");  
        var accountId;
        if (wrap.isAccountId == true) {
            accountId =  wrap.accRecord.Id;
        } else {
            accountId = wrap.billing.AcctSeed__Customer__c;
        }
        var spinner = component.find("fullScreenSpinnerId");
        $A.util.addClass(spinner, 'showFullScreenSpinner');
        var action = component.get("c.logoutAcc");
        action.setParams({
            accId: accountId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state => ', state);
            if (state === 'SUCCESS') {
                location.reload();
            }
            else{
                $A.util.removeClass(spinner, 'showFullScreenSpinner');
            }
        });
        $A.enqueueAction(action);
    },
    handleDeleteLawyer: function(component, event, helper){
        var popup = component.find('popupID');
        $A.util.addClass(popup, 'openPopup');
        let index = event.currentTarget.dataset.index;
        var wrap = component.get("v.payWrapper");
        var lawyers = wrap.policies[index].policy.Policy_Lawyers__r;
        component.set("v.payWrapper.policy",wrap.policies[index].policy);
        component.set("v.policyIndex",index);
        component.set("v.policyLawyers",lawyers);
        component.set("v.isHeaderFooterModal", true);
        component.set("v.showDeleteLawyerModal", true);
	},
    handleCancelPolicy: function(component, event, helper){
        var popup = component.find('popupID');
        $A.util.addClass(popup, 'openPopup');
        let index = event.currentTarget.dataset.index;
        component.set("v.policyIndex",index);
        component.set("v.isHeaderFooterModal", true);
        component.set("v.showCancelPolicyModal", true);
	},
    handleAddLawyer: function(component, event, helper){
        var popup = component.find('popupID');
        $A.util.addClass(popup, 'openPopup');
        let index = event.currentTarget.dataset.index;
        var wrap = component.get("v.payWrapper");
        component.set("v.payWrapper.policy",wrap.policies[index].policy);
        component.set("v.policyIndex",index);
        component.set("v.isHeaderFooterModal", true);
        component.set("v.showAddLawyerModal", true);
	},
    handleCancelDeleteLawyer: function(component, event, helper){
        component.set("v.showDeleteLawyerModal", false);
	},
    handleSaveDeleteLawyer: function(component, event, helper){
        var wrap = component.get("v.payWrapper");
        var lawyers = component.get("v.policyLawyers");
        var effectiveDate = component.get("v.endorsementEffectiveDate");
        var inputCmp = component.find('datefield');
        inputCmp.showHelpMessageIfInvalid();
        var allValid = inputCmp.get('v.validity').valid;
        if(allValid){
            var today = new Date();
            var priorDate = new Date(new Date().setDate(today.getDate() - 30));
            priorDate = new Date(new Date(priorDate).toDateString());
            var effDate = new Date(new Date(effectiveDate).toDateString());
            var flag = false;
            if(effectiveDate && effDate >= priorDate){
                flag = true;
            }
            
            if(!flag){
                helper.closeModalHelper(component, event);
                var popup = component.find('popupID');
                $A.util.addClass(popup, 'openPopup')
                //component.set("v.isHeaderFooterModal", true);
                component.set("v.showErrorModal", true);
            }
            else{
                var radioList = document.getElementsByClassName('selectedLawyer');
                var lawyerIndex;
                for(let x = 0; x < radioList.length; x++){
                    if(radioList[x].checked){
                        lawyerIndex = x;
                    }
                }
                console.log(lawyerIndex);
                var lawyerId;
                if(!isNaN(lawyerIndex)){
                    lawyerId = lawyers[lawyerIndex].Id;
                } 
                console.log(lawyerId);
                if(lawyerId){
                    console.log('Delete Lawyer Calling');
                    var spinner = component.find("fullScreenSpinnerId");
                    $A.util.addClass(spinner, 'showFullScreenSpinner');
                    var otherErrorList = []
                    var emptyFieldErrorList = [];
                    
                    var action = component.get("c.deletePolicyLawyer");
                    action.setParams({
                        policyLawyerId: lawyerId,
                        effectiveDate: effectiveDate
                    });
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        console.log('state => ', state);
                        if (state === 'SUCCESS') {
                            console.log('SUCCESS');
                            var result = response.getReturnValue();
                            component.set("v.payWrapper.policyEndorsements",result);
                            otherErrorList.push('Lawyer Removal Request submitted successfully.');
                            var toastType = 'success';
                            helper.closeModalHelper(component, event);
                        } else if (state === "INCOMPLETE") {
                            var toastType = 'error';
                            otherErrorList.push('Incomplete')
                            
                        } else if (state === "ERROR") {
                            var errors = response.getError();
                            var toastType = 'error';
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    let err = JSON.parse(errors[0].message);
                                    let errorMsg = err.errorMsg;
                                    helper.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                                    console.log("handleSaveDeleteLawyer-> Error message: " + errorMsg);
                                    otherErrorList.push(errorMsg);
                                }
                            } else {
                                otherErrorList.push('Unknown Error');
                                console.log("Unknown error");
                            }
                        }
                        helper.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
                        $A.util.removeClass(spinner, 'showFullScreenSpinner');
                    });
                    $A.enqueueAction(action);
                }
                else{
                    var otherErrorList = [];
                    var emptyFieldErrorList = [];
                    var toastType = 'error';
                    otherErrorList.push('Please select a Lawyer.');
                    helper.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
                }
            }
        }
    },
	handleSaveCancelPolicy: function(component, event, helper){
        var wrap = component.get("v.payWrapper");
        var index = component.get("v.policyIndex");
        var effectiveDate = component.get("v.endorsementEffectiveDate");
        var policyId = wrap.policies[index].policy.Id;
        if(policyId && effectiveDate){
            console.log('Cancel Policy Calling');
            var spinner = component.find("fullScreenSpinnerId");
            $A.util.addClass(spinner, 'showFullScreenSpinner');
            var otherErrorList = []
            var emptyFieldErrorList = [];
            
            var action = component.get("c.cancelPolicy");
            action.setParams({
                policyId: policyId,
                effectiveDate: effectiveDate
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('state => ', state);
                if (state === 'SUCCESS') {
                    console.log('SUCCESS');
                    var result = response.getReturnValue();
                    component.set("v.payWrapper.policyEndorsements",result);
                    otherErrorList.push('Policy cancellation request has been successfully submitted.');
                    var toastType = 'success';
                    helper.closeModalHelper(component, event);
                } else if (state === "INCOMPLETE") {
                    var toastType = 'error';
                    otherErrorList.push('Incomplete')
                    
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    var toastType = 'error';
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            let err = JSON.parse(errors[0].message);
                            let errorMsg = err.errorMsg;
                            helper.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                            console.log("handleSaveCancelPolicy-> Error message: " + errorMsg);
                            otherErrorList.push(errorMsg);
                        }
                    } else {
                        otherErrorList.push('Unknown Error');
                        console.log("Unknown error");
                    }
                }
                helper.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
                $A.util.removeClass(spinner, 'showFullScreenSpinner');
            });
            $A.enqueueAction(action);
        }
    },
    handleFieldChange: function(component, event, helper){
        var endorsement = component.get("v.endorsement");
        endorsement[event.currentTarget.name] = event.currentTarget.value;
        component.set("v.endorsement",endorsement);
    },
    handleSaveAddLawyer: function(component, event, helper){
        var endorsement = {};
		var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            let inputType = inputCmp.get("v.type");
            if(inputType == 'date' && !inputCmp.get("v.value")){
                endorsement[inputCmp.get("v.name")] = null;
            }
            else if(inputType == 'email' && inputCmp.get("v.value")){
                var value = inputCmp.get("v.value");
                
                var emailRegex = /^[a-zA-Z0-9]+([._%+-][a-zA-Z0-9]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[a-zA-Z]{2,6}$/;
                
                if (value && !emailRegex.test(value)) {
                    inputCmp.setCustomValidity("Enter a valid email address, such as name@email.com.");
                    validSoFar = false;
                } else {
                    inputCmp.setCustomValidity(""); 
                    endorsement[inputCmp.get("v.name")] = inputCmp.get("v.value");
                }
                
                inputCmp.reportValidity();
            }
            else{
                endorsement[inputCmp.get("v.name")] = inputCmp.get("v.value");
            }
            // ? inputCmp.get("v.value") : null;
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
		console.log('endorsement => ',endorsement);
	
        if (allValid) {       
            var today = new Date();
            var priorDate = new Date(new Date().setDate(today.getDate() - 30));
            priorDate = new Date(new Date(priorDate).toDateString());
            var effDate = new Date(new Date(endorsement.Endorsement_Effective_Date__c).toDateString());
            var flag = false;
            if(effDate && Date.parse(effDate) >= Date.parse(priorDate)){
                flag = true;
            }
            
            if(!flag){
                helper.closeModalHelper(component, event);
                var popup = component.find('popupID');
                $A.util.addClass(popup, 'openPopup')
                //component.set("v.isHeaderFooterModal", true);
                component.set("v.showErrorModal", true);
            }
            else{
                endorsement.IL_152_Contact_Role__c = component.get("v.contactRole");            
                console.log('endorsement => ',endorsement);
                var spinner = component.find("fullScreenSpinnerId");
                $A.util.addClass(spinner, 'showFullScreenSpinner');
                var otherErrorList = []
                var emptyFieldErrorList = [];
                var wrap = component.get("v.payWrapper");
                var index = component.get("v.policyIndex");
                var policyId = wrap.policies[index].policy.Id;
                var action = component.get("c.addPolicyLawyer");
                action.setParams({
                    policyId: policyId,
                    endorsement: JSON.stringify(endorsement)
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    console.log('state => ', state);
                    if (state === 'SUCCESS') {
                        console.log('SUCCESS');
                        var result = response.getReturnValue();
                        component.set("v.payWrapper.policyEndorsements",result);
                        otherErrorList.push('Add lawyer request has been successfully submitted.');
                        var toastType = 'success';
                        helper.closeModalHelper(component, event);
                    } else if (state === "INCOMPLETE") {
                        var toastType = 'error';
                        otherErrorList.push('Incomplete')
                        
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        var toastType = 'error';
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                let err = JSON.parse(errors[0].message);
                                let errorMsg = err.errorMsg;
                                helper.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                                console.log("handleSaveCancelPolicy-> Error message: " + errorMsg);
                                otherErrorList.push(errorMsg);
                            }
                        } else {
                            otherErrorList.push('Unknown Error');
                            console.log("Unknown error");
                        }
                    }
                    helper.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
                    $A.util.removeClass(spinner, 'showFullScreenSpinner');
                });
                $A.enqueueAction(action);
            }
        }
	},
    handleBlur : function(component, event, helper){
        var inputCmp = event.getSource();
        var value = inputCmp.get("v.value");
        
        var emailRegex = /^[a-zA-Z0-9]+([._%+-][a-zA-Z0-9]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[a-zA-Z]{2,6}$/;
        
        if (value && !emailRegex.test(value)) {
            inputCmp.setCustomValidity("Enter a valid email address, such as name@email.com.");
        } else {
            inputCmp.setCustomValidity(""); 
        }
        
        inputCmp.reportValidity();
	}
})