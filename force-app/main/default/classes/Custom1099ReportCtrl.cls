public with sharing class Custom1099ReportCtrl {
    @AuraEnabled
    public static List<Wrapper> RunReport(String reportType, Date startDate, Date endDate){
        try {
            String query = 'SELECT AcctSeed__Vendor__c vendor,sum(AcctSeed__Amount__c) amount FROM AcctSeed__Cash_Disbursement__c where AcctSeed__Vendor__r.AcctSeed__X1099_Vendor__c =true AND AcctSeed__Disbursement_Date__c >='+String.valueOf(startDate).substringBefore('T00')+' And AcctSeed__Disbursement_Date__c <='+String.valueOf(endDate).substringBefore('T00')+' and AcctSeed__Void_Date__c = null group by AcctSeed__Vendor__c limit 5000';
			system.debug('query => '+query);
            List<AggregateResult> results = Database.query(query); 


            Set<String> vendorIds = new Set<String>();
            Map<String,Decimal> vendorAmountMap = new Map<String,Decimal>();
            for(AggregateResult ar : results){
                vendorIds.add((String)ar.get('vendor'));
                vendorAmountMap.put((String)ar.get('vendor'),(Decimal)ar.get('amount'));
            }

            List<Account> vendors = [SELECT Id, Name, X1099_Vendor__c, BillingStreet, BillingCity, BillingState,  BillingPostalCode FROM Account WHERE Id IN :vendorIds order by Name];

            List<Wrapper> wrapList = new List<Wrapper>();

            for(Account vendor : vendors){
                Wrapper wrapObj = new Wrapper();
                wrapObj.recId = vendor.Id;
                wrapObj.vendorName = vendor.Name;
                wrapObj.amount = vendorAmountMap.get(vendor.Id);
                wrapObj.vendor1099 = vendor.X1099_Vendor__c;
                wrapObj.payeeStreet = vendor.BillingStreet;
                wrapObj.payeeCity = vendor.BillingCity;
                wrapObj.payeeState = vendor.BillingState;
                wrapObj.payeePostalCode = vendor.BillingPostalCode;
                wrapList.add(wrapObj);
            } 
            return wrapList;
        } catch (Exception e) {
            system.debug('Error => '+e.getMessage()+' \nat => '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class Wrapper {
        @AuraEnabled
        public String recId{get;set;}
        @AuraEnabled
        public String vendorName{get;set;}
        @AuraEnabled
        public Decimal amount{get;set;}
        @AuraEnabled
        public String vendor1099 {get;set;}
        @AuraEnabled
        public String payeeStreet{get;set;}
        @AuraEnabled
        public String payeeCity{get;set;}
        @AuraEnabled
        public String payeeState{get;set;}
        @AuraEnabled
        public String payeePostalCode{get;set;}

        public Wrapper() {
            this.recId = '';
            this.vendorName = '';
            this.amount = 0.00;
            this.vendor1099 = '';
            this.payeeStreet = '';
            this.payeeCity = '';
            this.payeeState = '';
            this.payeePostalCode = '';
        }
    }
}