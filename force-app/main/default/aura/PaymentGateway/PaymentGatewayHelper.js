({
    getDetails: function (component, event, lastTime, isDisable) {
        console.log('lastTime', lastTime);

        var spinner = component.find("fullScreenSpinnerId");
        $A.util.addClass(spinner, 'showFullScreenSpinner');
        if (lastTime != '' && lastTime != undefined) {
            var action = component.get("c.scheduleDetails");
            action.setParams({
                validationString: component.get("v.recordId"),
                sfInternalId: component.get("v.sfInternalId"),
                lasttime: lastTime
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('getDetails State--> ', state);
                if (state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    console.log('getDetails Result--> ', result);
                    if (lastTime == 'FirstTime') {
                        component.set("v.lastTime", result.paymentScheduleVar);
                        component.set("v.tempLastTime", JSON.parse(JSON.stringify(result.paymentScheduleVar)));
                    }
                    console.log('result:', result);

                    console.log('result.lasttime', result.lasttime);
                    // var da = new Date(result.firstInstallmentDate);
                    // console.log('.format:',da);

                    // var day = String(da.getDate()).padStart(2, '0');;
                    // var month = String(da.getMonth() + 1).padStart(2, '0');
                    // var year = da.getFullYear();
                    // var date = `${month}/${day}/${year}`;
                    // component.set("v.firstInstallmentDate",date);
                    // var formattedDate = this.formatDateHelper(result.dueDate);
                    // if(formattedDate){
                    //     result.firstInstallmentDate = formattedDate;
                    // }

                    //Updating bill Balance
                    
                    
                    // commented on April 6 2026 for showing the Unpaid
                    /*if (result.billings) {
                        for (let x of result.billings) {
                            if (x.bill.Payment_Schedules__r) {
                                for (let y of x.bill.Payment_Schedules__r) {
                                    if(y.Status__c == 'Pending'){
                                        x.bill.AcctSeed__Balance__c -= y.Amount__c;
                                        x.bill.AcctSeed__Received_Amount__c += y.Amount__c; 
                                    }
                                    
                                }
                            }
                        }
                    }*/

                    component.set("v.payWrapper", result);
                    if (result != null) {                        
                        if (result.isAccountId == true) {
                            var billingCount = 0;
                            for(let x of result.billings){
                                if(x.bill.AcctSeed__Balance__c > 0){
                                    billingCount+=1;
                                }
                            }
                            
                            var applicationEndorsementCount = 0;
                            applicationEndorsementCount += result.policyEndorsements.length;
                            applicationEndorsementCount += result.applications.length;
                            
                            component.set("v.pendingbillingCount", billingCount);
                            component.set("v.pendingPolicyEndorsCount", applicationEndorsementCount);
                              
                            var type = 'account';
                            this.getContactRole(component, event);
                            this.getTimmerDetails(component, event, result.accRecord.Id, type, result);
                        } else {
                            var type = 'billing'
                            this.getTimmerDetails(component, event, result.billing.AcctSeed__Customer__c, type, result);
                        }
                    }
                    else {
                        component.set("v.isPaymentLoad", false);
                        component.set("v.paymentMessageOnLoad", 'No Record Found');
                    }

                    window.setTimeout(() => {
                        this.changePaymentType(component, result.paymentScheduleVar);
                    }, 600);

                    if (isDisable) {
                        this.disablePayMethod(component, event, result.paymentScheduleVar);
                    }
                } else if (state === 'INCOMPLETE') {
                    component.set("v.isPaymentLoad", false);
                    component.set("v.paymentMessageOnLoad", 'Incomplete');
                } else if (state === 'ERROR') {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            //var errorMsg = errors[0].message;
                            ///let err = JSON.parse(errors[0].message);
                            let errorMsg = errors[0].message;//err.errorMsg;
                            //this.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                            console.log("Error message: " + errorMsg);
                            component.set("v.isPaymentLoad", false);
                            component.set("v.paymentMessageOnLoad", errorMsg);
                        }
                    } else {
                        component.set("v.isPaymentLoad", false);
                        component.set("v.paymentMessageOnLoad", 'Unknown Error');
                    }
                }
                $A.util.removeClass(spinner, 'showFullScreenSpinner');
            });
            $A.enqueueAction(action);
        }
    },
    isPayHelper: function (component, event) {
        console.log('IsPayHelper:')
        component.set("v.savedClick", true);
        var spinner = component.find("fullScreenSpinnerId");
        $A.util.addClass(spinner, 'showFullScreenSpinner');
        // this.getSavedPaymentMethodsList(component, event);
    },

    processPaymentHelper: function (component, event) {
        var wrapper = component.get("v.payWrapper");
        var ipAdd = component.get("v.ipAddress");
        var usrSession = component.get("v.userSession");
        var action = component.get("c.processPayment");
        var popupModalId = component.find("popupID");
        var spinner = component.find("fullScreenSpinnerId");
        let wrpStr = JSON.stringify(wrapper);
        const warpperObjStr = wrpStr.replaceAll('T00:00:00.000Z','');
        console.log('warpperObjStr => ',warpperObjStr); 
        action.setParams({
            warpperObjStr: warpperObjStr,
            ipAddress: ipAdd,
            userSession: usrSession
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            component.set('v.isHeaderFooterModal', false);
            component.set('v.isAddScreen', false);
            component.set('v.isWithoutHeaderFooterModal', true);
            $A.util.addClass(popupModalId, 'smallPopupModal')
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('result: => ', result);
                if (result != 'Error') {
                    $A.util.removeClass(spinner, 'showFullScreenSpinner');
                    wrapper.receiptNumber = result;
                    component.set('v.payWrapper', wrapper);
                    component.set('v.isPaymentSuccess', true);
                    var popup = component.find('popupID');
                    $A.util.removeClass(popup, 'openPopup');
                } else {
                    $A.util.removeClass(spinner, 'showFullScreenSpinner');
                    component.set('v.paymentErrorMessageOnScreen', result);
                    component.set('v.isPaymentError', true);
                }
                // if (result != 'Error') {
                //     $A.util.removeClass(spinner, 'showFullScreenSpinner');
                //     wrapper.receiptNumber = result;
                //     component.set('v.payWrapper', wrapper);
                //     component.set('v.isPaymentSuccess', true);
                // } else {
                //     $A.util.removeClass(spinner, 'showFullScreenSpinner');
                //     component.set('v.paymentErrorMessageOnScreen', result);
                //     component.set('v.isPaymentError', true);
                // }
            } else if (state === 'INCOMPLETE') {
                console.log('incomplete');
                $A.util.removeClass(spinner, 'showFullScreenSpinner');
                component.set('v.paymentErrorMessageOnScreen', 'Incomplete');
                component.set('v.isPaymentError', true);
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        let err = JSON.parse(errors[0].message);
                        let errorMsg = err.errorMsg;
                        this.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                        $A.util.removeClass(spinner, 'showFullScreenSpinner');

                        component.set('v.paymentErrorMessageOnScreen', errorMsg);
                        component.set('v.isPaymentError', true);
                    }
                } else {
                    $A.util.removeClass(spinner, 'showFullScreenSpinner');
                    component.set('v.paymentErrorMessageOnScreen', 'Unknown error');
                    component.set('v.isPaymentError', true);
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    getInvoiceDetails: function (component, event) {
        var action = component.get("c.getInvoiceRecordWithZip");
        action.setParams({
            policyInvNumber: null,
            zip: null,
            sfInternalId: component.get("v.sfInternalId"),
            lastTime: component.get("v.lastTime")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state--> ', state);
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('result--> ', result);
                component.set("v.payWrapper", result);
                component.set("v.wrapperLoad", true);
                // Code when Success
            } else if (state === 'INCOMPLETE') {
                console.log('incomplete');
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
        });
        $A.enqueueAction(action);
    },

    getExpiryOptions: function (component, event) {
        var action = component.get("c.getExpiryDetails");
        action.setParams({});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                var years = result.expYears;
                var months = result.expMonths;
                component.set("v.cardExpiryYearList", years);
                component.set("v.cardExpiryMonthList", months);
                return true;
            } else if (state === 'INCOMPLETE') {
                console.log("Incomplete");
                return false;
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        return false;
                    }
                } else {
                    console.log("Unknown error");
                    return false;
                }
            }
        });
        $A.enqueueAction(action);
    },
    getSavedPaymentMethodsList: function (component, event) {
        var payWrapper = component.get("v.payWrapper");
        if (payWrapper.billing) {
            var spinner = component.find("fullScreenSpinnerId");
            $A.util.addClass(spinner, 'showFullScreenSpinner');

            var action = component.get("c.ExistingList");

            console.log('payWrapper:', payWrapper);
            action.setParams({
                billing: payWrapper.billing
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var result = response.getReturnValue();

                    var savedCardList = result.cardList;
                    console.log('savedCardList:', savedCardList);
                    var savedEcheckList = result.eCheckList;
                    console.log('savedEcheckList:', savedEcheckList);

                    for (let x of savedCardList) {
                        if (x.paymentMethod.Id == payWrapper.paymentMethodId) {
                            component.set("v.isCC", true);
                            break;
                        }
                    }


                    if (savedCardList.length && savedCardList.length == 1 && !savedEcheckList.length) {
                        savedCardList[0].isSetToPay = true;
                    } else if (savedEcheckList.length && savedEcheckList.length == 1 && savedCardList.length) {
                        savedEcheckList[0].isSetToPay = true;
                    }

                    component.set('v.savedCardList', result.cardList);
                    component.set('v.savedEcheckList', result.eCheckList);

                    window.setTimeout(() => {
                        this.dueDateChangeHelper(component, event, 'start');
                        this.picklistPaymentMethodChangeHelper(component, event);
                    }, 1000);

                    var isPay = component.get("v.isPay");
                    var isPayTemp = component.get("v.isPayTemp");
                    // if (isPay == 'true' && isPayTemp == false) {
                    //     var isPaymentFirstTime = component.get("v.isPaymentFirstTime");
                    //     if (!isPaymentFirstTime) {
                    //         var popup = component.find('popupID');
                    //         $A.util.addClass(popup, 'openPopup');
                    //         component.set('v.isHeaderFooterModal', true);
                    //         component.set('v.isAddPaymentMethod', true);

                    //         var itemType = '';
                    //         if (savedCardList.length > 0 && savedCardList[0].isDefault) {
                    //             component.set('v.isAddScreen', true);
                    //             component.set("v.fieldDisabled", true);
                    //             itemType = 'creditCard';
                    //             this.setValuesInAddModal(component, event, 0, itemType);
                    //             $A.util.removeClass(spinner, 'showFullScreenSpinner');
                    //         } else if (savedEcheckList.length > 0 && savedEcheckList[0].isDefault) {
                    //             component.set('v.isAddScreen', true);
                    //             component.set("v.fieldDisabled", true);
                    //             itemType = 'eCheck';
                    //             this.setValuesInAddModal(component, event, 0, itemType);
                    //             $A.util.removeClass(spinner, 'showFullScreenSpinner');
                    //         } else {
                    //             if (savedCardList.length > 0 || savedEcheckList.length > 0) {
                    //             }
                    //             else {
                    //                 var otherErrorList = []
                    //                 otherErrorList.push('There are no Payment Method exist. Please add new one.')
                    //                 var toastType = 'error';
                    //                 var emptyFieldErrorList = [];
                    //                 this.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
                    //             }
                    //             component.set('v.isAddPaymentMethod', false);
                    //             component.set('v.isSavedScreen', true);
                    //             component.set('v.isAddScreen', false);
                    //             this.emptyTheFields(component, event);
                    //             component.set("v.fieldDisabled", false);
                    //             $A.util.removeClass(spinner, 'showFullScreenSpinner');
                    //         }
                    //         component.set("v.isPayTemp", true);
                    //     }
                    // } else {
                    $A.util.removeClass(spinner, 'showFullScreenSpinner');
                    //}
                } else if (state === 'INCOMPLETE') {
                    console.log('incomplete:', incomplete);
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
            });
            $A.enqueueAction(action);
        }
    },

    saveNewPaymentSchedules: function (component, event, callGetDetail) {
        var action = component.get("c.savePaymentSchedules");
        var payWrapp = component.get("v.payWrapper");
        action.setParams({
            warpperObj: payWrapp
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                if(result){
                    // Code when Success
                    component.set("v.payWrapper", result);
                    component.set("v.lastTime", result.paymentScheduleVar);
                    console.log('mytest->', result.paymentScheduleVar)
                    if (callGetDetail) {
                        this.getDetails(component, event, result.paymentScheduleVar, true);
                    }
                    else{
                        this.processPaymentHelper(component, event);
                    } 
                }
                else{
                    var spinner = component.find("fullScreenSpinnerId");
					$A.util.removeClass(spinner, 'showFullScreenSpinner');
                    //wrapper.receiptNumber = result;
                    //component.set('v.payWrapper', wrapper);
                    component.set('v.isPaymentSuccess', true);
                    var popup = component.find('popupID');
                    $A.util.removeClass(popup, 'openPopup');                    
                }
                return true;
            } else if (state === 'INCOMPLETE') {
                // Code when Imcomplete
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        let err = JSON.parse(errors[0].message);
                        let errorMsg = err.errorMsg;
                        this.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                        console.log("Error message: " + errorMsg);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    getCreditCardType: function (cardNumber_input) {
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
                visa: /^4[0-9]{12}(?:[0-9]{3})?$/,
                MasterCard: /^5[1-5][0-9]{14}$/,
                amex: /^3[47][0-9]{13}$/,
                //diners: /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/,
                Discover: /^6(?:011|5[0-9]{2})[0-9]{12}$/
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
    compareCardNumberAndType: function (cardNumber_input, cardType) {
        if (cardNumber_input.value != '' && cardType.value != 'none') {
            var cardNumber = cardNumber_input.value;
            cardNumber = cardNumber.split(' ').join("");
            var o = {
                //electron: /^(4026|417500|4405|4508|4844|4913|4917)\d+$/,
                //maestro: /^(5018|5020|5038|5612|5893|6304|6759|6761|6762|6763|0604|6390)\d+$/,
                //dankort: /^(5019)\d+$/,
                //interpayment: /^(636)\d+$/,
                //unionpay: /^(62|88)\d+$/,
                visa: /^4[0-9]{12}(?:[0-9]{3})?$/,
                MasterCard: /^5[1-5][0-9]{14}$/,
                amex: /^3[47][0-9]{13}$/,
                //diners: /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/,
                Discover: /^6(?:011|5[0-9]{2})[0-9]{12}$/
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
    isCardNumberValid: function (cardNumber_input) {
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
    isCVVValid: function (component, cardCvv, cardType) {
        var cvvNumber = cardCvv.value;
        var ccType = cardType.value;
        var isDisbled = component.get("v.fieldDisabled");
        if (isDisbled) {
            if (ccType != 'none') {
                let cvv = cvvNumber.toString();
                if (ccType === 'americanExpress') {
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
                if (ccType === 'americanExpress') {
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
    isExpiryValid: function (cardExpiryMonth, cardExpiryYear) {
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
                    cardExpiryMonth.className = '';
                    cardExpiryYear.className = '';
                    return '';
                }
            } else {
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
    isConfirmationEmailValid: function (securityMail) {
        if (securityMail.value != '') {
            var email = securityMail.value;
            var mailformat = /^[a-zA-Z0-9][a-zA-Z0-9._%+-]*[a-zA-Z0-9]@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[a-zA-Z]{2,6}$/;
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
    isFieldEmpty: function (input) {
        if (input.value == '') {
            input.className = 'errorInput';
            return input.name;
        } else {
            input.className = '';
            return '';
        }
    },
    isCheckAccountTypeValid: function (input) {
        if (input.value != 'none') {
            input.className = '';
            return '';
        } else {
            input.className = 'errorInput';
            return input.name;
        }
    },
    isCheckAccountNumberValid: function (input) {
        if (input.value && !isNaN(input.value) && input.value.length > 3 && input.value.length < 18) {
            input.className = '';
            return '';
        } else {
            input.className = 'errorInput';
            return input.name;
        }
    },
    isCheckRoutingNumberValid: function (input) {
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
    showCardNumberOnDisplayCard: function (number) {
        var temp = '';
        for (var i = number.length; i < 4; i++) {
            temp += '-';
        }
        return number + temp;
    },
    changePaymentType: function (cmp, clicked) {
        /*var getEle = cmp.find('payment-type');
        if (getEle) {
            for (var i in getEle) {
                var temp = getEle[i].getElement().getAttribute('data-id');
                if (clicked != temp) {
                    $A.util.addClass(getEle[i], 'itemBox');
                    $A.util.removeClass(getEle[i], 'isActiveSpan');
                    $A.util.removeClass(getEle[i], 'itemBoxDisable');
                } else {
                    var payWrap = cmp.get('v.payWrapper');
                    payWrap.paymentScheduleVar = temp;
                    cmp.set("v.payWrapper", payWrap);
                    $A.util.removeClass(getEle[i], 'itemBoxDisable');
                    $A.util.addClass(getEle[i], 'itemBox');
                    $A.util.addClass(getEle[i], 'isActiveSpan');
                }
            }
        } else {
            console.error('Error: Payment type not found!');
        }*/
    },
    changeListType: function (cmp, clicked) {
        var getEle = cmp.find('list-type');
        for (var i in getEle) {
            var temp = getEle[i].getElement().getAttribute('data-id');
            if (clicked != temp) {
                //$A.util.addClass(getEle[i], 'itemBox');
                $A.util.removeClass(getEle[i], 'isActiveSpan');
                //$A.util.removeClass(getEle[i], 'itemBoxDisable');
            } else {
                //$A.util.removeClass(getEle[i], 'itemBoxDisable');
                //$A.util.addClass(getEle[i], 'itemBox');
                $A.util.addClass(getEle[i], 'isActiveSpan');
            }
        }
    },
    showToast: function (component, emptyFieldErrorList, otherErrorList, toastType) {
        var toastDiv = component.find("toastId");
        $A.util.addClass(toastDiv, 'showToast');
        var errorToastmsg = [];

        if (emptyFieldErrorList.length) {
            var fieldNames = 'Please fill the ';
            for (var i = 0; i < emptyFieldErrorList.length; i++) {
                if (i != (emptyFieldErrorList.length - 1)) {
                    fieldNames += emptyFieldErrorList[i] + ', ';
                } else {
                    fieldNames += emptyFieldErrorList[i];
                }
            }
            if (emptyFieldErrorList.length == 1) {
                fieldNames += ' field.';
            } else {
                fieldNames += ' fields.';
            }
            errorToastmsg.push(fieldNames);
        }
        if (otherErrorList != undefined) {
            if (otherErrorList.length) {
                for (var i = 0; i < otherErrorList.length; i++) {
                    errorToastmsg.push(otherErrorList[i]);
                }
            }
        }
        if (toastType == 'error') {
            component.set("v.isToastPaymentError", true);
        } else if (toastType == 'success') {
            component.set("v.isToastPaymentSuccess", true);
        }

        if (errorToastmsg) {
            component.set("v.paymentToastMessage", errorToastmsg);
            // console.log('toast: ',component.get('v.errorToastmsg'));
            setTimeout(() => {
                $A.util.removeClass(toastDiv, 'showToast');
                component.set("v.isToastPaymentError", false);
                component.set("v.isToastPaymentSuccess", false);
            }, 4000);
        }
    },
    emptyTheFields: function (component, eve) {
        component.set('v.cardFirstFour', '----');
        component.set('v.cardSecondFour', '----');
        component.set('v.cardThirdFour', '----');
        component.set('v.cardFourthFour', '----');
        component.set('v.cardExpiryMonth', '--');
        component.set('v.cardExpiryYear', '----');
        component.set('v.cardHolderName', 'Name on Card');
        component.set('v.cardType', 'none');
        component.set('v.cardCvv', 'XXX');
        var payWrap = component.get("v.payWrapper");
        payWrap.cardTypeVar = 'none';
        payWrap.cardNumber = '';
        payWrap.expireMonth = '';
        payWrap.expireYear = '';
        payWrap.nameOnCard = '';
        payWrap.verificationNumber = '';
        payWrap.payMethodToken = '';
        payWrap.paymentMethodId = '';
        payWrap.routingNumber ='';
        payWrap.accountNumber ='';
        payWrap.accountType ='';
        payWrap.accountHolderName ='';
        component.set("v.payWrapper", payWrap);
    },
    disablePayMethod: function (component, event, tempLastTime) {
        var payWrap = component.get('v.payWrapper');
        payWrap.paymentScheduleVar = tempLastTime;
        component.set("v.payWrapper", payWrap);

        var itemBox = component.find("payment-type");
        if (itemBox) {

            for (var i = 0; i < 3; i++) {
                var temp = itemBox[i].getElement().getAttribute('data-id');
                if (temp == tempLastTime) {
                    $A.util.removeClass(itemBox[i], "itemBoxDisable");
                    $A.util.addClass(itemBox[i], "itemBox");
                    $A.util.addClass(itemBox[i], "isActiveSpan");
                } else {
                    $A.util.addClass(itemBox[i], "itemBoxDisable");
                    $A.util.removeClass(itemBox[i], "itemBox");
                    $A.util.removeClass(itemBox[i], "isActiveSpan");
                }
            }
        } else {
            console.error('Error: Payment type not found!');
        }

    },
    onlyForDisable: function (component, clicked) {
        // document.getElementById(clicked).classList = 'isActiveSpan itemBox normalHeading mediumPadding dflexcen dflexfo';
    },
    // getLinkHelper: function (component, emailId) {
    //     var spinner = component.find("fullScreenSpinnerId");
    //     var emptyFieldErrorList = [];
    //     var otherErrorList = [];
    //     var toastType = '';
    //     var action = component.get("c.getAccountId");
    //     action.setParams({
    //         emailId: emailId
    //     });
    //     action.setCallback(this, function (response) {
    //         var state = response.getState();
    //         console.log('state:', state);
    //         if (state === "SUCCESS") {
    //             var result = response.getReturnValue();
    //             console.log('result:', result);
    //             component.set("v.timmerInfo", result);
    //             component.set("v.minutes", parseInt(result.timerShowBefore));
    //             var timmerStarted =  parseInt(result.totalTimeOfTimer) - parseInt(result.timerShowBefore)*60000;
    //             window.setTimeout(component.set("v.timmerStarted", true),timmerStarted);
    //             // if (result == true) {
    //             console.log('success:');
    //             toastType = 'success';
    //             otherErrorList.push(result.baseUrl);
    //             // } else {
    //             //     console.log('error:');
    //             //     toastType = 'error';
    //             //     otherErrorList.push(result);
    //             // }
    //         } else if (state === "INCOMPLETE") {
    //             toastType = 'error';
    //             otherErrorList.push('INCOMPLETE');
    //         } else if (state === "ERROR") {
    //             var errors = response.getError();
    //             if (errors) {
    //                 if (errors[0] && errors[0].message) {
    //                     console.log("Error message: " + errors[0].message);
    //                     toastType = 'error';
    //                     otherErrorList.push(errors[0].message);
    //                 }
    //             } else {
    //                 console.log("Unknown error");
    //             }
    //         }
    //         this.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
    //         $A.util.removeClass(spinner, 'showFullScreenSpinner');
    //     });
    //     $A.enqueueAction(action);
    // },
    getLinkHelper: function (component, emailId) {
        var spinner = component.find("fullScreenSpinnerId");
        var emptyFieldErrorList = [];
        var otherErrorList = [];
        var toastType = '';
        var action = component.get("c.getAccountId");
        action.setParams({
            emailId: emailId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //console.log('result:', result);
                component.set("v.isLink", false);
                console.log('success:');
                toastType = 'success';
                //otherErrorList.push(result);
                otherErrorList.push('Please find the access link in the email you provided.');
                this.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
                $A.util.removeClass(spinner, 'showFullScreenSpinner');

            } else if (state === "INCOMPLETE") {
                toastType = 'error';
                otherErrorList.push('INCOMPLETE');
                this.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
                $A.util.removeClass(spinner, 'showFullScreenSpinner');

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        toastType = 'error';
                        otherErrorList.push(errors[0].message);
                        this.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
                        $A.util.removeClass(spinner, 'showFullScreenSpinner');
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    isModifyOrPayHelper: function (component, event, billid, buttonClick, tab) {
        var payWrapper = component.get("v.payWrapper");
        var siteUrl = payWrapper.siteUrl;
        // this.getInvoiceDetails(component, event);
        var spinner = component.find("fullScreenSpinnerId");

        var action = component.get("c.processEncryption");
        action.setParams({
            name: billid,
            key: null
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result:', result);
                if (result != undefined || result != '') {
                    $A.util.removeClass(spinner, 'showFullScreenSpinner');
                    var link = siteUrl + '?id=' + encodeURIComponent(result) + buttonClick;
                    window.open(link, tab);
                } else {
                    console.log('Link is empty:');
                }
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete:');

            } else if (state === "ERROR") {
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
    },
    setValuesInAddModal: function (component, event, itemIndex, itemType) {
        var spinner = component.find("fullScreenSpinnerId");
        var payWrap = component.get("v.payWrapper");

        var tabVal = '';
        if (itemType == 'creditCard') {
            tabVal = '1';
            var isExpriryDetailsFetch = this.getExpiryOptions(component, event);
            if (!isExpriryDetailsFetch) {
                var list = component.get("v.savedCardList");
                var itemValues = list[itemIndex];
                payWrap.cardTypeVar = itemValues.cardTypeVar;
                payWrap.cardNumber = itemValues.cardNumber;
                payWrap.expireMonth = itemValues.expireMonth;
                payWrap.expireYear = itemValues.expireYear;
                payWrap.nameOnCard = itemValues.nameOnCard;
                payWrap.verificationNumber = itemValues.verificationNumber;
                payWrap.payMethodToken = itemValues.payMethodToken;
                payWrap.paymentTypeVar = 'creditCard';
                payWrap.paymentMethodId = itemValues.paymentMethod.Id;
                payWrap.isAutoPay = itemValues.isDefault;

                component.set("v.payWrapper", payWrap);
                component.set("v.dataType", 'text');
                component.set("v.checkValidCVV", true);
                component.set("v.checkValidCardNumber", true);

                var typedCardNumber = component.get('v.payWrapper.cardNumber');
                component.set('v.cardCvv', component.get('v.payWrapper.verificationNumber'));
                component.set('v.cardHolderName', component.get('v.payWrapper.nameOnCard'));
                component.set('v.cardExpiryMonth', component.get('v.payWrapper.expireMonth'));
                component.set('v.cardExpiryYear', component.get('v.payWrapper.expireYear'));
                component.set('v.cardType', component.get('v.payWrapper.cardTypeVar'));
                component.set('v.cardFirstFour', this.showCardNumberOnDisplayCard(typedCardNumber.slice(0, 4)));
                component.set('v.cardSecondFour', this.showCardNumberOnDisplayCard(typedCardNumber.slice(4, 8)));
                component.set('v.cardThirdFour', this.showCardNumberOnDisplayCard(typedCardNumber.slice(8, 12)));
                component.set('v.cardFourthFour', this.showCardNumberOnDisplayCard(typedCardNumber.slice(12, 16)));
            } else {
                var emptyFieldErrorList = [];
                var otherErrorList = [];
                otherErrorList.push('Error in getting expiry details.');
                var toastType = 'error';
                this.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
                $A.util.removeClass(spinner, 'showFullScreenSpinner');
            }

        } if (itemType == 'eCheck') {
            tabVal = '2';
            var list = component.get("v.savedEcheckList");
            var itemValues = list[itemIndex];
            payWrap.accountType = itemValues.accountType;
            payWrap.accountNumber = itemValues.accountNumber;
            payWrap.routingNumber = itemValues.routingNumber;
            payWrap.accountHolderName = itemValues.accountHolderName;
            payWrap.payMethodToken = itemValues.payMethodToken;
            payWrap.paymentTypeVar = 'check';
            payWrap.paymentMethodId = itemValues.paymentMethod.Id;

            component.set("v.payWrapper", payWrap);
        }
        component.set('v.isSavedScreen', false);
        component.set('v.isAddScreen', true);
        var currentTab = 'tab-' + tabVal;
        for (var i = 1; i <= 2; i++) {
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
        $A.util.removeClass(spinner, 'showFullScreenSpinner');

    },

    savePaymentMethodHelper: function (component, event) {
        var spinner = component.find("fullScreenSpinnerId");
        var ipAdd = component.get("v.ipAddress");

        var wrapper = component.get("v.payWrapper");
        var flag = true;

        var cards = component.get("v.savedCardList");
        var eCheck = component.get("v.savedEcheckList");
        var otherErrorList = [];
        var emptyFieldErrorList = [];

        var key = '';
        var msg = '';
        if (wrapper.paymentTypeVar == 'creditCard') {
            key = (wrapper.cardTypeVar).toLowerCase() + ' ' + (wrapper.cardNumber).slice(wrapper.cardNumber.length - 4);
        }
        else if (wrapper.paymentTypeVar == 'check') {
            key = (wrapper.accountType).toLowerCase() + ' ' + (wrapper.accountNumber).slice(wrapper.accountNumber.length - 4);
        }
        for (let x of cards) {
            if (x.key == key) {
                flag = false;
                msg = 'You cannot add an Exesting Card.';
            }
        }
        for (let x of eCheck) {
            if (x.key == key) {
                flag = false;
                msg = 'You cannot add an Exesting eCheck.';
            }
        }

        if (flag) {
            var action = component.get("c.savePaymentMethod");
            console.log('saveeewrapper:', wrapper);
            action.setParams({
                wrapperObj: wrapper,
                ipAddress: ipAdd
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('savePaymentMethod: state:', state);

                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result) {
                        console.log('savePaymentMethod: result:', result);
                        wrapper.payMethodToken = result.token;

                        component.set("v.wrapper", wrapper);
                        this.getSavedPaymentMethodsList(component, event);

                        // this.picklistPaymentMethodChangeHelper(component, event);
                        otherErrorList.push('Payment method is successfully saved.')
                        var toastType = 'success';
                        component.set('v.isAddScreen', false);
                        component.set('v.isSavedScreen', true);

                    }
                } else if (state === "INCOMPLETE") {
                    var toastType = 'error';
                    otherErrorList.push('Incomplete')

                    console.log('savePayment: Incomplete:');
                } else if (state === "ERROR") {
                    var toastType = 'error';
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            let err = JSON.parse(errors[0].message);
                            let errorMsg = err.errorMsg;
                            this.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                            console.log("savePayment--> Error message: " + errorMsg);
                            otherErrorList.push(errorMsg);
                        }
                    } else {
                        otherErrorList.push("Unknown error");
                        console.log("savePayment: Unknown error");
                    }
                }
                this.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
                $A.util.removeClass(spinner, 'showFullScreenSpinner');
            });
            $A.enqueueAction(action);
        }
        else {
            otherErrorList.push(msg);
            this.showToast(component, emptyFieldErrorList, otherErrorList, 'error');
            $A.util.removeClass(spinner, 'showFullScreenSpinner');
        }
    },

    updatePaymentMethodHelper: function (component, event) {
        var action = component.get("c.updatePaymentMethod");
        var wrapper = component.get("v.payWrapper");
        console.log('updatePaymentMethodHelper--> wrapper:', wrapper);
        var spinner = component.find("fullScreenSpinnerId");
        $A.util.addClass(spinner, 'showFullScreenSpinner');
        action.setParams({
            wrapperObj: wrapper
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var otherErrorList = []
            var emptyFieldErrorList = [];
            console.log('updatePaymentMethodHelper state:', state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result == 'success') {
                    console.log('updatePaymentMethodHelper result:', result);
                    this.getSavedPaymentMethodsList(component, event);
                    // this.picklistPaymentMethodChangeHelper(component, event);
                    otherErrorList.push('Payment method is successfully updated.')
                    var toastType = 'success';
                    component.set('v.isAddScreen', false);
                    component.set('v.isSavedScreen', true);
                }
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
                        this.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                        console.log("updatePaymentMethodHelper-> Error message: " + errorMsg);
                        otherErrorList.push(errorMsg);
                    }
                } else {
                    otherErrorList.push('Unknown Error');
                    console.log("Unknown error");
                }
            }
            this.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
            $A.util.removeClass(spinner, 'showFullScreenSpinner');
        });
        $A.enqueueAction(action);
    },

    deleteSavedItemHelper: function (component, event) {
        component.set("v.isConfirmationDelete", true);
        var spinner = component.find("fullScreenSpinnerId");
        var smallpopup = component.find('popupSmallID');
        $A.util.addClass(smallpopup, 'openPopup');
        $A.util.addClass(spinner, 'showFullScreenSpinner');
        var wrapper = component.get("v.payWrapper");

        console.log('deleteSavedItemHelper--> wrapper: ', component.get("v.payWrapper"))

        var action = component.get("c.deletePaymentMethod");
        action.setParams({
            wrapperObj: wrapper
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var otherErrorList = []
            var emptyFieldErrorList = [];

            console.log('deleteSavedItemHelper state:', state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.isConfirmationDelete", false);
                console.log('result:', result);
                otherErrorList.push('Payment method is deleted.')
                var toastType = 'success';
                this.getSavedPaymentMethodsList(component, event);
                // this.picklistPaymentMethodChangeHelper(component, event);

            } else if (state === "INCOMPLETE") {
                console.log('deleteSavedItemHelper--> Incomplete:');
                component.set("v.isConfirmationDelete", false);
                otherErrorList.push('Incomplete.')
                var toastType = 'error';
            } else if (state === "ERROR") {
                var errors = response.getError();
                var toastType = 'error';
                if (errors) {
                    component.set("v.isConfirmationDelete", false);
                    if (errors[0] && errors[0].message) {
                        let err = JSON.parse(errors[0].message);
                        let errorMsg = err.errorMsg;
                        this.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                        console.log("deleteSavedItemHelper--> Error message: " + errorMsg);
                        otherErrorList.push(errorMsg);
                    }
                } else {
                    otherErrorList.push("Unknown error");
                    console.log("deleteSavedItemHelper--> Unknown error");
                }
            }
            this.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
            $A.util.removeClass(spinner, 'showFullScreenSpinner');
        });
        $A.enqueueAction(action);
    },

    addScreenHelper: function (component, event, from) {
        // console.log('wrrrr', component.get("v.payWrapper"))
        var spinner = component.find("fullScreenSpinnerId");
        component.set("v.checkValidCVV", false);
        component.set("v.checkValidCardNumber", false);
        var isExpriryDetailsFetch = this.getExpiryOptions(component, event);
        if (from == 'addButton') {
            this.emptyTheFields(component, event);
        }
        if (!isExpriryDetailsFetch) {
            //component.set("v.isAddPaymentMethod", false);
            component.set('v.isSavedScreen', false);
            component.set('v.isAddScreen', true);

        } else {
            var emptyFieldErrorList = [];
            var otherErrorList = [];
            otherErrorList.push('Error in getting expiry details.');
            var toastType = 'error';
            this.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
        }
        $A.util.removeClass(spinner, 'showFullScreenSpinner');
    },

    closeModalHelper: function (component, event) {
        component.set('v.isHeaderFooterModal', false);
        component.set('v.currentActiveTab', 'tab-2');
        component.set('v.isAddScreen', false);
        component.set('v.isSavedScreen', false);
        component.set('v.isPaymentError', false);
        component.set('v.showDeleteLawyerModal', false);
        component.set('v.showErrorModal', false);
        component.set('v.showAddLawyerModal', false);
        component.set('v.showCancelPolicyModal', false);
        component.set('v.isPaymentSuccess', false);
        component.set("v.fieldDisabled", false);
        component.set("v.savedClick", false);
        component.set("v.backToHomeScreen", false);
        component.set("v.ShowBillingPs", false);
        this.emptyTheFields(component, event);
        var popup = component.find('popupID');
        $A.util.removeClass(popup, 'openPopup');
        component.set("v.AddFromMainScreen", false);
        component.set("v.isAddPaymentMethod", false);
    },

    picklistPaymentMethodChangeHelper: function (component, event) {
        /*var timeOut = component.get("v.isTimeOut");
        if (!timeOut) {
            var selectMethodVal = document.getElementById('picklistPaymentMethod').value;
            // if(selectMethod){
            //     selectMethodVal = selectMethod.value
            // }
            var payBut = component.find("payBut");
            var payWrapp = component.get("v.payWrapper");
            var enablePaymentDate = payWrapp.enablePaymentDate;
            var isDueDateValid = component.get("v.isDueDateValid");
            var flag = true;

            flag = enablePaymentDate ? (!isDueDateValid ? false : true) : true;
            console.log('flag:', flag);
            
            let savedCardsList = component.get('v.savedCardList'); 
            console.log('savedCardsList => ',savedCardsList);
            let flag1= false;
            
            for(let x of savedCardsList){
                console.log(x.paymentMethod.Id+'==> '+x.paymentMethod);
                if(x.paymentMethod.Id == selectMethodVal){
                    flag1 = true;
                }                
            }  
            component.set("v.isCC", flag1);
            
            if (selectMethodVal != 'none' && selectMethodVal != undefined && flag) {
                component.set("v.isPayButDisable", false);
                
                //$A.util.removeClass(payBut, "disableBut");
            	
                payWrapp.paymentMethodId = selectMethodVal;
                component.set("v.payWrapper", payWrapp);
                console.log('payWrapp-->>>:', component.get("v.payWrapper"));
            } else {
                //$A.util.addClass(payBut, "disableBut");
                component.set("v.isPayButDisable", true);
                
            }
        }*/
        var timeOut = component.get("v.isTimeOut");
        if (!timeOut) {
            var allList = component.find('picklistPaymentMethod');
            console.log('allList:', allList);
            var selectMethodVal = '';
            if (allList && allList.length > 0) {
                for (var i = 0; i < allList.length; i++) {
                    console.log('i-> checked ', allList[i].getElement().checked);
                    console.log('i-> dataset ', allList[i].getElement().dataset.id);
                    if (allList[i].getElement().checked) {
                        selectMethodVal = allList[i].getElement().dataset.id;
                    }
                }
            }
            else if (allList) {
                if (allList.getElement().checked) {
                    selectMethodVal = allList.getElement().dataset.id;
                }
            }
            console.log('final:', selectMethodVal);
            let savedCardsList = component.get('v.savedCardList');
            console.log('savedCardsList => ', savedCardsList);

            var payBut = component.find("payBut");
            var payWrapp = component.get("v.payWrapper");
            var enablePaymentDate = payWrapp.enablePaymentDate;
            var isDueDateValid = component.get("v.isDueDateValid");
            var flag = true;

            flag = enablePaymentDate ? (!isDueDateValid ? false : true) : true;
            console.log('flag:', flag);

            let flag1 = false;
            for (let x of savedCardsList) {
                console.log(x.paymentMethod.Id + '==> ' + x.paymentMethod);
                if (x.paymentMethod.Id == selectMethodVal) {
                    flag1 = true;
                }
            }

            component.set("v.isCC", flag1);

            if (selectMethodVal != "" && selectMethodVal != 'none' && selectMethodVal != undefined) { // && flag
                component.set("v.isPayButDisable", false);

                //$A.util.removeClass(payBut, "disableBut");

                payWrapp.paymentMethodId = selectMethodVal;
                component.set("v.payWrapper", payWrapp);
                console.log('payWrapp-->>>:', component.get("v.payWrapper"));
            } else {
                //$A.util.addClass(payBut, "disableBut");
                component.set("v.isPayButDisable", true);

            }
        }
    },

    getTimmerDetails: function (component, event, accountId, type, result) {
        console.log('getTimmerDetails called');
        var otherErrorList = [];
        var emptyFieldErrorList = [];
        var toastType = '';
        var spinner = component.find("fullScreenSpinnerId");
        $A.util.addClass(spinner, 'showFullScreenSpinner');
        var action = component.get("c.getTimmerInfo");
        action.setParams({
            accId: accountId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state => ', state);
            if (state === 'SUCCESS') {
                var currentresult = response.getReturnValue();
                var flag = false;
                console.log('result.totalTimeOfTimer:', currentresult.totalTimeOfTimerMinutes);
                console.log('currentresult.timerShowBefore:', currentresult.timerShowBefore);
                if ((parseInt(currentresult.totalTimeOfTimerMinutes) == 0 && parseInt(currentresult.totalTimeOfTimerSeconds) <= 0) || parseInt(currentresult.totalTimeOfTimerMinutes) < 0) {
                    component.set("v.isTimeOut", true);
                    flag = true;
                    this.redirectToLoginScreenHelper(component, event);
                }
                else if (parseInt(currentresult.totalTimeOfTimerMinutes) > parseInt(currentresult.timerShowBefore)) {
                    component.set("v.minutes", parseInt(currentresult.timerShowBefore));
                    console.log('time => ', parseFloat(currentresult.totalTimeOfTimerMinutes + '.' + currentresult.totalTimeOfTimerSeconds));
                    var timmerStarted = (parseFloat(currentresult.totalTimeOfTimerMinutes + '.' + currentresult.totalTimeOfTimerSeconds) - parseFloat(currentresult.timerShowBefore)) * 60000 + (parseInt(currentresult.totalTimeOfTimerSeconds) * 1000);
                    console.log('timmerStarted', timmerStarted);
                    var tOut = setTimeout(function () {
                        clearTimeout(tOut);
                        console.log("TimeOutEnded");
                        component.set("v.timmerStarted", true);
                    }, timmerStarted);
                }
                else if (parseFloat(currentresult.totalTimeOfTimerMinutes + '.' + currentresult.totalTimeOfTimerSeconds) < parseFloat(currentresult.timerShowBefore)) {
                    component.set("v.minutes", parseInt(currentresult.totalTimeOfTimerMinutes));
                    component.set("v.seconds", parseInt(currentresult.totalTimeOfTimerSeconds));
                    component.set("v.timmerStarted", true);
                }

                if (!flag) {
                    component.set("v.wrapperLoad", true);
                    component.set("v.isPaymentLoad", true);
                    if (type == 'account') {
                        console.log('this is account:');
                        component.set("v.isAccount", true);
                        // var popupModalId = component.find("popupID");
                        // $A.util.removeClass(popupModalId, 'openPopup');
                        // $A.util.removeClass(popupModalId, 'smallPopupModalTwo');
                        component.set("v.isEnterEmail", false);
                        $A.util.removeClass(spinner, 'showFullScreenSpinner');
                    }
                    else {

                        // this.getSavedPaymentMethodsList(component, event);
                        if (component.get("v.lastTime") == 'FirstTime') {
                            window.setTimeout(() => {
                                if (newLastTime != undefined || newLastTime != null) {
                                    this.onlyForDisable(component, newLastTime);
                                }
                            }, 1000);
                        }
                        component.set("v.lastTime", result.paymentScheduleVar);

                        // var da = new Date(result.dueDate);
                        // console.log('.format:',da);
                        // var day = String(da.getDate()).padStart(2, '0');;
                        // var month = String(da.getMonth() + 1).padStart(2, '0');
                        // var year = da.getFullYear();
                        // var date = `${month}/${day}/${year}`;

                        // console.log('result.dueDate:', date);
                        // component.set("v.tempEffectiveDate", date);
                        var formattedDate = this.formatDateHelper(result.dueDate, 'MM/DD/YYYY');
                        if (formattedDate) {
                            component.set("v.tempEffectiveDate", formattedDate);
                        }


                        if (result.oldPaymentSchedule != null) {
                            component.set("v.isPaymentFirstTime", false);
                            component.set("v.oldPaymentSchedule", result.oldPaymentSchedule.allPaymentSchedules);
                            component.set("v.oldPaymentScheduleFields", result.oldPaymentSchedule.paymentScheduleFields);
                            console.log('paymentSchedules:', result.oldPaymentSchedule.paymentSchedules);
                            console.log('paymentScheduleFields:', result.oldPaymentSchedule.paymentScheduleFields);
                            var newLastTime = result.paymentScheduleVar;
                        }
                        var isPay = component.get("v.isPay");
                        var isModifySchedules = component.get("v.isModifySchedules");
                        var isModifyPaymentMethod = component.get("v.isModifyPaymentMethod");

                        var isPayTemp = component.get("v.isPayTemp");
                        var isModifySchedulesTemp = component.get("v.isModifySchedulesTemp");
                        var isModifyPaymentMethodTemp = component.get("v.isModifyPaymentMethodTemp");

                        if (isPay == 'true' && !isPayTemp) {
                            // this.isPayHelper(component, event);
                            // component.set("v.savedClick", true);
                            // var spinner = component.find("fullScreenSpinnerId");
                            $A.util.addClass(spinner, 'showFullScreenSpinner');
                        }
                        else if ((isModifySchedules == 'true') && !isModifySchedulesTemp) {
                            this.isModifySchedules(component, event);
                        } else if (isModifyPaymentMethod == 'true' && !isModifyPaymentMethodTemp) {
                            this.isModifyPaymentMethod(component, event);
                        }
                        else {
                            $A.util.removeClass(spinner, 'showFullScreenSpinner');
                        }
                    }
                }
            } else if (state === 'INCOMPLETE') {
                otherErrorList.push('Incomplete.')
                toastType = 'error';
                this.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
            } else if (state === 'ERROR') {
                var errors = response.getError();
                toastType = 'error';
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        let err = JSON.parse(errors[0].message);
                        let errorMsg = err.errorMsg;
                        this.sendErrorEmail(component, err.errorEmailSubject, err.errorEmailBody);
                        console.log("getTimmerDetails--> Error message: " + errorMsg);
                        otherErrorList.push(errorMsg);
                    }
                } else {
                    otherErrorList.push("Unknown error");
                    console.log("getTimmerDetails--> Unknown error");
                }
                this.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
            }
            $A.util.removeClass(spinner, 'showFullScreenSpinner');
        });
        $A.enqueueAction(action);
    },
    changeTime: function (component, event) {
        // console.log("changeTime called => ");
        component.set("v.timeAfterTimerStarted", parseInt(component.get("v.timeAfterTimerStarted")) + 1);
    },
    timeOutHelper: function (component, event) {
        component.set("v.isTimeOut", true);
        this.redirectToLoginScreenHelper(component, event);
    },

    redirectToLoginScreenHelper: function (component, event) {
        var payWrapper = component.get("v.payWrapper");
        var siteUrl = payWrapper.siteUrl;
        // setTimeout(siteUrl, 5000);
        window.setTimeout(() => {
            window.open(siteUrl, "_self");
        }, 3000);
    },
    closeToastButHelper: function (component, event) {
        console.log('closeeeee:');
        var toastDiv = component.find("toastId");
        $A.util.removeClass(toastDiv, 'showToast');
        component.set("v.fieldDisabled", false);
    },

    rs_expandRowHelper: function (component, event, index) {
        var paywrap = component.get("v.payWrapper");
        paywrap.billings[index].isExpended = !(paywrap.billings[index].isExpended);
        component.set("v.payWrapper", paywrap);

        var allRows = component.find('hiddenDetails');
        console.log('allRows ', allRows);
        for (var i = 0; i < allRows.length; i++) {
            var val = allRows[i].getElement().getAttribute('data-index');
            if (val == index && paywrap.billings[index].isExpended) {
                console.log('if ', val);
                $A.util.addClass(allRows[i], "showHiddenDetails");
            } else {
                console.log('else ', val);
                $A.util.removeClass(allRows[i], "showHiddenDetails");
            }
        }
    },

    rs_expandApplicationRowHelper: function (component, event, index) {
        var paywrap = component.get("v.payWrapper");
        console.log('paywrap before->', JSON.stringify(component.get("v.payWrapper")));
        paywrap.policies[index].isExpended = !(paywrap.policies[index].isExpended);
        component.set("v.payWrapper", paywrap);
console.log('paywrap after->', JSON.stringify(component.get("v.payWrapper")));
        /*setTimeout(function() {
    var allRows = component.find('hiddenDetailsApplication');
    if (!Array.isArray(allRows)) allRows = [allRows];

    for (var i = 0; i < allRows.length; i++) {
        var val = allRows[i].getElement().getAttribute('data-index');
        if (val === String(index) && paywrap.policies[index].isExpended) {
            $A.util.addClass(allRows[i], "showHiddenDetails");
        } else {
            $A.util.removeClass(allRows[i], "showHiddenDetails");
        }
    }
}, 0);*/
       
        
    },

    selectBillingMethodHelper: function (component, event, index, checked) {
        var paywrap = component.get("v.payWrapper");
        var rs_buttons = component.find("rs_buttons");
        paywrap.billings[index].isSelected = checked;
        // component.set("v.rs_selectedBillId", paywrap.billings[index].bill.Id);

        if (checked) {
            component.set("v.rs_selectedBillId", paywrap.billings[index].bill.Id);
            component.set("v.rs_selectedBillpdfLink", paywrap.billings[index].pdfUrl);

            for (var i = 0; i < (paywrap.billings).length; i++) {
                if (i != index) {
                    paywrap.billings[i].isSelected = !checked;
                }
            }

            $A.util.addClass(rs_buttons, "show_rs_buttons");
            if (paywrap.billings[index].bill.AcctSeed__Balance__c == 0) {
                component.set("v.rs_isPaymentPaid", true);
            } else {
                component.set("v.rs_isPaymentPaid", false);
                if (paywrap.billings[index].bill.Payment_Method__r != undefined && paywrap.billings[index].bill.Payment_Method__r.Type__c != null) {
                    component.set("v.rs_showPayButton", true);
                } else {
                    component.set("v.rs_showPayButton", false);
                }
            }
        } else {
            $A.util.removeClass(rs_buttons, "show_rs_buttons");
            component.set("v.rs_selectedBillId", '');
            component.set("v.rs_selectedBillpdfLink", '');
        }
        console.log('variable:', component.get("v.rs_selectedBillId"));
        console.log('paywrap.billings[index].isSelected:', paywrap.billings[index].isSelected);
        component.set("v.payWrapper", paywrap);
        console.log('wrapppp', component.get('v.payWrapper'));
    },
    checkMethodExistOrNot: function (component, event, savedCardList, savedEcheckList) {
        var itemType = '';
        if (savedCardList.length > 0) {
            itemType = 'creditCard';
        } else if (savedEcheckList.length) {
            itemType = 'eCheck';
        } else {
            if (savedCardList.length > 0 || savedEcheckList.length > 0) {
            }
            else {
                var otherErrorList = []
                otherErrorList.push('There are no Payment Method exist. Please add new one.')
                var toastType = 'error';
                var emptyFieldErrorList = [];
                this.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
            }
        }
    },
    printBillingHelper: function (component, link) {
        window.open(link, '_blank');
    },

    formatDateHelper: function (oldDate, format) {
        var tempDate = new Date(oldDate);
        let day = String(tempDate.getDate()).padStart(2, '0');;
        let month = String(tempDate.getMonth() + 1).padStart(2, '0');
        let year = tempDate.getFullYear();
        var newDate;
        if (format == 'MM/DD/YYYY') {
            newDate = `${month}/${day}/${year}`;
        } if (format == 'YYYY-MM-DD') {
            newDate = `${year}/${month}/${day}`;
        }
        if (newDate) {
            return newDate;
        } else {
            return false;
        }
    },
    dueDateChangeHelper: function (component, event, fromMethod) {
        var payWrapp = component.get("v.payWrapper");

        if (payWrapp.enablePaymentDate) {
            var tempselectedDate = component.get("v.tempselectedDate");
            var selectedUnformattedDate = event.getSource().get("v.value");
            if (tempselectedDate != selectedUnformattedDate) {

                var todayUnformattedDate = new Date();
                var effectiveUnformattedDate = component.get("v.tempEffectiveDate");

                this.closeToastButHelper(component, event);
                var toastDiv = component.find("toastId");
                $A.util.removeClass(toastDiv, 'showToast');

                var selectedDate = this.formatDateHelper(selectedUnformattedDate, 'MM/DD/YYYY');
                var todayDate = this.formatDateHelper(todayUnformattedDate, 'MM/DD/YYYY');
                var effectiveDate = this.formatDateHelper(effectiveUnformattedDate, 'MM/DD/YYYY');
                component.set("v.tempselectedDate", selectedDate);
                if (todayDate && selectedDate && effectiveDate) {
                    console.log('selectedDate:', selectedDate);
                    console.log('todayDate:', todayDate);
                    console.log('effectiveDate:', effectiveDate);
                    var d1 = todayDate.split("/");
                    var d2 = effectiveDate.split("/");
                    var c = selectedDate.split("/");

                    var from = new Date(d1[2], parseInt(d1[0]) - 1, d1[1]);  // -1 because months are from 0 to 11
                    var to = new Date(d2[2], parseInt(d2[0]) - 1, d2[1]);
                    var check = new Date(c[2], parseInt(c[0]) - 1, c[1]);

                    var oldFormatselectedDate = this.formatDateHelper(selectedUnformattedDate, 'YYYY/MM/DD');
                    //payWrapp.firstInstallmentDate = oldFormatselectedDate;
                    console.log('selectedDate => ', selectedDate);
                    payWrapp.firstInstallmentDateString = selectedDate;

                    console.log(check.getTime() == from.getTime());
                    if (check.getTime() == from.getTime()) {
                        payWrapp.totalAmountDue = payWrapp.billing.AcctSeed__Balance__c;
                        component.set("v.isDueDateValid", true);
                    } else if (check >= from && check <= to) {
                        payWrapp.totalAmountDue = '00';
                        console.log('if')
                        component.set("v.isDueDateValid", true);
                    } else {
                        component.set("v.isDueDateValid", false);
                        console.log('else')
                        payWrapp.totalAmountDue = '00';
                        var emptyFieldErrorList = [];
                        var otherErrorList = [];
                        otherErrorList.push('Payment date must be between ' + todayDate + ' and ' + effectiveDate);
                        var toastType = 'error';
                        this.showToast(component, emptyFieldErrorList, otherErrorList, toastType);
                    }
                    component.set("v.payWrapper", payWrapp);
                    console.log('new wrap:', component.get("v.payWrapper"));
                    if (fromMethod == 'onchange') {
                        this.picklistPaymentMethodChangeHelper(component, event);
                    }
                }
            }
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
    getContactRole: function(component,event){
        var action = component.get("c.getPicklistValues");
        action.setParams({
            strObjectName: 'Policy_Endorsement__c',
            strPicklistField: 'IL_152_Contact_Role__c'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state:', state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('contactRoleList => ',result);
                component.set('v.contactRoleList',result);
            }
        });
        $A.enqueueAction(action);
    },
    saveCreditCardInFiserv: function(component,event, data){
        
        console.log(JSON.stringify(data));
        let wrapper = component.get("v.payWrapper");
        wrapper.paymentTypeVar='creditCard';
        let cardData = JSON.parse(data);
        console.log('cardData' , cardData);
        wrapper.cardNumber = cardData.details.cardNumber;
        wrapper.expireMonth = cardData.details.expiryMonth;
        wrapper.expireYear = cardData.details.expiryYear;
        wrapper.nameOnCard = cardData.details.cardholderName;
        wrapper.payMethodToken = cardData.paymentReference;
        component.set("v.payWrapper",wrapper);
        this.savePaymentMethodHelper(component,event);
    },
    showSpinnerHelper: function(component){
    	var spinner = component.find("fullScreenSpinnerId");
        $A.util.addClass(spinner, 'showFullScreenSpinner');
    },
    closeSpinnerHelper: function(component){
    	var spinner = component.find("fullScreenSpinnerId");
        $A.util.removeClass(spinner, 'showFullScreenSpinner');
    },
})