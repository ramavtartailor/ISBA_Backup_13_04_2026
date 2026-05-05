public class ImportPayableLinesCtrl {
    
    @AuraEnabled
    public static DataWrapper getGLList(){
        DataWrapper dw = new DataWrapper();
        List<String> glNums = new List<String>{'6141%','6201%','6211%','6251%','6040%','6370%','6340%','6231%','6425%','6200%','6210%','6140%','6230%','6055%','6341%'};
            List<AcctSeed__GL_Account__c> glList = new List<AcctSeed__GL_Account__c>([SELECT Id, Name FROM AcctSeed__GL_Account__c WHERE Name like : glNums ]);
        List<AcctSeed__Accounting_Variable__c> glVar3List = new List<AcctSeed__Accounting_Variable__c>([SELECT Id, Name FROM AcctSeed__Accounting_Variable__c WHERE AcctSeed__Type__c = 'GL Account Variable 3' AND AcctSeed__Active__c = true]);
        dw.glList = glList;
        dw.glVar3List = glVar3List;
        return dw;
    }
    
    @AuraEnabled
    public Static boolean createPayableLines(String recId, List<csvWrapper> wrapList){
        try{
            List<AcctSeed__Account_Payable_Line__c> payableLines = new List<AcctSeed__Account_Payable_Line__c>();
            for(csvWrapper wrp: wrapList){
                AcctSeed__Account_Payable_Line__c apl = new AcctSeed__Account_Payable_Line__c();
                apl.AcctSeed__Date__c = wrp.dt;
                apl.AcctSeed__Amount__c = wrp.amount;
                apl.AcctSeed__Expense_GL_Account__c = wrp.gl;
                apl.AcctSeed__Internal_Comment__c = wrp.des;
                apl.AcctSeed__Account_Payable__c = recId;
                if(String.isNotBlank(wrp.glVar1)){
                    apl.AcctSeed__GL_Account_Variable_3__c = wrp.glVar1;
                }
                system.debug('apl =>'+apl);
                payableLines.add(apl);
            }        
            Insert payableLines;
            return true;
        }
        catch (DmlException ex){
            System.debug('Error-->> '+ex.getLineNumber() + '---'+ ex.getDMLMessage(0));
            AuraHandledException AuraError = new AuraHandledException( ex.getDMLMessage(0));
            AuraError.setMessage( ex.getDMLMessage(0));
            throw AuraError;
        }
    }
    
    @AuraEnabled
    public static List<csvWrapper> getCSVObject(String csv_str) {
        List<csvWrapper> csvWrapList = new List<csvWrapper>();
        try{
            List<String> lines_raw = csv_str.split('\n');
            List<List<String>> lines = new List<List<String>>();
            
            //remove first row
            lines_raw.remove(0);
            //Handling fields with commas
            for(String line : lines_raw) {
                
                List<String> line_sep = handlerCommaWithinColumn(line);
                
                List<String> fields = new List<String>();
                Boolean makeCompositeField = false;
                String compositeField;
                for(String field : line_sep) {
                    if (field.startsWith('"') && field.endsWith('"')) {
                        fields.add(field.trim());
                    } else if (field.startsWith('"')) {
                        makeCompositeField = true;
                        compositeField = field;
                    } else if (field.endsWith('"')) {
                        compositeField += ',' + field;
                        fields.add(compositeField.trim());
                        makeCompositeField = false;
                    } else if (makeCompositeField) {
                        compositeField +=  ',' + field;
                    } else {
                        fields.add(field.trim());
                    }
                }
                system.debug('rows =>> '+ fields);
                lines.add(fields);
            }
            
            for(List<String> obj : lines){
                csvWrapper cw = new csvWrapper();
                cw.dt = date.parse(obj[0]);
                cw.receipt = obj[1];
                cw.des = obj[2];
                cw.cardMember = obj[3];
                cw.accountNum = obj[4];
                cw.amount = Decimal.valueOf(obj[5].replaceAll('\\,', ''));
                cw.gl = null;
                cw.glVar1 = null;
                csvWrapList.add(cw);
                //Break;
            }
            system.debug(lines);
            return csvWrapList;
        }catch (Exception ex){
            System.debug('Error-->> '+ex.getLineNumber() + '---'+ ex.getMessage());
            AuraHandledException AuraError = new AuraHandledException( ex.getMessage());
            AuraError.setMessage( ex.getMessage());
            throw AuraError;
        }
    }
    
    public static List<String> handlerCommaWithinColumn(String csvLine){
        
        List<String> returnFields = new List<String>();
        String prevLine = csvLine;
        Integer startIndex;
        Integer endIndex;
        system.debug(csvLine+' => '+csvLine.indexOf('"'));
        while(csvLine.indexOf('"') > -1){
            if(startIndex == null){
                startIndex = csvLine.indexOf('"');
                csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
            }else{
                if(endIndex == null){
                    endIndex = csvLine.indexOf('"');
                    csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                }
            }
            if(startIndex != null && endIndex != null){
                String sub = csvLine.substring(startIndex, endIndex);
                sub = sub.replaceAll(',', ':comma:');
                csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                startIndex = null;
                endIndex = null;
            }
        }
        
        for(String column : csvLine.split(',')){
            column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
            returnFields.add(column);
        }
        System.debug('returnFields'+returnFields);
        return returnFields;
    }
    
    public class csvWrapper{
        @AuraEnabled
        public date dt{get;set;}
        @AuraEnabled
        public String receipt{get;set;}
        @AuraEnabled
        public String des{get;set;}
        @AuraEnabled
        public String cardMember{get;set;}
        @AuraEnabled
        public String accountNum{get;set;}
        @AuraEnabled
        public Decimal amount{get;set;}
        @AuraEnabled
        public String gl{get;set;}
        @AuraEnabled
        public String glVar1{get;set;}
    }
    
    public class DataWrapper{
        @AuraEnabled
        public List<AcctSeed__GL_Account__c> glList{get;set;}
        @AuraEnabled
        public List<AcctSeed__Accounting_Variable__c> glVar3List{get;set;}
    }
}