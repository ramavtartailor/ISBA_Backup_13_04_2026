({
	doInit : function(component, event, helper) {
        component.set("v.timezone",$A.get("$Locale.timezone"));
        
        var pageRef = component.get("v.pageReference");
        var recId = pageRef.state.c__recordId;
        var buttonTypeValue = pageRef.state.c__typeOfButton;
        component.set("v.recordId",recId);
        
        if(buttonTypeValue == 'renewalBundle'){
            var action = component.get('c.getDocId'); 
            action.setParams({
                RecordId : component.get("v.recordId")
            });
            action.setCallback(this, function(a){
                var state = a.getState();
                if(state == 'SUCCESS') {
                    var returnValue = a.getReturnValue();
                    console.log('returnValue => '+returnValue);
                    var action1 = component.get('c.getDetailsHelper'); 
                    action1.setParams({
                        RecordId : component.get("v.recordId"),
                        buttonType : buttonTypeValue,
                        contentVersionId : returnValue
                    });
                    action1.setCallback(this, function(a){
                        var state = a.getState();
                        if(state == 'SUCCESS') {
                            var returnValue = a.getReturnValue();
                            component.set("v.wrp",returnValue);
                            component.set("v.typeOfButton",buttonTypeValue);
                        }
                        component.set("v.spinner",false);
                    });
                    $A.enqueueAction(action1);
                }
                else{                    
                    component.set("v.spinner",false);
                }
            });
            $A.enqueueAction(action);
        }
        else{
            var action1 = component.get('c.getDetails'); 
            action1.setParams({
                RecordId : component.get("v.recordId"),
                buttonType : buttonTypeValue
            });
            action1.setCallback(this, function(a){
                var state = a.getState();
                if(state == 'SUCCESS') {
                    var returnValue = a.getReturnValue();
                    component.set("v.wrp",returnValue);
                    component.set("v.typeOfButton",buttonTypeValue);
                }
                else if( state == 'ERROR'){
                    var errors = a.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": '!Error',
                                "type": "error",
                                "message": errors[0].message
                            });
                            toastEvent.fire();
                        }
                        setTimeout(function(){
                            var url = "/"+component.get("v.recordId");
                            var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": url
                            });
                            urlEvent.fire();
                        }, 3000);
                    } else {
                            console.log("Unknown error");
                    }
                }
                component.set("v.spinner",false);
            });
            $A.enqueueAction(action1);
        }
    },
    reInit : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    openFile : function(component, event, helper) {
        var fileId = event.currentTarget.dataset.attachid;
        console.log(fileId);
        $A.get('e.lightning:openFiles').fire({
            recordIds: [fileId]
        });
    },
    attachFile : function(component, event, helper) {
        component.set("v.spinner",true);
        var index = event.currentTarget.dataset.index;
        var wrapper = component.get("v.wrp");
        wrapper.attachments[index].attached = true;
        component.set("v.wrp", wrapper);
        component.set("v.spinner",false);
    },
    unattachFile : function(component, event, helper) {
        component.set("v.spinner",true);
        var index = event.currentTarget.dataset.index;
        var wrapper = component.get("v.wrp");
        wrapper.attachments[index].attached = false;
        component.set("v.wrp", wrapper);
        component.set("v.spinner",false);
    },
    attachFileLib : function(component, event, helper) {
        component.set("v.spinner",true);
        var index = event.currentTarget.dataset.index;
        var wrapper = component.get("v.wrp");
        wrapper.LibraryAttachments[index].attached = true;
        component.set("v.wrp", wrapper);
        component.set("v.spinner",false);
    },
    unattachFileLib : function(component, event, helper) {
        component.set("v.spinner",true);
        var index = event.currentTarget.dataset.index;
        var wrapper = component.get("v.wrp");
        wrapper.LibraryAttachments[index].attached = false;
        component.set("v.wrp", wrapper);
        component.set("v.spinner",false);
    },
    send : function(component, event, helper) {
       	console.log(component.get("v.wrp"));
        component.set("v.spinner",true);
        console.log('test');
        var check = true;
        if($A.util.isUndefined(component.get("v.wrp.emailSubject")) || $A.util.isEmpty(component.get("v.wrp.emailSubject")) || component.get("v.wrp.emailSubject") == null){
            component.set("v.showError", true);
            component.set("v.status","Subject cannot be blank.");
            var tOut = setTimeout(function(){
                clearTimeout(tOut);
                component.set("v.showError", false);
            }, 5000); 
            check = false;
        }else if($A.util.isUndefined(component.get("v.wrp.emailBody")) || $A.util.isEmpty(component.get("v.wrp.emailBody")) || component.get("v.wrp.emailBody") == null){
            component.set("v.showError", true);
            component.set("v.status","Email body cannot be blank.");
            var tOut = setTimeout(function(){
                clearTimeout(tOut);
                component.set("v.showError", false);
            }, 5000); 
            check = false;
        }
        
        if(check){
            var action1 = component.get('c.SendEmail'); 
            action1.setParams({
                wrp : component.get("v.wrp"),
                buttonType : component.get("v.typeOfButton")
            });
            action1.setCallback(this, function(a){
                var state = a.getState();
                if(state == 'SUCCESS') {
                    var returnValue = a.getReturnValue();
                    console.log(returnValue);
                    if(returnValue == 'success'){
                        var url = "/"+component.get("v.recordId");
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": url
                        });
                        urlEvent.fire();
                    }else{
                        component.set("v.showError", true);
                        component.set("v.status",returnValue);
                        var tOut = setTimeout(function(){
                            clearTimeout(tOut);
                            component.set("v.showError", false);
                        }, 5000);
                    }
                }
                component.set("v.spinner",false);
            });
            $A.enqueueAction(action1);
        }
	},
    cancel : function(component, event, helper) {
        var tempVal = component.get("v.wrp.emailBody");  
        var url = "/"+component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },
    
    
    ChangeSendToContact : function(component, event, helper) {
      
        component.set("v.SendToisOpen",true);
    },
    
    closeModel1: function(component, event, helper) {
      
        component.set("v.SendToisOpen",false);
    },
    
    SelectContact: function(component, event, helper) {
      
        component.set("v.spinner",true);
        var index = event.currentTarget.dataset.index;
        var wrapper = component.get("v.wrp");
        
        for(let x in wrapper.toAddressList){
            if(x == index){
                wrapper.toAddressList[x].Selected = !wrapper.toAddressList[x].Selected;
                if(wrapper.toAddressList[x].Selected){
                    wrapper.sendToContactEmailSelected = wrapper.toAddressList[index].SelectedContact.Email;
                }
                else{
                    wrapper.sendToContactEmailSelected = '';
                }
            } 
            else{
                wrapper.toAddressList[x].Selected = false;
            }
        }
            
            component.set("v.wrp",wrapper);
        var action1 = component.get('c.UpdateEmailTemp'); 
        action1.setParams({
            RecordId : component.get("v.recordId"),
            wrp : wrapper,
            ConId : wrapper.toAddressList[index].SelectedContact.Id
        });
        action1.setCallback(this, function(a){
            var state = a.getState();
            if(state == 'SUCCESS') {
                var returnValue = a.getReturnValue();
                component.set("v.wrp",returnValue);
            }
            var action2 = component.get('c.SaveModal2');
        	$A.enqueueAction(action2);
            
            component.set("v.spinner",false);
            component.set("v.SendToisOpen",false);
        });
        $A.enqueueAction(action1);
        
        
    },
    handleCheck : function(component, event, helper) {
        
        var isChecked = component.find("bccCheckbox").get("v.checked");
        component.set("v.wrp.isBCCchecked", isChecked);
    },
    ChangeCcContact: function(component, event, helper) {
      
        component.set("v.AddConIsOpen",true);
    },
    
    closeModel2: function(component, event, helper) {
      
        component.set("v.AddConIsOpen",false);
    },
    
    SelectCCContact: function(component, event, helper) {
        component.set("v.spinner",true);
        var index = event.currentTarget.dataset.index;
        var wrapper = component.get("v.wrp");
        
        wrapper.ccAddressList[index].Selected = !wrapper.ccAddressList[index].Selected;

        
        
          component.set("v.wrp",wrapper);
          component.set("v.spinner",false);
        
    },
    
    
    SaveModal2 : function(component, event, helper) {
        component.set("v.spinner",true);
        var wrapper = component.get("v.wrp");
        var myString='';
        var newString ='';
        for(var i = 0 ; i < wrapper.toAddressList.length ; i++){
            if(wrapper.toAddressList[i].Selected){
                wrapper.sendToContactSelected = wrapper.toAddressList[i].SelectedContact;
                /*if(myString == ''){
                	newString += wrapper.toAddressList[i].SelectedContact.Name + ' ('+ wrapper.toAddressList[i].SelectedContact.Email + ')';
                	myString += wrapper.toAddressList[i].SelectedContact.Email;
                }
                else{
                    newString += ';' + wrapper.toAddressList[i].SelectedContact.Name + ' ('+ wrapper.toAddressList[i].SelectedContact.Email + ')';
                    myString +=';' + wrapper.toAddressList[i].SelectedContact.Email;
                }*/
            }
            
        }
        for(var i = 0 ; i < wrapper.ccAddressList.length ; i++){
            if(wrapper.ccAddressList[i].Selected){
                if(myString == ''){
                	newString += wrapper.ccAddressList[i].SelectedContact.Name + ' ('+ wrapper.ccAddressList[i].SelectedContact.Email + ')';
                	myString += wrapper.ccAddressList[i].SelectedContact.Email;
                }
                else{
                    newString += ';' + wrapper.ccAddressList[i].SelectedContact.Name + ' ('+ wrapper.ccAddressList[i].SelectedContact.Email + ')';
                    myString +=';' + wrapper.ccAddressList[i].SelectedContact.Email;
                }
            }
            
        }
        wrapper.CCAddressDisplay = newString;
        wrapper.CCAddress = myString;
        component.set("v.wrp",wrapper);
        component.set("v.AddConIsOpen",false);
        component.set("v.spinner",false);
    },
    selectFolder : function(component, event, helper) {
        component.set("v.spinner",true);
        var wrapper = component.get("v.wrp");
        var action = component.get('c.changeFolder'); 
        action.setParams({
            wrp : wrapper
        });
        action.setCallback(this, function(a){
            var state = a.getState();
            if(state == 'SUCCESS') {
                var returnValue = a.getReturnValue();
                component.set("v.wrp",returnValue);
            }
            component.set("v.spinner",false);
        });
        $A.enqueueAction(action);
	},
    selectTemplate : function(component, event, helper) {
        component.set("v.spinner",true);
        var wrapper = component.get("v.wrp");
        var action = component.get('c.changeTemplate'); 
        action.setParams({
            RecordId : component.get("v.recordId"),
            wrp : wrapper
        });
        action.setCallback(this, function(a){
            var state = a.getState();
            if(state == 'SUCCESS') {
                var returnValue = a.getReturnValue();
                component.set("v.wrp",returnValue);
            }
            component.set("v.spinner",false);
        });
        $A.enqueueAction(action);
	}
})