public class GeneratePositivePayController {

    public class GeneratePositivePayException extends Exception {}

    @AuraEnabled
    public static Boolean generateFile(String recId){
        generateCSV(new List<String>{recId});
        return true;
    }

	@AuraEnabled
    public static void generateCsv(List<String> recIds){
        try{
            List<AcctSeed__Cash_Disbursement_Batch__c> records = [SELECT Id, Name,(SELECT Id,AcctSeed__Bank_Account__r.Bank_Account_Number__c,AcctSeed__Check_Number__c,AcctSeed__Disbursement_Date__c,AcctSeed__Payee__c,AcctSeed__Amount__c FROM AcctSeed__Cash_Disbursements__r) FROM AcctSeed__Cash_Disbursement_Batch__c WHERE Id IN:recIds];
            DateTime tempDate = system.now();
            
            Map<String,ContentVersion> cvMap = new Map<String,ContentVersion>();
            
            for(AcctSeed__Cash_Disbursement_Batch__c record :records){
                String title = record.Name + tempDate.Year() + String.valueOf(tempDate.Month()).leftPad(2,'0') + String.valueOf(tempDate.Day()).leftPad(2,'0') + '_' + String.valueOf(tempDate.Hour()).leftPad(2,'0') + String.valueOf(tempDate.minute()).leftPad(2,'0') + String.valueOf(tempDate.second()).leftPad(2,'0');
                String csvString = '';//"A","B","C","D","E","F","G"\n
                for(AcctSeed__Cash_Disbursement__c cd: record.AcctSeed__Cash_Disbursements__r){
                    csvString += '"'+cd.AcctSeed__Bank_Account__r.Bank_Account_Number__c+'",';
                    csvString += '"'+(cd.AcctSeed__Check_Number__c != null ? String.valueOf(cd.AcctSeed__Check_Number__c) : '') +'",';
                    csvString += ''+cd.AcctSeed__Amount__c+',';
                    String dt = String.valueOf(cd.AcctSeed__Disbursement_Date__c.Month()).leftPad(2,'0')  + String.valueOf(cd.AcctSeed__Disbursement_Date__c.Day()).leftPad(2,'0') + cd.AcctSeed__Disbursement_Date__c.Year();
                    csvString += ''+dt+',';
                    csvString += '"IS",';
                    csvString += '"'+cd.AcctSeed__Payee__c+'",'; 
                    csvString += '""\n'; 
                }
                
                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S'; //denotes it resides on Salesforce
                cv.Title = title; //title of the file
                cv.PathOnClient = title+'.txt'; // full path within Salesforce this can just be the name of file to be in the library
                cv.VersionData = Blob.valueOf(csvString); //file data
                cvMap.put(record.Id, cv);
            }
            if(!cvMap.KeySet().isEmpty()){
                insert cvMap.values();
                Set<string> cvIds = new Set<String>();
                for(contentVersion cv: cvMap.Values()){
                    cvIds.add(cv.Id);
                }
                Map<String,ContentVersion> cvMapNew = new Map<String,ContentVersion>([SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN: cvIds]);
                List<ContentDocumentLink> ContentDocumentLinks = new List<ContentDocumentLink>();
                for(String key : cvMap.KeySet()){
                    ContentDocumentLink  cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = cvMapNew.get(cvMap.get(key).Id).ContentDocumentId;
                    cdl.LinkedEntityId = key;
                    cdl.Visibility = 'AllUsers';
                    cdl.ShareType = 'I';
                    ContentDocumentLinks.add(cdl);
                }
                insert ContentDocumentLinks;
            }
        }
        catch(DmlException e){
            system.debug('Exception is : '+e.getDmlMessage(0)); 
            throw new GeneratePositivePayException(e.getDmlMessage(0));
        }
        catch(Exception e){
            system.debug('Exception is : '+e.getMessage()); 
            throw new GeneratePositivePayException(e.getMessage());
        }
    }
}