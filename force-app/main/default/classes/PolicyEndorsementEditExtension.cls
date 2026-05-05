public class PolicyEndorsementEditExtension {
    private Policy_Endorsement__c endorsement;
    public PolicyEndorsementEditExtension(ApexPages.StandardController stdController) {
        this.endorsement = (Policy_Endorsement__c)stdController.getRecord();
    }
    public PageReference returnToEditPage(){
        endorsement = [select id,Endorsement_Number__c,name from Policy_Endorsement__c where id=: endorsement.Id];
        if(endorsement.Endorsement_Number__c == 'IL 102' || endorsement.Endorsement_Number__c == 'IL 260'){
            return new PageReference('/apex/PolicyEndorsement?id='+endorsement.Id);
        }else if(endorsement.Endorsement_Number__c == 'IL 152'){
            return new PageReference('/apex/AddingAnAttorney?id='+endorsement.Id);
        }else if(endorsement.Endorsement_Number__c == 'IL 153'){
            return new PageReference('/apex/DeletingAnAttorney?id='+endorsement.Id);
        }else{
            return new PageReference('/apex/EndorsementEditPage?id='+endorsement.Id+'&name='+endorsement.name);
        }
    }
}