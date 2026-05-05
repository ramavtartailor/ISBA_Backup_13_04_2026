public with sharing class RegenerateCustomerApplicationCtrl {
    
    public class RegenerateCustomerApplicationCtrlException extends Exception{}
    
    @auraEnabled
    public Static boolean updateDetails(String recId){
        try{
            if(String.isNotBlank(recId)){
                PolicyTriggerHandler.changeToRegularRenewal(new Set<String>{recId});//updated on Jan 8 2026
            }
            else{
                throw new RegenerateCustomerApplicationCtrlException('Record Not Found.');
            }
            /**Policy__c pol = [SELECT Id, Customer_Application__c, Effective_Date__c, Account__r.Name, Account__r.Trade_Name_or_D_B_A__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.Billing_Address_County__c, Account__r.Phone, Account__r.Website__c, Account__r.Establish_Date__c, Firm_Contact__r.FirstName, Firm_Contact__r.LastName, Firm_Contact__r.Phone, Firm_Contact__r.Email,
                             (SELECT First_Name_Contact__c, Middle_Name_Contact__c, Last_Name_Contact__c, ISBA_Number__c , ARDC_Number__c, Lawyer__r.Contact__r.Cell_Phone__c, Lawyer__r.Contact__r.Birthdate, Contact_Email__c, Lawyer__r.Contact__r.Personal_Email__c FROM Policy_Lawyers__r),//lawyer
                             (SELECT Id FROM Policy_Quotes__r WHERE Customer_Application__c = null)//quotes
                             FROM Policy__c WHERE Id=:recId LIMIT 1];
            
            
            Customer_Application__c  capp = new Customer_Application__c();
            
            List<Customer_Application__c> cappList = new List<Customer_Application__c>();
            
            
            if(String.isNotBlank(pol.Customer_Application__c)){
                cappList = [SELECT Id, 
                            (SELECT Id FROM Customer_Application_Lawyers__r), 
                            (SELECT Id FROM Quotes__r WHERE Policy__c !=: recId) 
                            FROM Customer_Application__c WHERE Id=: pol.Customer_Application__c LIMIT 1];
            }
            
            
            if(!cappList.isEmpty()){
               capp.Id = cappList[0].Id;
            }
            else{
                String customerAppRecordTypeId = [SELECT Id,Name,SObjectType FROM RecordType where SObjectType='Customer_Application__c' AND Name = 'Regular Renewal' Limit 1].Id;
                capp.RecordTypeId = customerAppRecordTypeId;
            }
            List<Customer_Application_Lawyer__c> lawyersToDelete = new List<Customer_Application_Lawyer__c>();
            List<Customer_Application_Lawyer__c> lawyersToInsert = new List<Customer_Application_Lawyer__c>();
            
            List<Policy_Quote__c> quotesToDelete = new List<Policy_Quote__c>();
            List<Policy_Quote__c> quotesToUpdate = new List<Policy_Quote__c>();
            
            capp.Effective_Date_Requested__c  = pol.Effective_Date__c;
            capp.Full_Legal_Name_of_the_Firm__c = pol.Account__r.Name;
            capp.Trade_Name_or_D_B_A__c = pol.Account__r.Trade_Name_or_D_B_A__c;
            capp.Street__c = pol.Account__r.BillingStreet;
            capp.City__c = pol.Account__r.BillingCity;
            capp.State__c = pol.Account__r.BillingState;
            capp.Zip_Code__c = pol.Account__r.BillingPostalCode;
            capp.County__c = pol.Account__r.Billing_Address_County__c;
            capp.Firm_Phone_Number__c = pol.Account__r.Phone;
            capp.Website__c = pol.Account__r.Website__c;
            capp.Date_Firm_Established__c = pol.Account__r.Establish_Date__c;
            capp.Contact_Name__c = pol.Firm_Contact__r.FirstName;
            capp.Contact_Last_Name__c = pol.Firm_Contact__r.LastName;
            capp.Contact_Phone_Number__c = pol.Firm_Contact__r.Phone;
            capp.Contact_E_mail_Address__c = pol.Firm_Contact__r.Email;
            capp.PolicyId__c = pol.Id;
            upsert capp;
            
            
            if(cappList.isEmpty()){
                Site mySite = [select Id from Site where Name = 'Customer_Application'];
                SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite.Id];
                pol.Customer_Application__c = capp.Id;
                capp.Form_Link__c = mySiteDetail.SecureURL + '?id=' + EncodingUtil.urlEncode(PaymentGateway_Ctrl.processEncryption(capp.Id,Label.Encryption_Key_Payment_Id),'UTF-8'); 
                Update pol;
                Update capp;
            }
            
            for(Policy_Lawyer__c law : pol.Policy_Lawyers__r){
                Customer_Application_Lawyer__c applicationLawyer = new Customer_Application_Lawyer__c();
                applicationLawyer.Name = law.First_Name_Contact__c;
                applicationLawyer.Middle_Initial__c  = law.Middle_Name_Contact__c ;
                applicationLawyer.Last_Name__c  = law.Last_Name_Contact__c;
                applicationLawyer.ISBA_Number__c = law.ISBA_Number__c; 
                applicationLawyer.ARDC_Number__c = law.ARDC_Number__c;
                applicationLawyer.Cell_Phone__c = law.Lawyer__r.Contact__r.Cell_Phone__c;
                applicationLawyer.Birthday__c = law.Lawyer__r.Contact__r.Birthdate;
                applicationLawyer.Firm_Email_Address__c = law.Contact_Email__c;
                applicationLawyer.Personal_Email_Address__c = law.Lawyer__r.Contact__r.Personal_Email__c;
                applicationLawyer.Customer_Application__c = pol.Customer_Application__c;
                lawyersToInsert.add(applicationLawyer);
            }
            
            if(!lawyersToInsert.isEmpty()){
                Insert lawyersToInsert;
            }
            
            if(!cappList.isEmpty()){
				system.debug('deleting lawyer and qoutes');
                system.debug('Lawyers =>'+ cappList[0].Customer_Application_Lawyers__r);
                
                if(!cappList[0].Customer_Application_Lawyers__r.isEmpty()){                    
                    lawyersToDelete.addAll(cappList[0].Customer_Application_Lawyers__r);
                    system.debug('deleting lawyers =>'+lawyersToDelete);
                    Delete lawyersToDelete;
                }
                system.debug('Quotes => '+cappList[0].Quotes__r);
                if(!cappList[0].Quotes__r.isEmpty()){
                    quotesToDelete.addAll(cappList[0].Quotes__r);
                    system.debug('deleting Quotes => '+quotesToDelete);
                    Delete quotesToDelete;
                }
            }
            if(!pol.Policy_Quotes__r.isEmpty()){
                List<Policy__c> bucketAccountPolicies = new List<Policy__c>([select id from Policy__c where Account__r.Name=: Label.Online_NBA_Account ]);
                List<String> fieldNames = new List<String>( Schema.getGlobalDescribe().get('Policy_Quote__c').getDescribe().fields.getMap().keySet() );
                String query =' SELECT ' +String.join( fieldNames, ',' ) +' FROM Policy_Quote__c'  +' WHERE ' +' Policy__c =: recId ';
                for (Policy_Quote__c quo : Database.query(query)) {
                    Policy_Quote__c newQuote = new Policy_Quote__c();
                    newQuote = quo.Clone(false, true);
                    newQuote.Policy__c = bucketAccountPolicies[0].Id;
                    newQuote.Customer_Application__c = pol.Customer_Application__c;
                    quotesToUpdate.add(newQuote);
                }
                Insert quotesToUpdate;
            }/**/
            return true;
        } 
        catch(exception e){
            system.debug('Error => '+e.getMessage()+' => '+ e.getLineNumber());
            throw new RegenerateCustomerApplicationCtrlException(e.getMessage());
        }
    }
    
}