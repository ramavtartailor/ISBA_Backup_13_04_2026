public with sharing class QuickClaimController {
    public static Date transDate;
    @AuraEnabled
    public static Policy_Claim__c getClaim(Id claimId) {
        // Perform isAccessible() checks here
        return [SELECT Id,Name,Policy__c,Policy__r.Account__c,Unpaid_Reserves_Direct_Loss__c,Claim_Status__c,
                Unpaid_Reserves_Direct_LAE__c,Payment_Direct_Loss__c,Payment_Direct_LAE__c,Incurred_Direct_Loss__c,Incurred_Direct_LAE__c,
                Reserve_Loss__c,Reserve_LAE__c,GL_2100__c,GL_2140__c,GL_5000__c,GL_5030__c,GL_5050__c,GL_5060__c,Ceded_Cutoff_Amount__c,Per_Claim_Deductible__c,GL_2120__c,GL_2160__c,GL_5010__c,GL_5035__c, Policy_Remaining_By_All_Claims__c  FROM Policy_Claim__c WHERE Id = :claimId];
    }
    @AuraEnabled
    public static String updateReserve(Decimal lossReserve,Decimal laeReserve,Policy_Claim__c claim,Date transactionDate) {
        try{
            if(transactionDate == null){
                system.debug('---ex------');
                throw new AuraHandledException('Invalid Transaction Date!');
            }
            transDate = transactionDate;
            Date startDate = transactionDate.toStartOfMonth();
            Date endDate = startDate.addMonths(1).addDays(-1);
     // Validate accounting period 
            List<AcctSeed__Accounting_Period__c> periods = [Select ID from AcctSeed__Accounting_Period__c where AcctSeed__Status__c = 'Open' 
                                                            and AcctSeed__Start_Date__c = :startDate AND AcctSeed__End_Date__C = :endDate];
            
            if(periods.size() == 0) throw new AuraHandledException('Accounting period not open for transaction!');
            
            System.debug(claim.Reserve_Loss__c);
            
            //claim.Reserve_Loss__c = claim.Reserve_Loss__c + (lossReserve - Math.abs(claim.GL_2100__c));
            
            //Decimal changeLossReserve =  (lossReserve - (Math.abs(claim.GL_5010__c) + Math.abs(claim.GL_5000__c)));
            Decimal changeLossReserve =  (lossReserve - (claim.GL_5010__c + claim.GL_5000__c));
            
            if(lossReserve - claim.GL_5000__c < 0){
                String str = 'Claim Loss Reserve Can not be in negative.';
                AuraHandledException auraEx = new AuraHandledException(str);
                auraEx.setMessage(str);
                throw auraEx;
            }
            
            //claim.Reserve_LAE__c = claim.Reserve_LAE__c + (laeReserve - Math.abs(claim.GL_2140__c));
            //Decimal changeLAEReserve = (laeReserve - (Math.abs(claim.GL_5035__c) + Math.abs(claim.GL_5030__c)));
            Decimal changeLAEReserve = (laeReserve - (claim.GL_5035__c + claim.GL_5030__c));
            
            if(laeReserve - claim.GL_5030__c < 0){
                String str = 'Claim LAE Reserve Can not be in negative.';
                AuraHandledException auraEx = new AuraHandledException(str);
                auraEx.setMessage(str);
                throw auraEx;
            }
            System.debug(changeLossReserve);
            System.debug(changeLAEReserve);
            System.debug(claim.Policy_Remaining_By_All_Claims__c);
            if(changeLossReserve + changeLAEReserve > claim.Policy_Remaining_By_All_Claims__c){
                throw new AuraHandledException('Loss Incurred and LAE Incurred cannot exceed policy limit.');
            }
            
            //upsert claim;
            
            List<Policy_Claim_Detail__c> PCDLst = new List<Policy_Claim_Detail__c>();
            if(changeLossReserve != 0 || changeLAEReserve != 0){
                Decimal reserveLoss = claim.GL_5010__c;
                Decimal reserveLae = claim.GL_5035__c;
                if(changeLossReserve != 0){
                    PCDLst.add(new Policy_Claim_Detail__c(
                        Policy_Claim__c = claim.ID,
                        Loss_Amount__c  = changeLossReserve,
                        Date__c         =  transactionDate,
                        Type__c         =  'User Reserve',
                        RecordTypeId    =  Policy_Claim_Gateway.ReserveRTID) );
                    reserveLoss += changeLossReserve;
                }
                if(changeLAEReserve != 0){
                    PCDLst.add(new Policy_Claim_Detail__c(
                        Policy_Claim__c = claim.ID,
                        LAE_Amount__c   =  changeLAEReserve,
                        Date__c         =  transactionDate,
                        Type__c         =  'User Reserve',
                        RecordTypeId    =  Policy_Claim_Gateway.ReserveRTID) );
                    reserveLae += changeLAEReserve;
                }
                
                
                Decimal cededLoss = 0 ;
                Decimal cededLAE = 0 ;
                
                if(( reserveLoss + reserveLae) >= ((claim.Ceded_Cutoff_Amount__c !=null ? claim.Ceded_Cutoff_Amount__c : 0) + (claim.Per_Claim_Deductible__c !=null ? claim.Per_Claim_Deductible__c : 0))){
                    Decimal lossProRata = (claim.GL_5000__c + reserveLoss) / ( reserveLoss + reserveLae);
                    Decimal laeProRata = 1 - lossProRata;
                    Decimal totalCeded = ((claim.Ceded_Cutoff_Amount__c !=null ? claim.Ceded_Cutoff_Amount__c : 0) + (claim.Per_Claim_Deductible__c !=null ? claim.Per_Claim_Deductible__c : 0)) - ( reserveLoss + reserveLae);
                    cededLoss = totalCeded * lossProRata;
                    cededLAE = totalCeded * laeProRata;
                    
                    cededLoss = cededLoss - claim.GL_2120__c;
                    cededLAE = cededLAE - claim.GL_2160__c;
                    
                }else if(( claim.GL_5010__c + claim.GL_5035__c) >= ((claim.Ceded_Cutoff_Amount__c !=null ? claim.Ceded_Cutoff_Amount__c : 0) + (claim.Per_Claim_Deductible__c !=null ? claim.Per_Claim_Deductible__c : 0))){
                    cededLoss = - claim.GL_2120__c;
                    cededLAE = - claim.GL_2160__c;
                }
                
                if(cededLoss != 0){
                    PCDLst.add(new Policy_Claim_Detail__c(
                        Policy_Claim__c = claim.ID,
                        //Reinsurance_Amount__c  = (claim.Reserve_Loss__c - oldItems.get(claim.id).Reserve_Loss__c)==0?null:(claim.Reserve_Loss__c - oldItems.get(claim.id).Reserve_Loss__c),
                        Reinsurance_Amount__c  = cededLoss,
                        Date__c         =  transactionDate,
                        Type__c         =  'Change in Ceded Loss Reserve',
                        RecordTypeId    =  Policy_Claim_Gateway.ReinsuranceRTID) );
                }
                if(cededLAE != 0){
                    PCDLst.add(new Policy_Claim_Detail__c(
                        Policy_Claim__c = claim.ID,
                        //Reinsurance_Amount__c   =  (claim.Reserve_LAE__c - oldItems.get(claim.id).Reserve_LAE__c)==0?null:(claim.Reserve_LAE__c - oldItems.get(claim.id).Reserve_LAE__c),
                        Reinsurance_Amount__c   =  cededLAE,
                        Date__c         =  transactionDate,
                        Type__c         =  'Change in Ceded LAE Reserve',
                        RecordTypeId    =  Policy_Claim_Gateway.ReinsuranceRTID) );
                }
            }
            
            If(PCDLst.size()>0){
                Database.insert(PCDLst);    
            }
            
            Policy_Claim__c claimObj = [SELECT Id, Incurred_Total__c,Incurred_Email_Send__c FROM Policy_Claim__c WHERE Id=:claim.Id];
            if(!claimObj.Incurred_Email_Send__c && claimObj.Incurred_Total__c >= 250000){
                Boolean success = sendEmailAlert(new Set<String>{claimObj.Id}, 'Incurred_Total_alert_email');
                if(success){
                    claimObj.Incurred_Email_Send__c = true;
                    update claimObj;
                }
            }
            else if(claimObj.Incurred_Total__c < 250000 && claimObj.Incurred_Email_Send__c){
                claimObj.Incurred_Email_Send__c = false;
                update claimObj;
            }
    
            return 'Success';
        }catch(Exception e){
            system.debug('---ex1------'+e);
            system.debug('---ex2------'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString()) ;
        }
    }
    
    @AuraEnabled
    public static void updateClaimSummary(Id claimId){
        try{
            Policy_Claim__c claim = new Policy_Claim__c(Id=claimId);
            Batch_MassUpdateClaimSummary claimSummary = new Batch_MassUpdateClaimSummary();
            claimSummary.updateClaimSummary(new Policy_Claim__c[]{claim});
        }catch(Exception e){
            system.debug('---ex1------'+e);
            system.debug('---ex2------'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString()) ;
        }
    }
    
    public static Boolean sendEmailAlert(Set<String> recIds , String emailTemplateName){
        if(String.isNotBlank(label.Claim_Email_Alert_send_to_email)){ 
            
            List<EmailTemplate> templateList = [SELECT Id FROM EmailTemplate WHERE DeveloperName =:emailTemplateName LIMIT 1];
            if(!templateList.isEmpty()){
                List<string> toAddress = new List<string>();
                toAddress.add(label.Claim_Email_Alert_send_to_email);
                
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                for(String recId : recIds){
                    Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateList[0].Id,userInfo.getUserId() ,recId);
                    Messaging.SingleEmailMessage mailTOSend = new Messaging.SingleEmailMessage();
                    
                    mailTOSend.setToAddresses(toAddress);
                    mailTOSend.setSubject(mail.getSubject());
                    mailTOSend.setHtmlBody(mail.getHtmlBody());
                    mailTOSend.setOrgWideEmailAddressId([select Id,Address from OrgWideEmailAddress where Address ='claims@isbamutual.com'].Id);
                    mailTOSend.setSaveAsActivity(false);
                    allmsg.add(mailTOSend);
                }
                try {
                    Messaging.SendEmailResult [] r = Messaging.sendEmail(allmsg);
                    system.debug(r[0]);
                    return r[0].isSuccess();
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }
            }
        }  
        return false;
    }
}