public class AttendanceCertificatePdfController {
    
    
    public decimal PR_MHSA{get;Set;}
	public decimal PR_DIV{get;Set;}
    public decimal PR_OTHER{get;Set;}
    public decimal PR_Total{get;Set;}
    public decimal General_Credit{get;Set;}
    
    public CLE_Attendance__c attendance{get;set;}
    
    public AttendanceCertificatePdfController(){
        String recId = '';
        if(Apexpages.currentpage().getparameters().get('id') != null){
            recId = Apexpages.currentpage().getparameters().get('id');
            system.debug('recId => '+recId);
        }
        
        if(String.isNotBlank(recId)){
            List<CLE_Attendance__c> CLE_AttList = new List<CLE_Attendance__c>([SELECT Id,CLE_Event__c,CLE_Event__r.General_Credit__c,CLE_Event__r.Event_Title__c,CLE_Event__r.Event_Location__c,CLE_Event__r.Date__c,PR_OTHER__c,PR_MHSA__c,PR_DIV__c,General_Credit__c,Lawyer_Participation_Method__c,Attorney_Attended__c,Contact__r.Name, Contact__r.ARDC_Number__c FROM CLE_Attendance__c WHERE Id=: recId limit 1]);
            attendance = new CLE_Attendance__c();
            if(!CLE_AttList.isEmpty()){
                attendance = CLE_AttList[0];
            }
            General_Credit = CLE_AttList[0].General_Credit__c != null ? CLE_AttList[0].General_Credit__c : 0.00;
            PR_MHSA = CLE_AttList[0].PR_MHSA__c != null ? CLE_AttList[0].PR_MHSA__c : 0.00;
            PR_DIV = CLE_AttList[0].PR_DIV__c != null ? CLE_AttList[0].PR_DIV__c : 0.00;
            PR_OTHER = CLE_AttList[0].PR_OTHER__c != null ? CLE_AttList[0].PR_OTHER__c : 0.00;
            PR_Total = PR_MHSA + PR_DIV + PR_OTHER;
            
            system.debug('attendance => '+attendance);
        }
    }

}