public class PrintCheckPageBatchController {
    public List<pdfWrp> pdfWrpList{get;set;}
    
    public PrintCheckPageBatchController(ApexPages.StandardController stdController) {
        pdfWrpList = new List<pdfWrp>();
        String recId = stdController.getId();
        List<AcctSeed__Cash_Disbursement__c> casObjList = new List<AcctSeed__Cash_Disbursement__c>([select id, AcctSeed__AP_Voucher_Count__c,AcctSeed__Payee__c,AcctSeed__Disbursement_Date__c,
                AcctSeed__Amount__c,AcctSeed__Payee_Street__c,AcctSeed__Payee_City_State_Zip__c,
                AcctSeed__Payee_Country__c,AcctSeed__Check_Number__c from AcctSeed__Cash_Disbursement__c where AcctSeed__Cash_Disbursement_Batch__c=:recId]);
        
        Map<id,List<AcctSeed__AP_Disbursement__c>> apListMap = new Map<id,List<AcctSeed__AP_Disbursement__c>>();
        for(AcctSeed__AP_Disbursement__c apObj : [select id, AcctSeed__Account_Payable__r.Name, AcctSeed__Payee_Reference__c, AcctSeed__Payable_Amount__c,
                                                  AcctSeed__Discount_Amount__c,AcctSeed__Net_Amount__c,AcctSeed__Applied_Date__c,
                                                  AcctSeed__Account_Payable__r.AcctSeed__Type__c,AcctSeed__Cash_Disbursement__r.id, AcctSeed__Paid_Amount__c  from AcctSeed__AP_Disbursement__c where 
                                                  AcctSeed__AP_Disbursement__c.AcctSeed__Cash_Disbursement__r.id in :casObjList]){
                                                      List<AcctSeed__AP_Disbursement__c> apList = new List<AcctSeed__AP_Disbursement__c>();
                                                      if(apListMap.containsKey(apObj.AcctSeed__Cash_Disbursement__r.id)){
                                                          apList.addAll(apListMap.get(apObj.AcctSeed__Cash_Disbursement__r.id));
                                                      }
                                                      apList.add(apObj);
                                                      apListMap.put(apObj.AcctSeed__Cash_Disbursement__r.id,apList);
                                                  }
        
        for(AcctSeed__Cash_Disbursement__c casObj : casObjList){
            Integer records;
            if(casObj.AcctSeed__AP_Voucher_Count__c>10){
                records=10;
            }
            else{
                records=Integer.valueOf(casObj.AcctSeed__AP_Voucher_Count__c);
            }
            
            String words = '';
            Integer DecimalValue = Integer.valueOf((casObj.AcctSeed__Amount__c - math.floor(casObj.AcctSeed__Amount__c)) * 100);
            if(DecimalValue == 0){
                Integer TotalInWord = Integer.valueOf(casObj.AcctSeed__Amount__c);
                Words = AnountInWords(TotalInWord);
            }else{
                Integer TotalInWord = Integer.valueOf(casObj.AcctSeed__Amount__c);
                Words = AnountInWords(TotalInWord)+' '+DecimalValue+'/100';
            }
            
            pdfWrpList.add(new pdfWrp(casObj,apListMap.get(casObj.id),words,records));
        }
    } 
    
    public string AnountInWords(Integer Amount){
        if(Amount == 1)
            return 'One';
        if(Amount == 2)
            return 'Two';
        if(Amount == 3)
            return 'Three';
        if(Amount == 4)
            return 'Four';
        if(Amount == 5)
            return 'Five';
        if(Amount == 6)
            return 'Six';
        if(Amount == 7)
            return 'Seven';
        if(Amount == 8)
            return 'Eight';
        if(Amount == 9)
            return 'Nine';
        if(Amount == 10)
            return 'Ten';
        if(Amount == 11)
            return 'Eleven';
        if(Amount == 12)
            return 'Twelve';
        if(Amount == 13)
            return 'Thirteen';
        if(Amount == 14)
            return 'Fourteen';
        if(Amount == 15)
            return 'Fifteen';
        if(Amount == 16)
            return 'Sixteen';
        if(Amount == 17)
            return 'Seventeen';
        if(Amount == 18)
            return 'Eighteen';
        if(Amount == 19)
            return 'Nineteen';
        if(Amount == 20)
            return 'Twenty';
        if(Amount > 20 && Amount < 100){
            if(math.mod(Amount, 10) == 0){
                if(Amount == 20)
                    return 'Twenty';
                if(Amount == 30)
                    return 'Thirty';
                if(Amount == 40)
                    return 'Fourty';
                if(Amount == 50)
                    return 'Fifty';
                if(Amount == 60)
                    return 'Sixty';
                if(Amount == 70)
                    return 'Seventy';
                if(Amount == 80)
                    return 'Eighty';
                if(Amount == 90)
                    return 'Ninety';
            }else{
                if(Amount/10 == 2)
                    return 'Twenty '+AnountInWords(math.mod(Amount, 10));
                if(Amount/10 == 3)
                    return 'Thirty '+AnountInWords(math.mod(Amount, 10));
                if(Amount/10 == 4)
                    return 'Fourty '+AnountInWords(math.mod(Amount, 10));
                if(Amount/10 == 5)
                    return 'Fifty '+AnountInWords(math.mod(Amount, 10));
                if(Amount/10 == 6)
                    return 'Sixty '+AnountInWords(math.mod(Amount, 10));
                if(Amount/10 == 7)
                    return 'Seventy '+AnountInWords(math.mod(Amount, 10));
                if(Amount/10 == 8)
                    return 'Eighty '+AnountInWords(math.mod(Amount, 10));
                if(Amount/10 == 9)
                    return 'Ninety '+AnountInWords(math.mod(Amount, 10));
            }
        }
        if(Amount >= 100 && Amount < 1000){
            string str = AnountInWords(Amount/100);
            if(math.mod(Amount, 100) == 0){
                str = str + ' Hundred';
            }else{
                str = str + ' Hundred ' + AnountInWords(math.mod(Amount, 100));
            }
            return str;
        }
        if(Amount >= 1000 && Amount < 1000000){
            string str = AnountInWords(Amount/1000);
            if(math.mod(Amount, 1000) == 0){
                str = str + ' Thousand';
            }else{
                str = str + ' Thousand ' + AnountInWords(math.mod(Amount, 1000));
            }
            return str;
        }
        if(Amount >= 1000000 && Amount < 1000000000){
            string str = AnountInWords(Amount/1000000);
            if(math.mod(Amount, 1000000) == 0){
                str = str + ' Million';
            }else{
                str = str + ' Million ' + AnountInWords(math.mod(Amount, 1000000));
            }
            return str;
        }
        return null;
        
    }
    
    public class pdfWrp{
        public list<AcctSeed__AP_Disbursement__c> apList{get;set;}
        public AcctSeed__Cash_Disbursement__c casObj{get;set;}
        public string Words {get; set;}
        public integer records{get; set;}
        public pdfWrp(AcctSeed__Cash_Disbursement__c casObj,list<AcctSeed__AP_Disbursement__c> apList1,string Words1,integer records1){
            this.casObj = casObj;
            this.apList = apList1;
            this.Words = Words1;
            this.records = records1;
        }
    }
}