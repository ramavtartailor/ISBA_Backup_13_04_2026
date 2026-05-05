public class Batch_MassUpdatePolicies implements Database.Batchable<Sobject>, Database.Stateful{
    public String soql;
    public String operation;
    Map<String,Decimal> effectiveYearDividendPolicies;
    Map<String,Decimal> expirationYearDividendPolicies;
    public Batch_MassUpdatePolicies(){
    }
    public Batch_MassUpdatePolicies(String soql,String operation){
        this.soql = soql;
        this.operation = operation;
        effectiveYearDividendPolicies = new Map<String,Decimal>();
        expirationYearDividendPolicies = new Map<String,Decimal>();
    }
	public Database.QueryLocator start(Database.BatchableContext BC) {
        if(String.isNotBlank(soql)){
            return Database.getQueryLocator(soql);
        }else if(operation == 'Dividend Update'){
            for(Policy__c pol : [select id,Account__c,Policy_Effective_Year__c,Policy_Expiration_Year__c,Effective_Year_Dividend__c,Dividend_Expiration_Year_Earned__c, Effective_Date__c,Policy_Series_Effective_Date__c  from Policy__c where Effective_Date__c >= 2017-01-01]){
                if(!effectiveYearDividendPolicies.containsKey(pol.Policy_Effective_Year__c + '-' + pol.Account__c)){
                    effectiveYearDividendPolicies.put(pol.Policy_Effective_Year__c + '-' + pol.Account__c,0);
                }
                if(pol.Effective_Year_Dividend__c != null){
                    effectiveYearDividendPolicies.put(pol.Policy_Effective_Year__c + '-' + pol.Account__c,effectiveYearDividendPolicies.get(pol.Policy_Effective_Year__c + '-' + pol.Account__c) + pol.Effective_Year_Dividend__c);
                }
                
                if(!expirationYearDividendPolicies.containsKey(pol.Policy_Expiration_Year__c + '-' + pol.Account__c)){
                    expirationYearDividendPolicies.put(pol.Policy_Expiration_Year__c + '-' + pol.Account__c,0);
                }
                if(pol.Dividend_Expiration_Year_Earned__c  != null){
                    expirationYearDividendPolicies.put(pol.Policy_Expiration_Year__c + '-' + pol.Account__c,expirationYearDividendPolicies.get(pol.Policy_Expiration_Year__c + '-' + pol.Account__c) + pol.Dividend_Expiration_Year_Earned__c );
                }
            }
            return Database.getQueryLocator([select id,Account__c,Policy_Effective_Year__c,Policy_Expiration_Year__c,Effective_Year_Dividend__c,Dividend_Expiration_Year_Earned__c,Effective_Date__c,Policy_Series_Effective_Date__c from Policy__c where Effective_Date__c >= 2017-01-01]);
        }else{
            operation = 'Update Treaty';
            return Database.getQueryLocator([select id,Treaty_Version__c,Effective_Date__c from Policy__c where Treaty_Version__c = null and Effective_Date__c > 2000-01-01 order by Effective_Date__c DESC]);
        }
    }
    public void execute(Database.BatchableContext BC, List<sObject> batch) {
        if(operation == 'Update Treaty'){
            List<Treaty_Versions__c> treatyVersions = new List<Treaty_Versions__c>([select id,Start_Date__c,End_Date__c from Treaty_Versions__c]);
            for(Policy__c pol : (List<Policy__c>)batch){
                for(Treaty_Versions__c version : treatyVersions){
                    if(pol.Effective_Date__c >= version.Start_Date__c && pol.Effective_Date__c <= version.End_Date__c){
                        pol.Treaty_Version__c = version.Id;
                    }
                }
            }
            update batch;
        }else if(operation == 'Update Policy Series'){
            // soql = select id,(select id,Effective_Date__c,Expiration_Date__c,Cancel_Date__c from Policies__r where RecordType.Name = \'Policy\' order by Effective_Date__c) from Account where id=\'0014A00002jNWcLQAW\'
            List<Policy__c> policies = new List<Policy__c>();
            for(Account acc : (List<Account>)batch){
                Integer policySeriesCount;
                Date policySeriesEffectiveDate;
                Date oldPolicyExpirationDate;
                for(Policy__c pol : acc.Policies__r){
                    if(pol.Effective_Date__c != oldPolicyExpirationDate){
                        policySeriesCount = 1;
                        policySeriesEffectiveDate = pol.Effective_Date__c;
                    }else{
                        policySeriesCount += 1;
                    }
                    if(pol.Cancel_Date__c != null){
                        oldPolicyExpirationDate = pol.Cancel_Date__c;
                    }else{
                        oldPolicyExpirationDate = pol.Expiration_Date__c;
                    }
                    policies.add(new Policy__c(Id = pol.Id,Policy_Series_Count__c = policySeriesCount,Policy_Series_Effective_Date__c = policySeriesEffectiveDate));
                }
            }
            update policies;
        }else if(operation == 'Dividend Update'){
            System.debug(effectiveYearDividendPolicies);
            System.debug(expirationYearDividendPolicies);
            for(Policy__C pol : (List<Policy__c>)batch){
                if(pol.Policy_Series_Effective_Date__c.year() <= (pol.Effective_Date__c.year()-2)){
                    pol.ISBAM_policy_dividend__c = ((effectiveYearDividendPolicies.containsKey((pol.Effective_Date__c.year() - 1) + '-' + pol.Account__c) ? (effectiveYearDividendPolicies.get((pol.Effective_Date__c.year() - 1) + '-' + pol.Account__c)) : 0) + 
                        + (expirationYearDividendPolicies.containsKey((pol.Effective_Date__c.year() - 1) + '-' + pol.Account__c) ? (expirationYearDividendPolicies.get((pol.Effective_Date__c.year() - 1) + '-' + pol.Account__c)) : 0)).round(System.RoundingMode.HALF_UP);
                    System.debug(pol.ISBAM_policy_dividend__c);
                }
            }
            update batch;
        }else if(operation == 'Update Next Policy'){
            // soql = select id,Old_Policy__c from Policy__c where RecordType.Name = '\Policy\' and Old_Policy__c != null
            List<Policy__c> policies = new List<Policy__c>();
            for(Policy__c pol : (List<Policy__c>)batch){
                policies.add(new Policy__c(Id = pol.Old_Policy__c,Next_Policy__c = pol.Id));
            }
            update policies;
        }
    }
    public void finish(Database.BatchableContext BC) { 
    }
}