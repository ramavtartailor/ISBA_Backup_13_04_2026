public class CreateLSAonRenewalQueueable implements Queueable, Database.AllowsCallouts {
    public Set<Id> policyIds;
    public Set<Id> oppties;
    public CreateLSAonRenewalQueueable(Set<Id> policyIdSet,Set<Id> opptiesSet){
        policyIds = policyIdSet;
        oppties = opptiesSet;
        system.debug('policyIds-->'+policyIds.size());
    }
    public void execute(QueueableContext context) {
        List<Policy__C> policiesToBeUpdated = new List<Policy__C>();
        for(Opportunity opp: [select id,Application_Policy__c from Opportunity where id in : oppties AND Application_Policy__c != NULL]){
            policiesToBeUpdated.add(new Policy__C(id=opp.Application_Policy__c,Opportunity__C=opp.id));
        }
        if(policiesToBeUpdated!=null && policiesToBeUpdated.size()>0){
            update policiesToBeUpdated;
            // To update policy count field on opportunity, required for One-One Validation.
            Set<String> setOpportunityIds = new Set<String>();
            Map<String,String> mapOpportunityPolicy = new Map<String,String>();
            List<Opportunity> lstOpportunities = new List<Opportunity>();
            
            for (Policy__c pol : policiesToBeUpdated) {
                setOpportunityIds.add(pol.Opportunity__c);
                mapOpportunityPolicy.put(pol.Opportunity__c,pol.Id);
            }
            
            if(setOpportunityIds.size()>0){
                for (Opportunity opp : [SELECT Id, Policy_Count__c FROM Opportunity WHERE Id IN :setOpportunityIds]) {
                    opp.Policy_Count__c = opp.Policy_Count__c + 1;
                    opp.Application_Policy__c = mapOpportunityPolicy.get(opp.Id);
                    lstOpportunities.add(opp);
                }            
                update lstOpportunities;
            }
        }
        
        
        /**/
        
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        Decimal currentMilliSeconds = System.now().getTime();
        for(Policy__c policy: [Select Id,Account__c,Account__r.Name,Name from Policy__c where Id in: policyIds]){
            PageReference pg = Page.LawyersSupplement;
            pg.getParameters().put('id',(String)policy.Id);
            Blob body;
            try {
                body = pg.getContent();
            } catch (VisualforceException e) {
                body = Blob.valueOf('Some Error Occurred While PDF Generation.');
            }
            String fileName = '';
            fileName = policy.Account__r.Name +' - '+policy.Name;
            fileName += ' - Lawyers Supplemental Application.pdf';
            ContentVersion content = new ContentVersion();
            content.VersionData = body;
            content.Title = fileName;
            content.PathOnClient = fileName;
            content.FirstPublishLocationId = policy.Id;
            content.Application_Policy__c = policy.Id;
            content.Account__c = policy.Account__c;
            content.Document_Type__c = 'Lawyer Supplement Application';
            content.Is_System_Generated_Document__c = true;
            content.Unique_Identifier__c = policy.Id + '_' + UserInfo.getUserId() +  '_' + currentMilliSeconds;
            cvList.add(content);
        }
        insert cvList;
    }
}