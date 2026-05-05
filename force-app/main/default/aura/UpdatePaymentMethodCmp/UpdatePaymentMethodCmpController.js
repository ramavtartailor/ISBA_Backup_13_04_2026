({
    doInit: function(component, event, helper) {
        let YearList = [];
        let currentYear = new Date().getFullYear();
        for(let i = 0; i<15; i++){
            YearList.push({'label': parseInt(currentYear)+i, 'value': parseInt(currentYear)+i});
        }
        
        component.set("v.YearList", YearList);
        
        helper.initHelper(component, event, helper);
        window.addEventListener('message', (message) => {
            if (message.data.name == "FiservToken") {
                console.log("message -> ", JSON.stringify(message.data.payload));
                if (message.data.payload) {
                    //component.set("v.showSpinner",true);
                    var eventData = JSON.parse(JSON.stringify(message.data.payload));
                    // console.log('single_use_token -> ' + eventData.paymentReference);
                    //component.set('v.tokenVal', eventData.paymentReference);
                    component.set('v.paymentMethodData', JSON.stringify(eventData));
                    let msg;
                    if (!eventData.details) {
                        msg = 'Missing credit card details';
                        component.set("v.showSpinner",false);      
                        helper.showToast("Error!",msg,'error');
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
                        msg = 'Please enter Card Holder Name';
                        component.set("v.showSpinner",false); 
    
                    } else if (!eventData.details.cardNumber) {
                        msg = 'Please enter Your Credit Card Number';
                        component.set("v.showSpinner",false); 
                        
                    } else if (creditCardExpiryYear == undefined || creditCardExpiryMonth == undefined) {
                        msg = 'Please enter valid Expiration Date';
                        component.set("v.showSpinner",false); 

                    } else if ((parseInt(creditCardExpiryYear) < currentYr) || (parseInt(creditCardExpiryYear) == currentYr && parseInt(creditCardExpiryMonth) < currentMonth)) {
                        msg = 'Please enter valid Expiration Date';
                        component.set("v.showSpinner",false); 
                        
                    } else {
                        console.log('Payment Method Details:', eventData);
                        var cmpEvent = component.getEvent("submitEvent");
                        cmpEvent.fire();
                    }
                    if (msg) {
                        helper.showToast("Error!",msg,'error');
                    }
                }
            }

            if (message.data.name == "TokenizeError") {
                console.log("message -> ", JSON.stringify(message.data.payload));
                if (message.data.payload) {
                    console.log('Error -> ', JSON.parse(JSON.stringify(message.data.payload)));
                    helper.showToast("Error!",message.data.payload,'error');
                    component.set("v.showSpinner",false); 
                }
            }
            if (message.data.name == "OpenSpinner") {
                console.log('Start spinner');
                component.set("v.showSpinner", true);
            }

            if (message.data.name == "CloseSpinner") {
                console.log('Close spinner');
                component.set("v.showSpinner", false);
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
    handleYes: function(component, event, helper) {
        helper.handleYesHelper(component, event, helper, true);
        /*component.set("v.showSpinner",true);
        var action = component.get("c.UpdatePaymentSchedule");
        action.setParams({
            recId : component.get('v.recordId'),
            selectedId :component.get("v.selectedId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if(state=='SUCCESS'){
                var result = response.getReturnValue();
                console.log('result -> ', result);
                helper.showToast("Success!","Payment Method Updated Successfully",'success');
                $A.get("e.force:closeQuickAction").fire();
                component.set("v.showSpinner",false);
            }else{
                helper.showToast("Error!","Some Error Occured!!",'error');
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);*/
    },
    
    handleNo: function(component, event, helper) {
        console.log('No clicked');
        $A.get("e.force:closeQuickAction").fire();
    },
    
    onSelect: function(component, event, helper) {
        var data = event.getSource().get("v.name");
        component.set("v.selectedId", data);
    },
    handleAdd: function(component, event, helper){
        component.set("v.showSpinner",true);
        component.set("v.isUpdateModal", false);
        component.set("v.isAddModal", true);
        component.set("v.showSpinner",false);
    },
    
    tabSwitchHandle: function(component, event, helper){
        var activeTab = component.get("v.activeTabId");
        var clickedTab = event.target.id;
        if(activeTab != clickedTab){
            let tab1 = component.find('tab-1');
            let tab2 = component.find('tab-2');
            if(clickedTab == 'tab-1'){
                $A.util.removeClass(tab2, 'activeTab');
                $A.util.addClass(tab1, 'activeTab');
                component.set("v.activeTabId", 'tab-1');
            }
            else{
                $A.util.removeClass(tab1, 'activeTab');
                $A.util.addClass(tab2, 'activeTab');
                component.set("v.activeTabId", 'tab-2');
            }
        }
    },
    
    handleBack: function(component, event, helper){
        component.set("v.showSpinner",true);
        component.set("v.isAddModal", false);
        component.set("v.isUpdateModal", true);
        component.set("v.activeTabId", 'tab-1');
        component.set("v.showSpinner",false);
    },
    
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
            //component.set('v.cardType', cardTypeHelper);
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
        helper.isExpiryValidHelper(component ,cardExpiryMonth, cardExpiryYear);
    },
    keyUpCardNumberHandle: function (component, event, helper) {
        let ccNum = document.getElementById('cardNumber').value;
        if(isNaN(ccNum[ccNum.length - 1])){
            document.getElementById('cardNumber').value = (ccNum.substring(0, ccNum.length - 1));
        }
        else{
            let i = 0;
            let tempCcNum = '';
            for(let x in ccNum){
                if(i != 0 && i%4 == 0 && ccNum[x] != ' '){
                    tempCcNum +=' ';
                    i = 0;
                }
                
                if(ccNum[x] == ' '){
                    tempCcNum += ccNum[x];
                    i = 0;
                }
                else{
                    tempCcNum += ccNum[x];
                    i++
                }       
            }
            document.getElementById('cardNumber').value = tempCcNum;
        }
    },
    handleSave: function (component, event, helper) {
        let flag = helper.validateAllFieldsHelper(component);
        if(flag){
            flag = helper.checkExestingMethodHelper(component);
        }
        if(flag){
            component.set("v.showSpinner",true);
            
            let jsonBody = '';
            let activeTab = component.get("v.activeTabId");
            if(activeTab == 'tab-1'){
                jsonBody = '{' +
                    '"paymentTypeVar": "eCheck",' +
                    '"accountHolderName": "' + document.getElementById('checkAccountHolderName').value + '",' +
                    '"accountType": "' + document.getElementById('checkAccountType').value + '",' +
                    '"accountNumber": "' + document.getElementById('checkAccountNumber').value + '",' +
                    '"routingNumber": "' + document.getElementById('checkRoutingNumber').value + '"' +
                    '}';
            }
            else{
                jsonBody = '{' +
                    '"paymentTypeVar": "Credit Card",' +
                    '"cardNumber": "' + document.getElementById('cardNumber').value + '",' +
                    '"cardType": "' + document.getElementById('cardType').value + '",' +
                    '"verificationNumber": "' + document.getElementById('cardCVV').value + '",' +
                    '"expireMonth": "' + document.getElementById('cardExpiryMonth').value + '",' +
                    '"expireYear": "' + document.getElementById('cardExpiryYear').value + '",' +
                    '"nameOnCard": "' + document.getElementById('cardNameOnCard').value + '"' +
                    '}';
            }
            console.log('jsonBody => ',jsonBody);
            
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
                        helper.showToast("Success!","Payment Method Created Successfully",'success');
                        component.set("v.selectedId", result);
                        helper.handleYesHelper(component, event, helper, false);
                        //helper.initHelper(component, event, helper);
                        component.set("v.isAddModal", false);
                        component.set("v.isUpdateModal", true);
                        component.set("v.activeTabId", 'tab-1');
                    }
                    else{
                        helper.showToast("Error!","Some Error Occured!!",'error');
                        component.set("v.showSpinner",false);
                    }
                }else if (state === "INCOMPLETE") {
                    helper.showToast("Error!","Some Error Occured!!",'error');
                    component.set("v.showSpinner",false);
                } else if (state === "ERROR") {
                    helper.showToast("Error!","Some Error Occured!!",'error');
                    component.set("v.showSpinner",false);
                }
            });
            $A.enqueueAction(action);
            
        }
    },
    handleDefaultChange : function(component, event, helper) {
        var recId = event.getSource().get("v.name");
        component.set("v.message",'Are you sure you want to Chenge the Default Payment Method?');
        component.set("v.isUpdateModal",false);
        component.set("v.isConfirmationModal",true);
        component.set("v.from",'default');
        component.set("v.currSelectedId",recId);
    },
    handleDeletePaymentMethod : function(component, event, helper) {
        var recId = event.currentTarget.dataset.id;
        var data = component.get("v.data");
        
        /*if(data.length > 1){
            for(let x of data){
                if(x.Id == recId && x.AcctSeed__Default__c){
                    helper.showToast("Error!","You can't delete the Default Payment method. ",'error');
                    return '';
                }
            }
        }*/
        
        component.set("v.message",'Are you sure you want to delete the payment method?');
        component.set("v.isUpdateModal",false);
        component.set("v.isConfirmationModal",true);
        component.set("v.from",'delete');
        component.set("v.currSelectedId",recId);
    },           
    handleConfClose : function(component, event, helper) {
        let from = component.get("v.from");
        if(from == 'default'){
            let recId = component.get("v.currSelectedId");
            var data = component.get("v.data");
            for(let x of data){
                if(x.Id == recId){
                    x.AcctSeed__Default__c = false;
                } 
            }
            component.set("v.data",data);
        }
        component.set("v.isConfirmationModal",false);
        component.set("v.isUpdateModal",true);
    },
    handleConfOk : function(component, event, helper){
        let from = component.get("v.from");
        if(from =='default'){
            helper.changeDefaultPaymentMethod(component, event, helper);
        }
        else if(from =='delete'){
            helper.deletePaymentMethodHelper(component, event, helper)
        }
    },
    
})