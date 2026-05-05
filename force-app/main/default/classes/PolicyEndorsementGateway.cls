/*
 * 
 * Created By     : Ali Zaidi
 * Created Date   : 11/20/2016
 * Purpose        : This class provides finder methods for accessing data in the Policy Endorsement object, and also the helper functions to implement trigger processes.
 * Name           : PolicyEndorsementGateway
 * Referenced     : Currently at the time of creation this class is referenced by PolicyEndorsementHandler.
 * 
 *  
 */
public without sharing class PolicyEndorsementGateway {
    
    // Function will verify updates on the policy endorsements and update version and conga template accordingly.
    public static void updateEndorsementVersion (Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {
        // Cast the map to list of policy endorsements.
        system.debug('updateEndorsementVersion called');
        List<Policy_Endorsement__c> lstNewPolicyEndorsements = (List<Policy_Endorsement__c>) newItems.values();
        Map<Id,SObject> mapEndorsementToUpdate = new Map<Id,SObject>();
        
        system.debug('--------new values-----'+newItems.values());
        
        for (Policy_Endorsement__c polEnd : lstNewPolicyEndorsements) {
            Policy_Endorsement__c oldEnd = (Policy_Endorsement__c) oldItems.get(polEnd.Id);
            
            if (polEnd.Endorsement_Effective_Date__c != oldEnd.Endorsement_Effective_Date__c) {
                mapEndorsementToUpdate.put(polEnd.Id, polEnd);
            }
        }
        
        if (mapEndorsementToUpdate.values().size() > 0) {
            setEndorsementVersion(mapEndorsementToUpdate);
        }
    }
    
    // Fucntion will fetch appropriate Conga Template based on the Endorsement Effective date and Endorsement Version.
    public static void setEndorsementVersion (Map<Id,SObject> newItems) {
        // Cast the map to list of policy endorsements.
        system.debug('setEndorsementVersion called');
        List<Policy_Endorsement__c> lstNewPolicyEndorsements = (List<Policy_Endorsement__c>) newItems.values();
        
        system.debug('===========value====='+lstNewPolicyEndorsements);
        
        // Variables used.
        Set<String> setPolicyEndorsementIds = new Set<String>();
        Set<String> setRecordTypeIds = new Set<String>();
        Set<String> setMasterEndorsementIds = new Set<String>();
        Map<String,Endorsement__c> mapRTMasterEndorsement = new Map<String,Endorsement__c>();
        Map<String,List<Endorsement_Version__c>> mapMasterEndorsementVersion = new Map<String,List<Endorsement_Version__c>>();
        List<Policy_Endorsement__c> policyEndorsementsToUpdate = new List<Policy_Endorsement__c>();
        
        // Fill the sets with policy endorsement ids and recordtype ids to get the master endorsement records.
        for (Policy_Endorsement__c polEnd : lstNewPolicyEndorsements) {
            setPolicyEndorsementIds.add(polEnd.Id);
            setRecordTypeIds.add(polEnd.RecordTypeId);
        }
        
        system.debug('==========setRecordTypeIds======'+setRecordTypeIds);
        
        // Fetch the master endorsement to fill the map and set to get the endorsement version records.
        for (Endorsement__c masEnd : [SELECT Description__c, Endorsement_Record_Type_ID__c, Endorsement_Sub_Type__c, Id, Name, Type__c FROM Endorsement__c WHERE Endorsement_Record_Type_ID__c IN :setRecordTypeIds]) {
            system.debug('Inside for loop');
            setMasterEndorsementIds.add(masEnd.Id);
            mapRTMasterEndorsement.put(masEnd.Endorsement_Record_Type_ID__c, masEnd);
        }
       
        system.debug('=============setMasterEndorsementIds======'+setMasterEndorsementIds);
        
        // Fetch the endorsement version records and fill the map.
        for (Endorsement_Version__c endVer : [SELECT Effective_From__c, Endorsement_Version_Number__c, Id, Master_Endorsement__c, Name, Policy_Version__c FROM Endorsement_Version__c WHERE Master_Endorsement__c IN :setMasterEndorsementIds]) {
            System.debug('===endVer==='+endVer);
            if (mapMasterEndorsementVersion.containsKey(endVer.Master_Endorsement__c)) {
                List<Endorsement_Version__c> lstEndorsementVersions = mapMasterEndorsementVersion.get(endVer.Master_Endorsement__c);
                lstEndorsementVersions.add(endVer);
                mapMasterEndorsementVersion.put(endVer.Master_Endorsement__c, lstEndorsementVersions);
            } else {
                List<Endorsement_Version__c> lstEndorsementVersions = new List<Endorsement_Version__c>();
                lstEndorsementVersions.add(endVer);
                mapMasterEndorsementVersion.put(endVer.Master_Endorsement__c, lstEndorsementVersions);
            }
        }
        
        // Query the Policy Endorsement records to fill the Name, Endorsement Number, Endorsement Version and Conga Template Field.
        for (Policy_Endorsement__c polEnd : [SELECT Id, Name, Endorsement_Effective_Date__c, Endorsement_Name__c, Endorsement_Number__c, Endorsement_Version__c, RecordTypeId,RecordType.Name,Policy__r.Policy_Document_Version__c FROM Policy_Endorsement__c WHERE Id IN: setPolicyEndorsementIds]) {
            Endorsement__c masEnd = new Endorsement__c();
            Endorsement_Version__c versionToUse = new Endorsement_version__c();
            masEnd = mapRTMasterEndorsement.get(polEnd.RecordTypeId);
            
            system.debug('=======mapMasterEndorsementVersion======='+mapMasterEndorsementVersion);
            if ( mapMasterEndorsementVersion.containsKey(masEnd.Id)){
                if(mapMasterEndorsementVersion.get(masEnd.Id).size() > 0) {
                system.debug('Endorsement Version: ' + mapMasterEndorsementVersion.get(masEnd.Id));
                // Iterate all the version and get the appropriate version that is to be used.
                for (Endorsement_Version__c endVer : mapMasterEndorsementVersion.get(masEnd.Id)) {
                    if (versionToUse.Id == null) {
                        versionToUse = endVer;
                    } else {
                        if (endVer.Effective_From__c <= polEnd.Endorsement_Effective_Date__c && endVer.Effective_From__c > versionToUse.Effective_From__c && endVer.Policy_Version__c == polEnd.Policy__r.Policy_Document_Version__c) {
                            versionToUse = endVer;
                        }
                    }
                }
                
                polEnd.Name = masEnd.Endorsement_Sub_Type__c + ' ' + versionToUse.Endorsement_Version_Number__c + ' ' + masEnd.Name;
                
                    if(polEnd.Name.length() > 80 ){
                        polEnd.Name = polEnd.Name.substring(0, 80);
                    }    
                    
                polEnd.Endorsement_Name__c = masEnd.Name;
                polEnd.Endorsement_Number__c = masEnd.Endorsement_Sub_Type__c;
                polEnd.Endorsement_Version__c = versionToUse.Endorsement_Version_Number__c;
                //polEnd.Conga_Template_Id__c = versionToUse.Conga_Template__c;

                policyEndorsementsToUpdate.add(polEnd);
            } }else if(!test.isRunningTest()){
                polEnd.Name = masEnd.Name;
                
                policyEndorsementsToUpdate.add(polEnd);
            }
        }
        if (policyEndorsementsToUpdate.size() > 0) {
            system.debug('policyEndorsement = >'+policyEndorsementsToUpdate);
            update policyEndorsementsToUpdate;
            /*Database.SaveResult [] insertResult = Database.update(policyEndorsementsToUpdate,false);
            for(integer idx = 0; idx < insertResult.size(); idx++) {
                if(!insertResult[idx].isSuccess()) {
                    Trigger.new[idx].addError(insertResult[idx].getErrors()[0].getMessage());
                }
            }*/
        }
    }
    
    // Function will verify updates on the policy endorsements.
    public static void updatePolicyEndorsements (Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {
        // Cast the map to list of policy endorsements.
        system.debug('updatePolicyEndorsements called');
        List<Policy_Endorsement__c> lstNewPolicyEndorsements = (List<Policy_Endorsement__c>) newItems.values();
        
        Set<String> setRecordTypeIds = new Set<String>();
        Set<String> setPolicyEndorsementIdsToUpdate = new Set<String>();
        Map<String,Endorsement__c> mapMasterEndorsement = new Map<String,Endorsement__c>();
        Map<Id,SObject> newItemsToUpdate = new Map<Id,SObject>();
        
        // Fill the set of record type ids from the trigger context list.
        for (Policy_Endorsement__c polEnd : lstNewPolicyEndorsements) {
            setRecordTypeIds.add(polEnd.RecordTypeId);
        }
        
        // Fetch the master endorsement records for all the ids in the set.
        for (Endorsement__c masterEnd : [SELECT Id, Name, Type__c, Endorsement_Sub_Type__c, Endorsement_Record_Type_ID__c FROM Endorsement__c WHERE Endorsement_Record_Type_ID__c IN: setRecordTypeIds]) {
            mapMasterEndorsement.put(masterEnd.Endorsement_Record_Type_ID__c, masterEnd);
        }
        
        Profile prof = [select id,name from Profile where id =:  UserInfo.getProfileId() ];
        
        // Check if Policy Endorsement Type is functional and then make list of all endorsements depending on sub types to send to related helper fucntions.
        for (Policy_Endorsement__c polEnd : lstNewPolicyEndorsements) {
            // Get the master endorsement record to compare type and sub type.
            Endorsement__c currentEnd = mapMasterEndorsement.get(polEnd.RecordTypeId);
            // Get the old policy endorsement record to validate the update.
            Policy_Endorsement__c oldEnd = (Policy_Endorsement__c) oldItems.get(polEnd.Id);
            // Check if the master record is of type 'Functional'.
            system.debug('----type----'+currentEnd.Type__c);
            if (currentEnd.Type__c == 'Functional') {
            system.debug('----sub type---'+currentEnd.Endorsement_Sub_Type__c);
                // Check the sub type to identify the function to perform and fill the related list.
                if (currentEnd.Endorsement_Sub_Type__c == 'IL 152') {
                    System.debug('polEnd.Event_Status__c'+polEnd.Event_Status__c);
                        System.debug('oldEnd.Event_Status__c'+oldEnd.Event_Status__c);
                    if (polEnd.Event_Status__c == 'Pending') {
                        system.debug('------new---------'+polEnd.Effective_Date__c+'------old------'+oldEnd.Effective_Date__c);
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Lawyer__c != oldEnd.Lawyer__c || polEnd.Rate_At__c != oldEnd.Rate_At__c || polEnd.Prior_Act_Date__c != oldEnd.Prior_Act_Date__c || polEnd.Step_Override__c != oldEnd.Step_Override__c || polEnd.Step_Override_Value__c != oldEnd.Step_Override_Value__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c) {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                             System.debug('==polEnd.Event_Status__c'+polEnd.Event_Status__c);
                        System.debug('==oldEnd.Event_Status__c'+oldEnd.Event_Status__c);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c != oldEnd.Event_Status__c) {
                        System.debug('==polEnd.Event_Status__c== '+polEnd.Event_Status__c );
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Lawyer__c != oldEnd.Lawyer__c || polEnd.Rate_At__c != oldEnd.Rate_At__c || polEnd.Prior_Act_Date__c != oldEnd.Prior_Act_Date__c || polEnd.Step_Override__c != oldEnd.Step_Override__c || polEnd.Step_Override_Value__c != oldEnd.Step_Override_Value__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c) {
                            polEnd.addError('Cannot change the calculation values while completing an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Void') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Lawyer__c != oldEnd.Lawyer__c || polEnd.Rate_At__c != oldEnd.Rate_At__c || polEnd.Prior_Act_Date__c != oldEnd.Prior_Act_Date__c || polEnd.Step_Override__c != oldEnd.Step_Override__c || polEnd.Step_Override_Value__c != oldEnd.Step_Override_Value__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c) {
                            polEnd.addError('Cannot change the calculation values while voiding an endorsement.');
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && (polEnd.Event_Status__c == oldEnd.Event_Status__c && polEnd.Policy_Lawyer__c ==  oldEnd.Policy_Lawyer__c) && prof.Name != 'System Administrator' && polEnd.Accounting_Processed__c == oldEnd.Accounting_Processed__c) {
                        polEnd.addError('Policy Endorsment is already completed.');
                    }
                } else if (currentEnd.Endorsement_Sub_Type__c == 'IL 151') {   // added by SH
                    if (polEnd.Event_Status__c == 'Pending') {
                        // comment code becuase no need any calculation in pending case
                        //if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Policy_Lawyer__c != oldEnd.Policy_Lawyer__c || polEnd.Rate_At__c != oldEnd.Rate_At__c || polEnd.Prior_Act_Date__c != oldEnd.Prior_Act_Date__c || polEnd.Step_Override__c != oldEnd.Step_Override__c || polEnd.Step_Override_Value__c != oldEnd.Step_Override_Value__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c) {
                        //      setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        // }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c != oldEnd.Event_Status__c) {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c ||  polEnd.Account_Name__c != oldEnd.Account_Name__c || polEnd.Account_Billing_Street__c != oldEnd.Account_Billing_Street__c || polEnd.Account_Billing_State__c != oldEnd.Account_Billing_State__c || polEnd.Account_Billing_PostalCode__c != oldEnd.Account_Billing_PostalCode__c || polEnd.Account_Billing_City__c != oldEnd.Account_Billing_City__c ) {
                            polEnd.addError('Cannot change values while completing an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                            
                        }
                    } else if (polEnd.Event_Status__c == 'Void') {
                        //if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Policy_Lawyer__c != oldEnd.Policy_Lawyer__c || polEnd.Rate_At__c != oldEnd.Rate_At__c || polEnd.Prior_Act_Date__c != oldEnd.Prior_Act_Date__c || polEnd.Step_Override__c != oldEnd.Step_Override__c || polEnd.Step_Override_Value__c != oldEnd.Step_Override_Value__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c) {
                        //    polEnd.addError('Cannot change the calculation values while voiding an endorsement.');
                       // }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c == oldEnd.Event_Status__c  && prof.Name != 'System Administrator') {
                        polEnd.addError('Policy Endorsment is already completed.');
                    }

                } else if (currentEnd.Endorsement_Sub_Type__c == 'IL 151A') {   // added by SH
                    if (polEnd.Event_Status__c == 'Pending') {
                        // comment code becuase no need any calculation in pending case
                        //if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Policy_Lawyer__c != oldEnd.Policy_Lawyer__c || polEnd.Rate_At__c != oldEnd.Rate_At__c || polEnd.Prior_Act_Date__c != oldEnd.Prior_Act_Date__c || polEnd.Step_Override__c != oldEnd.Step_Override__c || polEnd.Step_Override_Value__c != oldEnd.Step_Override_Value__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c) {
                         //      setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        // }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c != oldEnd.Event_Status__c) {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c ||  polEnd.Account_Name__c != oldEnd.Account_Name__c || polEnd.Account_Billing_Street__c != oldEnd.Account_Billing_Street__c || polEnd.Account_Billing_State__c != oldEnd.Account_Billing_State__c || polEnd.Account_Billing_PostalCode__c != oldEnd.Account_Billing_PostalCode__c || polEnd.Account_Billing_City__c != oldEnd.Account_Billing_City__c ) {
                            polEnd.addError('Cannot change values while completing an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                            
                        }
                    } else if (polEnd.Event_Status__c == 'Void') {
                        //if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Policy_Lawyer__c != oldEnd.Policy_Lawyer__c || polEnd.Rate_At__c != oldEnd.Rate_At__c || polEnd.Prior_Act_Date__c != oldEnd.Prior_Act_Date__c || polEnd.Step_Override__c != oldEnd.Step_Override__c || polEnd.Step_Override_Value__c != oldEnd.Step_Override_Value__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c) {
                        //    polEnd.addError('Cannot change the calculation values while voiding an endorsement.');
                       // }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c == oldEnd.Event_Status__c  && prof.Name != 'System Administrator') {
                        polEnd.addError('Policy Endorsment is already completed.');
                    }

                } else if (currentEnd.Endorsement_Sub_Type__c == 'Change Lawyer') {
                    if (polEnd.Event_Status__c == 'Pending') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Policy_Lawyer__c != oldEnd.Policy_Lawyer__c || polEnd.Rate_At__c != oldEnd.Rate_At__c || polEnd.Prior_Act_Date__c != oldEnd.Prior_Act_Date__c || polEnd.Step_Override__c != oldEnd.Step_Override__c || polEnd.Step_Override_Value__c != oldEnd.Step_Override_Value__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c) {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c != oldEnd.Event_Status__c) {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Policy_Lawyer__c != oldEnd.Policy_Lawyer__c || polEnd.Rate_At__c != oldEnd.Rate_At__c || polEnd.Prior_Act_Date__c != oldEnd.Prior_Act_Date__c || polEnd.Step_Override__c != oldEnd.Step_Override__c || polEnd.Step_Override_Value__c != oldEnd.Step_Override_Value__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c) {
                            polEnd.addError('Cannot change the calculation values while completing an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Void') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Policy_Lawyer__c != oldEnd.Policy_Lawyer__c || polEnd.Rate_At__c != oldEnd.Rate_At__c || polEnd.Prior_Act_Date__c != oldEnd.Prior_Act_Date__c || polEnd.Step_Override__c != oldEnd.Step_Override__c || polEnd.Step_Override_Value__c != oldEnd.Step_Override_Value__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c) {
                            polEnd.addError('Cannot change the calculation values while voiding an endorsement.');
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c == oldEnd.Event_Status__c  && prof.Name != 'System Administrator') {
                        polEnd.addError('Policy Endorsment is already completed.');
                    }
                } else if (currentEnd.Endorsement_Sub_Type__c == 'IL 153') {
                    if (polEnd.Event_Status__c == 'Pending') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Lawyer__c != oldEnd.Lawyer__c || polEnd.Rate_At__c != oldEnd.Rate_At__c || polEnd.Prior_Act_Date__c != oldEnd.Prior_Act_Date__c || polEnd.Step_Override__c != oldEnd.Step_Override__c || polEnd.Step_Override_Value__c != oldEnd.Step_Override_Value__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c) {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c != oldEnd.Event_Status__c) {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Lawyer__c != oldEnd.Lawyer__c || polEnd.Rate_At__c != oldEnd.Rate_At__c || polEnd.Prior_Act_Date__c != oldEnd.Prior_Act_Date__c || polEnd.Step_Override__c != oldEnd.Step_Override__c || polEnd.Step_Override_Value__c != oldEnd.Step_Override_Value__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c) {
                            polEnd.addError('Cannot change the calculation values while completing an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Void') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Lawyer__c != oldEnd.Lawyer__c || polEnd.Rate_At__c != oldEnd.Rate_At__c || polEnd.Prior_Act_Date__c != oldEnd.Prior_Act_Date__c || polEnd.Step_Override__c != oldEnd.Step_Override__c || polEnd.Step_Override_Value__c != oldEnd.Step_Override_Value__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c) {
                            polEnd.addError('Cannot change the calculation values while voiding an endorsement.');
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c == oldEnd.Event_Status__c  && prof.Name != 'System Administrator'  && polEnd.Accounting_Processed__c == oldEnd.Accounting_Processed__c) {
                        polEnd.addError('Policy Endorsment is already completed.');
                    }
                } else if (currentEnd.Endorsement_Sub_Type__c == 'Adjust Premium') {
                    if (polEnd.Event_Status__c == 'Pending') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Primary__c != oldEnd.Primary__c || polEnd.Premium_5_5__c != oldEnd.Premium_5_5__c || polEnd.Premium_10_10__c != oldEnd.Premium_10_10__c) {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c != oldEnd.Event_Status__c) {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Primary__c != oldEnd.Primary__c || polEnd.Premium_5_5__c != oldEnd.Premium_5_5__c || polEnd.Premium_10_10__c != oldEnd.Premium_10_10__c) {
                            polEnd.addError('Cannot change the calculation values while completing an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Void') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Primary__c != oldEnd.Primary__c || polEnd.Premium_5_5__c != oldEnd.Premium_5_5__c || polEnd.Premium_10_10__c != oldEnd.Premium_10_10__c) {
                            polEnd.addError('Cannot change the calculation values while voiding an endorsement.');
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c == oldEnd.Event_Status__c  && prof.Name != 'System Administrator') {
                        polEnd.addError('Policy Endorsment is already completed.');
                    }
                } else if (currentEnd.Endorsement_Sub_Type__c == 'IL 190') {
                    if (polEnd.Event_Status__c == 'Pending') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c) {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c != oldEnd.Event_Status__c) {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c) {
                            polEnd.addError('Cannot change the calculation values while completing an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Void') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c) {
                            polEnd.addError('Cannot change the calculation values while voiding an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c == oldEnd.Event_Status__c  && prof.Name != 'System Administrator'  && polEnd.Accounting_Processed__c == oldEnd.Accounting_Processed__c) {
                        polEnd.addError('Policy Endorsment is already completed.');
                    }
                } else if (currentEnd.Endorsement_Sub_Type__c == 'IL 120') {
                    if (polEnd.Event_Status__c == 'Pending') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Prior_Act_Date__c != oldEnd.Prior_Act_Date__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c || polEnd.New_Limits__c != oldEnd.New_Limits__c) {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c != oldEnd.Event_Status__c) {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Prior_Act_Date__c != oldEnd.Prior_Act_Date__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c || polEnd.New_Limits__c != oldEnd.New_Limits__c) {
                            polEnd.addError('Cannot change the calculation values while voiding an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Void') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Prior_Act_Date__c != oldEnd.Prior_Act_Date__c || polEnd.Days_Pro_Rated__c != oldEnd.Days_Pro_Rated__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c || polEnd.New_Limits__c != oldEnd.New_Limits__c) {
                            polEnd.addError('Cannot change the calculation values while voiding an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c == oldEnd.Event_Status__c  && prof.Name != 'System Administrator') {
                        polEnd.addError('Policy Endorsment is already completed.');
                    }
                } else if (currentEnd.Endorsement_Sub_Type__c == 'IL 107' || currentEnd.Endorsement_Sub_Type__c == 'IL 115') {
                    if (polEnd.Event_Status__c == 'Pending') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Coverage_Term__c != oldEnd.Coverage_Term__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c ) {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c != oldEnd.Event_Status__c) {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Coverage_Term__c != oldEnd.Coverage_Term__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c ) {
                            polEnd.addError('Cannot change the calculation values while completing an endorsement.');
                        } else if((polEnd.Policy_Canel_Date__c != null && polEnd.Endorsement_Effective_Date__c != polEnd.Policy_Canel_Date__c) || (polEnd.Policy_Canel_Date__c == null && polEnd.Endorsement_Effective_Date__c != polEnd.Policy_Expiration_Date__c  )){
                            polEnd.addError('Endorsement Effective Date needs to be Policy Expiration/Cancel Date.');
                        }else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Void') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Coverage_Term__c != oldEnd.Coverage_Term__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c ) {
                            polEnd.addError('Cannot change the calculation values while voiding an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c == oldEnd.Event_Status__c  && prof.Name != 'System Administrator'  && polEnd.Accounting_Processed__c == oldEnd.Accounting_Processed__c) {
                        polEnd.addError('Policy Endorsment is already completed.');
                    }
                } else if (currentEnd.Endorsement_Sub_Type__c == 'IL 191') {
                    if (polEnd.Event_Status__c == 'Pending') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Endorsement_Effective_Date__c != oldEnd.Endorsement_Effective_Date__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c) {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c != oldEnd.Event_Status__c) {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Endorsement_Effective_Date__c != oldEnd.Endorsement_Effective_Date__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c) {
                            polEnd.addError('Cannot change the calculation values while completing an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Void') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Endorsement_Effective_Date__c != oldEnd.Endorsement_Effective_Date__c || polEnd.Override_Rating__c != oldEnd.Override_Rating__c || polEnd.Override_5_5__c != oldEnd.Override_5_5__c || polEnd.Override_10_10__c != oldEnd.Override_10_10__c) {
                            polEnd.addError('Cannot change the calculation values while voiding an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c == oldEnd.Event_Status__c  && prof.Name != 'System Administrator') {
                        polEnd.addError('Policy Endorsment is already completed.');
                    }
                }else if (currentEnd.Endorsement_Sub_Type__c == 'IL 107B' || currentEnd.Endorsement_Sub_Type__c == 'IL 107C'  || currentEnd.Endorsement_Sub_Type__c == 'IL 107D') {
                    if (polEnd.Event_Status__c == 'Pending') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Name_Of_Insured__c != oldEnd.Name_Of_Insured__c) {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c != oldEnd.Event_Status__c) {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Name_Of_Insured__c != oldEnd.Name_Of_Insured__c) {
                            polEnd.addError('Cannot change the calculation values while completing an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Void') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Name_Of_Insured__c != oldEnd.Name_Of_Insured__c) {
                            polEnd.addError('Cannot change the calculation values while voiding an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c == oldEnd.Event_Status__c  && prof.Name != 'System Administrator') {
                        polEnd.addError('Policy Endorsment is already completed.');
                    }
                }
            }else if(currentEnd.Type__c == 'Descriptive'){
                if (currentEnd.Endorsement_Sub_Type__c == 'IL 230' || currentEnd.Endorsement_Sub_Type__c == 'IL 234'  || currentEnd.Endorsement_Sub_Type__c == 'IL 261') {
                    if (polEnd.Event_Status__c == 'Pending') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Endorsement_Mod__c != oldEnd.Endorsement_Mod__c) {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c != oldEnd.Event_Status__c) {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Endorsement_Mod__c != oldEnd.Endorsement_Mod__c) {
                            polEnd.addError('Cannot change the calculation values while completing an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Void') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Endorsement_Mod__c != oldEnd.Endorsement_Mod__c) {
                            polEnd.addError('Cannot change the calculation values while voiding an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c == oldEnd.Event_Status__c  && prof.Name != 'System Administrator') {
                        polEnd.addError('Policy Endorsment is already completed.');
                    }
                }else if (currentEnd.Endorsement_Sub_Type__c == 'IL 130' || currentEnd.Endorsement_Sub_Type__c == 'IL 210') {
                    if (polEnd.Event_Status__c == 'Pending') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Additional_Premium__c != oldEnd.Additional_Premium__c) {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c != oldEnd.Event_Status__c) {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Additional_Premium__c != oldEnd.Additional_Premium__c) {
                            polEnd.addError('Cannot change the calculation values while completing an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Void') {
                        if (polEnd.Effective_Date__c != oldEnd.Effective_Date__c || polEnd.Additional_Premium__c != oldEnd.Additional_Premium__c) {
                            polEnd.addError('Cannot change the calculation values while voiding an endorsement.');
                        } else {
                            setPolicyEndorsementIdsToUpdate.add(polEnd.Id);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete' && polEnd.Event_Status__c == oldEnd.Event_Status__c  && prof.Name != 'System Administrator') {
                        polEnd.addError('Policy Endorsment is already completed.');
                    }
                }
                
            }    
        }
        
        // Get the map from the set of ids and call the function to update the calculations.
        system.debug('-----setPolicyEndorsementIdsToUpdate---'+setPolicyEndorsementIdsToUpdate);
        for (String endorsementId : setPolicyEndorsementIdsToUpdate) {
            newItemsToUpdate.put(endorsementId,newItems.get(endorsementId));
        }
        performPolicyEndorsementFunctions(newItemsToUpdate);
    }
    
    // Function will decide what process to be called based on RecordType.
    public static void performPolicyEndorsementFunctions (Map<Id,SObject> newItems) {
		system.debug('performPolicyEndorsementFunctions called');
        // Cast the map to list of policy endorsements.
        List<Policy_Endorsement__c> lstPolicyEndorsements = (List<Policy_Endorsement__c>) newItems.values();
        Set<String> setRecordTypeIds = new Set<String>();
        Map<String,Endorsement__c> mapMasterEndorsement = new Map<String,Endorsement__c>();
        
        // Lists to identify which function to call and which list to pass to related function.
        List<Policy_Endorsement__c> lstCompleteAddLawyer = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstPendingAddLawyer = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstCompleteChangeLawyer = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstPendingChangeLawyer = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstCompleteDeleteLawyer = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstPendingDeleteLawyer = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstCompleteAdjustPremium = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstPendingAdjustPremium = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstCompleteCancelPolicy = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstPendingCancelPolicy = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstCompleteChangeCoverage = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstPendingChangeCoverage = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstCompleteERE = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstCompleteEREOnly = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstPendingERE = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstPendingEREUnlimited = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstCompleteReinstatePolicy = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstPendingReinstatePolicy = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstDescriptiveEndorsements = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstCompleteChangeAccount = new List<Policy_Endorsement__c>(); // Add by SH
        List<Policy_Endorsement__c>  lstCompleteTitlePremium = new List<Policy_Endorsement__c> ();
        List<Policy_Endorsement__c>  lstCompleteAdditionalPremium = new List<Policy_Endorsement__c> ();
        //List<Policy_Endorsement__c> lstAddEndorsementMod = new List<Policy_Endorsement__c>();
        // Fill the set of record type ids from the trigger context list.
        for (Policy_Endorsement__c polEnd : lstPolicyEndorsements) {
            setRecordTypeIds.add(polEnd.RecordTypeId);
        }
        
        // Fetch the master endorsement records for all the ids in the set.
        for (Endorsement__c masterEnd : [SELECT Id, Name, Type__c, Endorsement_Sub_Type__c, Endorsement_Record_Type_ID__c FROM Endorsement__c WHERE Endorsement_Record_Type_ID__c IN: setRecordTypeIds]) {
            mapMasterEndorsement.put(masterEnd.Endorsement_Record_Type_ID__c, masterEnd);
        }
        
        // Check if Policy Endorsement Type is functional and then make list of all endorsements depending on sub types to send to related helper fucntions.
        for (Policy_Endorsement__c polEnd : lstPolicyEndorsements) {
            // Get the master endorsement record to compare type and sub type.
            Endorsement__c currentEnd = mapMasterEndorsement.get(polEnd.RecordTypeId);
            // Check if the master record is of type 'Functional'.
            if (currentEnd != null && currentEnd.Type__c == 'Functional') {
                
                // Check the sub type to identify the function to perform and fill the related list.
                if (currentEnd.Endorsement_Sub_Type__c == 'IL 152') {
                    // Check the status to calculate and bind endorsements.
                    if (polEnd.Event_Status__c == 'Pending') {
                        lstPendingAddLawyer.add(polEnd);
                    } else if (polEnd.Event_Status__c == 'Complete') {
                        lstCompleteAddLawyer.add(polEnd);
                    }
                } else if (currentEnd.Endorsement_Sub_Type__c == 'IL 151') {  // add by SH
                    // Check the status to calculate and bind endorsements.
                    if (polEnd.Event_Status__c == 'Complete') {
                        lstCompleteChangeAccount.add(polEnd);
                    }

                } else if (currentEnd.Endorsement_Sub_Type__c == 'IL 151A') {  // add by SH
                    // Check the status to calculate and bind endorsements.
                    if (polEnd.Event_Status__c == 'Complete') {
                        lstCompleteChangeAccount.add(polEnd);
                    }

                }/*else if (currentEnd.Endorsement_Sub_Type__c == 'Change Lawyer') {
                    // Check the status to calculate and bind endorsements.
                    if (polEnd.Event_Status__c == 'Pending') {
                        lstPendingChangeLawyer.add(polEnd);
                    } else if (polEnd.Event_Status__c == 'Complete') {
                        lstCompleteChangeLawyer.add(polEnd);
                    }
                }*/ else if (currentEnd.Endorsement_Sub_Type__c == 'IL 153') {
                    // Check the status to calculate and bind endorsements.
                    if (polEnd.Event_Status__c == 'Pending') {
                        lstPendingDeleteLawyer.add(polEnd);
                    } else if (polEnd.Event_Status__c == 'Complete') {
                        lstCompleteDeleteLawyer.add(polEnd);
                    }
                } /*else if (currentEnd.Endorsement_Sub_Type__c == 'Adjust Premium') {
                    // Check the status to calculate and bind endorsements.
                    if (polEnd.Event_Status__c == 'Pending') {
                        lstPendingAdjustPremium.add(polEnd);
                    } else if (polEnd.Event_Status__c == 'Complete') {
                        lstCompleteAdjustPremium.add(polEnd);
                    }
                }*/ else if (currentEnd.Endorsement_Sub_Type__c == 'IL 190') {
                    // Check the status to calculate and bind endorsements.
                    if (polEnd.Event_Status__c == 'Pending') {
                        lstPendingCancelPolicy.add(polEnd);
                    } else if (polEnd.Event_Status__c == 'Complete') {
                        lstCompleteCancelPolicy.add(polEnd);
                    }
                } else if (currentEnd.Endorsement_Sub_Type__c == 'IL 120') {
                    // Check the status to calculate and bind endorsements.
                    if (polEnd.Event_Status__c == 'Pending') {
                        lstPendingChangeCoverage.add(polEnd);
                    } else if (polEnd.Event_Status__c == 'Complete') {
                        lstCompleteChangeCoverage.add(polEnd);
                    }
                } else if (currentEnd.Endorsement_Sub_Type__c == 'IL 107' || currentEnd.Endorsement_Sub_Type__c == 'IL 115') {
                    // Check the status to calculate and bind endorsements.
                    if (polEnd.Event_Status__c == 'Pending') {
                        if(currentEnd.Endorsement_Sub_Type__c == 'IL 107'){
                            lstPendingERE.add(polEnd);
                        }else{
                            lstPendingEREUnlimited.add(polEnd);
                        }
                    } else if (polEnd.Event_Status__c == 'Complete') {
                        lstCompleteERE.add(polEnd);
                    }
                } else if (currentEnd.Endorsement_Sub_Type__c == 'IL 191') {
                    // Check the status to calculate and bind endorsements.
                    if (polEnd.Event_Status__c == 'Pending') {
                        lstPendingReinstatePolicy.add(polEnd);
                    } else if (polEnd.Event_Status__c == 'Complete') {
                        lstCompleteReinstatePolicy.add(polEnd);
                    }
                } else if(currentEnd.Endorsement_Sub_Type__c == 'IL 107B' || currentEnd.Endorsement_Sub_Type__c == 'IL 107C'  || currentEnd.Endorsement_Sub_Type__c == 'IL 107D'){
                    if (polEnd.Event_Status__c == 'Complete') {
                        lstCompleteEREOnly.add(polEnd);
                    }
                }
            } else if (currentEnd != null && currentEnd.Type__c == 'Descriptive') {
                //if(currentEnd.Endorsement_Sub_Type__c == 'IL 130' || currentEnd.Endorsement_Sub_Type__c == 'IL 261'){
                if(currentEnd.Endorsement_Sub_Type__c == 'IL 130'){
                    if (polEnd.Event_Status__c == 'Complete') {
                        lstCompleteAdditionalPremium.add(polEnd);
                    }
                }else if(currentEnd.Endorsement_Sub_Type__c == 'IL 210'){
                    if (polEnd.Event_Status__c == 'Complete') {
                        lstCompleteTitlePremium.add(polEnd);
                    }
                }else if(currentEnd.Endorsement_Sub_Type__c == 'IL 230' || currentEnd.Endorsement_Sub_Type__c == 'IL 234' || currentEnd.Endorsement_Sub_Type__c == 'IL 261'){
                    //lstAddEndorsementMod.add(polEnd);
                }else if (polEnd.Event_Status__c == 'Pending') {
                    lstDescriptiveEndorsements.add(polEnd);
                }
                
            }
        }
        
        // Check the size of each list and call the functions.
        // Check if lstPendingAddLawyer is not empty, call the pendingAddLawyer function.
        if (lstPendingAddLawyer.size() > 0) {
            system.debug('pendingAddLawyer called');
            pendingAddLawyer(lstPendingAddLawyer);
        }
        // Check if lstCompleteAddLawyer is not empty, call the completeAddLawyer function.
        if (lstCompleteAddLawyer.size() > 0) {
            system.debug('completeAddLawyer called');
            completeAddLawyer(lstCompleteAddLawyer);
        }

        // Check if lstCompleteChangeAccountr is not empty, call the completeChangeAccount function.
        if (lstCompleteChangeAccount.size() > 0) {
            // Account update name and address
            completeChangeAccount(lstCompleteChangeAccount,True); //true means by pass valudation rule
            completeChangeAccount(lstCompleteChangeAccount,False); //False means, update Is_Allow_Change_Name_Address__c=False so that valudation rule will execute
        }

        // Check if lstPendingChangeLawyer is not empty, call the pendingAddLawyer function.
        /*if (lstPendingChangeLawyer.size() > 0) {
            pendingChangeLawyer(lstPendingChangeLawyer);
        }
        
        // Check if lstCompleteChangeLawyer is not empty, call the completeAddLawyer function.
        if (lstCompleteChangeLawyer.size() > 0) {
            completeChangeLawyer(lstCompleteChangeLawyer);
        }*/
        // Check if lstPendingDeleteLawyer is not empty, call the pendingAddLawyer function.
        if (lstPendingDeleteLawyer.size() > 0) {
            system.debug('pendingDeleteLawyer called');
            pendingDeleteLawyer(lstPendingDeleteLawyer);
        }
        // Check if lstCompleteDeleteLawyer is not empty, call the completeAddLawyer function.
        if (lstCompleteDeleteLawyer.size() > 0) {
            system.debug('completeDeleteLawyer called');
            completeDeleteLawyer(lstCompleteDeleteLawyer);
        }
        // Check if lstPendingAdjustPremium is not emplty, call the pendingAdjustPremium function.
        /*if (lstPendingAdjustPremium.size() > 0) {
            pendingAdjustPremium(lstPendingAdjustPremium);
        }
        // Check if lstCompleteAdjustPremium is not emplty, call the completeAdjustPremium function.
        if (lstCompleteAdjustPremium.size() > 0) {
            completeAdjustPremium(lstCompleteAdjustPremium);
        }*/
        // Check if lstPendingERE is not empty, call the pendingERE function.
        if (lstPendingERE.size() > 0) {
            system.debug('pendingERE called');
            pendingERE(lstPendingERE);
        }
        // Check if lstPendingEREUnlimited is not empty, call the pendingERE function.
        if (lstPendingEREUnlimited.size() > 0) {
            system.debug('pendingEREUnlimited called');
            pendingEREUnlimited(lstPendingEREUnlimited);
        }
        // Check if lstCompleteERE is not empty, call the completeERE function.
        if (lstCompleteERE.size() > 0) {
            system.debug('completeERE called');
            completeERE(lstCompleteERE);
        }
        // Check if lstPendingCancelPolicy is not empty, call the pendingCancelPolicy function.
        if (lstPendingCancelPolicy.size() > 0) {
            system.debug('pendingCancelPolicy called');
            pendingCancelPolicy(lstPendingCancelPolicy);
        }
        // Check if lstCompleteCancelPolicy is not empty, call the completeCancelPolicy function.
        if (lstCompleteCancelPolicy.size() > 0) {
            system.debug('completeCancelPolicy called');
            completeCancelPolicy(lstCompleteCancelPolicy);
        }
        // Check if lstPendingReinstatePolicy is not empty, call the pendingReinstatePolicy function.
        if (lstPendingReinstatePolicy.size() > 0) {
            system.debug('pendingReinstatePolicy called');
            pendingReinstatePolicy(lstPendingReinstatePolicy);
        }
        // Check if lstCompleteReinstatePolicy is not empty, call the completeReinstatePolicy function.
        if (lstCompleteReinstatePolicy.size() > 0) {
            system.debug('completeReinstatePolicy called');
            completeReinstatePolicy(lstCompleteReinstatePolicy);
        }
        // Check if lstPendingChangeCoverage is not empty, call the pendingChangeCoverage function.
        if (lstPendingChangeCoverage.size() > 0) {
            system.debug('pendingChangeCoverage called');
            pendingChangeCoverage(lstPendingChangeCoverage);
        }
        // Check if lstCompleteChangeCoverage is not empty, call the completeChangeCoverage function.
        if (lstCompleteChangeCoverage.size() > 0) {
            system.debug('completeChangeCoverage called');
            completeChangeCoverage(lstCompleteChangeCoverage);
        }
        // Mark all Descriptive Endorsements as Complete.
        if (lstDescriptiveEndorsements.size() > 0) {
            //completeDescriptiveEndorsements(lstDescriptiveEndorsements); // commented by SH 20170308 05:58 pm (already discussed with AZ)
            
        }
        if(lstCompleteEREOnly.size() > 0){
            system.debug('completeEREOnly called');
            completeEREOnly(lstCompleteEREOnly);
        }
        if(lstCompleteTitlePremium.size() > 0 ){
            system.debug('completeTitlePremium called');
            completeTitlePremium(lstCompleteTitlePremium);
        }
        if(lstCompleteAdditionalPremium.size() > 0 ){
            system.debug('completeAdditionalPremium called');
            completeAdditionalPremium(lstCompleteAdditionalPremium);
        }
        /*if(lstAddEndorsementMod.size() > 0){
            completeAddEndorsementMod(lstAddEndorsementMod);
        }*/
    }
    
    // Check Status Before Insert, status can only be pending at the time of creation.
    public static void checkStatusValidation(List<SObject> newItems) {
        for (Policy_Endorsement__c polEnd : (List<Policy_Endorsement__c>) newItems) {
            if (polEnd.Event_Status__c != 'Pending') {
                polEnd.addError('New Endorsement can only be created with Pending Status.');
            }
        }
    }
    
    // Check Status Before Update, if status is Complete or Void then don't let the status be changed.
    public static void checkStatusValidation(Map<Id,SObject> oldItems, Map<Id,SObject> newItems) {
        for (Policy_Endorsement__c newEnd : (List<Policy_Endorsement__c>) newItems.values()) {
            Policy_Endorsement__c oldEnd = (Policy_Endorsement__c) oldItems.get(newEnd.Id);
            
            if (oldEnd.Event_Status__c != newEnd.Event_Status__c) {
                if ((oldEnd.Event_Status__c == 'Complete' || oldEnd.Event_Status__c == 'Void') && newEnd.Event_Status__c != 'Cancel') {
                   newEnd.addError('Cannot change Status from Complete or Void.');
                }
            }
        }
    }
    
    // Check if the Lawyer is already added in the system.
    public static void policyLawyerValidation(Map<Id,SObject> newItems) {
        // Cast the map to list of policy endorsements.
        List<Policy_Endorsement__c> lstNewPolicyEndorsements = (List<Policy_Endorsement__c>) newItems.values();
        
        Set<String> setPolicyIds = new Set<String>();
        Set<String> setRecordTypeIds = new Set<String>();
        Map<String,String> mapRecordTypeName = new Map<String,String>();
        Map<String,Set<String>> mapOfPolicyLawyers = new Map<String,Set<String>>();
        
        // Get the Policy Ids to SOQL all lawyers added on the policy.
        for (Policy_Endorsement__c polEnd : lstNewPolicyEndorsements) {
            setPolicyIds.add(polEnd.Policy__c);
            setRecordTypeIds.add(polEnd.RecordTypeId);
        }
        
        // SOQL RecordType Developer Name to fill the map.
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE Id IN: setRecordTypeIds]) {
            mapRecordTypeName.put(rt.Id,rt.DeveloperName);
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

        // Check if lawyer id exist in the map.
        for (Policy_Endorsement__c polEnd : lstNewPolicyEndorsements) {
            Set<String> polIds = new Set<String>();
            polIds = mapOfPolicyLawyers.get(polEnd.Policy__c);
            if (polIds != null) {
                if (polIds.contains(polEnd.Lawyer__c) && mapRecordTypeName.get(polEnd.RecordTypeId) == 'AL_Add_Lawyer_Transaction') {
                    polEnd.addError('Lawyer is already added on the Policy.');
                } else if (polIds.contains(polEnd.Policy_Lawyer__c) && mapRecordTypeName.get(polEnd.RecordTypeId) == 'CL_Change_Lawyer_Transaction') {
                    polEnd.addError('Lawyer has been deleted from the Policy.');
                } else if (polIds.contains(polEnd.Policy_Lawyer__c) && mapRecordTypeName.get(polEnd.RecordTypeId) == 'DL_Delete_Lawyer_Transaction') {
                    polEnd.addError('Lawyer has been deleted from the Policy.');
                }
            }
        }
    }
    
    // Pending Add Lawyer Helper Function.
    public static void pendingAddLawyer(List<Policy_Endorsement__c> lstPendingAddLawyer) {
        //String masterStepFactorId;
        //String masterLimitFactorId;
        //Step_Rate_Factor__c stepFactors = new Step_Rate_Factor__c();
        //ILF_Coverage_Factor__c lowestLimitFactor = new ILF_Coverage_Factor__c();
        Map<Id,Step_Rate_Factor__c> stepFactors = new Map<Id,Step_Rate_Factor__c>();
        Map<Id,ILF_Coverage_Factor__c> lowestLimitFactor = new Map<Id,ILF_Coverage_Factor__c>();
        Set<String> setPolicyEndorsementIds = new Set<String>();
        Set<String> setPolicyIds = new Set<String>();
        set<String> setLimitFactorIds = new Set<String>();
        set<String> setDeductibleFactorIds = new Set<String>();
        Map<String,Policy__c> mapOfPolicies = new Map<String,Policy__c>();
        Map<String,ILF_Coverage_Factor__c> mapOfLimits = new Map<String,ILF_Coverage_Factor__c>();
        Map<String,Deductible_Factor__c> mapOfDeductibles = new Map<String,Deductible_Factor__c>();
        List<Policy_Endorsement__c> lstPolicyEndorsements = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstPolicyEndorsementsToUpdate = new List<Policy_Endorsement__c>();
        
        // Get the Master Factor Record Id For Step Rate and Limits where default is true.
        //masterStepFactorId = String.valueOf([SELECT Id, Name, Default__c, Factor_Type__c FROM Master_Factor__c WHERE Default__c = true AND Factor_type__c = 'Step Rate' LIMIT 1].Id);
        //masterLimitFactorId = String.valueOf([SELECT Id, Name, Default__c, Factor_Type__c FROM Master_Factor__c WHERE Default__c = true AND Factor_type__c = 'Coverage' LIMIT 1].Id);
        
        // Get the Step Factor To fetch all the Step Rate Factor Values.
        //stepFactors = [SELECT Id, Factor_Value_Step_Rate_0__c, Factor_Value_Step_Rate_1__c, Factor_Value_Step_Rate_2__c, Factor_Value_Step_Rate_3__c, Factor_Value_Step_Rate_4__c, Factor_Value_Step_Rate_5__c, Factor_Value_Step_Rate_6__c, Factor_Value_Step_Rate_7__c, Master_Factor__c FROM Step_Rate_Factor__c WHERE Master_Factor__c =: masterStepFactorId];
        
        List<Step_Rate_Factor__c> stepRateFactorsList = new List<Step_Rate_Factor__c>([SELECT Id,From_Date__c,To_Date__c, Factor_Value_Step_Rate_0__c, Factor_Value_Step_Rate_1__c, Factor_Value_Step_Rate_2__c, Factor_Value_Step_Rate_3__c, Factor_Value_Step_Rate_4__c, Factor_Value_Step_Rate_5__c, Factor_Value_Step_Rate_6__c, Factor_Value_Step_Rate_7__c, Master_Factor__c FROM Step_Rate_Factor__c WHERE Master_Factor__r.Factor_type__c = 'Step Rate']);
        
        // Get the lowest coverage factor and its value for primary calculations.
        //lowestLimitFactor = [SELECT Id, Factor_Value__c, Lowest_Coverage__c, Master_Factor__c FROM ILF_Coverage_Factor__c WHERE Master_Factor__c =: masterLimitFactorId AND Lowest_Coverage__c = true];
        
        List<ILF_Coverage_Factor__c> lowestLimitFactorList = new List<ILF_Coverage_Factor__c>([SELECT Id,From_Date__c,To_Date__c, Factor_Value__c, Lowest_Coverage__c, Master_Factor__c FROM ILF_Coverage_Factor__c WHERE Master_Factor__r.Factor_type__c = 'Coverage' AND Lowest_Coverage__c = true]);
        
        system.debug('=======lstPendingAddLawyer===='+lstPendingAddLawyer);
        // Get all the Policy Endorsement Ids to SOQL.
        for (Policy_Endorsement__c polEnd : lstPendingAddLawyer) {
            setPolicyEndorsementIds.add(polEnd.Id);
            setPolicyIds.add(polEnd.Policy__c);
        }
        system.debug('========setPolicyIds====='+setPolicyIds);
        // Get all the Policies related to the endorsements and fill the map.
        for (Policy__c pol : [SELECT Id, Name, Effective_Date__c, Expiration_Date__c, Limit__c, Firm_Mod__c, Deductible_ID__c, Base_Amount__c, Final_Quote_10x10_Value__c,ADJ_MOD__c,X5_5_Override__c,X10x10__c FROM Policy__c WHERE Id IN: setPolicyIds]) {
            for(Step_Rate_Factor__c factor : stepRateFactorsList){
                if(factor.From_Date__c <= pol.Effective_Date__c &&  factor.To_Date__c >= pol.Effective_Date__c){
                    stepFactors.put(pol.Id,factor);
                }
            }
            for(ILF_Coverage_Factor__c factor : lowestLimitFactorList){
                if(factor.From_Date__c <= pol.Effective_Date__c &&  factor.To_Date__c >= pol.Effective_Date__c){
                    lowestLimitFactor.put(pol.Id,factor);
                }
            }
            system.debug('========mapOfPolicies===='+mapOfPolicies);
            
            mapOfPolicies.put(pol.Id,pol);
            setLimitFactorIds.add(pol.Limit__c);
            setDeductibleFactorIds.add(pol.Deductible_ID__c);
        }
        
        // Get all the limits applied to policy endorsements and fill the map.
        for (ILF_Coverage_Factor__c lim : [SELECT Id, Name, Is_5X5_Coverage__c, Is_10X10_Coverage__c, Percnt_amt_5X5_Step_0__c, Percnt_amt_5X5_Step_1__c, Percnt_amt_5X5_Step_2__c, Percnt_amt_5X5_Step_3__c, Premium_Rate_5X5__c, Factor_Value__c,X4x1_Rate__c FROM ILF_Coverage_Factor__c WHERE Id IN: setLimitFactorIds]) {
            mapOfLimits.put(lim.Id,lim);
        }
        
        // Get all the deductibles applied to policy endorsements and fill the map.
        for (Deductible_Factor__c ded : [SELECT Id, Name, Deductible_Amount__c, Factor_Value__c, Master_Factor__c FROM Deductible_Factor__c WHERE Id IN: setDeductibleFactorIds]) {
            mapOfDeductibles.put(ded.Id,ded);
        }
        
        // SOQL the Policy Endorsemnts for calculations.
        for (Policy_Endorsement__c polEnd : [SELECT Id, Lawyer__c, Rate_At__c, Prior_Act_Date__c, Step__c, Step_Override__c, Step_Override_Value__c, Type__c, Term__c, Days_Pro_Rated__c, Premium__c, Override_Rating__c, Override_5_5__c, Override_10_10__c, Primary__c, Premium_5_5__c, Premium_10_10__c, Policy__c,Endorsement_Effective_Date__c FROM Policy_Endorsement__c WHERE Id IN: setPolicyEndorsementIds]) {
            Decimal stepFactorValue;
            
            system.debug('=========rate end==='+polEnd);
            
            Decimal rate = (polEnd.Rate_At__c == null ? 0 : polEnd.Rate_At__c) / 100;
            Decimal amountBeforeDeductible;
            Decimal deductibleFactorAmount;
            
            ILF_Coverage_Factor__c limitFactor = mapOfLimits.get(mapOfPolicies.get(polEnd.Policy__c).Limit__c);
            Deductible_Factor__c deductibleFactor = mapOfDeductibles.get(mapOfPolicies.get(polEnd.Policy__c).Deductible_ID__c);
            
            polEnd.Step__c = ApplicationPolicyUtil.CalculateLawyerStep(mapOfPolicies.get(polEnd.Policy__c).Effective_Date__c,polEnd.Prior_Act_Date__c);
            
            Decimal daysProRated = polEnd.Endorsement_Effective_Date__c.daysBetween(mapOfPolicies.get(polEnd.Policy__c).Expiration_Date__c) + 1;
            polEnd.Term__c = daysProRated / (Date.isLeapYear(Date.today().year()) ?  366 : 365);
            
            if(polEnd.Term__c > 1){
                polEnd.Term__c = 1;
            }
            
            system.debug('========Step_Override__c======='+polEnd.Step_Override__c+'========Step_Override_Value__c===='+polEnd.Step_Override_Value__c);
            system.debug('========stepFactors====='+stepFactors);
            
            if (polEnd.Step_Override__c == true) {
                if (polEnd.Step_Override_Value__c == 0) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                } else if (polEnd.Step_Override_Value__c == 1) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_1__c:0;
                } else if (polEnd.Step_Override_Value__c == 2) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_2__c:0;
                } else if (polEnd.Step_Override_Value__c == 3) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_3__c:0;
                } else if (polEnd.Step_Override_Value__c == 4) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_4__c:0;
                } else if (polEnd.Step_Override_Value__c == 5) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_5__c:0;
                } else if (polEnd.Step_Override_Value__c == 6) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_6__c:0;
                } else if (polEnd.Step_Override_Value__c == 7) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_7__c:0;
                }
            } else {
                if (polEnd.Step__c == 0) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                } else if (polEnd.Step__c == 1) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_1__c:0;
                } else if (polEnd.Step__c == 2) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_2__c:0;
                } else if (polEnd.Step__c == 3) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_3__c:0;
                } else if (polEnd.Step__c == 4) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_4__c:0;
                } else if (polEnd.Step__c == 5) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_5__c:0;
                } else if (polEnd.Step__c == 6) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_6__c:0;
                } else if (polEnd.Step__c == 7) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_7__c:0;
                }
            }
            
            system.debug('======mapOfPolicies==='+mapOfPolicies);
            system.debug('======stepFactorValue ==='+stepFactorValue );
            system.debug('======limitFactor.Factor_Value__c==='+limitFactor);
            
            amountBeforeDeductible = (100 * stepFactorValue * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * limitFactor.Factor_Value__c * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c) / 100;
            amountBeforeDeductible = amountBeforeDeductible.round(System.RoundingMode.HALF_UP);
            
            SYSTEM.DEBUG('-------lowestLimitFactor.Factor_Value__c--X---'+(lowestLimitFactor.containsKey(polEnd.Policy__c)?lowestLimitFactor.get(polEnd.Policy__c).Factor_Value__c:0));
            SYSTEM.DEBUG('-------X--deductibleFactor.Factor_Value__c-X---'+deductibleFactor.Factor_Value__c);
            
            deductibleFactorAmount = ((stepFactorValue * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * (lowestLimitFactor.containsKey(polEnd.Policy__c)?lowestLimitFactor.get(polEnd.Policy__c).Factor_Value__c:0) * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c) - (stepFactorValue * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * (lowestLimitFactor.containsKey(polEnd.Policy__c)?lowestLimitFactor.get(polEnd.Policy__c).Factor_Value__c:0) * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c * deductibleFactor.Factor_Value__c));
            deductibleFactorAmount = (100 * deductibleFactorAmount) / 100;
            deductibleFactorAmount = deductibleFactorAmount.round(System.RoundingMode.HALF_UP);
            deductibleFactorAmount = deductibleFactorAmount * (-1);
            
            polEnd.Excess__c =  limitFactor.X4x1_Rate__c != null ? (amountBeforeDeductible/limitFactor.Factor_Value__c)*limitFactor.X4x1_Rate__c : 0;
            
            //polEnd.Primary__c = (100 * stepFactorValue * rate * polEnd.Term__c * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * limitFactor.Factor_Value__c * deductibleFactor.Factor_Value__c * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c) / 100;
            
            polEnd.Primary__c = (amountBeforeDeductible + deductibleFactorAmount) - polEnd.Excess__c;
            
            polEnd.Excess__c = polEnd.Excess__c * rate * polEnd.Term__c;
            polEnd.Excess__c = polEnd.Excess__c.round(System.RoundingMode.HALF_UP);
                
            polEnd.Primary__c = polEnd.Primary__c * rate * polEnd.Term__c;
            
            polEnd.Primary__c = (100 * polEnd.Primary__c) / 100;
            polEnd.Primary__c = polEnd.Primary__c.round(System.RoundingMode.HALF_UP);
            
            if (limitFactor.Is_5X5_Coverage__c == true) {
                if (polEnd.Step_Override__c == true) {
                    if (polEnd.Step_Override_Value__c == 0) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_0__c;
                    } else if (polEnd.Step_Override_Value__c == 1) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_1__c;
                    } else if (polEnd.Step_Override_Value__c == 2) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_2__c;
                    } else if (polEnd.Step_Override_Value__c == 3) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_3__c;
                    } else if (polEnd.Step_Override_Value__c > 3) {
                        polEnd.Premium_5_5__c = limitFactor.Premium_Rate_5X5__c;
                    }
                }else if(mapOfPolicies.get(polEnd.Policy__c).X5_5_Override__c != null && mapOfPolicies.get(polEnd.Policy__c).X5_5_Override__c>0){
                    polEnd.Premium_5_5__c = mapOfPolicies.get(polEnd.Policy__c).X5_5_Override__c * polEnd.Term__c;
                } else {
                    if (polEnd.Step__c == 0) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_0__c;
                    } else if (polEnd.Step__c == 1) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_1__c;
                    } else if (polEnd.Step__c == 2) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_2__c;
                    } else if (polEnd.Step__c == 3) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_3__c;
                    } else if (polEnd.Step__c > 3) {
                        polEnd.Premium_5_5__c = limitFactor.Premium_Rate_5X5__c;
                    }
                    polEnd.Premium_5_5__c = polEnd.Premium_5_5__c * polEnd.Term__c;
                }
            } else {
                polEnd.Premium_5_5__c = 0.00;
            }
            
            if(mapOfPolicies.get(polEnd.Policy__c).X10x10__c != null && mapOfPolicies.get(polEnd.Policy__c).X10x10__c>0){
                polEnd.Premium_10_10__c = mapOfPolicies.get(polEnd.Policy__c).X10x10__c * polEnd.Term__c;
            }else{
                polEnd.Premium_10_10__c = 0.0;
            }
            
            // Removing the 10 X 10 from per lawyer calculations, because 10 X 10 is applicable per policy as per discussion with Gibran 03/01/2017.
            //if (limitFactor.Is_10X10_Coverage__c == true) {
            //    polEnd.Premium_10_10__c = mapOfPolicies.get(polEnd.Policy__c).Final_Quote_10x10_Value__c;
            //} else {
            //    polEnd.Premium_10_10__c = 0.0;
            //}
            
            if (polEnd.Override_Rating__c == true) {
                polEnd.Premium__c = polEnd.Primary__c + polEnd.Excess__c +  (polEnd.Override_5_5__c == null ? 0 : polEnd.Override_5_5__c) + (polEnd.Override_10_10__c == null ? 0 : polEnd.Override_10_10__c);
            } else {
                polEnd.Premium__c = polEnd.Primary__c + polEnd.Excess__c + (polEnd.Premium_5_5__c == null ? 0 : polEnd.Premium_5_5__c) + (polEnd.Premium_10_10__c == null ? 0 : polEnd.Premium_10_10__c);
            }
            if(mapOfPolicies.get(polEnd.Policy__c).ADJ_MOD__c!=null){
                polEnd.Premium__c = ( polEnd.Premium__c +  ((mapOfPolicies.get(polEnd.Policy__c).ADJ_MOD__c-1)*polEnd.Premium__c));
            }
            polEnd.Premium__c = (100 * polEnd.Premium__c) / 100;
            polEnd.Premium__c = polEnd.Premium__c.round(System.RoundingMode.HALF_UP);
            system.debug('policyEndorsement = >'+polEnd);
            lstPolicyEndorsementsToUpdate.add(polEnd);
        }
        update lstPolicyEndorsementsToUpdate;
    }
    
    // Complete Add Lawyer Helper Function.
    public static void completeAddLawyer(List<Policy_Endorsement__c> lstCompleteAddLawyer) {
        Set<String> setPolicyIds = new Set<String>();
        Map<String,Policy_Lawyer__c> lstLawyersToAdd = new Map<String,Policy_Lawyer__c>();
        List<AS_Transaction__c> lstASTransaction = new List<AS_Transaction__c>();
        List<Policy__c> lstPoliciesToUpdate = new List<Policy__c>();
        List<Policy_Endorsement__c> policyEndorsementToUpdate = new List<Policy_Endorsement__c>();
        List<Policy_Premium_History__c> premiumHistoryList = new List<Policy_Premium_History__c>();
        // Fill the set of policies to update and create a list of policy lawuers to add also create a list of account seed object transactions.
        for (Policy_Endorsement__c polEnd : lstCompleteAddLawyer) {
            setPolicyIds.add(polEnd.Policy__c);
            Policy_Lawyer__c polLaw = new Policy_Lawyer__c();
            polLaw.Account__c = polEnd.Account__c;
            polLaw.Lawyer__c = polEnd.Lawyer__c;
            polLaw.Policy__c = polEnd.Policy__c;
            polLaw.Primary__c = polEnd.Primary__c;
            polLaw.Rate_At__c = polEnd.Rate_At__c;
            polLaw.Step__c = (polEnd.Step_Override__c ? polEnd.Step_Override_Value__c : polEnd.Step__c);
            polLaw.X5_5__c = (polEnd.Override_Rating__c ? polEnd.Override_5_5__c : polEnd.Premium_5_5__c);
            polLaw.X10_10__c = (polEnd.Override_Rating__c ? polEnd.Override_10_10__c : polEnd.Premium_10_10__c);
            polLaw.Premium__c = polEnd.Premium__c;
            polLaw.Prior_Act_Date__c = polEnd.Prior_Act_Date__c;
            polLaw.Active__c = true;
            polLaw.Deleted_Lawyer__c = false;
            polLaw.Deleted_Date__c = null;
            polLaw.Added_Date__c = polEnd.Endorsement_Effective_Date__c;
            polLaw.Excess__c = polEnd.Excess__c;
            polLaw.Term__c = polEnd.Term__c;
            lstLawyersToAdd.put(polEnd.Account__c+'-'+polEnd.Policy__c+'-'+polEnd.Lawyer__c,polLaw);
            
            if(Label.Process_Accounting_On_Endorsements == 'Y'){
                lstASTransaction = getIL_152_Transactions(polEnd);
            }
            Policy_Premium_History__c premiumHistory = new Policy_Premium_History__c();
            premiumHistory.Policy__c = polEnd.Policy__c;
            premiumHistory.Action__c = 'Add Lawyer';
            premiumHistory.Premium__c = polEnd.Premium__c;
            premiumHistory.X10x10_value__c = (polEnd.Override_Rating__c ? polEnd.Override_10_10__c : polEnd.Premium_10_10__c);
            premiumHistory.X5x5_value__c = (polEnd.Override_Rating__c ? polEnd.Override_5_5__c : polEnd.Premium_5_5__c);
            
            premiumHistoryList.add(premiumHistory);
        }
        insert lstLawyersToAdd.values();
        insert lstASTransaction;
        insert premiumHistoryList;
        
        for(Policy_Endorsement__c polEnd : lstCompleteAddLawyer){
            Policy_Endorsement__c endor = new Policy_Endorsement__c(Id=polEnd.Id,Policy_Lawyer__c = lstLawyersToAdd.get(polEnd.Account__c+'-'+polEnd.Policy__c+'-'+polEnd.Lawyer__c).Id);
            policyEndorsementToUpdate.add(endor);
        }
        
        update policyEndorsementToUpdate;
        
        // SOQL Policies to update premium.
        for (Policy__c pol : [SELECT Id, Name, Premium__c,Total_5x5__c,Total_10x10__c,Excess_Premium__c,Primary__c FROM Policy__c WHERE Id IN: setPolicyIds]) {
            for (Policy_Endorsement__c polEnd : lstCompleteAddLawyer) {
                if (pol.Id == polEnd.Policy__c) {
                    pol.Premium__c = pol.Premium__c + polEnd.Premium__c;
                    pol.Total_5x5__c = (pol.Total_5x5__c == null ? 0 : pol.Total_5x5__c) + (polEnd.Premium_5_5__c == null ? 0 : polEnd.Premium_5_5__c);
                    pol.Total_10x10__c = (pol.Total_10x10__c == null ? 0 : pol.Total_10x10__c) + (polEnd.Premium_10_10__c == null ? 0 : polEnd.Premium_10_10__c); 
                    pol.Excess_Premium__c = (pol.Excess_Premium__c == null ? 0 : pol.Excess_Premium__c) + (polEnd.Excess__c == null ? 0 : polEnd.Excess__c); 
                    pol.Primary__c = (pol.Primary__c == null ? 0 : pol.Primary__c) + (polEnd.Primary__c == null ? 0 : polEnd.Primary__c);
                    
                    lstPoliciesToUpdate.add(pol);
                }
            }
        }
        update lstPoliciesToUpdate;
    }
    public static List<AS_Transaction__c> getIL_152_Transactions(Policy_Endorsement__c polEnd){
        List<AS_Transaction__c> lstASTransaction = new List<AS_Transaction__c>();
        AS_Transaction__c AS_SingleEntry = new AS_Transaction__c();
        AS_SingleEntry.Amount__c = polEnd.Premium__c;
        AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
        AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
        AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
        AS_SingleEntry.Transaction_Type__c = 'Add Lawyer';
        AS_SingleEntry.Transaction_Sub_Type__c = 'Add Lawyer';
        lstASTransaction.add(AS_SingleEntry);
        
        
        if(polEnd.Premium_5_5__c !=null && polEnd.Premium_5_5__c != 0){
            AS_SingleEntry = new AS_Transaction__c();
            AS_SingleEntry.Amount__c = polEnd.Premium_5_5__c;
            AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
            AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
            AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
            AS_SingleEntry.Transaction_Type__c = 'Add Lawyer';
            AS_SingleEntry.Transaction_Sub_Type__c = '5x5';
            lstASTransaction.add(AS_SingleEntry);
        }
        if(polEnd.Premium_10_10__c !=null && polEnd.Premium_10_10__c != 0){
            AS_SingleEntry = new AS_Transaction__c();
            AS_SingleEntry.Amount__c = polEnd.Premium_10_10__c;
            AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
            AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
            AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
            AS_SingleEntry.Transaction_Type__c = 'Add Lawyer';
            AS_SingleEntry.Transaction_Sub_Type__c = '10x10';
            lstASTransaction.add(AS_SingleEntry);
        }
        
        if(polEnd.Primary__c !=null && polEnd.Primary__c != 0){
            AS_SingleEntry = new AS_Transaction__c();
            AS_SingleEntry.Amount__c = polEnd.Primary__c;
            AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
            AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
            AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
            AS_SingleEntry.Transaction_Type__c = 'Add Lawyer';
            AS_SingleEntry.Transaction_Sub_Type__c = 'Primary';
            lstASTransaction.add(AS_SingleEntry);
        }
        
        //if(polEnd.Excess__c !=null && polEnd.Excess__c != 0){
        AS_SingleEntry = new AS_Transaction__c();
        AS_SingleEntry.Amount__c = (polEnd.Excess__c !=null ? polEnd.Excess__c : 0) + polEnd.Primary__c;
        AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
        AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
        AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
        AS_SingleEntry.Transaction_Type__c = 'Add Lawyer';
        AS_SingleEntry.Transaction_Sub_Type__c = 'PrimaryAndExcess';
        lstASTransaction.add(AS_SingleEntry);
        //}
        return lstASTransaction;
    }
    // Pending Change Account Helper Function.
    public static void pendingChangeAccount(List<Policy_Endorsement__c> lstPendingChangeAccount) {
        
    }
        
    // Complete Change Account Helper Function.
    public static void CompleteChangeAccount(List<Policy_Endorsement__c> lstCompleteChangeAccount,Boolean IsAllowAccountChkBox) {
        
        Set<String> setAccountIDs = new Set<String>();
        Map<Id, Policy_Endorsement__c> MapPolicyEndorsement = new Map<Id,Policy_Endorsement__c>(lstCompleteChangeAccount);

        //Maintain  lstAccounttobeUpdate & MapPolicyEndorsement to update account Address
        For(Policy_Endorsement__c ForPE : lstCompleteChangeAccount){
            setAccountIDs.add(ForPE.Account_ID__c);      
            MapPolicyEndorsement.put(ForPE.Account_ID__c,ForPE);
        }
        
        List<Account> lstAccounttobeUpdate  = [select ID,Name,BillingStreet,BillingCity,BillingState,BillingPostalCode,Is_Allow_Change_Name_Address__c from Account where ID in :setAccountIDs];
        
        // Maintain lstAccounttobeUpdate list to be Update Account
        For(Account ForAc : lstAccounttobeUpdate){
            If(IsAllowAccountChkBox){
                If(MapPolicyEndorsement.containsKey(ForAc.ID)){
                    If(MapPolicyEndorsement.get(ForAc.ID).Account_Name__c!= null){
                        ForAc.Name              = MapPolicyEndorsement.get(ForAc.ID).Account_Name__c;
                    }
                    If(MapPolicyEndorsement.get(ForAc.ID).Account_Billing_Street__c!= null){
                        ForAc.BillingStreet     = MapPolicyEndorsement.get(ForAc.ID).Account_Billing_Street__c;
                    }
                    If(MapPolicyEndorsement.get(ForAc.ID).Account_Billing_city__c!= null){
                        ForAc.BillingCity       = MapPolicyEndorsement.get(ForAc.ID).Account_Billing_city__c;
                    }
                    If(MapPolicyEndorsement.get(ForAc.ID).Account_Billing_State__c!= null){
                        ForAc.BillingState      = MapPolicyEndorsement.get(ForAc.ID).Account_Billing_State__c;
                    }
                    If(MapPolicyEndorsement.get(ForAc.ID).Account_Billing_PostalCode__c!= null){
                        ForAc.BillingPostalCode = MapPolicyEndorsement.get(ForAc.ID).Account_Billing_PostalCode__c;     
                        
                    }
                    ForAc.Is_Allow_Change_Name_Address__c = True;  // Validation will allow to change
                }
            }Else{
                ForAc.Is_Allow_Change_Name_Address__c = False; // Validation will not allow to change
            }

        } 
       Update lstAccounttobeUpdate;        
    }

    // Pending Change Lawyer Helper Function.
    /*public static void pendingChangeLawyer(List<Policy_Endorsement__c> lstPendingChangeLawyer) {
        //String masterStepFactorId;
        //String masterLimitFactorId;
        //Step_Rate_Factor__c stepFactors = new Step_Rate_Factor__c();
        //ILF_Coverage_Factor__c lowestLimitFactor = new ILF_Coverage_Factor__c();
        Map<Id,Step_Rate_Factor__c> stepFactors = new Map<Id,Step_Rate_Factor__c>();
        Map<Id,ILF_Coverage_Factor__c> lowestLimitFactor = new Map<Id,ILF_Coverage_Factor__c>();
        Set<String> setPolicyEndorsementIds = new Set<String>();
        Set<String> setPolicyIds = new Set<String>();
        Set<String> setLimitFactorIds = new Set<String>();
        Set<String> setDeductibleFactorIds = new Set<String>();
        Set<String> setPolicyLawyerIds = new Set<String>();
        Map<String,Policy__c> mapOfPolicies = new Map<String,Policy__c>();
        Map<String,ILF_Coverage_Factor__c> mapOfLimits = new Map<String,ILF_Coverage_Factor__c>();
        Map<String,Deductible_Factor__c> mapOfDeductibles = new Map<String,Deductible_Factor__c>();
        Map<String,Policy_Lawyer__c> mapOfPolicyLawyers = new Map<String,Policy_Lawyer__c>();
        List<Policy_Endorsement__c> lstPolicyEndorsements = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstPolicyEndorsementsToUpdate = new List<Policy_Endorsement__c>();
        
        // Get the Master Factor Record Id For Step Rate and Limits where default is true.
        //masterStepFactorId = String.valueOf([SELECT Id, Name, Default__c, Factor_Type__c FROM Master_Factor__c WHERE Default__c = true AND Factor_type__c = 'Step Rate' LIMIT 1].Id);
        //masterLimitFactorId = String.valueOf([SELECT Id, Name, Default__c, Factor_Type__c FROM Master_Factor__c WHERE Default__c = true AND Factor_type__c = 'Coverage' LIMIT 1].Id);
        
        // Get the Step Factor To fetch all the Step Rate Factor Values.
        //stepFactors = [SELECT Id, Factor_Value_Step_Rate_0__c, Factor_Value_Step_Rate_1__c, Factor_Value_Step_Rate_2__c, Factor_Value_Step_Rate_3__c, Factor_Value_Step_Rate_4__c, Factor_Value_Step_Rate_5__c, Factor_Value_Step_Rate_6__c, Factor_Value_Step_Rate_7__c, Master_Factor__c FROM Step_Rate_Factor__c WHERE Master_Factor__c =: masterStepFactorId];
        
        List<Step_Rate_Factor__c> stepRateFactorsList = new List<Step_Rate_Factor__c>([SELECT Id,From_Date__c,To_Date__c, Factor_Value_Step_Rate_0__c, Factor_Value_Step_Rate_1__c, Factor_Value_Step_Rate_2__c, Factor_Value_Step_Rate_3__c, Factor_Value_Step_Rate_4__c, Factor_Value_Step_Rate_5__c, Factor_Value_Step_Rate_6__c, Factor_Value_Step_Rate_7__c, Master_Factor__c FROM Step_Rate_Factor__c WHERE Master_Factor__r.Factor_type__c = 'Step Rate']);
        
        // Get the lowest coverage factor and its value for primary calculations.
        //lowestLimitFactor = [SELECT Id, Factor_Value__c, Lowest_Coverage__c, Master_Factor__c FROM ILF_Coverage_Factor__c WHERE Master_Factor__c =: masterLimitFactorId AND Lowest_Coverage__c = true];
        
        List<ILF_Coverage_Factor__c> lowestLimitFactorList = new List<ILF_Coverage_Factor__c>([SELECT Id,From_Date__c,To_Date__c, Factor_Value__c, Lowest_Coverage__c, Master_Factor__c FROM ILF_Coverage_Factor__c WHERE Master_Factor__r.Factor_type__c = 'Coverage' AND Lowest_Coverage__c = true]);
        
        // Get all the Policy Endorsement Ids to SOQL.
        for (Policy_Endorsement__c polEnd : lstPendingChangeLawyer) {
            setPolicyEndorsementIds.add(polEnd.Id);
            setPolicyIds.add(polEnd.Policy__c);
            setPolicyLawyerIds.add(polEnd.Policy_Lawyer__c);
        }
        
        // Get all the Policies related to the endorsements and fill the map.
        for (Policy__c pol : [SELECT Id, Name, Effective_Date__c, Expiration_Date__c, Limit__c, Firm_Mod__c, Deductible_ID__c, Base_Amount__c, Final_Quote_10x10_Value__c,ADJ_MOD__c,X5_5_Override__c,X10x10__c FROM Policy__c WHERE Id IN: setPolicyIds]) {
            for(Step_Rate_Factor__c factor : stepRateFactorsList){
                if(factor.From_Date__c <= pol.Effective_Date__c &&  factor.To_Date__c >= pol.Effective_Date__c){
                    stepFactors.put(pol.Id,factor);
                }
            }
            for(ILF_Coverage_Factor__c factor : lowestLimitFactorList){
                if(factor.From_Date__c <= pol.Effective_Date__c &&  factor.To_Date__c >= pol.Effective_Date__c){
                    lowestLimitFactor.put(pol.Id,factor);
                }
            }
            system.debug('--------mapOfPolicies-----'+mapOfPolicies);
            mapOfPolicies.put(pol.Id,pol);
            setLimitFactorIds.add(pol.Limit__c);
            setDeductibleFactorIds.add(pol.Deductible_ID__c);
        }
        
        // Get all the limits applied to policy endorsements and fill the map.
        for (ILF_Coverage_Factor__c lim : [SELECT Id, Name, Is_5X5_Coverage__c, Is_10X10_Coverage__c, Percnt_amt_5X5_Step_0__c, Percnt_amt_5X5_Step_1__c, Percnt_amt_5X5_Step_2__c, Percnt_amt_5X5_Step_3__c, Premium_Rate_5X5__c, Factor_Value__c FROM ILF_Coverage_Factor__c WHERE Id IN: setLimitFactorIds]) {
            mapOfLimits.put(lim.Id,lim);
        }
        
        // Get all the deductibles applied to policy endorsements and fill the map.
        for (Deductible_Factor__c ded : [SELECT Id, Name, Deductible_Amount__c, Factor_Value__c, Master_Factor__c FROM Deductible_Factor__c WHERE Id IN: setDeductibleFactorIds]) {
            mapOfDeductibles.put(ded.Id,ded);
        }
        
        // Get the Policy Lawyer records to check if the premium amount should be added or subtracted.
        for (Policy_Lawyer__c polLaw : [SELECT Id, Name, Step__c, Rate_At__c, Policy__c, Premium__c FROM Policy_Lawyer__c WHERE Id IN: setPolicyLawyerIds AND Policy__c IN: setPolicyIds]) {
            mapOfPolicyLawyers.put(polLaw.Id,polLaw);
        }
        
        // SOQL the Policy Endorsemnts for calculations.
        for (Policy_Endorsement__c polEnd : [SELECT Id, Policy_Lawyer__c, Rate_At__c, Prior_Act_Date__c, Step__c, Step_Override__c, Step_Override_Value__c, Type__c, Term__c, Days_Pro_Rated__c, Premium__c, Override_Rating__c, Override_5_5__c, Override_10_10__c, Primary__c, Premium_5_5__c, Premium_10_10__c, Policy__c FROM Policy_Endorsement__c WHERE Id IN: setPolicyEndorsementIds]) {
            Decimal stepFactorValue;
            Decimal rate = (polEnd.Rate_At__c == null ? 0 : polEnd.Rate_At__c) / 100;
            Decimal amountBeforeDeductible;
            Decimal deductibleFactorAmount;
            
            ILF_Coverage_Factor__c limitFactor = mapOfLimits.get(mapOfPolicies.get(polEnd.Policy__c).Limit__c);
            Deductible_Factor__c deductibleFactor = mapOfDeductibles.get(mapOfPolicies.get(polEnd.Policy__c).Deductible_ID__c);
            
            Decimal daysProRated = polEnd.Prior_Act_Date__c.daysBetween(mapOfPolicies.get(polEnd.Policy__c).Expiration_Date__c) + 1 ;
            
            polEnd.Step__c = ApplicationPolicyUtil.CalculateLawyerStep(mapOfPolicies.get(polEnd.Policy__c).Effective_Date__c,polEnd.Prior_Act_Date__c);
            polEnd.Term__c = polEnd.Days_Pro_Rated__c / (Date.isLeapYear(Date.today().year()) ?  366 : 365);
            
            if(polEnd.Term__c > 1){
                polEnd.Term__c = 1;
            }
            
            if (polEnd.Step_Override__c == true) {
                if (polEnd.Step_Override_Value__c == 0) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                } else if (polEnd.Step_Override_Value__c == 1) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_1__c:0;
                } else if (polEnd.Step_Override_Value__c == 2) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_2__c:0;
                } else if (polEnd.Step_Override_Value__c == 3) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_3__c:0;
                } else if (polEnd.Step_Override_Value__c == 4) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_4__c:0;
                } else if (polEnd.Step_Override_Value__c == 5) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_5__c:0;
                } else if (polEnd.Step_Override_Value__c == 6) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_6__c:0;
                } else if (polEnd.Step_Override_Value__c == 7) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_7__c:0;
                }
            } else {
                if (polEnd.Step__c == 0) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                } else if (polEnd.Step__c == 1) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_1__c:0;
                } else if (polEnd.Step__c == 2) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_2__c:0;
                } else if (polEnd.Step__c == 3) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_3__c:0;
                } else if (polEnd.Step__c == 4) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_4__c:0;
                } else if (polEnd.Step__c == 5) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_5__c:0;
                } else if (polEnd.Step__c == 6) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_6__c:0;
                } else if (polEnd.Step__c == 7) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_7__c:0;
                }
            }

            amountBeforeDeductible = (100 * stepFactorValue * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * limitFactor.Factor_Value__c * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c) / 100;
            amountBeforeDeductible = amountBeforeDeductible.round(System.RoundingMode.HALF_UP);
            
            deductibleFactorAmount = ((stepFactorValue * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * (lowestLimitFactor.containsKey(polEnd.Policy__c)?lowestLimitFactor.get(polEnd.Policy__c).Factor_Value__c:0) * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c) - (stepFactorValue * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * (lowestLimitFactor.containsKey(polEnd.Policy__c)?lowestLimitFactor.get(polEnd.Policy__c).Factor_Value__c:0) * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c * deductibleFactor.Factor_Value__c));
            deductibleFactorAmount = (100 * deductibleFactorAmount) / 100;
            deductibleFactorAmount = deductibleFactorAmount.round(System.RoundingMode.HALF_UP);
            deductibleFactorAmount = deductibleFactorAmount * (-1);
            
            //polEnd.Primary__c = (100 * stepFactorValue * rate * polEnd.Term__c * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * limitFactor.Factor_Value__c * deductibleFactor.Factor_Value__c * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c) / 100;
            polEnd.Primary__c = (amountBeforeDeductible + deductibleFactorAmount) * rate * polEnd.Term__c;
            polEnd.Primary__c = (100 * polEnd.Primary__c) / 100;
            polEnd.Primary__c = polEnd.Primary__c.round(System.RoundingMode.HALF_UP);
            
            if (limitFactor.Is_5X5_Coverage__c == true) {
                if (polEnd.Step_Override__c == true) {
                    if (polEnd.Step_Override_Value__c == 0) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_0__c;
                    } else if (polEnd.Step_Override_Value__c == 1) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_1__c;
                    } else if (polEnd.Step_Override_Value__c == 2) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_2__c;
                    } else if (polEnd.Step_Override_Value__c == 3) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_3__c;
                    } else if (polEnd.Step_Override_Value__c > 3) {
                        polEnd.Premium_5_5__c = limitFactor.Premium_Rate_5X5__c;
                    }
                }else if(mapOfPolicies.get(polEnd.Policy__c).X5_5_Override__c != null && mapOfPolicies.get(polEnd.Policy__c).X5_5_Override__c>0){
                    polEnd.Premium_5_5__c = mapOfPolicies.get(polEnd.Policy__c).X5_5_Override__c;
                } else {
                    if (polEnd.Step__c == 0) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_0__c;
                    } else if (polEnd.Step__c == 1) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_1__c;
                    } else if (polEnd.Step__c == 2) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_2__c;
                    } else if (polEnd.Step__c == 3) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_3__c;
                    } else if (polEnd.Step__c > 3) {
                        polEnd.Premium_5_5__c = limitFactor.Premium_Rate_5X5__c;
                    }
                    polEnd.Premium_5_5__c = polEnd.Premium_5_5__c * polEnd.Term__c;
                }
            } else {
                polEnd.Premium_5_5__c = 0.00;
            }
            
            if(mapOfPolicies.get(polEnd.Policy__c).X10x10__c != null && mapOfPolicies.get(polEnd.Policy__c).X10x10__c>0){
                polEnd.Premium_10_10__c = mapOfPolicies.get(polEnd.Policy__c).X10x10__c * polEnd.Term__c;
            }else{
                polEnd.Premium_10_10__c = 0.0;
            }
            
            
            
            
            // Removing the 10 X 10 from per lawyer calculations, because 10 X 10 is applicable per policy as per discussion with Gibran 03/01/2017.
            //if (limitFactor.Is_10X10_Coverage__c == true) {
            //    polEnd.Premium_10_10__c = mapOfPolicies.get(polEnd.Policy__c).Final_Quote_10x10_Value__c;
            //} else {
            //    polEnd.Premium_10_10__c = 0.0;
            //}
            
            if (polEnd.Override_Rating__c == true) {
                polEnd.Premium__c = polEnd.Primary__c + (polEnd.Override_5_5__c == null ? 0 : polEnd.Override_5_5__c) + (polEnd.Override_10_10__c == null ? 0 : polEnd.Override_10_10__c);
            } else {
                polEnd.Premium__c = polEnd.Primary__c + (polEnd.Premium_5_5__c == null ? 0 : polEnd.Premium_5_5__c) + (polEnd.Premium_10_10__c == null ? 0 : polEnd.Premium_10_10__c);
            }
            
            if(mapOfPolicyLawyers.containsKey(polEnd.Policy_Lawyer__c) && mapOfPolicyLawyers.get(polEnd.Policy_Lawyer__c).Premium__c != null){
            
                polEnd.Premium__c = polEnd.Premium__c - mapOfPolicyLawyers.get(polEnd.Policy_Lawyer__c).Premium__c;
            
            }
            if(mapOfPolicies.get(polEnd.Policy__c).ADJ_MOD__c!=null){
                polEnd.Premium__c += ( polEnd.Premium__c +  (polEnd.Premium__c * (mapOfPolicies.get(polEnd.Policy__c).ADJ_MOD__c - 1)));
            }
            polEnd.Premium__c = (100 * polEnd.Premium__c) / 100;
            polEnd.Premium__c = polEnd.Premium__c.round(System.RoundingMode.HALF_UP);
            
            lstPolicyEndorsementsToUpdate.add(polEnd);
            system.debug(lstPolicyEndorsementsToUpdate);
        }
        update lstPolicyEndorsementsToUpdate;
    }
    
    // Complete Change Lawyer Helper Function.
    public static void completeChangeLawyer(List<Policy_Endorsement__c> lstCompleteChangeLawyer) {
        Set<String> setPolicyIds = new Set<String>();
        Set<String> setLawyerIds = new Set<String>();
        List<Policy_Lawyer__c> lstLawyersToUpdate = new List<Policy_Lawyer__c>();
        List<AS_Transaction__c> lstASTransaction = new List<AS_Transaction__c>();
        List<Policy__c> lstPoliciesToUpdate = new List<Policy__c>();
        
        // Get the policy ids and the lawyer ids from the Policy Endorsements to update.
        for (Policy_Endorsement__c polEnd : lstCompleteChangeLawyer) {
            setPolicyIds.add(polEnd.Policy__c);
            setLawyerIds.add(polEnd.Policy_Lawyer__c);
        }
        
        // SOQL the Policy Lawyers to update based on the policy id and lawyer id.
        for (Policy_Lawyer__c polLaw : [SELECT Id, Account__c, Lawyer__c, Policy__c, Primary__c, Step__c, X5_5__c, X10_10__c, Premium__c, Prior_Act_Date__c, Active__c, Deleted_Lawyer__c, Deleted_Date__c FROM Policy_Lawyer__c WHERE Id IN: setLawyerIds AND Policy__c IN: setPolicyIds AND Deleted_Lawyer__c = false]) {
            for (Policy_Endorsement__c polEnd : lstCompleteChangeLawyer) {
                if (polLaw.Id == polEnd.Policy_Lawyer__c && polLaw.Policy__c == polEnd.Policy__c) {
                    polLaw.Account__c = polEnd.Account__c;
                    polLaw.Primary__c = polEnd.Primary__c;
                    polLaw.Step__c = (polEnd.Step_Override__c ? polEnd.Step_Override_Value__c : polEnd.Step__c);
                    polLaw.X5_5__c = (polEnd.Override_Rating__c ? polEnd.Override_5_5__c : polEnd.Premium_5_5__c);
                    polLaw.X10_10__c = (polEnd.Override_Rating__c ? polEnd.Override_10_10__c : polEnd.Premium_10_10__c);
                    polLaw.Premium__c = polEnd.Premium__c;
                    polLaw.Prior_Act_Date__c = polEnd.Prior_Act_Date__c;
                    polLaw.Active__c = true;
                    polLaw.Deleted_Lawyer__c = false;
                    polLaw.Deleted_Date__c = null;
                    lstLawyersToUpdate.add(polLaw);
                    
                    AS_Transaction__c asTransaction = new AS_Transaction__c();
                    asTransaction.Amount__c = polEnd.Premium__c;
                    asTransaction.Firm_Id__c = polEnd.Account__c;
                    asTransaction.Policy_Endorsement_Id__c = polEnd.Id;
                    asTransaction.Policy_Id__c = polEnd.Policy__c;
                    asTransaction.Transaction_Type__c = 'Change Lawyer';
                    asTransaction.Transaction_Sub_Type__c = 'Change Lawyer';
                    lstASTransaction.add(asTransaction);
                }
            }
        }
        update lstLawyersToUpdate;
        insert lstASTransaction;
        
        // SOQL Policies to update premium.
        for (Policy__c pol : [SELECT Id, Name, Premium__c FROM Policy__c WHERE Id IN: setPolicyIds]) {
            for (Policy_Endorsement__c polEnd : lstCompleteChangeLawyer) {
                if (pol.Id == polEnd.Policy__c) {
                    pol.Premium__c = pol.Premium__c + polEnd.Premium__c;
                    
                    lstPoliciesToUpdate.add(pol);
                }
            }
        }
        update lstPoliciesToUpdate;
    }*/
    
    // Pending Delete Lawyer Helper Function.
    public static void pendingDeleteLawyer(List<Policy_Endorsement__c> lstPendingDeleteLawyer) {
        //String masterStepFactorId;
        //String masterLimitFactorId;
        //Step_Rate_Factor__c stepFactors = new Step_Rate_Factor__c();
        //ILF_Coverage_Factor__c lowestLimitFactor = new ILF_Coverage_Factor__c();
        /*Map<Id,Step_Rate_Factor__c> stepFactors = new Map<Id,Step_Rate_Factor__c>();
        Map<Id,ILF_Coverage_Factor__c> lowestLimitFactor = new Map<Id,ILF_Coverage_Factor__c>();
        Set<String> setPolicyEndorsementIds = new Set<String>();
        Set<String> setPolicyIds = new Set<String>();
        set<String> setLimitFactorIds = new Set<String>();
        set<String> setDeductibleFactorIds = new Set<String>();
        set<String> setPolicyLawyerIds = new Set<String>();
        Map<String,Policy__c> mapOfPolicies = new Map<String,Policy__c>();
        Map<String,ILF_Coverage_Factor__c> mapOfLimits = new Map<String,ILF_Coverage_Factor__c>();
        Map<String,Deductible_Factor__c> mapOfDeductibles = new Map<String,Deductible_Factor__c>();
        Map<String,Policy_Lawyer__c> mapOfPolicyLawyers = new Map<String,Policy_Lawyer__c>();
        List<Policy_Endorsement__c> lstPolicyEndorsements = new List<Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstPolicyEndorsementsToUpdate = new List<Policy_Endorsement__c>();
        
        // Get the Master Factor Record Id For Step Rate and Limits where default is true.
        //masterStepFactorId = String.valueOf([SELECT Id, Name, Default__c, Factor_Type__c FROM Master_Factor__c WHERE Default__c = true AND Factor_type__c = 'Step Rate' LIMIT 1].Id);
        //masterLimitFactorId = String.valueOf([SELECT Id, Name, Default__c, Factor_Type__c FROM Master_Factor__c WHERE Default__c = true AND Factor_type__c = 'Coverage' LIMIT 1].Id);
        
        // Get the Step Factor To fetch all the Step Rate Factor Values.
        //stepFactors = [SELECT Id, Factor_Value_Step_Rate_0__c, Factor_Value_Step_Rate_1__c, Factor_Value_Step_Rate_2__c, Factor_Value_Step_Rate_3__c, Factor_Value_Step_Rate_4__c, Factor_Value_Step_Rate_5__c, Factor_Value_Step_Rate_6__c, Factor_Value_Step_Rate_7__c, Master_Factor__c FROM Step_Rate_Factor__c WHERE Master_Factor__c =: masterStepFactorId];
        List<Step_Rate_Factor__c> stepRateFactorsList = new List<Step_Rate_Factor__c>([SELECT Id,From_Date__c,To_Date__c, Factor_Value_Step_Rate_0__c, Factor_Value_Step_Rate_1__c, Factor_Value_Step_Rate_2__c, Factor_Value_Step_Rate_3__c, Factor_Value_Step_Rate_4__c, Factor_Value_Step_Rate_5__c, Factor_Value_Step_Rate_6__c, Factor_Value_Step_Rate_7__c, Master_Factor__c FROM Step_Rate_Factor__c WHERE Master_Factor__r.Factor_type__c = 'Step Rate']);
        // Get the lowest coverage factor and its value for primary calculations.
        //lowestLimitFactor = [SELECT Id, Factor_Value__c, Lowest_Coverage__c, Master_Factor__c FROM ILF_Coverage_Factor__c WHERE Master_Factor__c =: masterLimitFactorId AND Lowest_Coverage__c = true];
        List<ILF_Coverage_Factor__c> lowestLimitFactorList = new List<ILF_Coverage_Factor__c>([SELECT Id,From_Date__c,To_Date__c, Factor_Value__c, Lowest_Coverage__c, Master_Factor__c FROM ILF_Coverage_Factor__c WHERE Master_Factor__r.Factor_type__c = 'Coverage' AND Lowest_Coverage__c = true]);
        // Get all the Policy Endorsement Ids to SOQL.
        for (Policy_Endorsement__c polEnd : lstPendingDeleteLawyer) {
            setPolicyEndorsementIds.add(polEnd.Id);
            setPolicyIds.add(polEnd.Policy__c);
            setPolicyLawyerIds.add(polEnd.Policy_Lawyer__c);
        }
        
        // Get all the Policies related to the endorsements and fill the map.
        for (Policy__c pol : [SELECT Id, Name, Effective_Date__c, Expiration_Date__c, Limit__c, Firm_Mod__c, Deductible_ID__c, Base_Amount__c, Final_Quote_10x10_Value__c,ADJ_MOD__c FROM Policy__c WHERE Id IN: setPolicyIds]) {
            for(Step_Rate_Factor__c factor : stepRateFactorsList){
                if(factor.From_Date__c <= pol.Effective_Date__c &&  factor.To_Date__c >= pol.Effective_Date__c){
                    stepFactors.put(pol.Id,factor);
                }
            }
            for(ILF_Coverage_Factor__c factor : lowestLimitFactorList){
                if(factor.From_Date__c <= pol.Effective_Date__c &&  factor.To_Date__c >= pol.Effective_Date__c){
                    lowestLimitFactor.put(pol.Id,factor);
                }
            }
            mapOfPolicies.put(pol.Id,pol);
            setLimitFactorIds.add(pol.Limit__c);
            setDeductibleFactorIds.add(pol.Deductible_ID__c);
        }
        
        // Get all the limits applied to policy endorsements and fill the map.
        for (ILF_Coverage_Factor__c lim : [SELECT Id, Name, Is_5X5_Coverage__c, Is_10X10_Coverage__c, Percnt_amt_5X5_Step_0__c, Percnt_amt_5X5_Step_1__c, Percnt_amt_5X5_Step_2__c, Percnt_amt_5X5_Step_3__c, Premium_Rate_5X5__c, Factor_Value__c FROM ILF_Coverage_Factor__c WHERE Id IN: setLimitFactorIds]) {
            mapOfLimits.put(lim.Id,lim);
        }
        
        // Get all the deductibles applied to policy endorsements and fill the map.
        for (Deductible_Factor__c ded : [SELECT Id, Name, Deductible_Amount__c, Factor_Value__c, Master_Factor__c FROM Deductible_Factor__c WHERE Id IN: setDeductibleFactorIds]) {
            mapOfDeductibles.put(ded.Id,ded);
        }
        
        // Get all the policy lawyer infor to be updated in policy.
        for (Policy_lawyer__c polLaw : [SELECT Id, Rate_At__c FROM Policy_Lawyer__c WHERE Id IN: setPolicyLawyerIds]) {
            mapOfPolicyLawyers.put(polLaw.Id,polLaw);
        }
        
        // SOQL the Policy Endorsemnts for calculations.
        for (Policy_Endorsement__c polEnd : [SELECT Id, Policy_Lawyer__c, Rate_At__c, Prior_Act_Date__c, Step__c, Step_Override__c, Step_Override_Value__c, Type__c, Term__c, Days_Pro_Rated__c, Premium__c, Override_Rating__c, Override_5_5__c, Override_10_10__c, Primary__c, Premium_5_5__c, Premium_10_10__c, Policy__c FROM Policy_Endorsement__c WHERE Id IN: setPolicyEndorsementIds]) {
            Decimal stepFactorValue;
            Decimal rate;
            
            if(mapOfPolicyLawyers.containsKey(polEnd.Policy_Lawyer__c)){
               
               rate = (mapOfPolicyLawyers.get(polEnd.Policy_Lawyer__c).Rate_At__c == 0 ? 0 : mapOfPolicyLawyers.get(polEnd.Policy_Lawyer__c).Rate_At__c) / 100;
            
            } else {
            
               rate = 0;     
            }
            
             Decimal amountBeforeDeductible;
            Decimal deductibleFactorAmount;
            
            ILF_Coverage_Factor__c limitFactor = mapOfLimits.get(mapOfPolicies.get(polEnd.Policy__c).Limit__c);
            Deductible_Factor__c deductibleFactor = mapOfDeductibles.get(mapOfPolicies.get(polEnd.Policy__c).Deductible_ID__c);
            
            polEnd.Step__c = ApplicationPolicyUtil.CalculateLawyerStep(mapOfPolicies.get(polEnd.Policy__c).Effective_Date__c,polEnd.Prior_Act_Date__c);
            polEnd.Term__c = polEnd.Days_Pro_Rated__c / (Date.isLeapYear(Date.today().year()) ?  366 : 365);
            //polEnd.Rate_At__c = mapOfPolicyLawyers.get(polEnd.Policy_Lawyer__c).Rate_At__c;
            
            if (polEnd.Step_Override__c == true) {
                if (polEnd.Step_Override_Value__c == 0) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                } else if (polEnd.Step_Override_Value__c == 1) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_1__c:0;
                } else if (polEnd.Step_Override_Value__c == 2) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_2__c:0;
                } else if (polEnd.Step_Override_Value__c == 3) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_3__c:0;
                } else if (polEnd.Step_Override_Value__c == 4) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_4__c:0;
                } else if (polEnd.Step_Override_Value__c == 5) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_5__c:0;
                } else if (polEnd.Step_Override_Value__c == 6) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_6__c:0;
                } else if (polEnd.Step_Override_Value__c == 7) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_7__c:0;
                }
            } else {
                if (polEnd.Step__c == 0) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                } else if (polEnd.Step__c == 1) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_1__c:0;
                } else if (polEnd.Step__c == 2) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_2__c:0;
                } else if (polEnd.Step__c == 3) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_3__c:0;
                } else if (polEnd.Step__c == 4) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_4__c:0;
                } else if (polEnd.Step__c == 5) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_5__c:0;
                } else if (polEnd.Step__c == 6) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_6__c:0;
                } else if (polEnd.Step__c == 7) {
                    stepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_7__c:0;
                }
            }

            amountBeforeDeductible = (100 * stepFactorValue * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * limitFactor.Factor_Value__c * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c) / 100;
            amountBeforeDeductible = amountBeforeDeductible.round(System.RoundingMode.HALF_UP);
            
            deductibleFactorAmount = ((stepFactorValue * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * (lowestLimitFactor.containsKey(polEnd.Policy__c)?lowestLimitFactor.get(polEnd.Policy__c).Factor_Value__c:0) * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c) - (stepFactorValue * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * (lowestLimitFactor.containsKey(polEnd.Policy__c)?lowestLimitFactor.get(polEnd.Policy__c).Factor_Value__c:0) * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c * deductibleFactor.Factor_Value__c));
            deductibleFactorAmount = (100 * deductibleFactorAmount) / 100;
            deductibleFactorAmount = deductibleFactorAmount.round(System.RoundingMode.HALF_UP);
            deductibleFactorAmount = deductibleFactorAmount * (-1);
            
            //polEnd.Primary__c = (100 * stepFactorValue * rate * polEnd.Term__c * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * limitFactor.Factor_Value__c * deductibleFactor.Factor_Value__c * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c) / 100;
            polEnd.Primary__c = (amountBeforeDeductible + deductibleFactorAmount) * rate * polEnd.Term__c;
            polEnd.Primary__c = (100 * polEnd.Primary__c) / 100;
            polEnd.Primary__c = polEnd.Primary__c.round(System.RoundingMode.HALF_UP);
            
            if (limitFactor.Is_5X5_Coverage__c == true) {
                if (polEnd.Step_Override__c == true) {
                    if (polEnd.Step_Override_Value__c == 0) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_0__c;
                    } else if (polEnd.Step_Override_Value__c == 1) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_1__c;
                    } else if (polEnd.Step_Override_Value__c == 2) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_2__c;
                    } else if (polEnd.Step_Override_Value__c == 3) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_3__c;
                    } else if (polEnd.Step_Override_Value__c > 3) {
                        polEnd.Premium_5_5__c = limitFactor.Premium_Rate_5X5__c;
                    }
                } else {
                    if (polEnd.Step__c == 0) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_0__c;
                    } else if (polEnd.Step__c == 1) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_1__c;
                    } else if (polEnd.Step__c == 2) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_2__c;
                    } else if (polEnd.Step__c == 3) {
                        polEnd.Premium_5_5__c = limitFactor.Percnt_amt_5X5_Step_3__c;
                    } else if (polEnd.Step__c > 3) {
                        polEnd.Premium_5_5__c = limitFactor.Premium_Rate_5X5__c;
                    }
                    polEnd.Premium_5_5__c = polEnd.Premium_5_5__c * polEnd.Term__c;
                }
            } else {
                polEnd.Premium_5_5__c = 0.00;
            }
            
            polEnd.Premium_10_10__c = 0.0;
            
            // Removing the 10 X 10 from per lawyer calculations, because 10 X 10 is applicable per policy as per discussion with Gibran 03/01/2017.
            //if (limitFactor.Is_10X10_Coverage__c == true) {
            //    polEnd.Premium_10_10__c = mapOfPolicies.get(polEnd.Policy__c).Final_Quote_10x10_Value__c;
            //} else {
            //    polEnd.Premium_10_10__c = 0.0;
            //}
            
            if (polEnd.Override_Rating__c == true) {
                polEnd.Premium__c = polEnd.Primary__c + (polEnd.Override_5_5__c == null ? 0 : polEnd.Override_5_5__c) + (polEnd.Override_10_10__c == null ? 0 : polEnd.Override_10_10__c);
                if(mapOfPolicies.get(polEnd.Policy__c).ADJ_MOD__c!=null){
                    polEnd.Premium__c = ( polEnd.Premium__c +  (polEnd.Premium__c * (mapOfPolicies.get(polEnd.Policy__c).ADJ_MOD__c - 1)));
                }
                polEnd.Refund_Amount__c = polEnd.Premium__c;
                polEnd.Premium__c = polEnd.Premium__c * (-1);
                polEnd.Premium__c = (100 * polEnd.Premium__c) / 100;
                polEnd.Premium__c = polEnd.Premium__c.round(System.RoundingMode.HALF_UP);
            } else {
                polEnd.Premium__c = polEnd.Primary__c + (polEnd.Premium_5_5__c == null ? 0 : polEnd.Premium_5_5__c) + (polEnd.Premium_10_10__c == null ? 0 : polEnd.Premium_10_10__c);
                if(mapOfPolicies.get(polEnd.Policy__c).ADJ_MOD__c!=null){
                    polEnd.Premium__c = ( polEnd.Premium__c +  (polEnd.Premium__c * (mapOfPolicies.get(polEnd.Policy__c).ADJ_MOD__c - 1)));
                }
                polEnd.Refund_Amount__c = polEnd.Premium__c;
                polEnd.Premium__c = polEnd.Premium__c * (-1);
                polEnd.Premium__c = (100 * polEnd.Premium__c) / 100;
                polEnd.Premium__c = polEnd.Premium__c.round(System.RoundingMode.HALF_UP);
            }           
            polEnd.Primary__c = polEnd.Primary__c * (-1);
            lstPolicyEndorsementsToUpdate.add(polEnd);
            system.debug(lstPolicyEndorsementsToUpdate);
        }*/
        Map<String,Policy_Lawyer__c> mapOfPolicyLawyers = new Map<String,Policy_Lawyer__c>();
        Map<String,Policy__c> mapOfPolicies = new Map<String,Policy__c>();
        Set<String> setPolicyEndorsementIds = new Set<String>();
        Set<String> setPolicyIds = new Set<String>();
        set<String> setPolicyLawyerIds = new Set<String>();
        List<Policy_Endorsement__c> lstPolicyEndorsementsToUpdate = new List<Policy_Endorsement__c>();
        for (Policy_Endorsement__c polEnd : lstPendingDeleteLawyer) {
            setPolicyEndorsementIds.add(polEnd.Id);
            setPolicyIds.add(polEnd.Policy__c);
            setPolicyLawyerIds.add(polEnd.Policy_Lawyer__c);
        }
        
        for (Policy__c pol : [SELECT Id, Name, Effective_Date__c, Expiration_Date__c, Limit__c, Firm_Mod__c, Deductible_ID__c, Base_Amount__c, Final_Quote_10x10_Value__c,ADJ_MOD__c FROM Policy__c WHERE Id in : setPolicyIds]) {
            mapOfPolicies.put(pol.Id,pol);
        }
        
        for (Policy_Lawyer__c polLaw : [SELECT Id, Rate_At__c,Prior_Act_Date__c,Premium__c,Primary__c,X5_5__c,X10_10__c,Excess__c,Added_Date__c FROM Policy_Lawyer__c WHERE Id in:  setPolicyLawyerIds]) {
            mapOfPolicyLawyers.put(polLaw.Id,polLaw);
        }
        
        for (Policy_Endorsement__c policyEndorsement : [SELECT Id, Policy_Lawyer__c, Rate_At__c, Prior_Act_Date__c, Step__c, Step_Override__c, Step_Override_Value__c, Type__c, Term__c, Days_Pro_Rated__c, Premium__c, Override_Rating__c, Override_5_5__c, Override_10_10__c, Primary__c, Premium_5_5__c, Premium_10_10__c, Policy__c,Endorsement_Effective_Date__c FROM Policy_Endorsement__c WHERE Id IN: setPolicyEndorsementIds]) {
            policyEndorsement.Prior_Act_Date__c = mapOfPolicyLawyers.get(policyEndorsement.Policy_Lawyer__c).Prior_Act_Date__c;
            
            policyEndorsement.Step__c = ApplicationPolicyUtil.CalculateLawyerStep(mapOfPolicies.get(policyEndorsement.Policy__c).Effective_Date__c,policyEndorsement.Prior_Act_Date__c);
            
            Date endorsementEffectiveDate = policyEndorsement.Endorsement_Effective_Date__c;
            System.debug('endorsementEffectiveDate---'+endorsementEffectiveDate);
            System.debug('map----'+mapOfPolicies.get(policyEndorsement.Policy__c).Expiration_Date__c);
            Decimal daysProRated = endorsementEffectiveDate.daysBetween(mapOfPolicies.get(policyEndorsement.Policy__c).Expiration_Date__c) + 1;
            policyEndorsement.Term__c = daysProRated / (Date.isLeapYear(Date.today().year()) ?  366 : 365);
            if(mapOfPolicyLawyers.get(policyEndorsement.Policy_Lawyer__c).Added_Date__c != null){
                policyEndorsement.Term__c = daysProRated /  (mapOfPolicyLawyers.get(policyEndorsement.Policy_Lawyer__c).Added_Date__c.daysBetween(mapOfPolicies.get(policyEndorsement.Policy__c).Expiration_Date__c) + 1);
            }
            if(policyEndorsement.Term__c > 1){
                policyEndorsement.Term__c = 1;
            }
            policyEndorsement.Primary__c = mapOfPolicyLawyers.get(policyEndorsement.Policy_Lawyer__c).Primary__c == null ? 0 :(mapOfPolicyLawyers.get(policyEndorsement.Policy_Lawyer__c).Primary__c*policyEndorsement.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            policyEndorsement.Excess__c = mapOfPolicyLawyers.get(policyEndorsement.Policy_Lawyer__c).Excess__c == null ? 0 :(mapOfPolicyLawyers.get(policyEndorsement.Policy_Lawyer__c).Excess__c*policyEndorsement.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            policyEndorsement.Premium_5_5__c = mapOfPolicyLawyers.get(policyEndorsement.Policy_Lawyer__c).X5_5__c == null ? 0 :(mapOfPolicyLawyers.get(policyEndorsement.Policy_Lawyer__c).X5_5__c*policyEndorsement.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            policyEndorsement.Premium_10_10__c = mapOfPolicyLawyers.get(policyEndorsement.Policy_Lawyer__c).X10_10__c == null ? 0 :(mapOfPolicyLawyers.get(policyEndorsement.Policy_Lawyer__c).X10_10__c*policyEndorsement.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            policyEndorsement.Premium__c = mapOfPolicyLawyers.get(policyEndorsement.Policy_Lawyer__c).Premium__c == null ? 0 :(mapOfPolicyLawyers.get(policyEndorsement.Policy_Lawyer__c).Premium__c*policyEndorsement.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            policyEndorsement.Refund_Amount__c = mapOfPolicyLawyers.get(policyEndorsement.Policy_Lawyer__c).Premium__c == null ? 0 :(mapOfPolicyLawyers.get(policyEndorsement.Policy_Lawyer__c).Premium__c*policyEndorsement.Term__c).round(System.RoundingMode.HALF_UP);
            system.debug('policyEndorsement = >'+policyEndorsement);
            lstPolicyEndorsementsToUpdate.add(policyEndorsement);
        }
        
        update lstPolicyEndorsementsToUpdate;
    }
    
    // Complete Delete Lawyer Helper Function.
    public static void completeDeleteLawyer(List<Policy_Endorsement__c> lstCompleteDeleteLawyer) {
        Set<String> setPolicyIds = new Set<String>();
        Set<String> setPolicyLawyerIds = new Set<String>();
        List<Policy_Lawyer__c> lstLawyersToUpdate = new List<Policy_Lawyer__c>();
        List<AS_Transaction__c> lstASTransaction = new List<AS_Transaction__c>();
        List<Policy__c> lstPoliciesToUpdate = new List<Policy__c>();
        List<Policy_Premium_History__c> premiumHistoryList = new List<Policy_Premium_History__c>();
        
        // Get the Policy Lawyer Ids to mark the lawyers as deleted on the policy.
        for (Policy_Endorsement__c polEnd : lstCompleteDeleteLawyer) {
            setPolicyIds.add(polEnd.Policy__c);
            setPolicyLawyerIds.add(polEnd.Policy_Lawyer__c);
        }
        
        // SOQL the policy lawyer record and mark it as deleted. Also create as list of accounting seed object transactions.
        for (Policy_Lawyer__c polLaw : [SELECT Id, Account__c, Lawyer__c, Policy__c, Primary__c, Step__c, X5_5__c, X10_10__c, Premium__c, Prior_Act_Date__c, Active__c, Deleted_Lawyer__c, Deleted_Date__c, Old_Primary_Value__c,Old_Step_Value__c,Old_5x5_Value__c,Old_10x10_Value__c,Old_Premium__c,Old_Prior_Act_Date__c,Excess__c,Old_Excess__c FROM Policy_Lawyer__c WHERE Id IN: setPolicyLawyerIds AND Policy__c IN: setPolicyIds AND Deleted_Lawyer__c = false]) {
            for (Policy_Endorsement__c polEnd : lstCompleteDeleteLawyer) {
                if (polLaw.Id == polEnd.Policy_Lawyer__c && polLaw.Policy__c == polEnd.Policy__c) {
                    polLaw.Old_Primary_Value__c=polLaw.Primary__c ;
                    polLaw.Old_Step_Value__c=polLaw.Step__c ;
                    polLaw.Old_5x5_Value__c=polLaw.X5_5__c ;
                    polLaw.Old_10x10_Value__c=polLaw.X10_10__c ;
                    polLaw.Old_Premium__c=polLaw.Premium__c ;
                    polLaw.Old_Prior_Act_Date__c=polLaw.Prior_Act_Date__c ;
                    polLaw.Old_Excess__c = polLaw.Excess__c ;

                    polLaw.Account__c = polEnd.Account__c;
                    polLaw.Primary__c = polLaw.Primary__c == null ? 0 : (polLaw.Primary__c + polEnd.Primary__c);
                    polLaw.Excess__c = polLaw.Excess__c == null ? 0 : (polLaw.Excess__c + polEnd.Excess__c);
                    polLaw.Step__c = polEnd.Step__c;
                    polLaw.X5_5__c = polLaw.X5_5__c == null ? 0 : (polLaw.X5_5__c + polEnd.Premium_5_5__c); 
                    polLaw.X10_10__c = polLaw.X10_10__c == null ? 0 : (polLaw.X10_10__c + polEnd.Premium_10_10__c); 
                    polLaw.Premium__c = polLaw.Premium__c == null ? 0 : (polLaw.Premium__c + polEnd.Premium__c);
                    polLaw.Prior_Act_Date__c = polEnd.Prior_Act_Date__c;
                    polLaw.Active__c = false;
                    polLaw.Deleted_Lawyer__c = True;
                    polLaw.Deleted_Date__c = polEnd.Endorsement_Effective_Date__c;
                    lstLawyersToUpdate.add(polLaw);
                    if(Label.Process_Accounting_On_Endorsements == 'Y'){
                        lstASTransaction = getIL_153_Transactions(polEnd);
                    }
                    
                    Policy_Premium_History__c premiumHistory = new Policy_Premium_History__c();
                    premiumHistory.Policy__c = polEnd.Policy__c;
                    premiumHistory.Action__c = 'Delete Lawyer';
                    premiumHistory.Premium__c = polEnd.Premium__c;
                    premiumHistory.X10x10_value__c = (polEnd.Override_Rating__c ? polEnd.Override_10_10__c : polEnd.Premium_10_10__c);
                    premiumHistory.X5x5_value__c = (polEnd.Override_Rating__c ? polEnd.Override_5_5__c : polEnd.Premium_5_5__c);
                    
                    premiumHistoryList.add(premiumHistory);
                }
            }
        }
        update lstLawyersToUpdate;
        insert lstASTransaction;
        insert premiumHistoryList;
        
        // SOQL Policies to update premium.
        for (Policy__c pol : [SELECT Id, Name, Premium__c,Total_5x5__c,Total_10x10__c,Excess_Premium__c,Primary__c FROM Policy__c WHERE Id IN: setPolicyIds]) {
            for (Policy_Endorsement__c polEnd : lstCompleteDeleteLawyer) {
                if (pol.Id == polEnd.Policy__c) {
                    pol.Premium__c = pol.Premium__c + polEnd.Premium__c;
                    pol.Total_5x5__c = (pol.Total_5x5__c == null ? 0 : pol.Total_5x5__c) + (polEnd.Premium_5_5__c == null ? 0 : polEnd.Premium_5_5__c);
                    pol.Total_10x10__c = (pol.Total_10x10__c == null ? 0 : pol.Total_10x10__c) + (polEnd.Premium_10_10__c == null ? 0 : polEnd.Premium_10_10__c); 
                    pol.Excess_Premium__c = (pol.Excess_Premium__c == null ? 0 : pol.Excess_Premium__c) + (polEnd.Excess__c == null ? 0 : polEnd.Excess__c); 
                    pol.Primary__c = (pol.Primary__c == null ? 0 : pol.Primary__c) + (polEnd.Primary__c == null ? 0 : polEnd.Primary__c);
                    lstPoliciesToUpdate.add(pol);
                }
            }
        }
        update lstPoliciesToUpdate;
    }
    
    public static List<AS_Transaction__c> getIL_153_Transactions(Policy_Endorsement__c polEnd){
        List<AS_Transaction__c> lstASTransaction = new List<AS_Transaction__c>();
        AS_Transaction__c AS_SingleEntry = new AS_Transaction__c();
        AS_SingleEntry.Amount__c = polEnd.Premium__c;
        AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
        AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
        AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
        AS_SingleEntry.Transaction_Type__c = 'Delete Lawyer';
        AS_SingleEntry.Transaction_Sub_Type__c = 'Delete Lawyer';
        lstASTransaction.add(AS_SingleEntry);
        
        if(polEnd.Premium_5_5__c !=null && polEnd.Premium_5_5__c != 0){
            AS_SingleEntry = new AS_Transaction__c();
            AS_SingleEntry.Amount__c = polEnd.Premium_5_5__c;
            AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
            AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
            AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
            AS_SingleEntry.Transaction_Type__c = 'Delete Lawyer';
            AS_SingleEntry.Transaction_Sub_Type__c = '5x5';
            lstASTransaction.add(AS_SingleEntry);
        }
        if(polEnd.Premium_10_10__c !=null && polEnd.Premium_10_10__c != 0){
            AS_SingleEntry = new AS_Transaction__c();
            AS_SingleEntry.Amount__c = polEnd.Premium_10_10__c;
            AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
            AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
            AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
            AS_SingleEntry.Transaction_Type__c = 'Delete Lawyer';
            AS_SingleEntry.Transaction_Sub_Type__c = '10x10';
            lstASTransaction.add(AS_SingleEntry);
        }
        
        if(polEnd.Primary__c !=null && polEnd.Primary__c != 0){
            AS_SingleEntry = new AS_Transaction__c();
            AS_SingleEntry.Amount__c = polEnd.Primary__c;
            AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
            AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
            AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
            AS_SingleEntry.Transaction_Type__c = 'Delete Lawyer';
            AS_SingleEntry.Transaction_Sub_Type__c = 'Primary';
            lstASTransaction.add(AS_SingleEntry);
        }
        
        //if(polEnd.Excess__c !=null && polEnd.Excess__c != 0){
        AS_SingleEntry = new AS_Transaction__c();
        AS_SingleEntry.Amount__c = (polEnd.Excess__c != null ? polEnd.Excess__c : 0 ) + (polEnd.Primary__c != null ? polEnd.Primary__c : 0 );
        AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
        AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
        AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
        AS_SingleEntry.Transaction_Type__c = 'Delete Lawyer';
        AS_SingleEntry.Transaction_Sub_Type__c = 'PrimaryAndExcess';
        lstASTransaction.add(AS_SingleEntry);
        //}
        return lstASTransaction;
    }
    
    // Pending Adjust Premium Helper Function.
    /*public static void pendingAdjustPremium(List<Policy_Endorsement__c> lstPendingAdjustPremium) {
        // Get the set of policy endorsements id's to SOQL record and update the calculations.
        Set<Id> setPolicyEndorsementIds = (new Map<Id,SObject>(lstPendingAdjustPremium)).keySet();
        List<Policy_Endorsement__c> lstPolicyEndorsementsToUpdate = new List<Policy_Endorsement__c>();
        // Loop through the policy endorsements and calculate the premium.
        for (Policy_Endorsement__c pol : [SELECT Id, Premium_5_5__c, Premium_10_10__c, Premium__c, Primary__c FROM Policy_Endorsement__c WHERE Id IN: setPolicyEndorsementIds]) {
            pol.Premium__c = pol.Primary__c + pol.Premium_5_5__c + pol.Premium_10_10__c;
            lstPolicyEndorsementsToUpdate.add(pol);
        }
        // Update the calculation on Policy Endorsement.
        update lstPolicyEndorsementsToUpdate;
    }
    
    // Complete Adjust Premium Helper Function.
    public static void completeAdjustPremium(List<Policy_Endorsement__c> lstCompleteAdjustPremium) {
        Map<String,Policy_Endorsement__c> mapPolicyEndorsements = new Map<String,Policy_Endorsement__c>();
        List<Policy__c> lstPoliciesToUpdate = new List<Policy__c>();
        List<AS_Transaction__c> lstASTransaction = new List<AS_Transaction__c>();
        // Get the set of policy id's to update premium.
        for (Policy_Endorsement__c polEnd : lstCompleteAdjustPremium) {
            mapPolicyEndorsements.put(polEnd.Policy__c,polEnd);
        }
        // SOQL Policies and update the premium field with the premium from policy endorsement.
        for (Policy__c pol : [SELECT Id, Name, Premium__c, Account__c FROM Policy__c WHERE Id IN: mapPolicyEndorsements.keySet()]) {
            Policy_Endorsement__c polEnd = mapPolicyEndorsements.get(pol.Id);
            pol.Premium__c = pol.Premium__c + mapPolicyEndorsements.get(pol.Id).Premium__c;
            lstPoliciesToUpdate.add(pol);
            
            AS_Transaction__c asTransaction = new AS_Transaction__c();
            asTransaction.Amount__c = polEnd.Premium__c;
            asTransaction.Firm_Id__c = pol.Account__c;
            asTransaction.Policy_Endorsement_Id__c = polEnd.Id;
            asTransaction.Policy_Id__c = polEnd.Policy__c;
            asTransaction.Transaction_Type__c = 'Adjust Premium';
            asTransaction.Transaction_Sub_Type__c = 'Adjust Premium';
            lstASTransaction.add(asTransaction);
        }
        // Update policy with the new premium from policy endorsement.
        update lstPoliciesToUpdate;
        insert lstASTransaction;
    } */
    
    // Pending Change Coverage Helper Function.
    public static void pendingChangeCoverage(List<Policy_Endorsement__c> lstPendingChangeCoverage) {
        //String masterStepFactorId;
        //String masterLimitFactorId;
        //Step_Rate_Factor__c stepFactors = new Step_Rate_Factor__c();
        //ILF_Coverage_Factor__c lowestLimitFactor = new ILF_Coverage_Factor__c();
        Map<Id,Step_Rate_Factor__c> stepFactors = new Map<Id,Step_Rate_Factor__c>();
        Map<Id,ILF_Coverage_Factor__c> lowestLimitFactor = new Map<Id,ILF_Coverage_Factor__c>();
        Set<String> setPolicyEndorsementIds = new Set<String>();
        Set<String> setPolicyIds = new Set<String>();
        Set<String> setLimitFactorIds = new Set<String>();
        Set<String> setOldLimitFactorIds = new Set<String>();
        Set<String> setDeductibleFactorIds = new Set<String>();
        Map<String,Policy__c> mapOfPolicies = new Map<String,Policy__c>();
        Map<String,ILF_Coverage_Factor__c> mapOfLimits = new Map<String,ILF_Coverage_Factor__c>();
        Map<String,ILF_Coverage_Factor__c> mapOfOldLimits = new Map<String,ILF_Coverage_Factor__c>();
        Map<String,Deductible_Factor__c> mapOfDeductibles = new Map<String,Deductible_Factor__c>();
        Map<String,List<Policy_Lawyer__c>> mapOfPolicyLawyers = new Map<String,List<Policy_Lawyer__c>>();
        List<Policy_Endorsement__c> lstPolicyEndorsementsToUpdate = new List<Policy_Endorsement__c>();
        
        // Get the Master Factor Record Id For Step Rate and Limits where default is true.
        //masterStepFactorId = String.valueOf([SELECT Id, Name, Default__c, Factor_Type__c FROM Master_Factor__c WHERE Default__c = true AND Factor_type__c = 'Step Rate' LIMIT 1].Id);
        //masterLimitFactorId = String.valueOf([SELECT Id, Name, Default__c, Factor_Type__c FROM Master_Factor__c WHERE Default__c = true AND Factor_type__c = 'Coverage' LIMIT 1].Id);
        
        // Get the Step Factor To fetch all the Step Rate Factor Values.
        //stepFactors = [SELECT Id, Factor_Value_Step_Rate_0__c, Factor_Value_Step_Rate_1__c, Factor_Value_Step_Rate_2__c, Factor_Value_Step_Rate_3__c, Factor_Value_Step_Rate_4__c, Factor_Value_Step_Rate_5__c, Factor_Value_Step_Rate_6__c, Factor_Value_Step_Rate_7__c, Master_Factor__c FROM Step_Rate_Factor__c WHERE Master_Factor__c =: masterStepFactorId];
        List<Step_Rate_Factor__c> stepRateFactorsList = new List<Step_Rate_Factor__c>([SELECT Id,From_Date__c,To_Date__c, Factor_Value_Step_Rate_0__c, Factor_Value_Step_Rate_1__c, Factor_Value_Step_Rate_2__c, Factor_Value_Step_Rate_3__c, Factor_Value_Step_Rate_4__c, Factor_Value_Step_Rate_5__c, Factor_Value_Step_Rate_6__c, Factor_Value_Step_Rate_7__c, Master_Factor__c FROM Step_Rate_Factor__c WHERE Master_Factor__r.Factor_type__c = 'Step Rate']);
        // Get the lowest coverage factor and its value for primary calculations.
        //lowestLimitFactor = [SELECT Id, Factor_Value__c, Lowest_Coverage__c, Master_Factor__c FROM ILF_Coverage_Factor__c WHERE Master_Factor__c =: masterLimitFactorId AND Lowest_Coverage__c = true];
        List<ILF_Coverage_Factor__c> lowestLimitFactorList = new List<ILF_Coverage_Factor__c>([SELECT Id,From_Date__c,To_Date__c, Factor_Value__c, Lowest_Coverage__c, Master_Factor__c FROM ILF_Coverage_Factor__c WHERE Master_Factor__r.Factor_type__c = 'Coverage' AND Lowest_Coverage__c = true]);
        // Get all the Policy Endorsement Ids to SOQL.
        for (Policy_Endorsement__c polEnd : lstPendingChangeCoverage) {
            setPolicyEndorsementIds.add(polEnd.Id);
            setPolicyIds.add(polEnd.Policy__c);
            setLimitFactorIds.add(polEnd.New_Limits__c);
        }
        
        // Get all the Policies related to the endorsements and fill the map.
        for (Policy__c pol : [SELECT Id, Name, Effective_Date__c, Expiration_Date__c, Limit__c, Firm_Mod__c, Deductible_ID__c, Base_Amount__c, Final_Quote_10x10_Value__c FROM Policy__c WHERE Id IN: setPolicyIds]) {
            for(Step_Rate_Factor__c factor : stepRateFactorsList){
                if(factor.From_Date__c <= pol.Effective_Date__c &&  factor.To_Date__c >= pol.Effective_Date__c){
                    stepFactors.put(pol.Id,factor);
                }
            }
            for(ILF_Coverage_Factor__c factor : lowestLimitFactorList){
                if(factor.From_Date__c <= pol.Effective_Date__c &&  factor.To_Date__c >= pol.Effective_Date__c){
                    lowestLimitFactor.put(pol.Id,factor);
                }
            }
            mapOfPolicies.put(pol.Id,pol);
            setOldLimitFactorIds.add(pol.Limit__c);
            setDeductibleFactorIds.add(pol.Deductible_ID__c);
        }
        
        // Get all the limits applied to policy endorsements and fill the map.
        for (ILF_Coverage_Factor__c lim : [SELECT Id, Name, Is_5X5_Coverage__c, Full_Coverage__c, Is_10X10_Coverage__c, Percnt_amt_5X5_Step_0__c, Percnt_amt_5X5_Step_1__c, Percnt_amt_5X5_Step_2__c, Percnt_amt_5X5_Step_3__c, Percnt_amt_5X5_Step_4__c, Percnt_amt_5X5_Step_5__c, Percnt_amt_5X5_Step_6__c, Percnt_amt_5X5_Step_7__c, Premium_Rate_5X5__c, Factor_Value__c FROM ILF_Coverage_Factor__c WHERE Id IN: setLimitFactorIds]) {
            mapOfLimits.put(lim.Id,lim);
        }
        for (ILF_Coverage_Factor__c lim : [SELECT Id, Name, Is_5X5_Coverage__c, Full_Coverage__c, Is_10X10_Coverage__c, Percnt_amt_5X5_Step_0__c, Percnt_amt_5X5_Step_1__c, Percnt_amt_5X5_Step_2__c, Percnt_amt_5X5_Step_3__c, Percnt_amt_5X5_Step_4__c, Percnt_amt_5X5_Step_5__c, Percnt_amt_5X5_Step_6__c, Percnt_amt_5X5_Step_7__c, Premium_Rate_5X5__c, Factor_Value__c FROM ILF_Coverage_Factor__c WHERE Id IN: setOldLimitFactorIds]) {
            mapOfOldLimits.put(lim.Id,lim);
        }
        
        // Get all the deductibles applied to policy endorsements and fill the map.
        for (Deductible_Factor__c ded : [SELECT Id, Name, Deductible_Amount__c, Factor_Value__c, Master_Factor__c FROM Deductible_Factor__c WHERE Id IN: setDeductibleFactorIds]) {
            mapOfDeductibles.put(ded.Id,ded);
        }
        
        // Get the Policy Lawyer records to calculate per lawyer premium.
        for (Policy_Lawyer__c polLaw : [SELECT Id, Name, Step__c, Rate_At__c, Policy__c, Premium__c, X10_10__c, X5_5__c, Primary__c FROM Policy_Lawyer__c WHERE Policy__c IN: setPolicyIds AND Active__c = true AND Deleted_Lawyer__c = false]) {
            if (mapOfPolicyLawyers.containsKey(polLaw.Policy__c)) {
                List<Policy_Lawyer__c> lstPolicyLawyers = mapOfPolicyLawyers.get(polLaw.Policy__c);
                lstPolicyLawyers.add(polLaw);
                mapOfPolicyLawyers.put(polLaw.Policy__c,lstPolicyLawyers);
            } else {
                List<Policy_Lawyer__c> lstPolicyLawyers = new List<Policy_Lawyer__c>();
                lstPolicyLawyers.add(polLaw);
                mapOfPolicyLawyers.put(polLaw.Policy__c,lstPolicyLawyers);
            }
        }
        
        // SOQL Policy Endorsements and calculate term for each endorsement.
        for (Policy_Endorsement__c polEnd : [SELECT Check_Leap_Year__c, Endorsement_Effective_Date__c, Term__c, Id, Override_Rating__c, Policy__c, Premium_5_5__c, Premium_10_10__c, Premium__c, Primary__c, Days_Pro_Rated__c, Override_5_5__c, Override_10_10__c, New_Limits__c FROM Policy_Endorsement__c WHERE Id IN: setPolicyEndorsementIds]) {
            Policy__c policyRecord = mapOfPolicies.get(polEnd.Policy__c);
            ILF_Coverage_Factor__c limitFactor = mapOfLimits.get(polEnd.New_Limits__c);
            ILF_Coverage_Factor__c oldLimitFactor = mapOfOldLimits.get(policyRecord.Limit__c);
            Deductible_Factor__c deductibleFactor  = mapOfDeductibles.get(policyRecord.Deductible_ID__c);
            polEnd.Term__c = polEnd.Days_Pro_Rated__c / (polEnd.Check_Leap_Year__c ?  366 : 365);
            polEnd.Premium__c = 0;
            polEnd.Primary__c = 0;
            polEnd.Premium_5_5__c = 0;
            polEnd.Premium_10_10__c = 0;
            
            // Fetch Lawyer to calculate premium per lawyer.
            if (mapOfPolicyLawyers.get(polEnd.Policy__c).size() > 0) {
                for (Policy_Lawyer__c polLaw : mapOfPolicyLawyers.get(polEnd.Policy__c)) {
                    Decimal StepFactorValue;
                    Decimal Rate = (polLaw.Rate_At__c == 0 ? 0 : polLaw.Rate_At__c) / 100;
                    Decimal amountBeforeDeductible;
                    Decimal deductibleFactorAmount;
                    
                    // Set the step factor value.
                    if (polLaw.Step__c == 0) {
                        StepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                    } else if (polLaw.Step__c == 1) {
                        StepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                    } else if (polLaw.Step__c == 2) {
                        StepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                    } else if (polLaw.Step__c == 3) {
                        StepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                    } else if (polLaw.Step__c == 4) {
                        StepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                    } else if (polLaw.Step__c == 5) {
                        StepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                    } else if (polLaw.Step__c == 6) {
                        StepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                    } else if (polLaw.Step__c == 7) {
                        StepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                    }
                    
                    system.debug('Step Rate: ' + stepFactorValue);
                    system.debug('Base Amount: ' + mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c);
                    //system.debug('Limit Factor Value: ' + limitFactor.Factor_Value__c);
                    system.debug('Firm Mod: ' + mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c);
                    system.debug('Deductible Factor: ' + deductibleFactor.Factor_Value__c);  
                    
                    amountBeforeDeductible = (100 * stepFactorValue * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * limitFactor.Factor_Value__c * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c) / 100;
                    amountBeforeDeductible = amountBeforeDeductible.round(System.RoundingMode.HALF_UP);
                    
                    deductibleFactorAmount = ((stepFactorValue * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * (lowestLimitFactor.containsKey(polEnd.Policy__c)?lowestLimitFactor.get(polEnd.Policy__c).Factor_Value__c:0) * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c) - (stepFactorValue * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * (lowestLimitFactor.containsKey(polEnd.Policy__c)?lowestLimitFactor.get(polEnd.Policy__c).Factor_Value__c:0) * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c * deductibleFactor.Factor_Value__c));
                    deductibleFactorAmount = (100 * deductibleFactorAmount) / 100;
                    deductibleFactorAmount = deductibleFactorAmount.round(System.RoundingMode.HALF_UP);
                    deductibleFactorAmount = deductibleFactorAmount * (-1);
                    
                    system.debug('Rate: ' + Rate);
                    system.debug('Term: ' + polEnd.Term__c);
                    system.debug('Amount Before Deductible: ' + amountBeforeDeductible);
                    system.debug('Deductible Factor Amount: ' + deductibleFactorAmount);
                    
                    //polLaw.Primary__c = (100 * stepFactorValue * rate * polEnd.Term__c * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * limitFactor.Factor_Value__c * deductibleFactor.Factor_Value__c * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c) / 100;
                    polLaw.Primary__c = (amountBeforeDeductible + deductibleFactorAmount) * Rate * polEnd.Term__c;
                    polLaw.Primary__c = (100 * polLaw.Primary__c) / 100;
                    polLaw.Primary__c = polLaw.Primary__c.round(System.RoundingMode.HALF_UP);
                    
                    system.debug('Primary: ' + polLaw.Primary__c);
                    
                    // Add the per lawyer primary to make the endorsement primary.
                    polEnd.Primary__c = (polEnd.Primary__c != null ? polEnd.Primary__c : 0) + polLaw.Primary__c;
                    
                    // Set the Premium 5*5 Value.
                    if (limitFactor.Is_5X5_Coverage__c == true) {
                        if (polLaw.Step__c == 0) {
                            polLaw.X5_5__c = limitFactor.Percnt_amt_5X5_Step_0__c;
                        } else if (polLaw.Step__c == 1) {
                            polLaw.X5_5__c = limitFactor.Percnt_amt_5X5_Step_1__c;
                        } else if (polLaw.Step__c == 2) {
                            polLaw.X5_5__c = limitFactor.Percnt_amt_5X5_Step_2__c;
                        } else if (polLaw.Step__c == 3) {
                            polLaw.X5_5__c = limitFactor.Percnt_amt_5X5_Step_3__c;
                        } else if (polLaw.Step__c == 4) {
                            polLaw.X5_5__c = limitFactor.Percnt_amt_5X5_Step_4__c;
                        } else if (polLaw.Step__c == 5) {
                            polLaw.X5_5__c = limitFactor.Percnt_amt_5X5_Step_5__c;
                        } else if (polLaw.Step__c == 6) {
                            polLaw.X5_5__c = limitFactor.Percnt_amt_5X5_Step_6__c;
                        } else if (polLaw.Step__c == 7) {
                            polLaw.X5_5__c = limitFactor.Percnt_amt_5X5_Step_7__c;
                        }
                        polLaw.X5_5__c = polLaw.X5_5__c * polEnd.Term__c;
                    } else {
                        polLaw.X5_5__c = 0.00;
                    }
                    
                    // Add the per lawyer 5 X 5 to get endorsement 5 X 5.
                    polEnd.Premium_5_5__c = (polEnd.Premium_5_5__c != null ? polEnd.Premium_5_5__c : 0) + polLaw.X5_5__c;
                    
                    polLaw.X10_10__c = 0.0;
                    
                    // Add the per lawyer 10 X 10 to get endorsement 10 X 10.
                    polEnd.Premium_10_10__c = (polEnd.Premium_10_10__c != null ? polEnd.Premium_10_10__c : 0) + polLaw.X10_10__c;
                    
                    // Removing the 10 X 10 from per lawyer calculations, because 10 X 10 is applicable per policy as per discussion with Gibran 03/01/2017.
                    //if (limitFactor.Is_10X10_Coverage__c == true) {
                    //    polLaw.X10_10__c = mapOfPolicies.get(polEnd.Policy__c).Final_Quote_10x10_Value__c;
                    //} else {
                    //    polLaw.X10_10__c = 0.0;
                    //}
                    
                    if (polEnd.Override_Rating__c == true) {
                        polLaw.Premium__c = polLaw.Primary__c + (polEnd.Override_5_5__c == null ? 0 : polEnd.Override_5_5__c);
                    } else {
                        polLaw.Premium__c = polLaw.Primary__c + (polLaw.X5_5__c == null ? 0 : polLaw.X5_5__c) + (polLaw.X10_10__c == null ? 0 : polLaw.X10_10__c);
                    }
                    
                    // Add per lawyer premium to get policy endorsement premium.
                    polEnd.Premium__c = (polEnd.Premium__c != null ? polEnd.Premium__c : 0) + polLaw.Premium__c;
                }    
            } else {
                polEnd.Premium__c = 0;
            }
            
            if (polEnd.Override_Rating__c == true) {
                polEnd.Premium__c = (polEnd.Premium__c != null ? polEnd.Premium__c : 0) + polEnd.Override_10_10__c;
            }
            
            // Check with the old limits to see if the new limit is greater or lesser, if greater then premium will be added otherwise premium will be subtracted.
            if (oldLimitFactor.Factor_Value__c > limitFactor.Factor_Value__c) {
                polEnd.Premium__c = polEnd.Premium__c * (-1);
            } else {
                polEnd.Premium__c = polEnd.Premium__c * (1);
            }
            
            polEnd.Premium__c = (100 * polEnd.Premium__c) / 100;
            polEnd.Premium__c = polEnd.Premium__c.round(System.RoundingMode.HALF_UP);
            system.debug('policyEndorsement = >'+polEnd);
            lstPolicyEndorsementsToUpdate.add(polEnd);
        }
        update lstPolicyEndorsementsToUpdate;
    }
    
    // Complete Change Coverage Helper Function.
    public static void completeChangeCoverage(List<Policy_Endorsement__c> lstCompleteChangeCoverage) {
        //String masterStepFactorId;
        //String masterLimitFactorId;
        //Step_Rate_Factor__c stepFactors = new Step_Rate_Factor__c();
        //ILF_Coverage_Factor__c lowestLimitFactor = new ILF_Coverage_Factor__c();
        Map<Id,Step_Rate_Factor__c> stepFactors = new Map<Id,Step_Rate_Factor__c>();
        Map<Id,ILF_Coverage_Factor__c> lowestLimitFactor = new Map<Id,ILF_Coverage_Factor__c>();
        Set<String> setPolicyEndorsementIds = new Set<String>();
        Set<String> setPolicyIds = new Set<String>();
        Set<String> setLimitFactorIds = new Set<String>();
        Set<String> setOldLimitFactorIds = new Set<String>();
        Set<String> setDeductibleFactorIds = new Set<String>();
        Map<String,Policy__c> mapOfPolicies = new Map<String,Policy__c>();
        Map<String,ILF_Coverage_Factor__c> mapOfLimits = new Map<String,ILF_Coverage_Factor__c>();
        Map<String,ILF_Coverage_Factor__c> mapOfOldLimits = new Map<String,ILF_Coverage_Factor__c>();
        Map<String,Deductible_Factor__c> mapOfDeductibles = new Map<String,Deductible_Factor__c>();
        Map<String,List<Policy_Lawyer__c>> mapOfPolicyLawyers = new Map<String,List<Policy_Lawyer__c>>();
        List<Policy_Lawyer__c> lstLawyersToUpdate = new List<Policy_Lawyer__c>();
        List<Policy__c> lstPoliciesToUpdate = new List<Policy__c>();
        List<AS_Transaction__c> lstASTransaction = new List<AS_Transaction__c>();
        List<Policy_Endorsement__c> lstPolicyEndorsementsToUpdate = new List<Policy_Endorsement__c>();
        
        // Get the Master Factor Record Id For Step Rate and Limits where default is true.
        //masterStepFactorId = String.valueOf([SELECT Id, Name, Default__c, Factor_Type__c FROM Master_Factor__c WHERE Default__c = true AND Factor_type__c = 'Step Rate' LIMIT 1].Id);
        //masterLimitFactorId = String.valueOf([SELECT Id, Name, Default__c, Factor_Type__c FROM Master_Factor__c WHERE Default__c = true AND Factor_type__c = 'Coverage' LIMIT 1].Id);
        
        // Get the Step Factor To fetch all the Step Rate Factor Values.
        //stepFactors = [SELECT Id, Factor_Value_Step_Rate_0__c, Factor_Value_Step_Rate_1__c, Factor_Value_Step_Rate_2__c, Factor_Value_Step_Rate_3__c, Factor_Value_Step_Rate_4__c, Factor_Value_Step_Rate_5__c, Factor_Value_Step_Rate_6__c, Factor_Value_Step_Rate_7__c, Master_Factor__c FROM Step_Rate_Factor__c WHERE Master_Factor__c =: masterStepFactorId];
        List<Step_Rate_Factor__c> stepRateFactorsList = new List<Step_Rate_Factor__c>([SELECT Id,From_Date__c,To_Date__c, Factor_Value_Step_Rate_0__c, Factor_Value_Step_Rate_1__c, Factor_Value_Step_Rate_2__c, Factor_Value_Step_Rate_3__c, Factor_Value_Step_Rate_4__c, Factor_Value_Step_Rate_5__c, Factor_Value_Step_Rate_6__c, Factor_Value_Step_Rate_7__c, Master_Factor__c FROM Step_Rate_Factor__c WHERE Master_Factor__r.Factor_type__c = 'Step Rate']);
        // Get the lowest coverage factor and its value for primary calculations.
        //lowestLimitFactor = [SELECT Id, Factor_Value__c, Lowest_Coverage__c, Master_Factor__c FROM ILF_Coverage_Factor__c WHERE Master_Factor__c =: masterLimitFactorId AND Lowest_Coverage__c = true];
        List<ILF_Coverage_Factor__c> lowestLimitFactorList = new List<ILF_Coverage_Factor__c>([SELECT Id,From_Date__c,To_Date__c, Factor_Value__c, Lowest_Coverage__c, Master_Factor__c FROM ILF_Coverage_Factor__c WHERE Master_Factor__r.Factor_type__c = 'Coverage' AND Lowest_Coverage__c = true]);
        // Get all the Policy Endorsement Ids to SOQL.
        for (Policy_Endorsement__c polEnd : lstCompleteChangeCoverage) {
            setPolicyEndorsementIds.add(polEnd.Id);
            setPolicyIds.add(polEnd.Policy__c);
            setLimitFactorIds.add(polEnd.New_Limits__c);
        }
        
        // Get all the Policies related to the endorsements and fill the map.
        for (Policy__c pol : [SELECT Id, Name, Effective_Date__c, Expiration_Date__c, Limit__c, Firm_Mod__c, Deductible_ID__c, Base_Amount__c, Final_Quote_10x10_Value__c, Premium__c, Account__c FROM Policy__c WHERE Id IN: setPolicyIds]) {
            for(Step_Rate_Factor__c factor : stepRateFactorsList){
                if(factor.From_Date__c <= pol.Effective_Date__c &&  factor.To_Date__c >= pol.Effective_Date__c){
                    stepFactors.put(pol.Id,factor);
                }
            }
            for(ILF_Coverage_Factor__c factor : lowestLimitFactorList){
                if(factor.From_Date__c <= pol.Effective_Date__c &&  factor.To_Date__c >= pol.Effective_Date__c){
                    lowestLimitFactor.put(pol.Id,factor);
                }
            }
            mapOfPolicies.put(pol.Id,pol);
            setOldLimitFactorIds.add(pol.Limit__c);
            setDeductibleFactorIds.add(pol.Deductible_ID__c);
        }
        
        // Get all the limits applied to policy endorsements and fill the map.
        for (ILF_Coverage_Factor__c lim : [SELECT Id, Name, Is_5X5_Coverage__c, Full_Coverage__c, Is_10X10_Coverage__c, Percnt_amt_5X5_Step_0__c, Percnt_amt_5X5_Step_1__c, Percnt_amt_5X5_Step_2__c, Percnt_amt_5X5_Step_3__c, Percnt_amt_5X5_Step_4__c, Percnt_amt_5X5_Step_5__c, Percnt_amt_5X5_Step_6__c, Percnt_amt_5X5_Step_7__c, Premium_Rate_5X5__c, Factor_Value__c FROM ILF_Coverage_Factor__c WHERE Id IN: setLimitFactorIds]) {
            mapOfLimits.put(lim.Id,lim);
        }
        for (ILF_Coverage_Factor__c lim : [SELECT Id, Name, Is_5X5_Coverage__c, Full_Coverage__c, Is_10X10_Coverage__c, Percnt_amt_5X5_Step_0__c, Percnt_amt_5X5_Step_1__c, Percnt_amt_5X5_Step_2__c, Percnt_amt_5X5_Step_3__c, Percnt_amt_5X5_Step_4__c, Percnt_amt_5X5_Step_5__c, Percnt_amt_5X5_Step_6__c, Percnt_amt_5X5_Step_7__c, Premium_Rate_5X5__c, Factor_Value__c FROM ILF_Coverage_Factor__c WHERE Id IN: setOldLimitFactorIds]) {
            mapOfOldLimits.put(lim.Id,lim);
        }
        
        // Get all the deductibles applied to policy endorsements and fill the map.
        for (Deductible_Factor__c ded : [SELECT Id, Name, Deductible_Amount__c, Factor_Value__c, Master_Factor__c FROM Deductible_Factor__c WHERE Id IN: setDeductibleFactorIds]) {
            mapOfDeductibles.put(ded.Id,ded);
        }
        
        // Get the Policy Lawyer records to calculate per lawyer premium.
        for (Policy_Lawyer__c polLaw : [SELECT Id, Name, Step__c, Rate_At__c, Policy__c, Premium__c, X10_10__c, X5_5__c, Primary__c FROM Policy_Lawyer__c WHERE Policy__c IN: setPolicyIds AND Active__c = true AND Deleted_Lawyer__c = false]) {
            if (mapOfPolicyLawyers.containsKey(polLaw.Policy__c)) {
                List<Policy_Lawyer__c> lstPolicyLawyers = mapOfPolicyLawyers.get(polLaw.Policy__c);
                lstPolicyLawyers.add(polLaw);
                mapOfPolicyLawyers.put(polLaw.Policy__c,lstPolicyLawyers);
            } else {
                List<Policy_Lawyer__c> lstPolicyLawyers = new List<Policy_Lawyer__c>();
                lstPolicyLawyers.add(polLaw);
                mapOfPolicyLawyers.put(polLaw.Policy__c,lstPolicyLawyers);
            }
        }
        
        // SOQL Policy Endorsements and calculate term for each endorsement.
        for (Policy_Endorsement__c polEnd : [SELECT Check_Leap_Year__c, Endorsement_Effective_Date__c, Term__c, Id, Override_Rating__c, Policy__c, Premium_5_5__c, Premium_10_10__c, Premium__c, Primary__c, Days_Pro_Rated__c, Override_5_5__c, Override_10_10__c, New_Limits__c FROM Policy_Endorsement__c WHERE Id IN: setPolicyEndorsementIds]) {
            Policy__c policyRecord = mapOfPolicies.get(polEnd.Policy__c);
            ILF_Coverage_Factor__c limitFactor = mapOfLimits.get(polEnd.New_Limits__c);
            ILF_Coverage_Factor__c oldLimitFactor = mapOfOldLimits.get(policyRecord.Limit__c);
            Deductible_Factor__c deductibleFactor  = mapOfDeductibles.get(policyRecord.Deductible_ID__c);
            polEnd.Term__c = polEnd.Days_Pro_Rated__c / (polEnd.Check_Leap_Year__c ?  366 : 365);
            polEnd.Premium__c = 0;
            polEnd.Primary__c = 0;
            polEnd.Premium_5_5__c = 0;
            polEnd.Premium_10_10__c = 0;
            
            // Fetch Lawyer to calculate premium per lawyer.
            if (mapOfPolicyLawyers.get(polEnd.Policy__c).size() > 0) {
                for (Policy_Lawyer__c polLaw : mapOfPolicyLawyers.get(polEnd.Policy__c)) {
                    Decimal StepFactorValue;
                    Decimal Rate = (polLaw.Rate_At__c == 0 ? 0.0001 : polLaw.Rate_At__c) / 100;
                    Decimal amountBeforeDeductible;
                    Decimal deductibleFactorAmount;
                                        
                    // Set the step factor value.
                    if (polLaw.Step__c == 0) {
                        StepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                    } else if (polLaw.Step__c == 1) {
                        StepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                    } else if (polLaw.Step__c == 2) {
                        StepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                    } else if (polLaw.Step__c == 3) {
                        StepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                    } else if (polLaw.Step__c == 4) {
                        StepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                    } else if (polLaw.Step__c == 5) {
                        StepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                    } else if (polLaw.Step__c == 6) {
                        StepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                    } else if (polLaw.Step__c == 7) {
                        StepFactorValue = stepFactors.containsKey(polEnd.Policy__c)?stepFactors.get(polEnd.Policy__c).Factor_Value_Step_Rate_0__c:0;
                    }
                    
                    amountBeforeDeductible = (100 * stepFactorValue * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * limitFactor.Factor_Value__c * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c) / 100;
                    amountBeforeDeductible = amountBeforeDeductible.round(System.RoundingMode.HALF_UP);
                    
                    deductibleFactorAmount = ((stepFactorValue * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * (lowestLimitFactor.containsKey(polEnd.Policy__c)?lowestLimitFactor.get(polEnd.Policy__c).Factor_Value__c:0) * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c) - (stepFactorValue * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * (lowestLimitFactor.containsKey(polEnd.Policy__c)?lowestLimitFactor.get(polEnd.Policy__c).Factor_Value__c:0) * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c * deductibleFactor.Factor_Value__c));
                    deductibleFactorAmount = (100 * deductibleFactorAmount) / 100;
                    deductibleFactorAmount = deductibleFactorAmount.round(System.RoundingMode.HALF_UP);
                    deductibleFactorAmount = deductibleFactorAmount * (-1);
                    
                    //polLaw.Primary__c = (100 * stepFactorValue * rate * polEnd.Term__c * mapOfPolicies.get(polEnd.Policy__c).Base_Amount__c * limitFactor.Factor_Value__c * deductibleFactor.Factor_Value__c * mapOfPolicies.get(polEnd.Policy__c).Firm_Mod__c) / 100;
                    polLaw.Primary__c = (amountBeforeDeductible + deductibleFactorAmount) * rate * polEnd.Term__c;
                    polLaw.Primary__c = (100 * polLaw.Primary__c) / 100;
                    polLaw.Primary__c = polLaw.Primary__c.round(System.RoundingMode.HALF_UP);
                    
                    // Add the per lawyer primary to make the endorsement primary.
                    polEnd.Primary__c = (polEnd.Primary__c != null ? polEnd.Primary__c : 0) + polLaw.Primary__c;
                                        
                    // Set the Premium 5*5 Value.
                    if (limitFactor.Is_5X5_Coverage__c == true) {
                        if (polLaw.Step__c == 0) {
                            polLaw.X5_5__c = limitFactor.Percnt_amt_5X5_Step_0__c;
                        } else if (polLaw.Step__c == 1) {
                            polLaw.X5_5__c = limitFactor.Percnt_amt_5X5_Step_1__c;
                        } else if (polLaw.Step__c == 2) {
                            polLaw.X5_5__c = limitFactor.Percnt_amt_5X5_Step_2__c;
                        } else if (polLaw.Step__c == 3) {
                            polLaw.X5_5__c = limitFactor.Percnt_amt_5X5_Step_3__c;
                        } else if (polLaw.Step__c == 4) {
                            polLaw.X5_5__c = limitFactor.Percnt_amt_5X5_Step_4__c;
                        } else if (polLaw.Step__c == 5) {
                            polLaw.X5_5__c = limitFactor.Percnt_amt_5X5_Step_5__c;
                        } else if (polLaw.Step__c == 6) {
                            polLaw.X5_5__c = limitFactor.Percnt_amt_5X5_Step_6__c;
                        } else if (polLaw.Step__c == 7) {
                            polLaw.X5_5__c = limitFactor.Percnt_amt_5X5_Step_7__c;
                        }
                        polLaw.X5_5__c = polLaw.X5_5__c * polEnd.Term__c;
                    } else {
                        polLaw.X5_5__c = 0.00;
                    }
                    
                    // Add the per lawyer 5 X 5 to get endorsement 5 X 5.
                    polEnd.Premium_5_5__c = (polEnd.Premium_5_5__c != null ? polEnd.Premium_5_5__c : 0) + polLaw.X5_5__c;
                    
                    polLaw.X10_10__c = 0.0;
                    
                    // Add the per lawyer 10 X 10 to get endorsement 10 X 10.
                    polEnd.Premium_10_10__c = (polEnd.Premium_10_10__c != null ? polEnd.Premium_10_10__c : 0) + polLaw.X10_10__c;
                    
                    // Removing the 10 X 10 from per lawyer calculations, because 10 X 10 is applicable per policy as per discussion with Gibran 03/01/2017.
                    //if (limitFactor.Is_10X10_Coverage__c == true) {
                    //    polLaw.X10_10__c = mapOfPolicies.get(polEnd.Policy__c).Final_Quote_10x10_Value__c;
                    //} else {
                    //    polLaw.X10_10__c = 0.0;
                    //}
                    
                    if (polEnd.Override_Rating__c == true) {
                        polLaw.Premium__c = polLaw.Primary__c + (polEnd.Override_5_5__c == null ? 0 : polEnd.Override_5_5__c);
                    } else {
                        polLaw.Premium__c = polLaw.Primary__c + (polLaw.X5_5__c == null ? 0 : polLaw.X5_5__c) + (polLaw.X10_10__c == null ? 0 : polLaw.X10_10__c);
                    }
                    
                    polLaw.Premium__c = (100 * polLaw.Premium__c) / 100;
                    polLaw.Premium__c = polLaw.Premium__c.round(System.RoundingMode.HALF_UP);
                    
                    // Add per lawyer premium to get policy endorsement premium.
                    polEnd.Premium__c = (polEnd.Premium__c != null ? polEnd.Premium__c : 0) + polLaw.Premium__c;
                    lstLawyersToUpdate.add(polLaw);
                }    
            } else {
                polEnd.Premium__c = 0;
            }
            
            if (polEnd.Override_Rating__c == true) {
                polEnd.Premium__c = (polEnd.Premium__c != null ? polEnd.Premium__c : 0) + polEnd.Override_10_10__c;
            }
            
            // Check with the old limits to see if the new limit is greater or lesser, if greater then premium will be added otherwise premium will be subtracted.
            if (oldLimitFactor.Factor_Value__c > limitFactor.Factor_Value__c) {
                polEnd.Premium__c = polEnd.Premium__c * (-1);
            } else {
                polEnd.Premium__c = polEnd.Premium__c * (1);
            }
            polEnd.Premium__c = (100 * polEnd.Premium__c) / 100;
            polEnd.Premium__c = polEnd.Premium__c.round(System.RoundingMode.HALF_UP);
            system.debug('policyEndorsement = >'+polEnd);
            lstPolicyEndorsementsToUpdate.add(polEnd);
        }
        update lstLawyersToUpdate;
        
        // Update Policies And Make Accounting Seed Transactions.
        for (Policy_Endorsement__c polEnd : lstPolicyEndorsementsToUpdate) {
            Policy__c policyRecord = mapOfPolicies.get(polEnd.Policy__c);
            policyRecord.Limit__c = polEnd.New_Limits__c;
            policyRecord.Premium__c = policyRecord.Premium__c + polEnd.Premium__c;
            lstPoliciesToUpdate.add(policyRecord);
            
            AS_Transaction__c asTransaction = new AS_Transaction__c();
            asTransaction.Amount__c = polEnd.Premium__c;
            asTransaction.Firm_Id__c = policyRecord.Account__c;
            asTransaction.Policy_Endorsement_Id__c = polEnd.Id;
            asTransaction.Policy_Id__c = polEnd.Policy__c;
            asTransaction.Transaction_Type__c = 'Change Coverage';
            asTransaction.Transaction_Sub_Type__c = 'Change Coverage';
            lstASTransaction.add(asTransaction);
        }
        update lstPoliciesToUpdate;
        insert lstASTransaction;
    }
    
    // Pending Cancel Policy Helper Function.
    public static void pendingCancelPolicy(List<Policy_Endorsement__c> lstPendingCancelPolicy) {
        Set<String> setPolicyEndorsementIds = new Set<String>();
        Set<String> setOfPolicies = new Set<String>();
        Map<String,Policy__c> mapOfPolicies = new Map<String,Policy__c>();
        List<Policy_Endorsement__c> lstPolicyEndorsementsToUpdate = new List<Policy_Endorsement__c>();
        // loop through the policy endorsements to get the ids of the endorsements.
        for (Policy_Endorsement__c polEnd : lstPendingCancelPolicy) {
            setPolicyEndorsementIds.add(polEnd.Id);
            setOfPolicies.add(polEnd.Policy__c);
        }
        // SOQL Policies to get the Current premium for calculating Refund Amount.
        for (Policy__c pol : [SELECT Id, Premium__c,Expiration_Date__c,Primary__c,Excess_Premium__c,Total_5x5__c,Total_10x10__c FROM Policy__c WHERE Id IN: setOfPolicies]) {
            mapOfPolicies.put(pol.Id,pol);
        }
        // SOQL Policy Endorsements and calculate term for each endorsement.
        for (Policy_Endorsement__c polEnd : [SELECT Endorsement_Effective_Date__c, Term__c, Id, Override_Rating__c, Policy__c, Premium_5_5__c, Premium_10_10__c, Premium__c, Primary__c, Prior_Act_Date__c, Refund_Amount__c, Check_Leap_Year__c, Days_Pro_Rated__c, Override_5_5__c, Override_10_10__c,Policy__r.Effective_Date__c,Policy__r.Expiration_Date__c FROM Policy_Endorsement__c WHERE Id IN: setPolicyEndorsementIds]) {
            //polEnd.Term__c = polEnd.Days_Pro_Rated__c / (polEnd.Check_Leap_Year__c ?  366 : 365);
            //polEnd.Term__c = polEnd.Days_Pro_Rated__c / (polEnd.Policy__r.Effective_Date__c.daysBetween(polEnd.Policy__r.Expiration_Date__c));
            Decimal daysProRated = polEnd.Endorsement_Effective_Date__c.daysBetween(mapOfPolicies.get(polEnd.Policy__c).Expiration_Date__c) + 1;
            //polEnd.Term__c = daysProRated / (polEnd.Policy__r.Effective_Date__c.daysBetween(polEnd.Policy__r.Expiration_Date__c));
           	 polEnd.Term__c = daysProRated /(Date.isLeapYear(Date.today().year()) ?  366 : 365);
            if(polEnd.Term__c > 1){
                polEnd.Term__c = 1;
            }
            polEnd.Primary__c = mapOfPolicies.get(polEnd.Policy__c).Primary__c == null ? 0 :(mapOfPolicies.get(polEnd.Policy__c).Primary__c*polEnd.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            polEnd.Excess__c = mapOfPolicies.get(polEnd.Policy__c).Excess_Premium__c == null ? 0 :(mapOfPolicies.get(polEnd.Policy__c).Excess_Premium__c*polEnd.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            polEnd.Premium_5_5__c = mapOfPolicies.get(polEnd.Policy__c).Total_5x5__c == null ? 0 :(mapOfPolicies.get(polEnd.Policy__c).Total_5x5__c*polEnd.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            polEnd.Premium_10_10__c = mapOfPolicies.get(polEnd.Policy__c).Total_10x10__c == null ? 0 :(mapOfPolicies.get(polEnd.Policy__c).Total_10x10__c*polEnd.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            polEnd.Premium__c = mapOfPolicies.get(polEnd.Policy__c).Premium__c == null ? 0 :(mapOfPolicies.get(polEnd.Policy__c).Premium__c*polEnd.Term__c).round(System.RoundingMode.HALF_UP)*(-1);
            polEnd.Refund_Amount__c = mapOfPolicies.get(polEnd.Policy__c).Premium__c == null ? 0 :(mapOfPolicies.get(polEnd.Policy__c).Premium__c*polEnd.Term__c).round(System.RoundingMode.HALF_UP);
            if (polEnd.Override_Rating__c == true) {
                //polEnd.Primary__c = mapOfPolicies.get(polEnd.Policy__c).Premium__c;
                //polEnd.Premium__c = polEnd.Premium__c - (polEnd.Premium__c * polEnd.Term__c);
                //polEnd.Premium__c = mapOfPolicies.get(polEnd.Policy__c).Premium__c;
                //polEnd.Premium__c = - ((mapOfPolicies.get(polEnd.Policy__c).Premium__c + polEnd.Override_5_5__c + polEnd.Override_10_10__c)* polEnd.Term__c).round(System.RoundingMode.HALF_UP);
                //polEnd.Refund_Amount__c = ((mapOfPolicies.get(polEnd.Policy__c).Premium__c + polEnd.Override_5_5__c + polEnd.Override_10_10__c)* polEnd.Term__c).round(System.RoundingMode.HALF_UP);
                polEnd.Premium__c = (polEnd.Primary__c + polEnd.Excess__c + (polEnd.Override_5_5__c + polEnd.Override_10_10__c)*-1).round(System.RoundingMode.HALF_UP);
                polEnd.Refund_Amount__c = polEnd.Premium__c * -1 ;
            }/* else {
                //polEnd.Premium__c = mapOfPolicies.get(polEnd.Policy__c).Premium__c;
                //polEnd.Refund_Amount__c = polEnd.Premium__c - (polEnd.Premium__c * polEnd.Term__c);
                polEnd.Premium__c = - (mapOfPolicies.get(polEnd.Policy__c).Premium__c * polEnd.Term__c).round(System.RoundingMode.HALF_UP);
                polEnd.Refund_Amount__c = (mapOfPolicies.get(polEnd.Policy__c).Premium__c * polEnd.Term__c).round(System.RoundingMode.HALF_UP);
            }*/
            System.debug('==='+polEnd.Refund_Amount__c);
            System.debug('-==='+mapOfPolicies.get(polEnd.Policy__c).Premium__c);
            system.debug('policyEndorsement = >'+polEnd);
            lstPolicyEndorsementsToUpdate.add(polEnd);
        }
        update lstPolicyEndorsementsToUpdate;
    }
    
    // Complete Cancel Policy Helper Function.
    public static void completeCancelPolicy(List<Policy_Endorsement__c> lstCompleteCancelPolicy) {
        Set<String> setOfRelatedPolicies = new  Set<String>();
        Map<String,Policy__c> mapOfPolicies = new Map<String,Policy__c>();
        List<Policy__c> lstPoliciesToUpdate = new List<Policy__c>();
        List<AS_Transaction__c> lstASTransaction = new List<AS_Transaction__c>();

        // Get the related policy ids to get the policies to update the cancel effective date.
        for (Policy_Endorsement__c polEnd : lstCompleteCancelPolicy) {
            setOfRelatedPolicies.add(polEnd.Policy__c);
        }
        // Fetch the policies to update.
        for (Policy__c pol : [SELECT Id, Cancel_Date__c, Account__c, Premium__c,Total_5x5__c,Total_10x10__c,Excess_Premium__c,Primary__c FROM Policy__c WHERE Id IN: setOfRelatedPolicies]) {
            mapOfPolicies.put(pol.Id,pol);
        }
        // Update policies.
        for (Policy_Endorsement__c polEnd : lstCompleteCancelPolicy) {
            Policy__c pol = mapOfPolicies.get(polEnd.Policy__c);
            pol.Cancel_Date__c = polEnd.Endorsement_Effective_Date__c;
            //pol.Premium__c = pol.Premium__c - polEnd.Refund_Amount__c;
            
            pol.Premium__c = pol.Premium__c + polEnd.Premium__c;
            pol.Total_5x5__c = (pol.Total_5x5__c == null ? 0 : pol.Total_5x5__c) + (polEnd.Premium_5_5__c == null ? 0 : polEnd.Premium_5_5__c);
            pol.Total_10x10__c = (pol.Total_10x10__c == null ? 0 : pol.Total_10x10__c) + (polEnd.Premium_10_10__c == null ? 0 : polEnd.Premium_10_10__c); 
            pol.Excess_Premium__c = (pol.Excess_Premium__c == null ? 0 : pol.Excess_Premium__c) + (polEnd.Excess__c == null ? 0 : polEnd.Excess__c); 
            pol.Primary__c = (pol.Primary__c == null ? 0 : pol.Primary__c) + (polEnd.Primary__c == null ? 0 : polEnd.Primary__c);
            
            if(pol.Cancel_Date__c <= System.today()){
                pol.Active1__c = false;
            }
            lstPoliciesToUpdate.add(pol);
            if(Label.Process_Accounting_On_Endorsements == 'Y'){
                lstASTransaction = getIL_190_Transactions(polEnd);
            }
        }
        update lstPoliciesToUpdate;
        insert lstASTransaction;

    }
    
    public static List<AS_Transaction__c> getIL_190_Transactions(Policy_Endorsement__c polEnd){
        List<AS_Transaction__c> lstASTransaction = new List<AS_Transaction__c>();
        AS_Transaction__c AS_SingleEntry = new AS_Transaction__c();
        AS_SingleEntry.Amount__c = polEnd.Premium__c;
        AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
        AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
        AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
        AS_SingleEntry.Transaction_Type__c = 'Cancel Policy';
        AS_SingleEntry.Transaction_Sub_Type__c = 'Cancel Policy';
        lstASTransaction.add(AS_SingleEntry);
        
        if(polEnd.Premium_5_5__c !=null && polEnd.Premium_5_5__c != 0){
            AS_SingleEntry = new AS_Transaction__c();
            AS_SingleEntry.Amount__c = polEnd.Premium_5_5__c;
            AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
            AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
            AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
            AS_SingleEntry.Transaction_Type__c = 'Cancel Policy';
            AS_SingleEntry.Transaction_Sub_Type__c = '5x5';
            lstASTransaction.add(AS_SingleEntry);
        }
        if(polEnd.Premium_10_10__c !=null && polEnd.Premium_10_10__c != 0){
            AS_SingleEntry = new AS_Transaction__c();
            AS_SingleEntry.Amount__c = polEnd.Premium_10_10__c;
            AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
            AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
            AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
            AS_SingleEntry.Transaction_Type__c = 'Cancel Policy';
            AS_SingleEntry.Transaction_Sub_Type__c = '10x10';
            lstASTransaction.add(AS_SingleEntry);
        }
        
        if(polEnd.Primary__c !=null && polEnd.Primary__c != 0){
            AS_SingleEntry = new AS_Transaction__c();
            AS_SingleEntry.Amount__c = polEnd.Primary__c;
            AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
            AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
            AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
            AS_SingleEntry.Transaction_Type__c = 'Cancel Policy';
            AS_SingleEntry.Transaction_Sub_Type__c = 'Primary';
            lstASTransaction.add(AS_SingleEntry);
        }
        
        //if(polEnd.Excess__c !=null && polEnd.Excess__c != 0){
        AS_SingleEntry = new AS_Transaction__c();
        AS_SingleEntry.Amount__c = (polEnd.Excess__c != null ? polEnd.Excess__c : 0 ) + (polEnd.Primary__c != null ? polEnd.Primary__c : 0 );
        AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
        AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
        AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
        AS_SingleEntry.Transaction_Type__c = 'Cancel Policy';
        AS_SingleEntry.Transaction_Sub_Type__c = 'PrimaryAndExcess';
        lstASTransaction.add(AS_SingleEntry);
        //}
        return lstASTransaction;
    }
    
    // Pending Reinstate Policy Helper Function.
    public static void pendingReinstatePolicy(List<Policy_Endorsement__c> lstPendingReinstatePolicy) {
        Set<String> setOfPolicyIds = new Set<String>();
        Set<String> setOfPolicyEndorsementIds = new Set<String>();
        Map<String,Policy_Endorsement__c> mapOfPolicyEndorsement = new Map<String,Policy_Endorsement__c>();
        List<Policy_Endorsement__c> lstPolicyEndorsementToUpdate = new List<Policy_Endorsement__c>();
        // Fetch the policy ids from list of endorsements.
        for (Policy_Endorsement__c polEnd : lstPendingReinstatePolicy) {
            setOfPolicyIds.add(polEnd.Policy__c);
            setOfPolicyEndorsementIds.add(polEnd.Id);
        }
        // Fetch the most recent cancel policy endorsement related to the policy.
        for (Policy_Endorsement__c polEnd : [SELECT Id, Policy__c, Event_Status__c, CreatedDate, Refund_Amount__c, Endorsement_Effective_Date__c, RecordType.DeveloperName, Override_5_5__c, Override_10_10__c FROM Policy_Endorsement__c WHERE Policy__c IN: setOfPolicyIds AND RecordType.DeveloperName = 'CP_Cancel_Policy_Transaction' ORDER BY Endorsement_Effective_Date__c ASC]) {
            if (mapOfPolicyEndorsement.containsKey(polEnd.Policy__c)) {
                Policy_Endorsement__c oldEnd = mapOfPolicyEndorsement.get(polEnd.Policy__c);
                if (polEnd.CreatedDate > oldEnd.CreatedDate) {
                    mapOfPolicyEndorsement.put(polEnd.Policy__c,polEnd);
                }
            } else {
                mapOfPolicyEndorsement.put(polEnd.Policy__c,polEnd);
            }
        }
        system.debug(mapOfPolicyEndorsement);
        // Loop through reinstate endorsement to set the refund value as the premium amount.
        for (Policy_Endorsement__c polEnd : [SELECT Id, Override_Rating__c, Premium_5_5__c, Premium_10_10__c, Premium__c, Primary__c, Policy__c, Override_5_5__c, Override_10_10__c FROM Policy_Endorsement__c WHERE id IN: setOfPolicyEndorsementIds]) {
            Policy_Endorsement__c cancelEnd = mapOfPolicyEndorsement.get(polEnd.Policy__c);
            if (cancelEnd != null && cancelEnd.Event_Status__c == 'Complete') {
                if (polEnd.Override_Rating__c == true) {
                    polEnd.Primary__c = mapOfPolicyEndorsement.get(polEnd.Policy__c).Refund_Amount__c;
                    polEnd.Premium__c = (polEnd.Primary__c + polEnd.Override_5_5__c + polEnd.Override_10_10__c).round(System.RoundingMode.HALF_UP);
                } else {
                    polEnd.Premium__c = mapOfPolicyEndorsement.get(polEnd.Policy__c).Refund_Amount__c.round(System.RoundingMode.HALF_UP);
                }
                system.debug('policyEndorsement = >'+polEnd);
                lstPolicyEndorsementToUpdate.add(polEnd);
            }
        }
        update lstPolicyEndorsementToUpdate;
    }
    
    // Complete Reinstate Policy Helper Function.
    public static void completeReinstatePolicy(List<Policy_Endorsement__c> lstCompleteReinstatePolicy) {
        Set<String> setOfRelatedPolicies = new  Set<String>();
        Map<String,Policy__c> mapOfPolicies = new Map<String,Policy__c>();
        Map<String,Policy_Endorsement__c> mapPolicyEndorsements = new Map<String,Policy_Endorsement__c>();
        List<Policy__c> lstPoliciesToUpdate = new List<Policy__c>();
        List<AS_Transaction__c> lstASTransaction = new List<AS_Transaction__c>();
        // Get the related policy ids to get the policies to update the cancel effective date.
        for (Policy_Endorsement__c polEnd : lstCompleteReinstatePolicy) {
            setOfRelatedPolicies.add(polEnd.Policy__c);
            mapPolicyEndorsements.put(polEnd.Policy__c,polEnd);
        }
        
        // Fetch the policies to update.
        for (Policy__c pol : [SELECT Id, Cancel_Date__c, Active__c, Account__c, Premium__c FROM Policy__c WHERE Id IN: setOfRelatedPolicies]) {
            pol.Cancel_Date__c = null;
            system.debug('Premium Amount to Take: '+mapPolicyEndorsements.get(pol.Id).Premium__c+'---pol premimu----'+pol.Premium__c);
            pol.Premium__c = pol.Premium__c + mapPolicyEndorsements.get(pol.Id).Premium__c;
            //pol.Active__c = true;
            lstPoliciesToUpdate.add(pol);
            mapOfPolicies.put(pol.Id,pol);
        }
        update lstPoliciesToUpdate;
        
        for (Policy_Endorsement__c polEnd : lstCompleteReinstatePolicy) {
            if(Label.Process_Accounting_On_Endorsements == 'Y'){
                AS_Transaction__c asTransaction = new AS_Transaction__c();
                asTransaction.Amount__c = (polEnd.Premium__c != null ? polEnd.Premium__c : 0);
                asTransaction.Firm_Id__c = mapOfPolicies.get(polEnd.Policy__c).Account__c;
                asTransaction.Policy_Endorsement_Id__c = polEnd.Id;
                asTransaction.Policy_Id__c = polEnd.Policy__c;
                asTransaction.Transaction_Type__c = 'Reinstate Policy';
                asTransaction.Transaction_Sub_Type__c = 'Reinstate Policy';
                lstASTransaction.add(asTransaction);
            }
        }
        insert lstASTransaction;
    }
    
    // Pending ERE Helper Function.
    public static void pendingERE(List<Policy_Endorsement__c> lstPendingERE) {
        // Get the set of policy endorsements id's to SOQL record and update the calculations.
        Set<Id> setPolicyEndorsementIds = (new Map<Id,SObject>(lstPendingERE)).keySet();
        Set<Id> setPolicyIds = new Set<Id>();
        Map<String,Policy__c> mapOfPolicies = new Map<String,Policy__c>();
        List<Policy_Endorsement__c> lstPolicyEndorsementToUpdate = new List<Policy_Endorsement__c>();
        //Set<Id> policiesWithIL106End = new Set<Id>();
        //Map<Id,Id> policyLawyersMap = new Map<Id,Id>();
        //Map<Id,Integer> countPolicyLawyerMap = new Map<Id,Integer>();
        // Fill the setPolicyIds to fetch related policies.
        for (Policy_Endorsement__c polEnd : lstPendingERE) {
            setPolicyIds.add(polEnd.Policy__c);
        }
        // Get the related policy to set the premium value in the endorsement.
        for (Policy__c pol : [SELECT Id, Name, Original_Premium__c, Expiration_Date__c, Number_Of_Lawyers__c,Total_5x5__c,Total_10x10__c,Policy_Suffix_Formula__c,Original_5x5__c,Original_10x10__c,Original_Primary__c,Original_Excess__c,Policy_Series_Effective_Date__c,Effective_Date__c FROM Policy__c WHERE Id IN: setPolicyIds]) {
            mapOfPolicies.put(pol.Id,pol);
        }
        /*for(Policy_Endorsement__c polEnd : [select id,Policy__c from Policy_Endorsement__c where Policy__c in: setPolicyIds and Endorsement_Number__c = 'IL 106']){
            policiesWithIL106End.add(polEnd.Policy__c);
        }*/
        /*for(Policy_Lawyer__c lawyer : [select id,Policy__c,Lawyer_Contact_Id__c from Policy_Lawyer__c where Policy__c in: policiesWithIL106End]){
            policyLawyersMap.put(lawyer.Policy__c,lawyer.Lawyer_Contact_Id__c);
        }
        String str = '';
        Date dateToCompare = null;
        for(Policy_Lawyer__c lawyer : [select id,Lawyer_Contact_Id__c,Policy__r.Effective_Date__c,Policy__r.Expiration_Date__c from Policy_Lawyer__c where Lawyer_Contact_Id__c in: policyLawyersMap.values() order by Lawyer_Contact_Id__c DESC,Policy__r.Effective_Date__c ASC]){
            if(str == lawyer.Lawyer_Contact_Id__c){
                if(dateToCompare!=null && dateToCompare.addDays(-1) <= lawyer.Policy__r.Expiration_Date__c){
                    dateToCompare = lawyer.Policy__r.Effective_Date__c;
                    countPolicyLawyerMap.put(lawyer.Lawyer_Contact_Id__c,countPolicyLawyerMap.get(lawyer.Lawyer_Contact_Id__c)+1);
                }
            }else{
                countPolicyLawyerMap.put(lawyer.Lawyer_Contact_Id__c,1);
                dateToCompare = lawyer.Policy__r.Effective_Date__c;
                str = lawyer.Lawyer_Contact_Id__c;
            }
        } */
        // Loop through the policy endorsements and calculate the premium.
        for (Policy_Endorsement__c polEnd : [SELECT Coverage_Term__c, ERE_Expiration_Date__c, Id, Override_Rating__c, Policy__c, Premium_5_5__c, Premium_10_10__c, Premium__c, Primary__c,Endorsement_Effective_Date__c FROM Policy_Endorsement__c WHERE Id IN: setPolicyEndorsementIds]) {
            Policy__c relatedPolicy = mapOfPolicies.get(polEnd.Policy__c);
            polEnd.Premium__c = polEnd.Premium_5_5__c = polEnd.Premium_10_10__c = polEnd.Primary__c = polEnd.Excess__c = 0;
            if(relatedPolicy.Total_5x5__c == null){
                relatedPolicy.Total_5x5__c = 0;
            }
            if(relatedPolicy.Total_10x10__c == null){
                relatedPolicy.Total_10x10__c = 0;
            }
            Long policyYears = 0;
            if(relatedPolicy.Policy_Series_Effective_Date__c != null){
                policyYears = (Decimal.valueOf(relatedPolicy.Policy_Series_Effective_Date__c.monthsBetween(relatedPolicy.Effective_Date__c) / 12)).round(System.RoundingMode.DOWN);
                if(relatedPolicy.Expiration_Date__c == polEnd.Endorsement_Effective_Date__c){
                    policyYears += 1;
                }
            }
            if(relatedPolicy.Original_Premium__c != null){
                relatedPolicy.Original_Premium__c = (relatedPolicy.Original_Premium__c).round(System.RoundingMode.HALF_UP);
            }
            Decimal percentageFormula = 1;
            // Check the Coverage_Term__c field and add years to expiration date of policy and get the new ere expiration date.
            if (polEnd.Coverage_Term__c == '1 Year') {
                polEnd.ERE_Expiration_Date__c = relatedPolicy.Expiration_Date__c.addYears(1);
                
                // Check if Override Rating is set to true.
                if (polEnd.Override_Rating__c == true) {
                    polEnd.Premium__c = polEnd.Primary__c + polEnd.Premium_5_5__c + polEnd.Premium_10_10__c;
                } else if (polEnd.Override_Rating__c == false) {
                    if(policyYears <= 4){  
                        percentageFormula = 1;
                    }else if(policyYears == 5){
                        percentageFormula = 0.95;
                    }else if(policyYears == 6){
                        percentageFormula = 0.9;
                    }else if(policyYears == 7){
                        percentageFormula = 0.85;
                    }else if(policyYears == 8){
                        percentageFormula = 0.80;
                    }else if(policyYears == 9){ 
                        percentageFormula = 0.70;
                    }else{
                        percentageFormula = 0.60;
                    }
                    polEnd.Premium__c = (relatedPolicy.Original_Premium__c !=null ? relatedPolicy.Original_Premium__c : 0) * percentageFormula;
                    polEnd.Premium_5_5__c = (relatedPolicy.Original_5x5__c !=null ? relatedPolicy.Original_5x5__c : 0)  * percentageFormula;
                    polEnd.Premium_10_10__c = (relatedPolicy.Original_10x10__c !=null ? relatedPolicy.Original_10x10__c : 0) * percentageFormula;
                    polEnd.Primary__c = (relatedPolicy.Original_Primary__c !=null ? relatedPolicy.Original_Primary__c : 0) * percentageFormula;
                    polEnd.Excess__c = (relatedPolicy.Original_Excess__c !=null ? relatedPolicy.Original_Excess__c : 0) * percentageFormula;
                }
            } else if (polEnd.Coverage_Term__c == '3 Years') {
                polEnd.ERE_Expiration_Date__c = relatedPolicy.Expiration_Date__c.addYears(3);
                // Check if Override Rating is set to true.
                if (polEnd.Override_Rating__c == true) {
                    polEnd.Premium__c = polEnd.Primary__c + polEnd.Premium_5_5__c + polEnd.Premium_10_10__c;
                } else if (polEnd.Override_Rating__c == false) {
                    if(policyYears <= 4){  
                        percentageFormula = 1.75;
                    }else if(policyYears == 5){
                        percentageFormula = 1.60;
                    }else if(policyYears == 6){
                        percentageFormula = 1.45;
                    }else if(policyYears == 7){
                        percentageFormula = 1.25;
                    }else if(policyYears == 8){
                        percentageFormula = 1.10;
                    }else if(policyYears == 9){ 
                        percentageFormula = 0.9;
                    }else{
                        percentageFormula = 0.7;
                    }
                    polEnd.Premium__c = (relatedPolicy.Original_Premium__c !=null ? relatedPolicy.Original_Premium__c : 0) * percentageFormula;
                    polEnd.Premium_5_5__c = (relatedPolicy.Original_5x5__c !=null ? relatedPolicy.Original_5x5__c : 0)  * percentageFormula;
                    polEnd.Premium_10_10__c = (relatedPolicy.Original_10x10__c !=null ? relatedPolicy.Original_10x10__c : 0) * percentageFormula;
                    polEnd.Primary__c = (relatedPolicy.Original_Primary__c !=null ? relatedPolicy.Original_Primary__c : 0) * percentageFormula;
                    polEnd.Excess__c = (relatedPolicy.Original_Excess__c !=null ? relatedPolicy.Original_Excess__c : 0) * percentageFormula;
                }
            } else if (polEnd.Coverage_Term__c == '6 Years') {
                polEnd.ERE_Expiration_Date__c = relatedPolicy.Expiration_Date__c.addYears(6);
                // Check if Override Rating is set to true.
                if (polEnd.Override_Rating__c == true) {
                    polEnd.Premium__c = polEnd.Primary__c + polEnd.Premium_5_5__c + polEnd.Premium_10_10__c;
                } else if (polEnd.Override_Rating__c == false) {
                    if(policyYears <= 4){  
                        percentageFormula = 2;
                    }else if(policyYears == 5){
                        percentageFormula = 1.85;
                    }else if(policyYears == 6){
                        percentageFormula = 1.65;
                    }else if(policyYears == 7){
                        percentageFormula = 1.45;
                    }else if(policyYears == 8){
                        percentageFormula = 1.25;
                    }else if(policyYears == 9){ 
                        percentageFormula = 1.05;
                    }else{
                        percentageFormula = 0.85;
                    }
                    polEnd.Premium__c = (relatedPolicy.Original_Premium__c !=null ? relatedPolicy.Original_Premium__c : 0) * percentageFormula;
                    polEnd.Premium_5_5__c = (relatedPolicy.Original_5x5__c !=null ? relatedPolicy.Original_5x5__c : 0)  * percentageFormula;
                    polEnd.Premium_10_10__c = (relatedPolicy.Original_10x10__c !=null ? relatedPolicy.Original_10x10__c : 0) * percentageFormula;
                    polEnd.Primary__c = (relatedPolicy.Original_Primary__c !=null ? relatedPolicy.Original_Primary__c : 0) * percentageFormula;
                    polEnd.Excess__c = (relatedPolicy.Original_Excess__c !=null ? relatedPolicy.Original_Excess__c : 0) * percentageFormula;
                }
            } else if (polEnd.Coverage_Term__c == 'Unlimited') {
                //Decimal percentageFormula = 2.5;
                
                //if(policiesWithIL106End.contains(polEnd.Policy__c)){
                    if(policyYears <= 4){
                        percentageFormula = 2.5;
                    }else if(policyYears == 5){
                        percentageFormula = 2.25;
                    }else if(policyYears == 6){
                        percentageFormula = 2;
                    }else if(policyYears == 7){
                        percentageFormula = 1.75;
                    }else if(policyYears == 8){
                        percentageFormula = 1.5;
                    }else if(policyYears == 9){
                        percentageFormula = 1.25;
                    }else{
                        percentageFormula = 1;
                    }
                /*}else{
                    percentageFormula = polEnd.IL_107_Multiplier__c!=null ? polEnd.IL_107_Multiplier__c/100 : percentageFormula;
                }*/
                
                polEnd.ERE_Expiration_Date__c = relatedPolicy.Expiration_Date__c.addYears(100);
                // Check if Override Rating is set to true.
                if (polEnd.Override_Rating__c == true) {
                    polEnd.Premium__c = polEnd.Primary__c + polEnd.Premium_5_5__c + polEnd.Premium_10_10__c;
                } else if (polEnd.Override_Rating__c == false) {
                    polEnd.Premium__c = ((relatedPolicy.Original_Premium__c !=null ? relatedPolicy.Original_Premium__c : 0) * percentageFormula).round(System.RoundingMode.HALF_UP);
                    polEnd.Premium_5_5__c = ((relatedPolicy.Original_5x5__c !=null ? relatedPolicy.Original_5x5__c : 0)  * percentageFormula).round(System.RoundingMode.HALF_UP);
                    polEnd.Premium_10_10__c = ((relatedPolicy.Original_10x10__c !=null ? relatedPolicy.Original_10x10__c : 0) * percentageFormula).round(System.RoundingMode.HALF_UP);
                    polEnd.Primary__c = ((relatedPolicy.Original_Primary__c !=null ? relatedPolicy.Original_Primary__c : 0) * percentageFormula).round(System.RoundingMode.HALF_UP);
                    polEnd.Excess__c = ((relatedPolicy.Original_Excess__c !=null ? relatedPolicy.Original_Excess__c : 0) * percentageFormula).round(System.RoundingMode.HALF_UP);
                }
                
                /* if(policiesWithIL106End.contains(polEnd.Policy__c) && policyLawyersMap.containsKey(polEnd.Policy__c) && countPolicyLawyerMap.containsKey(policyLawyersMap.get(polEnd.Policy__c))){
                    Integer totalCount = countPolicyLawyerMap.get(policyLawyersMap.get(polEnd.Policy__c));
                    if(totalCount <= 4){
                        percentageFormula = 2.5;
                    }else if(totalCount == 5){
                        percentageFormula = 2.25;
                    }else if(totalCount == 6){
                        percentageFormula = 2;
                    }else if(totalCount == 7){
                        percentageFormula = 1.75;
                    }else if(totalCount == 8){
                        percentageFormula = 1.5;
                    }else if(totalCount == 9){
                        percentageFormula = 1.25;
                    }else if(totalCount >= 10){
                        percentageFormula = 1;
                    }
                } */
                  
            }
            
            polEnd.Premium__c = (polEnd.Premium__c).round(System.RoundingMode.HALF_UP);
            polEnd.Premium_5_5__c = (polEnd.Premium_5_5__c).round(System.RoundingMode.HALF_UP);
            polEnd.Premium_10_10__c = (polEnd.Premium_10_10__c).round(System.RoundingMode.HALF_UP);
            polEnd.Primary__c = (polEnd.Primary__c).round(System.RoundingMode.HALF_UP);
            polEnd.Excess__c = (polEnd.Excess__c).round(System.RoundingMode.HALF_UP);
            system.debug('policyEndorsement = >'+polEnd);
            lstPolicyEndorsementToUpdate.add(polEnd);
        }
        update lstPolicyEndorsementToUpdate;
    }
    public static void pendingEREUnlimited(List<Policy_Endorsement__c> lstPendingERE) {
        // Get the set of policy endorsements id's to SOQL record and update the calculations.
        Set<Id> setPolicyEndorsementIds = (new Map<Id,SObject>(lstPendingERE)).keySet();
        Set<Id> setPolicyIds = new Set<Id>();
        Map<String,Policy__c> mapOfPolicies = new Map<String,Policy__c>();
        List<Policy_Endorsement__c> lstPolicyEndorsementToUpdate = new List<Policy_Endorsement__c>();
        // Fill the setPolicyIds to fetch related policies.
        for (Policy_Endorsement__c polEnd : lstPendingERE) {
            setPolicyIds.add(polEnd.Policy__c);
        }
        // Get the related policy to set the premium value in the endorsement.
        for (Policy__c pol : [SELECT Id, Name, Premium_Amount__c, Expiration_Date__c, Number_Of_Lawyers__c FROM Policy__c WHERE Id IN: setPolicyIds]) {
            mapOfPolicies.put(pol.Id,pol);
        }
        // Loop through the policy endorsements and calculate the premium.
        for (Policy_Endorsement__c polEnd : [SELECT Coverage_Term__c, ERE_Expiration_Date__c, Id, Override_Rating__c, Policy__c, Premium_5_5__c, Premium_10_10__c, Premium__c, Primary__c FROM Policy_Endorsement__c WHERE Id IN: setPolicyEndorsementIds]) {
            Policy__c relatedPolicy = mapOfPolicies.get(polEnd.Policy__c);
            
            // Check the Coverage_Term__c field and add years to expiration date of policy and get the new ere expiration date.
            if (polEnd.Coverage_Term__c == '1-4 Years') {
                polEnd.ERE_Expiration_Date__c = relatedPolicy.Expiration_Date__c.addYears(1);
                polEnd.Premium__c = relatedPolicy.Premium_Amount__c * 2.5;
            } else if (polEnd.Coverage_Term__c == '5 Years') {
                polEnd.ERE_Expiration_Date__c = relatedPolicy.Expiration_Date__c.addYears(3);
                polEnd.Premium__c = relatedPolicy.Premium_Amount__c * 2.25;
            } else if (polEnd.Coverage_Term__c == '6 Years') {
                polEnd.ERE_Expiration_Date__c = relatedPolicy.Expiration_Date__c.addYears(6);
                polEnd.Premium__c = relatedPolicy.Premium_Amount__c * 2;
            } else if (polEnd.Coverage_Term__c == '7 Years') {
                polEnd.ERE_Expiration_Date__c = relatedPolicy.Expiration_Date__c.addYears(6);
                polEnd.Premium__c = relatedPolicy.Premium_Amount__c * 1.75;
            } else if (polEnd.Coverage_Term__c == '8 Years') {
                polEnd.ERE_Expiration_Date__c = relatedPolicy.Expiration_Date__c.addYears(6);
                polEnd.Premium__c = relatedPolicy.Premium_Amount__c * 1.5;
            } else if (polEnd.Coverage_Term__c == '9 Years') {
                polEnd.ERE_Expiration_Date__c = relatedPolicy.Expiration_Date__c.addYears(6);
                polEnd.Premium__c = relatedPolicy.Premium_Amount__c * 1.25;
            } else if (polEnd.Coverage_Term__c == '10 or more years') {
                polEnd.ERE_Expiration_Date__c = relatedPolicy.Expiration_Date__c.addYears(6);
                polEnd.Premium__c = relatedPolicy.Premium_Amount__c * 1;
            }
            system.debug('policyEndorsement = >'+polEnd);
            lstPolicyEndorsementToUpdate.add(polEnd);
        }
        update lstPolicyEndorsementToUpdate;
    }
    
    // Complete ERE Helper Function.
    public static void completeERE(List<Policy_Endorsement__c> lstCompleteERE) {
        Set<String> setPolicyIds = new Set<String>();
        List<Policy__c> lstPoliciesToUpdate = new List<Policy__c>();
        List<AS_Transaction__c> lstASTransaction = new List<AS_Transaction__c>();
        List<Policy_Premium_History__c> premiumHistoryList = new List<Policy_Premium_History__c>();
        // Loop through endoresement to get the policy ids to update.
        for (Policy_Endorsement__c polEnd : lstCompleteERE) {
            setPolicyIds.add(polEnd.Policy__c);
        }
        // Fetch the policies to update and put them in a map.
        for (Policy__c pol : [SELECT Id, Name, Premium__c, ERE_Date__c, Account__c FROM Policy__c WHERE Id IN: setPolicyIds]) {
            for (Policy_Endorsement__c polEnd : lstCompleteERE) {
                if (pol.Id == polEnd.Policy__c) {
                    pol.ERE_Date__c = polEnd.ERE_Expiration_Date__c;
                    pol.Premium__c = pol.Premium__c + polEnd.Premium__c;
                    
                    lstPoliciesToUpdate.add(pol);
                    if(Label.Process_Accounting_On_Endorsements == 'Y'){
                        lstASTransaction = getERE_Transactions(polEnd);
                    }
                    
                    
                    Policy_Premium_History__c premiumHistory = new Policy_Premium_History__c();
                    premiumHistory.Policy__c = polEnd.Policy__c;
                    premiumHistory.Action__c = 'IL107';
                    premiumHistory.Premium__c = polEnd.Premium__c;
                    premiumHistory.X10x10_value__c =  polEnd.Premium_10_10__c;
                    premiumHistory.X5x5_value__c =  polEnd.Premium_5_5__c;
                    
                    premiumHistoryList.add(premiumHistory);
                    
                }
            }
        }
        insert lstASTransaction;
        update lstPoliciesToUpdate;
        insert premiumHistoryList;
    }
    public static List<AS_Transaction__c> getERE_Transactions(Policy_Endorsement__c polEnd){
        List<AS_Transaction__c> lstASTransaction = new List<AS_Transaction__c>();
        AS_Transaction__c AS_SingleEntry = new AS_Transaction__c();
        AS_SingleEntry.Amount__c = polEnd.Premium__c;
        AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
        AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
        AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
        AS_SingleEntry.Transaction_Type__c = 'ERE';
        AS_SingleEntry.Transaction_Sub_Type__c = 'ERE';
        lstASTransaction.add(AS_SingleEntry);
        
        if(polEnd.Endorsement_Number__c == 'IL 107'){
            if(polEnd.Premium_5_5__c !=null && polEnd.Premium_5_5__c != 0){
                AS_SingleEntry = new AS_Transaction__c();
                AS_SingleEntry.Amount__c = polEnd.Premium_5_5__c;
                AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
                AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
                AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
                AS_SingleEntry.Transaction_Type__c = 'ERE';
                AS_SingleEntry.Transaction_Sub_Type__c = '5x5';
                lstASTransaction.add(AS_SingleEntry);
            }
            if(polEnd.Premium_10_10__c !=null && polEnd.Premium_10_10__c != 0){
                AS_SingleEntry = new AS_Transaction__c();
                AS_SingleEntry.Amount__c = polEnd.Premium_10_10__c;
                AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
                AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
                AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
                AS_SingleEntry.Transaction_Type__c = 'ERE';
                AS_SingleEntry.Transaction_Sub_Type__c = '10x10';
                lstASTransaction.add(AS_SingleEntry);
            }
            
            if(polEnd.Primary__c !=null && polEnd.Primary__c != 0){
                AS_SingleEntry = new AS_Transaction__c();
                AS_SingleEntry.Amount__c = polEnd.Primary__c;
                AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
                AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
                AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
                AS_SingleEntry.Transaction_Type__c = 'ERE';
                AS_SingleEntry.Transaction_Sub_Type__c = 'Primary';
                lstASTransaction.add(AS_SingleEntry);
            }
            
            //if(polEnd.Excess__c !=null && polEnd.Excess__c != 0){
            AS_SingleEntry = new AS_Transaction__c();
            AS_SingleEntry.Amount__c = (polEnd.Excess__c != null ? polEnd.Excess__c : 0 ) + polEnd.Primary__c;
            AS_SingleEntry.Firm_Id__c = polEnd.Account__c;
            AS_SingleEntry.Policy_Endorsement_Id__c = polEnd.Id;
            AS_SingleEntry.Policy_Id__c = polEnd.Policy__c;
            AS_SingleEntry.Transaction_Type__c = 'ERE';
            AS_SingleEntry.Transaction_Sub_Type__c = 'PrimaryAndExcess';
            lstASTransaction.add(AS_SingleEntry);
            //}
        }
        return lstASTransaction;
    }
    // Complete all Descriptive Endorsements.
    public static void completeDescriptiveEndorsements(List<Policy_Endorsement__c> lstCompleteDescriptiveEndorsements) {
        Set<String> setPolicyEndorsementIds = new Set<String>();
        List<Policy_Endorsement__c> lstDescriptiveEndorsementsToUpdate = new List<Policy_Endorsement__c>();
        
        // Get the Policy Endorsement Ids to SOQL records.
        for (Policy_Endorsement__c polEnd : lstCompleteDescriptiveEndorsements) {
            setPolicyEndorsementIds.add(polEnd.Id);
        }
        // Loop through endorsements and mark them complete.
        for (Policy_Endorsement__c polEnd : [SELECT Id, Event_status__c FROM Policy_Endorsement__c WHERE Id IN: setPolicyEndorsementIds]) {
            polEnd.Event_Status__c = 'Complete';
            lstDescriptiveEndorsementsToUpdate.add(polEnd);
        }
        update lstDescriptiveEndorsementsToUpdate;
    }
    
    public static void rollBackEndorsementOperation(Map<Id,SObject> oldItems){
        System.debug('4---PolicyEndorsementGateway');
        
        System.debug('oldItems---'+oldItems);
        
        List<Policy_Endorsement__c> lstPolicyEndorsements = (List<Policy_Endorsement__c>) oldItems.values();
        List<Policy_Endorsement__c> lstCompleteDeleteEndorsement = new List<Policy_Endorsement__c>();
        
        //Add Attoney Delete
        List<Policy_Endorsement__c> addAttorneyDeleteEndorsement = new List<Policy_Endorsement__c>();
        
         List<Policy_Endorsement__c> lstEREDeleteEndorsement = new List<Policy_Endorsement__c>();
        
        List<Policy_Endorsement__c> lstCancelDeleteEndorsement = new List<Policy_Endorsement__c>();
        
        Map<String,Endorsement__c> mapMasterEndorsement = new Map<String,Endorsement__c>();
        Set<String> setRecordTypeIds= new Set<String>();
        for (Policy_Endorsement__c polEnd : lstPolicyEndorsements) {
            setRecordTypeIds.add(polEnd.RecordTypeId);
        }
        System.debug('setRecordTypeIds---'+setRecordTypeIds);
        
        List<Policy_Endorsement__c> addAttorneyEndorseDel = new List<Policy_Endorsement__c>();
        
        for (Endorsement__c masterEnd : [SELECT Id, Name, Type__c, Endorsement_Sub_Type__c, Endorsement_Record_Type_ID__c FROM Endorsement__c WHERE Endorsement_Record_Type_ID__c IN: setRecordTypeIds]) {
            mapMasterEndorsement.put(masterEnd.Endorsement_Record_Type_ID__c, masterEnd);
        }
        
        System.debug('mapMasterEndorsement---'+mapMasterEndorsement);
        
        for (Policy_Endorsement__c polEnd : lstPolicyEndorsements) {
            Endorsement__c currentEnd = mapMasterEndorsement.get(polEnd.RecordTypeId);
            if (currentEnd.Type__c == 'Functional') {
                if (currentEnd.Endorsement_Sub_Type__c == 'IL 153') {
                    if (polEnd.Event_Status__c == 'Complete') {
                        lstCompleteDeleteEndorsement.add(polEnd);
                    }
                }
                if (currentEnd.Endorsement_Sub_Type__c == 'IL 152') {
                    if (polEnd.Event_Status__c == 'Complete') {
                        addAttorneyDeleteEndorsement.add(polEnd);
                    }
                }
                if (currentEnd.Endorsement_Sub_Type__c == 'IL 107') {
                    if (polEnd.Event_Status__c == 'Complete') {
                        lstEREDeleteEndorsement.add(polEnd);
                    }
                }
                if (currentEnd.Endorsement_Sub_Type__c == 'IL 190') {
                    if (polEnd.Event_Status__c == 'Complete') {
                        lstCancelDeleteEndorsement.add(polEnd);
                    }
                }
            }
        }
        System.debug('lstCompleteDeleteEndorsement---'+lstCompleteDeleteEndorsement);
        
        if(lstCompleteDeleteEndorsement.size()>0){
            performDeleteEndorsementDelete(lstCompleteDeleteEndorsement);    
        }
        
        if(addAttorneyDeleteEndorsement.size()>0){
            performAddEndorsementDelete(addAttorneyDeleteEndorsement);    
        }
        if(lstEREDeleteEndorsement.size()>0){
            performEREEndorsementDelete(lstEREDeleteEndorsement);
        }
        if(lstCancelDeleteEndorsement.size()>0){
            performCancelEndorsementDelete(lstEREDeleteEndorsement);
        }
    }
    
    public static void performDeleteEndorsementDelete(List<Policy_Endorsement__c> lstCompleteDeleteEndorsement){
    
        Set<String> setPolicyIds = new Set<String>();
        Set<String> setPolicyLawyerIds = new Set<String>();
        Set<Id> endorsementDeleteErrorIds = new Set<Id>();
        List<Policy_Lawyer__c> lstLawyersToUpdate = new List<Policy_Lawyer__c>();
        List<Policy__c> lstPoliciesToUpdate = new List<Policy__c>();
        List<Attachment> attachmentsToDelete = new List<Attachment>();
        List<AS_Transaction__c> asTransactionsToDelete = [select id,name,Policy_Endorsement_Id__c from AS_Transaction__c where Policy_Endorsement_Id__c = : lstCompleteDeleteEndorsement] ;
        List<AcctSeed__Billing__c> billingsToDelete = [SELECT id,name,Policy_Endorsement__c,Policy__c,AcctSeed__Status__c,AcctSeed__Accounting_Period__c,
                                                        AcctSeed__Customer__c,AcctSeed__Billing_Format__c,AcctSeed__Date__c,AcctSeed__Due_Date2__c 
                                                        FROM AcctSeed__Billing__c where Policy_Endorsement__c = : lstCompleteDeleteEndorsement];
        
        List<AcctSeed__Scheduled_Revenue_Expense__c> amortizedRevenueToDelete = [select id,name,AcctSeed__Billing__r.Policy_Endorsement__c from AcctSeed__Scheduled_Revenue_Expense__c where AcctSeed__Billing__r.Policy_Endorsement__c = : lstCompleteDeleteEndorsement];
        
        List<AcctSeed__Journal_Entry__c> journalToDelete = [select id,Policy_Endorsement__c from AcctSeed__Journal_Entry__c where Policy_Endorsement__c = : lstCompleteDeleteEndorsement ];
        
        Database.DeleteResult[] drList = Database.delete(asTransactionsToDelete,false);
        for(Integer i =0 ;i <drList.size();i++){
            if(!drList[i].isSuccess()){
                endorsementDeleteErrorIds.add(asTransactionsToDelete.get(i).Policy_Endorsement_Id__c);
            }
        }
        
        AcctSeed.PostResult[] unpostResults = AcctSeed.JournalEntryPostService.unpostJournalEntries(journalToDelete);
        for(Integer i =0 ;i<unpostResults.size();i++){
            if (!unpostResults[i].isSuccess) {
                endorsementDeleteErrorIds.add(journalToDelete.get(i).Policy_Endorsement__c);
            }
        }
        
        drList = Database.delete(journalToDelete,false);
        for(Integer i =0 ;i <drList.size();i++){
            if(!drList[i].isSuccess()){
                endorsementDeleteErrorIds.add(journalToDelete.get(i).Policy_Endorsement__c);
            }
        }
        
        unpostResults = AcctSeed.ScheduledRevenueExpensePostService.unpostScheduledRevenueExpenses(amortizedRevenueToDelete);
        for(Integer i =0 ;i<unpostResults.size();i++){
            if (!unpostResults[i].isSuccess) {
                endorsementDeleteErrorIds.add(amortizedRevenueToDelete.get(i).AcctSeed__Billing__r.Policy_Endorsement__c);
            }
        }
        
        drList = Database.delete(amortizedRevenueToDelete,false);
        for(Integer i =0 ;i <drList.size();i++){
            if(!drList[i].isSuccess()){
                endorsementDeleteErrorIds.add(amortizedRevenueToDelete.get(i).AcctSeed__Billing__r.Policy_Endorsement__c);
            }
        }
		
        
        unpostResults = AcctSeed.BillingPostService.unpostBillings(billingsToDelete);
        for(Integer i =0 ;i<unpostResults.size();i++){
            if (!unpostResults[i].isSuccess) {
                endorsementDeleteErrorIds.add(billingsToDelete.get(i).Policy_Endorsement__c);
            }
        }
        
        drList = Database.delete(billingsToDelete,false);
        for(Integer i =0 ;i <drList.size();i++){
            if(!drList[i].isSuccess()){
                endorsementDeleteErrorIds.add(billingsToDelete.get(i).Policy_Endorsement__c);
            }
        }
                
        for (Policy_Endorsement__c polEnd : lstCompleteDeleteEndorsement) {
            setPolicyIds.add(polEnd.Policy__c);
            setPolicyLawyerIds.add(polEnd.Policy_Lawyer__c);
        }
        for (Policy_Lawyer__c polLaw : [SELECT Id, Account__c, Lawyer__c, Policy__c, Primary__c, Step__c, X5_5__c, X10_10__c, Premium__c, Prior_Act_Date__c, Active__c,
                                        Deleted_Lawyer__c, Deleted_Date__c, Old_Primary_Value__c,Old_Step_Value__c,Old_5x5_Value__c,Old_10x10_Value__c,Old_Premium__c,Old_Prior_Act_Date__c,Old_Excess__c,Excess__c
                                        FROM Policy_Lawyer__c WHERE Id IN: setPolicyLawyerIds AND Policy__c IN: setPolicyIds AND Deleted_Lawyer__c = true]) {
            for (Policy_Endorsement__c polEnd : lstCompleteDeleteEndorsement) {
                if (polLaw.Id == polEnd.Policy_Lawyer__c && polLaw.Policy__c == polEnd.Policy__c) {
                    polLaw.Primary__c = polLaw.Old_Primary_Value__c;
                    polLaw.Step__c = polLaw.Old_Step_Value__c;
                    polLaw.X5_5__c = polLaw.Old_5x5_Value__c;
                    polLaw.X10_10__c = polLaw.Old_10x10_Value__c;
                    polLaw.Premium__c = polLaw.Old_Premium__c;
                    polLaw.Excess__c = polLaw.Old_Excess__c;
                    polLaw.Prior_Act_Date__c = polLaw.Old_Prior_Act_Date__c;
                    polLaw.Active__c = true;
                    polLaw.Deleted_Lawyer__c = false;
                    polLaw.Deleted_Date__c = null;
                    lstLawyersToUpdate.add(polLaw);
                    
                }
            }
        }
        Database.SaveResult[] srList =  Database.update(lstLawyersToUpdate,false);
        for(Integer i =0 ;i <srList.size();i++){
            if(!srList[i].isSuccess()){
                endorsementDeleteErrorIds.add(lstLawyersToUpdate.get(i).Id);                    
            }
        }
        
        /*List<AS_Transaction__c> asTransactionsToInsert = new List<AS_Transaction__c>();
        for(AS_Transaction__c as_trans: [SELECT Id,Name,Amount__c,Policy_Id__c,Firm_Id__c FROM AS_Transaction__c WHERE Policy_Endorsement_Id__c = : lstCompleteDeleteEndorsement]){
            
            AS_Transaction__c as_transCopy = as_trans.clone(false, true, false, false);
            as_transCopy.Amount__c = - as_trans.Amount__c;
            as_transCopy.Transaction_Type__c = 'Add Lawyer';
            as_transCopy.Transaction_Sub_Type__c = 'Add Lawyer';
            asTransactionsToInsert.add(as_transCopy);
            
        }
        
        if(!asTransactionsToInsert.isEmpty()){
            srList =  Database.insert(asTransactionsToInsert,false);
            for(Integer i =0 ;i <srList.size();i++){
                if(!srList[i].isSuccess()){
                    endorsementDeleteErrorIds.add(lstPoliciesToUpdate.get(i).Policy_Id__c);
                }
            }
        }*/
        
        // SOQL Policies to update premium.
        for (Policy__c pol : [SELECT Id, Name, Premium__c,Total_5x5__c,Total_10x10__c,Excess_Premium__c,Primary__c FROM Policy__c WHERE Id IN: setPolicyIds]) {
            for (Policy_Endorsement__c polEnd : lstCompleteDeleteEndorsement) {
                if (pol.Id == polEnd.Policy__c) {
                    pol.Premium__c = pol.Premium__c - (polEnd.Premium__c);
                    
                    pol.Total_5x5__c = (pol.Total_5x5__c == null ? 0 : pol.Total_5x5__c) - (polEnd.Premium_5_5__c == null ? 0 : polEnd.Premium_5_5__c);
                    pol.Total_10x10__c = (pol.Total_10x10__c == null ? 0 : pol.Total_10x10__c) - (polEnd.Premium_10_10__c == null ? 0 : polEnd.Premium_10_10__c); 
                    pol.Excess_Premium__c = (pol.Excess_Premium__c == null ? 0 : pol.Excess_Premium__c) - (polEnd.Excess__c == null ? 0 : polEnd.Excess__c); 
                    pol.Primary__c = (pol.Primary__c == null ? 0 : pol.Primary__c) - (polEnd.Primary__c == null ? 0 : polEnd.Primary__c);
                    
                    lstPoliciesToUpdate.add(pol);
                }
            }
        }
        srList =  Database.update(lstPoliciesToUpdate,false);
        for(Integer i =0 ;i <srList.size();i++){
            if(!srList[i].isSuccess()){
                endorsementDeleteErrorIds.add(lstPoliciesToUpdate.get(i).Id);
            }
        }
        for(Policy_Endorsement__c polEnd : lstCompleteDeleteEndorsement){
            if(endorsementDeleteErrorIds.contains(polEnd.id) || endorsementDeleteErrorIds.contains(polEnd.Policy_Lawyer__c) || endorsementDeleteErrorIds.contains(polEnd.Policy__c)){
                polEnd.addError('There is some error occurred while deleting the endorsement.');
            }else{
                if(polEnd.Attachment_Record_Id__c!=null){
                    attachmentsToDelete.add(new Attachment(Id=polEnd.Attachment_Record_Id__c));
                }
            }
        }
        if(attachmentsToDelete!=null && attachmentsToDelete.size()>0){
            Database.delete(attachmentsToDelete,false);
        }
    }
    
    public static void performAddEndorsementDelete(List<Policy_Endorsement__c> lstCompleteDeleteEndorsement){
        
        PolicyLawyerGateway.allowDeleteLawyerFromEndorsement = true;
        
        Set<Id> setPolicyIds = new Set<Id>();
        Set<Id> setPolicyLawyerIds = new Set<Id>();
        Map<Id,String> endorsementDeleteErrorIds = new Map<Id,String>();
        List<Policy__c> lstPoliciesToUpdate = new List<Policy__c>();
        List<Attachment> attachmentsToDelete = new List<Attachment>();
        //Map<Id, Decimal> deletedLawyerPremiumMap = new Map<Id, Decimal>();
                
        List<AS_Transaction__c> asTransactionsToDelete = [select id,name,Policy_Endorsement_Id__c from AS_Transaction__c where Policy_Endorsement_Id__c = : lstCompleteDeleteEndorsement] ;
        List<AcctSeed__Billing__c> billingsToDelete = [SELECT id,name,Policy_Endorsement__c,Policy__c,AcctSeed__Status__c,AcctSeed__Accounting_Period__c,
                                                       AcctSeed__Customer__c,AcctSeed__Billing_Format__c,AcctSeed__Date__c,AcctSeed__Due_Date2__c 
                                                       FROM AcctSeed__Billing__c where Policy_Endorsement__c = : lstCompleteDeleteEndorsement];
        
        List<AcctSeed__Scheduled_Revenue_Expense__c> amortizedRevenueToDelete = [select id,name,AcctSeed__Billing__r.Policy_Endorsement__c from AcctSeed__Scheduled_Revenue_Expense__c where AcctSeed__Billing__r.Policy_Endorsement__c = : lstCompleteDeleteEndorsement];
        
        List<AcctSeed__Journal_Entry__c> journalToDelete = [select id,Policy_Endorsement__c from AcctSeed__Journal_Entry__c where Policy_Endorsement__c = : lstCompleteDeleteEndorsement ];
        
        Database.DeleteResult[] drList = Database.delete(asTransactionsToDelete,false);
        for(Integer i =0 ;i <drList.size();i++){
            if(!drList[i].isSuccess()){
                endorsementDeleteErrorIds.put(asTransactionsToDelete.get(i).Policy_Endorsement_Id__c,'');
            }
        }
        
        AcctSeed.PostResult[] unpostResults = AcctSeed.JournalEntryPostService.unpostJournalEntries(journalToDelete);
        for(Integer i =0 ;i<unpostResults.size();i++){
            if (!unpostResults[i].isSuccess) {
                endorsementDeleteErrorIds.put(journalToDelete.get(i).Policy_Endorsement__c,'');
            }
        }
        
        drList = Database.delete(journalToDelete,false);
        for(Integer i =0 ;i <drList.size();i++){
            if(!drList[i].isSuccess()){
                endorsementDeleteErrorIds.put(journalToDelete.get(i).Policy_Endorsement__c,'');
            }
        }
        
        unpostResults = AcctSeed.ScheduledRevenueExpensePostService.unpostScheduledRevenueExpenses(amortizedRevenueToDelete);
        for(Integer i =0 ;i<unpostResults.size();i++){
            if (!unpostResults[i].isSuccess) {
                endorsementDeleteErrorIds.put(amortizedRevenueToDelete.get(i).AcctSeed__Billing__r.Policy_Endorsement__c,'');
            }
        }
        
        drList = Database.delete(amortizedRevenueToDelete,false);
        for(Integer i =0 ;i <drList.size();i++){
            if(!drList[i].isSuccess()){
                endorsementDeleteErrorIds.put(amortizedRevenueToDelete.get(i).AcctSeed__Billing__r.Policy_Endorsement__c,'');
            }
        }
        
        
        unpostResults = AcctSeed.BillingPostService.unpostBillings(billingsToDelete);
        for(Integer i =0 ;i<unpostResults.size();i++){
            if (!unpostResults[i].isSuccess) {
                endorsementDeleteErrorIds.put(billingsToDelete.get(i).Policy_Endorsement__c,'');
            }
        }
        
        drList = Database.delete(billingsToDelete,false);
        for(Integer i =0 ;i <drList.size();i++){
            if(!drList[i].isSuccess()){
                endorsementDeleteErrorIds.put(billingsToDelete.get(i).Policy_Endorsement__c,'');
            }
        }
        
        
        for (Policy_Endorsement__c polEnd : lstCompleteDeleteEndorsement) {
            setPolicyIds.add(polEnd.Policy__c);
            setPolicyLawyerIds.add(polEnd.Lawyer__c);
        }
        System.debug('setPolicyIds---'+setPolicyIds);
        System.debug('setPolicyLawyerIds---'+setPolicyLawyerIds);
        
        List<Policy_Lawyer__c> polLawyerToDelete = [SELECT Id, Premium__c,Policy__c,Primary__c,Excess__c FROM Policy_Lawyer__c WHERE Lawyer__c IN: setPolicyLawyerIds AND Policy__c IN: setPolicyIds AND Deleted_Lawyer__c = false];
        
        System.debug('polLawyerToDelete---'+polLawyerToDelete);
                                       
        drList =  Database.delete(polLawyerToDelete,false);
        for(Integer i =0 ;i <drList.size();i++){
            if(!drList[i].isSuccess()){
                String str ='';
                for(Database.Error err : drList[i].getErrors()) {
                    str += err.getMessage();
                }
                endorsementDeleteErrorIds.put(polLawyerToDelete.get(i).Id,str);                    
            }
        }
        
        /*List<AS_Transaction__c> asTransactionsToInsert = new List<AS_Transaction__c>();
        
        for(AS_Transaction__c as_trans: [SELECT Id,Name,Amount__c,Policy_Id__c,Firm_Id__c FROM AS_Transaction__c 
                                            WHERE Policy_Endorsement_Id__c = : lstCompleteDeleteEndorsement]){
                                            
            AS_Transaction__c as_transCopy = as_trans.clone(false, true, false, false);
            as_transCopy.Amount__c = - as_trans.Amount__c;
            as_transCopy.Transaction_Type__c = 'Delete Lawyer';
            as_transCopy.Transaction_Sub_Type__c = 'Delete Lawyer';
            
            asTransactionsToInsert.add(as_transCopy);
            
        }
        
        if(!asTransactionsToInsert.isEmpty()){
            //insert asTransactionsToInsert;
            Database.SaveResult[] srList =  Database.insert(asTransactionsToInsert,false);
            
            for(Integer i =0 ;i <srList.size();i++){
                if(!srList[i].isSuccess()){
                    String str ='';
                    for(Database.Error err : srList[i].getErrors()) {
                        str += err.getMessage();
                    }
                    endorsementDeleteErrorIds.put(lstPoliciesToUpdate.get(i).Policy_Id__c,str);
                }
            }
        
        
        }*/
        
        // SOQL Policies to update premium.
        for (Policy__c pol : [SELECT Id, Name, Premium__c,Total_5x5__c,Total_10x10__c,Excess_Premium__c,Primary__c FROM Policy__c WHERE Id IN: setPolicyIds]) {
            for (Policy_Endorsement__c polEnd : lstCompleteDeleteEndorsement) {
                if (pol.Id == polEnd.Policy__c) {
                    pol.Premium__c = pol.Premium__c - (polEnd.Premium__c);
                    pol.Total_5x5__c = (pol.Total_5x5__c == null ? 0 : pol.Total_5x5__c) - (polEnd.Premium_5_5__c == null ? 0 : polEnd.Premium_5_5__c);
                    pol.Total_10x10__c = (pol.Total_10x10__c == null ? 0 : pol.Total_10x10__c) - (polEnd.Premium_10_10__c == null ? 0 : polEnd.Premium_10_10__c); 
                    pol.Excess_Premium__c = (pol.Excess_Premium__c == null ? 0 : pol.Excess_Premium__c) - (polEnd.Excess__c == null ? 0 : polEnd.Excess__c); 
                    pol.Primary__c = (pol.Primary__c == null ? 0 : pol.Primary__c) - (polEnd.Primary__c == null ? 0 : polEnd.Primary__c);
                    lstPoliciesToUpdate.add(pol);
                }
            }
        }
        
        Database.SaveResult[] srList =  Database.update(lstPoliciesToUpdate,false);
        
        for(Integer i =0 ;i <srList.size();i++){
            if(!srList[i].isSuccess()){
                String str ='';
                for(Database.Error err : srList[i].getErrors()) {
                    str += err.getMessage();
                }
                endorsementDeleteErrorIds.put(lstPoliciesToUpdate.get(i).Id,str);
            }
        }
        
        
        for(Policy_Endorsement__c polEnd : lstCompleteDeleteEndorsement){
            String error = '';
            if(endorsementDeleteErrorIds.containsKey(polEnd.id)){
                error += (endorsementDeleteErrorIds.get(polEnd.id) + '.');
            }else if(endorsementDeleteErrorIds.containsKey(polEnd.Policy_Lawyer__c)){
                error += (endorsementDeleteErrorIds.get(polEnd.Policy_Lawyer__c) + '.');
            }else if( endorsementDeleteErrorIds.containsKey(polEnd.Policy__c)){
                error += (endorsementDeleteErrorIds.get(polEnd.Policy__c) + '.');
            }else{
                if(polEnd.Attachment_Record_Id__c!=null){
                    attachmentsToDelete.add(new Attachment(Id=polEnd.Attachment_Record_Id__c));
                }
            }
            
            if(String.isNotBlank(error)){
               polEnd.addError('There is some error occurred while deleting the endorsement. ' + error ); 
            }
        }
        if(attachmentsToDelete!=null && attachmentsToDelete.size()>0){
            Database.delete(attachmentsToDelete,false);
        }
        
        /*
        Set<String> setPolicyIds = new Set<String>();
        Set<String> setPolicyLawyerIds = new Set<String>();
        Set<Id> endorsementDeleteErrorIds = new Set<Id>();
        List<Policy_Lawyer__c> lstLawyersToUpdate = new List<Policy_Lawyer__c>();
        List<Policy__c> lstPoliciesToUpdate = new List<Policy__c>();
        List<AS_Transaction__c> asTransactionsToDelete = [select id,name,Policy_Endorsement_Id__c from AS_Transaction__c where Policy_Endorsement_Id__c = : lstCompleteDeleteEndorsement] ;
        List<AcctSeed__Billing__c> billingsToDelete = [SELECT id,name,Policy_Endorsement__c,Policy__c,AcctSeed__Status__c,AcctSeed__Accounting_Period__c,
                                                        AcctSeed__Customer__c,AcctSeed__Billing_Format__c,AcctSeed__Date__c,AcctSeed__Due_Date2__c 
                                                        FROM AcctSeed__Billing__c where Policy_Endorsement__c = : lstCompleteDeleteEndorsement];
        
        
        Map<Id, AcctSeed__Billing__c> billingsCreditMemoClone = new Map<Id, AcctSeed__Billing__c>();
        
        Map<Id, List<AcctSeed__Billing_Line__c>> billLineCreditMemoClone = new Map<Id, List<AcctSeed__Billing_Line__c>>();
        
        for(AcctSeed__Billing__c billingsAddAttorney: billingsToDelete){
            AcctSeed__Billing__c billCopy = billingsAddAttorney.clone(false, true, false, false);
            billingsCreditMemoClone.put(billingsAddAttorney.Id, billCopy);
        }
        
        for(AcctSeed__Billing_Line__c billLine: [SELECT Id, Name,AcctSeed__Billing__c,AcctSeed__Rate__c,AcctSeed__Hours_Units__c,
                                                    AcctSeed__Revenue_GL_Account__c,AcctSeed__Expense_GL_Account__c,AcctSeed__Date__c
                                                    FROM AcctSeed__Billing_Line__c WHERE AcctSeed__Billing__c IN: billingsToDelete]){
            AcctSeed__Billing_Line__c billLineCopy = billLine.clone(false, true, false, false);
            billLineCopy.AcctSeed__Rate__c = - billLine.AcctSeed__Rate__c;
            
            if(!billLineCreditMemoClone.containsKey(billLine.AcctSeed__Billing__c)){
                billLineCreditMemoClone.put(billLine.AcctSeed__Billing__c, new List<AcctSeed__Billing_Line__c>{billLineCopy});
            }
            else{
                billLineCreditMemoClone.get(billLine.AcctSeed__Billing__c).add(billLineCopy);
            }
            
        }
        
        List<AcctSeed__Scheduled_Revenue_Expense__c> amortizedRevenueToDelete = [select id,name,AcctSeed__Billing__r.Policy_Endorsement__c from AcctSeed__Scheduled_Revenue_Expense__c where AcctSeed__Billing__r.Policy_Endorsement__c = : lstCompleteDeleteEndorsement];
        
        Database.DeleteResult[] drList = Database.delete(asTransactionsToDelete,false);
        for(Integer i =0 ;i <drList.size();i++){
            if(!drList[i].isSuccess()){
                endorsementDeleteErrorIds.add(asTransactionsToDelete.get(i).Policy_Endorsement_Id__c);
            }
        }
        
        AcctSeed.PostResult[] unpostResults = AcctSeed.ScheduledRevenueExpensePostService.unpostScheduledRevenueExpenses(amortizedRevenueToDelete);
        for(Integer i =0 ;i<unpostResults.size();i++){
            if (!unpostResults[i].isSuccess) {
                endorsementDeleteErrorIds.add(amortizedRevenueToDelete.get(i).AcctSeed__Billing__r.Policy_Endorsement__c);
            }
        }
        
        drList = Database.delete(amortizedRevenueToDelete,false);
        for(Integer i =0 ;i <drList.size();i++){
            if(!drList[i].isSuccess()){
                endorsementDeleteErrorIds.add(amortizedRevenueToDelete.get(i).AcctSeed__Billing__r.Policy_Endorsement__c);
            }
        }
        
        drList = Database.delete(billingsToDelete,false);
        for(Integer i =0 ;i <drList.size();i++){
            if(!drList[i].isSuccess()){
                endorsementDeleteErrorIds.add(billingsToDelete.get(i).Policy_Endorsement__c);
                billingsCreditMemoClone.remove(billingsToDelete.get(i).Id);
                billLineCreditMemoClone.remove(billingsToDelete.get(i).Id);
            }
        }
        
        if(billingsCreditMemoClone != null){
            insert billingsCreditMemoClone.values();
            
            List<AcctSeed__Billing_Line__c> billLineList = new List<AcctSeed__Billing_Line__c>();
            
            for(Id billDelId: billingsCreditMemoClone.keyset()){
                        
                if(billLineCreditMemoClone.containskey(billDelId)){
                    for(AcctSeed__Billing_Line__c billLine : billLineCreditMemoClone.get(billDelId)) {
                    
                    
                        billLine.AcctSeed__Billing__c = billingsCreditMemoClone.get(billDelId).Id;
                        
                        //billLineCreditMemoClone.put(billDelId,billLine);
                        billLineList.add(billLine);
                    }
                    
                }
            }
            
            if(!billLineList.isEmpty()){
                insert billLineList;
            }
                
        }
        
        for (Policy_Endorsement__c polEnd : lstCompleteDeleteEndorsement) {
            setPolicyIds.add(polEnd.Policy__c);
            setPolicyLawyerIds.add(polEnd.Policy_Lawyer__c);
        }
        for (Policy_Lawyer__c polLaw : [SELECT Id, Account__c, Lawyer__c, Policy__c, Primary__c, Step__c, X5_5__c, X10_10__c, Premium__c, Prior_Act_Date__c, Active__c,
                                        Deleted_Lawyer__c, Deleted_Date__c, Old_Primary_Value__c,Old_Step_Value__c,Old_5x5_Value__c,Old_10x10_Value__c,Old_Premium__c,Old_Prior_Act_Date__c
                                        FROM Policy_Lawyer__c WHERE Id IN: setPolicyLawyerIds AND Policy__c IN: setPolicyIds AND Deleted_Lawyer__c = true]) {
            for (Policy_Endorsement__c polEnd : lstCompleteDeleteEndorsement) {
                if (polLaw.Id == polEnd.Policy_Lawyer__c && polLaw.Policy__c == polEnd.Policy__c) {
                    polLaw.Primary__c = polLaw.Old_Primary_Value__c;
                    polLaw.Step__c = polLaw.Old_Step_Value__c;
                    polLaw.X5_5__c = polLaw.Old_5x5_Value__c;
                    polLaw.X10_10__c = polLaw.Old_10x10_Value__c;
                    polLaw.Premium__c = polLaw.Old_Premium__c;
                    polLaw.Prior_Act_Date__c = polLaw.Old_Prior_Act_Date__c;
                    polLaw.Active__c = true;
                    polLaw.Deleted_Lawyer__c = false;
                    polLaw.Deleted_Date__c = null;
                    lstLawyersToUpdate.add(polLaw);
                    
                }
            }
        }
        Database.SaveResult[] srList =  Database.update(lstLawyersToUpdate,false);
        for(Integer i =0 ;i <srList.size();i++){
            if(!srList[i].isSuccess()){
                endorsementDeleteErrorIds.add(lstLawyersToUpdate.get(i).Id);                    
            }
        }
        // SOQL Policies to update premium.
        for (Policy__c pol : [SELECT Id, Name, Premium__c FROM Policy__c WHERE Id IN: setPolicyIds]) {
            for (Policy_Endorsement__c polEnd : lstCompleteDeleteEndorsement) {
                if (pol.Id == polEnd.Policy__c) {
                    pol.Premium__c = pol.Premium__c - (polEnd.Premium__c);
                    
                    lstPoliciesToUpdate.add(pol);
                }
            }
        }
        srList =  Database.update(lstPoliciesToUpdate,false);
        for(Integer i =0 ;i <srList.size();i++){
            if(!srList[i].isSuccess()){
                endorsementDeleteErrorIds.add(lstPoliciesToUpdate.get(i).Id);
            }
        }
        for(Policy_Endorsement__c polEnd : lstCompleteDeleteEndorsement){
            if(endorsementDeleteErrorIds.contains(polEnd.id) || endorsementDeleteErrorIds.contains(polEnd.Policy_Lawyer__c) || endorsementDeleteErrorIds.contains(polEnd.Policy__c)){
                polEnd.addError('There is some error occurred while deleting the endorsement.');
            }
        }
        
        */
    }
    public static void performEREEndorsementDelete(List<Policy_Endorsement__c> lstEREDeleteEndorsement){
        /*Set<String> setPolicyIds = new Set<String>();
        Set<Id> endorsementDeleteErrorIds = new Set<Id>();
        List<Policy__c> lstPoliciesToUpdate = new List<Policy__c>();
        List<Attachment> attachmentsToDelete = new List<Attachment>();
        List<AS_Transaction__c> asTransactionsToInsert = new List<AS_Transaction__c>();
        Database.SaveResult[] srList;
        for(Policy_Endorsement__c polEnd : lstEREDeleteEndorsement){
            setPolicyIds.add(polEnd.Policy__c);
        }
        for(AS_Transaction__c as_trans: [SELECT Id,Name,Amount__c,Policy_Id__c,Firm_Id__c FROM AS_Transaction__c WHERE Policy_Endorsement_Id__c = : lstEREDeleteEndorsement]){
            
            AS_Transaction__c as_transCopy = as_trans.clone(false, true, false, false);
            as_transCopy.Amount__c = - as_trans.Amount__c;
            as_transCopy.Transaction_Type__c = 'ERE';
            as_transCopy.Transaction_Sub_Type__c = 'ERE';
            asTransactionsToInsert.add(as_transCopy);
            
        }
        
        if(!asTransactionsToInsert.isEmpty()){
            srList =  Database.insert(asTransactionsToInsert,false);
            for(Integer i =0 ;i <srList.size();i++){
                if(!srList[i].isSuccess()){
                    endorsementDeleteErrorIds.add(lstPoliciesToUpdate.get(i).Policy_Id__c);
                }
            }
        }
        for (Policy__c pol : [SELECT Id, Name, Premium__c, ERE_Date__c FROM Policy__c WHERE Id IN: setPolicyIds]) {
            for (Policy_Endorsement__c polEnd : lstEREDeleteEndorsement) {
                if (pol.Id == polEnd.Policy__c) {
                    pol.Premium__c = pol.Premium__c - (polEnd.Premium__c);
                    pol.ERE_Date__c = null;
                    lstPoliciesToUpdate.add(pol);
                }
            }
        }
        srList =  Database.update(lstPoliciesToUpdate,false);
        for(Integer i =0 ;i <srList.size();i++){
            if(!srList[i].isSuccess()){
                endorsementDeleteErrorIds.add(lstPoliciesToUpdate.get(i).Id);
            }
        }
        for(Policy_Endorsement__c polEnd : lstEREDeleteEndorsement){
            if(endorsementDeleteErrorIds.contains(polEnd.id) || endorsementDeleteErrorIds.contains(polEnd.Policy_Lawyer__c) || endorsementDeleteErrorIds.contains(polEnd.Policy__c)){
                polEnd.addError('There is some error occurred while deleting the endorsement.');
            }else{
                if(polEnd.Attachment_Record_Id__c!=null){
                    attachmentsToDelete.add(new Attachment(Id=polEnd.Attachment_Record_Id__c));
                }
            }
        }
        if(attachmentsToDelete!=null && attachmentsToDelete.size()>0){
            Database.delete(attachmentsToDelete,false);
        }*/
    }
    
    public static void performCancelEndorsementDelete(List<Policy_Endorsement__c> lstEREDeleteEndorsement){
    }
    
    public static void completeEREOnly(List<Policy_Endorsement__c> lstCompleteEREOnly) {
        completeEREOnlyFunc(lstCompleteEREOnly,null,null);
    }
    
    // Complete ERE Helper Function. IL 107B,107C,107D
    public static void completeEREOnlyFunc(List<Policy_Endorsement__c> lstCompleteEREOnly,Id policyLawyerId,String lawyerName) {
        Set<String> setPolicyIds = new Set<String>();
        List<Policy__c> erpPolicy = new List<Policy__c>();
        List<Policy_Quote__c> lstQuotesToClone = new List<Policy_Quote__c>();
        List<Policy_Endorsement__c> lstEndsToClone = new List<Policy_Endorsement__c>();
        List<Policy_Lawyer__c> lstLawyersToClone = new List<Policy_Lawyer__c>();
        List<Policy_AOP__c> lstAOPsToClone = new List<Policy_AOP__c>();
        Set<Id> policyLawyerIds = new Set<Id>();
        List<GEO_Factor__c>threatMappings = [SELECT Id,Name,From_Date__c,To_Date__c FROM GEO_Factor__c];
        // Loop through endoresement to get the policy ids to update.
        for (Policy_Endorsement__c polEnd : lstCompleteEREOnly) {
            setPolicyIds.add(polEnd.Policy__c);
        }
        // Fetch the policies to update and put them in a map.
        
        Map<String, Schema.SObjectField> fieldMap = Policy__c.sObjectType.getDescribe().fields.getMap();
        
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
        List<Deductible_Factor__c> deductibleFactor = [select id,From_Date__c,To_Date__c,Deductible_Amount__c  from Deductible_Factor__c where Deductible_Amount__c = 0];
        List<ILF_Coverage_Factor__c> coverageFactor = [select id,From_Date__c,To_Date__c from ILF_Coverage_Factor__c  where Coverage_Max_Per_Claim__c = 1000000 and Full_Coverage__c = 1000000];
        for (Policy__c pol : Database.query('SELECT ' + String.join(lstFieldNames, ',') + ',County__r.Name,Limit__r.Full_Coverage__c FROM Policy__c where Id In: setPolicyIds')) {
            for (Policy_Endorsement__c polEnd : lstCompleteEREOnly) {
                if (pol.Id == polEnd.Policy__c) {
                    if(policyLawyerId != null){
                        policyLawyerIds.add(policyLawyerId);
                    }else{
                        policyLawyerIds.add(polEnd.Policy_Lawyer__c );
                    }
                    Policy__c newPolicy = new Policy__c();
                    newPolicy = pol.clone(false, true);
                    newPolicy.Old_Policy__c = null;
                    newPolicy.Previous_Policy__c = pol.Id;
                    newPolicy.PolicyExternalID__c = '';
                    newPolicy.RecordTypeId = ApplicationPolicyUtil.PolicyERPRTID;// mapPolicyRecordType.get('Application').Id;
                    newPolicy.Status__c = 'Bound';
                    //newPolicy.Status_Description__c = 'PolicyEndorsementGateway';
                    newPolicy.Renewal_Type__c = null;
                    //newPolicy.Active__c = false;
                    newPolicy.Effective_Date__c = polEnd.Endorsement_Effective_Date__c;
                    newPolicy.Application_Type__c = 'Renewal';
                    newPolicy.Account__c = pol.Account__c;
                    newPolicy.Expiration_Date__c = newPolicy.Effective_Date__c.addYears(100);
                    //newPolicy.Account_Contact__c = PolicyForloop.Account_Contact__c;
                    newPolicy.Firm_Contact__C = pol.Firm_Contact__C;
                    newPolicy.Policy_Retroactive_Date__c = pol.Policy_Retroactive_Date__c;
                    newPolicy.Premium__c = null;
                    newPolicy.Policy_Number__c = null;
                    newPolicy.Premium_Amount__c = null;
                    newPolicy.Original_Premium__c = null;
                    newPolicy.Underwriter_User__c = pol.Underwriter_User__c;
                    newPolicy.Support_Staff__c = pol.Support_Staff__c;
                    newPolicy.Opportunity__c=null;
                    newPolicy.ClonedBy__c = '';
                    newPolicy.PaymentReceived__c = '';
                    newPolicy.X10x10__c = pol.X10x10__c;
                    newPolicy.X5_5_Override__c = pol.X5_5_Override__c;
                    newPolicy.Claims_Factor__c = pol.Claims_Factor__c;
                    newPolicy.Is_Accepted_Confirm__c = false;
                    newPolicy.Is_Allow_to_Generate_AS__c =false;
                    newPolicy.Is_Allow_Calculate_Premium__c = false;
                    newPolicy.ISBAM_Processed__c = false;
                    newPolicy.Accounting_Processed__c = false;
                    newPolicy.GL_Processing_Date__c = null;
                    newPolicy.Policy_Renew_Status__c = '';
                    if(lawyerName != null){
                        newPolicy.Name = pol.Name + '-' + lawyerName ;
                    }else{
                        newPolicy.Name = pol.Name + '-' + polEnd.Lawyer_Name__c ;
                    }
                    newPolicy.County__c = null;
                    newPolicy.Bound_Date__c = null;
                    newPolicy.Mini_Tail_Override_Date__c = null;
                    newPolicy.Treaty_Correction_Processed__c = false;
                    newPolicy.Create_Follow_Up_Task__c = false;
                    newPolicy.Follow_Up_Task_Date__c = null;
                    newPolicy.Follow_Up_Task_Owner__c = null;
                    newPolicy.sharepoint_folder_id__c = null;
                    newPolicy.ISBAM_policy_dividend__c = 0;
                    newPolicy.ADJ_MOD__c = 0; 
                    newPolicy.ERP_Endorsement__c = polEnd.Id;
                    newPolicy.Cancel_Date__c = null;
                    if(pol.Limit__r.Full_Coverage__c <= 1000000){
                        newPolicy.Limit__c = pol.Limit__c;
                    }
                    else{
                        for(ILF_Coverage_Factor__c   factor : coverageFactor){
                            if(factor.From_Date__c <= newPolicy.Effective_Date__c &&  factor.To_Date__c >= newPolicy.Effective_Date__c){
                                newPolicy.Limit__c =factor.Id;
                            }
                        }
                    }
                    for(Deductible_Factor__c  factor : deductibleFactor){
                        if(factor.From_Date__c <= newPolicy.Effective_Date__c &&  factor.To_Date__c >= newPolicy.Effective_Date__c){
                            newPolicy.Deductible_ID__c =factor.Id;
                        }
                    }
                    newPolicy.Terms_Conditions__c = '<ul><li>Executed <b>Quote and Acceptance Form</b> confirming the firm’s limit and deductible selection.</li>' +
                        +'<li>Copy of Firm Letterhead, if not already provided.</li>' +
                        +'<li>ISBA Mutual Premium Payment Invoice confirming the Firm’s payment selection.</li></ul>';
                    for(GEO_Factor__c factor : threatMappings){
                        if(factor.From_Date__c <= newPolicy.Effective_Date__c &&  factor.To_Date__c >= newPolicy.Effective_Date__c && factor.name == pol.County__r.Name){
                            newPolicy.County__c = factor.Id;
                        }
                    }
                    erpPolicy.add(newPolicy);
                }
            }
        }
        insert erpPolicy;
        
        for(Integer i=0;i<erpPolicy.size();i++){
            List<String> fieldNames = new List<String>( Schema.getGlobalDescribe().get('Policy_Quote__c').getDescribe().fields.getMap().keySet() );
            String query =' SELECT ' +String.join( fieldNames, ',' ) +',Coverage__r.Name,Deductible__r.Name,Coverage__r.Full_Coverage__c ,Policy__r.Name FROM Policy_Quote__c'  +' WHERE ' +' Policy__c in: setPolicyIds ' +' AND Final_Quote__c = true ';
            
            for (Policy_Quote__c quo : Database.query(query)) {
                for (Policy__c pol : erpPolicy) {
                    if (quo.Policy__c == pol.Previous_Policy__c) {
                        Policy_Quote__c newQuote = new Policy_Quote__c();
                        newQuote = quo.Clone(false, true);
                        newQuote.Final_Quote__c = false; 
                        if(quo.Coverage__r.Full_Coverage__c <= 1000000){
                            newQuote.Coverage__c = quo.Coverage__c;
                        }
                        else{
                            for(ILF_Coverage_Factor__c   factor : coverageFactor){
                                if(factor.From_Date__c <= pol.Effective_Date__c &&  factor.To_Date__c >= pol.Effective_Date__c){
                                    newQuote.Coverage__c =factor.Id;
                                }
                            }
                        }
                        for(Deductible_Factor__c  factor : deductibleFactor){
                            if(factor.From_Date__c <= pol.Effective_Date__c &&  factor.To_Date__c >= pol.Effective_Date__c){
                                newQuote.Deductible__c =factor.Id;
                            }
                        }
                        newQuote.Policy__c = pol.Id;
                        newQuote.Quote_Expire_Date__c = pol.Effective_Date__c.addyears(100);
                        newQuote.Policy_Quote_External_ID__c =  null;
                        newQuote.ADJ_MOD__c = 0;
                        newQuote.X5X5_Override__c = 0;
                        newQuote.X10X10__c   = 0;
                        lstQuotesToClone.add(newQuote);
                    }
                }
            }
            
            if(lstQuotesToClone!=null && lstQuotesToClone.size()>0){
                insert lstQuotesToClone;
            }
            
            fieldNames = new List<String>( Schema.getGlobalDescribe().get('Policy_Lawyer__c').getDescribe().fields.getMap().keySet() );
            query =' SELECT ' +String.join( fieldNames, ',' ) +' FROM Policy_Lawyer__c'  +' WHERE ' +' Id in: policyLawyerIds ' +'  AND  Deleted_Date__c = null';
            
            // Fetch Policy Lawyers to Attach with Newly created applications.
            for (Policy_Lawyer__c law : Database.query(query)) {
                for (Policy__c pol : erpPolicy) {
                    if (law.Policy__c == pol.Previous_Policy__c) {
                        Policy_Lawyer__c newLawyer = new Policy_Lawyer__c();
                        newLawyer = law.Clone(false, true);
                        newLawyer.Is_Application_Lawyer__c = true;
                        newLawyer.Policy__c = pol.Id;
                        newLawyer.Policy_Lawyer_External_ID__c =  null;
                        newLawyer.Added_Date__c = null;
                        lstLawyersToClone.add(newLawyer);
                    }
                }
            }
            if(lstLawyersToClone!=null && lstLawyersToClone.size()>0){
                insert lstLawyersToClone;
            }
            
            
            
            // Fetch Policy AOP to Attach with Newly created applications.
            for (Policy_AOP__c AOP : [SELECT AOP__c, Bypass_Default_Factor__c, Factor_Mod__c, Id, Name, Percentage_Value__c, Percentage__c, Policy_Number__c, Policy__c,AOP__r.Name,Policy__r.Name FROM Policy_AOP__c WHERE Policy__c IN :setPolicyIds]) {
                for (Policy__c pol : erpPolicy) {
                    if (AOP.Policy__c == pol.Previous_Policy__c) {
                        Policy_AOP__c newAOP = new Policy_AOP__c();
                        newAOP = AOP.Clone(false, true);
                        newAOP.AOP__c = AOP.AOP__c;
                        newAOP.Policy__c = pol.Id;
                        newAOP.Policy_AOP_External_ID__c = null;
                        lstAOPsToClone.add(newAOP);
                    }
                }
            }
            if(lstAOPsToClone!=null && lstAOPsToClone.size()>0){
                insert lstAOPsToClone;
            }
            // Fetch all the Descriptive Endorsement record type ids.
            Set<String> setRecordTypeIds = new Set<String>();
            
            for (Endorsement__c endRT : [SELECT Id, Endorsement_Record_Type_ID__c FROM Endorsement__c WHERE Endorsement_Sub_Type__c = 'IL 102' OR (Type__c = 'Descriptive'and Endorsement_Sub_Type__c != 'IL 230' and  Endorsement_Sub_Type__c != 'IL 234' and  Endorsement_Sub_Type__c != 'IL 261'  and  Endorsement_Sub_Type__c != 'IL 302'  and  Endorsement_Sub_Type__c != 'IL 106')]) {
                setRecordTypeIds.add(endRT.Endorsement_Record_Type_ID__c);
            }
            Set<Id> oldEndorsementIds = new Set<Id>();
            
            fieldNames = new List<String>( Schema.getGlobalDescribe().get('Policy_Endorsement__c').getDescribe().fields.getMap().keySet() );
            query =' SELECT ' +String.join( fieldNames, ',' ) +' FROM Policy_Endorsement__c'  +' WHERE ' +' Policy__c in: setPolicyIds and  RecordTypeId IN :setRecordTypeIds';
            
            Long dateTimeNow = Datetime.now().getTime();
            
            // Fetch Policy Endorsements to Attach with Newly created applications.
            for (Policy_Endorsement__c ends : Database.query(query)) {
                for (Policy__c pol : erpPolicy) {
                    if (ends.Policy__c == pol.Previous_Policy__c) {
                        Policy_Endorsement__c newEnd = new Policy_Endorsement__c();
                        newEnd = ends.Clone(false, true);
                        newEnd.Event_Status__c = 'Pending';
                        newEnd.Endorsement_Effective_Date__c = pol.Effective_Date__c;
                        newEnd.Policy__c = pol.Id;
                        newEnd.Policy_Endorsement_External_Id__c = ends.Id + '-' + dateTimeNow;
                        oldEndorsementIds.add(ends.Id);
                        lstEndsToClone.add(newEnd);
                    }
                }
            }
            
            if(lstEndsToClone!=null && lstEndsToClone.size()>0){
                insert lstEndsToClone;
            }
            List<Policy_Endorsement_Term__c> termsToClone = new List<Policy_Endorsement_Term__c>();
            for(Policy_Endorsement_Term__c term : [select id,Attorney__c,Endorsement__c,Firm_Entity__c,Term_End_Date__c,Term_Start_Date__c from Policy_Endorsement_Term__c where Endorsement__c in: oldEndorsementIds]){
                Policy_Endorsement_Term__c newTerm = new Policy_Endorsement_Term__c();
                Policy_Endorsement__c newEnd = new Policy_Endorsement__c();
                newEnd.Policy_Endorsement_External_Id__c = term.Endorsement__c + '-' + dateTimeNow;
                newTerm.Attorney__c = term.Attorney__c;
                newTerm.Firm_Entity__c = term.Firm_Entity__c;
                newTerm.Term_End_Date__c = term.Term_End_Date__c;
                newTerm.Term_Start_Date__c = term.Term_Start_Date__c;
                newTerm.Endorsement__r = newEnd;
                System.debug('======newTerm' + newTerm);
                termsToClone.add(newTerm);
            }
            if(termsToClone.size()>0){
                insert termsToClone;
            }
            
        }
    }
    
    public static void completeAdditionalPremium(List<Policy_Endorsement__c> lstCompleteAdditionalPremium){
        Set<String> setPolicyIds = new Set<String>();
        List<Policy__c> lstPoliciesToUpdate = new List<Policy__c>();
        List<AS_Transaction__c> lstASTransaction = new List<AS_Transaction__c>();
        List<Policy_Premium_History__c> premiumHistoryList = new List<Policy_Premium_History__c>();
        // Loop through endoresement to get the policy ids to update.
        for (Policy_Endorsement__c polEnd : lstCompleteAdditionalPremium) {
            setPolicyIds.add(polEnd.Policy__c);
        }
        // Fetch the policies to update and put them in a map.
        for (Policy__c pol : [SELECT Id, Name, Premium__c, ERE_Date__c, Account__c FROM Policy__c WHERE Id IN: setPolicyIds and RecordType.Name = 'Policy']) {
            for (Policy_Endorsement__c polEnd : lstCompleteAdditionalPremium) {
                if (pol.Id == polEnd.Policy__c) {
                    pol.Premium__c = pol.Premium__c + polEnd.Additional_Premium__c;
                    
                    lstPoliciesToUpdate.add(pol);
                    
                    if(Label.Process_Accounting_On_Endorsements == 'Y'){
                        AS_Transaction__c asTransaction = new AS_Transaction__c();
                        asTransaction.Amount__c = polEnd.Premium__c;
                        asTransaction.Firm_Id__c = pol.Account__c;
                        asTransaction.Policy_Endorsement_Id__c = polEnd.Id;
                        asTransaction.Policy_Id__c = polEnd.Policy__c;
                        asTransaction.Transaction_Type__c = 'Adjust Premium';
                        asTransaction.Transaction_Sub_Type__c = 'Adjust Premium';
                        lstASTransaction.add(asTransaction);
                    }
                    
                    Policy_Premium_History__c premiumHistory = new Policy_Premium_History__c();
                    premiumHistory.Policy__c = polEnd.Policy__c;
                    if(polEnd.Endorsement_Number__c == 'IL 130'){
                        premiumHistory.Action__c = 'IL130';
                    }/*else if(polEnd.Endorsement_Number__c == 'IL 261'){
                        premiumHistory.Action__c = 'IL261';
                    }*/
                    
                    premiumHistory.Premium__c = polEnd.Additional_Premium__c;
                    
                    premiumHistoryList.add(premiumHistory);
                    
                }
            }
        }
        insert lstASTransaction;
        update lstPoliciesToUpdate;
        insert premiumHistoryList;
    }
    public static void completeTitlePremium(List<Policy_Endorsement__c> lstCompleteTitlePremium){
        Set<String> setPolicyIds = new Set<String>();
        List<Policy__c> lstPoliciesToUpdate = new List<Policy__c>();
        List<AS_Transaction__c> lstASTransaction = new List<AS_Transaction__c>();
        List<Policy_Premium_History__c> premiumHistoryList = new List<Policy_Premium_History__c>();
        // Loop through endoresement to get the policy ids to update.
        for (Policy_Endorsement__c polEnd : lstCompleteTitlePremium) {
            setPolicyIds.add(polEnd.Policy__c);
        }
        // Fetch the policies to update and put them in a map.
        for (Policy__c pol : [SELECT Id, Name, Premium__c, ERE_Date__c, Account__c FROM Policy__c WHERE Id IN: setPolicyIds and RecordType.Name = 'Policy']) {
            for (Policy_Endorsement__c polEnd : lstCompleteTitlePremium) {
                if (pol.Id == polEnd.Policy__c) {
                    pol.Premium__c = pol.Premium__c + polEnd.Additional_Premium__c;
                    
                    lstPoliciesToUpdate.add(pol);
                    if(Label.Process_Accounting_On_Endorsements == 'Y'){
                        AS_Transaction__c asTransaction = new AS_Transaction__c();
                        asTransaction.Amount__c = polEnd.Premium__c;
                        asTransaction.Firm_Id__c = pol.Account__c;
                        asTransaction.Policy_Endorsement_Id__c = polEnd.Id;
                        asTransaction.Policy_Id__c = polEnd.Policy__c;
                        asTransaction.Transaction_Type__c = 'Adjust Premium';
                        asTransaction.Transaction_Sub_Type__c = 'Adjust Premium';
                        lstASTransaction.add(asTransaction);
                    }
                    
                    Policy_Premium_History__c premiumHistory = new Policy_Premium_History__c();
                    premiumHistory.Policy__c = polEnd.Policy__c;
                    premiumHistory.Action__c = 'IL210';
                    premiumHistory.Premium__c = polEnd.Additional_Premium__c;
                    
                    premiumHistoryList.add(premiumHistory);
                    
                }
            }
        }
        insert lstASTransaction;
        update lstPoliciesToUpdate;
        insert premiumHistoryList;
    }
    
    /*public static void completeAddEndorsementMod(List<Policy_Endorsement__c> lstAddEndorsementMod){
        Map<Id,Policy__c> policyMap = new Map<Id,Policy__c>();
        for (Policy_Endorsement__c polEnd : lstAddEndorsementMod) {
            if(!policyMap.containsKey(polEnd.Policy__c)){
                policyMap.put(polEnd.Policy__c,new Policy__c(Id=polEnd.Policy__c));
            }
            Policy__c pol = policyMap.get(polEnd.Policy__c);
            if(polEnd.Endorsement_Number__c == 'IL 230'){
                pol.Mod_230__c = 1 + (polEnd.Endorsement_Mod__c / 100);
            }else if(polEnd.Endorsement_Number__c == 'IL 234'){
                pol.Mod_234__c = 1 + (polEnd.Endorsement_Mod__c / 100);
            }else if(polEnd.Endorsement_Number__c == 'IL 261'){
                pol.Mod_261__c = 1 + (polEnd.Endorsement_Mod__c / 100);
            }
            System.debug(pol + 'policyEnd');
            policyMap.put(polEnd.Policy__c,pol);
        }
        if(policyMap.size()>0){
            update policyMap.values();
        }
    }*/
}