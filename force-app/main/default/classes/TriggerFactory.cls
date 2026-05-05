/*
* 
* Created By     : Ali Zaidi
* Created Date   : 11/19/2016
* Purpose        : This class is wsed to instantiate and execute Trigger Handlers associated with sObjects.
* Name           : TriggerFactory
* Referenced     : Currently at the time of creation this class is referenced by Account Trigger.
* 
*  
*/
public without sharing class TriggerFactory {
    /*
this methods use to update policy Premium when we create OR update a Quote
Modified Date 19 April 2017
*/
    // Loop stop variable from update policy
    public Static Boolean isUpdatePremium = true;
    public static List<ILF_Coverage_Factor__c> ilfFactorsCoverage;
    public static Integer policyBaseAmount;
    public static List<Master_factor__C> baseValueFactorList;
    public static List<ILF_Coverage_Factor__c> getCoverageFactorsList(){
        if(ilfFactorsCoverage == null){
            ilfFactorsCoverage = [select ID,Master_Factor__c,name,Factor_Value__c,
                                  Full_Coverage__c,Coverage_Max_Per_Claim__c ,
                                  Is_Excess_Value_Zero__c,
                                  Is_5X5_Coverage__c,                                                 
                                  Percentage_5X5_Step_0__c,Percentage_5X5_Step_1__c,
                                  Percentage_5X5_Step_2__c,Percentage_5X5_Step_3__c,
                                  Percentage_5X5_Step_4__c,Percentage_5X5_Step_5__c,
                                  Percentage_5X5_Step_6__c,Percentage_5X5_Step_7__c,            
                                  Premium_Rate_5X5__c,
                                  Percnt_amt_5X5_Step_0__c,
                                  Percnt_amt_5X5_Step_1__c,
                                  Percnt_amt_5X5_Step_2__c,
                                  Percnt_amt_5X5_Step_3__c,
                                  Percnt_amt_5X5_Step_4__c,Percnt_amt_5X5_Step_5__c,
                                  Percnt_amt_5X5_Step_6__c,Percnt_amt_5X5_Step_7__c,Lowest_Coverage__c,Mid_Coverage__c,X4x1_Rate__c
                                  from ILF_Coverage_Factor__c];
        }
        return ilfFactorsCoverage;
    }
    public static List<ILF_Coverage_Factor__c> getCoverageFactors(Set<ID> CoverageFactorIDSet){
        List<ILF_Coverage_Factor__c> coverageFactor = new List<ILF_Coverage_Factor__c>();
        for(ILF_Coverage_Factor__c factor : getCoverageFactorsList()){
            if(CoverageFactorIDSet.contains(factor.Id)){
                coverageFactor.add(factor);
            }
        }
        return coverageFactor;
    }
    
    public static List<ILF_Coverage_Factor__c> getLowerCoverageFactors(Set<ID> CoverageFactor_ParentIDSet){
        List<ILF_Coverage_Factor__c> coverageFactor = new List<ILF_Coverage_Factor__c>();
        for(ILF_Coverage_Factor__c factor : getCoverageFactorsList()){
            if(CoverageFactor_ParentIDSet.contains(factor.Master_Factor__c) && factor.Lowest_Coverage__c ){
                coverageFactor.add(factor);
            }
        }
        return coverageFactor;
    }
    public static List<ILF_Coverage_Factor__c> getMidCoverageFactors(Set<ID> CoverageFactor_ParentIDSet){
        List<ILF_Coverage_Factor__c> coverageFactor = new List<ILF_Coverage_Factor__c>();
        for(ILF_Coverage_Factor__c factor : getCoverageFactorsList()){
            if(CoverageFactor_ParentIDSet.contains(factor.Master_Factor__c) && factor.Mid_Coverage__c){
                coverageFactor.add(factor);
            }
        }
        return coverageFactor;
    }
    public static Integer GetPolicyBaseAmt(){
        if(policyBaseAmount == null){
            Master_factor__C MasterFactorBaseObj =  [select (select id,Base_Amount__c 
                                                             from Base_Factors__r 
                                                             limit 1) 
                                                     from Master_Factor__c 
                                                     where Default__c=true 
                                                     and Factor_Type__c='Base Value' 
                                                     limit 1];               
            Base_Factor__c   BaseFactorObj =  MasterFactorBaseObj.Base_Factors__r; 
            policyBaseAmount = Integer.valueOf(BaseFactorObj.Base_Amount__c) ;
        }
        return policyBaseAmount;
    }
    public static List<Master_factor__C> getBaseValueMasterFactor(){
        if(baseValueFactorList == null){
            baseValueFactorList = [select From_Date__c,To_Date__c,(select id,Base_Amount__c 
                                                                   from Base_Factors__r 
                                                                   limit 1) 
                                   from Master_Factor__c 
                                   where Factor_Type__c='Base Value'];
        }
        return baseValueFactorList;
    }
    public void updatePremiumOfPolicy(){
        // Trigger context variable 
        List<Policy_Quote__c> processList = New List<Policy_Quote__c>();
        List<Policy_Quote__c> QuoteFinalCheckedLst = new List<Policy_Quote__c>();
        List<Policy__c> policyList = New List<Policy__c>();
        Map<id,Policy_Quote__c > PolicyMap = New Map<id,Policy_Quote__c >();
        system.debug('======isUpdatePremium ======'+isUpdatePremium );
        //if(isUpdatePremium ){
        system.debug('===enter==='+(Boolean)Trigger.IsAfter);
        if((Boolean)Trigger.IsAfter){
            system.debug('======enter1======');
            if((Boolean)Trigger.IsInsert || (Boolean)Trigger.IsUpdate || (Boolean)Trigger.IsUndelete){
                processList = (List<Policy_Quote__c>)Trigger.New;
            }else if((Boolean)Trigger.IsDelete){
                processList = (List<Policy_Quote__c>)Trigger.old;
            }
            if(!processList.IsEmpty()){
                for(Policy_Quote__c pq : processList){
                    if( pq.Policy__c != null && PolicyMap.Containskey(pq.Policy__c) == False)
                        policyList.add(New Policy__c(Id = pq.Policy__c,is_allow_calculate_premium__C = true));
                    PolicyMap.put(pq.Policy__c, pq);
                    if(pq.Final_Quote__c){
                        QuoteFinalCheckedLst.add(pq);
                    }
                    System.debug(pq);
                }
            }
            System.debug(isUpdatePremium);
            if(!policyList.IsEmpty() && isUpdatePremium){
                System.debug('2----TriggerFactory');
                //update policyList;
                //policyList = [select id,Effective_Date__c,Expiration_Date__c,AOP_Factor__c, from Policy__c where id in: PolicyMap.keySet()];
                List<String> fieldNames = new List<String>( Schema.getGlobalDescribe().get('Policy__c').getDescribe().fields.getMap().keySet() );
                String query =' SELECT ' +String.join( fieldNames, ',' ) +' FROM Policy__c'  +' WHERE ' +' Id in: policyList ';
                policyList = Database.query(query);
                TriggerFactory.isUpdatePremium = false;
                ApplicationPremiumCalculator.UpdateQuotePremium(policyList,PolicyMap.keySet());
            }
            if(!QuoteFinalCheckedLst.isEmpty()){
                ApplicationPolicyUtil.UpdateFinalQuoteToPolicy(QuoteFinalCheckedLst,False); 
            }
            System.debug(processList);
        }
        //}
    }
    
    /*
* Public static method to create and execute a trigger handler
*
* Arguments:   Schema.sObjectType soType - Object type to process (SObject.sObjectType)
*
* Throws a TriggerException if no handler has been coded.
*/
    public static void createHandler(Schema.sObjectType soType) {
        // Get a handler appropriate to the object being processed
        ITrigger handler = getHandler(soType);
        System.debug('handler==>'+handler);
        // Make sure we have a handler registered, new handlers must be registered in the getHandler method.
        if (handler == null)
        {
            throw new TriggerException('No Trigger Handler registered for Object Type: ' + soType);
        }
        
        // Get the Custom Setting to see if the trigger is enabled on not.
        Trigger_Setup__c trgSetup = new Trigger_Setup__c();
        Boolean IsEnabled;
        // Start - added by Shoukat 2/12/2017        
        //if (Test.isRunningTest()) {
        //  execute(handler);
        //} else {        
        // end - added by Shoukat 2/12/2017        
        try {
            //trgSetup = [SELECT Id, AccountContactJunction_Trigger_Disabled__c, Account_Trigger_Disabled__c, Endorsement_Trigger_Disabled__c, Opportunity_Trigger_Disabled__c, Policy_Claim_Detail_Trigger_Disabled__c, Policy_Claim_Trigger_Disabled__c, Policy_Endorsement_Trigger_Disabled__c, Policy_Lawyer_Trigger_Disabled__c, Policy_Quote_Trigger_Disabled__c, Policy_Trigger_Disabled__c, Quick_Quote_Trigger_Disabled__c FROM Trigger_Setup__c];
            IsEnabled = true;
        } catch (Exception e) {
            system.debug('Line 166 test -> '+e.getMessage() + e.getLineNumber());
            IsEnabled = false;
        }
        
        // Check the trgSetup accourding to the soType.
        if (soType == Account.sObjectType) {
            isEnabled = !(Trigger_Setup__c.getInstance().Account_Trigger_Disabled__c);
        } else if (soType == Policy_Endorsement__c.sObjectType) {
            isEnabled = !(Trigger_Setup__c.getInstance().Policy_Endorsement_Trigger_Disabled__c);
        } else if (soType == Endorsement__c.sObjectType) {
            isEnabled = !(Trigger_Setup__c.getInstance().Endorsement_Trigger_Disabled__c);
        } else if (soType == Policy_Claim__c.sObjectType) {
            isEnabled = !(Trigger_Setup__c.getInstance().Policy_Claim_Trigger_Disabled__c);
        } else if (soType == Policy_Claim_Detail__c.sObjectType) {
            isEnabled = !(Trigger_Setup__c.getInstance().Policy_Claim_Detail_Trigger_Disabled__c);
        } else if (soType == Policy_Quote__c.sObjectType) {
            isEnabled = !(Trigger_Setup__c.getInstance().Policy_Quote_Trigger_Disabled__c);
        } else if (soType == Policy_Lawyer__c.sObjectType) {
            isEnabled = !(Trigger_Setup__c.getInstance().Policy_Lawyer_Trigger_Disabled__c);
        } else if (soType == AccountContactJunction__c.sObjectType) {
            isEnabled = !(Trigger_Setup__c.getInstance().AccountContactJunction_Trigger_Disabled__c);
        } /*else if (soType == Quick_Quote__c.sObjectType) {
isEnabled = !(Trigger_Setup__c.getInstance().Quick_Quote_Trigger_Disabled__c);
}*/
        System.debug('isEnabled==>'+isEnabled);
        // Execute the handler to fulfil the trigger
        if (isEnabled == true) {
            execute(handler);
        }
        //}
    }
    
    /*
* private static method to control the execution of the handler
*
* Arguments:   ITrigger handler - A Trigger Handler to execute
*/ 
    private static void execute(ITrigger handler) {
        // Before Trigger
        if (Trigger.isBefore) {
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();
            
            // Iterate through the records to be deleted passing them to the handler.
            if (Trigger.isDelete) {
                handler.beforeDelete(Trigger.oldMap);
            }
            // Iterate through the records to be inserted passing them to the handler.
            else if (Trigger.isInsert) {
                System.debug('Before--Insert-Trigger.new====>'+Trigger.new);
                handler.beforeInsert(Trigger.new);
            }
            // Iterate through the records to be updated passing them to the handler.
            else if (Trigger.isUpdate) {
                handler.beforeUpdate(Trigger.oldMap, Trigger.newMap);
            }
        } else if (Trigger.isAfter) {
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();
            
            // Iterate through the records deleted passing them to the handler.
            if (Trigger.isDelete) {
                handler.afterDelete(Trigger.oldMap);
            }
            // Iterate through the records inserted passing them to the handler.
            else if (Trigger.isInsert) {
                System.debug('Before--Insert-Trigger.newMap====>'+Trigger.newMap);
                handler.afterInsert(Trigger.newMap);
            }
            // Iterate through the records updated passing them to the handler.
            else if (Trigger.isUpdate) {
                system.debug('=====old map==='+Trigger.oldMap);
                system.debug('=====new map==='+Trigger.newMap);
                handler.afterUpdate(Trigger.oldMap, Trigger.newMap);
            }
        }
        
        // Perform any post processing
        handler.andFinally();
    }
    
    /*
* private static method to get the appropriate handler for the object type.
* Modify this method to add any additional handlers.
*
* Arguments:   Schema.sObjectType soType - Object type tolocate (SObject.sObjectType)
*
* Returns:     ITrigger - A trigger handler if one exists or null.
*/
    private static ITrigger getHandler(Schema.sObjectType soType) {
        if (soType == Account.sObjectType) {
            return new AccountHandler();
        } else if (soType == Policy_Endorsement__c.sObjectType) {
            System.debug('2---TriggerFactory');
            return new PolicyEndorsementHandler();
        } else if (soType == Endorsement__c.sObjectType) {
            return new EndorsementHandler();
        } else if (soType == Policy_Claim__c.sObjectType) {
            return new Policy_Claim_Handler();
        } else if (soType == Policy_Claim_Detail__c.sObjectType) {
            return new Policy_Claim_Detail_Handler();
        } else if (soType == Policy_Quote__c.sObjectType) {
            return new Policy_Quote_Handler();
        } else if (soType == Policy_Lawyer__c.sObjectType) {
            return new PolicyLawyerHandler();
        } else if (soType == AccountContactJunction__c.sObjectType) {
            return new AccountContactJunctionHandler();
        } /*else if (soType == Quick_Quote__c.sObjectType) {
System.debug('1---QuickQuoteHandler');
return new QuickQuoteHandler();
}*/
        
        return null;
    }
    
    public class TriggerException extends Exception {}
}