public class CloneToOnlineAppCtrl {
	@AuraEnabled
    public static String getPolicy(String policyId){
        String message = '';
        Map<Id,Profile> profilesMap = new Map<Id,Profile>([select id from Profile where Name = 'System Administrator']);
        Policy__c objPolicy = [select Id,Account__r.Count_Active_Policies__c from Policy__c where Id =: policyId];
        if(objPolicy.Account__r.Count_Active_Policies__c > 0){
            message = 'Clone Online Application Blocked!';
        }else{
            message = createOnlineApp(policyId);
        }
        return message;
    }
    
    public static String createOnlineApp(String policyId){
        String customerAppRecordTypeId = [SELECT Id,Name,SObjectType FROM RecordType where SObjectType='Customer_Application__c' AND Name = 'New Business' Limit 1].Id;
        
        Policy__c pol = [SELECT Id, Name, Account__r.Open_Claims__c, Account__r.Name, Account__r.Trade_Name_or_D_B_A__c, Firm_Contact__r.Email, Firm_Contact__r.Phone, Firm_Contact__r.LastName, Firm_Contact__r.FirstName, Account__r.Website__c, Account__r.Establish_Date__c, Account__r.Phone, Account__r.Billing_Address_County__c, Account__r.BillingPostalCode, Account__r.BillingState, Account__r.BillingCity, Account__r.BillingStreet FROM Policy__c WHERE Id=:policyId];
        Account acc = pol.Account__r;
        
        Customer_Application__c capp = new Customer_Application__c();
        capp.RecordTypeId = customerAppRecordTypeId;
        capp.Full_Legal_Name_of_the_Firm__c = acc.Name;
        capp.Account__c = acc.Id;
        capp.Trade_Name_or_D_B_A__c = acc.Trade_Name_or_D_B_A__c;
        capp.Street__c = acc.BillingStreet;
        capp.City__c = acc.BillingCity;
        capp.State__c = acc.BillingState;
        capp.Zip_Code__c = acc.BillingPostalCode;
        capp.County__c = acc.Billing_Address_County__c;
        capp.Firm_Phone_Number__c = acc.Phone;
        capp.Website__c = acc.Website__c;
        capp.Date_Firm_Established__c = acc.Establish_Date__c;
        capp.Contact__c =  pol.Firm_Contact__c;
        capp.Contact_Name__c = pol.Firm_Contact__r.FirstName;
        capp.Contact_Last_Name__c = pol.Firm_Contact__r.LastName;
        capp.Contact_Phone_Number__c = pol.Firm_Contact__r.Phone;
        capp.Contact_E_mail_Address__c = pol.Firm_Contact__r.Email;
        Insert capp;
        
        List<String> fieldNames = new List<String>( Schema.getGlobalDescribe().get('Policy_Lawyer__c').getDescribe().fields.getMap().keySet() );
        String query =' SELECT Lawyer__r.Contact__c, Lawyer__r.Contact__r.MobilePhone, Lawyer__r.Contact__r.Personal_Email__c, Lawyer__r.Contact__r.Birthdate,' +String.join( fieldNames, ',' ) +' FROM Policy_Lawyer__c'  +' WHERE ' +' Policy__c =: policyId ' +'  AND  Deleted_Date__c = null';
        List<Customer_Application_Lawyer__c> applicationLawyerList = new List<Customer_Application_Lawyer__c>();
                    
        for (Policy_Lawyer__c law : Database.query(query)) {
            Customer_Application_Lawyer__c applicationLawyer = new Customer_Application_Lawyer__c();
            applicationLawyer.Name = law.First_Name_Contact__c;
            applicationLawyer.Contact__c = law.Lawyer__r.Contact__c;
            applicationLawyer.Middle_Initial__c  = law.Middle_Name_Contact__c ;
            applicationLawyer.Last_Name__c  = law.Last_Name_Contact__c;
            applicationLawyer.ISBA_Number__c = law.ISBA_Number__c; 
            applicationLawyer.ARDC_Number__c = law.ARDC_Number__c;
            applicationLawyer.Cell_Phone__c = law.Lawyer__r.Contact__r.MobilePhone;
            applicationLawyer.Birthday__c = law.Lawyer__r.Contact__r.Birthdate;
            applicationLawyer.Firm_Email_Address__c = law.Contact_Email__c;
            applicationLawyer.Personal_Email_Address__c = law.Lawyer__r.Contact__r.Personal_Email__c;
            applicationLawyer.Customer_Application__c = capp.Id;
            applicationLawyerList.add(applicationLawyer);
        }
        if(!applicationLawyerList.isEmpty()){
            Insert applicationLawyerList;
        }
        
        return capp.Id;
    }
}