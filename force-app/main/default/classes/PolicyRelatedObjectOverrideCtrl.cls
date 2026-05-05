public class PolicyRelatedObjectOverrideCtrl {
    @AuraEnabled
    public static PolicyRelatedObjectOverrideCtrlWrapper isOperationAllowed(String recordId,String operation){
        String objName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        PolicyRelatedObjectOverrideCtrlWrapper wrapper;
        if(objName == 'Policy_AOP__c'){
            List<Policy_AOP__c> policyAOPs = new List<Policy_AOP__c>([select id,Policy__c,Policy__r.RecordType.Name from Policy_AOP__c where id=: recordId]);
            if(policyAOPs.size()>0 && policyAOPs[0].Policy__r.RecordType.Name == 'Application'){
                wrapper = new PolicyRelatedObjectOverrideCtrlWrapper('Yes','/apex/AreaofPracticeDetailPageEdit_Ltng?id=' + policyAOPs[0].Policy__c +'&showNext=false');
            }else if(policyAOPs.size()>0 && policyAOPs[0].Policy__r.RecordType.Name == 'Policy'){
                wrapper = new PolicyRelatedObjectOverrideCtrlWrapper('No',policyAOPs[0].Policy__c);
            }
        }else if(objName == 'Policy_Quote__c'){
            List<Policy_Quote__c> quotes = new List<Policy_Quote__c>([select id,Policy__c,Policy__r.RecordType.Name from Policy_Quote__c where id=: recordId]);
            if(quotes.size()>0 && quotes[0].Policy__r.RecordType.Name == 'Application'){
                wrapper = new PolicyRelatedObjectOverrideCtrlWrapper('Yes','/apex/QuotesDetailPage?id=' + quotes[0].Policy__c +'&showNext=false');
            }else if(quotes.size()>0 && quotes[0].Policy__r.RecordType.Name == 'Policy'){
                wrapper = new PolicyRelatedObjectOverrideCtrlWrapper('No',quotes[0].Policy__c);
            }
        }else if(objName == 'Policy_Lawyer__c'){
            List<Policy_Lawyer__c> lawyers = new List<Policy_Lawyer__c>([select id,Policy__c,Policy__r.RecordType.Name,Policy__r.Effective_Date__c,Lawyer__r.Contact__c from Policy_Lawyer__c where id=: recordId]);
            if(lawyers.size()>0 && lawyers[0].Policy__r.RecordType.Name == 'Application'){
                wrapper = new PolicyRelatedObjectOverrideCtrlWrapper('Yes','/apex/ContactDetailPageEdit_Ltng?id=' + lawyers[0].Lawyer__r.Contact__c +'&retURL=' + lawyers[0].Policy__c);
            }else if(lawyers.size()>0 && lawyers[0].Policy__r.RecordType.Name == 'Policy'){
                if(operation == 'Delete'){
                    String effectiveDate;
                    RecordType recordType = [SELECT Id, Name FROM RecordType WHERE Name = 'IL 153 Deleting an Attorney Endorsement' and SobjectType = 'Policy_Endorsement__c' LIMIT 1];
                    if (lawyers[0].Policy__r.Effective_Date__c != null) {
                        effectiveDate = String.valueOf(lawyers[0].Policy__r.Effective_Date__c.Month() + '/' + lawyers[0].Policy__r.Effective_Date__c.Day() + '/' + lawyers[0].Policy__r.Effective_Date__c.Year());
                    } else {
                        effectiveDate = String.valueOf(Date.today().Month() + '/' + Date.today().Day() + '/' + Date.today().Year());
                    }
                    wrapper = new PolicyRelatedObjectOverrideCtrlWrapper('Yes','/apex/DeletingAnAttorney?policyId=' + lawyers[0].Policy__c +  '&Name='+recordType.Name+ '&RecordType=' + recordType.Id +'&effectiveDate=' + effectiveDate);
                }else{
                    wrapper = new PolicyRelatedObjectOverrideCtrlWrapper('Yes','/apex/ContactDetailPageEdit_Ltng?id=' + lawyers[0].Lawyer__r.Contact__c +'&retURL=' + lawyers[0].Policy__c);
                }
            }
        }
        return wrapper;
    }
    @TestVisible class PolicyRelatedObjectOverrideCtrlWrapper{
        @AuraEnabled
        public String isOperationAllowed;
        @AuraEnabled
        public String returnURL;
        PolicyRelatedObjectOverrideCtrlWrapper(String isOperationAllowed,String returnURL){
            this.isOperationAllowed = isOperationAllowed;
            this.returnURL = returnURL;
        }
    }
}