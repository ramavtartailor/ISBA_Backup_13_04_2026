public class NBA_ConvertValidationCtrl {
    @AuraEnabled
    public static List<String> getDetails(String recId){
        List<String> valList = new List<String>();
	
        List<Customer_Application__c> capp = new List<Customer_Application__c>([SELECT Id, Account__c,Contact__c,(SELECT Id,Contact__c FROM Customer_Application_Lawyers__r) FROM Customer_Application__c WHERE Id =: recId]);
	
        if(!capp.isEmpty()){
            if(!String.isNotBlank(capp[0].Account__c)){
                valList.add('Account not linked.');
            }
            if(!String.isNotBlank(capp[0].Contact__c)){
                valList.add('Contact not linked.');
            }
            Boolean Flag = false;
            for(Customer_Application_Lawyer__c law: capp[0].Customer_Application_Lawyers__r){
                if(!String.isNotBlank(law.Contact__c)){
                    Flag = true;
                }
            }
            
            if(flag){
                valList.add('Lawyer(s) not linked.');
            }
        }
        return valList;
    }

}