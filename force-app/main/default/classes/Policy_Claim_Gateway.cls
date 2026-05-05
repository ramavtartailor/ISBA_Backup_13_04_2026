public class Policy_Claim_Gateway {
/*
//Created By    :   Shoukat Hussain
//Created Date  :   11/27/2016
//Purpose       :   Different function for  Policy Claim
//              :   Public Valirables  Record Type for Claim
*/

    
    // Public static record type
    public static ID ReserveRTID = Schema.SObjectType.Policy_Claim_Detail__C.getRecordTypeInfosByName().get('Reserve').getRecordTypeId();
    public static ID ReinsuranceRTID = Schema.SObjectType.Policy_Claim_Detail__C.getRecordTypeInfosByName().get('Reinsurance').getRecordTypeId();

    public static void InsertReserveOpenRecord(list<Policy_Claim__c> PClaimData){
        // Iterate Trigger.
        system.debug('InsertReserveOpenRecord' +PClaimData);
        List<Policy_Claim_Detail__c> PCDLst = new List<Policy_Claim_Detail__c>();
        system.debug('PClaimData '+PClaimData);
        If(PClaimData.size()>0){
            For(Policy_Claim__c PCLoop : PClaimData){
                system.debug('PCLoop.Is_Reserve_Creation_Block__c : ' + PCLoop.Is_Reserve_Creation_Block__c);
                system.debug('PCLoop.Legacy_Import__c :: ' + PCLoop.Legacy_Import__c);
                 If(!PCLoop.Is_Reserve_Creation_Block__c && !PCLoop.Legacy_Import__c){
                       
                PCDLst.add(new Policy_Claim_Detail__c(
                    Policy_Claim__c = PCLoop.ID,
                    Loss_Amount__c  = PCLoop.Reserve_Loss__c,
                    LAE_Amount__c   =  PCLoop.Reserve_LAE__c,
                    Date__c         =  PCLoop.Report_Date__c,
                    Type__c         =  'Open Reserve',
                    RecordTypeId    =  ReserveRTID) );
                   }
                
            }
            Try{
                If(PCDLst.size()>0){
                    Database.insert(PCDLst);    
                }
               
            }
            catch(DmlException e) {
                System.debug('Error: ' + e.getMessage());  
            }            
        }
    }
    
    // Update Checks box for Incedent , Claim and Suit     
    Public static void UpdateClaimCheck(List<Policy_Claim__c> PClaimData){
        For(Policy_Claim__c PolicyClaimData : PClaimData ){
            If(PolicyClaimData.File_Type__c=='Incident' && !PolicyClaimData.Incident__c){
                PolicyClaimData.Incident__c = true;
                PolicyClaimData.Incident_Date__c = system.Date.today();
            }
            If(PolicyClaimData.File_Type__c=='Claim' && !PolicyClaimData.Claim__c){
                PolicyClaimData.Claim__c = true;
                PolicyClaimData.Claim_Date__c = system.Date.today();                
            }
            If(PolicyClaimData.File_Type__c=='Suit' && !PolicyClaimData.Suit__c){
                PolicyClaimData.Suit__c = true;
                PolicyClaimData.Suit_Date__c = system.Date.today();                
            }

        }
    }
    
    // Update Policy information on Claim
    Public static void UpdatePolicyInfoOnClaim(List<Policy_Claim__c> PClaimData){
        Set<ID> PolicyDataSet = new Set<ID>();
        For(Policy_Claim__c PolicyClaimData : PClaimData ){
            PolicyDataSet.add(PolicyClaimData.Policy__c);
        }
        Map<ID,Policy__c> PolicyDataMap = new Map<ID,Policy__c>([select 
                                                                 Limit__c, Deductible_ID__c, Deductible_Amount__c, Per_Claim_Limit__c,
                                                                 Aggregate_Limit__c,Effective_Date__c,Expiration_Date__c,ERE_Date__c,
                                                                 Mini_Tail_Override_Date__c,Cancel_Date__c,Per_Claim_Deductible_Amount__c,Account__r.Name
                                                                 from Policy__c 
                                                                 where id in :PolicyDataSet ]);
        
        
        For(Policy_Claim__c PolicyClaimData : PClaimData ){
            
            PolicyClaimData.Policy_Limit_ID__c      = PolicyDataMap.get(PolicyClaimData.Policy__c).Limit__c;
            PolicyClaimData.Policy_Deductible__c    = PolicyDataMap.get(PolicyClaimData.Policy__c).Deductible_ID__c;
            PolicyClaimData.Per_Claim_Deductible__c = PolicyDataMap.get(PolicyClaimData.Policy__c).Per_Claim_Deductible_Amount__c;
            PolicyClaimData.Per_Claim_Limit__c      = PolicyDataMap.get(PolicyClaimData.Policy__c).Per_Claim_Limit__c;
            PolicyClaimData.Aggregate_Limit__c      = PolicyDataMap.get(PolicyClaimData.Policy__c).Aggregate_Limit__c;
            PolicyClaimData.Policy_Effective_Date__c= PolicyDataMap.get(PolicyClaimData.Policy__c).Effective_Date__c;
            PolicyClaimData.Policy_Expire_Date__c   = PolicyDataMap.get(PolicyClaimData.Policy__c).Expiration_Date__c;
            PolicyClaimData.Policy_ERE_Date__c      = PolicyDataMap.get(PolicyClaimData.Policy__c).ERE_Date__c;
            PolicyClaimData.Policy_Mini_Tail_Date__c= PolicyDataMap.get(PolicyClaimData.Policy__c).Mini_Tail_Override_Date__c;
            PolicyClaimData.Policy_Cancel_Date__c   = PolicyDataMap.get(PolicyClaimData.Policy__c).Cancel_Date__c;       
            
            PolicyClaimData.Claim_Firm_Name__c = PolicyDataMap.get(PolicyClaimData.Policy__c).Account__r.Name;  
            system.debug('effective'+PolicyClaimData.Policy__r.Effective_Date__c);
            system.debug('pcdata:'+PolicyClaimData.Policy_Effective_Date__c);
            
        }
    }
    
    // Update Deductible LAE limit on Claim    
    Public static void UpdateCustomSettingInfoOnClaim(List<Policy_Claim__c> PClaimData){
        Claim_Setting__c ObjClaimSetting = [select Deductible_LAE_Applied_After__c from Claim_Setting__c limit 1];        
        For(Policy_Claim__c PolicyClaimData : PClaimData ){            
            PolicyClaimData.Deductible_LAE_Applied_Limit__c      = ObjClaimSetting.Deductible_LAE_Applied_After__c;       
          //  system.debug('Newcheck '+PolicyClaimData.Deductible_LAE_Applied_Limit__c);            
        }
    }
    
    public static void InsertReserveRecord(Map<Id,Policy_Claim__c> oldItems, Map<Id,Policy_Claim__c> newItems) {
        List<Policy_Claim_Detail__c> PCDLst = new List<Policy_Claim_Detail__c>();
        for(Policy_Claim__c claim : newItems.values()){
            if(claim.Claim_Status__c !='Closed'){
                /*if(claim.Claim_Status__c!=oldItems.get(claim.id).Claim_Status__c){
                    PCDLst.add(new Policy_Claim_Detail__c(
                        Policy_Claim__c = claim.ID,
                        Loss_Amount__c  = claim.Reserve_Loss__c - Math.abs(claim.GL_5000__c),
                        LAE_Amount__c   =  claim.Reserve_LAE__c - Math.abs(claim.GL_5030__c),
                        Date__c         =  System.today(),
                        Type__c         =  'Reopen Reserve',
                        RecordTypeId    =  ReserveRTID) );
                }else */ //if((claim.Reserve_Loss__c!=oldItems.get(claim.id).Reserve_Loss__c && claim.Reserve_Loss__c!= claim.Unpaid_Reserves_Direct_Loss__c) || (claim.Reserve_LAE__c!=oldItems.get(claim.id).Reserve_LAE__c && claim.Reserve_LAE__c!=claim.Unpaid_Reserves_Direct_LAE__c)){
                if((claim.Reserve_Loss__c!=oldItems.get(claim.id).Reserve_Loss__c) || (claim.Reserve_LAE__c!=oldItems.get(claim.id).Reserve_LAE__c)){
                    Decimal reserveLoss = claim.GL_5010__c;
                    Decimal reserveLae = claim.GL_5035__c;
                    if(claim.Reserve_Loss__c!=oldItems.get(claim.id).Reserve_Loss__c){
                        PCDLst.add(new Policy_Claim_Detail__c(
                        Policy_Claim__c = claim.ID,
                        Loss_Amount__c  = claim.Reserve_Loss__c,
                        Date__c         =  (QuickClaimController.transDate == null ? System.today() : QuickClaimController.transDate),
                        Type__c         =  'User Reserve',
                        RecordTypeId    =  ReserveRTID) );
                        reserveLoss += claim.Reserve_Loss__c;
                    }
                    if(claim.Reserve_LAE__c!=oldItems.get(claim.id).Reserve_LAE__c){
                        PCDLst.add(new Policy_Claim_Detail__c(
                        Policy_Claim__c = claim.ID,
                        LAE_Amount__c   =  claim.Reserve_LAE__c,
                        Date__c         =  (QuickClaimController.transDate == null ? System.today() : QuickClaimController.transDate),
                        Type__c         =  'User Reserve',
                        RecordTypeId    =  ReserveRTID) );
                        reserveLae += claim.Reserve_LAE__c;
                    }
                    
                    
                    Decimal cededLoss = 0 ;
                    Decimal cededLAE = 0 ;
                    
                    if(( reserveLoss + reserveLae) >= (claim.Ceded_Cutoff_Amount__c + claim.Per_Claim_Deductible__c)){
                        Decimal lossProRata = (claim.GL_5000__c + reserveLoss) / ( reserveLoss + reserveLae);
                        Decimal laeProRata = 1 - lossProRata;
                        Decimal totalCeded = (claim.Ceded_Cutoff_Amount__c + claim.Per_Claim_Deductible__c) - ( reserveLoss + reserveLae);
                        cededLoss = totalCeded * lossProRata;
                        cededLAE = totalCeded * laeProRata;
                        
                        cededLoss = cededLoss - claim.GL_2120__c;
                        cededLAE = cededLAE - claim.GL_2160__c;
                        
                    }else if(( oldItems.get(claim.id).Reserve_Loss__c + oldItems.get(claim.id).Reserve_LAE__c) >= (claim.Ceded_Cutoff_Amount__c + claim.Per_Claim_Deductible__c)){
                        cededLoss = - claim.GL_2120__c;
                        cededLAE = - claim.GL_2160__c;
                    }
                    
                    /*if(cededLoss != 0){
                        PCDLst.add(new Policy_Claim_Detail__c(
                            Policy_Claim__c = claim.ID,
                            //Reinsurance_Amount__c  = (claim.Reserve_Loss__c - oldItems.get(claim.id).Reserve_Loss__c)==0?null:(claim.Reserve_Loss__c - oldItems.get(claim.id).Reserve_Loss__c),
                            Reinsurance_Amount__c  = cededLoss,
                            Date__c         =  (QuickClaimController.transDate == null ? System.today() : QuickClaimController.transDate),
                            Type__c         =  'Change in Ceded Loss Reserve',
                            RecordTypeId    =  ReinsuranceRTID) );
                    }
                    if(cededLAE != 0){
                        PCDLst.add(new Policy_Claim_Detail__c(
                            Policy_Claim__c = claim.ID,
                            //Reinsurance_Amount__c   =  (claim.Reserve_LAE__c - oldItems.get(claim.id).Reserve_LAE__c)==0?null:(claim.Reserve_LAE__c - oldItems.get(claim.id).Reserve_LAE__c),
                            Reinsurance_Amount__c   =  cededLAE,
                            Date__c         =  (QuickClaimController.transDate == null ? System.today() : QuickClaimController.transDate),
                            Type__c         =  'Change in Ceded LAE Reserve',
                            RecordTypeId    =  ReinsuranceRTID) );
                    }*/
                }
            }/*else if(claim.Claim_Status__c=='Closed'){
                if(claim.Claim_Status__c!=oldItems.get(claim.id).Claim_Status__c){
                    PCDLst.add(new Policy_Claim_Detail__c(
                        Policy_Claim__c = claim.ID,
                        Loss_Amount__c  = - claim.Unpaid_Reserves_Direct_Loss__c,
                        LAE_Amount__c   =  - claim.Unpaid_Reserves_Direct_LAE__c,
                        Date__c         =  System.today(),
                        Type__c         =  'Close Reserve',
                        RecordTypeId    =  ReserveRTID) );
                }
            }*/
        }
        Try{
            If(PCDLst.size()>0){
                Database.insert(PCDLst);    
            }
            
        }
        catch(DmlException e) {
            System.debug('Error: ' + e.getMessage());  
        }   
    }
    
    public static void UpdateScheduleDate(List<Policy_Claim__c> PClaimData){
        Set<Id> policyIds = new Set<Id>();
        for(Policy_Claim__c claim : PClaimData){
            if(claim.Schedule_Date__c == null){
                policyIds.add(claim.Policy__c);
            }
        }
        Map<Id,Policy__c> policyMap = new Map<Id,Policy__c>([select id,ERE_Date__c,Expiration_Date__c,Effective_Date__c,RecordType.Name from Policy__c where id in:policyIds ]);
        for(Policy_Claim__c claim : PClaimData){
            if(claim.Schedule_Date__c == null && policyMap.containsKey(claim.Policy__c)){
                if(policyMap.get(claim.Policy__c).RecordType.Name == 'ERP Policy'){
                    claim.Schedule_Date__c = policyMap.get(claim.Policy__c).Effective_Date__c;
                    claim.Schedule_ERE__c = true;
                }else if(claim.Report_Date__c > policyMap.get(claim.Policy__c).Expiration_Date__c.addDays(60) && policyMap.get(claim.Policy__c).ERE_Date__c!=null && claim.Report_Date__c < policyMap.get(claim.Policy__c).ERE_Date__c){
                    claim.Schedule_Date__c = policyMap.get(claim.Policy__c).Effective_Date__c;
                    claim.Schedule_ERE__c = true;
                }else{
                    claim.Schedule_Date__c = claim.Report_Date__c;
                    claim.Schedule_ERE__c = false;
                }
            }
        }
    }
    
    public static void createFollowUpTasks(list<Policy_Claim__c> PClaimData){
        List<Task> tasksList = new List<Task>();
        for(Policy_Claim__c claim : PClaimData){
            if(claim.Follow_up_Date__c!=null){
                tasksList.add(new Task(OwnerId=(claim.Claim_Handler_Lookup__c==null?claim.CreatedById:claim.Claim_Handler_Lookup__c),Subject='Follow Up Task',ActivityDate=claim.Follow_up_Date__c,Description='Follow Up',WhatId=claim.Id,Status='In Progress'));
            }
        }
        if(tasksList.size()>0){
            insert tasksList;
        }
    }
    
    public static void validateClaimPolicy(List<Policy_Claim__c> PClaimData){
        Set<Id> policyIds = new Set<Id>();
        for(Policy_Claim__c claim : PClaimData){
            if(claim.Policy__c!=null){
                policyIds.add(claim.Policy__c);
            }
        }
        Map<Id,Profile> profilesMap = new Map<Id,Profile>([select id from Profile where Id =: UserInfo.getProfileId() and Name = 'System Administrator']);
        if(profilesMap.isEmpty()){
            Map<Id,Policy__c> policyMap = new Map<Id,Policy__c>([select id,Effective_Date__c,Expiration_Date__c,RecordType.Name,ERE_Date__c,Cancel_Date__c from Policy__c where id in: policyIds]);
            for(Policy_Claim__c claim : PClaimData){
                if(claim.Policy__c!=null && policyMap.containsKey(claim.Policy__c)){
                    Policy__c policy = policyMap.get(claim.Policy__c);
                    if(policy.RecordType.Name == 'Application' || (policy.ERE_Date__c==null && policy.Cancel_Date__c!=null && policy.Cancel_Date__c.addDays(90) < System.today()) || (policy.ERE_Date__c!=null && policy.ERE_Date__c.addDays(90) < System.today()) || (policy.ERE_Date__c==null && policy.Expiration_Date__c!=null && policy.Expiration_Date__c.addDays(90) < System.today())){
                        claim.addError('Claim must be filed against an active policy or must be within 90 days of cancel/expiration date of the policy');
                    }
                }
            }
        }
    }
    
    
}