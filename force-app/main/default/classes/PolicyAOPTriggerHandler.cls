public class PolicyAOPTriggerHandler {
    public static void onBeforeDelete(List<Policy_AOP__c> oldList){
        preventAOPDeletionForPolicy(oldList);
    }
    public static void onBeforeInsert(List<Policy_AOP__c> newList){
        updatePercentageValue(newList);
    }
    public static void onBeforeUpdate(List<Policy_AOP__c> newList,Map<Id,Policy_AOP__c> newMap){
        updatePercentageValue(newList);
    }
    public static void preventAOPDeletionForPolicy(List<Policy_AOP__c> oldList){
        Set<Id> policyIds = new Set<Id>();
        for(Policy_AOP__c aop : oldList){
            policyIds.add(aop.Policy__c);
        }
        Map<Id,Policy__c> policyMap = new Map<Id,Policy__c>([select id,RecordType.Name from Policy__c where id in: policyIds]);
        for(Policy_AOP__c aop : oldList){
            if(policyMap.containsKey(aop.Policy__c) && policyMap.get(aop.Policy__c).RecordType.Name == 'Policy'){
                aop.addError('You are not allowed to delete the AOP once the Application is bound.');
            }
        }
    }
    public static void updatePercentageValue(List<Policy_AOP__c> newList){
        Map<ID,AOP_Factor__c>  AOPFactorMap  = new  Map<ID,AOP_Factor__c>([select ID,name,AOP_Mod__c from AOP_Factor__C]);
        For(Policy_AOP__C PolicyAOPFor : newList){
            PolicyAOPFor.Factor_Mod__c = AOPFactorMap.get(PolicyAOPFor.AOP__c).AOP_Mod__c;
            
            if(PolicyAOPFor.Factor_Mod__c == null){
                PolicyAOPFor.Factor_Mod__c = 0;
            }
            PolicyAOPFor.Percentage_Value__c = PolicyAOPFor.Factor_Mod__c *   PolicyAOPFor.Percentage__c / 100;          
        }
    }
}