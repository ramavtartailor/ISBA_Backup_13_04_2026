({	
    initHelper: function(component, event, helper) {
        component.set("v.showSpinner",true);      
        var action = component.get("c.getDetails");
        action.setParams({
            recId : component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if(state=='SUCCESS'){
                var result = response.getReturnValue();
                console.log('result -> ', result);
                component.set("v.selectedId", result.selectedId);
                component.set("v.data",result.payMethodList);
                component.set("v.customerId",result.customerId);
                component.set("v.showSpinner",false);
            }else{
                helper.showToast("Error!","Some Error Occured!!",'error');
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },    
    showToast : function(title,msg,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": msg,
            "type": type
        });
        toastEvent.fire();
    },
    isRoutingNumberValidHelper: function (input) {
        if (!(input.value == '' || input.value == null || input.value == undefined)){
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
        /*if (cardType.value == 'amex') {
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
        }*/
        if (cardType.value != '') {
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
            }
            if (cardCvv.value != '') {
                this.isCvvValidHelper(component, cardCvv, cardType);
            }
        }
        else{
            cardType.className = 'errorInput';
            return cardType.name;
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
        if (cardNumber_input.value != '' && cardType.value != '') {
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

        if (cvvNumber != '' && ccType != '') {
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
        } else if (ccType != '') {
            cardType.className = 'errorInput';
            return '';
        } else {
            cardCvv.className = '';
            return '';
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
        if (cardExpiryMonth.value != '' && cardExpiryYear.value != '') {
            var dateObj = new Date();
            let thisYear = dateObj.getFullYear();
            let thisMonth = dateObj.getMonth() + 1;

            if (cardExpiryYear.value == thisYear) {
                if (cardExpiryMonth.value < thisMonth) {
                    cardExpiryMonth.className = 'errorInput';
                    cardExpiryYear.className = 'errorInput';
                    return 'Expiry Date should not be less than today.';
                } else {
                    //component.set("v.policywrap.expireMonth", cardExpiryMonth.value);
                    //component.set("v.policywrap.expireYear", cardExpiryYear.value);
                    cardExpiryMonth.className = '';
                    cardExpiryYear.className = '';
                    return '';
                }
            } else {
                //component.set("v.policywrap.expireMonth", cardExpiryMonth.value);
                //component.set("v.policywrap.expireYear", cardExpiryYear.value);
                cardExpiryMonth.className = '';
                cardExpiryYear.className = '';
                return '';
            }
        } else {
            if (cardExpiryMonth.value == '' && cardExpiryYear.value == '') {
                cardExpiryMonth.className = 'errorInput';
                cardExpiryYear.className = 'errorInput';
                return cardExpiryYear.name;
            } if (cardExpiryMonth.value == '') {
                cardExpiryMonth.className = 'errorInput';
                return 'Expiry Month';
            } if (cardExpiryYear.value == '') {
                cardExpiryYear.className = 'errorInput';
                return 'Expiry Year';
            }
        }
    },    
    validateAllFieldsHelper: function (component) {
        component.set("v.showSpinner",true);
        let flag = true;
        let activeTab = component.get("v.activeTabId");
        if(activeTab == 'tab-1'){
            var checkRoutingNumber = document.getElementById("checkRoutingNumber");
            if(this.isRoutingNumberValidHelper(checkRoutingNumber) != ''){
                flag = false;                
            }           
            var checkAccountNumber = document.getElementById("checkAccountNumber");
            if(this.isAccountNumberValidHelper(checkAccountNumber)!= ''){
                flag = false;                
            }            
            var checkAccountType = document.getElementById("checkAccountType");
            if(this.isFieldEmptyHelper(checkAccountType)!= ''){
                flag = false;                
            }            
            var checkAccountHolderName = document.getElementById("checkAccountHolderName");
            if(this.isFieldEmptyHelper(checkAccountHolderName)!= ''){
                flag = false;                
            }
        }
        else{
            var cardNumber = document.getElementById('cardNumber');            
            var cardType = document.getElementById('cardType');            
            var cardCvv = document.getElementById('cardCVV');
            var cardExpiryMonth = document.getElementById('cardExpiryMonth');
            var cardExpiryYear = document.getElementById('cardExpiryYear');
            var cardNameOnCard = document.getElementById('cardNameOnCard');
            
            if(this.isCardNumberValidHelper(cardNumber) != ''){
                flag = false;
            }
            if(cardType == '' || this.compareCardNumberAndTypeHelper(cardNumber, cardType) != ''){
                flag = false;
            }
            if(this.isCvvValidHelper(component, cardCvv, cardType) != ''){
                flag = false
            }
            if(this.isExpiryValidHelper(component ,cardExpiryMonth, cardExpiryYear) != ''){
                flag = false;
            }
            if(this.isFieldEmptyHelper(cardNameOnCard)!= ''){
                flag = false;                
            }
        }
        
        component.set("v.showSpinner",false);
        return flag;
    },
    checkExestingMethodHelper: function (component){        
        let activeTab = component.get("v.activeTabId");
        let paymentMethodList = component.get("v.data");
        if(activeTab == 'tab-1'){
            let accountType = document.getElementById('checkAccountType').value;
            let accountNumber = document.getElementById('checkAccountNumber').value;
            let key = accountType +' '+(accountNumber).slice(accountNumber.length - 4); 
            for(let x of paymentMethodList){
                if(x.AcctSeed__Payment_Method_Type__c == 'Bank Account'){
                    let accType = x.AcctSeed__Bank_Account_Type__c == 'Saving' ?  'Savings' : x.AcctSeed__Bank_Account_Type__c;
                    let oldKey = (accType).toLowerCase()+' '+x.AcctSeed__Last_Four_Digits__c;
                    if(key == oldKey){
                        this.showToast("Error!","You cannot add an Existing eCheck.",'error');
                        return false;
                    }
                }
            }
        }
        else{
            let cardNumber = document.getElementById('cardNumber').value;
            cardNumber = cardNumber.replace(/\s/g, '');
            let cardType = document.getElementById('cardType').value;
            let key = cardType+' '+(cardNumber).slice(cardNumber.length - 4);
            
            for(let x of paymentMethodList){
                if(x.AcctSeed__Payment_Method_Type__c == 'Credit Card'){
                    let oldKey = x.AcctSeed__Type__c+' '+x.AcctSeed__Last_Four_Digits__c;
                    if(key == oldKey){
                        this.showToast("Error!","You cannot add an Existing Card.",'error');
                        return false;
                    }
                }
            }
        }
        return true;
    },
    deletePaymentMethodHelper: function(component, event, helper) {
        component.set("v.showSpinner",true);   
        let recId = component.get("v.currSelectedId");
        var data = component.get("v.data");
        let payMethodId = '';
        for(let x of data){
            if(x.Id == recId){
                payMethodId = x.Payment_Method_Token__c;                
            } 
        }
        var action = component.get("c.deletePaymentMethod");
        
        action.setParams({
            payMethodId : payMethodId,
            recId : component.get('v.customerId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if(state=='SUCCESS'){
                component.set("v.isConfirmationModal",false);
                component.set("v.isUpdateModal",true);
                this.initHelper(component, event, helper);
            }else{
                helper.showToast("Error!","Some Error Occured!!",'error');
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    saveCreditCardInFiserv: function(component,event, data){
        component.set("v.showSpinner",true);
        let cardData = JSON.parse(data);
        console.log('cardData' , cardData);
        let jsonBody = '{' +
            '"paymentTypeVar": "Credit Card",' +
            '"cardNumber": "' + cardData.details.cardNumber + '",' +
            '"expireMonth": "' + cardData.details.expiryMonth + '",' +
            '"expireYear": "' + cardData.details.expiryYear + '",' +
            '"token": "' + cardData.paymentReference + '",' +
            '"nameOnCard": "' + cardData.details.cardholderName + '"' +
            '}';
        
        var action = component.get("c.savePaymentMethod");
        action.setParams({
            jsonBody : jsonBody,
            recId : component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if(state=='SUCCESS'){
                var result = response.getReturnValue();
                if(result){
                    this.showToast("Success!","Payment Method Created Successfully",'success');
                    component.set("v.selectedId", result);
                    this.handleYesHelper(component, event, helper, false);
                    //this.initHelper(component, event, helper);
                    component.set("v.isAddModal", false);
                    component.set("v.isUpdateModal", true);
                    component.set("v.activeTabId", 'tab-1');
                }
                else{
                    this.showToast("Error!","Some Error Occured!!",'error');
                }
            }else if (state === "INCOMPLETE") {
                this.showToast("Error!","Some Error Occured!!",'error');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast("Error!",errors[0].message,'error');
                    }
                }
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
        
    },
    handleYesHelper: function(component, event, helper, flag) {
        component.set("v.showSpinner",true);
        var action = component.get("c.UpdatePaymentSchedule");
        action.setParams({
            recId : component.get('v.recordId'),
            selectedId :component.get("v.selectedId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if(state=='SUCCESS'){
                var result = response.getReturnValue();
                if(flag){
                    console.log('result -> ', result);
                    this.showToast("Success!","Payment Method Updated Successfully",'success');
                    $A.get("e.force:closeQuickAction").fire();
                }
                else{
                    this.initHelper(component, event, helper);
                }
                component.set("v.showSpinner",false);
            }else{
                this.showToast("Error!","Some Error Occured!!",'error');
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
})