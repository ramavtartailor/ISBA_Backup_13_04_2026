/*
 * 
 * Created By     : Ali Zaidi
 * Created Date   : 11/20/2016
 * Purpose        : This class provides finder methods for accessing data in the Policy Lawyer object, and also the helper functions to implement trigger processes.
 * Name           : PolicyLawyerGateway
 * Referenced     : Currently at the time of creation this class is referenced by PolicyLawyerHandler.
 * 
 *  
 */
public without sharing class PolicyLawyerGateway {
    public static boolean allowDeleteLawyerFromEndorsement =  false;
    public static boolean boo = true;
    public static void validateAccount (Map<Id,SObject> newItems) {
        /*
         * 
        // Cast the map to list of policy endorsements.
        List<Policy_Lawyer__c> lstPolicyLawyers = (List<Policy_Lawyer__c>) newItems.values();
        // Variables used.
        Set<String> setPolicyIds = new Set<String>();
        Map<String,Policy__c> mapPolicyAccounts = new Map<String,Policy__c>();
        // Get the Policy Id's to SOQL Account on Policy.
        for (Policy_Lawyer__c polLaw : lstPolicyLawyers) {
            setPolicyIds.add(polLaw.Policy__c);                
        }
        
        // SOQL Account added on Policy to verify that they are same as on Policy Lawyer.
        for (Policy__c pol : [SELECT Id, Account__c FROM Policy__c WHERE Id IN: setPolicyIds]) {
            mapPolicyAccounts.put(pol.Id,pol);
        }
        
        // Check if Account are same otherwise display error.
        for (Policy_Lawyer__c polLaw : lstPolicyLawyers) {
            if (polLaw.Account__c != mapPolicyAccounts.get(polLaw.Policy__c).Account__c) {
                polLaw.addError('Account must be same as Policy.');
            }
        }*/
    }
    
    public static void validateLawyer (List<SObject> newItems) {
        // Cast the map to list of policy endorsements.
        List<Policy_Lawyer__c> lstPolicyLawyers = (List<Policy_Lawyer__c>) newItems;
        Set<Id> lawyerIds = new Set<Id>();
        // Used Varidables.
        Set<String> setPolicyIds = new Set<String>();
        Map<String,Set<String>> mapOfPolicyLawyers = new Map<String,Set<String>>();
        // Get the Policy Id's to SOQL Account on Policy.
        for (Policy_Lawyer__c polLaw : lstPolicyLawyers) {
            setPolicyIds.add(polLaw.Policy__c);        
            lawyerIds.add(polLaw.Lawyer__c);
        }
        // Get the Lawyers added on the Policy.
        for (Policy_Lawyer__c polLaw : [SELECT Id, Name, Policy__c, Lawyer__c, Deleted_Lawyer__c FROM Policy_Lawyer__c WHERE Policy__c IN: setPolicyIds AND Deleted_Date__c = null]) {
            if (mapOfPolicyLawyers.containsKey(polLaw.Policy__c)) {
                Set<String> polIds = new Set<String>();
                polIds = mapOfPolicyLawyers.get(polLaw.Policy__c);
                polIds.add(polLaw.Lawyer__c);
                mapOfPolicyLawyers.put(polLaw.Policy__c,polIds);
            } else {
                Set<String> polIds = new Set<String>();
                polIds.add(polLaw.Lawyer__c);
                mapOfPolicyLawyers.put(polLaw.Policy__c,polIds);
            }
        }
        
        Map<Id,AccountContactJunction__c> lawyersMap = new Map<Id,AccountContactJunction__c>([select id,Contact__r.LastName from AccountContactJunction__c where id in: lawyerIds]);
        
        // Check if lawyer id exist in the map.
        for (Policy_Lawyer__c polLaw : lstPolicyLawyers) {
            Set<String> polIds = new Set<String>();
            polIds = mapOfPolicyLawyers.get(polLaw.Policy__c);
            if (polIds != null) {
                if (polIds.contains(polLaw.Lawyer__c)) {
                    polLaw.addError('Lawyer Already Exists on Application/Policy.');
                }else if(lawyersMap.containsKey(polLaw.Lawyer__c)){
                    polLaw.LastName__c = lawyersMap.get(polLaw.Lawyer__c).Contact__r.LastName;
                }
            }
        }
    }
    
    public static void updateLatestPolicyOnLawyer(Map<Id,SObject> newItems){
        // Cast the map to list of policy endorsements.
        List<Policy_Lawyer__c> lstPolicyLawyers = (List<Policy_Lawyer__c>) newItems.values();
        system.debug(lstPolicyLawyers);
        //Set<AccountContactJunction__c> lawyersToUpdate = new Set<AccountContactJunction__c>();
        Map<String,AccountContactJunction__c> lawyersToUpdateMap = new Map<String, AccountContactJunction__c>(); 
        for(Policy_Lawyer__c lawyer : lstPolicyLawyers){
            AccountContactJunction__c acj = new AccountContactJunction__c();
            acj.Id=lawyer.Lawyer__c;
            if(lawyersToUpdateMap.containsKey(lawyer.Lawyer__c)){
                acj = lawyersToUpdateMap.get(lawyer.Lawyer__c);
            }
            
            if(!lawyer.Is_Application_Lawyer__c){
                //lawyersToUpdate.add(new AccountContactJunction__c(Id=lawyer.Lawyer__c, Latest_Policy__c =lawyer.Policy__c));
                acj.Latest_Policy__c =lawyer.Policy__c;
            }else{
                //lawyersToUpdate.add(new AccountContactJunction__c(Id=lawyer.Lawyer__c, Latest_Application__c =lawyer.Policy__c));
                acj.Latest_Application__c =lawyer.Policy__c;
            }
                
            lawyersToUpdateMap.put(lawyer.Lawyer__c, acj);
        }
        if(lawyersToUpdateMap.KeySet().size() > 0){
            System.debug('lawyersToUpdate => '+lawyersToUpdateMap.values());
            update new List<AccountContactJunction__c>(lawyersToUpdateMap.values());
        }
    }
    
    // Generate Lawyer Step for all the newly added lawyers.
    public static void generateLawyerStep (Map<Id,SObject> newItems) {
        // Cast the map to list of policy endorsements.
        List<Policy_Lawyer__c> lstPolicyLawyers = (List<Policy_Lawyer__c>) newItems.values();
        
        // Variable used.
        Set<Id> setPolicyLawyerIds = (new Map<Id,SObject>(lstPolicyLawyers)).keySet();
        List<Policy_Lawyer__c> lstPolicyLawyerToUpdate = new List<Policy_Lawyer__c>();
        
        // Traverse the lawyers added and generate step for each of them.
        for (Policy_Lawyer__c polLaw : [SELECT Id, Policy_Effective_Date__c, Prior_Act_Date__c, Step__c,Overriding_Step_Value__c FROM Policy_Lawyer__c WHERE Id IN: setPolicyLawyerIds]) {
            polLaw.Step__c = (ApplicationPolicyUtil.CalculateLawyerStep(polLaw.Policy_Effective_Date__c,polLaw.Prior_Act_Date__c) + (polLaw.Overriding_Step_Value__c!=null?Integer.valueOf(polLaw.Overriding_Step_Value__c):0))>7?7:(ApplicationPolicyUtil.CalculateLawyerStep(polLaw.Policy_Effective_Date__c,polLaw.Prior_Act_Date__c) + (polLaw.Overriding_Step_Value__c!=null?Integer.valueOf(polLaw.Overriding_Step_Value__c):0)) ;
            lstPolicyLawyerToUpdate.add(polLaw);
        }
        update lstPolicyLawyerToUpdate;
    }
    
    // Update Lawyer Step if the Prior Act Date or Policy Effective Date changes.
    public static void generateLawyerStep (Map<Id,SObject> oldItems,Map<Id,SObject> newItems) {
        // Cast the map to list of policy endorsements.
        List<Policy_Lawyer__c> lstNewPolicyLawyers = (List<Policy_Lawyer__c>) newItems.values();
        
        // Variable used.
        Set<Id> setPolicyLawyerIds = (new Map<Id,SObject>(lstNewPolicyLawyers)).keySet();
        List<Policy_Lawyer__c> lstPolicyLawyerToUpdate = new List<Policy_Lawyer__c>();
        Map<Id,Policy__c> policiesToUpdate = new Map<Id,Policy__c>();
        Set<Id> policyIds = new Set<Id>();
        // Traverse the lawyers added and generate step for each of them.
        for (Policy_Lawyer__c polLaw : lstNewPolicyLawyers) {
            Policy_Lawyer__c oldLaw = (Policy_Lawyer__c) oldItems.get(polLaw.Id);
            // Check if the Prior Act Date or Endorsement Effective Date has changed or not.
            System.debug(polLaw.Rate_At__c + '1111' );
            System.debug(oldLaw.Rate_At__c + '1111' );
            if (polLaw.Prior_Act_Date__c != oldLaw.Prior_Act_Date__c || polLaw.Policy_Effective_Date__c != oldLaw.Policy_Effective_Date__c || polLaw.Overriding_Step_Value__c!=oldLaw.Overriding_Step_Value__c ) {
                polLaw.Step__c = (ApplicationPolicyUtil.CalculateLawyerStep(polLaw.Policy_Effective_Date__c,polLaw.Prior_Act_Date__c) + (polLaw.Overriding_Step_Value__c!=null?Integer.valueOf(polLaw.Overriding_Step_Value__c):0))>7?7:(ApplicationPolicyUtil.CalculateLawyerStep(polLaw.Policy_Effective_Date__c,polLaw.Prior_Act_Date__c) + (polLaw.Overriding_Step_Value__c!=null?Integer.valueOf(polLaw.Overriding_Step_Value__c):0)) ;
            }
        }
    }
    
    public static void updatePremiumOnRateChange (Map<Id,SObject> oldItems,Map<Id,SObject> newItems) {
        // Cast the map to list of policy endorsements.
        List<Policy_Lawyer__c> lstNewPolicyLawyers = (List<Policy_Lawyer__c>) newItems.values();
        
        // Variable used.
        Set<Id> setPolicyLawyerIds = (new Map<Id,SObject>(lstNewPolicyLawyers)).keySet();
        Set<Id> policyIds = new Set<Id>();
        // Traverse the lawyers added and generate step for each of them.
        for (Policy_Lawyer__c polLaw : [SELECT Id, Policy_Effective_Date__c, Prior_Act_Date__c, Step__c,Overriding_Step_Value__c,Rate_At__C,Policy__c,Policy__r.RecordType.Name FROM Policy_Lawyer__c WHERE Id IN: setPolicyLawyerIds]) {
            Policy_Lawyer__c oldLaw = (Policy_Lawyer__c) oldItems.get(polLaw.Id);
            // Check if the Prior Act Date or Endorsement Effective Date has changed or not.
            System.debug(polLaw.Rate_At__c + '111' );
            System.debug(oldLaw.Rate_At__c + '111' );
            if((polLaw.Policy__r.RecordType.Name == 'Application' || polLaw.Policy__r.RecordType.Name == 'SA-ERP') && (polLaw.Rate_At__c!=oldLaw.Rate_At__c || polLaw.Prior_Act_Date__c != oldLaw.Prior_Act_Date__c || polLaw.Policy_Effective_Date__c != oldLaw.Policy_Effective_Date__c || polLaw.Overriding_Step_Value__c!=oldLaw.Overriding_Step_Value__c )){
                policyIds.add(polLaw.Policy__c);
            }
        }
        
        //if(policiesToUpdate.size()>0){
        if(policyIds.size() > 0){
            //update policiesToUpdate.values();
            List<String> fieldNames = new List<String>( Schema.getGlobalDescribe().get('Policy__c').getDescribe().fields.getMap().keySet() );
            String query =' SELECT ' +String.join( fieldNames, ',' ) +' FROM Policy__c'  +' WHERE ' +' Id in: policyIds ';
            List<Policy__c> policyList = Database.query(query);
            ApplicationPremiumCalculator.UpdateQuotePremium(policyList,policyIds);
        }
    }
    
    public static void preventLawyersDeletionForPolicy(List<Policy_Lawyer__c> oldItems){
        if(!allowDeleteLawyerFromEndorsement){
            Set<Id> policyIds = new Set<Id>();
            for(Policy_Lawyer__c lawyer : oldItems){
                policyIds.add(lawyer.Policy__c);
            }
            Map<Id,Policy__c> policyMap = new Map<Id,Policy__c>([select id,RecordType.Name from Policy__c where id in: policyIds]);
            for(Policy_Lawyer__c lawyer : oldItems){
                if(policyMap.containsKey(lawyer.Policy__c) && policyMap.get(lawyer.Policy__c).RecordType.Name == 'Policy'){
                    lawyer.addError('If you need to delete the Lawyer from the policy, please do it using the 153 endorsment.');
                }
            }
        }
    }
    
    public static void updateCLECredit(List<Policy_Lawyer__c> newItems){
        Set<Id> lawyerIds = new Set<Id>();
        Set<Id> policyIds = new Set<Id>();
        Map<Id,Id> lawyerContactMap = new Map<Id,Id>();
        for(Policy_Lawyer__c pol : newItems){
            if(pol.Is_Application_Lawyer__c){
                lawyerIds.add(pol.Lawyer__c);
                policyIds.add(pol.Policy__c);
            }
        }
        if(lawyerIds.size() > 0){
            Map<Id,Policy__c> policyMap = new Map<Id,Policy__c>([select id,Effective_Date__c from Policy__c where id in: policyIds and RecordType.Name = 'Application' and Application_Type__c = 'Renewal']);
            Map<Id,CLE_Attendance__c> attendanceMap = new Map<Id,CLE_Attendance__c>();
            for(AccountContactJunction__c law : [select id,Contact__c from AccountContactJunction__c where id=: lawyerIds]){
                lawyerContactMap.put(law.Id,law.Contact__c);
            }
            for(CLE_Attendance__c attendance : [select id,CLE_Event__r.Date__c,CLE_Event__r.Hours__c,Contact__c from CLE_Attendance__c where Contact__c in: lawyerContactMap.values() and Policy_Applied_To__c = null and CLE_Event__r.Hours__c > 0 order by CLE_Event__r.Date__c desc]){
                if(!attendanceMap.containsKey(attendance.Contact__c)){
                    attendanceMap.put(attendance.Contact__c,attendance);
                }
            }
            for(Policy_Lawyer__c pol : newItems){
                if(pol.Is_Application_Lawyer__c){
                    if(lawyerContactMap.containsKey(pol.Lawyer__c) && attendanceMap.containsKey(lawyerContactMap.get(pol.Lawyer__c)) && policyMap.containsKey(pol.Policy__c)){
                        if(attendanceMap.get(lawyerContactMap.get(pol.Lawyer__c)).CLE_Event__r.Date__c <= policyMap.get(pol.Policy__c).Effective_Date__c.addMonths(-3) && attendanceMap.get(lawyerContactMap.get(pol.Lawyer__c)).CLE_Event__r.Date__c > policyMap.get(pol.Policy__c).Effective_Date__c.addMonths(-15)){
                            //pol.CLE_Credit__c = 100;
                        }
                    }
                }
            }
        }
    }
}