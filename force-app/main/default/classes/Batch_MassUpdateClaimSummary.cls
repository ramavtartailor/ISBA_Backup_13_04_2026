public class Batch_MassUpdateClaimSummary implements Database.Batchable<Sobject>,Database.stateful{
    public String soql;
    public String sObjectName;
    public Batch_MassUpdateClaimSummary(String soql,String sObjectName){
        this.soql = soql;
        this.sObjectName = sObjectName;
    }
    public Batch_MassUpdateClaimSummary(){
        
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(soql != null){
            return Database.getQueryLocator(soql);
        }else{
            this.sObjectName = 'Policy_Claim__c';
            return Database.getQueryLocator([select Id from Policy_Claim__c]);
        }
    }
    public void execute(Database.BatchableContext BC, List<sObject> batch) {
        if(sObjectName == 'Policy_Claim__c'){
            updateClaimSummary(batch);
        }else{
            updatePolicySummary(batch);
        }
        
    }
    public void finish(Database.BatchableContext BC) {
        
    }
    public void updateClaimSummary(List<Policy_Claim__c> claims){
        List<String> glNames = new List<String>();
        Map<String,Decimal> claimGLMap = new Map<String,Decimal>();
        List<sObject> claimsToUpdate = new List<sObject>();
        Map<String,Date> claimLastTransactionDateMap = new Map<String,Date>();
        List<Claim_Loss_Summary_GL__mdt> glSummaryList =  [select MasterLabel,GL_Account__c,Claim_Field__c,Claim_Last_Transaction_Date_Field__c from Claim_Loss_Summary_GL__mdt where Claim_Field__c!=null];
        for(Claim_Loss_Summary_GL__mdt summary : glSummaryList){
            glNames.add(summary.GL_Account__c);
        }
        
        for(AcctSeed__Transaction__c tran : [select id,AcctSeed__Amount__c,AcctSeed__GL_Account__r.Name,Claim__c, AcctSeed__Date__c  from AcctSeed__Transaction__c where Claim__c in: claims and AcctSeed__GL_Account__r.Name in: glNames]){
            if(!claimGLMap.containsKey(tran.Claim__c + '-' + tran.AcctSeed__GL_Account__r.Name)){
                claimGLMap.put(tran.Claim__c + '-' + tran.AcctSeed__GL_Account__r.Name,0);
                claimLastTransactionDateMap.put(tran.Claim__c + '-' + tran.AcctSeed__GL_Account__r.Name,tran.AcctSeed__Date__c );
            }
            claimGLMap.put(tran.Claim__c + '-' + tran.AcctSeed__GL_Account__r.Name,claimGLMap.get(tran.Claim__c + '-' + tran.AcctSeed__GL_Account__r.Name) + tran.AcctSeed__Amount__c);
            claimLastTransactionDateMap.put(tran.Claim__c + '-' + tran.AcctSeed__GL_Account__r.Name,(claimLastTransactionDateMap.get(tran.Claim__c + '-' + tran.AcctSeed__GL_Account__r.Name) > tran.AcctSeed__Date__c ? claimLastTransactionDateMap.get(tran.Claim__c + '-' + tran.AcctSeed__GL_Account__r.Name) : tran.AcctSeed__Date__c));
        }
        for(Policy_Claim__c claim: claims){
            for(Claim_Loss_Summary_GL__mdt summary : glSummaryList){
                if(summary.Claim_Field__c != null){
                    claim.put(summary.Claim_Field__c,(claimGLMap.containsKey(claim.Id + '-' + summary.GL_Account__c) ? claimGLMap.get(claim.Id + '-' + summary.GL_Account__c) : 0));
                }
                if(summary.Claim_Last_Transaction_Date_Field__c != null){
                    claim.put(summary.Claim_Last_Transaction_Date_Field__c,(claimLastTransactionDateMap.containsKey(claim.Id + '-' + summary.GL_Account__c) ? claimLastTransactionDateMap.get(claim.Id + '-' + summary.GL_Account__c) : null));
                }
            }
            claimsToUpdate.add(claim);
        }
        if(claimsToUpdate.size() > 0){
            update claimsToUpdate;
        }
    }
    public void updatePolicySummary(List<Policy__c> policies){
        List<String> glNames = new List<String>();
        Map<String,Decimal> policyGLMap = new Map<String,Decimal>();
        List<sObject> policiesToUpdate = new List<sObject>();
        
        List<Claim_Loss_Summary_GL__mdt> glSummaryList =  [select MasterLabel,GL_Account__c,Claim_Field__c,Policy_Field__c from Claim_Loss_Summary_GL__mdt where Policy_Field__c!=null];
        for(Claim_Loss_Summary_GL__mdt summary : glSummaryList){
            glNames.add(summary.GL_Account__c);
        }
        
        for(AcctSeed__Transaction__c tran : [select id,AcctSeed__Amount__c,AcctSeed__GL_Account__r.Name,Claim__c,Policy__c from AcctSeed__Transaction__c where Policy__c in: policies and AcctSeed__GL_Account__r.Name in: glNames]){
            if(!policyGLMap.containsKey(tran.Policy__c + '-' + tran.AcctSeed__GL_Account__r.Name)){
                policyGLMap.put(tran.Policy__c + '-' + tran.AcctSeed__GL_Account__r.Name,0);
            }
            policyGLMap.put(tran.Policy__c + '-' + tran.AcctSeed__GL_Account__r.Name,policyGLMap.get(tran.Policy__c + '-' + tran.AcctSeed__GL_Account__r.Name) + tran.AcctSeed__Amount__c);
        }
        for(Policy__c policy: policies){
            for(Claim_Loss_Summary_GL__mdt summary : glSummaryList){
                policy.put(summary.Policy_Field__c,(policyGLMap.containsKey(policy.Id + '-' + summary.GL_Account__c) ? policyGLMap.get(policy.Id + '-' + summary.GL_Account__c) : 0));
            }
            policiesToUpdate.add(policy);
        }
        if(policiesToUpdate.size() > 0){
            update policiesToUpdate;
        }
    }
}