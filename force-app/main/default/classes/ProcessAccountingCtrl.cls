public class ProcessAccountingCtrl {
    @AuraEnabled
    public static void processAccounting(String recordId){
        SavePoint sp = Database.setSavepoint();
        try{
            String objName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            if(objName == 'Policy__c'){
                List<Policy__c> policy = new List<Policy__c>([select id,Accounting_Processed__c,Bound_Date__c from Policy__c where id =: recordId]);
                if(policy.size()>0){
                    if(!policy[0].Accounting_Processed__c){
                        if(policy[0].Bound_Date__c != null && policy[0].Bound_Date__c >= Date.newInstance(2020, 10, 16)){
                            Set<Id> policyIdsSet = new Set<Id>();
                            policyIdsSet.add(policy[0].Id);
                            ApplicationPolicyUtil.CreateAccuntingSeedsForPolicy(policyIdsSet);
                        }else{
                            throw new AuraHandledException('Accounting Can not be processed on this Policy') ;
                        }
                    }else{
                        System.debug('Here');
                        throw new AuraHandledException('Accounting has already been processed.') ;
                    }
                }else{
                    throw new AuraHandledException('Invalid Record Id') ;
                }
            }else if(objName == 'Policy_Endorsement__c'){
                List<Policy_Endorsement__c> endorsements = new List<Policy_Endorsement__c>([select id,Endorsement_Number__c,Accounting_Processed__c,Premium__c,Account__c,Policy__c,Premium_5_5__c,Premium_10_10__c,Primary__c,Excess__c,Event_Status__c,GL_Processing_Date__c,Endorsement_Effective_Date__c from Policy_Endorsement__c where id =: recordId]);
                if(endorsements.size() > 0){
                    if(endorsements[0].Event_Status__c == 'Complete' && !endorsements[0].Accounting_Processed__c){
                        if(endorsements[0].Endorsement_Number__c == 'IL 152' || endorsements[0].Endorsement_Number__c == 'IL 153'  || endorsements[0].Endorsement_Number__c == 'IL 107' || endorsements[0].Endorsement_Number__c == 'IL 190'){
                            List<AS_Transaction__c> lstASTransaction = new List<AS_Transaction__c>();
                            if(endorsements[0].Endorsement_Number__c == 'IL 152'){
                                lstASTransaction = PolicyEndorsementGateway.getIL_152_Transactions(endorsements[0]);
                            }else if(endorsements[0].Endorsement_Number__c == 'IL 153'){
                                lstASTransaction = PolicyEndorsementGateway.getIL_153_Transactions(endorsements[0]);
                            }else if(endorsements[0].Endorsement_Number__c == 'IL 190'){
                                lstASTransaction = PolicyEndorsementGateway.getIL_190_Transactions(endorsements[0]);
                            }else if(endorsements[0].Endorsement_Number__c == 'IL 107'){
                                lstASTransaction = PolicyEndorsementGateway.getERE_Transactions(endorsements[0]);
                            }
                            if(lstASTransaction.size() > 0){
                                insert lstASTransaction;
                                endorsements[0].Accounting_Processed__c = true;
                                if(endorsements[0].GL_Processing_Date__c == null){
                                    endorsements[0].GL_Processing_Date__c = (endorsements[0].Endorsement_Effective_Date__c >= System.today() ? endorsements[0].Endorsement_Effective_Date__c : System.today());
                                }
                                update endorsements[0];
                            }
                        }else{
                            throw new AuraHandledException('Accounting Process Not Valid On this Particular Endorsement.') ;
                        }
                    }else{
                        throw new AuraHandledException('Either Endorsement is not Approved or accounting has already been processed.') ;
                    }
                }else{
                    throw new AuraHandledException('Invalid Record Id') ;
                }
                //currentEnd.Endorsement_Sub_Type__c == 'IL 152';
                //lstASTransaction = getIL_152_Transactions(polEnd);
                //List<>
                /*if(){
                    
                }*/
            }else{
                throw new AuraHandledException('Invalid Record Id') ;
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