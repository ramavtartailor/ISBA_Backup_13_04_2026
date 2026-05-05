public class QuickNoteCtrl {
	@AuraEnabled
    public Static Contact getData(String recId){
        List<Contact> con = new List<Contact>([select Id,ISBAM_Rating_Last_Update__c, ISBAM_Quick_Note__c FROM Contact WHERE Id =:recId limit 1]);
        if(con.isEmpty()){
            return null;
        }
        return con[0];
    }
    @AuraEnabled
    public Static boolean updateData(String recId, String note){
        Contact con = new Contact();
        con.Id = recId;
        con.ISBAM_Quick_Note__c = note;
        //con.ISBAM_Rating_Last_Update__c = system.today();
        update con;
        return true;
    }
}