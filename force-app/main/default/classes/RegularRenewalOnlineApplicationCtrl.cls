public class RegularRenewalOnlineApplicationCtrl {
    
    public String objId {get; set;}
    public String recordId{get;set;}
    
    public RegularRenewalOnlineApplicationCtrl() {
        if (apexpages.currentpage().getparameters().get('id') != null){
            recordId = apexpages.currentpage().getparameters().get('id');
        }else{
            recordId = objId;
        }
        system.debug('recId => '+recordId);
        if(String.isNotBlank(recordId)){
            getObj();
        }
    }
    
    public Wrapper getObj() {
        system.debug('recId => '+recordId);
        Id recId = recordId;
        String sObjName = recId.getSObjectType().getDescribe().getName();
        Wrapper objNew = new Wrapper();
        
        if(sObjName == 'Policy__c'){
            Policy__c pol = [SELECT Id,Firm_Contact_First_Name__c,Firm_Contact_Last_Name__c,Customer_Application__r.Form_Link__c,Underwriter_User__r.Name,Underwriter_User_Title__c,Underwriter_Direct_Phone__c,Underwriter_Email__c FROM Policy__c WHERE Id=: recordId];
            objNew.name = pol.Firm_Contact_First_Name__c;
            objNew.name += String.isNotBlank(pol.Firm_Contact_Last_Name__c) ? ' ' + pol.Firm_Contact_Last_Name__c : '';
            objNew.link = pol.Customer_Application__r.Form_Link__c;
            objNew.underwriter_User = pol.Underwriter_User__r.Name;     
            objNew.underwriter_Title = pol.Underwriter_User_Title__c;   
            objNew.underwriter_Phone = pol.Underwriter_Direct_Phone__c;    
            objNew.underwriter_Email = pol.Underwriter_Email__c;
        }
        else if(sObjName == 'Customer_Application__c'){
            Customer_Application__c app = [SELECT Id,Contact_Name__c,Contact_Last_Name__c,Form_Link__c,PolicyId__r.Underwriter_User__r.Name,PolicyId__r.Underwriter_User_Title__c,PolicyId__r.Underwriter_Direct_Phone__c,PolicyId__r.Underwriter_Email__c FROM Customer_Application__c WHERE Id=: recordId];
            objNew.name = app.Contact_Name__c;
            objNew.name += String.isNotBlank(app.Contact_Last_Name__c) ? ' ' + app.Contact_Last_Name__c : '';
            objNew.link = app.Form_Link__c;
            objNew.underwriter_User = app.PolicyId__r.Underwriter_User__r.Name;     
            objNew.underwriter_Title = app.PolicyId__r.Underwriter_User_Title__c;   
            objNew.underwriter_Phone = app.PolicyId__r.Underwriter_Direct_Phone__c;    
            objNew.underwriter_Email = app.PolicyId__r.Underwriter_Email__c;
        }
        return objNew;
    }
    
    public class Wrapper {
        public String name {get; set;}
        public String link {get; set;}
        public String underwriter_User {get; set;}
        public String underwriter_Title {get; set;}
        public String underwriter_Phone {get; set;}
        public String underwriter_Email {get; set;}
        public Wrapper(){
            name = null;
            link = null;
            underwriter_User = null;
            underwriter_Title = null;
            underwriter_Phone = null;
            underwriter_Email = null;
        }
    }
}