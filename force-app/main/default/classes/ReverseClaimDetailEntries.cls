public class ReverseClaimDetailEntries {
	@AuraEnabled
    public static void checkRefundEligibility(String recordId){
        SavePoint sp = Database.setSavepoint();
        try{
            Policy_Claim_Detail__c detail = [SELECT Id,RecordType.Name,Policy_Claim__c,RecordTypeId,Date__c,Vendor__c,
                                             LAE_Amount__c,Loss_Amount__c,ISBA_First_Payment__c,Type__c 
                                             FROM Policy_Claim_Detail__c 
                                             WHERE Id=: recordId];
            Date startDate = System.Date.today().toStartOfMonth();
            Date endDate = startDate.addMonths(1).addDays(-1);
            System.debug('detail======>'+detail);
            // Validate accounting period 
            List<AcctSeed__Accounting_Period__c> periods = [Select ID from AcctSeed__Accounting_Period__c where AcctSeed__Status__c = 'Open' 
                                                            and AcctSeed__Start_Date__c = :startDate AND AcctSeed__End_Date__C = :endDate];
            System.debug('periods---'+periods);
            if(periods.size() == 0) 
                throw new AuraHandledException('Accounting period not open for reversal!');
            System.debug('detail----'+detail.Type__c);
            System.debug('detail----'+detail.LAE_Amount__c);
            if(detail.RecordType.Name == 'Claim Payment' || detail.RecordType.Name == 'Unallocated LAE'){
                Id detailId = detail.Id;
                Decimal amount;
                String type;
                if(detail.Type__c == 'LAE Payment' && detail.LAE_Amount__c > 0){
                    amount = detail.LAE_Amount__c;
                    type = 'LAE Pay';
                }else if(detail.Type__c == 'Loss Payment' && detail.Loss_Amount__c > 0){
                    amount = detail.Loss_Amount__c;
                    type = 'Loss Pay';
                }else if(detail.Type__c == 'Claim Coverage - ARDC' && detail.ISBA_First_Payment__c > 0){
                    amount = detail.ISBA_First_Payment__c;
                    type = detail.Type__c;
                }else if(detail.Type__c == 'Unallocated LAE Payment' && detail.LAE_Amount__c > 0){
                    amount = detail.LAE_Amount__c;
                    type = detail.Type__c;
                }else{
                    throw new AuraHandledException('Can\'t Reverse the entries') ;
                }
                System.debug(amount);
                System.debug(type);               
       
                List<String> payablefields = new List<String>(AcctSeed__Account_Payable__c.SObjectType.getDescribe().fields.getMap().keySet());
                List<String> lineFields = new List<String>(AcctSeed__Account_Payable_Line__c.SObjectType.getDescribe().fields.getMap().keySet());
                String soql = 'select ' + String.join(payablefields,',') + ',(select '+ String.join(lineFields,',') + ' from AcctSeed__Project_Account_Payable_Lines__r) from AcctSeed__Account_Payable__c where Policy_Claim_Detail__c =: detailId AND AcctSeed__Balance__c =: amount AND  Type__c=: type';
                System.debug('soql'+soql);
              
                List<AcctSeed__Account_Payable__c> payables = Database.query(soql);
                System.debug('payables---'+payables);
                if(payables.size() == 1){
                    if(payables[0].AcctSeed__Status__c != 'Posted'){
                        throw new AuraHandledException('Reversal Payable is not Posted.') ;
                    }
                    Policy_Claim_Detail__c newDetail = detail.clone(false, true, false, false);
                    if(detail.Type__c == 'LAE Payment'){
                        newDetail.LAE_Amount__c = amount * -1;
                    }else if(detail.Type__c == 'Loss Payment' && detail.Loss_Amount__c > 0){
                        newDetail.Loss_Amount__c = amount * -1;
                    }else if(detail.Type__c == 'Claim Coverage - ARDC' && detail.ISBA_First_Payment__c > 0){
                        newDetail.ISBA_First_Payment__c = amount * -1;
                    }else if(detail.Type__c == 'Unallocated LAE Payment' && detail.LAE_Amount__c > 0){
                        newDetail.LAE_Amount__c = amount * -1;
                    }
                    System.debug(newDetail.Loss_Amount__c+'<====newDetail---'+newDetail.Type__c);
                    newDetail.Date__c = System.today();
                    insert newDetail;
                    AcctSeed__Account_Payable__c newPayable = payables[0].clone(false, true, false, false);
                    newPayable.Policy_Claim_Detail__c = newDetail.Id;
                    newPayable.AcctSeed__Payee_Reference__c = 'Reverse ' + newPayable.AcctSeed__Payee_Reference__c ;
                    insert newPayable;
                    List<AcctSeed__Account_Payable_Line__c> newLines = new List<AcctSeed__Account_Payable_Line__c>();
                    for( AcctSeed__Account_Payable_Line__c line : payables[0].AcctSeed__Project_Account_Payable_Lines__r){
                        AcctSeed__Account_Payable_Line__c newLine = line.clone(false, true, false, false);
                        newLine.AcctSeed__Account_Payable__c = newPayable.Id;
                        newLine.AcctSeed__Amount__c = newLine.AcctSeed__Amount__c * -1;
                        newLines.add(newLine);
                    }
                    insert newLines;
                    AcctSeed.AccountPayablePostService.postAccountPayables(new AcctSeed__Account_Payable__c[]{newPayable});
                    AcctSeed__AP_Credit_Memo__c cm = new AcctSeed__AP_Credit_Memo__c();
                    cm.AcctSeed__Amount__c = - amount;
                    cm.AcctSeed__Account_Payable_Credit_Memo__c = newPayable.Id;
                    cm.AcctSeed__Account_Payable_Invoice__c = payables[0].Id;
                    cm.AcctSeed__Accounting_Period__c = periods[0].Id;
                    insert cm;
                }else if(payables.size() > 1){
                    throw new AuraHandledException('There are more than one payable. Please reverse entries manually. ') ;
                }else{
                    throw new AuraHandledException('Either there is no unpaid payable or payable partially paid. ') ;
                }
            }
        }catch(DmlException e){
            System.debug('Error----'+e.getMessage());
            System.debug('LIne-----'+e.getLineNumber());
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString()) ;
        }catch(LimitException e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString()) ;
        }catch(ListException e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString()) ;
        }catch(NullPointerException e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString()) ;
        }catch(QueryException e){
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString()) ;
        }
    }
}