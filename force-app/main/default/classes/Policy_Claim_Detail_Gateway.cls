public class Policy_Claim_Detail_Gateway {
/*
//Created By	: 	Shoukat Hussain
//Created Date	: 	12/28/2016
//Purpose		: 	Create Accounting Seeds Transaction
//				:	Create Auto Dedcutible entries
*/

    
    // Public static record type
    public static ID ReserveRTID 	= Schema.SObjectType.Policy_Claim_Detail__C.getRecordTypeInfosByName().get('Reserve').getRecordTypeId();
    public static ID DeductibleRTID = Schema.SObjectType.Policy_Claim_Detail__C.getRecordTypeInfosByName().get('Deductible').getRecordTypeId();

    public static void CreateAutoDedcutibleRecord(list<Policy_Claim_Detail__c> PCDData){
        Set<ID> PolicyClaimID = new Set<ID>();
        List<Policy_Claim_Detail__c> PolicyClaimDtlLst = new List<Policy_Claim_Detail__c>();
        List<Policy_Claim_Detail__c> PolicyClaimDtlLstToUpdate = new List<Policy_Claim_Detail__c>();
        // map are for maintain or get information from master claim 
        Map<ID,Decimal> PerClaimDeductible_Map = new Map<ID,Decimal>();
        Map<ID,Decimal> PerClaimDeductibleConsumed_Map = new Map<ID,Decimal>();
        Map<ID,Decimal> DedLAEAppliedISBALimit_Map = new Map<ID,Decimal>();        
        Map<ID,Decimal> DedLAEAppliedISBALimitConsumed_Map =  new Map<ID,Decimal>();
        Map<Id,Policy_Claim__c> claimMap = new Map<Id,Policy_Claim__c>();
        List<Policy_Claim__c> PolicyClaim_Lst = new List<Policy_Claim__c>();
		
        For(Policy_Claim_Detail__c PCDLoop : PCDData){
            PolicyClaimID.add(PCDLoop.Policy_Claim__c);
        }
        
        //Get LAE/Loss Consumed amount and put into Map
        If(PolicyClaimID.size()>0){
            PolicyClaim_Lst = [select ID,Per_Claim_Deductible__c,GL_5031__c,GL_5001__c,GL_5030__c,
                               Deductible_LAE_Applied_Limit__c,Deductible_LAE_Applied_Limit_Consumed__c 
                               from Policy_Claim__C where ID in :PolicyClaimID];
            If(PolicyClaim_Lst.size()>0){
                For(Policy_Claim__c PCdata :PolicyClaim_Lst){
                    PerClaimDeductible_Map.put(PCdata.ID, PCdata.Per_Claim_Deductible__c);
                    PerClaimDeductibleConsumed_Map.put(PCdata.ID,PCdata.GL_5031__c+PCdata.GL_5001__c);
                    //DedLAEAppliedISBALimit_Map.put(PCdata.ID,PCdata.Deductible_LAE_Applied_Limit__c);
                    DedLAEAppliedISBALimit_Map.put(PCdata.ID,Math.abs(PCdata.GL_5030__c));
                    DedLAEAppliedISBALimitConsumed_Map.put(PCdata.ID,PCdata.Deductible_LAE_Applied_Limit_Consumed__c);
                    claimMap.put(PCdata.ID,PCdata);
                }
            }
        }

        // Create Auto record 
        For(Policy_Claim_Detail__c PCDDataLoop : PCDData){  
            System.debug('$1Policy_Claim__c)'+PerClaimDeductible_Map.get(PCDDataLoop.Policy_Claim__c));
             System.debug('$2Policy_Claim__c)'+ PerClaimDeductibleConsumed_Map.get(PCDDataLoop.Policy_Claim__c));
            Decimal PerClaimDedBalance 		=  PerClaimDeductible_Map.get(PCDDataLoop.Policy_Claim__c)  - PerClaimDeductibleConsumed_Map.get(PCDDataLoop.Policy_Claim__c) ;
            Decimal DedAppliedLAEBalance  	=  DedLAEAppliedISBALimit_Map.get(PCDDataLoop.Policy_Claim__c)  - claimMap.get(PCDDataLoop.Policy_Claim__c).GL_5031__c;
            if(DedAppliedLAEBalance < 0){
                DedAppliedLAEBalance = 0;
            }
            Decimal Loss_Amt_2b_CreateRcd = 0;
            Decimal LAE_Amt_2b_CreateRcd = 0;
            Decimal LAE_AmtISBAExp_2b_CreateRcd = 0;
            // In case of Loss payment auto deductible record will be generate with respect to " balance available"
            // In case balance available then create record auto, otherwise we can not create auto record 
            If(PCDDataLoop.Type__c=='Loss Payment'){                
                If(PerClaimDedBalance > 0){ 
                    System.debug('PerClaimDedBalance---'+PerClaimDedBalance);
                    // incase balance is enough for payment then fully amount will be deductible.
                    If(PerClaimDedBalance >= PCDDataLoop.Loss_Amount__c) {
                        Loss_Amt_2b_CreateRcd =   PCDDataLoop.Loss_Amount__c;
                    System.debug('@If--Loss_Amt_2b_CreateRcd=====>'+Loss_Amt_2b_CreateRcd);     
                    }
                    // incase balance is not enough for payment then available amount will be deductible.
                    Else If(PerClaimDedBalance < PCDDataLoop.Loss_Amount__c){
                        Loss_Amt_2b_CreateRcd =   PerClaimDedBalance;  
                        System.debug('@Else--Loss_Amt_2b_CreateRcd=====>'+Loss_Amt_2b_CreateRcd);
                    }
                    Else{
                        //nothing
                    }                    
                    // Update Map for consumed and Create Entry for deductible
                    If (Loss_Amt_2b_CreateRcd<>0){
                        System.debug('@Loss_Amt_2b_CreateRcd=====>'+Loss_Amt_2b_CreateRcd);
                        PerClaimDeductibleConsumed_Map.put(PCDDataLoop.Policy_Claim__c, PerClaimDeductibleConsumed_Map.get(PCDDataLoop.Policy_Claim__c) + Loss_Amt_2b_CreateRcd);
                        // Create Entry For Loss                        
                        PolicyClaimDtlLst.add(  new Policy_Claim_Detail__c(
                                                    Policy_Claim__c = PCDDataLoop.Policy_claim__c,
                                                    Loss_Amount__c	= Loss_Amt_2b_CreateRcd,
                                                    Date__c			= PCDDataLoop.Date__c,
                                                    Type__c			= 'Deductible Loss',
                                                    RecordTypeId	=  DeductibleRTID) );
                        
                        PolicyClaimDtlLstToUpdate.add(new Policy_Claim_Detail__c(
                                                    Id = PCDDataLoop.Id,
                                                    Total_Deductible_Used__c	= Loss_Amt_2b_CreateRcd) );

                   	}
                }                
            } 

            // In case of LAE payment auto deductible record will be generate with respect to " balance available"
            // In case balance available then create record auto, otherwise we can not create auto record 
            If(PCDDataLoop.Type__c=='LAE Payment'){                
                // Incase not balance is available in DeductibleLAEIBSABalance then system will use Per claim deductible balance
                system.debug('AutoDed DedAppliedLAEBalance : '+DedAppliedLAEBalance);
                If(DedAppliedLAEBalance >= 0){ 
                     system.debug('AutoDed DedAppliedLAEBalance>=0 : '+DedAppliedLAEBalance);
                    // incase balance is enough for payment then fully amount will be deductible.
                    If(DedAppliedLAEBalance >= PCDDataLoop.LAE_Amount__c) {
                        LAE_AmtISBAExp_2b_CreateRcd =   PCDDataLoop.LAE_Amount__c;
                        // Update Map and create entry
                        DedLAEAppliedISBALimit_Map.put(PCDDataLoop.Policy_Claim__c, DedLAEAppliedISBALimit_Map.get(PCDDataLoop.Policy_Claim__c) + LAE_AmtISBAExp_2b_CreateRcd);
                        // Create Entry For LAE                        
                        PolicyClaimDtlLst.add(  new Policy_Claim_Detail__c(
                            Policy_Claim__c = PCDDataLoop.Policy_claim__c,
                            LAE_Amount__c	= LAE_AmtISBAExp_2b_CreateRcd,
                            Date__c			= PCDDataLoop.Date__c,
                            Type__c			= 'Deductible Expense New',
                            RecordTypeId	=  DeductibleRTID) );
                        
                    }
                    // incase balance is not enough for payment then available amount will be deductible.
                    Else If(DedAppliedLAEBalance < PCDDataLoop.LAE_Amount__c){
                        system.debug('AutoDed DedAppliedLAEBalance<lae amt : '+PCDDataLoop.LAE_Amount__c);
                        LAE_AmtISBAExp_2b_CreateRcd =   DedAppliedLAEBalance;
                        // Update Map for consumed and Create Entry for deductible
                        If (LAE_AmtISBAExp_2b_CreateRcd<>0){
                            DedLAEAppliedISBALimit_Map.put(PCDDataLoop.Policy_Claim__c, DedLAEAppliedISBALimit_Map.get(PCDDataLoop.Policy_Claim__c) + LAE_AmtISBAExp_2b_CreateRcd);
                            // Create Entry For LAE                        
                            PolicyClaimDtlLst.add(  new Policy_Claim_Detail__c(
                                Policy_Claim__c = PCDDataLoop.Policy_claim__c,
                                LAE_Amount__c	= LAE_AmtISBAExp_2b_CreateRcd,
                                Date__c			= PCDDataLoop.Date__c,
                                Type__c			= 'Deductible Expense New',
                                RecordTypeId	=  DeductibleRTID) );
                        }

                        // Get further payment amount by ISBA 
                        Decimal  RemLAEAmt_2b_pay = PCDDataLoop.LAE_Amount__c - LAE_AmtISBAExp_2b_CreateRcd;
                        system.debug('AutoDed RemLAEAmt_2b_pay : '+RemLAEAmt_2b_pay);
                        ///////////////////                        
                        // Incase balance is not available in DeductibleLAEIBSABalance then system will use Per claim deductible balance
                        system.debug('AutoDed1 PerClaimDedBalance>0 : '+PerClaimDedBalance);
                        If(PerClaimDedBalance > 0){                             
                            // incase balance is enough for payment then fully amount will be deductible.
                            system.debug('AutoDed2 PerClaimDedBalance>=RemLAEAmt_2b_pay : '+RemLAEAmt_2b_pay);
                            If(PerClaimDedBalance >= RemLAEAmt_2b_pay) {
                                system.debug('AutoDed3 PerClaimDedBalance>0 : '+PerClaimDedBalance);
                                LAE_Amt_2b_CreateRcd =   RemLAEAmt_2b_pay;
                            }
                            // incase balance is not enough for payment then available amount will be deductible.                            
                            Else If(PerClaimDedBalance < RemLAEAmt_2b_pay){
                                system.debug('AutoDed4 PerClaimDedBalance < RemLAEAmt_2b_pay : '+ RemLAEAmt_2b_pay);
                                LAE_Amt_2b_CreateRcd =   PerClaimDedBalance;   
                            }
                            Else{
                                //nothing
                                system.debug('AutoDed5');
                            }                    
                            // Update Map for consumed and Create Entry for deductible
                            If (LAE_Amt_2b_CreateRcd<>0){
                                PerClaimDeductibleConsumed_Map.put(PCDDataLoop.Policy_Claim__c, PerClaimDeductibleConsumed_Map.get(PCDDataLoop.Policy_Claim__c) + LAE_Amt_2b_CreateRcd);
                                // Create Entry For LAE                        
                                PolicyClaimDtlLst.add(  new Policy_Claim_Detail__c(
                                    Policy_Claim__c = PCDDataLoop.Policy_claim__c,
                                    LAE_Amount__c	= LAE_Amt_2b_CreateRcd,
                                    Date__c			= PCDDataLoop.Date__c,
                                    Type__c			= 'Deductible Expense',
                                    RecordTypeId	=  DeductibleRTID) );
                            }
                        }                
						
                    }
                }                
            }
            
            
        }     
        
        // Create Auto Record
            if(PolicyClaimDtlLst.size()>0){  
                System.debug('#PolicyClaimDtlLst===>'+PolicyClaimDtlLst);
             Insert(PolicyClaimDtlLst);
            }
        if(PolicyClaimDtlLstToUpdate.size()>0){
            update PolicyClaimDtlLstToUpdate;
        }     
   /*     
        Try{
            if(PolicyClaimDtlLst.size()>0){
             //Database.insert(PolicyClaimDtlLst);             
             Insert(PolicyClaimDtlLst);
            }
        }
        Catch(system.DmlException e){       	
            system.debug('Error: '+e.getMessage());
        }
*/
        
        
  }
        
    public static AS_Transaction__c Initiate_AS_entry(Policy_Claim_Detail__c PCDEntry){
         AS_Transaction__c AS_SingleEntry = new AS_Transaction__c();
        If(PCDEntry.Vendor__c!=null){
            AS_SingleEntry.Firm_Id__c = PCDEntry.Vendor__c;
        }
        Else{
            AS_SingleEntry.Firm_Id__c = PCDEntry.Account_ID__c;
        }

         AS_SingleEntry.Policy_Claim_Detail__c 	= PCDEntry.Id;
         AS_SingleEntry.Policy_Id__c 			= PCDEntry.Policy_record_id__c;
         AS_SingleEntry.Transaction_Type__c 	= PCDEntry.Type__c;
         AS_SingleEntry.Invoice_Number__c 		= PCDEntry.Invoice_Number__c;
         AS_SingleEntry.Claim_Id__c 			= PCDEntry.Policy_Claim__c;
        AS_SingleEntry.GL_Account_Name__c 			= PCDEntry.GL_Account_Name__c;

        Return AS_SingleEntry;
    }
    
    public static void CreateAccountingSeedsTransaction(list<Policy_Claim_Detail__c> PCDData){
      system.debug('CreateAccountingSeedsTransaction start procedure'+PCDData);
      List<AS_Transaction__c> lstASTransaction = new List<AS_Transaction__c>();
      For(Policy_Claim_Detail__C PCDLoopData : PCDData) {     
            //Initial object for Account Seeds (AS) 
            AS_Transaction__c asTransaction = new AS_Transaction__c(); 

            // Set AS transaction as per Claim File type and Claim detail type
            System.debug('PCDLoopData.Type__c;===>'+PCDLoopData.Type__c);
          System.debug('PCDLoopData.Loss_Amount__c;===>'+PCDLoopData.Loss_Amount__c);
            // Claim File Type "Reserve"
            If  (PCDLoopData.Type__c=='Open Reserve'){
               // no need "if condition" becuase open reserve should be create as per FW+ (Framework)
                               
               asTransaction = Initiate_AS_entry(PCDLoopData);           
               asTransaction.Transaction_Sub_Type__c = 'Open Reserve LAE';
               asTransaction.Amount__c = PCDLoopData.LAE_Amount__c;
               lstASTransaction.add(asTransaction);
               asTransaction = Initiate_AS_entry(PCDLoopData);            
               asTransaction.Transaction_Sub_Type__c = 'Open Reserve Loss';                
               asTransaction.Amount__c = PCDLoopData.Loss_Amount__c;
               lstASTransaction.add(asTransaction);     
               
            }Else if(PCDLoopData.Type__c=='User Reserve'){
               If(PCDLoopData.LAE_Amount__c!=null){
                    asTransaction = Initiate_AS_entry(PCDLoopData);            
                    asTransaction.Transaction_Sub_Type__c = 'User Reserve LAE';                
                    asTransaction.Amount__c = PCDLoopData.LAE_Amount__c;
                    lstASTransaction.add(asTransaction);                               
               }
               If(PCDLoopData.Loss_Amount__c!=null){

                    asTransaction = Initiate_AS_entry(PCDLoopData);            
                    asTransaction.Transaction_Sub_Type__c = 'User Reserve Loss';                
                    asTransaction.Amount__c = PCDLoopData.Loss_Amount__c;
                    lstASTransaction.add(asTransaction);                               
               }

            }Else if(PCDLoopData.Type__c=='Close Reserve'){

               If(PCDLoopData.LAE_Amount__c!=null){
                    asTransaction = Initiate_AS_entry(PCDLoopData);            
                    asTransaction.Transaction_Sub_Type__c = 'Close Reserve LAE';                
                    asTransaction.Amount__c = PCDLoopData.LAE_Amount__c;
                    lstASTransaction.add(asTransaction);                               
               }
               If(PCDLoopData.Loss_Amount__c!=null){
                    asTransaction = Initiate_AS_entry(PCDLoopData);            
                    asTransaction.Transaction_Sub_Type__c = 'Close Reserve Loss';                
                    asTransaction.Amount__c = PCDLoopData.Loss_Amount__c;
                    lstASTransaction.add(asTransaction);                               
               }

            }Else if(PCDLoopData.Type__c=='Reopen Reserve'){

               If(PCDLoopData.LAE_Amount__c!=null){
                    asTransaction = Initiate_AS_entry(PCDLoopData);            
                    asTransaction.Transaction_Sub_Type__c = 'Re-Open Reserve LAE';                
                    asTransaction.Amount__c = PCDLoopData.LAE_Amount__c;
                    lstASTransaction.add(asTransaction);                               
               }
               If(PCDLoopData.Loss_Amount__c!=null){
                    asTransaction = Initiate_AS_entry(PCDLoopData);            
                    asTransaction.Transaction_Sub_Type__c = 'Re-Open Reserve Loss';                
                    asTransaction.Amount__c = PCDLoopData.Loss_Amount__c;
                    lstASTransaction.add(asTransaction);                               
               }
                
            // Claim File Type "Claim Payment"
            }Else if(PCDLoopData.Type__c=='LAE Payment'){
                    asTransaction = Initiate_AS_entry(PCDLoopData);            
                    asTransaction.Transaction_Sub_Type__c = PCDLoopData.Type__c;                
                    asTransaction.Amount__c = PCDLoopData.LAE_Amount__c;
                    lstASTransaction.add(asTransaction);                               
                
            }Else if(PCDLoopData.Type__c=='Loss Payment'){
                asTransaction = Initiate_AS_entry(PCDLoopData);            
                asTransaction.Transaction_Sub_Type__c = PCDLoopData.Type__c;                
                asTransaction.Amount__c = PCDLoopData.Loss_Amount__c;
                lstASTransaction.add(asTransaction);                               

            }Else if(PCDLoopData.Type__c=='Deductible Expense'){
                asTransaction = Initiate_AS_entry(PCDLoopData);            
                asTransaction.Transaction_Sub_Type__c = 'LAE Deductible';                
                asTransaction.Amount__c = PCDLoopData.LAE_Amount__c;
                lstASTransaction.add(asTransaction);                               
            }Else if(PCDLoopData.Type__c=='Deductible Expense New'){
                asTransaction = Initiate_AS_entry(PCDLoopData);            
                asTransaction.Transaction_Sub_Type__c = 'Deductible Expense New';                
                asTransaction.Amount__c = PCDLoopData.LAE_Amount__c;
                lstASTransaction.add(asTransaction);                               
            }Else if(PCDLoopData.Type__c=='Deductible Loss'){
                asTransaction = Initiate_AS_entry(PCDLoopData);            
                asTransaction.Transaction_Sub_Type__c = 'Loss Deductible';                
                asTransaction.Amount__c = PCDLoopData.Loss_Amount__c;
                lstASTransaction.add(asTransaction);                               
            }
          /*  
          Else if(PCDLoopData.Type__c=='Cash Payment'){
                If(PCDLoopData.Reimburse_Amount__c!=null){
                    asTransaction = Initiate_AS_entry(PCDLoopData);            
                    asTransaction.Transaction_Sub_Type__c = 'The PrivateBank-Main';                
                    asTransaction.Amount__c = PCDLoopData.Reimburse_Amount__c;
                    lstASTransaction.add(asTransaction);                               
                    
                }
                Else if(PCDLoopData.Write_Off_Amount__c!=null){
                    asTransaction = Initiate_AS_entry(PCDLoopData);            
                    asTransaction.Transaction_Sub_Type__c = 'Other Income/Expense';                
                    asTransaction.Amount__c = PCDLoopData.Write_Off_Amount__c;
                    lstASTransaction.add(asTransaction);                               
                    
                }
            }
          */
          // Claim File Type "Reinsurance"
            Else if(PCDLoopData.Type__c=='Change in Ceded LAE Reserve'){
                    asTransaction = Initiate_AS_entry(PCDLoopData);            
                    asTransaction.Transaction_Sub_Type__c = 'Change in Ceded LAE Reserve';                
                    asTransaction.Amount__c = PCDLoopData.Reinsurance_Amount__c;
                    lstASTransaction.add(asTransaction); 
            }Else if(PCDLoopData.Type__c=='Change in Ceded Loss Reserve'){
                    asTransaction = Initiate_AS_entry(PCDLoopData);            
                    asTransaction.Transaction_Sub_Type__c = 'Change in Ceded Loss Reserve';                
                    asTransaction.Amount__c = PCDLoopData.Reinsurance_Amount__c;
                    lstASTransaction.add(asTransaction);                                              
            }Else if(PCDLoopData.Type__c=='Due from Reins. - LAE'){
                    asTransaction = Initiate_AS_entry(PCDLoopData);            
                    asTransaction.Transaction_Sub_Type__c = 'Reins. Recoverable-LAE';                
                    asTransaction.Amount__c = PCDLoopData.Reinsurance_Amount__c;
                    lstASTransaction.add(asTransaction);                                              
            }Else if(PCDLoopData.Type__c=='Due from Reins. - Loss'){
                    asTransaction = Initiate_AS_entry(PCDLoopData);            
                    asTransaction.Transaction_Sub_Type__c = 'Reins. Recoverable-Loss';                
                    asTransaction.Amount__c = PCDLoopData.Reinsurance_Amount__c;
                    lstASTransaction.add(asTransaction);                   
            // Type "Unallocated LAE Payment"
            }Else if(PCDLoopData.Type__c=='Unallocated LAE Payment'){
                    asTransaction = Initiate_AS_entry(PCDLoopData);            
                    asTransaction.Transaction_Sub_Type__c = 'Unallocated LAE Payment';                
                    asTransaction.Amount__c = PCDLoopData.LAE_Amount__c;
                    lstASTransaction.add(asTransaction);                   
            // Claim File Type "Unallocated LAE"
            }Else if(PCDLoopData.Type__c=='Claim Coverage - ARDC'){
                If(PCDLoopData.ISBA_First_Payment__c!=null){
                    asTransaction = Initiate_AS_entry(PCDLoopData);            
                    asTransaction.Transaction_Sub_Type__c = 'Claim Coverage - ARDC';                
                    asTransaction.Amount__c = PCDLoopData.ISBA_First_Payment__c;
                    lstASTransaction.add(asTransaction);                    
                }
                If(PCDLoopData.ISBA_Contribution__c!=null){
                    asTransaction = Initiate_AS_entry(PCDLoopData);            
                    asTransaction.Transaction_Sub_Type__c = 'Claim Coverage - ARDC';                
                    asTransaction.Amount__c = PCDLoopData.ISBA_Contribution__c;
                    lstASTransaction.add(asTransaction);                    
                }
               /* If(PCDLoopData.Lawyer_Contribution__c!=null){
                    asTransaction = Initiate_AS_entry(PCDLoopData);            
                    asTransaction.Transaction_Sub_Type__c = 'Claim Coverage - ARDC';                
                    asTransaction.Amount__c = PCDLoopData.Lawyer_Contribution__c;
                    lstASTransaction.add(asTransaction);                    
                }*/

            }Else{               
            }           
      }
        Try{
            if(lstASTransaction.size()>0){
             system.debug('start insertion of AS-->'+lstASTransaction);
             Database.insert(lstASTransaction);
            }
        }
        Catch(system.DmlException e){
            system.debug('Error: '+e.getMessage());
            system.debug('Error Line : '+e.getLineNumber());
        }
  }
}