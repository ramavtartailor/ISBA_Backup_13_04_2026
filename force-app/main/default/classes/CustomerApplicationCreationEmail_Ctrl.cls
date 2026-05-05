public class CustomerApplicationCreationEmail_Ctrl {
    public Id customerAppId;
    public String salesforceBaseURL{get;set;}
    public Customer_Application__c application{get;set;}
    public List<Policy_Quote__c> quotes{get;set;}
    public List<Customer_Application_Lawyer__c> lawyers{get;set;}
    public List<Customer_Application_AOP__c> aopList{get;set;}
    public CustomerApplicationCreationEmail_Ctrl(){
		salesforceBaseURL=System.URL.getOrgDomainUrl().toExternalForm();
    }
    public void setCustomerAppId(Id customerAppId){
        DescribeSObjectResult describeResult = Customer_Application__c.getSObjectType().getDescribe();
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        fieldNames.add('County__r.Name');
        String query =	  ' SELECT RecordType.Name,' +	      String.join( fieldNames, ',' ) +	  ' FROM ' +	      describeResult.getName() +	  ' WHERE ' +	      ' id = :customerAppId ' +	  ' LIMIT 1 '	;	
        if(customerAppId == null){
            application = new Customer_Application__c();
        }else{
            if(!salesforceBaseURL.endsWith('/view')){
               salesforceBaseURL = salesforceBaseURL.removeEnd('my.salesforce.com');
               salesforceBaseURL+= 'lightning.force.com/lightning/r/Customer_Application__c/'+customerAppId+'/view'; 
            }
            application = Database.query( query );
            quotes = new List<Policy_Quote__c>([select id,Coverage__r.Name,Deductible__r.Name from Policy_Quote__c where Customer_Application__c=:customerAppId ]);
            lawyers = new List<Customer_Application_Lawyer__c>([select id,Name,Middle_Initial__c,Last_Name__c,Designation__c,Date_of_Hire__c,ISBA_Number__c,ARDC_Number__c,Average_Number_of_Hours_Worked__c,Firm_Email_Address__c,Birthday__c,Cell_Phone__c,Personal_Email_Address__c from Customer_Application_Lawyer__c where Customer_Application__c=:customerAppId]);
            aopList = new List<Customer_Application_AOP__c>([SELECT Id, Percentage__c, AOP_Factor__r.Name FROM Customer_Application_AOP__c WHERE Customer_Application__c =:customerAppId and Percentage__c>0]);
        }
    }
    public Id getCustomerAppId(){
        return customerAppId;
    }
}