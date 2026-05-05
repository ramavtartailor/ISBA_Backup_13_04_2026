({
	init : function(component, event, helper) {
        var action = component.get("c.getPolicyEndorse");
        action.setParams(
			{policyId : component.get("v.recordId")}            
		);
        action.setCallback(this, function(response) {
            var state = response.getState();  
            if(state === "SUCCESS") {
                window.open("/apex/Endorsement_Pdf?id="+component.get("v.recordId")+"&number="+response.getReturnValue().Endorsement_Number__c+"&version="+response.getReturnValue().Endorsement_Version__c,'_blank');
                $A.get("e.force:closeQuickAction").fire();
                //component.set("v.PDFURL", "/apex/Endorsement_Pdf?id="+component.get("v.recordId")+"&number="+response.getReturnValue().Endorsement_Number__c+"&version="+response.getReturnValue().Endorsement_Version__c);
            } else {
                alert('Some error has occurred. Please contact your system Administrator');
                console.log(state);
            }
        });
        $A.enqueueAction(action); 
		
	}
})