/*
Created By      :   Shoukat Hussain
Created Date    :   6/1/2016
Purpose         :   Only system adminstrator can delete contacts.
*/

trigger Trg_Contact on Contact (before delete) {
    if(Trigger.isDelete && Trigger.isbefore){
        List<Profile> ProfileName = [select Name from profile WHERE id = :userinfo.getProfileId() limit 1]; 
        system.debug('ProfileName '+ProfileName);
        for (contact cont: Trigger.old) {
           if (profilename[0].name!='System Administrator'){
                cont.addError('Only a system admin can delete contact.\nPlease contact your system administrator for assistance.');
            }
       }
   }
}