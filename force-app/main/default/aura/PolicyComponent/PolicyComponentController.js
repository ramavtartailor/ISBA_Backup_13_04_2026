({
    
    doInit: function (component, event, helper) {
        
        var action = component.get("c.fetchLawyer");
        action.setParams({ "policyId": component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var lst = [];
                lst = response.getReturnValue().lawyerList;
                component.set("v.deductibleFactor",response.getReturnValue().deductibleFactor);
                component.set("v.limitFactor",response.getReturnValue().limitFactor);
                component.set("v.baseRate",response.getReturnValue().baseRate);
                component.set("v.firmMod",response.getReturnValue().firmMod);
                component.set("v.quoteLimit",response.getReturnValue().quoteLimit);
                component.set("v.quoteDeductible",response.getReturnValue().quoteDeductible);
                component.set("v.adjMod",response.getReturnValue().adjMod);
                component.set("v.mod_230",response.getReturnValue().mod_230);
                component.set("v.mod_234",response.getReturnValue().mod_234);
                component.set("v.mod_261",response.getReturnValue().mod_261);
                var total = 0;
                var value7 =0;
                var value6 =0;
                var value5 =0;
                var value4 =0;
                var value3 =0;
                var value2 =0;
                var value1 =0;
                var value0 =0;
                var Rate7 =0;
                var Rate6 =0;
                var Rate5 =0;
                var Rate4 =0;
                var Rate3 =0;
                var Rate2 =0;
                var Rate1 =0;
                var Rate0 =0;
                
                for(var i = 0 ; i < lst.length ; i++ ) {
                   
                    if(lst[i].Step__c == 7 ) {
                        value7++;
                        Rate7 = Rate7 + lst[i].Rate_At__c;
                        component.set("v.count7", value7);
                        
                    } else if(lst[i].Step__c == 6) {
                        value6++;
                        Rate6 = Rate6 + lst[i].Rate_At__c;
                        component.set("v.count6", value6);
                        
                    } else if(lst[i].Step__c == 5) {
                        value5++;
                        Rate5 = Rate5 + lst[i].Rate_At__c;
                        component.set("v.count5", value5);
                        
                    } else if(lst[i].Step__c == 4) {
                        value4++;
                        Rate4 = Rate4 + lst[i].Rate_At__c;
                        component.set("v.count4", value4);
                       
                    } else if(lst[i].Step__c == 3) {
                        value3++;
                        Rate3 = Rate3 + lst[i].Rate_At__c;
                        component.set("v.count3", value3);
                    } else if(lst[i].Step__c == 2) {
                        value2++;
                        Rate2 = Rate2 + lst[i].Rate_At__c;
                        component.set("v.count2", value2);
                    } else if(lst[i].Step__c == 1) {
                        value1++;
                        Rate1 = Rate1 + lst[i].Rate_At__c;
                        component.set("v.count1", value1);
                    } else if(lst[i].Step__c == 0) {
                        value0++;
                        Rate0 = Rate0 + lst[i].Rate_At__c;
                        component.set("v.count0", value0);
                    }
                }
                component.set("v.countTotal", value7+value6+value5+value4+value3+value2+value1+value0);
                component.set("v.fullTime7", (Rate7/100) );
                component.set("v.fullTime6", (Rate6/100) );
                component.set("v.fullTime5", (Rate5/100) );
                component.set("v.fullTime4", (Rate4/100) );
                component.set("v.fullTime3", (Rate3/100) );
                component.set("v.fullTime2", (Rate2/100) );
                component.set("v.fullTime1", (Rate1/100) );
                component.set("v.fullTime0", (Rate0/100) );
                component.set("v.fullTimeTotal", (Rate7/100)+(Rate6/100)+(Rate5/100)+(Rate4/100)+(Rate3/100)+(Rate2/100)+(Rate1/100)+(Rate0/100));
            }
        });
        $A.enqueueAction(action);
    },
    closeModal:function(component,event,helper){    
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },
    openModal: function(component,event,helper) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
    }
})